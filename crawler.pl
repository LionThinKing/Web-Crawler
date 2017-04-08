=pod
Name:     Crawler.pl
Verion:   0.1
Greetz:  All Members Of M1NDS
=cut

use LWP::UserAgent;
use URI;
use File::Basename;

@Links=();
@List=();
$Peticiones=0;


if ($#ARGV != 0)
{
 Logo();
 print "\nUsage: perl $0 http://example.com/index.php";
}
else
{
 Logo();
 $c=0;
 
 #Agregamos la primera Ruta a la lista
 push(@List,$ARGV[0]);
 
 #Limpiamos / Al Final
 $r=chop($List[$c]);
 if($r ne "/"){$List[$c].=$r;}
 
 
 #Convertimos el String a URI
 $Link = URI->new($List[$c]);
 
 #Sacamos el protocolo Usado
 $Protocol=$Link->scheme();
 
 #Sacamos el Host Principal
 $Host = $Link->host();
 
 #Sacamos el Path Principal
 $PrincipalPath=$Link->path();
 if($PrincipalPath eq ""){$PrincipalPath="//";}
 $PrincipalPath=SacarPath($PrincipalPath);
 print "Pagina: ".$Host."\n\n";
 
 
 do
 { 
  print "#".$c." URL: ".$List[$c]."\n";
  $Link = URI->new($List[$c]);
  
  $Path = $Link->path();
  if($Path eq ""){$Path="//";}
  $Path=SacarPath($Path);
  #print "Path: ".$Path."\n\n";
  
  my $Source=GetContent($List[$c]);
  SacarURI($Source,"href=",$Path);
  SacarURI($Source,"src=",$Path);
  
  #Ignoramos las Rutas Externas
  foreach(@Crawl)
  {
   #Limpiado URL 
   $_=~s/[\#|\?](.*$)//g;
   if($_=~/[\/|\\]$/){chop($_);}
   if($_=~/$Host/)
   {
    my $val=0;
    my $r1=$_;
    foreach(@List)
    {
     if($r1 eq $_){$val=1;last;}
    }
    if($val == 1){next;}
    push(@List,$_);
   }
  }
  $c++;
 }while($c<=$#List);
 
 print "\n\n$#List Archivos en $Peticiones Peticiones\n";
 open (Lista, ">Crawler.txt");
 foreach(@List)
 {
  print Lista $_."\n";
 }
 close(Lista);

}


sub SacarPath()
{
 my $Directorio=1;
 my $Original=$_[0];
 my $r=chop($_[0]);
 
 if($r ne "/")
 {
  while(true)
  {
   $r=chop($_[0]);
   $Ruto.=$r;
   if($r eq '.'){$Directorio=0;}
   if($r eq '/'){last;}
  }
  
  if($Directorio==0)
  {
   
   return dirname($Original);
  }
  else
  {
   
   return $Original."/";
  }
 }
 return $_[0];
}




sub SacarURI()
{
 my $Ruta=$_[2];
 my(@Clean)=$_[0]=~m/($_[1]\"*(.*?)")/gi;
 @Links = grep(s/href=\"|src=\"|\"//gi,@Clean);

 #Sacando Rutas
 $Rutas=$Ruta;
 $Rutas=~s/\/[^\/]*$/\//;
 chop($Rutas);
 while($Rutas gt $PrincipalPath)
 {
  push(@Links,$Link->scheme().":\/\/".$Host.$Rutas);
  $Rutas=~s/\/[^\/]*$/\//;
  chop($Rutas);
 }
 
 foreach(@Links)
 {
  if($_=~/^http:\/\//i || $_=~/^https:\/\//i)
  {
   push(@Crawl,$_);
  }
  else
  {
   if($_=~/^mailto/i){next;}
   if($_=~/^\//i){push(@Crawl,"http://".$Host.$_);}
   else{push(@Crawl,$Link->scheme().":\/\/".$Host.$Ruta.$_);}
  }
 }
}


sub GetContent()
{
 $Peticiones++;
 $ua = LWP::UserAgent->new(agent => 'Mozilla/5.0 (Windows; U; Windows NT 5.1; nl; rv:1.8.1.12) Gecko/20080201 Firefox/2.0.0.12');
 $response = $ua->get($_[0]);
 return $response->content;
}


sub Logo()
{
print"
          #                        
 #    #  ##   #    # #####   ####  
 ##  ## # #   ##   # #    # #      
 # ## #   #   # #  # #    #  ####  
 #    #   #   #  # # #    #      # 
 #    #   #   #   ## #    # #    # 
 #    # ##### #    # #####   ####
 
";
}