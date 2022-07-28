package com.leroux.curiosite

import android.Manifest
import android.annotation.TargetApi
import android.os.Build
import android.os.Environment
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.nio.file.Files.createFile

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.leroux.curiosite/storage_management"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler {
            // This method is invoked on the main thread.
                call, result ->
            when (call.method) {
                "getHomes" -> {
                    result.success(getHomes())
                }
                "getPaths" -> {
                    val uri = call.argument<String>("uri")
                    result.success(getPaths(uri))
                }
                "getFile" -> {
                    //mime types ?
                    val path = call.argument<String>("path")
                    result.success(getFile(path))
                }
                "createFile" -> {
                    val path = call.argument<String>("path")
                    val name = call.argument<String>("name")
                    result.success(createFile(path,name))
                }
                "createFolder" -> {
                    val path = call.argument<String>("path")
                    val name = call.argument<String>("name")
                    result.success(createFolder(path,name))
                }
                "rename" -> {
                    val path = call.argument<String>("path")
                    val newName = call.argument<String>("newName")
                    result.success(rename(path,newName))

                }
                "delete" -> {
                    val path = call.argument<String>("path")
                    result.success(delete(path))
                }
                "availableSpace" -> {
                    val path = call.argument<String>("path")
                    result.success(availableSpace(path))
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getHomes():List<String>{
        val paths: MutableList<String> = mutableListOf()
        paths.add(Environment.getExternalStorageDirectory().absolutePath.toString())
        return paths;
    }

    @TargetApi(Build.VERSION_CODES.JELLY_BEAN)
    private fun getPaths(uri:String?): List<String> {
        val paths: MutableList<String> = mutableListOf()
        val dir = File(uri!!).listFiles()?.toList()
        if (dir != null) {
            for(file in dir){
                paths.add("{\"name\":\"${file.name}\",\"absolutePath\":\"${file.absolutePath}\",\"isFile\":${file.isFile}}")
            }
        }
        return paths
    }

    private fun getFile(path:String?): IntArray {
        val lines: IntArray = intArrayOf()
        //...
        return lines
    }
    private fun createFile(path:String?, name:String?): Boolean {
        val success: Boolean = false
        //...
        return success
    }
    private fun createFolder(path:String?, name:String?): Boolean {
        val success: Boolean = false
        //...
        return success
    }
    private fun rename(path:String?, newName:String?): Boolean {
        val success: Boolean = false
        //...
        return success
    }
    private fun delete(path: String?): Boolean {
        val success: Boolean = false
        //...
        return success
    }
    private fun availableSpace(path:String?): Long {
        val space: Long = -1
        //...
        return space
    }

}