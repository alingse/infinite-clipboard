
package com.example.infclip

//import io.flutter.embedding.android.IntentService
//import io.flutter.embedding.android.Intent
 import android.app.IntentService
 import android.content.Intent

class RSSPullService(name: String="x"): IntentService (name) {    
    override fun onHandleIntent(workIntent: Intent?) {
        // Gets data from the incoming Intent
        // val dataString = workIntent.dataString
        print("start to work")
    }
}
