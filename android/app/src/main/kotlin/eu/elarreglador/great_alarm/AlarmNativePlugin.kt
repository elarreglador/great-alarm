package eu.elarreglador.great_alarm

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.graphics.drawable.Icon
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

private const val CHANNEL_NAME = "eu.elarreglador.great_alarm/native"
private const val PREFS_NAME = "great_alarm_native"
private const val KEY_SCHEDULE = "schedule"
private const val KEY_RINGING = "ringing"
private const val ACTION_SILENCE = "eu.elarreglador.great_alarm.SILENCE"
private const val RINGING_CHANNEL = "great_alarm_ringing"
private const val RINGING_NOTIFICATION_ID = 4242
private const val MAX_RINGING_MS = 5 * 60 * 1000L

private fun prefs(context: Context) =
    context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

private fun stopRinging(context: Context) {
    prefs(context).edit().remove(KEY_RINGING).apply()
    context.stopService(Intent(context, AlarmRingingService::class.java))
}

private fun scheduleAll(context: Context) {
    val raw = prefs(context).getString(KEY_SCHEDULE, null) ?: return
    val manager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    val specs = JSONArray(raw)
    for (i in 0 until specs.length()) {
        val spec = specs.getJSONObject(i)
        val id = spec.getInt("notificationId")
        val trigger = spec.getLong("triggerMillis")
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            putExtra("alarmId", spec.getInt("alarmId"))
            putExtra("label", spec.optString("label", "Alarma"))
            putExtra("toneHz", spec.optInt("toneHz", 700))
            putExtra("vibrate", spec.optBoolean("vibrate", false))
        }
        val pending = PendingIntent.getBroadcast(
            context,
            id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val showIntent = PendingIntent.getActivity(
            context,
            0,
            Intent(context, MainActivity::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        manager.setAlarmClock(AlarmManager.AlarmClockInfo(trigger, showIntent), pending)
    }
}

/// Puente MethodChannel y receptores del sistema para las alarmas nativas.
class AlarmNativePlugin(private val context: Context) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "saveSchedule" -> {
                val json = call.arguments as? String
                if (json == null) {
                    result.error("bad_args", "Se esperaba JSON", null)
                    return
                }
                prefs(context).edit().putString(KEY_SCHEDULE, json).apply()
                scheduleAll(context)
                result.success(null)
            }
            "isRinging" -> result.success(prefs(context).getString(KEY_RINGING, null))
            "stopRinging" -> {
                stopRinging(context)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        fun register(engine: FlutterEngine, context: Context) {
            MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL_NAME)
                .setMethodCallHandler(AlarmNativePlugin(context.applicationContext))
        }
    }
}

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val service = Intent(context, AlarmRingingService::class.java)
        intent.extras?.let { service.putExtras(it) }
        context.startForegroundService(service)
    }
}

class SilenceReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) = stopRinging(context)
}

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) = scheduleAll(context)
}

/// Mantiene el zumbido pulsado en bucle y la notificación con «Silenciar».
class AlarmRingingService : Service() {
    private var player: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    private val handler = Handler(Looper.getMainLooper())

    override fun onCreate() {
        super.onCreate()
        createChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null) {
            stopSelf()
            return START_NOT_STICKY
        }
        val alarmId = intent.getIntExtra("alarmId", 0)
        val label = intent.getStringExtra("label") ?: "Alarma"
        val toneHz = intent.getIntExtra("toneHz", 700)
        val vibrate = intent.getBooleanExtra("vibrate", false)

        val state = JSONObject().apply {
            put("alarmId", alarmId)
            put("label", label)
            put("toneHz", toneHz)
            put("vibrate", vibrate)
            put("startedAt", System.currentTimeMillis())
        }
        prefs(this).edit().putString(KEY_RINGING, state.toString()).apply()

        if (toneHz > 0) startTone(toneHz)
        if (vibrate) startVibration()

        startForeground(RINGING_NOTIFICATION_ID, buildNotification(label))
        handler.postDelayed({ stopSelf() }, MAX_RINGING_MS)
        return START_NOT_STICKY
    }

    private fun startTone(hz: Int) {
        val uri = Uri.parse("android.resource://$packageName/raw/buzz_$hz")
        player = MediaPlayer().apply {
            setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build(),
            )
            setDataSource(this@AlarmRingingService, uri)
            isLooping = true
            prepare()
            start()
        }
    }

    private fun startVibration() {
        val service = getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator ?: return
        vibrator = service
        val pattern = longArrayOf(0, 400, 400, 400, 400, 400)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            service.vibrate(VibrationEffect.createWaveform(pattern, 0))
        } else {
            @Suppress("DEPRECATION")
            service.vibrate(pattern, 0)
        }
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            RINGING_CHANNEL,
            "Alarma en curso",
            NotificationManager.IMPORTANCE_MAX,
        ).apply {
            description = "Zumbido y vibración de la alarma"
            setSound(null, null)
            enableVibration(false)
            setBypassDnd(true)
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
        }
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(channel)
    }

    private fun buildNotification(label: String): Notification {
        val open = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val silence = PendingIntent.getBroadcast(
            this,
            0,
            Intent(this, SilenceReceiver::class.java).setAction(ACTION_SILENCE),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, RINGING_CHANNEL)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        return builder
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(label)
            .setContentText("Toca para silenciar")
            // En MIUI el heads-up no muestra acciones: tocar el aviso silencia.
            .setContentIntent(silence)
            .setFullScreenIntent(open, true)
            .setOngoing(true)
            .setCategory(Notification.CATEGORY_ALARM)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .addAction(
                Notification.Action.Builder(
                    Icon.createWithResource(this, R.mipmap.ic_launcher),
                    "Silenciar",
                    silence,
                ).build(),
            )
            .build()
    }

    override fun onDestroy() {
        handler.removeCallbacksAndMessages(null)
        player?.stop()
        player?.release()
        player = null
        vibrator?.cancel()
        vibrator = null
        prefs(this).edit().remove(KEY_RINGING).apply()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?) = null
}
