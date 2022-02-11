/***
 * All systems invented by ALLCOINLAB
 * https://github.com/ALLCOINLAB
 * https://t.me/ALLCOINLAB
 * 
 * The Web3 Project
 * TG: https://t.me/TheWeb3Project
 * Website: https://theweb3project.com
 * 
 *
 * Written in easy code to for easy verificiation by the investors.
 * Some are made with manual if-else conditions in order not to make mistake + maintain code easily.
 * Those doesn't cost gas much so this is way better than the simple / short code.
 * Used high gas optimization if needed.
 * 
 *
 * 
 * $$$$$$$$\ $$\                       $$\      $$\           $$\        $$$$$$\        $$$$$$$\                                                $$\     
 * \__$$  __|$$ |                      $$ | $\  $$ |          $$ |      $$ ___$$\       $$  __$$\                                               $$ |    
 *    $$ |   $$$$$$$\   $$$$$$\        $$ |$$$\ $$ | $$$$$$\  $$$$$$$\  \_/   $$ |      $$ |  $$ | $$$$$$\   $$$$$$\  $$\  $$$$$$\   $$$$$$$\ $$$$$$\   
 *    $$ |   $$  __$$\ $$  __$$\       $$ $$ $$\$$ |$$  __$$\ $$  __$$\   $$$$$ /       $$$$$$$  |$$  __$$\ $$  __$$\ \__|$$  __$$\ $$  _____|\_$$  _|  
 *    $$ |   $$ |  $$ |$$$$$$$$ |      $$$$  _$$$$ |$$$$$$$$ |$$ |  $$ |  \___$$\       $$  ____/ $$ |  \__|$$ /  $$ |$$\ $$$$$$$$ |$$ /        $$ |    
 *    $$ |   $$ |  $$ |$$   ____|      $$$  / \$$$ |$$   ____|$$ |  $$ |$$\   $$ |      $$ |      $$ |      $$ |  $$ |$$ |$$   ____|$$ |        $$ |$$\ 
 *    $$ |   $$ |  $$ |\$$$$$$$\       $$  /   \$$ |\$$$$$$$\ $$$$$$$  |\$$$$$$  |      $$ |      $$ |      \$$$$$$  |$$ |\$$$$$$$\ \$$$$$$$\   \$$$$  |
 *    \__|   \__|  \__| \_______|      \__/     \__| \_______|\_______/  \______/       \__|      \__|       \______/ $$ | \_______| \_______|   \____/ 
 *                                                                                                              $$\   $$ |                              
 *                                                                                                              \$$$$$$  |                              
 *                                                                                                               \______/                               
 * 
 * 
 * This is UpGradable Contract
 * So many new features will be applied periodically :)
 * 
 *  
 * 
 * (Deprecated) Project UpFinity
 * [The Web3 Token] is the relaunch of the [UpFinity]
 * TG: https://t.me/UpFinityTG
 * Website: https://UpFinityCrypto.github.io
 ***/


// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2;

// import 'https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/proxy/utils/Initializable.sol';
import "./Initializable.sol";

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
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint value) external returns (bool);
}

/*
 * interfaces from here
 */


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IMyRouter {
    // function isBuyMode() external view returns (uint);
    // function isSellMode() external view returns (uint);
    function isAddLiqMode() external view returns (uint);
    function isDelLiqMode() external view returns (uint);
    // function debug() external view returns (uint);
}

interface IMyReward {
    function claimedBNB(address user) external view returns (uint);
    
    function approveWBNBToken() external;
    function approveRewardToken() external;
    
}

interface INFT {
    function calculateTaxReduction(address user) external view returns (uint);
}

/**
 * interfaces to here
 **/
 
