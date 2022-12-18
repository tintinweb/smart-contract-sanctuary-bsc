/**
 *Submitted for verification at BscScan.com on 2022-12-18
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
contract icoSwap is ReentrancyGuard {
    IBEP20 private Usdt = IBEP20(0x55d398326f99059fF775485246999027B3197955);
    IBEP20 private Usdc = IBEP20(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d);
    IBEP20 private Busd = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IBEP20 private Dai = IBEP20(0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3) ;

     
    IBEP20 public launchToken;
    address public owner;
    uint256 public claimableDays; 
    uint256 public releasedAmount;
      // 0 = bnb , 1 = usdt , 2 = eth , 3 = btc, 4 = Busd , 5 = usdc  
    uint256 public usdtRate ;
    uint256 public daiRate ; 
    uint256 public busdRate ;
    uint256 public usdcRate ; 
    struct purchaseDetails {
        uint256 amount;
        uint256 totalClaimed;
        uint256 lastClaimed;
    }
    struct stageDetails {
        uint256 saleRate;
        uint256 startDate;
        uint256 endDate;
        uint256 cliffing;
        uint256 vesting ;
    }
    mapping(address => purchaseDetails) public saleRecord;
    mapping(uint256 => stageDetails) public stageRecord;
    mapping(address => uint256) public perUserBnb;
    mapping(address => uint256) public perUserUsdt;
    mapping(address => uint256) public perUserDai;
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
    constructor( address _launchToken,uint _usdtRate , uint _busdRate , uint _usdcRate , uint _daiRate) {
        owner = msg.sender;
        launchToken = IBEP20(_launchToken);
        usdtRate = _usdtRate;
        busdRate = _busdRate;
        usdcRate = _usdcRate;
        daiRate = _daiRate;
    }
    function addStage(stageDetails memory details) public onlyOwner{
        require(
            details.endDate >= details.startDate,
            "This stage end date is before start date of the stage"
        );
        stageRecord[0] = details;
    }
        function calcualteToken( uint _qty) public view  returns(uint _bnb , uint _usdt , uint _busd , uint _usdc ,  uint _dai ) {
        uint rate = stageRecord[0].saleRate;
        _bnb = _qty * 1e18/ rate;
        _usdt = _qty * 1e18 / usdtRate ;
         _busd = _qty * 1e18 / busdRate; 
         _usdc = _qty * 1e18 / usdcRate;
         _dai = _qty * 1e18 /daiRate;
    }
        function swapCurrencyToToken(uint _no, uint currencyAmount   ) public payable nonReentrant {
        require(block.timestamp>=stageRecord[0].startDate,"stage 0  not started");
        require(block.timestamp<= stageRecord[0].endDate,"last stage has closed");
         if(_no ==0 && currencyAmount ==0  ){
        require(msg.value >= 0.001 ether,"You cannot buy less than minimum amount");
        require(msg.value <= 20 ether,"You cannot buy more than maximum amount");
       
        uint256 tokensAmount = msg.value *stageRecord[0].saleRate /1e18;
        payable(owner).transfer(address(this).balance);
        saleRecord[msg.sender].amount +=  tokensAmount;
        perUserBnb[msg.sender] += msg.value;
        sold+= tokensAmount;
        }
        if(_no ==1){
        Usdt.transferFrom(msg.sender,owner,currencyAmount);
        uint256 tokenAmount = currencyAmount * usdtRate/1e18;
        saleRecord[msg.sender].amount +=  tokenAmount;
        perUserUsdt[msg.sender] += currencyAmount;
        sold+= tokenAmount;
        }
 
             if(_no ==2){
        Busd.transferFrom(msg.sender,owner,currencyAmount);
        uint256 token4Quantity = currencyAmount * busdRate /1e18;
        saleRecord[msg.sender].amount +=  token4Quantity;
        perUserBusd[msg.sender] += currencyAmount;
        sold+= token4Quantity;
        }
         if(_no ==3){
        Usdc.transferFrom(msg.sender,owner,currencyAmount );
         uint256 tokenUQuantity = currencyAmount * usdcRate /1e18; 
        saleRecord[msg.sender].amount +=  tokenUQuantity;
        perUserUsdc[msg.sender] += currencyAmount;
        sold+= tokenUQuantity;
        }
         if(_no == 4 ){
        Dai.transferFrom(msg.sender,owner,currencyAmount );
        uint256 tokenUQuantity = currencyAmount * daiRate /1e18;
        saleRecord[msg.sender].amount +=  tokenUQuantity;
        perUserDai[msg.sender] += currencyAmount;
        sold+= tokenUQuantity;
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
        uint256  claimPercent = 8333333333330000000;
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
                 uint256  claimPercent = 8333333333330000000;
        claimableDay = (block.timestamp - lastClaimTimestamp) / stageRecord[0].vesting;
        claimAmount = (saleRecord[user].amount * (claimPercent * claimableDay)) / 100e18;
        if((saleRecord[user].totalClaimed + claimAmount) > saleRecord[user].amount) {
            claimAmount = saleRecord[user].amount - saleRecord[user].totalClaimed; 
        }
        return claimAmount;
             }
}


   function viewPurchase(address _buyer) public view returns( uint256 _bnb , uint256 _usdt ,uint256 _busd , uint256 _usdc, uint256 _dai ){
    return (  perUserBnb[_buyer],perUserUsdt[_buyer],perUserBusd[_buyer],perUserUsdc[_buyer],perUserDai[_buyer]);
}

   function soldValueinUsdt() public view returns(uint256 usdt) {
    uint256 tokenDecimal = launchToken.decimals();
    usdt = sold * usdtRate /(stageRecord[0].saleRate *(10**tokenDecimal));
    }

    function calculateCurrency(uint256 amount)
        public
        view
        returns (uint _bnb , uint _usdt , uint _busd , uint _usdc ,  uint _dai)
    {
                uint rate = stageRecord[0].saleRate;
        uint256 tokenAmount =  amount * rate /(1e18) ;
       uint256 tokenAmount1 =  amount * usdtRate /(1e18) ;
       uint256 tokenAmount2 =  amount *  busdRate /(1e18);
       uint256 tokenAmount3 =  amount *  usdcRate /(1e18);
      uint256  tokenAmount4 =  amount * daiRate /(1e18);

        return ( tokenAmount, tokenAmount1,tokenAmount2,tokenAmount3,tokenAmount4);
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
    function withdrawToken(uint256 amount)
        public onlyOwner returns(uint256)
    {
      require(block.timestamp >= stageRecord[0].endDate,"last stage has closed");
        IBEP20 tokenContract = IBEP20(launchToken);

            tokenContract.transfer(msg.sender, amount);

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