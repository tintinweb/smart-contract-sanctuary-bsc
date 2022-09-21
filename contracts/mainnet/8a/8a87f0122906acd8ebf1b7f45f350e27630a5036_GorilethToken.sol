/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// SPDX-License-Identifier: MIT

// @custom:security-contact [email protected]

pragma solidity 0.8.17;


// LIBRARY

/**
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
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Auth is Context {
    address private _owner;

    mapping(address => bool) internal authorizations;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor(address owner_) {
        _owner = owner_;
        authorizations[_owner] = true;

    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Throws if called by any unauthorized account.
     */
    modifier authorized() {
        _checkAuthorized();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Auth: caller is not the owner");
    }

    /**
     * @dev Throws if the sender is not authorized.
     */
    function _checkAuthorized() internal view virtual {
        require(isAuthorized(_msgSender()), "Auth: caller is not authorized");
    }

    /**
     * @dev Authorize address. Owner only
     * Can only be called by the current owner.
     */
    function authorize(address adr) external onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * @dev Remove address' authorization.
     * Can only be called by the current owner.
     */
    function unauthorize(address adr) external onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev Return authorization status of an address
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }
}


/** UNISWAP V2 INTERFACES **/

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

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


// ERC STANDARD

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}



// GORILETH TOKEN

