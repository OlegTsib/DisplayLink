//
//  DisplayLink.swift
//  DisplayLink
//
//  Created by Oleg Tsibulevskiy on 14/03/2020.
//  Copyright © 2020 OTCode. All rights reserved.
//

import Foundation

public protocol DisplayLinkDelegate: AnyObject
{
    func tick()
}

public class DisplayLink: NSObject
{
    //MARK: - Public Properties
    private var _controller    : DisplayLinkObserverController!
    private weak var _delegate : DisplayLinkDelegate?
    
    //MARK: - Computed Properties
    public static var notificationName: Notification.Name
    {
        return DisplayLinkObserverController.notificationName
    }
    
    var tickType: TickType = .perFrame
    {
        didSet
        {
            _controller.tickType = tickType
        }
    }
    
    //MARK: - Initializer
    public init(tickType: TickType, delegate: DisplayLinkDelegate?)
    {
        super.init()
        _controller = DisplayLinkObserverController(tickType: tickType, delegate: self)
        _delegate   = delegate
    }
}

// MARK: - Public funcs
extension DisplayLink
{
    public func startObservation()
    {
        _controller.startObservation()
    }
    
    public func stopObservation()
    {
        _controller.stopObservation()
    }
}

//MARK - DisplayLinkObserverControllerDelegate
extension DisplayLink: DisplayLinkObserverControllerDelegate
{
    func tick()
    {
        _delegate?.tick()
    }
}
