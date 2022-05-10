// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./DtravelConfig.sol";
import "./DtravelFactory.sol";
import "./DtravelStructs.sol";

enum BookingStatus {
    InProgress,
    PartialPayOut,
    FullyPaidOut,
    CancelledByGuest,
    CancelledByHost,
    EmergencyCancelled
}

struct Booking {
    string id;
    uint256 checkInTimestamp;
    uint256 checkOutTimestamp;
    uint256 balance;
    address guest;
    address token;
    BookingStatus status;
    CancellationPolicy[] cancellationPolicies;
}

contract DtravelProperty is Ownable, ReentrancyGuard {
    uint256 public id; // property id
    Booking[] public bookings; // bookings array
    mapping(string => uint256) public bookingsMap; // booking id to index + 1 in bookings array so the first booking has index 1
    DtravelConfig configContract; // config contract
    DtravelFactory factoryContract; // factory contract
    address host; // host address
    mapping(address => bool) public hostDelegates; // addresses authorized by the host to act in the host's behalf
    uint256 private constant oneDay = 60 * 60 * 24; // one day in seconds

    /**
    @param _id Property Id
    @param _config Contract address of DtravelConfig
    @param _factory Contract address of DtravelFactory
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

    /**
    @notice Modifier to check if the caller is the Dtravel backend
    */
    modifier onlyBackend() {
        require(msg.sender == configContract.dtravelBackend(), "Only Dtravel is authorized to call this action");

        _;
    }

    /**
    @notice Modifier to check if the caller is the host or a delegate approved by the host
    */
    modifier onlyHostOrDelegate() {
        require(
            msg.sender == host || hostDelegates[msg.sender] == true,
            "Only the host or a host's delegate is authorized to call this action"
        );

        _;
    }

    function approve(address delegate) external onlyHostOrDelegate {
        hostDelegates[delegate] = true;
    }

    function revoke(address delegate) external onlyHostOrDelegate {
        hostDelegates[delegate] = false;
    }

    /**
    @param _params Booking data provided by oracle backend
    @param _signature Signature of the transaction
    */
    function book(BookingParameters memory _params, bytes memory _signature) external nonReentrant {
        require(bookingsMap[_params.bookingId] == 0, "Booking already exists");
        require(block.timestamp < _params.bookingExpirationTimestamp, "Booking data is expired");
        require(configContract.supportedTokens(_params.token) == true, "Token is not whitelisted");
        require(_params.checkInTimestamp + oneDay >= block.timestamp, "Booking for past date is not allowed");
        require(
            _params.checkOutTimestamp >= _params.checkInTimestamp + oneDay,
            "Booking period should be at least one night"
        );
        require(_params.cancellationPolicies.length > 0, "Booking should have at least one cancellation policy");

        require(factoryContract.verifyBookingData(_params, _signature), "Invalid signature");

        require(
            IERC20(_params.token).allowance(msg.sender, address(this)) >= _params.bookingAmount,
            "Token allowance too low"
        );
        _safeTransferFrom(_params.token, msg.sender, address(this), _params.bookingAmount);

        bookings.push();
        uint256 bookingIndex = bookings.length - 1;
        for (uint8 i = 0; i < _params.cancellationPolicies.length; i++) {
            bookings[bookingIndex].cancellationPolicies.push(_params.cancellationPolicies[i]);
        }
        bookings[bookingIndex].id = _params.bookingId;
        bookings[bookingIndex].checkInTimestamp = _params.checkInTimestamp;
        bookings[bookingIndex].checkOutTimestamp = _params.checkOutTimestamp;
        bookings[bookingIndex].balance = _params.bookingAmount;
        bookings[bookingIndex].guest = msg.sender;
        bookings[bookingIndex].token = _params.token;
        bookings[bookingIndex].status = BookingStatus.InProgress;

        bookingsMap[_params.bookingId] = bookingIndex + 1;

        // emit Book event
        factoryContract.book(_params.bookingId);
    }

    function updateBookingStatus(string memory _bookingId, BookingStatus _status) internal {
        if (
            _status == BookingStatus.CancelledByGuest ||
            _status == BookingStatus.CancelledByHost ||
            _status == BookingStatus.FullyPaidOut ||
            _status == BookingStatus.EmergencyCancelled
        ) {
            bookings[getBookingIndex(_bookingId)].balance = 0;
        }
        bookings[getBookingIndex(_bookingId)].status = _status;
    }

    function cancel(string memory _bookingId) public nonReentrant {
        Booking memory booking = bookings[getBookingIndex(_bookingId)];
        require(booking.guest != address(0), "Booking does not exist");
        require(booking.guest == msg.sender, "Only the guest can cancel the booking");
        require(
            booking.balance > 0,
            "Booking is already cancelled or paid out"
        );

        uint256 guestAmount = 0;
        for (uint256 i = 0; i < booking.cancellationPolicies.length; i++) {
            if (booking.cancellationPolicies[i].expiryTime >= block.timestamp) {
                guestAmount = booking.cancellationPolicies[i].refundAmount;
                break;
            }
        }

        updateBookingStatus(_bookingId, BookingStatus.CancelledByGuest);

        // Refund to the guest
        uint256 treasuryAmount = ((booking.balance - guestAmount) * configContract.fee()) / 10000;
        uint256 hostAmount = booking.balance - guestAmount - treasuryAmount;

        _safeTransfer(booking.token, booking.guest, guestAmount);
        _safeTransfer(booking.token, host, hostAmount);
        _safeTransfer(booking.token, configContract.dtravelTreasury(), treasuryAmount);

        factoryContract.cancelByGuest(_bookingId, guestAmount, hostAmount, treasuryAmount, block.timestamp);
    }

    /**
    Anyone can call the `payout` function. When it is called, the difference between 
    the remaining balance and the amount due to the guest if the guest decides to cancel
    is split between the host and treasury.
    */
    function payout(string memory _bookingId) external nonReentrant {
        Booking storage booking = bookings[getBookingIndex(_bookingId)];
        require(booking.guest != address(0), "Booking does not exist");
        require(booking.balance != 0, "Booking is already cancelled or fully paid out");

        uint256 toBePaid = 0;

        if (booking.cancellationPolicies.length == 0) {
            toBePaid = booking.balance;
        } else if (
            booking.cancellationPolicies[booking.cancellationPolicies.length - 1].expiryTime +
                configContract.payoutDelayTime() <
            block.timestamp
        ) {
            toBePaid = booking.balance;
        } else {
            for (uint256 i = 0; i < booking.cancellationPolicies.length; i++) {
                if (booking.cancellationPolicies[i].expiryTime + configContract.payoutDelayTime() >= block.timestamp) {
                    toBePaid = booking.balance - booking.cancellationPolicies[i].refundAmount;
                    break;
                }
            }
        }

        require(toBePaid > 0, "Invalid payout call");

        booking.balance -= toBePaid;

        updateBookingStatus(
            _bookingId,
            booking.balance == 0 ? BookingStatus.FullyPaidOut : BookingStatus.PartialPayOut
        );

        // Split the payment
        uint256 treasuryAmount = (toBePaid * configContract.fee()) / 10000;
        uint256 hostAmount = toBePaid - treasuryAmount;

        _safeTransfer(booking.token, host, hostAmount);
        _safeTransfer(booking.token, configContract.dtravelTreasury(), treasuryAmount);

        factoryContract.payout(
            _bookingId,
            hostAmount,
            treasuryAmount,
            block.timestamp,
            booking.balance == 0 ? 1 : 2
        );
    }

    /**
    When a booking is cancelled by the host, the whole remaining balance is sent to the guest.
    Any amount that has been paid out to the host or to the treasury through calls to `payout` 
    will have to be refunded manually to the guest.
    */
    function cancelByHost(string memory _bookingId) public nonReentrant onlyHostOrDelegate {
        Booking storage booking = bookings[getBookingIndex(_bookingId)];
        require(booking.guest != address(0), "Booking does not exist");
        require(
            booking.status == BookingStatus.InProgress && booking.balance > 0,
            "Booking is already cancelled or fully paid out"
        );

        updateBookingStatus(_bookingId, BookingStatus.CancelledByHost);

        // Refund to the guest
        uint256 guestAmount = booking.balance;

        booking.balance = 0;

        _safeTransfer(booking.token, booking.guest, guestAmount);

        factoryContract.cancelByHost(_bookingId, guestAmount, block.timestamp);
    }

    function bookingHistory() external view returns (Booking[] memory) {
        return bookings;
    }

    function getBookingIndex(string memory _bookingId) public view returns (uint256) {
        uint256 bookingIndex = bookingsMap[_bookingId];
        require(bookingIndex > 0, "Booking does not exist");
        return bookingIndex - 1;
    }

    function getBooking(string memory _bookingId) external view returns (Booking memory) {
        return bookings[getBookingIndex(_bookingId)];
    }

    function _safeTransferFrom(
        address _token,
        address _sender,
        address _recipient,
        uint256 _amount
    ) internal returns (bool) {
        if (_amount > 0) {
            bool sent = IERC20(_token).transferFrom(_sender, _recipient, _amount);
            return sent;
        }
        return false;
    }

    function _safeTransfer(
        address _token,
        address _recipient,
        uint256 _amount
    ) internal returns (bool) {
        if (_amount > 0) {
            bool sent = IERC20(_token).transfer(_recipient, _amount);
            return sent;
        }
        return false;
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
    uint256 public payoutDelayTime; // payout delay time in seconds
    address public dtravelTreasury;
    address public dtravelBackend;
    mapping(address => bool) public supportedTokens;

    constructor(
        uint256 _fee,
        uint256 _payoutDelayTime,
        address _treasury,
        address[] memory _tokens
    ) {
        fee = _fee;
        payoutDelayTime = _payoutDelayTime;
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

    function updatePayoutDelayTime(uint256 _payoutDelayTime) public onlyOwner {
        payoutDelayTime = _payoutDelayTime;
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./DtravelProperty.sol";
import "./DtravelStructs.sol";
import { DtravelEIP712 } from "./DtravelEIP712.sol";

contract DtravelFactory is Ownable {
    address public configContract;
    mapping(address => bool) private propertyMapping;

    event PropertyCreated(uint256[] ids, address[] properties, address host);
    event Book(address property, string bookingId, uint256 bookedTimestamp);
    event CancelByGuest(
        address property,
        string bookingId,
        uint256 guestAmount,
        uint256 hostAmount,
        uint256 treasuryAmount,
        uint256 cancelTimestamp
    );
    event CancelByHost(address property, string bookingId, uint256 guestAmount, uint256 cancelTimestamp);
    event Payout(
        address property,
        string bookingId,
        uint256 hostAmount,
        uint256 treasuryAmount,
        uint256 payoutTimestamp,
        uint8 payoutType // 1: full payout, 2: partial payout
    );

    constructor(address _config) {
        configContract = _config;
    }

    modifier onlyMatchingProperty() {
        require(propertyMapping[msg.sender] == true, "Property not found");
        _;
    }

    function deployProperty(uint256[] memory _ids, address _host) public onlyOwner {
        require(_ids.length > 0, "Invalid property ids");
        require(_host != address(0), "Host address is invalid");
        address[] memory properties = new address[](_ids.length);
        for (uint256 i = 0; i < _ids.length; i++) {
            DtravelProperty property = new DtravelProperty(_ids[i], configContract, address(this), _host);
            propertyMapping[address(property)] = true;
            properties[i] = address(property);
        }
        emit PropertyCreated(_ids, properties, _host);
    }

    function verifyBookingData(BookingParameters memory _params, bytes memory _signature)
        external
        view
        onlyMatchingProperty
        returns (bool)
    {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DtravelConfig config = DtravelConfig(configContract);
        return DtravelEIP712.verify(_params, chainId, msg.sender, config.dtravelBackend(), _signature);
    }

    function book(string memory _bookingId) external onlyMatchingProperty {
        emit Book(msg.sender, _bookingId, block.timestamp);
    }

    function cancelByGuest(
        string memory _bookingId,
        uint256 _guestAmount,
        uint256 _hostAmount,
        uint256 _treasuryAmount,
        uint256 _cancelTimestamp
    ) external onlyMatchingProperty {
        emit CancelByGuest(msg.sender, _bookingId, _guestAmount, _hostAmount, _treasuryAmount, _cancelTimestamp);
    }

    function cancelByHost(
        string memory _bookingId,
        uint256 _guestAmount,
        uint256 _cancelTimestamp
    ) external onlyMatchingProperty {
        emit CancelByHost(msg.sender, _bookingId, _guestAmount, _cancelTimestamp);
    }

    function payout(
        string memory _bookingId,
        uint256 _hostAmount,
        uint256 _treasuryAmount,
        uint256 _payoutTimestamp,
        uint8 _payoutType
    ) external onlyMatchingProperty {
        emit Payout(msg.sender, _bookingId, _hostAmount, _treasuryAmount, _payoutTimestamp, _payoutType);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

struct CancellationPolicy {
    uint256 expiryTime;
    uint256 refundAmount;
}

struct BookingParameters {
    address token;
    string bookingId;
    uint256 checkInTimestamp;
    uint256 checkOutTimestamp;
    uint256 bookingExpirationTimestamp;
    uint256 bookingAmount;
    CancellationPolicy[] cancellationPolicies;
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

//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./DtravelStructs.sol";

struct EIP712Domain {
    string name;
    string version;
    uint256 chainId;
    address verifyingContract;
}

library DtravelEIP712 {
    bytes32 constant EIP712DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 constant CANCELLATION_POLICY_TYPEHASH =
        keccak256("CancellationPolicy(uint256 expiryTime,uint256 refundAmount)");
    bytes32 constant BOOKING_PARAMETERS_TYPEHASH =
        keccak256(
            "BookingParameters(address token,string bookingId,uint256 checkInTimestamp,uint256 checkOutTimestamp,uint256 bookingExpirationTimestamp,uint256 bookingAmount,CancellationPolicy[] cancellationPolicies)CancellationPolicy(uint256 expiryTime,uint256 refundAmount)"
        );

    function verify(
        BookingParameters memory parameters,
        uint256 chainId,
        address verifyingContract,
        address authorizedSigner,
        bytes memory signature
    ) external pure returns (bool) {
        bytes32 domainSeperator = hashDomain(
            EIP712Domain({
                name: "Dtravel Booking",
                version: "1",
                chainId: chainId,
                verifyingContract: verifyingContract
            })
        );
        return recoverSigner(parameters, domainSeperator, signature) == authorizedSigner;
    }

    function hashDomain(EIP712Domain memory eip712Domain) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    EIP712DOMAIN_TYPEHASH,
                    keccak256(bytes(eip712Domain.name)),
                    keccak256(bytes(eip712Domain.version)),
                    eip712Domain.chainId,
                    eip712Domain.verifyingContract
                )
            );
    }

    function hashCancellationPolicy(CancellationPolicy memory cancellationPolicy) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    CANCELLATION_POLICY_TYPEHASH,
                    cancellationPolicy.expiryTime,
                    cancellationPolicy.refundAmount
                )
            );
    }

    function hashBookingParameters(BookingParameters memory bookingParameters) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    BOOKING_PARAMETERS_TYPEHASH,
                    bookingParameters.token,
                    keccak256(bytes(bookingParameters.bookingId)),
                    bookingParameters.checkInTimestamp,
                    bookingParameters.checkOutTimestamp,
                    bookingParameters.bookingExpirationTimestamp,
                    bookingParameters.bookingAmount,
                    hashCancellationPolicyArray(bookingParameters.cancellationPolicies)
                )
            );
    }

    function hashCancellationPolicyArray(CancellationPolicy[] memory array) internal pure returns (bytes32) {
        if (array.length > 0) {
            bytes memory concatedHashArray = bytes.concat(hashCancellationPolicy(array[0]));
            for (uint256 i = 1; i < array.length; i++) {
                concatedHashArray = bytes.concat(concatedHashArray, hashCancellationPolicy(array[i]));
            }
            return keccak256(concatedHashArray);
        } else {
            return keccak256("");
        }
    }

    function digest(BookingParameters memory parameters, bytes32 domainSeparator) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, hashBookingParameters(parameters)));
    }

    function recoverSigner(
        BookingParameters memory parameters,
        bytes32 domainSeparator,
        bytes memory signature
    ) internal pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);
        return ecrecover(digest(parameters, domainSeparator), v, r, s);
    }

    function splitSignature(bytes memory sig)
        internal
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