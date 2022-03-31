/**
 *Submitted for verification at BscScan.com on 2022-03-31
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

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

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint8 tokenDecimals
    ) {
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = tokenDecimals;
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

interface InterfaceLP {
    function sync() external;
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

contract Adamantium is ERC20Detailed, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    uint256 private constant DECIMALS = 18;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant MAX_SUPPLY = ~uint128(0);
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY =
        40_000_000 * 10**DECIMALS;
    uint256 private constant TOTAL_GONS =
        MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    uint256 private constant REWARD_YIELD = 405861;
    uint256 private constant REWARD_YIELD_DENOMINATOR = 1e9;
    uint256 private constant REBASE_FREQUENCY = 1800;

    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address private constant ZERO = 0x0000000000000000000000000000000000000000;

    IDEXRouter public router;
    InterfaceLP public pairContract;
    address private _pair;

    bool public initialDistributionFinished = false;

    uint256 public liquidityFee = 5;
    uint256 public treasuryFee = 5;
    uint256 public riskFreeValueFee = 5;
    uint256 public sellFee = 5;
    uint256 public totalFee =
        liquidityFee.add(treasuryFee).add(riskFreeValueFee);
    uint256 public feeDenominator = 100;

    uint256 public nextRebase = block.timestamp + REBASE_FREQUENCY;

    address public treasuryReceiver;
    address public riskFreeValueReceiver;

    uint256 private _targetLiquidity = 50;
    uint256 private _targetLiquidityDenominator = 100;

    bool public swapEnabled = true;
    uint256 private _gonSwapThreshold = (TOTAL_GONS * 10) / 10000;
    bool public inSwap;

    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;
    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;

    mapping(address => bool) public isFeeExempt;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event SetTargetLiquidity(uint256 indexed target, uint256 indexed accuracy);
    event SetSwapBackSettings(
        bool indexed enabled,
        uint256 indexed num,
        uint256 indexed denum
    );
    event SetFeeReceivers(
        address indexed _treasuryReceiver,
        address indexed _riskFreeValueReceiver
    );
    event SetFeeExempt(address indexed addy, bool indexed value);

    modifier validRecipient(address to) {
        require(to != address(0x0), "invalid address");
        _;
    }

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        address _router,
        address _treasuryReceiver,
        address _riskFreeValueReceiver
    ) ERC20Detailed("TEST", "ATEST", uint8(DECIMALS)) {
        router = IDEXRouter(_router);
        _pair = IDEXFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        treasuryReceiver = _treasuryReceiver;
        riskFreeValueReceiver = _riskFreeValueReceiver;

        _allowedFragments[address(this)][address(router)] = uint256(-1);
        _allowedFragments[address(this)][_pair] = uint256(-1);
        _allowedFragments[address(this)][address(this)] = uint256(-1);

        pairContract = InterfaceLP(_pair);

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[msg.sender] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        isFeeExempt[treasuryReceiver] = true;
        isFeeExempt[riskFreeValueReceiver] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[msg.sender] = true;

        emit Transfer(address(0x0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    /**
     * @notice Everyone can call rebase. This ensures the rebase can be done even without contract owner's intervention
     */
    function rebase() external {
        require(initialDistributionFinished, "Not enabled");
        require(!inSwap, "In swap: try again");
        require(nextRebase <= block.timestamp, "Too early");

        uint256 epoch = block.timestamp;
        uint256 circulatingSupply = getCirculatingSupply();
        int256 supplyDelta = int256(
            circulatingSupply.mul(REWARD_YIELD).div(REWARD_YIELD_DENOMINATOR)
        );

        _coreRebase(epoch, supplyDelta);
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
        if (_allowedFragments[from][msg.sender] != uint256(-1)) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
                msg.sender
            ].sub(value, "Insufficient Allowance");
        }

        _transferFrom(from, to, value);
        return true;
    }

    function setInitialDistributionFinished() external onlyOwner {       
        initialDistributionFinished = true;
    }

    function setFeeExempt(address _addr, bool _value) external onlyOwner {
        require(isFeeExempt[_addr] != _value, "Not changed");
        isFeeExempt[_addr] = _value;

        emit SetFeeExempt(_addr, _value);
    }

    function setSwapBackSettings(
        bool _enabled,
        uint256 _num,
        uint256 _denom
    ) external onlyOwner {
        swapEnabled = _enabled;
        _gonSwapThreshold = TOTAL_GONS.div(_denom).mul(_num);
        emit SetSwapBackSettings(_enabled, _num, _denom);
    }

    function setTargetLiquidity(uint256 target, uint256 accuracy)
        external
        onlyOwner
    {
        _targetLiquidity = target;
        _targetLiquidityDenominator = accuracy;
        emit SetTargetLiquidity(target, accuracy);
    }

    function setFeeReceivers(
        address _treasuryReceiver,
        address _riskFreeValueReceiver
    ) external onlyOwner {
        require(_treasuryReceiver != address(0), "_treasuryReceiver not set");
        require(
            _riskFreeValueReceiver != address(0),
            "_riskFreeValueReceiver not set"
        );
        treasuryReceiver = _treasuryReceiver;
        riskFreeValueReceiver = _riskFreeValueReceiver;
        emit SetFeeReceivers(_treasuryReceiver, _riskFreeValueReceiver);
    }

    function setFees(
        uint256 _liquidityFee,
        uint256 _riskFreeValueFee,
        uint256 _treasuryFee,
        uint256 _sellFee,
        uint256 _feeDenominator
    ) external onlyOwner {
        liquidityFee = _liquidityFee;
        riskFreeValueFee = _riskFreeValueFee;
        treasuryFee = _treasuryFee;
        sellFee = _sellFee;
        totalFee = liquidityFee.add(treasuryFee).add(riskFreeValueFee);
        feeDenominator = _feeDenominator;
        // totalFee max 25%
        require(totalFee < feeDenominator / 4);
    }

    function manualSync() external {
        pairContract.sync();
    }

    function manualSwapBack() external onlyOwner {
        _doSwapBack();
    }

    function clearStuckBalance(address _receiver)
        external
        onlyOwner
        validRecipient(_receiver)
    {
        uint256 balance = address(this).balance;
        payable(_receiver).transfer(balance);
    }

    function rescueToken(address _tokenAddress)
        external
        onlyOwner
        returns (bool success)
    {
        require(_tokenAddress != address(this), "Can't withdraw ADM");
        uint256 balance = IERC20(_tokenAddress).balanceOf(address(this));
        return IERC20(_tokenAddress).transfer(msg.sender, balance);
    }
    
    function checkSwapThreshold() external view returns (uint256) {
        return _gonSwapThreshold.div(_gonsPerFragment);
    }

    function getGonBalances()
        external
        view
        returns (bool thresholdReturn, uint256 gonBalanceReturn)
    {
        thresholdReturn = _gonBalances[address(this)] >= _gonSwapThreshold;
        gonBalanceReturn = _gonBalances[address(this)];
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function allowance(address owner_, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    function balanceOf(address who) external view override returns (uint256) {
        return _gonBalances[who].div(_gonsPerFragment);
    }

    function getLiquidityBacking(uint256 accuracy)
        public
        view
        returns (uint256)
    {
        uint256 liquidityBalance = _gonBalances[_pair].div(_gonsPerFragment);
        return
            accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    function getCirculatingSupply() public view returns (uint256) {
        return
            (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(
                _gonsPerFragment
            );
    }

    function isOverLiquified(uint256 target, uint256 accuracy)
        public
        view
        returns (bool)
    {
        return getLiquidityBacking(accuracy) > target;
    }

    function _coreRebase(uint256 epoch, int256 supplyDelta)
        private
        returns (uint256)
    {
        nextRebase = epoch + REBASE_FREQUENCY;
        if (supplyDelta == 0) {
            emit LogRebase(epoch, _totalSupply);
            return _totalSupply;
        }

        _totalSupply = _totalSupply.add(uint256(supplyDelta));

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        pairContract.sync();

        emit LogRebase(epoch, _totalSupply);
        return _totalSupply;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) private returns (bool) {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) private returns (bool) {
        bool excludedAccount = isFeeExempt[sender] || isFeeExempt[recipient];

        require(
            initialDistributionFinished || excludedAccount,
            "Trading not started"
        );

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);

        if (_shouldSwapBack()) {
            swapBack();
        }

        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);

        uint256 gonAmountReceived = _shouldTakeFee(sender, recipient)
            ? _takeFee(sender, recipient, gonAmount)
            : gonAmount;
        _gonBalances[recipient] = _gonBalances[recipient].add(
            gonAmountReceived
        );

        emit Transfer(
            sender,
            recipient,
            gonAmountReceived.div(_gonsPerFragment)
        );
        return true;
    }

    function _doSwapBack() private {
        uint256 dynamicLiquidityFee = isOverLiquified(
            _targetLiquidity,
            _targetLiquidityDenominator
        )
            ? 0
            : liquidityFee;
        uint256 contractTokenBalance = _gonBalances[address(this)].div(
            _gonsPerFragment
        );
        uint256 amountToLiquify = contractTokenBalance
            .mul(dynamicLiquidityFee)
            .div(totalFee)
            .div(2);
        uint256 amountToSwap = contractTokenBalance.sub(amountToLiquify);

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

        uint256 amountETH = address(this).balance.sub(balanceBefore);

        uint256 totalETHFee = totalFee.sub(dynamicLiquidityFee.div(2));

        uint256 amountETHLiquidity = amountETH
            .mul(dynamicLiquidityFee)
            .div(totalETHFee)
            .div(2);
        uint256 amountETHRiskFreeValue = amountETH.mul(riskFreeValueFee).div(
            totalETHFee
        );
        uint256 amountETHTreasury = amountETH.mul(treasuryFee).div(totalETHFee);

        (bool success, ) = payable(treasuryReceiver).call{
            value: amountETHTreasury,
            gas: 30000
        }("");
        (success, ) = payable(riskFreeValueReceiver).call{
            value: amountETHRiskFreeValue,
            gas: 30000
        }("");

        success = false;

        if (amountToLiquify > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                DEAD,
                block.timestamp
            );
        }
    }

    function swapBack() private swapping {
        _doSwapBack();
    }

    function _takeFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) private returns (uint256) {
        uint256 _totalFee = totalFee;
        if (recipient == _pair) _totalFee = _totalFee.add(sellFee);

        uint256 feeAmount = gonAmount.mul(_totalFee).div(feeDenominator);

        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            feeAmount
        );
        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));

        return gonAmount.sub(feeAmount);
    }

    function _shouldTakeFee(address from, address to)
        private
        view
        returns (bool)
    {
        if (isFeeExempt[from] || isFeeExempt[to]) {
            return false;
        }
        return _pair == from || _pair == to;
    }

    function _shouldSwapBack() private view returns (bool) {
        return
            msg.sender != _pair &&
            !inSwap &&
            swapEnabled &&
            _gonBalances[address(this)] >= _gonSwapThreshold;
    }
}