/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

pragma solidity ^0.8.0;

interface IBEP20 {

  function totalSupply() external view returns (uint256);


  function decimals() external view returns (uint8);


  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);


  function transfer(address recipient, uint256 amount) external returns (bool);


  function allowance(address _owner, address spender) external view returns (uint256);


  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract warhouse {

    address public owner;

    constructor() {
        owner = msg.sender;
        token = IBEP20(0xE2Ae987873a1D348f0D9922B4a3a16C5fbD927ea);
    }

    IBEP20 public token;

    function withdraw(address _address, uint _amount) external {
        require(owner == msg.sender);
        token.transfer(_address, _amount);
    } 
}