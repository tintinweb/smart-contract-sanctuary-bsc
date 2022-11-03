// SPDX-License-Identifier: MIT

pragma solidity =0.8.16;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";
import {MarketOrder} from "./ConsiderationStructs.sol";
import "./TradeStorage.sol";

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


interface IERC721 {

    /**
         * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    function tokenIdMarker(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IFeeCollector {

    function serviceCharge(address offerToken, uint256 identifier, address quoteToken, uint256 quoteAmount) external returns(address, uint256, address, uint256);

}



contract TradeNFT is Ownable, TradeStorage {

    event SetFeeRatio(uint256 oldFeeRatio, uint256 newFeeRatio);
    event SetFeeCollector(address oldFeeCollector, address newFeeCollector);
    event PostAnOrder(address offerer, uint256 orderId, address offerToken, uint256 identifier, uint256 offerAmount, uint256 endTime);
    event Cancel(uint256 orderId, address offerer, address offerToken, uint256 identifier);
    event EditOrder(uint256 orderId, uint256 offerAmount, uint256 endTime);
    event FulfillBasicOrder(address offerer, address offerToken, uint256 identifier, address fulfiller, address quoteToken, uint256 considerationAmount, uint256 fee);


    constructor(address _feeCollector, uint256 _feeRatio){
        feeCollector = _feeCollector;
        feeRatio = _feeRatio;
    }


    function remove(uint256 orderId, address offerer) internal {
        delete marketOrder[orderId];

        uint len = marketOrderId.length;
        uint index = len;
        for (uint i; i < marketOrderId.length; i++) {
            if (marketOrderId[i] == orderId) {
                index = i;
                break;
            }
        }
        marketOrderId[index] = marketOrderId[len - 1];
        marketOrderId.pop();

        uint256[] storage offererOrderId = offererOrder[offerer];
        len = offererOrderId.length;
        index = len;
        for (uint j; j < offererOrderId.length; j++) {
            if (offererOrderId[j] == orderId) {
                index = j;
                break;
            }
        }
        offererOrderId[index] = offererOrderId[len - 1];
        offererOrderId.pop();
    }

    function fulfillBasicOrder(uint256 orderId, uint256 offerAmount) external returns(bool){
        MarketOrder memory order = marketOrder[orderId];
        require(order.orderId == orderId, "Order does not exist");
        require(order.endTime > block.timestamp, "Order has expired");
        require(offerAmount == order.offerAmount, "Bid error");

        IERC20(quoteToken).transferFrom(msg.sender, address(this), offerAmount);

        uint256 fee = order.offerAmount * feeRatio / 1e18;
        uint256 amount = order.offerAmount - fee;

        IERC721(order.offerToken).safeTransferFrom(order.offerer, msg.sender, order.identifier);

        IERC20(quoteToken).transfer(order.offerer, amount);

        IERC20(quoteToken).transfer(feeCollector, fee);
        IFeeCollector(feeCollector).serviceCharge(order.offerToken, order.identifier, quoteToken, fee);

        remove(orderId, order.offerer);
        orderActivity[order.offerToken][order.identifier] = 2;

        emit FulfillBasicOrder (order.offerer, order.offerToken, order.identifier, msg.sender, quoteToken, amount, fee);
        return true;
    }


    function cancel(uint256 orderId) external returns(bool){
        MarketOrder memory order = marketOrder[orderId];
        require(order.orderId == orderId, "Order does not exist");
        require(order.offerer == msg.sender, "Not order issuer");

        remove(orderId, msg.sender);
        orderActivity[order.offerToken][order.identifier] = 3;
        emit Cancel(order.orderId, order.offerer, order.offerToken, order.identifier);
        return true;
    }


    function postAnOrder(
        address offerToken,
        uint128 identifier,
        uint128 orderType,
        uint256 offerAmount,
        uint256 endTime
    ) external returns(uint256){
        bool success = IERC721(offerToken).isApprovedForAll(msg.sender, address(this));
        require(success, "NFT not approved");

        address owner = IERC721(offerToken).ownerOf(identifier);
        require(owner == msg.sender, "Order does not exist");
        require(endTime > block.timestamp, "Wrong order market online time");

        require(orderActivity[offerToken][identifier] != 1, "The current NFT cannot be listed repeatedly");

        _orderId += 1;
        MarketOrder memory order;
        order.orderId = _orderId;
        order.offerer = msg.sender;
        order.offerToken = offerToken;
        order.identifier = identifier;
        order.offerAmount = offerAmount;
        order.orderType = orderType;
        order.endTime = endTime;

        marketOrder[_orderId] = order;
        marketOrderId.push(_orderId);
        offererOrder[msg.sender].push(_orderId);

        orderActivity[offerToken][identifier] = 1;
        emit PostAnOrder(msg.sender, _orderId, offerToken, identifier, offerAmount, endTime);
        return _orderId;
    }


    function editOrder(
        uint128 orderId,
        uint128 offerAmount,
        uint256 endTime
    ) external returns(bool){
        MarketOrder storage order = marketOrder[orderId];
        require(order.orderId == orderId, "Order does not exist");
        require(order.offerer == msg.sender, "Not order issuer");

        order.offerAmount = offerAmount;
        if(endTime > 0){
            require(endTime > block.timestamp, "Wrong order market online time");
            order.endTime = endTime;
        }
        emit EditOrder(order.orderId, order.offerAmount, endTime);
        return true;
    }

    function allMarketOrder() external view returns(MarketOrder[] memory market){
        uint256 length = marketOrderId.length;
        market = new MarketOrder[](length);

        uint256 index;
        for(uint i; i < marketOrderId.length; i++){
            MarketOrder memory order = marketOrder[marketOrderId[i]];
            if(order.endTime > block.timestamp){
                market[index] = order;
                index += 1;
            }
        }
    }


    function allFererOrder(address offerer)external view returns(MarketOrder[] memory market) {
        uint256[] memory offererOrderIds = offererOrder[offerer];

        uint256 length = offererOrderIds.length;
        market = new MarketOrder[](length);

        uint256 index;
        for(uint i; i < length; i++){
            MarketOrder memory order = marketOrder[offererOrderIds[i]];
            if(order.endTime > block.timestamp){
                market[index] = order;
                index += 1;
            }
        }
    }


    function setFeeRatio(uint256 newFeeRatio) external onlyOwner {
        require(newFeeRatio > 0, "Parameter error");
        uint256 old = feeRatio;
        feeRatio = newFeeRatio;
        emit SetFeeRatio(old, newFeeRatio);
    }

    function setFeeCollector(address newFeeCollector) external onlyOwner {
        require(newFeeCollector != address(0), "Fee collector cannot be set to zero address");
        address old = feeCollector;
        feeCollector = newFeeCollector;
        emit SetFeeCollector(old, newFeeCollector);
    }

    function getMarketOrder(uint256 orderId) external view returns(MarketOrder memory) {
        MarketOrder memory order = marketOrder[orderId];
        return order;
    }

    function activity(address nft, uint256 tokenId) external view returns(uint256) {
        return orderActivity[nft][tokenId];
    }

}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.16;

import {MarketOrder} from "./ConsiderationStructs.sol";


contract TradeStorage {

    address public feeCollector;

    address public constant quoteToken = 0x55d398326f99059fF775485246999027B3197955;

    uint256 public feeRatio;

    uint256 internal _orderId;
    uint256[] internal marketOrderId;

    mapping(uint256 => MarketOrder) internal marketOrder;

    mapping(address => mapping(uint256 => uint256)) internal orderActivity;

    mapping(address => uint256[]) internal offererOrder;


}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.16;

    struct MarketOrder {
        uint256 orderId;
        address offerer;
        address offerToken;
        uint256 identifier;
        uint256 offerAmount;
        uint256 orderType;
        uint256 endTime;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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