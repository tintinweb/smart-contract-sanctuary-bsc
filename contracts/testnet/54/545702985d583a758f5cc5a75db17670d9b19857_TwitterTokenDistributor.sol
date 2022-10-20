/**
 *Submitted for verification at BscScan.com on 2022-10-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20 {
    function totalSupply() external view returns (uint _totalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract protected {

    mapping (address => bool) is_auth;

    function authorized(address addy) public view returns(bool) {
      return is_auth[addy];
    }

    function set_authorized(address addy, bool booly) public onlyAuth {
      is_auth[addy] = booly;
    }

    modifier onlyAuth() {
      require( is_auth[msg.sender] || msg.sender==owner, "not owner");
      _;
    }

    address owner;
    modifier onlyOwner() {
      require(msg.sender==owner, "not owner");
      _;
    }

    bool locked;
    modifier safe() {
      require(!locked, "reentrant");
      locked = true;
      _;
      locked = false;
    }

    
    uint cooldown = 5 seconds;

    mapping(address => uint) cooldown_block;
    mapping(address => bool) cooldown_free;

    modifier cooled() {
        if(!cooldown_free[msg.sender]) { 
            require(cooldown_block[msg.sender] < block.timestamp);
            _;
            cooldown_block[msg.sender] = block.timestamp + cooldown;
        }
    }

    receive() external payable {}
    fallback() external payable {}
}

contract TwitterTokenDistributor is protected {

    mapping(address => address) owner_token;

    function receive_tokens(address addy, uint qty) public safe {
      IERC20 tkn = IERC20(addy);
      tkn.transferFrom(msg.sender, address(this), qty);

      owner_token[msg.sender] = addy;
    }

    function give_reward(address addy, uint qty, address receiver) public onlyAuth {
      IERC20 tkn = IERC20(addy);
      require(tkn.balanceOf(address(this)) > 0, "balance has to be > 0");

      tkn.transferFrom(msg.sender, receiver, qty);
    }

    function unstuck_native() public onlyOwner {
      bool success;
      (success,) = address(msg.sender).call{value: address(this).balance}("");
    }

    function unstuck_tokens(address tkn) public onlyOwner {
      require(IERC20(tkn).balanceOf(address(this)) > 0, "No tokens");
      uint amount = IERC20(tkn).balanceOf(address(this));
      IERC20(tkn).transfer(msg.sender, amount);
    }

    function withdraw(address tkn) public safe {
      require(IERC20(tkn).balanceOf(address(this)) > 0, "No tokens");
      require(owner_token[msg.sender] == tkn, "Is not your token");
      uint amount = IERC20(tkn).balanceOf(address(this));
      IERC20(tkn).transfer(msg.sender, amount);
    }
}