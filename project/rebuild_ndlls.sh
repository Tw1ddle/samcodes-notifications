#!/bin/bash

set -eu

haxelib run hxcpp Build.xml clean
haxelib run hxcpp Build.xml -Diphoneos
haxelib run hxcpp Build.xml -Diphoneos -DHXCPP_ARMV7
haxelib run hxcpp Build.xml -Diphoneos -DHXCPP_ARM64
haxelib run hxcpp Build.xml -Diphonesim
haxelib run hxcpp Build.xml -Diphonesim -DHXCPP_M64