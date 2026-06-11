package com.projectos.shell.store.data

import androidx.room.*

@Database(entities = [InstalledApp::class], version = 1)
abstract class AppDatabase : RoomDatabase() {
    abstract fun appDao(): AppDao
}

@Entity(tableName = "installed_apps")
data class InstalledApp(
    @PrimaryKey
    val packageName: String,
    val versionCode: Int,
    val versionName: String = "",
    val installTime: Long,
    val lastUpdated: Long = 0
)

@Dao
interface AppDao {
    @Query("SELECT * FROM installed_apps")
    fun getAll(): List<InstalledApp>

    @Query("SELECT * FROM installed_apps WHERE packageName = :packageName")
    fun getByPackage(packageName: String): InstalledApp?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(app: InstalledApp)

    @Delete
    fun delete(app: InstalledApp)
}
