/**
 *Submitted for verification at BscScan.com on 2022-06-05
*/

// File: contracts/3_Ballot.sol



pragma solidity ^0.8.7;

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract contractB {
  ERC20 _token;
  address tracker_0x_address = 0x97f16fF1f2F6EE06e8E9E07cC1440fb851536Ff2;
  mapping ( address => uint256 ) public balances;
  
     constructor() {
        _token = ERC20(tracker_0x_address);
    }

      modifier checkAllowance(uint amount) {
        require(_token.allowance(msg.sender, address(this)) >= amount, "Error amount");
        _;
    }

    function getBalance() public view returns(uint256) {
      return _token.balanceOf(msg.sender);
    }


  function deposit(uint tokens) public {

    // add the deposited tokens into existing balance 
    balances[msg.sender]+= tokens;
    // transfer the tokens from the sender to this contract
    _token.transferFrom(msg.sender, address(this), tokens);
  }
  
  function returnTokens() public payable {
    uint256 amount = balances[msg.sender];
    balances[msg.sender] = 0;
    _token.transfer(msg.sender, amount);
  }
}