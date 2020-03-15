//
//  DisplayLinkTimer.swift
//  DisplayLink
//
//  Created by Oleg Tsibulevskiy on 14/03/2020.
//  Copyright © 2020 OTCode. All rights reserved.
//

import UIKit

public enum DisplayLinkTimerFinishType
{
    case foregroud
    case background
}

public protocol DisplayLinkTimerDelegate: class
{
    func timerDidFinish(with type: DisplayLinkTimerFinishType)
    func timerTick(counter: Double, timer: DisplayLinkTimer)
}

public class DisplayLinkTimer: NSObject
{
    //MARK: - Private Properties
    private let _accessQueue = DispatchQueue(label: "DisplayLinkTimer.accessQueue", attributes: DispatchQueue.Attributes.concurrent)
    private let _lostUserFocusKey = "DisplayLinkTimer-LostUserFocus"
    private let _defaults         = UserDefaults.standard
    
    weak private var _delegate : DisplayLinkTimerDelegate?
    private var _displayLink   : DisplayLink!
    private var _timerRun      : Bool
    private var _tickType      : TickType
    
    //MARK: - Public Properties
    public private(set) var timerIsOn : Bool
    public private(set) var infinite  : Bool
    public private(set) var timer     : Double

    //MARK: - Computed Properties
    private var counter : Double
    {
        didSet
        {
            guard _timerRun else { return }
            
            if counter >= timer
            {
                notifiDidFinish(type: .foregroud)
            }
        }
    }
    
    private lazy var notificationCenter : NotificationCenter =
    {
        return .default
    }()
    
    //MARK: - Initializer
    public init(delegate: DisplayLinkTimerDelegate)
    {
        self.timer      = 0
        self.counter    = 0
        self.infinite   = false
        self._timerRun  = false
        self.timerIsOn  = false
        _delegate       = delegate
        _tickType       = .delay(seconds: 1)
        super.init()
        
        _displayLink = DisplayLink(tickType: _tickType, delegate: self)
        notificationCenter.addObserver(self, selector: #selector(didEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(willEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
}

//MARK: - Public Methods
extension DisplayLinkTimer
{
    /**
     Restart Timer with minutes
     - Parameters:
       - minutes  : Minimum 1 minute
    */
    public func restartTimer(minutes: Double)
    {
        guard timerIsOn else { return }
        
        _accessQueue.sync { [weak self] in
            self?._timerRun = false
            self?.timer     = minutes * 60
            self?.counter   = 0
            self?._timerRun = true
        }
    }
    
    /**
     Restart Timer with seconds
     - Parameters:
       - seconds  : Minimum 1 second
    */
    public func restartTimer(seconds: Double)
    {
        guard timerIsOn else { return }
        
        _accessQueue.sync { [weak self] in
            self?._timerRun = false
            self?.timer    = seconds
            self?.counter  = 0
            self?._timerRun = true
        }
    }

    /**
     - Parameters:
       - seconds  : Minimum 1 minute
       - infinite : One time timer or infinite
       - delegate : Finish handler
    */
    public func startTrack(minutes: Double, infinite: Bool)
    {
        if timerIsOn
        {
            restartTimer(minutes: minutes)
        }
        else
        {
            startTimer(seconds: minutes * 60, infinite: infinite)
        }
        
    }
    
    /**
     - Parameters:
       - seconds  : Minimum 1 second
       - infinite : One time timer or infinite
       - delegate : Finish handler
    */
    public func startTrack(seconds: Double, infinite: Bool)
    {
        if timerIsOn
        {
            restartTimer(minutes: max(1, seconds) * 60)
        }
        else
        {
            startTimer(seconds: seconds, infinite: infinite)
        }
        
    }
    
    ///Stop and refresh timer
    public func stopTrack()
    {
        _accessQueue.sync { [weak self] in
            self?._timerRun  = false
            self?.timerIsOn = false
            self?.timer     = 0
            self?.counter   = 0
            self?._displayLink.stopObservation()
        }
    }

}

//MARK: - Private Methods
extension DisplayLinkTimer
{
    private func startTimer(seconds: Double, infinite: Bool)
    {
        self._timerRun   = true
        self.timerIsOn  = true
        self.timer      = seconds
        self.counter    = 0
        self.infinite   = infinite
        _displayLink.startObservation()
    }
    
    private func notifiDidFinish(type: DisplayLinkTimerFinishType)
    {
        if infinite
        {
            _accessQueue.sync { [weak self] in
                self?._timerRun = false
                self?.counter  = 0
                self?._timerRun = true
            }
        }
        else
        {
            stopTrack()
        }
        
        _delegate?.timerDidFinish(with: type)
    }
    
    private func handelTickWithDisplayLinkObserver()
    {
        counter += 1
    }
}

//MARK: - DisplayLinkDelegate
extension DisplayLinkTimer: DisplayLinkDelegate
{
    public func tick(displayLink: DisplayLink)
    {
        handelTickWithDisplayLinkObserver()
        _delegate?.timerTick(counter: counter, timer: self)
    }
}

//MARK: - Observers
extension DisplayLinkTimer
{
    @objc private func didEnterBackground(_ sender: NSNotification)
    {
        guard timerIsOn else { return }
        _defaults.set(Date().timeIntervalSince1970, forKey: _lostUserFocusKey)
    }
    
    @objc private func willEnterForeground(_ sender: NSNotification)
    {
        guard timerIsOn else { return }
        
        let lastTimeStamp    = Double(_defaults.double(forKey: _lostUserFocusKey))
        let currentTimeStamp = Double(Date().timeIntervalSince1970)
        
        let interval = currentTimeStamp - lastTimeStamp
        
        if counter + interval >= timer
        {
            notifiDidFinish(type: .background)
        }
        else
        {
            counter += interval
        }
    }
}
