/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

// File contracts/libraries/IdToAddressBiMap.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library IdToAddressBiMap {
    struct Data {
        mapping(uint64 => address) idToAddress;
        mapping(address => uint64) addressToId;
    }

    function hasId(Data storage self, uint64 id) internal view returns (bool) {
        return self.idToAddress[id + 1] != address(0);
    }

    function hasAddress(Data storage self, address addr)
        internal
        view
        returns (bool)
    {
        return self.addressToId[addr] != 0;
    }

    function getAddressAt(Data storage self, uint64 id)
        internal
        view
        returns (address)
    {
        require(hasId(self, id), "Must have ID to get Address");
        return self.idToAddress[id + 1];
    }

    function getId(Data storage self, address addr)
        internal
        view
        returns (uint64)
    {
        require(hasAddress(self, addr), "Must have Address to get ID");
        return self.addressToId[addr] - 1;
    }

    function insert(
        Data storage self,
        uint64 id,
        address addr
    ) internal returns (bool) {
        require(addr != address(0), "Cannot insert zero address");
        require(id != uint64(int64(-1)), "Cannot insert max uint64");
        // Ensure bijectivity of the mappings
        if (
            self.addressToId[addr] != 0 ||
            self.idToAddress[id + 1] != address(0)
        ) {
            return false;
        }
        self.idToAddress[id + 1] = addr;
        self.addressToId[addr] = id + 1;
        return true;
    }
}

// File @openzeppelin/contracts/utils/math/[email protected]

// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

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

// File contracts/libraries/IterableOrderedOrderSet.sol

pragma solidity ^0.8.0;

