// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "./LevelProcessing.sol";

contract NextLevel is LevelProcessing {
    mapping(uint => NextLevelDTOs.Level) levels;
    mapping(address => NextLevelDTOs.ClientRef) joins;

    constructor(address mainToken, uint companyFee, uint joinPrice) LevelProcessing(mainToken, companyFee, joinPrice) {
        for (uint i = 0; i < 16; ++i) {
            levels[i].level = i;
        }
    }


    function toNextLevel() external {
        address client = msg.sender;
        uint nextLevel = getAllowanceLevel(client, block.timestamp);

        bool isFirstJoinToLevel;
        if (nextLevel == 0) {
            isFirstJoinToLevel = join(levels[nextLevel]);
        } else {
            uint tableId = joins[client].tablesRefByLevel[nextLevel - 1];
            isFirstJoinToLevel = joinNextLevel(levels[nextLevel - 1], tableId, levels[nextLevel]);
        }

        if (isFirstJoinToLevel) {
            firstJoinToLevel(nextLevel);
        }
        saveJoinRef(nextLevel);
    }

    function getActualLevel(address client) external view returns (uint) {
        return joins[client].actualLevel;
    }

    function getActualTable(address client) external view returns (NextLevelDTOs.TableView memory) {
        NextLevelDTOs.ClientRef storage clientRef = joins[client];
        uint actualClientLevel = clientRef.actualLevel;
        NextLevelDTOs.Table storage table = levels[actualClientLevel].tables[clientRef.tablesRefByLevel[actualClientLevel]];
        if (table.owner != client) {
            revert("No actual table found");
        }

        address[] memory clientJoins = new address[](table.joinId);
        for (uint i = 0; i < table.joinId; ++i) {
            clientJoins[i] = table.joins[i];
        }

        return NextLevelDTOs.TableView(
            table.tableId,
            table.owner,
            table.createdDate,
            table.closedDate,
            clientJoins,
            table.state
        );
    }

    function getAllowanceLevel(address client, uint timestamp) public view returns (uint) {
        NextLevelDTOs.ClientRef storage clientRef = joins[client];
        uint actualClientLevel = clientRef.actualLevel;
        if (actualClientLevel == 0 && levels[0].tables[clientRef.tablesRefByLevel[0]].owner != client) {
            return 0;
        }

        NextLevelDTOs.Table storage table = levels[actualClientLevel].tables[clientRef.tablesRefByLevel[actualClientLevel]];
        if (table.state == NextLevelDTOs.TableState.CLOSED && (timestamp - table.closedDate < nextLevelDelay)) {
            return actualClientLevel + 1;
        }

        revert("You haven't allowance level");
    }

    function saveJoinRef(uint level) private {
        NextLevelDTOs.ClientRef storage clientRef = joins[msg.sender];
        clientRef.tablesRefByLevel[level] = levels[level].tablesSize - 1;
        clientRef.actualLevel = level;
    }

    event FirstJoin(
        address client,
        uint tableJoinRef
    );

    event JoinNextLevel(
        address client,
        uint fromLevel,
        uint fromTable
    );
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "./NextLevelDTOs.sol";
import "../processing/TokenProcessing.sol";

abstract contract LevelProcessing is TokenProcessing {
    constructor(address mainToken, uint companyFee, uint joinPrice) TokenProcessing(mainToken, companyFee, joinPrice) {}

    function joinNextLevel(NextLevelDTOs.Level storage level, uint tableToNextLevelId, NextLevelDTOs.Level storage nextLevel) internal returns (bool) {
        NextLevelDTOs.Table storage tableToNextLevel = level.tables[tableToNextLevelId];
        require(tableToNextLevel.state == NextLevelDTOs.TableState.CLOSED, "LevelProcessing.nextLevel: table to next level has wrong state");
        require(block.timestamp - tableToNextLevel.closedDate < nextLevelDelay, "LevelProcessing.nextLevel: next level action expired");
        tableToNextLevel.state = NextLevelDTOs.TableState.NEXT_LEVEL;
        return join(nextLevel);
    }

    // Join to level. Return if first join to level.
    function join(NextLevelDTOs.Level storage level) internal returns (bool) {
        depositByLevel(level.level, msg.sender);
        bool isFirstJoinToLevel = joinActualTable(level);
        createNewLevelJoin(level);
        return isFirstJoinToLevel;
    }

    function createNewLevelJoin(NextLevelDTOs.Level storage level) private {
        NextLevelDTOs.Table storage newTable = level.tables[level.tablesSize++];
        newTable.tableId = level.tablesSize - 1;
        newTable.state = NextLevelDTOs.TableState.OPENED;
        newTable.owner = msg.sender;
        newTable.createdDate = block.timestamp;
    }

    // Join actual table. Return if first join to level.
    function joinActualTable(NextLevelDTOs.Level storage level) private returns (bool) {
        NextLevelDTOs.Table storage table = level.tables[level.actualTableId];
        if (table.owner == address(0)) {
            return true;
        }

        table.joins[table.joinId++] = msg.sender;
        withdrawalPrizeByLevel(level.level, table.owner);

        if (table.joinId == tableSize) {
            // Close actual table
            table.state = NextLevelDTOs.TableState.CLOSED;
            table.closedDate = block.timestamp;

            // Move level actual pointer
            level.actualTableId++;
        }

        return false;
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

library NextLevelDTOs {
    enum TableState{OPENED, CLOSED, NEXT_LEVEL}

    struct Level {
        uint level;
        mapping(uint => Table) tables;
        uint actualTableId;
        uint tablesSize;
    }

    struct Table {
        uint tableId;
        address owner;
        uint createdDate;
        uint closedDate;
        mapping(uint => address) joins;
        uint joinId;
        TableState state;
    }

    struct TableView {
        uint tableId;
        address owner;
        uint createdDate;
        uint closedDate;
        address[] joins;
        TableState state;
    }

    struct ClientRef {
        mapping(uint => uint) tablesRefByLevel;
        uint actualLevel;
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "../security/Ownable.sol";
import "./CompanyVault.sol";
import "./NextLevelConfiguration.sol";

abstract contract TokenProcessing is CompanyVault, NextLevelConfiguration {
    event FeeTaken(uint amount, address indexed targetAddress);

    constructor(address mainToken, uint companyFee, uint joinPrice) CompanyVault(mainToken) NextLevelConfiguration(companyFee, joinPrice) {}

    // Deposit from sender by level
    function depositByLevel(uint level, address client) internal {
        uint levelAmount = getLevelPrice(level);
        uint feePart = applyCompanyFee(levelAmount);
        increaseFee(feePart);
        depositToken(getMainIERC20Token(), client, levelAmount);
    }

    // If first join to level, all amount to fee
    function firstJoinToLevel(uint level) internal {
        uint levelAmount = getLevelPrice(level);
        uint feePart = applyCompanyFee(levelAmount);
        increaseFee(levelAmount - feePart);
    }

    // Withdrawal prize by level to client
    function withdrawalPrizeByLevel(uint level, address client) internal {
        uint levelAmount = getLevelPrice(level);
        uint feePart = applyCompanyFee(levelAmount);
        withdrawalToken(getMainIERC20Token(), client, levelAmount - feePart);
    }


    // Withdraw amount of tokens to recipient
    function withdrawalToken(IERC20 token, address recipient, uint amount) private {
        bool result = token.transfer(recipient, amount);
        require(result, "TokenProcessing: withdrawal token failed");
    }


    // Deposit amount of tokens from sender to this contract
    function depositToken(IERC20 token, address sender, uint amount) private {
        require(token.allowance(sender, address(this)) >= amount, "TokenProcessing: depositMainToken, not enough funds to deposit token");

        bool result = token.transferFrom(sender, address(this), amount);
        require(result, "TokenProcessing: depositMainToken, transfer from failed");
    }

    // Take company fee from main token company balance
    function takeFee(uint amount, address targetAddress) external onlyOwner {
        IERC20 token = getMainIERC20Token();
        require(amount <= getCompanyTokenBalance(), "CompanyVault: take fee amount exceeds token balance");

        bool result = token.transfer(targetAddress, amount);
        decreaseFee(amount);
        require(result, "TokenProcessing: take fee transfer failed");
        emit FeeTaken(amount, targetAddress);
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "../utils/Context.sol";

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        require(owner() == _msgSender(), "Security: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Security: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "../security/Ownable.sol";
import "../utils/IERC20.sol";

abstract contract CompanyVault is Ownable {
    IERC20 internal _IERC20token;
    uint private _companyTokenBalance;

    event OtherTokensTaken(uint amount, address indexed tokenAddress, address indexed targetAddress);

    constructor (address mainToken) {
        _IERC20token = IERC20(mainToken);
    }

    // Get main token
    function getMainToken() public view returns (address) {
        return address(_IERC20token);
    }


    // Get main IERC20 interface
    function getMainIERC20Token() internal view returns (IERC20) {
        return _IERC20token;
    }


    // Get main token company balance from fees
    function getCompanyTokenBalance() public view returns (uint) {
        return _companyTokenBalance;
    }

    // Decrease main. Calls only from take fee.
    function decreaseFee(uint amount) internal {
        _companyTokenBalance -= amount;
    }

    // Increase main fee. Calls only from joining.
    function increaseFee(uint amount) internal {
        _companyTokenBalance += amount;
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

abstract contract NextLevelConfiguration {
    uint internal constant tableSize = 4;
    uint internal constant nextLevelDelay = 86400;

    //DECIMALS 6 for 100%
    uint private _companyFee;

    uint private _joinPrice;


    constructor(uint companyFee, uint joinPrice) {
        require(companyFee <= 10 ** 6);
        _companyFee = companyFee;
        _joinPrice = joinPrice;
    }

    // Get company fee(main token)
    function getCompanyFee() external view returns (uint) {
        return _companyFee;
    }

    function getLevelPrice(uint level) public view returns (uint) {
        uint joinAmount = _joinPrice;
        if (level == 0) {
            return joinAmount;
        }
        uint lastLevelAmount = getLevelPrice(level - 1);
        return lastLevelAmount * tableSize - applyCompanyFee(lastLevelAmount * tableSize);
    }

    // Apply company fee and return company fee part
    function applyCompanyFee(uint amount) internal view returns (uint) {
        return (amount * _companyFee) / 10 ** 6;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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