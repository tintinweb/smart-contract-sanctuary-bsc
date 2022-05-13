/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Quylopgame {
    struct Thanhvien {
    address Account;
    uint Sotien;
    }
    Thanhvien[] public Danhsach;
    function Dongtien()payable public {
        Thanhvien memory nguoidongtien  = Thanhvien(msg.sender, msg.value);
        Danhsach.push(nguoidongtien);

    }

    function Tongthanhvien() public view returns(uint){
        return Danhsach.length;
    }
}