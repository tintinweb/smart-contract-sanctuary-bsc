/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// Sources flattened with hardhat v2.5.0 https://hardhat.org

// File contracts/interfaces/IFortFutures.sol

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev Defines methods for Futures
interface IFortFutures {
    
    struct FutureView {
        uint index;
        address tokenAddress;
        uint lever;
        bool orientation;
        
        uint balance;
        // Base price
        uint basePrice;
        // Base block
        uint baseBlock;
    }

    /// @dev New future event
    /// @param tokenAddress Target token address, 0 means eth
    /// @param lever Lever of future
    /// @param orientation true: call, false: put
    /// @param index Index of the future
    event New(
        address tokenAddress, 
        uint lever,
        bool orientation,
        uint index
    );

    /// @dev Buy future event
    /// @param index Index of future
    /// @param dcuAmount Amount of paid DCU
    event Buy(
        uint index,
        uint dcuAmount,
        address owner
    );

    /// @dev Sell future event
    /// @param index Index of future
    /// @param amount Amount to sell
    /// @param owner The owner of future
    /// @param value Amount of dcu obtained
    event Sell(
        uint index,
        uint amount,
        address owner,
        uint value
    );

    /// @dev Settle future event
    /// @param index Index of future
    /// @param addr Target address
    /// @param sender Address of settler
    /// @param reward Liquidation reward
    event Settle(
        uint index,
        address addr,
        address sender,
        uint reward
    );
    
    /// @dev Returns the current value of target address in the specified future
    /// @param index Index of future
    /// @param oraclePrice Current price from oracle, usd based, 18 decimals
    /// @param addr Target address
    function balanceOf(uint index, uint oraclePrice, address addr) external view returns (uint);

    /// @dev Find the futures of the target address (in reverse order)
    /// @param start Find forward from the index corresponding to the given owner address 
    /// (excluding the record corresponding to start)
    /// @param count Maximum number of records returned
    /// @param maxFindCount Find records at most
    /// @param owner Target address
    /// @return futureArray Matched futures
    function find(
        uint start, 
        uint count, 
        uint maxFindCount, 
        address owner
    ) external view returns (FutureView[] memory futureArray);

    /// @dev List futures
    /// @param offset Skip previous (offset) records
    /// @param count Return (count) records
    /// @param order Order. 0 reverse order, non-0 positive order
    /// @return futureArray List of futures
    function list(uint offset, uint count, uint order) external view returns (FutureView[] memory futureArray);

    /// @dev Create future
    /// @param tokenAddress Target token address, 0 means eth
    /// @param levers Levers of future
    /// @param orientation true: call, false: put
    function create(address tokenAddress, uint[] calldata levers, bool orientation) external;

    /// @dev Obtain the number of futures that have been created
    /// @return Number of futures created
    function getFutureCount() external view returns (uint);

    /// @dev Get information of future
    /// @param tokenAddress Target token address, 0 means eth
    /// @param lever Lever of future
    /// @param orientation true: call, false: put
    /// @return Information of future
    function getFutureInfo(
        address tokenAddress, 
        uint lever,
        bool orientation
    ) external view returns (FutureView memory);

    /// @dev Buy future
    /// @param tokenAddress Target token address, 0 means eth
    /// @param lever Lever of future
    /// @param orientation true: call, false: put
    /// @param dcuAmount Amount of paid DCU
    function buy(
        address tokenAddress,
        uint lever,
        bool orientation,
        uint dcuAmount
    ) external payable;

    /// @dev Buy future direct
    /// @param index Index of future
    /// @param dcuAmount Amount of paid DCU
    function buyDirect(uint index, uint dcuAmount) external payable;

    /// @dev Sell future
    /// @param index Index of future
    /// @param amount Amount to sell
    function sell(uint index, uint amount) external payable;

    /// @dev Settle future
    /// @param index Index of future
    /// @param addresses Target addresses
    function settle(uint index, address[] calldata addresses) external payable;

    /// @dev K value is calculated by revised volatility
    /// @param sigmaSQ sigmaSQ for token
    /// @param p0 Last price (number of tokens equivalent to 2000 USD)
    /// @param bn0 Block number of the price p0
    /// @param p Latest price (number of tokens equivalent to 2000 USD)
    /// @param bn The block number of the price p
    function calcRevisedK(uint sigmaSQ, uint p0, uint bn0, uint p, uint bn) external view returns (uint k);

