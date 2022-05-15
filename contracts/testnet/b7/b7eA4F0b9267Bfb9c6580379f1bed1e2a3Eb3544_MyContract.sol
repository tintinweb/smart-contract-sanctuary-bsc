/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract MyContract{
//private
//bool status = false;
//string _mane="bass"; //เก็บข้อความ
//int _amount = 0;     //เก็บตัวเลขจำนวนเต็ม
//uint _balance = 1000; //เก็บตัวเลขจำนวนเต็มบวกเท่านั้น

string _name;
uint _balance;

constructor(string memory name,uint balance){
    require(balance>=500,"balance greater zero(money>500)");
    _name = name;  //การใส่ชื่อ ลงทะเบียน
    _balance = balance; //การใส่จำนวนเงินฝากลงทะเบียน
}
//ฟังก์ชันที่เรียกดูข้อมูล ไม่ต้องจ่ายค่าแก็ส
function getBalance()public view returns(uint balance){
    return _balance;
}

//การฝากเงินเพิ่ม
function deposite(uint amount) public{
    _balance+=amount; 
}
function withdraw(uint amount) public{
    _balance-=amount;
}   
}