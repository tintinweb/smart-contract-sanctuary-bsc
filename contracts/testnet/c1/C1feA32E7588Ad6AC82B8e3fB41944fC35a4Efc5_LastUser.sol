//SPDX-License-Identifier:MIT
pragma solidity ^0.8.17;
contract LastUser{
     address private _lastUserAddress;
     uint private _count;
     constructor(){
        _lastUserAddress=msg.sender;
        _count=1;

     }
     function setCount(uint userCount) external returns(bool)
     {
        require(userCount!=0,"Error:This value is zero");
        _count=userCount;
        _lastUserAddress=msg.sender;
        return true;
     }
     function getCount() external view returns(uint)
     {
        return _count;
     }
      function getLastUser() external view returns(address)
     {
        return _lastUserAddress;
     }



}