library IterableOrderedOrderSet {
    using SafeMath for uint96;
    using IterableOrderedOrderSet for bytes32;

    // represents smallest possible value for an order under comparison of fn smallerThan()
    bytes32 internal constant QUEUE_START =
        0x0000000000000000000000000000000000000000000000000000000000000001;
    // represents highest possible value for an order under comparison of fn smallerThan()
    bytes32 internal constant QUEUE_END =
        0xffffffffffffffffffffffffffffffffffffffff000000000000000000000001;

    /// The struct is used to implement a modified version of a doubly linked
    /// list with sorted elements. The list starts from QUEUE_START to
    /// QUEUE_END, and each node keeps track of its predecessor and successor.
    /// Nodes can be added or removed.
    ///
    /// `next` and `prev` have a different role. The list is supposed to be
    /// traversed with `next`. If `next` is empty, the node is not part of the
    /// list. However, `prev` might be set for elements that are not in the
    /// list, which is why it should not be used for traversing. Having a `prev`
    /// set for elements not in the list is used to keep track of the history of
    /// the position in the list of a removed element.
    struct Data {
        mapping(bytes32 => bytes32) nextMap;
        mapping(bytes32 => bytes32) prevMap;
    }

    struct Order {
        uint64 owner;
        uint96 buyAmount;
        uint96 sellAmount;
    }

    function initializeEmptyList(Data storage self) internal {
        self.nextMap[QUEUE_START] = QUEUE_END;
        self.prevMap[QUEUE_END] = QUEUE_START;
    }

    function isEmpty(Data storage self) internal view returns (bool) {
        return self.nextMap[QUEUE_START] == QUEUE_END;
    }

    function getCurrent(Data storage self) internal view returns (bytes32) {
        return self.prevMap[QUEUE_END];
    }

    function insert(
        Data storage self,
        bytes32 elementToInsert,
        bytes32 elementBeforeNewOne
    ) internal returns (bool) {
        (, , uint96 denominator) = decodeOrder(elementToInsert);
        require(denominator != uint96(0), "Inserting zero is not supported");
        require(
            elementToInsert != QUEUE_START && elementToInsert != QUEUE_END,
            "Inserting element is not valid"
        );
        if (contains(self, elementToInsert)) {
            return false;
        }
        if (
            elementBeforeNewOne != QUEUE_START &&
            self.prevMap[elementBeforeNewOne] == bytes32(0)
        ) {
            return false;
        }
        if (!elementBeforeNewOne.smallerThan(elementToInsert)) {
            return false;
        }

        // `elementBeforeNewOne` might have been removed during the time it
        // took to the transaction calling this function to be mined, so
        // the new order cannot be appended directly to this. We follow the
        // history of previous links backwards until we find an element in
        // the list from which to start our search.
        // Note that following the link backwards returns elements that are
        // before `elementBeforeNewOne` in sorted order.
        while (self.nextMap[elementBeforeNewOne] == bytes32(0)) {
            elementBeforeNewOne = self.prevMap[elementBeforeNewOne];
        }

        // `elementBeforeNewOne` belongs now to the linked list. We search the
        // largest entry that is smaller than the element to insert.
        bytes32 previous;
        bytes32 current = elementBeforeNewOne;
        do {
            previous = current;
            current = self.nextMap[current];
        } while (current.smallerThan(elementToInsert));
        // Note: previous < elementToInsert < current
        self.nextMap[previous] = elementToInsert;
        self.prevMap[current] = elementToInsert;
        self.prevMap[elementToInsert] = previous;
        self.nextMap[elementToInsert] = current;

        return true;
    }

    /// The element is removed from the linked list, but the node retains
    /// information on which predecessor it had, so that a node in the chain
    /// can be reached by following the predecessor chain of deleted elements.
    function removeKeepHistory(Data storage self, bytes32 elementToRemove)
        internal
        returns (bool)
    {
        if (!contains(self, elementToRemove)) {
            return false;
        }
        bytes32 previousElement = self.prevMap[elementToRemove];
        bytes32 nextElement = self.nextMap[elementToRemove];
        self.nextMap[previousElement] = nextElement;
        self.prevMap[nextElement] = previousElement;
        self.nextMap[elementToRemove] = bytes32(0);
        return true;
    }

    /// Remove an element from the chain, clearing all related storage.
    /// Note that no elements should be inserted using as a reference point a
    /// node deleted after calling `remove`, since an element in the `prev`
    /// chain might be missing.
    function remove(Data storage self, bytes32 elementToRemove)
        internal
        returns (bool)
    {
        bool result = removeKeepHistory(self, elementToRemove);
        if (result) {
            self.prevMap[elementToRemove] = bytes32(0);
        }
        return result;
    }

    function contains(Data storage self, bytes32 value)
        internal
        view
        returns (bool)
    {
        if (value == QUEUE_START) {
            return false;
        }
        // Note: QUEUE_END is not contained in the list since it has no
        // successor.
        return self.nextMap[value] != bytes32(0);
    }

    function smallerThan(bytes32 orderLeft, bytes32 orderRight)
        internal
        pure
        returns (bool)
    {
        (
            uint64 userIdLeft,
            uint96 priceNumeratorLeft,
            uint96 priceDenominatorLeft
        ) = decodeOrder(orderLeft);
        (
            uint64 userIdRight,
            uint96 priceNumeratorRight,
            uint96 priceDenominatorRight
        ) = decodeOrder(orderRight);

        if (
            priceNumeratorLeft.mul(priceDenominatorRight) <
            priceNumeratorRight.mul(priceDenominatorLeft)
        ) return true;
        if (
            priceNumeratorLeft.mul(priceDenominatorRight) >
            priceNumeratorRight.mul(priceDenominatorLeft)
        ) return false;

        if (priceNumeratorLeft < priceNumeratorRight) return true;
        if (priceNumeratorLeft > priceNumeratorRight) return false;
        require(
            userIdLeft != userIdRight,
            "user is not allowed to place same order twice"
        );
        if (userIdLeft < userIdRight) {
            return true;
        }
        return false;
    }

    function first(Data storage self) internal view returns (bytes32) {
        require(!isEmpty(self), "Trying to get first from empty set");
        return self.nextMap[QUEUE_START];
    }

    function next(Data storage self, bytes32 value)
        internal
        view
        returns (bytes32)
    {
        require(value != QUEUE_END, "Trying to get next of last element");
        bytes32 nextElement = self.nextMap[value];
        require(
            nextElement != bytes32(0),
            "Trying to get next of non-existent element"
        );
        return nextElement;
    }

    function decodeOrder(bytes32 _orderData)
        internal
        pure
        returns (
            uint64 userId,
            uint96 buyAmount,
            uint96 sellAmount
        )
    {
        // Note: converting to uint discards the binary digits that do not fit
        // the type.
        userId = uint64(uint256(_orderData) >> 192);
        buyAmount = uint96(uint256(_orderData) >> 96);
        sellAmount = uint96(uint256(_orderData));
    }

    function encodeOrder(
        uint64 userId,
        uint96 buyAmount,
        uint96 sellAmount
    ) internal pure returns (bytes32) {
        return
            bytes32(
                (uint256(userId) << 192) +
                    (uint256(buyAmount) << 96) +
                    uint256(sellAmount)
            );
    }
}

// File contracts/libraries/SafeCast.sol

pragma solidity ^0.8.0;

library SafeCast {
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value < 2**96, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value < 2**64, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }
}

// File @openzeppelin/contracts/utils/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File @openzeppelin/contracts/token/ERC20/[email protected]

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// File @openzeppelin/contracts/utils/[email protected]

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

