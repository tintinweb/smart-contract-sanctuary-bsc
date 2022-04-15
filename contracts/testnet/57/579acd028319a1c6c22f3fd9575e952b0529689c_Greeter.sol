/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Greeter{
    string private data;
    constructor (string memory _data){
        data=_data;
    }
    function checkData() public view returns(string memory){
       return data;
    }
}