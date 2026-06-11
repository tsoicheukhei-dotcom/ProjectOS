package com.projectos.shell.store

import android.content.Context
import androidx.room.Room
import com.projectos.shell.store.data.AppDatabase
import com.projectos.shell.store.data.InstalledApp
import com.projectos.shell.store.api.GooglePlayApi
import kotlinx.coroutines.*

class AppStore(private val context: Context) {
    private val database: AppDatabase = Room.databaseBuilder(
        context,
        AppDatabase::class.java,
        "projectos_apps.db"
    ).build()

    private val playApi = GooglePlayApi()
    private val scope = CoroutineScope(Dispatchers.Main + Job())

    fun searchApps(query: String, callback: (List<AppSearchResult>) -> Unit) {
        scope.launch {
            try {
                val results = withContext(Dispatchers.IO) {
                    playApi.searchApps(query)
                }
                callback(results)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    fun getAppVersions(packageName: String, callback: (List<AppVersion>) -> Unit) {
        scope.launch {
            try {
                val versions = withContext(Dispatchers.IO) {
                    playApi.getAppVersions(packageName)
                }
                callback(versions)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    fun installApp(packageName: String, versionCode: Int, onProgress: (Int) -> Unit) {
        scope.launch {
            try {
                withContext(Dispatchers.IO) {
                    val apkFile = playApi.downloadApk(packageName, versionCode) { progress ->
                        scope.launch(Dispatchers.Main) {
                            onProgress(progress)
                        }
                    }
                    installApkFile(apkFile)
                    val installedApp = InstalledApp(
                        packageName = packageName,
                        versionCode = versionCode,
                        installTime = System.currentTimeMillis()
                    )
                    database.appDao().insert(installedApp)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    fun getInstalledApps(): List<InstalledApp> {
        return database.appDao().getAll()
    }

    private fun installApkFile(apkFile: java.io.File) {
        val pm = context.packageManager
        val intent = android.content.Intent(android.content.Intent.ACTION_VIEW)
        intent.setDataAndType(
            androidx.core.content.FileProvider.getUriForFile(context, context.packageName, apkFile),
            "application/vnd.android.package-archive"
        )
        context.startActivity(intent)
    }
}

data class AppSearchResult(
    val packageName: String,
    val title: String,
    val icon: String,
    val description: String,
    val rating: Float,
    val downloads: String,
    val price: String
)

data class AppVersion(
    val versionCode: Int,
    val versionName: String,
    val releaseDate: String,
    val fileSize: Long,
    val changelog: String
)
