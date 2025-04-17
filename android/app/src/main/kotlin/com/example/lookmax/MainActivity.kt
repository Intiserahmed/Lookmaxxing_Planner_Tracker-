
package com.example.lookmax

import android.graphics.BitmapFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "face_landmark_detection"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "detectFaceLandmarks") {
                val imagePath = call.arguments as String
                val bitmap = BitmapFactory.decodeFile(imagePath)
                if (bitmap != null) {
                    val helper = FaceLandmarkerHelper(
                        context = this,
                        runningMode = com.google.mediapipe.tasks.vision.core.RunningMode.IMAGE,
                        minFaceDetectionConfidence = 0.5f,
                        minFaceTrackingConfidence = 0.5f,
                        minFacePresenceConfidence = 0.5f,
                        maxNumFaces = 1,
                        currentDelegate = FaceLandmarkerHelper.DELEGATE_CPU,
                        faceLandmarkerHelperListener = object : FaceLandmarkerHelper.LandmarkerListener {
                            override fun onError(error: String, errorCode: Int) {
                                result.error("ERROR", error, null)
                            }

                            override fun onResults(resultBundle: FaceLandmarkerHelper.ResultBundle) {
                                val landmarks = resultBundle.result.faceLandmarks()
                                if (landmarks.isNotEmpty()) {
                                    val landmarkList = mutableListOf<Double>()
                                    for (landmark in landmarks[0]) {
                                        landmarkList.add(landmark.x().toDouble())
                                        landmarkList.add(landmark.y().toDouble())
                                    }
                                    result.success(landmarkList)
                                } else {
                                    result.success(listOf<Double>())
                                }
                            }
                        }
                    )
                    helper.detectImage(bitmap)
                } else {
                    result.error("ERROR", "Failed to load image", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
