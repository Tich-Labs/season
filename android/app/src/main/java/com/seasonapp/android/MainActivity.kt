package com.seasonapp.android

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val webView = WebView(this).apply {
            settings.javaScriptEnabled = true
            settings.domStorageEnabled = true
            settings.userAgentString = "${settings.userAgentString} Season Android"

            webViewClient = object : WebViewClient() {
                override fun shouldOverrideUrlLoading(
                    view: WebView,
                    request: WebResourceRequest
                ): Boolean {
                    val host = request.url.host ?: return false
                    if (isInternalUrl(host)) return false

                    view.context.startActivity(Intent(Intent.ACTION_VIEW, request.url))
                    return true
                }
            }

            loadUrl("https://seasonv2.onrender.com")
        }

        setContentView(webView)
    }

    private fun isInternalUrl(host: String): Boolean {
        return host == "seasonv2.onrender.com" ||
            host.endsWith(".onrender.com") ||
            host.endsWith(".season.vision") ||
            host.endsWith(".seasonapp.co")
    }
}
