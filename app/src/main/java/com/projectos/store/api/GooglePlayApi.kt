package com.projectos.shell.store.api

import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Query
import com.google.gson.annotations.SerializedName
import java.io.File

interface GooglePlayApiService {
    @GET("/search")
    suspend fun searchApps(
        @Query("q") query: String,
        @Query("c") category: String = "apps"
    ): SearchResponse
}

class GooglePlayApi {
    private val retrofit = Retrofit.Builder()
        .baseUrl("https://play.google.com/store/api/")
        .addConverterFactory(GsonConverterFactory.create())
        .build()

    private val service = retrofit.create(GooglePlayApiService::class.java)

    suspend fun searchApps(query: String): List<AppSearchResultDto> {
        return try {
            val response = service.searchApps(query)
            response.results
        } catch (e: Exception) {
            emptyList()
        }
    }

    suspend fun getAppVersions(packageName: String): List<AppVersionDto> {
        return emptyList()
    }

    suspend fun downloadApk(
        packageName: String,
        versionCode: Int,
        onProgress: (Int) -> Unit
    ): File {
        return File("/tmp/$packageName.apk")
    }
}

data class SearchResponse(
    @SerializedName("results")
    val results: List<AppSearchResultDto> = emptyList()
)

data class AppSearchResultDto(
    @SerializedName("package_name")
    val packageName: String,
    @SerializedName("title")
    val title: String,
    @SerializedName("icon")
    val icon: String,
    @SerializedName("description")
    val description: String,
    @SerializedName("rating")
    val rating: Float,
    @SerializedName("downloads")
    val downloads: String
)

data class AppVersionDto(
    val versionCode: Int,
    val versionName: String
)
