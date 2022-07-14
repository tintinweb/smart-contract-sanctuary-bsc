/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

/**
 * Submitted for verification at BscScan.com on 2022-03-13
 */

/**
 * @title Everyday Off Club (EOC) Token
 *
 * @custom:website https://everydayoffclub.com
 * @custom:whitepaper https://docs.everydayoffclub.com
 * @custom:twitter https://twitter.com/everydayoffclub
 * @custom:telegram_group https://t.me/everydayoffclub
 * @custom:telegram_announcement https://t.me/everydayoffclub_announcement
 * @custom:tiktok https://www.tiktok.com/@everydayoffclub
 * @custom:instagram https://www.instagram.com/everydayoffclub/
 * @custom:youtube 
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;


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
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

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
    function getWBNB() external pure returns (address);

    /**
     * @dev Add liquidity.
     */
    function addLiquidityBNB(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountBNBMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountBNB,
            uint256 liquidity
        );

    /**
     * @dev Swap BNB.
     */
    function swapExactBNBForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    /**
     * @dev Swap BNB.
     */
    function swapExactTokensForBNBSupportingFeeOnTransferTokens(
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
interface IBUSDDividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

    function setShare(address shareholder, uint256 amount) external;

    function deposit() external payable;

    function process(uint256 gas) external;
}
/* Interfaces */


/* Libraries */
/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionCallWithValue(
                target,
                data,
                0,
                "Address: low-level call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage)
        private
        pure
    {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using Address for address;

    /**
     * @dev Safe transfer for external BEP20 token.
     */ 
    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: ERC20 operation did not succeed"
            );
        }
    }
}
/* Libraries */


/* Contracts */
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
 * @dev Contract module which distributes BUSD dividend to EOC token holders.
 */
