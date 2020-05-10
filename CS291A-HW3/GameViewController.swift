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
        arView.debugOptions = [ARView.DebugOptions.showFeaturePoints, ARView.DebugOptions.showWorldOrigin, ARView.DebugOptions.showAnchorOrigins]
        
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
                
                if(banana_position.y <= 0.025){
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
                    //var cam_transform = self.cameraAnchor.transform
                    //cam_transform.translation.z = -0.12
                    //entity?.move(to: cam_transform, relativeTo: self.planAnchor)
                    entity?.setParent(self.cameraAnchor, preservingWorldTransform: true)
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
        let t = self.time
        //print("I am tapping", self.cameraAnchor.children.isEmpty, t, Date().timeIntervalSince1970)
        if(t + 0.1 < Date().timeIntervalSince1970){
            if(self.cameraAnchor.children.isEmpty == false) {
                print("I am tapping here~")
                let tapLocation = sender.location(in: arView)
                //print(tapLocation)
                let hitTestResult = arView.hitTest(tapLocation, types: .existingPlane)
                //let hitTestResult = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .any)
                if(!hitTestResult.isEmpty){
                    //print(hitTestResult)
                    
                    //let rayResult = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
                    
                    //print(rayResult)
                    let transform = hitTestResult[0].worldTransform
                    
                    //print(transform.columns)
                    let entity = self.cameraAnchor.children[0]
                    
                    
                    self.performance_tuner = 0
                    let original_orientation = entity.orientation(relativeTo: nil)
                    entity.move(to: transform, relativeTo: nil)
                    entity.setParent(self.planAnchor, preservingWorldTransform: true)
                    entity.position.y = 0.015
                    entity.setOrientation(original_orientation, relativeTo: nil)
                    entity.setScale(SIMD3(0.5, 0.5, 0.5), relativeTo: self.planAnchor.children[0])
                    
                    //if (entity.move(to: transform, relativeTo: nil, duration: 0.5).isComplete){
                    //    entity.setParent(self.planAnchor, preservingWorldTransform: true)
                    //    entity.position.y = 0.015
                    //}
                    //let x = transform.columns.3.x//rayResult!.direction.x
                    //let y = transform.columns.3.y//rayResult!.direction.y
                    //let z = transform.columns.3.z//rayResult!.direction.z
                    
                    
                    
                    //entity.position = SIMD3(Float(x), Float(y), Float(z))
                    //print(SIMD3(Float(x), Float(y), Float(z)))
                    
                    
                    //entity.position.y = 0.015
                    //var x = rayResult.direction.x
                    //var y = rayResult.direction.y
                    //var z = rayResult.direction.z
                }
            }
        }
        //else {
        //    self.time = Date().timeIntervalSince1970
        //}
    }
    
    
    
    
    
}
