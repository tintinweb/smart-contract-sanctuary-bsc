/**
 *Submitted for verification at BscScan.com on 2022-12-23
*/

// ██████  ███████ ██    ██  ██████  ██      ██    ██ ███████ ██  ██████  ███    ██        ██  ██████                       
// ██   ██ ██      ██    ██ ██    ██ ██      ██    ██    ███  ██ ██    ██ ████   ██        ██ ██    ██                      
// ██████  █████   ██    ██ ██    ██ ██      ██    ██   ███   ██ ██    ██ ██ ██  ██        ██ ██    ██                      
// ██   ██ ██       ██  ██  ██    ██ ██      ██    ██  ███    ██ ██    ██ ██  ██ ██        ██ ██    ██                      
// ██   ██ ███████   ████    ██████  ███████  ██████  ███████ ██  ██████  ██   ████   ██   ██  ██████                       


// ███████ ███    ███  █████  ██████  ████████      ██████  ██████  ███    ██ ████████ ██████   █████   ██████ ████████ 
// ██      ████  ████ ██   ██ ██   ██    ██        ██      ██    ██ ████   ██    ██    ██   ██ ██   ██ ██         ██    
// ███████ ██ ████ ██ ███████ ██████     ██        ██      ██    ██ ██ ██  ██    ██    ██████  ███████ ██         ██    
//      ██ ██  ██  ██ ██   ██ ██   ██    ██        ██      ██    ██ ██  ██ ██    ██    ██   ██ ██   ██ ██         ██    
// ███████ ██      ██ ██   ██ ██   ██    ██         ██████  ██████  ██   ████    ██    ██   ██ ██   ██  ██████    ██

//Revoluzion Ecosystem
//WEB: https://revoluzion.io
//DAPP: https://revoluzion.app

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }
}

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

    function _msgValue() internal view virtual returns (uint256) {
        return msg.value;
    }
}

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
abstract contract Auth is Context {
    

    /** DATA **/
    address private _owner;
    
    mapping(address => bool) internal authorizations;

    
    /** CONSTRUCTOR **/

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = _msgSender();
        authorizations[_msgSender()] = true;
    }

    /** FUNCTION **/

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
     * @dev Throws if called by any account other authorized accounts.
     */
    modifier authorized() {
        require(isAuthorized(_msgSender()), "Ownable: caller is not an authorized account");
        _;
    }

    /**
     * @dev Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * @dev Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * @dev Check if address is owner
     */
    function isOwner(address adr) public view returns (bool) {
        return adr == owner();
    }

    /**
     * @dev Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }
}

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

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

contract RevoluzionPaymentReceiver is Auth, Pausable, ReentrancyGuard {

    // LIBRARY
    
    using Counters for Counters.Counter;

    // DATA

    Counters.Counter public numPaymentMade;

    address private constant DEAD = address(0xdead);
    address private constant ZERO = address(0);
    address public receiver;

    struct PaymentItem {
        address senderAddress;
        address receiverAddress;
        address tokenAddress;
        uint256 amountPaid;
        string paidFor;
        bool nativePayment;
        bool tokenPayment;
    }

    mapping(uint256 => PaymentItem) public idToPaymentItem;

    // CONSTRUCTOR

    constructor(
        address receiver_
    ) Auth () {
        require(receiver_ != ZERO, "Payment Receiver: Cannot send to null address.");
        require(receiver_ != DEAD, "Payment Receiver: Cannot send to dead address.");
        receiver = receiver_;
    }

    // EVENT
    
    event EditPaymentInfo(uint256 paymentID, string oldInfo, string newInfo);
    event PaymentInToken(address sender, address receiver, address tokenAddress, uint256 amount, string paymentInfo);
    event PaymentInNative(address sender, address receiver, uint256 amount, string paymentInfo);

    // FUNCTION
    
    receive() external payable {}

    function pause() external whenNotPaused authorized {
        _pause();
    }
    
    function unpause() external whenPaused onlyOwner {
        _unpause();
    }
    
    function wTokens(address to, IERC20 tokenAddress) external authorized {
        require(
            IERC20(tokenAddress).transfer(
                to,
                IERC20(tokenAddress).balanceOf(address(this))
            ),
            "Withdraw Tokens: Transfer transaction might fail."
        );
    }

    function wNative() external nonReentrant onlyOwner {
        require(_msgSender() != receiver, "Withdraw Native: Receiver cannot call this function.");
        require(receiver != ZERO, "Withdraw Native: Cannot send to null address.");
        require(receiver != DEAD, "Withdraw Native: Cannot send to dead address.");
        payable(receiver).transfer(address(this).balance);
    }
    
    function tokenPayment(uint256 amount, address tokenAddress, string memory paymentInfo) external whenNotPaused {
        require(IERC20(tokenAddress).balanceOf(_msgSender()) >= amount, "Token Payment: Insufficient balance.");
        createPaymentItem(_msgSender(), receiver, tokenAddress, amount, paymentInfo, false, true);
        emit PaymentInToken(_msgSender(), receiver, tokenAddress, amount, paymentInfo);
        require(
            IERC20(tokenAddress).transfer(
                receiver,
                amount
            ),
            "Token Payment: Transfer transaction might fail."
        );
    }

    function nativePayment(uint256 amount, string memory paymentInfo) external payable nonReentrant whenNotPaused {
        require(amount <= _msgSender().balance, "Native Payment: Insufficient balance.");
        require(_msgValue() == amount, "Native Payment: Please transfer the exact amount.");
        createPaymentItem(_msgSender(), receiver, ZERO, amount, paymentInfo, true, false);
        emit PaymentInNative(_msgSender(), receiver, amount, paymentInfo);
        payable(receiver).transfer(amount);
    }
    
    function createPaymentItem(address senderAddress_, address receiverAddress_, address tokenAddress_, uint256 amountPaid_, string memory paidFor_, bool nativePayment_, bool tokenPayment_) internal whenNotPaused {
        numPaymentMade.increment();
        uint256 _paymentID = numPaymentMade.current();

        idToPaymentItem[_paymentID] = PaymentItem(senderAddress_, receiverAddress_, tokenAddress_, amountPaid_, paidFor_, nativePayment_, tokenPayment_);
    }

    function editPaymentInfo(uint256 paymentID, string memory newInfo) external onlyOwner {
        string memory oldInfo = idToPaymentItem[paymentID].paidFor;
        idToPaymentItem[paymentID].paidFor = newInfo;
        emit EditPaymentInfo(paymentID, oldInfo, newInfo);
    }

    function updateReceiver(address newReceiver) external authorized {
        require(receiver != newReceiver, "Update Receiver: Cannot set the same receiver address.");
        receiver = newReceiver;
    }

}