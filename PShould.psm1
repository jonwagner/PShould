﻿<#
    PShould - Copyright(c) 2013 - Jon Wagner
    See https://github.com/jonwagner/PShould for licensing and other information.
    Version: $version$
    Changeset: $changeset$
#>

# operators for the be case
$operators = @{
    'GreaterThan' = '-gt'
    '-gt' = '-gt'
    'gt' = '-gt'
    '>' = '-gt'
    'LessThan' = '-lt'
    '-lt' = '-lt'
    'lt'  = '-lt'
    '<' = '-lt'
    'GreaterThanOrEqualTo' = '-ge'
    '-gte' = '-ge'
    '-ge' = '-ge'
    'gte' = '-ge'
    'ge' = '-ge'
    '>=' = '-ge'
    'LessThanOrEqualTo' = '-le'
    '-lte' = '-le'
    '-le' = '-le'
    'lte' = '-le'
    'le' = '-le'
    '<=' = '-le'
    'EqualTo' = '-eq'
    '-eq' = '-eq'
    'eq' = '-eq'
    '=' = '-eq'
    'NotEqualTo' = '-ne'
    '-ne' = '-ne'
    'ne' = '-ne'
    '!=' = '-ne'
    'in' = '-in'
    '-in' = '-in'
    'notin' = '-notin'
    '-notin' = '-notin'
}

$comparators = @(
    'Be',
    'Equal',
    'Throw',
    'Match',
    'Contain',
    'ContainAll',
    'ContainNone',
    'Count',
    'Exist',
    'ContainContent'
)

<#
.Synopsis
    A fluent syntax to assert values.
.Description
    A fluent syntax to assert values. If an assertion fails, an exception is thrown.

    Syntax:

    input | Should [not] [comparison] [expected] [as alias] [and | -test]

    The comparisons are:

    Be - the input is tested against the expected value. See Get-Help ShouldBe for details.
    Equal - the input is tested against the expected value. Arrays are tested for element equality.
    Contain - the input is a collection, and must contain the given value.
    Match - the input is a string, and must contain the given pattern.
    Count - the input is a collection, and must contain the given number of elements.
    Throw - the input is a script block, which is executed and the exception is tested.
    Exist - the input is a Path, and Test-Path is called to check its existence.
    ContainContent - the input is a Path, whose Get-Content is must contain a pattern.
    [ScriptBlock] - the scriptblock is executed. The first parameter is the input.

    If the expected value is follwed by 'as' then the next parameter is used to identify the
    assertion when an exception is thrown.

    If the command ends with 'and', then the inputs are copied to the output stream
    for further testing or operation.

    If the command ends with '-test', then the result of the test is output to the stream,
    and an exception is not thrown.

    For details on the individual operations, use Get-Help Should*
.Example
    1 | Should Be 1

    Tests that 1 is equal to 1.
.Example
    5 | Should Not Be GTE 6

    Tests that 5 is not greater than or equal to 6.
.Example
    @(a,b,c) | Should Count 3 and | Should Contain b

    Tests that the array is 3 elements long and contains the letter b.
.Example
    { Scary-Function } | Should Throw "bad mojo"

    Tests that Scary-Function throws an exception containing "bad mojo".
.Example
    5 | Should { param($value) $value -gt 4 }

    Tests that the input passes the given function.
.Example
    $answer | Should Be 42 as 'answer to the ultimate question of life, the universe and everything'

    Compares $answer to 42 and reports this error message if it is actually "money":
      Expected that (actual answer to the ultimate question of life, the universe and everything) (money) Be (42)
.Example
    "abc" | Should Match '^ab" -test

    Tests that "abc" starts with "ab" and returns the result rather than throwing an exception.f
.Link
    Should*
