/**
 *Submitted for verification at BscScan.com on 2022-06-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

interface IFarmGroup is IMarginable {
    // this id is needed because index of farmGroup in farmController can change
    function farmGroupId() external view returns (uint8);

    function deposit(
        uint32 pair,
        uint32 farm,
        uint256 amount0,
        uint256 amount1,
        address account
    ) external;

    function getDepositsLength(address account) external view returns (uint256);

    struct Deposit {
        address farm;
        address pair;
        uint256 amount;
    }

    function getDeposit(address account, uint32 index)
        external
        view
        returns (Deposit memory);

    function getPairsLength() external view returns (uint256);

    function getPairAddress(uint32 index) external view returns (address);

    function getPairDeposits(uint32 index) external view returns (uint256);

    function getPair(uint32 pool)
        external
        view
        returns (address token0, address token1);

    function getFarm(uint32) external view returns (address);

    function getFarmPool(uint32) external view returns (address);

    function getReserves(uint32 index)
        external
        view
        returns (uint256[] memory r);

    function getFarmsLength() external view returns (uint256);
}

interface IFarmController {
    //amount in USD
    function hasEnoughMargin(address from, uint256 amount)
        external
        view
        returns (bool);

    //netPosition in USD
    function netPosition(address from, uint32 id)
        external
        view
        returns (int256);

    function getFarmsLength() external view returns (uint256);

    function getFarms(uint32 index) external view returns (IFarmGroup);
}

interface InToken {
    function getUnderlying() external view returns (address);

    function getPriceId() external view returns (uint32);

    function getTotalReserves() external view returns (uint256);

    function getCash() external view returns (uint256);

    function getTotalBorrows() external view returns (uint256);

    function getReserveFactor() external view returns (uint256);

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

interface IUniswapV2Pair is IERC20 {
    function totalSupply() external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

interface INaviMarginGroup {
    function getMarginableLength() external view returns (uint256);

    function getMarginable(uint32 index)
        external
        view
        returns (address, uint32);
}

interface INaviControllerGroup is INaviMarginGroup {
    function getLTV() external view returns (uint256);
}

interface nTokenWrapped {
    function getUnderlying() external view returns (address);
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

interface IBridge {
    struct Transaction {
        address recipient;
        uint32 token;
        uint256 amount;
        uint256 chainIdTo;
        bytes32 lastBlockHash;
        uint256 feeTo;
    }

    function getPastBlock(uint32 index) external view returns (bytes memory);

    function getCurrentHeight() external view returns (uint32);

    function getTransaction(address addr)
        external
        view
        returns (Transaction memory);

    function getBlockTimestamp(uint32 index) external view returns (uint256);

    function getTimestampStart() external view returns (uint256);
}

/**
 * @title An User Interface helper contract.
 * @notice Collects all the data and returns all of it in one call for faster app loading.
 * @dev Contains only view methods.
 **/
