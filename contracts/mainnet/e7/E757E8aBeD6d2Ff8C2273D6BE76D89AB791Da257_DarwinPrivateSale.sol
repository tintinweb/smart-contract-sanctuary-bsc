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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IDarwinPresale} from "./interface/IDarwinPresale.sol";
import {IDarwinVester} from "./interface/IDarwinVester.sol";
import {IDarwin} from "./interface/IDarwin.sol";

/// @title Darwin Private Sale
contract DarwinPrivateSale is IDarwinPresale, ReentrancyGuard, Ownable {
    /// @notice Min BNB deposit per user
    uint256 public constant RAISE_MIN = .1 ether;
    /// @notice Max BNB deposit per user
    uint256 public constant RAISE_MAX = 200 ether;
    /// @notice Max number of BNB to be raised
    uint256 public constant HARDCAP = 500 ether;
    /// @notice How many DARWIN are sold for each BNB invested
    uint256 public constant DARWIN_PER_BNB = 10_000;
    /// @notice The % sent right away to the user. The left percentage is sent to the vester contract
    uint256 public constant PERC = 25;

    /// @notice The Darwin token
    IERC20 public darwin;
    /// @notice The Vester contract
    IDarwinVester public vester;
    /// @notice Timestamp of the presale start
    uint256 public presaleStart;
    /// @notice True if presale has been ended
    bool public privateSaleEnded;

    address public wallet1;

    enum Status {
        QUEUED,
        ACTIVE,
        SUCCESS
    }

    struct PresaleStatus {
        uint256 raisedAmount; // Total BNB raised
        uint256 soldAmount; // Total Darwin sold
        uint256 numBuyers; // Number of unique participants
    }

    /// @notice Mapping of total BNB deposited by user
    mapping(address => uint256) public userDeposits;

    PresaleStatus public status;

    bool private _isInitialized;

    modifier isInitialized() {
        if (!_isInitialized) {
            revert NotInitialized();
        }
        _;
    }

    /// @dev Initializes the darwin address and private sale start date
    /// @param _darwin The darwin token address
    /// @param _presaleStart The private sale start date
    function init(
        address _darwin,
        address _vester,
        uint256 _presaleStart
    ) external onlyOwner {
        if (_isInitialized) revert AlreadyInitialized();
        _isInitialized = true;
        if (_darwin == address(0) || _vester == address(0)) revert ZeroAddress();
        // solhint-disable-next-line not-rely-on-time
        if (_presaleStart < block.timestamp) revert InvalidStartDate();
        darwin = IERC20(_darwin);
        vester = IDarwinVester(_vester);
        IDarwin(address(darwin)).pause();
        _setWallet1(0x0bF1C4139A6168988Fe0d1384296e6df44B27aFd);
        presaleStart = _presaleStart;
    }

    /// @notice Deposits BNB into the presale
    /// @dev Emits a UserDeposit event
    /// @dev Emits a RewardsDispersed event
    function userDeposit() external payable nonReentrant isInitialized {

        if (presaleStatus() != Status.ACTIVE) {
            revert PresaleNotActive();
        }

        if (msg.value < RAISE_MIN || msg.value > RAISE_MAX) {
            revert InvalidDepositAmount();
        }

        if (userDeposits[msg.sender] == 0) {
            // new depositer
            ++status.numBuyers;
        }

        userDeposits[msg.sender] += msg.value;

        uint256 darwinAmount = msg.value * DARWIN_PER_BNB;

        status.raisedAmount += msg.value;
        status.soldAmount += darwinAmount;

        uint256 darwinAmountToUser = (darwinAmount * PERC) / 100;

        if (!darwin.transfer(msg.sender, darwinAmountToUser)) {
            revert TransferFailed();
        }
        darwin.approve(address(vester), darwinAmount - darwinAmountToUser);
        vester.deposit(msg.sender, darwinAmount - darwinAmountToUser);

        emit UserDeposit(msg.sender, msg.value, darwinAmount);
    }

    /// @notice Ends the private sale
    function endSale() external onlyOwner {
        // solhint-disable-next-line not-rely-on-time
        if (block.timestamp < presaleStart) {
            revert InvalidEndDate();
        }
        privateSaleEnded = true;
        emit PresaleEndDateSet(block.timestamp);
    }

    /// @notice Set address for Wallet1
    /// @param _wallet1 The new Wallet1 address
    function setWallet1(
        address _wallet1
    ) external onlyOwner {
        if (_wallet1 == address(0)) {
            revert ZeroAddress();
        }
        _setWallet1(_wallet1);
    }

    /// @dev Sends any unsold Darwin and raised BNB to Wallet 1
    function withdrawUnsoldDarwinAndRaisedBNB() external onlyOwner {
        if (wallet1 == address(0)) {
            revert ZeroAddress();
        }
        if (presaleStatus() != Status.SUCCESS) {
            revert PresaleNotEnded();
        }

        _transferBNB(wallet1, address(this).balance);

        // Send any unsold Darwin to Wallet 1
        if (darwin.balanceOf(address(this)) > 0) {
            darwin.transfer(wallet1, darwin.balanceOf(address(this)));
        }
    }

    function tokensDepositedAndOwned(
        address account
    ) external view returns (uint256, uint256) {
        uint256 deposited = userDeposits[account];
        uint256 owned = darwin.balanceOf(account);
        return (deposited, owned);
    }

    /// @notice Returns the number of BNB left to be raised on the current stage
    /// @return tokensLeft The number of BNB left to be raised on the current stage
    /// @dev The name of the function has been left unmodified to not cause mismatches with the frontend (we're using DarwinPresale typechain there)
    function baseTokensLeftToRaiseOnCurrentStage()
        public
        view
        returns (uint256 tokensLeft)
    {
        tokensLeft = HARDCAP - status.raisedAmount;
    }

    /// @notice Returns the current presale status
    /// @return The current presale status
    function presaleStatus() public view returns (Status) {
        // solhint-disable-next-line not-rely-on-time
        if (status.raisedAmount >= HARDCAP || privateSaleEnded) {
            return Status.SUCCESS; // Wonderful, presale has ended
        }

        // solhint-disable-next-line not-rely-on-time
        if (block.timestamp >= presaleStart && !privateSaleEnded) {
            return Status.ACTIVE; // ACTIVE - Deposits enabled, now in Presale
        }

        return Status.QUEUED; // QUEUED - Awaiting start block
    }

    function _transferBNB(address to, uint256 amount) internal {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = payable(to).call{value: amount}("");
        if (!success) {
            revert TransferFailed();
        }
    }

    function _setWallet1(address _wallet1) internal {
        wallet1 = _wallet1;
        emit Wallet1Set(_wallet1);
    }
}

