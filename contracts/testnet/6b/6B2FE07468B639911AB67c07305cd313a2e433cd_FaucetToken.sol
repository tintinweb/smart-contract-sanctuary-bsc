// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;


interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract FaucetToken
{
  address public admin;
  IERC20 public token;
  uint256 public currentAirdropAmount;


  constructor(address _token) {
    admin = msg.sender; 
    token = IERC20(_token);
  }

  function setToken(address _token) public {
    require(msg.sender == admin, 'only admin');
    token = IERC20(_token);
  }

  function updateAdmin(address newAdmin) external {
    require(msg.sender == admin, 'only admin');
    admin = newAdmin;
  }

  function claimTokens(address recipient, uint256 amount) external {

    currentAirdropAmount += amount;
    token.transfer(recipient, amount);
  }


}