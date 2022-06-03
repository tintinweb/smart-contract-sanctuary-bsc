/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

// OpenZeppelin Contracts v4.4.1 (token/ERC777/IERC777.sol)

/**
 * @dev Interface of the ERC777Token standard as defined in the EIP.
 *
 * This contract uses the
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 registry standard] to let
 * token holders and recipients react to token movements by using setting implementers
 * for the associated interfaces in said registry. See {IERC1820Registry} and
 * {ERC1820Implementer}.
 */
interface IERC777 {
    /**
     * @dev Emitted when `amount` tokens are created by `operator` and assigned to `to`.
     *
     * Note that some additional user `data` and `operatorData` can be logged in the event.
     */
    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    /**
     * @dev Emitted when `operator` destroys `amount` tokens from `account`.
     *
     * Note that some additional user `data` and `operatorData` can be logged in the event.
     */
    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    /**
     * @dev Emitted when `operator` is made operator for `tokenHolder`
     */
    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    /**
     * @dev Emitted when `operator` is revoked its operator status for `tokenHolder`
     */
    event RevokedOperator(address indexed operator, address indexed tokenHolder);

    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the smallest part of the token that is not divisible. This
     * means all token operations (creation, movement and destruction) must have
     * amounts that are a multiple of this number.
     *
     * For most token contracts, this value will equal 1.
     */
    function granularity() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by an account (`owner`).
     */
    function balanceOf(address owner) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * If send or receive hooks are registered for the caller and `recipient`,
     * the corresponding functions will be called with `data` and empty
     * `operatorData`. See {IERC777Sender} and {IERC777Recipient}.
     *
     * Emits a {Sent} event.
     *
     * Requirements
     *
     * - the caller must have at least `amount` tokens.
     * - `recipient` cannot be the zero address.
     * - if `recipient` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */
    function send(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev Destroys `amount` tokens from the caller's account, reducing the
     * total supply.
     *
     * If a send hook is registered for the caller, the corresponding function
     * will be called with `data` and empty `operatorData`. See {IERC777Sender}.
     *
     * Emits a {Burned} event.
     *
     * Requirements
     *
     * - the caller must have at least `amount` tokens.
     */
    function burn(uint256 amount, bytes calldata data) external;

    /**
     * @dev Returns true if an account is an operator of `tokenHolder`.
     * Operators can send and burn tokens on behalf of their owners. All
     * accounts are their own operator.
     *
     * See {operatorSend} and {operatorBurn}.
     */
    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);

    /**
     * @dev Make an account an operator of the caller.
     *
     * See {isOperatorFor}.
     *
     * Emits an {AuthorizedOperator} event.
     *
     * Requirements
     *
     * - `operator` cannot be calling address.
     */
    function authorizeOperator(address operator) external;

    /**
     * @dev Revoke an account's operator status for the caller.
     *
     * See {isOperatorFor} and {defaultOperators}.
     *
     * Emits a {RevokedOperator} event.
     *
     * Requirements
     *
     * - `operator` cannot be calling address.
     */
    function revokeOperator(address operator) external;

