// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./DtravelProperty.sol";

contract DtravelFactory is Ownable {
    address public configContract;
    mapping(address => bool) private properties;

    event PropertyCreated(uint256 _id, address _property);
    event Book(uint256 bookingId, uint256 bookedTimestamp);
    event Cancel(uint256 bookingId);
    event Payout(uint256 bookingId);

    constructor(address _config) {
        configContract = _config;
    }

    function deployProperty(uint256 _id, address _host) public onlyOwner {
        DtravelProperty property = new DtravelProperty(_id, configContract, address(this), _host);
        properties[address(property)] = true;
        emit PropertyCreated(_id, address(property));
    }

    function book(uint256 bookingId) external {
        emit Book(bookingId, block.timestamp);
    }

    function cancel(uint256 bookingId) external {
        emit Cancel(bookingId);
    }

    function payout(uint256 bookingId) external {
        emit Payout(bookingId);
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./DtravelConfig.sol";
import "./DtravelFactory.sol";

struct Booking {
    uint256 id;
    uint256 checkInTimestamp;
    uint256 checkOutTimestamp;
    uint256 paidAmount;
    address guest;
    address token;
    uint8 status; // 0: in_progress, 1: fulfilled, 2: cancelled, 3: emergency cancelled
}

contract DtravelProperty is Ownable, ReentrancyGuard {
    uint256 public id; // property id
    Booking[] public bookings; // bookings array
    DtravelConfig configContract;
    DtravelFactory factoryContract;
    address host;
    uint256 private constant oneDay = 60 * 60 * 24;

    /**
    @param _id Property Id
    @param _config Contract address of DtravelConfig
    @param _host Wallet address of the owner of this property
    */
    constructor(
        uint256 _id,
        address _config,
        address _factory,
        address _host
    ) {
        id = _id;
        configContract = DtravelConfig(_config);
        factoryContract = DtravelFactory(_factory);
        host = _host;
    }

    modifier onlyBackend() {
        require(msg.sender == configContract.dtravelBackend(), "Only Dtravel is authorized to call this action");

        _;
    }

    modifier onlyHost() {
        require(msg.sender == host, "Only Host is authorized to call this action");

        _;
    }

    function book(
        address _token,
        address _guest,
        uint256 _checkInTimestamp,
        uint256 _checkOutTimestamp,
        uint256 _bookingAmount,
        bytes memory signature
    ) external onlyBackend nonReentrant {
        require(configContract.supportedTokens(_token) == true, "Token is not whitelisted");
        require(_checkInTimestamp > block.timestamp, "Booking for past date is not allowed");
        require(_checkOutTimestamp >= _checkInTimestamp + oneDay, "Booking period should be at least one night");

        bytes32 messageHash = getBookingHash(
            configContract.dtravelBackend(),
            _guest,
            _checkInTimestamp,
            _checkOutTimestamp,
            _bookingAmount
        );
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        require(verify(configContract.dtravelBackend(), ethSignedMessageHash, signature), "Invalid signature");

        require(IERC20(_token).allowance(msg.sender, address(this)) >= _bookingAmount, "Token allowance too low");
        bool isSuccess = _safeTransferFrom(IERC20(_token), msg.sender, address(this), _bookingAmount);
        require(isSuccess == true, "Payment failed");

        uint256 bookingId = bookings.length;
        bookings.push(Booking(bookingId, _checkInTimestamp, _checkOutTimestamp, _bookingAmount, msg.sender, _token, 0));

        factoryContract.book(bookingId);
    }

    function updateBookingStatus(uint256 _bookingId, uint8 _status) internal {
        bookings[_bookingId].status = _status;
    }

    function cancel(uint256 _bookingId) external nonReentrant {
        require(_bookingId < bookings.length, "Booking not found");
        Booking memory booking = bookings[_bookingId];
        require(booking.status == 0, "Booking is already cancelled or fulfilled");
        require(
            msg.sender == host || msg.sender == booking.guest,
            "Only host or guest is authorized to call this action"
        );
        // require(block.timestamp < booking.checkInTimestamp - cancelPeriod, "Cancellation period is over"); @TODO: Uncomment this after demo

        updateBookingStatus(_bookingId, 2);

        // Refund to the guest

        bool isSuccess = IERC20(booking.token).transfer(booking.guest, booking.paidAmount);
        require(isSuccess == true, "Refund failed");

        factoryContract.cancel(_bookingId);
    }

    function emergencyCancel(uint256 _bookingId) external onlyBackend nonReentrant {
        require(_bookingId < bookings.length, "Booking not found");
        Booking memory booking = bookings[_bookingId];
        require(booking.status == 0, "Booking is already cancelled or fulfilled");

        updateBookingStatus(_bookingId, 3);

        // Refund to the guest

        bool isSuccess = IERC20(booking.token).transfer(booking.guest, booking.paidAmount);
        require(isSuccess == true, "Refund failed");
    }

    function fulfill(uint256 _bookingId) external nonReentrant {
        require(_bookingId < bookings.length, "Booking not found");
        Booking memory booking = bookings[_bookingId];
        require(booking.status == 0, "Booking is already cancelled or fulfilled");
        // require(block.timestamp >= booking.checkOutTimestamp, "Booking can be fulfilled only after the checkout date"); @TODO: Uncomment this after demo

        updateBookingStatus(_bookingId, 1);

        // Split the payment
        address dtravelTreasury = configContract.dtravelTreasury();
        uint256 paidAmount = booking.paidAmount;
        uint256 fee = configContract.fee();
        uint256 amountForHost = (paidAmount * (10000 - fee)) / 10000;
        uint256 amountForDtravel = paidAmount - amountForHost;

        IERC20(booking.token).transfer(host, amountForHost);
        IERC20(booking.token).transfer(dtravelTreasury, amountForDtravel);

        factoryContract.payout(_bookingId);
    }

    function bookingHistory() external view returns (Booking[] memory) {
        return bookings;
    }

    function _safeTransferFrom(
        IERC20 token,
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        bool sent = token.transferFrom(sender, recipient, amount);
        return sent;
    }

    function getBookingHash(
        address _signer,
        address _guest,
        uint256 _checkInTimestamp,
        uint256 _checkOutTimestamp,
        uint256 _bookingAmount
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_signer, _guest, _checkInTimestamp, _checkOutTimestamp, _bookingAmount));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function verify(
        address _signer,
        bytes32 ethSignedMessageHash,
        bytes memory signature
    ) public pure returns (bool) {
        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");
        assembly {
            /*
            First 32 bytes stores the length of the signature
            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature
            mload(p) loads next 32 bytes starting at the memory address p into memory
            */
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
        return (r, s, v);
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract DtravelConfig is Ownable {
    uint256 public fee; // fee percentage 5% -> 500, 0.1% -> 10
    address public dtravelTreasury;
    address public dtravelBackend;
    mapping(address => bool) public supportedTokens;

    constructor(
        uint256 _fee,
        address _treasury,
        address[] memory _tokens
    ) {
        fee = _fee;
        dtravelTreasury = _treasury;
        dtravelBackend = msg.sender;
        for (uint256 i = 0; i < _tokens.length; i++) {
            supportedTokens[_tokens[i]] = true;
        }
    }

    function updateFee(uint256 _fee) public onlyOwner {
        require(_fee >= 0 && _fee <= 10000, "Fee must be between 0 and 10000");
        fee = _fee;
    }

    function addSupportedToken(address _token) public onlyOwner {
        supportedTokens[_token] = true;
    }

    function removeSupportedToken(address _token) public onlyOwner {
        supportedTokens[_token] = false;
    }

    function updateTreasury(address _treasury) public onlyOwner {
        dtravelTreasury = _treasury;
    }
}