    /// @dev Calculate the impact cost
    /// @param vol Trade amount in dcu
    /// @return Impact cost
    function impactCost(uint vol) external pure returns (uint);
}


// File contracts/custom/ChainParameter.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev Specific parameters for target chain
contract ChainParameter {

    // Block average time. ethereum 14 seconds, BSC 3 seconds, polygon 2.2 seconds
    uint constant BLOCK_TIME = 3;

    // Minimal exercise block period. 840000
    uint constant MIN_PERIOD = 840000;

    // Minimal exercise block period for FortLPGuarantee. 840000
    uint constant MIN_EXERCISE_BLOCK = 840000;
}


// File contracts/interfaces/IFortMapping.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev The interface defines methods for Fort builtin contract address mapping
interface IFortMapping {

    /// @dev Address updated event
    /// @param name Address name
    /// @param oldAddress Old address
    /// @param newAddress New address
    event AddressUpdated(string name, address oldAddress, address newAddress);

    /// @dev Set the built-in contract address of the system
    /// @param dcuToken Address of dcu token contract
    /// @param fortDAO IFortDAO implementation contract address
    /// @param fortOptions IFortOptions implementation contract address
    /// @param fortFutures IFortFutures implementation contract address
    /// @param fortVaultForStaking IFortVaultForStaking implementation contract address
    /// @param nestPriceFacade INestPriceFacade implementation contract address
    function setBuiltinAddress(
        address dcuToken,
        address fortDAO,
        address fortOptions,
        address fortFutures,
        address fortVaultForStaking,
        address nestPriceFacade
    ) external;

    /// @dev Get the built-in contract address of the system
    /// @return dcuToken Address of dcu token contract
    /// @return fortDAO IFortDAO implementation contract address
    /// @return fortOptions IFortOptions implementation contract address
    /// @return fortFutures IFortFutures implementation contract address
    /// @return fortVaultForStaking IFortVaultForStaking implementation contract address
    /// @return nestPriceFacade INestPriceFacade implementation contract address
    function getBuiltinAddress() external view returns (
        address dcuToken,
        address fortDAO,
        address fortOptions,
        address fortFutures,
        address fortVaultForStaking,
        address nestPriceFacade
    );

    /// @dev Get address of dcu token contract
    /// @return Address of dcu token contract
    function getDCUTokenAddress() external view returns (address);

    /// @dev Get IFortDAO implementation contract address
    /// @return IFortDAO implementation contract address
    function getHedgeDAOAddress() external view returns (address);

    /// @dev Get IFortOptions implementation contract address
    /// @return IFortOptions implementation contract address
    function getHedgeOptionsAddress() external view returns (address);

    /// @dev Get IFortFutures implementation contract address
    /// @return IFortFutures implementation contract address
    function getHedgeFuturesAddress() external view returns (address);

    /// @dev Get IFortVaultForStaking implementation contract address
    /// @return IFortVaultForStaking implementation contract address
    function getHedgeVaultForStakingAddress() external view returns (address);

    /// @dev Get INestPriceFacade implementation contract address
    /// @return INestPriceFacade implementation contract address
    function getNestPriceFacade() external view returns (address);

    /// @dev Registered address. The address registered here is the address accepted by Fort system
    /// @param key The key
    /// @param addr Destination address. 0 means to delete the registration information
    function registerAddress(string calldata key, address addr) external;

    /// @dev Get registered address
    /// @param key The key
    /// @return Destination address. 0 means empty
    function checkAddress(string calldata key) external view returns (address);
}


// File contracts/interfaces/IFortGovernance.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev This interface defines the governance methods
interface IFortGovernance is IFortMapping {

    /// @dev Governance flag changed event
    /// @param addr Target address
    /// @param oldFlag Old governance flag
    /// @param newFlag New governance flag
    event FlagChanged(address addr, uint oldFlag, uint newFlag);

    /// @dev Set governance authority
    /// @param addr Destination address
    /// @param flag Weight. 0 means to delete the governance permission of the target address. Weight is not 
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function setGovernance(address addr, uint flag) external;

