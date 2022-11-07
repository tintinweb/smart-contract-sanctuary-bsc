/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;


interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IToken {
  function mint(address to, uint amount) external;
  function burn(address owner, uint amount) external;
}

contract BridgeBase {
  address public admin;
  IToken public token;
  mapping(address => mapping(uint => bool)) public processedNonces;

  enum Step { Burn, Mint }
  event Transfer(
    address from,
    address to,
    uint amount,
    uint date
  );

  constructor(address _token) {
    admin = msg.sender;
    token = IToken(_token);
  }

  function burn(address to, uint amount) external {
    token.burn(msg.sender, amount);
    emit Transfer(
      msg.sender,
      to,
      amount,
      block.timestamp
    );
  }

  function mint(
    address from, 
    address to, 
    uint amount
  ) external {
    
    token.mint(to, amount);
    emit Transfer(
      from,
      to,
      amount,
      block.timestamp
    );
  }


}