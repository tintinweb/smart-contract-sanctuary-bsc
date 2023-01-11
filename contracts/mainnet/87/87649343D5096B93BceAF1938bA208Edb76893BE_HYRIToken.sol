/**
 *Submitted for verification at BscScan.com on 2023-01-11
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

interface InterfaceLP {
    function sync() external;
}

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint8 _tokenDecimals
    ) {
        _name = _tokenName;
        _symbol = _tokenSymbol;
        _decimals = _tokenDecimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

interface IDEXRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
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
        require(msg.sender == _owner, "Not owner");
        _;
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

contract HYRIToken is ERC20Detailed {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    address owner;

    bool public initialDistributionFinished = false;
    bool public swapEnabled = false;
    bool public autoRebase = false;
    bool public feesOnNormalTransfers = false;
    bool public feesOnEarlyWithdrawal = true;

    uint256 public rewardYield = 405625;
    uint256 public rewardYieldDenominator = 1000000000;

    uint256 public rebaseFrequency = 3600;
    uint256 public nextRebase = block.timestamp + 432000;

    mapping (address => bool) _isFeeExempt;
    address[] public _markerPairs;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping (address => uint256) private userInitialAmount;

    uint256 private constant MAX_REBASE_FREQUENCY = 3600;
    uint256 private constant DECIMALS = 18;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 10 * 10**8 * 10**DECIMALS;
    uint256 private TOTAL_GONS;
    uint256 private constant MAX_SUPPLY = ~uint256(0);

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public liquidityReceiver = 0x2BE0F51a532b504C7e2C31D211C738246fb04e83;
    address public treasuryReceiver = 0x441A235eC69AE8cA9EbDC664C31d1D2124da6433;
    address public riskFreeValueReceiver = 0x1C659FB3c4498B8e6c366D49B4Ca30B1CC53eAf0;
    address public futureEcosystemReceiver = 0x1e9A07Ef8083917dC570Ec7d3fe6F3eC9Dd6F9E6;
    address public burnReceiver = DEAD;

    IDEXRouter public router;
    address public pair;

    /*
        0: Buy Fee
        1: Sell Fee
        2: Whale Sell Fee 
    */
    uint256[3] public totalFee          = [500, 800, 2000];
    uint256[3] public liquidityFee      = [150, 320, 500];
    uint256[3] public treasuryFee       = [200, 0, 500];
    uint256[3] public riskFeeValueFee   = [100, 200, 500];
    uint256[3] public ecosystemFee      = [50, 80, 250];
    uint256[3] public burnFee           = [0, 200, 250];
    uint256 public feeDenominator       = 10000;

    uint256 public purchasePeriod       = 60 * 60 * 24;
    uint256 public earlyWhalePeriod     = 60 * 60 * 24 * 7;

    uint256 targetLiquidity = 50;
    uint256 earlyWhaleFee = 30;
    uint256 targetLiquidityDenominator = 100;

    struct TokenSellInfo {
        uint256 startTime;
        uint256 sellAmount;
    }

    bool inSwap;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "HYRIToken: Caller is not owner of the contract.");
        _;
    }

    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;
    uint256 private gonSwapThreshold = (TOTAL_GONS * 10).div(10000);

    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => TokenSellInfo) public _userSellInfos;

    constructor(address _router) ERC20Detailed("Hyperion", "HYRI", uint8(DECIMALS)) {
        owner = msg.sender;
        TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
        router = IDEXRouter(_router);
        pair = IDEXFactory(router.factory()).createPair(address(this), router.WETH());

        _allowedFragments[address(this)][address(router)] = ~uint256(0);
        _allowedFragments[address(this)][pair] = ~uint256(0);
        _allowedFragments[address(this)][address(this)] = ~uint256(0);

        setAutomatedMarketMakerPair(pair, true);

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[msg.sender] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        _isFeeExempt[liquidityReceiver] = true;
        _isFeeExempt[treasuryReceiver] = true;
        _isFeeExempt[riskFreeValueReceiver] = true;
        _isFeeExempt[futureEcosystemReceiver] = true;
        _isFeeExempt[burnReceiver] = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[msg.sender] = true;

        emit Transfer(address(0x0), msg.sender, _totalSupply);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function allowance(address owner_, address spender) external view override returns (uint256) {
        return _allowedFragments[owner_][spender];
    }

    function balanceOf(address who) public view override returns (uint256) {
        if (automatedMarketMakerPairs[who])
            return _gonBalances[who];
        else
            return _gonBalances[who].div(_gonsPerFragment);
    }

    function initialBalanceOf(address who) public view returns (uint256) {
        return userInitialAmount[who];
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function checkSwapThreshold() external view returns (uint256) {
        return gonSwapThreshold.div(_gonsPerFragment);
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function shouldRebase() internal view returns (bool) {
        return nextRebase <= block.timestamp;
    }

    function shouldTakeFee(address from, address to) internal view returns (bool) {
        if (_isFeeExempt[from] || _isFeeExempt[to]) {
            return false;
        } else if (feesOnNormalTransfers) {
            return true;
        } else {
            return (automatedMarketMakerPairs[from] || automatedMarketMakerPairs[to]);
        }
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            !automatedMarketMakerPairs[msg.sender] &&
            !inSwap &&
            swapEnabled &&
            totalFee[0] + totalFee[1] > 0 &&
            _gonBalances[address(this)] >= gonSwapThreshold;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(_gonsPerFragment);
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        uint256 liquidityBalance = 0;
        for (uint i = 0; i < _markerPairs.length; i++){
            liquidityBalance.add(balanceOf(_markerPairs[i]).div(10 ** 9));
        }
        return accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply().div(10 ** 9));
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    function setOwner(address _owner) external onlyOwner {
        owner = _owner;
    }

    function manualSync() public {
        for (uint i = 0; i < _markerPairs.length; i++){
            InterfaceLP(_markerPairs[i]).sync();
        }
    }

    function transfer(address to, uint256 value) external override validRecipient(to) returns (bool) {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function _basicTransfer(address from, address to, uint256 amount) internal returns (bool) {
        uint256 gonAddAmount = amount.mul(_gonsPerFragment);
        uint256 gonSubAmount = amount.mul(_gonsPerFragment);

        if (automatedMarketMakerPairs[from])
            gonSubAmount = amount;

        if (automatedMarketMakerPairs[to])
            gonAddAmount = amount;

        _gonBalances[from] = _gonBalances[from].sub(gonSubAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAddAmount);

        emit Transfer(from, to, amount);
        return true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool excludedAccount = _isFeeExempt[sender] || _isFeeExempt[recipient];

        require(initialDistributionFinished || excludedAccount, "Trading not started");

        if (
            automatedMarketMakerPairs[recipient] &&
            !excludedAccount
        ) {
            if (block.timestamp - _userSellInfos[sender].startTime > purchasePeriod) {
                _userSellInfos[sender].startTime = block.timestamp;
                _userSellInfos[sender].sellAmount = 0;
            }
            
            require (_userSellInfos[sender].sellAmount + amount <= balanceOf(recipient) / 100 , "User can't sell more than 1% of pool balance");

            if (block.timestamp - _userSellInfos[sender].startTime < earlyWhalePeriod)
                amount = amount * earlyWhaleFee / targetLiquidityDenominator;

            _userSellInfos[sender].sellAmount += amount;
        }

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);

        if (shouldSwapBack()) {
            swapBack();
        }

        if (automatedMarketMakerPairs[sender]) {
            _gonBalances[sender] = _gonBalances[sender].sub(amount);
        }
        else {
            _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        }

        uint256 gonAmountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, gonAmount) : gonAmount;
        if (automatedMarketMakerPairs[recipient]) {
            _gonBalances[recipient] = _gonBalances[recipient].add(gonAmountReceived.div(_gonsPerFragment));
        }
        else {
            _gonBalances[recipient] = _gonBalances[recipient].add(gonAmountReceived);
            userInitialAmount[recipient] = userInitialAmount[recipient].add(gonAmountReceived);
        }

        emit Transfer(sender, recipient, gonAmountReceived.div(_gonsPerFragment));

        if (shouldRebase() && autoRebase) {
            _rebase();

            if (!automatedMarketMakerPairs[sender] && !automatedMarketMakerPairs[recipient]) {
                manualSync();
            }
        }

        return true;
    }

    function transferFrom(address from, address to, uint256 value) external override validRecipient(to) returns (bool) {
        if (_allowedFragments[from][msg.sender] != ~uint256(0)) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender].sub(value, "Insufficient Allowance");
        }

        _transferFrom(from, to, value);
        return true;
    }

    function _swapAndLiquify(uint256 contractTokenBalance) private {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        uint256 initialBalance = address(this).balance;

        _swapTokensForBNB(half, address(this));

        uint256 newBalance = address(this).balance.sub(initialBalance);

        _addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function _addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner,
            block.timestamp
        );
    }

    function _swapTokensForBNB(uint256 tokenAmount, address receiver) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            receiver,
            block.timestamp
        );
    }

    function swapBack() internal swapping {
        uint256 realTotalFee = totalFee[0].add(totalFee[1]).add(totalFee[2]);

        uint256 contractTokenBalance = _gonBalances[address(this)].div(_gonsPerFragment);

        uint256 amountToLiquify = 0;
        if (!isOverLiquified(targetLiquidity, targetLiquidityDenominator))
            amountToLiquify = contractTokenBalance.mul(liquidityFee[0] + liquidityFee[1] + liquidityFee[2]).div(realTotalFee);
        uint256 amountToRFV = contractTokenBalance.mul(riskFeeValueFee[0] + riskFeeValueFee[1] + riskFeeValueFee[2]).div(realTotalFee);
        uint256 amountToTreasury = contractTokenBalance.mul(treasuryFee[0] + treasuryFee[1] + treasuryFee[2]).div(realTotalFee);
        uint256 amountToEcosystem = contractTokenBalance.mul(ecosystemFee[0] + ecosystemFee[1] + ecosystemFee[2]).div(realTotalFee);
        uint256 amountToBurn = contractTokenBalance - amountToLiquify - amountToRFV - amountToTreasury - amountToEcosystem;

        if (amountToLiquify > 0) {
            _swapAndLiquify(amountToLiquify);
        }

        if (amountToRFV > 0) {
            _swapTokensForBNB(amountToRFV, riskFreeValueReceiver);
        }

        if (amountToTreasury > 0) {
            _swapTokensForBNB(amountToTreasury, treasuryReceiver);
        }

        if (amountToEcosystem > 0) {
            _swapTokensForBNB(amountToEcosystem, futureEcosystemReceiver);
        }

        if (amountToBurn > 0) {
            _basicTransfer(address(this), burnReceiver, amountToBurn);
        }

        emit SwapBack(contractTokenBalance, amountToLiquify, amountToRFV, amountToTreasury);
    }

    function takeFee(address sender, address recipient, uint256 gonAmount) internal returns (uint256) {
        uint256 _realFee = totalFee[0];
        if(automatedMarketMakerPairs[recipient]) {
            _realFee = totalFee[1];
            if (feesOnEarlyWithdrawal) {
                _realFee = totalFee[2];
            }
        }

        uint256 feeAmount = gonAmount.div(feeDenominator).mul(_realFee);

        _gonBalances[address(this)] = _gonBalances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));
        return gonAmount.sub(feeAmount);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        uint256 oldValue = _allowedFragments[msg.sender][spender];

        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);
        }

        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    function approve(address spender, uint256 value) external override returns (bool) {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function _rebase() private {
        if (!inSwap) {
            uint256 circulatingSupply = getCirculatingSupply();
            int256 supplyDelta = int256(circulatingSupply.mul(rewardYield).div(rewardYieldDenominator));

            coreRebase(supplyDelta);
        }
    }

    function coreRebase(int256 supplyDelta) private returns (uint256) {
        uint256 epoch = block.timestamp;

        if (supplyDelta == 0) {
            emit LogRebase(epoch, _totalSupply);
            return _totalSupply;
        }

        if (supplyDelta < 0) {
            _totalSupply = _totalSupply.sub(uint256(-supplyDelta));
        } else {
            _totalSupply = _totalSupply.add(uint256(supplyDelta));
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        nextRebase = epoch + rebaseFrequency;

        emit LogRebase(epoch, _totalSupply);
        return _totalSupply;
    }

    function manualRebase() external onlyOwner {
        require(!inSwap, "Try again");
        require(nextRebase <= block.timestamp, "Not in time");

        uint256 circulatingSupply = getCirculatingSupply();
        int256 supplyDelta = int256(circulatingSupply.mul(rewardYield).div(rewardYieldDenominator));

        coreRebase(supplyDelta);
        manualSync();
    }

    function setAutomatedMarketMakerPair(address _pair, bool _value) public onlyOwner {
        require(automatedMarketMakerPairs[_pair] != _value, "Value already set");

        automatedMarketMakerPairs[_pair] = _value;

        if (_value) {
            _markerPairs.push(_pair);
        } else {
            require(_markerPairs.length > 1, "Required 1 pair");
            for (uint256 i = 0; i < _markerPairs.length; i++) {
                if (_markerPairs[i] == _pair) {
                    _markerPairs[i] = _markerPairs[_markerPairs.length - 1];
                    _markerPairs.pop();
                    break;
                }
            }
        }

        emit SetAutomatedMarketMakerPair(_pair, _value);
    }

    function setInitialDistributionFinished(bool _value) external onlyOwner {
        require(initialDistributionFinished != _value, "Not changed");
        initialDistributionFinished = _value;
    }

    function setFeeExempt(address _addr, bool _value) external onlyOwner {
        require(_isFeeExempt[_addr] != _value, "Not changed");
        _isFeeExempt[_addr] = _value;
    }

    function setTargetLiquidity(uint256 target, uint256 accuracy) external onlyOwner {
        targetLiquidity = target;
        targetLiquidityDenominator = accuracy;
    }

    function setSwapBackSettings(bool _enabled, uint256 _num, uint256 _denom) external onlyOwner {
        swapEnabled = _enabled;
        gonSwapThreshold = TOTAL_GONS.div(_denom).mul(_num);
    }

    function setFeeReceivers(address _liquidityReceiver, address _treasuryReceiver, address _riskFreeValueReceiver, address _futureEcosystemReceiver, address _burnReceiver) external onlyOwner {
        liquidityReceiver = _liquidityReceiver;
        treasuryReceiver = _treasuryReceiver;
        riskFreeValueReceiver = _riskFreeValueReceiver;
        futureEcosystemReceiver = _futureEcosystemReceiver;
        burnReceiver = _burnReceiver;
    }

    function setFees(uint8 _feeKind, uint256 _total, uint256 _liquidityFee, uint256 _riskFreeValue, uint256 _treasuryFee, uint256 _feeFee, uint256 _burnFee) external onlyOwner {
        require (_liquidityFee + _riskFreeValue + _treasuryFee + _feeFee + _burnFee == 100, "subFee is not allowed");

        totalFee[_feeKind] = _total * 100;
        liquidityFee[_feeKind] = _total * _liquidityFee;
        treasuryFee[_feeKind] = _total * _treasuryFee;
        riskFeeValueFee[_feeKind] = _total * _riskFreeValue;
        ecosystemFee[_feeKind] = _total * _feeFee;
        burnFee[_feeKind] = _total * _burnFee;
    }

    function clearStuckBalance(address _receiver) external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_receiver).transfer(balance);
    }

    function rescueToken(address tokenAddress, uint256 tokens) external onlyOwner returns (bool success) {
        return ERC20Detailed(tokenAddress).transfer(msg.sender, tokens);
    }
    
    function setRouterAddress(address _router) external onlyOwner {
        router = IDEXRouter(_router);
    }

    function setAutoRebase(bool _autoRebase) external onlyOwner {
        require(autoRebase != _autoRebase, "Not changed");
        autoRebase = _autoRebase;
    }

    function setRebaseFrequency(uint256 _rebaseFrequency) external onlyOwner {
        require(_rebaseFrequency <= MAX_REBASE_FREQUENCY, "Too high");
        rebaseFrequency = _rebaseFrequency;
    }

    function setRewardYield(uint256 _rewardYield, uint256 _rewardYieldDenominator) external onlyOwner {
        rewardYield = _rewardYield;
        rewardYieldDenominator = _rewardYieldDenominator;
    }

    function setFeesOnEarlyWithdrawal(bool _enabled) external onlyOwner {
        require(feesOnEarlyWithdrawal != _enabled, "Not changed");
        feesOnEarlyWithdrawal = _enabled;
    }

    function setFeesOnNormalTransfers(bool _enabled) external onlyOwner {
        require(feesOnNormalTransfers != _enabled, "Not changed");
        feesOnNormalTransfers = _enabled;
    }

    function setNextRebase(uint256 _nextRebase) external onlyOwner {
        nextRebase = _nextRebase;
    }

    function setPurchasePeriod(uint256 _time) external onlyOwner {
        purchasePeriod = _time;
    }

    function setEarlyWhalePeriod(uint256 _time) external onlyOwner {
        earlyWhalePeriod = _time;
    }

    function setEarlyWhaleFee(uint256 _fee) external onlyOwner {
        earlyWhaleFee = _fee;
    }

    event SwapBack(uint256 contractTokenBalance,uint256 amountToLiquify,uint256 amountToRFV,uint256 amountToTreasury);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    receive() payable external {}

    fallback() payable external {}
}