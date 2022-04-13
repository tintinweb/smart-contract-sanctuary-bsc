// SPDX-License-Identifier: MIT
// Unagi Vesting Contracts v1.0.0 (LockedUltimateChampionsToken.sol)
pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @title LockedUltimateChampionsToken
 * @dev Partial implementation of IERC20 which allows to check balance of locked CHAMP for a given beneficiary.
 * This contract acts like a view of the CHAMP token and will simply return the balance of a vesting wallet assigned to a beneficiary.
 * @custom:security-contact [email protected]
 */
contract LockedUltimateChampionsToken is Ownable {
    address[] private _lockedWallets;
    mapping(address => bool) private _lockedWalletsTracked;
    mapping(address => address) private _lockedWalletToVestingContract;

    uint8 private constant MAX_TRACKED_WALLETS = 200;

    IERC20Metadata private immutable _champContract;

    /**
     * @dev Initialize the CHAMP contract.
     */
    constructor(address champAddress) {
        require(
            champAddress != address(0),
            "LockedUltimateChampionsToken: champAddress should be a valid address. Received address(0)."
        );
        _champContract = IERC20Metadata(champAddress);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() external pure returns (string memory) {
        return "Locked Ultimate Champions Token";
    }

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external pure returns (string memory) {
        return "CHAMP_LOCK";
    }

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8) {
        return _champContract.decimals();
    }

    /**
     * @dev Returns the sum of locked CHAMPs.
     */
    function totalSupply() external view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < _lockedWallets.length; i++) {
            total += _champContract.balanceOf(
                getVestingContract(_lockedWallets[i])
            );
        }
        return total;
    }

    /**
     * @dev Returns the amount of locked CHAMP tokens owned by `tokenHolder`.
     */
    function balanceOf(address tokenHolder) public view returns (uint256) {
        return _champContract.balanceOf(getVestingContract(tokenHolder));
    }

    /**
     * @dev Allow to update the list of locked wallets with their associated vesting contract.
     * Emits a {LockedWalletTracked} event.
     *
     * Requirements:
     *
     * - The caller must be the owner.
     * - The number of tracked locked wallets should remains bellow MAX_TRACKED_WALLETS items.
     */
    function setLockedWallet(address lockedWallet, address vestingContract)
        external
        onlyOwner
    {
        require(
            lockedWallet != address(0),
            "LockedUltimateChampionsToken: lockedWallet should be a valid address. Received address(0)."
        );
        require(
            vestingContract != address(0),
            "LockedUltimateChampionsToken: vestingContract should be a valid address. Received address(0)."
        );

        if (!_lockedWalletsTracked[lockedWallet]) {
            require(
                _lockedWallets.length < MAX_TRACKED_WALLETS,
                "Too much tracked wallets. Consider creating a new instance of this contract to handle more."
            );

            _lockedWallets.push(lockedWallet);
            _lockedWalletsTracked[lockedWallet] = true;
        }
        _lockedWalletToVestingContract[lockedWallet] = vestingContract;

        emit LockedWalletTracked(lockedWallet, vestingContract);
    }

    /**
     * @dev Getter to retrieve for a given locked wallet its associated vesting contract.
     */
    function getVestingContract(address lockedWallet)
        public
        view
        returns (address)
    {
        return _lockedWalletToVestingContract[lockedWallet];
    }

    event LockedWalletTracked(address lockedWallet, address vestingContract);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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