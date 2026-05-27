package com.seasonapp.android.activities

import android.os.Bundle
import android.view.View
import androidx.activity.enableEdgeToEdge
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.seasonapp.android.R
import com.seasonapp.android.models.mainTabs
import dev.hotwire.core.config.Hotwire
import dev.hotwire.core.turbo.config.PathConfiguration
import dev.hotwire.core.turbo.nav.visitProposalInterceptor
import dev.hotwire.navigation.activities.HotwireActivity
import dev.hotwire.navigation.tabs.HotwireBottomNavigationController
import dev.hotwire.navigation.tabs.navigatorConfigurations
import dev.hotwire.navigation.util.applyDefaultImeWindowInsets

const val baseURL = "https://seasonv2.onrender.com"

class MainActivity : HotwireActivity() {
    private lateinit var bottomNavigationController: HotwireBottomNavigationController
    private var tabsLoaded = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_main)
        findViewById<View>(R.id.main).applyDefaultImeWindowInsets()

        Hotwire.loadPathConfiguration(
            context = this,
            location = PathConfiguration.Location(
                remoteFileUrl = "$baseURL/configurations/android_v1.json"
            )
        )

        visitProposalInterceptor = VisitProposalInterceptor { proposal ->
            if (!tabsLoaded && isAuthenticatedPath(proposal.url.path)) {
                switchToTabs()
            }
            VisitProposalInterceptor.Result.ACCEPT
        }
    }

    override fun navigatorConfigurations() =
        if (tabsLoaded) mainTabs.navigatorConfigurations else emptyList()

    private fun switchToTabs() {
        tabsLoaded = true
        val bottomNav = findViewById<BottomNavigationView>(R.id.bottom_nav)
        bottomNav.visibility = View.VISIBLE
        bottomNavigationController = HotwireBottomNavigationController(this, bottomNav)
        bottomNavigationController.load(mainTabs, 0)
    }

    private fun isAuthenticatedPath(path: String): Boolean {
        return path.startsWith("/calendar") ||
            path.startsWith("/tracking") ||
            path.startsWith("/daily") ||
            path.startsWith("/symptoms") ||
            path.startsWith("/superpowers") ||
            path.startsWith("/settings") ||
            path.startsWith("/account") ||
            path.startsWith("/informations")
    }
}