    /// @dev Get governance rights
    /// @param addr Destination address
    /// @return Weight. 0 means to delete the governance permission of the target address. Weight is not 
    ///        implemented in the current system, only the difference between authorized and unauthorized. 
    ///        Here, a uint96 is used to represent the weight, which is only reserved for expansion
    function getGovernance(address addr) external view returns (uint);

    /// @dev Check whether the target address has governance rights for the given target
    /// @param addr Destination address
    /// @param flag Permission weight. The permission of the target address must be greater than this weight 
    /// to pass the check
    /// @return True indicates permission
    function checkGovernance(address addr, uint flag) external view returns (bool);
}


// File contracts/FortBase.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev Base contract of Fort
contract FortBase {

    /// @dev Governance address changed event
    /// @param oldGovernance Old governance address
    /// @param newGovernance New governance address
    event GovernanceChanged(address oldGovernance, address newGovernance);

    /// @dev IFortGovernance implementation contract address
    address public _governance;

    /// @dev To support open-zeppelin/upgrades
    /// @param governance IFortGovernance implementation contract address
    function initialize(address governance) public virtual {
        require(_governance == address(0), "Fort:!initialize");
        emit GovernanceChanged(address(0), governance);
        _governance = governance;
    }

    /// @dev Rewritten in the implementation contract, for load other contract addresses. Call 
    ///      super.update(newGovernance) when overriding, and override method without onlyGovernance
    /// @param newGovernance IFortGovernance implementation contract address
    function update(address newGovernance) public virtual {
        address governance = _governance;
        require(governance == msg.sender || IFortGovernance(governance).checkGovernance(msg.sender, 0), "Fort:!gov");
        emit GovernanceChanged(governance, newGovernance);
        _governance = newGovernance;
    }

    // Fort will merger with NEST, One NEST, One COIN!
    function disable() internal pure {
        revert("Fort:One NEST, One COIN!");
    }

    //---------modifier------------

    modifier onlyGovernance() {
        require(IFortGovernance(_governance).checkGovernance(msg.sender, 0), "Fort:!gov");
        _;
    }
}


// File contracts/custom/FortFrequentlyUsed.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev This contract include frequently used data
contract FortFrequentlyUsed is FortBase {

    // Address of DCU contract
    address constant DCU_TOKEN_ADDRESS = 0xf56c6eCE0C0d6Fbb9A53282C0DF71dBFaFA933eF;

    // Address of NestOpenPrice contract
    address constant NEST_OPEN_PRICE = 0x09CE0e021195BA2c1CDE62A8B187abf810951540;
    
    // USDT base
    uint constant USDT_BASE = 1 ether;
}


// File contracts/interfaces/INestBatchPrice2.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;

/// @dev This contract implemented the mining logic of nest
interface INestBatchPrice2 {

    /// @dev Get the latest trigger price
    /// @param channelId Target channelId
    /// @param pairIndices Array of pair indices
    /// @param payback Address to receive refund
    /// @return prices Price array, i * 2 is the block where the ith price is located, and i * 2 + 1 is the ith price
    function triggeredPrice(
        uint channelId,
        uint[] calldata pairIndices, 
        address payback
    ) external payable returns (uint[] memory prices);

    /// @dev Get the full information of latest trigger price
    /// @param channelId Target channelId
    /// @param pairIndices Array of pair indices
    /// @param payback Address to receive refund
    /// @return prices Price array, i * 4 is the block where the ith price is located, i * 4 + 1 is the ith price,
    /// i * 4 + 2 is the ith average price and i * 4 + 3 is the ith volatility
    function triggeredPriceInfo(
        uint channelId, 
        uint[] calldata pairIndices,
        address payback
    ) external payable returns (uint[] memory prices);

    /// @dev Find the price at block number
    /// @param channelId Target channelId
    /// @param pairIndices Array of pair indices
    /// @param height Destination block number
    /// @param payback Address to receive refund
    /// @return prices Price array, i * 2 is the block where the ith price is located, and i * 2 + 1 is the ith price
    function findPrice(
        uint channelId,
        uint[] calldata pairIndices, 
        uint height, 
        address payback
    ) external payable returns (uint[] memory prices);

