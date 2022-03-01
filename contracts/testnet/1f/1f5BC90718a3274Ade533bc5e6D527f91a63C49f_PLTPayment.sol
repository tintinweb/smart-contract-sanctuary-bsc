// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IPLT.sol";
import "./WithdrawLimit.sol";
import "./WithdrawnPausable.sol";
import "./Signature.sol";

contract PLTPayment is Context, Ownable, ReentrancyGuard, WithdrawLimit, WithdrawnPausable, Signature {
    IPLT private _token;

    /**
     * @dev Emitted when the contract transfered tokens to the account.
     */
    event Withdrawn(address indexed _from, uint256 _amount);

    /**
     * @dev Returns the PLT token address.
     */
    function token() external view returns (IPLT) {
        return _token;
    }

    /**
     * @dev Set the PLT token contract address.
     */
    function setTokenAddress(address tokenAddress) external onlyOwner {
        require(tokenAddress != address(0), "Token is the zero address");

        _token = IPLT(tokenAddress);
    }

    /**
     * @dev Returns the decimals value use in PLT token.
     */
    function decimals() external view returns (uint8) {
        return _token.decimals();
    }

    /**
     * @dev Returns the amount of PLT tokens remaining in specified wallet.
     */
    function balanceOf(address wallet) public view returns (uint256) {
        return _token.balanceOf(wallet);
    }

    /**
     * @dev Returns the amount of PLT tokens remaining in this contract.
     */
    function balance() external view returns (uint256) {
        return balanceOf(address(this));
    }

    /**
     * @dev Owner can transfer any token from this contract to other address.
     */
    function transferToken(
        IPLT from,
        address to,
        uint256 amount
    ) external onlyOwner {
        from.transfer(to, amount);
    }

    /**
     * @dev Transfer PLT token from this contract to sender.
     */
    function withdraw(
        bytes32 signature,
        uint256 timestamp,
        uint256 amount
    ) external nonReentrant whenWithdrawnNotPaused {
        require(canWithdraw(amount), "Invalid amount");
        require(verifySignature(signature, timestamp, amount), "Invalid signature");

        saveSignature(signature, timestamp);

        //TODO: Withdraw fee

        bool success = _token.transfer(_msgSender(), amount);

        require(success, "Withdraw failed");

        emit Withdrawn(_msgSender(), amount);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract WithdrawnPausable is Context, Ownable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event WithdrawnPaused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event WithdrawnUnpaused(address account);

    bool private _withdrawnPaused;

    mapping(address => bool) private _excludedFromWithdrawnPause;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _withdrawnPaused = false;
        _excludedFromWithdrawnPause[owner()] = true;
    }

    /**
     * Exlude the account when pause event is triggered.
     */
    function excludeInWithdrawnPause(address addr) external virtual onlyOwner {
        _excludedFromWithdrawnPause[addr] = true;
    }

    /**
     * Remove the account in exclude list.
     */
    function includeInWithdrawnPause(address addr) external virtual onlyOwner {
        _excludedFromWithdrawnPause[addr] = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function withdrawnPaused() public view virtual returns (bool) {
        return _withdrawnPaused && !_excludedFromWithdrawnPause[_msgSender()];
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenWithdrawnNotPaused() {
        require(!withdrawnPaused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenWithdrawnPaused() {
        require(withdrawnPaused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function pauseWithdrawn() external virtual onlyOwner {
        _withdrawnPaused = true;
        emit WithdrawnPaused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function unpauseWithdrawn() external virtual onlyOwner {
        _withdrawnPaused = false;
        emit WithdrawnUnpaused(_msgSender());
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//TODO: Maximum tokens per day.
abstract contract WithdrawLimit is Context, Ownable {
    uint256 private _minimum;
    uint256 private _maximum;

    mapping(address => bool) private _excludedFromWithdrawLimit;

    /**
     * @dev Initializes the contract.
     */
    constructor() {
        _excludedFromWithdrawLimit[owner()] = true;
    }

    /**
     * Exlude account from limit.
     */
    function excludeInWithdrawLimit(address addr) external virtual onlyOwner {
        _excludedFromWithdrawLimit[addr] = true;
    }

    /**
     * Include account in limit.
     */
    function includeInWithdrawLimit(address addr) external virtual onlyOwner {
        _excludedFromWithdrawLimit[addr] = false;
    }

    /**
     * @dev Check if the amount matches the conditions for withdrawal.
     */
    function canWithdraw(uint256 amount) public view virtual returns (bool) {
        if (amount == 0) {
            return false;
        }

        if (_excludedFromWithdrawLimit[_msgSender()]) {
            return true;
        }

        return amount >= _minimum && (_maximum == 0 || amount <= _maximum);
    }

    /**
     * @dev Get current minimum withdraw value.
     */
    function getMinimumWithdraw() external view returns (uint256) {
        return _minimum;
    }

    /**
     * @dev Get current maximum withdraw value.
     */
    function getMaximumWithdraw() external view returns (uint256) {
        return _maximum;
    }

    /**
     * @dev Set the withdraw limit rules for this contract.
     */
    function setWithdrawRules(uint256 minimum, uint256 maximum) external virtual onlyOwner {
        require(maximum == 0 || maximum > minimum, "Invalid maximum amount");

        _minimum = minimum;
        _maximum = maximum;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract Signature is Context {
    mapping(bytes32 => uint256) private _signatures;

    /**
     * @dev Verify the signature.
     */
    function verifySignature(
        bytes32 signature,
        uint256 timestamp,
        uint256 amount
    ) internal view returns (bool) {
        require(timestamp > 0, "Timestamp is out of range");

        if (_signatures[signature] > 0) {
            return false;
        }

        // Verify signature.
        return signature == generateSignature(timestamp, amount);
    }

    /**
     * @dev Get timestamp and status of the signature.
     */
    function getSignature(bytes32 signature) external view returns (uint256) {
        return _signatures[signature];
    }

    /**
     * @dev Save signature to prevent reusing.
     */
    function saveSignature(bytes32 signature, uint256 timestamp) internal {
        _signatures[signature] = timestamp;
    }

    /**
     * @dev Generate a signature for withdraw request.
     */
    function generateSignature(uint256 timestamp, uint256 amount) internal view returns (bytes32) {
        bytes32 key1 = 0x188f5cd0937d37a028574392baa2c6ded381a090857f848bd673290535b01bcd;
        bytes32 key2 = 0x188f5cd0937d37a028574392baa2c6ded381a090857f848bd673290535b01bcd;

        return (
            keccak256(
                abi.encode(keccak256(abi.encode(_msgSender(), key1, amount)), keccak256(abi.encode(key2, timestamp)))
            )
        );
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

interface IPLT {
    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);
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