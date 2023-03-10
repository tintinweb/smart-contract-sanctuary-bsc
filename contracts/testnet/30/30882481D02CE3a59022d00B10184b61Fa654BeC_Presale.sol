/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

pragma solidity ^0.8.4;

//SPDX-License-Identifier: MIT Licensed

interface IToken {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint8);

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

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract Presale {
    IToken public token;

    AggregatorV3Interface public priceFeedbnb;
    address payable public owner;

    uint256 public tokenPerUsd;
    uint256 public minAmount;
    uint256 public maxAmount;
    uint256 public preSaleTime;
    uint256 public soldToken;

    mapping(address => uint256) public bnbbalances;
    mapping(address => uint256) public tokenBalance;
    mapping(address => bool) public claimed;

    modifier onlyOwner() {
        require(msg.sender == owner, "preSale: Not an owner");
        _;
    }

    constructor() {
        owner = payable(msg.sender);
        token = IToken(0xf869Be63B49b47D368379CD810dD8787f76C1D8b);
        priceFeedbnb = AggregatorV3Interface(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        );

        tokenPerUsd = 10;
        minAmount = 0.000001 ether;
        maxAmount = 10 ether;
        preSaleTime = block.timestamp + 180 days;
    }

    receive() external payable {}

    // to get real time price of bnb
    function getLatestPricebnb() public view returns (uint256) {
        (, int256 price, , , ) = priceFeedbnb.latestRoundData();
        return uint256(price) / (1e8);
    }

    function buyToken() public payable {
        uint256 numberOfTokens = bnbToToken(msg.value);
        uint256 maxToken = bnbToToken(maxAmount);

        require(
            msg.value >= minAmount && msg.value <= maxAmount,
            "preSale: Amount not correct"
        );
        require(
            numberOfTokens + (tokenBalance[msg.sender]) <= maxToken,
            "preSale: Amount exceeded max limit"
        );
        require(block.timestamp < preSaleTime, "preSale: PreSale over");
        bnbbalances[msg.sender] += msg.value;
        tokenBalance[msg.sender] += numberOfTokens;
        token.transferFrom(owner, msg.sender, numberOfTokens);
        soldToken = soldToken + (numberOfTokens);
    }

    // to check number of token for given bnb
    function bnbToToken(uint256 _amount) public view returns (uint256) {
        uint256 precision = 1e4;
        uint256 bnbToUsd = (precision * (_amount) * (getLatestPricebnb())) /
            (1 ether);
        uint256 numberOfTokens = bnbToUsd * (tokenPerUsd);
        return (numberOfTokens * (10**token.decimals())) / (precision);
    }

    // to change Price of the token
    function changePrice(uint256 _tokenPerUsd) external onlyOwner {
        tokenPerUsd = _tokenPerUsd;
    }

    function setPreSaleAmount(uint256 _minAmount, uint256 _maxAmount)
        external
        onlyOwner
    {
        require(
            _minAmount <= _maxAmount,
            "preSale: Min amount should be less than max amount"
        );
        minAmount = _minAmount;
        maxAmount = _maxAmount;
    }

    function setpreSaleTime(uint256 _time) external onlyOwner {
        preSaleTime = _time;
    }

    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        require(_newOwner != address(0), "preSale: New owner cannot be 0x0");
        owner = _newOwner;
    }

    // to draw funds for liquidity
    function transferFunds(uint256 _value) external onlyOwner returns (bool) {
        owner.transfer(_value);
        return true;
    }

    function withdrawStuckFunds(IToken _token, uint256 amount)
        external
        onlyOwner
    {
        require(
            _token.balanceOf(address(this)) >= amount,
            "preSale: Insufficient funds"
        );
        _token.transfer(msg.sender, amount);
    }

    function getCurrentTime() public view returns (uint256) {
        return block.timestamp;
    }

    function contractBalancebnb() external view returns (uint256) {
        return address(this).balance;
    }

    function getContractTokenBalance() external view returns (uint256) {
        return token.allowance(owner, address(this));
    }
}