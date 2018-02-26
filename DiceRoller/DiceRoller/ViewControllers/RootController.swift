//
//  RootController.swift
//  DiceRoller
//
//  Created by Ryley Herrington on 2/25/18.
//  Copyright © 2018 Herrington. All rights reserved.
//

import UIKit

class RootController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        //Timeline portion
        let gameVC = GameFinderViewController()
        gameVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        let gameNavController = UINavigationController(rootViewController: gameVC)
        gameNavController.title = "Timeline"

        //Dice portion
        let diceVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DiceVC") 
        diceVC.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 1)
        let diceNavController = UINavigationController(rootViewController: diceVC)
        diceNavController.title = "Fate Roller"

        //Tab bar controllers
        self.viewControllers = [gameNavController, diceNavController]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
