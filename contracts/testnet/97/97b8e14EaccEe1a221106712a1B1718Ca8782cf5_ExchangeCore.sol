//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../libs/LibEIP712ExchangeDomain.sol";
import "../libs/LibExchangeRichErrors.sol";
import "../libs/LibOrder.sol";
import "../libs/LibFillResults.sol";
import "../libs/LibSafeMath.sol";
import "./SignatureValidator.sol";
import "./AssetProxyDispatcher.sol";
import "./ProtocolFees.sol";
import "../libs/LibRichErrors.sol";

contract ExchangeCore is
    Ownable,
    ReentrancyGuard,
    Pausable,
    LibEIP712ExchangeDomain,
    SignatureValidator,
    AssetProxyDispatcher,
    ProtocolFees
{
    using LibSafeMath for uint256;
    using LibOrder for LibOrder.Order;
    // Fill event is emitted whenever an order is filled.
    event Fill(
        address indexed makerAddress, // Address that created the order.
        address indexed feeRecipientAddress, // Address that received fees.
        bytes makerAssetData, // Encoded data specific to makerAsset.
        bytes takerAssetData, // Encoded data specific to takerAsset.
        bytes makerFeeAssetData, // Encoded data specific to makerFeeAsset.
        bytes takerFeeAssetData, // Encoded data specific to takerFeeAsset.
        bytes32 indexed orderHash, // EIP712 hash of order (see LibOrder.getTypedDataHash).
        address takerAddress, // Address that filled the order.
        address senderAddress, // Address that called the Exchange contract (msg.sender).
        uint256 makerAssetFilledAmount, // Amount of makerAsset sold by maker and bought by taker.
        uint256 takerAssetFilledAmount, // Amount of takerAsset sold by taker and bought by maker.
        uint256 makerFeePaid, // Amount of makerFeeAssetData paid to feeRecipient by maker.
        uint256 takerFeePaid, // Amount of takerFeeAssetData paid to feeRecipient by taker.
        uint256 protocolFeePaid // Amount of eth or weth paid to the staking contract.
    );

    // Cancel event is emitted whenever an individual order is cancelled.
    event Cancel(
        address indexed makerAddress, // Address that created the order.
        address indexed feeRecipientAddress, // Address that would have recieved fees if order was filled.
        bytes makerAssetData, // Encoded data specific to makerAsset.
        bytes takerAssetData, // Encoded data specific to takerAsset.
        address senderAddress, // Address that called the Exchange contract (msg.sender).
        bytes32 indexed orderHash // EIP712 hash of order (see LibOrder.getTypedDataHash).
    );

    mapping(bytes32 => uint256) public filled;
    mapping(bytes32 => bool) public cancelled;
    mapping(address => mapping(address => uint256)) public orderEpoch;

    constructor(uint256 chainId, address verifyingContractAddressIfExists)
        LibEIP712ExchangeDomain(chainId, verifyingContractAddressIfExists)
    {
        // Child construction code goes here
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // @dev Fills the input order.
    // @param order Order struct containing order specifications.
    // @param takerAssetFillAmount Desired amount of takerAsset to sell.
    // @param signature Proof that order has been created by maker.
    // @return fillResults Amounts filled and fees paid by maker and taker.
    function fillOrder(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        address takerAddress,
        bytes memory signature
    )
        public
        payable
        whenNotPaused
        nonReentrant
        returns (LibFillResults.FillResults memory fillResults)
    {
        if (order.orderType == LibOrder.OrderType.BID) {
            if (order.isNative || takerAddress == address(0)) {
                revert("EX:INVALID_ORDER_BID_DATA");
            }
        } else {
            takerAddress = msg.sender;
        }
        fillResults = _fillOrder(
            order,
            takerAssetFillAmount,
            takerAddress,
            signature
        );
        return fillResults;
    }

    // @dev Fills the input order.
    // @param order Order struct containing order specifications.
    // @param takerAssetFillAmount Desired amount of takerAsset to sell.
    // @param signature Proof that order has been created by maker.
    // @return fillResults Amounts filled and fees paid by maker and taker.
    function _fillOrder(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        address takerAddress,
        bytes memory signature
    ) internal returns (LibFillResults.FillResults memory fillResults) {
        // Fetch order info
        LibOrder.OrderInfo memory orderInfo = getOrderInfo(order);

        // Fetch taker address

        // Assert that the order is fillable by taker
        _assertFillableOrder(
            order,
            orderInfo,
            takerAddress,
            takerAssetFillAmount,
            signature
        );

        // Compute proportional fill amounts
        fillResults = LibFillResults.calculateFillResults(
            order,
            takerAssetFillAmount,
            protocolFeeMultiplier,
            tx.gasprice
        );

        bytes32 orderHash = orderInfo.orderHash;

        // Update exchange internal state
        _updateFilledState(
            order,
            takerAddress,
            orderHash,
            order.orderType == LibOrder.OrderType.BID
                ? order.oData.tAmount - fillResults.takerAssetFilledAmount
                : orderInfo.orderTakerAssetFilledAmount,
            fillResults
        );

        // Settle order
        if (!order.isNative) {
            if (order.orderType == LibOrder.OrderType.EVENT) {
                _dispatchTransferFrom(
                    order.oData.mAssetData,
                    order.oData.maker,
                    takerAddress,
                    fillResults.makerAssetFilledAmount
                );
            } else _settleOrder(order, takerAddress, fillResults);
        } else {
            if (msg.value < takerAssetFillAmount + fillResults.takerFeePaid) {
                revert("EX:INVALID_AMOUNT_NATIVE_ORDER");
            }
            _settleNativeOrder(order, takerAddress, fillResults);
        }
        return fillResults;
    }

    // @dev Gets information about an order: status, hash, and amount filled.
    // @param order Order to gather information on.
    // @return orderInfo Information about the order and its state.
    //         See LibOrder.OrderInfo for a complete description.
    function getOrderInfo(LibOrder.Order memory order)
        public
        view
        returns (LibOrder.OrderInfo memory orderInfo)
    {
        // Compute the order hash and fetch the amount of takerAsset that has already been filled
        (
            orderInfo.orderHash,
            orderInfo.orderTakerAssetFilledAmount
        ) = _getOrderHashAndFilledAmount(order);

        // If order.makerAssetAmount is zero, we also reject the order.
        // While the Exchange contract handles them correctly, they create
        // edge cases in the supporting infrastructure because they have
        // an 'infinite' price when computed by a simple division.
        if (order.oData.mAmount == 0) {
            orderInfo.orderStatus = LibOrder
                .OrderStatus
                .INVALID_MAKER_ASSET_AMOUNT;
            return orderInfo;
        }

        // If order.takerAssetAmount is zero, then the order will always
        // be considered filled because 0 == takerAssetAmount == orderTakerAssetFilledAmount
        // Instead of distinguishing between unfilled and filled zero taker
        // amount orders, we choose not to support them.
        if (order.oData.tAmount == 0) {
            orderInfo.orderStatus = LibOrder
                .OrderStatus
                .INVALID_TAKER_ASSET_AMOUNT;
            return orderInfo;
        }

        // Validate order availability
        if (orderInfo.orderTakerAssetFilledAmount >= order.oData.tAmount) {
            orderInfo.orderStatus = LibOrder.OrderStatus.FULLY_FILLED;
            return orderInfo;
        }

        // Validate order expiration
        // solhint-disable-next-line not-rely-on-time
        if (block.timestamp >= order.expired) {
            orderInfo.orderStatus = LibOrder.OrderStatus.EXPIRED;
            return orderInfo;
        }

        // Check if order has been cancelled
        if (cancelled[orderInfo.orderHash]) {
            orderInfo.orderStatus = LibOrder.OrderStatus.CANCELLED;
            return orderInfo;
        }
        if (orderEpoch[order.oData.maker][order.aSender] > order.salt) {
            orderInfo.orderStatus = LibOrder.OrderStatus.CANCELLED;
            return orderInfo;
        }

        // All other statuses are ruled out: order is Fillable
        orderInfo.orderStatus = LibOrder.OrderStatus.FILLABLE;
        return orderInfo;
    }

    // @dev Gets the order's hash and amount of takerAsset that has already been filled.
    // @param order Order struct containing order specifications.
    // @return The typed data hash and amount filled of the order.
    function _getOrderHashAndFilledAmount(LibOrder.Order memory order)
        internal
        view
        returns (bytes32 orderHash, uint256 orderTakerAssetFilledAmount)
    {
        orderHash = order.getTypedDataHash(EIP712_EXCHANGE_DOMAIN_HASH);
        orderTakerAssetFilledAmount = filled[orderHash];
        return (orderHash, orderTakerAssetFilledAmount);
    }

    // @dev Validates context for fillOrder. Succeeds or throws.
    // @param order to be filled.
    // @param orderInfo OrderStatus, orderHash, and amount already filled of order.
    // @param takerAddress Address of order taker.
    // @param signature Proof that the orders was created by its maker.
    function _assertFillableOrder(
        LibOrder.Order memory order,
        LibOrder.OrderInfo memory orderInfo,
        address takerAddress,
        uint256 takerAssetFillAmount,
        bytes memory signature
    ) internal view {
        // An order can only be filled if its status is FILLABLE.
        if (orderInfo.orderStatus != LibOrder.OrderStatus.FILLABLE) {
            revert("AFO:ORDER_STATUS_ERROR_SELECTOR");
        }

        // Validate sender is allowed to fill this order
        if (order.aSender != address(0)) {
            if (order.aSender != msg.sender) {
                revert("AFO:INVALID_SENDER");
            }
        }

        // Validate taker is allowed to fill this order
        if (order.oData.taker != address(0)) {
            if (order.oData.taker != takerAddress) {
                revert("AFO:INVALID_TAKER");
            }
        }

        if (
            order.orderType == LibOrder.OrderType.BASIC &&
            takerAssetFillAmount < order.oData.tAmount
        ) {
            revert("AFO:INVALID_TAKER_FILL_AMOUNT");
        }

        // Validate signature
        if (!_validateOrderEIP712(order, orderInfo.orderHash, signature)) {
            revert("AFO:BAD_ORDER_SIGNATURE");
        }
    }

    // @dev Updates state with results of a fill order.
    // @param order that was filled.
    // @param takerAddress Address of taker who filled the order.
    // @param orderTakerAssetFilledAmount Amount of order already filled.
    function _updateFilledState(
        LibOrder.Order memory order,
        address takerAddress,
        bytes32 orderHash,
        uint256 orderTakerAssetFilledAmount,
        LibFillResults.FillResults memory fillResults
    ) internal {
        // Update state
        filled[orderHash] = orderTakerAssetFilledAmount.safeAdd(
            fillResults.takerAssetFilledAmount
        );

        emit Fill(
            order.oData.maker,
            order.feeRecipient,
            order.oData.mAssetData,
            order.oData.tAssetData,
            order.oData.mfAssetData,
            order.oData.tfAssetData,
            orderHash,
            takerAddress,
            msg.sender,
            fillResults.makerAssetFilledAmount,
            fillResults.takerAssetFilledAmount,
            fillResults.makerFeePaid,
            fillResults.takerFeePaid,
            fillResults.protocolFeePaid
        );
    }

    // @dev Settles an order by transferring assets between counterparties.
    // @param orderHash The order hash.
    // @param order Order struct containing order specifications.
    // @param takerAddress Address selling takerAsset and buying makerAsset.
    // @param fillResults Amounts to be filled and fees paid by maker and taker.
    function _settleOrder(
        LibOrder.Order memory order,
        address takerAddress,
        LibFillResults.FillResults memory fillResults
    ) internal {
        for (uint256 i = 0; i < order.oData.others.length; ++i) {
            _dispatchTransferFrom(
                order.oData.tAssetData,
                takerAddress,
                order.oData.others[i].aRecipient,
                order.oData.others[i].amount
            );
        }

        // Transfer taker -> maker
        _dispatchTransferFrom(
            order.oData.tAssetData,
            takerAddress,
            order.oData.maker,
            fillResults.takerAssetFilledAmount.safeSub(fillResults.makerFeePaid)
        );

        // Transfer maker -> taker
        _dispatchTransferFrom(
            order.oData.mAssetData,
            order.oData.maker,
            takerAddress,
            fillResults.makerAssetFilledAmount
        );

        // Transfer taker fee -> feeRecipient
        _dispatchTransferFrom(
            order.oData.tfAssetData,
            takerAddress,
            order.feeRecipient,
            fillResults.takerFeePaid
        );

        // Maker fee was subtracted above, transfer from taker -> feeRecipient
        _dispatchTransferFrom(
            order.oData.mfAssetData,
            takerAddress,
            order.feeRecipient,
            fillResults.makerFeePaid
        );

        // Pay protocol fee
        bool didPayProtocolFee = _paySingleProtocolFee(
            fillResults.protocolFeePaid,
            order.oData.maker,
            takerAddress
        );

        // Protocol fees are not paid if the protocolFeeCollector contract is not set
        if (!didPayProtocolFee) {
            fillResults.protocolFeePaid = 0;
        }
    }

    // @dev Settles an order by transferring assets between counterparties.
    // @param orderHash The order hash.
    // @param order Order struct containing order specifications.
    // @param takerAddress Address selling takerAsset and buying makerAsset.
    // @param fillResults Amounts to be filled and fees paid by maker and taker.
    function _settleNativeOrder(
        LibOrder.Order memory order,
        address takerAddress,
        LibFillResults.FillResults memory fillResults
    ) internal {
        // Transfer extras
        address payable to = payable(order.oData.maker);
        uint256 receiveAmount = fillResults.takerAssetFilledAmount.safeSub(
            fillResults.makerFeePaid
        );
        uint256 totalAdditionalRecipients = order.oData.others.length;
        unchecked {
            // Iterate over each additional recipient.
            for (uint256 i = 0; i < totalAdditionalRecipients; ++i) {
                // Transfer Ether to the additional recipient.
                _transferEth(
                    order.oData.others[i].aRecipient,
                    order.oData.others[i].amount
                );
            }
        }

        //transfer taker->maker (real amount - maker fee paid)
        _transferEth(to, receiveAmount);

        //transfer maker->taker
        _dispatchTransferFrom(
            order.oData.mAssetData,
            order.oData.maker,
            takerAddress,
            fillResults.makerAssetFilledAmount
        );

        //transfer takerfee->feeRecipient
        if (fillResults.takerFeePaid > 0) {
            _transferEth(payable(order.feeRecipient), fillResults.takerFeePaid);
        }

        //transfer makerfee->feeRecipient
        if (fillResults.makerFeePaid > 0) {
            _transferEth(payable(order.feeRecipient), fillResults.makerFeePaid);
        }
    }

    /// @dev After calling, the order can not be filled anymore.
    /// @param order Order struct containing order specifications.
    function cancelOrder(LibOrder.Order memory order)
        public
        payable
        whenNotPaused
        nonReentrant
    {
        _cancelOrder(order);
    }

    /// @dev After calling, the order can not be filled anymore.
    /// Throws if order is invalid or sender does not have permission to cancel.
    /// @param order Order to cancel. Order must be OrderStatus.FILLABLE.
    function _cancelOrder(LibOrder.Order memory order) internal {
        // Fetch current order status
        LibOrder.OrderInfo memory orderInfo = getOrderInfo(order);

        // Validate context
        _assertValidCancel(order);

        // Noop if order is already unfillable
        if (orderInfo.orderStatus != LibOrder.OrderStatus.FILLABLE) {
            return;
        }

        // Perform cancel
        _updateCancelledState(order, orderInfo.orderHash);
    }

    // @dev Validates context for cancelOrder. Succeeds or throws.
    // @param order to be cancelled.
    // @param orderInfo OrderStatus, orderHash, and amount already filled of order.
    function _assertValidCancel(LibOrder.Order memory order) internal view {
        // Validate sender is allowed to cancel this order
        if (order.aSender != address(0)) {
            if (order.aSender != msg.sender) {
                revert("AVC:INVALID_SENDER");
            }
        }

        // Validate transaction signed by maker
        address makerAddress = _msgSender();
        if (order.oData.maker != makerAddress) {
            revert("AVC:INVALID_MAKER");
        }
    }

    /// @dev Updates state with results of cancelling an order.
    ///      State is only updated if the order is currently fillable.
    ///      Otherwise, updating state would have no effect.
    /// @param order that was cancelled.
    /// @param orderHash Hash of order that was cancelled.
    function _updateCancelledState(
        LibOrder.Order memory order,
        bytes32 orderHash
    ) internal {
        // Perform cancel
        cancelled[orderHash] = true;

        // Log cancel
        emit Cancel(
            order.oData.maker,
            order.feeRecipient,
            order.oData.mAssetData,
            order.oData.tAssetData,
            msg.sender,
            orderHash
        );
    }

    function _transferEth(address payable to, uint256 amount) internal {
        // Ensure that the supplied amount is non-zero.
        LibFillResults.assertNonZeroAmount(amount);

        // Declare a variable indicating whether the call was successful or not.
        bool success;

        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        // If the call fails...
        if (!success) {
            // Revert and pass the revert reason along if one was returned.
            LibRichErrors.revertWithReasonIfOneIsReturned();
            // Otherwise, revert with a generic error message.
            revert("EX_TRANSFER_ETH_FAILED");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "./LibEIP712.sol";

contract LibEIP712ExchangeDomain {
    // EIP712 Exchange Domain Name value
    string internal constant _EIP712_EXCHANGE_DOMAIN_NAME = "Nftciti VN";

    // EIP712 Exchange Domain Version value
    string internal constant _EIP712_EXCHANGE_DOMAIN_VERSION = "1.0.0";

    // solhint-disable var-name-mixedcase
    // @dev Hash of the EIP712 Domain Separator data
    // @return 0 Domain hash.
    bytes32 public EIP712_EXCHANGE_DOMAIN_HASH;

    // solhint-enable var-name-mixedcase

    // @param chainId Chain ID of the network this contract is deployed on.
    // @param verifyingContractAddressIfExists Address of the verifying contract (null if the address of this contract)
    constructor(uint256 chainId, address verifyingContractAddressIfExists) {
        address verifyingContractAddress = verifyingContractAddressIfExists ==
            address(0)
            ? address(this)
            : verifyingContractAddressIfExists;
        EIP712_EXCHANGE_DOMAIN_HASH = LibEIP712.hashEIP712Domain(
            _EIP712_EXCHANGE_DOMAIN_NAME,
            _EIP712_EXCHANGE_DOMAIN_VERSION,
            chainId,
            verifyingContractAddress
        );
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "./LibRichErrors.sol";
import "./LibOrder.sol";

library LibExchangeRichErrors {
    enum AssetProxyDispatchErrorCodes {
        INVALID_ASSET_DATA_LENGTH,
        UNKNOWN_ASSET_PROXY
    }

    enum BatchMatchOrdersErrorCodes {
        ZERO_LEFT_ORDERS,
        ZERO_RIGHT_ORDERS,
        INVALID_LENGTH_LEFT_SIGNATURES,
        INVALID_LENGTH_RIGHT_SIGNATURES
    }

    enum ExchangeContextErrorCodes {
        INVALID_MAKER,
        INVALID_TAKER,
        INVALID_SENDER
    }

    enum FillErrorCodes {
        INVALID_TAKER_AMOUNT,
        TAKER_OVERPAY,
        OVERFILL,
        INVALID_FILL_PRICE
    }

    enum SignatureErrorCodes {
        BAD_ORDER_SIGNATURE,
        BAD_TRANSACTION_SIGNATURE,
        INVALID_LENGTH,
        UNSUPPORTED,
        ILLEGAL,
        INAPPROPRIATE_SIGNATURE_TYPE,
        INVALID_SIGNER
    }

    enum TransactionErrorCodes {
        ALREADY_EXECUTED,
        EXPIRED
    }

    enum IncompleteFillErrorCode {
        INCOMPLETE_MARKET_BUY_ORDERS,
        INCOMPLETE_MARKET_SELL_ORDERS,
        INCOMPLETE_FILL_ORDER
    }

    // bytes4(keccak256("SignatureError(uint8,bytes32,address,bytes)"))
    bytes4 internal constant SIGNATURE_ERROR_SELECTOR = 0x7e5a2318;

    // bytes4(keccak256("SignatureValidatorNotApprovedError(address,address)"))
    bytes4 internal constant SIGNATURE_VALIDATOR_NOT_APPROVED_ERROR_SELECTOR =
        0xa15c0d06;

    // bytes4(keccak256("EIP1271SignatureError(address,bytes,bytes,bytes)"))
    bytes4 internal constant EIP1271_SIGNATURE_ERROR_SELECTOR = 0x5bd0428d;

    // bytes4(keccak256("SignatureWalletError(bytes32,address,bytes,bytes)"))
    bytes4 internal constant SIGNATURE_WALLET_ERROR_SELECTOR = 0x1b8388f7;

    // bytes4(keccak256("OrderStatusError(bytes32,uint8)"))
    bytes4 internal constant ORDER_STATUS_ERROR_SELECTOR = 0xfdb6ca8d;

    // bytes4(keccak256("ExchangeInvalidContextError(uint8,bytes32,address)"))
    bytes4 internal constant EXCHANGE_INVALID_CONTEXT_ERROR_SELECTOR =
        0xe53c76c8;

    // bytes4(keccak256("FillError(uint8,bytes32)"))
    bytes4 internal constant FILL_ERROR_SELECTOR = 0xe94a7ed0;

    // bytes4(keccak256("OrderEpochError(address,address,uint256)"))
    bytes4 internal constant ORDER_EPOCH_ERROR_SELECTOR = 0x4ad31275;

    // bytes4(keccak256("AssetProxyExistsError(bytes4,address)"))
    bytes4 internal constant ASSET_PROXY_EXISTS_ERROR_SELECTOR = 0x11c7b720;

    // bytes4(keccak256("AssetProxyDispatchError(uint8,bytes32,bytes)"))
    bytes4 internal constant ASSET_PROXY_DISPATCH_ERROR_SELECTOR = 0x488219a6;

    // bytes4(keccak256("AssetProxyTransferError(bytes32,bytes,bytes)"))
    bytes4 internal constant ASSET_PROXY_TRANSFER_ERROR_SELECTOR = 0x4678472b;

    // bytes4(keccak256("NegativeSpreadError(bytes32,bytes32)"))
    bytes4 internal constant NEGATIVE_SPREAD_ERROR_SELECTOR = 0xb6555d6f;

    // bytes4(keccak256("TransactionError(uint8,bytes32)"))
    bytes4 internal constant TRANSACTION_ERROR_SELECTOR = 0xf5985184;

    // bytes4(keccak256("TransactionExecutionError(bytes32,bytes)"))
    bytes4 internal constant TRANSACTION_EXECUTION_ERROR_SELECTOR = 0x20d11f61;

    // bytes4(keccak256("TransactionGasPriceError(bytes32,uint256,uint256)"))
    bytes4 internal constant TRANSACTION_GAS_PRICE_ERROR_SELECTOR = 0xa26dac09;

    // bytes4(keccak256("TransactionInvalidContextError(bytes32,address)"))
    bytes4 internal constant TRANSACTION_INVALID_CONTEXT_ERROR_SELECTOR =
        0xdec4aedf;

    // bytes4(keccak256("IncompleteFillError(uint8,uint256,uint256)"))
    bytes4 internal constant INCOMPLETE_FILL_ERROR_SELECTOR = 0x18e4b141;

    // bytes4(keccak256("BatchMatchOrdersError(uint8)"))
    bytes4 internal constant BATCH_MATCH_ORDERS_ERROR_SELECTOR = 0xd4092f4f;

    // bytes4(keccak256("PayProtocolFeeError(bytes32,uint256,address,address,bytes)"))
    bytes4 internal constant PAY_PROTOCOL_FEE_ERROR_SELECTOR = 0x87cb1e75;

    // solhint-disable func-name-mixedcase
    function SignatureErrorSelector() internal pure returns (bytes4) {
        return SIGNATURE_ERROR_SELECTOR;
    }

    function SignatureValidatorNotApprovedErrorSelector()
        internal
        pure
        returns (bytes4)
    {
        return SIGNATURE_VALIDATOR_NOT_APPROVED_ERROR_SELECTOR;
    }

    function EIP1271SignatureErrorSelector() internal pure returns (bytes4) {
        return EIP1271_SIGNATURE_ERROR_SELECTOR;
    }

    function SignatureWalletErrorSelector() internal pure returns (bytes4) {
        return SIGNATURE_WALLET_ERROR_SELECTOR;
    }

    function OrderStatusErrorSelector() internal pure returns (bytes4) {
        return ORDER_STATUS_ERROR_SELECTOR;
    }

    function ExchangeInvalidContextErrorSelector()
        internal
        pure
        returns (bytes4)
    {
        return EXCHANGE_INVALID_CONTEXT_ERROR_SELECTOR;
    }

    function FillErrorSelector() internal pure returns (bytes4) {
        return FILL_ERROR_SELECTOR;
    }

    function OrderEpochErrorSelector() internal pure returns (bytes4) {
        return ORDER_EPOCH_ERROR_SELECTOR;
    }

    function AssetProxyExistsErrorSelector() internal pure returns (bytes4) {
        return ASSET_PROXY_EXISTS_ERROR_SELECTOR;
    }

    function AssetProxyDispatchErrorSelector() internal pure returns (bytes4) {
        return ASSET_PROXY_DISPATCH_ERROR_SELECTOR;
    }

    function AssetProxyTransferErrorSelector() internal pure returns (bytes4) {
        return ASSET_PROXY_TRANSFER_ERROR_SELECTOR;
    }

    function NegativeSpreadErrorSelector() internal pure returns (bytes4) {
        return NEGATIVE_SPREAD_ERROR_SELECTOR;
    }

    function TransactionErrorSelector() internal pure returns (bytes4) {
        return TRANSACTION_ERROR_SELECTOR;
    }

    function TransactionExecutionErrorSelector()
        internal
        pure
        returns (bytes4)
    {
        return TRANSACTION_EXECUTION_ERROR_SELECTOR;
    }

    function IncompleteFillErrorSelector() internal pure returns (bytes4) {
        return INCOMPLETE_FILL_ERROR_SELECTOR;
    }

    function BatchMatchOrdersErrorSelector() internal pure returns (bytes4) {
        return BATCH_MATCH_ORDERS_ERROR_SELECTOR;
    }

    function TransactionGasPriceErrorSelector() internal pure returns (bytes4) {
        return TRANSACTION_GAS_PRICE_ERROR_SELECTOR;
    }

    function TransactionInvalidContextErrorSelector()
        internal
        pure
        returns (bytes4)
    {
        return TRANSACTION_INVALID_CONTEXT_ERROR_SELECTOR;
    }

    function PayProtocolFeeErrorSelector() internal pure returns (bytes4) {
        return PAY_PROTOCOL_FEE_ERROR_SELECTOR;
    }

    function BatchMatchOrdersError(BatchMatchOrdersErrorCodes errorCode)
        internal
        pure
        returns (bytes memory)
    {
        return
            abi.encodeWithSelector(
                BATCH_MATCH_ORDERS_ERROR_SELECTOR,
                errorCode
            );
    }

    function SignatureError(
        SignatureErrorCodes errorCode,
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                SIGNATURE_ERROR_SELECTOR,
                errorCode,
                hash,
                signerAddress,
                signature
            );
    }

    function SignatureValidatorNotApprovedError(
        address signerAddress,
        address validatorAddress
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                SIGNATURE_VALIDATOR_NOT_APPROVED_ERROR_SELECTOR,
                signerAddress,
                validatorAddress
            );
    }

    function EIP1271SignatureError(
        address verifyingContractAddress,
        bytes memory data,
        bytes memory signature,
        bytes memory errorData
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                EIP1271_SIGNATURE_ERROR_SELECTOR,
                verifyingContractAddress,
                data,
                signature,
                errorData
            );
    }

    function SignatureWalletError(
        bytes32 hash,
        address walletAddress,
        bytes memory signature,
        bytes memory errorData
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                SIGNATURE_WALLET_ERROR_SELECTOR,
                hash,
                walletAddress,
                signature,
                errorData
            );
    }

    function OrderStatusError(
        bytes32 orderHash,
        LibOrder.OrderStatus orderStatus
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                ORDER_STATUS_ERROR_SELECTOR,
                orderHash,
                orderStatus
            );
    }

    function ExchangeInvalidContextError(
        ExchangeContextErrorCodes errorCode,
        bytes32 orderHash,
        address contextAddress
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                EXCHANGE_INVALID_CONTEXT_ERROR_SELECTOR,
                errorCode,
                orderHash,
                contextAddress
            );
    }

    function FillError(FillErrorCodes errorCode, bytes32 orderHash)
        internal
        pure
        returns (bytes memory)
    {
        return
            abi.encodeWithSelector(FILL_ERROR_SELECTOR, errorCode, orderHash);
    }

    function OrderEpochError(
        address makerAddress,
        address orderSenderAddress,
        uint256 currentEpoch
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                ORDER_EPOCH_ERROR_SELECTOR,
                makerAddress,
                orderSenderAddress,
                currentEpoch
            );
    }

    function AssetProxyExistsError(
        bytes4 assetProxyId,
        address assetProxyAddress
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                ASSET_PROXY_EXISTS_ERROR_SELECTOR,
                assetProxyId,
                assetProxyAddress
            );
    }

    function AssetProxyDispatchError(
        AssetProxyDispatchErrorCodes errorCode,
        bytes32 orderHash,
        bytes memory assetData
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                ASSET_PROXY_DISPATCH_ERROR_SELECTOR,
                errorCode,
                orderHash,
                assetData
            );
    }

    function AssetProxyTransferError(
        bytes32 orderHash,
        bytes memory assetData,
        bytes memory errorData
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                ASSET_PROXY_TRANSFER_ERROR_SELECTOR,
                orderHash,
                assetData,
                errorData
            );
    }

    function NegativeSpreadError(bytes32 leftOrderHash, bytes32 rightOrderHash)
        internal
        pure
        returns (bytes memory)
    {
        return
            abi.encodeWithSelector(
                NEGATIVE_SPREAD_ERROR_SELECTOR,
                leftOrderHash,
                rightOrderHash
            );
    }

    function TransactionError(
        TransactionErrorCodes errorCode,
        bytes32 transactionHash
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                TRANSACTION_ERROR_SELECTOR,
                errorCode,
                transactionHash
            );
    }

    function TransactionExecutionError(
        bytes32 transactionHash,
        bytes memory errorData
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                TRANSACTION_EXECUTION_ERROR_SELECTOR,
                transactionHash,
                errorData
            );
    }

    function TransactionGasPriceError(
        bytes32 transactionHash,
        uint256 actualGasPrice,
        uint256 requiredGasPrice
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                TRANSACTION_GAS_PRICE_ERROR_SELECTOR,
                transactionHash,
                actualGasPrice,
                requiredGasPrice
            );
    }

    function TransactionInvalidContextError(
        bytes32 transactionHash,
        address currentContextAddress
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                TRANSACTION_INVALID_CONTEXT_ERROR_SELECTOR,
                transactionHash,
                currentContextAddress
            );
    }

    function IncompleteFillError(
        IncompleteFillErrorCode errorCode,
        uint256 expectedAssetFillAmount,
        uint256 actualAssetFillAmount
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                INCOMPLETE_FILL_ERROR_SELECTOR,
                errorCode,
                expectedAssetFillAmount,
                actualAssetFillAmount
            );
    }

    function PayProtocolFeeError(
        bytes32 orderHash,
        uint256 protocolFee,
        address makerAddress,
        address takerAddress,
        bytes memory errorData
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                PAY_PROTOCOL_FEE_ERROR_SELECTOR,
                orderHash,
                protocolFee,
                makerAddress,
                takerAddress,
                errorData
            );
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import "./LibBytes.sol";

