// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./interfaces/IERC20BurnableMinter.sol";
import "./interfaces/IMarket.sol";
import "./interfaces/IBank.sol";
import "./interfaces/IStakePool.sol";
import "./utils/Initializer.sol";
import "./utils/DelegateGuard.sol";

contract Bank is Context, Ownable, Pausable, Initializer, DelegateGuard, IBank {
    // Order token address
    IERC20BurnableMinter public override Order;
    // Market contract address
    IMarket public override market;
    // StakePool contract address
    IStakePool public override pool;
    // helper contract address
    address public override helper;

    // user debt
    mapping(address => uint256) public override debt;

    // developer address
    address public override dev;
    // fee for borrowing Order
    uint32 public override borrowFee;

    event OptionsChanged(address dev, uint32 borrowFee);

    event Borrow(address user, uint256 amount, uint256 fee);

    event Repay(address user, uint256 amount);

    modifier onlyHelper() {
        require(_msgSender() == helper, "Bank: only helper");
        _;
    }

    /**
     * @dev Constructor.
     * NOTE This function can only called through delegatecall.
     * @param _Order - Order token address.
     * @param _market - Market contract address.
     * @param _pool - StakePool contract address.
     * @param _helper - Helper contract address.
     * @param _owner - Owner address.
     */
    function constructor1(
        IERC20BurnableMinter _Order,
        IMarket _market,
        IStakePool _pool,
        address _helper,
        address _owner
    ) external override isDelegateCall isUninitialized {
        Order = _Order;
        market = _market;
        pool = _pool;
        helper = _helper;
        _transferOwnership(_owner);
    }

    /**
     * @dev Set bank options.
     *      The caller must be owner.
     * @param _dev - Developer address
     * @param _borrowFee - Fee for borrowing Order
     */
    function setOptions(address _dev, uint32 _borrowFee)
        public
        override
        onlyOwner
    {
        require(_dev != address(0), "Bank: zero dev address");
        require(_borrowFee <= 10000, "Bank: invalid borrowFee");
        dev = _dev;
        borrowFee = _borrowFee;
        emit OptionsChanged(_dev, _borrowFee);
    }

    /**
     * @dev Calculate the amount of Chaos that can be withdrawn.
     * @param user - User address
     */
    function withdrawable(address user)
        external
        view
        override
        isInitialized
        returns (uint256)
    {
        uint256 userDebt = debt[user];
        (uint256 amountChaos, ) = pool.userInfo(0, user);
        uint256 floorPrice = market.f();
        if (amountChaos * floorPrice <= userDebt * 1e18) {
            return 0;
        }
        return (amountChaos * floorPrice - userDebt * 1e18) / floorPrice;
    }

    /**
     * @dev Calculate the amount of Chaos that can be withdrawn.
     * @param user - User address
     * @param amountChaos - User staked Chaos amount
     */
    function withdrawable(address user, uint256 amountChaos)
        external
        view
        override
        isInitialized
        returns (uint256)
    {
        uint256 userDebt = debt[user];
        uint256 floorPrice = market.f();
        if (amountChaos * floorPrice <= userDebt * 1e18) {
            return 0;
        }
        return (amountChaos * floorPrice - userDebt * 1e18) / floorPrice;
    }

    /**
     * @dev Calculate the amount of Order that can be borrowed.
     * @param user - User address
     */
    function available(address user)
        public
        view
        override
        isInitialized
        returns (uint256)
    {
        uint256 userDebt = debt[user];
        (uint256 amountChaos, ) = pool.userInfo(0, user);
        uint256 floorPrice = market.f();
        if (amountChaos * floorPrice <= userDebt * 1e18) {
            return 0;
        }
        return (amountChaos * floorPrice - userDebt * 1e18) / 1e18;
    }

    /**
     * @dev Borrow Order.
     * @param amount - The amount of Order
     * @return borrowed - Borrowed Order
     * @return fee - Borrow fee
     */
    function borrow(uint256 amount)
        external
        override
        isInitialized
        whenNotPaused
        returns (uint256 borrowed, uint256 fee)
    {
        return _borrowFrom(_msgSender(), amount);
    }

    /**
     * @dev Borrow Order from user and directly mint to msg.sender.
     *      The caller must be helper contract.
     * @param user - User address
     * @param amount - The amount of Order
     * @return borrowed - Borrowed Order
     * @return fee - Borrow fee
     */
    function borrowFrom(address user, uint256 amount)
        external
        override
        onlyHelper
        isInitialized
        whenNotPaused
        returns (uint256 borrowed, uint256 fee)
    {
        return _borrowFrom(user, amount);
    }

    /**
     * @dev Borrow Order from user and directly mint to msg.sender.
     */
    function _borrowFrom(address user, uint256 amount)
        internal
        returns (uint256 borrowed, uint256 fee)
    {
        require(amount > 0, "Bank: amount is zero");
        uint256 userDebt = debt[user];
        (uint256 amountChaos, ) = pool.userInfo(0, user);
        require(
            userDebt + amount <= (amountChaos * market.f()) / 1e18,
            "Bank: exceeds available"
        );
        fee = (amount * borrowFee) / 10000;
        borrowed = amount - fee;
        Order.mint(_msgSender(), borrowed);
        Order.mint(dev, fee);
        debt[user] = userDebt + amount;
        emit Borrow(user, borrowed, fee);
    }

    /**
     * @dev Repay Order.
     * @param amount - The amount of Order
     */
    function repay(uint256 amount)
        external
        override
        isInitialized
        whenNotPaused
    {
        require(amount > 0, "Bank: amount is zero");
        uint256 userDebt = debt[_msgSender()];
        require(userDebt >= amount, "Bank: exceeds debt");
        Order.burnFrom(_msgSender(), amount);
        unchecked {
            debt[_msgSender()] = userDebt - amount;
        }
        emit Repay(_msgSender(), amount);
    }

    /**
     * @dev Triggers stopped state.
     *      The caller must be owner.
     */
    function pause() external override onlyOwner {
        _pause();
    }

    /**
     * @dev Returns to normal state.
     *      The caller must be owner.
     */
    function unpause() external override onlyOwner {
        _unpause();
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IERC20BurnableMinter is IERC20Metadata {
    function mint(address to, uint256 amount) external;

    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/IAccessControlEnumerable.sol";
import "./IERC20BurnableMinter.sol";
import "./IStakePool.sol";

interface IMarket is IAccessControlEnumerable {
    function Chaos() external view returns (IERC20BurnableMinter);

    function prChaos() external view returns (IERC20BurnableMinter);

    function pool() external view returns (IStakePool);

    // target funding ratio (target/10000)
    function target() external view returns (uint32);

    // target adjusted funding ratio (targetAdjusted/10000)
    function targetAdjusted() external view returns (uint32);

    // minimum value of target
    function minTarget() external view returns (uint32);

    // maximum value of the targetAdjusted
    function maxTargetAdjusted() external view returns (uint32);

    // step value of each raise
    function raiseStep() external view returns (uint32);

    // step value of each lower
    function lowerStep() external view returns (uint32);

    // interval of each lower
    function lowerInterval() external view returns (uint32);

    // the time when ratio was last modified
    function latestUpdateTimestamp() external view returns (uint256);

    // developer address
    function dev() external view returns (address);

    // fee for buying Chaos
    function buyFee() external view returns (uint32);

    // fee for selling Chaos
    function sellFee() external view returns (uint32);

    // the slope of the price function (1/(k * 1e18))
    function k() external view returns (uint256);

    // current Chaos price
    function c() external view returns (uint256);

    // floor Chaos price
    function f() external view returns (uint256);

    // floor supply
    function p() external view returns (uint256);

    // total worth
    function w() external view returns (uint256);

    // stablecoins decimals
    function stablecoinsDecimals(address token) external view returns (uint8);

    /**
     * @dev Constructor.
     * NOTE This function can only called through delegatecall.
     * @param _Chaos - Chaos token address.
     * @param _prChaos - _prChaos token address.
     * @param _pool - StakePool contract addresss.
     * @param _k - Slope.
     * @param _target - Target funding ratio.
     * @param _targetAdjusted - Target adjusted funding ratio.
     * @param _manager - Manager address.
     * @param _stablecoins - Stablecoin addresses.
     */
    function constructor1(
        IERC20BurnableMinter _Chaos,
        IERC20BurnableMinter _prChaos,
        IStakePool _pool,
        uint256 _k,
        uint32 _target,
        uint32 _targetAdjusted,
        address _manager,
        address[] memory _stablecoins
    ) external;

    /**
     * @dev Startup market.
     *      The caller must be owner.
     * @param _token - Initial stablecoin address
     * @param _w - Initial stablecoin worth
     * @param _t - Initial Chaos total supply
     */
    function startup(
        address _token,
        uint256 _w,
        uint256 _t
    ) external;

    /**
     * @dev Get the number of stablecoins that can buy Chaos.
     */
    function stablecoinsCanBuyLength() external view returns (uint256);

    /**
     * @dev Get the address of the stablecoin that can buy Chaos according to the index.
     * @param index - Stablecoin index
     */
    function stablecoinsCanBuyAt(uint256 index) external view returns (address);

    /**
     * @dev Get whether the token can be used to buy Chaos.
     * @param token - Token address
     */
    function stablecoinsCanBuyContains(address token)
        external
        view
        returns (bool);

    /**
     * @dev Get the number of stablecoins that can be exchanged with Chaos.
     */
    function stablecoinsCanSellLength() external view returns (uint256);

    /**
     * @dev Get the address of the stablecoin that can be exchanged with Chaos,
     *      according to the index.
     * @param index - Stablecoin index
     */
    function stablecoinsCanSellAt(uint256 index)
        external
        view
        returns (address);

    /**
     * @dev Get whether the token can be exchanged with Chaos.
     * @param token - Token address
     */
    function stablecoinsCanSellContains(address token)
        external
        view
        returns (bool);

    /**
     * @dev Calculate current funding ratio.
     */
    function currentFundingRatio()
        external
        view
        returns (uint256 numerator, uint256 denominator);

    /**
     * @dev Estimate adjust result.
     * @param _k - Slope
     * @param _tar - Target funding ratio
     * @param _w - Total worth
     * @param _t - Total supply
     * @return success - Whether the calculation was successful
     * @return _c - Current price
     * @return _f - Floor price
     * @return _p - Point of intersection
     */
    function estimateAdjust(
        uint256 _k,
        uint256 _tar,
        uint256 _w,
        uint256 _t
    )
        external
        pure
        returns (
            bool success,
            uint256 _c,
            uint256 _f,
            uint256 _p
        );

    /**
     * @dev Estimate next raise price.
     * @return success - Whether the calculation was successful
     * @return _t - The total supply when the funding ratio reaches targetAdjusted
     * @return _c - The price when the funding ratio reaches targetAdjusted
     * @return _w - The total worth when the funding ratio reaches targetAdjusted
     * @return raisedFloorPrice - The floor price after market adjusted
     */
    function estimateRaisePrice()
        external
        view
        returns (
            bool success,
            uint256 _t,
            uint256 _c,
            uint256 _w,
            uint256 raisedFloorPrice
        );

    /**
     * @dev Estimate raise price by input value.
     * @param _f - Floor price
     * @param _k - Slope
     * @param _p - Floor supply
     * @param _tar - Target funding ratio
     * @param _tarAdjusted - Target adjusted funding ratio
     * @return success - Whether the calculation was successful
     * @return _t - The total supply when the funding ratio reaches _tar
     * @return _c - The price when the funding ratio reaches _tar
     * @return _w - The total worth when the funding ratio reaches _tar
     * @return raisedFloorPrice - The floor price after market adjusted
     */
    function estimateRaisePrice(
        uint256 _f,
        uint256 _k,
        uint256 _p,
        uint256 _tar,
        uint256 _tarAdjusted
    )
        external
        pure
        returns (
            bool success,
            uint256 _t,
            uint256 _c,
            uint256 _w,
            uint256 raisedFloorPrice
        );

    /**
     * @dev Lower target and targetAdjusted with lowerStep.
     */
    function lowerAndAdjust() external;

    /**
     * @dev Set market options.
     *      The caller must has MANAGER_ROLE.
     *      This function can only be called before the market is started.
     * @param _k - Slope
     * @param _target - Target funding ratio
     * @param _targetAdjusted - Target adjusted funding ratio
     */
    function setMarketOptions(
        uint256 _k,
        uint32 _target,
        uint32 _targetAdjusted
    ) external;

    /**
     * @dev Set adjust options.
     *      The caller must be owner.
     * @param _minTarget - Minimum value of target
     * @param _maxTargetAdjusted - Maximum value of the targetAdjusted
     * @param _raiseStep - Step value of each raise
     * @param _lowerStep - Step value of each lower
     * @param _lowerInterval - Interval of each lower
     */
    function setAdjustOptions(
        uint32 _minTarget,
        uint32 _maxTargetAdjusted,
        uint32 _raiseStep,
        uint32 _lowerStep,
        uint32 _lowerInterval
    ) external;

    /**
     * @dev Set fee options.
     *      The caller must be owner.
     * @param _dev - Dev address
     * @param _buyFee - Fee for buying Chaos
     * @param _sellFee - Fee for selling Chaos
     */
    function setFeeOptions(
        address _dev,
        uint32 _buyFee,
        uint32 _sellFee
    ) external;

    /**
     * @dev Manage stablecoins.
     *      Add/Delete token to/from stablecoinsCanBuy/stablecoinsCanSell.
     *      The caller must be owner.
     * @param token - Token address
     * @param buyOrSell - Buy or sell token
     * @param addOrDelete - Add or delete token
     */
    function manageStablecoins(
        address token,
        bool buyOrSell,
        bool addOrDelete
    ) external;

    /**
     * @dev Estimate how much Chaos user can buy.
     * @param token - Stablecoin address
     * @param tokenWorth - Number of stablecoins
     * @return amount - Number of Chaos
     * @return fee - Dev fee
     * @return worth1e18 - The amount of stablecoins being exchanged(1e18)
     * @return newPrice - New Chaos price
     */
    function estimateBuy(address token, uint256 tokenWorth)
        external
        view
        returns (
            uint256 amount,
            uint256 fee,
            uint256 worth1e18,
            uint256 newPrice
        );

    /**
     * @dev Estimate how many stablecoins will be needed to realize prChaos.
     * @param amount - Number of prChaos user want to realize
     * @param token - Stablecoin address
     * @return worth1e18 - The amount of stablecoins being exchanged(1e18)
     * @return worth - The amount of stablecoins being exchanged
     */
    function estimateRealize(uint256 amount, address token)
        external
        view
        returns (uint256 worth1e18, uint256 worth);

    /**
     * @dev Estimate how much stablecoins user can sell.
     * @param amount - Number of Chaos user want to sell
     * @param token - Stablecoin address
     * @return fee - Dev fee
     * @return worth1e18 - The amount of stablecoins being exchanged(1e18)
     * @return worth - The amount of stablecoins being exchanged
     * @return newPrice - New Chaos price
     */
    function estimateSell(uint256 amount, address token)
        external
        view
        returns (
            uint256 fee,
            uint256 worth1e18,
            uint256 worth,
            uint256 newPrice
        );

    /**
     * @dev Buy Chaos.
     * @param token - Address of stablecoin used to buy Chaos
     * @param tokenWorth - Number of stablecoins
     * @param desired - Minimum amount of Chaos user want to buy
     * @return amount - Number of Chaos
     * @return fee - Dev fee(Chaos)
     */
    function buy(
        address token,
        uint256 tokenWorth,
        uint256 desired
    ) external returns (uint256, uint256);

    /**
     * @dev Buy Chaos for user.
     * @param token - Address of stablecoin used to buy Chaos
     * @param tokenWorth - Number of stablecoins
     * @param desired - Minimum amount of Chaos user want to buy
     * @param user - User address
     * @return amount - Number of Chaos
     * @return fee - Dev fee(Chaos)
     */
    function buyFor(
        address token,
        uint256 tokenWorth,
        uint256 desired,
        address user
    ) external returns (uint256, uint256);

    /**
     * @dev Realize Chaos with floor price and equal amount of prChaos.
     * @param amount - Amount of prChaos user want to realize
     * @param token - Address of stablecoin used to realize prChaos
     * @param desired - Maximum amount of stablecoin users are willing to pay
     * @return worth - The amount of stablecoins being exchanged
     */
    function realize(
        uint256 amount,
        address token,
        uint256 desired
    ) external returns (uint256);

    /**
     * @dev Realize Chaos with floor price and equal amount of prChaos for user.
     * @param amount - Amount of prChaos user want to realize
     * @param token - Address of stablecoin used to realize prChaos
     * @param desired - Maximum amount of stablecoin users are willing to pay
     * @param user - User address
     * @return worth - The amount of stablecoins being exchanged
     */
    function realizeFor(
        uint256 amount,
        address token,
        uint256 desired,
        address user
    ) external returns (uint256);

    /**
     * @dev Sell Chaos.
     * @param amount - Amount of Chaos user want to sell
     * @param token - Address of stablecoin used to buy Chaos
     * @param desired - Minimum amount of stablecoins user want to get
     * @return fee - Dev fee(Chaos)
     * @return worth - The amount of stablecoins being exchanged
     */
    function sell(
        uint256 amount,
        address token,
        uint256 desired
    ) external returns (uint256, uint256);

    /**
     * @dev Sell Chaos for user.
     * @param amount - Amount of Chaos user want to sell
     * @param token - Address of stablecoin used to buy Chaos
     * @param desired - Minimum amount of stablecoins user want to get
     * @param user - User address
     * @return fee - Dev fee(Chaos)
     * @return worth - The amount of stablecoins being exchanged
     */
    function sellFor(
        uint256 amount,
        address token,
        uint256 desired,
        address user
    ) external returns (uint256, uint256);

    /**
     * @dev Burn Chaos.
     *      It will preferentially transfer the excess value after burning to PSL.
     * @param amount - The amount of Chaos the user wants to burn
     */
    function burn(uint256 amount) external;

    /**
     * @dev Burn Chaos for user.
     *      It will preferentially transfer the excess value after burning to PSL.
     * @param amount - The amount of Chaos the user wants to burn
     * @param user - User address
     */
    function burnFor(uint256 amount, address user) external;

    /**
     * @dev Triggers stopped state.
     *      The caller must be owner.
     */
    function pause() external;

    /**
     * @dev Returns to normal state.
     *      The caller must be owner.
     */
    function unpause() external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20BurnableMinter.sol";
import "./IStakePool.sol";
import "./IMarket.sol";

interface IBank {
    // Order token address
    function Order() external view returns (IERC20BurnableMinter);

    // Market contract address
    function market() external view returns (IMarket);

    // StakePool contract address
    function pool() external view returns (IStakePool);

    // helper contract address
    function helper() external view returns (address);

    // user debt
    function debt(address user) external view returns (uint256);

    // developer address
    function dev() external view returns (address);

    // fee for borrowing Order
    function borrowFee() external view returns (uint32);

    /**
     * @dev Constructor.
     * NOTE This function can only called through delegatecall.
     * @param _Order - Order token address.
     * @param _market - Market contract address.
     * @param _pool - StakePool contract address.
     * @param _helper - Helper contract address.
     * @param _owner - Owner address.
     */
    function constructor1(
        IERC20BurnableMinter _Order,
        IMarket _market,
        IStakePool _pool,
        address _helper,
        address _owner
    ) external;

    /**
     * @dev Set bank options.
     *      The caller must be owner.
     * @param _dev - Developer address
     * @param _borrowFee - Fee for borrowing Order
     */
    function setOptions(address _dev, uint32 _borrowFee) external;

    /**
     * @dev Calculate the amount of Chaos that can be withdrawn.
     * @param user - User address
     */
    function withdrawable(address user) external view returns (uint256);

    /**
     * @dev Calculate the amount of Chaos that can be withdrawn.
     * @param user - User address
     * @param amountChaos - User staked Chaos amount
     */
    function withdrawable(address user, uint256 amountChaos)
        external
        view
        returns (uint256);

    /**
     * @dev Calculate the amount of Order that can be borrowed.
     * @param user - User address
     */
    function available(address user) external view returns (uint256);

    /**
     * @dev Borrow Order.
     * @param amount - The amount of Order
     * @return borrowed - Borrowed Order
     * @return fee - Borrow fee
     */
    function borrow(uint256 amount)
        external
        returns (uint256 borrowed, uint256 fee);

    /**
     * @dev Borrow Order from user and directly mint to msg.sender.
     *      The caller must be helper contract.
     * @param user - User address
     * @param amount - The amount of Order
     * @return borrowed - Borrowed Order
     * @return fee - Borrow fee
     */
    function borrowFrom(address user, uint256 amount)
        external
        returns (uint256 borrowed, uint256 fee);

    /**
     * @dev Repay Order.
     * @param amount - The amount of Order
     */
    function repay(uint256 amount) external;

    /**
     * @dev Triggers stopped state.
     *      The caller must be owner.
     */
    function pause() external;

    /**
     * @dev Returns to normal state.
     *      The caller must be owner.
     */
    function unpause() external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IERC20BurnableMinter.sol";
import "./IBank.sol";

// The stakepool will mint prChaos according to the total supply of Chaos and
// then distribute it to all users according to the amount of Chaos deposited by each user.
interface IStakePool {
    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of prChaoss
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. prChaoss to distribute per block.
        uint256 lastRewardBlock; // Last block number that prChaoss distribution occurs.
        uint256 accPerShare; // Accumulated prChaoss per share, times 1e12. See below.
    }

    // The Chaos token
    function Chaos() external view returns (IERC20);

    // The prChaos token
    function prChaos() external view returns (IERC20BurnableMinter);

    // The bank contract address
    function bank() external view returns (IBank);

    // Info of each pool.
    function poolInfo(uint256 index)
        external
        view
        returns (
            IERC20,
            uint256,
            uint256,
            uint256
        );

    // Info of each user that stakes LP tokens.
    function userInfo(uint256 pool, address user)
        external
        view
        returns (uint256, uint256);

    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    function totalAllocPoint() external view returns (uint256);

    // Daily minted Chaos as a percentage of total supply, the value is mintPercentPerDay / 1000.
    function mintPercentPerDay() external view returns (uint32);

    // How many blocks are there in a day.
    function blocksPerDay() external view returns (uint256);

    // Developer address.
    function dev() external view returns (address);

    // Withdraw fee(Chaos).
    function withdrawFee() external view returns (uint32);

    // Mint fee(prChaos).
    function mintFee() external view returns (uint32);

    // Constructor.
    function constructor1(
        IERC20 _Chaos,
        IERC20BurnableMinter _prChaos,
        IBank _bank,
        address _owner
    ) external;

    function poolLength() external view returns (uint256);

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate
    ) external;

    // Update the given pool's prChaos allocation point. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) external;

    // Set options. Can only be called by the owner.
    function setOptions(
        uint32 _mintPercentPerDay,
        uint256 _blocksPerDay,
        address _dev,
        uint32 _withdrawFee,
        uint32 _mintFee,
        bool _withUpdate
    ) external;

    // View function to see pending prChaoss on frontend.
    function pendingRewards(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    // Update reward vairables for all pools. Be careful of gas spending!
    function massUpdatePools() external;

    // Deposit LP tokens to StakePool for prChaos allocation.
    function deposit(uint256 _pid, uint256 _amount) external;

    // Deposit LP tokens to StakePool for user for prChaos allocation.
    function depositFor(
        uint256 _pid,
        uint256 _amount,
        address _user
    ) external;

    // Withdraw LP tokens from StakePool.
    function withdraw(uint256 _pid, uint256 _amount) external;

    // Claim reward.
    function claim(uint256 _pid) external;

    // Claim reward for user.
    function claimFor(uint256 _pid, address _user) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Initializer {
    bool public initialized = false;

    modifier isUninitialized() {
        require(!initialized, "Initializer: initialized");
        _;
        initialized = true;
    }

    modifier isInitialized() {
        require(initialized, "Initializer: uninitialized");
        _;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract DelegateGuard {
    // a global variable used to determine whether it is a delegatecall
    address private immutable self = address(this);

    modifier isDelegateCall() {
        require(self != address(this), "DelegateGuard: delegate call");
        _;
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
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}