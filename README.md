[![by Crossroad Labs](./header.png)](http://www.crossroadlabs.xyz/)

# Regex

![🐧 linux: ready](https://img.shields.io/badge/%F0%9F%90%A7%20linux-ready-red.svg)
[![GitHub license](https://img.shields.io/badge/license-Apache%202.0-lightgrey.svg)](https://raw.githubusercontent.com/crossroadlabs/Regex/master/LICENSE)
[![Build Status](https://travis-ci.org/crossroadlabs/Regex.svg?branch=master)](https://travis-ci.org/crossroadlabs/Regex)
[![GitHub release](https://img.shields.io/github/release/crossroadlabs/Regex.svg)](https://github.com/crossroadlabs/Regex/releases)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods version](https://img.shields.io/cocoapods/v/CrossroadRegex.svg)](https://cocoapods.org/pods/CrossroadRegex)
![Platform OS X | iOS | tvOS | watchOS | Linux](https://img.shields.io/badge/platform-Linux%20%7C%20OS%20X%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-orange.svg)

## Advanced regular expressions for Swift

## Goals

[<img align="left" src="https://raw.githubusercontent.com/crossroadlabs/Express/master/logo-full.png" hspace="20" height=128>](https://github.com/crossroadlabs/Express) Regex library was mainly introduced to fulfill the needs of [Swift Express](https://github.com/crossroadlabs/Express) - web application server side framework for Swift.

Still we hope it will be useful for everybody else.

[Happy regexing ;)](#examples)

## Features

- [x] Deep Integration with Swift
	- [x] `=~` operator support
	- [x] Swift Pattern Matching (aka `switch` operator) support
- [x] Named groups
- [x] Match checking
- [x] Extraction/Search functions
- [x] Replace functions
	- [x] With a pattern
	- [x] With custom replacing function
- [x] Splitting with a Regular Expression
	- [x] Simple
	- [x] With groups
- [x] String extensions

## Extra

Path to Regex converter is available as a separate library here: [PathToRegex](https://github.com/crossroadlabs/PathToRegex)

This one allows using path patterns like `/folder/*/:file.txt` or `/route/:one/:two` to be converted to Regular Expressions and matched against strings.

## Getting started

### Installation

#### [Package Manager](https://swift.org/package-manager/)

Add the following dependency to your [Package.swift](https://github.com/apple/swift-package-manager/blob/master/Documentation/Usage.md#define-dependencies):

```swift
.Package(url: "https://github.com/crossroadlabs/Regex.git", majorVersion: 1)
```

Run ```swift build``` and build your app.

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

#### Manually
1. Download and drop ```/Regex``` folder in your project.  
2. Congratulations! 

### Examples

#### Hello Regex:

All the lines below are identical and represent simple matching. All operators and `matches` function return Bool

```swift
//operator way, can match either regex or string containing pattern
"l321321alala" =~ "(.+?)([123]*)(.*)".r
"l321321alala" =~ "(.+?)([123]*)(.*)"

//similar function
"(.+?)([123]*)(.*)".r!.matches("l321321alala")
```
Operator `!~` returns `true` if expression does **NOT** match:

```swift
"l321321alala" !~ "(.+?)([123]*)(.*)".r
"l321321alala" !~ "(.+?)([123]*)(.*)"
//both return false
```

#### Swift Pattern Matching (aka `switch` keyword)

Regex provides very deep integration with Swift and can be used with the switch keyword in the following way:

```swift
let letter = "a"
let digit = "1"
let other = "!"

//you just put your string is a regular Swift's switch to match to regular expressions
switch letter {
	//note .r after the string literal of the pattern
	case "\\d".r: print("digit")
	case "[a-z]".r: print("letter")
	default: print("bizarre symbol")
}

switch digit {
	case "\\d".r: print("digit")
	case "[a-z]".r: print("letter")
	default: print("bizarre symbol")
}

switch other {
	//note .r after the string literal of the pattern
	case "\\d".r: print("digit")
	case "[a-z]".r: print("letter")
	default: print("bizarre symbol")
}
```

The output of the code above will be:

```
letter
digit
bizarre symbol
```

#### Accessing groups:

```swift
// strings can be converted to regex in Scala style .r property of a string
let digits = "(.+?)([123]*)(.*)".r?.findFirst(in: "l321321alala")?.group(at: 2)
// digits is "321321" here
```

#### Named groups:

```swift
let regex:RegexType = try Regex(pattern:"(.+?)([123]*)(.*)",
                                        groupNames:"letter", "digits", "rest")
let match = regex.findFirst(in: "l321321alala")
if let match = match {
	let letter = match.group(named: "letter")
	let digits = match.group(named: "digits")
	let rest = match.group(named: "rest")
	//do something with extracted data
}
```

#### Replace:

```swift
let replaced = "(.+?)([123]*)(.*)".r?.replaceAll(in: "l321321alala", with: "$1-$2-$3")
//replaced is "l-321321-alala"
```

#### Replace with custom replacer function:

```swift
let replaced = "(.+?)([123]+)(.+?)".r?.replaceAll(in: "l321321la321a") { match in
	if match.group(at: 1) == "l" {
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
let nameList = names.split(using: "\\s*;\\s*".r)
//name list contains ["Harry Trump", "Fred Barney", "Helen Rigby", "Bill Abel", "Chris Hand"]
```

#### Split with groups:

If separator contains capturing parentheses, matched results are returned in the array.

```swift
let myString = "Hello 1 word. Sentence number 2."
let splits = myString.split(using: "(\\d)".r)
//splits contains ["Hello ", "1", " word. Sentence number ", "2", "."]
```

## Changelog

You can view the [CHANGELOG](./CHANGELOG.md) as a separate document [here](./CHANGELOG.md).

## Contributing

To get started, <a href="https://www.clahub.com/agreements/crossroadlabs/Regex">sign the Contributor License Agreement</a>.

## [![Crossroad Labs](http://i.imgur.com/iRlxgOL.png?1) by Crossroad Labs](http://www.crossroadlabs.xyz/)
