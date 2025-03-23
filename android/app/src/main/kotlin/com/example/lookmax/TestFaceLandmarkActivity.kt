package com.example.lookmax

import android.graphics.BitmapFactory
import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import com.example.lookmax.FaceLandmarkerHelper.Companion.DELEGATE_CPU
import com.google.mediapipe.tasks.vision.core.RunningMode

// Import your FaceLandmarkerHelper – adjust the package name if needed.
//import com.example.lookmax.FaceLandmarkerHelper
//import com.google.mediapipe.examples.facelandmarker.FaceLandmarkerHelper.Companion.DELEGATE_CPU

class TestFaceLandmarkActivity : AppCompatActivity(), FaceLandmarkerHelper.LandmarkerListener {

    companion object {
        private const val TAG = "TestFaceLandmarkActivity"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Set a simple layout for this test
//        setContentView(R.layout.activity_test_face_landmark)

        // Load the test image from drawable resources.
        val bitmap = BitmapFactory.decodeResource(resources, R.drawable.test_face)
        if (bitmap == null) {
            Log.e(TAG, "Failed to load test image.")
            return
        }

        // Initialize the FaceLandmarkerHelper in IMAGE mode.
        val helper = FaceLandmarkerHelper(
            context = this,
            runningMode = RunningMode.IMAGE,
            minFaceDetectionConfidence = 0.5f,
            minFaceTrackingConfidence = 0.5f,
            minFacePresenceConfidence = 0.5f,
            maxNumFaces = 1,
            currentDelegate = DELEGATE_CPU,
            faceLandmarkerHelperListener = this
        )

        // Run detection on the loaded image.
        val resultBundle = helper.detectImage(bitmap)
        if (resultBundle != null) {
            Log.d(TAG, "Inference time: ${resultBundle.inferenceTime} ms")
            // FaceLandmarkerHelper.ResultBundle.result is a FaceLandmarkerResult.
            // Its method faceLandmarks() returns a List<NormalizedLandmark>.
            val landmarks = resultBundle.result.faceLandmarks()
            Log.d(TAG, "Detected ${landmarks.size} landmarks:")
            for ((i, landmark) in landmarks.withIndex()) {
                Log.d(TAG, "Landmark $i: $landmark")
            }
        } else {
            Log.e(TAG, "Face detection failed.")
        }

        // Always clear the helper when done to release resources.
        helper.clearFaceLandmarker()
    }

    // For IMAGE mode, these listener methods might not be called.
    override fun onError(error: String, errorCode: Int) {
        Log.e(TAG, "Error: $error")
    }

    override fun onResults(resultBundle: FaceLandmarkerHelper.ResultBundle) {
        // Not used in IMAGE mode.
    }
}
