## ts-backup-powershell

Usage:

 - Download: https://github.com/pmario/ts-backup-powershell/releases
 - Copy the script into `\your\backup\dir`
 - Open the PowerShell

```
cd \your\backup\dir
ts-backup.ps1
```

## Video

see: https://youtu.be/tb9TRVLfx1g 

## Known Work Arounds

Depending on your Windows ExecutionPolicy, it may be possible that you run into some problems.

You can check your actual setting with: 

```
Get-ExecutionPolicy
```

On many systems, it seems to be `RemoteSigned`, which means. Your own locally created scripts can be executed, but downloaded scripts are blocked. 

### Work Around 1

 - download the script from the release page
 - open `ts-backup.ps1` with your own editor
 - save the file
 - It should be possible to execute it now. 
 
### Work Around 2

Set your policy to "RemoteSigned" and use the "Unblock-File" powershell command. 

You'll need to start **PowerShell As Admin**

```
Set-ExecutionPolicy RemoteSigned
```

Start a standard PowerShell

```
cd \your\backup\dir
Unblock-File -path ./ts-backup.ps1

./ts-backup.ps1
```

Also see Microsoft docs: [Get-ExecutionPolicy](https://technet.microsoft.com/en-us/library/hh849821.aspx) and [Unblock-File](https://technet.microsoft.com/en-us/library/hh849924.aspx)


## Have Fun!
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.me/PMarioJo)

If this script helped you, to save your valuable time, you can help me spend more time creating useful things. Thanks!

