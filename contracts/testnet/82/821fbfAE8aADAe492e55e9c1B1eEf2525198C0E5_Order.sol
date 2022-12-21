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

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Order is Ownable {
    IERC20 public immutable stablecoin;
    uint256 public constant storeFee = 100; // in bps (basis point, 1/100 of a percent or /10,000)
    uint256 public constant provisionedFee = 20;

    enum State {
        Created,
        Locked,
        Release,
        Inactive
    }

    struct Purchase {
        uint256 price;
        uint256 totalProvisioned;
        address buyer;
        State state;
    }

    mapping(address => mapping(uint256 => Purchase)) public sales;

    error ZeroValue();
    error TooLowValue();
    error PurchaseExists();
    error PurchaseNotExists();
    error PurchaseTransferFailed();
    error SellerAsBuyer();
    error OnlyBuyer();
    error OnlySeller();

    error InvalidState();

    event Add(
        address indexed seller,
        uint256 indexed id,
        address indexed buyer,
        uint256 price
    );
    event Buy(
        address indexed seller,
        uint256 indexed id,
        address indexed buyer,
        uint256 price,
        uint256 provisioned
    );
    event Confirm(
        address indexed seller,
        uint256 indexed id,
        address indexed buyer,
        uint256 sellerAmount,
        uint256 storeAmount
    );
    event Cancel(
        address indexed seller,
        uint256 indexed id,
        address indexed buyer
    );

    constructor(address _stablecoin) {
        stablecoin = IERC20(_stablecoin);
    }

    function add(uint256 _id, uint256 _price, address _buyer) external {
        if (sales[msg.sender][_id].price != 0) revert PurchaseExists();
        if (_price == 0) revert ZeroValue();
        if (_price < 1_000_000) revert TooLowValue();
        if (msg.sender == _buyer) revert SellerAsBuyer();

        sales[msg.sender][_id].price = _price;
        sales[msg.sender][_id].buyer = _buyer;
        sales[msg.sender][_id].state = State.Created;

        emit Add(msg.sender, _id, _buyer, _price);
    }

    function buy(address _seller, uint256 _id) external {
        _validateState(_seller, _id, State.Created);
        if (msg.sender != sales[_seller][_id].buyer) revert OnlyBuyer();

        uint256 price = sales[_seller][_id].price;
        if (price == 0) revert PurchaseNotExists();

        uint256 amount = (price * (100 + provisionedFee)) / 100;
        if (!stablecoin.transferFrom(msg.sender, address(this), amount))
            revert PurchaseTransferFailed();

        sales[_seller][_id].totalProvisioned = amount;

        emit Buy(_seller, _id, msg.sender, price, amount);

        sales[_seller][_id].state = State.Locked;
    }

    function confirm(address _seller, uint256 _id) external {
        _validateState(_seller, _id, State.Locked);
        if (msg.sender != sales[_seller][_id].buyer) revert OnlyBuyer();

        uint256 price = sales[_seller][_id].price;
        uint256 chargeback = sales[_seller][_id].totalProvisioned - price;

        stablecoin.transfer(msg.sender, chargeback);

        uint256 storeAmount = (price * (storeFee)) / 10_000;
        uint256 sellerAmour = price - storeAmount;

        stablecoin.transfer(owner(), storeAmount);
        stablecoin.transfer(_seller, sellerAmour);

        emit Confirm(_seller, _id, msg.sender, sellerAmour, storeAmount);

        sales[_seller][_id].state = State.Release;
    }

    function cancel(uint256 _id) external {
        _validateState(msg.sender, _id, State.Locked);

        stablecoin.transfer(
            sales[msg.sender][_id].buyer,
            sales[msg.sender][_id].totalProvisioned
        );

        emit Cancel(msg.sender, _id, sales[msg.sender][_id].buyer);

        sales[msg.sender][_id].state = State.Inactive;
    }

    function getOrder(uint256 _id, address _seller) external view returns (Purchase memory) {
        return sales[_seller][_id];
    }
    
    function getOrderPrice(uint256 _id, address _seller)
        external
        view
        returns (uint256)
    {
        return sales[_seller][_id].price;
    }

    function getOrderBuyer(uint256 _id, address _seller)
        external
        view
        returns (address)
    {
        return sales[_seller][_id].buyer;
    }

    function getOrderState(uint256 _id, address _seller)
        external
        view
        returns (State)
    {
        return sales[_seller][_id].state;
    }

    function _validateState(
        address _seller,
        uint256 _id,
        State _state
    ) internal view {
        if (sales[_seller][_id].state != _state) revert InvalidState();
    }
}