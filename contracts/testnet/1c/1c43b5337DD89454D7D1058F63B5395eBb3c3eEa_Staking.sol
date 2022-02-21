// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IStaking } from "./interfaces/IStaking.sol";
import { IVesting } from "./interfaces/IVesting.sol";
import { DataTypes } from "./interfaces/DataTypes.sol";
import { Utils } from "./libs/Utils.sol";
import { VestingWallet } from "./Vesting.sol";
import { Treasury } from "./Treasury.sol";

contract Staking is IStaking, Ownable {
    using Utils for uint256;
    using SafeERC20 for IERC20;

    uint256 public constant SECONDS_IN_WEEK = 7 days;
    uint256 public constant ACCUMULATOR_BASE = 10**15;

    IERC20 public immutable reward;

    mapping(IERC20 => address) public treasuries; // underlying asset => treasury
    mapping(IERC20 => uint256) public totalVirtualAmount; // underlying asset => total virtual amount
    mapping(IERC20 => uint256) public totalLockedValue; // underlying asset => total Locked Value
    mapping(IERC20 => uint256) public globalInterestAccumulator; // underlying asset => global interest accumulator
    mapping(address => VestingWallet) public wallets; // user => vesting wallet
    mapping(address => mapping(IERC20 => mapping(uint8 => DataTypes.StakingRecord[])))
        public staked; // user => asset => period => record
    mapping(address => uint256) public stakedCount;

    constructor(IERC20 _reward) {
        reward = _reward;
    }

    modifier checkAsset(IERC20 asset) {
        require(treasuries[asset] != address(0), "staking/asset-not-supported");
        _;
    }

    modifier checkPeriod(uint8 weekPeriod) {
        require(isSupportedPeriod(weekPeriod), "staking/period-not-supported");
        _;
    }

    function getTreasuryAddress(address asset, uint256 withdrawFactor)
        external
        view
        returns (address)
    {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                keccak256(abi.encodePacked(address(asset))),
                keccak256(
                    abi.encodePacked(
                        type(Treasury).creationCode,
                        abi.encode(address(asset), reward, withdrawFactor)
                    )
                )
            )
        );

        return address(uint160(uint256(hash)));
    }

    function getWalletAddress(address owner) external view returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                keccak256(abi.encodePacked(reward, owner)),
                keccak256(
                    abi.encodePacked(
                        type(VestingWallet).creationCode,
                        abi.encode(address(this), reward, owner)
                    )
                )
            )
        );

        return address(uint160(uint256(hash)));
    }

    function whitelist(IERC20 asset, uint256 withdrawFactor) external onlyOwner {
        require(treasuries[asset] == address(0), "staking/asset-exists");
        bytes memory bytecode = abi.encodePacked(
            type(Treasury).creationCode,
            abi.encode(asset, reward, withdrawFactor)
        );
        bytes32 salt = keccak256(abi.encodePacked(asset));
        address treasury;
        assembly {
            treasury := create2(0, add(bytecode, 32), mload(bytecode), salt)

            if iszero(extcodesize(treasury)) {
                revert(0, 0)
            }
        }
        treasuries[asset] = treasury;
        emit TreasuryCreated(address(asset), treasury, withdrawFactor);
    }

    function isSupportedPeriod(uint8 _weeks) public pure returns (bool) {
        return _weeks >= 1 && _weeks <= 52;
    }

    function calculateVirtualAmount(uint256 amount, uint8 period) public pure returns (uint256) {
        return (amount * (period + 50)) / 51;
    }

    function deposit(
        IERC20 asset,
        uint8 period,
        uint256 amount
    ) external checkAsset(asset) checkPeriod(period) {
        require(amount > 0, "staking/invalid-amount");
        asset.safeTransferFrom(msg.sender, address(this), amount);
        uint256 virtualAmount = calculateVirtualAmount(amount, period);
        _updateGlobalAccumulatorsWithdrawInterest(asset, virtualAmount);
        totalLockedValue[asset] = totalLockedValue[asset] + amount;
        staked[msg.sender][asset][period].push(
            DataTypes.StakingRecord(
                amount,
                block.timestamp + (period * SECONDS_IN_WEEK),
                virtualAmount,
                globalInterestAccumulator[asset]
            )
        );
        stakedCount[msg.sender]++;
        emit Deposit(msg.sender, address(asset), period, amount);
    }

    function withdraw(
        IERC20 asset,
        uint8 period,
        uint256 index
    ) external checkAsset(asset) checkPeriod(period) {
        uint256 length = staked[msg.sender][asset][period].length;
        require(index < length, "staking/invalid-record-index");

        _updateGlobalAccumulatorsWithdrawInterest(asset, 0);

        uint256 interestAmount = calculateInterestAmount(msg.sender, asset, period, index);

        _withdrawInterest(_getOrCreateWallet(msg.sender), interestAmount);

        staked[msg.sender][asset][period][index]
            .lastGlobalMultiplierValue = globalInterestAccumulator[asset];

        if (staked[msg.sender][asset][period][index].unlockTimestamp.hasExpired()) {
            _withdrawBase(asset, period, index);
        }
    }

    function calculateInterestAmount(
        address owner,
        IERC20 asset,
        uint8 period,
        uint256 index
    ) public view returns (uint256) {
        DataTypes.StakingRecord memory record = staked[owner][asset][period][index];
        return ((record.virtualAmount *
            (globalInterestAccumulator[asset] - record.lastGlobalMultiplierValue)) /
            ACCUMULATOR_BASE);
    }

    function withdrawAll(IERC20 asset) external checkAsset(asset) {
        _updateGlobalAccumulatorsWithdrawInterest(asset, 0);

        uint256 interestAmount = 0;
        for (uint8 periodIndex = 1; periodIndex <= 52; periodIndex++) {
            DataTypes.StakingRecord[] memory records = staked[msg.sender][asset][periodIndex];
            for (uint256 index = records.length; index > 0; index--) {
                interestAmount += calculateInterestAmount(
                    msg.sender,
                    asset,
                    periodIndex,
                    index - 1
                );
                
                staked[msg.sender][asset][periodIndex][index-1]
                    .lastGlobalMultiplierValue = globalInterestAccumulator[asset];

                if (records[index - 1].unlockTimestamp.hasExpired()) {
                    _withdrawBase(asset, periodIndex, index - 1);
                }
            }
        }

        require(interestAmount > 0, "staking/no-deposits");

        _withdrawInterest(_getOrCreateWallet(msg.sender), interestAmount);
    }

    function _getOrCreateWallet(address owner) internal returns (VestingWallet) {
        VestingWallet wallet = wallets[owner];
        if (address(wallet) != address(0)) {
            return wallet;
        }

        bytes memory bytecode = abi.encodePacked(
            type(VestingWallet).creationCode,
            abi.encode(address(this), reward, owner)
        );
        bytes32 salt = keccak256(abi.encodePacked(reward, owner));
        assembly {
            wallet := create2(0, add(bytecode, 32), mload(bytecode), salt)

            if iszero(extcodesize(wallet)) {
                revert(0, 0)
            }
        }
        wallets[owner] = wallet;
        emit WalletCreated(owner, address(wallet));
        reward.approve(address(wallet), type(uint256).max);
        return wallet;
    }

    function _withdrawBase(
        IERC20 asset,
        uint8 period,
        uint256 index
    ) internal {
        uint256 amount = staked[msg.sender][asset][period][index].amount;
        asset.safeTransfer(msg.sender, amount);

        uint256 virtualAmount = calculateVirtualAmount(amount, period);
        totalLockedValue[asset] = totalLockedValue[asset] - amount;
        totalVirtualAmount[asset] = totalVirtualAmount[asset] - virtualAmount;

        _remove(asset, period, index);
        stakedCount[msg.sender]--;
        emit Withdrawal(msg.sender, address(asset), period, amount);
    }

    function _withdrawInterest(VestingWallet wallet, uint256 amount) internal {
        if (amount > 0) {
            wallet.vest(amount);
            emit InterestClaimed(msg.sender, address(wallet), amount);
        }
    }

    function _remove(
        IERC20 asset,
        uint8 period,
        uint256 index
    ) internal {
        uint256 length = staked[msg.sender][asset][period].length;
        require(index < length, "staking/array-out-of-bounds");

        // remove element from array
        if (index != length - 1) {
            staked[msg.sender][asset][period][index] = staked[msg.sender][asset][period][
                length - 1
            ];
        }
        staked[msg.sender][asset][period].pop();
    }

    function _updateGlobalAccumulatorsWithdrawInterest(IERC20 asset, uint256 virtualAmount)
        internal
    {
        Treasury treasury = Treasury(treasuries[asset]);
        uint256 assetTotalVirtualAmount = totalVirtualAmount[asset];
        if (assetTotalVirtualAmount > 0) {
            // wait for accruing interest till staking contract is not empty
            uint256 interestAccrued = treasury.withdrawInterest();
            globalInterestAccumulator[asset] =
                globalInterestAccumulator[asset] +
                (interestAccrued * ACCUMULATOR_BASE) /
                assetTotalVirtualAmount;
        }
        totalVirtualAmount[asset] = assetTotalVirtualAmount + virtualAmount;
    }

    function withdrawFromTreasury(
        IERC20 asset,
        address recipient,
        uint256 amount
    ) external onlyOwner checkAsset(asset) {
        Treasury(treasuries[asset]).withdrawReward(recipient, amount);
    }

    function getAllUsersPositions(address user, IERC20 asset)
        external
        view
        checkAsset(asset)
        returns (DataTypes.StakingState[] memory data)
    {
        uint256 userStakedCount = stakedCount[user];
        data = new DataTypes.StakingState[](userStakedCount);

        if (userStakedCount == 0) {
            return data;
        }

        uint256 index = 0;
        for (uint8 period = 1; period <= 52; period++) {
            DataTypes.StakingRecord[] memory records = staked[user][asset][period];
            for (uint256 recordIndex = 0; recordIndex < records.length; recordIndex++) {
                DataTypes.StakingRecord memory record = records[recordIndex];
                uint256 rewardsAccrued = calculateInterestAmount(user, asset, period, recordIndex);
                data[index] = DataTypes.StakingState(
                    address(asset),
                    period,
                    uint32(record.unlockTimestamp - (period * SECONDS_IN_WEEK)),
                    uint32(record.unlockTimestamp),
                    record.amount,
                    rewardsAccrued,
                    recordIndex
                );
                index++;
            }
        }

        return data;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IStaking {
    event Deposit(
        address indexed user,
        address indexed asset,
        uint8 indexed period,
        uint256 amount
    );
    event Withdrawal(
        address indexed user,
        address indexed asset,
        uint8 indexed period,
        uint256 amount
    );
    event InterestClaimed(address indexed user, address indexed wallet, uint256 amount);

    event TreasuryCreated(address indexed asset, address indexed treasury, uint256 withdrawFactor);
    event WalletCreated(address indexed user, address indexed wallet);
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IVesting {
    event VestingStarted(address indexed user, uint256 amount);
    event VestingEnded(address indexed user, uint256 amount);
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface DataTypes {
    struct StakingRecord {
        uint256 amount;
        uint256 unlockTimestamp;
        uint256 virtualAmount;
        uint256 lastGlobalMultiplierValue;
    }

    struct VestingRecord {
        uint256 amount;
        uint256 unlockTimestamp;
    }

    struct VestingState {
        uint32 startTime;
        uint32 endTime;
        uint256 amount;
        uint256 index;
    }

    struct StakingState {
        address asset;
        uint8 period;
        uint32 startTime;
        uint32 endTime;
        uint256 amountStaked;
        uint256 amountClaimable;
        uint256 index;
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

library Utils {
    function hasExpired(uint256 timestamp) internal view returns (bool) {
        return block.timestamp >= timestamp;
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IVesting } from "./interfaces/IVesting.sol";
import { DataTypes } from "./interfaces/DataTypes.sol";
import { Utils } from "./libs/Utils.sol";

contract VestingWallet is IVesting {
    using Utils for uint256;
    using SafeERC20 for IERC20;

    uint256 constant SECONDS_PER_YEAR = 365 days;

    IERC20 public immutable reward;
    address public immutable staking;
    address public immutable owner;
    DataTypes.VestingRecord[] public vested;

    constructor(
        address _staking,
        IERC20 _reward,
        address _owner
    ) {
        staking = _staking;
        reward = _reward;
        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "vesting/not-owner");
        _;
    }

    modifier onlyStaking() {
        require(msg.sender == staking, "vesting/not-staking");
        _;
    }

    function vest(uint256 amount) external onlyStaking {
        require(amount > 0, "vesting/invalid-amount");
        reward.safeTransferFrom(msg.sender, address(this), amount);
        vested.push(DataTypes.VestingRecord(amount, block.timestamp + SECONDS_PER_YEAR)); // create records
        emit VestingStarted(owner, amount);
    }

    function claim(uint256 index) external onlyOwner {
        require(vested[index].unlockTimestamp.hasExpired(), "vesting/claim-not-eligible");
        _claim(index);
    }

    function claimAll() external onlyOwner {
        DataTypes.VestingRecord[] memory records = vested;
        require(records.length > 0, "vesting/no-records");

        for (uint256 idx = records.length; idx > 0; idx--) {
            if (records[idx - 1].unlockTimestamp.hasExpired()) {
                _claim(idx - 1);
            }
        }
    }

    function getVestingRecordsCount() external view returns (uint256) {
        return vested.length;
    }

    function getVestingRecords() external view returns (DataTypes.VestingState[] memory data) {
        data = new DataTypes.VestingState[](vested.length);
        for (uint256 index = 0; index < vested.length; index++) {
            data[index] = DataTypes.VestingState(
                uint32(vested[index].unlockTimestamp - SECONDS_PER_YEAR),
                uint32(vested[index].unlockTimestamp),
                vested[index].amount,
                index
            );
        }
        return data;
    }

    function _claim(uint256 index) internal {
        DataTypes.VestingRecord memory record = vested[index];
        reward.safeTransfer(owner, record.amount);
        _remove(index);
        emit VestingEnded(owner, record.amount);
    }

    function _remove(uint256 index) internal {
        uint256 length = vested.length;
        require(index < length, "vesting/array-out-of-bounds");

        // remove element from array
        if (index != length - 1) {
            vested[index] = vested[length - 1];
        }
        vested.pop();
    }
}

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Treasury is Ownable {
    using SafeERC20 for IERC20;

    uint256 public constant WITHDRAWAL_FACTOR_BASE = 10**9;

    IERC20 public immutable asset;
    IERC20 public immutable reward;

    uint256 public immutable withdrawalFactorPerBlock;
    uint256 public lastWithdrawalBlock;

    constructor(
        IERC20 _asset,
        IERC20 _reward,
        uint256 _withdrawalFactor
    ) {
        asset = _asset;
        reward = _reward;
        require(_withdrawalFactor < WITHDRAWAL_FACTOR_BASE, "treasury/incorrect-withdrawal-factor");
        withdrawalFactorPerBlock = _withdrawalFactor;
        lastWithdrawalBlock = block.number;
        // Ownership should be transfered to staking contract during deployment
    }

    function withdrawReward(address recipient, uint256 amount) external onlyOwner {
        uint256 balance = reward.balanceOf(address(this));
        require(amount <= balance, "treasury/invalid-balance");
        reward.safeTransfer(recipient, amount);
    }

    function withdrawInterest() external onlyOwner returns (uint256) {
        if (block.number == lastWithdrawalBlock) {
            return 0;
        }
        uint256 blocksPassed = block.number - lastWithdrawalBlock;
        uint256 interestFactor = withdrawalFactorPerBlock * blocksPassed;
        uint256 availableAmount = reward.balanceOf(address(this));
        uint256 amountToWithdraw = (availableAmount * interestFactor) / (WITHDRAWAL_FACTOR_BASE+interestFactor);
        reward.safeTransfer(msg.sender, amountToWithdraw);
        lastWithdrawalBlock = block.number;
        return amountToWithdraw;
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
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}