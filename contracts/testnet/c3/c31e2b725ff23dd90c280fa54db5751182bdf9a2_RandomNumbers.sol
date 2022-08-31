/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

pragma solidity ^0.8.0;
contract RandomNumbers{

       struct phienDauGia { 
           uint256 phien;
           uint256 soPhieu;
           uint256 triGia;
           uint256 soTrung;
    }


    mapping (uint256 => phienDauGia) public phienCho;

    function random(uint number,uint256 phien,uint256 so_phieu, uint256 tri_gia) public returns(uint){
        uint result  = uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number;
        phienDauGia storage phienDG = phienCho[phien];
        //  /// update ticket info
        phienDG.phien = phien;
        phienDG.soPhieu = so_phieu;
        phienDG.triGia = tri_gia;
        phienDG.soTrung = result;
        return result;
    }



}