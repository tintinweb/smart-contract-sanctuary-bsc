/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

/**
 * Submitted for verification at BscScan.com on 2022-03-13
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

/* Interfaces */
/**
 * @dev Interface of the BEP20 standard as defined in the EIP.
 */
interface IBEP20 {
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
     * @dev Returns the token decimals.
     */
    function decimals() external pure returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external pure returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external pure returns (string memory);

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
 * @dev Interface of the PancakeSwap factory.
 */
interface IPancakeSwapFactory {
    /**
     * @dev Return the canonical address for the WBNB token (ETH = BNB).
     */
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

/**
 * @dev Interface of the PancakeSwap router.
 */
interface IPancakeSwapRouter {
    /**
     * @dev Return the address for the router.
     */
    function factory() external pure returns (address);

    /**
     * @dev Return the canonical address for the WBNB token (ETH = BNB).
     */
    function WETH() external pure returns (address);

    /**
     * @dev Swap BNB.
     */
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    /**
     * @dev Swap BNB.
     */
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

/**
 * @dev Interface of the BUSD dividend distributor.
 */
interface IDividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit() external payable;

    function process(uint256 gas) external;
}

/**
 * @dev Interface of the PinkSale anti-bot.
 */
interface IPinkAntiBot {
    function setTokenOwner(address owner) external;

    function onPreTransferCheck(
        address from,
        address to,
        uint256 amount
    ) external;
}

/* Interfaces */

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
 * @dev Contract module which distributes BUSD dividend to Web3Santa token holders.
 */
contract DividendDistributor is IDividendDistributor {
    // Types
    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    // Mappings
    mapping(address => uint256) shareholderIndexes;
    mapping(address => uint256) shareholderClaims;
    mapping(address => Share) public shares;

    // Addresses
    address[] shareholders;
    address _token;

    // Booleans
    bool initialized;

    // BUSD
    IBEP20 BUSD;
    address private constant BUSD_CONTRACT_ADDRESS =
        0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; // Testnet
    // address private constant BUSD_CONTRACT_ADDRESS = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // Mainnet

    // PancakeSwap
    IPancakeSwapRouter router;
    address private constant PANCAKE_ROUTER_CONTRACT_ADDRESS =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;

    // Dividend distribute factors
    uint256 public dividendsPerShareAccuracyFactor;
    uint256 public minPeriod;
    uint256 public minDistribution;
    uint256 public totalShares;
    uint256 public totalDividend;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public currentIndex;

    // Modifiers
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(
            msg.sender == _token,
            "DividendDistributor: a router is not the PancakeSwap."
        );
        _;
    }

    // Constructor
    constructor(address _router) {
        _token = msg.sender;

        // Set PancakeSwap router
        router = _router != address(0)
            ? IPancakeSwapRouter(_router)
            : IPancakeSwapRouter(PANCAKE_ROUTER_CONTRACT_ADDRESS);

        // Set BUSD
        BUSD = IBEP20(BUSD_CONTRACT_ADDRESS);

        // Set dividend distribute factors
        dividendsPerShareAccuracyFactor = 10**36;
        minPeriod = 1 hours;
        minDistribution = 1 * (10**18);
    }

    // External functions
    /**
     * @dev Only token contract can set distribution criteria for dividend distributor.
     */
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    /**
     * @dev Only token contract can set the number of shares owned by the address.
     */
    function setShare(address shareholder, uint256 amount)
        external
        override
        onlyToken
    {
        if (shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }

        if (amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }

        totalShares = totalShares - shares[shareholder].amount + amount;
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividend(
            shares[shareholder].amount
        );
    }

    /**
     * @dev Only token contract can deposit funds into the pool.
     */
    function deposit() external payable override onlyToken {
        uint256 balanceBefore = BUSD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(BUSD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: msg.value
        }(0, path, address(this), block.timestamp);

        uint256 amount = BUSD.balanceOf(address(this)) - balanceBefore;

        totalDividend = totalDividend + amount;
        dividendsPerShare =
            dividendsPerShare +
            ((dividendsPerShareAccuracyFactor * amount) / totalShares);
    }

