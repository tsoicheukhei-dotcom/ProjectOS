package com.projectos.shell.dialer

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.projectos.shell.R
import com.projectos.shell.account.AccountManager

class DialerActivity : AppCompatActivity() {
    private lateinit var accountManager: AccountManager
    private lateinit var dialPad: GridView
    private lateinit var displayTextView: TextView
    private lateinit var callButton: Button
    private val CALL_PERMISSION_REQUEST = 1

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_dialer)

        accountManager = AccountManager(this)
        displayTextView = findViewById(R.id.number_display)
        callButton = findViewById(R.id.call_button)
        dialPad = findViewById(R.id.dial_pad)

        setupDialPad()
        callButton.setOnClickListener {
            makeCall(displayTextView.text.toString())
        }
        requestCallPermissions()
    }

    private fun setupDialPad() {
        val dialPadButtons = arrayOf(
            "1", "2", "3",
            "4", "5", "6",
            "7", "8", "9",
            "*", "0", "#"
        )

        val adapter = ArrayAdapter(this, android.R.layout.simple_list_item_1, dialPadButtons)
        dialPad.adapter = adapter
        dialPad.setOnItemClickListener { _, _, position, _ ->
            val selectedNumber = dialPadButtons[position]
            addToDisplay(selectedNumber)
        }
    }

    private fun addToDisplay(digit: String) {
        displayTextView.append(digit)
    }

    private fun makeCall(phoneNumber: String) {
        if (phoneNumber.isNotEmpty()) {
            if (ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.CALL_PHONE
                ) == PackageManager.PERMISSION_GRANTED
            ) {
                val intent = Intent(Intent.ACTION_CALL)
                intent.data = Uri.parse("tel:$phoneNumber")
                startActivity(intent)
            } else {
                requestCallPermissions()
            }
        } else {
            Toast.makeText(this, "Please enter a number", Toast.LENGTH_SHORT).show()
        }
    }

    private fun requestCallPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.CALL_PHONE),
                CALL_PERMISSION_REQUEST
            )
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == CALL_PERMISSION_REQUEST) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                Toast.makeText(this, "Permission granted", Toast.LENGTH_SHORT).show()
            }
        }
    }
}
