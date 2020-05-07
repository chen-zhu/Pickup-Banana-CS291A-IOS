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
        arView.physicsOrigin = planAnchor.sign
        
        self.setupObjNotifyActions(arView: arView)
        
    }
    
    
    // MARK: - ARSessionDelegate
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if(self.time + 4 > Date().timeIntervalSince1970){
            print("Time Buffer detected")
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
            /*else {
                print("above the plan~")
            }*/
        }
            
        
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        print("trackingState: \(camera.trackingState)")
    }
    
    
    // MARK: - Object Notification Action
    func setupObjNotifyActions(arView: ARView){
        self.planAnchor.actions.pickupBanana.onAction = { entity in
            print("Picking up banana~")
            self.cameraAnchor = AnchorEntity(.camera)
            self.cameraAnchor.name = "cameraAnchor"
            arView.scene.addAnchor(self.cameraAnchor)
            entity?.setParent(self.cameraAnchor, preservingWorldTransform: true)
            //var cam_transform = cameraAnchor.transform
            //cam_transform.translation.z = -0.12
            //entity?.move(to: cam_transform, relativeTo: cameraAnchor, duration: 1)
            entity?.position = SIMD3(0, 0, -0.12)
            //print(cameraAnchor)
            self.time = Date().timeIntervalSince1970
        }
    }
    
    
}
