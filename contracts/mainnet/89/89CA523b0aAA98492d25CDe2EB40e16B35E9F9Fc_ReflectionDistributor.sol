/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

/** LIBRARIES **/

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
}

/**
 * @title Context
 * 
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    
    /** FUNCTION **/

    /**
     * @dev Provide information of current sender.
     */
    function _msgSender() internal view virtual returns (address) {
        /**
         * @dev Returns msg.sender.
         */
        return msg.sender;
    }

    /**
     * @dev Provide information current value.
     */
    function _msgValue() internal view virtual returns (uint256) {
        /**
         * @dev Returns msg.value.
         */
        return msg.value;
    }

}

abstract contract Auth is Context {
    address internal owner;
    mapping(address => bool) internal authorizations;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _owner) {
        _transferOwnership(_owner);
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(_msgSender()), "!OWNER");
        _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(_msgSender()), "!AUTHORIZED");
        _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }


    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/** IERC20 STANDARD **/

interface IERC20Extended {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/** UNISWAP V2 INTERFACES **/

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function removeLiquidity(address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(uint256 amountOut, uint256 amountInMax, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint256 deadline) external payable returns (uint256[] memory amounts);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountOut);

    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);

}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
}

/** REFLECTION DISTRIBUTOR **/

interface IReflectionERC20Extended is IERC20Extended{
    function transferReflection(address shareholder, uint256 amount) external returns (bool);
}

interface IReflectionDistributor {
    function setDistributionCriteria(uint256 minPeriod_, uint256 minDistribution_) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit() external payable;

    function process(uint256 gas) external;
}

