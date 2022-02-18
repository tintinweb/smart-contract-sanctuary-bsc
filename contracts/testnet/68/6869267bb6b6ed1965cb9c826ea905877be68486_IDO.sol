/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

interface Token {
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function transfer(address _to, uint256 _value) external returns (bool success);
}

contract IDO {
    // address public USDTToken = 0x55d398326f99059fF775485246999027B3197955; //USDT
    address public USDTToken = 0xD2C6e5d5174BeF50017FB216DC66769baC34a12d;   //Test
    address public  owner;
    address public  administrator;
    mapping(address => uint) public subscribeMap;

    uint public subTotal = 20000 * 10 ** 18;
    uint public subHold = 0;
    uint public subAmount = 500 * 10 ** 18;
    uint public subRatio = 20;

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
        subscribeMap[msg.sender] = subAmount;
    }

    function changeOwner(address _add) external onlyOwner {
        require(_add != address(0));
        owner = _add;
    }

    function changeAdministrator(address _add) external onlyOwner {
        require(_add != address(0));
        administrator = _add;
    }

    function getSubscribeData() view external  returns (uint, uint, uint, uint){
        return (subTotal, subHold, subAmount, subRatio);
    }

    function setSubscribeConfig(uint _qua, uint _ratio) external onlyOwner {
        subAmount = _qua;
        subRatio = _ratio;
    }

    function subscribe(address _inviter) external {
        require(msg.sender != _inviter, "Can't invite myself");
        require(subscribeMap[_inviter] > 0, "Inviter does not exist");
        uint inviteAmount = subAmount * subRatio / 100;
        subHold += 10;
        Token(USDTToken).transferFrom(msg.sender, _inviter, inviteAmount);
        Token(USDTToken).transferFrom(msg.sender, address(this), subAmount - inviteAmount);
        subscribeMap[msg.sender] = subAmount;
    }

    function withdrawToken(address _token, address _add, uint _amount) public onlyOwner {
        Token(_token).transfer(_add, _amount);
        emit Withdraw(_token, msg.sender, _amount, _add);
    }

}