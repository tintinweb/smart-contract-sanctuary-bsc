/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

interface IV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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
}

interface IReflectionDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit() external payable;

    function process(uint256 gas) external;
}

contract ReflectionDistributor is IReflectionDistributor {
    address public token;

    //--------------------------------------
    // Data structure
    //--------------------------------------

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    //--------------------------------------
    // State variables
    //--------------------------------------

    IERC20 public BUSD;
    IV2Router02 router;

    address[] shareholders;
    mapping(address => uint256) shareholderIndexes;
    mapping(address => uint256) shareholderClaims;

    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalReflections;
    uint256 public totalDistributed;
    uint256 public reflectionsPerShare;
    uint256 public reflectionsPerShareAccuracyFactor = 10**36;

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10**18);

    uint256 currentIndex;

    modifier onlyToken() {
        require(msg.sender == token);
        _;
    }

    constructor(IV2Router02 _router, IERC20 _busd) {
        router = _router;
        BUSD = _busd;
        token = msg.sender;
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount)
        external
        override
        onlyToken
    {
        if (shares[shareholder].amount > 0) {
            distributeReflection(shareholder);
        }

        if (amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }

        totalShares = totalShares + amount - shares[shareholder].amount;
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeReflections(
            shares[shareholder].amount
        );
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = BUSD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(BUSD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: msg.value
        }(0, path, address(this), block.timestamp);

        uint256 amount = BUSD.balanceOf(address(this)) - balanceBefore;

        totalReflections = totalReflections + amount;
        reflectionsPerShare =
            reflectionsPerShare +
            (reflectionsPerShareAccuracyFactor * amount) /
            totalShares;
    }

    function process(uint256 gas) external override onlyToken {
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
                distributeReflection(shareholders[currentIndex]);
            }

            gasUsed = gasUsed + gasLeft - gasleft();
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder)
        internal
        view
        returns (bool)
    {
        return
            shareholderClaims[shareholder] + minPeriod < block.timestamp &&
            getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeReflection(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0) {
            totalDistributed = totalDistributed + amount;
            BUSD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised =
                shares[shareholder].totalRealised +
                amount;
            shares[shareholder].totalExcluded = getCumulativeReflections(
                shares[shareholder].amount
            );
        }
    }

    function claimReflection() external {
        distributeReflection(msg.sender);
    }

    function getUnpaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
        if (shares[shareholder].amount == 0) {
            return 0;
        }

        uint256 shareholderTotalReflections = getCumulativeReflections(
            shares[shareholder].amount
        );
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalReflections <= shareholderTotalExcluded) {
            return 0;
        }

        return shareholderTotalReflections - shareholderTotalExcluded;
    }

    function getCumulativeReflections(uint256 share)
        internal
        view
        returns (uint256)
    {
        return
            (share * reflectionsPerShare) / reflectionsPerShareAccuracyFactor;
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

    function setRouter(IV2Router02 _router) external onlyToken {
        router = _router;
    }

    function setBUSD(IERC20 _busd) external onlyToken {
        BUSD = _busd;
    }
}

/**
 * @dev Cutoken token contract
 *
 * The `owner` account of Cutoken token contract will be multi-sig wallet.
 */
