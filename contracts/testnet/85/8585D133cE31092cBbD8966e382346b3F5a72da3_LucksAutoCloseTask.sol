// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// OpenZeppelin contracts
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

// Chainlink contracts
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

// Openluck interfaces
import {ILucksExecutor, TaskItem} from "../interfaces/ILucksExecutor.sol";
import {ILucksAuto,Task} from "../interfaces/ILucksAuto.sol";
import {lzTxObj} from "../interfaces/ILucksBridge.sol";
import "../libraries/SortedLinkMap.sol";

contract LucksAutoCloseTask is ILucksAuto, Ownable, Pausable, KeeperCompatibleInterface {

    using SortedLinkMap for SortedLinkMap.SortedMap;    

    SortedLinkMap.SortedMap private taskList;

    // uint256 public WAIT_PERIOD_SEC = 300; // set WAIT_PERIOD_SEC to avoid repeated execution, default 5min
    uint256 public BATCH_PERFORM_LIMIT = 10; // perform limist, default 10
    uint256 public DST_GAS_AMOUNT = 0; // layer zero dstGasAmount

    address public KEEPER; // chainLink keeper Registry Address
    ILucksExecutor public EXECUTOR;    

    /**
    * @param _keeperRegAddr The address of the keeper registry contract
    * @param _executor The LucksExecutor contract
    */
    constructor(address _keeperRegAddr, ILucksExecutor _executor) {        
        KEEPER = _keeperRegAddr;
        EXECUTOR = _executor;
    }


    modifier onlyKeeper() {
        require(msg.sender == KEEPER || msg.sender == owner(), "onlyKeeperRegistry");
        _;
    }

    modifier onlyExecutor() {
        require(msg.sender == address(EXECUTOR) || msg.sender == owner(), "onlyExecutor");
        _;
    }

    /**
    * @notice Receive funds
    */
    receive() external payable {
        emit FundsAdded(msg.value, address(this).balance, msg.sender);
    }

    //  ============ Public  functions  ============

    function size() external view returns(uint256) {
        return taskList.count;
    }

    function first() external view returns(uint256) {
        return taskList.first();
    }

    function next(uint256 taskId) external view returns(uint256) {
        return taskList.next(taskId);
    }    

    function get(uint256 taskId) external view returns(uint256) {
        return taskList.nodes[taskId].value;
    }

    function addTask(uint256 taskId, uint endTime) external override onlyExecutor {    
        if (taskId > 0 && endTime > 0) {            
            taskList.add(taskId, endTime);
        }
    }

    function removeTask(uint256 taskId) external override onlyExecutor {        
        _removeTask(taskId);
    }

    function getQueueTasks() public override view returns (uint256[] memory) {

        uint256[] memory ids = new uint256[](BATCH_PERFORM_LIMIT);

        uint256 count = 0;
        uint taskId = taskList.first();
       
        while (taskId > 0 && count < BATCH_PERFORM_LIMIT) {
                  
            if (taskList.nodes[taskId].value <= block.timestamp) {                
                ids[count] = taskId;    
                count++;                   
            }else {
                break;
            }
            taskId = taskList.next(taskId);           
        }
       
        if (count != BATCH_PERFORM_LIMIT) {
            assembly {
                mstore(ids, count)
            }
        }
        return ids;
    }

    //  ============ internal  functions  ============

    function _removeTask(uint256 taskId) internal {                
        taskList.remove(taskId);
    }

    function invokeTasks(uint256[] memory _taskIds) internal {

        lzTxObj memory _lzTxObj = lzTxObj(DST_GAS_AMOUNT, 0, bytes("0x"), bytes("0x"));

         for (uint256 i = 0; i < _taskIds.length; i++) {

            uint256 taskId = _taskIds[i];
            _removeTask(taskId);

            try EXECUTOR.closeTask(taskId, _lzTxObj) {
         
            } catch(bytes memory reason) {
                emit RevertInvoke(taskId, reason);
            }            
        }
    }

    //  ============ Keeper  functions  ============

    function checkUpkeep(bytes calldata /* checkData */) external view override whenNotPaused returns (bool upkeepNeeded, bytes memory performData) {
        uint256[] memory ids = getQueueTasks();
        upkeepNeeded = ids.length > 0;
        performData = abi.encode(ids);
        return (upkeepNeeded, performData);
    }

    function performUpkeep(bytes calldata performData) external override whenNotPaused onlyKeeper {
        uint256[] memory ids = abi.decode(performData, (uint256[]));
        invokeTasks(ids);
    }

    //  ============ onlyOwner  functions  ============
    
    /**
    * @notice Pauses the contract, which prevents executing performUpkeep
    */
    function pause() external onlyOwner {
        _pause();
    }

    /**
    * @notice Unpauses the contract
    */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
    * @notice Withdraws the contract balance
    * @param amount The amount of eth (in wei) to withdraw
    * @param payee The address to pay
    */
    function withdraw(uint256 amount, address payable payee) external onlyOwner {
        require(payee != address(0));
        emit FundsWithdrawn(amount, payee);
        payee.transfer(amount);
    }

    /**
    * @notice Sets the keeper registry address
    */
    function setKeeper(address _keeperRegAddr) public onlyOwner {
        require(_keeperRegAddr != address(0));
        emit KeeperRegistryAddressUpdated(KEEPER, _keeperRegAddr);
        KEEPER = _keeperRegAddr;
    }

    // function setWaitPeriod(uint256 second) public onlyOwner {      
    //     WAIT_PERIOD_SEC = second;
    // }

    function setBatchPerformLimist(uint256 num) public onlyOwner {      
        require(num > 0, "Invalid limit num");
        BATCH_PERFORM_LIMIT = num;
    }

    function setDstGasAmount(uint256 amount) public onlyOwner {      
        DST_GAS_AMOUNT = amount;
    }

    /**
    @notice set operator
     */
    function setExecutor(ILucksExecutor _executor) external onlyOwner {
        EXECUTOR = _executor;
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

import "./KeeperBase.sol";
import "./interfaces/KeeperCompatibleInterface.sol";

abstract contract KeeperCompatible is KeeperBase, KeeperCompatibleInterface {}

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


library SortedLinkMap {

    struct Item {        
        uint id;
        uint value;
        uint leftId;
    }

    uint constant None = uint(0);

    struct SortedMap {
        uint count;
        Item max;
        mapping(uint => uint) keys; // id => id , linked list
        mapping(uint => Item) nodes; // id => value item
    }
    
    function add(SortedMap storage self, uint id, uint value) internal {                

        require(id > 0, "require id > 0");
        
        if (self.nodes[id].value > 0){
            // not allow duplicate key
            return;
        }

        uint leftId = findPrevByValue(self, value);
        uint rightId = next(self, leftId);

        // update prev item link
        self.keys[leftId] = id;

        // update current item
        self.keys[id] = rightId;        
        self.nodes[id] = Item(id, value, leftId);   

        // update max item
        if (rightId == None) {
            self.max.id = id;
            self.max.leftId = leftId;
            self.max.value = value;
        }        
        else {
            // upate next item link
            self.nodes[rightId].leftId = id;   
        }

        // update counts
        self.count ++;                    
    }

    function remove(SortedMap storage self, uint id) internal {

        if (exists(self, id)) {

            delete self.nodes[id]; // remove value
            delete self.keys[id]; // remove key

            uint leftId = prev(self, id);
            uint rightId = next(self, id);

            self.keys[leftId] = rightId;

            if (rightId > 0) {
                self.nodes[rightId].leftId = leftId;
            }

            self.count --;
        }
    }

    function exists(SortedMap storage self, uint id) internal view returns(bool) {
        require(id > 0);
        return self.nodes[id].value > 0;
    }

    function first(SortedMap storage self) internal view returns(uint) {
        return next(self, 0);
    }
       
    function last(SortedMap storage self) internal view returns(uint) {
        return self.max.id;
    }

    function size(SortedMap storage self) internal view returns(uint) {
        return self.count;
    }

    function findPrevByValue(SortedMap storage self, uint target) internal view returns(uint256) {  

        require(target > 0, "require target > 0");

        if (self.count == 0) return None;
        
        // try to match last item
        uint lastId = self.max.id;
        uint lastValue = self.max.value;
        if (target >= lastValue) {            
            return lastId; // return max
        }

        // try to match first item
        uint firstId = first(self);
        uint firsValue = self.nodes[firstId].value;
        if (target <= firsValue) {
            return None;  // return head
        }

        uint mid = (firsValue + lastValue) >> 1;

        if (target >= mid) {
            // find prev item step by step (right to left)
            uint curentId = lastId;
            while (curentId > 0) {
                curentId = prev(self, curentId);
                if (curentId > 0 && target >= self.nodes[curentId].value) {
                    return curentId;
                }        
            }
        }
        else {
            // find next item step by step (left to right)
            uint curentId = firstId;
            while (curentId > 0) { // the lastId node is zero
                curentId = next(self, curentId);
                if (curentId > 0 && target >= self.nodes[curentId].value) {
                    return curentId;
                }        
            }
        }

        return None;
    }

    function prev(SortedMap storage self, uint id) internal view returns(uint256) {
        if (exists(self, id)) {
            return self.nodes[id].leftId;
        }  
        return None;     
    }

    function next(SortedMap storage self, uint id) internal view returns(uint256) {
        uint nextId = self.keys[id];
        return nextId;
    }  

    function get(SortedMap storage self, uint id) internal view returns(Item memory) {
        return self.nodes[id];
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

contract KeeperBase {
  error OnlySimulatedBackend();

  /**
   * @notice method that allows it to be simulated via eth_call by checking that
   * the sender is the zero address.
   */
  function preventExecution() internal view {
    if (tx.origin != address(0)) {
      revert OnlySimulatedBackend();
    }
  }

  /**
   * @notice modifier that allows it to be simulated via eth_call by checking
   * that the sender is the zero address.
   */
  modifier cannotExecute() {
    preventExecution();
    _;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface KeeperCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easily be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}