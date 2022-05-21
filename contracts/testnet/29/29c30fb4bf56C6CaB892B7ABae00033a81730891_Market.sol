// SPDX-License-Identifier: MIT

pragma solidity 0.8.8;

import "./IERC20.sol";
import "./Owner.sol";
import "./ReentrancyGuard.sol";

interface NFTS {
    function awardToken(address _newOwner, uint256 _tokenType) external returns (uint256);
}

contract Market is Owner, ReentrancyGuard {

    address public payTokenContract;
    address public sgTokenContract;
    address public sonerTokenContract;

    uint256 public sg_acumulated;

    uint256 private constant mulDec = 10**18;
    uint256 private constant amountDivToGetDiscount = 10**4;

    uint256 public limit_sg_acumulated = 1200000*mulDec;

    uint256[5] public limit_soner_amount_acumulated = [5000, 5000, 5000, 5000, 5000];
    uint256[5] public soner_amount_acumulated = [0, 0, 0, 0, 0];

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
    // 0-4   = SG
    // 5-9  = SG+SONER
    // 10-14 = SONER
    uint256[15] public token_ids = [1, 2, 3, 4, 5, 1, 2, 3, 4, 5, 1, 2, 3, 4, 5];
    uint256[15] public nft_prices = [150*mulDec, 750*mulDec, 1500*mulDec, 7500*mulDec, 15000*mulDec, 300*mulDec, 1200*mulDec, 2350*mulDec, 8850*mulDec, 16350*mulDec, 50*mulDec, 150*mulDec, 450*mulDec, 850*mulDec, 1350*mulDec];
    bool[15] public active_sales = [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true];

    uint[5] public combosSonerType = [2,3,4,5,5];

    mapping(address => mapping(uint256 => uint256)) public free_claim_list;

    event AddToClaimList(
        address claimer,
        uint256 tokenType,
        uint256 amount
    );

    event SetContracts(
        address pay_token,
        address sg_token,
        address soner_token
    );

    event SuccessfulPurchase(
        uint256 indexed purchase_type,
        uint256 amount,
        uint256 price,
        uint256 amount_paid,
        address buyer,
        uint256[] sg_tokenIds,
        uint256[] soner_tokenIds
    );
    event SetTokenId(
        uint256 index,
        uint256 new_id
    );
    event SetNftPrice(
        uint256 index,
        uint256 new_price
    );
    event SetActiveSale(
        uint256 index,
        bool new_status
    );
    event SetLimitSGAcumulated(
        uint256 new_value
    );
    event SetSGAcumulated(
        uint256 new_value
    );
    event SetMinimumSGAcumulateds(
        uint256 _m_sg_acumulated_2,
        uint256 _m_sg_acumulated_3,
        uint256 _m_sg_acumulated_4,
        uint256 _m_sg_acumulated_5
    );
    event SetDiscountPercentages(
        uint256 _discountP_1,
        uint256 _discountP_2,
        uint256 _discountP_3,
        uint256 _discountP_4,
        uint256 _discountP_5
    );

    event SuccessfulClaim(
        uint256 indexed claim_type,
        uint256 amount,
        address buyer,
        uint256[] tokenIds
    );

    event SetLimitSONERAmountAcumulated(
        uint256 index,
        uint256 new_value
    );
    event SetSONERAmountAcumulated(
        uint256 index,
        uint256 new_value
    );

    event SetCombosSonerType(
        uint256 index,
        uint256 new_type
    );

    constructor(address _payTokenContract, address _sgTokenContract, address _sonerTokenContract) {
        payTokenContract = _payTokenContract;
        sgTokenContract = _sgTokenContract;
        sonerTokenContract = _sonerTokenContract;
        emit SetContracts(_payTokenContract, _sgTokenContract, _sonerTokenContract);
        for (uint256 i=0; i<token_ids.length; i++) {
            emit SetTokenId(i, token_ids[i]);
            emit SetNftPrice(i, nft_prices[i]);
            emit SetActiveSale(i, active_sales[i]);
        }

        for (uint256 i=0; i<combosSonerType.length; i++) {
            emit SetCombosSonerType(i, combosSonerType[i]);
        }
        emit SetLimitSGAcumulated(limit_sg_acumulated);
        emit SetSGAcumulated(sg_acumulated);
        emit SetMinimumSGAcumulateds(m_sg_acumulated_2, m_sg_acumulated_3, m_sg_acumulated_4, m_sg_acumulated_5);
        emit SetDiscountPercentages(discountP_1, discountP_2, discountP_3, discountP_4, discountP_5);
    }

    function active_sales_array() external view returns(bool[] memory){
        bool[] memory activeSalesArray = new bool[](active_sales.length);
        for (uint256 i=0; i<active_sales.length; i++) {
            activeSalesArray[i] = active_sales[i]; 
        }
        return activeSalesArray;
    }

    function check_and_add_soner_amount_acumulated(uint256 _type, uint256 _amount) private {
        require(_type<=4, "invalid _type");
        uint256 new_soner_amount_acumulated = soner_amount_acumulated[_type]+_amount;
        require(new_soner_amount_acumulated <= limit_soner_amount_acumulated[_type], "exceeds the limit of soner that can be created");
        soner_amount_acumulated[_type] += _amount;
        emit SetSONERAmountAcumulated(_type, new_soner_amount_acumulated);
    }

    function add_to_free_claim_list(address[] memory _claimers, uint256[] memory _tokenType, uint256[] memory _amount) public isOwner {
        require(_claimers.length <= 1000, "the maximum number of records per batch is 1000");
        require(_claimers.length == _tokenType.length && _claimers.length == _amount.length, "size of all arrays must be equal");

        for (uint256 i=0; i<_claimers.length; i++) {
            require((_tokenType[i]>=0 && _tokenType[i]<=4) || (_tokenType[i]>=10 && _tokenType[i]<=14), "some invalid _tokenType");
            if(_tokenType[i]>=10 && _tokenType[i]<=14){
                check_and_add_soner_amount_acumulated(_tokenType[i]-10, _amount[i]);
            }
            free_claim_list[_claimers[i]][_tokenType[i]] = _amount[i];
            emit AddToClaimList(_claimers[i], _tokenType[i], _amount[i]);
        }
    }

    function setTokenContracts(address _payTokenContract, address _sgTokenContract, address _sonerTokenContract) external isOwner {
        payTokenContract = _payTokenContract;
        sgTokenContract = _sgTokenContract;
        sonerTokenContract = _sonerTokenContract;
        emit SetContracts(_payTokenContract, _sgTokenContract, _sonerTokenContract);
    }

    function setTokenIds(uint256 _arrayIndex, uint256 _newVal) external isOwner {
        require(_newVal>=1 && _newVal<=5, "invalid _newVal");
        token_ids[_arrayIndex] = _newVal;
        emit SetTokenId(_arrayIndex, _newVal);
    }
    function setNftPrices(uint256 _arrayIndex, uint256 _newVal) external isOwner {
        nft_prices[_arrayIndex] = _newVal;
        emit SetNftPrice(_arrayIndex, _newVal);
    }
    function setActiveSales(uint256 _arrayIndex, bool _newVal) external isOwner {
        active_sales[_arrayIndex] = _newVal;
        emit SetActiveSale(_arrayIndex, _newVal);
    }
    
    function set_combos_soner_type(uint256 _arrayIndex, uint256 _newVal) external isOwner {
        require(_newVal>=1 && _newVal<=5, "invalid _newVal");
        combosSonerType[_arrayIndex] = _newVal;
        emit SetCombosSonerType(_arrayIndex, _newVal);
    }

    function set_limit_soner_amount_acumulated(uint256 _arrayIndex, uint256 _newVal) external isOwner {
        limit_soner_amount_acumulated[_arrayIndex] = _newVal;
        emit SetLimitSONERAmountAcumulated(_arrayIndex, _newVal);
    }

    function set_soner_amount_acumulated(uint256 _arrayIndex, uint256 _newVal) external isOwner {
        soner_amount_acumulated[_arrayIndex] = _newVal;
        emit SetSONERAmountAcumulated(_arrayIndex, _newVal);
    }

    function set_limit_sg_acumulated(uint256 _newVal) external isOwner {
        limit_sg_acumulated = _newVal;
        emit SetLimitSGAcumulated(_newVal);
    }

    function set_sg_acumulated(uint256 _newVal) external isOwner {
        sg_acumulated = _newVal;
        emit SetSGAcumulated(_newVal);
    }

    function set_minimum_sg_acumulateds(uint256 _m_sg_acumulated_2, uint256 _m_sg_acumulated_3, uint256 _m_sg_acumulated_4, uint256 _m_sg_acumulated_5) external isOwner {
        m_sg_acumulated_2 = _m_sg_acumulated_2;
        m_sg_acumulated_3 = _m_sg_acumulated_3;
        m_sg_acumulated_4 = _m_sg_acumulated_4;
        m_sg_acumulated_5 = _m_sg_acumulated_5;
        emit SetMinimumSGAcumulateds(_m_sg_acumulated_2, _m_sg_acumulated_3, _m_sg_acumulated_4, _m_sg_acumulated_5);
    }

    function set_discount_percentages(uint256 _discountP_1, uint256 _discountP_2, uint256 _discountP_3, uint256 _discountP_4, uint256 _discountP_5) external isOwner { // example: 4000=40%, 100=1%
        discountP_1 = _discountP_1;
        discountP_2 = _discountP_2;
        discountP_3 = _discountP_3;
        discountP_4 = _discountP_4;
        discountP_5 = _discountP_5;
        emit SetDiscountPercentages(_discountP_1, _discountP_2, _discountP_3, _discountP_4, _discountP_5);
    }

    function getCurrentDiscountPercentage() public view returns(uint256){
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
        if(sg_acumulated>= m_sg_acumulated_5){
            discountPercentage = discountP_5;
        }
        return discountPercentage;
    }

    function getDiscount(uint256 _amount) public view returns(uint256) {
        return (_amount * getCurrentDiscountPercentage()) / amountDivToGetDiscount;
    }

    function is_sg_limit_reached() public view returns(bool) {
        bool status;
        if(sg_acumulated<limit_sg_acumulated){
            status = false;
        }else{
            status = true;
        }
        return status;
    }

    function buy(uint256 _type, uint256 _amount) external nonReentrant {
        require(_type>=0 && _type<=14, "invalid _type");
        require(_amount>=1 && _amount<=100, "invalid _amount");
        require(active_sales[_type], "this type of sale is disabled");

        uint256 price = nft_prices[_type] * _amount;
        uint256 amountToPay;
        if(_type<=9){
            require(sg_acumulated<limit_sg_acumulated, "sg sales are closed");
            amountToPay = price - getDiscount(price);
        }else{
            amountToPay = price;
        }
        IERC20(payTokenContract).transferFrom(msg.sender, getOwner(), amountToPay);

        uint256[] memory sg_tokenIds = new uint256[](_amount);
        uint256[] memory soner_tokenIds = new uint256[](_amount);
        if(_type>=0 && _type<=4){
            sg_acumulated += price;
            for (uint256 i=0; i<_amount; i++) {
                sg_tokenIds[i] = NFTS(sgTokenContract).awardToken(msg.sender, token_ids[_type]);
            }
        }
        if(_type>=5 && _type<=9){
            sg_acumulated += nft_prices[_type - 5] * _amount;
            check_and_add_soner_amount_acumulated(_type-5, _amount);
            for (uint256 i=0; i<_amount; i++) {
                sg_tokenIds[i] = NFTS(sgTokenContract).awardToken(msg.sender, token_ids[_type]);
                soner_tokenIds[i] = NFTS(sonerTokenContract).awardToken(msg.sender, combosSonerType[_type-5]);
            }
        }
        if(_type>=10 && _type<=14){
            check_and_add_soner_amount_acumulated(_type-10, _amount);
            for (uint256 i=0; i<_amount; i++) {
                soner_tokenIds[i] = NFTS(sonerTokenContract).awardToken(msg.sender, token_ids[_type]);
            }
        }

        emit SetSGAcumulated(sg_acumulated);
        emit SuccessfulPurchase(_type, _amount, price, amountToPay, msg.sender, sg_tokenIds, soner_tokenIds);
    }

    function claim(uint256 _type) external nonReentrant {
        require((_type>=0 && _type<=4) || (_type>=10 && _type<=14), "invalid _type");
        require(free_claim_list[msg.sender][_type] >= 1, "there are no tokens of this type to claim");
        
        uint256 amountToClaim;
        if(free_claim_list[msg.sender][_type] > 500){
            amountToClaim = 500;
        }else{
            amountToClaim = free_claim_list[msg.sender][_type];
        }

        free_claim_list[msg.sender][_type] -= amountToClaim;
        uint256[] memory tokenIds = new uint256[](amountToClaim);

        if(_type>=0 && _type<=4){
            for (uint256 i=0; i<amountToClaim; i++) {
                tokenIds[i] = NFTS(sgTokenContract).awardToken(msg.sender, token_ids[_type]);
            }
        }

        if(_type>=10 && _type<=14){
            for (uint256 i=0; i<amountToClaim; i++) {
                tokenIds[i] = NFTS(sonerTokenContract).awardToken(msg.sender, token_ids[_type]);
            }
        }
        
        emit SuccessfulClaim(_type, amountToClaim, msg.sender, tokenIds);
    }

}