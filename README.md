# Regex

[![GitHub license](https://img.shields.io/badge/license-Apache 2.0-lightgrey.svg)](https://raw.githubusercontent.com/crossroadlabs/Regex/master/LICENSE)
[![Build Status](https://travis-ci.org/crossroadlabs/Regex.svg?branch=master)](https://travis-ci.org/crossroadlabs/Regex)
[![GitHub release](https://img.shields.io/github/release/crossroadlabs/Regex.svg)](https://github.com/crossroadlabs/Regex/releases)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods version](https://img.shields.io/cocoapods/v/CrossroadRegex.svg)](https://cocoapods.org/pods/CrossroadRegex)
![Platform OS X | iOS | tvOS | watchOS](https://img.shields.io/badge/platform-OS%20X%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-orange.svg)

## Advanced regular expressions for Swift

## Getting started

### Installation

#### [CocoaPods](http://cocoapods.org/)
Add the following to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```rb
pod 'CrossroadRegex'
```

Make sure that you are integrating your dependencies using frameworks: add `use_frameworks!` to your Podfile. Then run `pod install`.

#### [Carthage](https://github.com/Carthage/Carthage)
Add the following to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

```
github "crossroadlabs/Regex"
```

Run `carthage update` and follow the steps as described in Carthage's [README](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

### Examples

#### Hello Regex:

All the lines below are identical and represent simple matching. All operators and `matches` function return Bool

```swift
//operator way, can match either regex or string containing pattern
"l321321alala" =~ "(.+?)([1,2,3]*)(.*)".r
"l321321alala" =~ "(.+?)([1,2,3]*)(.*)"

//similar function
"(.+?)([1,2,3]*)(.*)".r!.matches("l321321alala")
```
Operator `!~` returns `true` if expression does **NOT** match:

```swift
"l321321alala" !~ "(.+?)([1,2,3]*)(.*)".r
"l321321alala" !~ "(.+?)([1,2,3]*)(.*)"
//both return false
```

#### Accessing groups:

```swift
// strings can be converted to regex in Scala style .r property of a string
let digits = "(.+?)([1,2,3]*)(.*)".r?.findFirst("l321321alala")?.group(2)
// digits is "321321" here
```

#### Named groups:

```swift
let regex:RegexType = try Regex(pattern:"(.+?)([1,2,3]*)(.*)",
	groupNames:"letter", "digits", "rest")
let match = regex.findFirst("l321321alala")
if let match = match {
	let letter = match.group("letter")
	let digits = match.group("digits")
	let rest = match.group("rest")
	//do something with extracted data
}
```

#### Replace:

```swift
let replaced = "(.+?)([1,2,3]*)(.*)".r?.replaceAll("l321321alala", replacement: "$1-$2-$3")
//replaced is "l-321321-alala"
```

#### Replace with custom replacer function:

```swift
let replaced = "(.+?)([1,2,3]+)(.+?)".r?.replaceAll("l321321la321a") { match in
	if match.group(1) == "l" {
		return nil
	} else {
		return match.matched.uppercaseString
	}
}
//replaced is "l321321lA321A"
```

#### Split:

In the following example, split() looks for 0 or more spaces followed by a semicolon followed by 0 or more spaces and, when found, removes the spaces from the string. nameList is the array returned as a result of split().

```swift
let names = "Harry Trump ;Fred Barney; Helen Rigby ; Bill Abel ;Chris Hand"
let nameList = names.split("\\s*;\\s*".r)
//name list contains ["Harry Trump", "Fred Barney", "Helen Rigby", "Bill Abel", "Chris Hand"]
```

#### Split with groups:

If separator contains capturing parentheses, matched results are returned in the array.

```swift
let myString = "Hello 1 word. Sentence number 2."
let splits = myString.split("(\\d)".r)
//splits contains ["Hello ", "1", " word. Sentence number ", "2", "."]
```

## Goals

Regex framework was mainly introduced to fulfill the needs of [Swift Express](https://github.com/crossroadlabs/Express) - web application server side framework for Swift. Still we hope it will be useful for everybody else.

## Roadmap

* v0.5: alternative PCRE based implementation (OS X, Linux)
* v1.0: full Linux support

## Changelog
* v0.4.1
	* support for optionally present groups
* v0.4
	* iOS, tvOS and watchOS support
	* Pod supports watchOS
	* automated pod deployment
* v0.3
	* Split
	* Matches
	* CocoaPod
	* Syntactic sugar operators (`=~` and `!~`)
* v0.2
	* Replace functions
	* Carthage support
* v0.1
	* basic find functions for OS X and iOS

## Contributing

To get started, <a href="https://www.clahub.com/agreements/crossroadlabs/Regex">sign the Contributor License Agreement</a>.

## [![Crossroad Labs](http://i.imgur.com/iRlxgOL.png?1) by Crossroad Labs](http://www.crossroadlabs.xyz/)
