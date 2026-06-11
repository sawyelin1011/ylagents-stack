package com.psyche.kelivo

import android.app.Activity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ActivityNotFoundException
import android.net.Uri
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class MainActivity : FlutterActivity() {
    private companion object {
        const val CREATE_DOCUMENT_REQUEST_CODE = 4107
        const val NOTIFICATION_CHANNEL_ID = "kelivo_bg_chat_v2"
    }

    private val processTextChannelName = "app.process_text"
    private val fileSaveChannelName = "app.file_save"
    private val notificationsChannelName = "app.notifications"
    private var processTextChannel: MethodChannel? = null
    private var fileSaveChannel: MethodChannel? = null
    private var notificationsChannel: MethodChannel? = null
    private var pendingProcessText: String? = null
    private var pendingSaveResult: MethodChannel.Result? = null
    private var pendingSaveSourcePath: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        processTextChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, processTextChannelName)
        processTextChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialText" -> {
                    val text = pendingProcessText ?: extractProcessText(intent)
                    pendingProcessText = null
                    result.success(text)
                }
                else -> result.notImplemented()
            }
        }
        fileSaveChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, fileSaveChannelName)
        fileSaveChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "saveFileFromPath" -> handleSaveFileFromPath(call.arguments, result)
                else -> result.notImplemented()
            }
        }
        notificationsChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, notificationsChannelName)
        notificationsChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "init" -> {
                    createNotificationChannel()
                    result.success(true)
                }
                "showNotification" -> {
                    val args = call.arguments as? Map<*, *>
                    val title = args?.get("title")?.toString() ?: ""
                    val body = args?.get("body")?.toString() ?: ""
                    val id = (args?.get("id") as? Int) ?: System.currentTimeMillis().toInt()
                    showNotification(id, title, body)
                    result.success(true)
                }
                "show" -> {
                    val args = call.arguments as? Map<*, *>
                    val title = args?.get("title")?.toString() ?: ""
                    val body = args?.get("body")?.toString() ?: ""
                    val id = (System.currentTimeMillis() % Int.MAX_VALUE).toInt()
                    showNotification(id, title, body)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
        pendingProcessText = extractProcessText(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val text = extractProcessText(intent) ?: return
        val ch = processTextChannel
        if (ch != null) {
            ch.invokeMethod("onProcessText", text)
        } else {
            pendingProcessText = text
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != CREATE_DOCUMENT_REQUEST_CODE) {
            return
        }

        val destUri = if (resultCode == Activity.RESULT_OK) data?.data else null
        handleSaveDestination(destUri)
    }

    private fun extractProcessText(intent: Intent?): String? {
        if (intent?.action != Intent.ACTION_PROCESS_TEXT) return null
        val text = intent.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)?.toString()
        return text?.trim()?.takeIf { it.isNotEmpty() }
    }

    private fun handleSaveFileFromPath(arguments: Any?, result: MethodChannel.Result) {
        if (pendingSaveResult != null) {
            result.error("busy", "Another save operation is already in progress.", null)
            return
        }

        val args = arguments as? Map<*, *>
        val rawSourcePath = args?.get("sourcePath")?.toString()?.trim().orEmpty()
        if (rawSourcePath.isEmpty()) {
            result.error("invalid_args", "Missing sourcePath.", null)
            return
        }

        val sourceFile = File(rawSourcePath)
        if (!sourceFile.exists() || !sourceFile.isFile) {
            result.error("not_found", "Source file does not exist.", null)
            return
        }

        val suggestedFileName = args?.get("fileName")?.toString()?.trim().takeUnless { it.isNullOrEmpty() }
            ?: sourceFile.name

        pendingSaveResult = result
        pendingSaveSourcePath = sourceFile.absolutePath

        try {
            val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = "application/zip"
                putExtra(Intent.EXTRA_TITLE, suggestedFileName)
            }
            startActivityForResult(intent, CREATE_DOCUMENT_REQUEST_CODE)
        } catch (e: ActivityNotFoundException) {
            pendingSaveResult = null
            pendingSaveSourcePath = null
            result.error("launch_failed", e.message, null)
        }
    }

    private fun handleSaveDestination(destUri: Uri?) {
        val result = pendingSaveResult ?: return
        val sourcePath = pendingSaveSourcePath

        if (destUri == null || sourcePath.isNullOrBlank()) {
            pendingSaveResult = null
            pendingSaveSourcePath = null
            result.success(false)
            return
        }

        Thread {
            try {
                contentResolver.openOutputStream(destUri)?.use { outputStream ->
                    FileInputStream(File(sourcePath)).use { inputStream ->
                        inputStream.copyTo(outputStream, DEFAULT_BUFFER_SIZE)
                    }
                } ?: throw IllegalStateException("Unable to open destination stream.")

                runOnUiThread {
                    pendingSaveResult = null
                    pendingSaveSourcePath = null
                    result.success(true)
                }
            } catch (e: Exception) {
                runOnUiThread {
                    pendingSaveResult = null
                    pendingSaveSourcePath = null
                    result.error("save_failed", e.message, null)
                }
            }
        }.start()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "Chat Background",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifications for chat generation status"
                enableVibration(true)
                setShowBadge(true)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun showNotification(id: Int, title: String, body: String) {
        val notification = NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .build()

        val manager = getSystemService(NotificationManager::class.java)
        manager.notify(id, notification)
    }
}
