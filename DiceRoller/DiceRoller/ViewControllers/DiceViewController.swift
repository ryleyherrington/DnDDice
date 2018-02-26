//
//  DiceViewController.swift
//  DiceRoller
//
//  Created by Ryley Herrington on 12/6/16.
//  Copyright © 2016 Herrington. All rights reserved.
//

import UIKit

class DiceViewController: UIViewController {

    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var diceButton: UIButton!
    @IBOutlet weak var bottomMessage: UILabel!
    @IBOutlet weak var redSquare: UIView!
    @IBOutlet weak var blueSquare: UIView!
    
    private var animator: UIDynamicAnimator!
    private var attachmentBehavior: UIAttachmentBehavior!
    private var pushBehavior: UIPushBehavior!
    private var itemBehavior: UIDynamicItemBehavior!
    private var collisionBehavior: UICollisionBehavior!

    let throwingThreshold: CGFloat = 1000
    let throwingVelocityPadding: CGFloat = 100

    private var originalBounds = CGRect.zero
    private var originalCenter = CGPoint.zero
   
    var upperLimit:Int = 20
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.segControl.selectedSegmentIndex = 4
        self.becomeFirstResponder()
        
        animator = UIDynamicAnimator(referenceView: view)
        originalBounds = diceButton.bounds
        
        self.redSquare.isHidden = true
        self.blueSquare.isHidden = true
        originalCenter = diceButton.center

