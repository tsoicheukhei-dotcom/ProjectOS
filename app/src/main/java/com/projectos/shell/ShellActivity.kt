package com.projectos.shell

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.preference.PreferenceManager
import com.projectos.shell.databinding.ActivityShellBinding
import com.projectos.shell.device.DeviceDetectionService
import com.projectos.shell.account.AccountManager

class ShellActivity : AppCompatActivity() {
    private lateinit var binding: ActivityShellBinding
    private lateinit var accountManager: AccountManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityShellBinding.inflate(layoutInflater)
        setContentView(binding.root)

        accountManager = AccountManager(this)
        
        if (!accountManager.isUserLoggedIn()) {
            accountManager.startAccountSetup()
            finish()
            return
        }

        DeviceDetectionService.detectDevice(this)
        initializeShell()
    }

    private fun initializeShell() {
        val prefs = PreferenceManager.getDefaultSharedPreferences(this)
        val wallpaperId = prefs.getString("wallpaper", "default") ?: "default"
        loadWallpaper(wallpaperId)
        setupAppGrid()
        setupNavigationBar()
    }

    private fun loadWallpaper(wallpaperId: String) {
        // Load iPadOS 15-style wallpaper
    }

    private fun setupAppGrid() {
        // Initialize app grid view with installed apps
    }

    private fun setupNavigationBar() {
        // Setup bottom navigation similar to iPad dock
    }
}
