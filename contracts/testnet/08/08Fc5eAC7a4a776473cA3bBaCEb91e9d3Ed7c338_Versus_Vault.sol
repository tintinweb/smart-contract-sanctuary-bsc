/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

pragma solidity ^0.8.15;
//SPDX-License-Identifier: MIT

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

interface IVSToken { 


    function totalSupply() external view  returns (uint256);
    function decimals() external pure  returns (uint8);
    function symbol() external pure  returns (string memory);
    function name() external pure  returns (string memory);
    function getOwner() external view  returns (address);
    function balanceOf(address account) external view  returns (uint256);
    function allowance(address holder, address spender) external view  returns (uint256);
    function approve(address spender, uint256 amount) external  returns (bool);
    function approveMax(address spender) external returns (bool);
    function transfer(address recipient, uint256 amount) external  returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external  returns (bool);
    function setMaxWalletPercent(uint256 maxWallPercent) external;
    function _transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function _basicTransfer(address sender, address recipient, uint256 amount) external returns (bool);
    function LaunchToken() external;      
    function setTradingStatus(bool _status) external;
    function triggerManualBuyback(uint256 amount) external;
    function setBuyTxLimitInPercent(uint256 maxBuyTxPercent) external; 
    function setSellTxLimitInPercent(uint256 maxSellTxPercent) external;
    function setBuyFees(uint256 _liquidityFeeBuy, uint256 _reflectionFeeBuy, uint256 _marketingFeeBuy, uint256 _VAULTFeeBuy, uint256 _feeDenominator) external;
    function setSellFees(uint256 _liquidityFeeSell, uint256 _reflectionFeeSell, uint256 _marketingFeeSell, uint256 _VAULTFeeSell, uint256 _feeDenominator) external;
    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver, address _VAULTFeeReceiver) external;

    // Set swapBack settings   250 = 25,000,000
    function setSwapBackSettings(bool _enabled, uint256 _amount) external;
    // Send BNB to marketingwallet
    function manualSend() external;
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;


} 