contract NaviUi is Ownable {
    INaviMarginGroup public controller;
    IFarmController public farmController;
    INaviOracle public oracle;
    IBridge public bridge;

    struct PoolInfo {
        address pool;
        uint256 balance;
        uint256[] reserves;
        uint256 supply;
        uint256 deposits;
    }

    constructor(
        address ctl,
        address farmCtl,
        address orcl,
        address brg
    ) Ownable() {
        controller = INaviMarginGroup(ctl);
        farmController = IFarmController(farmCtl);
        oracle = INaviOracle(orcl);
        bridge = IBridge(brg);
    }

    function setAddresses(
        address ctl,
        address farmCtl,
        address orcl,
        address brg
    ) external onlyOwner {
        controller = INaviMarginGroup(ctl);
        farmController = IFarmController(farmCtl);
        oracle = INaviOracle(orcl);
        bridge = IBridge(brg);
    }

    function getBridgeTransfers(address account)
        public
        view
        returns (bytes[] memory out)
    {
        uint32 height = bridge.getCurrentHeight();
        if (height == 0) return out;
        uint256 length = getBridgeTransfersLength(account);
        IBridge.Transaction memory t = bridge.getTransaction(account);
        if (t.amount > 0) length++;
        if (length == 0) return out;
        out = new bytes[](length);
        if (t.amount > 0)
            out[0] = abi.encode(t, height, bridge.getTimestampStart());
        uint256 k = 1;
        uint256 last = 0;
        if (height > 1000) last = height - 1000;
        for (uint32 i = height - 1; i > last; i--) {
            IBridge.Transaction[] memory txs = abi.decode(
                bridge.getPastBlock(i),
                (IBridge.Transaction[])
            );
            for (uint32 j = 0; j < txs.length; j++)
                if (txs[j].recipient == account)
                    out[k++] = abi.encode(
                        txs[j],
                        i,
                        bridge.getBlockTimestamp(i)
                    );
        }
    }

    function getBridgeTransfersLength(address account)
        public
        view
        returns (uint256 ret)
    {
        uint32 height = bridge.getCurrentHeight();
        if (height == 0) return 0;
        for (uint32 i = height - 1; i > 0; i--) {
            IBridge.Transaction[] memory txs = abi.decode(
                bridge.getPastBlock(i),
                (IBridge.Transaction[])
            );
            for (uint32 j = 0; j < txs.length; j++)
                if (txs[j].recipient == account) ret++;
        }
    }

    function getOracle() public view returns (bytes[] memory out) {
        uint256 length = oracle.maxId();
        out = new bytes[](length);
        for (uint32 i = 1; i <= length; i++) {
            if (oracle.isnToken(i))
                out[i - 1] = abi.encode(
                    oracle.tokenAddress(i),
                    nTokenWrapped(oracle.tokenAddress(i)).getUnderlying(),
                    oracle.price(i)
                );
            else if (oracle.hasPriceFeed(i))
                out[i - 1] = abi.encode(
                    oracle.tokenAddress(i),
                    oracle.price(i)
                );
            else if (oracle.tokenAddress(i) != address(0))
                out[i - 1] = abi.encode(oracle.tokenAddress(i));
        }
    }

    function getPrices() public view returns (bytes[] memory out) {
        uint256 length = oracle.maxId();
        out = new bytes[](length);
        for (uint32 i = 1; i <= length; i++) {
            if (oracle.hasPriceFeed(i))
                out[i - 1] = abi.encode(oracle.price(i));
        }
    }

    function getPairDeposits() public view returns (bytes[] memory out) {
        uint256 length = farmController.getFarmsLength();
        out = new bytes[](length);
        for (uint32 i = 0; i < length; i++) {
            IFarmGroup grp = farmController.getFarms(i);
            uint256 allPairsLength = grp.getPairsLength();
            uint256[] memory allPairs = new uint256[](allPairsLength);
            for (uint32 j = 0; j < length; j++) {
                allPairs[j] = grp.getPairDeposits(j);
            }
            out[i] = abi.encode(grp.farmGroupId(), allPairs);
        }
    }

    function getAll(address account, bool fullRound)
        public
        view
        returns (
            bytes[] memory groups,
            bytes[] memory farms,
            bytes[] memory prices
        )
    {
        groups = getGroup(account, controller);
        if (fullRound) farms = getFarmsFullRound(account);
        else farms = getFarms(account);
        prices = getPrices();
    }

    function getFarmsFullRound(address account)
        public
        view
        returns (bytes[] memory out)
    {
        uint256 length = farmController.getFarmsLength();
        out = new bytes[](length);
        for (uint32 i = 0; i < length; i++) {
            IFarmGroup grp = farmController.getFarms(i);
            out[i] = abi.encode(
                grp.farmGroupId(),
                grp.getLTV(),
                getFarmDeposits(account, grp),
                getPoolBalances(account, grp),
                getFarmBalances(account, grp)
            );
        }
    }

    function getFarms(address account)
        public
        view
        returns (bytes[] memory out)
    {
        uint256 length = farmController.getFarmsLength();
        out = new bytes[](length);
        for (uint32 i = 0; i < length; i++) {
            IFarmGroup grp = farmController.getFarms(i);
            out[i] = abi.encode(
                grp.farmGroupId(),
                grp.getLTV(),
                getFarmDeposits(account, grp)
            );
        }
    }

    function getFarmDeposits(address account, IFarmGroup grp)
        public
        view
        returns (IFarmGroup.Deposit[] memory out)
    {
        uint256 length = grp.getDepositsLength(account);
        out = new IFarmGroup.Deposit[](length);
        for (uint32 i = 0; i < length; i++) {
            out[i] = grp.getDeposit(account, i);
        }
    }

    function getPoolBalances(address account, IFarmGroup grp)
        public
        view
        returns (PoolInfo[] memory out)
    {
        uint256 length = grp.getPairsLength();
        out = new PoolInfo[](length);
        for (uint32 i = 0; i < length; i++) {
            address pool = grp.getPairAddress(i);
            IUniswapV2Pair pair = IUniswapV2Pair(pool);
            out[i] = PoolInfo(
                pool,
                pair.balanceOf(account),
                grp.getReserves(i),
                pair.totalSupply(),
                grp.getPairDeposits(i)
            );
        }
    }

    function getPairInfo(address[] calldata addrs)
        external
        view
        returns (PoolInfo[] memory out)
    {
        out = new PoolInfo[](addrs.length);
        for (uint32 i = 0; i < addrs.length; i++) {
            IUniswapV2Pair pair = IUniswapV2Pair(addrs[i]);
            uint256[] memory r = new uint256[](2);
            (r[0], r[1], ) = pair.getReserves();
            out[i] = PoolInfo(
                addrs[i],
                pair.balanceOf(msg.sender),
                r,
                pair.totalSupply(),
                0
            );
        }
    }

    function getFarmBalances(address account, IFarmGroup grp)
        public
        view
        returns (IFarmGroup.Deposit[] memory out)
    {
        uint256 length = grp.getFarmsLength();
        out = new IFarmGroup.Deposit[](length);
        length = grp.getFarmsLength();
        uint256 k = 0;
        for (uint32 i = 0; i < length; i++) {
            address farm = grp.getFarm(i);
            if (farm == address(0)) continue;
            uint256 balance = IERC777(farm).balanceOf(account);
            //if (balance == 0) continue;
            out[k++] = IFarmGroup.Deposit(farm, grp.getFarmPool(i), balance);
        }
    }

    function getGroupStructure(address account)
        public
        view
        returns (bytes[] memory out)
    {
        out = getGroup(account, controller);
    }

    function getGroup(address account, INaviMarginGroup group)
        public
        view
        returns (bytes[] memory out)
    {
        uint256 length = group.getMarginableLength();
        out = new bytes[](length);
        for (uint32 i = 0; i < length; i++) {
            (address item, uint32 data) = group.getMarginable(i);
            out[i] = getOne(account, item, data);
        }
    }

    IERC1820Registry internal constant _erc1820 =
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    function isnToken(address tok) internal view returns (bool) {
        return
            _erc1820.getInterfaceImplementer(tok, keccak256("NaviToken")) ==
            tok;
    }

    function isNaviControllerGroup(address tok) internal view returns (bool) {
        return
            _erc1820.getInterfaceImplementer(
                tok,
                keccak256("NaviControllerGroup")
            ) == tok;
    }

    function getBalance(address account, address item)
        public
        view
        returns (uint256)
    {
        address token = nTokenWrapped(item).getUnderlying();
        if (token == address(0)) return account.balance;
        return IERC777(token).balanceOf(account);
    }

    function encodeToken(address account, address item)
        internal
        view
        returns (bytes memory out)
    {
        InToken tok = InToken(item);
        return
            abi.encode(
                tok.getPriceId(),
                tok.getCash(),
                tok.getTotalBorrows(),
                tok.getTotalReserves(),
                tok.balanceOfUnderlying(account),
                tok.borrowBalance(account),
                tok.bridgeDeposits(account),
                tok.bridgeBorrows(account),
                tok.getReserveFactor(),
                IMarginable(item).getLTV(),
                IERC777(item).balanceOf(account),
                getBalance(account, item)
            );
    }

    function getOne(
        address account,
        address item,
        uint32 data
    ) public view returns (bytes memory out) {
        if (item == address(farmController)) {
            int256 pos = farmController.netPosition(account, data);
            if (pos == 0) return out;
            return abi.encode(pos);
        }

        if (isnToken(item)) return encodeToken(account, item);
        INaviControllerGroup grp = INaviControllerGroup(item);
        if (isNaviControllerGroup(item))
            return abi.encode(grp.getLTV(), getGroup(account, grp));
    }
}