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

    private var descLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor(red: 56/255, green: 114/255, blue: 180/255, alpha: 1.0)
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 22)
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private var textField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.layer.borderWidth = 1
        tf.layer.cornerRadius = 5
        tf.textAlignment = .center
        tf.clipsToBounds = true
        return tf
    }()
    
    private var findButton: UIButton = {
        let b = UIButton(type: .custom)
        b.backgroundColor = UIColor(red: 56/255, green: 114/255, blue: 180/255, alpha: 1.0)
        b.titleLabel?.textColor = UIColor.white
        b.layer.cornerRadius = 5
        b.clipsToBounds = true
        return b
    }()

    fileprivate var coordinator: EventCoordinator<TimelineEvent, TimelineState>?
    typealias Dependencies = String //in case we need more later, just send in a tuple (String, String, Int...)
    static func create() -> GameFinderViewController {
        let vc = GameFinderViewController()
        
        let initialState = TimelineState()
        let coordinator = EventCoordinator(eventHandler: TimelineHandler(), state: initialState)
        vc.coordinator = coordinator
        coordinator.onStateChange = { [weak vc] state in vc?.updateState(state: state) }
        
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let initialState = TimelineState()
        let coordinator = EventCoordinator(eventHandler: TimelineHandler(), state: initialState)
        self.coordinator = coordinator
        coordinator.onStateChange = { [weak self] state in self?.updateState(state: state) }

        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.title = "Timeline"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupView() {
        view.addSubview(descLabel)
        view.addSubview(textField)
        view.addSubview(findButton)

        findButton.setTitle("Find Game", for: .normal)
        findButton.addTarget(self, action: #selector(findGame), for: .touchUpInside)

        textField.placeholder = "Enter game name"
        descLabel.text = "Enter the name of the game your group is using already, or create a new one. "
        
        descLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(90)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        textField.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalTo(descLabel.snp.bottom).offset(10)
            make.height.equalTo(44)
        }
        
        findButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.bottomMargin).offset(-10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(60)
        }
    }
    
    func updateState(state: TimelineState) {
        performService(state: state)
        performNavigation(state: state)
        handleError(state.error)
    }
    
    func performService(state: TimelineState) {
        guard let service = state.service else { return }
        
        switch service {
        case .checkTimelineExist:
            guard let timelineName = state.timelineName else { return }
            checkTimelineExistence(timelineName: timelineName, completion: { [weak self] doesExist in
                if doesExist == true {
                    self?.coordinator?.notify(event: .timelineExists)
                } else {
                    self?.coordinator?.notify(event: .timelineNotExists)
                }
            })
            
        default: break
            
        }
    }

    func performNavigation(state: TimelineState) {
        guard let navigationState = state.navigation else { return }
        switch navigationState {
        case .history:
            guard let timelineName = state.timelineName else { return }
            navigationController?.pushViewController(HistoryViewController.create(deps: timelineName), animated: true)
            
        case let .setupGame(name):
            print("setupgame with name: \(name)")

        case .setupNewEvent(_), .insertEvent(_):
            break
        }
    }
    
    func handleError(_ error: TimelineError?) {
        guard let error = error else { return }
        
        switch error {
        case .gameNotFound:
            let alert = UIAlertController(title: "Uh Oh", message: "Game not found, do you want to create one?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { [weak self] _ in
                guard let timelineName = self?.textField.text  else { return }
                self?.coordinator?.notify(event: .createTimeline(timelineName))
            }))
            alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: nil))
            self.navigationController?.present(alert, animated: true, completion: nil)

        case .emptyTimelineName:
            let alert = UIAlertController(title: "Uh Oh", message: "You can't find an empty game!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler:nil))
                
            self.navigationController?.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func findGame() {
        guard let timelineName = textField.text  else { return }
        //TODO:RYLEY THIS IS ONLY FOR TESTING
        coordinator?.notify(event: .timelineChosen("GameExample"))
    }

    func checkTimelineExistence(timelineName: String, completion: (Bool) -> Void ) {
        completion(true)
    }

}
