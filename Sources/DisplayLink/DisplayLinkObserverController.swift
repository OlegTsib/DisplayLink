//
//  DisplayLinkObserverController.swift
//  DisplayLink
//
//  Created by Oleg Tsibulevskiy on 14/03/2020.
//  Copyright © 2020 OTCode. All rights reserved.
//

import Foundation

internal protocol DisplayLinkObserverControllerDelegate: AnyObject
{
    func tick()
}

internal final class DisplayLinkObserverController: NSObject
{
    private var _displayLinker : DisplayLinkObserver!
    private weak var _delegate : DisplayLinkObserverControllerDelegate!
    
    //MARK: - Public Properties
    public static let notificationName = NSNotification.Name(rawValue: "DisplayLinkObserverDidTick")
    
    internal var tickType: TickType = .perFrame
    {
        didSet
        {
            _displayLinker.tickType = tickType
        }
    }
    
    //MARK: - Initializer
    internal init(tickType: TickType, delegate: DisplayLinkObserverControllerDelegate? = nil)
    {
        super.init()
        _displayLinker = DisplayLinkObserver(delegate: self, tickType: tickType)
        _delegate      = delegate
    }
    
    // MARK: - Object LifeCycle
    deinit
    {
        _displayLinker?.stopTicker()
        _displayLinker = nil
    }
}

//MARK: - Public Methods
extension DisplayLinkObserverController
{
    internal func startObservation()
    {
        _displayLinker.startTicker()
    }
    
    internal func stopObservation()
    {
        _displayLinker.stopTicker()
    }
}

// MARK: - DisplayLinkObserverDelegate
extension DisplayLinkObserverController: DisplayLinkObserverDelegate
{
    internal func handelTickWithDisplayLinkObserver(_ linkObserver: DisplayLinkObserver)
    {
        NotificationCenter.default.post(name: DisplayLinkObserverController.notificationName, object: linkObserver)
        _delegate.tick()
    }
}
