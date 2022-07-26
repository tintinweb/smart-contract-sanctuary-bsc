/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

// File: eth-contracts-org/contracts/core/cross_chain_manager/interface/IEthCrossChainData.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the EthCrossChainData contract, the implementation is in EthCrossChainData.sol
 */
interface IEthCrossChainData {
    function putCurEpochStartHeight(uint64 startHeight) external returns (bool);
    function getCurEpochStartHeight() external view returns (uint64);
    function putCurEpochId(uint64 epochId) external returns (bool);
    function getCurEpochId() external view returns (uint64);
    function putCurEpochValidatorPkBytes(bytes calldata curEpochPkBytes)  external returns (bool);
    function getCurEpochValidatorPkBytes() external view returns (bytes memory);
    function markFromChainTxExist(uint64 fromChainId, bytes32 fromChainTx) external returns (bool);
    function checkIfFromChainTxExist(uint64 fromChainId, bytes32 fromChainTx) external view returns (bool);
    function getEthTxHashIndex() external view returns (uint256);
    function putEthTxHash(bytes32 ethTxHash) external returns (bool);
    function putExtraData(bytes32 key1, bytes32 key2, bytes calldata value) external returns (bool);
    function getExtraData(bytes32 key1, bytes32 key2) external view returns (bytes memory);
    function transferOwnership(address newOwner) external;
    function pause() external returns (bool);
    function unpause() external returns (bool);
    function paused() external view returns (bool);
    // Not used currently by ECCM
    function getEthTxHash(uint256 ethTxHashIndex) external view returns (bytes32);
}
// File: eth-contracts-org/contracts/libs/GSN/Context.sol

pragma solidity ^0.5.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 * Refer from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/GSN/Context.sol
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: eth-contracts-org/contracts/libs/lifecycle/Pausable.sol

pragma solidity ^0.5.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called to pause, triggers stopped state.
     */
    function _pause() internal whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Called to unpause, returns to normal state.
     */
    function _unpause() internal whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: eth-contracts-org/contracts/libs/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
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
    constructor () internal {
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
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
    function transferOwnership(address newOwner) public  onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: eth-contracts-org/contracts/core/cross_chain_manager/data/EthCrossChainData.sol

pragma solidity ^0.5.0;




contract EthCrossChainData is IEthCrossChainData, Ownable, Pausable{

    mapping(uint256 => bytes32) public EthToPolyTxHashMap;
  
    uint256 public EthToPolyTxHashIndex;

    bytes public CurValidatorPkBytes;
    
    uint64 public CurEpochStartHeight;

    uint64 public CurEpochId;
    
    mapping(uint64 => mapping(bytes32 => bool)) FromChainTxExist;
    
    mapping(bytes32 => mapping(bytes32 => bytes)) public ExtraData;
    
    function putCurEpochStartHeight(uint64 startHeight) public whenNotPaused onlyOwner returns (bool) {
        CurEpochStartHeight = startHeight;
        return true;
    }

    function getCurEpochStartHeight() public view returns (uint64) {
        return CurEpochStartHeight;
    }
    
    function putCurEpochId(uint64 epochId) public whenNotPaused onlyOwner returns (bool) {
        CurEpochId = epochId;
        return true;
    }

    function getCurEpochId() public view returns (uint64) {
        return CurEpochId;
    }

    function putCurEpochValidatorPkBytes(bytes memory curEpochPkBytes) public whenNotPaused onlyOwner returns (bool) {
        CurValidatorPkBytes = curEpochPkBytes;
        return true;
    }

    function getCurEpochValidatorPkBytes() public view returns (bytes memory) {
        return CurValidatorPkBytes;
    }

    function markFromChainTxExist(uint64 fromChainId, bytes32 fromChainTx) public whenNotPaused onlyOwner returns (bool) {
        FromChainTxExist[fromChainId][fromChainTx] = true;
        return true;
    }

    function checkIfFromChainTxExist(uint64 fromChainId, bytes32 fromChainTx) public view returns (bool) {
        return FromChainTxExist[fromChainId][fromChainTx];
    }

    function getEthTxHashIndex() public view returns (uint256) {
        return EthToPolyTxHashIndex;
    }

    function putEthTxHash(bytes32 ethTxHash) public whenNotPaused onlyOwner returns (bool) {
        EthToPolyTxHashMap[EthToPolyTxHashIndex] = ethTxHash;
        EthToPolyTxHashIndex = EthToPolyTxHashIndex + 1;
        return true;
    }

    function getEthTxHash(uint256 ethTxHashIndex) public view returns (bytes32) {
        return EthToPolyTxHashMap[ethTxHashIndex];
    }

    function putExtraData(bytes32 key1, bytes32 key2, bytes memory value) public whenNotPaused onlyOwner returns (bool) {
        ExtraData[key1][key2] = value;
        return true;
    }
    function getExtraData(bytes32 key1, bytes32 key2) public view returns (bytes memory) {
        return ExtraData[key1][key2];
    }
    
    function pause() onlyOwner whenNotPaused public returns (bool) {
        _pause();
        return true;
    }
    
    function unpause() onlyOwner whenPaused public returns (bool) {
        _unpause();
        return true;
    }
}