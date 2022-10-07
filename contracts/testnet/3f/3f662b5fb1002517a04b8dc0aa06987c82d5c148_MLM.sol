/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16 ;

interface tokenInterface 
{

function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

}

contract MLM{
    address public referrer;
    address tokenInterfaceAddress = 0xDf36112bc7348fa99367B38a50D8765af1c36710;
     
    
     struct userInfo
    {

        uint referrerId;
        uint Id;
        uint paidAmount; 
        bool coin;  

    }
    mapping (address => userInfo) userInfos ;

    function UpdateReferrerCoin(uint _referrerId, uint _Id) public payable returns(bool)
    {
       
        userInfo memory temp ;
        temp.referrerId = _referrerId ;
        temp.Id =_Id ;
        temp.paidAmount = msg.value ;
        temp.coin = true ;
        userInfos[msg.sender] = temp ;
        return true ;
    }
    
    function UpdateReferrer2Token(uint _referrerId, uint _Id, uint _paidAmount) public payable returns(bool)
    {


        
        userInfo memory temp;
        temp.referrerId = _referrerId;
        temp.Id =_Id;
        temp.paidAmount = _paidAmount;
        tokenInterface(tokenInterfaceAddress).transferFrom(msg.sender, address(this), _paidAmount); 
        userInfos[msg.sender] = temp;
        return true;
    }
    
  }