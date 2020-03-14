//
//  DisplayLinkObserver.swift
//  DisplayLink
//
//  Created by Oleg Tsibulevskiy on 14/03/2020.
//  Copyright © 2020 OTCode. All rights reserved.
//

import UIKit

internal enum TickType
{
    case perFrame
    case delay(seconds: Double)
}

internal protocol DisplayLinkObserverDelegate : class
{
    func handelTickWithDisplayLinkObserver(_ linkObserver: DisplayLinkObserver)
}

internal final class DisplayLinkObserver: NSObject
{
    //MARK: - Private Properties
    internal private(set) var tickerTimestamp   : CFTimeInterval
    internal private(set) var displayLinkTicker : CADisplayLink?
    
    private weak var _delegate : DisplayLinkObserverDelegate!
    
    //MARK: - Public Properties
    internal var tickType : TickType
    
    //MARK: - Initializer
    internal init(delegate : DisplayLinkObserverDelegate, tickType: TickType)
    {
        self.tickType         = tickType
        self.tickerTimestamp   = CFTimeInterval(0.0)
        self.displayLinkTicker = nil
        super.init()
        _delegate = delegate
    }
    
    //MARK: - Object LifeCycle
    deinit
    {
        stopTicker()
    }
}

// MARK: - Publick methods
extension DisplayLinkObserver
{
    internal func startTicker()
    {
        guard  displayLinkTicker == nil else { return }
        let displayLink = CADisplayLink(target: self, selector: #selector(updateTicker(with:)))
        displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
        displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.tracking)
        displayLinkTicker = displayLink
    }
    
    internal func stopTicker()
    {
        displayLinkTicker?.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
        displayLinkTicker?.remove(from: RunLoop.main, forMode: RunLoop.Mode.tracking)
        displayLinkTicker?.invalidate()
        displayLinkTicker = nil
        tickerTimestamp = 0.0
    }
}

//MARK: - Selectors
extension DisplayLinkObserver
{
    @objc private func updateTicker(with displayLink: CADisplayLink)
    {
        switch tickType
        {
        case .perFrame:
            
            guard tickerTimestamp != 0.0 else { tickerTimestamp = displayLink.timestamp; return }
            
            tickerTimestamp = displayLink.timestamp
            _delegate.handelTickWithDisplayLinkObserver(self)
            
        case .delay(let seconds):
            
            guard tickerTimestamp != 0.0 else { tickerTimestamp = displayLink.timestamp; return }
            
            let delta = displayLink.timestamp - tickerTimestamp
            
            guard delta >= seconds else { return }
            
            tickerTimestamp = displayLink.timestamp
            _delegate.handelTickWithDisplayLinkObserver(self)
        }
    }
}
