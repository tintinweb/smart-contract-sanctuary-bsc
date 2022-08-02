/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;


interface IBEP20 {

  function totalSupply() external view returns (uint256);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);
  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract SocialMusify is IBEP20 {
    string  public name = "Social Musify";
    string  public symbol = "SM";
    string  public standard = "SM Token v1.8";
    uint256 public totalSupply;
    constructor() {
    totalSupply = 1000000000000000000000000000;
    balanceOf[msg.sender] = totalSupply;
    }




    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function Socialmusify (uint256 _initialSupply) public {
        balanceOf[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
    }
    function transfer(address recipient, uint256 amount) external returns (bool) {
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }


    function approve(address spender, uint256 amount) external returns (bool) {
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    
    }
}



contract SocialMusifySale {
    address admin;
    SocialMusify public tokenContract;
    uint256 public tokenPrice;
    uint256 public tokensSold;
    event Sell(address _buyer, uint256 _amount);

    mapping(address => uint256) public balanceOf;

    function SocialmusifySale(SocialMusify _tokenContract, uint256 _tokenPrice) public {
        admin = msg.sender;
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
    }

    constructor () {
        admin = msg.sender;
        // put token contract for sale here 
        tokenPrice = 1000000000000000;
        tokenContract;
    }

    function multiply(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function buyTokens(uint256 _numberOfTokens) public payable {
        require(msg.value == multiply(_numberOfTokens, tokenPrice));
        require(tokenContract.balanceOf(address(this)) >= _numberOfTokens);
        require(tokenContract.transfer(msg.sender, _numberOfTokens));

        tokensSold += _numberOfTokens;

        emit Sell(msg.sender, _numberOfTokens);
    }

    function endSale() public {
        require(msg.sender == admin);
        require(
            tokenContract.transfer(
                admin,
                tokenContract.balanceOf(address(this))
            )
        );

    }
}