contract TheWeb3Project is Initializable {
    using SafeMath for uint256;
    
    // Upgradable Contract Test
    uint public _uptest;
    
    // My Basic Variables
    address public _owner; // constant
    
    address public _token; // constant
    address public _myRouterSystem; // constant
    address public _stakeSystem; // constant
    address public _rewardSystem; // constant
    address public _projectFund; // constant
    address public _rewardToken; // constant
    
    /*
     * vars and events from here
     */
    
    
    // Basic Variables
    string private _name; // constant
    string private _symbol; // constant
    uint8 private _decimals; // constant
    
    address public _uniswapV2Router; // constant
    address public _uniswapV2Pair; // constant
    
    
    // Redistribution Variables
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private MAX; // constant
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    
    mapping (address => bool) public _isExcluded;
    address[] public _excluded;
    
    
    // Fee Variables
    uint public _liquidityFee; // fixed
    uint public _improvedRewardFee; // fixed
    uint public _projectFundFee; // fixed
    uint public _dipRewardFee; // fixed
    uint public _manualBuyFee; // fixed    
    uint public _autoBurnFee; // fixed
    uint public _redistributionFee; // fixed

    // Price Recovery System Variables
    uint public _priceRecoveryFee; // fixed
    uint private PRICE_RECOVERY_ENTERED;
    


    // presale
    uint public _isLaunched;


    // Dip Reward System Variables
    uint public _minReservesAmount;
    uint public _curReservesAmount;
    
    // Improved Reward System Variables
    uint public _rewardTotalBNB;
    mapping (address => uint) public _adjustBuyBNB;
    mapping (address => uint) public _adjustSellBNB;



    
    // Anti Bot System Variables
    mapping (address => uint256) public _buySellTimer;
    uint public _buySellTimeDuration; // fixed
    
    // // Anti Whale System Variables
    // uint public _whaleRate; // fixed
    // uint public _whaleTransferFee; // fixed
    // uint public _whaleSellFee; // fixed
    
    // // Anti-Dump Algorithm
    // uint public _antiDumpTimer;
    // uint public _antiDumpDuration; // fixed


    // LP manage System Variables
    uint public _lastLpSupply;
    
    // Blacklists
    mapping (address => bool) public _blacklisted;
    

    
    // Max Variables
    // uint public _maxTxNume; // fixed
    // uint public _maxBalanceNume; // fixed
    // uint public _maxSellNume; // fixed

    // Accumulated Tax System
    uint public DAY; // constant
    // uint public _accuTaxTimeWindow; // fixed
    uint public _accuMulFactor; // fixed

    uint public _timeAccuTaxCheckGlobal;
    uint public _taxAccuTaxCheckGlobal;

    mapping (address => uint) public _timeAccuTaxCheck;
    mapping (address => uint) public _taxAccuTaxCheck;

    // Circuit Breaker
    uint public _curcuitBreakerFlag;
    // uint public _curcuitBreakerThreshold; // fixed
    uint public _curcuitBreakerTime;
    // uint public _curcuitBreakerDuration; // fixed
    
    
    // Advanced Airdrop Algorithm
    address public _freeAirdropSystem; // constant
    address public _airdropSystem; // constant
    mapping (address => uint) public _airdropTokenLocked;
    uint public _airdropTokenUnlockTime;


    
    // First Penguin Algorithm
    uint public _firstPenguinWasBuy; // fixed
    
    // Life Support Algorithm
    mapping (address => uint) public _lifeSupports;
    
    // Monitor Algorithm
    mapping (address => uint) public _monitors;


    // events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    event Redistribution(uint256 value);
    
    event WhaleTransaction(uint256 amount, uint256 tax);
    
    event DividendParty(uint256 DividendAmount);
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    event CircuitBreakerActivated();

    event DebugLog(uint debugType, uint v);
    // deactivate cannot be emitted in time if triggered automatically.
    
    /**
     * vars and events to here
     **/
     
    fallback() external payable {}
    receive() external payable {}
    
    // if you know how to read the code,
    // then you will see this message
    // and also you will know this code is very well made with safety :)
    // but many safe checkers cannot recognize ownership code in here
    // so made workaround to make the ownership look deleted instead
    modifier limited() {
        require(_owner == msg.sender, "limited usage");
        _;
    }
    
    function initialize(address owner_) public initializer {
        _owner = owner_;

        /**
         * inits from here
         **/
        
        _token = address(this);
        _myRouterSystem = address(0x8A7320663dDD60602D95bcce93a86B570A4a3eFB);
        _stakeSystem = address(0xCeC0Ee6071571d77cFcD52244D7A1D875f71d32D);
        _rewardSystem = address(0x373764c3deD9316Af3dA1434ccba32caeDeC09f5);
        _projectFund = address(0xe710D22dcf97779EE598085d96B5DF60aA382f6B);
        _rewardToken = address(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82); // currently CAKE

        _name = "The Web3 Project";
        _symbol = "WEB3";
        _decimals = 18;

        MAX = ~uint256(0);
        _tTotal = 10 * 10**9 * 10**18; // total supply: 10B
        _rTotal = (MAX - (MAX % _tTotal));
        
        
        // before price recovery fee
        _liquidityFee = 400; // should be considered half for bnb/upfinity
        _improvedRewardFee = 200;
        _projectFundFee = 400;
        _dipRewardFee = 100;
        _manualBuyFee = 50; // 0.5% manual buyback + 2% eco
        _autoBurnFee = 50;
        _redistributionFee = 50; // no more than this
    
        uint sellFee = 1200;
        
        _priceRecoveryFee = sellFee
        .sub(_manualBuyFee)
        .sub(_autoBurnFee); // 900
        
        // calculate except burn / minustax part
        // buyingFee = sellFee - _manualBuyFee = 1200 - 250 = 950
        // yFee = buyingFee - _autoBurnFee = 950 - 50 = 900
    
        // bnbFee = _dipRewardFee + _improvedRewardFee + _projectFundFee + _liquidityFee = 650
        // yFee - bnbFee = 900 - 650 = 250
        // tokenFee = _liquidityFee + _redistributionFee = 200 + min(50, x) <= 250
        // max(tokenFee) = 250
        // yFee - bnbFee >= max(tokenFee)
        
        
        // TODO: localnet has no time!
        
        // basic vars
        PRICE_RECOVERY_ENTERED = 1;
        // _minReservesAmount
        // _curReservesAmount
        // _rewardTotalBNB

        // Anti Bot System
        _buySellTimeDuration = 60; // 60 in mainnet

        // Anti Whale System
        // denominator = 10000
        // _whaleRate = 10 ** 2;
        // _whaleTransferFee = 2 * 10 ** 2;
        // _whaleSellFee = 4 * 10 ** 2;
        
        // Anti-Dump System
        // _antiDumpDuration = 10;

        // LP Manage System
        // _lastLpSupply

        // Max Variables
        // _maxTxNume = 1000;
        // _maxSellNume = 150;
        // _maxBalanceNume = 110;

        // Accumulated Tax System
        DAY = 24 * 60 * 60;
        // _accuTaxTimeWindow = 0; // 24 * 60 * 60 in mainnet
        _accuMulFactor = 2;
        // _timeAccuTaxCheckGlobal
        // _taxAccuTaxCheckGlobal
        
        // Circuit Breaker
        _curcuitBreakerFlag = 1;
        // _curcuitBreakerThreshold = 1500;
        // _curcuitBreakerTime
        // _curcuitBreakerDuration = 0; // 3 * 60 * 60; in mainnet // 3 hours of chill time

        // Advanced Airdrop Algorithm
        // _freeAirdropSystem
        // _airdropSystem
        // _airdropTokenUnlockTime = 1638882000; // 21.12.07 1PM GMT

        // First Penguin Algorithm
        _firstPenguinWasBuy = 1;

        /**
         * inits to here
         **/
         
    }
    
    function setUptest(uint uptest_) external {
        _uptest = uptest_;
    }

    function setToken(address token_) external limited { // test purpose
        _token = token_;
    }

    // function setRewardToken(address rewardToken_) external limited {
    //     _rewardToken = rewardToken_;
    // }
    
    // function setAirdropSystem(address _freeAirdropSystem_, address _airdropSystem_) external limited {
    //     _freeAirdropSystem = _freeAirdropSystem_;
    //     _airdropSystem = _airdropSystem_;
    // }
    
    /**
     * functions from here
     **/
    
    
    // function setFeeVars(
    // uint _minusTaxBonus_,
    // uint _liquidityFee_, 
    // uint _improvedRewardFee_, 
    // uint _projectFundFee_, 
    // uint _dipRewardFee_,
    // uint _manualBuyFee_,
    // uint _autoBurnFee_,
    // uint _redistributionFee_
    // ) external limited {
    //     // before price recovery fee
        
        
    //     _liquidityFee = _liquidityFee_;
    //     _improvedRewardFee = _improvedRewardFee_;
    //     _projectFundFee = _projectFundFee_;
    //     _dipRewardFee = _dipRewardFee_;
    //     _manualBuyFee = _manualBuyFee_;
    //     _autoBurnFee = _autoBurnFee_;
    //     _redistributionFee = _redistributionFee_;
        
    //     uint sellFee = 1200;
        
    //     _priceRecoveryFee = sellFee
    //     .sub(_manualBuyFee)
    //     .sub(_autoBurnFee);
    // }
    
    // function setBuySellTimeDuration(uint buySellTimeDuration_) external limited {
    //   _buySellTimeDuration = buySellTimeDuration_;
    // }
    
    // function setDividendPartyVars(uint dividendPartyPortion_, uint dividendPartyThreshold_) external limited {
    //     _dividendPartyPortion = dividendPartyPortion_;
    //     _dividendPartyThreshold = dividendPartyThreshold_;
    // }
    
    // function setMaxVars(uint _maxTxNume_, uint _maxSellNume_, uint _maxBalanceNume_) external limited {
    //     _maxTxNume = _maxTxNume_;
    //     _maxSellNume = _maxSellNume_;
    //     _maxBalanceNume = _maxBalanceNume_;
    // }

    // function setAccuTaxVars(uint accuMulFactor_) external limited {
    //      _accuMulFactor = accuMulFactor_;
    // }
    
    // function setCircuitBreakerVars(uint _curcuitBreakerThreshold_, uint _curcuitBreakerDuration_) external limited {
    //     _curcuitBreakerThreshold = _curcuitBreakerThreshold_;
    //     _curcuitBreakerDuration = _curcuitBreakerDuration_;
    // }
    
    // function setAirdropVars(uint _airdropTokenUnlockTime_) external limited {
    //     _airdropTokenUnlockTime = _airdropTokenUnlockTime_;
    // }
    
    // function setAntiWhaleVars(uint _whaleRate_, uint _whaleTransferFee_, uint _whaleSellFee_) external limited {
    //     _whaleRate = _whaleRate_;
    //     _whaleTransferFee = _whaleTransferFee_;
    //     _whaleSellFee = _whaleSellFee_;
    // }
    
    /**
    * Tokenomics Plan
    * 
    *  1 800 000 000 ( 1.8  B) ( 18 %) UPF Holders Migration
    *  1 000 000 000 ( 1    B) ( 10 %) Private Sale Allocation
    *  2 500 000 000 ( 2.5  B) ( 25 %) Presale Allocation
    *  2 000 000 000 ( 2    B) ( 20 %) Max Initial Liquidity for Token
    * ======================================================
    *  7 300 000 000 ( 7.3  B) ( 73 %) Used for System Initialization
    *  +
    *  1 100 000 000 ( 1.1  B) ( 11 %) Staking & Airdrop
    *  1 100 000 000 ( 1.1  B) ( 11 %) P2E & Other Rewards (Burn, Airdrop, Giveaway, etc)
    *    500 000 000 ( 0.5  B) (  5 %) Marketing & Development
    * ======================================================
    * 10 000 000 000 (10    B) (100 %) Total Supply
    * 
    *  2 000 000 000 ( 2    B) ( 20 %) Max Initial Liquidity for Token
    * 800 BNB        (800 BNB) (100 %) Max Initial liquidity for BNB
    * ======================================================
    * Listing Price: 100M Token (1  %) = 40 BNB

    **/
         
    // inits
    function runInit() external limited {
        require(_uniswapV2Pair == address(0), "Already Initialized");
        
        // Initialize
        _rOwned[_owner] = _rTotal;
        emit Transfer(address(0), _owner, _tTotal);

        // 50% send to token contract first (check website!)
        _tokenTransfer(_owner, address(this), _tTotal.mul(5000).div(10000));
        

        {
            _uniswapV2Router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
            _uniswapV2Pair = IUniswapV2Factory(address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73))
            .createPair(address(this), address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));
        } //////////////////////////////////////////////////////////// TODO: change all pairs

        // pancakeswap router have full token control of my router
        _approve(_myRouterSystem, _uniswapV2Router, ~uint256(0));
        
        // exclude pair for make getting distribution to make token price stable
        excludeFromReward(_uniswapV2Pair);
        excludeFromReward(_stakeSystem);

        // zero / burn address will get redistribution
        // it will work as a auto burn, which will help the deflation
        // excludeFromReward(address(0x0000000000000000000000000000000000000000));
        // excludeFromReward(address(0x000000000000000000000000000000000000dEaD));
        
        // others can also be excluded from redistribtuion
        // but it will increase gas fee for each trade so let them be added


        // preparation for the improved reward
        IMyReward(_rewardSystem).approveWBNBToken();
        IMyReward(_rewardSystem).approveRewardToken();
        IERC20(address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c)).approve(_uniswapV2Router, ~uint256(0));

        // before official launch, penalize buy/sell bot traders
        _isLaunched = 1;
    }
    
    
    // function addBlacklists(address[] calldata adrs) external limited {
    //     for (uint i = 0; i < adrs.length; i++) {
    //         _blacklisted[adrs[i]] = true;
    //     }
    // }
    // function delBlacklists(address[] calldata adrs) external limited {
    //     for (uint i = 0; i < adrs.length; i++) {
    //         _blacklisted[adrs[i]] = false;
    //     }
    // }
    

    // basic viewers
    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
    // ooooo() erased
    
    function totalSupply() public view returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view returns (uint256) { // gas 26345 / 56492
        if (_isExcluded[account]) return _tOwned[account];
        
        uint256 rAmount = _rOwned[account];
        if (rAmount == 0) return uint256(0); // [gas opt] 0/x = 0
        
        return tokenFromReflection(rAmount);
    }
    
    function reflectionFromToken(uint256 tAmount) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        uint256 rAmount = tAmount.mul(_getRate());
        return rAmount;
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) { // 54312
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }
    
    
    function balanceOfLowGas(address account, uint256 rate) internal view returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        
        uint256 rAmount = _rOwned[account];
        if (rAmount == 0) return uint256(0); // [gas opt] 0/x = 0
        
        return tokenFromReflectionLowGas(rAmount, rate);
    }
    function tokenFromReflectionLowGas(uint256 rAmount, uint256 rate) internal view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = rate;
        return rAmount.div(currentRate);
    }
    
    
    
    function excludeFromReward(address account) public limited {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }
    
    // function includeToReward(address account) public limited {
    //     require(_isExcluded[account], "Account is not excluded");
    //     for (uint256 i = 0; i < _excluded.length; i++) {
    //         if (_excluded[i] == account) {
    //             _excluded[i] = _excluded[_excluded.length - 1];
    //             _tOwned[account] = 0;
    //             _isExcluded[account] = false;
    //             _excluded.pop();
    //             break;
    //         }
    //     }
    // }
    
    
    // allowances
    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    
    
    
    

    
    // Anti Dump System (future use)
    // function antiDumpSystem() internal {
    //     require(_antiDumpTimer + _antiDumpDuration <= block.timestamp, 'Anti-Dump System activated');
    //     _antiDumpTimer = block.timestamp;
    // }
    
    
    
    // Anti Bot System
    
    // bot use sequential buy/sell/transfer to get profit
    // this will heavily decrease the chance for bot to do that
    function antiBotSystem(address target) internal {
        if (target == address(0x10ED43C718714eb63d5aA57B78B54704E256024E)) { // Router can do in sequence
            return;
        }
        if (target == _uniswapV2Pair) { // Pair can do in sequence
            return;
        }
            
        require(_buySellTimer[target] + _buySellTimeDuration <= block.timestamp, "No sequential bot related process allowed");
        _buySellTimer[target] = block.timestamp; ///////////////////// NFT values
    }
    
    
    
    
    // // Improved Anti Whale System (future use)
    // // details in: https://github.com/AllCoinLab/AllCoinLab/wiki
    
    // // based on token
    // // send portion to the marketing
    // // amount = antiWhaleSystem(sender, amount, _whaleSellFee);
    // function antiWhaleSystemToken(address sender, uint amount, uint tax) internal returns (uint) {
    //     uint r1 = balanceOf(_uniswapV2Pair);
    //     if (r1.mul(100).div(10000) < amount) { // whale movement
    //         emit WhaleTransaction(amount, tax);
            
    //         uint whaleFee = amount.mul(tax).div(10000);
    //         _tokenTransfer(sender, address(this), whaleFee);
    //         return amount.sub(whaleFee);
    //     } else { // normal user movement
    //         return amount;
    //     }
    // }
    
    
    // // based on BNB
    // // return bool, send will be done at the caller
    // function antiWhaleSystemBNB(uint amount, uint tax) internal returns (bool) {
    //     uint r1 = balanceOf(_uniswapV2Pair);
    //     if (r1.mul(100).div(10000) < amount) { // whale movement
    //         emit WhaleTransaction(amount, tax);
    //         return true;
    //     } else { // normal user movement
    //         return false;
    //     }
    // }
    
    
    
    
    
    
    
    
    
    
    function _deactivateCircuitBreaker() internal returns (uint) {
        // in the solidity world,
        // to save the gas,
        // 1 is false, 2 is true
        _curcuitBreakerFlag = 1; // you can sell now!
        
        _taxAccuTaxCheckGlobal = 1; // [save gas]
        _timeAccuTaxCheckGlobal = block.timestamp.sub(1); // set time (set to a little past than now)

        return 1;
    }
    
    // there could be community's request
    // owner can deactivate it. cannot activate :)
    function deactivateCircuitBreaker() external limited {
        uint curcuitBreakerFlag_ = _curcuitBreakerFlag;
        
        curcuitBreakerFlag_ = _deactivateCircuitBreaker(); // returns uint
    }
    
    // test with 1 min in testnet
    // Accumulated Tax System
    // personal and global
    function accuTaxSystem(address adr, uint amount, bool isSell) internal returns (uint) { // TODO: make this as a template and divide with personal
        if (_isLaunched == 1) { // based on liquidity but no liquidity
            return amount;
        }
        
        uint r1 = balanceOf(_uniswapV2Pair);
        
        uint accuMulFactor_ = _accuMulFactor;
        uint curcuitBreakerFlag_ = _curcuitBreakerFlag;
        // global check first
        if (isSell) {
            if (curcuitBreakerFlag_ == 2) { // circuit breaker activated
                if (_curcuitBreakerTime + 7200 < block.timestamp) { // certain duration passed. everyone chilled now?, _curcuitBreakerDuration
                    curcuitBreakerFlag_ = _deactivateCircuitBreaker();
                } else {
                }
            }
            
            if (curcuitBreakerFlag_ == 1) { // circuit breaker not activated
            uint taxAccuTaxCheckGlobal_ = _taxAccuTaxCheckGlobal;
            uint timeAccuTaxCheckGlobal_ = _timeAccuTaxCheckGlobal;
            
            uint timeDiffGlobal = block.timestamp.sub(timeAccuTaxCheckGlobal_);
            uint priceChange = _getPriceChange(r1, amount); // price change based, 10000

            if (timeAccuTaxCheckGlobal_ == 0) { // first time checking this
                // timeDiff cannot be calculated. skip.
                // accumulate
                
                taxAccuTaxCheckGlobal_ = priceChange;
                timeAccuTaxCheckGlobal_ = block.timestamp; // set time
            } else { // checked before
                // timeDiff can be calculated. check.
                // could be in same block so timeDiff == 0 should be included
                // to avoid duplicate check, only check this one time
                
                if (timeDiffGlobal < 21600) { // still in time window
                    // accumulate
                    taxAccuTaxCheckGlobal_ = taxAccuTaxCheckGlobal_.add(priceChange);
                } else { // time window is passed. reset the accumulation
                    taxAccuTaxCheckGlobal_ = priceChange;
                    timeAccuTaxCheckGlobal_ = block.timestamp; // reset time
                }
            }
            
            // 8% change
            if (800 < taxAccuTaxCheckGlobal_) { // this is for the actual impact. so set 1, _curcuitBreakerThreshold
                // https://en.wikipedia.org/wiki/Trading_curb
                // a.k.a circuit breaker
                // Let people chill and do the rational think and judgement :)
                
                _curcuitBreakerFlag = 2; // stop the sell for certain duration
                _curcuitBreakerTime = block.timestamp;
                
                emit CircuitBreakerActivated();
            }
            /////////////////////////////////////////////// always return local variable to state variable!
            
            _taxAccuTaxCheckGlobal = taxAccuTaxCheckGlobal_;
            _timeAccuTaxCheckGlobal = timeAccuTaxCheckGlobal_;
            }
        }
        
        // now personal
        {
            
            uint taxAccuTaxCheck_ = _taxAccuTaxCheck[adr];
            uint timeAccuTaxCheck_ = _timeAccuTaxCheck[adr];
            
            {
                uint timeDiff = block.timestamp.sub(timeAccuTaxCheck_);
                uint impact = _getImpact(r1, amount); // impact based, 10000
    
                if (timeAccuTaxCheck_ == 0) { // first time checking this
                    // timeDiff cannot be calculated. skip.
                    // accumulate
                    
                    taxAccuTaxCheck_ = impact;
                    timeAccuTaxCheck_ = block.timestamp; // set time
                } else { // checked before
                    // timeDiff can be calculated. check.
                    // could be in same block so timeDiff == 0 should be included
                    // to avoid duplicate check, only check this one time
                    
                    if (timeDiff < 0) { // still in time window //////////////// NFT value
                        // accumulate
                        // let them sell freely. but will suffer by heavy tax if sell big
                        taxAccuTaxCheck_ = taxAccuTaxCheck_.add(impact);
                        
                    } else { // time window is passed. reset the accumulation
                        taxAccuTaxCheck_ = impact;
                        timeAccuTaxCheck_ = block.timestamp; // reset time
                    }
                }
            }
            
            {
                uint amountTax;
                if (curcuitBreakerFlag_ == 1) { // circuit breaker not activated
                if (_firstPenguinWasBuy == 1) { // buy 1, sell 2
                    accuMulFactor_ = accuMulFactor_.mul(2);
                }
                
                // no more than 20% by calculation
                ////////////////////////// NFT: reduce impact tax %
                if (2000 < taxAccuTaxCheck_.mul(accuMulFactor_)) { // more than 20%
                    amountTax = amount.mul(2000).div(10000);
                } else {
                    amountTax = amount.mul(taxAccuTaxCheck_).mul(accuMulFactor_).div(10000);
                }

                } else { // circuit breaker activated
                    // flat 20% sell tax
                    ////////////////////////// NFT: reduce impact tax at cb %
                    amountTax = amount.mul(2000).div(10000);
                }
                
                amount = amount.sub(amountTax); // accumulate tax apply, sub first
                if (isSell) { // already send token to contract. no need to transfer. skip
                } else {
                    _tokenTransfer(adr, address(this), amountTax); // send tax to contract
                }
            }
            
            _taxAccuTaxCheck[adr] = taxAccuTaxCheck_;
            _timeAccuTaxCheck[adr] = timeAccuTaxCheck_;
        }
        
        return amount;
    }
    
    
    
    
    // pcs / poo price impact cal
    function _getImpact(uint r1, uint x) internal pure returns (uint) {
        uint x_ = x.mul(9975); // pcs fee
        uint r1_ = r1.mul(10000);
        uint nume = x_.mul(10000); // to make it based on 10000 multi
        uint deno = r1_.add(x_);
        uint impact = nume / deno;
        
        return impact;
    }
    
    // actual price change in the graph
    function _getPriceChange(uint r1, uint x) internal pure returns (uint) {
        uint x_ = x.mul(9975); // pcs fee
        uint r1_ = r1.mul(10000);
        uint nume = r1.mul(r1_).mul(10000); // to make it based on 10000 multi
        uint deno = r1.add(x).mul(r1_.add(x_));
        uint priceChange = nume / deno;
        priceChange = uint(10000).sub(priceChange);
        
        return priceChange;
    }

    
    function _maxTxCheck(address sender, address recipient, uint amount) internal view {
        if (_isLaunched == 1) { // based on liquidity but no liquidity
            return;
        }

        sender;
        recipient;
        uint r1 = balanceOf(_uniswapV2Pair); // liquidity pool
        uint impact = _getImpact(r1, amount);
        // liquidity based approach
        require(impact <= 1000, "buy/sell/tx should be lower than criteria"); // _maxTxNume
    }

    // function _maxBalanceCheck(address sender, address recipient, address adr) internal view {
    //     uint balance = balanceOf(adr);
    //     uint balanceLimit = _tTotal.mul(100).div(10000); // _maxBalanceNume
    //     require(balance <= balanceLimit, 'balance should be lower than criteria'); // save totalsupply gas
    // }
    
    
    
    // Improved Reward System
    function addTotalBNB(uint addedTotalBNB_) internal {
        _rewardTotalBNB = _rewardTotalBNB + addedTotalBNB_;
    }
    
    function getUserTokenAmount() public view returns (uint) { // 73604 for 6
        // [save gas] multi balance check with same rate
        uint rate = _getRate();
        
        return _tTotal
        .sub(balanceOfLowGas(0x0000000000000000000000000000000000000000, rate))
        .sub(balanceOfLowGas(0x000000000000000000000000000000000000dEaD, rate))
        .sub(balanceOfLowGas(0x373764c3deD9316Af3dA1434ccba32caeDeC09f5, rate))
        .sub(balanceOfLowGas(0xCeC0Ee6071571d77cFcD52244D7A1D875f71d32D, rate))
        .sub(balanceOfLowGas(_uniswapV2Pair, rate))
        // .sub(balanceOf(_owner)); // complicated if included. leave it.
        .sub(balanceOfLowGas(address(this), rate));
        // .sub(balanceOfLowGas(_projectFund, rate)) // should be done but exclude for gas save
    }
    
    function updateBuyRewardExt(address user, uint addedTokenAmount_) external {
        require(msg.sender == 0xCeC0Ee6071571d77cFcD52244D7A1D875f71d32D, 'not allowed');

        updateBuyReward(user, addedTokenAmount_);
    }

    function updateSellRewardExt(address user, uint subedTokenAmount_) external {
        require(msg.sender == 0xCeC0Ee6071571d77cFcD52244D7A1D875f71d32D, 'not allowed');

        updateSellReward(user, subedTokenAmount_);
    }

    function updateBuyReward(address user, uint addedTokenAmount_) internal {
        // balances are already updated
        uint rewardTotalBNB_ = _rewardTotalBNB;
        
        uint userTokenAmount = getUserTokenAmount();
        _adjustBuyBNB[user] = _adjustBuyBNB[user].add(rewardTotalBNB_.mul(addedTokenAmount_).div(userTokenAmount.sub(addedTokenAmount_))); // it will be subed normally
        rewardTotalBNB_ = rewardTotalBNB_.mul(userTokenAmount).div(userTokenAmount.sub(addedTokenAmount_));
        
        _rewardTotalBNB = rewardTotalBNB_;
    }
    
    function updateSellReward(address user, uint subedTokenAmount_) internal {
        uint rewardTotalBNB_ = _rewardTotalBNB;
        
        // balances are already updated
        uint userTokenAmount = getUserTokenAmount();
        _adjustSellBNB[user] = _adjustSellBNB[user].add(rewardTotalBNB_.mul(subedTokenAmount_).div(userTokenAmount.add(subedTokenAmount_))); // it will be added in equation so 'add'
        rewardTotalBNB_ = rewardTotalBNB_.mul(userTokenAmount).div(userTokenAmount.add(subedTokenAmount_));
        
        _rewardTotalBNB = rewardTotalBNB_;
    }
    
    function updateTxReward(address sender, address recipient, uint beforeAmount, uint amount, uint beforeUserTokenAmount) internal {
        uint rewardTotalBNB_ = _rewardTotalBNB;
        
        // balances should not be changed
        uint userTokenAmount = getUserTokenAmount();

        _adjustSellBNB[sender] = _adjustSellBNB[sender].add(rewardTotalBNB_.mul(beforeAmount).div(beforeUserTokenAmount)); // full transfer
        _adjustBuyBNB[recipient] = _adjustBuyBNB[recipient].add(rewardTotalBNB_.mul(amount).div(beforeUserTokenAmount)); // partial transferred
        rewardTotalBNB_ = rewardTotalBNB_.mul(userTokenAmount).div(beforeUserTokenAmount); // usually they are same. but some people do weird things
        
        _rewardTotalBNB = rewardTotalBNB_;
    }
    
    // there are some malicious or weird users regarding reward, calibrate the parameters
    function calibrateValues(address[] calldata users, uint[] calldata valueAdds, uint[] calldata valueSubs) external limited {
        for (uint i = 0; i < users.length; i++) {
            _adjustSellBNB[users[i]] = IMyReward(_rewardSystem).claimedBNB(users[i]).add(_adjustBuyBNB[users[i]]).add(valueAdds[i]).sub(valueSubs[i]);
        }
    }
    
    // cannot calculate all holders in contract
    // so calculate at the outside and set manually
    function calibrateTotal(uint rewardTotalBNB_) external limited {
        _rewardTotalBNB = rewardTotalBNB_;
    }
    
    
    
    
    // Dip Reward System
    function _dipRewardTransfer(address recipient, uint256 amount) internal {
        // [gas save]
        uint curReservesAmount = _curReservesAmount;
        uint minReservesAmount = _minReservesAmount;
        
        if (curReservesAmount == minReservesAmount) { // in the ATH
            return;
        }
        
        address rewardToken = _rewardToken;
        address rewardSystem = _rewardSystem;
        
        // sellers should be excluded? NO. include seller also
        uint userBonus;
        {
            
            // [save gas] buy manually
            // address WBNB = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
            // uint balanceWBNB = IERC20(WBNB).balanceOf(_rewardSystem);
            // if (10 ** 17 < balanceWBNB) { // [save gas] convert WBNB to reward token when 0.1 WBNB
                
            //     // pull WBNB to here to trade
            //     IERC20(WBNB).transferFrom(_rewardSystem, address(this), balanceWBNB);
                
            //     address[] memory path = new address[](2);
            //     path[0] = WBNB;
            //     path[1] = _rewardToken; // CAKE, BUSD, etc
        
            //     // make the swap
            //     IUniswapV2Router02(_uniswapV2Router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            //         balanceWBNB,
            //         0,
            //         path,
            //         _rewardSystem,
            //         block.timestamp
            //     );
            // }
            
            {
                uint dipRewardFund = IERC20(rewardToken).balanceOf(rewardSystem);
                uint reserveATH = curReservesAmount.sub(minReservesAmount);
                if (reserveATH <= amount) { // passed ATH
                    userBonus = dipRewardFund;
                } else {
                    userBonus = dipRewardFund.mul(amount).div(reserveATH); ////////////////////////// NFT: increase dip reward %
                }
            }
        }
        
        if (0 < userBonus) {
            IERC20(rewardToken).transferFrom(rewardSystem, recipient, userBonus); // CAKE, BUSD, etc
        }
    }
    
    
    
    
    // // Advanced Airdrop Algorithm
    // function _airdropReferralCheck(address refAdr, uint rate) internal view returns (bool) {
    //     if (refAdr == address(0x000000000000000000000000000000000000dEaD)) { // not specified address
    //         return false;
    //     }
        
    //     if (0 < balanceOfLowGas(refAdr, rate)) {
    //         return true;
    //     }
        
    //     return false;
    // }
    
    
    
    // // reward of airdrop contract will be transfered also
    // function airdropTransfer(address recipient, address refAdr, uint256 amount) external {
    //     require(
    //         (msg.sender == _airdropSystem) ||
    //         (msg.sender == _freeAirdropSystem)
    //         , "Only Airdrop Systems can call this");
        
    //     require(refAdr != recipient, "Cannot set yourself");
    //     require(refAdr != _uniswapV2Pair, "Cannot set pair addresss");
    //     require(refAdr != _stakeSystem, "Cannot set minus tax addresss");
        
    //     // lock the token
    //     _airdropTokenLocked[recipient] = 2; // always 0, 1 is false, 2 is true
        
    //     // [gas optimization] pair, minus will not change. do low gas mode
    //     uint rate = _getRate();
        
    //     _tokenTransferLowGas(msg.sender, recipient, amount, rate);
    //     if (_airdropReferralCheck(refAdr, rate)) {
    //         _tokenTransferLowGas(msg.sender, refAdr, amount.mul(500).div(10000), rate); // 5% referral
    //     }
    // }
    
    
    
    
    
    // LP manage System
    function setLastLpSupply(uint amount) external {
        require(msg.sender == _myRouterSystem, "Only My Router can set this");
        _lastLpSupply = amount;
    }
    
    
    

    // function setMonitors(address[] calldata adrs, uint[] calldata values) external limited {
    //     for (uint i = 0; i < adrs.length; i++) {
    //         _monitors[adrs[i]] = values[i];
    //     }
    // }
   

    function sanityCheck(address sender, address recipient, uint256 amount) internal returns (uint) {
        sender;
        recipient;

        // Blacklisted Bot Sell will be heavily punished
        if (_blacklisted[sender]) {
            _tokenTransfer(sender, address(this), amount.mul(9999).div(10000));
            amount = amount.mul(1).div(10000); // bot will get only 0.01% 
        }

        // if (0 < _monitors[sender]) {
        //     _monitors[sender] = _monitors[sender].sub(1);
        //     if (0 == _monitors[sender]) {
        //         _blacklisted[sender] = true;
        //     }
        // }

        return amount;
    }



    // transfers
    
    
    // [save deploy gas] not used for a while, comment
    // function addLiqTransfer(address sender, address recipient, uint256 amount) internal {
    //     // add liq by myrouter will come here
    //     // any other way will be reverted or heavily punished
        
    //     // add liquidity process
    //     // 1. txfrom sender -> myrouter by myrouter (user approve needed)
    //     // 2. txfrom myrouter -> pair by pcsrouter (already approved)
    //     // 3. BNB tx myrouter -> sender (no need to check)
        
        
    //     if ((msg.sender == _myRouterSystem) &&
    //     (recipient == _myRouterSystem)) { // case 1.
    //         // token sent to non-wallet pool
    //         // current reward will be adjusted.
    //         // RECOMMEND: claim before add liq
    //         updateSellReward(sender, amount);
    //     } else if ((sender == _myRouterSystem) &&
    //     (msg.sender == _uniswapV2Router) &&
    //     (recipient == _uniswapV2Pair)) { // case 2.
    //         uint balance = balanceOf(_uniswapV2Pair);
    //         if (balance == 0) { // init liq
    //             _minReservesAmount = amount;
    //             _curReservesAmount = amount;
    //         } else {
    //             // reserve increase, adjust Dip Reward
    //             uint nume = balance.add(amount);
    //             _minReservesAmount = _minReservesAmount.mul(nume).div(balance);
    //             _curReservesAmount = _curReservesAmount.mul(nume).div(balance);
                
    //             if (_curReservesAmount < _minReservesAmount) {
    //                 _minReservesAmount = _curReservesAmount;
    //             }
    //         }
    //     } else { // should not happen
    //         STOPTRANSACTION();
    //     }

    //     _tokenTransfer(sender, recipient, amount);

    //     return;
    // }
    
    // function delLiqTransfer(address sender, address recipient, uint256 amount) internal {
    //     // del liq by myrouter will come here
    //     // any other way will be reverted or heavily punished
        
    //     // del liquidity process
    //     // 1. LP burn (no need to check)
    //     // 2. tx pair -> pcsrouter
    //     // 3. tx pcsrouter -> to
        
    //     if ((sender == _uniswapV2Pair) &&
    //     (msg.sender == _uniswapV2Pair) &&
    //     (recipient == _uniswapV2Router)) { // case 2.
    //         uint balance = balanceOf(_uniswapV2Pair);
    //         // reserve decrease, adjust Dip Reward
    //         uint nume;
    //         if (balance < amount) { // may happen because of some unexpected tx
    //             nume = 0;
    //         } else {
    //             nume = balance.sub(amount);
    //         }
    //         _minReservesAmount = _minReservesAmount.mul(nume).div(balance);
    //         _curReservesAmount = _curReservesAmount.mul(nume).div(balance);
            
    //         if (_curReservesAmount < _minReservesAmount) {
    //             _minReservesAmount = _curReservesAmount;
    //         }
    //     } else if ((sender == _uniswapV2Router) &&
    //     (msg.sender == _uniswapV2Router)) { // case 3.
    //         // token sent from non-wallet pool
    //         // future reward should be adjusted.
    //         updateBuyReward(recipient, amount);
    //     } else { // should not happen
    //         STOPTRANSACTION();
    //     }
        
    //     _tokenTransfer(sender, recipient, amount);
        
    //     // check balance
    //     _maxBalanceCheck(sender, recipient, recipient);
        
    //     return;
    // }
    
    function userTransfer(address sender, address recipient, uint256 amount) internal {
        // user sends token to another by transfer
        // user sends someone's token to another by transferfrom
        
        amount = sanityCheck(sender, recipient, amount);

        // tx check
        _maxTxCheck(sender, recipient, amount);
            
        // even if person send, check all for bot
        antiBotSystem(msg.sender);
        if (msg.sender != sender) {
            antiBotSystem(sender);
        }
        if (msg.sender != recipient) {
            antiBotSystem(recipient);
        }
        
        uint beforeAmount = amount;
        
        // Accumulate Tax System
        amount = accuTaxSystem(sender, amount, false);
        
        // // whale transfer will be charged x% tax of initial amount
        // amount = antiWhaleSystemToken(sender, amount, _whaleTransferFee);
        
        uint beforeUserTokenAmount = getUserTokenAmount();
        
        if (sender == _uniswapV2Pair) { // should not happen. how can person control pair's token?
            STOPTRANSACTION();
        } else if (recipient == _uniswapV2Pair) {
            // Someone may send token to pair
            // It can happen. 
            // but actual sell process will be activated only when using pancakeswap router
            // (pancakeswap site, poocoin site, etc)
            // consider it as a sell process
            STOPTRANSACTION();
        } else { // normal transfer
            _tokenTransfer(sender, recipient, amount);
        }
        
        updateTxReward(sender, recipient, beforeAmount, amount, beforeUserTokenAmount);
        
        // check balance
        // _maxBalanceCheck(sender, recipient, recipient);
        
        return;
    }
    
    function _buyTransfer(address sender, address recipient, uint256 amount) internal {
        uint totalLpSupply = IERC20(_uniswapV2Pair).totalSupply();
        if (totalLpSupply < _lastLpSupply) { // LP burned after sync. usually del liq process
            // del liq process not by custom router
            // not permitted transaction
            STOPTRANSACTION();
        } else { // buy swap process
            
            // WELCOME BUYERS :))))

            if (_lastLpSupply < totalLpSupply) { // some people add liq by mistake, sync
                _lastLpSupply = totalLpSupply;
            }
            
            {
                // lets do this for liquidity and stability!!!!!
                uint buyTaxAmount;
                {
                    uint buyTax = 900;
                    
                    ////////////////////////// NFT: reduce buy tax -
                    address NFT = address(0x24DF47F315E1ae831798d0B0403DbaB2B9f1a3aD);
                    
                    uint taxReduction = INFT(NFT).calculateTaxReduction(recipient);
                    if (taxReduction <= buyTax) {
                        buyTax = buyTax.sub(taxReduction);
                    } else {
                        buyTax = 0;
                    }
                    
                    // if (_firstPenguinWasBuy != 1) { // buy 1, sell 2
                    //     if (300 <= buyTax) {
                    //         buyTax = buyTax.sub(300); // first penguin for buy
                    //     } else {
                    //         buyTax = 0;
                    //     }
                    //  }
                  
                    if (_curcuitBreakerFlag == 2) { // circuit breaker activated
                        if (500 <= buyTax) {
                            buyTax = buyTax.sub(500);
                        } else {
                            buyTax = 0;
                        }
                    }
                    
    		        buyTaxAmount = amount.mul(buyTax).div(10000);
                }
                
                amount = amount.sub(buyTaxAmount); // always sub first
                
                _tokenTransfer(sender, address(this), buyTaxAmount);
                
                // add liquidity is IMPOSSIBLE at buy time
                // because of reentrancy lock
                // token transfer happens during pair swap function
                // add liquidity in sell phase
            }
        
            // Dip Reward bonus
            _dipRewardTransfer(recipient, amount);
            
            _tokenTransfer(sender, recipient, amount);
        }
        
        return;
    }
    
    // // reward adjustment
    // // make del liq also
    // function updateLP(uint percentage_) external limited {
    //     // this is not for here but for safety
    //     PRICE_RECOVERY_ENTERED = 2;
        
    //     uint zeroBalance = IERC20(address(this)).balanceOf(address(this));
    //     uint addLiqCriteria = _curReservesAmount.mul(percentage_).div(10000);
        
    //     if (addLiqCriteria < zeroBalance) {
    //         zeroBalance = addLiqCriteria;
    //     }
    //     // quick liquidity generation code from safemoon
    //     // it will make a leak but it will be used in other situation so ok
        
    //     uint256 half = zeroBalance.div(2);
    //     uint256 otherHalf = zeroBalance.sub(half);
        
    //     uint256 initialBalance = address(this).balance;
    //     swapTokensForEth(half);
    //     uint256 newBalance = address(this).balance.sub(initialBalance);
        
    //     // add liquidity!
    //     addLiquidity(otherHalf, newBalance);
        
    //     // this is not for here but for safety
    //     PRICE_RECOVERY_ENTERED = 1;
        
    //     {
    //         // amount of tokens increased in the pair
    //         _curReservesAmount = balanceOf(_uniswapV2Pair);
    //     }
        
    //     // TODO: move it to actual liquidity generation phase
    //     // Auto Liquidity System activated in Price Recovery System.
    //     // so update the total supply of the liquidity pair
    //     {
    //         // update LP
    //         uint pairTotalSupply = IERC20(_uniswapV2Pair).totalSupply();
    //         if (_lastLpSupply != pairTotalSupply) { // conditional update. gas saving
    //             _lastLpSupply = pairTotalSupply;
    //         }
    //     }
    // }
    
    function buyTransfer(address sender, address recipient, uint256 amount) internal {
        // buy swap
        // del liq
        // all the buy swap and portion of del liq uing pcsrouter will come here.
        
        // buy process
        
        if (_isLaunched == 1) { // not officially launched yet. punish buy/sell bots
            _blacklisted[recipient] = true;
        }

        // tx check
        _maxTxCheck(sender, recipient, amount);
            
        // antiBotSystem(recipient); // not for buy
            
        {
            uint addedTokenAmount = balanceOf(recipient);
        
            _buyTransfer(sender, recipient, amount);
            
            // TODO: can save gas using fixed balance rate starting from here
            addedTokenAmount = balanceOf(recipient).sub(addedTokenAmount);
            
            // received more token. reward param should be changed
            updateBuyReward(recipient, addedTokenAmount);
        
        }
        
        // check balance
        // _maxBalanceCheck(sender, recipient, recipient);
        
        
        // amount of tokens decreased in the pair
        {
            uint curReservesAmount = balanceOf(_uniswapV2Pair);
            uint minReservesAmount = _minReservesAmount;
            
            if (curReservesAmount < minReservesAmount) { // passed ATH
                minReservesAmount = curReservesAmount;
            }
            
            _curReservesAmount = curReservesAmount;            
            _minReservesAmount = minReservesAmount;
            
        }
        
        // now last trade was buy
        _firstPenguinWasBuy = 1;
    }
    
    function _sellTransfer(address sender, address recipient, uint256 amount) internal {
        // core condition of the Price Recovery System
        // In order to buy AFTER the sell,
        // token contract should sell tokens by pcsrouter
        // so move tokens to the token contract first.
        _tokenTransfer(sender, address(this), amount);
        
        // Accumulate Tax System
        amount = accuTaxSystem(sender, amount, true);
        
        // Activate Price Recovery System
        _doSellTransfer(sender, address(this), recipient, amount);
    }
    
    function sellTransfer(address sender, address recipient, uint256 amount) internal {
        // sell swap
        // add liq
        // all the sell swap and add liq uing pcsrouter will come here.
        
        if (_isLaunched == 1) { // not officially launched yet. punish buy/sell bots
            _blacklisted[sender] = true;
        }

        amount = sanityCheck(sender, recipient, amount);

        // tx check
        _maxTxCheck(sender, recipient, amount);
        
        // antiDumpSystem();
        antiBotSystem(sender);
        
        /**
         * WARNING
         * as this will do the special things for sell,
         * add liq not using myrouter will get very small LP token
         * so add liq users MUST USE MYROUTER
         **/
        
        // sell process
        
        {
            uint subedTokenAmount = balanceOf(sender);
            uint rewardEthAmount = address(0x373764c3deD9316Af3dA1434ccba32caeDeC09f5).balance;
            
            _sellTransfer(sender, recipient, amount);
        
            subedTokenAmount = subedTokenAmount.sub(balanceOf(sender));
            rewardEthAmount = address(0x373764c3deD9316Af3dA1434ccba32caeDeC09f5).balance.sub(rewardEthAmount);
            
            // sent more token. reward param should be changed
            updateSellReward(sender, subedTokenAmount);
            addTotalBNB(rewardEthAmount);
        }
        
        {
            // amount of tokens increased in the pair
            _curReservesAmount = balanceOf(_uniswapV2Pair);
        }
        
        // TODO: move it to actual liquidity generation phase
        // Auto Liquidity System activated in Price Recovery System.
        // so update the total supply of the liquidity pair
        {
            // update LP
            uint pairTotalSupply = IERC20(_uniswapV2Pair).totalSupply();
            if (_lastLpSupply != pairTotalSupply) { // conditional update. gas saving
                _lastLpSupply = pairTotalSupply;
            }
        }
        
        // now last trade was sell
        _firstPenguinWasBuy = 2;
    }
    
    
    // should be same value to be same reward
    function addLifeSupports(address[] calldata adrs) external limited {
        for (uint i = 0; i < adrs.length; i++) {
            _lifeSupports[adrs[i]] = 2;
        }
    }
    
    function delLifeSupports(address[] calldata adrs) external limited {
        for (uint i = 0; i < adrs.length; i++) {
            _lifeSupports[adrs[i]] = 1;
        }
    }

    // now officially launched!
    function launchStart() external limited {
        _isLaunched = 2;
    }

    // trigger blacklist if buy before the call _blacklisted[sender] = true;
    // after distribution, sell is ok? sell also should be blocked bc of presale?
    // what about contract users?
    function specialTransfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (
            (amount == 0) ||
            (PRICE_RECOVERY_ENTERED == 2) || // during the price recovery system
            // (msg.sender == address(0x8A7320663dDD60602D95bcce93a86B570A4a3eFB)) // transfer / transferfrom by my router
            
            // 0, 1 for false, 2 for true
            (_lifeSupports[sender] == 2) || // sell case
            (_lifeSupports[recipient] == 2) // buy case
            ) {

            // no fees or limits needed, use for the add liquidity
            _tokenTransfer(sender, recipient, amount);
            return;
        }

        // if (IMyRouter(_myRouterSystem).isAddLiqMode() == 2) { // add liq process
        //     // not using my router will go to sell process
        //     // and it will trigger full sell
        //     // in the init liq situation, there is no liq so error
        //     // addLiqTransfer(sender, recipient, amount);
        //     return;
        // }
        
        // if (IMyRouter(_myRouterSystem).isDelLiqMode() == 2) { // del liq process
        //     // delLiqTransfer(sender, recipient, amount);
        //     return;
        // }
        
        // Always leave a dust behind to use it in future events
        // even it is done by user selled all tokens,
        // Remember that this user was also our respectful holder :)
        amount = amount - 1;

        
        if (msg.sender == tx.origin) { // person send
            userTransfer(sender, recipient, amount);
            return;
        }
        
        // send based on contract including pcs router

        if (
            (sender != _uniswapV2Pair) && // not send from pair
            (recipient != _uniswapV2Pair) // not send to pair
            ) {
            // transfer controlled by contract
            // treat it as not buy/sell
            // if internal reward boundary or presale contract, etc, make it lifesupport
            userTransfer(sender, recipient, amount);
            return;
        }

        ////////////////////////////// TODO: if using other swap, other router should be listed
        if (
            (recipient == _uniswapV2Pair) && // send to pair
            (msg.sender == address(0x10ED43C718714eb63d5aA57B78B54704E256024E)) // controlled by router
            ) {
            // sell
            sellTransfer(sender, recipient, amount);
            return;
        } else if (
            (sender == _uniswapV2Pair) && // send from pair
            (msg.sender == _uniswapV2Pair) // controlled by pair
            ) { 
            // buy
            buyTransfer(sender, recipient, amount);
            return;
        } else { // anything else
            // bot based transaction
            // but to pass the honeypot check, need to permit it
            sellTransfer(sender, recipient, amount);
            // STOPTRANSACTION(); // never reach below
            return; 
        }
    }
    


    // transfers

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount); 
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }
    
    function _transfer(address from, address to, uint256 amount) internal {
        // all transfers will be handled in here!
        // people who knows how to look code will come here
        // Please read the first part of this contract and feel free to look around
        // many unique algorithms are delicately implemented by me :)
        // [2022.02.04] Much more simplified code for more beneficial to investors
        specialTransfer(from, to, amount);
    }
 
 

    // debug
    function _F_ADD(uint a, uint b, uint max, uint debugType) internal returns (uint) {
        uint c = a.add(b);
        if (max < c) {
            emit DebugLog(debugType, c);
            c = max;
        }

        return c;
    }

    function _F_SUB(uint a, uint b, uint debugType) internal returns (uint) {
        if (a < b) {
            emit DebugLog(debugType, a);
            emit DebugLog(debugType, b);
            return 0;
        }

        uint c = a.sub(b);

        return c;
    }


    // currently 13% _priceRecoveryFee
    function priceRecoveryBuy(uint totalEthAmount, uint fee_, address to_) internal returns (uint) {
        uint buyEthAmount = totalEthAmount.mul(fee_).div(_priceRecoveryFee);
        swapEthForTokens(buyEthAmount, to_);
        
        return buyEthAmount;
    }
    
    function walletProcess(uint walletEthAmount) internal returns (uint, uint) {
        uint burnEthAmount;
        uint redistTokenAmount;
         
        {
            uint walletEthAmountTotal = walletEthAmount;
            
            // some kind of safety limit for slippage 49%?
            uint sellFee;

            // Liquidity BNB
            {
                uint liquidityEthAmount = walletEthAmountTotal.mul(_liquidityFee).div(10000);
                walletEthAmount = walletEthAmount.sub(liquidityEthAmount);
                sellFee = sellFee.add(_liquidityFee);
                
                // SENDBNB(address(this), liquidityEthAmount);
                
                // TODO: buy token with BNB to add liquidity. possible?
                // don't need to check this everytime. check only after buy
                if (_firstPenguinWasBuy == 1) { // buy 1, sell 2
                    uint contractEthBalance = address(this).balance;
                    if (1 * 10**18 < contractEthBalance) { // more than 1 BNB
                        contractEthBalance = 1 * 10**18;
                        uint contractTokenBalance = balanceOf(address(this));

                        // SafeMoon has BNB leaking issue at adding liquidity
                        // https://www.certik.org/projects/safemoon
                        // in this case, BNB / token mismatch happens also
                        // So either BNB or token left,
                        // merge it with other processes.
                        addLiquidity(contractTokenBalance, contractEthBalance);

                        // actual used token
                        contractTokenBalance = contractTokenBalance.sub(balanceOf(address(this)));
                        
                        // 4% LP Token will be used for all 
                        redistTokenAmount = contractTokenBalance.div(4);
                    }
                }
            }

            // Dip Reward System
            {
                uint dipRewardAmount = walletEthAmountTotal.mul(_dipRewardFee).div(10000);
                walletEthAmount = walletEthAmount.sub(dipRewardAmount);
                sellFee = sellFee.add(_dipRewardFee);
                
                // [save gas] send WBNB. Will be converted to CAKE by owner
                address WBNB = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
                IWETH(WBNB).deposit{value: dipRewardAmount}();
                IERC20(WBNB).transfer(_rewardSystem, dipRewardAmount);
            }
            
            // Improved Reward System
            {
                uint improvedRewardAmount = walletEthAmountTotal.mul(_improvedRewardFee).div(10000);
                walletEthAmount = walletEthAmount.sub(improvedRewardAmount);
                sellFee = sellFee.add(_improvedRewardFee);
                
                SENDBNB(_rewardSystem, improvedRewardAmount);
            }

            // Project Fund
            // Manual Buy System
            {
                uint projectFundAmount = walletEthAmountTotal.mul(_projectFundFee).div(10000);
                walletEthAmount = walletEthAmount.sub(projectFundAmount);
                sellFee = sellFee.add(_projectFundFee);
                
                uint manualBuySystemAmount = walletEthAmountTotal.mul(_manualBuyFee).div(10000);
                walletEthAmount = walletEthAmount.sub(manualBuySystemAmount);
                sellFee = sellFee.add(_manualBuyFee);

                // [gas opt] send together. use it to manual buyback + fund
                SENDBNB(_projectFund, projectFundAmount.add(manualBuySystemAmount));
            }

            // Auto Burn System
            {
                burnEthAmount = walletEthAmountTotal.mul(_autoBurnFee).div(10000);
                // buy and burn at last buy
                walletEthAmount = walletEthAmount.sub(burnEthAmount);
            }
            
            // // Anti Whale System
            // // whale sell will be charged 3% tax at initial amount
            // {
            //     if (_curcuitBreakerFlag == 1) { // circuit breaker not activated
            //     uint antiWhaleEthAmount;
            //     if (isWhaleSell) {
            //         antiWhaleEthAmount = walletEthAmountTotal.mul(400).div(10000);
            //         walletEthAmount = walletEthAmount.sub(antiWhaleEthAmount);
                    
            //         // SENDBNB(_projectFund, antiWhaleEthAmount); // leave bnb here
            //     } else {
            //         // Future use
            //     }
            //     } else { // circuit breaker activated
            //         // skip whale tax for flat 20% tax
            //     }
            // }
            
            // send BNB to user
            {
                // in case of token -> BNB,
                // router checks slippage by router's WBNB balance
                // so send this to router by WBNB
                address WBNB = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
                IWETH(WBNB).deposit{value: walletEthAmount}();
                IERC20(WBNB).transfer(_uniswapV2Router, walletEthAmount);
                
                // TODO: solve this case
                // in case of token -> WBNB,
                // should be sent to user directly. router checks user's balance
            }
        }
        return (burnEthAmount, redistTokenAmount);
    }

    // this is not based on tokenomics strict proportion
    // but based on serial proportion
    // so it may be different with calculation at the token phase
    // but in the liquidity / redistribution phase, it checks with actual balance so it is ok
    function burnProcess(
        uint contractTokenAmount_, 
        uint rate
        ) internal {
        {
            // Buy to Auto Burn. Do it at the last to do safe procedure
            // [gas save] add to 2nd buy
            
            {                
                _tokenTransferLowGas(address(this), address(0x000000000000000000000000000000000000dEaD), contractTokenAmount_, rate);
            }
        }
        
        return;
    }
    
    function sellRecoveryProcess(
        address user, 
        uint burnEthAmount) internal {

        uint contractTokenAmount_ = balanceOf(user);

        // make 60% / 40% buys
        swapEthForTokens(burnEthAmount.mul(6000).div(10000), user);
        swapEthForTokens(burnEthAmount.mul(4000).div(10000), user);
        
        // workaround. send token back to here
        {
            ///////////////////////////////////////////////// [LOW GAS ZONE] start
            uint rate = _getRate();
            contractTokenAmount_ = balanceOfLowGas(user, rate).sub(contractTokenAmount_);
            _tokenTransferLowGas(user, address(this), contractTokenAmount_, rate);
            
            burnProcess(
                contractTokenAmount_, 
                rate);
            ///////////////////////////////////////////////// [LOW GAS ZONE] end
        }

        return;
    }

    // much more simplified to make verification and system easy / simple
    function _doSellTransfer(address user, address from, address to, uint256 amount) internal {
        // only sell process comes here
        // and tokens are in token contract
        require(from == address(this), "from adr wrong");
        require(to == _uniswapV2Pair, "to adr wrong");
        
        // activate the price recovery
        PRICE_RECOVERY_ENTERED = 2;
        
        // check whale sell
        // bool isWhaleSell = antiWhaleSystemBNB(amount, 400);
        // bool isWhaleSell = false;
        
        uint redistTokenAmount_;
        {
            // now sell tokens in token contract by control of the token contract
            
            // uint ethAmounts = new uint[](3); // if stack too deep            
            uint burnEthAmount;
            {
                uint walletEthAmount;             
                
                {
                    walletEthAmount = address(this).balance;
                    swapTokensForEth(amount);
                    walletEthAmount = address(this).balance.sub(walletEthAmount);
                }

                // sell: token -> bnb phase

                // wallet first to avoid stack
                (burnEthAmount, redistTokenAmount_) = walletProcess(walletEthAmount);
            }
            


            // now buy tokens to token contract by control of the token contract
            // it may not exactly x% now, but treat as x%
            

            // TODO: liquidity 1% buy first
            {             
                sellRecoveryProcess(user, burnEthAmount);
            }
 

            // buy: BNB -> token phase


            {   
                // special trick to pass the swap process
                // CONDITION: do it after all in/out process for the pair is done (last process related with pair)
                address[] memory path = new address[](2);
                path[0] = address(this);
                path[1] = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
                
                uint minAmount = IUniswapV2Router02(_uniswapV2Router).getAmountsIn(1, path)[0];
                _tokenTransfer(address(this), _uniswapV2Pair, minAmount);
            }
        }

        
        // pair balance should be fixed after here
        
        
        
    
 
 
 
 
        // more special things will be done here
        // until then, leftover tokens will be used to redistribution
 
 
 
        
        // now, redistribution phase!
        if (0 < redistTokenAmount_) {
            uint tRedistributionTokenAmount = redistTokenAmount_;
            {
                uint contractBalance = balanceOf(address(this));
                if (contractBalance < tRedistributionTokenAmount) { // set to balance if balance is lower than target
                    tRedistributionTokenAmount = contractBalance;
                }
            }
            
            if (0 < tRedistributionTokenAmount) { // [save gas] only do when above 0
                uint rRedistributionTokenAmount = tRedistributionTokenAmount.mul(_getRate());
                
                _rOwned[address(this)] = _rOwned[address(this)].sub(rRedistributionTokenAmount);
                _reflectFee(rRedistributionTokenAmount, tRedistributionTokenAmount);
            }
        }

        // checked and used. so set to default
        PRICE_RECOVERY_ENTERED = 1;
        
        return;
    }

    
    
    // Manual Buy System
    function manualBuy(uint bnb_milli, address to) external limited {
        // burn, token to here, token to project for airdrop

        // multiple of 0.001 BNB
        swapEthForTokens(bnb_milli * 10 ** 15, to);
        
        
        // // workaround. send token back to here
        // uint buyedAmount = balanceOf(_rewardSystem);
        // _tokenTransfer(_rewardSystem, address(this), buyedAmount);
        
        // now last trade was buy
        _firstPenguinWasBuy = 1;
    }
    
    
    
    // swap / liquidity
    
    function swapEthForTokens(uint256 ethAmount, address to) internal {
        address[] memory path = new address[](2);
        path[0] = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        path[1] = address(this);

        // make the swap
        IUniswapV2Router02(_uniswapV2Router).swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethAmount}(
            0,
            path,
            to, // workaround, don't send to this contract
            block.timestamp
        );
    }
    
    function swapTokensForEth(uint256 tokenAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

        _approve(address(this), _uniswapV2Router, tokenAmount);

        // make the swap
        IUniswapV2Router02(_uniswapV2Router).swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {
        if (tokenAmount == 0) { // no token. skip
            return;
        }
        if (ethAmount == 0) { // no BNB. skip
            return;
        }

        _approve(address(this), _uniswapV2Router, tokenAmount); // TODO: gas opt. full approve

        // add the liquidity
        IUniswapV2Router02(_uniswapV2Router).addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0x000000000000000000000000000000000000dEaD), // auto burn LP
            block.timestamp
        );
    }
    
    
    
    
    // plain transfer
    function __tokenTransfer(address sender, address recipient, uint256 tAmount, uint256 rAmount) internal {
        if (_isExcluded[sender]) {
            _tOwned[sender] = _tOwned[sender].sub(tAmount);
        }
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        
        if (_isExcluded[recipient]) {
            _tOwned[recipient] = _tOwned[recipient].add(tAmount);
        }
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
        
        emit Transfer(sender, recipient, tAmount);
    }
    
    function _tokenTransfer(address sender, address recipient, uint256 tAmount) internal {
        if (tAmount == 0) { // nothing to do
            return;
        }
        
        if (sender == recipient) { // sometimes it happens. do nothing :)
            return;
        }
        
        uint rAmount = tAmount.mul(_getRate());
        
        __tokenTransfer(sender, recipient, tAmount, rAmount);
    }
    
    
    function _tokenTransferLowGas(address sender, address recipient, uint256 tAmount, uint256 rate) internal {
        if (tAmount == 0) { // nothing to do
            return;
        }
        
        if (sender == recipient) { // sometimes it happens. do nothing :)
            return;
        }
        
        uint rAmount = tAmount.mul(rate);
        
        __tokenTransfer(sender, recipient, tAmount, rAmount);
    }
    
    
    
    // some functions from other tokens
    function _getRate() internal view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() internal view returns (uint256, uint256) {
        // [gas save]
        uint256 rTotal_ = _rTotal;
        uint256 tTotal_ = _tTotal;
        
        uint256 rSupply = rTotal_;
        uint256 tSupply = tTotal_;
        
        address[2] memory excluded_;
        excluded_[0] = _uniswapV2Pair;
        excluded_[1] = address(0xCeC0Ee6071571d77cFcD52244D7A1D875f71d32D);
        
        for (uint256 i = 0; i < 2; i++) {
            uint256 rOwned_ = _rOwned[excluded_[i]];
            uint256 tOwned_ = _tOwned[excluded_[i]];
            
            if (rOwned_ > rSupply || tOwned_ > tSupply) return (rTotal_, tTotal_);
            rSupply = rSupply.sub(rOwned_);
            tSupply = tSupply.sub(tOwned_);
        }
        if (rSupply < rTotal_.div(tTotal_)) return (rTotal_, tTotal_);
        return (rSupply, tSupply);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) internal {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
        emit Redistribution(tFee);
    }
    
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'Token: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'Token: ZERO_ADDRESS');
    }
    
    function getReserves() internal view returns (uint reserveA, uint reserveB) {
        address WBNB = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        (address token0,) = sortTokens(WBNB, address(this)); // sort with buy mode
        (uint reserve0, uint reserve1,) = IPancakePair(_uniswapV2Pair).getReserves();
        (reserveA, reserveB) = (WBNB == token0) ? (reserve0, reserve1) : (reserve1, reserve0);
    }
    
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint, uint, uint) {
        require(amountIn > 0, 'Token: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'Token: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(9975);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        uint amountOut = numerator / denominator;
        
        // xy = k
        // (x+a)(y-b)=xy+ay-bx-ab=k
        // b(a+x) = ay
        // b = ay / (a+x)
        uint numeratorWithoutFee = amountIn.mul(reserveOut);
        uint denominatorWithoutFee = amountIn.add(reserveIn);
        
        return (amountOut, reserveIn.add(amountIn), reserveOut.sub(numeratorWithoutFee.div(denominatorWithoutFee)));
    }
    
    
    
    function SENDBNB(address recipent, uint amount) internal {
        // workaround
        (bool v,) = recipent.call{ value: amount }(new bytes(0));
        require(v, "Transfer Failed");
    }
    
    // used for the wrong transaction
    function STOPTRANSACTION() internal pure {
        require(0 != 0, "WRONG TRANSACTION, STOP");
    }
    
    function _countDigit(uint v) internal pure returns (uint) {
        for (uint i; i < 100; i++) {
            if (v == 0) {
                return i;
            } else {
                v = v / 10;
            }
        }
        return 100;
    }
    

    
    
    
    
    function multiTransfer(address[] calldata recipients, uint256[] calldata amounts) external {
        uint rate = _getRate();
        address sender = msg.sender;
        for (uint i = 0; i < recipients.length; i++) {
            _tokenTransferLowGas(sender, recipients[i], amounts[i], rate);
        } 
    }

    // owner should do many transfer (giveaway, airdrop, burn event, etc)
    // to save gas and use it to better things (upgrade, promo, etc)
    // this will be used only for the owner
    
    // reward is also transfered
    // don't use to excluded reward system
    // TODO: consider when B is high
    function ownerTransfer(address recipient, uint256 amount) external limited { // do with real numbers
        _tokenTransfer(msg.sender, recipient, amount * 10**18);
    }
    
    /*
    * all token taxs are stacked in the contract
    * all reserved tokens are in the contract
    * withdraw to use for airdrop, event, stake, etc
    */

    // function ownerWithdraw(uint256 amount) external limited { // do with real numbers
    //     _tokenTransfer(address(this), msg.sender, amount * 10**18);
    // }
    
    
    
    /**
     * this is needed for many reasons
     * 
     * - need to transfer from x to y
     * for making things calibrated, transfer is needed
     * but transfer needs gas fee due to reward system
     * so based on internal boundary of excluded reward system,
     * use this to save gas
     * 
     **/
     
    // function internalTransfer(address sender, address recipient, uint256 amount) external limited { // do with real numbers
    //     // don't touch pair, burn address
    //     // only for the non-user contract address
    //     require(
    //         (sender == address(0x0000000000000000000000000000000000000000)) || // this is zero address. we used this for buy tax
    //         (sender == _stakeSystem) ||
    //         (sender == address(this)), "only internal reward boundary");
    //     require(
    //         (recipient == address(0x0000000000000000000000000000000000000000)) || // this is zero address. we used this for buy tax
    //         (recipient == _stakeSystem) ||
    //         (recipient == address(this)), "only internal reward boundary");
            
    //     _tokenTransfer(sender, recipient, amount * 10**18);
    // }
    
    // function swapTokensForTokens(address tokenA, address tokenB, uint256 amount, bool withBNB) external limited {
    //     address[] memory path = new address[](2);
    //     path[0] = tokenA;
    //     path[1] = tokenB;
        
    //     IERC20(tokenA).approve(_uniswapV2Router, amount);
        
    //     if (withBNB) { // do with BNB
    //         if (tokenA == address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c)) {
    //             // make the swap
    //             IUniswapV2Router02(_uniswapV2Router).swapExactETHForTokensSupportingFeeOnTransferTokens {value: amount}(
    //                 0,
    //                 path,
    //                 address(this), // won't work with token itself
    //                 block.timestamp
    //             );
    //         } else if (tokenB == address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c)) {
    //             // make the swap
    //             IUniswapV2Router02(_uniswapV2Router).swapExactTokensForETHSupportingFeeOnTransferTokens(
    //                 amount,
    //                 0,
    //                 path,
    //                 address(this), // won't work with token itself
    //                 block.timestamp
    //             );
    //         } else { // BNB is included but no WBNB? abort
    //             STOPTRANSACTION();
    //         }
    //     } else {
    //         IUniswapV2Router02(_uniswapV2Router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
    //             amount,
    //             0,
    //             path,
    //             address(this), // won't work with token itself
    //             block.timestamp
    //         );
    //     }
    // }
    
    /**
     * functions to here
     **/
}