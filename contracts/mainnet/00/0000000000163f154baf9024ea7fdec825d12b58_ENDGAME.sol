/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

/**
Endgame

The time has come to pass the torch to the community.
The future is yours to create, will you join us?

Telegram awaits: https://t.me/endgameblack
Or visit us at endgame.black

The end is near.
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

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
        require(b != 0,
            'parameter 2 can not be 0');
        return a % b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

}

library TaxSystemLib {
    struct TradeTaxSystem {
        uint256 rTokenRewardFee;
        uint256 rTokenDirectRewardFee;
        uint256 smallBattleRTokenFee;
        uint256 smallBattleEndgameFee;
        uint256 liquidityFee;
        uint256 rfvFee;
        uint256 treasuryFee;
        uint256 bigBattleFee;
        uint256 rebaserFee;
        uint256 referralFee;
        uint256 burnFee;
        uint256 totalFee;
	}
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

interface IPancakeSwapPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );
	function sync() external;
    function skim(address to) external;
}

interface IPancakeSwapRouter{
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
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

interface IPancakeSwapFactory {
		function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode
        return msg.data;
    }
}

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

interface IENDGAMEDividendTracker {
    function excludeFromDividends(address account) external;
    function updateClaimWait(uint256 newClaimWait) external;
    function updateMinimumTokenBalanceForDividends(uint256 newMinimumTokenBalanceForDividends) external;
    function getNumberOfTokenHolders() external view returns(uint256);
    function setBalance(address payable account, uint256 newBalancel, address _rToken) external;
    function process(uint256 gas, address _rToken) external returns (uint256, uint256, uint256);
    function processAccount(address payable account, bool automatic, address _rToken) external;
    function addRToken(address _token) external;
    function updateTaxSystem(address _taxSystem) external;
}

interface IReferralSystem {
    function getReferrer(address _investor) external view returns (address);
}

interface IBattle {
    function buyAction(address _investor, uint256 _buyAmount) external;
    function endRound(uint256 _gamesPerFragment) external;
    function updateTaxSystem(address _taxSystem) external;
}

interface ITaxSystem {
    function updateEpochAcc(
        uint256 gameAmount,
        TaxSystemLib.TradeTaxSystem memory tradeTax,
        uint256 _dynamicFee,
        uint256 _gamesPerFragment,
        address _trader,
        address _router,
        address _rToken,
        address _rTokenRouter,
        uint256 _tradeFlag
    ) external;
    function swapBack(
        uint256 _gamesPerFragment,
        address _router,
        address _rToken,
        address _rTokenRouter
    ) external;
    function addLiquidity(uint256 autoLiquidityAmount, address _router) external;
    function withdrawAllToTreasury(uint256 amountToSwap, address _router) external;
    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _treasuryReceiver,
        address _RFVWallet,
        address _rebaserWallet,
        address _researchFund,
        address _dynamicFeeReceiver
    ) external;
    function updateDividendTracker(address _dividendTracker) external;
    function updateBattle(address _battle) external;
    function buyTaxWithReferral() external view returns (TaxSystemLib.TradeTaxSystem memory);
    function sellTaxWithReferral() external view returns (TaxSystemLib.TradeTaxSystem memory);
    function transferTaxWithReferral() external view returns (TaxSystemLib.TradeTaxSystem memory);
    function buyTaxWithoutReferral() external view returns (TaxSystemLib.TradeTaxSystem memory);
    function sellTaxWithoutReferral() external view returns (TaxSystemLib.TradeTaxSystem memory);
    function transferTaxWithoutReferral() external view returns (TaxSystemLib.TradeTaxSystem memory);
    function maxBracketTax() external view returns (uint256);
    function feeDenominator() external view returns (uint256);
    
}

contract ENDGAME is Ownable, IERC20, IERC20Metadata, ReentrancyGuard {
    using SafeMath for uint256;
    using TaxSystemLib for TaxSystemLib.TradeTaxSystem;

    string public _name = "ENDGAME";
    string public _symbol = "ENDGAME";
    uint8 public _decimals = 5;
    uint256 public _totalSupply;
    uint256 private _gamesPerFragment;
    uint256 private _dividendGamesPerFragment;

    mapping(address => bool) _isFeeExempt;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    uint8 public constant DECIMALS = 5;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint256 public constant MAX_UINT128 = uint256(~uint128(0));
    uint8 public constant RATE_DECIMALS = 12;
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY =
        1_000_000 * (10**DECIMALS);

    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    address constant BURN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address public autoLiquidityReceiver;
    address public treasuryReceiver;
    address public RFVWallet;
    address public rebaserWallet;
    address public researchFund;
    address public trueRebaseFeature;
    address public dynamicFeeReceiver;

    IENDGAMEDividendTracker public dividendTracker;
    IReferralSystem public referralSystem;
    IBattle public battle;
    ITaxSystem public taxSystem;
    address[] public pairs;
    address[] public rToken; //Reflection Token List
    uint256 private selectedRTokenId;

    bool inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 private constant TOTAL_GAMES =
        MAX_UINT128 - (MAX_UINT128 % INITIAL_FRAGMENTS_SUPPLY);

    uint256 private constant MAX_SUPPLY = 21_000_000 * (10**DECIMALS);

    bool public _autoRebase;
    bool public _autoRebaseTrigger;
    bool public _autoRoundEnd;
    bool public _autoRoundEndTrigger;
    uint256 public _initRebaseStartTime;
    uint256 public _lastRebasedTime;
    uint256 public _lastRoundEndTime;

    uint256 public gasForProcessing = 300000;

    mapping(address => uint256) private _gameBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;
    mapping(address => address) public router;
    mapping(address => uint256) public userReferralReward;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor,
        address _rToken
    );
    event ReferralReward(
        address indexed _referrer,
        address indexed _follower,
        uint256 amount
    );

    constructor() Ownable() {
        _name = "ENDGAME";
        _symbol = "ENDGAME";
        _decimals = DECIMALS;
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;

        uint256 _startTime = 2000000000;

        treasuryReceiver = 0x7777777770B1Dd9c4ce592fB6F7dDF88796182Fc;

        _gameBalances[treasuryReceiver] = TOTAL_GAMES;

        _gamesPerFragment = TOTAL_GAMES.div(_totalSupply);
        _dividendGamesPerFragment = TOTAL_GAMES.div(MAX_SUPPLY).div(10**(18-DECIMALS));
        _autoRebase = false;
        _autoRebaseTrigger = true;
        _autoRoundEnd = false;
        _autoRoundEndTrigger = true;
        _initRebaseStartTime = _startTime;
        _lastRebasedTime = _startTime;
        _lastRoundEndTime = _startTime;
        _isFeeExempt[treasuryReceiver] = true;
        _isFeeExempt[address(this)] = true;

        _transferOwnership(treasuryReceiver);
        emit Transfer(address(0x0), treasuryReceiver, _totalSupply);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
   
    function balanceOf(address who) public view returns (uint256) {
        return _gameBalances[who].div(_gamesPerFragment);
    }

    function rebase() internal {
        
        if ( inSwap ) return;
        uint256 rebaseRate;
        uint256 deltaTimeFromInit = block.timestamp - _initRebaseStartTime;
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(30 minutes);
        uint256 epoch = times.mul(30);

        if (deltaTimeFromInit <= (7000 days)) {
            rebaseRate = 412639848;
        } else {
            rebaseRate = 0;
        }

        uint256 _totalSupplyBuf = _totalSupply;

        for (uint256 i = 0; i < times; i++) {
            _totalSupplyBuf = _totalSupplyBuf
                .mul((10**RATE_DECIMALS).add(rebaseRate))
                .div(10**RATE_DECIMALS);
        }

        if (_totalSupplyBuf > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        } else {
            _totalSupply = _totalSupplyBuf;
        }

        _gamesPerFragment = TOTAL_GAMES.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(30 minutes));

        inSwap = true;
        for (uint256 j = 0; j < pairs.length; j++) {
            IPancakeSwapPair(pairs[j]).skim(trueRebaseFeature);
        }
        inSwap = false;

        emit LogRebase(epoch, _totalSupply);
    }

    function manualRebase() external nonReentrant{
        require(!_autoRebase, "Not available");
        require(_totalSupply < MAX_SUPPLY, "No need");
        require(!inSwap, "Try again");
        require(block.timestamp >= (_lastRebasedTime + 30 minutes), "Not in time");
        rebase();
    }

    function transfer(address to, uint256 value)
        external
        override
        validRecipient(to)
        returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {
        
        if (_allowedFragments[from][msg.sender] != MAX_UINT256) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
                msg.sender
            ].sub(value, "Insufficient Allowance");
        }
        _transferFrom(from, to, value);
        return true;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 gameAmount = amount.mul(_gamesPerFragment);
        _gameBalances[from] = _gameBalances[from].sub(gameAmount);
        _gameBalances[to] = _gameBalances[to].add(gameAmount);

        try dividendTracker.setBalance(
            payable(from), _gameBalances[from].div(_dividendGamesPerFragment), rToken[selectedRTokenId]) {} catch {}
        try dividendTracker.setBalance(
            payable(to), _gameBalances[to].div(_dividendGamesPerFragment), rToken[selectedRTokenId]) {} catch {}
        
        emit Transfer(from, to, amount);
        return true;
    }

    function randomizeRTokenId(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(sender)))) / (block.timestamp)) +
            ((uint256(keccak256(abi.encodePacked(recipient)))) / (block.timestamp)) +
            ((uint256(keccak256(abi.encodePacked(amount)))) / (block.timestamp)) +
            block.number
        )));
        selectedRTokenId = seed % rToken.length;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {

        require(!blacklist[sender] && !blacklist[recipient], "in_blacklist");
        randomizeRTokenId(sender, recipient, amount);

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        uint256 tradeFlag = 0; // transfer flag
        for (uint256 i = 0; i < pairs.length; i++) {
            if (recipient == pairs[i]) {
                tradeFlag = 1; // sell flag
                break;
            }
            if (sender == pairs[i]) {
                tradeFlag = 2; // buy flag
                break;
            }
        }

        if (tradeFlag == 2) {
            uint112 reserve0;
            uint112 reserve1;
            uint32 blockTimestampLast;
            address token0;
            address token1;
            uint256 WETHBal;
            uint256 tokenBal;
            for (uint256 i = 0; i < pairs.length; i++) {
                (reserve0, reserve1, blockTimestampLast) = IPancakeSwapPair(pairs[i])
                    .getReserves();
                token0 = IPancakeSwapPair(pairs[i]).token0();
                token1 = IPancakeSwapPair(pairs[i]).token1();
                if (token0 == IPancakeSwapRouter(router[address(this)]).WETH()) {
                    WETHBal = uint256(reserve0);
                    tokenBal = uint256(reserve1);
                } else if (token1 == IPancakeSwapRouter(router[address(this)]).WETH()) {
                    WETHBal = uint256(reserve1);
                    tokenBal = uint256(reserve0);
                }
            }
            uint256 buyAmount = (WETHBal.mul(tokenBal).div(tokenBal.sub(amount))).sub(WETHBal);
            battle.buyAction(recipient, buyAmount);
        }

        if (_autoRebaseTrigger && !_autoRebase && dividendTracker.getNumberOfTokenHolders() > 100) {
            _autoRebase = true;
            _autoRebaseTrigger = false;
        }

        if (_autoRoundEndTrigger && !_autoRoundEnd && dividendTracker.getNumberOfTokenHolders() > 25) {
            _autoRoundEnd = true;
            _autoRoundEndTrigger = false;
        }

        if (shouldRebase()) {
           rebase();
        }

        if (tradeFlag != 2) {
            addLiquidity();
            swapBack();
        }

        if (shouldRoundEnd()) {
           roundEnd();
        }

        uint256 gameAmount = amount.mul(_gamesPerFragment);
        _gameBalances[sender] = _gameBalances[sender].sub(gameAmount);
        uint256 gameAmountReceived = shouldTakeFee(sender, recipient, tradeFlag)
            ? takeFee(sender, recipient, gameAmount, tradeFlag)
            : gameAmount;
        _gameBalances[recipient] = _gameBalances[recipient].add(
            gameAmountReceived
        );

        try dividendTracker.setBalance(
            payable(sender), _gameBalances[sender].div(_dividendGamesPerFragment), rToken[selectedRTokenId]) {} catch {}
        try dividendTracker.setBalance(
            payable(recipient), _gameBalances[recipient].div(_dividendGamesPerFragment), rToken[selectedRTokenId]) {} catch {}

        uint256 gas = gasForProcessing;
        try dividendTracker.process(gas, rToken[selectedRTokenId]) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
            emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin, rToken[selectedRTokenId]);
        }
        catch { }

        emit Transfer(
            sender,
            recipient,
            gameAmountReceived.div(_gamesPerFragment)
        );
        
        return true;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 gameAmount,
        uint256 tradeFlag
    ) internal  returns (uint256) {
        uint256[] memory mValue = new uint256[](5);
        address _referrer;
        address _trader;
        TaxSystemLib.TradeTaxSystem memory tradeTax;
        mValue[1] = taxSystem.feeDenominator(); // fee denominator

        if (tradeFlag == 0) { // transfer flag
            _trader = sender;
            _referrer = referralSystem.getReferrer(sender);
            if (_referrer == address(0)) {
                _referrer = BURN;
                tradeTax = taxSystem.transferTaxWithoutReferral();
            } else {
                tradeTax = taxSystem.transferTaxWithReferral();
            }
        } else if (tradeFlag == 1) { // sell flag
            _trader = sender;
            _referrer = referralSystem.getReferrer(sender);
            if (_referrer == address(0)) {
                _referrer = BURN;
                tradeTax = taxSystem.sellTaxWithoutReferral();
            } else {
                tradeTax = taxSystem.sellTaxWithReferral();
            }
        } else if (tradeFlag == 2) { // buy flag
            _trader = recipient;
            _referrer = referralSystem.getReferrer(recipient);
            if (_referrer == address(0)) {
                _referrer = BURN;
                tradeTax = taxSystem.buyTaxWithoutReferral();
            } else {
                tradeTax = taxSystem.buyTaxWithReferral();
            }
        }

        mValue[0] = gameAmount.mul(tradeTax.referralFee).div(mValue[1]); // gameAmountBuffer
        if (mValue[0] > 0) {
            _gameBalances[_referrer] = _gameBalances[_referrer].add(mValue[0]);
            try dividendTracker.setBalance(
                payable(_referrer), _gameBalances[_referrer].div(_dividendGamesPerFragment), rToken[selectedRTokenId]) {} catch {}
            
            emit Transfer(
                address(taxSystem),
                _referrer,
                mValue[0].div(_gamesPerFragment)
            );

            emit ReferralReward(
                _referrer,
                _trader,
                mValue[0].div(_gamesPerFragment)
            );

            userReferralReward[_referrer] += mValue[0].div(_gamesPerFragment);
        }

        mValue[0] = gameAmount.mul(tradeTax.burnFee).div(mValue[1]);
        if (mValue[0] > 0) {
            _gameBalances[BURN] = _gameBalances[BURN].add(mValue[0]);

            emit Transfer(
                address(taxSystem),
                BURN,
                mValue[0].div(_gamesPerFragment)
            );
        }

        mValue[2] = 0; // dynamic fee
        if (tradeFlag !=2) {
            mValue[2] = getCurrentTaxBracket(sender);
        }

        mValue[3] = tradeTax.totalFee.add(mValue[2]); // _totalFee

        _gameBalances[autoLiquidityReceiver] = _gameBalances[autoLiquidityReceiver].add(
            gameAmount.mul(tradeTax.liquidityFee).div(mValue[1])
        );
        _gameBalances[address(taxSystem)] = _gameBalances[address(taxSystem)].add(
            gameAmount.mul(mValue[3].sub(tradeTax.referralFee).sub(
                tradeTax.liquidityFee).sub(tradeTax.burnFee)).div(mValue[1])
        );

        inSwap = true;
        taxSystem.updateEpochAcc(
            gameAmount,
            tradeTax,
            mValue[2],
            _gamesPerFragment,
            _trader,
            router[address(this)],
            rToken[selectedRTokenId],
            router[rToken[selectedRTokenId]],
            tradeFlag
        );
        inSwap = false;

        mValue[4] = gameAmount.mul(mValue[3]).div(mValue[1]); // feeAmount
        
        emit Transfer(sender, address(taxSystem), mValue[4].div(_gamesPerFragment));

        return gameAmount.sub(mValue[4]);
    }

    function addLiquidity() internal swapping {
        uint256 autoLiquidityAmount = _gameBalances[autoLiquidityReceiver].div(
            _gamesPerFragment
        );
        _gameBalances[address(taxSystem)] = _gameBalances[address(taxSystem)].add(
            _gameBalances[autoLiquidityReceiver]
        );
        _gameBalances[autoLiquidityReceiver] = 0;

        taxSystem.addLiquidity(autoLiquidityAmount, router[address(this)]);
    }

    function swapBack() internal swapping {
        taxSystem.swapBack(
            _gamesPerFragment,
            router[address(this)],
            rToken[selectedRTokenId],
            router[rToken[selectedRTokenId]]
        );
    }

    function roundEnd() internal swapping {
        battle.endRound(_gamesPerFragment);
        _lastRoundEndTime = block.timestamp;
    }

    function manualRoundEnd() external nonReentrant{
        require(!_autoRoundEnd, "Not available");
        require(!inSwap, "Try again");
        require(block.timestamp >= (_lastRoundEndTime + 30 minutes), "Not in time");
        roundEnd();
    }

    function withdrawAllToTreasury() external swapping onlyOwner {
        uint256 amountToSwap = _gameBalances[address(taxSystem)].div(_gamesPerFragment);
        require( amountToSwap > 0,"There is no ENDGAME token deposited in taxSystem contract");
        taxSystem.withdrawAllToTreasury(amountToSwap, router[address(this)]);
    }

    function shouldRebase() internal view returns (bool) {
        bool flag = _autoRebase &&
            (_totalSupply < MAX_SUPPLY) &&
            !inSwap &&
            block.timestamp >= (_lastRebasedTime + 30 minutes);
        if (flag) {
            for (uint256 i = 0; i < pairs.length; i++) {
                if (msg.sender == pairs[i]) {
                    flag = false;
                    break;
                }
            }
        }
        return flag;
    }

    function shouldRoundEnd() internal view returns (bool) {
        bool flag = _autoRoundEnd &&
            !inSwap &&
            block.timestamp >= (_lastRoundEndTime + 30 minutes);
        if (flag) {
            for (uint256 i = 0; i < pairs.length; i++) {
                if (msg.sender == pairs[i]) {
                    flag = false;
                    break;
                }
            }
        }
        return flag;
    }

    function shouldTakeFee(address from, address to, uint256 tradeFlag) internal view returns (bool) {
        if (tradeFlag == 2) {
            return !_isFeeExempt[to];
        }
        return !_isFeeExempt[from];
    }

    function getTokensInLPCirculation() public view returns (uint256) {
        uint112 reserve0;
        uint112 reserve1;
        uint32 blockTimestampLast;
        address token0;
        address token1;
        uint256 LPTotal;

        for (uint256 i = 0; i < pairs.length; i++) {
            (reserve0, reserve1, blockTimestampLast) = IPancakeSwapPair(pairs[i])
                .getReserves();

            token0 = IPancakeSwapPair(pairs[i]).token0();
            token1 = IPancakeSwapPair(pairs[i]).token1();

            if (token0 == address(this)) {
                LPTotal += reserve0;
            } else if (token1 == address(this)) {
                LPTotal += reserve1;
            }
        }

        return LPTotal;
    }

    function getCurrentTaxBracket(address _address) public view returns (uint256) {
        uint256 feeDenominator = taxSystem.feeDenominator();
        uint256 maxBracketTax = taxSystem.maxBracketTax();
        uint256 userTotal = _gameBalances[_address].div(_gamesPerFragment);
        uint256 totalCap = userTotal.mul(feeDenominator).div(getTokensInLPCirculation());
        uint256 _bracket = SafeMath.min(totalCap, maxBracketTax);

        return _bracket;
    }

    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            _autoRebase = _flag;
            _lastRebasedTime = block.timestamp;
        } else {
            _autoRebase = _flag;
        }
    }

    function setAutoRebaseTrigger(bool _flag) external onlyOwner {
        _autoRebaseTrigger = _flag;
    }

    function setAutoRoundEnd(bool _flag) external onlyOwner {
        if (_flag) {
            _autoRoundEnd = _flag;
            _lastRoundEndTime = block.timestamp;
        } else {
            _autoRoundEnd = _flag;
        }
    }

    function setAutoRoundEndTrigger(bool _flag) external onlyOwner {
        _autoRoundEndTrigger = _flag;
    }

    function allowance(address owner_, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][
            spender
        ].add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function approve(address spender, uint256 value)
        external
        override
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function getCirculatingSupply() public view returns (uint256) {
        return
            (TOTAL_GAMES.sub(_gameBalances[BURN]).sub(_gameBalances[DEAD]).sub(
                _gameBalances[ZERO])).div(_gamesPerFragment);
    }

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }

    function manualSync() external {
        for (uint256 i = 0; i < pairs.length; i++) {
            IPancakeSwapPair(pairs[i]).sync();
        }
    }

    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _treasuryReceiver,
        address _RFVWallet,
        address _rebaserWallet,
        address _researchFund,
        address _trueRebaseFeature,
        address _dynamicFeeReceiver
    ) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        treasuryReceiver = _treasuryReceiver;
        RFVWallet = _RFVWallet;
        rebaserWallet = _rebaserWallet;
        researchFund = _researchFund;
        trueRebaseFeature = _trueRebaseFeature;
        dynamicFeeReceiver = _dynamicFeeReceiver;

        taxSystem.setFeeReceivers(
            _autoLiquidityReceiver,
            _treasuryReceiver,
            _RFVWallet,
            _rebaserWallet,
            _researchFund,
            _dynamicFeeReceiver
        );
    }

    function getLiquidityBacking(uint256 accuracy)
        external
        view
        returns (uint256)
    {
        uint256 liquidityBalance = 0;
        for (uint256 i = 0; i < pairs.length; i++) {
            liquidityBalance = liquidityBalance.add(
                _gameBalances[pairs[i]].div(_gamesPerFragment));
        }
        return
            accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isFeeExempt[account] != excluded, "Account is already the value of 'excluded'");
        _isFeeExempt[account] = excluded;
    }

    function setBotBlacklist(address _botAddress, bool _flag) external onlyOwner {
        require(isContract(_botAddress),
            "only contract address, not allowed externally owned account");
        blacklist[_botAddress] = _flag;    
    }

    function addPair(address _pair) external onlyOwner {
        require(isContract(_pair), "only contract address");
        pairs.push(_pair);
    }

    function setPair(uint256 _id, address _pair) external onlyOwner {
        require(isContract(_pair), "only contract address");
        pairs[_id] = _pair;
    }

    function removePair(uint256 _id) external onlyOwner {
        pairs[_id] = pairs[pairs.length-1];
        pairs.pop();
    }

    function pairsLength() external view returns (uint256) {
        return pairs.length;
    }

    function addRToken(address _token, address _router) external onlyOwner {
        require(isContract(_token), "only contract address");
        rToken.push(_token);
        router[_token] = _router;
        dividendTracker.addRToken(_token);
    }

    function setRToken(address _oldToken, address _newToken, address _router) external onlyOwner {
        require(isContract(_newToken), "only contract address");
        bool isRToken = false;
        uint256 _id;
        for (uint256 i = 0; i < rToken.length; i++) {
            if (rToken[i] == _oldToken) {
                isRToken = true;
                _id = i;
                break;
            }
        }
        require(isRToken, "old token does not exist in rToken list.");
        rToken[_id] = _newToken;
        router[_newToken] = _router;
    }

    function removeRToken(address _rToken) external onlyOwner {
        bool isRToken = false;
        uint256 _id;
        for (uint256 i = 0; i < rToken.length; i++) {
            if (rToken[i] == _rToken) {
                isRToken = true;
                _id = i;
                break;
            }
        }
        require(isRToken, "the token does not exist in rToken list.");
        rToken[_id] = rToken[rToken.length-1];
        rToken.pop();
    }

    function rTokenLength() external view returns (uint256) {
        return rToken.length;
    }

    function initContracts(
        address _router,
        address _referralSystem,
        address _battle,
        address _taxSystem,
        address _dividendTracker
    ) external onlyOwner {
        require(isContract(_router), "only contract address");
        require(isContract(_referralSystem), "only contract address");
        require(isContract(_battle), "only contract address");
        require(isContract(_taxSystem), "only contract address");
        require(isContract(_dividendTracker), "only contract address");

        router[address(this)] = _router;
        referralSystem = IReferralSystem(_referralSystem);
        battle = IBattle(_battle);
        taxSystem = ITaxSystem(_taxSystem);
        dividendTracker = IENDGAMEDividendTracker(_dividendTracker);

        taxSystem.updateBattle(_battle);
        taxSystem.updateDividendTracker(_dividendTracker);

        dividendTracker.updateTaxSystem(_taxSystem);
        dividendTracker.excludeFromDividends(_battle);
        dividendTracker.excludeFromDividends(_taxSystem);
        dividendTracker.excludeFromDividends(_dividendTracker);
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(DEAD);
        dividendTracker.excludeFromDividends(ZERO);
        dividendTracker.excludeFromDividends(BURN);
        dividendTracker.excludeFromDividends(treasuryReceiver);
        for (uint256 i = 0; i < pairs.length; i++) {
            dividendTracker.excludeFromDividends(pairs[i]);
        }

        battle.updateTaxSystem(_taxSystem);

        _isFeeExempt[_battle] = true;
        _isFeeExempt[_taxSystem] = true;
        _allowedFragments[_taxSystem][_router] = MAX_UINT256;
    }

    function setRouter(address _router) external onlyOwner {
        require(isContract(_router), "only contract address");
        router[address(this)] = _router;
        _allowedFragments[address(taxSystem)][_router] = MAX_UINT256;
    }

    function updateReferralSystem(address _referralSystem) external onlyOwner {
        require(isContract(_referralSystem), "only contract address");
        referralSystem = IReferralSystem(_referralSystem);
    }

    function updateStartTime(uint256 _startTime) external onlyOwner {
        require(_initRebaseStartTime > block.timestamp, "Rebase have been already begun.");
        _initRebaseStartTime = _startTime;
        _lastRebasedTime = _startTime;
        _lastRoundEndTime = _startTime;
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "ENDGAME: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "ENDGAME: Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function updateMinimumTokenBalanceForDividends(uint256 minimumTokenBalanceForDividends) external onlyOwner {
        dividendTracker.updateMinimumTokenBalanceForDividends(minimumTokenBalanceForDividends);
    }

    function excludeFromDividends(address account) external onlyOwner{
        dividendTracker.excludeFromDividends(account);
    }

    function processDividendTracker(uint256 gas, address _rToken) external {
        (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas, _rToken);
        emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin, _rToken);
    }

    function claim(address _rToken) external {
        dividendTracker.processAccount(payable(msg.sender), false, _rToken);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    receive() external payable {}
}