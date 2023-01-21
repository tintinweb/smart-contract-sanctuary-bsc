/**
 *Submitted for verification at BscScan.com on 2023-01-21
*/

/*
 * Day of Defeat (DOD)
 *
 * Radical Social Experiment token mathematically designed to give holders 10,000,000X PRICE INCREASE
 *
 * Website: https://dayofdefeat.app/
 * Twitter: https://twitter.com/dayofdefeatBSC
 * Telegram: https://t.me/DayOfDefeatBSC
 * BTok: https://titanservice.cn/dayofdefeatCN
 *
 * By Studio L, Legacy Capital Division
*/

// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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

// File: StudioL/DOD/DODTokenV2.sol



pragma solidity ^0.8.7;




abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     */
    function decimals() external view returns (uint8) {
        return _decimals;
    }
}

interface IPancakeSwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IFundPool {
    function swapForFundPool() external;
}

interface IMarketingPool {
    function swapForMarketingPool() external;
}

/**
 * Ensure that the dao governance contract has been deployed correctly
 * before deploying the dod token contract
 */
contract DODToken_2_0 is Ownable, ReentrancyGuard, ERC20Detailed("Day of Defeat 2.0", "DOD", 18) {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    uint256 private constant genesisTotalSupply = 100000000000000 * 10 ** 18;

    uint256 private constant DIVISOR = 10000;
    uint256 private marketingFee = 400;
    uint256 private transitionFee = 1500;

    uint256 private constant maxFee = 2500; // The tax rate can be adjusted from 0% to 25%
    uint256 private constant transferLimit = 9999999999; // Limit per transfer
    uint256 private constant BASE = 10000000000;

    /**
     * When any one of the following three conditions is met,
     * the bonus pool will be triggered to start the voting mechanism.
     *
     * Triggering conditions:
     *
     * - When there is >=99,999,000BUSD in the bonus pool.
     * - When the total remaining amount of DOD <= 1,000,000,000 (1 billion).
     * - When the number of DOD burned >= 99,999,000,000,000 (999,99 billion).
     *
     * To learn more about the mechanism, please transfer to the official website to view.
     */
    uint256 private constant bonusPoolTrigger = 99999000 * 10 ** 18;
    uint256 private constant totalRemainingTrigger = 1000000000 * 10 ** 18;
    uint256 private constant totalBurnedTrigger = 99999000000000 * 10 ** 18;

    /**
     * When the conditions of the prize pool are met, if the voting is passed, the exchange will be started.
     * As long as DOD is transferred to the bonus pool address,
     * The bonus pool will automatically transfer BUSD to the corresponding wallet address at the rate of 0.1BUSD/DOD.
     * The redemption period is 90 days
     */
    uint256 private constant exchangePeriod = 90 days;

    /**
     * When the conditions are met, the rigid price of DOD to BUSD (1 DOD => 0.1 BUSD)
     */
    uint256 private constant dodToBusdMultiplier = 1000;

    /**
     * If none of the above three conditions are met,
     * the bonus pool will be automatically triggered after November 18, 2026 to open the voting mechanism.
     * Note: this time is relative to the deployment time of v1
     *
     * If the vote fails, the game continues without making any changes.
     * If the vote is passed, the bonus pool will be opened and the exchange will be opened.
     * But the conversion ratio needs to be determined according to the amount of DOD held.
     */
    uint256 private constant deadline = 1794931200; // November 18, 2026

    mapping(address => bool) public excludeFee; // Do trading accounts need to pay taxes
    mapping(address => bool) public includePair; // Trading Pair Limits for Selling

    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant BNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public constant FACTORY = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;

    address public pair; // BNB-DOD LP

    address private genesis; // genesis wallet address
    address private marketingPool; // marketing pool
    address private fundPool; // Fund pool
    address private governor; // governance contract
    bool private meetCriteria; // When the conditions of the prize pool are met.
    bool private pass; // If the voting is passed, the prize pool will be unlock.
    bool private swapStatus; // Whether to trigger an automatic call to a third party.
    bool private isFundSwap; // Indicator, which only triggers one swap operation at a time, and is executed alternately.
    bool private inSwap = false;
    uint256 public lastTriggerTime; // In order to reduce the trigger frequency and reduce the gas fee borne by the user
    uint256 public triggerInterval = 2 hours; // The trigger interval for checkUnlock and autoSwap.
    uint256 private unlockTime; // The unlock time when the unlock condition is met.
    /**
     * 
     * After the bonus pool is unlocked, the game is over and the transaction is closed.
     * At this time, users holding DOD can only swap in this contract and cannot trade in DEX
     * 
     * Notice:
     * Closing transactions are performed by the administrator, provided that the pool is unlocked
     * 
     */
    bool private stopTrade;

    /**
     * When unlocking, the bonus pool's (BUSD balance and total remaining amount of DOD)
     */
    uint256 private busdBalanceUnlocking;
    uint256 private totalSupplyUnlocking;

    event AdjustmentFee(address indexed operator, uint256 _marketingFee, uint256 _transitionFee);
    event SetVotePass(address indexed operator, bool _pass);
    event SetGovernor(address indexed newGovernor, address indexed oldGovernor);
    event UpdatePool(address indexed marketingPool, address indexed fundPool);
    event UnlockFundPool(address indexed operator, uint256 unlockTime);
    event SetTradeInCase(address indexed operator, bool enable);
    event SetSwapStatus(address indexed operator, bool swapStatus);
    event SetTriggerInterval(address indexed operator, uint256 _triggerInterval);
    event IncludePairLimit(address indexed operator, address pair, bool enable);
    event WithdrawToken(address indexed operator, address token, address to, uint256 amount);

    /**
     *  Note: After the token contract is deployed,
     *  all administrator privileges will be transferred to the multi-signature wallet address
     *  All FEE RECEIVER addresses use multi-signature wallets
     */
    constructor(address _genesis, address _governor) {
        require(_genesis != address(0), "Zero genesis address");
        require(_governor != address(0), "Zero governor");
        require(isContract(_governor), "Non contract address");
        genesis = _genesis;
        governor = _governor;

        excludeFee[address(this)] = true;
        excludeFee[genesis] = true;
        excludeFee[address(0)] = true;

        pair = IPancakeSwapFactory(FACTORY).createPair(
            BNB,
            address(this)
        );
        includePair[pair] = true;
        /**
         * Notes:
         * 
         * Add the `ROUTER` to includePair, otherwise, removing liquidity will fail.
         * When removing liquidity, tokens are transferred from pair to router,
         * and then transferred from router to user address
         * 
         */
        includePair[ROUTER] = true;

        // The totalSupply is assigned to the genesis
        _mint(_genesis, genesisTotalSupply);
    }

    modifier onlyGovernor () {
        require(_msgSender() == governor, "Governor: caller is not the governor");
        _;
    }

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() external pure override returns (uint256) {
        return genesisTotalSupply;
    }

    /**
     * @dev genesisTotalSupply - bured.
     */
    function circulatingSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) external override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     */
    function _transferUnchecked(
        address from,
        address to,
        uint256 amount
    ) private {

        unchecked {
            _balances[from] -= amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        if (stopTrade) {
            require(
                !includePair[from] && !includePair[to],
                "Trading in dex has been stopped"
            );
        }
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        // If `to` is the blackhole address,
        // it will be included in the totalSupply of destruction
        if (to == DEAD) {
            unchecked {
                _totalSupply -= amount;
            }
            return _transferUnchecked(from, to, amount);
        }

        if (inSwap || unlockTime != 0) {
            return _transferUnchecked(from, to, amount);
        }

        // Not triggered when buying. from = pair  
        if (
            !includePair[from] &&
            block.timestamp >= lastTriggerTime + triggerInterval
        ) {
            _autoSwapInPool();
            _checkUnlock();
        }

        uint256 fromAmount = amount;

        // 19% tax on all transactions.
        // Exclude `from` is `ROUTER` to avoid being charged twice
        // When removing liquidity, tokens are transferred from pair to router,
        // and then transferred from router to user address
        if (from != ROUTER && !excludeFee[from] && !excludeFee[to]) {
            if (marketingFee != 0) {
                uint256 marketTax = (fromAmount * marketingFee) / DIVISOR;
                _transferUnchecked(from, marketingPool, marketTax);
                amount -= marketTax;
            }
            if (transitionFee != 0) {
                uint256 transitionTax = (fromAmount * transitionFee) / DIVISOR;
                _transferUnchecked(from, fundPool, transitionTax);
                amount -= transitionTax;
            }
            // When sold all, leave a trace of dust..
            if (includePair[to] && fromAmount == fromBalance) {            
                amount = (amount * transferLimit) / BASE;
            }
        }

        _transferUnchecked(from, to, amount);

    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the `DEAD` address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _balances[DEAD] += amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, DEAD, amount);

    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = _allowances[owner][spender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Destroys `amount` tokens from `caller`, reducing the total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     */
    function burn(uint256 amount) external {
        // require(amount != 0, "DOD: burn zero amount");
        if (amount == 0) return;
        _burn(_msgSender(), amount);
    }

    function autoSwapInPool() external {
        _autoSwapInPool();
    }

    /**
     * @dev Swap trigger. Only one operation is triggered at a time, alternate execution
     */
    function _autoSwapInPool() internal swapping {
        if (swapStatus) {
            isFundSwap
                ? IFundPool(fundPool).swapForFundPool()
                : IMarketingPool(marketingPool).swapForMarketingPool();
            isFundSwap = !isFundSwap;
        }
    }

    /**
     * @dev Check whether the unlock trigger condition is met.
     *
     * Triggering conditions:
     *
     * - When there is >=99,999,000BUSD in the bonus pool.
     * - When the total remaining amount of DOD <= 1,000,000,000 (1 billion).
     * - When the number of DOD burned >= 99,999,000,000,000 (999,99 billion).
     */
    function _checkUnlock() internal {
        lastTriggerTime = block.timestamp;
        if (
            !meetCriteria &&
            (IERC20(BUSD).balanceOf(address(this)) >= bonusPoolTrigger ||
                _totalSupply <= totalRemainingTrigger ||
                genesisTotalSupply - _totalSupply >= totalBurnedTrigger ||
                block.timestamp >= deadline /* (November 18, 2026) 86400 * 30 * 12 * 5 */
            )
        ) {
            meetCriteria = true;
        }
    }

    /**
     * @dev Check whether the unlock trigger condition is met.
     * When the conditions are met and the vote is passed, the exchange is started
     */
    function swap(uint256 amount) external nonReentrant {
        require(meetCriteria && pass, "DOD: contract is locked");
        require(unlockTime != 0, "DOD: vote failed");
        require(
            block.timestamp <= unlockTime + exchangePeriod,
            "DOD: The redemption time has passed"
        );

        address sender = _msgSender();
        IERC20(address(this)).transferFrom(sender, address(this), amount);

        /**
         * 1. Before the deadline, all conditions are met,
         * and the bonus pool is unlocked, 1DOD:0.1BUSD swap.
         * 
         * 2. In any other case,
         * swap according to the ratio of the swap amount to the totalSupply amount of DOD
         */
        if (
            IERC20(BUSD).balanceOf(address(this)) >= bonusPoolTrigger &&
                _totalSupply <= totalRemainingTrigger &&
                genesisTotalSupply - _totalSupply >= totalBurnedTrigger
        ) {
            IERC20(BUSD).transfer(
                sender,
                (amount * dodToBusdMultiplier) / DIVISOR
            );
        } else {
            require(
                busdBalanceUnlocking != 0 && totalSupplyUnlocking != 0,
                "Abnormal quantity"
            );
            IERC20(BUSD).transfer(
                sender,
                (amount * busdBalanceUnlocking) / totalSupplyUnlocking
            );
        }
    }

    /**
     * @dev Current unlock exchange information.
     */
    function getUnlockInfo()
        external
        view
        returns (
            uint256 _busdBalanceUnlocking,
            uint256 _totalSupplyUnlocking,
            uint256 _unlockTime,
            bool _stopTrade,
            bool _meetCriteria,
            bool _pass,
            uint256 _deadline,
            uint256 _exchangePeriod,
            uint256 _dodToBusdMultiplier
        )
    {
        return (
            busdBalanceUnlocking,
            totalSupplyUnlocking,
            unlockTime,
            stopTrade,
            meetCriteria,
            pass,
            deadline,
            exchangePeriod,
            dodToBusdMultiplier
        );
    }

    /**
     * @dev Current pool address.
     */
    function getPool() external view returns (address marketing, address fund) {
        return (marketingPool, fundPool);
    }

    /**
     * @dev Current unlock exchange information.
     */
    function getFeeInfo()
        external
        view
        returns (
            address _genesis,
            address _governor,
            bool _swapStatus,
            bool _isFundSwap,
            uint256 _lastTriggerTime,
            uint256 _triggerInterval,
            uint256 _marketingFee,
            uint256 _transitionFee,
            uint256 _maxFee,
            uint256 _BASE,
            uint256 _bonusPoolTrigger,
            uint256 _totalRemainingTrigger,
            uint256 _totalBurnedTrigger
        )
    {
        return (
            genesis,
            governor,
            swapStatus,
            isFundSwap,
            lastTriggerTime,
            triggerInterval,
            marketingFee,
            transitionFee,
            maxFee,
            BASE,
            bonusPoolTrigger,
            totalRemainingTrigger,
            totalBurnedTrigger
        );
    }

    // ============================================== Governor operation ==============================================
    /**
     * @dev Regulate fees within limits (maximum 25%)
     */
    function adjustmentFee(
        uint256 _marketingFee,
        uint256 _transitionFee
    ) external onlyGovernor {
        require(
            _marketingFee + _transitionFee <= maxFee,
            "DOD: total tax over range"
        );
        marketingFee = _marketingFee;
        transitionFee = _transitionFee;
        emit AdjustmentFee(_msgSender(), _marketingFee, _transitionFee);
    }

    /**
     * @dev Voting passed, governance contract execution
     */
    function setVotePass() external onlyGovernor {
        require(!pass, "DOD: is currently passed");
        pass = true;
        emit SetVotePass(_msgSender(), pass);
    }

    /**
     * @dev Set up the governance contract
     */
    function setGovernor(address _newGovernor) external onlyGovernor {
        require(_newGovernor != address(0), "error governor");
        require(governor != _newGovernor, "same address");
        emit SetGovernor(_newGovernor, governor);
        governor = _newGovernor;
    }

    /**
     * @dev In case of emergency, change the pool address
     * - The pool address is the contract address or multi-signature address
     */
    function setPoolInCase(address _marketingPool, address _fundPool) external onlyGovernor {
        require(marketingPool != address(0), "MarketingPool: uninitialized");
        require(fundPool != address(0), "FundPool: uninitialized");

        _updatePool(_marketingPool, _fundPool);
    }

    /**
     * @dev Just in case, if a user has liquidity and has not lift it,
     * requests to open/close the transaction through the governance contract.
     * 
     * Any operation is prohibited before the bonus pool is unlocked
     */
    function setTradeInCase(bool enable) external onlyGovernor {
        require(unlockTime != 0, "Bonus pool not unlocked");
        require(stopTrade != enable, "Same status");
        stopTrade = enable;
        emit SetTradeInCase(_msgSender(), enable);
    }

    /**
     * @dev If the DOD token is attacked or needs to be migrated,
     * transfer the assets in the contract to the new address
     */
    function withdrawToken(
        address _token,
        address _to,
        uint256 _amount
    ) external onlyGovernor {
        if (_token == address(0)) {
            payable(_to).transfer(_amount);
        } else {
            IERC20(_token).transfer(_to, _amount);
        }
        emit WithdrawToken(_msgSender(), _token, _to, _amount);
    }
    // ============================================== Owner operation ==============================================
    
    /**
     * Initialize after deploying the token contract
     */
    function initializePool(address _marketingPool, address _fundPool) external onlyOwner {
        require(marketingPool == address(0), "MarketingPool: has been set");
        require(fundPool == address(0), "FundPool: has been set");
        _updatePool(_marketingPool, _fundPool);
    }

    function _updatePool(address _marketingPool, address _fundPool) internal {
        require(isContract(_marketingPool), "MarketingPool: non contract address");
        require(isContract(_fundPool), "FundPool: non contract address");
        marketingPool = _marketingPool;
        fundPool = _fundPool;
        emit UpdatePool(_marketingPool, _fundPool);

        excludeFee[marketingPool] = true;
        excludeFee[fundPool] = true;
    }

    /**
     * @dev When the vote is passed, the administrator needs to unlock it
     * When the bonus pool is unlocked, close the DEX transaction
     * 
     * NOTICE:
     * Make sure that the liquidity has been removed before unlocking,
     * otherwise the user who added liquidity will not be able to unlock the liquidity
     * after unlocking and will be permanently locked
     */
    function unlockFundPool() external onlyOwner {
        require(pass, "Unlock: vote failed");
        require(
            IERC20(pair).balanceOf(genesis) < 10 ** 18,
            "Unlock: genesis did not remove liquidity"
        );

        unlockTime = block.timestamp;
        busdBalanceUnlocking = IERC20(BUSD).balanceOf(address(this));
        totalSupplyUnlocking = _totalSupply;
        emit UnlockFundPool(_msgSender(), unlockTime);

        stopTrade = true;
        emit SetTradeInCase(_msgSender(), true);
    }

    /**
     * @dev Include/exclude pair selling limit
     */
    function includePairLimit(address addr, bool enable) external onlyOwner {
        require(addr != address(0), "DOD: zero address");
        require(includePair[addr] != enable, "DOD: same value");
        includePair[addr] = enable;
        emit IncludePairLimit(_msgSender(), addr, enable);
    }

    /**
     * @dev Turn on/off third-party automatic swap calls
     */
    function setSwapStatus(bool enable) external onlyOwner {
        require(swapStatus != enable, "DOD: same value");
        swapStatus = enable;
        emit SetSwapStatus(_msgSender(), enable);
    }

    /**
     * @dev Set trigger interval
     */
    function setTriggerInterval(uint256 _triggerInterval) external onlyOwner {
        require(triggerInterval != _triggerInterval, "DOD: same value");
        require(_triggerInterval != 0, "DOD: zero value");
        triggerInterval = _triggerInterval;
        emit SetTriggerInterval(_msgSender(), _triggerInterval);
    }

    /**
     * @dev Add/Remove Fee Whitelist
     */
    function setExcludeFee(address account, bool enable) external onlyOwner {
        require(account != address(0), "DOD: zero address");
        require(excludeFee[account] != enable, "DOD: same value");
        excludeFee[account] = enable;
    }

    /**
     * @dev Add/Remove Fee Whitelist in batches
     */
    function batchSetExcludeFee(
        address[] calldata accounts,
        bool[] calldata enables
    ) external onlyOwner {
        require(accounts.length == enables.length, "DOD: array mismatch");
        for (uint256 i = 0; i < accounts.length; i++) {
            require(accounts[i] != address(0), "DOD: zero address");
            require(excludeFee[accounts[i]] != enables[i], "DOD: same value");
            excludeFee[accounts[i]] = enables[i];
        }
    }

}