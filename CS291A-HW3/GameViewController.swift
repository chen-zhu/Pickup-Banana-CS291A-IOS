//
//  GameViewController.swift
//  CS291A-HW3
//
//  Created by Stone Zhu on 5/5/20.
//  Copyright © 2020 Stone Zhu. All rights reserved.
//

import UIKit
import RealityKit
import ARKit

class GameViewController: UIViewController, ARSessionDelegate{
    
    @IBOutlet var arView: ARView!
    
    var planAnchor = try! Experience.loadPlan()
    var cameraAnchor = AnchorEntity(.camera)
    var time = Date().timeIntervalSince1970
    
    var performance_tuner = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        arView.session.delegate = self
        arView.debugOptions = [ARView.DebugOptions.showFeaturePoints, ARView.DebugOptions.showWorldOrigin]
        
        //let independent_anchor = AnchorEntity(plane: .horizontal)
        //arView.scene.addAnchor(independent_anchor)
        
        // Load the "Box" scene from the "Experience" Reality File
        planAnchor = try! Experience.loadPlan()
        //independent_anchor.addChild(planAnchor)
        
        arView.scene.anchors.append(planAnchor)
        
        //print(planAnchor.children[0].children[1].position)
        //print(planAnchor.banana?.position)
        //print(planAnchor.sign?.position)
        //arView.physicsOrigin = planAnchor.sign
        
        self.setupObjNotifyActions(arView: arView)
        
    }
    
    
    // MARK: - ARSessionDelegate
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        //if(self.performance_tuner > 0){
            if(self.time + 2 > Date().timeIntervalSince1970){
                //print("Putting down: Time Buffer detected")
            } else if(self.cameraAnchor.children.isEmpty == false){
                let banana = self.cameraAnchor.children[0]
                let banana_position = banana.position(relativeTo: self.planAnchor)
                
                if(banana_position.y <= 0.015){
                    print("touched the plan~")
                    banana.setParent(self.planAnchor, preservingWorldTransform: true)
                    var pos = banana.position
                    pos.y = 0.015
                    banana.position = pos
                }
                
                self.time = Date().timeIntervalSince1970
                self.performance_tuner = 0
            }
        //}
        
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        print("trackingState: \(camera.trackingState)")
    }
    
    
    // MARK: - Object Notification Action
    func setupObjNotifyActions(arView: ARView){
        self.planAnchor.actions.pickupBanana.onAction = { entity in
            //Only pick up banana if the current camera anchor has nothing
            //self.cameraAnchor = AnchorEntity(.camera)
            if(self.performance_tuner <= 0){
                if(self.time + 2 > Date().timeIntervalSince1970){
                    //print("Picking up: Time Buffer detected")
                } else if(self.cameraAnchor.children.isEmpty) {
                    print("Picking up banana~")
                    self.cameraAnchor.name = "cameraAnchor"
                    arView.scene.addAnchor(self.cameraAnchor)
                    entity?.setParent(self.cameraAnchor, preservingWorldTransform: true)
                    //var cam_transform = cameraAnchor.transform
                    //cam_transform.translation.z = -0.12
                    //entity?.move(to: cam_transform, relativeTo: cameraAnchor, duration: 1)
                    entity?.position = SIMD3(0, 0, -0.12)
                    self.time = Date().timeIntervalSince1970
                    
                    self.performance_tuner = 1;
                    //print(self.cameraAnchor.children)
                }
            }
        }
        
        
        self.planAnchor.actions.tapBanana.onAction = { entity in
            if(self.performance_tuner <= 0){
                if(self.cameraAnchor.children.isEmpty) {
                    print("Tapped banana~")
                    self.cameraAnchor.name = "cameraAnchor"
                    arView.scene.addAnchor(self.cameraAnchor)
                    entity?.setParent(self.cameraAnchor, preservingWorldTransform: true)
                    //var cam_transform = cameraAnchor.transform
                    //cam_transform.translation.z = -0.12
                    //entity?.move(to: cam_transform, relativeTo: cameraAnchor, duration: 1)
                    entity?.position = SIMD3(0, 0, -0.12)
                    self.time = Date().timeIntervalSince1970
                    
                    self.performance_tuner = 1;
                    //print(self.cameraAnchor.children)
                }
            }
            
        }
    }
    
    // MARK: - Tap Gesture
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        if(self.cameraAnchor.children.isEmpty == false) {
            print("I am tapping here~")
            let tapLocation = sender.location(in: arView)
            //print(tapLocation)
            let hitTestResult = arView.hitTest(tapLocation, types: .featurePoint)
            //print(hitTestResult)
            
            let rayResult = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
            //let rayResult = arView.scene.raycastQuery(from: tapLocation, allowing: .estimatedPlane, alignment: .any)
            
            print(rayResult)
            let entity = self.cameraAnchor.children[0]
            entity.setParent(self.planAnchor, preservingWorldTransform: true)
            self.performance_tuner = 0
            //var x = rayResult.direction.x
            //var y = rayResult.direction.y
            //var z = rayResult.direction.z
            
            
            
            
        }
    }
    
    
    
    
    
}
