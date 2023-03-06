/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

//SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/utils/Context.sol
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity 0.8.19;

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

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

interface IRCL20 {
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

contract BridgeSwap is Ownable , ReentrancyGuard {
    mapping(address => bool) authorizedLiquidityAddresses;
    mapping(address => bool) authorizedWithdrawAddresses;
    mapping(address => Tdetails) public TDetails;
    struct Tdetails {
        address Faddress;
        uint256 Famount;
        bool swaped;
    }
    uint256 public minimumLock;

    event Deposit(address _from, uint256 _value);
    event Swaped(address _from, uint256 _value, bool _status);
    event Liquidized(address _from, uint256 _value);
    event Transfer(address _from, uint256 _value);

    constructor(uint256 _amount) {
        minimumLock = _amount;
    }

    // Authorized Liquidity modifier
    modifier authorizedLiquidity() {
        require(
            authorizedLiquidityAddresses[msg.sender] == true,
            "Only authorized address can add liquidity"
        );
        _;
    }

    // Authorized Withdraw modifier
    modifier authorizedWithdraw() {
        require(
            authorizedWithdrawAddresses[msg.sender] == true,
            "Only authorized address can add widthraw"
        );
        _;
    }    

    // Update minimum locked tokes
    function updateMinimumAmount(uint256 _amount) public onlyOwner {
        minimumLock = _amount;
    }

    // Add authorized withdraw address
    function addAuthorizedWithdrawAddress(address newAddress) public onlyOwner {
        authorizedWithdrawAddresses[newAddress] = true;
    }

    // Add authorized liquidity address
    function addAuthorizedLiquidityAddress(address newAddress)
        public
        onlyOwner
    {
        authorizedLiquidityAddresses[newAddress] = true;
    }

    // Remove authorized withdraw address
    function removeAuthorizedWithdrawAddress() public authorizedWithdraw {
        authorizedWithdrawAddresses[msg.sender] = false;
    }

    // Remove authorized liquidity address
    function removeAuthorizedLiquidityAddress() public authorizedLiquidity {
        authorizedLiquidityAddresses[msg.sender] = false;
    }

    // Rmove authorizedwithdraw address for contract owner
    function removeAuthorizedWithdrawforOwner(address _address) public onlyOwner {
        authorizedWithdrawAddresses[_address] = false;
    }

    // Rmove authorizedliquidity address for contract owner
    function removeAuthorizedLiquidityforOwner(address _address) public onlyOwner {
        authorizedLiquidityAddresses[_address] = false;
    }

    // Get list of authorized withdraw address
    function isAddressAuthorizedWithdraw(address _address)
        public
        view
        returns (bool)
    {
        return authorizedWithdrawAddresses[_address];
    }

    // Get list of authorized liquidity address
    function isAddressAuthorizedLiquidity(address _address)
        public
        view
        returns (bool)
    {
        return authorizedLiquidityAddresses[_address];
    }

    // Deposit token for user
    function deposit(address _token, uint256 _amount) public nonReentrant {
        TDetails[msg.sender] = Tdetails(_token, _amount, false);
        require (IRCL20(_token).transferFrom(msg.sender, address(this), _amount));       
        emit Deposit(msg.sender, _amount);
    }

    // Deposit native token for user.
    function depositNativeCoin() public payable nonReentrant  {
        TDetails[msg.sender] = Tdetails(msg.sender, msg.value, false);
        emit Deposit(msg.sender, msg.value);
    }

    // Withdraw token
    function withdrawOwner(address _token) public authorizedWithdraw nonReentrant {
        uint256 totalAmount = IRCL20(_token).balanceOf(address(this));
        uint256 balanceAmount = totalAmount - minimumLock;
        require(
            balanceAmount > 0,
            "Insufficient balance after subtraction minimum amount"
        );
        require (IRCL20(_token).approve(msg.sender, balanceAmount));
        require (IRCL20(_token).transfer(msg.sender, balanceAmount));
    }

    // Withdraw native coin
    function withdrawNativeCoinOwner() public authorizedWithdraw nonReentrant{
        uint256 totalAmount = address(this).balance;
        uint256 balanceAmount = totalAmount - minimumLock;
        require(
            balanceAmount > 0,
            "Insufficient balance after subtraction minimum amount"
        );
        payable(msg.sender).transfer(balanceAmount);
    }

    // Swap function for swap tokens.
    function swap(
        address _token,
        uint256 _amount,
        address _address
    ) public onlyOwner {
        uint256 totalAmount = IRCL20(_token).balanceOf(address(this));
        require(_amount <= totalAmount, "Insufficient balance");
        require (IRCL20(_token).approve(_address, _amount));
        require (IRCL20(_token).transfer(_address, _amount));
        emit Transfer(_address, _amount);
    }

    // Swap native coin.
    function swapNativeCoin(uint256 _amount, address _address)
        public
        onlyOwner
    {
        payable(_address).transfer(_amount);
        emit Transfer(_address, _amount);
    }

    // Add liquidity token for authorized user
    function addLiquidity(address _token, uint256 _amount)
        public
        authorizedLiquidity nonReentrant
    {
        require( IRCL20(_token).transferFrom(
            msg.sender,
            payable(address(this)),
            _amount
        ));
        emit Liquidized(msg.sender, _amount);
    }

    // Add liquidity native coin for authorized user
    function addLiquidityNativeCoin() public payable authorizedLiquidity nonReentrant{
        emit Liquidized(msg.sender, msg.value);
    }

    // Update swaped condition
    function swaped(address _address, uint256 _amount) public onlyOwner {
        require(
            TDetails[_address].swaped == false,
            "Transaction already completed"
        );
        TDetails[_address].swaped = true;
        emit Swaped(_address, _amount, true);
    }

    // Get token balance from this contract
    function getContractBalance(address _token) public view returns (uint256) {
        return IRCL20(_token).balanceOf(address(this));
    }

    // Get native coin balance from this contract
    function getbalance() public view returns (uint256) {
        return address(this).balance;
    }
}