contract Cutoken is Ownable, IERC20, IERC20Metadata, Pausable {
    struct Fee {
        uint256 lp;
        uint256 reflect;
        uint256 fundraise;
        uint256 market;
    }

    // 1: 0.01%, 100: 1%, 10000: 100%
    uint256 public constant MAX_FEE = 5000;
    uint256 public constant DENOMINATOR = 10000;
    uint256 public constant LIMIT = 500;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) public isWhitelist;
    mapping(address => bool) public isBlacklist;
    mapping(address => bool) public isReflectionExempt;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    address public pair;
    IV2Router02 public router;

    uint256 public limitToAddLp;
    uint256 public limitTransfer;
    uint256 public limitToReflection;

    address public lpWallet;
    address public fundraiseWallet;
    address public marketWallet;

    uint256 private lpFee;
    uint256 private reflectFee;
    uint256 private fundraiseFee;
    uint256 private marketFee;

    Fee public buyFee;
    Fee public sellFee;

    address public minter;

    bool public isTradingEnabled;
    bool public swapAndLiquifyEnabled;

    uint256 public pendingLpFee;
    uint256 public pendingReflectionFee;
    bool private shouldTakeFee;
    bool private inSwapAndLiquify;

    ReflectionDistributor public distributor;
    uint256 public distributorGas;

    event LogReceive(address indexed from, uint256 amount);
    event LogFallback(address indexed from, uint256 amount);
    event LogSetMinter(address indexed minter);
    event LogSetPair(address indexed pair);
    event LogSetRouter(IV2Router02 indexed router);
    event LogSetWhitelist(address indexed account, bool set);
    event LogSetBlacklist(address indexed account, bool set);
    event LogSetEnableTrading(bool set);
    event LogSetEnableSwapAndLiquify(bool set);
    event LogSetLimitToAddLp(uint256 indexed amount);
    event LogSetLimitToReflection(uint256 indexed amount);
    event LogSetLimitTransfer(uint256 indexed amount);
    event LogSetBuyFee(address indexed setter, Fee buyFee);
    event LogSetSellFee(address indexed setter, Fee sellFee);
    event LogSwapAndAddLp(uint256 indexed lp, uint256 token, uint256 eth);
    event LogSwapAndReflection(uint256 indexed eth);
    event LogWithdrawETH(address indexed to, uint256 amount);
    event LogWithdrawToken(IERC20 indexed token, address to, uint256 amount);
    event LogSetLpWallet(address indexed lpWallet);
    event LogSetFundraiseWallet(address indexed fundraiseWallet);
    event LogSetMarketWallet(address indexed marketWallet);
    event LogSetDistributorGas(uint256 indexed gas);
    event LogSetDistributorBUSD(IERC20 indexed busd);
    event LogSetDistributionCriteria(
        uint256 indexed minPeriod,
        uint256 indexed minDistribution
    );
    event LogSetIsReflectionExempt(address indexed account, bool set);

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     *
     * It is not need to do `Zero-address check` of input params because deployer will check these before deploy.
     */
    constructor(
        IV2Router02 _router,
        IERC20 _busd,
        address _lpWallet,
        address _fundraiseWallet,
        address _marketWallet
    ) {
        _name = "Cutoken";
        _symbol = "CT";

        minter = msg.sender;

        pair = IV2Factory(_router.factory()).createPair(
            address(this),
            _router.WETH()
        );

        router = _router;

        isWhitelist[address(this)] = true;
        isWhitelist[owner()] = true;

        swapAndLiquifyEnabled = true;

        lpWallet = _lpWallet;
        fundraiseWallet = _fundraiseWallet;
        marketWallet = _marketWallet;

        buyFee.lp = 100;
        buyFee.reflect = 100;
        buyFee.fundraise = 100;
        buyFee.market = 200;

        sellFee.lp = 200;
        sellFee.reflect = 200;
        sellFee.fundraise = 200;
        sellFee.market = 500;

        limitToAddLp = 10**3 * 10**9;
        limitTransfer = 10**4 * 10**9;
        limitToReflection = 10**3 * 10**9;

        distributor = new ReflectionDistributor(router, _busd);
        distributorGas = 500000;

        isReflectionExempt[pair] = true;
        isReflectionExempt[address(this)] = true;
        isReflectionExempt[address(0xdEaD)] = true;
        isReflectionExempt[address(0x0)] = true;
    }

    modifier lockSwapAndAddLp() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() external view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() external view virtual override returns (uint8) {
        return 9;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
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
    function transfer(address to, uint256 amount)
        public
        virtual
        override
        whenNotPaused
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
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
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
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
    ) public virtual override whenNotPaused returns (bool) {
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
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
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
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        bool isSwapAndAddLp = pendingLpFee >= limitToAddLp;
        if (
            swapAndLiquifyEnabled &&
            isSwapAndAddLp &&
            pair != from &&
            pair != to &&
            !inSwapAndLiquify
        ) {
            swapAndAddLpAndReflection();
        }

        require(!isBlacklist[from] && !isBlacklist[to], "Cutoken: isBlacklist");

        if (!isWhitelist[from] && !isWhitelist[to]) {
            require(isTradingEnabled, "Trading is disabled");

            require(
                amount <= limitTransfer,
                "Cutoken: EXCEED_LIMIT_AMOUNT_TO_TRANSFER"
            );

            shouldTakeFee = true;

            if (pair == from) {
                applyBuyFee();
            } else if (pair == to) {
                applySellFee();
            } else {
                shouldTakeFee = false;
            }
        }

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        _balances[from] = fromBalance - amount;

        uint256 transferAmount = takeFee(from, amount);

        _balances[to] += transferAmount;

        // Dividend tracker
        if (!isReflectionExempt[from]) {
            try distributor.setShare(from, _balances[from]) {} catch {}
        }

        if (!isReflectionExempt[to]) {
            try distributor.setShare(to, _balances[to]) {} catch {}
        }

        try distributor.process(distributorGas) {} catch {}

        if (shouldTakeFee == true) {
            shouldTakeFee = false;
            restoreAllFee();
        }

        emit Transfer(from, to, transferAmount);

        _afterTokenTransfer(from, to, amount);
    }

    function swapAndAddLpAndReflection() private lockSwapAndAddLp {
        uint256 half = limitToAddLp / 2;
        uint256 otherHalf = limitToAddLp - half;

        uint256 initialBalance = address(this).balance;

        swapTokensForETH(half);

        uint256 newBalance = address(this).balance - initialBalance;

        (uint256 token, uint256 eth, uint256 lp) = addLiquidity(
            otherHalf,
            newBalance
        );

        pendingLpFee -= limitToAddLp;

        if (pendingReflectionFee >= limitToReflection) {
            initialBalance = address(this).balance;

            swapTokensForETH(limitToReflection);

            newBalance = address(this).balance - initialBalance;

            try distributor.deposit{value: newBalance}() {} catch {}

            pendingReflectionFee -= limitToReflection;

            emit LogSwapAndReflection(newBalance);
        }

        emit LogSwapAndAddLp(lp, token, eth);
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // slippage is unavoidable
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount)
        private
        returns (
            uint256 token,
            uint256 eth,
            uint256 lp
        )
    {
        _approve(address(this), address(router), tokenAmount);

        (token, eth, lp) = router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            lpWallet,
            block.timestamp
        );
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
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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
    ) internal virtual {
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
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function takeFee(address from, uint256 amount)
        private
        returns (uint256 transferAmount)
    {
        transferAmount = amount;
        if (shouldTakeFee == true) {
            uint256 lpFeeAmount = (amount * lpFee) / DENOMINATOR;
            uint256 reflectFeeAmount = (amount * reflectFee) / DENOMINATOR;
            uint256 fundraiseFeeAmount = (amount * fundraiseFee) / DENOMINATOR;
            uint256 marketFeeAmount = (amount * marketFee) / DENOMINATOR;

            pendingLpFee += lpFeeAmount;
            pendingReflectionFee += reflectFeeAmount;

            _balances[address(this)] += (lpFeeAmount + reflectFeeAmount);
            _balances[fundraiseWallet] += fundraiseFeeAmount;
            _balances[marketWallet] += marketFeeAmount;

            transferAmount -= (lpFeeAmount +
                reflectFeeAmount +
                fundraiseFeeAmount +
                marketFeeAmount);

            emit Transfer(from, address(this), lpFeeAmount + reflectFeeAmount);
            emit Transfer(from, fundraiseWallet, fundraiseFeeAmount);
            emit Transfer(from, marketWallet, marketFeeAmount);
        }
    }

    function restoreAllFee() private {
        lpFee = 0;
        reflectFee = 0;
        fundraiseFee = 0;
        marketFee = 0;
    }

    function applyBuyFee() private {
        lpFee = buyFee.lp;
        reflectFee = buyFee.reflect;
        fundraiseFee = buyFee.fundraise;
        marketFee = buyFee.market;
    }

    function applySellFee() private {
        lpFee = sellFee.lp;
        reflectFee = sellFee.reflect;
        fundraiseFee = sellFee.fundraise;
        marketFee = sellFee.market;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    modifier onlyMinter() {
        require(msg.sender == minter, "Cutoken: NOT_MINTER");
        _;
    }

    function mint(address account, uint256 amount)
        external
        onlyMinter
        whenNotPaused
    {
        _mint(account, amount);
    }

    receive() external payable {
        emit LogReceive(msg.sender, msg.value);
    }

    fallback() external payable {
        emit LogFallback(msg.sender, msg.value);
    }

    function setPause() external onlyOwner {
        _pause();
    }

    function setUnpause() external onlyOwner {
        _unpause();
    }

    function setMinter(address _minter) external onlyOwner {
        minter = _minter;
        emit LogSetMinter(_minter);
    }

    function setPair(address _pair) external onlyOwner {
        pair = _pair;
        emit LogSetPair(pair);
    }

    function setRouter(IV2Router02 _router) external onlyOwner {
        router = _router;
        distributor.setRouter(_router);
        emit LogSetRouter(router);
    }

    function setDistributorBUSD(IERC20 _busd) external onlyOwner {
        distributor.setBUSD(_busd);
        emit LogSetDistributorBUSD(_busd);
    }

    function setDistributorGas(uint256 _gas) external onlyOwner {
        require(_gas < 750000);
        distributorGas = _gas;
        emit LogSetDistributorGas(_gas);
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
        emit LogSetDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setIsReflectionExempt(address _account, bool _set)
        external
        onlyOwner
    {
        require(_account != address(this) && _account != pair);
        isReflectionExempt[_account] = _set;
        if (_set) {
            distributor.setShare(_account, 0);
        } else {
            distributor.setShare(_account, _balances[_account]);
        }
        emit LogSetIsReflectionExempt(_account, _set);
    }

    function setWhitelist(address _account, bool _set) external onlyOwner {
        isWhitelist[_account] = _set;
        emit LogSetWhitelist(_account, _set);
    }

    function setBlacklist(address _account, bool _set) external onlyOwner {
        isBlacklist[_account] = _set;
        emit LogSetBlacklist(_account, _set);
    }

    function setEnableTrading(bool _set) external onlyOwner {
        isTradingEnabled = _set;
        emit LogSetEnableTrading(_set);
    }

    function setLimitToAddLp(uint256 _amount) external onlyOwner {
        require(
            _amount < (_totalSupply * LIMIT) / DENOMINATOR,
            "Cutoken: EXCEED_LIMIT_TO_ADD_LP"
        );
        limitToAddLp = _amount;
        emit LogSetLimitToAddLp(_amount);
    }

    function setLimitToReflection(uint256 _amount) external onlyOwner {
        require(
            _amount < (_totalSupply * LIMIT) / DENOMINATOR,
            "Cutoken: EXCEED_LIMIT_TO_ADD_LP"
        );
        limitToReflection = _amount;
        emit LogSetLimitToReflection(_amount);
    }

    function setLimitTransfer(uint256 _amount) external onlyOwner {
        require(
            _amount < (_totalSupply * LIMIT) / DENOMINATOR,
            "Cutoken: EXCEED_LIMIT_TRANSFER"
        );
        limitTransfer = _amount;
        emit LogSetLimitTransfer(_amount);
    }

    function setBuyFee(
        uint256 _lp,
        uint256 _reflect,
        uint256 _fundraise,
        uint256 _market
    ) external onlyOwner {
        require(
            (_lp + _reflect + _fundraise + _market) <= MAX_FEE,
            "EXCEED_MAX_FEE"
        );
        buyFee.lp = _lp;
        buyFee.reflect = _reflect;
        buyFee.fundraise = _fundraise;
        buyFee.market = _market;

        emit LogSetBuyFee(msg.sender, buyFee);
    }

    function setSellFee(
        uint256 _lp,
        uint256 _reflect,
        uint256 _fundraise,
        uint256 _market
    ) external onlyOwner {
        require(
            (_lp + _reflect + _fundraise + _market) <= MAX_FEE,
            "EXCEED_MAX_FEE"
        );
        sellFee.lp = _lp;
        sellFee.reflect = _reflect;
        sellFee.fundraise = _fundraise;
        sellFee.market = _market;

        emit LogSetSellFee(msg.sender, sellFee);
    }

    function setEnableSwapAndLiquify(bool _set) external onlyOwner {
        swapAndLiquifyEnabled = _set;
        emit LogSetEnableSwapAndLiquify(_set);
    }

    function setLpWallet(address _lpWallet) external onlyOwner {
        lpWallet = _lpWallet;
        emit LogSetLpWallet(lpWallet);
    }

    function setFundraiseWallet(address _fundraiseWallet) external onlyOwner {
        fundraiseWallet = _fundraiseWallet;
        emit LogSetFundraiseWallet(fundraiseWallet);
    }

    function setMarketWallet(address _marketWallet) external onlyOwner {
        marketWallet = _marketWallet;
        emit LogSetMarketWallet(marketWallet);
    }

    /**
     * @notice  Owner will withdraw ETH and will use to benefit the token holders.
     */
    function withdrawETH(address payable to, uint256 amount)
        external
        onlyOwner
    {
        require(amount <= (address(this)).balance, "INSUFFICIENT_FUNDS");
        to.transfer(amount);
        emit LogWithdrawETH(to, amount);
    }

    /**
     * @notice  Owner will withdraw ERC20 token that have the price and then will use to benefit the token holders.
     #          Should not be withdrawn scam token or this token.
     */
    function withdrawToken(
        IERC20 token,
        address to,
        uint256 amount
    ) external onlyOwner {
        require(amount <= token.balanceOf(address(this)), "INSUFFICIENT_FUNDS");
        require(token.transfer(to, amount), "Transfer Fail");

        emit LogWithdrawToken(token, to, amount);
    }
}