/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
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

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: FairPlayDeFi.sol

//SPDX-License-Identifier: MIT

/*
 * FairPlay DeFi
 * Brought to you by Cryptolic
 * Developed by Kevin Remer (Totenmacher)
 */

pragma solidity ^0.8.7;






/*
 * External Resource Interfaces
 */
interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

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

interface IDividendDistributor {
    function setShare(address shareholder, uint256 amount) external;
    function depositRewards(uint256 rewardAmount_) external;
    function process(uint256 gas) external;
    function claimDividend() external;
}

/*
 * Main Distributor contract
 */
contract FairPlayDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address public ownerToken;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    string public distributorName;
    address public rewardToken;
    address WBNB;
    IDEXRouter router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public dividendBNBThreshold = .25 * (10 ** 18);

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10 ** 18);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == ownerToken); _;
    }

    constructor (address router_, address rewardtoken_, address bnbaddress_, string memory distributorName_) {
        router = IDEXRouter(router_);
        distributorName = distributorName_;
        ownerToken = msg.sender;
        rewardToken = rewardtoken_;
        WBNB = bnbaddress_;
    }

    receive() external payable {}

    /*
     * Set and Read Shareholder Values
     */
    function setShare(address shareholder_, uint256 amount_) external override onlyToken {
        if(shares[shareholder_].amount > 0 && rewardToken != ownerToken){
            distributeDividend(shareholder_);
        }

        if(amount_ > 0 && shares[shareholder_].amount == 0){
            addShareholder(shareholder_);
        }else if(amount_ == 0 && shares[shareholder_].amount > 0){
            removeShareholder(shareholder_);
        }

        totalShares = totalShares.sub(shares[shareholder_].amount).add(amount_);
        shares[shareholder_].amount = amount_;
        if(rewardToken != ownerToken) {
            shares[shareholder_].totalExcluded = getCumulativeDividends(shares[shareholder_].amount);
        }
    }

    function addShareholder(address shareholder_) internal {
        shareholderIndexes[shareholder_] = shareholders.length;
        shareholders.push(shareholder_);
    }

    function removeShareholder(address shareholder_) internal {
        shareholders[shareholderIndexes[shareholder_]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder_];
        shareholders.pop();
    }
    
    function getUnpaidEarnings(address shareholder_) public view returns (uint256) {
        if(shares[shareholder_].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder_].amount);
        uint256 shareholderTotalExcluded = shares[shareholder_].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share_) internal view returns (uint256) {
        return share_.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    /*
     * Add Reward Tokens to the Distributor
     */
    function depositRewards(uint256 rewardAmount_) external override onlyToken {
        if(rewardAmount_ > 0) {
            totalDividends = totalDividends.add(rewardAmount_);
            dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(rewardAmount_).div(totalShares));
        }
    }

    function swapForRewards() internal {
        if(address(this).balance > dividendBNBThreshold) {
            uint256 balanceBefore = IERC20(rewardToken).balanceOf(address(this));
            uint256 bnbToSwap = address(this).balance;
            
            address[] memory path = new address[](2);
            path[0] = WBNB;
            path[1] = rewardToken;

            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bnbToSwap}(
                0,
                path,
                address(this),
                block.timestamp
            );

            uint256 amount = IERC20(rewardToken).balanceOf(address(this)).sub(balanceBefore);

            totalDividends = totalDividends.add(amount);
            dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
        }
    }

    /*
     * Distribute Tokens
     */
    function process(uint256 gas_) external override onlyToken {
        swapForRewards();

        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas_ && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    
    function shouldDistribute(address shareholder_) internal view returns (bool) {
        return shareholderClaims[shareholder_] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder_) > minDistribution;
    }

    function distributeDividend(address shareholder_) internal {
        if(shares[shareholder_].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder_);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            IERC20(rewardToken).transfer(shareholder_, amount);
            shareholderClaims[shareholder_] = block.timestamp;
            shares[shareholder_].totalRealised = shares[shareholder_].totalRealised.add(amount);
            shares[shareholder_].totalExcluded = getCumulativeDividends(shares[shareholder_].amount);
        }
    }

    /*
     * Manually Claim Rewards
     */
    function claimDividend() external override {
        if(shares[msg.sender].amount > 0) {
            distributeDividend(msg.sender);
        }
    }
}


/*
 * Main Token Contract
 */
