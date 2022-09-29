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
pragma solidity 0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./libraries/Errors.sol";
import "./interfaces/IPalmPad.sol";
import "./interfaces/IPalmToken.sol";

contract PalmVesting is Ownable {
    struct VestingInfo {
        uint64 timeFromTge; // First release time from TGE (seconds)
        uint64 tgePct; // First release percentage
        uint64 periodInDays; // Vesting period of days after first release (days)
    }

    /// @dev emitted when TGE time updated
    event TgeSet(uint64 tgeTime);

    /// @dev emitted when last category updated
    event LastCategorySet(uint8 lastCategory);

    /// @dev emitted when vesting info updated
    event VestingInfoSet(uint8 indexed category, VestingInfo info);

    /// @dev emitted when user claimed PALM
    event Claimed(uint8 indexed category, address indexed user, uint256 amount);

    /// @dev emitted when amount of user set
    event AmountSet(uint8 indexed category, address user, uint256 amount);

    uint64 constant DENOMINATOR = 100000;
    uint64 constant ONE_DAY = 1 hours;

    /// @dev new category can be added later, so we don't use enum type
    uint8 constant PUBLIC_SALE = 0;
    uint8 constant PUBLIC_SALE_SPONSOR_COMMISSION = 1;
    uint8 constant SEED_SALE = 2;
    uint8 constant PRIVATE_SLAE = 3;
    uint8 constant TEAM = 4;
    uint8 constant RETROACTIVE_REWARDS = 5;
    uint8 constant MARKETING = 6;
    uint8 constant TRADING_COMPETTIION_AIRDROP = 7;
    uint8 constant AIRDROP = 8;
    uint8 constant NFT_WINNER_AIRDROP = 9;

    uint8 public lastCategory = 9;

    /// @dev palm token address
    IPalmToken public immutable palmToken;
    /// @dev palm pad address
    IPalmPad public immutable palmPad;
    /// @dev TGE time. all vesting starts after TGE.
    uint64 public tgeTime;

    /// @dev Vesting info per category
    mapping(uint8 => VestingInfo) public vestingInfos;
    /// @dev Vesting amount per category and user address
    mapping(uint8 => mapping(address => uint256)) private amounts;
    /// @dev Claimed amount per category and user address
    mapping(uint8 => mapping(address => uint256)) public claimedAmounts;

    modifier onlyValidCategory(uint8 category) {
        if (category > lastCategory) {
            revert Errors.InvalidCategory();
        }
        _;
    }

    constructor(address _palmToken, address _palmPad) {
        if (_palmToken == address(0) || _palmPad == address(0)) {
            revert Errors.ZeroAddress();
        }

        palmToken = IPalmToken(_palmToken);
        palmPad = IPalmPad(_palmPad);
    }

    /// @dev set TGE time
    function setTgeTime(uint64 _tgeTime) external onlyOwner {
        if (_tgeTime == 0) {
            revert Errors.ZeroAmount();
        }
        tgeTime = _tgeTime;

        emit TgeSet(_tgeTime);
    }

    /// @dev set last category
    function setLastCategory(uint8 _lastCategory) external onlyOwner {
        lastCategory = _lastCategory;

        emit LastCategorySet(_lastCategory);
    }

    /// @dev set vesting info
    function setVestingInfo(uint8 category, VestingInfo calldata vestingInfo)
        public
        onlyOwner
        onlyValidCategory(category)
    {
        if (vestingInfo.tgePct > DENOMINATOR) {
            revert Errors.InvalidPercentage();
        }
        if (
            vestingInfo.tgePct != DENOMINATOR && vestingInfo.periodInDays == 0
        ) {
            revert Errors.InvalidVestingInfo();
        }
        vestingInfos[category] = vestingInfo;

        emit VestingInfoSet(category, vestingInfo);
    }

    /// @dev set multiple vesting infos
    function setVestingInfoInBatch(
        uint8[] calldata _categories,
        VestingInfo[] calldata _vestingInfos
    ) external {
        uint256 len = _categories.length;
        if (len == 0 || len != _vestingInfos.length) {
            revert Errors.InvalidArray();
        }
        for (uint256 i = 0; i < len; i += 1) {
            setVestingInfo(_categories[i], _vestingInfos[i]);
        }
    }

    /// @dev set vesting amount per category and user
    function setAmount(
        uint8 category,
        address user,
        uint256 amount
    ) public onlyOwner onlyValidCategory(category) {
        if (amount == 0) {
            revert Errors.ZeroAmount();
        }
        if (user == address(0)) {
            revert Errors.ZeroAddress();
        }
        require(
            category != PUBLIC_SALE &&
                category != PUBLIC_SALE_SPONSOR_COMMISSION,
            "PalmVesting: Cannot set amount for public sale"
        );

        amounts[category][user] = amount;

        emit AmountSet(category, user, amount);
    }

    /// @dev set multiple amounts
    function setAmountInBatch(
        uint8[] calldata _categories,
        address[] calldata _users,
        uint256[] calldata _amounts
    ) external {
        uint256 len = _categories.length;
        if (len == 0 || len != _users.length || len != _amounts.length) {
            revert Errors.InvalidArray();
        }
        for (uint256 i = 0; i < len; i += 1) {
            setAmount(_categories[i], _users[i], _amounts[i]);
        }
    }

    /// @dev get allocated amount per category and user
    function getAmount(uint8 category, address user)
        public
        view
        returns (uint256)
    {
        if (category == PUBLIC_SALE) {
            return palmPad.getPalmAmount(user);
        } else if (category == PUBLIC_SALE_SPONSOR_COMMISSION) {
            return palmPad.getPalmCommissionAmount(user);
        } else {
            return amounts[category][user];
        }
    }

    /// @dev get vested amount until now
    function getVestedAmount(uint8 category, address user)
        public
        view
        returns (uint256)
    {
        VestingInfo memory vestingInfo = vestingInfos[category];
        uint256 totalAmount = getAmount(category, user);

        if (totalAmount == 0 || block.timestamp < tgeTime) {
            return 0;
        }

        uint64 firstReleaseTime = tgeTime + vestingInfo.timeFromTge;
        uint256 tgeAmount = (totalAmount * vestingInfo.tgePct) / DENOMINATOR;

        if (block.timestamp < firstReleaseTime) {
            return tgeAmount;
        }

        if (vestingInfo.tgePct == DENOMINATOR) {
            return totalAmount;
        }
        if (vestingInfo.periodInDays == 0) {
            return 0;
        }

        uint256 totalVestedAmount = totalAmount - tgeAmount;
        uint64 elapsedDays = (uint64(block.timestamp) - firstReleaseTime) /
            ONE_DAY;

        uint256 vestedAmount = ((totalVestedAmount * elapsedDays) /
            vestingInfo.periodInDays) + tgeAmount;

        if (vestedAmount > totalAmount) {
            return totalAmount;
        }
        return vestedAmount;
    }

    /// @dev claim available PALM
    function claim(uint8 category, bool revertForZero) public {
        uint256 vestedAmount = getVestedAmount(category, msg.sender);
        uint256 availableAmount = vestedAmount -
            claimedAmounts[category][msg.sender];

        if (availableAmount != 0) {
            claimedAmounts[category][msg.sender] = vestedAmount;
            palmToken.mint(msg.sender, availableAmount);

            emit Claimed(category, msg.sender, availableAmount);
        } else if (revertForZero) {
            revert Errors.NothingToClaim();
        }
    }

    /// @dev claim available PALM of all categories
    function claimAll() external {
        uint256 lastIdx = lastCategory;
        for (uint8 i = 0; i <= lastIdx; i += 1) {
            claim(uint8(i), false);
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

interface IPalmPad {
    /// @dev get PALM allocation from launchpad
    function getPalmAmount(address user) external view returns (uint256);

    /// @dev get PALM commission from launchpad invite program
    function getPalmCommissionAmount(address user)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPalmToken is IERC20 {
    function mint(address to, uint256 amount) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

library Errors {
    error ZeroAddress();
    error ZeroAmount();
    error NotReadyToMint();
    error AlreadyStarted();
    error MintStartBlockNotSet();
    error PoolDoesNotExist();
    error NoReward();
    error AlreadyClaimed();
    error InvalidProof();
    error InvalidPercentage();
    error InvalidArray();
    error NothingToRecover();
    error InvalidVestingInfo();
    error NothingToClaim();
    error InvalidCategory();
}