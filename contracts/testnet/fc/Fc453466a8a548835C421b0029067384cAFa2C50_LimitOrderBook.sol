// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Decimal} from "./utils/Decimal.sol";
import {SignedDecimal} from "./utils/SignedDecimal.sol";
import {DecimalERC20} from "./utils/DecimalERC20.sol";

import {IAmm} from "./interface/IAmm.sol";
import {IInsuranceFund} from "./interface/IInsuranceFund.sol";
import {ISmartWallet} from "./interface/ISmartWallet.sol";
import {ISmartWalletFactory} from "./interface/ISmartWalletFactory.sol";
import {ILimitOrderBook} from "./interface/ILimitOrderBook.sol";

contract LimitOrderBook is OwnableUpgradeable, DecimalERC20, ILimitOrderBook {
    using Decimal for Decimal.decimal;
    using SignedDecimal for SignedDecimal.signedDecimal;

    mapping(uint256 => LimitOrder) public orders;
    mapping(uint256 => RemainingOrderInfo) public remainingOrders;
    uint256 public orderLength;

    /* All smart wallets will be deployed by the factory - this allows you to get the
        contract address of the smart wallet for any trader */
    ISmartWalletFactory public factory;

    /* Other smart contracts that we interact with */
    IERC20 public quoteAsset;
    IInsuranceFund public insuranceFund;

    /* The minimum fee that needs to be attached to an order for it to be executed
        by a keeper. This can be adjusted at a later stage. This is to prevent spam attacks
        on the network */
    Decimal.decimal public minimumTipFee;

    function initialize(address _insuranceFund) external initializer {
        __Ownable_init();
        insuranceFund = IInsuranceFund(_insuranceFund);
        quoteAsset = insuranceFund.quoteToken();
    }

    /*
     * FUNCTIONS TO ADD ORDERS
     */

    /*
     * @notice This function will create a limit order and store it within the contract.
     * Please see documentation for _createOrder()
     */
    function addLimitOrder(
        IAmm _asset,
        Decimal.decimal memory _limitPrice,
        SignedDecimal.signedDecimal memory _positionSize,
        Decimal.decimal memory _collateral,
        Decimal.decimal memory _leverage,
        Decimal.decimal memory _slippage,
        Decimal.decimal memory _tipFee,
        bool _reduceOnly,
        uint256 _expiry
    ) external {
        requireNonZeroInput(_limitPrice, "Limit cannot be zero");
        _createOrder(
            _asset,
            OrderType.LIMIT,
            _limitPrice,
            _positionSize,
            _collateral,
            _leverage,
            _slippage,
            _tipFee,
            _reduceOnly,
            _expiry
        );
    }

    /*
     * @notice This function will create a stop market order and store it within the contract.
     * Please see documentation for _createOrder()
     */
    function addStopOrder(
        IAmm _asset,
        Decimal.decimal memory _stopPrice,
        SignedDecimal.signedDecimal memory _positionSize,
        Decimal.decimal memory _collateral,
        Decimal.decimal memory _leverage,
        Decimal.decimal memory _slippage,
        Decimal.decimal memory _tipFee,
        bool _reduceOnly,
        uint256 _expiry
    ) external {
        requireNonZeroInput(_stopPrice, "Stop cannot be zero");
        _createOrder(
            _asset,
            OrderType.STOPLOSS,
            _stopPrice,
            _positionSize,
            _collateral,
            _leverage,
            _slippage,
            _tipFee,
            _reduceOnly,
            _expiry
        );
    }

    /*
     * @notice Will create an advanced order and store it within the contract
     * @param _asset the AMM address for the asset being traded
     * @param _orderType the type of order (as enum)
     * @param _stopPrice the STOP trigger price
     * @param _limitPrice the LIMIT trigger price
     * @param _positionSize the size of the order in base asset
     * @param _collateral the amount of margin/collateral that will be used for order
     * @param _leverage the maximum leverage acceptable for trade
     * @param _slippage the minimum amount of base asset that the trader will accept
     *    This is subtly different to _positionSize. Let us assume that the trader
     *    has created an order to buy 1 BTC below 50K. The price of bitcoin hits
     *    49,980 and so an order gets executed. His actual execution price may be
     *    50,500 (due to price impact). He can adjust the slippage parameter to
     *    decide whether he wants the transaction to be executed at this price or not.
     *    If slippage is set to 0, then any price is accepted.
     * @param _tipFee is the fee that will go to the keeper that executes the order.
     *    This fee is taken as soon as the order is created.
     * @param _reduceOnly whether the order is reduceonly or not
     * @param _expiry when the order expires (block timestamp). If this variable is
     *    0 then it will never expire.
     */
    function _createOrder(
        IAmm _asset,
        OrderType _orderType,
        Decimal.decimal memory _limitPrice,
        SignedDecimal.signedDecimal memory _positionSize,
        Decimal.decimal memory _collateral,
        Decimal.decimal memory _leverage,
        Decimal.decimal memory _slippage,
        Decimal.decimal memory _tipFee,
        bool _reduceOnly,
        uint256 _expiry
    ) internal {
        //Check expiry parameter
        require(
            ((_expiry == 0) || (block.timestamp < _expiry)),
            "Event will expire in past"
        );
        //Check whether fee is sufficient
        require(
            _tipFee.cmp(minimumTipFee) >= 0,
            "Just the tip! Tip is below minimum tip fee"
        );
        //Check on the smart wallet factory whether this trader has a smart wallet
        address _smartWallet = factory.getSmartWallet(msg.sender);
        require(_smartWallet != address(0), "Need smart wallet");
        //Need to make sure the asset is actually a PERP asset
        require(insuranceFund.isExistedAmm(IAmm(_asset)), "amm not found");
        //Sanity checks
        requireNonZeroInput(_positionSize.abs(), "Cannot do empty order");
        require(
            _slippage.cmp(Decimal.one()) != 1,
            "Slippage must be percentage"
        );

        requireNonZeroInput(_collateral, "Cannot spend 0 collateral");
        require(_leverage.cmp(Decimal.one()) != -1, "Minimum 1x leverage");
        if (_tipFee.toUint() != 0) {
            //Take fee from user - user needs to approve this contract to spend their asset first
            _transferFrom(quoteAsset, _smartWallet, address(this), _tipFee);
        }
        //Emit event on order creation

        uint256 _orderLength = orderLength;
        emit OrderCreated(msg.sender, _orderLength);
        //Add values to array
        orders[_orderLength] = LimitOrder({
            asset: address(_asset),
            trader: msg.sender,
            orderType: _orderType,
            limitPrice: _limitPrice,
            orderSize: _positionSize,
            collateral: _collateral,
            leverage: _leverage,
            slippage: _slippage,
            tipFee: _tipFee,
            reduceOnly: _reduceOnly,
            stillValid: true,
            expiry: _expiry
        });

        orderLength = _orderLength + 1;
    }

    /*
     * FUNCTIONS TO INTERACT WITH ORDERS (EXECUTE/DELETE/ETC)
     */

    /*
     * @notice Delete an order
     */
    function deleteOrder(uint256 order_id)
        external
        onlyMyOrder(order_id)
        onlyValidOrder(order_id)
    {
        LimitOrder memory order = orders[order_id];

        emit OrderCancelled(order.trader, order_id);
        delete orders[order_id];
    }

    /*
     * @notice Execute an order using the order_id
     * All the logic verifying the order can be successfully executed occurs on the SmartWallet.sol contract
     */
    function execute(uint256 order_id, Decimal.decimal memory maxQuoteAsset)
        external
        onlyValidOrder(order_id)
    {
        //First check that the order hasn't been cancelled/already been executed
        LimitOrder memory order = orders[order_id];
        address _trader = order.trader;
        require(order.stillValid, "No longer valid");
        //Get the smart wallet of the trader from the factory contract
        address _smartwallet = factory.getSmartWallet(order.trader);
        //Try and execute the order (should return true if successful)
        (
            SignedDecimal.signedDecimal memory exchangedPositionSize,
            Decimal.decimal memory exchangedQuoteAmount
        ) = ISmartWallet(_smartwallet).executeOrder(order_id, maxQuoteAsset);

        _afterOrderExecution(
            _trader,
            msg.sender,
            order_id,
            exchangedPositionSize,
            exchangedQuoteAmount
        );
    }

    function _afterOrderExecution(
        address trader,
        address operator,
        uint256 order_id,
        SignedDecimal.signedDecimal memory exchangedPositionSize,
        Decimal.decimal memory exchangedQuoteAmount
    ) internal {
        (
            ILimitOrderBook.LimitOrder memory _limitOrder,
            ILimitOrderBook.RemainingOrderInfo memory _remainingOrder
        ) = getLimitOrder(order_id);

        SignedDecimal.signedDecimal memory orderSize;
        Decimal.decimal memory collateral;
        Decimal.decimal memory tipFee;

        if (_remainingOrder.remainingOrderSize.toInt() == 0) {
            orderSize = _limitOrder.orderSize;
            collateral = _limitOrder.collateral;
            tipFee = _limitOrder.tipFee;
        } else {
            orderSize = _remainingOrder.remainingOrderSize;
            collateral = _remainingOrder.remainingCollateral;
            tipFee = _remainingOrder.remainingTipFee;
        }

        Decimal.decimal memory payableTipFee;
        Decimal.decimal memory usedCollateral = exchangedQuoteAmount.divD(
            _limitOrder.leverage
        );

        bool filledAll;
        if (
            orderSize.toInt() <= exchangedPositionSize.toInt() ||
            collateral.toUint() <= usedCollateral.toUint()
        ) {
            delete orders[order_id];
            delete remainingOrders[order_id];

            payableTipFee = tipFee;
            filledAll = true;
        } else {
            remainingOrders[order_id].remainingOrderSize = orderSize.subD(
                exchangedPositionSize
            );
            remainingOrders[order_id].remainingCollateral = collateral.subD(
                exchangedQuoteAmount.divD(_limitOrder.leverage)
            );

            payableTipFee = tipFee.mulD(usedCollateral).divD(collateral);
        }

        if (payableTipFee.toUint() != 0) {
            _transfer(quoteAsset, operator, payableTipFee);
        }

        emit OrderFilled(
            trader,
            operator,
            order_id,
            filledAll,
            exchangedPositionSize.toInt(),
            exchangedQuoteAmount.toUint()
        );
    }

    /*
     * VIEW FUNCTIONS
     */
    function getLimitOrder(uint256 id)
        public
        view
        override
        onlyValidOrder(id)
        returns (LimitOrder memory, RemainingOrderInfo memory)
    {
        return (orders[id], remainingOrders[id]);
    }

    function getLimitOrderParams(uint256 id)
        public
        view
        override
        onlyValidOrder(id)
        returns (
            address,
            address,
            OrderType,
            bool,
            bool,
            uint256
        )
    {
        LimitOrder memory order = orders[id];
        return (
            order.asset,
            order.trader,
            order.orderType,
            order.reduceOnly,
            order.stillValid,
            order.expiry
        );
    }

    /*
     * ADMIN / SETUP FUNCTIONS
     */

    function setFactory(address _addr) public onlyOwner {
        factory = ISmartWalletFactory(_addr);
    }

    function changeMinimumFee(Decimal.decimal memory _fee) public onlyOwner {
        minimumTipFee = _fee;
    }

    /*
     * MODIFIERS
     */

    modifier onlyValidOrder(uint256 order_id) {
        require(order_id < orderLength, "Invalid ID");
        LimitOrder memory order = orders[order_id];
        require(order.stillValid, "No longer valid");
        require(
            ((order.expiry == 0) || (block.timestamp < order.expiry)),
            "Order expired"
        );
        _;
    }

    modifier onlyMyOrder(uint256 order_id) {
        require(msg.sender == orders[order_id].trader, "Not your order");
        _;
    }

    function requireNonZeroInput(
        Decimal.decimal memory _decimal,
        string memory errorMessage
    ) private pure {
        require(_decimal.toUint() != 0, errorMessage);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Decimal} from "../utils/Decimal.sol";
import {SignedDecimal} from "../utils/SignedDecimal.sol";

interface IAmm {
    /**
     * @notice asset direction, used in getInputPrice, getOutputPrice, swapInput and swapOutput
     * @param ADD_TO_AMM add asset to Amm
     * @param REMOVE_FROM_AMM remove asset from Amm
     */
    enum Dir {
        ADD_TO_AMM,
        REMOVE_FROM_AMM
    }

    //
    // enum and struct
    //
    struct ReserveSnapshot {
        Decimal.decimal quoteAssetReserve;
        Decimal.decimal baseAssetReserve;
        uint256 timestamp;
        uint256 blockNumber;
    }

    // internal usage
    enum QuoteAssetDir {
        QUOTE_IN,
        QUOTE_OUT
    }
    // internal usage
    enum TwapCalcOption {
        RESERVE_ASSET,
        INPUT_ASSET
    }

    // To record current base/quote asset to calculate TWAP

    struct TwapInputAsset {
        Dir dir;
        Decimal.decimal assetAmount;
        QuoteAssetDir inOrOut;
    }

    struct TwapPriceCalcParams {
        TwapCalcOption opt;
        uint256 snapshotIndex;
        TwapInputAsset asset;
    }

    struct LiquidityChangedSnapshot {
        SignedDecimal.signedDecimal cumulativeNotional;
        // the base/quote reserve of amm right before liquidity changed
        Decimal.decimal quoteAssetReserve;
        Decimal.decimal baseAssetReserve;
        // total position size owned by amm after last snapshot taken
        // `totalPositionSize` = currentBaseAssetReserve - lastLiquidityChangedHistoryItem.baseAssetReserve + prevTotalPositionSize
        SignedDecimal.signedDecimal totalPositionSize;
    }

    function swapInput(
        Dir _dir,
        Decimal.decimal calldata _quoteAssetAmount,
        Decimal.decimal calldata _baseAssetAmountLimit,
        bool _canOverFluctuationLimit
    ) external returns (Decimal.decimal memory);

    function swapOutput(
        Dir _dir,
        Decimal.decimal calldata _baseAssetAmount,
        Decimal.decimal calldata _quoteAssetAmountLimit
    ) external returns (Decimal.decimal memory);

    function shutdown() external;

    function settleFunding()
        external
        returns (SignedDecimal.signedDecimal memory);

    //
    // VIEW
    //

    function isOverFluctuationLimit(
        Dir _dirOfBase,
        Decimal.decimal memory _baseAssetAmount
    ) external view returns (bool);

    function calcBaseAssetAfterLiquidityMigration(
        SignedDecimal.signedDecimal memory _baseAssetAmount,
        Decimal.decimal memory _fromQuoteReserve,
        Decimal.decimal memory _fromBaseReserve
    ) external view returns (SignedDecimal.signedDecimal memory);

    function getInputTwap(Dir _dir, Decimal.decimal calldata _quoteAssetAmount)
        external
        view
        returns (Decimal.decimal memory);

    function getOutputTwap(Dir _dir, Decimal.decimal calldata _baseAssetAmount)
        external
        view
        returns (Decimal.decimal memory);

    function getInputPrice(Dir _dir, Decimal.decimal calldata _quoteAssetAmount)
        external
        view
        returns (Decimal.decimal memory);

    function getOutputPrice(Dir _dir, Decimal.decimal calldata _baseAssetAmount)
        external
        view
        returns (Decimal.decimal memory);

    function getInputPriceWithReserves(
        Dir _dir,
        Decimal.decimal memory _quoteAssetAmount,
        Decimal.decimal memory _quoteAssetPoolAmount,
        Decimal.decimal memory _baseAssetPoolAmount
    ) external pure returns (Decimal.decimal memory);

    function getOutputPriceWithReserves(
        Dir _dir,
        Decimal.decimal memory _baseAssetAmount,
        Decimal.decimal memory _quoteAssetPoolAmount,
        Decimal.decimal memory _baseAssetPoolAmount
    ) external pure returns (Decimal.decimal memory);

    function getSpotPrice() external view returns (Decimal.decimal memory);

    function getLiquidityHistoryLength() external view returns (uint256);

    function open() external view returns (bool);

    // can not be overridden by state variable due to type `Deciaml.decimal`
    function getSettlementPrice()
        external
        view
        returns (Decimal.decimal memory);

    function getBaseAssetDeltaThisFundingPeriod()
        external
        view
        returns (SignedDecimal.signedDecimal memory);

    function getCumulativeNotional()
        external
        view
        returns (SignedDecimal.signedDecimal memory);

    function getMaxHoldingBaseAsset()
        external
        view
        returns (Decimal.decimal memory);

    function getOpenInterestNotionalCap()
        external
        view
        returns (Decimal.decimal memory);

    function getLiquidityChangedSnapshots(uint256 i)
        external
        view
        returns (LiquidityChangedSnapshot memory);

    function getBaseAssetDelta()
        external
        view
        returns (SignedDecimal.signedDecimal memory);

    function getUnderlyingPrice()
        external
        view
        returns (Decimal.decimal memory);

    function isOverSpreadLimit() external view returns (bool);

    function getSnapshotLen() external view returns (uint256);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Decimal} from "../utils/Decimal.sol";
import {IAmm} from "./IAmm.sol";

interface IInsuranceFund {
    function withdraw(Decimal.decimal calldata _amount) external;

    function isExistedAmm(IAmm _amm) external view returns (bool);

    function getAllAmms() external view returns (IAmm[] memory);

    function quoteToken() external view returns (IERC20);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import {Decimal} from "../utils/Decimal.sol";
import {SignedDecimal} from "../utils/SignedDecimal.sol";

interface ILimitOrderBook {
    /*
     * EVENTS
     */

    event OrderCreated(address indexed trader, uint256 order_id);
    event OrderFilled(
        address indexed trader,
        address indexed operator,
        uint256 order_id,
        bool filledAll,
        int256 exchangedPositionSize,
        uint256 exchangedQuoteSize
    );
    event OrderCancelled(address indexed trader, uint256 order_id);

    /*
     * ENUMS
     */

    /*
     * Order types that the user is able to create.
     * Note that market orders are actually executed instantly on clearing house
     * therefore there should never actually be a market order in the LOB
     */
    enum OrderType {
        MARKET,
        LIMIT,
        STOPLOSS,
        CLOSEPOSITION
    }

    /*
     * STRUCTS
     */

    /*
     * @notice Every order is stored within a limit order struct (regardless of
     *    the type of order)
     * @param asset is the address of the perp AMM for that particular asset
     * @param trader is the user that created the order - note that the order will
     *   actually be executed on their smart wallet (as stored in the factory)
     * @param orderType represents the order type
     * @param reduceOnly whether the order is reduceOnly or not. A reduce only order
     *   will never increase the size of a position and will either reduce the size
     *   or close the position.
     * @param stillValid whether the order can be executed. There are two conditions
     *   where an order is no longer valid: the trader cancels the order, or the
     *   order gets executed (to prevent double spend)
     * @param expiry is the blockTimestamp when this order expires. If this value
     *   is 0 then the order will not expire
     * @param limitPrice is the trigger price for any limit order. a limit BUY can
     *   only be executed below/above this price, whilst a limit SELL is executed above/below
     * @param orderSize is the size of the order (denominated in the base asset)
     * @param collateral is the amount of collateral or margin that will be used
     *   for this order. This amount is guaranteed ie an order with 300 USDC will
     *   always use 300 USDC.
     * @param leverage is the maximum amount of leverage that the trader will accept.
     * @param slippage is the minimum amount of ASSET that the user will accept.
     *   The trader will usually achieve the amount specified by orderSize. This
     *   parameter allows the user to specify their tolerance to price impact / frontrunning
     * @param tipFee is the fee that goes to the keeper for executing the order.
     *   This fee is taken when the order is created, and paid out when executing.
     */
    struct LimitOrder {
        address asset;
        address trader;
        bool reduceOnly;
        bool stillValid;
        OrderType orderType;
        uint256 expiry;
        Decimal.decimal limitPrice;
        SignedDecimal.signedDecimal orderSize;
        Decimal.decimal collateral;
        Decimal.decimal leverage;
        Decimal.decimal slippage;
        Decimal.decimal tipFee;
    }

    struct RemainingOrderInfo {
        SignedDecimal.signedDecimal remainingOrderSize;
        Decimal.decimal remainingCollateral;
        Decimal.decimal remainingTipFee;
    }

    function getLimitOrder(uint256 id)
        external
        view
        returns (LimitOrder memory, RemainingOrderInfo memory);

    function getLimitOrderParams(uint256 id)
        external
        view
        returns (
            address,
            address,
            OrderType,
            bool,
            bool,
            uint256
        );
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import {IAmm} from "./IAmm.sol";
import {Decimal} from "../utils/Decimal.sol";
import {SignedDecimal} from "../utils/SignedDecimal.sol";

interface ISmartWallet {
    function initialize(
        address _clearingHouse,
        address _limitOrderBook,
        address _owner
    ) external;

    function owner() external view returns (address);

    function executeCall(
        address target,
        bytes calldata callData,
        uint256 value
    ) external payable returns (bytes memory);

    function executeMarketOrder(
        IAmm _asset,
        SignedDecimal.signedDecimal memory _orderSize,
        Decimal.decimal memory _collateral,
        Decimal.decimal memory _leverage,
        Decimal.decimal memory _slippage
    ) external;

    function executeClosePosition(IAmm _asset, Decimal.decimal memory _slippage)
        external;

    function executeClosePartialPosition(
        IAmm _asset,
        Decimal.decimal memory _percentage,
        Decimal.decimal memory _slippage
    ) external;

    function executeOrder(uint256 order_id, Decimal.decimal memory maxNotional)
        external
        returns (
            SignedDecimal.signedDecimal memory exchangedPositionSize,
            Decimal.decimal memory exchangedQuoteAmount
        );

    function executeAddMargin(
        IAmm _asset,
        Decimal.decimal calldata _addedMargin
    ) external;

    function executeRemoveMargin(
        IAmm _asset,
        Decimal.decimal calldata _removedMargin
    ) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

interface ISmartWalletFactory {
    function getSmartWallet(address) external returns (address);

    function isWhitelisted(address) external returns (bool);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {DecimalMath} from "./DecimalMath.sol";

library Decimal {
    using DecimalMath for uint256;

    struct decimal {
        uint256 d;
    }

    function zero() internal pure returns (decimal memory) {
        return decimal(0);
    }

    function one() internal pure returns (decimal memory) {
        return decimal(DecimalMath.unit(18));
    }

    function toUint(decimal memory x) internal pure returns (uint256) {
        return x.d;
    }

    function modD(decimal memory x, decimal memory y)
        internal
        pure
        returns (decimal memory)
    {
        return decimal((x.d * DecimalMath.unit(18)) % y.d);
    }

    function cmp(decimal memory x, decimal memory y)
        internal
        pure
        returns (int8)
    {
        if (x.d > y.d) {
            return 1;
        } else if (x.d < y.d) {
            return -1;
        }
        return 0;
    }

    /// @dev add two decimals
    function addD(decimal memory x, decimal memory y)
        internal
        pure
        returns (decimal memory)
    {
        decimal memory t;
        t.d = x.d + y.d;
        return t;
    }

    /// @dev subtract two decimals
    function subD(decimal memory x, decimal memory y)
        internal
        pure
        returns (decimal memory)
    {
        decimal memory t;
        t.d = x.d - y.d;
        return t;
    }

    /// @dev multiple two decimals
    function mulD(decimal memory x, decimal memory y)
        internal
        pure
        returns (decimal memory)
    {
        decimal memory t;
        t.d = x.d.muld(y.d);
        return t;
    }

    /// @dev multiple a decimal by a uint256
    function mulScalar(decimal memory x, uint256 y)
        internal
        pure
        returns (decimal memory)
    {
        decimal memory t;
        t.d = x.d * y;
        return t;
    }

    /// @dev divide two decimals
    function divD(decimal memory x, decimal memory y)
        internal
        pure
        returns (decimal memory)
    {
        decimal memory t;
        t.d = x.d.divd(y.d);
        return t;
    }

    /// @dev divide a decimal by a uint256
    function divScalar(decimal memory x, uint256 y)
        internal
        pure
        returns (decimal memory)
    {
        decimal memory t;
        t.d = x.d / y;
        return t;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Decimal} from "./Decimal.sol";

abstract contract DecimalERC20 {
    using Decimal for Decimal.decimal;

    mapping(address => uint256) private decimalMap;

    //◥◤◥◤◥◤◥◤◥◤◥◤◥◤◥◤ add state variables below ◥◤◥◤◥◤◥◤◥◤◥◤◥◤◥◤//

    //◢◣◢◣◢◣◢◣◢◣◢◣◢◣◢◣ add state variables above ◢◣◢◣◢◣◢◣◢◣◢◣◢◣◢◣//

    //
    // INTERNAL functions
    //

    // CAUTION: do not input _from == _to s.t. this function will always fail
    function _transfer(
        IERC20 _token,
        address _to,
        Decimal.decimal memory _value
    ) internal {
        _updateDecimal(address(_token));
        Decimal.decimal memory balanceBefore = _balanceOf(_token, _to);
        uint256 roundedDownValue = _toUint(_token, _value);

        // solhint-disable avoid-low-level-calls
        (bool success, bytes memory data) = address(_token).call(
            abi.encodeWithSelector(
                _token.transfer.selector,
                _to,
                roundedDownValue
            )
        );

        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "DecimalERC20: transfer failed"
        );
        _validateBalance(_token, _to, roundedDownValue, balanceBefore);
    }

    function _transferFrom(
        IERC20 _token,
        address _from,
        address _to,
        Decimal.decimal memory _value
    ) internal {
        _updateDecimal(address(_token));
        Decimal.decimal memory balanceBefore = _balanceOf(_token, _to);
        uint256 roundedDownValue = _toUint(_token, _value);

        // solhint-disable avoid-low-level-calls
        (bool success, bytes memory data) = address(_token).call(
            abi.encodeWithSelector(
                _token.transferFrom.selector,
                _from,
                _to,
                roundedDownValue
            )
        );

        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "DecimalERC20: transferFrom failed"
        );
        _validateBalance(_token, _to, roundedDownValue, balanceBefore);
    }

    function _approve(
        IERC20 _token,
        address _spender,
        Decimal.decimal memory _value
    ) internal {
        _updateDecimal(address(_token));
        // to be compatible with some erc20 tokens like USDT
        __approve(_token, _spender, Decimal.zero());
        __approve(_token, _spender, _value);
    }

    //
    // VIEW
    //
    function _allowance(
        IERC20 _token,
        address _owner,
        address _spender
    ) internal view returns (Decimal.decimal memory) {
        return _toDecimal(_token, _token.allowance(_owner, _spender));
    }

    function _balanceOf(IERC20 _token, address _owner)
        internal
        view
        returns (Decimal.decimal memory)
    {
        return _toDecimal(_token, _token.balanceOf(_owner));
    }

    function _totalSupply(IERC20 _token)
        internal
        view
        returns (Decimal.decimal memory)
    {
        return _toDecimal(_token, _token.totalSupply());
    }

    function _toDecimal(IERC20 _token, uint256 _number)
        internal
        view
        returns (Decimal.decimal memory)
    {
        uint256 tokenDecimals = _getTokenDecimals(address(_token));
        if (tokenDecimals >= 18) {
            return Decimal.decimal(_number / (10**(tokenDecimals - 18)));
        }

        return Decimal.decimal(_number * (10**(uint256(18) - tokenDecimals)));
    }

    function _toUint(IERC20 _token, Decimal.decimal memory _decimal)
        internal
        view
        returns (uint256)
    {
        uint256 tokenDecimals = _getTokenDecimals(address(_token));
        if (tokenDecimals >= 18) {
            return _decimal.toUint() * (10**(tokenDecimals - 18));
        }
        return _decimal.toUint() / (10**(uint256(18) - tokenDecimals));
    }

    function _getTokenDecimals(address _token) internal view returns (uint256) {
        uint256 tokenDecimals = decimalMap[_token];
        if (tokenDecimals == 0) {
            (bool success, bytes memory data) = _token.staticcall(
                abi.encodeWithSignature("decimals()")
            );
            require(
                success && data.length != 0,
                "DecimalERC20: get decimals failed"
            );
            tokenDecimals = abi.decode(data, (uint256));
        }
        return tokenDecimals;
    }

    //
    // PRIVATE
    //
    function _updateDecimal(address _token) private {
        uint256 tokenDecimals = _getTokenDecimals(_token);
        if (decimalMap[_token] != tokenDecimals) {
            decimalMap[_token] = tokenDecimals;
        }
    }

    function __approve(
        IERC20 _token,
        address _spender,
        Decimal.decimal memory _value
    ) private {
        // solhint-disable avoid-low-level-calls
        (bool success, bytes memory data) = address(_token).call(
            abi.encodeWithSelector(
                _token.approve.selector,
                _spender,
                _toUint(_token, _value)
            )
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "DecimalERC20: approve failed"
        );
    }

    // To prevent from deflationary token, check receiver's balance is as expectation.
    function _validateBalance(
        IERC20 _token,
        address _to,
        uint256 _roundedDownValue,
        Decimal.decimal memory _balanceBefore
    ) private view {
        require(
            _balanceOf(_token, _to).cmp(
                _balanceBefore.addD(_toDecimal(_token, _roundedDownValue))
            ) == 0,
            "DecimalERC20: balance inconsistent"
        );
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

/// @dev Implements simple fixed point math add, sub, mul and div operations.
/// @author Alberto Cuesta Cañada
library DecimalMath {
    /// @dev Returns 1 in the fixed point representation, with `decimals` decimals.
    function unit(uint8 decimals) internal pure returns (uint256) {
        return 10**uint256(decimals);
    }

    /// @dev Adds x and y, assuming they are both fixed point with 18 decimals.
    function addd(uint256 x, uint256 y) internal pure returns (uint256) {
        return x + y;
    }

    /// @dev Subtracts y from x, assuming they are both fixed point with 18 decimals.
    function subd(uint256 x, uint256 y) internal pure returns (uint256) {
        return x - y;
    }

    /// @dev Multiplies x and y, assuming they are both fixed point with 18 digits.
    function muld(uint256 x, uint256 y) internal pure returns (uint256) {
        return muld(x, y, 18);
    }

    /// @dev Multiplies x and y, assuming they are both fixed point with `decimals` digits.
    function muld(
        uint256 x,
        uint256 y,
        uint8 decimals
    ) internal pure returns (uint256) {
        return (x * y) / unit(decimals);
    }

    /// @dev Divides x between y, assuming they are both fixed point with 18 digits.
    function divd(uint256 x, uint256 y) internal pure returns (uint256) {
        return divd(x, y, 18);
    }

    /// @dev Divides x between y, assuming they are both fixed point with `decimals` digits.
    function divd(
        uint256 x,
        uint256 y,
        uint8 decimals
    ) internal pure returns (uint256) {
        return (x * unit(decimals)) / y;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {SignedDecimalMath} from "./SignedDecimalMath.sol";
import {Decimal} from "./Decimal.sol";

library SignedDecimal {
    using SignedDecimalMath for int256;

    struct signedDecimal {
        int256 d;
    }

    function zero() internal pure returns (signedDecimal memory) {
        return signedDecimal(0);
    }

    function toInt(signedDecimal memory x) internal pure returns (int256) {
        return x.d;
    }

    function isNegative(signedDecimal memory x) internal pure returns (bool) {
        if (x.d < 0) {
            return true;
        }
        return false;
    }

    function abs(signedDecimal memory x)
        internal
        pure
        returns (Decimal.decimal memory)
    {
        Decimal.decimal memory t;
        if (x.d < 0) {
            t.d = uint256(0 - x.d);
        } else {
            t.d = uint256(x.d);
        }
        return t;
    }

    /// @dev add two decimals
    function addD(signedDecimal memory x, signedDecimal memory y)
        internal
        pure
        returns (signedDecimal memory)
    {
        signedDecimal memory t;
        t.d = x.d + y.d;
        return t;
    }

    /// @dev subtract two decimals
    function subD(signedDecimal memory x, signedDecimal memory y)
        internal
        pure
        returns (signedDecimal memory)
    {
        signedDecimal memory t;
        t.d = x.d - y.d;
        return t;
    }

    /// @dev multiple two decimals
    function mulD(signedDecimal memory x, signedDecimal memory y)
        internal
        pure
        returns (signedDecimal memory)
    {
        signedDecimal memory t;
        t.d = x.d.muld(y.d);
        return t;
    }

    /// @dev multiple a signedDecimal by a int256
    function mulScalar(signedDecimal memory x, int256 y)
        internal
        pure
        returns (signedDecimal memory)
    {
        signedDecimal memory t;
        t.d = x.d * y;
        return t;
    }

    /// @dev divide two decimals
    function divD(signedDecimal memory x, signedDecimal memory y)
        internal
        pure
        returns (signedDecimal memory)
    {
        signedDecimal memory t;
        t.d = x.d.divd(y.d);
        return t;
    }

    /// @dev divide a signedDecimal by a int256
    function divScalar(signedDecimal memory x, int256 y)
        internal
        pure
        returns (signedDecimal memory)
    {
        signedDecimal memory t;
        t.d = x.d / y;
        return t;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

/// @dev Implements simple signed fixed point math add, sub, mul and div operations.
library SignedDecimalMath {
    /// @dev Returns 1 in the fixed point representation, with `decimals` decimals.
    function unit(uint8 decimals) internal pure returns (int256) {
        return int256(10**uint256(decimals));
    }

    /// @dev Adds x and y, assuming they are both fixed point with 18 decimals.
    function addd(int256 x, int256 y) internal pure returns (int256) {
        return x + y;
    }

    /// @dev Subtracts y from x, assuming they are both fixed point with 18 decimals.
    function subd(int256 x, int256 y) internal pure returns (int256) {
        return x - y;
    }

    /// @dev Multiplies x and y, assuming they are both fixed point with 18 digits.
    function muld(int256 x, int256 y) internal pure returns (int256) {
        return muld(x, y, 18);
    }

    /// @dev Multiplies x and y, assuming they are both fixed point with `decimals` digits.
    function muld(
        int256 x,
        int256 y,
        uint8 decimals
    ) internal pure returns (int256) {
        return (x * y) / unit(decimals);
    }

    /// @dev Divides x between y, assuming they are both fixed point with 18 digits.
    function divd(int256 x, int256 y) internal pure returns (int256) {
        return divd(x, y, 18);
    }

    /// @dev Divides x between y, assuming they are both fixed point with `decimals` digits.
    function divd(
        int256 x,
        int256 y,
        uint8 decimals
    ) internal pure returns (int256) {
        return (x * unit(decimals)) / y;
    }
}