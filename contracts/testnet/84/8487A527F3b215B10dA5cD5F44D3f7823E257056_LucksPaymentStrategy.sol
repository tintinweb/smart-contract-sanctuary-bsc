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
pragma solidity ^0.8.0;

struct Task {
    uint256 endTime;
    uint256 lastTimestamp;
}

interface ILucksAuto {

    event FundsAdded(uint256 amountAdded, uint256 newBalance, address sender);
    event FundsWithdrawn(uint256 amountWithdrawn, address payee);

    event KeeperRegistryAddressUpdated(address oldAddress, address newAddress);
    event MinWaitPeriodUpdated(uint256 oldMinWaitPeriod, uint256 newMinWaitPeriod);

    event RevertInvoke(uint256 taskId, bytes reason);

    function addTask(uint256 taskId, uint endTime) external;
    function removeTask(uint256 taskId) external;
    function getQueueTasks() external view returns (uint256[] memory);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// OpenLuck
import {TaskItem, TaskExt} from "./ILucksExecutor.sol";

struct lzTxObj {
    uint256 dstGasForCall;
    uint256 dstNativeAmount;
    bytes dstNativeAddr;
    bytes zroPaymentAddr; //  the address of the ZRO token holder who would pay for the transaction
}

interface ILucksBridge {
    // ============= events ====================
    event SendMsg(uint8 msgType, uint64 nonce);

    // ============= Task functions ====================

    function sendCreateTask(
        uint16 _dstChainId,
        address payable _user,
        TaskItem memory item,
        TaskExt memory ext,
        lzTxObj memory _lzTxParams
    ) external payable;

    function sendWithdrawNFTs(
        uint16 _dstChainId,
        address payable _user,
        uint256 depositId,
        lzTxObj memory _lzTxParams
    ) external payable;

    // ============= Assets functions ====================

    function quoteLayerZeroFee(
        uint16 _dstChainId,
        uint8 _functionType,
        string memory _note,
        lzTxObj memory _lzTxParams
    ) external view returns (uint256 nativeFee, uint256 zroFee);

    function estimateCreateTaskFee(
        uint16 _dstChainId,
        TaskItem memory item,
        TaskExt memory ext,
        lzTxObj memory _lzTxParams
    ) external view returns (uint256 nativeFee, uint256 zroFee);

    function estimateWithdrawNFTsFee(
        uint16 _dstChainId,
        address payable _user,
        uint256 depositId,
        lzTxObj memory _lzTxParams
    ) external view returns (uint256 nativeFee, uint256 zroFee);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { lzTxObj } from "./ILucksBridge.sol";

/** 
    TaskStatus
    0) Pending: task created but not reach starttime
    1) Open: task opening
    2) Close: task close, waiting for draw
    3) Success: task reach target, drawed winner
    4) Fail: task Fail and expired
    5) Cancel: task user cancel
 */
enum TaskStatus {
    Pending,
    Open,
    Close,
    Success,
    Fail,
    Cancel
}

struct ExclusiveToken {
    address token; // exclusive token contract address    
    uint256 amount; // exclusive token holding amount required
}

struct TaskItem {

    address seller; // Owner of the NFTs
    uint16 nftChainId; // NFT source ChainId    
    address nftContract; // NFT registry address    
    uint256[] tokenIds; // Allow mulit nfts for sell    
    uint256[] tokenAmounts; // support ERC1155
    
    address acceptToken; // acceptToken    
    TaskStatus status; // Task status    

    uint256 startTime; // Task start time    
    uint256 endTime; // Task end time
    
    uint256 targetAmount; // Task target crowd amount (in wei) for the published item    
    uint256 price; // Per ticket price  (in wei)    
    
    uint16 paymentStrategy; // payment strategy;
    ExclusiveToken exclusiveToken; // exclusive token contract address    
    
    // editable fields
    uint256 amountCollected; // The amount (in wei) collected of this task
    uint256 depositId; // NFTs depositId (system set)
}

struct TaskExt {
    uint16 chainId; // Task Running ChainId   
    string title; // title (for searching keywords)  
    string note;   // memo
}

struct Ticket {
    uint256 number;  // the ticket's id, equal to the end number (last ticket id)
    uint32 count;   // how many QTY the ticket joins, (number-count+1) equal to the start number of this ticket.
    address owner;  // ticket owner
}

struct TaskInfo {
    uint256 lastTID;
    uint256 closeTime;
    uint256 finalNo;
}
 
struct UserState {
    uint256 num; // user buyed tickets count
    bool claimed;  // user claimed
}
interface ILucksExecutor {

    // ============= events ====================

    event CreateTask(uint256 taskId, TaskItem item, TaskExt ext);
    event CancelTask(uint256 taskId, address seller);
    event CloseTask(uint256 taskId, address caller, TaskStatus status);
    event JoinTask(uint256 taskId, address buyer, uint256 amount, uint256 count, uint256 number,string note);
    event PickWinner(uint256 taskId, address winner, uint256 number);
    event ClaimToken(uint256 taskId, address caller, uint256 amount, address acceptToken);
    event ClaimNFT(uint256 taskId, address seller, address nftContract, uint256[] tokenIds);
    
    event CreateTickets(uint256 taskId, address buyer, uint256 num, uint256 start, uint256 end);

    // ============= functions ====================

    function count() external view returns (uint256);
    function exists(uint256 taskId) external view returns (bool);
    function getTask(uint256 taskId) external view returns (TaskItem memory);
    function getInfo(uint256 taskId) external view returns (TaskInfo memory);
    function isFail(uint256 taskId) external view returns(bool);
    function getChainId() external view returns (uint16);