    /// @dev Get the last (num) effective price
    /// @param channelId Target channelId
    /// @param pairIndices Array of pair indices
    /// @param count The number of prices that want to return
    /// @param payback Address to receive refund
    /// @return prices Result array, i * count * 2 to (i + 1) * count * 2 - 1 are 
    /// the price results of group i quotation pairs
    function lastPriceList(
        uint channelId, 
        uint[] calldata pairIndices, 
        uint count, 
        address payback
    ) external payable returns (uint[] memory prices);

    /// @dev Returns lastPriceList and triggered price info
    /// @param channelId Target channelId
    /// @param pairIndices Array of pair indices
    /// @param count The number of prices that want to return
    /// @param payback Address to receive refund
    /// @return prices result of group i quotation pair. Among them, the first two count * are the latest prices, 
    /// and the last four are: trigger price block number, trigger price, average price and volatility
    function lastPriceListAndTriggeredPriceInfo(
        uint channelId, 
        uint[] calldata pairIndices,
        uint count, 
        address payback
    ) external payable returns (uint[] memory prices);
}


// File contracts/custom/FortPriceAdapter.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev PriceAdapter from NEST to Fort
contract FortPriceAdapter is FortFrequentlyUsed {
    
    // Token configuration
    struct TokenConfig {
        // The channelId for call nest price
        uint16 channelId;
        // The pairIndex for call nest price
        uint16 pairIndex;

        // SigmaSQ for token
        uint64 sigmaSQ;
        // MIU_LONG for token
        uint64 miuLong;
        // MIU_SHORT for token
        uint64 miuShort;
    }

    // Post unit: 2000usd
    uint constant POST_UNIT = 2000 * USDT_BASE;

    function _pairIndices(uint pairIndex) private pure returns (uint[] memory pairIndices) {
        pairIndices = new uint[](1);
        pairIndices[0] = pairIndex;
    }

    // Query latest 2 price
    function _lastPriceList(
        TokenConfig memory tokenConfig, 
        uint fee, 
        address payback
    ) internal returns (uint[] memory prices) {
        prices = INestBatchPrice2(NEST_OPEN_PRICE).lastPriceList {
            value: fee
        } (uint(tokenConfig.channelId), _pairIndices(uint(tokenConfig.pairIndex)), 2, payback);

        prices[1] = _toUSDTPrice(prices[1]);
        prices[3] = _toUSDTPrice(prices[3]);
    }

    // Query latest price
    function _latestPrice(
        TokenConfig memory tokenConfig, 
        uint fee, 
        address payback
    ) internal returns (uint oraclePrice) {
        uint[] memory prices = INestBatchPrice2(NEST_OPEN_PRICE).lastPriceList {
            value: fee
        } (uint(tokenConfig.channelId), _pairIndices(uint(tokenConfig.pairIndex)), 1, payback);

        oraclePrice = _toUSDTPrice(prices[1]);
    }

    // Find price by blockNumber
    function _findPrice(
        TokenConfig memory tokenConfig, 
        uint blockNumber, 
        uint fee, 
        address payback
    ) internal returns (uint oraclePrice) {
        uint[] memory prices = INestBatchPrice2(NEST_OPEN_PRICE).findPrice {
            value: fee
        } (uint(tokenConfig.channelId), _pairIndices(uint(tokenConfig.pairIndex)), blockNumber, payback);

        oraclePrice = _toUSDTPrice(prices[1]);
    }

    // Convert to usdt based price
    function _toUSDTPrice(uint rawPrice) internal pure returns (uint) {
        return POST_UNIT * 1 ether / rawPrice;
    }
}


// File @openzeppelin/contracts/token/ERC20/[email protected]

// MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}


// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]

// MIT

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


// File @openzeppelin/contracts/utils/[email protected]

// MIT

pragma solidity ^0.8.0;

