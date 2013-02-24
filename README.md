# PShould #

**PShould** (pronounced "should" or "puh-should") is a fluent assertion module for Powershell.

PShould will validate a given assumption and throw an exception if the assumption is incorrect.

PShould is part of the PSST PowerShell Suite for Testing:

* [PSMock - mocking for PowerShell](https://github.com/jonwagner/PSMock)
* [PShould - fluent assertions for PowerShell](https://github.com/jonwagner/PShould)
* [PSate - test runner for PowerShell](https://github.com/jonwagner/PSate)

## Examples ##

Getting started:

	Import-Module PShould

	5 | should be 5
	0 | should not be 1
	0 | should not !be 1
	0 | should ! be 1
	(1,2) | should be (1,2)
	(1,2) | should not be (3,4)
	(1,2,3) | should not be (3,4)
	@{a=1;b=2} | should be @{a=1;b=2}
	@{a=1;b=2} | should not be @{a=1;b=3}
	@{a=1;b=2} | should not be @{a=1;b=2;c=3}
	5 | should equal 5
	0 | should not equal 1
	(1,2) | should equal (1,2)
	(1,2) | should not equal (3,4)
	(1,2,3) | should not equal (3,4)
	(1,2) | should contain 1
	(1,2) | should not contain 3
	"hi, bob" | should match 'bob$'
	"hi, james" | should not match 'bob$'
	"" | should be blank
	"bob" | should not be blank
	@() | should be empty
	@(1) | should not be empty
	$null | should be null
	5 | should not be null
	{ throw "whoops" } | should throw
	{ throw "whoops" } | should throw -any
	{ throw "whoops" } | should throw "whoops"
	{ throw "whoops" } | should not throw "dang"
	{ "hi" } | should not throw
	"hi" | should { param($value) $value -eq 'hi' }
	@(1,2) | should { param($value) $value[0] + $value[1] -eq 3 }
	@(2,2) | should not { param($value) $value[0] + $value[1] -eq 5 
	1 | should be 1 and | should be 1
	1 | should be 1 and | should not be 2
	@() | should count 0
	@(1) | should count 1
	@(1,2) | should count 2
	@(1,2) | should not count 1 and | should count 2
	"pshould.psm1" | should exist
	"notafile" | should not exist
	"pshould.psm1" | should containcontent "should"
	"pshould.psm1" | should not containcontent "supercalifragilisticexpialidocious$"
	5 | should be -gt 4
	5 | should be gt 4
	5 | should be `> 4

## Features ##

See the [PShould wiki](https://github.com/jonwagner/PShould/wiki) for full documentation.

* Fluent syntax
* Full help at `Get-Help Should*`
* Test based on conditionals
* Test throws with optional filtering
* And continuations
* Automatic array and hashtable validation at the element label
* -test option to return $true/$false instead of throwing an exception

## Getting PShould ##

A variety of ways:

- PSGet - [http://psget.net/](http://psget.net)
	- Get PSGet
	- Install-Module -nugetpackageid PShould
	- PShould will be installed into as a global module
- NuGet - [http://nuget.org/packages/PShould](http://nuget.org/packages/PShould)
	- Install-Package PShould
	- PShould will be installed into your current project
- GitHub - [Download PShould.psm1](https://github.com/jonwagner/PShould/tree/master/PShould.psm1)
	- Copy the file to your modules folder or a local folder

## Credits ##

PShould was inspired by the great work by the [Pester](https://github.com/pester/Pester) team, but has a totally different implementation now after a lot of rounds of coding...

