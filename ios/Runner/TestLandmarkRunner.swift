//
//  TestLandmarkRunner.swift
//  Runner
//
//  Created by intiser Ahmed on 3/22/25.
//

import UIKit

enum TestLandmarkRunner {
    static func run() {
        // Load the test image from your asset catalog or bundle
        guard let image = UIImage(named: "test_face") else {
            print("❌ Failed to load test image.")
            return
        }

        // Initialize the FaceLandmarkerService with required parameters.
        // (Make sure the model file "face_landmarker.task" is added to your project and target.)
        guard let faceLandmarkerService = FaceLandmarkerService(
            modelPath: Bundle.main.path(forResource: "face_landmarker", ofType: "task")!,
            runningMode: .image,
            numFaces: 1,
            minFaceDetectionConfidence: 0.5,
            minFacePresenceConfidence: 0.5,
            minTrackingConfidence: 0.5,
            delegate: .GPU // Use .CPU or .GPU as defined in your FaceLandmarkerDelegate enum
        ) else {
            print("❌ Failed to initialize FaceLandmarkerService.")
            return
        }

        // Run detection (synchronously for .image mode)
        guard let resultBundle = faceLandmarkerService.detect(image: image) else {
            print("❌ Face detection failed.")
            return
        }

        // Remove nil results from the array of optional FaceLandmarkerResult
        let results = resultBundle.faceLandmarkerResults.compactMap { $0 }
        print("✅ Detected \(results.count) face(s)")

        // For each detected face, iterate over the sets of landmarks.
        // Each 'result.faceLandmarks' is of type [[NormalizedLandmark]]
        for (resultIndex, result) in results.enumerated() {
            let faceLandmarkSets = result.faceLandmarks // This is [[NormalizedLandmark]]
            for (faceIndex, landmarks) in faceLandmarkSets.enumerated() {
                print("Face \(resultIndex + 1) - set \(faceIndex + 1):")
                for (i, point) in landmarks.enumerated() {
                    print("  Landmark \(i): x=\(point.x), y=\(point.y), z=\(point.z)")
                }
            }
        }
    }
}
