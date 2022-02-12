// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./libraries/Ownable.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IProfile.sol";
import "./libraries/SafeMath.sol";
import "./libraries/TransferHelper.sol";

contract Bazaar is Ownable {
    using SafeMath for uint256;

    event OrderPlaced(Order order);
    event OrderCanceled(uint256 indexed orderIdx);
    event OrderWithdrew(uint256 indexed orderIdx);
    event OrderSold(uint256 indexed orderIdx, address indexed buyer);
    event DeliveryApproved(uint256 indexed orderIdx);

    enum OrderState {
        Placed,
        Soled,
        Conflict,
        Finished,
        Closed,
        Withdrew
    }

    struct SourceAsset {
        string symbol;
        bool deleted;
    }

    struct Order {
        uint256 id;
        address seller;
        address buyer;
        uint256 createdAt;
        uint256 deadline; // timestamp of order deadline
        OrderState state;
        uint256 sourceAsset; // index of source asset
        address targetAsset;
        uint256 sourceAmount;
        uint256 targetAmount;
    }

    Order[] public orders;
    SourceAsset[] public allowedSourceAssets;

    address public feeTo;
    address public feeToSetter;
    address public profileContract;

    uint256 public guaranteePercent; // seller guarantee amount by fraction of 1000
    uint256 public cancellationFee; // cancellation fee by fraction of 1000
    uint256 public sellFee; // sell fee by fraction of 1000
    uint256 public buyFee; // buy fee by fraction of 1000

    modifier onlyProfileHolders() {
        require(
            IProfile(profileContract).registered(msg.sender),
            "BAZAAR: NOT_REGISTERED"
        );
        _;
    }

    modifier onlySeller(uint256 _orderIdx) {
        require(msg.sender == orders[_orderIdx].seller, "BAZAAR: ONLY_SELLER");
        _;
    }

    modifier onlyBuyer(uint256 _orderIdx) {
        require(msg.sender == orders[_orderIdx].buyer, "BAZAAR: ONLY_BUYER");
        _;
    }

    modifier validSourceAsset(uint256 _idx) {
        require(
            (_idx < allowedSourceAssets.length) &&
                !allowedSourceAssets[_idx].deleted,
            "BAZAAR: INVALID_SOURCE_ASSET"
        );
        _;
    }

    modifier validOrder(uint256 _idx) {
        require(_idx < orders.length, "BAZAAR: INVALID_ORDER");
        _;
    }

    modifier inState(uint256 _orderIdx, OrderState state) {
        require(
            orders[_orderIdx].state == state,
            "BAZAAR: INVALID_ORDER_STATE"
        );
        _;
    }

    modifier notExpired(uint256 _orderIdx) {
        require(
            block.timestamp < orders[_orderIdx].deadline,
            "BAZAAR: ORDER_DEADLINE_EXCEEDED"
        );
        _;
    }

    modifier expired(uint256 _orderIdx) {
        require(
            block.timestamp >= orders[_orderIdx].deadline,
            "BAZAAR: ORDER_DEADLINE_NOT_EXCEEDED"
        );
        _;
    }

    constructor(address _profileContract) {
        profileContract = _profileContract;
        allowedSourceAssets.push(SourceAsset("GOLD", false));
        guaranteePercent = 10_000; // 10% of sale price
        cancellationFee = 1_000; // 1% of sale price
        sellFee = 100; // 0.1 of sale price
        buyFee = 100; // 0.1 of sale price
        feeToSetter = msg.sender;
        feeTo = msg.sender;
    }

    /**
     * @dev calculate guarantee amount
     */
    function calcGuarantee(uint256 _orderIdx) internal view returns (uint256) {
        Order storage order = orders[_orderIdx];

        return order.targetAmount.mul(guaranteePercent).div(100_000);
    }

    /**
     * @dev calculate sell fee
     */
    function calcSellFee(uint256 _orderIdx) internal view returns (uint256) {
        Order storage order = orders[_orderIdx];

        return order.targetAmount.mul(sellFee).div(100_000);
    }

    /**
     * @dev calculate buy fee
     */
    function calcBuyFee(uint256 _orderIdx) internal view returns (uint256) {
        Order storage order = orders[_orderIdx];

        return order.targetAmount.mul(buyFee).div(100_000);
    }

    /**
     * @dev calculate cancellation fee
     */
    function calcCancellationFee(uint256 _orderIdx)
        internal
        view
        returns (uint256)
    {
        Order storage order = orders[_orderIdx];

        return order.targetAmount.mul(cancellationFee).div(100_000);
    }

    /**
     * @dev set fee to account
     */
    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, "BAZAAR: FORBIDDEN");
        feeTo = _feeTo;
    }

    /**
     * @dev set fee to setter account
     */
    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, "BAZAAR: FORBIDDEN");
        feeToSetter = _feeToSetter;
    }

    /**
     * @dev set guarantee percent
     */
    function setGuaranteePercent(uint256 _value) public onlyOwner {
        guaranteePercent = _value;
    }

    /**
     * @dev set cancellation fee
     */
    function setCancellationFee(uint256 _value) public onlyOwner {
        cancellationFee = _value;
    }

    /**
     * @dev set sell fee
     */
    function setSellFee(uint256 _value) public onlyOwner {
        sellFee = _value;
    }

    /**
     * @dev set buy fee
     */
    function setBuyFee(uint256 _value) public onlyOwner {
        buyFee = _value;
    }

    /**
     * @dev change profile contract address
     */
    function setProfile(address addr) public onlyOwner {
        profileContract = addr;
    }

    /**
     * @dev add new allowed source asset
     */
    function addAllowedSourceAsset(string memory _symbol) public onlyOwner {
        allowedSourceAssets.push(SourceAsset(_symbol, false));
    }

    /**
     * @dev delete allowed source asset
     */
    function deleteAllowedSourceAsset(uint256 _idx) public onlyOwner {
        allowedSourceAssets[_idx].deleted = true;
    }

    /**
     * @dev create a new order
     */
    function placeOrder(
        uint256 sourceAsset,
        uint256 sourceAmount,
        address targetAsset,
        uint256 targetAmount,
        uint256 timeout
    )
        public
        onlyProfileHolders
        validSourceAsset(sourceAsset)
        returns (uint256)
    {
        require(sourceAmount > 0, "BAZAAR: INVALID_SOURCE_AMOUNT");
        require(targetAmount > 0, "BAZAAR: INVALID_TARGET_AMOUNT");

        Order memory order;
        order.id = orders.length;
        order.seller = msg.sender;
        order.deadline = block.timestamp + timeout;
        order.createdAt = block.timestamp;
        order.sourceAsset = sourceAsset;
        order.sourceAmount = sourceAmount;
        order.targetAsset = targetAsset;
        order.targetAmount = targetAmount;
        order.state = OrderState.Placed;

        orders.push(order);

        // ((targetAmount * guaranteePercent) / 1000) / 100
        uint256 _guaranteeAmount = targetAmount.mul(guaranteePercent).div(
            100_000
        );

        TransferHelper.safeTransferFrom(
            order.targetAsset,
            msg.sender,
            address(this),
            _guaranteeAmount
        );

        emit OrderPlaced(order);

        return orders.length - 1;
    }

    /**
     * @dev seller cancel's an order
     */
    function cancel(uint256 _orderIdx)
        public
        validOrder(_orderIdx)
        onlySeller(_orderIdx)
        inState(_orderIdx, OrderState.Placed)
        notExpired(_orderIdx)
    {
        Order storage order = orders[_orderIdx];

        order.state = OrderState.Closed;

        uint256 _guaranteeAmount = calcGuarantee(_orderIdx);
        uint256 _cancellationFee = calcCancellationFee(_orderIdx);

        uint256 _toReturn = _guaranteeAmount.sub(_cancellationFee);

        // transfer cancellation fee
        TransferHelper.safeTransfer(order.targetAsset, feeTo, _cancellationFee);

        // return rest of guarantee deposit
        TransferHelper.safeTransfer(order.targetAsset, order.seller, _toReturn);

        emit OrderCanceled(_orderIdx);
    }

    /**
     * @dev withdraw guarantee amount for expired orders
     */
    function withdraw(uint256 _orderIdx)
        public
        validOrder(_orderIdx)
        onlySeller(_orderIdx)
        inState(_orderIdx, OrderState.Placed)
        expired(_orderIdx)
    {
        Order storage order = orders[_orderIdx];

        order.state = OrderState.Withdrew;

        uint256 _guaranteeAmount = calcGuarantee(_orderIdx);

        TransferHelper.safeTransfer(
            order.targetAsset,
            order.seller,
            _guaranteeAmount
        );

        emit OrderWithdrew(_orderIdx);
    }

    /**
     * @dev buy an asset
     */
    function buy(uint256 _orderIdx)
        public
        onlyProfileHolders
        validOrder(_orderIdx)
        inState(_orderIdx, OrderState.Placed)
        notExpired(_orderIdx)
    {
        Order storage order = orders[_orderIdx];
        order.buyer = msg.sender;
        order.state = OrderState.Soled;

        uint256 _buyFee = calcBuyFee(_orderIdx);

        uint256 _totalDepo = order.targetAmount.add(_buyFee);

        TransferHelper.safeTransferFrom(
            order.targetAsset,
            msg.sender,
            address(this),
            _totalDepo
        );

        emit OrderSold(_orderIdx, msg.sender);
    }

    /**
     * @dev buyer approves that recieved asset
     */
    function approveDelivery(uint256 _orderIdx)
        public
        validOrder(_orderIdx)
        onlyBuyer(_orderIdx)
        inState(_orderIdx, OrderState.Soled)
        expired(_orderIdx)
    {
        Order storage order = orders[_orderIdx];
        order.state = OrderState.Finished;

        uint256 _guaranteeAmount = calcGuarantee(_orderIdx);
        uint256 _buyFee = calcBuyFee(_orderIdx);
        uint256 _sellFee = calcSellFee(_orderIdx);

        uint256 _totalFee = _buyFee.add(_sellFee);

        uint256 _transferAmount = order.targetAmount.add(_guaranteeAmount).sub(
            _sellFee
        );

        TransferHelper.safeTransfer(
            order.targetAsset,
            order.seller,
            _transferAmount
        );

        if (feeTo != address(0)) {
            TransferHelper.safeTransfer(order.targetAsset, feeTo, _totalFee);
        }

        emit DeliveryApproved(_orderIdx);
    }

    function fetchOrders(
        uint256 fromID,
        uint256 maxLength,
        address buyer,
        address seller,
        OrderState[] memory states,
        uint256 fromDate,
        uint256 toDate
    ) public view returns (Order[] memory) {
        uint256 count = 0;
        Order[] memory _upfrontOrders = new Order[](orders.length);

        for (uint256 i = fromID; i < orders.length; i++) {
            if (count >= maxLength) break;

            Order storage _order = orders[i];

            if (buyer != address(0)) {
                if (_order.buyer != buyer) {
                    continue;
                }
            }

            if (seller != address(0)) {
                if (_order.seller != seller) {
                    continue;
                }
            }

            if (fromDate > 0) {
                if (_order.createdAt < fromDate) {
                    continue;
                }
            }

            if (toDate > 0) {
                if (_order.createdAt > toDate) {
                    continue;
                }
            }

            if (states.length > 0) {
                bool found = false;

                for (uint256 l = 0; l < states.length; l++) {
                    if (_order.state == states[l]) {
                        found = true;
                        break;
                    }
                }

                if (!found) continue;
            }

            _upfrontOrders[count] = _order;
            count++;
        }

        Order[] memory _orders = new Order[](count);

        for (uint256 i = 0; i < count; i++) {
            _orders[i] = _upfrontOrders[i];
        }

        return _orders;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.11;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
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
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
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
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.4.0;

import './Context.sol';

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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.4.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IProfile {
    function registered(address account) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}