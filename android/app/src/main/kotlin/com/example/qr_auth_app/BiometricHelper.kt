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
                    val result = AuthResult()
                    result.success = false
                    result.error = errString.toString()
                    continuation.resumeWith(Result.success(result))
                }

                override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                    super.onAuthenticationSucceeded(result)
                    val authResult = AuthResult()
                    authResult.success = true
                    continuation.resumeWith(Result.success(authResult))
                }

                override fun onAuthenticationFailed() {
                    super.onAuthenticationFailed()
                    val result = AuthResult()
                    result.success = false
                    result.error = "Authentication failed"
                    continuation.resumeWith(Result.success(result))
                }
            })

        biometricPrompt.authenticate(promptInfo)
    }
}