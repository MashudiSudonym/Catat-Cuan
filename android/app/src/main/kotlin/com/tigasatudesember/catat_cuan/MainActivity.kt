package com.tigasatudesember.catat_cuan

import android.net.Uri
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    /// Method channel for file save operations
    private var fileSaveMethodChannel: MethodChannel? = null

    /// Event channel for file save events
    private var fileSaveEventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null

    /// Pending file save data (content + mime type) while picker is open
    private var pendingSaveContent: ByteArray? = null
    private var pendingSaveMimeType: String? = null

    /// Activity result launcher for file picker
    private val saveFileLauncher =
        registerForActivityResult(ActivityResultContracts.CreateDocument()) { uri: Uri? ->
            handleSaveFileResult(uri)
        }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup method channel for file save
        fileSaveMethodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "catat_cuan/file_save"
        )
        fileSaveMethodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "saveFile" -> handleSaveFile(call, result)
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

    /// Handle save file method call from Flutter
    private fun handleSaveFile(call: MethodCall, result: MethodChannel.Result) {
        try {
            // Extract arguments
            val contentBytes = call.argument<ByteArray>("content")
            val fileName = call.argument<String>("fileName")
            val mimeType = call.argument<String>("mimeType")

            if (contentBytes == null || fileName == null || mimeType == null) {
                result.error(
                    "INVALID_ARGUMENTS",
                    "Missing required arguments: content, fileName, or mimeType",
                    null
                )
                return
            }

            // Store pending data
            pendingSaveContent = contentBytes
            pendingSaveMimeType = mimeType

            // Launch file picker with suggested filename
            saveFileLauncher.launch(fileName)

            // Result will be handled asynchronously via event channel
            result.success(null)
        } catch (e: Exception) {
            result.error(
                "SAVE_ERROR",
                "Failed to launch file picker: ${e.message}",
                null
            )
        }
    }

    /// Handle file picker result
    private fun handleSaveFileResult(uri: Uri?) {
        if (uri == null) {
            // User cancelled the picker
            eventSink?.success(mapOf(
                "event" to "onCancelled",
                "data" to null
            ))
            return
        }

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
