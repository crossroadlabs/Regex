# Regex v0.2 [![GitHub license](https://img.shields.io/badge/license-Apache 2.0-lightgrey.svg)](https://raw.githubusercontent.com/crossroadlabs/Regex/master/LICENSE) [![GitHub release](https://img.shields.io/github/release/crossroadlabs/Regex.svg)](https://github.com/crossroadlabs/Regex/releases) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

**Regular expressions for Swift**

## Getting started

### Installation

Add following lines to your Cartfile:  

	github "crossroadlabs/Regex" "develop"

### Examples

Hellow Regex:

```swift
// strings can be converted to regex in Scala style .r property of a string
let digits = "(.+?)([1,2,3]*)(.*)".r?.findFirst("l321321alala")?.group(2)
// digits is "321321" here
```

Named groups:

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

Replace:

```swift
let replaced = "(.+?)([1,2,3]*)(.*)".r?.replaceAll("l321321alala", replacement: "$1-$2-$3")
//replaced is "l-321321-alala"
```

Replace with custom replacer function:

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

## Roadmap

* v0.2 replace support
* v0.3 split
* v0.4 syntactic sugar operators (like ~=)
* v0.5 alternative PCRE based implementation (OS X, Linux)
* v1.0 full Linux support

## Changelog

* v0.2
	* Replace functions
	* Carthage support
* v0.1
	* basic find functions for OS X and iOS
