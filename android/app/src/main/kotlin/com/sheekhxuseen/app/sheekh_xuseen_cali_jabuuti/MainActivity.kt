package com.sheekhxuseen.app.sheekh_xuseen_cali_jabuuti

import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import androidx.core.view.WindowCompat
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity : AudioServiceActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // ALWAYS call super.onCreate first to properly initialize Activity lifecycle & window decor
        super.onCreate(savedInstanceState)

        try {
            // Modern edge-to-edge window display
            WindowCompat.setDecorFitsSystemWindows(window, false)
            window.statusBarColor = Color.TRANSPARENT
            window.navigationBarColor = Color.TRANSPARENT

            // Android 15 (API 35) and Android 16 (API 36) deprecate LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES.
            // On API 30+, LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS allows seamless layout in display cutouts.
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                window.attributes.layoutInDisplayCutoutMode =
                    WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS
            }
        } catch (e: Throwable) {
            // Safely guard against any OEM-specific window attribute issues to guarantee zero crashes on launch
        }
    }
}
