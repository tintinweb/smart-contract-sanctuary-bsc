/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

interface Token {
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function transfer(address _to, uint256 _value) external returns (bool success);
}

contract IDO {
    //address public USDTToken = 0x55d398326f99059fF775485246999027B3197955; //USDT
    address public USDTToken = 0xD2C6e5d5174BeF50017FB216DC66769baC34a12d;   //Test
    address public  owner;
    address public  administrator;
    mapping(address => uint) public subscribeMap;
    mapping(address => address) public inviterMap; 

    uint public subTotal = 42 * 1e4 * 1e18;
    uint public subHold = 0;
    uint public subPrice = 50;  // subPrice / 100
    uint public subRatio = 20;  //subRatio%
    uint public baseAmount = 500 * 1e18;

    event Subscribe(address _add, uint _qua, uint _price);
    event SubscribeInvite(address _add, address _invite, uint _qua);
    event Withdraw(address token, address user, uint amount, address to);

    modifier onlyOwner() {
        require(msg.sender == owner || msg.sender == administrator, "Permission denied");
        _;
    }
    constructor() {
        owner = msg.sender;
        administrator = msg.sender;
        subscribeMap[msg.sender] = baseAmount;
        inviterMap[msg.sender] = msg.sender;
    }

    function changeOwner(address _add) external onlyOwner {
        require(_add != address(0));
        owner = _add;
    }

    function changeAdministrator(address _add) external onlyOwner {
        require(_add != address(0));
        administrator = _add;
    }

    function subscribeOf() view external returns (uint){
        return subscribeMap[msg.sender];
    }

    function getSubscribeData() view external returns (uint, uint, uint){
        return (subTotal, subHold, subRatio);
    }

    function setSubscribeConfig(uint _ratio, uint _amount, uint _price) external onlyOwner {
        subRatio = _ratio;
        baseAmount = _amount;
        subPrice = _price;
    }

    function subscribe(address _inviter, uint _amount) external {
        require(msg.sender != _inviter, "Can't invite myself");
        require(subscribeMap[_inviter] > 0, "Inviter does not exist");
        require(subscribeMap[msg.sender] <= 0, "already subscribed");
        require(_amount % baseAmount == 0, "Subscribe amount fail");
        uint inviteAmount = _amount * subRatio / 100;
        subHold += _amount * 100 / subPrice;
        Token(USDTToken).transferFrom(msg.sender, inviterMap[_inviter], inviteAmount / 2);
        Token(USDTToken).transferFrom(msg.sender, _inviter, inviteAmount / 2);
        Token(USDTToken).transferFrom(msg.sender, address(this), _amount - inviteAmount);
        subscribeMap[msg.sender] = _amount;
        inviterMap[msg.sender] = _inviter;
    }

    function withdrawToken(address _token, address _add, uint _amount) public onlyOwner {
        Token(_token).transfer(_add, _amount);
        emit Withdraw(_token, msg.sender, _amount, _add);
    }

}