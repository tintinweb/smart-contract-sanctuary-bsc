// SPDX-License-Identifier: MIT

pragma solidity 0.8.8;

import "./IERC20.sol";
import "./IERC1155.sol";
import "./Owner.sol";
import "./ReentrancyGuard.sol";

contract Market is Owner, ReentrancyGuard {

    address public payTokenContract;
    address public sgTokenContract;
    address public sonerTokenContract;

    uint256 public sg_acumulated;
    uint256 public soner_acumulated;
    uint256 public sg_and_soner_acumulated;

    uint256 private constant mulDec = 10**18;
    uint256 private constant amountDivToGetDiscount = 10**4;

    uint256 public limit_sg_accumulated = 1200000*mulDec;


    // m_sg_acumulated_1 is no necesary, because always discountP_1 is aplied in the start 
    uint256 public m_sg_acumulated_2 = 168000*mulDec;
    uint256 public m_sg_acumulated_3 = 192000*mulDec;
    uint256 public m_sg_acumulated_4 = 216000*mulDec;
    uint256 public m_sg_acumulated_5 = 240000*mulDec;

    uint256 public discountP_1 = 4000; // example: 4000 = 40%
    uint256 public discountP_2 = 3000;
    uint256 public discountP_3 = 2000;
    uint256 public discountP_4 = 1000;
    uint256 public discountP_5 = 0;

    // array idexes:  
    // 1-5   = SG
    // 6-10  = SG+SONER
    // 11-15 = SONER
    uint256[15] public token_ids = [1, 2, 3, 4, 5, 1, 2, 3, 4, 5, 1, 2, 3, 4, 5];
    uint256[15] public nft_prices = [10*mulDec, 20*mulDec, 30*mulDec, 40*mulDec, 50*mulDec, 60*mulDec, 70*mulDec, 80*mulDec, 90*mulDec, 100*mulDec, 110*mulDec, 120*mulDec, 130*mulDec, 140*mulDec, 150*mulDec];
    bool[15] public active_sales = [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true];

    event SuccessfulPurchase(
        uint256 indexed purchase_type,
        uint256 amount,
        uint256 price,
        uint256 amount_paid,
        address buyer
    );

    constructor(address _payTokenContract, address _sgTokenContract, address _sonerTokenContract) {
        payTokenContract = _payTokenContract;
        sgTokenContract = _sgTokenContract;
        sonerTokenContract = _sonerTokenContract;
    }

    function setTokenContracts(address _payTokenContract, address _sgTokenContract, address _sonerTokenContract) external isOwner {
        payTokenContract = _payTokenContract;
        sgTokenContract = _sgTokenContract;
        sonerTokenContract = _sonerTokenContract;
    }

    function setTokenIds(uint256 _arrayIndex, uint256 _newVal) external isOwner {
        token_ids[_arrayIndex] = _newVal;
    }
    function setNftPrices(uint256 _arrayIndex, uint256 _newVal) external isOwner {
        nft_prices[_arrayIndex] = _newVal;
    }
    function setActiveSales(uint256 _arrayIndex, bool _newVal) external isOwner {
        active_sales[_arrayIndex] = _newVal;
    }

    function set_limit_sg_accumulated(uint256 _newVal) external isOwner {
        limit_sg_accumulated = _newVal;
    }

    function set_minimum_sg_acumulateds(uint256 _m_sg_acumulated_2, uint256 _m_sg_acumulated_3, uint256 _m_sg_acumulated_4, uint256 _m_sg_acumulated_5) external isOwner {
        m_sg_acumulated_2 = _m_sg_acumulated_2;
        m_sg_acumulated_3 = _m_sg_acumulated_3;
        m_sg_acumulated_4 = _m_sg_acumulated_4;
        m_sg_acumulated_5 = _m_sg_acumulated_5;
    }

    function set_discount_percentages(uint256 _discountP_1, uint256 _discountP_2, uint256 _discountP_3, uint256 _discountP_4, uint256 _discountP_5) external isOwner { // example: 4000=40%, 100=1%
        discountP_1 = _discountP_1;
        discountP_2 = _discountP_2;
        discountP_3 = _discountP_3;
        discountP_4 = _discountP_4;
        discountP_5 = _discountP_5;
    }

    function getDiscount(uint256 _amount) public view returns(uint256) {
        uint256 discountPercentage = discountP_1;
        if(sg_acumulated>= m_sg_acumulated_2){
            discountPercentage = discountP_2;
        }
        if(sg_acumulated>= m_sg_acumulated_3){
            discountPercentage = discountP_3;
        }
        if(sg_acumulated>= m_sg_acumulated_4){
            discountPercentage = discountP_4;
        }
        if(sg_acumulated>= discountP_5){
            discountPercentage = discountP_5;
        }
        return (_amount * discountPercentage) / amountDivToGetDiscount;
    }

    function buy(uint256 _type, uint256 _amount) external nonReentrant {
        require(_type>=0 && _type<=14, "invalid _type");
        require(_amount>=1, "invalid _amount");
        require(active_sales[_type], "this type of sale is disabled");

        uint256 price = nft_prices[_type] * _amount;
        uint256 amountToPay;
        if(_type<=9){
            require(sg_acumulated<limit_sg_accumulated, "sg sales are closed");
            amountToPay = price - getDiscount(price);
        }else{
            amountToPay = price;
        }
        IERC20(payTokenContract).transferFrom(msg.sender, address(this), amountToPay);

        if(_type>=0 && _type<=4){
            sg_acumulated += price;
            IERC1155(sgTokenContract).safeTransferFrom(getOwner(), msg.sender, token_ids[_type], _amount, "");
        }
        if(_type>=5 && _type<=9){
            sg_acumulated += nft_prices[_type - 5] * _amount;
            IERC1155(sgTokenContract).safeTransferFrom(getOwner(), msg.sender, token_ids[_type], _amount, "");
            IERC1155(sonerTokenContract).safeTransferFrom(getOwner(), msg.sender, token_ids[_type], _amount, "");
        }
        if(_type>=10 && _type<=14){
            IERC1155(sonerTokenContract).safeTransferFrom(getOwner(), msg.sender, token_ids[_type], _amount, "");
        }

        emit SuccessfulPurchase(_type, _amount, price, amountToPay, msg.sender);
    }

}