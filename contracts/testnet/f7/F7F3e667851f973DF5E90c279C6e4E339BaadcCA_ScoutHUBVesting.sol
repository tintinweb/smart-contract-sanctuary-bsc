// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IScoutHUBVesting.sol";

/**
 * @title Vesting Contract for ScoutHUB
 * @author 0xVeliUysal, 0xfunTalia, dozcan, ScoutHUB team and Deneth firm
 */
contract ScoutHUBVesting is
    IScoutHUBVesting,
    Ownable,
    Pausable,
    ReentrancyGuard
{
    // The HUB token
    IERC20 public immutable hub;

    // The status of each vesting member (Vester)
    mapping(address => Vester[]) public vest;
    // Informations about Vester Types
    mapping(VesterType => VesterTypeInfo) public vesterTypeInfos;

    uint256 public currentTime;

    function getVest(address account)
        external
        view
        returns (Vester[] memory vesters)
    {
        return vest[account];
    }

    function setCurrentTime(uint256 newValue) external onlyOwner {
        currentTime = newValue;
    }

    function getCurrentTime() external view onlyOwner returns(uint256){
        currentTime;
    }

    /* ========== CONSTRUCTOR ========== */

    /**
     * @dev Initializes the contract's vesters and vesting amounts as well as sets
     * the HUB token address.
     *
     * It conducts a sanity check to ensure that the total vesting amounts specified match
     * the team allocation to ensure that the contract is deployed correctly.
     *
     * Additionally, it transfers ownership to the Vader contract that needs to consequently
     * initiate the vesting period via {begin} after it mints the necessary amount to the contract.
     */
    constructor(
        address hubAddress,
        VesterType[] memory vesterTypes,
        VesterTypeInfo[] memory vesterTypeInformations
    ) {
        require(
            hubAddress != address(0),
            "ScoutHUBVesting::constructor: Misconfiguration"
        );
        require(
            vesterTypes.length == vesterTypeInformations.length,
            "ScoutHUBVesting::constructor: Misconfiguration"
        );
        hub = IERC20(hubAddress);
        for (uint256 index = 0; index < vesterTypes.length; index++) {
            require(vesterTypeInformations[index].monthsCount != 0, "");
            vesterTypeInfos[vesterTypes[index]] = vesterTypeInformations[index];
        }
    }

    /* ========== MODIFIERS ========== */

    modifier onlyAccounts() {
        require(msg.sender == tx.origin, "Not allowed origin");
        _;
    }

    /* ========== VIEWS ========== */

    /**
     * @dev Returns the amount a user can claim at a given point in time.
     *
     * Requirements:
     * - the vesting period has started
     */
    function getClaim(address account)
        external
        view
        whenNotPaused
        onlyAccounts
        returns (uint256 totalVestedAmount)
    {
        uint256 vestedAmount;
        for (uint256 index = 0; index < vest[account].length; index++) {
            Vester memory vester = vest[account][index];
            (vestedAmount, , ) = getClaimInternal(vester);
            totalVestedAmount += vestedAmount;
        }
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    /**
     * @dev Allows a user to claim their pending vesting the vested claim
     *
     * Emits a {Vested} event indicating the user who claimed their vested tokens
     * as well as the amount that was vested.
     *
     * Requirements:
     *
     * - the vesting period has started
     * - the caller must have a non-zero vested amount
     */
    function claim()
        external
        whenNotPaused
        nonReentrant
        onlyAccounts
        returns (uint256 totalVestedAmount)
    {
        address account = msg.sender;
        uint256 vestedAmount;
        for (uint256 index = 0; index < vest[account].length; index++) {
            Vester memory vester = vest[account][index];

            if (vester.start != 0 && vester.start < currentTime) {
                bool tgeClaimed;
                uint256 claimCount;

                (vestedAmount, tgeClaimed, claimCount) = getClaimInternal(
                    vester
                );

                if (vestedAmount != 0) {
                    vester.claimedAmount += vestedAmount;
                    vester.claimedCount += uint64(claimCount);
                    if (tgeClaimed) vester.tgeClaimed = tgeClaimed;

                    vest[account][index] = vester;

                    emit Vested(msg.sender, vester);

                    totalVestedAmount += vestedAmount;
                }
            }
        }
        if (totalVestedAmount != 0) {
            bool success = hub.transfer(msg.sender, totalVestedAmount);
            require(success, "ScoutHUBVesting::claim: Transfer failed");
        }
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    /**
     * @dev Allows the vesting period to be initiated.
     *
     * Emits a {VestingInitializedIn} event from which the start and
     * end can be calculated via it's attached timestamp.
     *
     * Requirements:
     *
     * - the caller must be the owner (HUB token)
     */
    function batchVestFor(
        address[] calldata accounts,
        Vester[] calldata vesters
    ) external whenNotPaused onlyOwner {
        require(
            accounts.length == vesters.length,
            "ScoutHUBVesting::begin: Vesters and Amounts lengths do not match"
        );

        for (uint256 i = 0; i < accounts.length; i++) {
            vestForInternal(accounts[i], vesters[i]);
        }

        emit BatchVestingCreated(currentTime, accounts, vesters);
    }

    /**
     * @dev Adds a new vesting schedule to the contract.
     *
     * Requirements:
     * - Only {owner} can call.
     */
    function vestFor(address account, Vester memory vester)
        external
        whenNotPaused
        onlyOwner
    {
        vestForInternal(account, vester);

        emit VestingCreated(currentTime, account, vester);
    }

    /* ========== PRIVATE FUNCTIONS ========== */

    function vestForInternal(address account, Vester memory vester) private {
        require(
            vester.totalAmount != 0,
            "ScoutHUBVesting::begin: Incorrect Amount Specified"
        );
        require(
            account != address(0),
            "ScoutHUBVesting::begin: Zero Vester Address Specified"
        );
        require(
            vester.start != 0,
            "ScoutHUBVesting::begin: Zero Vester Start Specified"
        );
        require(
            vester.start < vester.end,
            "ScoutHUBVesting::begin: Wrong Vester Start - End Times"
        );
        bool beforeAddedToVester = false;
        for (uint256 index = 0; index < vest[account].length; index++) {
            if (vest[account][index].vesterType == vester.vesterType)
                beforeAddedToVester = true;
        }
        require(
            !beforeAddedToVester,
            "ScoutHUBVesting::begin: Duplicate Vester Entry Specified"
        );
        vest[account].push(vester);
    }

    function getClaimInternal(Vester memory vester)
        private
        view
        returns (
            uint256 vestedAmount,
            bool tgeClaimed,
            uint256 claimableCount
        )
    {
        // uint256 currentTime = block.timestamp;
        if (currentTime >= vester.end) {
            if (vester.claimedCount == 0) {
                VesterTypeInfo memory vesterTypeInfo = vesterTypeInfos[
                    vester.vesterType
                ];
                if (!vester.tgeClaimed) {
                    vestedAmount = vester.totalAmount;
                    tgeClaimed = true;
                } else {
                    vestedAmount =
                        (vester.totalAmount * (1000 - vesterTypeInfo.tgeRate)) /
                        1000;
                }
                claimableCount = vesterTypeInfo.monthsCount;
            } else {
                VesterTypeInfo memory vesterTypeInfo = vesterTypeInfos[
                    vester.vesterType
                ];
                (vestedAmount, claimableCount) = getClaimableCountAndAmount(
                    vester.end,
                    vester.start,
                    vesterTypeInfo.cliff,
                    vester.totalAmount,
                    vesterTypeInfo.tgeRate,
                    vesterTypeInfo.monthsCount,
                    vester.vesterType,
                    vester.claimedCount
                );
            }
        } else {
            VesterTypeInfo memory vesterTypeInfo = vesterTypeInfos[
                vester.vesterType
            ];

            uint256 cliffTime = vester.start + vesterTypeInfo.cliff;
            if (currentTime >= cliffTime) {
                if (vester.tgeClaimed && currentTime >= (cliffTime + 30 days)) {
                    (vestedAmount, claimableCount) = getClaimableCountAndAmount(
                        currentTime,
                        vester.start,
                        vesterTypeInfo.cliff,
                        vester.totalAmount,
                        vesterTypeInfo.tgeRate,
                        vesterTypeInfo.monthsCount,
                        vester.vesterType,
                        vester.claimedCount
                    );
                } else if (!vester.tgeClaimed) {
                    tgeClaimed = true;
                    vestedAmount =
                        (vester.totalAmount * vesterTypeInfo.tgeRate) /
                        1000;
                    if (currentTime >= cliffTime + 30 days) {
                        uint256 claimableAmount;
                        (
                            claimableAmount,
                            claimableCount
                        ) = getClaimableCountAndAmount(
                            currentTime,
                            vester.start,
                            vesterTypeInfo.cliff,
                            vester.totalAmount,
                            vesterTypeInfo.tgeRate,
                            vesterTypeInfo.monthsCount,
                            vester.vesterType,
                            vester.claimedCount
                        );
                        vestedAmount += claimableAmount;
                    }
                }
            }
        }
    }

    function getClaimableCountAndAmount(
        uint256 blockTime,
        uint256 start,
        uint256 cliff,
        uint256 amount,
        uint256 tgeRate,
        uint256 monthsCount,
        VesterType vesterType,
        uint256 claimedCount
    ) private view returns (uint256 claimableAmount, uint256 claimableCount) {
        claimableCount = ((blockTime - start - cliff) / 30 days) - claimedCount;
        if (claimableCount != 0) {
            if (vesterType == VesterType.CLUBS_CONTENT) {
                claimableCount = claimableCount / 3; //for only quarters
                if (claimedCount + claimableCount < 5) {
                    claimableAmount = (amount * claimableCount * 10) / 100;
                } else {
                    if (claimedCount > 4) {
                        claimableAmount += (amount * claimableCount * 15) / 100;
                    } else {
                        claimableAmount =
                            (amount *
                                (((4 - claimedCount) * 10) +
                                    ((claimedCount + claimableCount - 4) *
                                        15))) /
                            100;
                    }
                }
            } else {
                claimableAmount =
                    claimableCount *
                    ((amount * ((1000 - tgeRate) / monthsCount)) / 1000);
            }
        }
    }

    fallback() external {
        revert("Something bad happened");
    }

    /**
     *
     * @notice toggle pause
     * This method using for toggling pause for contract
     */
    function togglePause() external onlyOwner {
        paused() ? _unpause() : _pause();
    }

    /**
     * @notice transfer ownership for vesting rights
     * This method using for transfer ownership from old owner to new owner. This can start only by vesting owner
     */
    function transferVestingOwnership(address newOwner) external {
        address oldOwner = msg.sender;
        require(
            vest[oldOwner].length > 0,
            "ScoutHUBVesting::change:No has vesting"
        );
        for (uint256 index = 0; index < vest[oldOwner].length; index++) {
            vest[newOwner][index] = vest[oldOwner][index];
        }
        delete vest[oldOwner];
    }
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

pragma solidity ^0.8.9;

interface IScoutHUBVesting {
    enum VesterType {
        SEED,
        PRIVATE,
        PUBLIC,
        CLUBS_CONTENT,
        TEAM,
        ADVISORS,
        GAME_STAKING,
        MARKETING,
        TREASURY
    }

    /***
     * TGE Rate/1000
     * For example TGE Rate is %2.5; you set tgeRate '25'
     *
     */
    struct VesterTypeInfo {
        uint128 cliff;
        uint32 tgeRate;
        uint32 monthsCount;
    }

    /**
     * 1 month equals 2592000
     *
     */
    struct Vester {
        uint256 totalAmount;
        uint256 claimedAmount;
        uint64 claimedCount;
        uint128 start;
        uint128 end;
        VesterType vesterType;
        bool tgeClaimed;
    }

    /* ========== FUNCTIONS ========== */

    function getClaim(address account)
        external
        view
        returns (uint256 vestedAmount);

    // function getTotalClaimCountFor(
    //     uint256 start,
    //     uint256 end,
    //     VesterType vesterType
    // ) external view returns (uint256 totalClaimCount);

    function claim() external returns (uint256 vestedAmount);

    function batchVestFor(
        address[] calldata vesterAccounts,
        Vester[] calldata vesters
    ) external;

    function vestFor(address user, Vester memory vester) external;

    function transferVestingOwnership(address newOwner) external;

    /* ========== EVENTS ========== */

    event BatchVestingCreated(
        uint256 timeOfBatchInitialization,
        address[] accounts,
        Vester[] vesters
    );

    event VestingCreated(
        uint256 timeOfVestingInitialization,
        address user,
        Vester vester
    );

    event Vested(address indexed from, Vester vester);
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