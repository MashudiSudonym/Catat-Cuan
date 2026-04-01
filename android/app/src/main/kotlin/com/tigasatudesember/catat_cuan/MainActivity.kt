package com.tigasatudesember.catat_cuan

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import android.app.Activity.RESULT_CANCELED
import android.app.Activity.RESULT_OK

class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "MainActivity"
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

        Log.d(TAG, "Configuring Flutter Engine")

        // Setup method channel for file save
        fileSaveMethodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "catat_cuan/file_save"
        )
        fileSaveMethodChannel?.setMethodCallHandler { call, result ->
            Log.d(TAG, "Method call: ${call.method}")
            when (call.method) {
                "saveFile" -> {
                    @Suppress("UNCHECKED_CAST")
                    val args = call.arguments as? Map<String, Any>
                    val contentBytes = args?.get("content") as? ByteArray
                    val fileName = args?.get("fileName") as? String
                    val mimeType = args?.get("mimeType") as? String

                    Log.d(TAG, "saveFile called: fileName=$fileName, mimeType=$mimeType, contentSize=${contentBytes?.size}")

                    if (contentBytes == null || fileName == null || mimeType == null) {
                        Log.e(TAG, "Missing arguments")
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
                        Log.d(TAG, "Launching file picker")
                        startActivityForResult(intent, SAVE_FILE_REQUEST_CODE)
                        result.success(null)
                    } catch (e: Exception) {
                        Log.e(TAG, "Failed to launch file picker", e)
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
                Log.d(TAG, "EventChannel: onListen - eventSink = $events")
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                Log.d(TAG, "EventChannel: onCancel")
                eventSink = null
            }
        })
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        Log.d(TAG, "onActivityResult: requestCode=$requestCode, resultCode=$resultCode")

        if (requestCode == SAVE_FILE_REQUEST_CODE) {
            if (resultCode == RESULT_CANCELED) {
                // User cancelled the picker
                Log.d(TAG, "User cancelled file picker")
                sendEvent("onCancelled", null)
                return
            }

            if (resultCode == RESULT_OK && data != null) {
                val uri: Uri? = data.data
                if (uri != null) {
                    Log.d(TAG, "File selected: $uri")
                    handleSaveFileResult(uri)
                } else {
                    Log.e(TAG, "No URI returned from file picker")
                    sendError("No URI returned from file picker")
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
                Log.e(TAG, "No content to save")
                sendError("No content to save")
                return
            }

            Log.d(TAG, "Writing content (${content.size} bytes) to $uri")

            contentResolver.openOutputStream(uri)?.use { output ->
                output.write(content)
                output.flush()
            } ?: run {
                Log.e(TAG, "Failed to open output stream")
                sendError("Failed to open output stream")
                return
            }

            Log.d(TAG, "File saved successfully")

            // Notify success with the URI path
            sendEvent("onSuccess", mapOf("path" to uri.toString()))
        } catch (e: Exception) {
            Log.e(TAG, "Error saving file", e)
            sendError(e.message ?: "Unknown error")
        } finally {
            // Clear pending data
            pendingSaveContent = null
            pendingSaveMimeType = null
        }
    }

    /// Send event to Flutter
    private fun sendEvent(eventType: String, data: Map<String, Any?>?) {
        Log.d(TAG, "Sending event: $eventType, data: $data, eventSink: $eventSink")
        val sink = eventSink
        if (sink != null) {
            try {
                sink.success(mapOf(
                    "event" to eventType,
                    "data" to data
                ))
            } catch (e: Exception) {
                Log.e(TAG, "Error sending event", e)
            }
        } else {
            Log.e(TAG, "Cannot send event: eventSink is null")
        }
    }

    /// Send error to Flutter
    private fun sendError(message: String) {
        Log.d(TAG, "Sending error: $message")
        val sink = eventSink
        if (sink != null) {
            try {
                sink.error(
                    "SAVE_ERROR",
                    message,
                    null
                )
            } catch (e: Exception) {
                Log.e(TAG, "Error sending error event", e)
            }
        } else {
            Log.e(TAG, "Cannot send error: eventSink is null")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "onDestroy")
        fileSaveMethodChannel?.setMethodCallHandler(null)
        fileSaveEventChannel?.setStreamHandler(null)
    }
}
