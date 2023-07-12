//
//  ViewController.swift
//  ARDicee
//
//  Created by Jinyoung Yoo on 2023/07/06.
//

/*
       SceneKit을 활용한 3D 객체 활용 코드

       1. let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01) //width, height => 2차원, length => 3차원
       2. let moon = SCNSphere(radius: 0.1)

        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/moon.jpeg")

        moon.materials = [material]

        let node = SCNNode()
        node.position = SCNVector3(x: 0 , y: 0, z: 0)

        node.geometry = moon

        print(sceneView.scene.rootNode.position)
        sceneView.scene.rootNode.addChildNode(node)
 */


import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var diceArray: [SCNNode] = []
    
    //MARK: - UIViewController Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: - UIResponder Override Methods
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchLocation = touches.first?.location(in: sceneView) else { return }
        guard let query = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneGeometry, alignment: .any) else { return }
        
        let raycastResults = sceneView.session.raycast(query)
        
        if let location = raycastResults.first {
            addDice(atLocation: location)
        }
    }
    
    //MARK: - ARSCNViewDelegate Methods

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        node.addChildNode(planeNode)
        // didAdd node의 자식으로 추가
        // 만약 didAdd node의 자식으로 하는게 아니라 rootNode의 자식으로 추가하면 didAdd node의 자식이 아니게되므로 결과가 달라짐

    }
    
    //MARK: - IBAction Methods
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    

    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        for dice in diceArray {
            dice.removeFromParentNode()
        }
    }
    
    //MARK: - Feature
    
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        // SCNPlane
        let plane = SCNPlane(width: CGFloat(planeAnchor.planeExtent.width), height: CGFloat(planeAnchor.planeExtent.height))
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [material]
        
        // SCNPlane을 담는 Node
        let gridNode = SCNNode()
        gridNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        gridNode.transform = SCNMatrix4MakeRotation(-GLKMathDegreesToRadians(90), 1, 0, 0)
        gridNode.geometry = plane
        
        return gridNode
    }
    
    func addDice(atLocation location: ARRaycastResult) {
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            diceNode.position = SCNVector3(location.worldTransform.columns.3.x, location.worldTransform.columns.3.y + diceNode.boundingSphere.radius, location.worldTransform.columns.3.z)

            sceneView.scene.rootNode.addChildNode(diceNode)
            diceArray.append(diceNode)
        }
    }
    
    func roll(dice: SCNNode) {
        let randomX = Float(Int.random(in: 1...4)) * GLKMathDegreesToRadians(90)
        let randomZ = Float(Int.random(in: 1...4)) * GLKMathDegreesToRadians(90)
        
        dice.runAction(
            SCNAction.rotateBy(x: CGFloat(randomX * 5), y: 0, z: CGFloat(randomZ * 5), duration: 0.5)
        )
    }
    
    func rollAll() {
        for dice in diceArray {
            roll(dice: dice)
        }
    }
}