#>
function Should {

    # we are going to get a set of fluent arguments like "Not Be $null"
    # parse them into a set of values
    $i = 0
    $not = $false
    $comparator = $args[$i++]

    # gather the inputs into an array
    $savedinput = @($input)

    # unwrap certain types of collections if passed in individually
    if ($savedinput.Length -eq 1) {
        if (($savedinput[0] -is [Hashtable]) -or
            ($savedinput[0] -is [System.Collections.Specialized.OrderedDictionary])) {
            $savedinput = $savedinput[0]
        }
    }

    # handle not
    if (('not' -eq $comparator) -or ('!' -eq $comparator)) {
        $not = $true
        $comparator = $args[$i++]
    }
    if ($comparator -match '^!') {
        $not = $true
        $comparator = $comparator -replace '^!',''
    }

    # handle be operators
    if ($operators.Keys -contains $args[$i]) {
        $operator = $args[$i++]
    }

    # call the comparator
    if ($comparator -is [scriptblock]) {
        # handle scriptblock tests
        $result = & $comparator $savedinput
    }
    elseif ($comparators -contains $comparator) {
        # handle value
        $value = $args[$i++]

        # call the assertion by name
        $result = & "Should$comparator" $savedinput $value $operator
    }
    else {
        throw "Comparison $comparator is not supported"
    }

    # handle the result
    if ($not) {
        $result = !$result
    }

    $alias = ''
    if ($args[$i] -eq 'as') {
        $i++
        $alias = "'$($args[$i++])' "
    }

    # if the should ends in 'and', then emit the input for chaining
    if ($args[$i] -eq 'and') {
        $savedinput
    }

    if ($args[$i] -eq '-test') {
        # if -test is specified, then just output $true/$false
        if ($result) {
            $true
        }
        else {
            $false
        }
    }
    else {
        if (!$result) {
            if ($operator) { $operator += ' ' }
            if ($not) { $not = 'not ' } else { $not = '' }
            throw "Expected that $alias(actual) ($savedinput) $not$comparator $operator($value)"
        }
    }
}

<#
.Synopsis
    Tests whether two items are equal, with additional options.
.Description
    Tests whether two items are equal, with additional options.
.Parameter Actual
    The actual result.
.Parameter Expected
    The expected value, or one of the following values:

    Null - $null
    Blank - ''
    Empty - an empty array
.Parameter Operator
    A comparison operator to use. Default is -eq.

    This can be the PowerShell operators -eq -ne -gt -gte -lt -lte,
    or the more readable versions GreaterThan, lt, ne, !=, =, etc.
.Example
    ShouldBe 5 4 gt

    Checks whether the actual value 5 is greater than the expected value 4.
.Example
    7 | Should Not Be Null

    Tests that the value is not null
.Example
    $array.Count | Should Be GreaterThan 1

    Tests that the array count is greater than 1
.Link
    Should
#>
function ShouldBe {
    param (
        $Actual,
        $Expected,
        $Operator
    )

    # handle null by checking the value
    if ('Null' -eq $Expected) {
        return $($Actual) -eq $null
    }

    # handle blank by checking the string value
    if ('Blank' -eq $Expected) {
        [string] $s = $($Actual)
        return $s -eq ''
    }

    # handle empty by checking the length of the array
    if ('Empty' -eq $Expected) {
        return @($Actual).Length -eq 0
    }

    # map the operator
    if (!$Operator) {
        $Operator = '-eq'
    } else {
        $Operator = $operators[$Operator]
    }

    # evaluate equality or another operator
    if ($Operator -eq '-eq') {
        return ShouldEqualEx $Actual $Expected
    }
    elseif (('-in', '-notin') -contains $Operator) {
        # for in/notin, make sure all of the items are in/not in the expected array
        foreach ($item in $Actual) {
            if ($PSVersionTable.PSVersion.Major -lt 3) {
                $result = ("`$Expected $($Operator -replace 'in','contains') `$item" | iex)
            }
            else {
                $result = ("`$item $Operator `$Expected" | iex)
            }

            if (!$result) {
                return $false
            }
        }
        return $true
     }
    else {
        # although the operators handle dereferencing the array, it's an array of object and
        # then numerics get converted to string comparisons
        if ($Actual -is [system.array] -and $Actual.length -eq 1) {
            $Actual = $Actual[0]
        }
        return "`$Actual $Operator `$Expected" | iex
    }
}

