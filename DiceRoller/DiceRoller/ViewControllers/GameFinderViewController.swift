//
//  GameFinderViewController.swift
//  DiceRoller
//
//  Created by Ryley Herrington on 2/24/18.
//  Copyright © 2018 Herrington. All rights reserved.
//

import UIKit
import SnapKit

class GameFinderViewController: UIViewController {

    var descLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor(red: 56/255, green: 114/255, blue: 180/255, alpha: 1.0)
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 22)
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    var textField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.layer.borderWidth = 1
        tf.layer.cornerRadius = 5
        tf.textAlignment = .center
        tf.clipsToBounds = true
        return tf
    }()
    
    var findButton: UIButton = {
        let b = UIButton(type: .custom)
        b.backgroundColor = UIColor(red: 56/255, green: 114/255, blue: 180/255, alpha: 1.0)
        b.titleLabel?.textColor = UIColor.white
        b.layer.cornerRadius = 5
        b.clipsToBounds = true
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupView() {
        self.title = "Timeline"
        
        view.addSubview(descLabel)
        view.addSubview(textField)
        view.addSubview(findButton)

        findButton.setTitle("Find Game", for: .normal)
        findButton.addTarget(self, action: #selector(findGame), for: .touchUpInside)
        
        textField.placeholder = "Enter game name"
        
        descLabel.text = "Enter the name of the game your group is using already, or create a new one. "
        
        descLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(84)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        textField.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.center.equalToSuperview()
            make.height.equalTo(44)
        }
        
        findButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.bottomMargin).offset(-10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(60)
        }
    }
    
    @objc func findGame() {
        navigationController?.pushViewController(HistoryViewController(), animated: true)
    }

}
