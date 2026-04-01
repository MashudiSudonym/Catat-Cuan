package com.tigasatudesember.catat_cuan

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import android.app.Activity.RESULT_CANCELED
import android.app.Activity.RESULT_OK

class MainActivity : FlutterActivity() {
    companion object {
        private const val SAVE_FILE_REQUEST_CODE = 1001
    }

    /// Method channel for file save operations
    private var fileSaveMethodChannel: MethodChannel? = null

    /// Event channel for file save events
    private var fileSaveEventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null

    /// Pending file save data (content + mime type) while picker is open
    private var pendingSaveContent: ByteArray? = null
    private var pendingSaveMimeType: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup method channel for file save
        fileSaveMethodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "catat_cuan/file_save"
        )
        fileSaveMethodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "saveFile" -> {
                    @Suppress("UNCHECKED_CAST")
                    val args = call.arguments as? Map<String, Any>
                    val contentBytes = args?.get("content") as? ByteArray
                    val fileName = args?.get("fileName") as? String
                    val mimeType = args?.get("mimeType") as? String

                    if (contentBytes == null || fileName == null || mimeType == null) {
                        result.error(
                            "INVALID_ARGUMENTS",
                            "Missing required arguments: content, fileName, or mimeType",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    // Store pending data
                    pendingSaveContent = contentBytes
                    pendingSaveMimeType = mimeType

                    // Create intent for saving file
                    val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                        addCategory(Intent.CATEGORY_OPENABLE)
                        type = mimeType
                        putExtra(Intent.EXTRA_TITLE, fileName)
                    }

                    // Launch file picker
                    try {
                        startActivityForResult(intent, SAVE_FILE_REQUEST_CODE)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error(
                            "SAVE_ERROR",
                            "Failed to launch file picker: ${e.message}",
                            null
                        )
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Setup event channel for async callbacks
        fileSaveEventChannel = EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "catat_cuan/file_save_events"
        )
        fileSaveEventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == SAVE_FILE_REQUEST_CODE) {
            if (resultCode == RESULT_CANCELED) {
                // User cancelled the picker
                eventSink?.success(mapOf(
                    "event" to "onCancelled",
                    "data" to null
                ))
                return
            }

            if (resultCode == RESULT_OK && data != null) {
                val uri: Uri? = data.data
                if (uri != null) {
                    handleSaveFileResult(uri)
                } else {
                    eventSink?.error(
                        "SAVE_ERROR",
                        "No URI returned from file picker",
                        null
                    )
                }
            }
        }
    }

    /// Handle file picker result
    private fun handleSaveFileResult(uri: Uri) {
        try {
            // Write content to the selected URI
            val content = pendingSaveContent
            if (content == null) {
                eventSink?.error(
                    "SAVE_ERROR",
                    "No content to save",
                    null
                )
                return
            }

            contentResolver.openOutputStream(uri)?.use { output ->
                output.write(content)
                output.flush()
            } ?: run {
                eventSink?.error(
                    "SAVE_ERROR",
                    "Failed to open output stream",
                    null
                )
                return
            }

            // Notify success with the URI path
            eventSink?.success(mapOf(
                "event" to "onSuccess",
                "data" to mapOf("path" to uri.toString())
            ))
        } catch (e: Exception) {
            eventSink?.error(
                "SAVE_ERROR",
                e.message ?: "Unknown error",
                null
            )
        } finally {
            // Clear pending data
            pendingSaveContent = null
            pendingSaveMimeType = null
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        fileSaveMethodChannel?.setMethodCallHandler(null)
        fileSaveEventChannel?.setStreamHandler(null)
    }
}
