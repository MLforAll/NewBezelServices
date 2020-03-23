# NewBezelServices

This app is a replacement for macOS HUD (for volume, brightness, etc...)

## Features

- Uses the same XPC connection as Apple's OSDUIHelper
- Can catch all events Apple's indicator can (altho only 4 are implemented)
- Volume, Brightness, Keyboard Brightness Indicator
- Set Volume and Brightness from indicator

_Light Mode_

![](screenshots/NewBezelServicesLight.png)

_Dark Mode_

![](screenshots/NewBezelServicesDark.png)

## Compatibility

The app is made to be compatible with Mac OS X Lion and up.

However, the XPC method only works on **macOS Sierra and up**.<br/>
**Why ?** OS X 10.11 and earlier use a different XPC MachService name as well as the C-based API compared to the Obj-C/Swift API used in macOS 10.12 and later.

**Thus, the app deployement target is set to 10.12**.

If you want to run it on 10.7-10.11, you can do so by compiling the project in Debug mode.

## Disable Apple's OSDUIHelper

Because NewBezelServices is using the same XPC connection as Apple's OSDUIHelper, if it is loaded, then NewBezelServices won't get XPC messages (OSDUIHelper will get them instead).

So you need to disable it before installing NewBezelServices.

**SIP DISABLED**

~~~
$ launchctl unload -w /System/Library/LaunchAgent/com.apple.OSDUIHelper.plist
~~~

**SIP ENABLED**

With SIP turned on, you won't be able to unload OSDUIHelper with the command above.

To disable it:

- Reboot your Mac in Recovery Mode (`Cmd + R` at bootup)
- Open Terminal
- `cd /Volumes/Macintosh\ HD/System/Library/LaunchAgents`
- `mv com.apple.OSDUIHelper.plist com.apple.OSDUIHelper.plist__`
- `reboot`

## Build and Install

To build, just type :

~~~
$ make
~~~

or open the Xcode project and `Cmd + B`.

To install, type :

~~~
$ sudo make install
~~~

## Manual Install

To install NewBezelServices:

- Build the app
- Copy `NewBezelServices.app` somewhere
- Copy the `com.mlforall.NewBezelServices.plist` to `/Library/LaunchAgents` or `~/Library/LaunchAgents`

The default path for `NewBezelServices.app` is `/Library/Services/NewBezelServices.app`

If you copy it elsewhere, don't forget to change the path in `com.mlforall.NewBezelServices.plist`

**You cannot use NewBezelServices without a LaunchAgents**

The app will open, but won't get any XPC message.
