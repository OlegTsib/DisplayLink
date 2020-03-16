<h1 align="center">
DisplayLink
</h1>
<h3 align="center">Timer on base CADisplayLink</h3>
<p align="center">
<img alt="Version" src="https://img.shields.io/badge/version-1.0.5-green">
<img alt="Author" src="https://img.shields.io/badge/author-Oleg%20Tsibulevskiy-blue.svg">
<img alt="Swift" src="https://img.shields.io/badge/swift-5%2B-orange.svg">
<img alt="Swift" src="https://img.shields.io/badge/platform-ios-lightgrey.svg">
</p>

#### Table of Contents  
1. [Requirements](#requirements)
2. [Installation](#installation)
3. [How to Use](#use)
4. [DisplayLink](#displayLink)
5. [DisplayLinkTimer](#displayLinkTimer)

<a name="requirements"/>

# Requirements:
* iOS 9+ 
* Xcode 11+
* Swift 5+

<a name="installation"/>

# Installation:

### Package manger
Click on File ->  Swift Packages ->  Add Package Dependencies -> Add Repository by URL - https://github.com/OlegTsib/DisplayLink.git

### Demo app URL:
 https://github.com/OlegTsib/DisplayLinkDemo.git

<a name="use"/>

# How to Use:

### Import: 

```swift
import DisplayLink
```
<a name="displayLink"/>

## DisplayLink:
Class representing a timer bound to the display.
You can be notified changes per frame or configure notifier time by second or minutes by self
```swift
let displayLink  = DisplayLink(tickType: .delay(seconds: 3), delegate: self)
let displayLink2 = DisplayLink(tickType: .perFrame, delegate: self)
displayLink.startObservation()
displayLink2.startObservation()
```
<h5>You have two ways to subscribe on DisplayLink ticker</h5>

<h5>1. By delegate "DisplayLinkDelegate" :</h5>

```swift
DisplayLink(tickType: .delay(seconds: 3), delegate: self)
```
<h5>1. By Notification Center :</h5>

```swift
NotificationCenter.default.addObserver(self,
 selector: #selector(displayLinkTick(_:)),
 name: DisplayLink.notificationName,
 object: nil)
```
<a name="displayLinkTimer"/>

## DisplayLinkTimer:

Timer on-base DisplayLink  - is a good choice for you  if you must do something like refresh app or send an event after some period of time. You can not worry about the timer when your app goes to background mode, after backing to the foreground mode timer will shoot with <strong>DisplayLinkTimerFinishType </strong> or will keep counting. 

<h5>DisplayLinkTimerFinishType </h5>

```swift
enum  DisplayLinkTimerFinishType
{
	case  foregroud
	case  background
}
```

<h5>Initializer </h5>

```swift
let timer = DisplayLinkTimer(delegate: self)
```
<h5>You have two Timer modes
<em>Infinite</em> or
 <em>One time </em> and track by <em>Minutes</em>  or<em> Seconds</em>  </h5>
 
<strong>Infinite</strong>
```swift
timer.startTrack(seconds: 5, infinite: true)
```
<strong>One time</strong>
```swift
timer.startTrack(minutes: 10, infinite: false)
```

## Author

OlegTsib, olegtsib@gmail.com

## License

DisplayLink is available under the MIT license. See the LICENSE file for more info.






