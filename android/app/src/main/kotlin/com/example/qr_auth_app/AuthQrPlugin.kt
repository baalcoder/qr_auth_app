package com.example.qr_auth_app

import android.app.Activity
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class AuthQrPlugin : FlutterPlugin, BiometricApi, QRScannerApi, ActivityAware {
    private lateinit var activity: FragmentActivity
    private lateinit var biometricHelper: BiometricHelper
    private var qrScannerHelper: QRScannerHelper? = null
    private var flutterApi: QRScannerFlutterApi? = null
    private val scope = CoroutineScope(Dispatchers.Main)

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        BiometricApi.setUp(binding.binaryMessenger, this)
        QRScannerApi.setUp(binding.binaryMessenger, this)
        flutterApi = QRScannerFlutterApi(binding.binaryMessenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        flutterApi = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity as FragmentActivity
        biometricHelper = BiometricHelper(activity)
        qrScannerHelper = QRScannerHelper(activity, activity) { qrCode ->
            flutterApi?.onQRCodeDetected(qrCode) { }
        }
    }

    override fun onDetachedFromActivity() {
        qrScannerHelper?.stopScanner()
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun authenticate(config: AuthConfig, callback: (Result<AuthResult>) -> Unit) {
        scope.launch {
            try {
                val result = biometricHelper.authenticate(
                    config.title ?: "Biometric Authentication",
                    config.subtitle ?: "Please authenticate to continue",
                    config.negativeButtonText ?: "Cancel"
                )
                callback(Result.success(result))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun isBiometricAvailable(): Boolean {
        return biometricHelper.isBiometricAvailable()
    }

    override fun startScanner(callback: (Result<Unit>) -> Unit) {
        try {
            qrScannerHelper?.startScanner()
            callback(Result.success(Unit))
        } catch (e: Exception) {
            callback(Result.failure(e))
        }
    }

    override fun stopScanner(callback: (Result<Unit>) -> Unit) {
        try {
            qrScannerHelper?.stopScanner()
            callback(Result.success(Unit))
        } catch (e: Exception) {
            callback(Result.failure(e))
        }
    }
}