library Address {
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

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

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

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

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

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

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
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

// File @openzeppelin/contracts/token/ERC20/utils/[email protected]

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(
            nonceAfter == nonceBefore + 1,
            "SafeERC20: permit did not succeed"
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

// File contracts/MutoPool.sol

pragma solidity ^0.8.0;

// Pool input data
struct InitialPoolData {
    string formHash;
    IERC20 poolingToken;
    IERC20 biddingToken;
    uint40 orderCancellationEndDate;
    uint40 poolStartDate;
    uint40 poolEndDate;
    uint96 pooledSellAmount;
    uint96 minBuyAmount;
    uint256 minimumBiddingAmountPerOrder;
    uint256 minFundingThreshold;
    bool isAtomicClosureAllowed;
}

// Pool data
struct PoolData {
    InitialPoolData initData;
    address poolOwner;
    bytes32 initialPoolOrder;
    uint256 interimSumBidAmount;
    bytes32 interimOrder;
    bytes32 clearingPriceOrder;
    uint96 volumeClearingPriceOrder;
    bool minFundingThresholdNotReached;
    uint256 feeNumerator;
    bool isScam;
    bool isDeleted;
}

contract MutoPool is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint40;
    using SafeMath for uint64;
    using SafeMath for uint96;
    using SafeMath for uint256;
    using SafeCast for uint256;
    using SafeCast for uint64;
    using IterableOrderedOrderSet for bytes32;
    using IdToAddressBiMap for IdToAddressBiMap.Data;
    using IterableOrderedOrderSet for IterableOrderedOrderSet.Data;

    mapping(uint256 => PoolData) public poolData;
    mapping(uint256 => IterableOrderedOrderSet.Data) internal sellOrders;

    uint64 public numUsers;
    uint256 public poolCounter;
    IdToAddressBiMap.Data private registeredUsers;

    constructor() Ownable() {}

    uint64 public feeReceiverUserId = 1;
    uint256 public feeNumerator = 15;
    uint256 public constant FEE_DENOMINATOR = 1000;

    // To check if pool is marked scam or deleted
    modifier scammedOrDeleted(uint256 poolId) {
        require(
            poolData[poolId].isScam || poolData[poolId].isDeleted,
            "Pool not Scammed or Deleted"
        ); // pool should be scammed or deleted
        _;
    }

    // To check if cancelation date is reached or not
    modifier atStageOrderPlacementAndCancelation(uint256 poolId) {
        require(
            block.timestamp <
                poolData[poolId].initData.orderCancellationEndDate,
            "Not in order placement/cancelation phase"
        ); // cancellation date shouldn't have passed
        _;
    }

    // To check if pool has finished
    modifier atStageFinished(uint256 poolId) {
        require(
            poolData[poolId].clearingPriceOrder != bytes32(0),
            "Pool not finished"
        );
        _;
    }

    // To check if pool end date is reached
    modifier atStageOrderPlacement(uint256 poolId) {
        require(
            block.timestamp < poolData[poolId].initData.poolEndDate,
            "Not in order placement phase"
        ); // pool end date must not be reached
        _;
    }

    // To check pool is not marked scam and deleted
    modifier isScammedOrDeleted(uint256 poolId) {
        require(
            !poolData[poolId].isScam && !poolData[poolId].isDeleted,
            "Deleted or Scammed"
        ); // poll must not be marked as deleted or scammed
        _;
    }

    // To check if end date has reached and pool can be cleared
    modifier atStageSolutionSubmission(uint256 poolId) {
        require(
            poolData[poolId].initData.poolEndDate != 0 &&
                block.timestamp >= poolData[poolId].initData.poolEndDate &&
                poolData[poolId].clearingPriceOrder == bytes32(0),
            "Not in submission phase"
        ); // pool end date must have reached
        require(
            !poolData[poolId].isScam && !poolData[poolId].isDeleted,
            "Deleted or Scammed"
        ); //pool must not be deleted or scamed
        _;
    }

    // Both NewPoolE1 and NewPoolE2 are emitted on pool initialization
    event NewPoolE1(
        uint256 indexed poolId,
        uint256 indexed userId,
        address indexed poolOwner,
        string formHash,
        IERC20 poolingToken,
        IERC20 biddingToken,
        uint40 orderCancellationEndDate,
        uint40 poolStartDate,
        uint40 poolEndDate,
        uint96 pooledSellAmount,
        uint96 minBuyAmount
    );

    event NewPoolE2(
        uint256 indexed poolId,
        bytes32 initialPoolOrder,
        uint256 interimsumBidAmount,
        bytes32 interimOrder,
        bytes32 clearingPriceOrder,
        uint96 volumeClearingOrder,
        bool minimumFundingThresholdReached,
        uint256 minimumBiddingAmountPerOrder,
        uint256 minFundingThreshold,
        bool isAtomicClosureAllowed,
        uint256 feeNumerator,
        bool isScam,
        bool isDeleted
    );

    event OrderClaimedByUser(
        uint256 indexed poolId,
        uint64 indexed userId,
        uint96 buyAmount,
        uint96 sellAmount
    );

    event PoolEdittedByUser(uint256 indexed poolId, string formHash);

    event PoolEdittedByAdmin(
        uint256 indexed poolId,
        uint256 poolStartDate,
        uint256 poolEndDate,
        uint256 orderCancellationEndDate,
        uint256 minimumBiddingAmountPerOrder,
        uint256 minFundingThreshold
    );

    event PoolCleared(
        uint256 indexed poolId,
        uint96 soldPoolingTokens,
        uint96 soldBiddingTokens,
        bytes32 clearingPriceOrder
    );

    event NewSellOrderPlaced(
        uint256 indexed poolId,
        uint64 indexed userId,
        uint96 buyAmount,
        uint96 sellAmount,
        bytes32 sellOrder
    );

    event SellOrderCancelled(
        uint256 indexed poolId,
        uint64 indexed userId,
        uint96 buyAmount,
        uint96 sellAmount,
        bytes32 sellOrder
    );

    event OrderRefunded(
        uint256 indexed poolId,
        uint64 indexed userId,
        uint96 buyAmount,
        uint96 sellAmount,
        bytes32 sellOrder
    );

    event NewUser(uint64 indexed userId, address indexed userAddress);

    event UserRegistration(address indexed user, uint64 userId);

    function setFeeParameters(
        uint256 newFeeNumerator,
        address newfeeReceiverAddress
    ) external onlyOwner {
        require(newFeeNumerator <= 15); // pool fee can be maximum upto 1.5 %
        feeReceiverUserId = getUserId(newfeeReceiverAddress);
        feeNumerator = newFeeNumerator;
    }

    function CheckUserId(address userAddress) external view returns (uint64) {
        require(registeredUsers.hasAddress(userAddress), "Not Registered Yet"); // user must be registered
        return registeredUsers.getId(userAddress);
    }

    function initiatePool(InitialPoolData calldata _initData)
        external
        returns (uint256)
    {
        uint256 _ammount = _initData
            .pooledSellAmount
            .mul(FEE_DENOMINATOR.add(feeNumerator))
            .div(FEE_DENOMINATOR);
        require(
            _initData.poolingToken.balanceOf(msg.sender) >= _ammount,
            "Not enough balance"
        );
        // dates must be configured carefully
        // start date < cancellation date < end date
        require(
            block.timestamp < _initData.poolStartDate &&
                _initData.poolStartDate < _initData.poolEndDate &&
                _initData.orderCancellationEndDate <= _initData.poolEndDate &&
                _initData.poolEndDate > block.timestamp,
            "Date not configured correctly"
        );
        require(
            _initData.pooledSellAmount > 0 && // ppled amount must be greater than zero
                _initData.minBuyAmount > 0 && // minimum buy amount must be greater than zero
                _initData.minimumBiddingAmountPerOrder > 0, // minimum sell amount of order must be grater than zero
            "Ammount can't be zero"
        );
        // need to approve tokens to this contract
        _initData.poolingToken.safeTransferFrom(
            msg.sender,
            address(this),
            _ammount
        );
        poolCounter = poolCounter.add(1);
        sellOrders[poolCounter].initializeEmptyList();
        uint64 userId = getUserId(msg.sender);
        poolData[poolCounter] = PoolData(
            _initData,
            msg.sender,
            IterableOrderedOrderSet.encodeOrder(
                userId,
                _initData.minBuyAmount,
                _initData.pooledSellAmount
            ),
            0,
            IterableOrderedOrderSet.QUEUE_START,
            bytes32(0),
            0,
            false,
            feeNumerator,
            false,
            false
        );
        emit NewPoolE1(
            poolCounter,
            userId,
            msg.sender,
            _initData.formHash,
            _initData.poolingToken,
            _initData.biddingToken,
            _initData.orderCancellationEndDate,
            _initData.poolStartDate,
            _initData.poolEndDate,
            _initData.pooledSellAmount,
            _initData.minBuyAmount
        );
        emit NewPoolE2(
            poolCounter,
            IterableOrderedOrderSet.encodeOrder(
                userId,
                _initData.minBuyAmount,
                _initData.pooledSellAmount
            ),
            0,
            IterableOrderedOrderSet.QUEUE_START,
            bytes32(0),
            0,
            false,
            _initData.minimumBiddingAmountPerOrder,
            _initData.minFundingThreshold,
            _initData.isAtomicClosureAllowed,
            feeNumerator,
            false,
            false
        );
        return poolCounter;
    }

    function getFormHash(uint256 pool_id)
        external
        view
        returns (string memory)
    {
        // pool must exist
        require(pool_id <= poolCounter, "Invali pool ID");
        return poolData[pool_id].initData.formHash;
    }

    function updatePoolAdmin(
        uint256 poolId,
        uint40 _startTime,
        uint40 _endTime,
        uint40 _cancelTime,
        uint256 _fundingThreshold,
        uint256 _minBid
    ) external onlyOwner {
        poolData[poolId].initData.poolStartDate = _startTime;
        poolData[poolId].initData.poolEndDate = _endTime;
        poolData[poolId].initData.orderCancellationEndDate = _cancelTime;
        poolData[poolId].initData.minFundingThreshold = _fundingThreshold;
        poolData[poolId].initData.minimumBiddingAmountPerOrder = _minBid;
        emit PoolEdittedByAdmin(
            poolId,
            _startTime,
            _endTime,
            _cancelTime,
            _minBid,
            _fundingThreshold
        );
    }

    function updatePoolUser(uint256 poolId, string memory _formHash) external {
        require(
            msg.sender == poolData[poolId].poolOwner,
            "Can be updated by pool owner only"
        );
        poolData[poolId].initData.formHash = _formHash;
        emit PoolEdittedByUser(poolId, _formHash);
    }

    // To fetch the latest bid buy & sell amount
    function getCurrentPoolPrice(uint256 _poolId)
        external
        view
        returns (uint96 buyAmount, uint96 sellAmount)
    {
        bytes32 current = sellOrders[_poolId].getCurrent();
        (, buyAmount, sellAmount) = current.decodeOrder();
    }

    function markSpam(uint256 poolId) external onlyOwner {
        poolData[poolId].isScam = true;
        // returns the funds to pooler
        poolData[poolId].initData.poolingToken.safeTransfer(
            msg.sender,
            poolData[poolId].initData.pooledSellAmount
        );
    }

    function deletPool(uint256 poolId) external onlyOwner {
        poolData[poolId].isDeleted = true;
        //returns the funds to pooler
        poolData[poolId].initData.poolingToken.safeTransfer(
            msg.sender,
            poolData[poolId].initData.pooledSellAmount
        );
    }

    function getEncodedOrder(
        uint64 userId,
        uint96 buyAmount,
        uint96 sellAmount
    ) external pure returns (bytes32) {
        return
            bytes32(
                (uint256(userId) << 192) +
                    (uint256(buyAmount) << 96) +
                    uint256(sellAmount)
            );
    }

    function placeSellOrders(
        uint256 poolId,
        uint96[] memory _minBuyAmounts,
        uint96[] memory _sellAmounts,
        bytes32[] memory _prevSellOrders
    )
        external
        atStageOrderPlacement(poolId)
        isScammedOrDeleted(poolId)
        returns (uint64 userId)
    {
        return
            _placeSellOrders(
                poolId,
                _minBuyAmounts,
                _sellAmounts,
                _prevSellOrders,
                msg.sender
            );
    }

    function placeSellOrdersOnBehalf(
        uint256 poolId,
        uint96[] memory _minBuyAmounts,
        uint96[] memory _sellAmounts,
        bytes32[] memory _prevSellOrders,
        address orderSubmitter
    )
        external
        atStageOrderPlacement(poolId)
        isScammedOrDeleted(poolId)
        returns (uint64 userId)
    {
        return
            _placeSellOrders(
                poolId,
                _minBuyAmounts,
                _sellAmounts,
                _prevSellOrders,
                orderSubmitter
            );
    }

    function cancelSellOrders(uint256 poolId, bytes32[] memory _sellOrders)
        external
        atStageOrderPlacementAndCancelation(poolId)
        isScammedOrDeleted(poolId)
    {
        uint64 userId = getUserId(msg.sender);
        uint256 claimableAmount = 0;
        for (uint256 i = 0; i < _sellOrders.length; i++) {
            bool success = sellOrders[poolId].removeKeepHistory(_sellOrders[i]);
            if (success) {
                (
                    uint64 userIdOfIter,
                    uint96 buyAmountOfIter,
                    uint96 sellAmountOfIter
                ) = _sellOrders[i].decodeOrder();
                // User must be order placer
                require(userIdOfIter == userId, "Only order placer can cancel");
                claimableAmount = claimableAmount.add(sellAmountOfIter);
                emit SellOrderCancelled(
                    poolId,
                    userId,
                    buyAmountOfIter,
                    sellAmountOfIter,
                    _sellOrders[i]
                );
            }
        }
        poolData[poolId].initData.biddingToken.safeTransfer(
            msg.sender,
            claimableAmount
        );
    }

    function refundOrder(uint256 poolId, bytes32 order)
        external
        scammedOrDeleted(poolId)
    {
        // check if order exists
        require(sellOrders[poolId].remove(order), "Order not refundable");
        uint64 userId = getUserId(msg.sender);
        (uint64 userIdOrder, uint96 buyAmount, uint96 sellAmount) = order
            .decodeOrder();
        // check if user is order placer
        require(userIdOrder == userId, "Not Order Placer");
        poolData[poolId].initData.biddingToken.safeTransfer(
            msg.sender,
            sellAmount
        );
        emit OrderRefunded(poolId, userId, buyAmount, sellAmount, order);
    }

    function claimFromParticipantOrder(uint256 poolId, bytes32[] memory orders)
        external
        atStageFinished(poolId)
        isScammedOrDeleted(poolId)
        returns (uint256 sumPoolingTokenAmount, uint256 sumBiddingTokenAmount)
    {
        for (uint256 i = 0; i < orders.length; i++) {
            require(
                sellOrders[poolId].remove(orders[i]),
                "Order not claimable"
            );
        }
        PoolData memory pool = poolData[poolId];
        (, uint96 priceNumerator, uint96 priceDenominator) = pool
            .clearingPriceOrder
            .decodeOrder();
        (uint64 userId, , ) = orders[0].decodeOrder();
        bool minFundingThresholdNotReached = poolData[poolId]
            .minFundingThresholdNotReached;
        for (uint256 i = 0; i < orders.length; i++) {
            (uint64 userIdOrder, uint96 buyAmount, uint96 sellAmount) = orders[
                i
            ].decodeOrder();
            require(userIdOrder == userId, "Claimable by user only");
            if (minFundingThresholdNotReached) {
                sumBiddingTokenAmount = sumBiddingTokenAmount.add(sellAmount);
            } else {
                if (orders[i] == pool.clearingPriceOrder) {
                    sumPoolingTokenAmount = sumPoolingTokenAmount.add(
                        pool.volumeClearingPriceOrder.mul(priceNumerator).div(
                            priceDenominator
                        )
                    );
                    sumBiddingTokenAmount = sumBiddingTokenAmount.add(
                        sellAmount.sub(pool.volumeClearingPriceOrder)
                    );
                } else {
                    if (orders[i].smallerThan(pool.clearingPriceOrder)) {
                        sumPoolingTokenAmount = sumPoolingTokenAmount.add(
                            sellAmount.mul(priceNumerator).div(priceDenominator)
                        );
                    } else {
                        sumBiddingTokenAmount = sumBiddingTokenAmount.add(
                            sellAmount
                        );
                    }
                }
            }
            emit OrderClaimedByUser(poolId, userId, buyAmount, sellAmount);
        }
        sendOutTokens(
            poolId,
            sumPoolingTokenAmount,
            sumBiddingTokenAmount,
            userId
        );
    }

    function settlePoolAtomically(
        uint256 poolId,
        uint96[] memory _minBuyAmount,
        uint96[] memory _sellAmount,
        bytes32[] memory _prevSellOrder
    ) external atStageSolutionSubmission(poolId) {
        require(
            poolData[poolId].initData.isAtomicClosureAllowed,
            "Not autosettle allowed"
        );
        require(_minBuyAmount.length == 1 && _sellAmount.length == 1);
        uint64 userId = getUserId(msg.sender);
        require(
            poolData[poolId].interimOrder.smallerThan(
                IterableOrderedOrderSet.encodeOrder(
                    userId,
                    _minBuyAmount[0],
                    _sellAmount[0]
                )
            )
        );
        _placeSellOrders(
            poolId,
            _minBuyAmount,
            _sellAmount,
            _prevSellOrder,
            msg.sender
        );
        settlePool(poolId);
    }

    function registerUser(address user) public returns (uint64 userId) {
        numUsers = numUsers.add(1).toUint64();
        // check if user already registered
        require(registeredUsers.insert(numUsers, user), "User already exists");
        userId = numUsers;
        emit UserRegistration(user, userId);
    }

    function getUserId(address user) public returns (uint64 userId) {
        if (registeredUsers.hasAddress(user)) {
            userId = registeredUsers.getId(user);
        } else {
            userId = registerUser(user);
            emit NewUser(userId, user);
        }
    }

    function getSecondsRemainingInBatch(uint256 poolId)
        public
        view
        returns (uint256)
    {
        if (poolData[poolId].initData.poolEndDate < block.timestamp) {
            return 0;
        }
        return poolData[poolId].initData.poolEndDate.sub(block.timestamp);
    }

    function containsOrder(uint256 poolId, bytes32 order)
        public
        view
        returns (bool)
    {
        return sellOrders[poolId].contains(order);
    }

    function settlePool(uint256 poolId)
        public
        atStageSolutionSubmission(poolId)
        returns (bytes32 clearingOrder)
    {
        (
            uint64 poolerId,
            uint96 minPooledBuyAmount,
            uint96 fullPooledAmount
        ) = poolData[poolId].initialPoolOrder.decodeOrder();

        uint256 currentBidSum = poolData[poolId].interimSumBidAmount;
        bytes32 currentOrder = poolData[poolId].interimOrder;
        uint256 buyAmountOfIter;
        uint256 sellAmountOfIter;
        uint96 fillVolumeOfPoolerOrder = fullPooledAmount;
        do {
            bytes32 nextOrder = sellOrders[poolId].next(currentOrder);
            if (nextOrder == IterableOrderedOrderSet.QUEUE_END) {
                break;
            }
            currentOrder = nextOrder;
            (, buyAmountOfIter, sellAmountOfIter) = currentOrder.decodeOrder();
            currentBidSum = currentBidSum.add(sellAmountOfIter);
        } while (
            currentBidSum.mul(buyAmountOfIter) <
                fullPooledAmount.mul(sellAmountOfIter)
        );

        if (
            currentBidSum > 0 &&
            currentBidSum.mul(buyAmountOfIter) >=
            fullPooledAmount.mul(sellAmountOfIter)
        ) {
            uint256 uncoveredBids = currentBidSum.sub(
                fullPooledAmount.mul(sellAmountOfIter).div(buyAmountOfIter)
            );

            if (sellAmountOfIter >= uncoveredBids) {
                uint256 sellAmountClearingOrder = sellAmountOfIter.sub(
                    uncoveredBids
                );
                poolData[poolId]
                    .volumeClearingPriceOrder = sellAmountClearingOrder
                    .toUint96();
                currentBidSum = currentBidSum.sub(uncoveredBids);
                clearingOrder = currentOrder;
            } else {
                currentBidSum = currentBidSum.sub(sellAmountOfIter);
                clearingOrder = IterableOrderedOrderSet.encodeOrder(
                    0,
                    fullPooledAmount,
                    uint96(currentBidSum)
                );
            }
        } else {
            if (currentBidSum > minPooledBuyAmount) {
                clearingOrder = IterableOrderedOrderSet.encodeOrder(
                    0,
                    fullPooledAmount,
                    currentBidSum.toUint96()
                );
            } else {
                clearingOrder = IterableOrderedOrderSet.encodeOrder(
                    0,
                    fullPooledAmount,
                    minPooledBuyAmount
                );
                fillVolumeOfPoolerOrder = currentBidSum
                    .mul(fullPooledAmount)
                    .div(minPooledBuyAmount)
                    .toUint96();
            }
        }
        poolData[poolId].clearingPriceOrder = clearingOrder;

        if (poolData[poolId].initData.minFundingThreshold > currentBidSum) {
            poolData[poolId].minFundingThresholdNotReached = true;
        }
        processFeesAndPoolerFunds(
            poolId,
            fillVolumeOfPoolerOrder,
            poolerId,
            fullPooledAmount
        );
        emit PoolCleared(
            poolId,
            fillVolumeOfPoolerOrder,
            uint96(currentBidSum),
            clearingOrder
        );

        poolData[poolId].initialPoolOrder = bytes32(0);
        poolData[poolId].interimOrder = bytes32(0);
        poolData[poolId].interimSumBidAmount = uint256(0);
        poolData[poolId].initData.minimumBiddingAmountPerOrder = uint256(0);
    }

    function precalculateSellAmountSum(uint256 poolId, uint256 iterationSteps)
        public
        atStageSolutionSubmission(poolId)
    {
        (, , uint96 poolerSellAmount) = poolData[poolId]
            .initialPoolOrder
            .decodeOrder();
        uint256 sumBidAmount = poolData[poolId].interimSumBidAmount;
        bytes32 iterOrder = poolData[poolId].interimOrder;

        for (uint256 i = 0; i < iterationSteps; i++) {
            iterOrder = sellOrders[poolId].next(iterOrder);
            (, , uint96 sellAmountOfIter) = iterOrder.decodeOrder();
            sumBidAmount = sumBidAmount.add(sellAmountOfIter);
        }

        // current iteration order is not the end of order que
        require(iterOrder != IterableOrderedOrderSet.QUEUE_END, "Reached end");
        (, uint96 buyAmountOfIter, uint96 selAmountOfIter) = iterOrder
            .decodeOrder();
        require(
            sumBidAmount.mul(buyAmountOfIter) <
                poolerSellAmount.mul(selAmountOfIter),
            "Too many orders"
        );

        poolData[poolId].interimSumBidAmount = sumBidAmount;
        poolData[poolId].interimOrder = iterOrder;
    }

    function _placeSellOrders(
        uint256 poolId,
        uint96[] memory _minBuyAmounts,
        uint96[] memory _sellAmounts,
        bytes32[] memory _prevSellOrders,
        address orderSubmitter
    ) internal returns (uint64 userId) {
        {
            (
                ,
                uint96 buyAmountOfInitialPoolOrder,
                uint96 sellAmountOfInitialPoolOrder
            ) = poolData[poolId].initialPoolOrder.decodeOrder();
            for (uint256 i = 0; i < _minBuyAmounts.length; i++) {
                require(
                    _minBuyAmounts[i].mul(buyAmountOfInitialPoolOrder) <
                        sellAmountOfInitialPoolOrder.mul(_sellAmounts[i]),
                    "limit price is <  min offer"
                );
            }
        }
        uint256 sumOfSellAmounts = 0;
        userId = getUserId(orderSubmitter);
        uint256 minimumBiddingAmountPerOrder = poolData[poolId]
            .initData
            .minimumBiddingAmountPerOrder;
        for (uint256 i = 0; i < _minBuyAmounts.length; i++) {
            require(_minBuyAmounts[i] > 0, "buyAmounts must be > 0");
            require(
                _sellAmounts[i] > minimumBiddingAmountPerOrder,
                "order too small"
            );
            if (
                sellOrders[poolId].insert(
                    IterableOrderedOrderSet.encodeOrder(
                        userId,
                        _minBuyAmounts[i],
                        _sellAmounts[i]
                    ),
                    _prevSellOrders[i]
                )
            ) {
                sumOfSellAmounts = sumOfSellAmounts.add(_sellAmounts[i]);
                emit NewSellOrderPlaced(
                    poolId,
                    userId,
                    _minBuyAmounts[i],
                    _sellAmounts[i],
                    IterableOrderedOrderSet.encodeOrder(
                        userId,
                        _minBuyAmounts[i],
                        _sellAmounts[i]
                    )
                );
            }
        }

        // transfer the sum of sell amounts to this contract
        poolData[poolId].initData.biddingToken.safeTransferFrom(
            msg.sender,
            address(this),
            sumOfSellAmounts
        );
    }

    function sendOutTokens(
        uint256 poolId,
        uint256 poolingTokenAmount,
        uint256 biddingTokenAmount,
        uint64 userId
    ) internal {
        address userAddress = registeredUsers.getAddressAt(userId);
        if (poolingTokenAmount > 0) {
            poolData[poolId].initData.poolingToken.safeTransfer(
                userAddress,
                poolingTokenAmount
            );
        }
        if (biddingTokenAmount > 0) {
            poolData[poolId].initData.biddingToken.safeTransfer(
                userAddress,
                biddingTokenAmount
            );
        }
    }

    function processFeesAndPoolerFunds(
        uint256 poolId,
        uint256 fillVolumeOfPoolerOrder,
        uint64 poolerId,
        uint96 fullPooledAmount
    ) internal {
        uint256 feeAmount = fullPooledAmount
            .mul(poolData[poolId].feeNumerator)
            .div(FEE_DENOMINATOR);
        if (poolData[poolId].minFundingThresholdNotReached) {
            sendOutTokens(poolId, fullPooledAmount.add(feeAmount), 0, poolerId); //[4]
        } else {
            (, uint96 priceNumerator, uint96 priceDenominator) = poolData[
                poolId
            ].clearingPriceOrder.decodeOrder();
            uint256 unsettledPoolTokens = fullPooledAmount.sub(
                fillVolumeOfPoolerOrder
            );
            uint256 poolingTokenAmount = unsettledPoolTokens.add(
                feeAmount.mul(unsettledPoolTokens).div(fullPooledAmount)
            );
            uint256 biddingTokenAmount = fillVolumeOfPoolerOrder
                .mul(priceDenominator)
                .div(priceNumerator);
            sendOutTokens(
                poolId,
                poolingTokenAmount,
                biddingTokenAmount,
                poolerId
            );
            sendOutTokens(
                poolId,
                feeAmount.mul(fillVolumeOfPoolerOrder).div(fullPooledAmount),
                0,
                feeReceiverUserId
            );
        }
    }
}