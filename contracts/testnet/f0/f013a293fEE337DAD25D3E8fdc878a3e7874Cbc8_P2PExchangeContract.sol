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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract P2PExchangeContract is Ownable, Pausable {

    struct OrderData {
        TypeOrder typeOrder;
        address payable owner;
        uint256 amount;
        uint256 price;
        //address token wPi
        address asset;
        //address USDT
        address assetExchange;
        //min amount wPi to trade
        uint256 mintAmount;
        string id;
    }
    // 0 - 1
    enum TypeOrder {BUY, SELL}

    address private token;
    TypeOrder public typeOrder;
    uint256 private mintAmountP2P;

    //Mapping address user to backlist
    mapping(address => bool) public isBlacklisted;
    //Mapping orderId to amount 
    mapping(string => OrderData) public order;
    //Mapping orderId to order exist
    mapping(string => bool) public statusOrder;
    //Mapping token address to exist
    mapping(address => bool) public statusToken;

    //Log event
    event SetBlacklist(address indexed userAddress, bool indexed status);
    event CreateNewOrder(string indexed id, TypeOrder typeOrder, uint256 amount, uint256 price, address asset, address assetExchange, uint256 mintAmount, bool statusOrder);
    event CancelOrder(string indexed id, TypeOrder typeOrder, uint256 amount, uint256 price, address asset, address assetExchange, uint256 mintAmount, bool statusOrder);
    event TradeOrder(string indexed id, address owner,address trader, uint256 amount, uint256 amountAssetExchange, bool statusOrder);
    event SetMinAmountP2P(uint256 mintAmountP2P);
    event SetTokenP2P(address token, bool statusToken);
     //pause contract
    function pause() external virtual onlyOwner {
        _pause();
    }
    //unpause contract
    function unpause() external virtual onlyOwner {
        _unpause();
    }
    //add and remove user to blacklist
    function setBlacklist(address user, bool status) public onlyOwner {
        require(!isBlacklisted[user], "user already blacklist");
        isBlacklisted[user] = status;
        emit SetBlacklist(user, status);
    }
    //check address backlist
    function checkAddressInBlacklist(address user) public view onlyOwner returns (bool) {
        return isBlacklisted[user];
    }
    
    //set mint amount to create order
    function setMinAmountP2P(uint256 value) external virtual onlyOwner {
        mintAmountP2P = value;
        emit SetMinAmountP2P(mintAmountP2P);
    }
    //set token P2P
    function setTokenP2P(address value, bool status) external virtual onlyOwner {
        token = value;
        statusToken[token] = status;
        emit SetTokenP2P(token, statusToken[token]);
    }
    //create new order
    function createNewOrder(OrderData memory data) external virtual {
        require(data.amount >= mintAmountP2P, "amount too min!");
        require(data.mintAmount >= mintAmountP2P, "set amount too min!");
        require(data.owner == msg.sender, "you aren't owner!");
        require(!isBlacklisted[msg.sender], "you in blacklisted!"); 
        require(!statusOrder[data.id], "order id is exist!");
        require(statusToken[data.asset], "token isn't exist!");
        require(statusToken[data.assetExchange], "token isn't exist!");
        if(data.typeOrder == TypeOrder.SELL) {
            require(IERC20(data.asset).allowance(msg.sender, address(this)) >= data.amount, "Insufficient allowance");
            IERC20(data.asset).transferFrom(msg.sender, address(this), data.amount);
        }
        else {
            require(IERC20(data.assetExchange).allowance(msg.sender, address(this)) >= data.amount * data.price, "Insufficient allowance");
            IERC20(data.assetExchange).transferFrom(msg.sender, address(this), data.amount * data.price);
        }
        order[data.id] = data;
        statusOrder[data.id] = true;
        emit CreateNewOrder(data.id, data.typeOrder, data.amount, data.price, data.asset, data.assetExchange, data.mintAmount, statusOrder[data.id]);
    }
    //cancel order 
    function cancelOrder(string memory id) external virtual {
        require(order[id].owner == msg.sender, "you aren't own order!");
        require(statusOrder[id], "order isn't exist!");
        require(order[id].amount >= mintAmountP2P, "amount too min!");
        if(order[id].typeOrder == TypeOrder.SELL) {
           IERC20(order[id].asset).transfer(msg.sender, order[id].amount);
        }
        else {
            IERC20(order[id].assetExchange).transfer(msg.sender, order[id].amount * order[id].price);
        }
        statusOrder[id] = false;
        emit CancelOrder(id, order[id].typeOrder, order[id].amount, order[id].price, order[id].asset, order[id].assetExchange, order[id].mintAmount, statusOrder[order[id].id]);
    }

    //sell order
    function tradeOrder(string memory id, uint256 amountAssetExchange, uint256 amountAsset) external payable virtual {
        require(msg.sender != order[id].owner, "you are own order!");
        require(amountAsset >= order[id].mintAmount, "amount too min!");
        require(statusOrder[id], "order id isn't exist!");
        //amount USDT of order remain
        order[id].amount = order[id].amount - amountAsset;
        if(order[id].typeOrder == TypeOrder.SELL) {
            require(IERC20(order[id].assetExchange).allowance(msg.sender, address(this)) >= amountAssetExchange, "Insufficient allowance");
            IERC20(order[id].assetExchange).transferFrom(msg.sender, address(this), amountAssetExchange);
            IERC20(order[id].asset).transfer(msg.sender, amountAsset);
            IERC20(order[id].assetExchange).transfer(order[id].owner, amountAssetExchange);
        }
        else {
            require(IERC20(order[id].asset).allowance(msg.sender, address(this)) >= amountAsset, "Insufficient allowance");
            IERC20(order[id].asset).transferFrom(msg.sender, address(this), amountAsset);
            IERC20(order[id].assetExchange).transfer(msg.sender, amountAssetExchange);
            IERC20(order[id].asset).transfer(order[id].owner, amountAsset);
        }
        if(order[id].amount <= mintAmountP2P) {
            statusOrder[id] = false;
        }
        emit TradeOrder(id, order[id].owner, msg.sender, order[id].amount, amountAssetExchange, statusOrder[id]);
    }
    receive() external payable {}
}