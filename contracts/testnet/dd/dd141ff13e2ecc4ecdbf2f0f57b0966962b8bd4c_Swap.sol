/**
 *Submitted for verification at BscScan.com on 2022-10-19
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
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Swap {
    IBEP20 public currency = IBEP20(0x6B4Ef01a6896543c3d96B688e39F5202d00C0f0A);
    IBEP20 public launchToken ;
    IBEP20 public Usdc = IBEP20(0x4dbf78366338d17A2C38c176B8EabE91f3854665);
    IBEP20 public Busd = IBEP20(0x936935Bb69067BE9F295D06C59CfAdC129230301) ;
    address public owner;
    uint256 public stageCount = 0;
    uint256 public stageNumber;
    address private platformCommission = 0x292f18156E5ec34BA3c6760D8fa4A95281852a18;
    uint256 private fee = 0.01 ether;
    uint256 private currencyfee = 10;
    struct purchaseDetails {
        uint numberOfstage;
        uint amount;  
    }
    struct stageDetails {
                uint256 saleRate;
                uint256 softCap ;
                uint256 hardCap;
                uint256 refundType;
                uint256 minimumBuy;
                uint256 maximumBuy;
                uint256 liquidity;
                uint256 startDate;
                uint256 endDate;
                uint256 liquidityLockUp; 
    }
 
    mapping (address =>  mapping(uint256 => purchaseDetails)) public saleRecord;
    mapping (uint256 => stageDetails) public stageRecord; 
    mapping (uint256 => uint256) public sold;
    mapping (uint256 => uint256) public remaining;
    mapping (uint256 => bool) public swapEnable ;   

    modifier onlyOwner {
        require(owner == msg.sender,"Caller must be Ownable!!");
        _;
    }

    constructor(address _launchToken){
        owner = msg.sender;
        launchToken = IBEP20(_launchToken);
    }            
   
    function addStage (stageDetails memory details) public payable
                {     
                require(msg.value >= fee, "Insufficient Balance." );        
                require (details.endDate >=details.startDate,"This stage end date is before start date of the stage");
                launchToken.transferFrom(msg.sender,address(this),details.liquidity);
                payable(platformCommission).transfer(address(this).balance);
                if(stageCount>0)
                require (details.startDate >= stageRecord[stageCount-1].endDate,"This stage start date is merging with the end date of previous stage");
                remaining[stageCount]= details.liquidity;
                stageRecord[stageCount] = details;
                swapEnable[stageCount] = true;
                stageCount++;
    }
           
    function getCurrentStage () internal view returns (uint256) {
    uint i;
    uint currentStage;
        for (i=0;i<stageCount;i++)
        {
            if (block.timestamp >= stageRecord[i].startDate && block.timestamp <= stageRecord[i].endDate)
            currentStage = i;
        }  
    return currentStage;
    }
// 1 = usdt , 2 = Busd , 3 = Busd 
    function swapCurrencyToToken(uint _no,uint currencyAmount) public {
        require(block.timestamp>=stageRecord[0].startDate,"stage 0  not started");
        require(block.timestamp<= stageRecord[stageCount-1].endDate,"last stage has closed");
        uint256 currentStage = getCurrentStage(); 
        uint256 launchtokenDecimal = launchToken.decimals();
        uint256 currencydecimal = currency.decimals();
        uint256 rawCurrency = (currencyAmount*1e18)/(10**currencydecimal);
        uint256 tokenAmount = rawCurrency*stageRecord[currentStage].saleRate;
         tokenAmount = (tokenAmount*(10**launchtokenDecimal))/1e18;
        require((swapEnable[currentStage] == true),"swap is paused");
        require(tokenAmount < remaining[currentStage],"Private sale liquidity exceeds, try reduce the amount");
        require(currencyAmount >= stageRecord[currentStage].minimumBuy,"You cannot buy less than minimum amount");
        require(currencyAmount <= stageRecord[currentStage].maximumBuy,"You cannot buy more than maximum amount");
        // 1 = usdt , 2 = Busd , 3 = Busd 
        if(_no ==1){
        currency.transferFrom(msg.sender,address(this),(currencyAmount *(1000 - currencyfee)/1000));
        currency.transferFrom(msg.sender,platformCommission,(currencyAmount *currencyfee/1000));
        launchToken.transfer(msg.sender,tokenAmount);
        saleRecord[msg.sender][currentStage].amount +=  tokenAmount;
        saleRecord[msg.sender][currentStage].numberOfstage =  currentStage;
        sold[currentStage]+= tokenAmount;
        remaining[currentStage]-=tokenAmount;
        }
        if(_no ==2){
        Usdc.transferFrom(msg.sender,address(this),(currencyAmount *(1000 - currencyfee)/1000));
        Usdc.transferFrom(msg.sender,platformCommission,(currencyAmount *currencyfee/1000));
        launchToken.transfer(msg.sender,tokenAmount);
        saleRecord[msg.sender][currentStage].amount +=  tokenAmount;
        saleRecord[msg.sender][currentStage].numberOfstage =  currentStage;
        sold[currentStage]+= tokenAmount;
        remaining[currentStage]-=tokenAmount;
        }
        if(_no ==3){
        Busd.transferFrom(msg.sender,address(this),(currencyAmount *(1000 - currencyfee)/1000));
        Busd.transferFrom(msg.sender,platformCommission,(currencyAmount *currencyfee/1000));
        launchToken.transfer(msg.sender,tokenAmount);
        saleRecord[msg.sender][currentStage].amount +=  tokenAmount;
        saleRecord[msg.sender][currentStage].numberOfstage =  currentStage;
        sold[currentStage]+= tokenAmount;
        remaining[currentStage]-=tokenAmount;
        }

        }

        function changeStageVariables(stageDetails memory details ,uint256 _stageNumber ) public
        {   
        require(_stageNumber<stageCount,"stage is not existing in the blockchain");
        uint256 currentStage = getCurrentStage();
        require(
            _stageNumber >= currentStage,
            "previous stages can't be modified"
        );
        require(
            details.endDate >= stageRecord[_stageNumber].startDate,"This stage end date is before start date of stage" );
        if((_stageNumber+1) < stageCount)require(stageRecord[_stageNumber].endDate <= stageRecord[_stageNumber + 1].startDate,"This stage end date is merging with start date of next stage");
        stageRecord[_stageNumber]=details;
        remaining[_stageNumber]= details.liquidity;
        }

        function calculatetoken(uint amount, uint _stageNumber) public view returns( uint swapToken) { 
       uint256 launchtokenDecimal = launchToken.decimals();
        uint256 currencydecimal = currency.decimals();
        uint256 rawCurrency = (amount*1e18)/(10**currencydecimal);
        uint256 tokenAmount = rawCurrency*stageRecord[_stageNumber].saleRate;
        tokenAmount = (tokenAmount*(10**launchtokenDecimal))/1e18;
        return tokenAmount;
        }
        function calculateCurrency(uint amount, uint _stageNumber) public view returns( uint swapToken) {
        uint256 launchtokenDecimal = launchToken.decimals();
        uint256 currencydecimal = currency.decimals();
        uint256 rawToken = (amount*1e18)/(10**launchtokenDecimal);
        uint256 currencyAmount = rawToken/stageRecord[_stageNumber].saleRate;
        currencyAmount = (currencyAmount*(10**currencydecimal))/1e18;
        return currencyAmount;
        }

        function tokeninfo(address _token) public view  returns(string memory name ,string memory symbol,uint8 decimals){
        symbol = IBEP20(_token).symbol();
        name = IBEP20(_token).name();
        decimals = IBEP20(_token).decimals();
    }
        function ChangePlatformFee( uint _fee) public{
        require(  platformCommission  == msg.sender,"only platform owner change");
        fee = _fee;
        }
        function ChangeCurrencyFee( uint _fee) public{
        require(  platformCommission  == msg.sender,"only platform owner change");
        currencyfee = _fee;
        }


        function withdrawToken(address _tokenContract, uint256 _amount) external onlyOwner{
        require(block.timestamp<= stageRecord[stageCount-1].endDate,"last stage has closed");
        IBEP20 tokenContract = IBEP20(_tokenContract);      
        tokenContract.transfer(msg.sender, _amount);
        }

        function Balance(address _user) public view returns(uint){
        return launchToken.balanceOf(_user);
        }

        function swapDisable(uint256 _stageNumber ,  bool _paused) external onlyOwner{
       swapEnable[_stageNumber] = _paused;
        }
        
        function getPurchase(address _user,uint _stage) public view returns (uint,uint){
        return  (saleRecord[_user][_stage].amount,saleRecord[_user][_stage].numberOfstage);
    }
}