[cmdletbinding()]
Param (
  [string]$ScriptPath      = "C:\Automation\AD\Cleanup\",
  [string]$LogDirectory    = "logfiles\",
  [string]$Date            = (Get-Date).ToString("dd-MM-yyyy"),
  [string[]]$NamedExceptions = (Get-Content $ScriptPath`ADnamedExceptions.txt),
  [string]$Server          = "DC002.domain.com"
)
