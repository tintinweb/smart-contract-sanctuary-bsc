//SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;


import "./Ownable.sol";
import "./SafeMath.sol";

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
interface IFreeper {
    function registerDomain(string memory domain, address owner) external returns (uint);
}

interface IWord{
    function charCheckAndCount(string memory str) external view returns(uint);
}

contract RegisterContract is  Ownable{

    mapping(address=>bool) public governance;

    modifier onlyGov(){
        require(governance[msg.sender],"not governance");
        _;
    }

    function setGov(address addr, bool status) public onlyGov{
        governance[addr] = status;
    }
    using SafeMath for uint;

    // struct WhiteList {
    //     // bool status;
    //     // uint total;
    //     uint canUse;
    // }

    struct Promotion{
        uint total;
        uint balance;
        uint discount;
        uint num;
        uint expiredTime;
    }
    
    // mapping (address => WhiteList) whitelists;
    mapping (string => Promotion) promotions;

    struct NumPrice {
        uint price;
    }


    struct RegisterCount {
        uint registCount;
        uint wordLen3;
    }

    mapping(address=>RegisterCount) public registCount;

    mapping (uint => NumPrice) public numPrices;

    // mapping (string => uint) specialDomainPrice;

    bool openNormal = false;
    bool openPromotion = false;
    bool openWhiteList = false;

    uint recommenderV1 = 100;
    uint recommenderV2 = 50;
    uint recommenderDiscount = 100;

    struct Recommender{
        address recommender;
        bool status;
    }
    mapping(address=>Recommender) public recommenders;

    uint public registerCount = 0;
    uint public whilteListDiscountV1 = 500;
    uint public whilteListDiscountV2 = 700;
    // uint balan

    address public usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
    address public  feeAddress = 0x9eA91A137e06341EeB4ac3660465e1149043CF6e;

    address public freeperAddress = 0xE0682C420119F37429b28bB58C6519cC80FC003e;
    address public wordAddress = 0xD50ecbEbcD566277Cc363bec4AE3FcA5c4C7204E;
    
    event Reward(address indexed dest, address indexed from, uint indexed level,uint amount);

    constructor()public{
        // whitelists[msg.sender] =  true;
        numPrices[1].price = 2000 ether;
        numPrices[2].price = 100 ether;
        numPrices[3].price = 40 ether;
        numPrices[4].price = 10 ether;
    }

    function checkDomain(string memory domain) internal returns (uint, bool isDiscount){
        uint n = IWord(wordAddress).charCheckAndCount(domain);
        require(n<=64,"character is too long");
        require(n >= 3, "can't regist word which is length less than 3");
        uint p = 0;
        if (n == 3){
            p = 1;
        }else if(n >= 4 && n <=6){
            registCount[msg.sender].registCount = registCount[msg.sender].registCount.add(1);
            if (registCount[msg.sender].registCount.mod(5) == 0){
                registCount[msg.sender].wordLen3 = registCount[msg.sender].wordLen3.add(1);
            }
            p = 2;
        }else if(n >= 7 && n <=9){
            p = 3;
        }else if(n >= 10){
            p = 4;
        }
        uint price = numPrices[p].price;
        if (n<10 && n >3){
            if (registerCount <= 5000){
                price = price.mul(whilteListDiscountV1).div(1000);
                isDiscount = true;
            }else if (registerCount <= 15000){
                price = price.mul(whilteListDiscountV2).div(1000);
                isDiscount = true;
            }else{
                isDiscount = false;
            }
        }else{
            if(n == 3){
                if(registCount[msg.sender].wordLen3 > 0){
                    price  = price.mul(500).div(1000);
                    isDiscount = true;
                    registCount[msg.sender].wordLen3 = registCount[msg.sender].wordLen3.sub(1);
                }
            }else{
                isDiscount = false;
            }
        }
        registerCount = registerCount.add(1);
        return (price, isDiscount);

    }


    function distribute(uint amount, address recommender) internal returns (uint) {
        require(msg.sender != recommender, "can't recommender self");
        uint left = amount;
        address r = recommender;
        uint count = 0;
        while(true){
            if (r != address(0)){
                if(count == 0){
                    // transfer level 1;
                    left = left.sub(amount.mul(recommenderV1).div(1000)); 
                    IERC20(usdtAddress).transferFrom(msg.sender, r, amount.mul(recommenderV1).div(1000));
                    emit Reward(r, msg.sender, 1, amount.mul(recommenderV1).div(1000));
                }else{
                    // transfer level 2;
                    left = left.sub(amount.mul(recommenderV2).div(1000));
                    IERC20(usdtAddress).transferFrom(msg.sender, r, amount.mul(recommenderV2).div(1000));
                    emit Reward(r, msg.sender, 2, amount.mul(recommenderV2).div(1000));
                }
            }else{
                break;
            }
            if(count ==1) {
                break;
            }
            r = recommenders[r].recommender;
            count++;
        }

        return left;

    }

    function checkDomainPrice(string memory domain,address addr) public view returns(uint){
        uint n = IWord(wordAddress).charCheckAndCount(domain);
        require(n<=64,"character is too long");
        require(n >= 3, "can't regist word which is length less than 3");
        uint p = 0;
        if (n == 3){
            p = 1;
        }else if(n >= 4 && n <=6){
            p = 2;
        }else if(n >= 7 && n <=9){
            p = 3;
        }else if(n >= 10){
            p = 4;
        }
        uint price = numPrices[p].price;
        if (n<10 && n >3){
            if (registerCount <= 5000){
                price = price.mul(whilteListDiscountV1).div(1000);
             
            }else if (registerCount <= 15000){
                price = price.mul(whilteListDiscountV2).div(1000);
            }
        }else{
            if(n == 3){
                if(registCount[addr].wordLen3 > 0){
                    price  = price.mul(500).div(1000);
                }
            }
        }
        return price;
    }

    function regist(string memory domain, address recommender) public {
        (uint price,bool isDiscount) = checkDomain(domain);
        uint left  = 0;
        if (recommender != address(0)){
            if(recommenders[msg.sender].status == false){
                recommenders[msg.sender].recommender = recommender;
                recommenders[msg.sender].status = true;
            }
        }
        if (isDiscount == false){
            left = distribute(price, recommenders[msg.sender].recommender);
        }else{
                left = price;
        }
        IERC20(usdtAddress).transferFrom(msg.sender, feeAddress, left);
        IFreeper(freeperAddress).registerDomain(domain, msg.sender);
    }
}