contract BUSDDividendDistributor is IBUSDDividendDistributor {
    // Use library
    using SafeBEP20 for IBEP20;

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
    IBEP20 busd;
    address private constant BUSD_CONTRACT_ADDRESS = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    // PancakeSwap
    IPancakeSwapRouter router;
    address private constant PANCAKE_ROUTER_CONTRACT_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    // Dividend distribute factors
    uint256 public dividendPerShareAccuracyFactor;
    uint256 public minPeriod;
    uint256 public minDistribution;
    uint256 public totalShares;
    uint256 public totalDividend;
    uint256 public totalDistributed;
    uint256 public dividendPerShare;
    uint256 public currentIndex;

    // Modifiers
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token, "BUSDDividendDistributor: a router is not the PancakeSwap.");
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
        busd = IBEP20(BUSD_CONTRACT_ADDRESS);

        // Set dividend distribute factors
        dividendPerShareAccuracyFactor = 10**36;
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
        uint256 balanceBefore = busd.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.getWBNB();
        path[1] = address(busd);

        router.swapExactBNBForTokensSupportingFeeOnTransferTokens{
            value: msg.value
        }(0, path, address(this), block.timestamp);

        uint256 amount = busd.balanceOf(address(this)) - balanceBefore;

        totalDividend = totalDividend + amount;
        dividendPerShare =
            dividendPerShare +
            ((dividendPerShareAccuracyFactor * amount) / totalShares);
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
    function getUndistributedDividend(address shareholder)
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

    // Internal functions
    /**
     * @dev Distribute dividend to the shareholders and update dividend information.
     */
    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint256 amount = getUndistributedDividend(shareholder);
        if (amount > 0) {
            totalDistributed = totalDistributed + amount;
            busd.safeTransfer(shareholder, amount);
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
            getUndistributedDividend(shareholder) > minDistribution;
    }

    /**
     * @dev Get cumulative dividend.
     */
    function getCumulativeDividend(uint256 share)
        internal
        view
        returns (uint256)
    {
        return (share * dividendPerShare) / dividendPerShareAccuracyFactor;
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
 * @dev Contract module which provides a 7% BUSD reflection from a trading volume with a 10% tax.
 */
contract EOC is IBEP20, Ownable {
    // Maps
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => uint256) private balances;
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isDividendExempt;
    mapping(address => bool) public isWalletLimitExempt;
    mapping(address => bool) public botBlacklist;

    // Naming
    string private constant NAME = "EOC";
    string private constant SYMBOL = "EOC";

    // Decimal handling
    uint8 private constant DECIMALS = 18;
    uint256 private constant DECIMAL_FACTOR = 10**DECIMALS;

    // Total supply
    uint256 private constant ONE_BILLION = 1000000000;
    uint256 private constant TOTAL_SUPPLY = ONE_BILLION * DECIMAL_FACTOR;

    // Max wallet size
    uint256 public maxWalletSize;

    // Swap and liquify
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled;
    uint256 public swapAndLiquifyThreshold;

    // Fees
    uint256 public autoBurnFee;
    uint256 public autoLiquidityFee;
    uint256 public busdDividendFee;
    uint256 public developmentFee;
    uint256 public marketingAndDAOFee;
    uint256 public totalFee;
    uint256 public feeDenominator;

    // Addresses
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address private constant ZERO = 0x0000000000000000000000000000000000000000;
    address public autoBurnWalletAddress;
    address public developmentWalletAddress;
    address public busdDividendAddress;
    address public marketingAndDAOWalletAddress;

    // Dividend Distributor
    uint256 private constant MAX_DIVIDEND_DISTRIBUTOR_GAS_FEE = 750000;
    BUSDDividendDistributor public distributor;
    uint256 public distributorGas;

    // PancakeSwap
    address private constant PANCAKE_ROUTER_CONTRACT_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    IPancakeSwapRouter public router;
    address public pair;

    // Events
    event LiquidityAdded(uint256 tokenAmount, uint256 bnbAmount);
    event SetDividendExempt(address holder, bool exempt);
    event SetFeeExempt(address holder, bool exempt);
    event SetWalletLimitExempt(address holder, bool exempt);
    event SetDistributionCriteria(uint256 minPeriod, uint256 minDistribution);
    event SetDistributorGas(uint256 gas);
    event SetSwapAndLiquifyEnabled(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 bnbAmount,
        uint256 tokensIntoLiquidity
    );
    event BurnLeftoverBNB(uint256 leftoverBNB);

    // Modifiers
    // Prevent transferring tokens to the 0x0 address and the contract address
    modifier validRecipient(address to) {
        require(to != address(0x0), "Transfer: the receiver cannot be ZERO address.");
        require(to != address(this), "Transfer: the receiver cannot be the contract address.");
        _;
    }

    // Prevent getting caught in a circular adding liquidity event.
    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    // Constructor
    constructor() Ownable() {
        // Dividend Distributor
        distributor = new BUSDDividendDistributor(PANCAKE_ROUTER_CONTRACT_ADDRESS);
        distributorGas = 100000;

        // Set addresses
        autoBurnWalletAddress = DEAD;
        developmentWalletAddress = 0x41BDcADA2A5018b0F95dC219971cF171F2799A11;
        busdDividendAddress = address(distributor);
        marketingAndDAOWalletAddress = 0x7dFF9A370d101B5dC0816b8e61276477449a9E05;

        // Set fees
        autoBurnFee = 5;
        autoLiquidityFee = 10;
        busdDividendFee = 70;
        developmentFee = 5;
        marketingAndDAOFee = 10;
        totalFee =
            autoBurnFee +
            autoLiquidityFee +
            busdDividendFee +
            developmentFee +
            marketingAndDAOFee;
        feeDenominator = 1000;

        // Set false initially since we do presale on PinkSale
        swapAndLiquifyEnabled = false;
        swapAndLiquifyThreshold = TOTAL_SUPPLY / 2000; // 0.005%

        // Anti-whale: a single wallet cannot hold more than 1% of the total supply
        maxWalletSize = TOTAL_SUPPLY / 100;

        // Set dividend exempts
        // Remove all tax wallets from dividend.
        // Thus, holders can get more BUSD dividend.
        isDividendExempt[msg.sender] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[ZERO] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[autoBurnWalletAddress] = true;
        isDividendExempt[developmentWalletAddress] = true;
        isDividendExempt[marketingAndDAOWalletAddress] = true;

        // Set fee exempts
        isFeeExempt[msg.sender] = true;
        isFeeExempt[pair] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[ZERO] = true;
        isFeeExempt[DEAD] = true;
        isFeeExempt[autoBurnWalletAddress] = true;
        isFeeExempt[developmentWalletAddress] = true;
        isFeeExempt[marketingAndDAOWalletAddress] = true;

        // Set wallet limit exempts
        isWalletLimitExempt[msg.sender] = true;
        isWalletLimitExempt[pair] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[ZERO] = true;
        isWalletLimitExempt[DEAD] = true;
        isWalletLimitExempt[autoBurnWalletAddress] = true;
        isWalletLimitExempt[developmentWalletAddress] = true;
        isWalletLimitExempt[marketingAndDAOWalletAddress] = true;

        // PancakeSwap
        // router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // MAINNET
        router = IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // TESTNET
        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.getWBNB(),
            address(this)
        );

        // Set total supply as an allowance from the contract to PancakeSwap
        allowances[address(this)][address(router)] = TOTAL_SUPPLY;

        emit Transfer(address(0x0), msg.sender, TOTAL_SUPPLY);
    }

    // Receive function
    receive() external payable {} // Recieve ETH from PancakeSwap when swaping

    // External functions
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
        if (allowances[from][msg.sender] != TOTAL_SUPPLY) {
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
    function setBotBlacklist(address _botAddress, bool _flag) external onlyOwner {
        require(isContract(_botAddress), "SetBotBlacklist: an externally-owned address cannot be blacklisted.");
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
     * @dev Exempt an address from token holding limitation.
     */
    function setWalletLimitExempt(address holder, bool exempt) external onlyOwner {
        isWalletLimitExempt[holder] = exempt;
        emit SetWalletLimitExempt(holder, exempt);
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
    function setSwapAndLiquifyEnabled(bool enabled) external onlyOwner {
        swapAndLiquifyEnabled = enabled;

        emit SetSwapAndLiquifyEnabled(enabled);
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
     * @dev Check whether max wallet limitation is applied to the given address.
     */
    function checkWalletLimitExempt(address _addr) external view returns (bool) {
        return isWalletLimitExempt[_addr];
    }

    /**
     * @dev Check whether a bot wallet is blacklisted.
     */
    function checkBotWalletBlacklisted(address _addr) external view returns (bool) {
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
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() external view override returns (uint256) {
        return TOTAL_SUPPLY;
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

    // Public functions
    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return balances[account];
    }

    // Internal functions    
    /**
     * @dev Logic to take a fee that will run internally.
     */
    function takeFee(address sender, uint256 amount)
        internal
        returns (uint256)
    {
        uint256 burnAmount = (amount*autoBurnFee) / feeDenominator;
        balances[autoBurnWalletAddress] = balances[autoBurnWalletAddress] + burnAmount;
        
        uint256 restFeeAmount = (amount*(totalFee - autoBurnFee)) / feeDenominator;
        balances[address(this)] = balances[address(this)] + restFeeAmount;

        uint256 totalFeeAmount = (amount * totalFee) / feeDenominator;
        emit Transfer(sender, address(this), totalFeeAmount);

        return amount - totalFeeAmount;
    }

    /**
     * @dev Check whether the predetermined conditions for adding liquidity have been met.
     */
    function shouldSwapAndLiquify() internal view returns (bool) {
        return swapAndLiquifyEnabled && !inSwapAndLiquify && msg.sender != pair && balances[address(this)] >= swapAndLiquifyThreshold;
    }

    /**
     * @dev Check if an address is a contract address. Anti-bot measure.
     */
    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    // Private functions
    /**
     * @dev Override BEP function for transfer from that will be executed internally based on predetermined conditions.
     */
    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) private returns (bool) {
        require(!botBlacklist[sender] && !botBlacklist[recipient], "Transfer: this bot wallet is blacklisted. ");
        require(amount > 0, "Transfer: the transfer amount should be greater than zero.");

        if (!isWalletLimitExempt[recipient]) {
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= maxWalletSize, "Transfer: an wallet cannot hold more than 1% of the supply.");
        }

        uint256 amountReceived = !isFeeExempt[sender]
            ? takeFee(sender, amount)
            : amount;

        if (shouldSwapAndLiquify()) {
            swapAndLiquify();
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
     * @dev Basic transfer.
     */
    function basicTransfer(
        address from,
        address to,
        uint256 amount
    ) private returns (bool) {
        balances[from] = balances[from] - amount;
        balances[to] = balances[to] + amount;
        emit Transfer(from, to, amount);
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
    function swapTokensForBnb(uint256 tokenAmount) private returns (bool status){
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.getWBNB();

        router.swapExactTokensForBNBSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    /**
     * @dev For every `swapAndLiquify` function call, a small amount 
     * of BNB remains in the contract. This function burns leftover BNB.
     */
    function burnLeftoverBNB() private {
        uint256 leftoverBalance = address(this).balance;
        basicTransfer(address(this), autoBurnWalletAddress, leftoverBalance);

        emit BurnLeftoverBNB(leftoverBalance);
    }

    /**
     * @dev Swap tokens for BNB, transfer fees to tax wallets, and add liquidity to PancakeSwap.
     */
    function swapAndLiquify() private lockTheSwap {
        uint256 tokenAmountToLiquify = (address(this).balance*autoLiquidityFee / totalFee) / 2;
        uint256 tokenAmountToSwap = address(this).balance - tokenAmountToLiquify;

        uint256 balanceBefore = address(this).balance;

        // Swap tokens for BNB
        swapTokensForBnb(tokenAmountToSwap);

        uint256 bnbAmount = address(this).balance - balanceBefore;

        uint256 totalBNBFee = totalFee - (autoLiquidityFee / 2);

        uint256 bnbForLiquidity = ((bnbAmount*autoLiquidityFee) / totalBNBFee) / 2;
        uint256 bnbForReflection = (bnbAmount*busdDividendFee) / totalBNBFee;
        uint256 bnbForDevelopment = (bnbAmount*developmentFee) / totalBNBFee;
        uint256 bnbForMarketingAndDAO = (bnbAmount*marketingAndDAOFee) / totalBNBFee;

        try distributor.deposit{value: bnbForReflection}() {} catch {}
        payable(developmentWalletAddress).transfer(bnbForDevelopment);
        payable(marketingAndDAOWalletAddress).transfer(bnbForMarketingAndDAO);

        // Check if an externally owned account initiated the transfer.
        // It minimizes the risk of a flashloan attack.
        bool isEOATransaction = msg.sender == tx.origin;
        if (tokenAmountToLiquify > 0 && isEOATransaction) {
          // Add liquidity to PancakeSwap
          addLiquidity(tokenAmountToLiquify, bnbForLiquidity);
          burnLeftoverBNB();
        }
        emit SwapAndLiquify(balanceBefore, bnbForLiquidity, tokenAmountToLiquify);
    }

    /**
     * @dev Add liquidity.
     */
    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        router.addLiquidityBNB{value: bnbAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            address(this),
            block.timestamp
        );
        emit LiquidityAdded(tokenAmount, bnbAmount);  
    }
}
/* Contracts */