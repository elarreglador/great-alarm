package eu.elarreglador.great_alarm

import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity : FlutterActivity() {
    /// Los botones de volumen solo llegan a la Activity en primer plano; se consumen
    /// mientras suena para que no cambien el volumen del sistema.
    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        val volume = event.keyCode == KeyEvent.KEYCODE_VOLUME_UP ||
            event.keyCode == KeyEvent.KEYCODE_VOLUME_DOWN
        if (event.action == KeyEvent.ACTION_DOWN && volume && isRinging(this)) {
            stopRinging(this)
            return true
        }
        return super.dispatchKeyEvent(event)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            TIMEZONE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getTimezoneId" -> result.success(TimeZone.getDefault().id)
                else -> result.notImplemented()
            }
        }
        AlarmNativePlugin.register(flutterEngine, applicationContext)
    }

    private companion object {
        const val TIMEZONE_CHANNEL = "eu.elarreglador.great_alarm/timezone"
    }
}
