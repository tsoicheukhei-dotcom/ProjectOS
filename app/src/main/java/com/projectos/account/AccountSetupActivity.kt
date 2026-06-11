package com.projectos.shell.account

import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.projectos.shell.R
import com.projectos.shell.ShellActivity
import android.content.Intent

class AccountSetupActivity : AppCompatActivity() {
    private lateinit var accountManager: AccountManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_account_setup)

        accountManager = AccountManager(this)

        val phoneNumberInput = findViewById<EditText>(R.id.phone_number_input)
        val verificationCodeInput = findViewById<EditText>(R.id.verification_code_input)
        val sendCodeButton = findViewById<Button>(R.id.send_code_button)
        val verifyButton = findViewById<Button>(R.id.verify_button)

        sendCodeButton.setOnClickListener {
            val phoneNumber = phoneNumberInput.text.toString()
            if (phoneNumber.isNotEmpty()) {
                sendVerificationCode(phoneNumber)
            } else {
                Toast.makeText(this, "Please enter phone number", Toast.LENGTH_SHORT).show()
            }
        }

        verifyButton.setOnClickListener {
            val phoneNumber = phoneNumberInput.text.toString()
            val code = verificationCodeInput.text.toString()
            if (code.isNotEmpty()) {
                if (accountManager.verifyPhoneNumber(phoneNumber, code)) {
                    accountManager.createAccount(phoneNumber)
                    navigateToShell()
                } else {
                    Toast.makeText(this, "Invalid verification code", Toast.LENGTH_SHORT).show()
                }
            }
        }
    }

    private fun sendVerificationCode(phoneNumber: String) {
        Toast.makeText(this, "Verification code sent to $phoneNumber", Toast.LENGTH_SHORT).show()
    }

    private fun navigateToShell() {
        val intent = Intent(this, ShellActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        startActivity(intent)
    }
}