import "./LibEIP712.sol";

library LibOrder {
    using LibOrder for Order;

    // Hash for the EIP712 Order Schema:
    // keccak256(abi.encodePacked(
    //     "Order(",
    //     "address makerAddress,",
    //     "address takerAddress,",
    //     "address feeRecipientAddress,",
    //     "address senderAddress,",
    //     "uint256 makerAssetAmount,",
    //     "uint256 takerAssetAmount,",
    //     "uint256 makerFee,",
    //     "uint256 takerFee,",
    //     "uint256 expirationTimeSeconds,",
    //     "uint256 salt,",
    //     "bytes makerAssetData,",
    //     "bytes takerAssetData,",
    //     "bytes makerFeeAssetData,",
    //     "bytes takerFeeAssetData",
    //     ")"
    // ))
    bytes32 internal constant ORDER_DATA_SCHEMA_HASH =
        keccak256(
            "OrderData(address maker,address taker,uint256 mAmount,uint256 tAmount,uint256 mFee,uint256 tFee,bytes mAssetData,bytes tAssetData,bytes mfAssetData,bytes tfAssetData,Extras[] others)Extras(address aRecipient,uint256 amount)"
        );
    bytes32 internal constant ADDITIONAL_RECIPIENT_SCHEMA_HASH =
        keccak256("Extras(address aRecipient,uint256 amount)");
    bytes32 internal constant _EIP712_ORDER_SCHEMA_HASH =
        keccak256(
            "Order(address feeRecipient,address aSender,uint256 expired,uint256 salt,bool isNative,uint16 orderType,uint16 itemType,OrderData oData)Extras(address aRecipient,uint256 amount)OrderData(address maker,address taker,uint256 mAmount,uint256 tAmount,uint256 mFee,uint256 tFee,bytes mAssetData,bytes tAssetData,bytes mfAssetData,bytes tfAssetData,Extras[] others)"
        );

    // A valid order remains fillable until it is expired, fully filled, or cancelled.
    // An order's status is unaffected by external factors, like account balances.
    enum OrderStatus {
        INVALID, // Default value
        INVALID_MAKER_ASSET_AMOUNT, // Order does not have a valid maker asset amount
        INVALID_TAKER_ASSET_AMOUNT, // Order does not have a valid taker asset amount
        FILLABLE, // Order is fillable
        EXPIRED, // Order has already expired
        FULLY_FILLED, // Order is fully filled
        CANCELLED // Order has been cancelled
    }

    enum ItemType {
        ERC721,
        ERC1155
    }

    enum OrderType {
        BASIC,
        BID,
        EVENT
    }

    // solhint-disable max-line-length
    // @dev Canonical order structure.
    struct Order {
        address feeRecipient;
        address aSender; // Address that is allowed to call Exchange contract methods that affect this order. If set to 0, any address is allowed to call these methods.
        uint256 expired; // Timestamp in seconds at which order expires.
        uint256 salt; // Arbitrary number to facilitate uniqueness of the order's hash.
        bool isNative; // native or erc20
        OrderType orderType; // 0: Basic, 1: Bid
        ItemType itemType; //0: erc721, 1:erc1155
        OrderData oData;
    }

    struct Extras {
        address payable aRecipient;
        uint256 amount;
    }

    struct OrderData {
        address maker; // Address that created the order.
        address taker; // Address that is allowed to fill the order. If set to 0, any address is allowed to fill the order.
        uint256 mAmount; // Amount of makerAsset being offered by maker. Must be greater than 0.
        uint256 tAmount; // Amount of takerAsset being bid on by maker. Must be greater than 0.
        uint256 mFee; // Fee paid to feeRecipient by maker when order is filled.
        uint256 tFee; // Fee paid to feeRecipient by taker when order is filled.
        bytes mAssetData; // Encoded data that can be decoded by a specified proxy contract when transferring makerAsset. The leading bytes4 references the id of the asset proxy.
        bytes tAssetData; // Encoded data that can be decoded by a specified proxy contract when transferring takerAsset. The leading bytes4 references the id of the asset proxy.
        bytes mfAssetData; // Encoded data that can be decoded by a specified proxy contract when transferring makerFeeAsset. The leading bytes4 references the id of the asset proxy.
        bytes tfAssetData;
        Extras[] others;
    }
    // @dev Order information returned by `getOrderInfo()`.
    struct OrderInfo {
        OrderStatus orderStatus; // Status that describes order's validity and fillability.
        bytes32 orderHash; // EIP712 typed data hash of the order (see LibOrder.getTypedDataHash).
        uint256 orderTakerAssetFilledAmount; // Amount of order that has already been filled.
    }

    // @dev Calculates the EIP712 typed data hash of an order with a given domain separator.
    // @param order The order structure.
    // @return EIP712 typed data hash of the order.
    function getTypedDataHash(
        Order memory order,
        bytes32 eip712ExchangeDomainHash
    ) internal pure returns (bytes32 orderHash) {
        orderHash = LibEIP712.hashEIP712Message(
            eip712ExchangeDomainHash,
            getStructHash(order)
        );
        return orderHash;
    }

    function hashRecipients(Extras[] memory others)
        internal
        pure
        returns (bytes32)
    {
        bytes32[] memory arrayExtra = new bytes32[](others.length);
        for (uint256 i = 0; i < others.length; ++i) {
            arrayExtra[i] = keccak256(
                abi.encode(
                    ADDITIONAL_RECIPIENT_SCHEMA_HASH,
                    others[i].aRecipient,
                    others[i].amount
                )
            );
        }
        return keccak256(abi.encodePacked(arrayExtra));
    }

    function hashOrderData(OrderData memory orderData)
        internal
        pure
        returns (bytes32 result)
    {
        return
            keccak256(
                abi.encode(
                    ORDER_DATA_SCHEMA_HASH,
                    orderData.maker,
                    orderData.taker,
                    orderData.mAmount,
                    orderData.tAmount,
                    orderData.mFee,
                    orderData.tFee,
                    keccak256(orderData.mAssetData),
                    keccak256(orderData.tAssetData),
                    keccak256(orderData.mfAssetData),
                    keccak256(orderData.tfAssetData),
                    hashRecipients(orderData.others)
                )
            );
    }

    // @dev Calculates EIP712 hash of the order struct.
    // @param order The order structure.
    // @return EIP712 hash of the order struct.
    function getStructHash(Order memory order)
        internal
        pure
        returns (bytes32 result)
    {
        bytes32 schemaHash = _EIP712_ORDER_SCHEMA_HASH;
        bytes32 hashedOrderData = hashOrderData(order.oData);
        //     keccak256(
        //         abi.encode(
        //             _EIP712_ORDER_SCHEMA_HASH,
        //             order.feeRecipient,
        //             order.aSender,
        //             order.expired,
        //             order.salt,
        //             order.orderType,
        //             order.itemType,
        //             hashOrderData(order.oData)
        //         )
        //     );
        assembly {
            // Assert order offset (this is an internal error that should never be triggered)
            if lt(order, 32) {
                invalid()
            }

            // Calculate memory addresses that will be swapped out before hashing
            let pos1 := sub(order, 32)
            let pos2 := add(order, 224)

            // Backup
            let temp1 := mload(pos1)
            let temp2 := mload(pos2)

            // Hash in place
            mstore(pos1, schemaHash)
            mstore(pos2, hashedOrderData)

            result := keccak256(pos1, 288)

            // Restore
            mstore(pos1, temp1)
            mstore(pos2, temp2)
        }
        return result;
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import "./LibSafeMath.sol";
import "./LibOrder.sol";
import "./LibMath.sol";

library LibFillResults {
    using LibSafeMath for uint256;
    struct FillResults {
        uint256 makerAssetFilledAmount; // Total amount of makerAsset(s) filled.
        uint256 takerAssetFilledAmount; // Total amount of takerAsset(s) filled.
        uint256 makerFeePaid; // Total amount of fees paid by maker(s) to feeRecipient(s).
        uint256 takerFeePaid; // Total amount of fees paid by taker to feeRecipients(s).
        uint256 protocolFeePaid; // Total amount of fees paid by taker to the staking contract.
    }

    // @dev Calculates amounts filled and fees paid by maker and taker.
    // @param order to be filled.
    // @param takerAssetFilledAmount Amount of takerAsset that will be filled.
    // @param protocolFeeMultiplier The current protocol fee of the exchange contract.
    // @param gasPrice The gasprice of the transaction. This is provided so that the function call can continue
    //        to be pure rather than view.
    // @return fillResults Amounts filled and fees paid by maker and taker.
    function calculateFillResults(
        LibOrder.Order memory order,
        uint256 takerAssetFilledAmount,
        uint256 protocolFeeMultiplier,
        uint256 gasPrice
    ) internal pure returns (FillResults memory fillResults) {
        // Compute proportional transfer amounts

        fillResults.takerAssetFilledAmount = takerAssetFilledAmount;

        for (uint256 i = 0; i < order.oData.others.length; ++i) {
            fillResults.takerAssetFilledAmount = fillResults
                .takerAssetFilledAmount
                .safeSub(order.oData.others[i].amount);
        }

        fillResults.makerAssetFilledAmount = order.oData.mAmount;
        fillResults.makerFeePaid = order.oData.mFee;
        fillResults.takerFeePaid = order.oData.tFee;

        // Compute the protocol fee that should be paid for a single fill.
        fillResults.protocolFeePaid = gasPrice.safeMul(protocolFeeMultiplier);

        return fillResults;
    }

    function assertNonZeroAmount(uint256 amount) internal pure {
        // Revert if the supplied amount is equal to zero.
        if (amount == 0) {
            revert("LFR_ZERO_AMOUNT");
        }
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import "./LibRichErrors.sol";
import "./LibSafeMathRichErrors.sol";

library LibSafeMath {
    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        if (c / a != b) {
            revert("SM_MULTIPLICATION_OVERFLOW");
        }
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            revert("SD_DIVISION_BY_ZERO");
        }
        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b > a) {
            revert("SS_SUBTRACTION_UNDERFLOW");
        }
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        if (c < a) {
            revert("SA_ADDITION_OVERFLOW");
        }
        return c;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import "../libs/LibOrder.sol";
import "../libs/LibExchangeRichErrors.sol";
import "../libs//LibBytes.sol";
import "../interface/IWallet.sol";

contract SignatureValidator {
    // Allowed signature types.
    using LibBytes for bytes;
    enum SignatureType {
        Illegal, // 0x00, default value
        Invalid, // 0x01
        EIP712, // 0x02
        EthSign, // 0x03
        Wallet, // 0x04
        Validator, // 0x05
        PreSigned, // 0x06
        EIP1271Wallet, // 0x07
        NSignatureTypes // 0x08, number of signature types. Always leave at end.
    }

    mapping(address => mapping(address => bool)) public allowedValidators;
    mapping(bytes32 => mapping(address => bool)) public preSigned;
    bytes4 private constant LEGACY_WALLET_MAGIC_VALUE = 0xb0671381;

    function _validateOrderEIP712(
        LibOrder.Order memory order,
        bytes32 orderHash,
        bytes memory signature
    ) internal pure returns (bool isValid) {
        address signerAddress = order.oData.maker;
        if (signature.length != 65) {
            revert("VHST:SIGNATURE_ERROR_SELECTOR_INVALID_LENGTH_EIP712");
        }
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
        address recovered = ecrecover(orderHash, v, r, s);
        isValid = signerAddress == recovered;
        return isValid;
    }

    function _isValidOrderWithHashSignature(
        LibOrder.Order memory order,
        bytes32 orderHash,
        bytes memory signature
    ) internal view returns (bool isValid) {
        address signerAddress = order.oData.maker;
        SignatureType signatureType = _readValidSignatureType(
            signerAddress,
            signature
        );

        // Otherwise, it's one of the hash-only signature types.
        isValid = _validateHashSignatureTypes(
            signatureType,
            orderHash,
            signerAddress,
            signature
        );

        return isValid;
    }

    // @dev Reads the `SignatureType` from the end of a signature and validates it.
    function _readValidSignatureType(
        address signerAddress,
        bytes memory signature
    ) private pure returns (SignatureType signatureType) {
        // Read the signatureType from the signature
        signatureType = _readSignatureType(signature);

        // Disallow address zero because ecrecover() returns zero on failure.
        if (signerAddress == address(0)) {
            revert("RVST:INVALID_SIGNER");
        }

        // Ensure signature is supported
        if (uint8(signatureType) >= uint8(SignatureType.NSignatureTypes)) {
            revert("RVST:SIGNATURE_ERROR_SELECTOR_UNSUPPORTED");
        }

        // Always illegal signature.
        // This is always an implicit option since a signer can create a
        // signature array with invalid type or length. We may as well make
        // it an explicit option. This aids testing and analysis. It is
        // also the initialization value for the enum type.
        if (signatureType == SignatureType.Illegal) {
            revert("RVST:SIGNATURE_ERROR_SELECTOR_ILLEGAL");
        }

        return signatureType;
    }

    // @dev Reads the `SignatureType` from a signature with minimal validation.
    function _readSignatureType(bytes memory signature)
        private
        pure
        returns (SignatureType)
    {
        if (signature.length == 0) {
            revert("RST:SIGNATURE_ERROR_SELECTOR_INVALID_LENGTH");
        }
        return SignatureType(uint8(signature[signature.length - 1]));
    }

    // Validates a hash-only signature type
    // (anything but `Validator` and `EIP1271Wallet`).
    function _validateHashSignatureTypes(
        SignatureType signatureType,
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    ) private view returns (bool isValid) {
        // Always invalid signature.
        // Like Illegal, this is always implicitly available and therefore
        // offered explicitly. It can be implicitly created by providing
        // a correctly formatted but incorrect signature.
        if (signatureType == SignatureType.Invalid) {
            if (signature.length != 1) {
                revert("VHST:SIGNATURE_ERROR_SELECTOR_INVALID_LENGTH");
            }
            isValid = false;

            // Signature using EIP712
        } else if (signatureType == SignatureType.EIP712) {
            if (signature.length != 66) {
                revert("VHST:SIGNATURE_ERROR_SELECTOR_INVALID_LENGTH_EIP712");
            }
            uint8 v = uint8(signature[0]);
            bytes32 r = signature.readBytes32(1);
            bytes32 s = signature.readBytes32(33);
            address recovered = ecrecover(hash, v, r, s);
            isValid = signerAddress == recovered;
            // Signed using web3.eth_sign
        } else if (signatureType == SignatureType.EthSign) {
            if (signature.length != 66) {
                revert("VHST:SIGNATURE_ERROR_SELECTOR_INVALID_LENGTH_ETHSIGN");
            }
            uint8 v = uint8(signature[0]);
            bytes32 r = signature.readBytes32(1);
            bytes32 s = signature.readBytes32(33);
            address recovered = ecrecover(
                keccak256(
                    abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
                ),
                v,
                r,
                s
            );

            isValid = signerAddress == recovered;

            // Signature verified by wallet contract.
        } else if (signatureType == SignatureType.Wallet) {
            isValid = _validateHashWithWallet(hash, signerAddress, signature);

            // Otherwise, signatureType == SignatureType.PreSigned
        } else {
            assert(signatureType == SignatureType.PreSigned);
            // Signer signed hash previously using the preSign function.
            isValid = preSigned[hash][signerAddress];
        }
        return isValid;
    }

    // @dev Verifies a hash and signature using logic defined by Wallet contract.
    // @param hash Any 32 byte hash.
    // @param walletAddress Address that should have signed the given hash
    //                      and defines its own signature verification method.
    // @param signature Proof that the hash has been signed by signer.
    // @return True if the signature is validated by the Wallet.
    function _validateHashWithWallet(
        bytes32 hash,
        address walletAddress,
        bytes memory signature
    ) private view returns (bool) {
        // Backup length of signature
        uint256 signatureLength = signature.length;
        // Temporarily remove signatureType byte from end of signature
        signature.writeLength(signatureLength - 1);
        // Encode the call data.
        bytes memory callData = abi.encodeWithSelector(
            IWallet(address(0)).isValidSignature.selector,
            hash,
            signature
        );
        // Restore the original signature length
        signature.writeLength(signatureLength);
        // Static call the verification function.
        (bool didSucceed, bytes memory returnData) = walletAddress.staticcall(
            callData
        );
        // Return the validity of the signature if the call was successful
        if (didSucceed && returnData.length == 32) {
            return returnData.readBytes4(0) == LEGACY_WALLET_MAGIC_VALUE;
        }
        revert("VHWW:SIGNATURE_ERROR_SELECTOR");
        // Revert if the call was unsuccessful
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../libs/LibBytes.sol";
import "../interface/IAssetProxy.sol";
import "../interface/IAssetProxyDispatcher.sol";
import "../interface/IAssetData.sol";

contract AssetProxyDispatcher is Ownable, IAssetProxyDispatcher {
    using LibBytes for bytes;
    using SafeERC20 for IERC20;
    // Mapping from Asset Proxy Id's to their respective Asset Proxy
    mapping(bytes4 => address) internal _assetProxies;

    // @dev Registers an asset proxy to its asset proxy id.
    //      Once an asset proxy is registered, it cannot be unregistered.
    // @param assetProxy Address of new asset proxy to register.
    function registerAssetProxy(address assetProxy) external onlyOwner {
        // Ensure that no asset proxy exists with current id.

        bytes4 assetProxyId = IAssetProxy(assetProxy).getProxyId();
        // console.log("assetProxyId");
        // console.logBytes4(assetProxyId);
        address currentAssetProxy = _assetProxies[assetProxyId];
        if (currentAssetProxy != address(0)) {
            revert("ASSET_PROXY_EXISTS_ERROR_SELECTOR");
        }

        // Add asset proxy and log registration.
        _assetProxies[assetProxyId] = assetProxy;
        emit AssetProxyRegistered(assetProxyId, assetProxy);
    }

    // @dev Gets an asset proxy.
    // @param assetProxyId Id of the asset proxy.
    // @return assetProxy The asset proxy address registered to assetProxyId. Returns 0x0 if no proxy is registered.
    function getAssetProxy(bytes4 assetProxyId)
        external
        view
        returns (address assetProxy)
    {
        return _assetProxies[assetProxyId];
    }

    // @dev Forwards arguments to assetProxy and calls `transferFrom`. Either succeeds or throws.
    // @param orderHash Hash of the order associated with this transfer.
    // @param assetData Byte array encoded for the asset.
    // @param from Address to transfer token from.
    // @param to Address to transfer token to.
    // @param amount Amount of token to transfer.
    function _dispatchTransferFrom(
        bytes memory assetData,
        address from,
        address to,
        uint256 amount
    ) internal {
        // Do nothing if no amount should be transferred.
        if (amount > 0) {
            // Ensure assetData is padded to 32 bytes (excluding the id) and is at least 4 bytes long
            if (assetData.length % 32 != 4) {
                revert("DTF:INVALID_ASSET_DATA_LENGTH");
            }

            // Lookup assetProxy.
            bytes4 assetProxyId = assetData.readBytes4(0);
            address assetProxy = _assetProxies[assetProxyId];
            // Ensure that assetProxy exists
            if (assetProxy == address(0)) {
                revert("DTF:UNKNOWN_ASSET_PROXY");
            }

            IAssetProxy(assetProxy).transferFrom(assetData, from, to, amount);
        }
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../libs/LibRichErrors.sol";
import "../libs/LibExchangeRichErrors.sol";
import "../interface/IProtocolFees.sol";
import "../interface/IStaking.sol";

contract ProtocolFees is IProtocolFees, Ownable {
    // @dev The protocol fee multiplier -- the owner can update this field.
    // @return 0 Gas multplier.
    uint256 public protocolFeeMultiplier;

    // @dev The address of the registered protocolFeeCollector contract -- the owner can update this field.
    // @return 0 Contract to forward protocol fees to.
    address public protocolFeeCollector;

    // @dev Allows the owner to update the protocol fee multiplier.
    // @param updatedProtocolFeeMultiplier The updated protocol fee multiplier.
    function setProtocolFeeMultiplier(uint256 updatedProtocolFeeMultiplier)
        external
        onlyOwner
    {
        emit ProtocolFeeMultiplier(
            protocolFeeMultiplier,
            updatedProtocolFeeMultiplier
        );
        protocolFeeMultiplier = updatedProtocolFeeMultiplier;
    }

    // @dev Allows the owner to update the protocolFeeCollector address.
    // @param updatedProtocolFeeCollector The updated protocolFeeCollector contract address.
    function setProtocolFeeCollectorAddress(address updatedProtocolFeeCollector)
        external
        onlyOwner
    {
        _setProtocolFeeCollectorAddress(updatedProtocolFeeCollector);
    }

    // @dev Sets the protocolFeeCollector contract address to 0.
    //      Only callable by owner.
    function detachProtocolFeeCollector() external onlyOwner {
        _setProtocolFeeCollectorAddress(address(0));
    }

    // @dev Sets the protocolFeeCollector address and emits an event.
    // @param updatedProtocolFeeCollector The updated protocolFeeCollector contract address.
    function _setProtocolFeeCollectorAddress(
        address updatedProtocolFeeCollector
    ) internal {
        emit ProtocolFeeCollectorAddress(
            protocolFeeCollector,
            updatedProtocolFeeCollector
        );
        protocolFeeCollector = updatedProtocolFeeCollector;
    }

    // @dev Pays a protocol fee for a single fill.
    // @param orderHash Hash of the order being filled.
    // @param protocolFee Value of the fee being paid (equal to protocolFeeMultiplier * tx.gasPrice).
    // @param makerAddress Address of maker of order being filled.
    // @param takerAddress Address filling order.
    function _paySingleProtocolFee(
        uint256 protocolFee,
        address makerAddress,
        address takerAddress
    ) internal returns (bool) {
        address feeCollector = protocolFeeCollector;
        if (feeCollector != address(0)) {
            _payProtocolFeeToFeeCollector(
                feeCollector,
                address(this).balance,
                protocolFee,
                makerAddress,
                takerAddress
            );
            return true;
        } else {
            return false;
        }
    }

    // @dev Pays a protocol fee for two orders (used when settling functions in MixinMatchOrders)
    // @param orderHash1 Hash of the first order being filled.
    // @param orderHash2 Hash of the second order being filled.
    // @param protocolFee Value of the fee being paid (equal to protocolFeeMultiplier * tx.gasPrice).
    // @param makerAddress1 Address of maker of first order being filled.
    // @param makerAddress2 Address of maker of second order being filled.
    // @param takerAddress Address filling orders.
    function _payTwoProtocolFees(
        uint256 protocolFee,
        address makerAddress1,
        address makerAddress2,
        address takerAddress
    ) internal returns (bool) {
        address feeCollector = protocolFeeCollector;
        if (feeCollector != address(0)) {
            // Since the `BALANCE` opcode costs 400 gas, we choose to calculate this value by hand rather than calling it twice.
            uint256 exchangeBalance = address(this).balance;

            // Pay protocol fee and attribute to first maker
            uint256 valuePaid = _payProtocolFeeToFeeCollector(
                feeCollector,
                exchangeBalance,
                protocolFee,
                makerAddress1,
                takerAddress
            );

            // Pay protocol fee and attribute to second maker
            _payProtocolFeeToFeeCollector(
                feeCollector,
                exchangeBalance - valuePaid,
                protocolFee,
                makerAddress2,
                takerAddress
            );
            return true;
        } else {
            return false;
        }
    }

    // @dev Pays a single protocol fee.
    // @param orderHash Hash of the order being filled.
    // @param feeCollector Address of protocolFeeCollector contract.
    // @param exchangeBalance Assumed ETH balance of Exchange contract (in wei).
    // @param protocolFee Value of the fee being paid (equal to protocolFeeMultiplier * tx.gasPrice).
    // @param makerAddress Address of maker of order being filled.
    // @param takerAddress Address filling order.
    function _payProtocolFeeToFeeCollector(
        address feeCollector,
        uint256 exchangeBalance,
        uint256 protocolFee,
        address makerAddress,
        address takerAddress
    ) internal returns (uint256 valuePaid) {
        // Do not send a value with the call if the exchange has an insufficient balance
        // The protocolFeeCollector contract will fallback to charging WETH
        if (exchangeBalance >= protocolFee) {
            valuePaid = protocolFee;
        }
        bytes memory payProtocolFeeData = abi.encodeWithSelector(
            IStaking(address(0)).payProtocolFee.selector,
            makerAddress,
            takerAddress,
            protocolFee
        );
        // solhint-disable-next-line avoid-call-value
        (bool didSucceed, ) = feeCollector.call{value: valuePaid}(
            payProtocolFeeData
        );
        if (!didSucceed) {
            revert("PFTF:PAY_PROTOCOL_FEE_ERROR_SELECTOR");
        }
        return valuePaid;
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

library LibRichErrors {
    // bytes4(keccak256("Error(string)"))
    bytes4 internal constant STANDARD_ERROR_SELECTOR = 0x08c379a0;

    uint256 internal constant AlmostOneWord = 0x1f;
    uint256 internal constant OneWord = 0x20;
    uint256 internal constant FreeMemoryPointerSlot = 0x40;
    uint256 internal constant CostPerWord = 3;
    uint256 internal constant MemoryExpansionCoefficient = 0x200; // 512
    uint256 internal constant ExtraGasBuffer = 0x20;

    // solhint-disable func-name-mixedcase
    // @dev ABI encode a standard, string revert error payload.
    //      This is the same payload that would be included by a `revert(string)`
    //      solidity statement. It has the function signature `Error(string)`.
    // @param message The error string.
    // @return The ABI encoded error.
    function StandardError(string memory message)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(STANDARD_ERROR_SELECTOR, bytes(message));
    }

    // solhint-enable func-name-mixedcase

    // @dev Reverts an encoded rich revert reason `errorData`.
    // @param errorData ABI encoded error data.
    function rrevert(bytes memory errorData) internal pure {
        assembly {
            revert(add(errorData, 0x20), mload(errorData))
        }
    }

    function revertWithReasonIfOneIsReturned() internal view {
        assembly {
            // If it returned a message, bubble it up as long as sufficient gas
            // remains to do so:
            if returndatasize() {
                // Ensure that sufficient gas is available to copy returndata
                // while expanding memory where necessary. Start by computing
                // the word size of returndata and allocated memory.
                let returnDataWords := div(
                    add(returndatasize(), AlmostOneWord),
                    OneWord
                )

                // Note: use the free memory pointer in place of msize() to work
                // around a Yul warning that prevents accessing msize directly
                // when the IR pipeline is activated.
                let msizeWords := div(mload(FreeMemoryPointerSlot), OneWord)

                // Next, compute the cost of the returndatacopy.
                let cost := mul(CostPerWord, returnDataWords)

                // Then, compute cost of new memory allocation.
                if gt(returnDataWords, msizeWords) {
                    cost := add(
                        cost,
                        add(
                            mul(sub(returnDataWords, msizeWords), CostPerWord),
                            div(
                                sub(
                                    mul(returnDataWords, returnDataWords),
                                    mul(msizeWords, msizeWords)
                                ),
                                MemoryExpansionCoefficient
                            )
                        )
                    )
                }

                // Finally, add a small constant and compare to gas remaining;
                // bubble up the revert data if enough gas is still available.
                if lt(add(cost, ExtraGasBuffer), gas()) {
                    // Copy returndata to memory; overwrite existing memory.
                    returndatacopy(0, 0, returndatasize())

                    // Revert, specifying memory region with copied returndata.
                    revert(0, returndatasize())
                }
            }
        }
    }
}

// SPDX-License-Identifier: MIT
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

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

library LibEIP712 {
    // Hash of the EIP712 Domain Separator Schema
    // keccak256(abi.encodePacked(
    //     "EIP712Domain(",
    //     "string name,",
    //     "string version,",
    //     "uint256 chainId,",
    //     "address verifyingContract",
    //     ")"
    // ))
    bytes32 internal constant _EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH =
        0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    // @dev Calculates a EIP712 domain separator.
    // @param name The EIP712 domain name.
    // @param version The EIP712 domain version.
    // @param verifyingContract The EIP712 verifying contract.
    // @return EIP712 domain separator.
    function hashEIP712Domain(
        string memory name,
        string memory version,
        uint256 chainId,
        address verifyingContract
    ) internal pure returns (bytes32 result) {
        result = keccak256(
            abi.encode(
                _EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH,
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                chainId,
                verifyingContract
            )
        );
    }

    // @dev Calculates EIP712 encoding for a hash struct with a given domain hash.
    // @param eip712DomainHash Hash of the domain domain separator data, computed
    //                         with getDomainHash().
    // @param hashStruct The EIP712 hash struct.
    // @return EIP712 hash applied to the given EIP712 Domain.
    function hashEIP712Message(bytes32 eip712DomainHash, bytes32 hashStruct)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19\x01", eip712DomainHash, hashStruct)
            );
        // Assembly for more efficient computing:
        // keccak256(abi.encodePacked(
        //     EIP191_HEADER,
        //     EIP712_DOMAIN_HASH,
        //     hashStruct
        // ));

        // assembly {
        //     // Load free memory pointer
        //     let memPtr := mload(64)

        //     mstore(
        //         memPtr,
        //         0x1901000000000000000000000000000000000000000000000000000000000000
        //     ) // EIP191 header
        //     mstore(add(memPtr, 2), eip712DomainHash) // EIP712 domain hash
        //     mstore(add(memPtr, 34), hashStruct) // Hash of struct

        //     // Compute hash
        //     result := keccak256(memPtr, 66)
        // }
        // return result;
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "./LibBytesRichErrors.sol";
import "./LibRichErrors.sol";

library LibBytes {
    using LibBytes for bytes;

    // @dev Gets the memory address for a byte array.
    // @param input Byte array to lookup.
    // @return memoryAddress Memory address of byte array. This
    //         points to the header of the byte array which contains
    //         the length.
    function rawAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := input
        }
        return memoryAddress;
    }

    // @dev Gets the memory address for the contents of a byte array.
    // @param input Byte array to lookup.
    // @return memoryAddress Memory address of the contents of the byte array.
    function contentAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := add(input, 32)
        }
        return memoryAddress;
    }

    // @dev Copies `length` bytes from memory location `source` to `dest`.
    // @param dest memory address to copy bytes to.
    // @param source memory address to copy bytes from.
    // @param length number of bytes to copy.
    function memCopy(
        uint256 dest,
        uint256 source,
        uint256 length
    ) internal pure {
        if (length < 32) {
            // Handle a partial word by reading destination and masking
            // off the bits we are interested in.
            // This correctly handles overlap, zero lengths and source == dest
            assembly {
                let mask := sub(exp(256, sub(32, length)), 1)
                let s := and(mload(source), not(mask))
                let d := and(mload(dest), mask)
                mstore(dest, or(s, d))
            }
        } else {
            // Skip the O(length) loop when source == dest.
            if (source == dest) {
                return;
            }

            // For large copies we copy whole words at a time. The final
            // word is aligned to the end of the range (instead of after the
            // previous) to handle partial words. So a copy will look like this:
            //
            //  ####
            //      ####
            //          ####
            //            ####
            //
            // We handle overlap in the source and destination range by
            // changing the copying direction. This prevents us from
            // overwriting parts of source that we still need to copy.
            //
            // This correctly handles source == dest
            //
            if (source > dest) {
                assembly {
                    // We subtract 32 from `sEnd` and `dEnd` because it
                    // is easier to compare with in the loop, and these
                    // are also the addresses we need for copying the
                    // last bytes.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    // Remember the last 32 bytes of source
                    // This needs to be done here and not after the loop
                    // because we may have overwritten the last bytes in
                    // source already due to overlap.
                    let last := mload(sEnd)

                    // Copy whole words front to back
                    // Note: the first check is always true,
                    // this could have been a do-while loop.
                    // solhint-disable-next-line no-empty-blocks
                    for {

                    } lt(source, sEnd) {

                    } {
                        mstore(dest, mload(source))
                        source := add(source, 32)
                        dest := add(dest, 32)
                    }

                    // Write the last 32 bytes
                    mstore(dEnd, last)
                }
            } else {
                assembly {
                    // We subtract 32 from `sEnd` and `dEnd` because those
                    // are the starting points when copying a word at the end.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    // Remember the first 32 bytes of source
                    // This needs to be done here and not after the loop
                    // because we may have overwritten the first bytes in
                    // source already due to overlap.
                    let first := mload(source)

                    // Copy whole words back to front
                    // We use a signed comparisson here to allow dEnd to become
                    // negative (happens when source and dest < 32). Valid
                    // addresses in local memory will never be larger than
                    // 2**255, so they can be safely re-interpreted as signed.
                    // Note: the first check is always true,
                    // this could have been a do-while loop.
                    // solhint-disable-next-line no-empty-blocks
                    for {

                    } slt(dest, dEnd) {

                    } {
                        mstore(dEnd, mload(sEnd))
                        sEnd := sub(sEnd, 32)
                        dEnd := sub(dEnd, 32)
                    }

                    // Write the first 32 bytes
                    mstore(dest, first)
                }
            }
        }
    }

    // @dev Returns a slices from a byte array.
    // @param b The byte array to take a slice from.
    // @param from The starting index for the slice (inclusive).
    // @param to The final index for the slice (exclusive).
    // @return result The slice containing bytes at indices [from, to)
    function slice(
        bytes memory b,
        uint256 from,
        uint256 to
    ) internal pure returns (bytes memory result) {
        // Ensure that the from and to positions are valid positions for a slice within
        // the byte array that is being used.
        if (from > to) {
            revert("SLICE:FROM_GRT_TO");
        }
        if (to > b.length) {
            revert("SLICE:TO_GRT_B_LENTH");
        }

        // Create a new bytes structure and copy contents
        result = new bytes(to - from);
        memCopy(
            result.contentAddress(),
            b.contentAddress() + from,
            result.length
        );
        return result;
    }

    // @dev Returns a slice from a byte array without preserving the input.
    // @param b The byte array to take a slice from. Will be destroyed in the process.
    // @param from The starting index for the slice (inclusive).
    // @param to The final index for the slice (exclusive).
    // @return result The slice containing bytes at indices [from, to)
    // @dev When `from == 0`, the original array will match the slice. In other cases its state will be corrupted.
    function sliceDestructive(
        bytes memory b,
        uint256 from,
        uint256 to
    ) internal pure returns (bytes memory result) {
        // Ensure that the from and to positions are valid positions for a slice within
        // the byte array that is being used.
        if (from > to) {
            revert("SLICED_FROM_GT_TO");
        }
        if (to > b.length) {
            revert("SLICED_TO_GT_B_LENGTH");
        }

        // Create a new bytes structure around [from, to) in-place.
        assembly {
            result := add(b, from)
            mstore(result, sub(to, from))
        }
        return result;
    }

    // @dev Pops the last byte off of a byte array by modifying its length.
    // @param b Byte array that will be modified.
    // @return The byte that was popped off.
    function popLastByte(bytes memory b) internal pure returns (bytes1 result) {
        if (b.length == 0) {
            revert("PLB_B_LENGTH_IS_ZERO");
        }

        // Store last byte.
        result = b[b.length - 1];

        assembly {
            // Decrement length of byte array.
            let newLen := sub(mload(b), 1)
            mstore(b, newLen)
        }
        return result;
    }

    // @dev Tests equality of two byte arrays.
    // @param lhs First byte array to compare.
    // @param rhs Second byte array to compare.
    // @return True if arrays are the same. False otherwise.
    function equals(bytes memory lhs, bytes memory rhs)
        internal
        pure
        returns (bool equal)
    {
        // Keccak gas cost is 30 + numWords * 6. This is a cheap way to compare.
        // We early exit on unequal lengths, but keccak would also correctly
        // handle this.
        return lhs.length == rhs.length && keccak256(lhs) == keccak256(rhs);
    }

    // @dev Reads an address from a position in a byte array.
    // @param b Byte array containing an address.
    // @param index Index in byte array of address.
    // @return address from byte array.
    function readAddress(bytes memory b, uint256 index)
        internal
        pure
        returns (address result)
    {
        if (b.length < index + 20) {
            revert("RA_B_LENGTH_LT_INDEX");
        }

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Read address from array memory
        assembly {
            // 1. Add index to address of bytes array
            // 2. Load 32-byte word from memory
            // 3. Apply 20-byte mask to obtain address
            result := and(
                mload(add(b, index)),
                0xffffffffffffffffffffffffffffffffffffffff
            )
        }
        return result;
    }

    // @dev Writes an address into a specific position in a byte array.
    // @param b Byte array to insert address into.
    // @param index Index in byte array of address.
    // @param input Address to put into byte array.
    function writeAddress(
        bytes memory b,
        uint256 index,
        address input
    ) internal pure {
        if (b.length < index + 20) {
            revert("WA_B_LENGTH_LT_INDEX");
        }

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Store address into array memory
        assembly {
            // The address occupies 20 bytes and mstore stores 32 bytes.
            // First fetch the 32-byte word where we'll be storing the address, then
            // apply a mask so we have only the bytes in the word that the address will not occupy.
            // Then combine these bytes with the address and store the 32 bytes back to memory with mstore.

            // 1. Add index to address of bytes array
            // 2. Load 32-byte word from memory
            // 3. Apply 12-byte mask to obtain extra bytes occupying word of memory where we'll store the address
            let neighbors := and(
                mload(add(b, index)),
                0xffffffffffffffffffffffff0000000000000000000000000000000000000000
            )

            // Make sure input address is clean.
            // (Solidity does not guarantee this)
            input := and(input, 0xffffffffffffffffffffffffffffffffffffffff)

            // Store the neighbors and address into memory
            mstore(add(b, index), xor(input, neighbors))
        }
    }

    // @dev Reads a bytes32 value from a position in a byte array.
    // @param b Byte array containing a bytes32 value.
    // @param index Index in byte array of bytes32 value.
    // @return bytes32 value from byte array.
    function readBytes32(bytes memory b, uint256 index)
        internal
        pure
        returns (bytes32 result)
    {
        if (b.length < index + 32) {
            revert("RB32_B_LENGTH_LT_INDEX");
        }

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            result := mload(add(b, index))
        }
        return result;
    }

    // @dev Writes a bytes32 into a specific position in a byte array.
    // @param b Byte array to insert <input> into.
    // @param index Index in byte array of <input>.
    // @param input bytes32 to put into byte array.
    function writeBytes32(
        bytes memory b,
        uint256 index,
        bytes32 input
    ) internal pure {
        if (b.length < index + 32) {
            revert("WB32_B_LENGTH_LT_INDEX");
        }

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            mstore(add(b, index), input)
        }
    }

    // @dev Reads a uint256 value from a position in a byte array.
    // @param b Byte array containing a uint256 value.
    // @param index Index in byte array of uint256 value.
    // @return uint256 value from byte array.
    function readUint256(bytes memory b, uint256 index)
        internal
        pure
        returns (uint256 result)
    {
        result = uint256(readBytes32(b, index));
        return result;
    }

    // @dev Writes a uint256 into a specific position in a byte array.
    // @param b Byte array to insert <input> into.
    // @param index Index in byte array of <input>.
    // @param input uint256 to put into byte array.
    function writeUint256(
        bytes memory b,
        uint256 index,
        uint256 input
    ) internal pure {
        writeBytes32(b, index, bytes32(input));
    }

    // @dev Reads an unpadded bytes4 value from a position in a byte array.
    // @param b Byte array containing a bytes4 value.
    // @param index Index in byte array of bytes4 value.
    // @return bytes4 value from byte array.
    function readBytes4(bytes memory b, uint256 index)
        internal
        pure
        returns (bytes4 result)
    {
        if (b.length < index + 4) {
            revert("RB4_B_LENGTH_LT_INDEX");
        }

        // Arrays are prefixed by a 32 byte length field
        index += 32;

        // Read the bytes4 from array memory
        assembly {
            result := mload(add(b, index))
            // Solidity does not require us to clean the trailing bytes.
            // We do it anyway
            result := and(
                result,
                0xFFFFFFFF00000000000000000000000000000000000000000000000000000000
            )
        }
        return result;
    }

    // @dev Writes a new length to a byte array.
    //      Decreasing length will lead to removing the corresponding lower order bytes from the byte array.
    //      Increasing length may lead to appending adjacent in-memory bytes to the end of the byte array.
    // @param b Bytes array to write new length to.
    // @param length New length of byte array.
    function writeLength(bytes memory b, uint256 length) internal pure {
        assembly {
            mstore(b, length)
        }
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

library LibBytesRichErrors {

    enum InvalidByteOperationErrorCodes {
        FromLessThanOrEqualsToRequired,
        ToLessThanOrEqualsLengthRequired,
        LengthGreaterThanZeroRequired,
        LengthGreaterThanOrEqualsFourRequired,
        LengthGreaterThanOrEqualsTwentyRequired,
        LengthGreaterThanOrEqualsThirtyTwoRequired,
        LengthGreaterThanOrEqualsNestedBytesLengthRequired,
        DestinationLengthGreaterThanOrEqualSourceLengthRequired
    }

    // bytes4(keccak256("InvalidByteOperationError(uint8,uint256,uint256)"))
    bytes4 internal constant INVALID_BYTE_OPERATION_ERROR_SELECTOR =
        0x28006595;

    // solhint-disable func-name-mixedcase
    function InvalidByteOperationError(
        InvalidByteOperationErrorCodes errorCode,
        uint256 offset,
        uint256 required
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            INVALID_BYTE_OPERATION_ERROR_SELECTOR,
            errorCode,
            offset,
            required
        );
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "./LibSafeMath.sol";
import "./LibRichErrors.sol";
import "./LibMathRichErrors.sol";

library LibMath {
    using LibSafeMath for uint256;

    // @dev Calculates partial value given a numerator and denominator rounded down.
    //      Reverts if rounding error is >= 0.1%
    // @param numerator Numerator.
    // @param denominator Denominator.
    // @param target Value to calculate partial of.
    // @return Partial value of target rounded down.
    function safeGetPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    ) internal pure returns (uint256 partialAmount) {
        if (isRoundingErrorFloor(numerator, denominator, target)) {
            revert("SGPAF_ROUNDING_ERROR");
        }

        partialAmount = numerator.safeMul(target).safeDiv(denominator);
        return partialAmount;
    }

    // @dev Calculates partial value given a numerator and denominator rounded down.
    //      Reverts if rounding error is >= 0.1%
    // @param numerator Numerator.
    // @param denominator Denominator.
    // @param target Value to calculate partial of.
    // @return Partial value of target rounded up.
    function safeGetPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    ) internal pure returns (uint256 partialAmount) {
        if (isRoundingErrorCeil(numerator, denominator, target)) {
            revert("SGPAC_ROUNDING_ERROR");
        }

        // safeDiv computes `floor(a / b)`. We use the identity (a, b integer):
        //       ceil(a / b) = floor((a + b - 1) / b)
        // To implement `ceil(a / b)` using safeDiv.
        partialAmount = numerator
            .safeMul(target)
            .safeAdd(denominator.safeSub(1))
            .safeDiv(denominator);

        return partialAmount;
    }

    // @dev Calculates partial value given a numerator and denominator rounded down.
    // @param numerator Numerator.
    // @param denominator Denominator.
    // @param target Value to calculate partial of.
    // @return Partial value of target rounded down.
    function getPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    ) internal pure returns (uint256 partialAmount) {
        partialAmount = numerator.safeMul(target).safeDiv(denominator);
        return partialAmount;
    }

    // @dev Calculates partial value given a numerator and denominator rounded down.
    // @param numerator Numerator.
    // @param denominator Denominator.
    // @param target Value to calculate partial of.
    // @return Partial value of target rounded up.
    function getPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    ) internal pure returns (uint256 partialAmount) {
        // safeDiv computes `floor(a / b)`. We use the identity (a, b integer):
        //       ceil(a / b) = floor((a + b - 1) / b)
        // To implement `ceil(a / b)` using safeDiv.
        partialAmount = numerator
            .safeMul(target)
            .safeAdd(denominator.safeSub(1))
            .safeDiv(denominator);

        return partialAmount;
    }

    // @dev Checks if rounding error >= 0.1% when rounding down.
    // @param numerator Numerator.
    // @param denominator Denominator.
    // @param target Value to multiply with numerator/denominator.
    // @return Rounding error is present.
    function isRoundingErrorFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    ) internal pure returns (bool isError) {
        if (denominator == 0) {
            revert("REF_D_IS_ZERO");
        }

        // The absolute rounding error is the difference between the rounded
        // value and the ideal value. The relative rounding error is the
        // absolute rounding error divided by the absolute value of the
        // ideal value. This is undefined when the ideal value is zero.
        //
        // The ideal value is `numerator * target / denominator`.
        // Let's call `numerator * target % denominator` the remainder.
        // The absolute error is `remainder / denominator`.
        //
        // When the ideal value is zero, we require the absolute error to
        // be zero. Fortunately, this is always the case. The ideal value is
        // zero iff `numerator == 0` and/or `target == 0`. In this case the
        // remainder and absolute error are also zero.
        if (target == 0 || numerator == 0) {
            return false;
        }

        // Otherwise, we want the relative rounding error to be strictly
        // less than 0.1%.
        // The relative error is `remainder / (numerator * target)`.
        // We want the relative error less than 1 / 1000:
        //        remainder / (numerator * denominator)  <  1 / 1000
        // or equivalently:
        //        1000 * remainder  <  numerator * target
        // so we have a rounding error iff:
        //        1000 * remainder  >=  numerator * target
        uint256 remainder = mulmod(target, numerator, denominator);
        isError = remainder.safeMul(1000) >= numerator.safeMul(target);
        return isError;
    }

    // @dev Checks if rounding error >= 0.1% when rounding up.
    // @param numerator Numerator.
    // @param denominator Denominator.
    // @param target Value to multiply with numerator/denominator.
    // @return Rounding error is present.
    function isRoundingErrorCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    ) internal pure returns (bool isError) {
        if (denominator == 0) {
            revert("REC_D_IS_ZERO");
        }

        // See the comments in `isRoundingError`.
        if (target == 0 || numerator == 0) {
            // When either is zero, the ideal value and rounded value are zero
            // and there is no rounding error. (Although the relative error
            // is undefined.)
            return false;
        }
        // Compute remainder as before
        uint256 remainder = mulmod(target, numerator, denominator);
        remainder = denominator.safeSub(remainder) % denominator;
        isError = remainder.safeMul(1000) >= numerator.safeMul(target);
        return isError;
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

library LibSafeMathRichErrors {

    // bytes4(keccak256("Uint256BinOpError(uint8,uint256,uint256)"))
    bytes4 internal constant UINT256_BINOP_ERROR_SELECTOR =
        0xe946c1bb;

    // bytes4(keccak256("Uint256DowncastError(uint8,uint256)"))
    bytes4 internal constant UINT256_DOWNCAST_ERROR_SELECTOR =
        0xc996af7b;

    enum BinOpErrorCodes {
        ADDITION_OVERFLOW,
        MULTIPLICATION_OVERFLOW,
        SUBTRACTION_UNDERFLOW,
        DIVISION_BY_ZERO
    }

    enum DowncastErrorCodes {
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT32,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT64,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT96
    }

    // solhint-disable func-name-mixedcase
    function Uint256BinOpError(
        BinOpErrorCodes errorCode,
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            UINT256_BINOP_ERROR_SELECTOR,
            errorCode,
            a,
            b
        );
    }

    function Uint256DowncastError(
        DowncastErrorCodes errorCode,
        uint256 a
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            UINT256_DOWNCAST_ERROR_SELECTOR,
            errorCode,
            a
        );
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

library LibMathRichErrors {

    // bytes4(keccak256("DivisionByZeroError()"))
    bytes internal constant DIVISION_BY_ZERO_ERROR =
        hex"a791837c";

    // bytes4(keccak256("RoundingError(uint256,uint256,uint256)"))
    bytes4 internal constant ROUNDING_ERROR_SELECTOR =
        0x339f3de2;

    // solhint-disable func-name-mixedcase
    function DivisionByZeroError()
        internal
        pure
        returns (bytes memory)
    {
        return DIVISION_BY_ZERO_ERROR;
    }

    function RoundingError(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            ROUNDING_ERROR_SELECTOR,
            numerator,
            denominator,
            target
        );
    }
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "../libs/LibOrder.sol";


interface IWallet {

    // @dev Validates a hash with the `Wallet` signature type.
    // @param hash Message hash that is signed.
    // @param signature Proof of signing.
    // @return magicValue `bytes4(0xb0671381)` if the signature check succeeds.
    function isValidSignature(
        bytes32 hash,
        bytes calldata signature
    )
        external
        view
        returns (bytes4 magicValue);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface IAssetProxy {
    // @dev Transfers assets. Either succeeds or throws.
    // @param assetData Byte array encoded for the respective asset proxy.
    // @param from Address to transfer asset from.
    // @param to Address to transfer asset to.
    // @param amount Amount of asset to transfer.
    function transferFrom(
        bytes calldata assetData,
        address from,
        address to,
        uint256 amount
    ) external;

    // @dev Gets the proxy id associated with the proxy address.
    // @return Proxy id.
    function getProxyId() external pure returns (bytes4);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
interface IAssetProxyDispatcher {

    // Logs registration of new asset proxy
    event AssetProxyRegistered(
        bytes4 id,              // Id of new registered AssetProxy.
        address assetProxy      // Address of new registered AssetProxy.
    );

    // @dev Registers an asset proxy to its asset proxy id.
    //      Once an asset proxy is registered, it cannot be unregistered.
    // @param assetProxy Address of new asset proxy to register.
    function registerAssetProxy(address assetProxy)
        external;

    // @dev Gets an asset proxy.
    // @param assetProxyId Id of the asset proxy.
    // @return The asset proxy registered to assetProxyId. Returns 0x0 if no proxy is registered.
    function getAssetProxy(bytes4 assetProxyId)
        external
        view
        returns (address);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;


// @dev Interface of the asset proxy's assetData.
// The asset proxies take an ABI encoded `bytes assetData` as argument.
// This argument is ABI encoded as one of the methods of this interface.
interface IAssetData {

    // @dev Function signature for encoding ERC20 assetData.
    // @param tokenAddress Address of ERC20Token contract.
    function ERC20Token(address tokenAddress)
        external;

    // @dev Function signature for encoding ERC721 assetData.
    // @param tokenAddress Address of ERC721 token contract.
    // @param tokenId Id of ERC721 token to be transferred.
    function ERC721Token(
        address tokenAddress,
        uint256 tokenId
    )
        external;

    // @dev Function signature for encoding ERC1155 assetData.
    // @param tokenAddress Address of ERC1155 token contract.
    // @param tokenIds Array of ids of tokens to be transferred.
    // @param values Array of values that correspond to each token id to be transferred.
    //        Note that each value will be multiplied by the amount being filled in the order before transferring.
    // @param callbackData Extra data to be passed to receiver's `onERC1155Received` callback function.
    function ERC1155Assets(
        address tokenAddress,
        uint256[] calldata tokenIds,
        uint256[] calldata values,
        bytes calldata callbackData
    )
        external;

    // @dev Function signature for encoding MultiAsset assetData.
    // @param values Array of amounts that correspond to each asset to be transferred.
    //        Note that each value will be multiplied by the amount being filled in the order before transferring.
    // @param nestedAssetData Array of assetData fields that will be be dispatched to their correspnding AssetProxy contract.
    function MultiAsset(
        uint256[] calldata values,
        bytes[] calldata nestedAssetData
    )
        external;

    // @dev Function signature for encoding StaticCall assetData.
    // @param staticCallTargetAddress Address that will execute the staticcall.
    // @param staticCallData Data that will be executed via staticcall on the staticCallTargetAddress.
    // @param expectedReturnDataHash Keccak-256 hash of the expected staticcall return data.
    function StaticCall(
        address staticCallTargetAddress,
        bytes calldata staticCallData,
        bytes32 expectedReturnDataHash
    )
        external;

    // @dev Function signature for encoding ERC20Bridge assetData.
    // @param tokenAddress Address of token to transfer.
    // @param bridgeAddress Address of the bridge contract.
    // @param bridgeData Arbitrary data to be passed to the bridge contract.
    function ERC20Bridge(
        address tokenAddress,
        address bridgeAddress,
        bytes calldata bridgeData
    )
        external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface IProtocolFees {
    // Logs updates to the protocol fee multiplier.
    event ProtocolFeeMultiplier(
        uint256 oldProtocolFeeMultiplier,
        uint256 updatedProtocolFeeMultiplier
    );

    // Logs updates to the protocolFeeCollector address.
    event ProtocolFeeCollectorAddress(
        address oldProtocolFeeCollector,
        address updatedProtocolFeeCollector
    );

    // @dev Allows the owner to update the protocol fee multiplier.
    // @param updatedProtocolFeeMultiplier The updated protocol fee multiplier.
    function setProtocolFeeMultiplier(uint256 updatedProtocolFeeMultiplier)
        external;

    // @dev Allows the owner to update the protocolFeeCollector address.
    // @param updatedProtocolFeeCollector The updated protocolFeeCollector contract address.
    function setProtocolFeeCollectorAddress(address updatedProtocolFeeCollector)
        external;

    // @dev Returns the protocolFeeMultiplier
    function protocolFeeMultiplier() external view returns (uint256);

    // @dev Returns the protocolFeeCollector address
    function protocolFeeCollector() external view returns (address);
}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface IStaking {
    // @dev Pays a protocol fee in ETH.
    // @param makerAddress The address of the order's maker.
    // @param payerAddress The address that is responsible for paying the protocol fee.
    // @param protocolFee The amount of protocol fees that should be paid.
    function payProtocolFee(
        address makerAddress,
        address payerAddress,
        uint256 protocolFee
    ) external payable;
}