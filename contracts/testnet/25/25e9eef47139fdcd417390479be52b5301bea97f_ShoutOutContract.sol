/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

// File: contracts/ShoutOutPayable.sol

//SPDX-License-Identifier: MIT

pragma solidity 0.8.15;


contract ShoutOutContract {

    string public shoutOutName;
    uint public shoutOutCost = 1 gwei;
    

    function sendShoutOut(string memory _name) public payable{
        if(msg.value == shoutOutCost){
            shoutOutName = _name;
        }
        else {
            payable(msg.sender).transfer(msg.value);
        }
    }

    function getShoutOutText() public view returns(string memory){
        return string(abi.encodePacked("Heeeeey ", shoutOutName));
    }

    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }

}