﻿Import-Module -Name Statistics -Force

Describe 'Statistics' {
    Context 'ConvertFrom-PrimitiveType' {
        $array = @(1, 2, 3)
        It 'Produces output from parameter' {
            $data = ConvertFrom-PrimitiveType -InputObject $array
            $data -is [array] | Should Be $true
            $data.Length | Should Be $array.Length
        }
        It 'Produces output from pipeline' {
            $data = $array | ConvertFrom-PrimitiveType
            $data -is [array] | Should Be $true
            $data.Length | Should Be $array.Length
        }
        It 'Throws on piped complex type' {
            { Get-Process | Select-Object -First 1 | ConvertFrom-PrimitiveType } | Should Throw
        }
    }
    Context 'Get-Histogram' {
        $data = 1..10 | ConvertFrom-PrimitiveType
        It 'Produces output from parameter' {
            $histogram = Get-Histogram -InputObject $data -Property Value
            $histogram -is [array] | Should Be $true
            $histogram.Length | Should Be 9
        }
        It 'Produces output from pipeline' {
            $histogram = $data | Get-Histogram -Property Value
            $histogram -is [array] | Should Be $true
            $histogram.Length | Should Be 9
        }
        It 'Produces output type [HistogramBucket]' {
            $item = $data | Get-Histogram -Property Value | Select-Object -First 1
            $item.PSTypeNames -contains 'HistogramBucket' | Should Be $true
        }
        It 'Honors minimum and maximum values' {
            $histogram = Get-Histogram -InputObject $data -Property Value -Minimum 2 -Maximum 5
            $histogram | Select-Object -First 1 -ExpandProperty lowerBound | Should Be 2
            $histogram | Select-Object -Last  1 -ExpandProperty upperBound | Should Be 5
        }
        It 'Dies on missing property' {
            $data = 1..10
            { Get-Histogram -InputObject $data -Property Value } | Should Throw
        }
    }
    Context 'Add-Bar' {
        It 'Produces bars from parameter' {
            $data = Get-Process | Select-Object -Property Name,Id,WorkingSet
            $bars = Add-Bar -InputObject $data -Property WorkingSet -Width 50
            $bars | ForEach-Object {
                $_.PSObject.Properties | Where-Object Name -eq 'Bar' | Select-Object -ExpandProperty Name | Should Be 'Bar'
            }
        }
        It 'Produces bars from pipeline' {
            $data = Get-Process | Select-Object -Property Name,Id,WorkingSet
            $bars = $data | Add-Bar -Property WorkingSet -Width 50
            $bars | ForEach-Object {
                $_.PSObject.Properties | Where-Object Name -eq 'Bar' | Select-Object -ExpandProperty Name | Should Be 'Bar'
            }
        }
        It 'Produces output type [HistogramBucket]' {
            $item = Get-Process | Add-Bar -Property WorkingSet -Width 50 | Select-Object -First 1
            $item.PSTypeNames -contains 'HistogramBar' | Should Be $true
        }
        It 'Has one bar of maximum width' {
            $data = Get-Process | Select-Object -Property Name,Id,WorkingSet
            $bars = Add-Bar -InputObject $data -Property WorkingSet -Width 50
            $bars | Where-Object { $_.Bar.Length -eq 50 } | Should Not Be $null
        }
        It 'Dies on missing property' {
            $data = 1..10
            { Add-Bar -InputObject $data -Property Value } | Should Throw
        }
    }
    Context 'Measure-Object' {
        It 'Produces output from parameter' {
            $data = 0..10 | ConvertFrom-PrimitiveType
            $Stats = Measure-Object -InputObject $data -Property Value
            $Stats | Select-Object -ExpandProperty Property | Should Be 'Value'
        }
        It 'Produces output from pipeline' {
            $data = 0..10 | ConvertFrom-PrimitiveType
            $Stats = $data | Measure-Object -Property Value
            $Stats | Select-Object -ExpandProperty Property | Should Be 'Value'
        }
        It 'Produces correct Median for an odd number of values' {
            $data = 0..10 | ConvertFrom-PrimitiveType
            $Stats = Measure-Object -InputObject $data -Property Value
            $Stats.Median | Should Be 5
        }
        It 'Produces correct Median for an even number of values' {
            $data = 1..10 | ConvertFrom-PrimitiveType
            $Stats = Measure-Object -InputObject $data -Property Value
            $Stats.Median | Should Be 5.5
        }
        It 'Dies on missing property' {
            $data = 1..10
            { Measure-Object -InputObject $data -Property -Value } | Should Throw
        }
    }
    Context 'Show-Measurement' {
        $stats = 0..10 | ConvertFrom-PrimitiveType | Measure-Object -Property Value
        It 'Produces a string' {
            $graph = $stats | Show-Measurement
            $graph -is [string] | Should Be $true
        }
    }
}