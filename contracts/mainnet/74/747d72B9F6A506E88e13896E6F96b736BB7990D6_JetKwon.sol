/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

/**

@JetKwon - Jetting DoKwon's BTC to the moon!

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

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

interface IDividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
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

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address public _token;
    address public _owner;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IERC20 constant REWARD = IERC20(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c); // BTC 
    IPancakeSwapRouter immutable router;

    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;
    mapping(address => uint256) public shareholderClaims;

    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;

    uint256 public minPeriod = 30 * 60;
    uint256 public minDistribution = 1 * (10**12);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token || msg.sender == _owner);
        _;
    }

    constructor(address _router, address owner_) {
        router = IPancakeSwapRouter(_router);
        _token = msg.sender;
        _owner = owner_;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution)
        external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount)
        external override onlyToken {
        if (shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }

        if (amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(
            shares[shareholder].amount
        );
    }

    function deposit() external payable override {
        
        uint256 balanceBefore = REWARD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(REWARD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: msg.value
        }(0, path, address(this), block.timestamp);

        uint256 amount = REWARD.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(
            dividendsPerShareAccuracyFactor.mul(amount).div(totalShares)
        );
    }

    function process(uint256 gas) external override {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            if (shouldDistribute(shareholders[currentIndex])) {
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder)
        internal view returns (bool){
        return
            shareholderClaims[shareholder] + minPeriod < block.timestamp &&
            getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0) {
            totalDistributed = totalDistributed.add(amount);
            REWARD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder)
        public view returns (uint256) {

        if (shares[shareholder].amount == 0) {
            return 0;
        }

        uint256 shareholderTotalDividends = getCumulativeDividends(
            shares[shareholder].amount
        );
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {
            return 0;
        }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share)
        internal view returns (uint256) {
        return
            share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[
            shareholders.length - 1
        ];
        shareholderIndexes[
            shareholders[shareholders.length - 1]
        ] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}

interface IPancakeSwapPair {
		function factory() external view returns (address);
		function sync() external;
}

interface IPancakeSwapRouter{
		function factory() external pure returns (address);
		function WETH() external pure returns (address);

		function addLiquidityETH(
				address token,
				uint amountTokenDesired,
				uint amountTokenMin,
				uint amountETHMin,
				address to,
				uint deadline
		) external payable returns (uint amountToken, uint amountETH, uint liquidity);
		function swapExactTokensForTokens(
				uint amountIn,
				uint amountOutMin,
				address[] calldata path,
				address to,
				uint deadline
		) external returns (uint[] memory amounts);
		function swapTokensForExactTokens(
				uint amountOut,
				uint amountInMax,
				address[] calldata path,
				address to,
				uint deadline
		) external returns (uint[] memory amounts);
		function swapExactTokensForETHSupportingFeeOnTransferTokens(
			uint amountIn,
			uint amountOutMin,
			address[] calldata path,
			address to,
			uint deadline
		) external;
        function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
}

interface IPancakeSwapFactory {
		function createPair(address tokenA, address tokenB) external returns (address pair);
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

    modifier onlyOwner {
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
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
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

contract JetKwon is ERC20Detailed, Ownable {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event Launch();

    string public _name = "JetKwon";
    string public _symbol = "JETKWON";
    uint8 public _decimals = 9;

    IPancakeSwapPair public pairContract;
    mapping(address => bool) _isFeeExempt;

    uint256 public constant DECIMALS = 9;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 7;

    uint256 private constant INITIAL_FRAGMENTS_SUPPLY =
        10**9 * 10**DECIMALS;

    uint256 constant public liquidityFee = 20;
    uint256 constant public treasuryFee = 30;
    uint256 constant public RFVfee = 30;
    uint256 constant public rewardsFee = 20;
    
    uint256 immutable public totalFee =
        liquidityFee.add(treasuryFee).add(RFVfee).add(rewardsFee);
    uint256 immutable public totalSwapFee = treasuryFee.add(RFVfee).add(rewardsFee);
    uint256 constant public feeDenominator = 1000;

    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address public constant ZERO = 0x0000000000000000000000000000000000000000;

    address public autoLiquidityFund;
    address public treasuryFund;
    address public RFV;
    bool public swapEnabled = true;
    IPancakeSwapRouter public router;
    address public pair;

    DividendDistributor public dividendDistributor;
    uint256 public distributorGas = 300000;
    mapping(address => bool) isDividendExempt;
    uint256 shareGonDivisor = 10**60;

    bool inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 private constant TOTAL_GONS =
        MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    uint256 private constant MIN_SUPPLY = 1 * 10**DECIMALS;

    uint256 public INDEX;

    bool public _autoRebase;
    bool public _autoAddLiquidity;
    uint256 public _initRebaseStartTime;
    uint256 public _lastRebasedTime;
    uint256 public rebaseRate = 40000;
    uint256 public _lastAddLiquidityTime;
    uint256 immutable public _autoLiquidityCooldown;
    uint256 public _rebaseCooldown;
    uint256 public _totalSupply;
    uint256 private _gonsPerFragment;

    bool public useTradeLimits = true;
    uint256 public swapLimitNumerator = 3;
    uint256 public constant swapLimitDenom = 1000;


    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;

    mapping(address => bool) private botWallets; 
    uint256 private launchBlock;  

    constructor() ERC20Detailed(_name, _symbol, uint8(DECIMALS)) Ownable() {
        router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        pair = IPancakeSwapFactory(router.factory()).createPair(router.WETH(), address(this));
      
        autoLiquidityFund = 0x2BB6f3B563387BFC1630DCd1164c2Ab08bf4e67a;
        treasuryFund = 0xA0D1d9e2cAb34d6073650496495EA702a10FB536;
        RFV = 0x917E5B29bd0dD7b7b9d5fdfd07041f392Dd298a8;
         
        
        dividendDistributor = new DividendDistributor(address(router), msg.sender);

        _allowedFragments[address(this)][address(router)] = type(uint256).max;
        pairContract = IPancakeSwapPair(pair);

        
        _isFeeExempt[msg.sender] = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[RFV] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(dividendDistributor)] = true;
        isDividendExempt[address(router)] = true; 

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[msg.sender] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _initRebaseStartTime = block.timestamp;
        _lastRebasedTime = block.timestamp;
        _rebaseCooldown = 15 minutes;
        _autoLiquidityCooldown = 15 minutes;
        _autoRebase = true;
        _autoAddLiquidity = true;


        INDEX = gonsForBalance(100000);
        
        emit Transfer(address(0x0), msg.sender, _totalSupply);
    }

    function rebase() internal {
        
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(_rebaseCooldown);
        uint256 epoch = times.mul(_rebaseCooldown/60);

        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
                .mul((10**RATE_DECIMALS))
                .div((10**RATE_DECIMALS).add(rebaseRate));
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(_rebaseCooldown));

        pairContract.sync();

        emit LogRebase(epoch, _totalSupply);
    }

    function manualRebase(uint256 rebaseRateManual) external onlyOwner {

        _totalSupply = _totalSupply
                .mul((10**RATE_DECIMALS))
                .div((10**RATE_DECIMALS).add(rebaseRateManual));

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = block.timestamp;
        pairContract.sync();
    }

    function transfer(address to, uint256 value)
        external override returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {
        if (_allowedFragments[from][msg.sender] !=  type(uint256).max) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender]
            .sub(value, "Insufficient Allowance");
        }
        _transferFrom(from, to, value);
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
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(!botWallets[sender], "in_blacklist");

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
       
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);

        uint256 gonAmountReceived;
        if(_isFeeExempt[sender] || _isFeeExempt[recipient]){
            gonAmountReceived = gonAmount;
        }
        else{
            require(launchBlock != 0, "Not launched");
            if(recipient != pair && useTradeLimits){        
             require(_gonBalances[recipient].add(gonAmount) <= gonsForBalance(_totalSupply) / 50,
              "Initial 2% max wallet restriction");        
            }
            gonAmountReceived = takeFee(sender, gonAmount);

            if(recipient == pair && !inSwap){
                uint256 swapLimit = getSwapLimit();
                if(_autoRebase && _totalSupply > MIN_SUPPLY &&
                block.timestamp >= _lastRebasedTime + _rebaseCooldown){
                    rebase();
                }
                if (_autoAddLiquidity && _gonBalances[autoLiquidityFund].div(_gonsPerFragment) >= swapLimit &&
                block.timestamp >= (_lastAddLiquidityTime + _autoLiquidityCooldown)) {
                    addLiquidity();
                }
                else if (_gonBalances[address(this)].div(_gonsPerFragment) >= swapLimit) {
                    swapBack(swapLimit);
                }        
            }
        }
        _gonBalances[recipient] = _gonBalances[recipient].add(gonAmountReceived);

        if(!isDividendExempt[sender]){
            try dividendDistributor.setShare(payable(sender), _gonBalances[sender].div(shareGonDivisor)) {} catch {}
        }
        if(!isDividendExempt[recipient]){
            try dividendDistributor.setShare(payable(recipient), _gonBalances[recipient].div(shareGonDivisor)) {} catch {}
        }
        if(launchBlock != 0 && !inSwap) {
	    	try dividendDistributor.process(distributorGas) {} catch {}
        }

        emit Transfer(sender, recipient, gonAmountReceived.div(_gonsPerFragment));
        return true;
    }

    function takeFee(address sender, uint256 gonAmount) internal  returns (uint256) {

        uint256 feeAmount = gonAmount.div(feeDenominator).mul(totalFee);
        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            gonAmount.div(feeDenominator).mul(treasuryFee.add(RFVfee))
        );
        _gonBalances[autoLiquidityFund] = _gonBalances[autoLiquidityFund].add(
            gonAmount.div(feeDenominator).mul(liquidityFee)
        );
        
        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));
        return gonAmount.sub(feeAmount);
    }

    function getSwapLimit() internal view returns (uint256){
        return swapLimitNumerator * _totalSupply / swapLimitDenom;
    }

    function addLiquidity() internal swapping {
        uint256 autoLiquidityAmount = _gonBalances[autoLiquidityFund].div(
            _gonsPerFragment
        );
        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            _gonBalances[autoLiquidityFund]
        );
        _gonBalances[autoLiquidityFund] = 0;
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

        if (amountToLiquify > 0 && amountETHLiquidity > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityFund,
                block.timestamp
            );
        }
        _lastAddLiquidityTime = block.timestamp;
    }

    function swapBack(uint256 amountToSwap) internal swapping {
        uint256 balanceBefore = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHSwapped = address(this).balance.sub(balanceBefore);

        uint256 ethForTreasury = treasuryFee.mul(amountETHSwapped).div(totalSwapFee);
        uint256 ethForRFV = RFVfee.mul(amountETHSwapped).div(totalSwapFee);
        uint256 ethForRewards = rewardsFee.mul(amountETHSwapped).div(totalSwapFee);

        (bool success, ) = payable(treasuryFund).call{
            value: ethForTreasury,
            gas: 30000}("");
        (success, ) = payable(RFV).call{
            value: ethForRFV,
             gas: 30000}("");
        try dividendDistributor.deposit{value: ethForRewards}() {} catch {}
    }

    function withdrawAllToTreasury() external swapping onlyOwner {
        uint256 amountToSwap = _gonBalances[address(this)].div(_gonsPerFragment);
        require( amountToSwap > 0,"There are tokens deposited in contract");
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            treasuryFund,
            block.timestamp
        );
    }

    function claimStuckBalance() external swapping onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance, gas: 30000}(""); success;
    }

    function setAutoRebase(bool _flag, uint256 rebaseCooldown, uint256 _rebaseRate) external onlyOwner {
        if (_flag) {
            _autoRebase = _flag;
            _lastRebasedTime = block.timestamp;
            _rebaseCooldown = rebaseCooldown;
            rebaseRate = _rebaseRate;
        } else {
            _autoRebase = _flag;
        }
    }

    function setAutoAddLiquidity(bool _flag) external onlyOwner {
        if(_flag) {
            _autoAddLiquidity = _flag;
            _lastAddLiquidityTime = block.timestamp;
        } else {
            _autoAddLiquidity = _flag;
        }
    }

    function setSwapLimit(uint256 _swapLimitNumerator) external onlyOwner {
        require(_swapLimitNumerator >= 2 && _swapLimitNumerator <= 10);
        swapLimitNumerator = _swapLimitNumerator;
    }

    function allowance(address owner_, address spender) external view override returns (uint256){
        return _allowedFragments[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool){
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool){
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

    function approve(address spender, uint256 value) external override returns (bool){
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

     function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
   
    function balanceOf(address who) public view override returns (uint256) {
        return _gonBalances[who].div(_gonsPerFragment);
    }

    function gonsForBalance(uint256 amount) public view returns (uint256) {
        return amount.mul(_gonsPerFragment);
    }

    function balanceForGons(uint256 gons) public view returns (uint256) {
        return gons.div(_gonsPerFragment);
    }

    function index() public view returns (uint256) {
        return balanceForGons(INDEX);
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function getCirculatingSupply() public view returns (uint256) {
        return (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(_gonsPerFragment);
    }

    function setFeeReceivers(
        address _autoLiquidityFund,
        address _treasuryFund,
        address _RFV 
    ) external onlyOwner {
        autoLiquidityFund = _autoLiquidityFund;
        treasuryFund = _treasuryFund;
        RFV = _RFV; 
    }

    function setWhitelist(address _addr, bool isWhitelisted) external onlyOwner {
        _isFeeExempt[_addr] = isWhitelisted;
    }

    function addBotWallet(address botwallet) external onlyOwner {
        require(block.number <= launchBlock + 100, "Antibot only first 100 blocks, ~5 minutes");
        botWallets[botwallet] = true;
    }
    
    function removeBotWallet(address botwallet) external onlyOwner {
        botWallets[botwallet] = false;
    }
    
    function allowtrading() external onlyOwner {
        launchBlock = block.number;   
        emit Launch();     
    }  

    // * * * DISTRIBUTOR SETTINGS * * * 
     function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
        isDividendExempt[holder] = exempt;
        if (exempt) {
            dividendDistributor.setShare(holder, 0);
        } else {
            dividendDistributor.setShare(holder, balanceOf(holder));
        }
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner {
        dividendDistributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas <= 600000);
        distributorGas = gas;
    }
    //  * * * 
    

    receive() external payable {}
}