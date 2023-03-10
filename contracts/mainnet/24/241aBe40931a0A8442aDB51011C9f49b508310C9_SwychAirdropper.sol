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

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../contracts/SwychAirdropper.sol";

contract $SwychAirdropper is SwychAirdropper {
    bytes32 public __hh_exposed_bytecode_marker = "hardhat-exposed";

    constructor() {}

    function $_checkOwner() external view {
        return super._checkOwner();
    }

    function $_transferOwnership(address newOwner) external {
        return super._transferOwnership(newOwner);
    }

    function $_msgSender() external view returns (address) {
        return super._msgSender();
    }

    function $_msgData() external view returns (bytes memory) {
        return super._msgData();
    }

    receive() external payable {}
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

//             _ L
//         . # # # [
//           # # # #
//           ] # # # L   . _
//             ? # # # # # # ,       ____                     _
//     . _ _ _ ' # # # # # # [      / ___|_      ___   _  ___| |__
//   d # # # # # / # # # # # F      \___ \ \ /\ / / | | |/ __| '_ \
//   ] # # # # # # , ^ ^ ^ `         ___) \ V  V /| |_| | (__| | | |
//   ' # # # # # # L                |____/ \_/\_/  \__, |\___|_| |_|
//     ^ `   ? # # # [                             |___/
//             # # # #
//             ' # # # `
//               ? ^

// Import libraries.
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; // Interface of the ERC20 standard as defined in the EIP.;
import "@openzeppelin/contracts/access/Ownable.sol"; // Access control mechanism for smart contract functions.

/**
 * @title The airdrop smart contract.
 * @notice The smart contract is used to airdrop Swych tokens to Titano and Uniqo holders.
 * @dev The following smart contract is responsible to airdrop Swych tokens to Titano and Uniqo holders.
 *      It is initially funded with Swych and provides a function that receives wallet addresses of the holders
 *      and amounts of Swych tokens to transfer.
 */
contract SwychAirdropper is Ownable {
    /// @notice The index of the wallet used in the last transaction.
    uint32 public lastWalletIndex;

    /// @notice Events that are fired during emergency withdraws.
    event EmergencyWithdraw();

    /**
     * @notice Transfers Swych to the provided wallets.
     * @dev The function iterates over the arrays and transfers Swych to the wallets.
     *      The received arrays must be of the same length.
     *      To keep things in sync the last wallet index is saved in the contract.
     *      The function is only callable by the owner and requires to be funded by Swych beforehand.
     * @param token The address of the token to airdrop.
     * @param wallets The array of wallet addresses to airdrop Swych to.
     * @param amounts The array of amount to airdrop.
     * @param startIndex The index of the first wallet in the array.
     * @param lastIndex The index of the last wallet in the array.
     */
    function airdrop(
        IERC20 token,
        address[] calldata wallets,
        uint256[] calldata amounts,
        uint32 startIndex,
        uint32 lastIndex
    ) external onlyOwner {
        require(address(token) != address(0), "INVALID_TOKEN_ADDRESS");
        require(wallets.length == amounts.length, "ARRAY_LENGTH_MISMATCH");
        require(startIndex == lastWalletIndex + 1, "START_INDEX_MISMATCH");

        // Transfer Swych to the wallets.
        for (uint256 i = 0; i < wallets.length; i++) {
            token.transfer(wallets[i], amounts[i]);
        }

        // Save the last wallet index.
        lastWalletIndex = lastIndex;
    }     

    /**
     * @notice Withdraws Swych tokens to the owner wallet.
     * @dev The function is only callable by the owner.
     * @param token The address of the token to withdraw.
     */
    function emergencyWithdrawERC20(IERC20 token) external onlyOwner {
        // Read the token balance of the contract.
        uint256 balance = token.balanceOf(address(this));
        // Transfer the balance to the owner.
        token.transfer(owner(), balance);
        emit EmergencyWithdraw();
    }
}