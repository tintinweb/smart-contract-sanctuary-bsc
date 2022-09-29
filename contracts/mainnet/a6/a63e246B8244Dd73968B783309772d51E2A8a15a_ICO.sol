/**
 *Submitted for verification at BscScan.com on 2022-09-29
*/

pragma solidity 0.8.9;

//SPDX-License-Identifier: MIT Licensed

interface IToken {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

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

contract ICO {
    IToken public token;
    address payable public owner;
    address public tokenreceiver;

    uint256 public tokenPerBNB;
    uint256 public minAmount;
    uint256 public maxAmount;
    uint256 public preSaleStartTime;
    uint256 public preSaleEndTime;
    uint256 public soldToken;

    bool public isclaimactive;

    mapping(address => uint256) public BNBbalances;
    mapping(address => uint256) public tokenBalance;
    mapping(address => bool) public claimed;

    modifier onlyOwner() {
        require(msg.sender == owner, "preSale: Not an owner");
        _;
    }

    constructor() {
        owner = payable(0x042340602a029A44516A714cA7734F61Bd3111c4);
        tokenreceiver = 0x17d8Ab84E72f1B2070599590e50a8c0179Ea88a3;
        //mainnet token address
        token = IToken(0xB021333310fa0a7A45fafF31aa0696B18944443B);
       
        tokenPerBNB = 50000;
        minAmount = 0.1 ether;
        maxAmount = 100 ether;
        preSaleStartTime = block.timestamp;
        preSaleEndTime = block.timestamp + 1 days;
    }

    receive() external payable {}

    // to buy token
    function buy() public payable {
        uint256 numberOfTokens = BNBToToken(msg.value);
        uint256 maxToken = BNBToToken(maxAmount);

        require(
            msg.value >= minAmount && msg.value <= maxAmount,
            "preSale: Amount not correct"
        );
        require(
            numberOfTokens + (tokenBalance[msg.sender]) <= maxToken,
            "preSale: Amount exceeded max limit"
        );
        require(
            block.timestamp >= preSaleStartTime &&
                block.timestamp <= preSaleEndTime,
            "preSale: Not in preSale time"
        );
        BNBbalances[msg.sender] += msg.value;
        tokenBalance[msg.sender] += numberOfTokens;
        soldToken = soldToken + (numberOfTokens);
    }

    function claim() public {
        require(isclaimactive, "preSale: Claim not active");
        require(claimed[msg.sender] == false, "preSale: Already claimed");
        require(tokenBalance[msg.sender] > 0, "preSale: No token to claim");
        claimed[msg.sender] = true;
        uint256 amount = tokenBalance[msg.sender];
        tokenBalance[msg.sender] = 0;
        token.transfer(msg.sender, amount);
    }

    //to enable claim
    function enableClaim() public onlyOwner {
        require(isclaimactive == false, "preSale: Already enabled");
        require(block.timestamp > preSaleEndTime, "preSale: PreSale not over");
        isclaimactive = true;
        if (token.balanceOf(address(this)) > soldToken) {
            token.transfer(
                tokenreceiver,
                token.balanceOf(address(this)) - soldToken
            );
        }
        payable(owner).transfer(address(this).balance);
    }

    // to check number of token for given BNB
    function BNBToToken(uint256 _amount) public view returns (uint256) {
        return (_amount * 10**token.decimals() * (tokenPerBNB)) / 1e18;
    }

    // to change Price of the token
    function changePrice(uint256 _tokenPerBNB) external onlyOwner {
        tokenPerBNB = _tokenPerBNB;
    }

    // to change min and max amount
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

    // to change the preSale time
    function setpreSaleTime(uint256 _starttime, uint256 _endtime)
        external
        onlyOwner
    {
        require(
            _starttime < _endtime,
            "preSale: Start time should be less than end time"
        );
        preSaleStartTime = _starttime;
        preSaleEndTime = _endtime;
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

    // to draw tokens stuck in contract
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

    // to get current time
    function getCurrentTime() public view returns (uint256) {
        return block.timestamp;
    }

    // to get current balance of contract
    function contractBalanceBNB() external view returns (uint256) {
        return address(this).balance;
    }

    // to get current balance of contract
    function getContractTokenBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
}