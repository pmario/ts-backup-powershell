# author: Mario Pietsch
# version: 0.2.2
# source: https://github.com/pmario/ts-backup-powershell
# license: CC-BY-NC-SA
# 
# This script allows you to download your wikis from tiddlyspace.com

$tsHost="http://tiddlyspace.com"

Function LogAdd {

	Param ([string]$logstring)
	Add-content $Logfile -value $logstring
}

Function tsSetCredentials() {

	write-host "`nImportant:
	The user name and password will be transfered in plain text!
	Use this sript on your trusted home network only !!!!!!!

	A new <UserName> subdirectory will be created. 
	This allows you to download content for different users!

	Use [Ctrl]-C to stop the script at any time!`n"

	# get tiddlyspace user name   userName.tiddlyspace.com
	$user = Read-Host TiddlySpace Username

	# hide plain text password, so it's not stored in the shell history.
	$pass = Read-Host TiddlySpace Password -AsSecureString 

	# convert it back to a variable. .. be aware .. everything is plain text!
	$pair = "$($user):$( (New-Object System.Net.NetworkCredential("a", $pass, "a")).Password)"

	$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))

	$basicAuthValue = "Basic $encodedCreds"

	$Headers = @{
		Authorization = $basicAuthValue
	}

	# read all my spaces with basic auth and write to json file. 
	# (Invoke-WebRequest -Uri "http://$($user).tiddlyspace.com/spaces?mine=1" -Headers $Headers).Content | Out-File "test.json" -force;

	# gives us a list of all our spaces and creates a session cookie. 
	$response = Invoke-WebRequest -Uri "http://tiddlyspace.com/spaces?mine=1" -Headers $Headers -SessionVariable ts

	# test read with session cookie
	# Invoke-WebRequest -Uri "http://$($user).tiddlyspace.com/spaces?mine=1"  -WebSession $ts

	# debug info. show cookie
	#$ts
	
	Set-Variable -Name response -Value $response -Scope Global
	Set-Variable -Name user -Value $user -Scope Global
	Set-Variable -Name ts -Value $ts -Scope Global
}

Function tsShowList() {
	# convert TS JSON list to psList object, we can use. 

	$list = ($response).content

	#$list
	#exit

	$psList = ConvertFrom-JSON $list

	Write-Host ("`n---> Those Spaces are prepared to be downloaded:`n")

	if (!$psList.name) {
		Write-Host ("The list is empty! `nPlease check your username and password!

 - If this doesn't work you can log in to your tiddylspace, with the browser.
 - Then try this link: http://tiddlyspace.com/spaces?mine=1 `
 - If the browser shows an empty page: [], try to get help from the mailing list.`n")
		exit
	}

	# add lofile, to make it easier to move the stuff to the internet archive.org
	# see: https://archive.org/web/  "Save Page Now" section
	
	$logfile = "$user-spaces.log"

	If (Test-Path $logfile){
		Remove-Item $logfile
	}
	
	foreach($obj in $psList)
	{
	#    Write-Host ("Object: " + $obj)
	#    Write-Host ("Name: " + $obj.name)
		Write-Host ("  " + $obj.uri)
		LogAdd($obj.uri)
	}
	
}


Function tsGetAll() {

	# the response object also contains a lot of meta data.
	$list = ($response).content

	# convert TS JSON list to psList object, we can use. 
	$psList = ConvertFrom-JSON $list

#	$psList

	Write-Host ("`nDirectory will be created: $($user)")
	mkdir $user -force
	
	foreach($space in $psList)
	{
		Write-Host ("`n---> Get Info from: " + $space.uri)
		
		# get the public recipe. It can be used to regenerate the structure. This info is optional!!!
		(Invoke-WebRequest -Uri "$($tsHost)/recipes/$($space.name)_public.txt" -WebSession $ts).content  | Out-File "$($user)\$($space.name)_public.recipe.txt" -encoding utf8 -force;
		
		$props = "public", "private"

		foreach($mode in $props) {
			# Write-Host ("test: " + $mode)
						
			$uri="$($tsHost)/bags/$($space.name)_$($mode)/tiddlers.json?fat=1"
			# dev only! the following json is empty!
			#$uri="$($tsHost)/bags/dboxgallery_$($mode)/tiddlers.json?fat=1"
			#$uri
			
			$tiddlers = (Invoke-WebRequest -Uri "$($uri)" -WebSession $ts).content  
			$tiddlers | Out-File "$($user)\$($space.name)_$($mode).json" -encoding utf8 -force;
			# $tiddlers

			$tiddlersJSON = ConvertFrom-JSON $tiddlers
			#$tiddlersJSON

			# check, if there is at least one title element
			if ( ! ($tiddlersJSON.title) ) {
				Write-Host ("$($uri) JSON is empty. HTML file download skipped!")
			} else {
				$uri="$($tsHost)/recipes/$($space.name)_$($mode)/tiddlers.wiki"
				Write-host ("Download Wiki: " + $uri)
				(Invoke-WebRequest -Uri "$($uri)" -WebSession $ts).content | Out-File "$($user)\$($space.name)_$($mode).html" -encoding utf8 -force;
			}
		}
	}
}


##################################
# main

tsSetCredentials
tsShowList

$confirm = Read-Host "`nThe download process may need several minutes.`n`nDo you want to continue [y/N]?"

switch($confirm) {
    { @("y", "yes") -contains $_ } { 
		tsGetAll
	}
}

