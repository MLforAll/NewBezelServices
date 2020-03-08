# NewBezelServices

This app is a replacement for macOS' volume/brightness... indicator.

It uses XPC and requires macOS 10.12.

If run in debug mode, it will detect keys instead of XPC.

## Compatibility

The app is made to be compatible with Mac OS X Lion and up.

However, the XPC method will only work on macOS Sierra and up.

If you want to run it on 10.7-10.11, you can do so by compiling the project in Debug mode.

## Building and Installing

To build, just type :

~~~
$ make
~~~

or open the Xcode project and `Cmd + B`.

To install, type :

~~~
$ sudo make install
~~~

Please note that you should unload Apple's OSDUIHelper first :

~~~
$ launchctl unload /System/Library/LaunchAgent/com.apple.OSDUIHelper.plist
~~~
