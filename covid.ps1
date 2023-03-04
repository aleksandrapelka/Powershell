[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 #protokol pozwalajacy na polaczenie, zeby zadanie nie zostalo przerwane i moc odczytac zawartosc z linku
$pobierzDane = 'https://api.covid19api.com/summary'
$a = Invoke-WebRequest $pobierzDane | ConvertFrom-Json #pobiera zawartosc strony internetowej
$a.Countries | Select-Object Country, TotalConfirmed, TotalDeaths, TotalRecovered, Date | Format-Table


$aktualna = Get-Date 
$aktualnaData = "{0:yyyy-MM-dd HH:mm:ss}" -f ($aktualna) 
Write-host "Aktualna data: $aktualnaData `n`n"

$pobranaData = $a.Countries.Date 

Write-host "Różnica czasowa obliczona na podstawie znacznika z pobranych danych: `n"

$data = for($i = 0; $i -lt $pobranaData.Count; $i++)
{

    $pData = [DateTime]$pobranaData[$i]
  
    $znacznik = "{0:yyyy-MM-dd HH:mm:ss}" -f ($pData) #konwersja do takiego samego formatu jak data aktualna 
   

    $c = NEW-TIMESPAN –Start $znacznik –End $aktualnaData | Select-Object -Property Days, Hours, Minutes #obliczenie roznicy czasowej

    $dzien = $c.Days
    $godzina = $c.Hours
    $minuta = $c.Minutes


    if($dzien -eq 0)
    {
        $godzina = "$godzina h "
        $minuta = "$minuta min "
        $g = $godzina + $minuta
    }
    elseif($dzien -eq 0 -and $godzina -eq 0)
    {
        $minuta = "$minuta min "
        $g = $minuta

    } 
    else
    { 
        if($dzien -eq 1)
        {
            $dzien = "$dzien dzień "
        }
        else
        {
            $dzien = "$dzien dni "
        }

        $godzina = "$godzina h "
        $minuta = "$minuta min"
        $g = $dzien + $godzina + $minuta
    }

    $g

}

$data

$nowa = $a.Countries

$nowaTabela = for($i = 0; $i -lt $nowa.Count; ++$i)
{

    [PSCustomObject]@{

             Kraj = $nowa[$i].Country
             WszystkieZakażenia = $nowa[$i].TotalConfirmed
             WszystkieZgony = $nowa[$i].TotalDeaths
             WszytkieOzdrowienia = $nowa[$i].TotalRecovered
             Data = $data[$i]

     }

}

$nowaTabela |  Format-Table 

#$nowaTabela |  Format-Table > .\covid.txt



