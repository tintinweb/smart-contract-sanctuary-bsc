/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

interface Token {
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function transfer(address _to, uint256 _value) external returns (bool success);
}


contract IDO {

    struct Period {
//        uint startTime;
//        uint endTime;
        uint total;
        uint hold;
        uint price;
        uint min;
        uint max;
    }

    mapping(uint => Period) public periodMap;

    //address public USDTToken = 0x55d398326f99059fF775485246999027B3197955; //USDT
    address public USDTToken = 0x55d398326f99059fF775485246999027B3197955; //USDT
    address public  owner;
    address public  administrator;

    mapping(address => uint) public subscribeMap;

    uint public subTotal = 23333 * 1e18;
    uint public subHold = 0;
    uint public subPrice = 10;  // subPrice / 100
    uint public baseAmount = 100 * 1e18;
    address pro;
    bool public open;
    uint public whiteTotal = 0;
    uint whiteAmount = 1000 * 1e18;

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
    }

    function changeOwner(address _add) external onlyOwner {
        require(_add != address(0));
        owner = _add;
    }

    function changeAdministrator(address _add) external onlyOwner {
        require(_add != address(0));
        administrator = _add;
    }


    // [40000,0,"210000000000000000",100,2000]
    function setPeriod(uint _id, Period memory _period) public onlyOwner {
        _period.total;
        _period.hold;
        _period.price;
        _period.min;
        _period.max;
        periodMap[_id] = _period;
    }


    function getSubscribeData() view external returns (uint, uint){
        return (subTotal, subHold);
    }

    //0xE6f50ac45FFd40763BA26a7DDCE229be8bcd8857,10000000000000000000000,0
    function setProConfig(address _add, uint _total, uint _hold) external onlyOwner {
        pro = _add;
        subTotal = _total;
        subHold = _hold;
    }

    //10000000000000000000,210000000000000000,true
    function setSubscribeConfig(uint _amount, uint _price, bool _open) external onlyOwner {
        baseAmount = _amount;
        subPrice = _price;
        open = _open;
    }

    function subscribe(uint _amount,uint _period) external {
        require(open, "IDO Close!");
        require(subscribeMap[msg.sender] < periodMap[_period].max, "Full subscription");
        require(periodMap[_period].total > periodMap[_period].hold, "subscribe completed");
        //本次认购数量
        uint quantity = _amount / subPrice;
        uint limit = periodMap[_period].max - subscribeMap[msg.sender];
        if (quantity > limit) {
            quantity = limit;
        }
        require(quantity % 100 == 0, "subscription multiple of 100");
        _amount = quantity * subPrice;
        //计算用户认购的枚数
        Token(USDTToken).transferFrom(msg.sender, address(this), _amount);
        periodMap[_period].hold += quantity;
        subscribeMap[msg.sender] += quantity;
    }

    function withdrawToken(address _token, address _add, uint _amount) public onlyOwner {
        Token(_token).transfer(_add, _amount);
        emit Withdraw(_token, msg.sender, _amount, _add);
    }

}