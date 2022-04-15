/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract CodeOpen{
    address m_Owener;
    address m_TokenAddr;

    constructor(){
        m_Owener = msg.sender;
    }

    modifier IsOwener(){
        require(m_Owener == msg.sender);
        _;
    }

    function SetTokenAddress(address _addr) IsOwener public {
        m_TokenAddr = _addr;
    }

    function GetCount() public view returns(uint){
        return IERC20(m_TokenAddr).balanceOf(address(this));
    }
    //uint256 private immutable m_total;      //total token saleable

    
        
}