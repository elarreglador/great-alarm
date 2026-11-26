package eu.elarreglador.great_alarm

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity : FlutterActivity() {
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
