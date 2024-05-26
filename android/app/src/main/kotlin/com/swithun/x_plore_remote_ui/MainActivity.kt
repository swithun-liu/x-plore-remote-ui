package com.swithun.x_plore_remote_ui

import android.os.Bundle
import android.os.PersistableBundle
import android.os.StrictMode
import android.provider.Settings.Global
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.hierynomus.smbj.SMBClient
import com.hierynomus.smbj.auth.AuthenticationContext
import com.hierynomus.smbj.session.Session
import com.hierynomus.smbj.share.DiskShare
import com.hierynomus.smbj.share.Share
import com.swithun.x_plore_remote_ui.sever.SMBToHTTPServer
import fi.iki.elonen.NanoHTTPD
import io.flutter.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.swithun/SMB"

    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        startServer()

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "testChannel") {
                result.success(testChannel())
            }
            if (call.method == "getPathList") {
                GlobalScope.launch(Dispatchers.IO) {
                    val parent = call.argument<String>("parent")!!
                    result.success(getPathList(parent))
                }
            }
        }
    }

    private fun testChannel(): String {
        return "Haha"
    }

    private fun getPathList(parent: String): List<String> {
        val pathList = mutableListOf<String>();

        (share as? DiskShare)?.let { diskShare ->
            try {
                diskShare.list(parent).forEach {
                    Log.d("swithun-xxxx", "[getPathList] folder($parent): ${it.fileName}")
                    pathList.add(it.fileName)
                }
            } catch (e: Exception) {
                Log.e("swithun-xxxx", "[getPathList] failed ${e.message}")
            }
        }

        return pathList

    }


    private val share: Share by lazy {
        val client = SMBClient()
        val connection = client.connect("192.168.31.36")
        val ac = AuthenticationContext("Guest", charArrayOf(), "")
        val session: Session = connection.authenticate(ac)
        session.connectShare("share")
    }


    private fun startServer() {
        Log.d(TAG, "begin Server started on port 8080")
        val server = SMBToHTTPServer()
        server.start(NanoHTTPD.SOCKET_READ_TIMEOUT, false)
        Log.d(TAG, "Server started on port 8080")
    }

    companion object {
        private const val TAG = "MainActivity"
    }

}
