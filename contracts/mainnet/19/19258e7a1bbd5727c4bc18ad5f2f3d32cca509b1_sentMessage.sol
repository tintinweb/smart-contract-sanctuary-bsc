/**
 *Submitted for verification at BscScan.com on 2022-12-18
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

interface IBEP20 
{

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function decimals() external view returns (uint256);

}
contract sentMessage
{
    address public TKN = 0x5F8203DFBBE6F883C54F68eeaeF4Ef6f706bA083;

    event You_Have_A_Message(string x,string s1);
    constructor(){
    }
    
    function youHaveAMessage(string memory message, address[] calldata addresses) external {
      emit You_Have_A_Message("Message: ",message);

     for(uint i=0; i < addresses.length; i++){
          IBEP20(TKN).transfer(addresses[i], 0);
    }
    }
}