    /**
     * @dev Allow user to manually claim their accumulated dividend.
     */
    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    /**
     * @dev Only token contract can process and trigger dividend distribution.
     */
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
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    // Public functions
    /**
     * @dev Get undistributed dividend.
     */
    function getUndistributedDividends(address shareholder)
        public
        view
        returns (uint256)
    {
        if (shares[shareholder].amount == 0) {
            return 0;
        }

        uint256 shareholderTotalDividend = getCumulativeDividend(
            shares[shareholder].amount
        );
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalDividend <= shareholderTotalExcluded) {
            return 0;
        }

        return shareholderTotalDividend - shareholderTotalExcluded;
    }

    /**
     * @dev Get holder's details.
     */
    function getHolderDetails(address shareholder)
        public
        view
        returns (
            uint256 lastClaim,
            uint256 undistributedDividends,
            uint256 totalReward,
            uint256 holderIndex
        )
    {
        lastClaim = shareholderClaims[shareholder];
        undistributedDividends = getUndistributedDividends(shareholder);
        totalReward = shares[shareholder].totalRealised;
        holderIndex = shareholderIndexes[shareholder];
    }

    // Internal functions
    /**
     * @dev Distribute dividend to the shareholders and update dividend information.
     */
    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint256 amount = getUndistributedDividends(shareholder);
        if (amount > 0) {
            totalDistributed = totalDistributed + amount;
            BUSD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised =
                shares[shareholder].totalRealised +
                amount;
            shares[shareholder].totalExcluded = getCumulativeDividend(
                shares[shareholder].amount
            );
        }
    }

    /**
     * @dev Remove the address from the array of shareholders.
     */
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[
            shareholders.length - 1
        ];
        shareholderIndexes[
            shareholders[shareholders.length - 1]
        ] = shareholderIndexes[shareholder];
        shareholders.pop();

        // Remove the relevant data from shareholderIndexes to prevent unexpected errors.
        delete shareholderIndexes[shareholder];
    }

    // Internal functions that are view
    /**
     * @dev Check if all the predetermined conditions for dividend distribution have been met.
     */
    function shouldDistribute(address shareholder)
        internal
        view
        returns (bool)
    {
        return
            shareholderClaims[shareholder] + minPeriod < block.timestamp &&
            getUndistributedDividends(shareholder) > minDistribution;
    }

    /**
     * @dev Get cumulative dividend.
     */
    function getCumulativeDividend(uint256 share)
        internal
        view
        returns (uint256)
    {
        return (share * dividendsPerShare) / dividendsPerShareAccuracyFactor;
    }

    /**
     * @dev Add the address to the array of shareholders.
     */
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
}

/**
 * @dev Contract module which provides a 3% BUSD reflection from a trading volume with a 5% tax.
 */