/*
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


// File @openzeppelin/contracts/token/ERC20/[email protected]

// MIT

pragma solidity ^0.8.0;



/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
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
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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
}


// File contracts/DCU.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev DCU token
contract DCU is FortBase, ERC20("Decentralized Currency Unit", "DCU") {

    /// @dev Mining permission flag change event
    /// @param account Target address
    /// @param oldFlag Old flag
    /// @param newFlag New flag
    event MinterChanged(address account, uint oldFlag, uint newFlag);

    // Flags for account
    mapping(address=>uint) _minters;

    constructor() {
    }

    modifier onlyMinter {
        require(_minters[msg.sender] == 1, "DCU:not minter");
        _;
    }

    /// @dev Set mining permission flag
    /// @param account Target address
    /// @param flag Mining permission flag
    function setMinter(address account, uint flag) external onlyGovernance {
        emit MinterChanged(account, _minters[account], flag);
        _minters[account] = flag;
    }

    /// @dev Check mining permission flag
    /// @param account Target address
    /// @return flag Mining permission flag
    function checkMinter(address account) external view returns (uint) {
        return _minters[account];
    }

    /// @dev Mint DCU
    /// @param to Target address
    /// @param value Mint amount
    function mint(address to, uint value) external onlyMinter {
        _mint(to, value);
    }

    /// @dev Burn DCU
    /// @param from Target address
    /// @param value Burn amount
    function burn(address from, uint value) external onlyMinter {
        _burn(from, value);
    }
}


// File contracts/FortFutures.sol

// GPL-3.0-or-later

pragma solidity ^0.8.6;
/// @dev Futures
contract FortFutures is ChainParameter, FortFrequentlyUsed, FortPriceAdapter, IFortFutures {

    /// @dev Account information
    struct Account {
        // Amount of margin
        uint128 balance;
        // Base price
        uint64 basePrice;
        // Base block
        uint32 baseBlock;
    }

    /// @dev Future information
    struct FutureInfo {
        // Target token address
        address tokenAddress; 
        // Lever of future
        uint32 lever;
        // true: call, false: put
        bool orientation;

        // Token index in _tokenConfigs
        uint16 tokenIndex;
        
        // Account mapping
        mapping(address=>Account) accounts;
    }

    // Minimum balance quantity. If the balance is less than this value, it will be liquidated
    uint constant MIN_VALUE = 10 ether;

    // Mapping from composite key to future index
    mapping(uint=>uint) _futureMapping;

    // Future array, element of 0 is place holder
    FutureInfo[] _futures;

    // token to index mapping, address=>tokenConfigIndex + 1
    mapping(address=>uint) _tokenMapping;

    // Token configs
    TokenConfig[] _tokenConfigs;

    constructor() {
    }

    /// @dev To support open-zeppelin/upgrades
    /// @param governance IFortGovernance implementation contract address
    function initialize(address governance) public override {
        super.initialize(governance);
        _futures.push();
    }

    /// @dev Register token configuration
    /// @param tokenAddress Target token address, 0 means eth
    /// @param tokenConfig token configuration
    function register(address tokenAddress, TokenConfig calldata tokenConfig) external onlyGovernance {
        disable();
    }

    /// @dev Returns the current value of target address in the specified future
    /// @param index Index of future
    /// @param oraclePrice Current price from oracle, usd based, 18 decimals
    /// @param addr Target address
    function balanceOf(uint index, uint oraclePrice, address addr) external view override returns (uint) {
        FutureInfo storage fi = _futures[index];
        Account memory account = fi.accounts[addr];
        return _balanceOf(
            _tokenConfigs[fi.tokenIndex],
            uint(account.balance), 
            _decodeFloat(account.basePrice), 
            uint(account.baseBlock),
            oraclePrice, 
            fi.orientation, 
            uint(fi.lever)
        );
    }

    /// @dev Find the futures of the target address (in reverse order)
    /// @param start Find forward from the index corresponding to the given owner address 
    /// (excluding the record corresponding to start)
    /// @param count Maximum number of records returned
    /// @param maxFindCount Find records at most
    /// @param owner Target address
    /// @return futureArray Matched futures
    function find(
        uint start, 
        uint count, 
        uint maxFindCount, 
        address owner
    ) external view override returns (FutureView[] memory futureArray) {
        futureArray = new FutureView[](count);
        // Calculate search region
        FutureInfo[] storage futures = _futures;

        // Loop from start to end
        uint end = 0;
        // start is 0 means Loop from the last item
        if (start == 0) {
            start = futures.length;
        }
        // start > maxFindCount, so end is not 0
        if (start > maxFindCount) {
            end = start - maxFindCount;
        }
        
        // Loop lookup to write qualified records to the buffer
        for (uint index = 0; index < count && start > end;) {
            FutureInfo storage fi = futures[--start];
            if (uint(fi.accounts[owner].balance) > 0) {
                futureArray[index++] = _toFutureView(fi, start, owner);
            }
        }
    }

    /// @dev List futures
    /// @param offset Skip previous (offset) records
    /// @param count Return (count) records
    /// @param order Order. 0 reverse order, non-0 positive order
    /// @return futureArray List of futures
    function list(
        uint offset, 
        uint count, 
        uint order
    ) external view override returns (FutureView[] memory futureArray) {
        // Load futures
        FutureInfo[] storage futures = _futures;
        // Create result array
        futureArray = new FutureView[](count);
        uint length = futures.length;
        uint i = 0;

        // Reverse order
        if (order == 0) {
            uint index = length - offset;
            uint end = index > count ? index - count : 0;
            while (index > end) {
                FutureInfo storage fi = futures[--index];
                futureArray[i++] = _toFutureView(fi, index, msg.sender);
            }
        } 
        // Positive order
        else {
            uint index = offset;
            uint end = index + count;
            if (end > length) {
                end = length;
            }
            while (index < end) {
                futureArray[i++] = _toFutureView(futures[index], index, msg.sender);
                ++index;
            }
        }
    }

    /// @dev Create future
    /// @param tokenAddress Target token address, 0 means eth
    /// @param levers Levers of future
    /// @param orientation true: call, false: put
    function create(address tokenAddress, uint[] calldata levers, bool orientation) external override onlyGovernance {
        disable();
    }

    /// @dev Obtain the number of futures that have been created
    /// @return Number of futures created
    function getFutureCount() external view override returns (uint) {
        return _futures.length;
    }

    /// @dev Get information of future
    /// @param tokenAddress Target token address, 0 means eth
    /// @param lever Lever of future
    /// @param orientation true: call, false: put
    /// @return Information of future
    function getFutureInfo(
        address tokenAddress, 
        uint lever,
        bool orientation
    ) external view override returns (FutureView memory) {
        uint index = _futureMapping[_getKey(tokenAddress, lever, orientation)];
        return _toFutureView(_futures[index], index, msg.sender);
    }

    /// @dev Buy future
    /// @param tokenAddress Target token address, 0 means eth
    /// @param lever Lever of future
    /// @param orientation true: call, false: put
    /// @param dcuAmount Amount of paid DCU
    function buy(
        address tokenAddress,
        uint lever,
        bool orientation,
        uint dcuAmount
    ) external payable override {
        disable();
    }

    /// @dev Buy future direct
    /// @param index Index of future
    /// @param dcuAmount Amount of paid DCU
    function buyDirect(uint index, uint dcuAmount) public payable override {
        disable();
    }

    /// @dev Sell future
    /// @param index Index of future
    /// @param amount Amount to sell
    function sell(uint index, uint amount) external payable override {

        require(index != 0, "HF:not exist");
        
        // 1. Load the future
        FutureInfo storage fi = _futures[index];
        bool orientation = fi.orientation;

        // 2. Query oracle price
        // When call, the base price multiply (1 + k), and the sell price divide (1 + k)
        // When put, the base price divide (1 + k), and the sell price multiply (1 + k)
        // When merger, s0 use recorded price, s1 use corrected by k
        TokenConfig memory tokenConfig = _tokenConfigs[uint(fi.tokenIndex)];
        uint oraclePrice = _queryPrice(0, tokenConfig, !orientation, msg.sender);

        // 3. Update account
        Account memory account = fi.accounts[msg.sender];
        account.balance -= _toUInt128(amount);
        fi.accounts[msg.sender] = account;

        // 4. Mint DCU to user
        uint value = _balanceOf(
            tokenConfig,
            amount, 
            _decodeFloat(account.basePrice), 
            uint(account.baseBlock),
            oraclePrice, 
            orientation, 
            uint(fi.lever)
        );
        DCU(DCU_TOKEN_ADDRESS).mint(msg.sender, value);

        // emit Sell event
        emit Sell(index, amount, msg.sender, value);
    }

    /// @dev Settle future
    /// @param index Index of future
    /// @param addresses Target addresses
    function settle(uint index, address[] calldata addresses) external payable override {

        require(index != 0, "HF:not exist");

        // 1. Load the future
        FutureInfo storage fi = _futures[index];
        uint lever = uint(fi.lever);
        require(lever > 1, "HF:lever must greater than 1");

        bool orientation = fi.orientation;
            
        // 2. Query oracle price
        // When call, the base price multiply (1 + k), and the sell price divide (1 + k)
        // When put, the base price divide (1 + k), and the sell price multiply (1 + k)
        // When merger, s0 use recorded price, s1 use corrected by k
        TokenConfig memory tokenConfig = _tokenConfigs[uint(fi.tokenIndex)];
        uint oraclePrice = _queryPrice(0, tokenConfig, !orientation, msg.sender);

        // 3. Loop and settle
        uint reward = 0;
        for (uint i = addresses.length; i > 0;) {
            address acc = addresses[--i];

            // 4. Update account
            Account memory account = fi.accounts[acc];
            uint balance = _balanceOf(
                tokenConfig,
                uint(account.balance), 
                _decodeFloat(account.basePrice), 
                uint(account.baseBlock),
                oraclePrice, 
                orientation, 
                lever
            );

            // 5. Settle logic
            // lever is great than 1, and balance less than a regular value, can be liquidated
            // the regular value is: Max(balance * lever * 2%, MIN_VALUE)
            uint minValue = uint(account.balance) * lever / 50;
            if (balance < (minValue < MIN_VALUE ? MIN_VALUE : minValue)) {
                fi.accounts[acc] = Account(uint128(0), uint64(0), uint32(0));
                reward += balance;
                emit Settle(index, acc, msg.sender, balance);
            }
        }

        // 6. Mint DCU to user
        if (reward > 0) {
            DCU(DCU_TOKEN_ADDRESS).mint(msg.sender, reward);
        }
    }

    // Compose key by tokenAddress, lever and orientation
    function _getKey(
        address tokenAddress, 
        uint lever,
        bool orientation
    ) private pure returns (uint) {
        //return keccak256(abi.encodePacked(tokenAddress, lever, orientation));
        require(lever < 0x100000000, "HF:lever too large");
        return (uint(uint160(tokenAddress)) << 96) | (lever << 8) | (orientation ? 1 : 0);
    }

    // Query price
    function _queryPrice(
        uint dcuAmount, 
        TokenConfig memory tokenConfig, 
        bool enlarge, 
        address payback
    ) private returns (uint oraclePrice) {

        // Query price from oracle
        uint[] memory prices = _lastPriceList(tokenConfig, msg.value, payback);
        
        // Convert to usdt based price
        oraclePrice = prices[1];
        uint k = calcRevisedK(uint(tokenConfig.sigmaSQ), prices[3], prices[2], oraclePrice, prices[0]);

        // When call, the base price multiply (1 + k), and the sell price divide (1 + k)
        // When put, the base price divide (1 + k), and the sell price multiply (1 + k)
        // When merger, s0 use recorded price, s1 use corrected by k
        if (enlarge) {
            oraclePrice = oraclePrice * (1 ether + k + impactCost(dcuAmount)) / 1 ether;
        } else {
            oraclePrice = oraclePrice * 1 ether / (1 ether + k + impactCost(dcuAmount));
        }
    }

    /// @dev Calculate the impact cost
    /// @param vol Trade amount in dcu
    /// @return Impact cost
    function impactCost(uint vol) public pure override returns (uint) {
        //impactCost = vol / 10000 / 1000;
        return vol / 10000000;
    }

    /// @dev K value is calculated by revised volatility
    /// @param sigmaSQ sigmaSQ for token
    /// @param p0 Last price (number of tokens equivalent to 2000 USD)
    /// @param bn0 Block number of the price p0
    /// @param p Latest price (number of tokens equivalent to 2000 USD)
    /// @param bn The block number of the price p
    function calcRevisedK(uint sigmaSQ, uint p0, uint bn0, uint p, uint bn) public view override returns (uint k) {
        uint sigmaISQ = p * 1 ether / p0;
        if (sigmaISQ > 1 ether) {
            sigmaISQ -= 1 ether;
        } else {
            sigmaISQ = 1 ether - sigmaISQ;
        }

        // The left part change to: Max((p2 - p1) / p1, 0.002)
        if (sigmaISQ > 0.002 ether) {
            k = sigmaISQ;
        } else {
            k = 0.002 ether;
        }

        sigmaISQ = sigmaISQ * sigmaISQ / (bn - bn0);

        if (sigmaISQ > sigmaSQ * BLOCK_TIME * 1 ether) {
            k += _sqrt(sigmaISQ * (block.number - bn));
        } else {
            k += _sqrt(1 ether * BLOCK_TIME * sigmaSQ * (block.number - bn));
        }
    }

    function _sqrt(uint256 x) private pure returns (uint256) {
        unchecked {
            if (x == 0) return 0;
            else {
                uint256 xx = x;
                uint256 r = 1;
                if (xx >= 0x100000000000000000000000000000000) { xx >>= 128; r <<= 64; }
                if (xx >= 0x10000000000000000) { xx >>= 64; r <<= 32; }
                if (xx >= 0x100000000) { xx >>= 32; r <<= 16; }
                if (xx >= 0x10000) { xx >>= 16; r <<= 8; }
                if (xx >= 0x100) { xx >>= 8; r <<= 4; }
                if (xx >= 0x10) { xx >>= 4; r <<= 2; }
                if (xx >= 0x8) { r <<= 1; }
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1;
                r = (r + x / r) >> 1; // Seven iterations should be enough
                uint256 r1 = x / r;
                return (r < r1 ? r : r1);
            }
        }
    }

    /// @dev Encode the uint value as a floating-point representation in the form of fraction * 16 ^ exponent
    /// @param value Destination uint value
    /// @return float format
    function _encodeFloat(uint value) private pure returns (uint64) {

        uint exponent = 0; 
        while (value > 0x3FFFFFFFFFFFFFF) {
            value >>= 4;
            ++exponent;
        }
        return uint64((value << 6) | exponent);
    }

    /// @dev Decode the floating-point representation of fraction * 16 ^ exponent to uint
    /// @param floatValue fraction value
    /// @return decode format
    function _decodeFloat(uint64 floatValue) private pure returns (uint) {
        return (uint(floatValue) >> 6) << ((uint(floatValue) & 0x3F) << 2);
    }

    // Convert uint to uint128
    function _toUInt128(uint value) private pure returns (uint128) {
        require(value < 0x100000000000000000000000000000000, "FEO:can't convert to uint128");
        return uint128(value);
    }

    // Convert uint to int128
    function _toInt128(uint v) private pure returns (int128) {
        require(v < 0x80000000000000000000000000000000, "FEO:can't convert to int128");
        return int128(int(v));
    }

    // Convert int128 to uint
    function _toUInt(int128 v) private pure returns (uint) {
        require(v >= 0, "FEO:can't convert to uint");
        return uint(int(v));
    }
    
    // Calculate net worth
    function _balanceOf(
        TokenConfig memory tokenConfig,
        uint balance,
        uint basePrice,
        uint baseBlock,
        uint oraclePrice, 
        bool ORIENTATION, 
        uint LEVER
    ) private view returns (uint) {

        if (balance > 0) {
            uint left;
            uint right;
            // Call
            if (ORIENTATION) {
                left = balance + (LEVER << 64) * balance * oraclePrice / basePrice
                        / _expMiuT(uint(tokenConfig.miuLong), baseBlock);
                right = balance * LEVER;
            } 
            // Put
            else {
                left = balance * (1 + LEVER);
                right = (LEVER << 64) * balance * oraclePrice / basePrice 
                        / _expMiuT(uint(tokenConfig.miuShort), baseBlock);
            }

            if (left > right) {
                balance = left - right;
            } else {
                balance = 0;
            }
        }

        return balance;
    }

    // Calculate e^μT
    function _expMiuT(uint miu, uint baseBlock) private view returns (uint) {
        // return _toUInt(ABDKMath64x64.exp(
        //     _toInt128((orientation ? MIU_LONG : MIU_SHORT) * (block.number - baseBlock) * BLOCK_TIME)
        // ));

        // Using approximate algorithm: x*(1+rt)
        return miu * (block.number - baseBlock) * BLOCK_TIME + 0x10000000000000000;
    }

    // Convert FutureInfo to FutureView
    function _toFutureView(FutureInfo storage fi, uint index, address owner) private view returns (FutureView memory) {
        Account memory account = fi.accounts[owner];
        return FutureView(
            index,
            fi.tokenAddress,
            uint(fi.lever),
            fi.orientation,
            uint(account.balance),
            _decodeFloat(account.basePrice),
            uint(account.baseBlock)
        );
    }
}