/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract casino {

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint public USDT_PRICE = 1 ether;
    IERC20 public USDT = IERC20( 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);  //USDT TESTNET

    function deposit(uint number) public {
        uint amount = number * USDT_PRICE;
        _balances[msg.sender]+=amount;
        USDT.transferFrom(msg.sender, address(this), amount);
        
    }
    function withdraw(uint amount) public{
    require(_balances[msg.sender]>=amount);
    _balances[msg.sender]-=amount;
    USDT.transfer(msg.sender, amount);   
    }

}