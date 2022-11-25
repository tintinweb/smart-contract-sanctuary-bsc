/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// SPDX-License-Identifier: MIT
 pragma solidity ^0.8.8;//表示版本，写在最前面

contract SimpleStorage {
     //boolean,uint,int,address,bytes

    uint256 favoriteNumber = 5;

    function set(uint256 _favoriteNumber) public {
        favoriteNumber = _favoriteNumber; 
    }

    function get() public view returns(uint256){
        return favoriteNumber;
    }

}