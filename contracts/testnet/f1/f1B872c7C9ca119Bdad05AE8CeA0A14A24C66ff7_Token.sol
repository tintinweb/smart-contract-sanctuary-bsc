import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC20Upgradeable.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

pragma solidity ^0.8.7;

contract Token is Initializable, OwnableUpgradeable, IERC20Upgradeable {
    uint256 private constant MAX_UINT256 = 2**256 - 1;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    uint256 public override totalSupply;

    string public name;
    uint8 public decimals;
    string public symbol;

    bool isPaused;

    mapping(address => bool) public isBlacklisted;
    mapping(address => bool) public isExcludedFromFee;
    mapping(address => uint256) public lastPurchase;

    IUniswapV2Router02 public router;
    address public liquidityPair;
    mapping(address => bool) public isLiquidityPair;

    struct Fees {
        uint16 buy;
        uint16 sell;
        uint16 transfer;
    }

    Fees public fees;

    struct FeesReceivers {
        address buy;
        address sell;
        address transfer;
    }

    FeesReceivers public feesReceivers;

    struct FeesCounters {
        uint256 buy;
        uint256 sell;
        uint256 transfer;
        uint256 total;
    }

    FeesCounters public feesCounter;

    struct MaxTrades {
        uint256 buy;
        uint256 sell;
        uint256 transfer;
    }

    MaxTrades public maxTrades;

    uint16[] public volumeSellThresholds;
    uint16[] public volumeSellTax;

    uint16[] public whaleSellThresholds;
    uint16[] public whaleSellTax;

    uint16[] public whaleTransferThresholds;
    uint16[] public whaleTransferTax;

    struct SniperTax {
        uint16 strict;
        uint16 loose;
    }

    SniperTax public sniperTax;
    uint256 public sniperThreshold;

    /// @notice Constructor of the smart contract
    /// @param _initialAmount Initial amount of tokens in circulation
    /// @param _tokenName Name of the token
    /// @param _decimalUnits Decimal units of the token
    /// @param _tokenSymbol Symbol of the token
    /// @param _router Address of the DEX router
    function initialize(
        uint256 _initialAmount,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol,
        uint256 maxBuy,
        uint256 maxSell,
        uint256 maxTransfer,
        address _router,
        address buyReceiver,
        address sellReceiver,
        address transferReceiver
    ) public initializer {
        __Ownable_init();
        balances[_msgSender()] = _initialAmount;
        totalSupply = _initialAmount;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;

        maxTrades = MaxTrades({
            buy: maxBuy * 10**decimals,
            sell: maxSell * 10**decimals,
            transfer: maxTransfer * 10**decimals
        });

        router = IUniswapV2Router02(_router);
        liquidityPair = IUniswapV2Factory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        isLiquidityPair[liquidityPair] = true;

        _approve(msg.sender, _router, type(uint256).max);
        _approve(address(this), _router, type(uint256).max);

        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[_msgSender()] = true;

        isPaused = true;
        fees = Fees({buy: 800, sell: 800, transfer: 400});
        feesReceivers = FeesReceivers({
            buy: buyReceiver,
            sell: sellReceiver,
            transfer: transferReceiver
        });

        volumeSellThresholds = [100, 200, 300];
        volumeSellTax = [1000, 2000, 3000];

        whaleSellThresholds = [100, 200, 300];
        whaleSellTax = [600, 800, 1000];

        whaleTransferThresholds = [100, 200, 300];
        whaleTransferTax = [600, 800, 1000];

        sniperTax = SniperTax({strict: 4000, loose: 2000});
        sniperThreshold = 5 minutes;

        emit Transfer(address(0), _msgSender(), _initialAmount);
        emit OwnershipTransferred(address(0), _msgSender());
    }

    /// @notice Fetch the balance of an address
    /// @param _owner Address to fetch the balance of
    /// @return balance The balance of the address
    function balanceOf(address _owner)
        public
        view
        override
        returns (uint256 balance)
    {
        return balances[_owner];
    }

    /// @notice Fetch the allowance of an address
    /// @param _owner Address of the owner
    /// @param _spender Address of the spender
    /// @return remaining The allowance of the spender
    function allowance(address _owner, address _spender)
        public
        view
        override
        returns (uint256 remaining)
    {
        return allowances[_owner][_spender];
    }

    /// @notice Transfer tokens to another address
    /// @param _to Receiver
    /// @param _value Amount of tokens
    /// @return success If the transfer successfuly occured
    function transfer(address _to, uint256 _value)
        public
        override
        returns (bool success)
    {
        _transfer(_msgSender(), _to, _value);
        return true;
    }

    /// @notice Transfer tokens of another address
    /// @param _from Sender
    /// @param _to Receiver
    /// @param _value Amount of tokens
    /// @return success If the transfer successfuly occured
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool success) {
        if (allowances[_from][_msgSender()] < MAX_UINT256) {
            allowances[_from][_msgSender()] -= _value;
        }
        _transfer(_from, _to, _value);
        return true;
    }

    /// @notice Approve an address to spend one's tokens
    /// @param _spender Address on the spender
    /// @param _value Amount of tokens
    /// @return success If the spender was succesfully approved
    function approve(address _spender, uint256 _value)
        public
        override
        returns (bool success)
    {
        _approve(_msgSender(), _spender, _value);
        return true;
    }

    /// @notice Transfer funds between excluded addresses
    /// @param _from Sender
    /// @param _to Receiver
    /// @param _value Amount of tokens
    function _transferExcluded(
        address _from,
        address _to,
        uint256 _value
    ) private {
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    function getBuyFees(uint256 _value) public view returns (uint256 feeValue) {
        feeValue = (_value * fees.buy) / 10000;
    }

    function getSellFees(address _from, uint256 _value)
        public
        view
        returns (uint256 feeValue)
    {
        feeValue = (_value * fees.sell) / 10000;
        uint256 balance = balanceOf(_from) + _value;

        uint16[] memory whaleTax = whaleSellTax;
        uint16[] memory whaleThreshold = whaleSellThresholds;

        for (uint256 i = whaleTax.length; i > 0; i--) {
            if (balance >= (totalSupply * whaleThreshold[i - 1]) / 10000) {
                feeValue += (_value * whaleTax[i - 1]) / 10000;
                break;
            }
        }

        if (lastPurchase[_from] == block.timestamp) {
            feeValue += (_value * sniperTax.strict) / 10000;
        } else if (lastPurchase[_from] + sniperThreshold > block.timestamp) {
            feeValue += (_value * sniperTax.loose) / 10000;
        }

        (uint256 pairBalance, , ) = IUniswapV2Pair(liquidityPair).getReserves();
        uint16[] memory volumeTax = volumeSellTax;
        uint16[] memory volumeThresholds = volumeSellThresholds;

        for (uint256 i = volumeTax.length; i > 0; i--) {
            if (balance >= (pairBalance * volumeThresholds[i - 1]) / 10000) {
                feeValue += _value * volumeTax[i - 1] / 10000;
                break;
            }
        }
    }

    function getTransferFees(address _from, uint256 _value)
        public
        view
        returns (uint256 feeValue)
    {
        feeValue = (_value * fees.transfer) / 10000;
        uint256 balance = balanceOf(_from) + _value;

        uint16[] memory whaleTax = whaleTransferTax;
        uint16[] memory whaleThreshold = whaleTransferThresholds;

        for (uint256 i = whaleTax.length; i > 0; i--) {
            if (balance >= (totalSupply * whaleThreshold[i - 1]) / 10000) {
                feeValue += (_value * whaleTax[i - 1]) / 10000;
                break;
            }
        }
    }

    /// @notice Transfer funds between non-excluded addresses
    /// @param _from Sender
    /// @param _to Receiver
    /// @param _value Amount of tokens
    function _transferNoneExcluded(
        address _from,
        address _to,
        uint256 _value
    ) private {
        balances[_from] -= _value;

        uint256 feeValue = 0;

        if (isLiquidityPair[_from]) {
            require(_value <= maxTrades.buy, "TRANSFER: Max buy reached.");
            feeValue = getBuyFees(_value);
            balances[feesReceivers.buy] += feeValue;
            lastPurchase[_to] = block.timestamp;
            feesCounter.buy += feeValue;
            feesCounter.total += feeValue;
            emit Transfer(_from, feesReceivers.buy, feeValue);
        } else if (isLiquidityPair[_to]) {
            require(_value <= maxTrades.sell, "TRANSFER: Max sell reached.");
            feeValue = getSellFees(_from, _value);
            balances[address(this)] += feeValue;
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = router.WETH();

            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                feeValue,
                0,
                path,
                feesReceivers.sell,
                block.timestamp
            );
            feesCounter.sell += feeValue;
            feesCounter.total += feeValue;
        } else {
            require(_value <= maxTrades.transfer, "TRANSFER: Max buy reached.");
            if (block.timestamp < lastPurchase[_from] + sniperThreshold) {
                lastPurchase[_to] = lastPurchase[_from];
            }
            feeValue = getTransferFees(_from, _value);
            balances[feesReceivers.transfer] += feeValue;
            feesCounter.transfer += feeValue;
            feesCounter.total += feeValue;
            emit Transfer(_from, feesReceivers.transfer, feeValue);
        }

        uint256 value = _value - feeValue;
        balances[_to] += value;
        emit Transfer(_from, _to, value);
    }

    /// @notice Redirect a transfer to the right fonction
    /// @param _from Sender
    /// @param _to Receiver
    /// @param _value Amount of tokens
    function _routeTransfer(
        address _from,
        address _to,
        uint256 _value
    ) private {
        if (isExcludedFromFee[_from] || isExcludedFromFee[_to])
            _transferExcluded(_from, _to, _value);
        else _transferNoneExcluded(_from, _to, _value);
    }

    /// @notice Perform various checks on transfers
    /// @param _from Sender
    /// @param _to Receiver
    /// @param _value Amount of tokens
    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) private {
        require(!isPaused, "TRANSFER: Transfers are currently disabled");
        require(
            _from != address(0),
            "TRANSFER: Transfer from the dead address"
        );
        require(_to != address(0), "TRANSFER: Transfer to the dead address");
        require(_value > 0, "TRANSFER: Invalid amount");
        require(isBlacklisted[_from] == false, "TRANSFER: Blacklisted");
        require(balances[_from] >= _value, "TRANSFER: Insufficient balance");
        _routeTransfer(_from, _to, _value);
    }

    /// @notice Approve an address to spend one's tokens
    /// @param _sender Address of the sender
    /// @param _spender Address on the spender
    /// @param _value Amount of tokens
    /// @return success If the spender was succesfully approved
    function _approve(
        address _sender,
        address _spender,
        uint256 _value
    ) private returns (bool success) {
        allowances[_sender][_spender] = _value;
        emit Approval(_sender, _spender, _value);
        return true;
    }

    /// @notice Update buy and sell fees
    /// @dev Must be X% * 1e2 (8% = 800)
    /// @param buy_ Buy fees
    /// @param sell_ Sell fees
    /// @param transfer_ Transfer fees
    function setFees(
        uint16 buy_,
        uint16 sell_,
        uint16 transfer_
    ) public onlyOwner {
        fees = Fees({buy: buy_, sell: sell_, transfer: transfer_});
    }

    /// @notice Update buy and sell fees receivers
    /// @dev Buy fees are sent as token, sell fees are sent as native
    /// @param buy_ Buy fees receiver
    /// @param sell_ Sell fees receiver
    /// @param transfer_ Transfer fees receiver
    function setFeesReceivers(
        address buy_,
        address sell_,
        address transfer_
    ) public onlyOwner {
        feesReceivers = FeesReceivers({
            buy: buy_,
            sell: sell_,
            transfer: transfer_
        });
    }

    /// @notice Define if an address should be excluded from fees
    /// @param user Address to be defined
    /// @param value Is excluded
    function setIsExcludedFromFees(address user, bool value) public onlyOwner {
        isExcludedFromFee[user] = value;
    }

    /// @notice Define if an address should considered as a liquidityPair
    /// @param user Address to be defined
    /// @param value Is a liquidity pair
    function setIsLiquidityPair(address user, bool value) public onlyOwner {
        isLiquidityPair[user] = value;
    }

    /// @notice Define if an address should be blacklisted
    /// @param user Address to be defined
    /// @param value Is blacklisted
    function setBlacklisted(address user, bool value) public onlyOwner {
        isBlacklisted[user] = value;
    }

    /// @notice Define if transfers should be disabled
    /// @param value Is paused
    function setIsPaused(bool value) public onlyOwner {
        isPaused = value;
    }

    /// @notice Define the maximum trade values
    /// @param maxBuy Maximum tokens of a "buy" transaction
    /// @param maxSell Maximum tokens of a "sell" transaction
    function setMaxTrades(
        uint256 maxBuy,
        uint256 maxSell,
        uint256 maxTransfer
    ) public onlyOwner {
        maxTrades = MaxTrades({
            buy: maxBuy,
            sell: maxSell,
            transfer: maxTransfer
        });
    }

    function setWhaleSellTax(
        uint16[] memory whaleTax,
        uint16[] memory whaleThresholds
    ) public onlyOwner {
        require(whaleTax.length == whaleThresholds.length, "Invalid lengths");
        whaleSellTax = whaleTax;
        whaleSellThresholds = whaleThresholds;
    }

    function setWhaleTransferTax(
        uint16[] memory whaleTax,
        uint16[] memory whaleThresholds
    ) public onlyOwner {
        require(whaleTax.length == whaleThresholds.length, "Invalid lengths");
        whaleTransferTax = whaleTax;
        whaleTransferThresholds = whaleThresholds;
    }

    function setVolumeSellTax(
        uint16[] memory voluemTax,
        uint16[] memory volumeThresholds
    ) public onlyOwner {
        require(voluemTax.length == volumeThresholds.length, "Invalid lengths");
        volumeSellTax = voluemTax;
        volumeSellThresholds = volumeThresholds;
    }

    function setSniperTax(
        uint16 strict,
        uint16 loose,
        uint256 threshold
    ) public onlyOwner {
        sniperTax = SniperTax({strict: strict, loose: loose});
        sniperThreshold = threshold;
    }

    /// @notice Approve tokens on router (necessary for swapping sale tax into BNB)
    function approveOnRouter() public onlyOwner {
        _approve(address(this), address(router), type(uint256).max);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20Upgradeable.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
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
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
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
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}