        diceButton.layer.borderColor = UIColor.white.cgColor
        diceButton.layer.borderWidth = 1.0
        diceButton.layer.cornerRadius = 4.0
        
    }
   
    @IBAction func panned(sender: UIPanGestureRecognizer) {
        let location = sender.location(in: self.view)
        let boxLocation = sender.location(in: self.diceButton)
        
        switch sender.state {
        case .began:
            animator.removeAllBehaviors()
            
            let centerOffset = UIOffset(horizontal: boxLocation.x - diceButton.bounds.midX, vertical: boxLocation.y - diceButton.bounds.midY)
            attachmentBehavior = UIAttachmentBehavior(item: diceButton, offsetFromCenter: centerOffset, attachedToAnchor: location)
            
            redSquare.center = attachmentBehavior.anchorPoint
            blueSquare.center = location
            
            animator.addBehavior(attachmentBehavior)
            
        case .ended:
            self.updateDie()
            animator.removeAllBehaviors()
            
            let velocity = sender.velocity(in: view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            
            if magnitude > throwingThreshold {
                let pushBehavior = UIPushBehavior(items: [diceButton], mode: .instantaneous)
                pushBehavior.pushDirection = CGVector(dx: velocity.x / 10, dy: velocity.y / 10)
                pushBehavior.magnitude = magnitude / throwingVelocityPadding
                
                self.pushBehavior = pushBehavior
                animator.addBehavior(pushBehavior)
                
                let angle = Int(arc4random_uniform(20)) - 10
                
                itemBehavior = UIDynamicItemBehavior(items: [diceButton])
                itemBehavior.friction = 0.3
                itemBehavior.elasticity = 0.9
                itemBehavior.allowsRotation = true
                itemBehavior.addAngularVelocity(CGFloat(angle), for: diceButton)
                animator.addBehavior(itemBehavior)
                
               
                collisionBehavior = UICollisionBehavior(items: [diceButton])
                collisionBehavior.translatesReferenceBoundsIntoBoundary = true
                animator.addBehavior(collisionBehavior)
                
                let snapTime = DispatchTime.now() + .milliseconds(350)
                DispatchQueue.main.asyncAfter(deadline: snapTime) {
                    let snap = UISnapBehavior(item: self.diceButton, snapTo: self.originalCenter)
                    snap.damping = 0.2
                    self.animator.addBehavior(snap)
                }

                let deadlineTime = DispatchTime.now() + .seconds(2)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.resetDemo()
                }
            } else {
                resetDemo()
            }
            
        default:
            attachmentBehavior.anchorPoint = sender.location(in: view)
            redSquare.center = attachmentBehavior.anchorPoint
            
            break
        }
    }
   
    func resetDemo() {
        animator.removeAllBehaviors()
        
        UIView.animate(withDuration: 0.45, animations: { 
            self.diceButton.bounds = self.originalBounds
            self.diceButton.center = self.originalCenter
            self.diceButton.transform = CGAffineTransform.identity
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "Fate Roller"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateMessage(text: "Shake to roll!", duration: 1.5, dismissDelay: 8)
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if(event?.subtype == .motionShake) {
            
            self.updateDie()
            self.updateDie()
            animator.removeAllBehaviors()
            
            // 1
            let velocity = CGPoint(x: 10, y: 45)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            
            if magnitude > throwingThreshold {
                // 2
                let pushBehavior = UIPushBehavior(items: [diceButton], mode: .instantaneous)
                pushBehavior.pushDirection = CGVector(dx: velocity.x / 10, dy: velocity.y / 10)
                pushBehavior.magnitude = magnitude / throwingVelocityPadding
                
                self.pushBehavior = pushBehavior
                animator.addBehavior(pushBehavior)
                
                // 3
                let angle = Int(arc4random_uniform(20)) - 10
                
                itemBehavior = UIDynamicItemBehavior(items: [diceButton])
                itemBehavior.friction = 0.3
                itemBehavior.elasticity = 0.9
                itemBehavior.allowsRotation = true
                itemBehavior.addAngularVelocity(CGFloat(angle), for: diceButton)
                animator.addBehavior(itemBehavior)
                
                
                collisionBehavior = UICollisionBehavior(items: [diceButton])
                collisionBehavior.translatesReferenceBoundsIntoBoundary = true
                animator.addBehavior(collisionBehavior)
                
                let snapTime = DispatchTime.now() + .milliseconds(350)
                DispatchQueue.main.asyncAfter(deadline: snapTime) {
                    let snap = UISnapBehavior(item: self.diceButton, snapTo: self.originalCenter)
                    snap.damping = 0.2
                    self.animator.addBehavior(snap)
                }
                // 4
                let deadlineTime = DispatchTime.now() + .seconds(3)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.resetDemo()
                }
            } else {
                resetDemo()
            }
        }
    }
   
    func rollRandomNumber() -> Int {
        return Int(arc4random_uniform(UInt32(self.upperLimit)) + 1)
    }
    
    func updateDie(){
        let roll = self.rollRandomNumber()
        print(roll)
        
        self.diceButton.setTitle("\(roll)", for: .normal)
        
        if roll <= 3 {
            let message = getMessage(isGood: false)
            print(message)
            self.updateMessage(text: message, duration: 1.5, dismissDelay: 4)
        }
        
        if roll >= self.upperLimit-3 {
            let message = getMessage(isGood: true) + "!"
            print(message)
            self.updateMessage(text: message, duration: 1.5, dismissDelay: 4)
        }
    }
   
    func getMessage(isGood:Bool) ->String{
        if isGood == true{
            let goodArr = ["Nice",
                           "Sweet roll",
                           "Score",
                           "Winner, winner",
                           "Supreme roll",
                           "You da man (or woman)",
                           "Are you Hawaiian? 'Cause that was a sweet roll",
                          ]
            return goodArr[Int(arc4random_uniform(UInt32(goodArr.count)))]
        } else {
            let badArr  = ["Yikes.",
                           "Not a great roll.",
                           "Try again probably...",
                           "Oh good lord.",
                           "Bruh. No bueno.",
                           "Come on, you can do better.",
                           "If this were a drinking game, you'd have to finish your drink.",
                           "Don't quit your day job.",
                           ]
            return badArr[Int(arc4random_uniform(UInt32(badArr.count)))]
        }
        
    }
    
    
    @IBAction func segControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.upperLimit = 4
        case 1:
            self.upperLimit = 6
        case 2:
            self.upperLimit = 8
        case 3:
            self.upperLimit = 10
        case 4:
            self.upperLimit = 20
        case 5:
            self.upperLimit = 100
            
        default:
            break;
        }
        
    }
    
    @IBAction func diceButtonTouched(_ sender: Any) {
        self.updateDie()
    }

    func updateMessage(text:String, duration:TimeInterval, dismissDelay:TimeInterval) {
        self.bottomMessage.text = text
        
        UIView.animate(withDuration:duration, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            self.bottomMessage.alpha = 1
        }, completion: { (finished: Bool) -> Void in
            UIView.animate(withDuration:duration, delay: dismissDelay, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                self.bottomMessage.alpha = 0
                self.bottomMessage.text = ""
            })
        })
    }

    
    

}

