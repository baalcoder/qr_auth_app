package com.example.qr_auth_app

import android.app.Activity
import android.content.Context
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import kotlin.coroutines.suspendCoroutine

class BiometricHelper(private val activity: FragmentActivity) {
    private val biometricManager = BiometricManager.from(activity)

    fun isBiometricAvailable(): Boolean {
        return biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG) == BiometricManager.BIOMETRIC_SUCCESS
    }

    suspend fun authenticate(
        title: String,
        subtitle: String,
        negativeButtonText: String
    ): AuthResult = suspendCoroutine { continuation ->
        val executor = ContextCompat.getMainExecutor(activity)

        val promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle(title)
            .setSubtitle(subtitle)
            .setNegativeButtonText(negativeButtonText)
            .build()

        val biometricPrompt = BiometricPrompt(activity, executor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    super.onAuthenticationError(errorCode, errString)
                    continuation.resumeWith(Result.success(AuthResult(false, errString.toString())))
                }

                override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                    super.onAuthenticationSucceeded(result)
                    continuation.resumeWith(Result.success(AuthResult(true, null)))
                }

                override fun onAuthenticationFailed() {
                    super.onAuthenticationFailed()
                    continuation.resumeWith(Result.success(AuthResult(false, "Authentication failed")))
                }
            })

        biometricPrompt.authenticate(promptInfo)
    }
}
