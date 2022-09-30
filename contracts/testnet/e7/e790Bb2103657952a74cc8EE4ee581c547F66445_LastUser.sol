//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract LastUser{

    address private _lastUserAddress;

    constructor(){
        _lastUserAddress=msg.sender;
    }

    function setLastUser() external returns(bool){
        _lastUserAddress=msg.sender;    
        return true;
    }

    function getLastUser() external view returns(address){ 
        return _lastUserAddress;
    }
    
}