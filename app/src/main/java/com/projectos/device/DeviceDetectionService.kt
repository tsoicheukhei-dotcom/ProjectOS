package com.projectos.shell.device

import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log

class DeviceDetectionService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        detectAndLogDeviceInfo()
        return START_STICKY
    }

    private fun detectAndLogDeviceInfo() {
        Log.d("ProjectOS", "Device Detection:")
        Log.d("ProjectOS", "Device: ${Build.DEVICE}")
        Log.d("ProjectOS", "Model: ${Build.MODEL}")
        Log.d("ProjectOS", "Manufacturer: ${Build.MANUFACTURER}")
        Log.d("ProjectOS", "Android Version: ${Build.VERSION.SDK_INT}")
        Log.d("ProjectOS", "Build: ${Build.DISPLAY}")
    }

    companion object {
        fun detectDevice(context: Context) {
            val intent = Intent(context, DeviceDetectionService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }
    }
}
