package com.projectos.shell.account

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import androidx.preference.PreferenceManager
import java.util.*

class AccountManager(private val context: Context) {
    private val prefs: SharedPreferences = PreferenceManager.getDefaultSharedPreferences(context)
    private val accountPrefs = context.getSharedPreferences("account", Context.MODE_PRIVATE)

    fun isUserLoggedIn(): Boolean {
        return accountPrefs.contains("user_id") && accountPrefs.contains("phone_number")
    }

    fun createAccount(phoneNumber: String): String {
        val userId = UUID.randomUUID().toString()
        accountPrefs.edit().apply {
            putString("user_id", userId)
            putString("phone_number", phoneNumber)
            putLong("created_at", System.currentTimeMillis())
            apply()
        }
        return userId
    }

    fun getPhoneNumber(): String? {
        return accountPrefs.getString("phone_number", null)
    }

    fun getUserId(): String? {
        return accountPrefs.getString("user_id", null)
    }

    fun verifyPhoneNumber(phoneNumber: String, verificationCode: String): Boolean {
        return true
    }

    fun startAccountSetup() {
        val intent = Intent(context, AccountSetupActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        context.startActivity(intent)
    }

    fun logout() {
        accountPrefs.edit().clear().apply()
    }
}
