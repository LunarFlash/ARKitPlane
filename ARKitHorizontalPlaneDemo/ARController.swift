//
//  ViewController.swift
//  https://www.appcoda.com/arkit-horizontal-plane/
//  Created by Yi Wang on 11/14/17.
//  Copyright © 2017 Jayven Nhan. All rights reserved.
//

import UIKit
import ARKit

class ARController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment to configure lighting
        configureLighting()
        addTapGuestureToSceneView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    @objc func addShipToSceneView(withGuestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform.translation
        let x = translation.x
        let y = translation.y
        let z = translation.z
        
        guard let shipScene = SCNScene(named: "ship.scn"),
            let shipNode = shipScene.rootNode.childNode(withName: "ship", recursively: false)
            else { return }
        
        shipNode.position = SCNVector3(x, y, z)
        sceneView.scene.rootNode.addChildNode(shipNode)
    }
    
    func addTapGuestureToSceneView() {
        let tapGuestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ARController.addShipToSceneView(withGuestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGuestureRecognizer)
    }
}

// MARK: - ARSCNViewDelegate
extension ARController: ARSCNViewDelegate {
    // gets called every time the scene view’s session has a new ARAnchor added
    // ARAnchor is an object that represents a physical location and orientation in 3D space.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        // SCNPlane is a rectangular “one-sided” plane geometry.
        let plane = SCNPlane(width: width, height: height)
        // Then we give the plane a transparent light blue color to simulate a body of water.
        plane.materials.first?.diffuse.contents = UIColor.transparentLightBlue
        
        let planeNode = SCNNode(geometry: plane)
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
        // We rotate the planeNode’s x euler angle by 90 degrees in the counter-clockerwise direction, else the planeNode will sit up perpendicular to the table.
        planeNode.eulerAngles.x = -.pi / 2
        
        node.addChildNode(planeNode) // add it to the node being passed in
    }
    
    // With ARKit receiving additional information about our environment, we may want to expand our previously detected horizontal plane(s) to make use of a larger surface or have a more accurate representation with the new information.
    //  where ARKit refines its estimation of the horizontal plane’s position and extent.
    //  node argument gives us the updated position of the anchor. The anchor argument gives us the anchor’s updated width and height.
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAchor = anchor as? ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // we update the plane’s width and height using the planeAnchor extent’s x and z properties.
        let width = CGFloat(planeAchor.extent.x)
        let height = CGFloat(planeAchor.extent.z)
        plane.width = width
        plane.height = height
        
        // update the planeNode’s position to the planeAnchor’s center x, y, and z coordinates.
        let x = CGFloat(planeAchor.center.x)
        let y = CGFloat(planeAchor.center.y)
        let z = CGFloat(planeAchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension UIColor {
    open class var transparentLightBlue: UIColor {
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
    }
}
