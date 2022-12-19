/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

/**
Hypercube

I make this #Hypercube and I hand it over to the community.

Help build the community for yourselves, if you are interested.

I suggest hopping into the telegram https://t.me/hypercube_money

I will adjust and improve the token as we shift into the 4th dimension.

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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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

interface IHypercubeDividendTracker {
    function owner() external view returns (address);
    function distributeWZERDividends(uint256 amount) external;
    function claimWait() external view returns(uint256);
    function totalDividendsDistributed() external view returns(uint256);
    function balanceOf(address who) external view returns (uint256);
    function excludeFromDividends(address account) external;
    function updateClaimWait(uint256 newClaimWait) external;
    function getLastProcessedIndex() external view returns(uint256);
    function getNumberOfTokenHolders() external view returns(uint256);
    function getAccount(address _account)
        external view returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable);
    function getAccountAtIndex(uint256 index)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256);
    function setBalance(address payable account, uint256 newBalance) external;
    function process(uint256 gas) external returns (uint256, uint256, uint256);
    function processAccount(address payable account, bool automatic) external;
    function withdrawableDividendOf(address _owner) external view returns(uint256);
}

interface IReferralSystem {
    function setInvestor(address _investor, address _referrer) external;
    function checkInvestor(address _user) external view returns (bool);
    function getReferrer(address _investor) external view returns (address);
}

interface IBattle {
    function buyAction(address _investor, uint256 _buyAmount) external;
    function endRound(
        uint256 _wzerFundsForSmallBattle,
        uint256 _fundsForBigBattle
    ) external payable;
}

contract Hypercube is Ownable, IERC20, IERC20Metadata, ReentrancyGuard {
    using SafeMath for uint256;

    string public _name = "Hypercube";
    string public _symbol = "Hypercube";
    uint8 public _decimals = 5;
    uint256 public _totalSupply;
    uint256 private _hypersPerFragment;
    uint256 private _dividendHypersPerFragment;

    mapping(address => bool) _isFeeExempt;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    uint8 public constant DECIMALS = 5;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 12;
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY =
        1_000_000 * (10**DECIMALS);
    
    uint256 public wzerRewardFee = 10;
    uint256 public tempChampWZERFee = 10;
    uint256 public liquidityFee = 20;
    uint256 public rfvFee = 20;
    uint256 public treasuryFee = 10;
    uint256 public hyperChampFee = 10;
    uint256 public battleFee = 10;
    uint256 public rebaserFee = 10;
    uint256 public referralFee = 30;
    uint256 public extraWZERRewardFee = 10;
    uint256 public extraBattleFee = 10;
    uint256 public sellReferralFee = 40;
    uint256 public extraSellReferralFee = 10;
    uint256 public transferReferralFee = 100;

    uint256 public constant feeDenominator = 1000;

    uint256 public maxBracketTax = 100; // max bracket is holding 10%

    struct EpochAcc {
        uint256 accWZERReward;
        uint256 accTempChampWZER;
        uint256 accRFV;
        uint256 accTreasury;
        uint256 accHyperChamp;
        uint256 accBattle;
        uint256 accRebaser;
	}
    EpochAcc public eA;

    address public immutable WZER = address(0x530e9346870E632A63E8d461bb3c3622e00782DE); //WZER

    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;
    address constant BURN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address public autoLiquidityReceiver;
    address public treasuryReceiver;
    address public RFVWallet;
    address public rebaserWallet;

    IPancakeSwapRouter public router;
    IHypercubeDividendTracker public dividendTracker;
    IReferralSystem public referralSystem;
    IBattle public battle;
    address[] public pairs;

    bool inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 private constant TOTAL_HYPERS =
        MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    uint256 private constant MAX_SUPPLY = 21_000_000 * (10**DECIMALS);

    bool public _autoRebase;
    bool public _autoRebaseTrigger;
    bool public _autoAddLiquidity;
    bool public _autoSwapBack;
    bool public _autoSwapBackTrigger;
    uint256 public _initRebaseStartTime;
    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public _lastRewardTime;

    uint256 public gasForProcessing = 300000;

    mapping(address => uint256) private _hyperBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
        );

    constructor() Ownable() {
        _name = "Hypercube";
        _symbol = "Hypercube";
        _decimals = DECIMALS;
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;

        uint256 _startTime = 2000000000;

        router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        treasuryReceiver = 0x111111111d414570616ABc89e817EdC9dcc1798F;
        autoLiquidityReceiver = 0x222222222090a774cABa55062339ce205eB58f26;
        RFVWallet = 0x3333333335692C1bEe30a3A75306DA297C7442b4;
        rebaserWallet = 0x44444444484De9643A34857Fc86f0D9B29Ec253A;

        _hyperBalances[treasuryReceiver] = TOTAL_HYPERS;
        _allowedFragments[address(this)][address(router)] = MAX_UINT256;

        _hypersPerFragment = TOTAL_HYPERS.div(_totalSupply);
        _dividendHypersPerFragment = TOTAL_HYPERS.div(MAX_SUPPLY).div(10**(18-DECIMALS));
        _autoRebase = false;
        _autoRebaseTrigger = true;
        _autoAddLiquidity = true;
        _autoSwapBack = false;
        _autoSwapBackTrigger = true;
        _initRebaseStartTime = _startTime;
        _lastRebasedTime = _startTime;
        _lastAddLiquidityTime = _startTime;
        _lastRewardTime = _startTime;
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
        return _hyperBalances[who].div(_hypersPerFragment);
    }

    function rebase() internal {
        
        if ( inSwap ) return;
        uint256 rebaseRate;
        uint256 deltaTimeFromInit = block.timestamp - _initRebaseStartTime;
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(30 minutes);
        uint256 epoch = times.mul(30);

        if (deltaTimeFromInit <= (7000 days)) {
            rebaseRate = 302081574;
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

        _hypersPerFragment = TOTAL_HYPERS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(30 minutes));

        inSwap = true;
        for (uint256 j = 0; j < pairs.length; j++) {
            IPancakeSwapPair(pairs[j]).skim(treasuryReceiver);
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
        uint256 hyperAmount = amount.mul(_hypersPerFragment);
        _hyperBalances[from] = _hyperBalances[from].sub(hyperAmount);
        _hyperBalances[to] = _hyperBalances[to].add(hyperAmount);

        try dividendTracker.setBalance(
            payable(from), _hyperBalances[from].div(_dividendHypersPerFragment)) {} catch {}
        try dividendTracker.setBalance(
            payable(to), _hyperBalances[to].div(_dividendHypersPerFragment)) {} catch {}
        
        emit Transfer(from, to, amount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {

        require(!blacklist[sender] && !blacklist[recipient], "in_blacklist");

        bool buyActionFlag = false;
        for (uint256 i = 0; i < pairs.length; i++) {
            if (sender == pairs[i]) {
                buyActionFlag = true;
                break;
            }
        }
        if (buyActionFlag) {
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
                if (token0 == router.WETH()) {
                    WETHBal = uint256(reserve0);
                    tokenBal = uint256(reserve1);
                } else if (token1 == router.WETH()) {
                    WETHBal = uint256(reserve1);
                    tokenBal = uint256(reserve0);
                }
            }
            uint256 buyAmount = (WETHBal.mul(tokenBal).div(tokenBal.sub(amount))).sub(WETHBal);
            battle.buyAction(recipient, buyAmount);
        }

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (_autoRebaseTrigger && !_autoRebase && dividendTracker.getNumberOfTokenHolders() > 1000) {
            _autoRebase = true;
            _autoRebaseTrigger = false;
        }

        if (_autoSwapBackTrigger && !_autoSwapBack && dividendTracker.getNumberOfTokenHolders() > 25) {
            _autoSwapBack = true;
            _autoSwapBackTrigger = false;
        }

        if (shouldRebase()) {
           rebase();
        }

        if (shouldAddLiquidity()) {
            addLiquidity();
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        uint256 hyperAmount = amount.mul(_hypersPerFragment);
        _hyperBalances[sender] = _hyperBalances[sender].sub(hyperAmount);
        uint256 hyperAmountReceived = (!_isFeeExempt[sender])
            ? takeFee(sender, recipient, hyperAmount)
            : hyperAmount;
        _hyperBalances[recipient] = _hyperBalances[recipient].add(
            hyperAmountReceived
        );

        try dividendTracker.setBalance(
            payable(sender), _hyperBalances[sender].div(_dividendHypersPerFragment)) {} catch {}
        try dividendTracker.setBalance(
            payable(recipient), _hyperBalances[recipient].div(_dividendHypersPerFragment)) {} catch {}

        uint256 gas = gasForProcessing;
        try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
            emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
        }
        catch {

        }

        emit Transfer(
            sender,
            recipient,
            hyperAmountReceived.div(_hypersPerFragment)
        );
        
        return true;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 hyperAmount
    ) internal  returns (uint256) {
        uint256 _wzerRewardFee = wzerRewardFee;
        uint256 _BattleFee = battleFee;
        uint256 _ReferralFee = referralFee;
        uint256 _totalFee;
        address _referrer = referralSystem.getReferrer(sender);
        bool buyActionFlag = false;
        bool sellActionFlag = false;
        uint256 _hyperAmountBuffer;
        for (uint256 i = 0; i < pairs.length; i++) {
            if (recipient == pairs[i]) {
                sellActionFlag = true;
                break;
            }
            if (sender == pairs[i]) {
                buyActionFlag = true;
                _referrer = referralSystem.getReferrer(recipient);
                break;
            }
        }

        if (buyActionFlag || sellActionFlag) {
            if (_referrer == address(0)) {
                _wzerRewardFee = _wzerRewardFee.add(extraWZERRewardFee);
                _BattleFee = _BattleFee.add(extraBattleFee);
                if (sellActionFlag) {
                    _ReferralFee = _ReferralFee.add(sellReferralFee).add(extraSellReferralFee);
                }
                _hyperAmountBuffer = hyperAmount.div(feeDenominator).mul(_ReferralFee);
                _hyperBalances[BURN] = _hyperBalances[BURN].add(_hyperAmountBuffer);

                emit Transfer(
                    address(this),
                    BURN,
                    _hyperAmountBuffer.div(_hypersPerFragment)
                );
            } else {
                if (sellActionFlag) {
                    _ReferralFee = _ReferralFee.add(sellReferralFee);
                }
                _hyperAmountBuffer = hyperAmount.div(feeDenominator).mul(_ReferralFee);
                _hyperBalances[_referrer] = _hyperBalances[_referrer].add(_hyperAmountBuffer);
                try dividendTracker.setBalance(
                    payable(_referrer), _hyperBalances[_referrer].div(_dividendHypersPerFragment)) {} catch {}
                
                emit Transfer(
                    address(this),
                    _referrer,
                    _hyperAmountBuffer.div(_hypersPerFragment)
                );
            }

            _totalFee = _wzerRewardFee.add(tempChampWZERFee).add(liquidityFee).add(rfvFee);
            _totalFee = _totalFee.add(treasuryFee).add(hyperChampFee).add(_BattleFee).add(rebaserFee).add(_ReferralFee);
            _hyperBalances[autoLiquidityReceiver] = _hyperBalances[autoLiquidityReceiver].add(
                hyperAmount.div(feeDenominator).mul(liquidityFee)
            );
            _hyperBalances[address(this)] = _hyperBalances[address(this)].add(
                hyperAmount.div(feeDenominator).mul(_totalFee.sub(_ReferralFee))
            );

            eA.accWZERReward += hyperAmount.div(feeDenominator).mul(_wzerRewardFee).div(_hypersPerFragment);
            eA.accTempChampWZER += hyperAmount.div(feeDenominator).mul(tempChampWZERFee).div(_hypersPerFragment);
            eA.accRFV += hyperAmount.div(feeDenominator).mul(rfvFee).div(_hypersPerFragment);
            eA.accTreasury += hyperAmount.div(feeDenominator).mul(treasuryFee).div(_hypersPerFragment);
            eA.accHyperChamp += hyperAmount.div(feeDenominator).mul(hyperChampFee).div(_hypersPerFragment);
            eA.accBattle += hyperAmount.div(feeDenominator).mul(_BattleFee).div(_hypersPerFragment);
            eA.accRebaser += hyperAmount.div(feeDenominator).mul(rebaserFee).div(_hypersPerFragment);
        } else {
            if (_referrer == address(0)) {
                _hyperAmountBuffer = hyperAmount.div(feeDenominator).mul(transferReferralFee);
                _hyperBalances[BURN] = _hyperBalances[BURN].add(_hyperAmountBuffer);

                emit Transfer(
                    address(this),
                    BURN,
                    _hyperAmountBuffer.div(_hypersPerFragment)
                );
            } else {
                _hyperAmountBuffer = hyperAmount.div(feeDenominator).mul(transferReferralFee);
                _hyperBalances[_referrer] = _hyperBalances[_referrer].add(_hyperAmountBuffer);
                try dividendTracker.setBalance(
                    payable(_referrer), _hyperBalances[_referrer].div(_dividendHypersPerFragment)) {} catch {}
                
                emit Transfer(
                    address(this),
                    _referrer,
                    _hyperAmountBuffer.div(_hypersPerFragment)
                );
            }
            _totalFee = transferReferralFee;
        }

        uint256 dynamicFee = getCurrentTaxBracket(sender);
        _hyperAmountBuffer = hyperAmount.div(feeDenominator).mul(dynamicFee);
        _hyperBalances[BURN] = _hyperBalances[BURN].add(_hyperAmountBuffer);
        emit Transfer(
            address(this),
            BURN,
            _hyperAmountBuffer.div(_hypersPerFragment)
        );
        _totalFee = _totalFee.add(dynamicFee);

        uint256 feeAmount = hyperAmount.div(feeDenominator).mul(_totalFee);
        
        emit Transfer(sender, address(this), feeAmount.div(_hypersPerFragment));
        return hyperAmount.sub(feeAmount);
    }

    function addLiquidity() internal swapping {
        uint256 autoLiquidityAmount = _hyperBalances[autoLiquidityReceiver].div(
            _hypersPerFragment
        );
        _hyperBalances[address(this)] = _hyperBalances[address(this)].add(
            _hyperBalances[autoLiquidityReceiver]
        );
        _hyperBalances[autoLiquidityReceiver] = 0;
        uint256 amountToLiquify = autoLiquidityAmount.div(2);
        uint256 amountToSwap = autoLiquidityAmount.sub(amountToLiquify);

        if( amountToSwap == 0 ) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint256 balanceBefore = address(this).balance;


        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHLiquidity = address(this).balance.sub(balanceBefore);

        if (amountToLiquify > 0&&amountETHLiquidity > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
        }
        _lastAddLiquidityTime = block.timestamp;
    }

    function swapBack() internal swapping {
        uint256 _amountToETH = eA.accWZERReward.add(eA.accTempChampWZER).add(eA.accTreasury).add(
            eA.accRFV).add(eA.accBattle).add(eA.accRebaser);

        if( _amountToETH == 0) {
            return;
        }

        uint256 accRFVPercent = eA.accRFV.mul(1000).div(_amountToETH);
        uint256 accBattlePercent = eA.accBattle.mul(1000).div(_amountToETH);
        uint256 accRebaserPercent = eA.accRebaser.mul(1000).div(_amountToETH);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _amountToETH,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETH = address(this).balance.sub(balanceBefore);
        uint256 amountETHToRFV = amountETH.mul(accRFVPercent).div(1000);
        uint256 amountETHToRebaser = amountETH.mul(accRebaserPercent).div(1000);
        uint256 amountETHToBattle = amountETH.mul(accBattlePercent).div(1000);

        bool success;
        (success, ) = RFVWallet.call{
            value: amountETHToRFV,
            gas: 30000
        }("");
        (success, ) = rebaserWallet.call{
            value: amountETHToRebaser,
            gas: 30000
        }("");

        uint256 amountETHToWZER = amountETH.sub(amountETHToRFV).sub(amountETHToRebaser).sub(
            amountETHToBattle);


        path[0] = router.WETH();
        path[1] = WZER;

        balanceBefore = IERC20(WZER).balanceOf(address(this));

        router.swapExactETHForTokens{value: amountETHToWZER}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountWZER = IERC20(WZER).balanceOf(
            address(this)).sub(balanceBefore);
        
        uint256 _amountToWZER = eA.accWZERReward.add(eA.accTempChampWZER).add(eA.accTreasury);

        uint256 accWZERRewardPercent = eA.accWZERReward.mul(1000).div(_amountToWZER);
        uint256 accTempChampWZERPercent = eA.accTempChampWZER.mul(1000).div(_amountToWZER);

        uint256 amountWZERToReward = amountWZER.mul(accWZERRewardPercent).div(1000);
        uint256 amountWZERToTempChamp = amountWZER.mul(accTempChampWZERPercent).div(1000);
        uint256 amountWZERToTreasury = amountWZER.sub(amountWZERToReward).sub(amountWZERToTempChamp);

        success = IERC20(WZER).transfer(address(dividendTracker), amountWZERToReward);
        if (success) {
            dividendTracker.distributeWZERDividends(amountWZERToReward);
        }
        success = IERC20(WZER).transfer(treasuryReceiver, amountWZERToTreasury);
        battle.endRound{value: amountETHToBattle}(amountWZERToTempChamp, eA.accHyperChamp);

        _lastRewardTime = block.timestamp;
        eA.accWZERReward = 0;
        eA.accTempChampWZER = 0;
        eA.accRFV = 0;
        eA.accTreasury = 0;
        eA.accHyperChamp = 0;
        eA.accBattle = 0;
        eA.accRebaser = 0;
    }

    function manualSwapBack() external nonReentrant{
        require(!_autoSwapBack, "Not available");
        require(!inSwap, "Try again");
        require(block.timestamp >= (_lastRewardTime + 30 minutes), "Not in time");
        swapBack();
    }

    function withdrawAllToTreasury() external swapping onlyOwner {
        uint256 amountToSwap = _hyperBalances[address(this)].div(_hypersPerFragment);
        require( amountToSwap > 0,"There is no Hypercube token deposited in token contract");
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            treasuryReceiver,
            block.timestamp
        );
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

    function shouldAddLiquidity() internal view returns (bool) {
        bool flag = _autoAddLiquidity && 
            !inSwap && 
            block.timestamp >= (_lastAddLiquidityTime + 2 days);
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

    function shouldSwapBack() internal view returns (bool) {
        bool flag = _autoSwapBack &&
            !inSwap &&
            block.timestamp >= (_lastRewardTime + 30 minutes);
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
        uint256 userTotal = _hyperBalances[_address].div(_hypersPerFragment);
        uint256 totalCap = userTotal.mul(1000).div(getTokensInLPCirculation());
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

    function setAutoAddLiquidity(bool _flag) external onlyOwner {
        if(_flag) {
            _autoAddLiquidity = _flag;
            _lastAddLiquidityTime = block.timestamp;
        } else {
            _autoAddLiquidity = _flag;
        }
    }

    function setAutoSwapBack(bool _flag) external onlyOwner {
        if (_flag) {
            _autoSwapBack = _flag;
            _lastRewardTime = block.timestamp;
        } else {
            _autoSwapBack = _flag;
        }
    }

    function setAutoSwapBackTrigger(bool _flag) external onlyOwner {
        _autoSwapBackTrigger = _flag;
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
            (TOTAL_HYPERS.sub(_hyperBalances[BURN]).sub(_hyperBalances[DEAD]).sub(
                _hyperBalances[ZERO])).div(_hypersPerFragment);
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
        address _rebaserWallet
    ) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        treasuryReceiver = _treasuryReceiver;
        RFVWallet = _RFVWallet;
        rebaserWallet = _rebaserWallet;
    }

    function setFees(
        uint256 _wzerRewardFee,
        uint256 _tempChampWZERFee,
        uint256 _liquidityFee,
        uint256 _rfvFee,
        uint256 _treasuryFee,
        uint256 _hyperChampFee,
        uint256 _battleFee,
        uint256 _rebaserFee,
        uint256 _referralFee,
        uint256 _sellReferralFee
    ) external onlyOwner {
        uint256 _totalFee = _wzerRewardFee;
        _totalFee = _totalFee.add(_tempChampWZERFee).add(_liquidityFee).add(_rfvFee);
        _totalFee = _totalFee.add(_treasuryFee).add(_hyperChampFee).add(_battleFee);
        _totalFee = _totalFee.add(_rebaserFee).add(_referralFee).add(_sellReferralFee);
        require(_totalFee < 500, "Invalid Fee");
        wzerRewardFee = _wzerRewardFee;
        tempChampWZERFee = _tempChampWZERFee;
        liquidityFee = _liquidityFee;
        rfvFee = _rfvFee;
        treasuryFee = _treasuryFee;
        hyperChampFee = _hyperChampFee;
        battleFee = _battleFee;
        rebaserFee = _rebaserFee;
        referralFee = _referralFee;
        sellReferralFee = _sellReferralFee;
    }

    function setExtraFees(
        uint256 _extraWZERRewardFee,
        uint256 _extraBattleFee,
        uint256 _extraSellReferralFee,
        uint256 _transferReferralFee,
        uint256 _maxBracketTax
    ) external onlyOwner {
        uint256 _extraTotalFee = _extraWZERRewardFee.add(_extraBattleFee).add(_extraSellReferralFee);
        require(_extraTotalFee < 500, "Invalid Fee");
        require(_transferReferralFee < 500, "Invalid Fee");
        require(_maxBracketTax < 500, "Invalid Fee");

        extraWZERRewardFee = _extraWZERRewardFee;
        extraBattleFee = _extraBattleFee;
        extraSellReferralFee = _extraSellReferralFee;
        transferReferralFee = _transferReferralFee;
        maxBracketTax = _maxBracketTax;
    }

    function getLiquidityBacking(uint256 accuracy)
        external
        view
        returns (uint256)
    {
        uint256 liquidityBalance = 0;
        for (uint256 i = 0; i < pairs.length; i++) {
            liquidityBalance = liquidityBalance.add(
                _hyperBalances[pairs[i]].div(_hypersPerFragment));
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

    function setRouter(address _router) external onlyOwner {
        require(isContract(_router), "only contract address");
        router = IPancakeSwapRouter(_router);
        _allowedFragments[address(this)][address(_router)] = MAX_UINT256;
    }

    function updateStartTime(uint256 _startTime) external onlyOwner {
        require(_initRebaseStartTime > block.timestamp, "Rebase have been already begun.");
        _initRebaseStartTime = _startTime;
        _lastRebasedTime = _startTime;
        _lastAddLiquidityTime = _startTime;
        _lastRewardTime = _startTime;
    }

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "Hypercube: The dividend tracker already has that address");

        IHypercubeDividendTracker newDividendTracker = IHypercubeDividendTracker(payable(newAddress));

        require(newDividendTracker.owner() == address(this), "Hypercube: The new dividend tracker must be owned by the Hypercube token contract");

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(DEAD);
        newDividendTracker.excludeFromDividends(BURN);
        newDividendTracker.excludeFromDividends(address(router));
        for (uint256 i = 0; i < pairs.length; i++) {
            newDividendTracker.excludeFromDividends(address(pairs[i]));
        }

        emit UpdateDividendTracker(newAddress, address(dividendTracker));
        dividendTracker = newDividendTracker;
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "Hypercube: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "Hypercube: Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns(uint256) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function withdrawableDividendOf(address account) public view returns(uint256) {
        return dividendTracker.withdrawableDividendOf(account);
    }

    function dividendTokenBalanceOf(address account) public view returns (uint256) {
        return dividendTracker.balanceOf(account);
    }

    function excludeFromDividends(address account) external onlyOwner{
        dividendTracker.excludeFromDividends(account);
    }

    function getAccountDividendsInfo(address account)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return dividendTracker.getAccount(account);
    }

    function getAccountDividendsInfoAtIndex(uint256 index)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return dividendTracker.getAccountAtIndex(index);
    }

    function processDividendTracker(uint256 gas) external {
        (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
        emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }

    function claim() external {
        dividendTracker.processAccount(payable(msg.sender), false);
    }

    function getLastProcessedIndex() external view returns(uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function updateReferralSystem(address _referralSystem) external onlyOwner {
        referralSystem = IReferralSystem(_referralSystem);
    }

    function updateBattle(address _battle) external onlyOwner {
        battle = IBattle(_battle);
        IERC20(WZER).approve(_battle, MAX_UINT256);
        _allowedFragments[address(this)][_battle] = MAX_UINT256;
        _isFeeExempt[_battle] = true;
        dividendTracker.excludeFromDividends(_battle);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    receive() external payable {}
}