    function createTask(TaskItem memory item, TaskExt memory ext, lzTxObj memory _param) external payable;
    function joinTask(uint256 taskId, uint32 num, string memory note) external payable;
    function cancelTask(uint256 taskId, lzTxObj memory _param) external payable;
    function closeTask(uint256 taskId, lzTxObj memory _param) external payable;
    function pickWinner(uint256 taskId, lzTxObj memory _param) external payable;

    function claimTokens(uint256[] memory taskIds) external;
    function claimNFTs(uint256[] memory taskIds, lzTxObj memory _param) external payable;

    function onLzReceive(uint8 functionType, bytes memory _payload) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Openluck interfaces
import {ILucksExecutor, TaskItem, TaskStatus, Ticket} from "./ILucksExecutor.sol";
import {ILucksHelper} from "./ILucksHelper.sol";

interface ILucksGroup {    

    event JoinGroup(address user, uint256 taskId, uint256 groupId);
    event CreateGroup(address user, uint256 taskId, uint256 groupId, uint16 seat);     

    function getGroupUsers(uint256 taskId, address winner) view external returns (address[] memory);
   
    function joinGroup(uint256 taskId, uint256 groupId, uint16 seat) external;
    function createGroup(uint256 taskId, uint16 seat) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// OpenZeppelin contracts
import "@openzeppelin/contracts/access/Ownable.sol";

// Openluck interfaces
import {TaskItem, TaskExt} from "./ILucksExecutor.sol";
import {ILucksVRF} from "./ILucksVRF.sol";
import {ILucksGroup} from "./ILucksGroup.sol";
import {ILucksPaymentStrategy} from "./ILucksPaymentStrategy.sol";
import {ILucksAuto} from "./ILucksAuto.sol";

interface ILucksHelper {

    function checkPerJoinLimit(uint32 num) external view returns (bool);
    function checkAcceptToken(address acceptToken) external view returns (bool);
    function checkNFTContract(address addr) external view returns (bool);
    function checkNewTask(address user, TaskItem memory item) external view returns (bool);
    function checkNewTaskExt(TaskExt memory ext) external pure returns (bool);
    function checkNewTaskRemote(TaskItem memory item) external view returns (bool);
    function checkJoinTask(address user, uint256 taskId, uint32 num, string memory note) external view returns (bool);
    function checkTokenListing(address addr, address seller, uint256[] memory tokenIds, uint256[] memory amounts) external view returns (bool,string memory);    
    function checkExclusive(address account, address token, uint256 amount) external view returns (bool);

    function getProtocolFeeRecipient() external view returns (address);
    function getProtocolFee() external view returns (uint256);
    function getMinTargetLimit(address token) external view returns (uint256);
    function getDrawDelay() external view returns (uint32);

    function getVRF() external view returns (ILucksVRF);
    function getGROUPS() external view returns (ILucksGroup);
    // function getREWARDS() external view returns (ILucksRewards);
    function getSTRATEGY() external view returns (ILucksPaymentStrategy);
    function getAutoClose() external view returns (ILucksAuto);
    function getAutoDraw() external view returns (ILucksAuto);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface ILucksPaymentStrategy {
    
    function getShareRate(uint16 strategyId) external pure returns (uint32);
    function viewPaymentShares(uint16 strategyId, address winner,uint256 taskId) external view returns (uint256, uint256[] memory, address[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILucksVRF {

    event ReqRandomNumber(uint256 taskId, uint256 max, uint256 requestId);
    event RspRandomNumber(uint256 taskId, uint256 requestId, uint256 randomness, uint32 number);    

    /**
     * Requests randomness from a user-provided max
     */
    function reqRandomNumber(uint256 taskId, uint256 max) external;

    /**
     * Views random result
     */
    function viewRandomResult(uint256 taskId) external view returns (uint32);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Openluck interfaces
import {ILucksPaymentStrategy} from "../interfaces/ILucksPaymentStrategy.sol";
import {ILucksGroup} from "../interfaces/ILucksGroup.sol";
import {ILucksExecutor, Ticket} from "../interfaces/ILucksExecutor.sol";


/** @title Openluck LucksPaymentStrategy
 * @notice It is the contract for PaymentStrategy
 */
contract LucksPaymentStrategy is ILucksPaymentStrategy {    

    ILucksExecutor public EXECUTOR;
    ILucksGroup public GROUPS;

    constructor(address _executor, ILucksGroup _groups) {
        EXECUTOR = ILucksExecutor(_executor);
        GROUPS = _groups;
    }

    function getShareRate(uint16 strategyId) public override pure returns (uint32) {
        if (strategyId == 1){ // 10%
            return 1000;  
        } else if (strategyId == 2) { // 20%
            return 2000;   
        }
        else if (strategyId == 3){ // 30%
            return 3000;
        }
        else {
            return 0;
        }
    }

    function viewPaymentShares(uint16 strategyId, address winner,uint256 taskId) 
      override public view returns (uint256, uint256[] memory, address[] memory) 
    {        
        uint32 rate = getShareRate(strategyId);
        uint256[] memory spliter;
        address[] memory users;

        if (rate > 0) {                               
            users = GROUPS.getGroupUsers(taskId, winner);
            if (users.length > 1){            
                spliter = new uint256[](users.length);
                uint256 splitShare = 10000 / users.length;
                for (uint i=0; i< users.length; i++) {
                    spliter[i] = splitShare;
                }            
            }             
        }

        return (rate,spliter,users);
    }
}