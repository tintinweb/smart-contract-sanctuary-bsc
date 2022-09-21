/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: EscrowContract.sol

pragma solidity >=0.8.0 <0.9.0;




contract EscrowContract is Ownable {
    enum Status {
        NEUTRAL,
        CONFIRM,
        CANCEL
    }

    struct Deal {
        address seller;
        address buyer;
        uint256 amount;
        uint8 fee;
        Status sellerStatus;
        Status buyerStatus;
        Status escrowAgentStatus;
        Status status;
    }

    /// Not permitted
    error NotPermitted();

    /// New deal creation paused
    error NewDealCreationPaused();

    /// Insufficient amount
    error InsufficientAmount(uint256 amount);

    event DealCreated(bytes32 indexed dealId, Deal deal);
    event DealConfirmed(bytes32 indexed dealId, Deal deal);
    event DealCanceled(bytes32 indexed dealId, Deal deal);
    event DealChanged(bytes32 indexed dealId, Deal deal);

    mapping(bytes32 => Deal) public deals;
    mapping(bytes32 => bool) isIdTaken;
    bytes32[] dealIds;
    address escrow;

    bool paused = false;

    uint8 percentageFee = 4;
    IERC20 public BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    uint256 private withdrawableAmount;

    constructor(address escrow_agent) {
        escrow = escrow_agent;
    }

    function getDealStatus(
        Status sellerStatus,
        Status buyerStatus,
        Status escrowStatus
    ) private pure returns (Status) {
        Status status = Status.NEUTRAL;
        if (
            (sellerStatus == Status.CONFIRM && buyerStatus == Status.CONFIRM) ||
            (sellerStatus == Status.CONFIRM && escrowStatus == Status.CONFIRM) ||
            (buyerStatus == Status.CONFIRM && escrowStatus == Status.CONFIRM)
        ) status = Status.CONFIRM;
        else if (
            (sellerStatus == Status.CANCEL && buyerStatus == Status.CANCEL) ||
            (sellerStatus == Status.CANCEL && escrowStatus == Status.CANCEL) ||
            (buyerStatus == Status.CANCEL && escrowStatus == Status.CANCEL)
        ) status = Status.CANCEL;
        return status;
    }

    function getDeal(bytes32 id) public view returns (Deal memory) {
        Deal memory deal = deals[id];
        return deal;
    }

    function _confirmDeal(bytes32 id) private {
        uint256 fee = deals[id].fee * deals[id].amount / 100;
        require(BUSD.transfer(deals[id].seller, deals[id].amount - fee), "wtf man");

        withdrawableAmount += fee;
        deals[id].status = Status.CONFIRM;
        emit DealConfirmed(id, deals[id]);
    }

    function _cancelDeal(bytes32 id) private {
        BUSD.transfer(deals[id].buyer, deals[id].amount);
        deals[id].status = Status.CANCEL;
        emit DealCanceled(id, deals[id]);
    }

    function _checkDealStatus(bytes32 id) private {
        Status currentStatus = getDealStatus(
            deals[id].sellerStatus,
            deals[id].buyerStatus,
            deals[id].escrowAgentStatus
        );
        if (currentStatus == Status.CONFIRM) _confirmDeal(id);
        else if (currentStatus == Status.CANCEL) _cancelDeal(id);
    }

    function createDeal(address seller, uint256 amount)
        external
        returns (bytes32)
    {
        if (paused) revert NewDealCreationPaused();
        BUSD.transferFrom(msg.sender, address(this), amount);
        Deal memory new_deal = Deal({
            seller: seller,
            buyer: msg.sender,
            amount: amount,
            fee: percentageFee,
            sellerStatus: Status.NEUTRAL,
            buyerStatus: Status.NEUTRAL,
            escrowAgentStatus: Status.NEUTRAL,
            status: Status.NEUTRAL
        });
        bytes32 newDealId = _generateNewHash(seller, msg.sender, amount);

        deals[newDealId] = new_deal;
        isIdTaken[newDealId] = true;
        dealIds.push(newDealId);

        emit DealCreated(newDealId, new_deal);
        return newDealId;
    }

    function confirmDeal(bytes32 id) external {
        require(deals[id].status == Status.NEUTRAL, "Deal is closed");

        if (msg.sender == deals[id].seller)
            deals[id].sellerStatus = Status.CONFIRM;
        else if (msg.sender == deals[id].buyer)
            deals[id].buyerStatus = Status.CONFIRM;
        else if (msg.sender == escrow)
            deals[id].escrowAgentStatus = Status.CONFIRM;
        else revert NotPermitted();
        
        emit DealChanged(id, deals[id]);
        _checkDealStatus(id);
    }

    function _generateNewHash(
        address seller,
        address sender,
        uint256 value
    ) private view returns (bytes32) {
        uint32 nonce = 0;
        bytes32 newDealId = keccak256(abi.encode(seller, sender, value, nonce));
        while (isIdTaken[newDealId]) {
            newDealId = keccak256(abi.encode(seller, sender, value, ++nonce));
        }

        return newDealId;
    }

    function cancelDeal(bytes32 id) external {
        require(deals[id].status == Status.NEUTRAL, "Deal is closed");
        
        if (msg.sender == deals[id].seller)
            deals[id].sellerStatus = Status.CANCEL;
        else if (msg.sender == deals[id].buyer)
            deals[id].buyerStatus = Status.CANCEL;
        else if (msg.sender == escrow)
            deals[id].escrowAgentStatus = Status.CANCEL;
        else revert NotPermitted();

        emit DealChanged(id, deals[id]);
        _checkDealStatus(id);
    }

    function isPaused(bool newPausedValue) external onlyOwner {
        require(paused != newPausedValue, "Setting the same value");
        paused = newPausedValue;
    }

    function setPercentageFee(uint8 newPercentageFee) external onlyOwner {
        percentageFee = newPercentageFee;
    }

    function withdraw(uint256 amount) external {
        address sender = _msgSender();
        if (sender != owner() && sender != escrow) revert NotPermitted();

        if (amount > withdrawableAmount) revert InsufficientAmount(amount);

        BUSD.transfer(msg.sender, amount);
        withdrawableAmount -= amount;
    }

    function getDealIds() external view returns (bytes32[] memory) {
        return dealIds;
    }


    function getWithdrawableAmount() external onlyOwner returns(uint256) {
        return withdrawableAmount;
    }
}