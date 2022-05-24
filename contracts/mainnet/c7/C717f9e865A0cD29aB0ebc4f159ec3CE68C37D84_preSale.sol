/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

pragma solidity ^0.8.4;

//SPDX-License-Identifier: MIT Licensed

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract preSale {
    IBEP20 public token; 

    address payable public owner;

    uint256 public tokenPerBnb;
    uint256 private minAmount;
    uint256 private maxAmount;
    uint256 public amountRaised;
    uint256 public soldToken;
    uint256 public startTime = block.timestamp;
    uint256 public endTime = startTime + 7 days;
    uint256 public totalForPrivateSale = 2500000000 *1e18;
    modifier onlyOwner() {
        require(msg.sender == owner, "BEP20: Not an owner");
        _;
    }

    event BuyToken(address _user, uint256 _amount);

    constructor(address payable _owner, address _token) {
        owner = _owner;
        token = IBEP20(_token);
        tokenPerBnb = 50000000;
        minAmount = 0.1 ether;
        maxAmount = 10 ether;
    }

    receive() external payable {}

    // to buy token during preSale time => for web3 use
    function buyToken() public payable {
        uint256 numberOfTokens = bnbToToken(msg.value);
        require(
            msg.value >= minAmount && msg.value <= maxAmount,
            "PRESALE: Amount not correct"
        );
        require(soldToken <= totalForPrivateSale, "All Sold");
        require(
            block.timestamp >= startTime && block.timestamp < endTime,
            "PRESALE: PreSale over"
        );
        token.transferFrom(owner, msg.sender, numberOfTokens);

        amountRaised = amountRaised + (msg.value);
        soldToken = soldToken + (numberOfTokens);
        emit BuyToken(msg.sender, numberOfTokens);
    }

    // to check number of token for given BNB
    function bnbToToken(uint256 _amount) public view returns (uint256) {
        uint256 numberOfTokens = _amount * (tokenPerBnb);
        return numberOfTokens;
    }

    function getCurrentTime() external view returns (uint256) {
        return block.timestamp;
    }

    // to change price
    function setPriceOfToken(uint256 _price) external onlyOwner {
        tokenPerBnb = _price;
    }

    function setPreSaletLimits(uint256 _minAmount, uint256 _maxAmount)
        external
        onlyOwner
    {
        minAmount = _minAmount;
        maxAmount = _maxAmount;
    }

    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }
    function changeSupply(uint256 amount)public onlyOwner{
        totalForPrivateSale = amount;
    }
    function setToken(address newtoken) public onlyOwner {
        token = IBEP20(newtoken);
    }

    function changeTime(uint256 _time,uint256 endtime) public onlyOwner {
        startTime = _time;
        endTime = endtime;
    } 

    // to draw funds for liquidity
    function migrateFunds(uint256 _value) external onlyOwner {
        owner.transfer(_value);
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getContractTokenBalance() external view returns (uint256) {
        return token.allowance(owner, address(this));
    }
}