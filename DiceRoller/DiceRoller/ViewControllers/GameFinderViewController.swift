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
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 24)
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private var textField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont(name: "HelveticaNeue-Light", size: 16)
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

    var coordinator: EventCoordinator<TimelineEvent, TimelineState>?
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

        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupView() {
        self.title = "Timeline"

        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 20
        stack.axis = .vertical

        let scrollView = UIScrollView()
        scrollView.isDirectionalLockEnabled = true
        view.addSubview(scrollView)
        scrollView.addSubview(stack)

        scrollView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        stack.addArrangedSubview(descLabel)
        stack.addArrangedSubview(textField)
        stack.addArrangedSubview(findButton)

        findButton.setTitle("Find Game", for: .normal)
        findButton.addTarget(self, action: #selector(findGame), for: .touchUpInside)

        textField.placeholder = "Enter game name"
        textField.delegate = self
        descLabel.text = "Enter the name of the game your group is using already, or create a new one. "

        descLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }

        textField.snp.makeConstraints { (make) in
            make.height.equalTo(44)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }

        findButton.snp.makeConstraints { (make) in
            make.height.equalTo(60)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }

        let info:[CardInfo] = [CardInfo.init(title: "Create Your World",
                                             desc: "Start by defining your first and last events (0, 100). \n\n1. Aliens land on earth \n\n100. Humans go extinct!",
                                             color: UIColor(hex: "#EDAE49"),
                                             textColor: UIColor.black),
                               CardInfo.init(title: "Make History",
                                             desc: "Add important events between the two to shape your timeline. These should be larger events that will be focused on later. Add key characters or places to be defined.\n\n25. Faster than light travel is discovered. \n\n50.Aliens and humans start a war.",
                                             color: UIColor(hex: "#D1495B"),
                                             textColor: UIColor.white),
                               CardInfo.init(title: "Dive Deeper",
                                             desc: "Add more definition to each large event. Be more specific about items and possible character arcs or reasons for the events to have happened in the first place. \n\n50.\na. Aliens destroyed their homeworld by accident. \n\nb. General Rose evacuated many into space.",
                                             color: UIColor(hex: "#00798C"),
                                             textColor: UIColor.white),
                               CardInfo.init(title: "Have Fun",
                                             desc: "It's easy to play with friends and have everyone play in turns. \n\nThe general rules are that each person gets to add an event or description each time around. \n\nMore than 50% of the group has to disagree before an event can be removed.",
                                             color: UIColor(hex: "#80DED9"),
                                             textColor: UIColor.black)]

        let onboardingCards = CardCarouselView(sources: info.map { CardType.info($0)})
        stack.addArrangedSubview(onboardingCards)

        let buffer = UIView()
        stack.addArrangedSubview(buffer) //buffer at bottom
        buffer.snp.makeConstraints { (make) in
            make.height.equalTo(30)
        }

        stack.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(30)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
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
                self?.coordinator?.notify(event: .timelineExistence(doesExist))
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

        case .setupEvent:
            break
        case .setupSubEvent(_):
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
        case .notEnoughInfoFail, .notEnoughInfoSoft, .tooManyCharacters:
            break
        }
    }
    
    @objc func findGame() {
        guard let timelineName = textField.text  else { return }
        //TODO: RYLEY THIS IS ONLY FOR TESTING
        coordinator?.notify(event: .timelineChosen("GameExample"))
    }

    //TODO: ACTUALLY IMPLEMENT EXISTENCE CHECK
    func checkTimelineExistence(timelineName: String, completion: (Bool) -> Void ) {
        completion(true)
    }

}

extension GameFinderViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}
