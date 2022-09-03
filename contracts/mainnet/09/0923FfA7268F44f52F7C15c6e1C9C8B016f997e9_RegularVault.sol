// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../interfaces/IBotVault.sol";
import "./VaultBase.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../interfaces/IRoboFiGame.sol";


struct RegularVaultData {
    mapping(uint => RegularVaultOption) option;
}

contract RegularVault is VaultBase, IBotVaultEvent {

    using SafeERC20 for IERC20;

    bytes32 constant VAULT_DATA_POSITION = keccak256('data.regular.vault');

    uint constant PRECISION = 1e18;

    modifier nonRestricted(uint vID) {
        require(!vaultData().option[vID].restricted, Errors.RV_VAULT_IS_RESTRICTED);
        _;
    }

    function vaultData() internal pure returns(RegularVaultData storage ds) {
        bytes32 position = VAULT_DATA_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function setVaultOption(uint vID, bytes calldata data) external ownedBotOnly(vID) { 
        vaultData().option[vID] = abi.decode(data, (RegularVaultOption));
    }

    function getVaultOption(uint vID) external view returns(bytes memory result) {
        result = abi.encode(vaultData().option[vID]);
    }

    function getVaultInfo(uint vID, address account) external view returns(VaultInfo memory result) {
        Vault storage vault = _vaultOf(vID);
        result.data = vault.data;
        result.user = vault.users[account];
        result.totalDeposit = vault.totalDeposit;
        result.accRewardPerShare = vault.accRewardPerShare;
        result.lastRewardTime = vault.lastRewardTime;
        result.pendingReward = _pendingReward(vault, account);
        result.option = abi.encode(vaultData().option[vID]);
    }

    function pendingReward(uint vID, address account) public view returns(uint) {
        Vault storage vault = _vaultOf(vID);
        return _pendingReward(vault, account);
    }

    function deposit(uint vID, uint amount) external _validVault(vID) nonRestricted(vID) {
        _deposit(vID, _msgSender(), _msgSender(), amount, 0);
    }

    function delegateDeposit(uint vID, address payor, address account, uint amount, uint lock) external _validVault(vID) ownedBotOnly(vID) botOnly {
        _deposit(vID, payor, account, amount, lock);
    }

    function withdraw(uint vID, uint amount) external _validVault(vID) {
        _withdraw(vID, _msgSender(), amount);
    }

    function delegateWithdraw(uint vID, address account, uint amount) external _validVault(vID) ownedBotOnly(vID) botOnly {
        _withdraw(vID, account, amount);
    }

    function updateReward(uint vID, uint assetAmount) external _validVault(vID) botOnly {
        Vault storage vault = _vaultOf(vID);
        if (vault.totalDeposit > 0)
            vault.accRewardPerShare += assetAmount * PRECISION / vault.totalDeposit;
        else
            vault.accRewardPerShare = 0;

        vault.lastRewardTime = block.timestamp;
        emit RewardAdded(vID, assetAmount);
    }

    function claimReward(uint vID, address account) external _validVault(vID) {
        Vault storage vault = _vaultOf(vID);
        UserInfo storage user = vault.users[account];
        _claimReward(vID, vault, account);
        user.debt = user.deposit * vault.accRewardPerShare / PRECISION;
    }

    function snapshot(uint vID) external _validVault(vID) botOnly {
        _snapshot(vID);
    }

    function _snapshot(uint vID) private {
        Vault storage vault = _vaultOf(vID);
        vault.currentSnapshotId = block.number;
        emit Snapshot(vID, block.number);
    }

    function _pendingReward(Vault storage vault, address account) internal view returns(uint) {
        if (vault.data.botToken == address(0))
            return 0;
        UserInfo storage user = vault.users[account];
        uint reward = vault.accRewardPerShare * user.deposit / PRECISION;
        if (reward < user.debt)
            return 0;
        return reward - user.debt; 
    }

    function _claimReward(uint vID, Vault storage vault, address account) internal {
        uint reward = _pendingReward(vault, account);
        if (reward == 0)
            return; 
        IERC20(vault.data.asset).safeTransfer(account, reward);
        emit RewardClaimed(vID, account, reward);
    }

    function _deposit(uint vID, address payor, address account, uint amount, uint lock) internal {

        _snapshot(vID);

        Vault storage vault = _vaultOf(vID);
        UserInfo storage user = vault.users[account];

        _claimReward(vID, vault, account);

        if (amount != 0) {    
            if (payor != address(0))
                IERC20(vault.data.botToken).safeTransferFrom(payor, address(this), amount);
            _updateDepositSnapshot(vault, account, user.deposit);

            user.lockPeriod = lock;
            user.deposit += amount;
            vault.totalDeposit += amount;
            _generateTicket(vault, account, amount);
        }
        user.debt = user.deposit * vault.accRewardPerShare / PRECISION;
        user.lastDepositTime = block.timestamp; 

        emit Deposit(vID, payor, account, amount);
    }

    function _withdraw(uint vID, address account, uint amount) internal {
        Vault storage vault = _vaultOf(vID);
        UserInfo storage user = vault.users[account];

        require(block.timestamp >= user.lastDepositTime + user.lockPeriod, Errors.RV_DEPOSIT_LOCKED);

        _snapshot(vID);

        _claimReward(vID, vault, account);

        if (amount > 0) {
            require(amount <= user.deposit, Errors.RV_WITHDRAWL_AMOUNT_EXCEED_DEPOSIT);
            _updateDepositSnapshot(vault, account, user.deposit);
            
            user.deposit -= amount;
            vault.totalDeposit -= amount;
            _deleteTicket(vault, account, amount);
        }
        user.debt = user.deposit * vault.accRewardPerShare / PRECISION;
        IERC20(vault.data.botToken).safeTransfer(account, amount);
        emit Widthdraw(vID, account, amount);
    }

    function _updateDepositSnapshot(Vault storage vault, address account, uint currentValue) internal {
        DepositSnapshots storage shot = vault.userDepositSnapshots[account];
        if (shot.ids.length > 0 && 
            shot.ids[shot.ids.length - 1] == vault.currentSnapshotId)
            return;
        shot.ids.push(vault.currentSnapshotId);
        shot.values.push(currentValue);
    }

    function _generateTicket(Vault storage vault, address account, uint amount) private {
        VaultManagerData storage vaultManagerData = data();
        IConfigurator configurator = vaultManagerData.botManager.configurator();
        IRoboFiGame roboFiGame = IRoboFiGame(configurator.addressOf(AddressBook.ADDR_ROBOFI_GAME));
        roboFiGame.generateTicket(vault.data.bot, account, vault.data.botToken, uint112(amount));
    }

    function _deleteTicket(Vault storage vault, address account, uint amount) private {
        VaultManagerData storage vaultManagerData = data();
        IConfigurator configurator = vaultManagerData.botManager.configurator();
        IRoboFiGame roboFiGame = IRoboFiGame(configurator.addressOf(AddressBook.ADDR_ROBOFI_GAME));
        roboFiGame.deleteTicket(vault.data.bot, account, vault.data.botToken, uint112(amount));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../token/IRoboFiERC20.sol";

struct VaultData {
    address botToken;
    IERC20 asset;
    address bot;
    uint8 index;                // the index-th vault generated from botToken
                                //  0 - warmup vault, 1 - regular vault, 2 - VIP vault
    bytes4 vaultType;           // type of the vault, used to determine the vault handler
}

struct UserInfo {
    uint deposit;
    uint debtPoints;
    uint debt;
    uint lockPeriod;
    uint lastDepositTime;
}

struct VaultInfo {
    VaultData data;             
    UserInfo user;
    uint totalDeposit;          // total deposits in the vault
    uint accRewardPerShare;     // the pending reward per each unit of deposit
    uint lastRewardTime;        // the block time of the last reward transaction
    uint pendingReward;         // the pending reward for the caller
    bytes option;               // vault option
} 

struct RegularVaultOption {
    bool restricted;    // restrict deposit activity to bot only
}


interface IBotVaultEvent {
    event Deposit(uint vID, address indexed payor, address indexed account, uint amount);
    event Widthdraw(uint vID, address indexed account, uint amount);
    event RewardAdded(uint vID, uint assetAmount);
    event RewardClaimed(uint vID, address indexed account, uint amount);
    event Snapshot(uint vID, uint snapshotId);
}

interface IBotVault is IBotVaultEvent {
    function deposit(uint vID, uint amount) external;
    function delegateDeposit(uint vID, address payor, address account, uint amount, uint lockTime) external;
    function withdraw(uint vID, uint amount) external;
    function delegateWithdraw(uint vID, address account, uint amount) external;
    function pendingReward(uint vID, address account) external view returns(uint);
    function balanceOf(uint vID, address account) external view returns(uint);
    function balanceOfAt(uint vID, address account, uint blockNo) external view returns(uint);
    function updateReward(uint vID, uint assetAmount) external;
    function claimReward(uint vID, address account) external;

    /**
    @dev Queries user deposit info for the given vault.
    @param vID the vault ID to query.
    @param account the user account to query.
     */
    function getUserInfo(uint vID, address account) external view returns(UserInfo memory result);
    function getVaultInfo(uint vID, address account) external view returns(VaultInfo memory);
    function getVaultOption(uint vID) external view returns(bytes memory);
    function setVaultOption(uint vID, bytes calldata option) external;
}

interface IBotVaultManagerEvent is IBotVaultEvent {
    event OpenVault(uint vID, VaultData data);
    event DestroyVault(uint vID);
    event RegisterHandler(bytes4 vaultType, address handler);
    event BotManagerUpdated(address indexed botManager);
}

interface IBotVaultManager is IBotVault, IBotVaultManagerEvent {
    function vaultOf(uint vID) external view returns(VaultData memory result);
    function validVault(uint vID) external view returns(bool);
    function createVault(VaultData calldata data) external returns(uint);
    function destroyVault(uint vID) external;
    function vaultId(address botToken, uint8 vaultIndex) external pure returns(uint);
    function registerHandler(bytes4 vaultType, IBotVault handler) external;
    function botManager() external view returns(address);
    function setBotManager(address account) external;
    function snapshot(uint vID) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Arrays.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../../token/IRoboFiERC20.sol";
import "../../common/Ownable.sol";
import "../../common/Errors.sol";
import "../interfaces/IDABotManager.sol";
import "../interfaces/IBotVault.sol";

interface IBotToken {
    function owner() external view returns(address);
}

abstract contract VaultBase is Context, Ownable {

    using Arrays for uint[];
    using SafeERC20 for IERC20;

    struct DepositSnapshots {
        uint[] ids;
        uint[] values;
    }

    struct Vault {
        VaultData data;
        uint totalDeposit;
        uint totalDebtPoint;
        uint accRewardPerShare;
        uint lastRewardTime;
        mapping(address => UserInfo) users;
        mapping(address => DepositSnapshots) userDepositSnapshots;
        uint currentSnapshotId;
    }

    struct VaultManagerData {
        IDABotManager botManager;
        mapping(uint => Vault) vaults;
        mapping(bytes4 => address) vaultHandlers;
    }

    modifier botOnly() {
        require(data().botManager.isRegisteredBot(_msgSender()), Errors.VB_CALLER_IS_NOT_DABOT);
        _;
    }

    modifier ownedBotOnly(uint vID) {
        Vault storage vault = _vaultOf(vID);
        require(IBotToken(vault.data.botToken).owner() == _msgSender(), Errors.VB_CALLER_IS_NOT_OWNER_BOT);
        _;
    }

    modifier _validVault(uint vID) {
        require(__isValidVaultId(vID), string(abi.encodePacked(Errors.VB_INVALID_VAULT_ID, Strings.toHexString(vID, 32))));
        _;
    }

    bytes32 constant VAULT_MANAGER_SLOT = keccak256('vault.manager');

    function data() internal pure returns(VaultManagerData storage ds) {
        bytes32 position = VAULT_MANAGER_SLOT;
        assembly {
            ds.slot := position
        }
    }

    function _vaultId(address botToken, uint8 vaultIndex) internal pure returns(uint) {
        return (uint160(botToken) << 8) | uint(vaultIndex);
    }

    function _vaultOf(uint vID) internal view returns(Vault storage) {
        return data().vaults[vID];
    }

    function _vaultHandler(uint vID) internal view returns(address result) {
        result = data().vaultHandlers[_vaultOf(vID).data.vaultType];
        require(address(result) != address(0), Errors.VB_INVALID_VAULT_TYPE);
    }

    function __isValidVaultId(uint vID) internal view returns(bool) {
        Vault storage vault = _vaultOf(vID);
        return vault.data.botToken != address(0);
    }

    function getUserInfo(uint vID, address account) external view returns(UserInfo memory result) {
        Vault storage vault = _vaultOf(vID);
        return vault.users[account];
    }

    function balanceOf(uint vID, address account) external view returns(uint) {
        Vault storage vault = _vaultOf(vID);
        if (vault.data.botToken == address(0))
            return 0;
        return vault.users[account].deposit;
    }

    function balanceOfAt(uint vID, address account, uint snapshotId) external view returns(uint) {
        Vault storage vault = _vaultOf(vID);
        if (snapshotId > vault.currentSnapshotId || snapshotId == 0)
            return vault.users[account].deposit;
        DepositSnapshots storage snapshots = vault.userDepositSnapshots[account];
        uint index = snapshots.ids.findUpperBound(snapshotId);
        if (index == snapshots.ids.length)
            return vault.users[account].deposit;
        return snapshots.values[index];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../common/IConfigurator.sol";
import "../interfaces/IDABotManager.sol";


enum RoundState { NotFinished, RoundClosed, Finished }

struct Ticket {
    uint32 ticketId;
    uint112 lower;
    uint112 upper;
}

struct RoundData {
    uint64 startTime;           // time for game start (in seconds)
    uint64 commitPhaseDuration; // time for commit period (in seconds)
    uint64 revealPhaseDuration; // time for reveal period (in seconds)
    uint8 state;                // 0 - not finished, 1 - finished
    bool noWinnerAllowed;
    uint8 numberWinners;
    uint secretHash;            // hash of the random secret number by backend to generate randseed
    uint randSeed;              // current randseed value
    uint prize;
}

struct GameRound {
    RoundData data;
    mapping(address => uint) committedHashes;
}

struct GameSetting {
    bool noWinnerAllowed;
    uint8 numberWinners;
    uint64 commitPhaseDuration;
    uint64 revealPhaseDuration;
    uint112 lastTicketNumber;
    uint32 lastTicketId;
}

interface IRoboFiGameEvent {
    event GenerateTicket(address indexed bot, address indexed account, uint32 ticketId, uint112 lower, uint112 upper);
    event DeleteTicket(address indexed bot, address indexed account, uint32 ticketId);
    event UpdateTicket(address indexed bot, address indexed account, uint32 ticketId, uint112 newLower);
    event StartRound(address indexed bot, uint roundId, uint64 startTime, uint64 commitPhaseDuration,
                     uint64 revealPhaseDuration, uint prizePool);
    event Submit(address indexed bot, address indexed account, uint roundId, uint secretHash);
    event Reveal(address indexed bot, address indexed account, uint roundId);
    event CloseRound(address indexed bot, uint roundId, uint randSeed);
    event RoundWinner(address indexed bot, uint roundId, address[] winners, uint112[] wonNumbers,
                      uint32[] wonNumberOffsets, uint32[] wonTicketLocalIndexes, uint32[] ticketIds,
                      uint112 lastTicketNumber);
}

interface IRoboFiGame is IRoboFiGameEvent {
    function getUserTickets(address bot, address account) external view returns(Ticket[] memory);
    function randSeed(address bot, uint roundId) external view returns (uint);
    function getCurrentRoundId(address bot) external view returns(int);
    function getRoundDetails(address bot, uint roundId) external view returns (RoundData memory);
    function getBotGameSettings(address bot) external view returns (GameSetting memory);
    function getLastTicketNumber(address bot) external view returns(uint);
    function getBotPrize(address bot) external view returns(uint);

    function initialize(IDABotManager manager, IBotVaultManager botVault, IConfigurator config) external;
    function setBotManager(IDABotManager manager) external;
    function setVaultManager(IBotVaultManager botVault) external;
    function setConfigurator(IConfigurator config) external;
    function generateTicket(address bot, address account, address botToken, uint112 amount) external;
    function deleteTicket(address bot, address account, address botToken, uint112 amount) external;
    function startRound(address bot, uint secretHash) external;
    function submit(address bot, uint secretHash) external;
    function reveal(address bot, uint secretNumber) external;
    function submitAndReveal(address bot, uint secretNumber) external;
    function closeRound(address bot, uint secretNumber) external;
    function submitWinners(address bot, address[] memory winners, uint32[] memory wonNumberOffsets,
                           uint32[] memory wonTicketLocalIndexes) external;
    function updateGameSettings(address bot, bool noWinnerAllowed, uint8 numberWinners,
                                uint64 commitPhaseDuration, uint64 revealPhaseDuration) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRoboFiERC20 is IERC20 {
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
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
// OpenZeppelin Contracts v4.4.1 (utils/Arrays.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";

/**
 * @dev Collection of functions related to array types.
 */
library Arrays {
    /**
     * @dev Searches a sorted `array` and returns the first index that contains
     * a value greater or equal to `element`. If no such index exists (i.e. all
     * values in the array are strictly less than `element`), the array length is
     * returned. Time complexity O(log n).
     *
     * `array` is expected to be sorted in ascending order, and to contain no
     * repeated elements.
     */
    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            // Note that mid will always be strictly less than high (i.e. it will be a valid array index)
            // because Math.average rounds down (it does integer division with truncation).
            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        // At this point `low` is the exclusive upper bound. We will return the inclusive upper bound.
        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
    }
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library Errors {
    /// Common error
    string constant CM_CONTRACT_HAS_BEEN_INITIALIZED = "CM-01"; 
    string constant CM_FACTORY_ADDRESS_IS_NOT_CONFIGURED = "CM-02";
    string constant CM_VICS_ADDRESS_IS_NOT_CONFIGURED = "CM-03";
    string constant CM_VICS_EXCHANGE_IS_NOT_CONFIGURED = "CM-04";
    string constant CM_CEX_FUND_MANAGER_IS_NOT_CONFIGURED = "CM-05";
    string constant CM_TREASURY_MANAGER_IS_NOT_CONFIGURED = "CM-06";
    string constant CM_CEX_DEFAULT_MASTER_ACCOUNT_IS_NOT_CONFIGURED = "CM-07";
    string constant CM_ADDRESS_IS_NOT_ICEXDABOTCERTTOKEN = "CM-08";
    string constant CM_INDEX_OUT_OF_RANGE = "CM-09";
    string constant CM_UNAUTHORIZED_CALLER = "CM-10";
    string constant CM_PROXY_ADMIN_IS_NOT_CONFIGURED = "CM-11";
    

    /// IBCertToken error  (Bot Certificate Token)
    string constant BCT_CALLER_IS_NOT_OWNER = "BCT-01"; 
    string constant BCT_REQUIRE_ALL_TOKENS_BURNT = "BCT-02";
    string constant BCT_UNLOCK_AMOUNT_EXCEEDS_TOTAL_LOCKED = "BCT-03";
    string constant BCT_INSUFFICIENT_LIQUID_FOR_UNLOCKING = "BCT-04a";
    string constant BCT_INSUFFICIENT_LIQUID_FOR_LOCKING = "BCT-04b";
    string constant BCT_AMOUNT_EXCEEDS_TOTAL_STAKE = "BCT-05";
    string constant BCT_CANNOT_MINT_TO_ZERO_ADDRESS = "BCT-06";
    string constant BCT_INSUFFICIENT_LIQUID_FOR_BURN = "BCT-07";
    string constant BCT_INSUFFICIENT_ACCOUNT_FUND = "BCT-08";
    string constant BCT_CALLER_IS_NEITHER_BOT_NOR_CERTLOCKER = "BCT-09";
    string constant BCT_VALUE_MISMATCH_ASSET_AMOUNT = "BCT-10";

    /// IBCEXCertToken error (Cex Bot Certificate Token)
    string constant CBCT_CALLER_IS_NOT_FUND_MANAGER = "CBCT-01";

    /// GovernToken error (Bot Governance Token)
    string constant BGT_CALLER_IS_NOT_OWNED_BOT = "BGT-01";
    string constant BGT_CANNOT_MINT_TO_ZERO_ADDRESS = "BGT-02";
    string constant BGT_CALLER_IS_NOT_GOVERNANCE = "BGT-03";

    // VaultBase error (VB)
    string constant VB_CALLER_IS_NOT_DABOT = "VB-01a";
    string constant VB_CALLER_IS_NOT_OWNER_BOT = "VB-01b";
    string constant VB_INVALID_VAULT_ID = "VB-02";
    string constant VB_INVALID_VAULT_TYPE = "VB-03";
    string constant VB_INVALID_SNAPSHOT_ID = "VB-04";

    // RegularVault Error (RV)
    string constant RV_VAULT_IS_RESTRICTED = "RV-01";
    string constant RV_DEPOSIT_LOCKED = "RV-02";
    string constant RV_WITHDRAWL_AMOUNT_EXCEED_DEPOSIT = "RV-03";

    // BotVaultManager (VM)
    string constant VM_VAULT_EXISTS = "VM-01";

    // BotManager (BM)
    string constant BM_DOES_NOT_SUPPORT_IDABOT = "BM-01";
    string constant BM_DUPLICATED_BOT_QUALIFIED_NAME = "BM-02";
    string constant BM_TEMPLATE_IS_NOT_REGISTERED = "BM-03";
    string constant BM_GOVERNANCE_TOKEN_IS_NOT_DEPLOYED = "BM-04";
    string constant BM_BOT_IS_NOT_REGISTERED = "BM-05";

    // DABotModule (BMOD)
    string constant BMOD_CALLER_IS_NOT_OWNER = "BMOD-01";
    string constant BMOD_CALLER_IS_NOT_BOT_MANAGER = "BMOD-02";
    string constant BMOD_BOT_IS_ABANDONED = "BMOD-03";

    // DABotControllerLib (BCL)
    string constant BCL_DUPLICATED_MODULE = "BCL-01";
    string constant BCL_CERT_TOKEN_IS_NOT_CONFIGURED = "BCL-02";
    string constant BCL_GOVERN_TOKEN_IS_NOT_CONFIGURED = "BCL-03";
    string constant BCL_GOVERN_TOKEN_IS_NOT_DEPLOYED = "BCL-04";
    string constant BCL_WARMUP_LOCKER_IS_NOT_CONFIGURED = "BCL-05";
    string constant BCL_COOLDOWN_LOCKER_IS_NOT_CONFIGURED = "BCL-06";
    string constant BCL_UKNOWN_MODULE_ID = "BCL-07";
    string constant BCL_BOT_MANAGER_IS_NOT_CONFIGURED = "BCL-08";

    // DABotController (BCMOD)
    string constant BCMOD_CANNOT_CALL_TEMPLATE_METHOD_ON_BOT_INSTANCE = "BCMOD-01";
    string constant BCMOD_CALLER_IS_NOT_OWNER = "BCMOD-02";
    string constant BCMOD_MODULE_HANDLER_NOT_FOUND_FOR_METHOD_SIG = "BCMOD-03";
    string constant BCMOD_NEW_OWNER_IS_ZERO = "BCMOD-04";

    // CEXFundManagerModule (CFMOD)
    string constant CFMOD_DUPLICATED_BENEFITCIARY = "CFMOD-01";
    string constant CFMOD_INVALID_CERTIFICATE_OF_ASSET = "CFMOD-02";
    string constant CFMOD_CALLER_IS_NOT_FUND_MANAGER = "CFMOD-03";

    // DABotSettingLib (BSL)
    string constant BSL_CALLER_IS_NOT_OWNER = "BSL-01";
    string constant BSL_CALLER_IS_NOT_GOVERNANCE_EXECUTOR = "BSL-02";
    string constant BSL_IBO_ENDTIME_IS_SOONER_THAN_IBO_STARTTIME = "BSL-03";
    string constant BSL_BOT_IS_ABANDONED = "BSL-04";

    // DABotSettingModule (BSMOD)
    string constant BSMOD_IBO_ENDTIME_IS_SOONER_THAN_IBO_STARTTIME =  "BSMOD-01";
    string constant BSMOD_INIT_DEPOSIT_IS_LESS_THAN_CONFIGURED_THRESHOLD = "BSMOD-02";
    string constant BSMOD_FOUNDER_SHARE_IS_ZERO = "BSMOD-03";
    string constant BSMOD_INSUFFICIENT_MAX_SHARE = "BSMOD-04";
    string constant BSMOD_FOUNDER_SHARE_IS_GREATER_THAN_IBO_SHARE = "BSMOD-05";

    // DABotCertLocker (LOCKER)
    string constant LOCKER_CALLER_IS_NOT_OWNER_BOT = "LOCKER-01";

    // DABotStakingModule (BSTMOD)
    string constant BSTMOD_PRE_IBO_REQUIRED = "BSTMOD-01";
    string constant BSTMOD_AFTER_IBO_REQUIRED = "BSTMOD-02";
    string constant BSTMOD_INVALID_PORTFOLIO_ASSET = "BSTMOD-03";
    string constant BSTMOD_PORTFOLIO_FULL = "BSTMOD-04";
    string constant BSTMOD_INVALID_CERTIFICATE_ASSET = "BSTMOD-05";
    string constant BSTMOD_PORTFOLIO_ASSET_NOT_FOUND = "BSTMOD-06";
    string constant BSTMOD_ASSET_IS_ZERO = "BSTMOD-07";
    string constant BSTMOD_INVALID_STAKING_CAP = "BSTMOD-08";
    string constant BSTMOD_INSUFFICIENT_FUND = "BSTMOD-09";
    string constant BSTMOD_CAP_IS_ZERO = "BSTMOD-10";
    string constant BSTMOD_CAP_IS_LESS_THAN_STAKED_AND_IBO_CAP = "BSTMOD-11";
    string constant BSTMOD_WERIGHT_IS_ZERO = "BSTMOD-12";

    // CEX FundManager (CFM)
    string constant CFM_REQ_TYPE_IS_MISMATCHED = "CFM-01";
    string constant CFM_INVALID_REQUEST_ID = "CFM-02";
    string constant CFM_CALLER_IS_NOT_BOT_TOKEN = "CFM-03";
    string constant CFM_CLOSE_TYPE_VALUE_IS_NOT_SUPPORTED = "CFM-04";
    string constant CFM_UNKNOWN_REQUEST_TYPE = "CFM-05";
    string constant CFM_CALLER_IS_NOT_REQUESTER = "CFM-06";
    string constant CFM_CALLER_IS_NOT_APPROVER = "CFM-07";
    string constant CFM_CEX_CERTIFICATE_IS_REQUIRED = "CFM-08";
    string constant CFM_TREASURY_ASSET_CERTIFICATE_IS_REQUIRED = "CFM-09";
    string constant CFM_FAIL_TO_TRANSFER_VALUE = "CFM-10";
    string constant CFM_AWARDED_ASSET_IS_NOT_TREASURY = "CFM-11";
    string constant CFM_INSUFFIENT_ASSET_TO_MINT_STOKEN = "CFM-12";

    // FarmBot Module (FBM)  string constant FBM_ = "FBM-";
    string constant FBM_CANNOT_REMOVE_WORKER = "FBM-01";
    string constant FBM_NULL_OPERATOR_ACCOUNT = "FBM-02";
    string constant FBM_INVALID_WORKER = "FBM-03";
    string constant FBM_REPAY_ERROR = "FBM-04";
    string constant FBM_INVALID_SWAP_ADAPTER = "FBM-05";
    string constant FBM_INVALID_SWAP_PATH = "FBM-06";
    string constant FBM_INSUFFICIENT_FUND = "FBM-07";

    // TreasuryAsset (TA)
    string constant TA_MINT_ZERO_AMOUNT = "TA-01";
    string constant TA_LOCK_AMOUNT_EXCEED_BALANCE = "TA-02";
    string constant TA_UNLOCK_AMOUNT_AND_PASSED_VALUE_IS_MISMATCHED = "TA-03";
    string constant TA_AMOUNT_EXCEED_AVAILABLE_BALANCE = "TA-04";
    string constant TA_AMOUNT_EXCEED_VALUE_BALANCE = "TA-05";
    string constant TA_FUND_MANAGER_IS_NOT_SET = "TA-06";
    string constant TA_FAIL_TO_TRANSFER_VALUE = "TA-07";

    // Governance (GOV)
    string constant GOV_DEFAULT_STRATEGY_IS_NOT_SET = "GOV-01";
    string constant GOV_INSUFFICIENT_POWER_TO_CREATE_PROPOSAL = "GOV-02";
    string constant GOV_INSUFFICIENT_VICS_TO_CREATE_PROPOSAL = "GOV-03";
    string constant GOV_INVALID_PROPOSAL_ID = "GOV-04";
    string constant GOV_REQUIRED_PROPOSER_OR_GUARDIAN = "GOV-05";
    string constant GOV_TARGET_SHOULD_BE_ZERO_OR_REGISTERED_BOT = "GOV-06";
    string constant GOV_INSUFFICIENT_POWER_TO_VOTE = "GOV-07";
    string constant GOV_INVALID_NEW_STATE = "GOV-08";
    string constant GOV_CANNOT_CHANGE_STATE_OF_CLOSED_PROPOSAL = "GOV-08";
    string constant GOV_INVALID_CREATION_DATA = "GOV-09";
    string constant GOV_CANNOT_CHANGE_STATE_OF_ON_CHAIN_PROPOSAL = "GOV-10";
    string constant GOV_PROPOSAL_DONT_ACCEPT_VOTE = "GOV-11";
    string constant GOV_DUPLICATED_VOTE = "GOV-12";
    string constant GOV_CAN_ONLY_QUEUE_PASSED_PROPOSAL = "GOV-13";
    string constant GOV_DUPLICATED_ACTION = "GOV-14";
    string constant GOV_INVALID_VICS_ADDRESS = "GOV-15";

    // Timelock Executor (TLE)
    string constant TLE_DELAY_SHORTER_THAN_MINIMUM = "TLE-01";
    string constant TLE_DELAY_LONGER_THAN_MAXIMUM = "TLE-02";
    string constant TLE_ONLY_BY_ADMIN = "TLE-03";
    string constant TLE_ONLY_BY_PENDING_ADMIN = "TLE-04";
    string constant TLE_ONLY_BY_THIS_TIMELOCK = "TLE-05";
    string constant TLE_EXECUTION_TIME_UNDERESTIMATED = "TLE-06";
    string constant TLE_ACTION_NOT_QUEUED = "TLE-07";
    string constant TLE_TIMELOCK_NOT_FINISHED = "TLE-08";
    string constant TLE_GRACE_PERIOD_FINISHED = "TLE-09";
    string constant TLE_NOT_ENOUGH_MSG_VALUE = "TLE-10";

    // DABotVoteStrategy (BVS) string constant BVS_ = "BVS-";
    string constant BVS_NOT_A_REGISTERED_DABOT = "BVS-01";

    // DABotWhiteList (BWL) string constant BWL_ = "BWL-";
    string constant BWL_ACCOUNT_IS_ZERO = "BWL-01";
    string constant BWL_ACCOUNT_IS_NOT_WHITELISTED = "BWL-02";

    // Marginal Lending Worker string constant MLF_ = "MLF-";
    string constant MLF_ZERO_DEPOSIT = "MLF-01";
    string constant MLF_UNKNOWN_CONFIG_TOPIC = "MLF-02";
    string constant MLF_REGISTERED_COLLATERAL_ID_EXPECTED = "MLF-03";
    string constant MLF_CONFIG_TOPICS_AND_VALUES_MISMATCHED = "MLF-04";
    string constant MLF_ADAPTER_IS_NOT_CONFIGURED = "MLF-05";
    string constant MLF_CANNOT_REMOVE_IN_USED_COLLATERAL = "MLF-06";
    string constant MLF_CANNOT_CHANGE_LENDING_ADAPTER = "MLF-07";
    string constant MLF_INVALID_PLATFORM_TOKEN = "MLF-08";
    string constant MLF_CANNOT_CHANGE_IN_USED_LEVERAGE_ASSET = "MLF-09";
    string constant MLF_INVALID_EXPECTED_HEALTH_FACTOR = "MLF-10";
    string constant MLF_LEVERAGE_ASSET_IS_NOT_SET = "MLF-11";
    string constant MLF_INVALID_PRECISION = "MLF-12";
    string constant MLF_INTERNAL_ERROR = "MLF-13";

    // FarmCertTokenModule (FTM) string constant FTM_ = "FTM-";
    string constant FTM_INSUFFICICIENT_AMOUNT_TO_DEPOSIT = "FTM-01";

    // ILendingAdapter (ILA) string constant ILA_ = "ILA-";
    string constant ILA_INVALID_EXPECTED_HEALTH_FACTOR = "ILA-01";

    // RoboFi game string constant RFG_ = "RFG-";
    string constant RFG_CALLER_IS_NOT_REGISTERED_BOT = "RFG-01";
    string constant RFG_CALLER_IS_NOT_BOT_OWNER = "RFG-02";
    string constant RFG_CALLER_IS_NOT_VAULT = "RFG-03";
    string constant RFG_ROUND_NOT_FINISHED = "RFG-04";
    string constant RFG_ROUND_NOT_IN_COMMIT_PHASE = "RFG-05";
    string constant RFG_ROUND_NOT_IN_REVEAL_PHASE = "RFG-06";
    string constant RFG_ROUND_NOT_READY_CLOSE = "RFG-07";
    string constant RFG_ROUND_NOT_CLOSED_YET = "RFG-08";
    string constant RFG_INVALID_SECRET_NUMBER = "RFG-09";
    string constant RFG_WINNER_IS_REQUIRE = "RFG-10";
    string constant RFG_INVALID_SUBMIT_WINNERS = "RFG-11";
    string constant RFG_INVALID_NUMBER_OF_WINNERS = "RFG-12";
    string constant RFG_INVALID_WON_NUMBER = "RFG-13";
    string constant RFG_INVALID_VICS_ADDRESS = "RFG-14";
    string constant RFG_INVALID_COMMIT_DURATION = "RFG-15";
    string constant RFG_INVALID_REVEAL_DURATION = "RFG-16";
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IBotVault.sol";
import "../DABotCommon.sol";
import "../../common/IRoboFiFactory.sol";
import "../../common/IConfigurator.sol";

interface IDABotManagerEvent {
    event BotRemoved(address indexed bot);
    event BotDeployed(uint botId, address indexed bot, BotDetail detail); 
    event TemplateRegistered(address indexed template, string name, string version, uint8 templateType);
}

interface IDABotManager is IDABotManagerEvent {
    
    function configurator() external view returns(IConfigurator);
    function vaultManager() external view returns(IBotVaultManager);
    function addTemplate(address template) external;
    function templates() external view returns(address[] memory);
    function isRegisteredTemplate(address template) external view returns(bool);
    function isRegisteredBot(address botAccount) external view returns(bool);
    function totalBots() external view returns(uint);
    function botIdOf(string calldata qualifiedName) external view returns(int);
    function queryBots(uint[] calldata botId) external view returns(BotDetail[] memory output);
    function deployBot(address template, 
                        string calldata symbol, 
                        string calldata name,
                        BotModuleInitData[] calldata initData
                        ) external;
    function snapshot(address botAccount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

import "./interfaces/IDABotComponent.sol";

enum BotStatus { PRE_IBO, IN_IBO, ACTIVE, ABANDONED }

struct BotModuleInitData {
    bytes32 moduleId;
    bytes data;
}

struct BotSetting {             // for saving storage, the meta-fields of a bot are encoded into a single uint256 byte slot.
    uint64 iboTime;             // 32 bit low: iboStartTime (unix timestamp), 
                                // 32 bit high: iboEndTime (unix timestamp)
    uint24 stakingTime;         // 8 bit low: warm-up time, 
                                // 8 bit mid: cool-down time
                                // 8 bit high: time unit (0 - day, 1 - hour, 2 - minute, 3 - second)
    uint32 pricePolicy;         // 16 bit low: price multiplier (fixed point, 2 digits for decimal)
                                // 16 bit high: commission fee in percentage (fixed point, 2 digit for decimal)
    uint128 profitSharing;      // packed of 16bit profit sharing: bot-creator, gov-user, stake-user, and robofi-game
    uint initDeposit;           // the intial deposit (in VICS) of bot-creator
    uint initFounderShare;      // the intial shares (i.e., governance token) distributed to bot-creator
    uint maxShare;              // max cap of gtoken supply
    uint iboShare;              // max supply of gtoken for IBO. Constraint: maxShare >= iboShare + initFounderShare
}

struct BotMetaData {
    string name;
    string symbol;
    string version;
    uint8 botType;
    bool abandoned;
    bool isTemplate;        // determine this module is a template, not a bot instance
    bool initialized;       // determines whether the bot has been initialized 
    address botOwner;       // the public address of the bot owner
    address botManager;
    address botTemplate;    // address of the template contract 
    address gToken;         // address of the governance token
}

struct BotDetail { // represents a detail information of a bot, merely use for bot infomation query
    uint id;                    // the unique id of a bot within its manager.
                                // note: this id only has value when calling {DABotManager.queryBots}
    address botAddress;         // the contract address of the bot.

    BotStatus status;           // 0 - PreIBO, 1 - InIBO, 2 - Active, 3 - Abandonned
    uint8 botType;              // type of the bot (inherits from the bot's template)
    string botSymbol;           // get the bot name.
    string botName;             // get the bot full name.
    address governToken;        // the address of the governance token
    address template;           // the address of the master contract which defines the behaviors of this bot.
    string templateName;        // the template name.
    string templateVersion;     // the template version.
    uint iboStartTime;          // the time when IBO starts (unix second timestamp)
    uint iboEndTime;            // the time when IBO ends (unix second timestamp)
    uint warmup;                // the duration (in days) for which the staking profit starts counting
    uint cooldown;              // the duration (in days) for which users could claim back their stake after submiting the redeem request.
    uint priceMul;              // the price multiplier to calculate the price per gtoken (based on the IBO price).
    uint commissionFee;         // the commission fee when buying gtoken after IBO time.
    uint initDeposit;           
    uint initFounderShare;
    uint144 profitSharing;
    uint maxShare;              // max supply of governance token.
    uint circulatedShare;       // the current supply of governance token.
    uint iboShare;              // the max supply of gtoken for IBO.
    uint userShare;             // the amount of governance token in the caller's balance.
    UserPortfolioAsset[] portfolio;
}

struct BotModuleInfo {
    string name;
    string version;
    address handler;
}

struct PortfolioCreationData {
    address asset;
    uint256 cap;            // the maximum stake amount for this asset (bot-lifetime).
    uint256 iboCap;         // the maximum stake amount for this asset within the IBO.
    uint256 weight;         // preference weight for this asset. Use to calculate the max purchasable amount of governance tokens.
}

struct PortfolioAsset {
    address certToken;    // the certificate asset to return to stake-users
    uint256 cap;            // the maximum stake amount for this asset (bot-lifetime).
    uint256 iboCap;         // the maximum stake amount for this asset within the IBO.
    uint256 weight;         // preference weight for this asset. Use to calculate the max purchasable amount of governance tokens.
}

struct UserPortfolioAsset {
    address asset;
    PortfolioAsset info;
    uint256 userStake;
    uint256 totalStake;     // the total stake of all users.
    uint256 certSupply;     // the total supply of the certificated token
}

/**
@dev Records warming-up certificate tokens of a DABot.
*/
struct LockerData {         
    address bot;            // the DABOT which creates this locker.
    address owner;          // the locker owner, who is albe to unlock and get tokens after the specified release time.
    address token;          // the contract of the certificate token.
    uint64 created_at;      // the moment when locker is created.
    uint64 release_at;      // the monent when locker could be unlock. 
}

/**
@dev Provides detail information of a warming-up token lock, plus extra information.
    */
struct LockerInfo {
    address locker;
    LockerData info;
    uint256 amount;         // the locked amount of cert token within this locker.
    uint256 reward;         // the accumulated rewards
    address asset;          // the stake asset beyond the certificated token
}

struct MintableShareDetail {
    address asset;
    uint stakeAmount;
    uint mintableShare;
    uint weight;
    uint iboCap;
}

struct AwardingDetail {
    address asset;
    uint compound;
    uint reward;
    uint compoundMode;  // 0 - increase, 1 - decrrease
}

struct StakingReward {
    address asset;
    uint amount;
}

struct BenefitciaryInfo {
    address account;
    string name;
    string shortName;
    uint weight;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IRoboFiFactory {
    function deploy(address masterContract, 
                    bytes calldata data, 
                    bool useCreate2) 
        external 
        payable 
        returns(address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


library Roles {
    bytes32 constant ROLE_ADMIN = keccak256('operator.dabot.role');
    bytes32 constant ROLE_OPERATORS = keccak256('operator.dabot.role');
    bytes32 constant ROLE_TEMPLATE_CREATOR = keccak256('creator.template.dabot.role');
    bytes32 constant ROLE_BOT_CREATOR = keccak256('creator.dabot.role');
    bytes32 constant ROLE_FUND_APPROVER = keccak256('approver.fund.role');
}

library AddressBook {
    bytes32 constant ADDR_FACTORY = keccak256('factory.address');
    bytes32 constant ADDR_VICS = keccak256('vics.address');
    bytes32 constant ADDR_TAX = keccak256('tax.address');
    bytes32 constant ADDR_GOVERNANCE = keccak256('governance.address');
    bytes32 constant ADDR_GOVERNANCE_EXECUTOR = keccak256('executor.governance.address');
    bytes32 constant ADDR_BOT_MANAGER = keccak256('botmanager.address');
    bytes32 constant ADDR_VICS_EXCHANGE = keccak256('exchange.vics.address');
    bytes32 constant ADDR_TREASURY_MANAGER = keccak256('treasury-manager.address');
    bytes32 constant ADDR_CEX_FUND_MANAGER = keccak256('fund-manager.address');
    bytes32 constant ADDR_CEX_DEFAULT_MASTER_ACCOUNT = keccak256('default.master.address');
    bytes32 constant ADDR_ROBOFI_GAME = keccak256('robofi-game.address');
}

library Config {
    /// The amount of VICS that a proposer has to pay when create a new proposal
    bytes32 constant PROPOSAL_DEPOSIT = keccak256('deposit.proposal.config');

    /// The percentage of proposal creation fee distributed to the account that execute a propsal
    bytes32 constant PROPOSAL_REWARD_PERCENT = keccak256('reward.proposal.config');

    /// The minimum VICS a bot creator has to deposit to a newly created bot
    bytes32 constant CREATOR_DEPOSIT = keccak256('deposit.creator.config');

    /// The minim 
    bytes32 constant PROPOSAL_CREATOR_MININUM_POWER = keccak256('minpower.goverance.config');
    
    /// The minimum percentage of for-votes over total votes a proposal has to achieve to be passed
    bytes32 constant PROPOSAL_MINIMUM_QUORUM = keccak256('minquorum.governance.config');

    /// The minimum difference (in percentage) between for-votes and against-vote for a proposal to be passed
    bytes32 constant PROPOSAL_VOTE_DIFFERENTIAL = keccak256('differential.governance.config');

    /// The voting duration of a proposal
    bytes32 constant PROPOSAL_DURATION = keccak256('duration.goverance.config');

    /// The interval that a passed proposed is waiting in queue before being executed
    bytes32 constant PROPOSAL_EXECUTION_DELAY = keccak256('execdelay.governance.config');

    // Number of winners of RoboFi Game
    bytes32 constant GAME_NUMBER_WINNER = keccak256('num-of-winner.game.config');

    // The commit phase duration of a game
    bytes32 constant GAME_COMMIT_DURATION = keccak256('commit.game.config');

    // The reveal phase duration of a game
    bytes32 constant GAME_REVEAL_DURATION = keccak256('reveal.game.config');
}

interface IConfigurator {
    function addressOf(bytes32 addrId) external view returns(address);
    function configOf(bytes32 configId) external view returns(uint);
    function bytesConfigOf(bytes32 configId) external view returns(bytes memory);

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);
    function getRoleMemberCount(bytes32 role) external view returns (uint256);

    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

bytes32 constant IDABotFarmingModuleID = keccak256("farming.module");
bytes32 constant IDABotFundManagerModuleID = keccak256('fundmanager.module');
bytes32 constant IDABotStakingModuleID = keccak256("staking.module");
bytes32 constant IDABotGovernModuleID = keccak256('governance.module');
bytes32 constant IDABotSettingModuleID = keccak256('setting.module');
bytes32 constant IDABotWhitelistModuleID = keccak256("whitelist.module");

bytes32 constant GovTokenHandlerID = keccak256('govtokenimpl.dabot.module');
bytes32 constant CertTokenHandlerID = keccak256('certtokenimpl.dabot.module');

bytes32 constant BOT_CERT_TOKEN_COOLDOWN_HANDLER_ID = keccak256("cooldown.dabot.module");

bytes32 constant BOT_CERT_TOKEN_TEMPLATE_ID = keccak256("certificate-token.dabot.module");
bytes32 constant BOT_GOV_TOKEN_TEMPLATE_ID = keccak256("governance-token.dabot.module");

//bytes32 constant BOT_MODULE_COOLDOWN_LOCKER = keccak256("cooldown.dabot.module");

interface IDABotComponent {   
    function moduleInfo() external view returns(string memory name, string memory version, bytes32 moduleId);
}