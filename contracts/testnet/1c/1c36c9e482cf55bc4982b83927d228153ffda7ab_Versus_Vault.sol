/**
 *Submitted for verification at BscScan.com on 2022-08-12
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
      

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event marketingWalletUpdated(address indexed newWallet, address indexed oldWallet);    
    event VSPotWalletUpdated(address indexed newWallet, address indexed oldWallet);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );
    event VSPotTriggered(uint256 amount);
    
    function owner() external  returns (address);
    function SetTradingStatus(bool) external;
    function removeLimits() external  returns (bool);
    function disableTransferDelay() external  returns (bool);
    function updateSwapTokensAtAmount(uint256 newAmount) external  returns (bool);
    function updateMaxAmount(uint256 newNum) external;
    function MaxTXs() external;
    function excludeFromMaxTransaction(address updAds, bool isEx) external;
    function updateSwapEnabled(bool enabled) external;
    function _2_ZEROBuyFees() external;
    function _3_NormalBuyFees() external;
    function updateBuyFees(uint256 _marketingFee, uint256 _liquidityFee, uint256 _VSPotFee) external;
    function updateSellFees(uint256 _marketingFee, uint256 _liquidityFee, uint256 _VSPotFee) external;
    function _4_NormalSellFees() external;
    function excludeFromFees(address account, bool excluded) external;
    function setAutomatedMarketMakerPair(address pair, bool value) external;
    function _setAutomatedMarketMakerPair(address pair, bool value) external; 
    function updateMarketingWallet(address newMarketingWallet) external;
    function updateVSPotWallet(address newWallet) external;
    function isExcludedFromFees(address account) external returns(bool);
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) external;
    function swapTokensForEth(uint256 tokenAmount) external;
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) external;
    function swapBack() external;
    function manualRetrieve() external;
    function manualDepositToVSPot(uint256 _amntInWei) external payable; 
    function weAreTheChampions() external;
    


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

    //Vault Status -- Paused between Versus Battles
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

    // set V and S token address
    function _1_setVersusTokens(address _vAddr, address _sAddr) public onlyOwner  {
       vtoken = IVSToken(_vAddr);
        stoken = IVSToken(_sAddr);
       
    }

    // 10% fee setup for DEV team leaving 1% for GAS

    uint256 public devPay = 40;             // 4%
    uint256 public mktMngrPay = 25;         // 2.5%
    uint256 public webMngrPay = 25;         // 2.5%
    uint256 public payDenominator = 1000;   // 100%

    // Switch Vault Live status
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

    //TOKEN TRADINGSTATUS 
    function _2_SetTradingStatus(bool _live) public onlyOwner {        
        stoken.SetTradingStatus(_live);
        vtoken.SetTradingStatus(_live);
    } 

//////WINNER - Initiate BUYBACKsss After game is over
    function Winner_VVV() public onlyOwner {     

        //Dev team payout
        uint256 payout10percent = (address(this).balance) / payDenominator;

        stoken.SetTradingStatus(true);
        vtoken.SetTradingStatus(true); 

        payable(devPayReceiver).transfer(payout10percent.mul(devPay)); 
        payable(mktMngrPayReceiver).transfer(payout10percent.mul(mktMngrPay)); 
        payable(webMngrPayReceiver).transfer(payout10percent.mul(webMngrPay)); 

        stoken.SetTradingStatus(true);
        vtoken.SetTradingStatus(true); 
        
        // After game Winner Buy/Sell Tax 5% LP  5% Marketing
        vtoken.updateBuyFees(5, 5, 0);
        vtoken.updateSellFees(5, 5, 0);

        // After game LOSER Buy/Sell Tax 25% LP  25% Marketing 49% VSPOT   --- you like losing huh!?
        stoken.updateBuyFees(25, 25, 49);
        stoken.updateSellFees(25, 25, 49);

        //Initiate V Token Buyback
        vtoken.weAreTheChampions();
    }  

    function Winner_SSS() public onlyOwner {   

        //Dev team payout FIRST
        uint256 payout10percent = (address(this).balance) / payDenominator;

        stoken.SetTradingStatus(true);
        vtoken.SetTradingStatus(true); 

        // After game Winner Buy/Sell Tax 5% LP  5% Marketing
        stoken.updateBuyFees(5, 5, 0);
        stoken.updateSellFees(5, 5, 0);

        // After game LOSER Buy/Sell Tax 25% LP  25% Marketing 49% VSPOT   --- you like losing huh!?
        vtoken.updateBuyFees(25, 25, 49);
        vtoken.updateSellFees(25, 25, 49);

        payable(devPayReceiver).transfer(payout10percent.mul(devPay)); 
        payable(mktMngrPayReceiver).transfer(payout10percent.mul(mktMngrPay)); 
        payable(webMngrPayReceiver).transfer(payout10percent.mul(webMngrPay));              

        //Initiate V Token Buyback
        stoken.weAreTheChampions();
    }             


//////Battle over --  24 hours after end of game Tokens Paused and  LP WILL BE DRAINED to prepare for next BATTLE!!!

    function battleOver() public onlyOwner {
        stoken.SetTradingStatus(false);
        vtoken.SetTradingStatus(false);
    }



    //Set MaxTX equal to max wallet
    function BigWallets() public view onlyOwner {
        vtoken.MaxTXs;  
        stoken.MaxTXs;                  
    }

    function ZEROBuyFees() public onlyOwner {
        vtoken._2_ZEROBuyFees();
        stoken._2_ZEROBuyFees();
    }

    function normalFees() public onlyOwner {
        // Buy 14%
        vtoken._4_NormalSellFees();
        stoken._4_NormalSellFees();
        // Sell 16%
        vtoken._3_NormalBuyFees();
        stoken._3_NormalBuyFees();
    }

    function setFees(uint256 _market, uint256 _liquidity, uint256 _VSPot) public onlyOwner {        
        stoken.updateBuyFees(_market, _liquidity, _VSPot);
        stoken.updateSellFees(_market, _liquidity, _VSPot);
        vtoken.updateBuyFees(_market, _liquidity, _VSPot);
        vtoken.updateSellFees(_market, _liquidity, _VSPot);
    }    




    
}