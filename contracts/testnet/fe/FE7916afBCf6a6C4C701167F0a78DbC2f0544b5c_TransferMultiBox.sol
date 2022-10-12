/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: tranferMultiBox.sol


pragma solidity ^0.8.3;


pragma experimental ABIEncoderV2;

interface RunBoxInterface{
    function balanceOf(address owner) external view returns (uint256 balance);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function getBoxType(uint256 tokenId) external view returns (uint256);
    function setApprovalForAll(address operator, bool _approved) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

contract TransferMultiBox is Ownable {
    RunBoxInterface runboxContract;

    struct Box {
        uint256 tokenId;
        uint256 boxType;
    }

    constructor(address _runBoxAddress) {
        runboxContract = RunBoxInterface(_runBoxAddress);
    }

    function runBoxAddress(address _runBoxAddress) public onlyOwner {
        runboxContract = RunBoxInterface(_runBoxAddress);
    }

    //GET INFO BOXS OWNER
    function getListBoxByOwner(address owner) public view returns (Box[] memory) { 
        uint256 balance = runboxContract.balanceOf(owner);
        Box[] memory boxs = new Box[](balance);      
        for (uint i = 0; i < balance; i++) {
            uint256 tokenId = runboxContract.tokenOfOwnerByIndex(owner, i);
            uint256 typeBox = runboxContract.getBoxType(tokenId);
            Box memory box;
            box.tokenId = tokenId;
            box.boxType = typeBox;
            boxs[i] = box;
        }
        return boxs;
    } 

   function getListBoxIdByType(address owner, uint256 boxType) public view returns (uint256[] memory) { 
        uint256 totalType = getTotalBoxByType(owner, boxType);
        uint256 balance = runboxContract.balanceOf(owner);
        uint256[] memory listIdsByType = new uint256[](totalType);
        uint256 indexBox = 0;
        for (uint i = 0; i < balance; i++) {
            uint256 tokenId = runboxContract.tokenOfOwnerByIndex(owner, i);
            uint256 boxTypeById = runboxContract.getBoxType(tokenId);
            if(boxType == boxTypeById) {
                listIdsByType[indexBox] = tokenId;
                indexBox++;
            }           
        }
        return listIdsByType;
    }

    function getTotalBoxByType(address owner, uint256 boxType) public view returns (uint256) { 
        uint256 balance = runboxContract.balanceOf(owner);
        uint256 countBoxType;
        for (uint i = 0; i < balance; i++) {
            uint256 tokenId = runboxContract.tokenOfOwnerByIndex(owner, i);
            uint256 boxTypeById = runboxContract.getBoxType(tokenId);
            if(boxType == boxTypeById) {
                countBoxType++;
            }
        }
        return countBoxType;
    }

    function getTotalBoxByOwner(address owner) public view returns (uint256) { 
        return runboxContract.balanceOf(owner);
    }

    //TRANSFER BOX
    function getListBoxIdByOwner(address owner) private view returns (uint256[] memory) { 
        uint256 balance = runboxContract.balanceOf(owner);
        uint256[] memory listIds = new uint256[](balance);      
        for (uint i = 0; i < balance; i++) {
            uint256 tokenId = runboxContract.tokenOfOwnerByIndex(owner, i);
            listIds[i] = tokenId;
        }
        return listIds;
    } 

    function transferAllMultibox(address receiver) public { 
        uint256[] memory listIds = getListBoxIdByOwner(msg.sender);    
        for (uint i = 0; i < listIds.length; i++) {
           runboxContract.transferFrom(msg.sender, receiver, listIds[i]);
        }        
    } 

    function transferMultibox(address receiver, uint256 boxType, uint256 amount) public { 
        require(receiver != address(0), "account must be not equal address 0x");
        require(boxType > 0, "boxType must be greater than 0");
        require(amount <= getTotalBoxByType(msg.sender, boxType), "amount must be greater than balance box type amount");

        uint256[] memory listIds = getListBoxIdByType(msg.sender, boxType);    
        for (uint i = 0; i < amount; i++) {
           runboxContract.transferFrom(msg.sender, receiver, listIds[i]);
        }        
    }    
}