contract GorilethToken is IERC20, IERC20Metadata, Auth {

    // Data

    IUniswapV2Router02 public router;

    address public constant DEAD = address(0xdead);
    address public constant ZERO = address(0);
    address public pair;
    address public autoLiquidityReceiver;
    address public marketingReceiver;
    address public treasuryReceiver;
    address public teamReceiver;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    uint256 public xTeam = 0;
    uint256 public xLiquidity = 0;
    uint256 public xBuyback = 2;
    uint256 public xTreasury = 2;
    uint256 public xMarketing = 1;
    uint256 public constant BASEFEE = 1;
    uint256 public constant TOTALFEE = 10;
    uint256 public constant FEEDENOMINATOR = 100;

    uint256 public lastAddLiquidityTime;
    uint256 public targetLiquidity = 25;
    uint256 public targetLiquidityDenominator = 100;
    
    uint256 public buybackMultiplierTriggeredAt;
    uint256 public buybackMultiplierNumerator = 200;
    uint256 public buybackMultiplierDenominator = 100;
    uint256 public buybackMultiplierLength = 3600;

    uint256 public autoBuybackCap;
    uint256 public autoBuybackAccumulator;
    uint256 public autoBuybackAmount;
    uint256 public autoBuybackBlockPeriod;
    uint256 public autoBuybackBlockLast;

    uint256 public swapThreshold;

    bool public inSwap;
    bool public swapEnabled = true;
    bool public autoBuybackEnabled = true;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    mapping(address => bool) public buyBacker;
    mapping(address => bool) public isFeeExempt;

    // Modifier

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyBuybacker() {
        require(buyBacker[_msgSender()], "Not a buybacker");
        _;
    }
    
    // Constructor

    constructor(
        uint256 supply_,
        address autoLiquidityReceiver_,
        address marketingReceiver_,
        address treasuryReceiver_,
        address teamReceiver_,
        IUniswapV2Router02 router_
    )
    Auth(_msgSender()) {
        
        name = "GorilethToken";
        symbol = "Goken";
        decimals = 9;
        totalSupply = supply_ * 10 ** decimals;

        router = IUniswapV2Router02(router_);
        pair = IUniswapV2Factory(router.factory()).createPair(
            address(this),
            router.WETH()
        );

        swapThreshold = totalSupply / 20000;

        isFeeExempt[_msgSender()] = true;
        buyBacker[_msgSender()] = true;

        autoLiquidityReceiver = autoLiquidityReceiver_;
        marketingReceiver = marketingReceiver_;
        treasuryReceiver = treasuryReceiver_;
        teamReceiver = teamReceiver_;

        allowances[address(this)][address(router)] = totalSupply;
        allowances[address(this)][address(pair)] = totalSupply;
        balances[_msgSender()] = totalSupply;
        
        emit Transfer(ZERO, _msgSender(), totalSupply);
        emit TokenCreated(_msgSender(), address(this));
    }

    // Event

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event BuybackMultiplierActive(uint256 duration);
    event TokenCreated(address indexed owner, address indexed token);

    // Function

    receive() external payable {}

    /* Update settings function */

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setBuyBacker(address acc, bool add) external authorized {
        buyBacker[acc] = add;
    }

    function setNewRouter(IUniswapV2Router02 router_) external authorized {
        router = router_;
    }

    function setFeeReceivers(address autoLiquidityReceiver_, address teamReceiver_, address treasuryReceiver_, address marketingReceiver_) external authorized {
        autoLiquidityReceiver = autoLiquidityReceiver_;
        teamReceiver = teamReceiver_;
        treasuryReceiver = treasuryReceiver_;
        marketingReceiver = marketingReceiver_;
    }

    function adjustExtraDistribution(uint256 xLiquidity_, uint256 xBuyback_, uint256 xTreasury_, uint256 xMarketing_, uint256 xTeam_) external authorized {
        require(xLiquidity_ + xBuyback_ + xTreasury_ + xMarketing_ + xTeam_ == 5, "Extra distribution must be a total of 5%.");
        xLiquidity = xLiquidity_;
        xBuyback = xBuyback_;
        xTreasury = xTreasury_;
        xMarketing = xMarketing_;
        xTeam = xTeam_;
    }

    function setAutoBuybackSettings(bool enabled, uint256 cap, uint256 amount, uint256 period) external authorized {
        autoBuybackEnabled = enabled;
        autoBuybackCap = cap;
        autoBuybackAccumulator = 0;
        autoBuybackAmount = amount;
        autoBuybackBlockPeriod = period;
        autoBuybackBlockLast = block.number;
    }

    function setBuybackMultiplierSettings(uint256 numerator, uint256 denominator, uint256 length) external authorized {
        require(numerator / denominator <= 2 && numerator > denominator, "Numerator should be greater than denominator but with value lesser than or equal to 200%");
        buybackMultiplierNumerator = numerator;
        buybackMultiplierDenominator = denominator;
        buybackMultiplierLength = length;
    }

    function clearBuybackMultiplier() external authorized {
        buybackMultiplierTriggeredAt = 0;
    }

    function setSwapBackSettings(bool enabled, uint256 amount) external authorized {
        swapEnabled = enabled;
        swapThreshold = amount;
    }

    function setTargetLiquidity(uint256 target, uint256 denominator) external authorized {
        targetLiquidity = target;
        targetLiquidityDenominator = denominator;
    }

    /* Override ERC function */

    function balanceOf(address account) public view override returns (uint256) {
        return balances[account];
    }

    function allowance(address holder, address spender) external view override returns (uint256) {
        return allowances[holder][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        allowances[_msgSender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(_msgSender(), recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (allowances[sender][_msgSender()] != totalSupply) {
            require(amount <= allowances[sender][_msgSender()], "Insufficient Allowance");
            allowances[sender][_msgSender()] = allowances[sender][_msgSender()] - amount;
        }

        return _transferFrom(sender, recipient, amount);
    }

    /* Extending ERC function */

    function approveMax(address spender) external returns (bool) {
        return approve(spender, totalSupply);
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

        require(amount <= balances[sender], "Insufficient Balance");
        balances[sender] = balances[sender] - amount;

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, recipient, amount) : amount;

        balances[recipient] = balances[recipient] + amountReceived;

        emit Transfer(sender, recipient, amountReceived);

        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount ) internal returns (bool) {
        require(amount <= balances[sender], "Insufficient Balance");
        balances[sender] = balances[sender] - amount;
        balances[recipient] = balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    /* Conditional check function */

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function shouldSwapBack() internal view returns (bool) {
        return _msgSender() != pair && !inSwap && swapEnabled && balances[address(this)] >= swapThreshold;
    }

    function shouldAutoBuyback() internal view returns (bool) {
        return _msgSender() != pair && !inSwap && autoBuybackEnabled && autoBuybackBlockLast + autoBuybackBlockPeriod <= block.number && address(this).balance >= autoBuybackAmount;
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    /* Value check function */

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return (accuracy * (2 * balanceOf(pair))) / getCirculatingSupply();
    }

    function getCirculatingSupply() public view returns (uint256) {
        return totalSupply - balanceOf(DEAD) - balanceOf(ZERO);
    }

    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = (amount * getTotalFee(receiver == pair)) / FEEDENOMINATOR;

        balances[address(this)] = balances[address(this)] + feeAmount;
        
        emit Transfer(sender, address(this), feeAmount);

        return amount - feeAmount;
    }

    function getMultipliedFee() public view returns (uint256) {
        if (buybackMultiplierTriggeredAt + buybackMultiplierLength > block.timestamp) {
            uint256 remainingTime = buybackMultiplierTriggeredAt + buybackMultiplierLength - block.timestamp;
            uint256 feeIncrease = ((TOTALFEE * buybackMultiplierNumerator) / buybackMultiplierDenominator) - TOTALFEE;
            return ((TOTALFEE * 150) / 100) + ((feeIncrease * remainingTime) / buybackMultiplierLength);
        }
        return (TOTALFEE * 150) / 100;
    }

    function getTotalFee(bool selling) public view returns (uint256) {
        if (selling) {
            return getMultipliedFee();
        }
        return TOTALFEE;
    }

    /* Internal function */

    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : BASEFEE + xLiquidity;
        uint256 amountToLiquify = ((swapThreshold * dynamicLiquidityFee) / TOTALFEE) / 2;
        uint256 amountToSwap = swapThreshold - amountToLiquify;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountToSwap, 0, path, address(this), block.timestamp);

        uint256 amountBNB = address(this).balance - balanceBefore;

        uint256 totalBNBFee = TOTALFEE - (dynamicLiquidityFee / 2);

        uint256 amountBNBLiquidity = ((amountBNB * dynamicLiquidityFee) / totalBNBFee) / 2;
        uint256 amountBNBTreasury = (amountBNB * (BASEFEE + xTreasury)) / totalBNBFee;
        uint256 amountBNBTeam = (amountBNB * (BASEFEE + xTeam)) / totalBNBFee;
        uint256 amountBNBMarketing = (amountBNB * (BASEFEE + xMarketing)) / totalBNBFee;
        
        payable(treasuryReceiver).transfer(amountBNBTreasury);
        payable(teamReceiver).transfer(amountBNBTeam);
        payable(marketingReceiver).transfer(amountBNBMarketing);

        if (amountToLiquify > 0) {
            router.addLiquidityETH{
                value: amountBNBLiquidity
            } (address(this), amountToLiquify, 0, 0, autoLiquidityReceiver, block.timestamp);

            lastAddLiquidityTime = block.timestamp;

            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }

    function triggerAutoBuyback() internal {
        buyTokens(autoBuybackAmount, DEAD);
        autoBuybackBlockLast = block.number;
        autoBuybackAccumulator = autoBuybackAccumulator + autoBuybackAmount;
        if (autoBuybackAccumulator > autoBuybackCap) {
            autoBuybackEnabled = false;
        }
    }

    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        } (0, path, to, block.timestamp);
    }

    /* Manual buyback/burn function */

    function triggerZeusBuyback(uint256 amount, bool triggerBuybackMultiplier) external authorized {
        buyTokens(amount, DEAD);
        if (triggerBuybackMultiplier) {
            buybackMultiplierTriggeredAt = block.timestamp;
            emit BuybackMultiplierActive(buybackMultiplierLength);
        }
    }

}