<#
.Synopsis
    Tests whether two items are equal.
.Description
    Tests whether two items are equal.
.Parameter Actual
    The actual result.
.Parameter Expected
    The expected value.
.Example
    ShouldEqual 1 1

    Checks whether the actual value 1 is equal to the expected value 1.
.Example
    1 | Should Equal 1

    Checks whether the actual value 1 is equal to the expected value 1.
.Link
    Should
#>
function ShouldEqual {
    param (
        $Actual,
        $Expected
    )

    return ShouldEqualEx $Actual $Expected
}

# Internal function to test equality. Handles collection equality by testing the equality of elements.
function ShouldEqualEx {
    param (
        $Actual,
        $Expected
    )

    # array equality
    if (($Actual -is [System.Array]) -and ($Expected -is [System.Array])) {
        if ($Actual.Length -ne $Expected.Length) {
            return $false
        }

        for($i = 0; $i -lt $actual.Length; $i++) {
            if ($Actual[$i] -ne $Expected[$i]) {
                return $false
            }
        }

        return $true
    }

    # hashtable/dictionary equality
    if ((($($Actual) -is [Hashtable]) -and ($Expected -is [Hashtable])) -or
        (($($Actual) -is [System.Collections.Specialized.OrderedDictionary]) -and ($Expected -is [System.Collections.Specialized.OrderedDictionary]))) {
        $actualHashtable = $($Actual)
        if ($actualHashtable.Count -ne $Expected.Count) {
            return $false
        }

        foreach ($key in $Expected.Keys) {
            if ($actualHashtable[$key] -ne $Expected[$key]) {
                return $false
            }
        }

        return $true
    }

    return $Expected -eq $($Actual)
}

<#
.Synopsis
    Tests whether a collection contains a given element.
.Description
    Tests whether a collection contains a given element.
.Parameter Collection
    The collection to test.
.Parameter Element
    The expected element.
.Example
    ShouldContain @(a,b,c) 'b'

    Checks whether the given array contains the letter b.
.Example
    @(a,b,c) | Should Contain 'b'

    Checks whether the given array contains the letter b.
.Example
    @{"a"=1;"b"=2} | Should Contain 'b'

    Checks whether the given hashtable contains the letter b as a key.
.Link
    Should
#>
function ShouldContain {
    param (
        $Collection,
        $Element
    )

    return $Collection.Contains($Element)
}

<#
.Synopsis
    Tests whether a collection contains all the given elements.
.Description
    Tests whether a collection contains all the given elements.
.Parameter Collection
    The collection to test.
.Parameter Elements
    The expected elements.
.Example
    ShouldContainAll @(a,b,c) @('b','a','c')

    Checks whether the given array contains all the letters b, a, and c.
.Example
    @{a=1;c=3;b=2} | Should ContainAll @(b,a,c)

    Checks whether the given hashtable contains the letters b, a, and c as keys.
.Link
    Should
#>
function ShouldContainAll {
    param (
        $Collection,
        $Elements
    )

    $result = $True
    $Elements.GetEnumerator() | ForEach-Object {
        If (-Not ($Collection.Contains($_))) {
            $result = $False
        }
    }
    return $result
}

<#
.Synopsis
    Tests whether a collection contains none of the given elements.
.Description
    Tests whether a collection contains none of the given elements.
.Parameter Collection
    The collection to test.
.Parameter Elements
    The elements expected to not be present.
.Example
    ShouldContainNone @(a,b,c) @(e,f)

    Checks that the given array does not contain either of the letters e, or f.
.Example
    @{a=1;c=3;b=2} | Should ContainNone @(e,f,g)

    Checks that the given hashtable does not contain any of the keys e, f, or g.
