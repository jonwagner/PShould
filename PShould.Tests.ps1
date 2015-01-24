Import-Module .\PShould.psm1 -Force

$failedTests = 0

function Check {
    param (
        [string] $name,
        [scriptblock] $test
    )

    try {
        & $test

        Write-Host "PASS: $name"
    }
    catch {
        Write-Host "FAIL: $name"
        Write-Host $_       
        $script:failedTests++;
    }
}

function Throws {
    param (
        [string] $name,
        [scriptblock] $test
    )

    try {
        & $test

        Write-Host "FAIL: $name"
        $script:failedTests++;
    }
    catch {
        Write-Host "PASS: $name"
    }
}

Check "BE" { 5 | should be 5 }
Check "NOT BE" { 0 | should not be 1 }
Check "$true is $true" { $true | should be $true }
Throws "$false is $true" { $false | should be $true }
Check "!BE" { 0 | should not !be 1 }
Check "! BE" { 0 | should ! be 1 }
Check "BE ARRAY" { (1,2) | should be (1,2) }
Check "NOT BE ARRAY" { (1,2) | should not be (3,4) }
Check "NOT BE ARRAY OF DIFFERENT LENGTHS" { (1,2,3) | should not be (3,4) }
Check "BE HASHTABLE" { @{a=1;b=2} | should be @{a=1;b=2} }
Check "NOT BE HASHTABLE" { @{a=1;b=2} | should not be @{a=1;b=3} }
Check "NOT BE HASHTABLE OF DIFFERENT LENGTHS" { @{a=1;b=2} | should not be @{a=1;b=2;c=3} }
Check "EQUAL" { 5 | should equal 5 }
Check "NOT EQUAL" { 0 | should not equal 1 }
Check "EQUAL ARRAY" { (1,2) | should equal (1,2) }
Check "NOT EQUAL ARRAY" { (1,2) | should not equal (3,4) }
Check "NOT EQUAL ARRAY OF DIFFERENT LENGTHS" { (1,2,3) | should not equal (3,4) }
Check "ARRAY CONTAIN" { (1,2) | should contain 1 }
Check "NOT ARRAY CONTAIN" { (1,2) | should not contain 3 }
Check "MATCH" { "hi, bob" | should match 'bob$' }
Check "NOT MATCH" { "hi, james" | should not match 'bob$' }
Check "BLANK" { "" | should be blank }
Check "NOT BLANK" { "bob" | should not be blank }
Check "EMPTY ARRAY" { @() | should be empty }
Check "NOT EMPTY ARRAY" { @(1) | should not be empty }
Check "NULL" { $null | should be null }
Check "NOT NULL" { 5 | should not be null }
Check "THROW" { { throw "whoops" } | should throw }
Check "THROW ANY" { { throw "whoops" } | should throw -any }
Check "THROW MATCH" { { throw "whoops" } | should throw "whoops" }
Check "NOT THROW MATCH" { { throw "whoops" } | should not throw "dang" }
Check "NOT THROW" { { "hi" } | should not throw }
Check "SCRIPTBLOCK" { "hi" | should { param($value) $value -eq 'hi' } }
Check "SCRIPTBLOCK ARRAY" { @(1,2) | should { param($value) $value[0] + $value[1] -eq 3 } }
Check "NOT SCRIPTBLOCK" { @(2,2) | should not { param($value) $value[0] + $value[1] -eq 5 } }
Check "AND" { 1 | should be 1 and | should be 1 }
Check "AND NOT" { 1 | should be 1 and | should not be 2 }
Check "COUNT" { @() | should count 0 }
Check "COUNT 1" { @(1) | should count 1 }
Check "COUNT 2" { @(1,2) | should count 2 }
Check "COUNT AND COUNT" { @(1,2) | should not count 1 and | should count 2 }
Check "HASHTABLE COUNT" { @{"a"=1;"b"=2} | should count 2 }
Check "EXIST" { "pshould.psm1" | should exist }
Check "NOT EXIST" { "notafile" | should not exist }
Check "CONTAINCONTENT" { "pshould.psm1" | should containcontent "should" }
Check "NOT CONTAINCONTENT" { "pshould.psm1" | should not containcontent "supercalifragilisticexpialidocious$" }
Check "OPERATOR -GT" { 5 | should be -gt 4 }
Check "OPERATOR GT" { 5 | should be gt 4 }
Check "OPERATOR >" { 5 | should be `> 4 }
Check "-TEST" { 5 | should be 5 -test }
Check "NOT -TEST" { 7 | should not be 8 -test }
Throws "Invalid Comparator true" { $true | should $true }
Throws "Invalid Comparator foo" { $true | should foo }
Throws '$null is not a collection' { $null | should be ("Null","Blank","Empty") }
Check "NULL IN" { $null | should be -in ($null, "Null","Blank","Empty") }
Check "IN" { 'null' | should be in ($null, "Null","Blank","Empty") }
Check "ARRAY IN" { (1, 2) | should be in (1, 2, 3) }
Throws "ARRAY NOT IN" { (4) | should be in (1, 2, 3) }
Check "NULL INPUT" { $null | should be $Null }
Throws "ARRAY INEQUALITY" { ,(1, 2) | Should Be In ((1, 2), (3, 4)) }
Check "OBJECT EQUALITY" { $a = (1, 2); ,$a | Should Be In ($a, (3, 4)) }
Check "ORDERED DICTIONARY EQUALITY" {
    # requires PS3.0 or later
    if ($PSVersionTable.PSVersion.Major -ge 3) {
        $o1= [ordered]@{a=1;b=2;c=3}
        $o2= [ordered]@{a=1;b=2;c=3}
        $o1  | Should Equal $o2
    }
}
Check "ORDERED DICTIONARY COUNT" {
    # requires PS3.0 or later
    if ($PSVersionTable.PSVersion.Major -ge 3) {
        $o1= [ordered]@{a=1;b=2;c=3}
        $o1  | Should Count 3
    }
}
Throws "FAIL ON ANY FAILING CHAINED SHOULD" { @('a','b','c') | Should Count 2 and | Should Contain 'b' }

if ($failedTests -gt 0) {
    throw "FAIL: $failedTests failed tests"
}