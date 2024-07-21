package com.swithun.x_plore_remote_ui

import android.os.Bundle
import android.os.PersistableBundle
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

    private var shareV2: Share? = null

    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

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
            if (call.method == "connectSMB") {
                GlobalScope.launch(Dispatchers.IO) {
                    val ip = call.argument<String>("ip")!!
                    val port = call.argument<String>("port")!!
                    val path = call.argument<String>("path")!!
                    val uname = call.argument<String>("uname")!!
                    val upassword = call.argument<String>("upassword")!!
                    connectSMB(ip, port, path, uname, upassword)
                    startServer(ip)
                    result.success(null)
                }
            }
        }
    }

    private fun connectSMB(
        ip: String,
        port: String,
        path: String,
        uname: String,
        upassword: String
    ) {
        shareV2?.close()

        val client = SMBClient()
        val connection = client.connect(ip)
        val ac = AuthenticationContext(uname, upassword.toCharArray(), "")
        val session: Session = connection.authenticate(ac)
        val share = session.connectShare(path)
        this.shareV2 = share
    }

    private fun testChannel(): String {
        return "Haha"
    }


    private fun getPathList(parent: String): List<String> {
        val pathList = mutableListOf<String>();

        (shareV2 as? DiskShare)?.let { diskShare ->
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

    private fun startServer(ip: String) {
        Log.d(TAG, "begin Server started on port 8080")
        val server = SMBToHTTPServer()
        server.reInitShare(ip)
        server.start(NanoHTTPD.SOCKET_READ_TIMEOUT, false)
        Log.d(TAG, "Server started on port 8080")
    }

    companion object {
        private const val TAG = "MainActivity"
    }

}