contract FairPlayDeFi is IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;

    address BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    // Team and Marketing wallets will be permanenty locked forever
    address teamWallet1 = 0xB320b5e0fCc9cce9D9b4533040f2dACf056D8026; // Kevin
    address teamWallet2 = 0xF06c7a6435A1cc0ff3B87e2151942A9f6cAc1763; // David
    address teamWallet3 = 0x1eF75F59d9768C60109DD1a05b27e5D3711867d2; // Zach
    address marketingWallet = 0x17Ca4E06896969084355655C67d11Bdf7dF1b955;
    
    string constant _name = "Fair Play DeFi";
    string constant _symbol = "FRPY";
    uint8 constant _decimals = 18;

    uint256 _totalSupply =  1000000000 * (10 ** 18);

    uint256 public _maxTxAmount = _totalSupply.div(200);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isFreezeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isRewardExempt;
    mapping (address => bool) isReflectionExempt;
    mapping (address => bool) isLockedWallet;

    uint256 public liquidityFee = 100;
    uint256 public rewardFee = 100;
    uint256 public reflectionFee = 100;
    uint256 public burnFee = 100;
    uint256 public luckystrikeFee = 100;
    uint256 public totalFee = 500;
    uint256 public feeDenominator = 10000;

    uint256 public luckystrikeMultiplier = 3;
    uint256 public luckystrikeThreshold = 1000 * (10 **18);
    uint256 public luckystrikeMinAmount = luckystrikeThreshold.mul(luckystrikeMultiplier);
    uint256 public luckystrikeBalance;

    IDEXRouter public pcsRouter;
    address bnbPair;

    uint256 public launchedAt;

    bool public feesOnNormalTransfers = false;
    bool public liquifyEnabled = false;
    bool public freeze_contract = true;
    bool public swapEnabled = false;

    FairPlayDistributor busdDistributor;
    FairPlayDistributor frpyDistributor;
    uint256 distributorGas = 600000;

    uint256 public swapThreshold = luckystrikeThreshold.mul(20);
    bool public inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    
    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    event Launched(uint256 blockNumber, uint256 timestamp);
    event SwapBackSuccess(uint256 amount);
    event SwapBackFailed(string message);

    constructor () Ownable() {
        pcsRouter = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        
        bnbPair = IDEXFactory(pcsRouter.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(pcsRouter)] = ~uint256(0);

        busdDistributor = new FairPlayDistributor(address(pcsRouter), BUSD, WBNB, 'Fair Play BUSD Distributor');
        frpyDistributor = new FairPlayDistributor(address(pcsRouter), address(this), WBNB, 'Fair Play Reflection Distributor');

        address owner_ = msg.sender;

        isFreezeExempt[owner_] = true;

        isFeeExempt[owner_] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[address(frpyDistributor)] = true;

        isTxLimitExempt[owner_] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[address(frpyDistributor)] = true;

        isRewardExempt[bnbPair] = true;
        isRewardExempt[address(this)] = true;
        isRewardExempt[DEAD] = true;
        isRewardExempt[owner_] = true;
        isRewardExempt[address(frpyDistributor)] = true;

        isLockedWallet[teamWallet1] = true;
        isLockedWallet[teamWallet2] = true;
        isLockedWallet[teamWallet3] = true;
        isLockedWallet[marketingWallet] = true;

        isReflectionExempt[teamWallet1] = true;
        isReflectionExempt[teamWallet2] = true;
        isReflectionExempt[teamWallet3] = true;
        isReflectionExempt[marketingWallet] = true;
        isReflectionExempt[bnbPair] = true;
        isReflectionExempt[address(this)] = true;
        isReflectionExempt[DEAD] = true;
        isReflectionExempt[owner_] = true;
        isReflectionExempt[address(frpyDistributor)] = true;

        approve(address(pcsRouter), _totalSupply);
        _balances[owner_] = _totalSupply;
        emit Transfer(address(0), owner_, _totalSupply);
    }

    receive() external payable { }

    /*
     * Basic Contract Functions
     */
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender_, uint256 amount_) public override returns (bool) {
        _allowances[msg.sender][spender_] = amount_;
        emit Approval(msg.sender, spender_, amount_);
        return true;
    }

    function approveMax(address spender_) external returns (bool) {
        return approve(spender_, ~uint256(0));
    }

    function clearStuckBNB(address wallet_) external onlyOwner {
        payable(wallet_).transfer(address(this).balance);
    }

    /*
     * Token Transfer Functions
     */
    function transfer(address recipient_, uint256 amount_) external override returns (bool) {
        return _transferFrom(msg.sender, recipient_, amount_);
    }

    function transferFrom(address sender_, address recipient_, uint256 amount_) external override returns (bool) {
        if(_allowances[sender_][msg.sender] != ~uint256(0)){
            _allowances[sender_][msg.sender] = _allowances[sender_][msg.sender].sub(amount_, "Insufficient Allowance");
        }

        return _transferFrom(sender_, recipient_, amount_);
    }

    function _transferFrom(address sender_, address recipient_, uint256 amount_) internal returns (bool) {
        require(!freeze_contract || isFreezeExempt[sender_], "Contract frozen!");
        require(!isLockedWallet[sender_], "Wallet is locked");
        require(amount_ <= _maxTxAmount || isTxLimitExempt[sender_], "TX Limit Exceeded");

        bool isPresale = false;

        if(inSwap){ return _basicTransfer(sender_, recipient_, amount_); }
        if(sender_ == address(frpyDistributor)){ return _reflectionTransfer(sender_, recipient_, amount_); }
        
        if(shouldSwapBack()){ swapBack(); }

        if(!launched() && recipient_ == bnbPair) {
            require(_balances[sender_] > 0);
            isPresale = true;
            launch();
        }

        _balances[sender_] = _balances[sender_].sub(amount_, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender_, recipient_) ? takeFee(sender_, amount_) : amount_;
        _balances[recipient_] = _balances[recipient_].add(amountReceived);
        
        if(launched() && !isPresale) {
            if(amount_ >= luckystrikeMinAmount) {
                if(luckystrikeBalance >= luckystrikeThreshold && recipient_ != bnbPair) {
                    _basicTransfer(address(this), recipient_, luckystrikeThreshold);
                    luckystrikeBalance -= luckystrikeThreshold;
                }
                uint256 lsEligibleAmount = amount_.div(10);
                luckystrikeThreshold = luckystrikeThreshold.add(lsEligibleAmount).div(2);
                luckystrikeMinAmount = luckystrikeThreshold.mul(luckystrikeMultiplier);
                swapThreshold = luckystrikeThreshold.mul(10);
            }
        }

        if(!isRewardExempt[sender_]) {
            try busdDistributor.setShare(sender_, _balances[sender_]) {} catch {}
        }
        if(!isReflectionExempt[sender_]) {
            try frpyDistributor.setShare(sender_, _balances[sender_]) {} catch {}
        }
        if(!isRewardExempt[recipient_]) {
            try busdDistributor.setShare(recipient_, _balances[recipient_]) {} catch {}
        }
        if(!isReflectionExempt[recipient_]) {
            try frpyDistributor.setShare(recipient_, _balances[recipient_]) {} catch {}
        }

        if(launched() && !isPresale) {
            try busdDistributor.process(distributorGas) {} catch {}
            try frpyDistributor.process(distributorGas) {} catch {}
        }

        emit Transfer(sender_, recipient_, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender_, address recipient_, uint256 amount_) internal returns (bool) {
        _balances[sender_] = _balances[sender_].sub(amount_, "Insufficient Balance");
        _balances[recipient_] = _balances[recipient_].add(amount_);
        emit Transfer(sender_, recipient_, amount_);
        return true;
    }

    function _reflectionTransfer(address sender_, address recipient_, uint256 amount_) internal returns (bool) {
        _balances[sender_] = _balances[sender_].sub(amount_, "Insufficient Balance");
        _balances[recipient_] = _balances[recipient_].add(amount_);
        try busdDistributor.setShare(recipient_, _balances[recipient_]) {} catch {}
        try frpyDistributor.setShare(recipient_, _balances[recipient_]) {} catch {}
        emit Transfer(sender_, recipient_, amount_);
        return true;
    }

    /*
     * Transfer Support Functions
     */
    function shouldTakeFee(address sender_, address recipient_) internal view returns (bool) {
        if (isFeeExempt[sender_] || isFeeExempt[recipient_] || !launched()) return false;
        if (sender_ == bnbPair || recipient_ == bnbPair) return true;
        return feesOnNormalTransfers;
    }

    function takeFee(address sender_, uint256 amount_) internal returns (uint256) {
        uint256 feeAmount = amount_.mul(totalFee).div(feeDenominator);

        uint256 luckystrikeAmount = feeAmount.mul(luckystrikeFee).div(totalFee);
        luckystrikeBalance += luckystrikeAmount;
        
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender_, address(this), feeAmount);

        return amount_.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != bnbPair
        && !inSwap
        && swapEnabled
        && _balances[address(this)].sub(luckystrikeBalance) >= swapThreshold;
    }

    function swapBack() internal swapping {
        uint256 swapTotalFee = totalFee.sub(luckystrikeFee);
        uint256 swapLiquidityFee = liquifyEnabled ? liquidityFee : 0;
        uint256 amountToLiquify = swapThreshold.mul(swapLiquidityFee).div(swapTotalFee).div(2);

        uint256 burnAmount = swapThreshold.mul(burnFee).div(swapTotalFee);
        _basicTransfer(address(this), DEAD, burnAmount);

        uint256 reflectionAmount = swapThreshold.mul(reflectionFee).div(swapTotalFee);
        _basicTransfer(address(this), address(frpyDistributor), reflectionAmount);
        try frpyDistributor.depositRewards(reflectionAmount) {} catch {}

        uint256 amountToSwap = swapThreshold.sub(amountToLiquify).sub(burnAmount).sub(reflectionAmount);
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        uint256 balanceBefore = address(this).balance;

        try pcsRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        ) {

            uint256 amountBNB = address(this).balance.sub(balanceBefore);

            uint256 totalBNBFee = swapTotalFee.sub(swapLiquidityFee.div(2));

            uint256 amountBNBLiquidity = amountBNB.mul(swapLiquidityFee).div(totalBNBFee).div(2);
            uint256 amountBNBRewards = amountBNB.mul(rewardFee).div(totalBNBFee);

            payable(address(busdDistributor)).transfer(amountBNBRewards);
        
            if(amountToLiquify > 0){
                try pcsRouter.addLiquidityETH{ value: amountBNBLiquidity }(
                    address(this),
                    amountToLiquify,
                    0,
                    0,
                    DEAD,
                    block.timestamp
                ) {
                    emit AutoLiquify(amountToLiquify, amountBNBLiquidity);
                } catch {
                    emit AutoLiquify(0, 0);
                }
            }

            emit SwapBackSuccess(amountToSwap);
        } catch Error(string memory e) {
            emit SwapBackFailed(string(abi.encodePacked("SwapBack failed with error ", e)));
        } catch {
            emit SwapBackFailed("SwapBack failed without an error message from pancakeSwap");
        }
    }


    /*
     * Set Contract Settings
     */
    function launch() internal {
        launchedAt = block.number;
        emit Launched(block.number, block.timestamp);
    }
    
    function freeze(bool freeze_) external onlyOwner {
        freeze_contract = freeze_;
    }

    function setIsRewardExempt(address holder_, bool exempt_) external onlyOwner {
        require(holder_ != address(this) && holder_ != bnbPair);
        isRewardExempt[holder_] = exempt_;
        if(exempt_){
            busdDistributor.setShare(holder_, 0);
        }else{
            busdDistributor.setShare(holder_, _balances[holder_]);
        }
    }

    function setIsReflectionExempt(address holder_, bool exempt_) external onlyOwner {
        require(holder_ != address(this) && holder_ != bnbPair);
        isReflectionExempt[holder_] = exempt_;
        if(exempt_){
            frpyDistributor.setShare(holder_, 0);
        }else{
            frpyDistributor.setShare(holder_, _balances[holder_]);
        }
    }

    function setIsFeeExempt(address holder_, bool exempt_) external onlyOwner {
        isFeeExempt[holder_] = exempt_;
    }

    function setIsTxLimitExempt(address holder_, bool exempt_) external onlyOwner {
        isTxLimitExempt[holder_] = exempt_;
    }

    function setIsFreezeExempt(address holder_, bool exempt_) external onlyOwner {
        isFreezeExempt[holder_] = exempt_;
    }

    function setSwapBackSettings(bool enabled_, uint256 amount_) external onlyOwner {
        swapEnabled = enabled_;
        swapThreshold = amount_;
    }
    
    function setLiquifyEnabled(bool enabled_) external onlyOwner {
        liquifyEnabled = enabled_;
    }

    function setDistributorSettings(uint256 gas_) external onlyOwner {
        distributorGas = gas_;
    }

    /*
     * Read Contract Settings
     */
    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function setFeesOnNormalTransfers(bool enabled_) external onlyOwner {
        feesOnNormalTransfers = enabled_;
    }

    function setLaunchedAt(uint256 launched_) external onlyOwner {
        launchedAt = launched_;
    }

}