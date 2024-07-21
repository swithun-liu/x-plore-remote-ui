package com.swithun.x_plore_remote_ui.sever

import com.hierynomus.msdtyp.AccessMask
import com.hierynomus.mssmb2.SMB2CreateDisposition
import com.hierynomus.mssmb2.SMB2ShareAccess
import fi.iki.elonen.NanoHTTPD
import com.hierynomus.smbj.SMBClient
import com.hierynomus.smbj.auth.AuthenticationContext
import com.hierynomus.smbj.session.Session
import com.hierynomus.smbj.share.DiskShare
import io.flutter.Log
import java.io.InputStream
import java.util.EnumSet

class SMBToHTTPServer: NanoHTTPD(8080) {

    private var share: DiskShare? = null
    var ip: String = ""

    override fun serve(session: IHTTPSession?): Response {
        val uri = session?.uri
        val params = session?.parameters
        val filePath = params?.get("path")?.firstOrNull()
        Log.d(TAG, "serve $uri $filePath")

        if (filePath == null) {
            return newFixedLengthResponse(Response.Status.BAD_REQUEST, MIME_PLAINTEXT, "File path not specified")
        }

        return try {
            val bufferSize = 10 * 1024 // 设置合适的缓冲区大小
            val rangeHeader = session.headers["range"]
            val (fileStream, fileSize) = getFileStream(filePath)
            val mimeType = getMimeType(filePath)

            if (rangeHeader == null) {
                newFixedLengthResponse(Response.Status.OK, mimeType, fileStream, fileSize)
            } else {
                val range = rangeHeader.substring("bytes=".length).split("-")
                val start = range[0].toLong()
                val end = if (range.size > 1 && range[1].isNotEmpty()) range[1].toLong() else fileSize - 1
                Log.d(TAG, "range: start: $start | ranger[1]: ${range[1]} | end: $end| fileSize: $fileSize")
                val contentLength = end - start + 1

                fileStream.skip(start)
                val partialStream = fileStream.buffered(bufferSize)
                newFixedLengthResponse(Response.Status.PARTIAL_CONTENT, mimeType, partialStream, contentLength).apply {
                    addHeader("Content-Range", "bytes $start-$end/$fileSize")
                    addHeader("Content-Length", contentLength.toString())
                    addHeader("Accept-Ranges", "bytes")
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
            Log.e(TAG, "serve err: ${e.message}")
            newFixedLengthResponse(Response.Status.INTERNAL_ERROR, MIME_PLAINTEXT, "Error accessing SMB file")
        }
    }

    fun reInitShare(smbIp: String): DiskShare {
        this.ip = smbIp

        val client = SMBClient()
        val connection = client.connect(smbIp)
        val ac = AuthenticationContext("Guest", charArrayOf(), "")
        val session: Session = connection.authenticate(ac)
        val share: DiskShare = session.connectShare("share") as DiskShare
        this.share = share
        return share
    }

    private fun getFileStream(filePath: String): Pair<InputStream, Long> {
        Log.d(TAG, "getFileStream $filePath")
        val share = share ?: reInitShare(ip)

        val file = share.openFile(filePath, EnumSet.of(AccessMask.GENERIC_READ), null, SMB2ShareAccess.ALL, SMB2CreateDisposition.FILE_OPEN, null)
        val size = file.fileInformation.standardInformation.endOfFile
        return file.inputStream to size
    }

    private fun getMimeType(filePath: String): String {
        return when {
            filePath.endsWith(".mp4", ignoreCase = true) -> "video/mp4"
            filePath.endsWith(".mkv", ignoreCase = true) -> "video/x-matroska"
            filePath.endsWith(".avi", ignoreCase = true) -> "video/x-msvideo"
            filePath.endsWith(".mov", ignoreCase = true) -> "video/quicktime"
            filePath.endsWith(".flv", ignoreCase = true) -> "video/x-flv"
            else -> "application/octet-stream"
        }
    }

    companion object {
        private const val TAG = "SMBToHTTPServer"
    }

}