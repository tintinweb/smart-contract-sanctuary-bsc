/**
 *Submitted for verification at BscScan.com on 2022-06-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a), 'mul overflow');
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a),
            'sub overflow');
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a),
            'add overflow');
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256,
            'abs overflow');
        return a < 0 ? -a : a;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Auth is Context{
    address owner;
    mapping (address => bool) private authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender)); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender)); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
        emit Authorized(adr);
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
        emit Unauthorized(adr);
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        authorizations[msg.sender] = false;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
    event Authorized(address adr);
    event Unauthorized(address adr);
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
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
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
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
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

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface ILiquidityProvider {
    function sync() external;
}


contract abc is ERC20Detailed, Auth {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    bool public initialDistributionFinished = true;
    bool public swapEnabled = true;

    uint256 public rebaseIndex = 1 * 10**18;
    uint256 private oneEEighteen = 1 * 10**18;
    uint256 private REWARD_YIELD_DENOMINATOR = 10000000000000000;
    uint256 public rewardYield = 4166700000000; 
    uint256 public maxSellTransactionAmount = 5000 * 10**18;

    uint256 public rebaseFrequency = 1800;
    uint256 public nextRebase = block.timestamp;
    uint256 public rebaseEpoch = 0;
    uint256 public _markerPairCount;
    
    address[] public _markerPairs;
    
    mapping(address => bool) _isFeeExempt;
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) public blacklist;

    uint256 private constant MAX_FEE_RATE = 300;
    uint256 private constant MIN_SELL_AMOUNT_RATE = 5000 * 10**18;
    uint256 private constant MAX_REBASE_FREQUENCY = 1800;
    uint256 private constant feeDenominator = 1000;

    uint256 private constant DECIMALS = 18;
    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY =
    50000000 * 10**DECIMALS;
    uint256 private constant TOTAL_GONS =
    MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
    uint256 private constant MAX_SUPPLY = ~uint128(0);

    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address private constant ZERO = 0x0000000000000000000000000000000000000000;

    address public liquidityReceiver =
    0xc0702Ae0374F83fc3bA71CE2B30A323b09EC19da;
    address public treasuryReceiver =
    0xEB6c4b5aC4822480860476FF543D77D3882244e1;
    address public riskFreeValueReceiver =
    0xEB6c4b5aC4822480860476FF543D77D3882244e1;

    IDEXRouter public router;
    IDEXFactory private factory;
    address public pair;
    IERC20 public usdtToken = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    uint256 public liquidityFee = 50;
    uint256 public treasuryFee = 50;
    uint256 public buyFeeRFV = 50;
    uint256 public sellFeeTreasuryAdded = 50;
    uint256 public sellFeeRFVAdded = 10;
    uint256 public sellFeeLiquidityAdded = 50;
    uint256 public totalBuyFee = liquidityFee.add(treasuryFee).add(buyFeeRFV);
    uint256 public totalSellFee = totalBuyFee.add(sellFeeTreasuryAdded).add(sellFeeRFVAdded).add(sellFeeLiquidityAdded);

    bool inSwap;

    modifier swapping() {
        require (inSwap == false, "In swap already");
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier validRecipient(address to) {
        require(to != address(0x0),
            'recipient is not valid');
        _;
    }

    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;
    uint256 private gonSwapThreshold = (TOTAL_GONS * 10) / 10000;
    
    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;

    constructor() ERC20Detailed('abc', 'abc', uint8(DECIMALS)) Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        pair = IDEXFactory(router.factory()).createPair(
            address(this),
            address(usdtToken)
        );

        _allowedFragments[address(this)][address(router)] = uint256(-1);
        _allowedFragments[address(this)][pair] = uint256(-1);
        _allowedFragments[address(this)][address(this)] = uint256(-1);

        setAutomatedMarketMakerPair(pair, true);

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[msg.sender] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        _isFeeExempt[treasuryReceiver] = true;
        _isFeeExempt[riskFreeValueReceiver] = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[msg.sender] = true;

        IERC20(usdtToken).approve(address(router), type(uint256).max);
        IERC20(usdtToken).approve(address(pair), type(uint256).max);
        IERC20(usdtToken).approve(address(this), type(uint256).max);

        emit Transfer(address(0x0), msg.sender, _totalSupply);
    }

    receive() external payable {}

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

    function balanceOf(address who) public view override returns (uint256) {
        return _gonBalances[who].div(_gonsPerFragment);
    }

    function markerPairAddress(uint256 value) public view returns (address) {
        return _markerPairs[value];
    }

    function currentIndex() public view returns (uint256) {
        return rebaseIndex;
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function checkSwapThreshold() external view returns (uint256) {
        return gonSwapThreshold.div(_gonsPerFragment);
    }


    function shouldTakeFee(address from, address to)
    internal
    view
    returns (bool)
    {
        if (_isFeeExempt[from] || _isFeeExempt[to]) {
            return false;
        } else {
            return (automatedMarketMakerPairs[from] ||
            automatedMarketMakerPairs[to]);
        }
    }

    function shouldSwapBack() internal view returns (bool) {
        return
        !automatedMarketMakerPairs[msg.sender] &&
        !inSwap &&
        swapEnabled &&
        totalBuyFee.add(totalSellFee) > 0 &&
        _gonBalances[address(this)] >= gonSwapThreshold;
    }

    function getGonBalances() public view returns (bool thresholdReturn, uint256 gonBalanceReturn ) {
        thresholdReturn  = _gonBalances[address(this)] >= gonSwapThreshold;
        gonBalanceReturn = _gonBalances[address(this)];

    }

    function getCirculatingSupply() public view returns (uint256) {
        return
        (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(
            _gonsPerFragment
        );
    }

    function getCurrentTimestamp() public view returns (uint256) {
        return block.timestamp;
    }

    function manualSync() public {
        for (uint256 i = 0; i < _markerPairs.length; i++) {
            ILiquidityProvider(_markerPairs[i]).sync();
        }
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

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);

        emit Transfer(from, to, amount);

        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(!blacklist[sender] && !blacklist[recipient], 'in_blacklist');

        bool excludedAccount = _isFeeExempt[sender] || _isFeeExempt[recipient];

        require(
            initialDistributionFinished || excludedAccount,
            'Trading not started'
        );

        if (automatedMarketMakerPairs[recipient] && !excludedAccount) {
            require(amount <= maxSellTransactionAmount, 'Error amount');
        }

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);

        if (shouldSwapBack()) {
            swapBack();
        }

        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);

        uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
        ? takeFee(sender, recipient, gonAmount)
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

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {
        if (_allowedFragments[from][msg.sender] != uint256(-1)) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
            msg.sender
            ].sub(value, 'Insufficient Allowance');
        }

        _transferFrom(from, to, value);
        return true;
    }

    function _swapAndLiquify(uint256 contractTokenBalance) private {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
      
        uint256 initialBalance = IERC20(usdtToken).balanceOf(address(this));

        _swapTokensForBusd(half, address(this));

        uint256 newBalance = IERC20(usdtToken).balanceOf(address(this)).sub(initialBalance);

        _addLiquidityBusd(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
        
    
 }

    function _addLiquidityBusd(uint256 tokenAmount, uint256 busdAmount)
        private
    {
        router.addLiquidity(
            address(this),
            address(usdtToken),
            tokenAmount,
            busdAmount,
            0,
            0,
            liquidityReceiver,
            block.timestamp
        );
    }

    function _swapTokensForBusd(uint256 tokenAmount, address receiver) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdtToken);

        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            receiver,
            block.timestamp
        );
    }

    function swapBack() internal swapping {
        uint256 realTotalFee = totalBuyFee.add(totalSellFee);

        uint256 contractTokenBalance = _gonBalances[address(this)].div(
            _gonsPerFragment
        );

        uint256 amountToLiquify = contractTokenBalance
        .mul(liquidityFee.mul(2).add(sellFeeLiquidityAdded))
        .div(realTotalFee);

        uint256 amountToRFV = contractTokenBalance
        .mul(buyFeeRFV.mul(2).add(sellFeeRFVAdded))
        .div(realTotalFee);

        uint256 amountToTreasury = contractTokenBalance
        .sub(amountToLiquify)
        .sub(amountToRFV);

        if (amountToLiquify > 0) {
            _swapAndLiquify(amountToLiquify);
        }

        if (amountToRFV > 0) {
            _swapTokensForBusd(amountToRFV, riskFreeValueReceiver);
        }

        if (amountToTreasury > 0) {
            _swapTokensForBusd(amountToTreasury, treasuryReceiver);
        }

        emit SwapBack(
            contractTokenBalance,
            amountToLiquify,
            amountToRFV,
            amountToTreasury
        );
    }

    function manualSwapBack() external authorized {
        swapBack();
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) internal returns (uint256) {
        uint256 _realFee = totalBuyFee;

        if (automatedMarketMakerPairs[recipient]) {
            _realFee = totalSellFee;
        }

        uint256 feeAmount = gonAmount.mul(_realFee).div(feeDenominator);

        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            feeAmount
        );
        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));

        return gonAmount.sub(feeAmount);
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

    function coreRebase(int256 supplyDelta) private returns (uint256) {
        
        if (supplyDelta == 0) {
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

        updateRebaseIndex();
      
        return _totalSupply;
        
    }

    function manualRebase() external authorized {
        require(!inSwap, 'Try again');
        require(nextRebase <= block.timestamp, 'Not in time');
        int256 supplyDelta;
        int i = 0;

        do {
            supplyDelta = int256(_totalSupply.mul(rewardYield).div(REWARD_YIELD_DENOMINATOR));
            coreRebase(supplyDelta);
            emit LogManualRebase(supplyDelta, block.timestamp);
            i++;
        }
        while (nextRebase < block.timestamp && i < 100);

        manualSync();
    }

    function updateRebaseIndex() private {

        nextRebase += rebaseFrequency;

        rebaseIndex = rebaseIndex
        .mul(
            oneEEighteen.add(
                oneEEighteen.mul(rewardYield).div(REWARD_YIELD_DENOMINATOR)
            )
        )
        .div(oneEEighteen);

        rebaseEpoch += 1;
    }


    function setAutomatedMarketMakerPair(address _pair, bool _value)
    public
    onlyOwner
    {
        require(
            automatedMarketMakerPairs[_pair] != _value,
            'Value already set'
        );

        automatedMarketMakerPairs[_pair] = _value;

        if (_value) {
            _markerPairs.push(_pair);
            _markerPairCount++;
        } else {
            require(_markerPairs.length > 1, 'Required 1 pair');
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
        require(initialDistributionFinished != _value, 'Not changed');
        initialDistributionFinished = _value;

        emit SetInitialDistribution(_value);
    }

    function setFeeExempt(address _addr, bool _value) external onlyOwner {
        require(_isFeeExempt[_addr] != _value, 'Not changed');
        _isFeeExempt[_addr] = _value;

        emit SetFeeExempt(_addr, _value);
    }

    function setSwapBackSettings(
        bool _enabled,
        uint256 _num,
        uint256 _denom
    ) external onlyOwner {
        swapEnabled = _enabled;
        gonSwapThreshold = TOTAL_GONS.mul(_num).div(_denom);
        emit SetSwapBackSettings(_enabled, _num, _denom);
    }

    function setFeeReceivers(
        address _liquidityReceiver,
        address _treasuryReceiver,
        address _riskFreeValueReceiver
    ) external onlyOwner {
        require(_liquidityReceiver != address(0), '_liquidityReceiver not set');
        require(_treasuryReceiver != address(0), '_treasuryReceiver not set');
        require(
            _riskFreeValueReceiver != address(0),
            '_riskFreeValueReceiver not set'
        );
        liquidityReceiver = _liquidityReceiver;
        treasuryReceiver = _treasuryReceiver;
        riskFreeValueReceiver = _riskFreeValueReceiver;
        emit SetFeeReceivers(_liquidityReceiver, _treasuryReceiver, _riskFreeValueReceiver);
    }

    function setFees(
        uint256 _liquidityFee,
        uint256 _riskFreeValue,
        uint256 _treasuryFee,
        uint256 _sellFeeTreasuryAdded,
        uint256 _sellFeeRFVAdded,
        uint256 _sellFeeLiquidityAdded
    ) external authorized {

        require(
            _liquidityFee <= MAX_FEE_RATE &&
            _riskFreeValue <= MAX_FEE_RATE &&
            _treasuryFee <= MAX_FEE_RATE &&
            _sellFeeTreasuryAdded <= MAX_FEE_RATE &&
            _sellFeeRFVAdded <= MAX_FEE_RATE &&
            _sellFeeLiquidityAdded <= MAX_FEE_RATE,
            'set fee higher than max fee allowing'
        );

        uint256 maxTotalBuyFee = _liquidityFee.add(_treasuryFee).add(_riskFreeValue);

        uint256 maxTotalSellFee = maxTotalBuyFee.add(_sellFeeTreasuryAdded).add(_sellFeeRFVAdded).add(_sellFeeLiquidityAdded);

        require(maxTotalBuyFee <= MAX_FEE_RATE, 'exceeded max buy fees');

        require(maxTotalSellFee <= MAX_FEE_RATE, 'exceeded max sell fees');

        liquidityFee = _liquidityFee;
        buyFeeRFV = _riskFreeValue;
        treasuryFee = _treasuryFee;
        sellFeeTreasuryAdded = _sellFeeTreasuryAdded;
        sellFeeRFVAdded = _sellFeeRFVAdded;
        sellFeeLiquidityAdded = _sellFeeLiquidityAdded;
        totalBuyFee = liquidityFee.add(treasuryFee).add(buyFeeRFV);
        totalSellFee = totalBuyFee.add(sellFeeTreasuryAdded).add(sellFeeRFVAdded).add(sellFeeLiquidityAdded);

        emit SetFees(_liquidityFee, _riskFreeValue, _treasuryFee, _sellFeeTreasuryAdded, _sellFeeRFVAdded, _sellFeeLiquidityAdded, totalBuyFee, totalSellFee);
    }

    function setRouterPair(address _router, address _pair) external onlyOwner {
        require(_router != address(0x0), 'can not use 0x0 address');
        require(_pair != address(0x0), 'can not use 0x0 address');

        router = IDEXRouter(_router);
        pair = _pair;

        _allowedFragments[address(this)][address(router)] = uint256(-1);
        _allowedFragments[address(this)][pair] = uint256(-1);

        setAutomatedMarketMakerPair(pair, true);
    }

    function clearStuckBalance(address _receiver) external onlyOwner {
        require(_receiver != address(0x0), 'invalid address');
        uint256 balance = address(this).balance;
        payable(_receiver).transfer(balance);
        emit ClearStuckBalance(balance, _receiver, block.timestamp);

    }

    function rescueToken(address tokenAddress, uint256 tokens)
    external
    onlyOwner
    returns (bool success)
    {
        emit RescueToken(tokenAddress, msg.sender, tokens, block.timestamp);
        return ERC20Detailed(tokenAddress).transfer(msg.sender, tokens);
    }

    function setRebaseFrequency(uint256 _rebaseFrequency) external onlyOwner {
        require(_rebaseFrequency <= MAX_REBASE_FREQUENCY, 'Too high');
        rebaseFrequency = _rebaseFrequency;
        emit SetRebaseFrequency(_rebaseFrequency, block.timestamp);
    }

    function setRewardYield(
        uint256 _rewardYield,
        uint256 _rewardYieldDenominator
    ) external authorized {
        rewardYield = _rewardYield;
        REWARD_YIELD_DENOMINATOR = _rewardYieldDenominator;
        emit SetRewardYield(_rewardYield, _rewardYieldDenominator, block.timestamp);
    }

    function setNextRebase(uint256 _nextRebase) external onlyOwner {
        require(
            _nextRebase > block.timestamp,
            'Next rebase can not be in the past'
        );
        nextRebase = _nextRebase;
        emit SetNextRebase(_nextRebase, block.timestamp);
    }

    function setMaxSellTransaction(uint256 _maxTxn) external onlyOwner {
        require(_maxTxn > MIN_SELL_AMOUNT_RATE, 'Above maximum sell amount');
        maxSellTransactionAmount = _maxTxn;
        emit SetMaxSellTransaction(_maxTxn, block.timestamp);
    }

    function updateBlacklist(address _user, bool _flag) external onlyOwner{
        blacklist[_user] = _flag;
    }

    event SwapBack(
        uint256 contractTokenBalance,
        uint256 amountToLiquify,
        uint256 amountToRFV,
        uint256 amountToTreasury
    );

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 BNBReceived,
        uint256 tokensIntoLiqudity
    );

    event SetFeeReceivers(
        address indexed _liquidityReceiver,
        address indexed _treasuryReceiver,
        address indexed _riskFreeValueReceiver
    );

    event ClearStuckBalance(
        uint256 indexed amount,
        address indexed receiver,
        uint256 indexed time
    );

    event RescueToken(
        address indexed tokenAddress,
        address indexed sender,
        uint256 indexed tokens,
        uint256 time
    );

    event SetRebaseFrequency(
        uint256 indexed frequency,
        uint256 indexed time
    );

    event SetRewardYield(
        uint256 indexed rewardYield,
        uint256 indexed frequency,
        uint256 indexed time
    );

    event SetNextRebase(
        uint256 indexed value,
        uint256 indexed time
    );

    event SetMaxSellTransaction(
        uint256 indexed value,
        uint256 indexed time
    );

    event SetSwapBackSettings(
        bool indexed enabled,
        uint256 indexed num,
        uint256 indexed denum
    );

    event SetFees(
        uint256 indexed _liquidityFee,
        uint256 indexed _riskFreeValue,
        uint256 indexed _treasuryFee,
        uint256 _sellFeeTreasuryAdded,
        uint256 _sellFeeRFVAdded,
        uint256 _sellFeeLiquidityAdded,
        uint256 totalBuyFee,
        uint256 totalSellFee
    );

    event LogManualRebase(int256 supplyDelta, uint256 timeStamp);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SetInitialDistribution(bool indexed value);
    event SetFeeExempt(address indexed addy, bool indexed value);
}