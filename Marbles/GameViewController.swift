//
//  GameViewController.swift
//  Marbles
//
//  Created by Friedrich Gräter on 05/10/14.
//  Copyright (c) 2014 Friedrich Gräter. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import CoreMotion

class GameViewController : UIViewController {
	var scene : SCNScene!
	var cameraNode : SCNNode!
	var floorNode : SCNNode!
	var motionManager : CMMotionManager!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Setup scene
		scene = SCNScene()
		scene.physicsWorld.speed = 3
		
		// Setup camera
		cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
		cameraNode.camera?.xFov = 50
		cameraNode.camera?.yFov = 50
        cameraNode.position = SCNVector3(x: 0, y: 2, z: 15)
		scene.rootNode.addChildNode(cameraNode)
		
        // Setup light
		setupLights()
		
		// Add a ground
		setupFloor()
		
		// Add marble
		addMarbleAtAltitude(2)
		
		// Setup view
		let view = self.view as SCNView
		view.scene = scene

		let tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
		view.gestureRecognizers = [tapRecognizer]
		
		// Detect motion
		motionManager = CMMotionManager()
		motionManager.accelerometerUpdateInterval = 0.3
		
		motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()) { (accelerometerData, error) in
			let acceleration = accelerometerData.acceleration
			
			let accelX = Float(9.8 * acceleration.y)
			let accelY = Float(-9.8 * acceleration.x)
			let accelZ = Float(9.8 * acceleration.z)
			
			self.scene.physicsWorld.gravity = SCNVector3(x: accelX, y: accelY, z: accelZ)
		}
	}
	
	func setupLights() {
		// Setup ambient light
		let ambientLightNode = SCNNode()
		ambientLightNode.light = SCNLight()
		ambientLightNode.light!.type = SCNLightTypeAmbient
		ambientLightNode.light!.color = UIColor.init(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
		scene.rootNode.addChildNode(ambientLightNode)
		
		// Add spotlight
		let spotlightNode = SCNNode()
		spotlightNode.light = SCNLight()
		spotlightNode.light!.type = SCNLightTypeSpot
		spotlightNode.light!.color = UIColor.whiteColor()
		spotlightNode.light!.spotInnerAngle = 60;
		spotlightNode.light!.spotOuterAngle = 140;
		spotlightNode.light!.attenuationFalloffExponent = 1
		spotlightNode.position = SCNVector3(x: 0, y: 10, z: 0)
		spotlightNode.rotation = SCNVector4(x: -1, y: 0, z: 0, w: Float(M_PI_2))
		scene.rootNode.addChildNode(spotlightNode)
	}
	
	func setupFloor() {
		let floorMaterial = SCNMaterial()
		floorMaterial.diffuse.contents = UIColor.init(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
		
		let floor = SCNFloor()
		floor.materials = [floorMaterial]
		floor.reflectivity = 0.1
		
		floorNode = SCNNode()
		floorNode.geometry = floor
		floorNode.physicsBody = SCNPhysicsBody.staticBody()
		
		scene.rootNode.addChildNode(floorNode)
	}
	
	func addMarbleAtAltitude(altitude: Float) {
		let radius = Float(1.0)
		let textureNames = ["orange", "blue", "red"]
		let textureName = textureNames[Int(arc4random()) % textureNames.count]
		
		let marbleMaterial = SCNMaterial()
		marbleMaterial.diffuse.contents = UIImage(named: textureName)
		marbleMaterial.specular.contents = UIColor.whiteColor()
		
		let marbleGeometry = SCNSphere(radius: CGFloat(radius))
		marbleGeometry.segmentCount = 128
		
		let marble = SCNNode(geometry: marbleGeometry)
		marble.geometry?.materials = [marbleMaterial];
		marble.physicsBody = SCNPhysicsBody.dynamicBody()
		marble.position = SCNVector3(x: Float(arc4random()) / (Float(UINT32_MAX) * 10), y: altitude + radius, z: 0)
		
		scene.rootNode.addChildNode(marble)
	}

	func handleTap(sender: AnyObject) {
		addMarbleAtAltitude(10)
	}
}
