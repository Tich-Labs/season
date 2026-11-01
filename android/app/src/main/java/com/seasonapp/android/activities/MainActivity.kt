package com.seasonapp.android.activities

import android.net.Uri
import android.os.Bundle
import android.view.View
import androidx.activity.enableEdgeToEdge
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.seasonapp.android.R
import com.seasonapp.android.config.AppConfig
import com.seasonapp.android.fragments.AuthGate
import com.seasonapp.android.fragments.SeasonWebFragment
import com.seasonapp.android.models.mainTabs
import dev.hotwire.core.config.Hotwire
import dev.hotwire.core.turbo.config.PathConfiguration
import dev.hotwire.navigation.activities.HotwireActivity
import dev.hotwire.navigation.config.defaultFragmentDestination
import dev.hotwire.navigation.config.registerFragmentDestinations
import dev.hotwire.navigation.navigator.NavigatorConfiguration
import dev.hotwire.navigation.tabs.HotwireBottomNavigationController
import dev.hotwire.navigation.tabs.navigatorConfigurations
import dev.hotwire.navigation.util.applyDefaultImeWindowInsets

private val mainNavigator = NavigatorConfiguration(
    name = "main",
    navigatorHostId = R.id.main_nav_host,
    startLocation = AppConfig.baseUrl
)

class MainActivity : HotwireActivity(), AuthGate {
    private lateinit var bottomNavigationController: HotwireBottomNavigationController
    private var tabsLoaded = false

    override fun onCreate(savedInstanceState: Bundle?) {
        Hotwire.defaultFragmentDestination = SeasonWebFragment::class
        Hotwire.registerFragmentDestinations(SeasonWebFragment::class)
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        findViewById<View>(R.id.main).applyDefaultImeWindowInsets()

        Hotwire.loadPathConfiguration(
            context = this,
            location = PathConfiguration.Location(
                remoteFileUrl = "${AppConfig.baseUrl}/configurations/android_v1.json"
            )
        )

        delegate.setCurrentNavigator(mainNavigator)
    }

    // Tab configurations stay registered so the tab NavigatorHosts in the layout have
    // a configuration, but tabs are never switched to, so the bottom bar stays hidden.
    // Navigation is web-side (burger menu), matching iOS.
    override fun navigatorConfigurations() =
        listOf(mainNavigator) + mainTabs.navigatorConfigurations

    override fun onPageCompleted(location: String) {
        // Intentionally empty: tabs are disabled. See navigatorConfigurations().
    }

    private fun switchToTabs() {
        tabsLoaded = true

        val bottomNav = findViewById<BottomNavigationView>(R.id.bottom_nav)
        bottomNav.visibility = View.VISIBLE
        findViewById<View>(R.id.main_nav_host).visibility = View.GONE

        bottomNavigationController = HotwireBottomNavigationController(
            activity = this,
            view = bottomNav,
            lazyLoadTabs = true
        )
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
