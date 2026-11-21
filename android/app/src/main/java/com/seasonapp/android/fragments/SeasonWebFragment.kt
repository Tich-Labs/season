package com.seasonapp.android.fragments

import android.os.Bundle
import android.view.View
import dev.hotwire.navigation.destinations.HotwireDestinationDeepLink
import dev.hotwire.navigation.fragments.HotwireWebFragment

interface AuthGate {
    fun onPageCompleted(location: String)
}

@HotwireDestinationDeepLink(uri = "hotwire://fragment/web")
class SeasonWebFragment : HotwireWebFragment() {
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        hideNativeToolbar()
    }

    override fun onStart() {
        super.onStart()
        hideNativeToolbar()
    }

    // The web app draws its own header, so Hotwire's toolbar is hidden to avoid a double header.
    // The library re-shows it on start and between visits, so this runs on each of those too.
    private fun hideNativeToolbar() {
        toolbarForNavigation()?.parent?.let { (it as? View)?.visibility = View.GONE }
    }

    override fun onVisitCompleted(location: String, completedOffline: Boolean) {
        super.onVisitCompleted(location, completedOffline)
        hideNativeToolbar()
        (activity as? AuthGate)?.onPageCompleted(location)
    }
}