pragma solidity ^0.8.14;

// SPDX-License-Identifier: MIT

interface IDarwin {

    /// @notice Accumulatively log sold tokens
    struct TokenSellLog {
        uint40 lastSale;
        uint216 amount;
    }

    event ExcludedFromReflection(address account, bool isExcluded);
    event ExcludedFromSellLimit(address account, bool isExcluded);

    // PUBLIC
    function distributeRewards(uint256 amount) external;
    function bulkTransfer(address[] calldata recipients, uint256[] calldata amounts) external;

    // PRESALE
    function pause() external;
    function unPause() external;
    function setLive() external;

    // COMMUNITY
    // function upgradeTo(address newImplementation) external; RESTRICTED
    // function upgradeToAndCall(address newImplementation, bytes memory data) external payable; RESTRICTED
    function setMinter(address user_, bool canMint_) external; // RESTRICTED
    function setReceiveRewards(address account, bool shouldReceive) external; // RESTRICTED
    function setHoldingLimitWhitelist(address account, bool whitelisted) external; // RESTRICTED
    function setSellLimitWhitelist(address account, bool whitelisted) external; // RESTRICTED
    function registerPair(address pairAddress) external; // RESTRICTED
    function communityUnPause() external;

    // FACTORY
    function registerDarwinSwapPair(address _pair) external;

