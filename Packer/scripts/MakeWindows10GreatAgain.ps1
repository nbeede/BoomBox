# Import the registry keys
Write-Host "Making Windows 10 Great again"
Write-Host "Importing registry keys..."
regedit /s a:\MakeWindows10GreatAgain.reg

# Remove OneDrive from the System
Write-Host "Removing OneDrive..."
$onedrive = Get-Process onedrive -ErrorAction SilentlyContinue
if ($onedrive) {
  taskkill /f /im OneDrive.exe
}
c:\Windows\SysWOW64\OneDriveSetup.exe /uninstall

Write-Host "Running Update-Help..."
Update-Help -Force -ErrorAction SilentlyContinue

Write-Host "Removing bloatware"
        Get-AppxPackage "Microsoft.3DBuilder" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.AppConnector" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.BingFinance" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.BingFoodAndDrink" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.BingHealthAndFitness" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.BingMaps" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.BingNews" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.BingSports" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.BingTranslator" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.BingTravel" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.BingWeather" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.CommsPhone" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.ConnectivityStore" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.FreshPaint" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.GetHelp" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.Getstarted" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.HelpAndTips" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.Media.PlayReadyClient.2" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.Messaging" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.Microsoft3DViewer" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.MicrosoftOfficeHub" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.MicrosoftPowerBIForWindows" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.MicrosoftSolitaireCollection" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.MicrosoftStickyNotes" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.MinecraftUWP" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.MixedReality.Portal" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.MoCamera" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.MSPaint" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.NetworkSpeedTest" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.OfficeLens" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.Office.OneNote" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.Office.Sway" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.OneConnect" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.People" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.Print3D" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.Reader" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.RemoteDesktop" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.SkypeApp" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.Todos" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.Wallet" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.WebMediaExtensions" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.Whiteboard" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.WindowsAlarms" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.WindowsCamera" | Remove-AppxPackage
        Get-AppxPackage "microsoft.windowscommunicationsapps" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.WindowsFeedbackHub" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.WindowsMaps" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.WindowsPhone" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.Windows.Photos" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.WindowsReadingList" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.WindowsScan" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.WindowsSoundRecorder" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.WinJS.1.0" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.WinJS.2.0" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.YourPhone" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.ZuneMusic" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.ZuneVideo" | Remove-AppxPackage
        Get-AppxPackage "Microsoft.Advertising.Xaml" | Remove-AppxPackage # Dependency for microsoft.windowscommunicationsapps, Microsoft.BingWeather
        Get-AppxPackage "2414FC7A.Viber" | Remove-AppxPackage
        Get-AppxPackage "41038Axilesoft.ACGMediaPlayer" | Remove-AppxPackage
        Get-AppxPackage "46928bounde.EclipseManager" | Remove-AppxPackage
        Get-AppxPackage "4DF9E0F8.Netflix" | Remove-AppxPackage
        Get-AppxPackage "64885BlueEdge.OneCalendar" | Remove-AppxPackage
        Get-AppxPackage "7EE7776C.LinkedInforWindows" | Remove-AppxPackage
        Get-AppxPackage "828B5831.HiddenCityMysteryofShadows" | Remove-AppxPackage
        Get-AppxPackage "89006A2E.AutodeskSketchBook" | Remove-AppxPackage
        Get-AppxPackage "9E2F88E3.Twitter" | Remove-AppxPackage
        Get-AppxPackage "A278AB0D.DisneyMagicKingdoms" | Remove-AppxPackage
        Get-AppxPackage "A278AB0D.DragonManiaLegends" | Remove-AppxPackage
        Get-AppxPackage "A278AB0D.MarchofEmpires" | Remove-AppxPackage
        Get-AppxPackage "ActiproSoftwareLLC.562882FEEB491" | Remove-AppxPackage
        Get-AppxPackage "AD2F1837.GettingStartedwithWindows8" | Remove-AppxPackage
        Get-AppxPackage "AD2F1837.HPJumpStart" | Remove-AppxPackage
        Get-AppxPackage "AD2F1837.HPRegistration" | Remove-AppxPackage
        Get-AppxPackage "AdobeSystemsIncorporated.AdobePhotoshopExpress" | Remove-AppxPackage
        Get-AppxPackage "Amazon.com.Amazon" | Remove-AppxPackage
        Get-AppxPackage "C27EB4BA.DropboxOEM" | Remove-AppxPackage
        Get-AppxPackage "CAF9E577.Plex" | Remove-AppxPackage
        Get-AppxPackage "CyberLinkCorp.hs.PowerMediaPlayer14forHPConsumerPC" | Remove-AppxPackage
        Get-AppxPackage "D52A8D61.FarmVille2CountryEscape" | Remove-AppxPackage
        Get-AppxPackage "D5EA27B7.Duolingo-LearnLanguagesforFree" | Remove-AppxPackage
        Get-AppxPackage "DB6EA5DB.CyberLinkMediaSuiteEssentials" | Remove-AppxPackage
        Get-AppxPackage "DolbyLaboratories.DolbyAccess" | Remove-AppxPackage
        Get-AppxPackage "Drawboard.DrawboardPDF" | Remove-AppxPackage
        Get-AppxPackage "Facebook.Facebook" | Remove-AppxPackage
        Get-AppxPackage "Fitbit.FitbitCoach" | Remove-AppxPackage
        Get-AppxPackage "flaregamesGmbH.RoyalRevolt2" | Remove-AppxPackage
        Get-AppxPackage "GAMELOFTSA.Asphalt8Airborne" | Remove-AppxPackage
        Get-AppxPackage "KeeperSecurityInc.Keeper" | Remove-AppxPackage
        Get-AppxPackage "king.com.BubbleWitch3Saga" | Remove-AppxPackage
        Get-AppxPackage "king.com.CandyCrushFriends" | Remove-AppxPackage
        Get-AppxPackage "king.com.CandyCrushSaga" | Remove-AppxPackage
        Get-AppxPackage "king.com.CandyCrushSodaSaga" | Remove-AppxPackage
        Get-AppxPackage "king.com.FarmHeroesSaga" | Remove-AppxPackage
        Get-AppxPackage "Nordcurrent.CookingFever" | Remove-AppxPackage
        Get-AppxPackage "PandoraMediaInc.29680B314EFC2" | Remove-AppxPackage
        Get-AppxPackage "PricelinePartnerNetwork.Booking.comBigsavingsonhot" | Remove-AppxPackage
        Get-AppxPackage "SpotifyAB.SpotifyMusic" | Remove-AppxPackage
        Get-AppxPackage "ThumbmunkeysLtd.PhototasticCollage" | Remove-AppxPackage
        Get-AppxPackage "WinZipComputing.WinZipUniversal" | Remove-AppxPackage
        Get-AppxPackage "XINGAG.XING" | Remove-AppxPackage
        Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -like "Internet-Explorer-Optional*" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
        Get-WindowsCapability -Online | Where-Object { $_.Name -like "Browser.InternetExplorer*" } | Remove-WindowsCapability -Online | Out-Null
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive")) {
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 1

Write-Host "Removing Microsoft Store, Mail, and Edge shortcuts from the taskbar..."
$appname = "Microsoft Edge"
((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from taskbar'} | %{$_.DoIt(); $exec = $true}
$appname = "Microsoft Store"
((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from taskbar'} | %{$_.DoIt(); $exec = $true}
$appname = "Mail"
((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from taskbar'} | %{$_.DoIt(); $exec = $true}
