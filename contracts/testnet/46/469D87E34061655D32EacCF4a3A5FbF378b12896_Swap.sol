/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);
        return a / b;
    }
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
interface IBEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
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
abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {

        _status = _NOT_ENTERED;
    }

    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
contract Swap is ReentrancyGuard {
    IBEP20 private Usdt = IBEP20(0x6B4Ef01a6896543c3d96B688e39F5202d00C0f0A);
    IBEP20 private Usdc = IBEP20(0x4dbf78366338d17A2C38c176B8EabE91f3854665);
    IBEP20 private Busd = IBEP20(0x936935Bb69067BE9F295D06C59CfAdC129230301);
    IBEP20 private Eth = IBEP20(0xa9C206a388B55CaAa3C791d50a925F3822CA3921) ;
    IBEP20 private Btc = IBEP20(0xE0FB99673da24F483103717fFf1Ac798B2B7aEC8) ;
  address private Burn = 0x000000000000000000000000000000000000dEaD;

     
    IBEP20 public launchToken;
    address public owner;
    uint256 public stageNumber;
    address public launchTokenOwner;
    uint256 public swapFee ;  //50=5% of currency amount
    uint256 public claimableDays; 
    uint256 public releasedAmount;
      // 0 = bnb , 1 = usdt , 2 = eth , 3 = btc, 4 = Busd , 5 = usdc  
    uint256 public usdtRate ; // 326.48e18;
    uint256 private ethRate ; // 0.210743e18;
    uint256 private btcRate ; // 0.0160418e18;
    uint256 private busdRate ; // 326.23e18;
    uint256 private usdcRate ; // 326e18;
    struct purchaseDetails {
        uint256 amount;
        uint256 totalClaimed;
        uint256 lastClaimed;
    }
    struct stageDetails {
        uint256 saleRate;
        uint256 softCap;
        uint256 hardCap;
        uint256 minimumBuy;
        uint256 maximumBuy;
        uint256 liquidity;
        bool    refund;
        uint256 startDate;
        uint256 endDate;
        uint256 cliffing;
        uint256 vesting ;
        uint256 totalDays;
    }
    mapping(address => purchaseDetails) public saleRecord;
    mapping(uint256 => stageDetails) public stageRecord;
    mapping(address => uint256) public perUserBnb;
    mapping(address => uint256) public perUserUsdt;
    mapping(address => uint256) public perUserEth;
    mapping(address => uint256) public perUserBtc;
    mapping(address => uint256) public perUserBusd;
    mapping(address => uint256) public perUserUsdc;
    uint256 public sold;
    uint256 public totalUsdtRaised;
    uint256 public totalBnbRaised;
    uint256 public remaining;
    bool public swapEnable;
    modifier onlyOwner() {
        require(owner == msg.sender, "Caller must be Ownable!!");
        _;
    }
    constructor( address _launchToken,address _launchTokenOwner , uint256 _swapFee ,uint _usdtRate ,uint _ethRate , uint _btcRate , uint _busdRate , uint _usdcRate) {
        owner = msg.sender;
        launchToken = IBEP20(_launchToken);
        launchTokenOwner = _launchTokenOwner;
        swapFee = _swapFee;
        usdtRate = _usdtRate;
        ethRate = _ethRate;
        btcRate = _btcRate;
        busdRate = _busdRate;
        usdcRate = _usdcRate;
    }
    function addStage(stageDetails memory details) public onlyOwner{
        require(
            details.endDate >= details.startDate,
            "This stage end date is before start date of the stage"
        );
        require(details.totalDays >= 1 ," always greater than 0");
        launchToken.transferFrom(msg.sender, address(this), details.liquidity);
        remaining = details.liquidity;
        stageRecord[0] = details;
        swapEnable = true;
    }
        function calcualteToken( uint _qty) public view  returns(uint _bnb , uint _usdt , uint _eth , uint _btc, uint _busd , uint _usdc   ) {
            uint256 tokenDecimal = launchToken.decimals();
            uint rate = stageRecord[0].saleRate*(10**tokenDecimal);
        _bnb = _qty * 1e18/ rate;
        _usdt = _qty * usdtRate /rate ;
        _eth = _qty* ethRate /rate ;
         _btc =  _qty * btcRate/rate;
         _busd =_qty *busdRate/rate; 
         _usdc =_qty *usdcRate  /rate;
    }
        function swapCurrencyToToken(uint _no,uint currencyAmount) public payable nonReentrant {
        require(block.timestamp>=stageRecord[0].startDate,"stage 0  not started");
        require(block.timestamp<= stageRecord[0].endDate,"last stage has closed");
        require((swapEnable == true),"swap is paused");
        require(sold < stageRecord[0].liquidity,"Private sale liquidity exceeds, try reduce the amount");
        // 0 = bnb , 1 = usdt , 2 = eth , 3 = btc, 4 = Busd , 5 = usdc  
         if(_no ==0 && currencyAmount ==0  ){
        require(msg.value >= 0.001 ether,"You cannot buy less than minimum amount");
        require(msg.value <= 10 ether,"You cannot buy more than maximum amount");
        uint256 tokenDecimal = launchToken.decimals(); 
        uint256 tokensAmount = msg.value *stageRecord[0].saleRate *(10**tokenDecimal)/1e18;
        require(tokensAmount <= remaining,"This stage liquidity exceeds, try reduce the amount");
        uint256 launchPadAmount = msg.value * swapFee/1000;
        payable(owner).transfer(launchPadAmount);
        payable(launchTokenOwner).transfer(address(this).balance);
        saleRecord[msg.sender].amount +=  tokensAmount;
        perUserBnb[msg.sender] += msg.value;
        sold+= tokensAmount;
        remaining-=tokensAmount;
        }
        if(_no ==1){
        require(currencyAmount >= stageRecord[0].minimumBuy,"You cannot buy less than minimum amount");
        require(currencyAmount <= stageRecord[0].maximumBuy,"You cannot buy more than maximum amount");
        Usdt.transferFrom(msg.sender,launchTokenOwner,(currencyAmount *(1000 - swapFee)/1000));
        Usdt.transferFrom(msg.sender,owner,(currencyAmount *swapFee/1000));
        uint256 tokenDecimal = launchToken.decimals(); 
        uint256 tokenAmount = currencyAmount * stageRecord[0].saleRate *(10**tokenDecimal)/ usdtRate;
        saleRecord[msg.sender].amount +=  tokenAmount;
        perUserUsdt[msg.sender] += currencyAmount;
        sold+= tokenAmount;
        remaining-=tokenAmount;
        }
       
        if(_no ==2){
        require(currencyAmount >= 0.00644734e18 ,"You cannot buy less than minimum amount");
        require(currencyAmount <= 0.643342e18,"You cannot buy more than maximum amount");
        Eth.transferFrom(msg.sender,launchTokenOwner,(currencyAmount *(1000 - swapFee)/1000));
        Eth.transferFrom(msg.sender,owner,(currencyAmount *swapFee/1000));
        uint256 tokenDecimal = launchToken.decimals(); 
        uint256 tokenEQuantity = currencyAmount * stageRecord[0].saleRate *(10**tokenDecimal) / ethRate;
        saleRecord[msg.sender].amount +=  tokenEQuantity;
        perUserEth[msg.sender] += currencyAmount;
        sold+= tokenEQuantity;
        remaining-=tokenEQuantity;
        }
             if(_no ==3){
        require(currencyAmount >= 0.000491033e18 ,"You cannot buy less than minimum amount");
        require(currencyAmount <= 0.0490398e18,"You cannot buy more than maximum amount");
        Btc.transferFrom(msg.sender,launchTokenOwner,(currencyAmount *(1000 - swapFee)/1000));
        Btc.transferFrom(msg.sender,owner,(currencyAmount *swapFee/1000));
        uint256 tokenDecimal = launchToken.decimals(); 
         uint256 tokenBQuantity = currencyAmount * stageRecord[0].saleRate*(10**tokenDecimal)/ btcRate;
        saleRecord[msg.sender].amount +=  tokenBQuantity;
        perUserBtc[msg.sender] += currencyAmount;
        sold+= tokenBQuantity;
        remaining-=tokenBQuantity;
        }
             if(_no ==4){
        require(currencyAmount >= stageRecord[0].minimumBuy,"You cannot buy less than minimum amount");
        require(currencyAmount <= stageRecord[0].maximumBuy,"You cannot buy more than maximum amount");
        Busd.transferFrom(msg.sender,launchTokenOwner,(currencyAmount *(1000 - swapFee)/1000));
        Busd.transferFrom(msg.sender,owner,(currencyAmount *swapFee/1000));
        uint256 tokenDecimal = launchToken.decimals(); 
         uint256 token4Quantity = currencyAmount * stageRecord[0].saleRate *(10**tokenDecimal)/ busdRate;
        saleRecord[msg.sender].amount +=  token4Quantity;
        perUserBusd[msg.sender] += currencyAmount;
        sold+= token4Quantity;
        remaining-=token4Quantity;
        }
         if(_no ==5){
        require(currencyAmount >= stageRecord[0].minimumBuy,"You cannot buy less than minimum amount");
        require(currencyAmount <= stageRecord[0].maximumBuy,"You cannot buy more than maximum amount");
        Usdc.transferFrom(msg.sender,launchTokenOwner,(currencyAmount *(1000 - swapFee)/1000));
        Usdc.transferFrom(msg.sender,owner,(currencyAmount *swapFee/1000));
        uint256 tokenDecimal = launchToken.decimals(); 
         uint256 tokenUQuantity = currencyAmount * stageRecord[0].saleRate *(10**tokenDecimal)/ usdcRate;
        saleRecord[msg.sender].amount +=  tokenUQuantity;
        perUserUsdc[msg.sender] += currencyAmount;
        sold+= tokenUQuantity;
        remaining-=tokenUQuantity;
        }
        saleRecord[msg.sender].lastClaimed = stageRecord[0].endDate + stageRecord[0].cliffing;
        }
  function claim() public nonReentrant {
        require(saleRecord[msg.sender].amount > 0, "swap : user not exist");
        require(saleRecord[msg.sender].totalClaimed < saleRecord[msg.sender].amount, "swap  : total claim < total balance");
        require((saleRecord[msg.sender].lastClaimed > 0) && ((saleRecord[msg.sender].lastClaimed + stageRecord[0].vesting) <= block.timestamp), "wait for completed vesting time");
        uint claimableDay;
        uint lastClaimTimestamp = saleRecord[msg.sender].lastClaimed;
        uint claimAmount;
              if(stageRecord[0].vesting == 0) {
                claimAmount =  saleRecord[msg.sender].amount;
                 launchToken.transfer(msg.sender,claimAmount);
                 saleRecord[msg.sender].totalClaimed += claimAmount;
            }
             if(stageRecord[0].vesting != 0){
        uint256  claimPercent = 100e18 / stageRecord[0].totalDays;
        claimableDay = (block.timestamp - lastClaimTimestamp) / stageRecord[0].vesting;
        saleRecord[msg.sender].lastClaimed += stageRecord[0].vesting * claimableDay;
        claimAmount = (saleRecord[msg.sender].amount * (claimPercent * claimableDay)) / 100e18;
        if((saleRecord[msg.sender].totalClaimed + claimAmount) > saleRecord[msg.sender].amount) {
            claimAmount = saleRecord[msg.sender].amount - saleRecord[msg.sender].totalClaimed; 
        }
        launchToken.transfer(msg.sender,claimAmount);
        saleRecord[msg.sender].totalClaimed += claimAmount;
             }
  }
function viewClaimTokens(address user ) public view returns(uint256 claims ) {
        if((saleRecord[user].totalClaimed >= saleRecord[user].amount) || (saleRecord[user].amount == 0) || ((saleRecord[user].lastClaimed + stageRecord[0].vesting) >= block.timestamp)) {
            return 0;
        }
        uint claimableDay;
        uint lastClaimTimestamp = saleRecord[user].lastClaimed;
        uint claimAmount;
              if(stageRecord[0].vesting == 0) {
                claimAmount =  saleRecord[user].amount;
                 return claimAmount;
            }
             if(stageRecord[0].vesting != 0){
                 uint256  claimPercent = 100e18 / stageRecord[0].totalDays;
        claimableDay = (block.timestamp - lastClaimTimestamp) / stageRecord[0].vesting;
        claimAmount = (saleRecord[user].amount * (claimPercent * claimableDay)) / 100e18;
        if((saleRecord[user].totalClaimed + claimAmount) > saleRecord[user].amount) {
            claimAmount = saleRecord[user].amount - saleRecord[user].totalClaimed; 
        }
        return claimAmount;
             }
}
 function swapFeeChange(uint _fee) public  onlyOwner{
     swapFee = _fee;
 }

   function viewPurchase(address _buyer) public view returns( uint256 _bnb , uint256 _usdt , uint256 _eth , uint256 _btc, uint256 _busd , uint256 _usdc){
    return (  perUserBnb[_buyer],perUserUsdt[_buyer],perUserEth[_buyer],perUserBtc[_buyer],perUserBusd[_buyer],perUserUsdc[_buyer]);
}

   function soldValueinUsdt() public view returns(uint256 usdt) {
    uint256 tokenDecimal = launchToken.decimals();
    usdt = sold * usdtRate /(stageRecord[0].saleRate *(10**tokenDecimal));
    }

    function calculatetoken(uint256 amount)
        public
        view
        returns (uint256 swapToken)
    {
        uint256 launchtokenDecimal = launchToken.decimals();
        uint256 currencydecimal = Usdt.decimals();
        uint256 rawCurrency = (amount * 1e18) / (10**currencydecimal);
        uint256 tokenAmount = rawCurrency * stageRecord[0].saleRate/100;
        tokenAmount = (tokenAmount * (10**launchtokenDecimal)) / 1e18;
        return tokenAmount;
    }
    function calculateCurrency(uint256 amount)
        public
        view
        returns (uint256 swapToken)
    {
        uint256 launchtokenDecimal = launchToken.decimals();
        uint256 currencydecimal = Usdt.decimals();
        uint256 rawToken = (amount * 1e18) / (10**launchtokenDecimal);
        uint256 currencyAmount = rawToken * 100/ stageRecord[0].saleRate;
        currencyAmount = (currencyAmount * (10**currencydecimal)) / 1e18;
        return currencyAmount;
    }
    function tokeninfo(address _token)
        public
        view
        returns (
            string memory name,
            string memory symbol,
            uint8 decimals
        )
    {
        symbol = IBEP20(_token).symbol();
        name = IBEP20(_token).name();
        decimals = IBEP20(_token).decimals();
    }
    function withdrawToken()
        external returns(uint256)
    {
      require(block.timestamp >= stageRecord[0].endDate,"last stage has closed");
      require (msg.sender ==  launchTokenOwner,"address not launch token owner ");
        IBEP20 tokenContract = IBEP20(launchToken);
        uint amount = remaining;
           
          if (stageRecord[0].refund == true){
            tokenContract.transfer(msg.sender, amount);
        }
      
        if (stageRecord[0].refund == false){
         
            tokenContract.transfer(Burn, amount);
        }
        remaining = 0;
        return 0;
    }
    function Balance(address _user) public view returns (uint256) {
        return launchToken.balanceOf(_user);
    }
    function swapDisable( bool _paused)
        external
        onlyOwner
    {
        swapEnable = _paused;
    }
    function getPurchase(address _user)
        public
        view
        returns (uint256)
    {
        return (
            saleRecord[_user].amount
        );
    }
}