package com.swithun.x_plore_remote_ui

import android.os.Build
import android.os.StrictMode
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.hierynomus.smbj.SMBClient
import com.hierynomus.smbj.auth.AuthenticationContext
import com.hierynomus.smbj.share.DiskShare
import io.flutter.Log

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.swithun/SMB"

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
                val parent = call.argument<String>("parent")!!
                result.success(getPathList(parent))
            }
        }
    }

    private fun testChannel(): String {
        return "Haha"
    }

    private fun getPathList(parent: String): List<String> {
        Log.d("swithun-xxxx", "[ANDROID] getPathList: ${parent}")

        val policy = StrictMode.ThreadPolicy.Builder().permitAll().build()
        StrictMode.setThreadPolicy(policy)

        val pathList = mutableListOf<String>();

        val client = SMBClient()
        client.connect("192.168.31.36")?.let { connection ->
            val ac = AuthenticationContext("Guest", CharArray(0), "")
            connection.authenticate(ac)?.let { session ->
                session.connectShare("share")?.let { share ->
                    Log.d("swithun-xxxx", "share smbpath: ${share.smbPath}")
                    (share as? DiskShare)?.let { diskShare ->
                        diskShare.list(parent).forEach {
                            Log.d("swithun-xxxx", "folder($parent): ${it.fileName}")
                            pathList.add(it.fileName)
                        }
                    }
                }
            }
        }

        return pathList

    }

}
