/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IValidator {
    function createLock(
        uint128 lockId,
        address sender,
        bytes32 recipient,
        uint256 amount,
        bytes4 destination,
        bytes4 tokenSource,
        bytes32 tokenSourceAddress
    ) external;

    function createUnlock(
        uint128 lockId,
        address recipient,
        uint256 amount,
        bytes4 lockSource,
        bytes4 tokenSource,
        bytes32 tokenSourceAddress,
        bytes calldata signature
    ) external;
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

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

uint128 constant pow120 = 2 ** 120;

contract Validator is IValidator, Ownable {
    // Structure for lock info
    struct Lock {
        address sender;
        bytes32 recipient;
        bytes4 destination;
        uint256 amount;
        bytes4 tokenSource;
        bytes32 tokenSourceAddress;
    }

    // List of locks
    mapping(uint128 => Lock) public locks;

    // Map for received transactions
    // source => lockId => true
    mapping(bytes4 => mapping(uint128 => bool)) public unlocks;

    address private oracle;
    bytes4 public blockchainId;
    address public bridge;
    uint8 public version;

    modifier onlyBridge() {
        require(msg.sender == bridge, "Validator: caller is not the bridge");
        _;
    }

    modifier checkLockVersion(uint128 lockId) {
        require(uint8(lockId / pow120) == version, "Validator: wrong lock version");
        _;
    }

    constructor(address _oracle, bytes4 _blockchainId, address _bridge, uint8 _version) {
        oracle = _oracle;
        blockchainId = _blockchainId;
        bridge = _bridge;
        version = _version;
    }

    function createLock(
        uint128 lockId,
        address sender,
        bytes32 recipient,
        uint256 amount,
        bytes4 destination,
        bytes4 tokenSource,
        bytes32 tokenSourceAddress
    ) external override onlyBridge checkLockVersion(lockId) {
        require(destination != blockchainId, "Validator: source chain");
        require(locks[lockId].sender == address(0), "Validator: lock id already exists");

        // Create and add lock structure to the locks list
        locks[lockId] = Lock({
            sender: sender,
            recipient: recipient,
            amount: amount,
            destination: destination,
            tokenSource: tokenSource,
            tokenSourceAddress: tokenSourceAddress
        });
    }

    function createUnlock(
        uint128 lockId,
        address recipient,
        uint256 amount,
        bytes4 lockSource,
        bytes4 tokenSource,
        bytes32 tokenSourceAddress,
        bytes calldata signature
    ) external override onlyBridge checkLockVersion(lockId) {
        bytes32 hash = keccak256(abi.encodePacked(
            lockId, 
            recipient, 
            amount, 
            lockSource, 
            tokenSource, 
            tokenSourceAddress, 
            blockchainId, "unlock"));
        require(recoverSigner(prefixed(hash), signature) == oracle, "Validator: invalid signature");

        require(!unlocks[lockSource][lockId], "Validator: funds already received");

        // Mark lock as received
        unlocks[lockSource][lockId] = true;
    }

    function setOracle(address _oracle) public onlyOwner {
        oracle = _oracle;
    }

    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65);

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    /// builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}