contract Test is IBEP20, Ownable {
    // Maps
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => uint256) private balances;
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isDividendExempt;
    mapping(address => bool) public botBlacklist;

    // Naming
    string private constant NAME = "Test";
    string private constant SYMBOL = "Test";

    // Decimal handling
    uint8 private constant DECIMALS = 18;
    uint256 private constant DECIMAL_FACTOR = 10**DECIMALS;

    // Total supply
    uint256 private constant ONE_BILLION = 100000000000; // One hundred billion
    uint256 private constant TOTAL_SUPPLY = ONE_BILLION * DECIMAL_FACTOR;

    // Contract Swap
    bool inContractSwap;
    bool public contractSwapEnabled;
    uint256 public contractSwapThreshold;

    // PinkSale Anti-bot
    bool public pinkAntiBotEnabled;
    IPinkAntiBot public pinkAntiBot;

    // Fees
    uint256 public busdDividendFee;
    uint256 public developmentFee;
    uint256 public donationFee;
    uint256 public marketingAndDAOFee;
    uint256 public totalTax;
    uint256 public taxDenominator;

    // Addresses
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address private constant ZERO = 0x0000000000000000000000000000000000000000;
    address public busdDividendAddress;
    address public developmentWalletAddress;
    address public donationWalletAddress;
    address public marketingAndDAOWalletAddress;

    // Dividend Distributor
    uint256 private constant MAX_DIVIDEND_DISTRIBUTOR_GAS_FEE = 750000;
    DividendDistributor public distributor;
    uint256 public distributorGas;

    // PancakeSwap
    IPancakeSwapRouter public router;
    address public pair;

    // Events
    event SetDividendExempt(address holder, bool exempt);
    event SetFeeExempt(address holder, bool exempt);
    event SetWalletLimitExempt(address holder, bool exempt);
    event SetDistributionCriteria(uint256 minPeriod, uint256 minDistribution);
    event SetDistributorGas(uint256 gas);
    event SetContractSwapEnabled(bool enable);
    event SetEnablePinkAntiBot(bool enable);

    // Modifiers
    // Prevent transferring tokens to the 0x0 address and the contract address
    modifier validRecipient(address to) {
        require(
            to != address(0x0),
            "Transfer: the receiver cannot be ZERO address."
        );
        require(
            to != address(this),
            "Transfer: the receiver cannot be the contract address."
        );
        _;
    }

    // Prevent getting caught in a circular event.
    modifier swapping() {
        inContractSwap = true;
        _;
        inContractSwap = false;
    }

    // Constructor
    constructor() Ownable() {
        // PancakeSwap
        // router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // MAINNET
        router = IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // TESTNET
        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        // Dividend Distributor
        distributor = new DividendDistributor(pair);
        distributorGas = 500000;

        // Set addresses
        busdDividendAddress = address(distributor);
        developmentWalletAddress = 0xE65690b556A9894020bB444D9bF55c17c06453D1;
        donationWalletAddress = 0x41BDcADA2A5018b0F95dC219971cF171F2799A11;
        marketingAndDAOWalletAddress = 0xaEFde9b261a05aa1D7C147B44590ba8E72cAf529;

        // Set fees
        busdDividendFee = 30; // 3%
        developmentFee = 5; // 0.5%
        donationFee = 5; // 0.5%
        marketingAndDAOFee = 10; // 1%
        totalTax =
            busdDividendFee +
            developmentFee +
            donationFee +
            marketingAndDAOFee; // 5%
        taxDenominator = 1000;

        // Set false initially since we do presale on PinkSale
        contractSwapEnabled = false;
        contractSwapThreshold = TOTAL_SUPPLY / 2000; // 0.005%

        // Set dividend exempts
        // Remove all tax wallets from dividend.
        // Thus, holders can get more BUSD dividend.
        isDividendExempt[msg.sender] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[ZERO] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[developmentWalletAddress] = true;
        isDividendExempt[donationWalletAddress] = true;
        isDividendExempt[marketingAndDAOWalletAddress] = true;

        // Set fee exempts
        isFeeExempt[msg.sender] = true;
        isFeeExempt[developmentWalletAddress] = true;
        isFeeExempt[donationWalletAddress] = true;
        isFeeExempt[marketingAndDAOWalletAddress] = true;

        // Set total supply as an allowance from the contract to PancakeSwap
        allowances[address(this)][address(router)] = TOTAL_SUPPLY;

        // Create an instance of the PinkAntiBot variable from the provided address
        pinkAntiBot = IPinkAntiBot(0xbb06F5C7689eA93d9DeACCf4aF8546C4Fe0Bf1E5);
        // Register the deployer to be the token owner with PinkAntiBot
        pinkAntiBot.setTokenOwner(msg.sender);
        pinkAntiBotEnabled = false;

        balances[msg.sender] = TOTAL_SUPPLY;
        emit Transfer(address(0x0), msg.sender, TOTAL_SUPPLY);
    }

    // Receive function
    receive() external payable {} // Recieve ETH from PancakeSwap when swaping

    // External functions
    /**
     * @dev Use this function to control whether to use PinkAntiBot or not instead
     * of managing this in the PinkAntiBot contract
     */
    function setEnablePinkAntiBot(bool enable) external onlyOwner {
        pinkAntiBotEnabled = enable;

        emit SetEnablePinkAntiBot(enable);
    }

    /**
     * @dev See {IBEP20-transfer}.
     */
    function transfer(address to, uint256 value)
        external
        override
        validRecipient(to)
        returns (bool)
    {
        return _transferFrom(msg.sender, to, value);
    }

    /**
     * @dev See {IBEP20-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {
        require(
            allowances[from][msg.sender] - value >= 0,
            "Insufficient allowance"
        );
        if (allowances[from][msg.sender] != type(uint256).max) {
            allowances[from][msg.sender] = allowances[from][msg.sender] - value;
        }

        return _transferFrom(from, to, value);
    }

    /**
     * @dev See {IBEP20-approve}.
     */
    function approve(address spender, uint256 value)
        external
        override
        returns (bool)
    {
        allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Anti-bot measure.
     */
    function setBotBlacklist(address _botAddress, bool _flag)
        external
        onlyOwner
    {
        require(
            isContract(_botAddress),
            "SetBotBlacklist: an externally-owned address cannot be blacklisted."
        );
        botBlacklist[_botAddress] = _flag;
    }

    /**
     * @dev Exempt an address from dividend.
     */
    function setIsDividendExempt(address holder, bool exempt)
        external
        onlyOwner
    {
        require(
            holder != address(this) && holder != pair && holder != DEAD,
            "Failed to set dividend exempt."
        );
        isDividendExempt[holder] = exempt;

        if (exempt) {
            distributor.setShare(holder, 0);
        } else {
            distributor.setShare(holder, balanceOf(holder));
        }
        emit SetDividendExempt(holder, exempt);
    }

    /**
     * @dev Exempt an address from fee.
     */
    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
        emit SetFeeExempt(holder, exempt);
    }

    /**
     * @dev Set the criteria for dividend distribution.
     */
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
        emit SetDistributionCriteria(_minPeriod, _minDistribution);
    }

    /**
     * @dev Set the gas to be used for auto dividend distribution.
     */
    function setDistributorGas(uint256 gas) external onlyOwner {
        require(
            gas < MAX_DIVIDEND_DISTRIBUTOR_GAS_FEE,
            "Gas must be lower than 750000"
        );
        distributorGas = gas;
        emit SetDistributorGas(gas);
    }

    /**
     * @dev Enable/Disable swap and liquify.
     */
    function setContractSwapEnabled(bool enable) external onlyOwner {
        contractSwapEnabled = enable;

        emit SetContractSwapEnabled(enable);
    }

    // External functions that are view
    /**
     * @dev Check whether fees are exempted from the given address.
     */
    function checkFeeExempt(address _addr) external view returns (bool) {
        return isFeeExempt[_addr];
    }

    /**
     * @dev Check whether dividend is exempted from the given address.
     */
    function checkDividendExempt(address _addr) external view returns (bool) {
        return isDividendExempt[_addr];
    }

    /**
     * @dev Check whether a bot wallet is blacklisted.
     */
    function checkBotWalletBlacklisted(address _addr)
        external
        view
        returns (bool)
    {
        return botBlacklist[_addr];
    }

    /**
     * @dev See {IBEP20-allowance}.
     */
    function allowance(address owner_, address spender)
        external
        view
        override
        returns (uint256)
    {
        return allowances[owner_][spender];
    }

    /**
     * @dev Get the circulating supply based on fragment.
     */
    function circulatingSupply() public view returns (uint256) {
        return TOTAL_SUPPLY - balances[DEAD] - balances[ZERO];
    }

    // External functions that are pure
    /**
     * @dev See {IBEP20-name}.
     */
    function name() external pure override returns (string memory) {
        return NAME;
    }

    /**
     * @dev See {IBEP20-symbol}.
     */
    function symbol() external pure override returns (string memory) {
        return SYMBOL;
    }

    /**
     * @dev See {IBEP20-decimals}.
     */
    function decimals() external pure override returns (uint8) {
        return DECIMALS;
    }

    /**
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() external pure override returns (uint256) {
        return TOTAL_SUPPLY;
    }

    // Public functions
    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return balances[account];
    }

    // Internal functions
    /**
     * @dev Logic to take a tax that will run internally.
     */
    function takeTax(address sender, uint256 amount)
        internal
        returns (uint256)
    {
        uint256 taxAmount = (amount * totalTax) / taxDenominator;
        balances[address(this)] = balances[address(this)] + taxAmount;

        emit Transfer(sender, address(this), taxAmount);
        return amount - taxAmount;
    }

    /**
     * @dev Check whether a contract swap needs to be triggered.
     */
    function shouldContractSwap() internal view returns (bool) {
        return
            contractSwapEnabled &&
            !inContractSwap &&
            msg.sender != pair &&
            balances[address(this)] >= contractSwapThreshold;
    }

    /**
     * @dev Check if an address is a contract address.
     */
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    /**
     * @dev Swap stored tokens that collected from a tax in the smart contract to BNB.
     * Then, transfer BNB to the BUSD distributor and tax wallets.
     */
    function contractSwap() internal swapping {
        swapTokensForBNB(address(this).balance);

        uint256 bnbAmount = address(this).balance;

        uint256 bnbForReflection = (bnbAmount * busdDividendFee) / totalTax;
        uint256 bnbForDevelopment = (bnbAmount * developmentFee) / totalTax;
        uint256 bnbForDonation = (bnbAmount * donationFee) / totalTax;
        uint256 bnbForMarketingAndDAO = bnbAmount -
            bnbForReflection -
            bnbForDevelopment -
            bnbForDonation;

        if (bnbForReflection > 0) {
            try distributor.deposit{value: bnbForReflection}() {} catch {}
        }
        if (bnbForDevelopment > 0) {
            (bool developmentSuccess, ) = payable(developmentWalletAddress)
                .call{value: bnbForDevelopment, gas: 30000}("");
            developmentSuccess = false;
        }
        if (bnbForDonation > 0) {
            (bool donationSuccess, ) = payable(donationWalletAddress).call{
                value: bnbForDonation,
                gas: 30000
            }("");
            donationSuccess = false;
        }
        if (bnbForMarketingAndDAO > 0) {
            (bool marketingAndDAOSuccess, ) = payable(
                marketingAndDAOWalletAddress
            ).call{value: bnbForMarketingAndDAO, gas: 30000}("");
            marketingAndDAOSuccess = false;
        }
    }

    // Private functions
    /**
     * @dev Override BEP function for transfer from that will be executed
     * internally based on predetermined conditions.
     */
    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) private returns (bool) {
        require(
            !botBlacklist[sender] && !botBlacklist[recipient],
            "Transfer: this bot wallet is blacklisted. "
        );
        require(
            amount > 0,
            "Transfer: the transfer amount should be greater than zero."
        );

        // Only use PinkAntiBot if this state is true
        if (pinkAntiBotEnabled) {
            pinkAntiBot.onPreTransferCheck(sender, recipient, amount);
        }

        uint256 amountReceived = !isFeeExempt[sender]
            ? takeTax(sender, amount)
            : amount;

        if (shouldContractSwap()) {
            contractSwap();
        }

        balances[sender] = balances[sender] - amount;
        balances[recipient] = balances[recipient] + amountReceived;

        if (!isDividendExempt[sender]) {
            try distributor.setShare(sender, balances[sender]) {} catch {}
        }

        if (!isDividendExempt[recipient]) {
            try distributor.setShare(recipient, balances[recipient]) {} catch {}
        }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);

        return true;
    }

    /**
     * @dev Set `amount` as the allowance of `spender` over the `owner`s tokens.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Swap tokens for BNB.
     */
    function swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }
}
/* Contracts */