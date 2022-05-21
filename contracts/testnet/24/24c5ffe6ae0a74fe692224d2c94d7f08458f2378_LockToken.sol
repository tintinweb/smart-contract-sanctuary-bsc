/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

interface token {
     function approve(address spender, uint256 amount) external returns (bool);
     function transferFrom(address spender, address recipient, uint256 amount) external returns (bool);
     function balanceOf(address addr) external view returns (uint256);
}

contract LockToken{
    address m_Owner;
    address public m_TokenAddr; 
    uint public m_BeginTime = 0;    //lock begin time

    constructor (address _tokenAddr) {
       m_Owner = msg.sender;
       m_TokenAddr = _tokenAddr;
    }

    modifier IsOwner(){
        require(msg.sender == m_Owner);
        _;
    }

    function ActiveLock() IsOwner public{
        m_BeginTime = block.timestamp;
    }

    function GetBack() IsOwner public{
        require(block.timestamp - m_BeginTime>1 days);
        uint _count = token(m_TokenAddr).balanceOf(address(this));
        require(_count >0);
        token(m_TokenAddr).approve(address(this),_count);
        token(m_TokenAddr).transferFrom(address(this), m_Owner, _count);
    }
}