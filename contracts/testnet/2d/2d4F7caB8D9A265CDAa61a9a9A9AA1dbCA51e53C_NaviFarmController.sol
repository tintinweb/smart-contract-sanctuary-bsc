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

interface IMarginGroup {
    //amount in USD
    function hasEnoughMargin(address from, uint256 amount)
        external
        view
        returns (bool);

    function balanceUpdated(uint8, address from) external;
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

/**
 * @title Controller of all farms and pools.
 * @notice Contains FarmGroups, each FarmGroup represents farms and pools of one DEX.
 * @dev This controller can be added to MarginGroup multiple times with different [_data] parameter values.
 **/
contract NaviFarmController is NaviMarginable, Ownable, IFarmController {
    IFarmGroup[] internal _members;

    constructor(address parent) NaviMarginable(1 ether, parent) Ownable() {}

    event NewFarmGroupRegistered(address farmGroup);
    event FarmGroupRemoved(address farmGroup);

    function registerFarms(address farms) external onlyOwner {
        _members.push(IFarmGroup(farms));
        emit NewFarmGroupRegistered(farms);
    }

    function removeFarms(uint32 index) external onlyOwner {
        emit FarmGroupRemoved(address(_members[index]));
        _members[index] = _members[_members.length - 1];
        _members.pop();
    }

    function getFarmsLength() external view override returns (uint256) {
        return _members.length;
    }

    function getFarms(uint32 index)
        external
        view
        override
        returns (IFarmGroup)
    {
        return _members[index];
    }

    function seizeAccount(address account, address seizeTo)
        external
        onlyParent
    {
        for (uint32 i = 0; i < _members.length; i++)
            _members[i].seizeAccount(account, seizeTo);
    }

    function hasEnoughMargin(address from, uint256 amount)
        public
        view
        override
        returns (bool)
    {
        return _parent.hasEnoughMargin(from, amount);
    }

    function netPosition(address from, uint32 id) public view returns (int256) {
        int256 totalDeposit = 0;
        for (uint16 i = 0; i < _members.length; i++)
            totalDeposit += _members[i].netPosition(from, id);

        return totalDeposit;
    }

    function getTotalReserves() public pure returns (uint256) {
        return 0;
    }

    function setBridgeBorrowsStatus(uint8 status) external {}

    function authorizeStrategy(
        address strategy,
        address signatory,
        bool authorize
    ) external onlyParent {
        for (uint32 i = 0; i < _members.length; i++)
            _members[i].authorizeStrategy(strategy, signatory, authorize);
    }
}