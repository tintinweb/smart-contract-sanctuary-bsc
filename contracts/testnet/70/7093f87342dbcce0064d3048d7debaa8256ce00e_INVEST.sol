/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

interface Token {
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function transfer(address _to, uint256 _value) external returns (bool success);
}

contract INVEST {
    address public  owner;
    address public  administrator;

    mapping(address=>uint)  priceMap;

    event Invest(address add, uint force,address _inviter);
    event Withdraw(address token, address user, uint amount, address to);

    modifier onlyOwner() {
        require(msg.sender == owner || msg.sender == administrator, "Permission denied");
        _;
    }
    constructor() {
        owner = msg.sender;
        administrator = msg.sender;
    }

    function changeOwner(address _add) external onlyOwner {
        require(_add != address(0));
        owner = _add;
    }

    function changeAdministrator(address _add) external onlyOwner {
        require(_add != address(0));
        administrator = _add;
    }


    function setPrice(address _tokne,uint _price) public {
        priceMap[_tokne] = _price;
    }

    function invest(uint _force,address _token,address _inviter) public {
        require(_force >= 0);
        uint  _quantity = _force * 1e18  /  priceMap[_token];
        Token(_token).transferFrom(msg.sender, address(this), _quantity);
        emit Invest(msg.sender,_force,_inviter);
    }

    //联合投资
    function nuionInvest(uint _force,address _tokenA, address _tokenB,uint _ratio,address _inviter) public {
        require(_force >= 0);
        uint usdtA = _force *_ratio / 100;
        uint  _amountA = usdtA  * 1e18  /  priceMap[_tokenA];
        Token(_tokenA).transferFrom(msg.sender, address(this), _amountA);
        uint  _amountB = (_force - usdtA)  * 1e18  /  priceMap[_tokenB];
        Token(_tokenB).transferFrom(msg.sender, address(this), _amountB);
        emit Invest(msg.sender,_force,_inviter);
    }
    function withdrawToken(address _token, address _add, uint _amount) public onlyOwner {
        Token(_token).transfer(_add, _amount);
        emit Withdraw(_token, msg.sender, _amount, _add);
    } 
}