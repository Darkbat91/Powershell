<#
.SYNOPSIS
	New York State Identification and Intelligence System Implimentation in Powershell
.DESCRIPTION
	Creates a General Phonetic pronunciation of words in order to compare for common misspellings and user error.
.PARAMETER Word
    The Word that is going to be parsed
	
.NOTES	
Author: Micah
Version: 1
Date Created: 04APR2015
Date Modified
	#>

function Create-NYSIIS(){
param(
	[Parameter(Mandatory=$true)][string]$word
	)



#Just to lower the word
$word = $word.ToLower()

#####     Rule 1    #####
# Replace First characters of name

#MAC → MCC  
$word = $word -replace [regex]'^mac', "mcc"

#KN → N
$word = $word -replace [regex]'^kn', "n"

#K → C
$word = $word -replace [regex]'^k', "c"

#SCH → SSS
$work = $word -replace [regex]'^sch', "sss"

#PH, PF → FF,
$work = $word -replace [regex]'^ph|pf', "ff"

#####     Rule 2    #####
#Translate last characters of name

#EE, IE → Y
$word = $word -replace [regex]'ee|ie$', "y"

#DT, RT, RD, NT, ND → D
$word = $word -replace [regex]'dt|rt|rd|nt|nd$', "d"


#####     Rule 3    #####
#First character of key = first character of name

$key = $word[0]
$word = $word -replace "^$($word[0])", ""

#####     Rule 4    #####
#Translate remaining characters by following rules, incrementing by one character each time: 

#EV → AF else A, E, I, O, U → A
$word = $word -replace [regex]'ev', "af"
$word = $word -replace [regex]'[aeiou]', "a"

#Q → G
$word = $word -replace [regex]'q', "g"

#Z → S
$word = $word -replace [regex]'z', "s"

#M → N
$word = $word -replace [regex]'m', "n"

#KN → N
$word = $word -replace [regex]'kn', "n"

#K → C
$word = $word -replace [regex]'k', "c"

#SCH → SSS
$word = $word -replace [regex]'sch', "sss"

#PH, PF → FF,
$word = $word -replace [regex]'ph', "ff"

$word = $word -replace [regex]'([aeiou])(w)', '$1a'

$word = $word -replace [regex]'([aeiou])(w)', '$1a'


$word = $word -replace [regex]'([b-z&&[^eiou])h([b-z&&[^eiou])', '$1$1$2'

$word = $word -replace [regex]'[sa]$', ''

$word = $word -replace [regex]'ay$', 'y'


$key += $word

$key
} 