.Link
    Should
#>
function ShouldContainNone {
    param (
        $Collection,
        $Elements
    )

    $result = $True
    $Elements.GetEnumerator() | ForEach-Object {
        If ($Collection.Contains($_)) {
            $result = $False
        }
    }
    return $result
}

<#
.Synopsis
    Tests whether a string matches a given pattern.
.Description
    Tests whether a string matches a given pattern.
.Parameter String
    The string to test.
.Parameter Match
    The pattern to match.
.Example
    ShouldMatch "Hi, Bob!" "Bob?$"

    Checks whether the given string ends with Bob and another character.
.Example
    "Hi, Bob!" | Should Match "Bob?$"

    Checks whether the given string ends with Bob and another character.
.Link
    Should
#>
function ShouldMatch {
    param (
        $String,
        $Match
    )

    return $($String) -match $Match
}

<#
.Synopsis
    Tests whether a collection has the given number of elements.
.Description
    Tests whether a collection has the given number of elements.
.Parameter Collection
    The collection to test.
.Parameter Count
    The expected number of elements.
.Example
    ShouldCount @(a,b,c) 3

    Checks whether the given array contain 3 elements.
.Example
    @(a,b,c) | Should Count 3

    Checks whether the given array contain 3 elements.
.Link
    Should
#>
function ShouldCount {
    param (
        $Collection,
        $Count
    )

    if ($Collection -and ($Collection | Get-Member Count)) {
        return $Collection.Count -eq $Count
    }

    return @($Collection).Count -eq $Count
}

<#
.Synopsis
    Tests whether a scriptblock throws.
.Description
    Tests whether a scriptblock throws. Optionally, this can also test that
    the exception matches a given pattern.
.Parameter Script
    The script block to test.
.Parameter Match
    If specified, tests whether the thrown exception matches the pattern.
    If Match is "-any", then any exception is matched.
.Example
    ShouldThrow { throw "foo" }

    Tests whether the given block throws.
.Example
    { throw "An error" } | Should Throw "Error"

    Tests whether the given block throws an error that contains error
.Link
    Should
#>
function ShouldThrow {
    param (
        $Script,
        $Match
    )

    try {
        # execute the script and eat the results
        & $($Script) | Out-Null

        return $false
    }
    catch {
        if (!$Match -or ($Match -eq '-any')) {
            return $true
        }

        return $_ -match $Match
    }
}

<#
.Synopsis
    Tests whether a file exists.
.Description
    Tests whether a file exists. Internally, this calls Test-Path.
.Parameter Path
    The name of the file to test.
.Example
    ShouldExist 'PShould.ps1'

    Tests whether the file PShould.ps1 exists.
.Example
    'PShould.ps1' | Should Exist

    Tests whether the file PShould.ps1 exists.
.Link
    Should
#>
function ShouldExist {
    param (
        $Path
    )

    return Test-Path $Path
}

<#
.Synopsis
    Tests whether a file exists and contains the given content.
.Description
    Tests whether a file exists and contains the given content.
    The content is a regex match.
.Parameter Path
    The name of the file to test.
.Parameter Match
    The regex match to check for.
.Example
    ShouldContainContent 'PShould.ps1' '^function'

    Tests whether the file PShould.ps1 contains the word function at the beginning of a line.
.Example
    'PShould.ps1' | Should ContainContent '^function'

    Tests whether the file PShould.ps1 contains the word function at the beginning of a line.
.Link
    Should
#>
function ShouldContainContent {
    param (
        $Path,
        $Match
    )

    return ((Get-Content $Path) -match $Match)
}

# export all of the functions so we can see help on all of them
Export-ModuleMember Should, ShouldBe, ShouldEqual, ShouldContain, ShouldContainAll,
    ShouldContainNone, ShouldMatch, ShouldCount, ShouldThrow, ShouldExist, ShouldContainContent