contract Versus_Vault {

   IVSToken  vtoken ; //** V Token
   IVSToken  stoken ; //** S Token    

    using SafeMath for uint256;

    // Versus Token addresses
    address public V_Token;
    address public S_Token;

    // These are owner by default

    address public devPayReceiver;
    address public mktMngrPayReceiver;
    address public webMngrPayReceiver;    

    bool public liveStatus;
    
    address public owner;

    constructor() {

        owner = msg.sender;

    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    receive()   external payable{ }
    fallback()  external payable{ }

    // 10% fee setup for DEV team leaving 1% for GAS

    uint256 public devPay = 40;             // 4% dev takes 1% hit for gas
    uint256 public mktMngrPay = 25;         // 2.5%
    uint256 public webMngrPay = 25;         // 2.5%
    uint256 public payDenominator = 1000;   // 100%

    // Switch Vault Live status
    //Vault Status -- Paused between Versus Battles
    function setVaultStatus(bool _status) public onlyOwner  {
        liveStatus = _status; 
    }

    // Set pay receivers
    function setPayReceivers(

            address _devPayReceiver,
            address _mktMngrPayReceiver,
            address _webMngrPayReceiver  

            ) 
            external onlyOwner {

        devPayReceiver = _devPayReceiver;
        mktMngrPayReceiver = _mktMngrPayReceiver;
        webMngrPayReceiver = _webMngrPayReceiver;
    }

    function setPayAmounts(
        uint256 _devPay, 
        uint256 _mktMngrPay, 
        uint256 _webMngrPay,
        uint256 _payDenominator
        ) 
        external onlyOwner {
        devPay = _devPay;
        mktMngrPay = _mktMngrPay;
        webMngrPay = _webMngrPay;
        payDenominator = _payDenominator; 
    }
    

    function depositToVault() public payable{
        require(liveStatus, "Vault not Live");
        require(msg.value >= ((1 ether) / 1000), "You must send at least .001 ETHER");
    }
   
    function manualWithdrawal() public onlyOwner {
        require(liveStatus, "Vault not Live");
        uint256 contractBnBBalance = address(this).balance;
        payable(devPayReceiver).transfer(contractBnBBalance);
    } 

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

// VERSUS TOKEN CONTROL

    // set V and S token address
    function _1_setVersusTokens(address _vAddr, address _sAddr) public onlyOwner  {
        vtoken = IVSToken(_vAddr);
        stoken = IVSToken(_sAddr);

        V_Token = _vAddr;
        S_Token = _sAddr;
       
    }

    function _2_LaunchVERSUSTokens() public onlyOwner  {
        vtoken.LaunchToken();
        stoken.LaunchToken();       
    }    

    //TOKEN TRADINGSTATUS 
    function _6_setTokenStatus(bool _live) public onlyOwner {        
        stoken.setTradingStatus(_live);
        vtoken.setTradingStatus(_live);
    } 

//////WINNER - Initiate BUYBACKsss After game is over
    function Winner_VVV() public onlyOwner {     

        //Dev team payout
        uint256 payout10percent = (address(this).balance) / payDenominator;

        vtoken.setTradingStatus(true); 
        stoken.setTradingStatus(true); 

        payable(devPayReceiver).transfer(payout10percent.mul(devPay)); 
        payable(mktMngrPayReceiver).transfer(payout10percent.mul(mktMngrPay)); 
        payable(webMngrPayReceiver).transfer(payout10percent.mul(webMngrPay)); 

        // After game Winner Buy/Sell Tax 6% LP 
        vtoken.setBuyFees(6, 0, 0, 0, 100);
        vtoken.setSellFees(6, 0, 0, 0, 100);

        // After game LOSER Buy/Sell Tax 25% LP  25% Marketing 49% VSPOT   --- you like losing huh!?
        stoken.setBuyFees(25, 0, 25, 49, 100);  
        stoken.setSellFees(25, 0, 25, 49, 100);


        //Initiate V Token Buyback     
        vtoken.triggerManualBuyback((address(this).balance).mul(99).div(100));
    }  

    function Winner_SSS() public onlyOwner {   

        //Dev team payout FIRST
        uint256 payout10percent = (address(this).balance) / payDenominator;

        vtoken.setTradingStatus(true); 
        stoken.setTradingStatus(true); 

        // After game Winner Buy/Sell Tax 6% LP  
        stoken.setBuyFees(6, 0, 0, 0, 100);
        stoken.setSellFees(6, 0, 0, 0, 100);

        // After game LOSER Buy/Sell Tax 25% LP  25% Marketing 49% VSPOT   --- you like losing huh!?
        vtoken.setBuyFees(25, 0, 25, 49, 100);
        vtoken.setSellFees(25, 0, 25, 49, 100);

        payable(devPayReceiver).transfer(payout10percent.mul(devPay)); 
        payable(mktMngrPayReceiver).transfer(payout10percent.mul(mktMngrPay)); 
        payable(webMngrPayReceiver).transfer(payout10percent.mul(webMngrPay));              

        //Initiate V Token Buyback
        stoken.triggerManualBuyback((address(this).balance).mul(99).div(100));
    }             

//////Battle over --  24 hours after end of game Tokens Paused and  LP WILL BE DRAINED to prepare for next BATTLE!!!

    function battleOver() public onlyOwner {
        stoken.setTradingStatus(false);
        vtoken.setTradingStatus(false);
    }

    //Set MaxTX equal to max wallet
    function _5_BigWallets() public onlyOwner {
        vtoken.setBuyTxLimitInPercent(700);  
        stoken.setBuyTxLimitInPercent(700);                  
    }

    function _4_setZeroBuyFees() public onlyOwner {
        stoken.setBuyFees(0, 0, 0, 0, 100);
        vtoken.setBuyFees(0, 0, 0, 0, 100);
    }

    function _3_setNormalFees() public onlyOwner {
        // Buy 15%
        vtoken.setBuyFees(3, 1, 3, 8, 100);
        stoken.setBuyFees(3, 1, 3, 8, 100);
        // Sell 18%
        stoken.setSellFees(4, 1, 3, 10, 100);
        vtoken.setSellFees(4, 1, 3, 10, 100);
    }

    
}