// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "./IERC20.sol";
import "./Owner.sol";
import "./ReentrancyGuard.sol";

interface Referrals{
    function addReward1(address _referredAccount, uint256 _amount) external returns(uint256);
    function addReward2(address _referredAccount, uint256 _amount) external returns(uint256);
}

contract ICOContract is Owner, ReentrancyGuard {
    uint256 public mulDec_token1;
    uint256 public mulDec_token2;

    address public address_token1;
    address public address_token2;

    uint256 public minimumBuy_token1 = 1;
    uint256 public minimumBuy_token2 = 1;

    uint256 public maximumBuy_token1 = 100;
    uint256 public maximumBuy_token2 = 100;

    uint256 public salePrice_token1; // set salePrice with token decimals (e.g. BUSD TOKEN 18 Decimals)
    uint256 public salePrice_token2; // set salePrice with token decimals (e.g. LVLX TOKEN 18 Decimals)

    bool public lockNewOrders_token1;
    bool public lockNewOrders_token2;

    // referrals contract address 
    address public referrals;
    mapping(address => bool) public first_buy;

    // properties used to get fee
    uint256 private constant amountDivToGetFee = 10**4;
    uint256 public amountMulToGetFee = 0; // 100 = 1%

    event SetTokensContract(
        address token1,
        address token2,
        address referrals
    );

    event SetSalePrice(
        uint256 salePrice_token1,
        uint256 salePrice_token2
    );

    event BuyToken1(
        uint256 timestamp,
        address buyer,
        uint256 amount,
        uint256 paidAmount
    );

    event BuyToken2(
        uint256 timestamp,
        address buyer,
        uint256 amount,
        uint256 paidAmount,
        uint256 fee
    );

    event SetMulDec(
        uint256 mulDec_token1,
        uint256 mulDec_token2
    );

    event SetLockNewOrders(
        bool lockNewOrders_token1,
        bool lockNewOrders_token2
    );

    event SetAmountMulToGetFee(
        uint256 amountMulToGetFee
    );

    event SetMinimumBuy(
        uint256 minimumBuy_token1,
        uint256 minimumBuy_token2
    );

    event SetMaximumBuy(
        uint256 maximumBuy_token1,
        uint256 maximumBuy_token2
    );

    constructor(address _address_token1, address _address_token2, uint256 _salePrice_token1, uint256 _salePrice_token2, address _address_referrals) {
        setTokenContract(_address_token1, _address_token2, _address_referrals);
        setSalePrice(_salePrice_token1, _salePrice_token2);
        uint256 muldec = 10**18; // this is a muldec for 18 decimals
        set_mulDec(muldec, muldec);
        set_minimumBuy(1, 1);
        set_maximumBuy(100, 100);
    }

    function setTokenContract(address _address_token1, address _address_token2, address _address_referrals) public isOwner {
        address_token1 = _address_token1;
        address_token2 = _address_token2;
        referrals = _address_referrals;
        emit SetTokensContract(_address_token1, _address_token2, _address_referrals);
    }

    function setSalePrice(uint256 _salePrice_token1, uint256 _salePrice_token2) public isOwner {
        salePrice_token1 = _salePrice_token1;
        salePrice_token2 = _salePrice_token2;
        emit SetSalePrice(_salePrice_token1, _salePrice_token2);
    }

    function set_mulDec(uint256 _muldec_token1, uint256 _muldec_token2) public isOwner {
        mulDec_token1 = _muldec_token1;
        mulDec_token2 = _muldec_token2;
        emit SetMulDec(_muldec_token1, _muldec_token2);
    }

    function setLockNewOrders(bool _lock_token1, bool _lock_token2) external isOwner {
        lockNewOrders_token1 = _lock_token1;
        lockNewOrders_token2 = _lock_token2;
        emit SetLockNewOrders(_lock_token1, _lock_token2);
    }

    function set_minimumBuy(uint256 _minimum_token1, uint256 _minimum_token2) public isOwner {
        require(_minimum_token1>=1 && _minimum_token2>=1, "minimum values must be greater than or equal to 1");
        minimumBuy_token1 = _minimum_token1;
        minimumBuy_token2 = _minimum_token2;
        emit SetMinimumBuy(_minimum_token1, _minimum_token2);
    }

    function set_maximumBuy(uint256 _maximum_token1, uint256 _maximum_token2) public isOwner {
        require(_maximum_token1>=1 && _maximum_token2>=1, "maximum values must be greater than or equal to 1");
        maximumBuy_token1 = _maximum_token1;
        maximumBuy_token2 = _maximum_token2;
        emit SetMaximumBuy(_maximum_token1, _maximum_token2);
    }

    function setAmountMulToGetFee(uint256 _amountMulToGetFee) external isOwner {
        require(_amountMulToGetFee >= 0 && _amountMulToGetFee <= 9900, "the new value should range from 0 to 9900");
        amountMulToGetFee = _amountMulToGetFee;
        emit SetAmountMulToGetFee(_amountMulToGetFee);
    }

    function getFee_token2(uint256 _value) public view returns(uint256){
        return (_value*amountMulToGetFee)/amountDivToGetFee;
    }

    function buy_token1(uint256 _amount) external nonReentrant{
        require(!lockNewOrders_token1, "cannot currently create new buy orders");
        require(_amount>=1, "amount to buy must be greater or equal than 1");
        require(_amount>=minimumBuy_token1 && _amount<=maximumBuy_token1, "amount exceeds the minimum or maximum buy");
        uint256 amountToPay = _amount*salePrice_token1;
        uint256 amountToReceive = _amount*mulDec_token1;
        IERC20(address_token2).transferFrom(msg.sender, getOwner(), amountToPay);
        IERC20(address_token1).transferFrom(getOwner(), msg.sender, amountToReceive);
        if(!first_buy[msg.sender]){
            first_buy[msg.sender] = true;
            Referrals(referrals).addReward1(msg.sender, amountToReceive);
        }
        emit BuyToken1(block.timestamp, msg.sender, _amount, amountToPay);
    }

    function buy_token2(uint256 _amount) external nonReentrant{
        require(!lockNewOrders_token2, "cannot currently create new buy orders");
        require(_amount>=1, "amount to buy must be greater or equal than 1");
        require(_amount>=minimumBuy_token2 && _amount<=maximumBuy_token2, "amount exceeds the minimum or maximum buy");
        uint256 amountToPay = _amount*salePrice_token2;
        IERC20(address_token1).transferFrom(msg.sender, getOwner(), amountToPay);
        uint256 amountToBuy = _amount*mulDec_token2;
        uint256 fee = getFee_token2(amountToBuy);
        uint256 amountPurchased = amountToBuy-fee;
        IERC20(address_token2).transferFrom(getOwner(), msg.sender, amountPurchased);
        emit BuyToken2(block.timestamp, msg.sender, _amount, amountToPay, fee);
    }

}