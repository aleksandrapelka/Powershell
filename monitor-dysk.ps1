#MONITOROWANIE PAMIĘCI NA DYSKACH:

while($true)
{
    $infoOPamieci = Get-CimInstance -ClassName Win32_LogicalDisk 


        $tabela = [PSCustomObject] @{

            Dysk = $infoOPamieci.DeviceID 
            CalkowityRozmiar = $infoOPamieci.Size 
            WolneMiejsce = $infoOPamieci.FreeSpace 
    
            }
"`n##############################################################################################################`n"
    $tabela | Format-Table
"`n##############################################################################################################`n"

    

    "`nSUMA WOLNEGO MIEJSCA NA DYSKACH:`n"

    $wolne = $tabela.WolneMiejsce | Measure-Object -sum
    $wolneM = [math]::round($wolne.Sum/1000000000 , 2) 
    "$wolneM GB `n`n"


    "WOLNE MIEJSCE NA POSZCZEGOLNYCH DYSKACH:`n"


    for($i = 0; $i -lt $tabela.WolneMiejsce.Count; $i++)
    {

        $wolneNaDysku = $tabela.WolneMiejsce[$i] 
        $wolneMiejsce = [System.Math]::round($wolneNaDysku/1000000000 , 2) 
        $calkowiteMiejsce = [System.Math]::round($tabela.CalkowityRozmiar[$i]/1000000000 , 2) 
        $ileProcent = [System.Math]::round(($wolneMiejsce/$calkowiteMiejsce) * 100, 2)


        "`n`nNa dysku {0} jest wolnego miejsca: {1} GB (jest to {2} % całkowitego miejsca) `n" -f $tabela.Dysk[$i], $wolneMiejsce, $ileProcent 

        if($ileProcent -lt 30)
        {
            $dyskk = $tabela.Dysk[$i]
            [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

            [System.Windows.Forms.MessageBox]::Show(
            "Usuń niepotrzebne pliki",
            "Kończy się miejsce na dysku {0}" -f $tabela.Dysk[$i],
        
            [System.Windows.Forms.MessageBoxButtons]::OKCancel,
            [System.Windows.Forms.MessageBoxIcon]::Warning

            )

            Write-host "`n"
            Write-Warning "ZWOLNIJ MIEJSCE NA DYSKU $dyskk"  #jakby nie dzialalo powyzsze
             

        }
        else
        {
            Write-Host "Super! Na tym dysku jest ponad 30% wolnego miejsca!" -BackgroundColor DarkGreen -ForegroundColor White
        }


    }
    Start-Sleep 5

    cls
}