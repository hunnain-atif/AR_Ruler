//
//  ViewController.swift
//  ARRuler
//
//  Created by Hunnain Atif on 2020-04-12.
//  Copyright © 2020 Hunnain Atif. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var displayNode = SCNNode()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
        }
    }
    
    func addDot(at hitResult: ARHitTestResult) {
        let dot = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        dot.materials = [material]
        let dotNode = SCNNode(geometry: dot)
        dotNode.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
           calculate()
        }
    }
    
    func calculate() {
        let startPoint = dotNodes[0]
        let endPoint = dotNodes[1]
        
        print(startPoint.position)
        print(endPoint.position)
        
        let l = endPoint.position.x - startPoint.position.x
        let w = endPoint.position.y - startPoint.position.y
        let h = endPoint.position.z - startPoint.position.z
        
        let distance = sqrt(pow(l, 2) + pow(w, 2) + pow(h,2))
        
        displayText(text: "\(abs(distance))m", atPosition: endPoint.position)
    }
    
    func displayText(text: String, atPosition: SCNVector3) {
        displayNode.removeFromParentNode()
        let display = SCNText(string: text, extrusionDepth: 1.0)
        display.firstMaterial?.diffuse.contents = UIColor.red
        displayNode = SCNNode(geometry: display)
        displayNode.position = SCNVector3(
            atPosition.x,
            atPosition.y + 0.01,
            atPosition.z)
        displayNode.scale = SCNVector3(0.01, 0.01, 0.01)
        sceneView.scene.rootNode.addChildNode(displayNode)
    }
    
}