    // SECURITY
    function emergencyPause() external;
    function emergencyUnPause() external;

    // MAINTENANCE
    function setDarwinSwapFactory(address _darwinSwapFactory) external;
    function setPauseWhitelist(address _addr, bool value) external;
    function setPrivateSaleAddress(address _addr) external;

    // MINTER
    function mint(address account, uint256 amount) external;

    // VIEW
    function isExcludedFromHoldingLimit(address account) external view returns (bool);
    function isExcludedFromSellLimit(address account) external view returns (bool);
    function isPaused() external view returns (bool);
    function maxTokenHoldingSize() external view returns(uint256);
    function maxTokenSellSize() external view returns(uint256);

    /// TransferFrom amount is greater than allowance
    error InsufficientAllowance();
    /// Only the DarwinCommunity can call this function
    error OnlyDarwinCommunity();

    /// Input cannot be the zero address
    error ZeroAddress();
    /// Amount cannot be 0
    error ZeroAmount();
    /// Arrays must be the same length
    error InvalidArrayLengths();

    /// Holding limit exceeded
    error HoldingLimitExceeded();
    /// Sell limit exceeded
    error SellLimitExceeded();
    /// Paused
    error Paused();
    error AccountAlreadyExcluded();
    error AccountNotExcluded();

    /// Max supply reached, cannot mint more Darwin
    error MaxSupplyReached();
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

/// @title Interface for the Darwin Presale
interface IDarwinPresale {

    /// Presale contract is already initialized
    error AlreadyInitialized();
    /// Presale contract is not initialized
    error NotInitialized();
    /// Presale has not started yet
    error PresaleNotActive();
    /// Presale has not ended yet
    error PresaleNotEnded();
    /// Parameter cannot be the zero address
    error ZeroAddress();
    /// Start date cannot be less than the current timestamp
    error InvalidStartDate();
    /// End date cannot be less than the start date or the current timestamp
    error InvalidEndDate();
    /// Deposit amount must be between 0.1 and 4,000 BNB
    error InvalidDepositAmount();
    /// Deposit amount exceeds the hardcap
    error AmountExceedsHardcap();
    /// Attempted transfer failed
    error TransferFailed();
    /// ERC20 token approval failed
    error ApproveFailed();

    /// @notice Emitted when bnb is deposited
    /// @param user Address of the user who deposited
    /// @param amountIn Amount of BNB deposited
    /// @param darwinAmount Amount of Darwin received
    event UserDeposit(address indexed user, uint256 indexed amountIn, uint256 indexed darwinAmount);
    event PresaleEndDateSet(uint256 indexed endDate);
    event Wallet1Set(address indexed wallet1);
    event Wallet2Set(address indexed wallet2);
    event RouterSet(address indexed router);
    event LpProvided(uint256 indexed lpAmount, uint256 indexed remainingAmount);
    
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

/// @title Interface for the Darwin Vester
interface IDarwinVester {

    /// Presale contract is already initialized
    error AlreadyInitialized();
    /// Presale contract is not initialized
    error NotInitialized();
    /// Caller is not private sale
    error NotPrivateSale();
    /// Parameter cannot be the zero address
    error ZeroAddress();
    /// Selected amount exceeds the withdrawable amount
    error AmountExceedsWithdrawable();
    /// Selected amount exceeds the claimable amount
    error AmountExceedsClaimable();
    /// Attempted transfer failed
    error TransferFailed();

    event Vest(address indexed user, uint indexed vestAmount);
    event Withdraw(address indexed user, uint indexed withdrawAmount);
    event Claim(address indexed user, uint indexed claimAmount);

    struct UserInfo {
        uint256 withdrawn;
        uint256 vested;
        uint256 vestTimestamp;
        uint256 claimed;
    }

    function deposit(address _user, uint _amount) external;
}