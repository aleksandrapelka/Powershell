$katalog = $args[0]  #"D:\projekt" 

########################################################################################
function zwrocUnikatowaWartosc
{
    param($tabelaHash)

    $tabelaHash = $tabelaHash.Hash | Sort-Object

    if($tabelaHash.Count -eq 1)
    {
        $tabelaHash
    }
    else
    {
        for($i = 0; $i -lt $tabelaHash.Count; $i++)
        {
            if($tabelaHash[$i] -ne $tabelaHash[$i+1])
            {
                $tabelaHash[$i]
            }

        }
    }
}
########################################################################################
function duplikaty #FUNKCJA DO WYSZUKIWANIA DUPLIKATÓW
{
    param($sumaK)

    $s = zwrocUnikatowaWartosc -tabelaHash $sumaK
    "`nUNIKATOWE HASHE:"
    $s
    $p = $sumaK.Path
    

    $tabela =  if($s.Count -eq 1)
    {
        $s
        $sumak.Path
    }
    else
    {
        for($i = 0; $i -lt $s.Count; $i++)
        {


            $znajdzDuplikaty = for($j = 0; $j -lt $sumaK.Path.Count; $j++)
            {
                    if($s[$i] -eq $sumaK.Hash[$j])
                    {
                        $sumaK.Path[$j] 

                    }
  
            }

             if($znajdzDuplikaty.Count -gt 1)
             {
                  $s[$i]
                  $znajdzDuplikaty
             }

        }
     }

    $tabela > duplikaty.json

}
########################################################################################

if(Test-Path "bazaczas.txt")
{
    $sprawdzamSciezka = Get-Content bazaczas.txt 


    $sprawdzamSciezka = $sprawdzamSciezka[-1]
    $sprawdzamSciezka

    if($sprawdzamSciezka -eq $katalog)
    {
        $test = $true
    }
        
}
else
{
    $test = $false
}
########################################################################################

if((Test-Path "baza.json") -and ($test)) 
{

   $a = Get-Content bazaczas.txt 
   $a = $a[0]

   $dane = Get-ChildItem  $katalog  -Recurse -Force -File


   $job = Start-Job -ScriptBlock{

   $dane = $args[0]
   $a = $args[1]
   $duplikat = $args[2]
    

       for($i = 0; $i -lt $dane.lastwritetime.Count; $i++)
       {
           if($dane.lastwritetime[$i] -gt $a)
           {
                $dane[$i] |  Get-FileHash | Select  Hash, Path | Sort-Object Hash 
           }
        }


    } -ArgumentList $dane, $a, $duplikat

    $job.State 
    $zmienna = Wait-job $job
    $job.State 
    $nowyDuplikat = Receive-Job $job


    $nowyDuplikat =  for($i = 0; $i -lt $nowyDuplikat.Path.Count; ++$i)
    {

        [PSCustomObject]@{

                    Hash = $nowyDuplikat[$i].Hash
                    Path = $nowyDuplikat[$i].Path

            }

    }


    if($nowyDuplikat.Path.Count -gt 0)
    {
        Write-Host "`nMOŻLIWE DUPLIKATY `n"
        $duplikat = $true

        "#####################################################################################################`n"
        "DODANO LUB ZMODYFIKOWANO PONIŻSZE PLIKI:`n"

    }
    else
    {
        Write-host "BRAK NOWYCH DUPLIKATÓW `n"
    }



        $nowyDuplikat
        "`n#####################################################################################################`n"
    
    if($duplikat)
    {
     
        $stara = Get-Content baza.json | ConvertFROM-JSON

        "`nSTARA BAZA:------------------------------------------------------------------------------------------"
        $stara


        $nowaTab = @(for($i = 0; $i -lt $nowyDuplikat.Path.Count; $i++)
        {

            $czyZmodyfikowany = $true

            if($nowyDuplikat.Path.Count -eq 1)
            {
          
               for($h = 0; $h -lt $stara.Path.Count; $h++)
               {

                   if($nowyDuplikat.Path -eq $stara.Path[$h])
                   {
                         $stara[$h] = $nowyDuplikat
                         $czyZmodyfikowany = $false
                   }
  
               }
                
            }
            else
            {

                for($j = 0; $j -lt $stara.Path.Count; $j++)
                {

                   if($nowyDuplikat.Path[$i] -eq $stara.Path[$j])
                   {
                         $stara[$j] = $nowyDuplikat[$i]
                         $czyZmodyfikowany = $false
                   }
  
                 }   

            }

           if($czyZmodyfikowany)
           {

               if($nowyDuplikat.Path.Count -eq 1)
                {
                        [PSCustomObject]@{

                                Hash = $nowyDuplikat.Hash
                                Path = $nowyDuplikat.Path
 
                          }       
                }  
                else
                {
                        [PSCustomObject]@{

                                Hash = $nowyDuplikat[$i].Hash
                                Path = $nowyDuplikat[$i].Path
 
                          }

                   }
                }
          })

          $nowaTabela = $stara + $nowaTab 
          



    "`nZMODYFIKOWANA BAZA:----------------------------------------------------------------------------------"
    $stara
    

    "`nDODANE PLIKI:----------------------------------------------------------------------------------------"
    $nowaTab

    "`nZAKTUALIZOWANA BAZA:---------------------------------------------------------------------------------"
    $nowaTabela


    $nowaTabela | ConvertTo-JSON > baza.json
    duplikaty -sumaK $nowaTabela

    }

    $czas = get-date 
    $czas = "{0:yyyy-MM-dd HH:mm:ss}" -f $czas > bazaczas.txt
    $katalog >> bazaczas.txt

}
else
{
    $czas = get-date 
    $czas = "{0:yyyy-MM-dd HH:mm:ss}" -f $czas > bazaczas.txt
    $katalog >> bazaczas.txt
   
    #$dane = Get-ChildItem  $katalog  -Recurse 
    #$dane

    #$sumaKontrolna =  Get-ChildItem  $katalog  -Recurse |  Get-FileHash | Select  Hash, Path | Sort-Object Hash 
   
    $job = Start-Job -ScriptBlock {

      Get-ChildItem  $args[0]  -Recurse -Force -File |  Get-FileHash | Select  Hash, Path | Sort-Object Hash  
    
    } -ArgumentList $katalog

    $job.State
    $zmienna = Wait-Job $job
    $job.State

    $sumaKontrolna = Receive-Job $job 
    
      $sumaKontrolna =  for($i = 0; $i -lt $sumaKontrolna.Path.Count; ++$i)
        {

            [PSCustomObject]@{

                     Hash = $sumaKontrolna[$i].Hash
                     Path = $sumaKontrolna[$i].Path

             }

        }

    $sumaKontrolna
    $sumaKontrolna  | convertto-json >  baza.json 
       

    duplikaty($sumaKontrolna)

}