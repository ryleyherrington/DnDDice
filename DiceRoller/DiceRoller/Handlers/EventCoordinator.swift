//
//  EventCoordinator.swift
//  DiceRoller
//
//  Created by Ryley Herrington on 2/25/18.
//  Copyright © 2018 Herrington. All rights reserved.
//

import Foundation

protocol EventHandler {
    associatedtype Event
    associatedtype State
    
    func handle(event: Event, state: State) -> State?
}

class EventCoordinator<Event, State> {
    
    var onStateChange: ((State)->Void)?
    
    private var state: State {
        didSet {
            onStateChange?(state)
        }
    }
    private var subscribers: [AnyEventSubscriber<Event, State>] = []
    private var eventHandler: (Event, State) -> State?
    
    init<SM: EventHandler>(eventHandler:SM, state:State) where SM.Event == Event, SM.State == State {
        self.eventHandler = eventHandler.handle
        self.state = state
    }
    
    func start() {
        onStateChange?(state)
        subscribers.forEach { subscriber in
            subscriber.start(state: state)
        }
    }
    
    func notify(event: Event) {
        let newState = eventHandler(event, state)
        if let newState = newState {
            subscribers.forEach {(subscriber: AnyEventSubscriber<Event, State>)->Void in
                subscriber.onChange(event: event, state: newState)
            }
            state = newState
        }
    }
    
    func subscribe<S: EventSubscriber>(_ subscriber:S) where S.Event == Event, S.State == State {
        subscribers.append(AnyEventSubscriber(subscriber))
    }
    
    deinit {
        subscribers.removeAll()
    }
}

protocol EventSubscriber {
    associatedtype Event
    associatedtype State
    
    func start(state: State)
    func onChange(event: Event, state: State)
}

extension EventSubscriber {
    func start(state: State) {
        
    }
}

class AnyEventSubscriber<Event, State>:EventSubscriber {
    private var _onChange: ((Event, State)->Void)?
    private var _start: ((State)->Void)?
    
    init<ES: EventSubscriber>(_ subscriber:ES) where ES.State == State, ES.Event == Event {
        _onChange = subscriber.onChange
    }
    
    func start(state: State) {
        _start?(state)
    }
    
    func onChange(event: Event, state: State) {
        _onChange?(event, state)
    }
    
    deinit {
        _onChange = nil
        _start = nil
    }
}
