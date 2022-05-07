/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Quylopgame{

    struct Thanhvien{
        address Account;
        uint Sotien;
    }

     Thanhvien[] public Danhsach;

    function Dongtien() public payable {
        Thanhvien memory nguoidongtien = Thanhvien(msg.sender, msg.value);
        Danhsach.push(nguoidongtien);
    }

    function Tongthanhvien() public view returns(uint){
        return Danhsach.length;
    }
}