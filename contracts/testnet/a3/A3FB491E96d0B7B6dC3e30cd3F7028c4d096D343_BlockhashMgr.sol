// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Manager is Ownable {
    
    mapping(string => address) public members;

    mapping(address => mapping(string => bool)) public userPermits;

    function setMember(string memory name, address member) external onlyOwner {
        members[name] = member;
    }

    function setUserPermit(
        address user,
        string memory permit,
        bool enable
    ) external onlyOwner {
        userPermits[user][permit] = enable;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "./Manager.sol";

abstract contract Member is Ownable{

    Manager public manager;

    address public contractOwner = msg.sender;

    modifier CheckPermit(string memory permit) {
        require(manager.userPermits(msg.sender, permit),
            "no permit");
        _;
    }

    function setManager(address addr) external onlyOwner {
        manager = Manager(addr);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;
 
import "../interface/IBlockhashMgr.sol";
import "../access/Member.sol";

contract BlockhashMgr is IBlockhashMgr, Member {

    mapping(uint256 => bytes32) public blockInfo;

    uint256 public preBlockNum = block.number;

    mapping(address => bool) public permission;

    function setPermission(address sender, bool enable) public CheckPermit("Config") {
        permission[sender] = enable;
    }

    function request() external{
        require(blockInfo[preBlockNum] == 0,"BlockhashMgr: Block has been updated");
        blockInfo[preBlockNum] = blockhash(preBlockNum);
    }

    function isRequest()public view returns(bool){
        return (blockInfo[preBlockNum] == 0) && (preBlockNum + 200 < block.number);
    }


    function request(uint256 blockNumber) external override {
        require(permission[msg.sender],"BlockhashMgr: No viewing permission");
        require(blockNumber >= block.number && blockNumber < block.number + 2,"BlockhashMgr: Block gap is too large");
        if (blockNumber != preBlockNum && blockInfo[preBlockNum] == 0) {
            if (block.number - preBlockNum > 256) {
                blockInfo[preBlockNum] = keccak256(abi.encodePacked(block.difficulty, blockNumber, block.timestamp, block.number, preBlockNum));
            } else {
                blockInfo[preBlockNum] = blockhash(preBlockNum);
            }
        }
        preBlockNum = blockNumber;
    }

    function getBlockhash(uint256 blockNumber) external override returns (bytes32) {
        require(permission[msg.sender],"BlockhashMgr: No viewing permission");
        require(block.number >= blockNumber,"BlockhashMgr: Only query historical blocks");

        if (blockInfo[blockNumber] == 0) {
            if (block.number - blockNumber > 256) {
                blockInfo[blockNumber] = keccak256(abi.encodePacked(block.difficulty, blockNumber, block.timestamp, block.number, preBlockNum));
            } else {
                blockInfo[blockNumber] = blockhash(blockNumber);
            }
            preBlockNum = blockNumber;
        }

        return blockInfo[blockNumber];
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

 
interface IBlockhashMgr {
    function request(uint256 blockNumber) external;

    function getBlockhash(uint256 blockNumber) external returns(bytes32);
}