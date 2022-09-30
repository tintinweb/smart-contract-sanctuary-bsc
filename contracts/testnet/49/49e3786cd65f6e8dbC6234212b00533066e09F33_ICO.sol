/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8 .0;

interface IBEP20 {
    function totalSupply()external view returns(uint256);

    function decimals()external view returns(uint256);

    function balanceOf(address account)external view returns(uint256);

    function transfer(address recipient, uint256 amount)external returns(bool);

    function allowance(address owner, address spender)
    external view returns(uint256);

    function approve(address spender, uint256 amount)external returns(bool);
    function burn(uint256 amount)external;

    function transferFrom(address sender, address recipient, uint256 amount)external returns(bool);


    function mintPRESALE(address account_, uint256 amount_)external;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ICO {
    mapping(address => uint256)public boughtAmount;
    mapping(uint256 => address)public buyerList;
    uint256 public buyerCount;
    uint256 public price;
    uint256 public minAmount;
    uint256 public maxAmount;
    uint256 public softCap;
    uint256 public hardCap;
    mapping(IBEP20 => bool) public isPayToken;
    IBEP20[] public payTokens;
    mapping(address=>mapping(IBEP20=>uint256)) public paidAmount;
    uint256 public releaseTime;
    uint256 public totalSold;
    uint256 public endTime;

    address private _owner;
    mapping(address => address)public referrers;
    mapping(address => uint8)public referredCount;
    mapping(address => uint256)public referralComission;
    uint256 public referralFee = 50; // 0.5%;

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    constructor(uint256 _price, uint256 _minAmount, uint256 _maxAmount, uint256 _endTime, uint256 _referralFee, uint256 _softCap, uint256 _hardCap) {
        price = _price;
        minAmount = _minAmount;
        maxAmount = _maxAmount;

        _owner = msg.sender;
        endTime = _endTime;

        referralFee = _referralFee;

        softCap = _softCap;
        hardCap = _hardCap;
    }

    function owner()external view returns(address) {
        return _owner;
    }

    function transferOwnership(address _newOwner)external onlyOwner {
        require(_newOwner != address(0), "Invalide address");
        _owner = _newOwner;
    }

    function updateConfig(uint256 _price, uint256 _minAmount, uint256 _maxAmount, uint256 _endTime, uint256 _referralFee)external onlyOwner {
        price = _price;
        minAmount = _minAmount;
        maxAmount = _maxAmount;
        endTime = _endTime;
        referralFee = _referralFee;
    }

    function setPayToken(IBEP20 _payToken, bool _toSet) external onlyOwner {
        if (isPayToken[_payToken] != _toSet) {
            if(_toSet)
                payTokens.push(_payToken);
            isPayToken[_payToken] = _toSet;
        }
    }

    function setReleasTime(uint256 _releaseTime)external onlyOwner {
        require(block.timestamp < _releaseTime, "Invalide release time");
        releaseTime = _releaseTime;
    }

    function buy(uint256 amount, IBEP20 payToken, address referrer) external {
        require(block.timestamp <= endTime, "Public sale is ended.");
        require(isPayToken[payToken], "Invalid payToken");
        if (referrers[msg.sender] != address(0) && referrer != msg.sender && referrer != address(0)) {
            referrers[msg.sender] = referrer;
            referredCount[referrer]++;
        }
        if (boughtAmount[msg.sender] == 0) {
            buyerList[buyerCount] = msg.sender;
            buyerCount ++;
        }
        require(boughtAmount[msg.sender] + amount <= maxAmount, "Max amount reached");
        require(amount >= minAmount, "You have to buy at least minamount");
        uint256 decimals = payToken.decimals();
        uint256 payAmount = price * amount / (10 ** (36-decimals));
        payToken.transferFrom(msg.sender, address(this), payAmount);
        paidAmount[msg.sender][payToken] += payAmount;
        if (referrers[msg.sender] != address(0)) {
            uint256 referralAmount = amount * referralFee / 10000;
            amount = amount - referralAmount;
            referralComission[referrers[msg.sender]] += referralAmount;
            boughtAmount[msg.sender] += amount;
        } else {
            boughtAmount[msg.sender] += amount;
        }
        totalSold += amount;
    }

    function getPayTokens() external view returns(IBEP20[] memory){
        return payTokens;
    }

    function withDraw()external onlyOwner {
        for (uint i = 0; i < payTokens.length; i ++) {
            if (payTokens[i].balanceOf(address(this)) > 0) 
                payTokens[i].transfer(_owner, payTokens[i].balanceOf(address(this)));            
        }
    }
}