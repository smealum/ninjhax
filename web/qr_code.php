<?

error_reporting(0);

function getRoVersion($v)
{
	if($v[0]<4)
	{
		return "0";
	}else if($v[0]<5){
		return "1024";
	}else if(!($v[0]>=7 and $v[1]>=2) and $v[0]<=7){
		return "2049";
	}else if($v[0]<8){
		return "3074";
	}else{
		return "4096";
	}
}

function getSpiderVersion($v)
{
	if($v[5]=="NEW")
	{
		return "SKATER_10";
	}else{
		if($v[3]<7)
		{
			return "1024";
		}else if($v[3]<11){
			return "2050";
		}else if($v[3]<16){
			return "3074";
		}else{
			return "4096";
		}
	}
}

function getCnVersion($v)
{
	if($v[4]=="J")
	{
		return "JPN";
	}else{
		return "WEST";
	}
}

function getFirmVersion($v)
{
	if($v[5]=="NEW")
	{
		return "N3DS";
	}else{
		if($v[0]<5)
		{
			return "PRE5";
		}else{
			return "POST5";
		}
	}
}

$version = array(
		0 => $_POST['zero'],
		1 => $_POST['one'],
		2 => $_POST['two'],
		3 => $_POST['three'],
		4 => $_POST['four'],
		5 => $_POST['five']
	);

$filename="./unsupported.png";

// check that version is valid-ish
if(is_numeric($version[0]) && is_numeric($version[1]) && is_numeric($version[2]) && is_numeric($version[3]))
{
	$filename="./q/".getFirmVersion($version)."_".getCnVersion($version)."_".getSpiderVersion($version)."_".getRoVersion($version).".png";
}

if(!file_exists($filename))
{
	$filename="./unsupported.png";
}

$fp = fopen($filename, 'rb');

// // send the right headers
header("Content-Type: image/png");
header("Content-Length: " . filesize($filename));

// dump the picture and stop the script
fpassthru($fp);

exit;

?>