    /**
     * @dev Returns the list of default operators. These accounts are operators
     * for all token holders, even if {authorizeOperator} was never called on
     * them.
     *
     * This list is immutable, but individual holders may revoke these via
     * {revokeOperator}, in which case {isOperatorFor} will return false.
     */
    function defaultOperators() external view returns (address[] memory);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient`. The caller must
     * be an operator of `sender`.
     *
     * If send or receive hooks are registered for `sender` and `recipient`,
     * the corresponding functions will be called with `data` and
     * `operatorData`. See {IERC777Sender} and {IERC777Recipient}.
     *
     * Emits a {Sent} event.
     *
     * Requirements
     *
     * - `sender` cannot be the zero address.
     * - `sender` must have at least `amount` tokens.
     * - the caller must be an operator for `sender`.
     * - `recipient` cannot be the zero address.
     * - if `recipient` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the total supply.
     * The caller must be an operator of `account`.
     *
     * If a send hook is registered for `account`, the corresponding function
     * will be called with `data` and `operatorData`. See {IERC777Sender}.
     *
     * Emits a {Burned} event.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     * - the caller must be an operator for `account`.
     */
    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );
}

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC1820Registry.sol)

/**
 * @dev Interface of the global ERC1820 Registry, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1820[EIP]. Accounts may register
 * implementers for interfaces in this registry, as well as query support.
 *
 * Implementers may be shared by multiple accounts, and can also implement more
 * than a single interface for each account. Contracts can implement interfaces
 * for themselves, but externally-owned accounts (EOA) must delegate this to a
 * contract.
 *
 * {IERC165} interfaces can also be queried via the registry.
 *
 * For an in-depth explanation and source code analysis, see the EIP text.
 */
interface IERC1820Registry {
    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);

    /**
     * @dev Sets `newManager` as the manager for `account`. A manager of an
     * account is able to set interface implementers for it.
     *
     * By default, each account is its own manager. Passing a value of `0x0` in
     * `newManager` will reset the manager to this initial state.
     *
     * Emits a {ManagerChanged} event.
     *
     * Requirements:
     *
     * - the caller must be the current manager for `account`.
     */
    function setManager(address account, address newManager) external;

    /**
     * @dev Returns the manager for `account`.
     *
     * See {setManager}.
     */
    function getManager(address account) external view returns (address);

    /**
     * @dev Sets the `implementer` contract as ``account``'s implementer for
     * `interfaceHash`.
     *
     * `account` being the zero address is an alias for the caller's address.
     * The zero address can also be used in `implementer` to remove an old one.
     *
     * See {interfaceHash} to learn how these are created.
     *
     * Emits an {InterfaceImplementerSet} event.
     *
     * Requirements:
     *
     * - the caller must be the current manager for `account`.
     * - `interfaceHash` must not be an {IERC165} interface id (i.e. it must not
     * end in 28 zeroes).
     * - `implementer` must implement {IERC1820Implementer} and return true when
     * queried for support, unless `implementer` is the caller. See
     * {IERC1820Implementer-canImplementInterfaceForAddress}.
     */
    function setInterfaceImplementer(
        address account,
        bytes32 _interfaceHash,
        address implementer
    ) external;

    /**
     * @dev Returns the implementer of `interfaceHash` for `account`. If no such
     * implementer is registered, returns the zero address.
     *
     * If `interfaceHash` is an {IERC165} interface id (i.e. it ends with 28
     * zeroes), `account` will be queried for support of it.
     *
     * `account` being the zero address is an alias for the caller's address.
     */
    function getInterfaceImplementer(address account, bytes32 _interfaceHash) external view returns (address);

    /**
     * @dev Returns the interface hash for an `interfaceName`, as defined in the
     * corresponding
     * https://eips.ethereum.org/EIPS/eip-1820#interface-name[section of the EIP].
     */
    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);

    /**
     * @notice Updates the cache with whether the contract implements an ERC165 interface or not.
     * @param account Address of the contract for which to update the cache.
     * @param interfaceId ERC165 interface for which to update the cache.
     */
    function updateERC165Cache(address account, bytes4 interfaceId) external;

    /**
     * @notice Checks whether a contract implements an ERC165 interface or not.
     * If the result is not cached a direct lookup on the contract address is performed.
     * If the result is not cached or the cached value is out-of-date, the cache MUST be updated manually by calling
     * {updateERC165Cache} with the contract address.
     * @param account Address of the contract to check.
     * @param interfaceId ERC165 interface to check.
     * @return True if `account` implements `interfaceId`, false otherwise.
     */
    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);

    /**
     * @notice Checks whether a contract implements an ERC165 interface or not without using nor updating the cache.
     * @param account Address of the contract to check.
     * @param interfaceId ERC165 interface to check.
     * @return True if `account` implements `interfaceId`, false otherwise.
     */
    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);
}

// OpenZeppelin Contracts v4.4.1 (token/ERC777/IERC777Recipient.sol)

/**
 * @dev Interface of the ERC777TokensRecipient standard as defined in the EIP.
 *
 * Accounts can be notified of {IERC777} tokens being sent to them by having a
 * contract implement this interface (contract holders can be their own
 * implementer) and registering it on the
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 global registry].
 *
 * See {IERC1820Registry} and {ERC1820Implementer}.
 */
interface IERC777Recipient {
    /**
     * @dev Called by an {IERC777} token contract whenever tokens are being
     * moved or created into a registered account (`to`). The type of operation
     * is conveyed by `from` being the zero address or not.
     *
     * This call occurs _after_ the token contract's state is updated, so
     * {IERC777-balanceOf}, etc., can be used to query the post-operation state.
     *
     * This function may revert to prevent the operation from being executed.
     */
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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

interface IMarginable {
    /**
     * @notice IMarginable can credit itself, so account can be either net borrower(deposits=0) or
     * net depositer(borrows=0).
     * @dev This function returns USD value of free margin with LTV risk parameters applied
     */
    function netPosition(address account, uint32 data)
        external
        view
        returns (int256);

    /**
     * @notice Gets risk parameters
     */
    function getLTV() external view returns (uint256);

    function seizeAccount(address account, address seizeTo) external;

    function setParent(address newParent) external;

    function getTotalReserves() external view returns (uint256);

    function setBridgeBorrowsStatus(uint8 status) external;

    function authorizeStrategy(
        address strategy,
        address signatory,
        bool authorize
    ) external;
}

interface INaviOracle {
    function isBridged(uint32 id) external view returns (bool);

    function hasBridgedData(uint32 id) external view returns (bool);

    function isnToken(uint32 id) external view returns (bool);

    function hasPriceFeed(uint32 id) external view returns (bool);

    function tokenAddress(uint32 id) external view returns (address);

    function daoAddress(uint32 id) external view returns (address);

    function price(uint32 id) external view returns (uint256);

    function tokenExtra(uint32 id) external view returns (string memory);

    function maxId() external view returns (uint32);

    function idByTokenAddress(address token) external view returns (uint32);
}

interface INaviDebt {
    function controllerMint(address account, uint256 amount) external;
}

interface InToken {
    function getUnderlying() external view returns (address);

    function getPriceId() external view returns (uint32);

    function getTotalReserves() external view returns (uint256);

    function getCash() external view returns (uint256);

    function getTotalBorrows() external view returns (uint256);

    function balanceOfUnderlying(address owner) external view returns (uint256);

    function redeemByStrategy(
        uint256 redeemTokensIn,
        uint256 redeemAmountIn,
        address redeemer,
        bytes memory data
    ) external;

    function borrowByStrategy(
        uint256 borrowAmount,
        address borrower,
        bytes memory data
    ) external;

    function borrowBalance(address account) external view returns (uint256);

    function burnDebtFor(address sender, uint256 amount) external;

    function bridgeDeposits(address account) external view returns (uint256);

    function bridgeBorrows(address account) external view returns (uint256);
}

interface IDaoToken {
    function maxSupply() external view returns (uint256);
}

interface IMarginGroup {
    //amount in USD
    function hasEnoughMargin(address from, uint256 amount)
        external
        view
        returns (bool);
}

/**
 * @dev Just a common part of all contracts implementing IMarginable.
 **/
abstract contract NaviMarginable {
    IMarginGroup internal _parent;

    function getParent() external view returns (address) {
        return address(_parent);
    }

    modifier onlyParent() {
        if (address(_parent) != msg.sender) return;
        _;
    }
    uint256 internal _LTV;

    function getLTV() external view returns (uint256) {
        return _LTV;
    }

    constructor(uint256 ltv, address parent) {
        _LTV = ltv;
        _parent = IMarginGroup(parent);
    }

    function setParent(address controllerContract) external onlyParent {
        _parent = IMarginGroup(controllerContract);
    }

    event LTVUpdated(uint256 oldValue, uint256 newValue);
}

/// math.sol -- mixin for inline numerical wizardry

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/**
 * @title Fixed point WAD\RAY math contract
 * @notice Implements the fixed point arithmetic operations for WAD numbers (18 decimals) and RAY (27 decimals)
 * @dev Wad functions have a [w] prefix: wmul, wdiv. Ray functions have a [r] prefix: rmul, rdiv, rpow.
 * @author https://github.com/dapphub/ds-math
 **/

contract DSMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x <= y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x >= y ? x : y;
    }

    function imin(int256 x, int256 y) internal pure returns (int256 z) {
        return x <= y ? x : y;
    }

    function imax(int256 x, int256 y) internal pure returns (int256 z) {
        return x >= y ? x : y;
    }

    uint256 constant WAD = 10**18;
    uint256 constant RAY = 10**27;

    //rounds to zero if x*y < WAD / 2
    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    //rounds to zero if x*y < WAD / 2
    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }

    //rounds to zero if x*y < WAD / 2
    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

    //rounds to zero if x*y < RAY / 2
    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint256 x, uint256 n) internal pure returns (uint256 z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

/**
 * @title A contract for storing a set of nTokens, farmControllers or another NaviMarginGroups
 * @notice This group is used to represent a level of hierarchy with certain Loan to value ratio
 * @dev Base contract for NaviController and NaviControllerGroup, both are implementing IMarginGroup
 **/
abstract contract NaviMarginGroup is Ownable, DSMath {
    IERC1820Registry internal constant _erc1820 =
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    IMarginable[] internal _members;
    uint32[] internal _data; //this is the index of an asset when marginable member has multiple assets
    INaviOracle public immutable _oracle;

    event Migrated(address to);
    event MigrationsDisabled();
    event MigratedFrom(address from);

    constructor(address oracle) Ownable() {
        _oracle = INaviOracle(oracle);
        _erc1820.setInterfaceImplementer(
            address(this),
            keccak256("NaviMarginGroup"),
            address(this)
        );
    }

    function registerMarginable(address ntoken) external onlyOwner {
        _members.push(IMarginable(ntoken));
        _data.push(0);
    }

    function registerMarginable(address ntoken, uint32 data)
        external
        onlyOwner
    {
        _members.push(IMarginable(ntoken));
        _data.push(data);
    }

    function removeMarginable(uint32 index) external onlyOwner {
        _members[index] = _members[_members.length - 1];
        _members.pop();

        _data[index] = _data[_data.length - 1];
        _data.pop();
    }

    function getMarginableLength() external view returns (uint256) {
        return _members.length;
    }

    function getMarginable(uint32 index)
        external
        view
        returns (address, uint32)
    {
        return (address(_members[index]), _data[index]);
    }

    function getTotalReserves() public view returns (uint256) {
        uint256 totalReserves = 0;
        for (uint32 i = 0; i < _members.length; i++) {
            uint256 price = _oracle.price(_data[i]);
            uint256 reserves = _members[i].getTotalReserves();
            totalReserves += wmul(reserves, price);
        }
        return totalReserves;
    }

    function mirgate(address to) external onlyOwner {
        for (uint32 i = 0; i < _members.length; i++) _members[i].setParent(to);
        delete _members;
        delete _data;
        emit Migrated(to);
    }

    function mirgateFrom(address from_) external onlyOwner {
        NaviMarginGroup from = NaviMarginGroup(from_);
        delete _members;
        delete _data;
        for (uint32 i = 0; i < from.getMarginableLength(); i++) {
            (address a, uint32 d) = from.getMarginable(i);
            _members.push(IMarginable(a));
            _data.push(d);
        }
        emit MigratedFrom(from_);
    }

    function sweepToken(IERC20 token) external {
        token.transfer(owner(), token.balanceOf(address(this)));
    }
}

/**
 * @title A contract for storing a group of nTokens, farmControllers or another NaviControllerGroups
 * @dev This contract is a top level of the hierarhy.
 **/
contract NaviController is
    IERC777Recipient,
    NaviMarginGroup,
    ReentrancyGuard,
    IMarginGroup
{
    event TokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes userData,
        bytes operatorData
    );
    event SeizureStarted(address account, address sender, uint256 blockNumber);
    event SeizurePerformed(address account, address sender, uint256 debtMinted);
    event AccountSeized(address account, address sender);
    event BridgeBorrowsStatusUpdated(uint8 newStatus);
    event ReservesClaimableFactorUpdated(uint256 oldValue, uint256 newValue);
    event SeizureTimeoutMinUpdated(uint256 oldValue, uint256 newValue);
    event SeizureTimeoutMaxUpdated(uint256 oldValue, uint256 newValue);
    event NewStrategyRegistered(address strategy);
    event StrategyRemoved(address strategy);
    event StrategyAuthorization(
        address strategy,
        address signatory,
        bool authorize
    );

    // number of blocks required for an account to be considered "permanently" unfunded
    uint256 private _seizureTimeoutMin;

    // maximum number of blocks when liquidator can liquidate an account if it is still unfunded
    uint256 private _seizureTimeoutMax;

    // block number when an acounted entered the state of being "permanently" unfunded
    mapping(address => mapping(address => uint256)) private _startedSiezures;

    // factor of how much NaviDAO token is backed up by protocol reserves. Default=50%
    // it is a good practice to keep fraction of reserves unclaimable for unfunded siezures
    uint256 private _reservesClaimableFactor;

    //here we keep track of all registered strategies for introspection only
    address[] public strategyAllowance;
    mapping(address => uint32) private _nonces; // to exclude transaction signature reuse

    function getNounce(address addr) external view returns (uint32) {
        return _nonces[addr];
    }

    constructor(
        address oracle,
        uint256 seizureTimeoutMin,
        uint256 seizureTimeoutMax
    ) NaviMarginGroup(oracle) {
        _seizureTimeoutMin = seizureTimeoutMin;
        _seizureTimeoutMax = seizureTimeoutMax;
        _reservesClaimableFactor = 0.5 ether;
        _erc1820.setInterfaceImplementer(
            address(this),
            keccak256("ERC777TokensRecipient"),
            address(this)
        );
        _erc1820.setInterfaceImplementer(
            address(this),
            keccak256("NaviController"),
            address(this)
        );
    }

    function setReservesClaimableFactor(uint256 factor) external onlyOwner {
        require(factor <= 1 ether, "factor must be <= 100%");
        emit ReservesClaimableFactorUpdated(_reservesClaimableFactor, factor);
        _reservesClaimableFactor = factor;
    }

    function setSeizureTimeout(uint256 seizureTimeoutMin) external onlyOwner {
        require(seizureTimeoutMin > 1, "seizureTimeoutMin must be 2 or more");
        require(
            seizureTimeoutMin < 500,
            "seizureTimeoutMin must be less than 500"
        );
        emit SeizureTimeoutMinUpdated(_seizureTimeoutMin, seizureTimeoutMin);
        _seizureTimeoutMin = seizureTimeoutMin;
    }

    function setSeizureTimeoutMax(uint256 seizureTimeoutMax)
        external
        onlyOwner
    {
        require(seizureTimeoutMax > 5, "seizureTimeoutMax must be 6 or more");
        require(
            seizureTimeoutMax < 50000,
            "seizureTimeoutMax must be less than 50000"
        );
        emit SeizureTimeoutMaxUpdated(_seizureTimeoutMax, seizureTimeoutMax);
        _seizureTimeoutMax = seizureTimeoutMax;
    }

    struct RegisterStrategyBySigParams {
        address strategy;
        bool authorize;
        uint32 nonce;
        uint256 expiry;
        bytes32 schema;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function authorizeStrategyBySig(bytes calldata params) external {
        RegisterStrategyBySigParams memory vars = abi.decode(
            params,
            (RegisterStrategyBySigParams)
        );
        require(
            block.timestamp <= vars.expiry,
            "Navi::registerStrategyBySig: Signature expired"
        );
        bytes32 data = keccak256(
            abi.encodePacked(
                vars.strategy,
                vars.authorize,
                address(this),
                vars.nonce,
                vars.expiry
            )
        );
        data = keccak256(abi.encodePacked(vars.schema, data));
        address signatory = ecrecover(data, vars.v, vars.r, vars.s);
        require(
            signatory != address(0),
            "Navi::registerStrategyBySig: Invalid signature"
        );
        require(
            vars.nonce > _nonces[signatory],
            "Navi::registerStrategyBySig: Invalid nonce"
        );
        _nonces[signatory] = vars.nonce;
        for (uint32 i = 0; i < _members.length; i++)
            _members[i].authorizeStrategy(
                vars.strategy,
                signatory,
                vars.authorize
            );
        emit StrategyAuthorization(vars.strategy, signatory, vars.authorize);
    }

    function authorizeStrategy(address strategy, bool authorize) public {
        for (uint32 i = 0; i < _members.length; i++)
            _members[i].authorizeStrategy(strategy, msg.sender, authorize);
        emit StrategyAuthorization(strategy, msg.sender, authorize);
    }

    function registerStrategy(address strategy) external onlyOwner {
        strategyAllowance.push(strategy); // for introspection
        for (uint32 i = 0; i < _members.length; i++)
            _members[i].authorizeStrategy(strategy, address(0), true);
        emit NewStrategyRegistered(strategy);
    }

    function removeStrategy(address strategy) external onlyOwner {
        for (uint256 i = 0; i < strategyAllowance.length; i++)
            if (strategyAllowance[i] == strategy) delete strategyAllowance[i]; // for introspection
        for (uint32 i = 0; i < _members.length; i++)
            _members[i].authorizeStrategy(strategy, address(0), false);
        emit StrategyRemoved(strategy);
    }

    function strategyAllowanceLength() external view returns (uint256) {
        return strategyAllowance.length;
    }

    /**
     * @notice NaviControllerGroup can credit itself, so account can be either net borrower(deposits=0) or
     * net depositer(borrows=0)
     */
    function netPosition(address from) public view returns (int256) {
        int256 total = 0;
        for (uint32 i = 0; i < _members.length; i++)
            total += _members[i].netPosition(from, _data[i]);

        return total;
    }

    function hasEnoughMargin(address from, uint256 amount)
        public
        view
        override
        returns (bool)
    {
        return netPosition(from) >= int256(amount);
    }

    function performSiezeChecks(address account)
        internal
        view
        returns (uint256)
    {
        int256 pos = netPosition(account);
        require(
            pos < 0,
            "NaviController::performSiezeChecks: This account is well funded"
        );
        require(
            netPosition(msg.sender) + pos > 0,
            "NaviController::performSiezeChecks: Your account is not funded enough"
        );
        return uint256(-pos);
    }

    function seizeAccount(address account) external nonReentrant {
        performSiezeChecks(account);
        for (uint32 i = 0; i < _members.length; i++)
            _members[i].seizeAccount(account, msg.sender);
        emit AccountSeized(account, msg.sender);
    }

    function startSeizure(address account) external nonReentrant {
        performSiezeChecks(account);
        _startedSiezures[account][msg.sender] = block.number;
        emit SeizureStarted(account, msg.sender, block.number);
    }

    function performStartedSeizure(address account) external nonReentrant {
        uint256 unfunded = performSiezeChecks(account);
        uint256 started = _startedSiezures[account][msg.sender];
        require(
            started > 0,
            "NaviController::performStartedSeizure: This seize is not started"
        );
        require(
            block.number - started > _seizureTimeoutMin,
            "NaviController::performStartedSeizure: Timeout is not reached yet"
        );
        require(
            block.number - started < _seizureTimeoutMax,
            "NaviController::performStartedSeizure: Started seizure has expired"
        );
        for (uint32 i = 0; i < _members.length; i++)
            _members[i].seizeAccount(account, msg.sender);
        INaviDebt(_oracle.tokenAddress(2)).controllerMint(msg.sender, unfunded);
        delete _startedSiezures[account][msg.sender];
        emit SeizurePerformed(account, msg.sender, unfunded);
    }

    function tokensReceivedInternal(
        address from,
        uint256 amount,
        bytes calldata userData
    ) internal nonReentrant {
        address daoToken = _oracle.tokenAddress(1);
        address debtToken = _oracle.tokenAddress(2);

        require(
            msg.sender == daoToken || msg.sender == debtToken,
            "nTokenForERC777: Invalid token received"
        );
        uint256 amountDebt = 0;
        (uint8 operation, address ntoken) = abi.decode(
            userData,
            (uint8, address)
        );
        if (msg.sender == daoToken) {
            amountDebt = wmul(
                wmul(
                    _reservesClaimableFactor,
                    wdiv(amount, IDaoToken(daoToken).maxSupply())
                ),
                getTotalReserves()
            );
            //amountDebt = wmul(_oracle.price(1), amount)
            IERC777(daoToken).burn(amount, "");
            if (operation == 0)
                INaviDebt(debtToken).controllerMint(from, amountDebt);
            if (operation == 1)
                INaviDebt(debtToken).controllerMint(address(this), amountDebt);
        }
        if (msg.sender == debtToken) amountDebt = amount;

        if (amountDebt > 0) {
            if (operation == 1) {
                IERC20(debtToken).approve(ntoken, amountDebt);
                InToken(ntoken).burnDebtFor(from, amountDebt);
            }
        }
    }

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external override {
        if (userData.length == 0) return;
        tokensReceivedInternal(from, amount, userData);
        emit TokensReceived(operator, from, to, amount, userData, operatorData);
    }

    //this is used in nToken to protect other chains of the protocol from misbehavior on this chain
    function setBridgeBorrowsStatus(uint8 status) external onlyOwner {
        require(status < 3, "status must be < 3"); //0=allowed 1=closeOnly 2=paused
        for (uint32 i = 0; i < _members.length; i++)
            _members[i].setBridgeBorrowsStatus(status);
        emit BridgeBorrowsStatusUpdated(status);
    }
}