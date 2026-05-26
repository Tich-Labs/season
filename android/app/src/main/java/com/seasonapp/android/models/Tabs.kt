package com.seasonapp.android.models

import com.seasonapp.android.R
import com.seasonapp.android.activities.baseURL
import dev.hotwire.navigation.navigator.NavigatorConfiguration
import dev.hotwire.navigation.tabs.HotwireBottomTab

private val calendar = HotwireBottomTab(
    title = "Calendar",
    iconResId = android.R.drawable.ic_menu_month,
    configuration = NavigatorConfiguration(
        name = "calendar",
        navigatorHostId = R.id.calendar_nav_host,
        startLocation = "$baseURL/calendar"
    )
)

private val tracking = HotwireBottomTab(
    title = "Tracking",
    iconResId = android.R.drawable.ic_menu_edit,
    configuration = NavigatorConfiguration(
        name = "tracking",
        navigatorHostId = R.id.tracking_nav_host,
        startLocation = "$baseURL/tracking"
    )
)

private val settings = HotwireBottomTab(
    title = "Settings",
    iconResId = android.R.drawable.ic_menu_preferences,
    configuration = NavigatorConfiguration(
        name = "settings",
        navigatorHostId = R.id.settings_nav_host,
        startLocation = "$baseURL/settings/edit"
    )
)

val mainTabs = listOf(calendar, tracking, settings)
