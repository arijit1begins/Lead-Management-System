Function FunctionScope
{
    'Changing $MyVar with a function.'
    $MyVar = 'I got set by a function!'
    "MyVar says $MyVar"
}
''
'Checking current value of $MyVar.'
"MyVar says $MyVar"
''
'Changing $MyVar by script.'
$MyVar = 'I got set by a script!'
"MyVar says $MyVar"
''
FunctionScope
''
'Checking final value of MyVar before script exit.'
"MyVar says $MyVar"
''