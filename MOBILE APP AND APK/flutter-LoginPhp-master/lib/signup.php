<?php

require_once("dbconfig.php");

$email = $_POST["email"];
$name = $_POST["name"];
$pass = $_POST["pass"];

$query = "SELECT * FROM user_registration WHERE email LIKE '$email'";
$res = mysqli_query($con,$query);
$data = mysqli_fetch_array($res);

if($data[0] >= 1){
    echo json_encode("account already exist");

}else{
    $query = "INSERT INTO user_registration (id,name,email,pass) VALUES (null,'$name','$email','$pass')";
    $res = mysqli_query($con,$query);

    if($res){
        echo json_encode("true");
    }else{
        echo json_encode("false");
    }
}

?>