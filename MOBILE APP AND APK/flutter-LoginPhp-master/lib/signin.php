<?php

require_once("dbconfig.php");

$email = $_POST["email"];
$pass = $_POST["pass"];

$query = "SELECT * FROM user_registration WHERE email LIKE '$email'";
$res = mysqli_query($con,$query);
$data = mysqli_fetch_array($res);

if($data[2] >= 1){

    $query = "SELECT * FROM user_registration WHERE pass LIKE '$pass'";
    $res = mysqli_query($con,$query);
    $data = mysqli_fetch_array($res);
    if($data[3] >= 1){
        
        $resarr = array();
        array_push($resarr,array("name"=>$data['1'],"email"=>$data['2'],"pass"=>$data['3'],));
        json_encode(array("result"=>$resarr));
    }else{
        echo json_encode("false");

    }
}else{
    echo json_encode("dont have an account");

}
?>