contract ReflectionDistributor is IReflectionDistributor, Auth {
    

    /* LIBRARY */
    using SafeMath for uint256;


    /* DATA */
    IReflectionERC20Extended public rewardToken;
    IUniswapV2Router02 public router;
    address public token;

    address private constant DEAD = address(0xdead);
    address private constant ZERO = address(0);

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }
    
    bool public initialized;
    uint256 public currentIndex;
    uint256 public minPeriod;
    uint256 public minDistribution;
    address[] public shareholders;
    
    mapping(address => uint256) public shareholderIndexes;
    mapping(address => uint256) public shareholderClaims;
    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalReflections; 
    uint256 public totalDistributed;
    uint256 public reflectionsPerShare;
    uint256 public reflectionsPerShareAccuracyFactor;


    /* MODIFIER */
    modifier initializer() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(_msgSender() == token);
        _;
    }

    modifier onlyTokenAndAuthorized() {
        require(_msgSender() == token || isAuthorized(_msgSender()));
        _;
    }


    /* CONSTRUCTOR */
    constructor(
        address router_,
        address rewardToken_
    ) payable Auth(
        _msgSender()
    ) {
        token = _msgSender();
        router = IUniswapV2Router02(router_);
        rewardToken = IReflectionERC20Extended(rewardToken_);
        authorize(_msgSender());

        reflectionsPerShareAccuracyFactor = 10**36;
        minPeriod = 1 hours;
        minDistribution = 1 * (10**rewardToken.decimals());
    }
    

    /* FUNCTION */

    function unInitialized(bool initialization) external onlyToken {
        initialized = initialization;
    }

    function setTokenAddress(address token_) external initializer onlyTokenAndAuthorized {
        require(token_ != ZERO && token_ != DEAD, "Cannot set zero address or dead address as the token address.");
        token = token_;
    }

    function setRewardTokenAddress(address rewardToken_) external authorized {
        require(rewardToken_ != ZERO && rewardToken_ != DEAD, "Cannot set zero address or dead address as the token address.");
        rewardToken = IReflectionERC20Extended(rewardToken_);
    }

    function setDistributionCriteria(uint256 minPeriod_, uint256 minDistribution_) external override onlyTokenAndAuthorized {
        minPeriod = minPeriod_;
        minDistribution = minDistribution_;
    }

    /**
     * @dev Set the number of shares owned by the address.
     */
    function setShare(address shareholder, uint256 amount) external override onlyToken {
        uint256 currentShare = shares[shareholder].amount;
        uint256 excludedAmount = shares[shareholder].totalExcluded;

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeReflections(shares[shareholder].amount);
        
        if (amount > 0 && currentShare > 0) {
            distributeReflection(shareholder, currentShare, excludedAmount);
        } else if (amount == 0 && currentShare > 0) {
            removeShareholder(shareholder);
            distributeReflection(shareholder, currentShare, excludedAmount);
        } else if (amount > 0 && currentShare == 0) {
            addShareholder(shareholder);
        }
    }

    function deposit() external payable override onlyTokenAndAuthorized {
        uint256 balanceBefore = rewardToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(rewardToken);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens {
            value: _msgValue()
        } (0, path, address(this), block.timestamp);

        uint256 amount = rewardToken.balanceOf(address(this)).sub(balanceBefore);

        totalReflections = totalReflections.add(amount);
        reflectionsPerShare = reflectionsPerShare.add(reflectionsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function updateReflections(uint256 amount) external onlyTokenAndAuthorized {
        totalReflections = totalReflections.add(amount);
        reflectionsPerShare = reflectionsPerShare.add(reflectionsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyTokenAndAuthorized {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;

        while (gasUsed < gas && iterations < shareholderCount) {
            currentIndex++;
            iterations++;

            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            if (shouldDistribute(shareholders[currentIndex])) {
                distributeReflection(shareholders[currentIndex], shares[shareholders[currentIndex]].amount, shares[shareholders[currentIndex]].totalExcluded);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
        }
    }

    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp && getUnpaidEarnings(shareholder) > minDistribution;
    }

    /**
     * @dev Distribute reflection to the shareholders and update reflection information.
     */
    function distributeReflection(address shareholder, uint256 currentShare, uint256 excludedAmount) internal returns (bool) {
        if (currentShare == 0) {
            return false;
        }

        uint256 amount = checkUnpaidEarnings(currentShare, excludedAmount);

        if (amount <= 0) {
            return false;
        }
        
        totalDistributed = totalDistributed.add(amount);
        shareholderClaims[shareholder] = block.timestamp;
        shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
        shares[shareholder].totalExcluded = getCumulativeReflections(shares[shareholder].amount);
        return rewardToken.transferReflection(shareholder, amount);
    }

    /**
     * @dev Get the cumulative reflection for the given share.
     */
    function getCumulativeReflections(uint256 share) internal view returns (uint256) {
        return share.mul(reflectionsPerShare).div(reflectionsPerShareAccuracyFactor);
    }
    
    /**
     * @dev Get unpaid reflection that needed to be distributed for the given address.
     */
    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if (shares[shareholder].amount == 0) {
            return 0;
        }

        uint256 shareholderTotalReflections = getCumulativeReflections(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalReflections <= shareholderTotalExcluded) {
            return 0;
        }

        return shareholderTotalReflections.sub(shareholderTotalExcluded);
    }
    
    /**
     * @dev Check unpaid reflection that needed to be distributed for the given address.
     */
    function checkUnpaidEarnings(uint256 amount, uint256 excluded) public view returns (uint256) {
        if (amount == 0) {
            return 0;
        }

        uint256 shareholderTotalReflections = getCumulativeReflections(amount);

        if (shareholderTotalReflections <= excluded) {
            return 0;
        }

        return shareholderTotalReflections.sub(excluded);
    }

    /**
     * @dev Add the address to the array of shareholders.
     */
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    /**
     * @dev Remove the address from the array of shareholders.
     */
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length - 1];
        shareholderIndexes[shareholders[shareholders.length - 1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function claimReflection() external {
        distributeReflection(_msgSender(), shares[_msgSender()].amount, shares[_msgSender()].totalExcluded);
    }

}

/** BANANA LABS TOKEN **/

contract BananaLabsToken is IReflectionERC20Extended, Auth {


    /* LIBRARY*/
    using SafeMath for uint256;


    /* DATA */
    ReflectionDistributor public distributor;
    IUniswapV2Router02 public router;

    address private constant DEAD = address(0xdead);
    address private constant ZERO = address(0);

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    address public rewardToken;
    address public pair;
    uint256 public distributorGas = 5 * 10**5;

    address public growthFeeReceiver;

    bool public feeEnabled = true;
    uint256 public buybackFee;
    uint256 public reflectionFee;
    uint256 public growthFee;
    uint256 public totalFee;
    uint256 public feeDenominator;

    bool public autoBuybackEnabled;
    uint256 public autoBuybackCap;
    uint256 public autoBuybackAccumulator;
    uint256 public autoBuybackAmount;
    uint256 public autoBuybackBlockPeriod;
    uint256 public autoBuybackBlockLast;

    uint256 public buybackMultiplierNumerator = 200;
    uint256 public buybackMultiplierDenominator = 100;
    uint256 public buybackMultiplierLength = 30 minutes;
    uint256 public buybackMultiplierTriggeredAt;
    
    bool internal inSwap;
    bool public swapEnabled = false;
    uint256 public swapThreshold;


    /* MAPPING */
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) public buyBacker;
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isReflectionExempt;


    /* EVENT */
    event BuybackMultiplierActive(uint256 duration);
    event TokenCreated(address indexed owner, address indexed token);

    
    /* MODIFIER */
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyBuybacker() {
        require(buyBacker[_msgSender()], "Not a buybacker address.");
        _;
    }

    modifier onlyDistributor() {
        require(_msgSender() == address(distributor), "Not the distributor address.");
        _;
    }


    /* CONSTRUCTOR */
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 supply_,
        ReflectionDistributor distributor_,
        address router_,
        address growthFeeReceiver_,
        uint256[4] memory feeSettings_
    ) payable Auth(
        _msgSender()
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = supply_ * 10**_decimals;

        rewardToken = address(this);
        router = IUniswapV2Router02(router_);
        pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());

        _initializeFees(feeSettings_);
        _initializeDistributor(distributor_);

        swapThreshold = _totalSupply / 20000; // 0.005%

        isFeeExempt[_msgSender()] = true;
        isFeeExempt[address(this)] = true;

        isReflectionExempt[_msgSender()] = true;
        isReflectionExempt[pair] = true;
        isReflectionExempt[address(this)] = true;
        isReflectionExempt[DEAD] = true;
        
        buyBacker[_msgSender()] = true;

        require(growthFeeReceiver_ != ZERO && growthFeeReceiver_ != DEAD, "Cannot set zero address or dead address as growth fee receiver.");
        growthFeeReceiver = growthFeeReceiver_;

        _allowances[address(this)][address(router)] = _totalSupply;
        _allowances[address(this)][address(pair)] = _totalSupply;

        _balances[_msgSender()] = _totalSupply;
        emit Transfer(ZERO, _msgSender(), _totalSupply);

        emit TokenCreated(_msgSender(), address(this));

    }


    /* FUNCTION */

    receive() external payable {}

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }
    
    function setDistributorSettings(uint256 gas) external authorized {
        require(gas <= 750000, "Gas must be lower than 750000");
        distributorGas = gas;
    }

    // ERC20 standard related functions.

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[_msgSender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(_msgSender(), recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][_msgSender()] != _totalSupply) {
            _allowances[sender][_msgSender()] = _allowances[sender][_msgSender()].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (shouldSwapBack()) {
            swapBack();
        }
        if (shouldAutoBuyback()) {
            triggerAutoBuyback();
        }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, recipient, amount) : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);

        if (!isReflectionExempt[sender]) {
            try distributor.setShare(sender, _balances[sender]) {} catch {}
        }
        if (!isReflectionExempt[recipient]) {
            try distributor.setShare(recipient, _balances[recipient]) {} catch {}
        }

        try distributor.process(distributorGas) {} catch {}

        return true;
    }

    function transferReflection(address recipient, uint256 amount) external onlyDistributor override returns (bool) {
        return _basicTransfer(_msgSender(), recipient, amount);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Conditional check related function.

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function shouldSwapBack() internal view returns (bool) {
        return _msgSender() != pair && !inSwap && swapEnabled && _balances[address(this)] >= swapThreshold;
    }

    function shouldAutoBuyback() internal view returns (bool) {
        return _msgSender() != pair && !inSwap && autoBuybackEnabled && autoBuybackBlockLast + autoBuybackBlockPeriod <= block.number && address(this).balance >= autoBuybackAmount;
    }

    // Fees related functions.

    /**
     * @dev Set all the fee settings during contract initialization.
     * 
     * NOTE:
     * 0 - Buyback fee
     * 1 - Reflection fee
     * 2 - Growth fee
     * 3 - Fee denominator
     */
    function _initializeFees(uint256[4] memory feeSettings_) internal {
        _setFees(feeSettings_[0], feeSettings_[1], feeSettings_[2], feeSettings_[3]);
    }

    /**
     * @dev Enable / disable fee.
     */
    function enableFees(bool enabled) public onlyOwner {
        require(feeEnabled != enabled, "Cannot set the same condition.");
        feeEnabled = enabled;
    }

    /**
     * @dev Run internally to set all the fee settings and ensure that total fee is not more than 25%. 
     */
    function _setFees(uint256 buybackFee_, uint256 reflectionFee_, uint256 growthFee_, uint256 feeDenominator_) internal {
        buybackFee = buybackFee_;
        reflectionFee = reflectionFee_;
        growthFee = growthFee_;
        totalFee = buybackFee_.add(reflectionFee_).add(growthFee_);
        feeDenominator = feeDenominator_;
        require(totalFee < feeDenominator.mul(25).div(100), "Total fee should not be greater than 25%.");
    }

    /**
     * @dev Set the address that will receive growth fee.
     */
    function setGrowthFeeReceivers(address growthFeeReceiver_) external authorized {
        require(growthFeeReceiver != growthFeeReceiver_, "Cannot set the same address.");
        growthFeeReceiver = growthFeeReceiver_;
    }

    /**
     * @dev Set isFeeExempt boolean for the given address.
     */
    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function getTotalFee(bool selling) public view returns (uint256) {
        if (selling) {
            return getMultipliedFee();
        }
        return totalFee;
    }

    function getMultipliedFee() public view returns (uint256) {
        if (buybackMultiplierTriggeredAt.add(buybackMultiplierLength) > block.timestamp) {
            uint256 remainingTime = buybackMultiplierTriggeredAt.add(buybackMultiplierLength).sub(block.timestamp);
            uint256 feeIncrease = totalFee.mul(buybackMultiplierNumerator).div(buybackMultiplierDenominator).sub(totalFee);
            return totalFee.add(feeIncrease.mul(remainingTime).div(buybackMultiplierLength));
        }
        return totalFee;
    }

    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        if (!feeEnabled) {
            return amount;
        }
        uint256 feeAmount = amount.mul(getTotalFee(receiver == pair)).div(feeDenominator);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    // Reflection related functions.

    function _initializeDistributor(ReflectionDistributor distributor_) internal {
        distributor = ReflectionDistributor(distributor_);
        isFeeExempt[address(distributor)] = true;
        isReflectionExempt[address(distributor)] = true;
    }

    function distributorInitialization(bool initialized) public authorized {
        distributor.unInitialized(initialized);
    }

    function setReflectionDistributor(address distributor_) external authorized {
        ReflectionDistributor prevDistributor = distributor;
        isFeeExempt[address(distributor_)] = true;
        isReflectionExempt[address(distributor_)] = true;
        distributor = ReflectionDistributor(distributor_);
        prevDistributor.unInitialized(false);
        prevDistributor.setTokenAddress(_msgSender());
    }

    /**
     * @dev Set isReflectionExempt boolean and reflection share for the given address.
     * 
     * REQUIREMENT:
     * - Address must not be the token address.
     * - Address must not be token pair address.
     *
     * NOTE:
     * Token address, token pair address and dead address are automatically exempted from reflection during contract initialization.
     */
    function setIsReflectionExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair);
        isReflectionExempt[holder] = exempt;

        if (exempt) {
            distributor.setShare(holder, 0);
        } else {
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function setDistributionCriteria(uint256 minPeriod_, uint256 minDistribution_) external authorized {
        distributor.setDistributionCriteria(minPeriod_, minDistribution_);
    }

    function claimReflection() external {
        distributor.claimReflection();
    }

    // Swapback related functions.

    function setSwapBackSettings(bool enabled, uint256 amount) external authorized {
        swapEnabled = enabled;
        swapThreshold = amount;
    }
    
    function swapBack() internal swapping {
        uint256 amountToReflection = swapThreshold.mul(reflectionFee).div(totalFee);

        _basicTransfer(address(this), address(distributor), amountToReflection);

        distributor.updateReflections(amountToReflection);

        uint256 amountToSwap = swapThreshold.sub(amountToReflection);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountToSwap, 0, path, address(this), block.timestamp);

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalBNBFee = totalFee.sub(reflectionFee);

        uint256 amountBNBGrowth = amountBNB.mul(growthFee).div(totalBNBFee);

        payable(growthFeeReceiver).transfer(amountBNBGrowth);
    }

    // Buyback related functions

    function setAutoBuybackSettings(bool enabled, uint256 cap, uint256 amount, uint256 period) external authorized {
        autoBuybackEnabled = enabled;
        autoBuybackCap = cap;
        autoBuybackAccumulator = 0;
        autoBuybackAmount = amount;
        autoBuybackBlockPeriod = period;
        autoBuybackBlockLast = block.number;
    }

    function setBuybackMultiplierSettings(uint256 numerator, uint256 denominator, uint256 length) external authorized {
        require(numerator / denominator <= 2 && numerator > denominator);
        buybackMultiplierNumerator = numerator;
        buybackMultiplierDenominator = denominator;
        buybackMultiplierLength = length;
    }

    function setBuyBacker(address acc, bool add) external authorized {
        buyBacker[acc] = add; 
    }

    function clearBuybackMultiplier() external authorized {
        buybackMultiplierTriggeredAt = 0;
    }
    
    function triggerAutoBuyback() internal {
        autoBuybackBlockLast = block.number;
        autoBuybackAccumulator = autoBuybackAccumulator.add(autoBuybackAmount);
        if (autoBuybackAccumulator > autoBuybackCap) {
            autoBuybackEnabled = false;
        }
        buyTokens(autoBuybackAmount, DEAD);
    }

    function triggerManualBuyback(uint256 amount, bool triggerBuybackMultiplier) external onlyBuybacker {
        if (triggerBuybackMultiplier) {
            buybackMultiplierTriggeredAt = block.timestamp;
            emit BuybackMultiplierActive(buybackMultiplierLength);
        }
        buyTokens(amount, DEAD);
    }

    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens {
            value: amount
        } (0, path, to, block.timestamp);
    }

}