// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

library Array {
     
    function getMaxElementandIndex(uint[] memory arr) internal pure returns(uint, uint) {
         
          uint max = arr[0];
          uint index;

          for (uint i=0; i< arr.length; i++) {
           if (arr[i] > max ) {
                max = arr[i];
                index = i;
           }
        }
        return (index,max);       
   }

   function getNoofDuplicates(uint[] memory arr, uint maxvalue) internal pure returns(uint) {
       uint duplicates;
       for (uint i=0; i< arr.length; i++) {
            if (maxvalue == arr[i]) {
                duplicates++;
            }
       }
       return duplicates;
   }

   function getAllDuplicateValue(uint[] memory arr, uint maxvalue, uint duplicates) internal pure returns(uint[] memory, uint[] memory) {
             
       uint[] memory index = new uint[](duplicates);
       uint[] memory value = new uint[](duplicates); 
       
       uint j;
       for (uint i=0; i< arr.length; i++) {
            if (maxvalue == arr[i]) {
                index[j] = i;
                value[j] = arr[i];
                j=j+1;
            }          
       }
       return (index,value);
   }

    function getWinners(uint[] memory indexes, bytes32[] memory bytesarr) internal pure returns(string[] memory) {
          
        string[] memory winners = new string[](indexes.length);
        
        for (uint i=0; i<indexes.length; i++) {
            winners[i] = string(abi.encodePacked(bytesarr[indexes[i]]));
        }
        return winners;  
    }

    function getAllchoices(uint[] memory indexes, bytes32[] memory bytesarr) internal pure returns(string[] memory) {
        
        string[] memory allchoices = new string[](bytesarr.length);

        for (uint i=0; i<indexes.length; i++) {
            allchoices[i] = string(abi.encodePacked(bytesarr[i]));
        }

        return allchoices;  
   }



    function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

}

    
contract NFTVoting is Ownable {

    using Array for uint[];

    struct VotingDetails {
       IERC721 votingAddress;                 
       bytes32[] choices;
       uint[] totalVotes;
    //    bytes32 winner;
       mapping(uint => bool) ticketIdUsed;       // ticketId is equivalent to NFTId
    //    bool iswinnerAnnounced;
       bool isVotinglive;
    }                                       

    uint public totalvotingEvents;  
    mapping(uint => VotingDetails) private votingeventDetails;
   
    event OpenNewVotingEvent(uint eventid, IERC721 _votingAddress);
    event CasteVote(uint eventid, uint ticketId, uint option);
 
    constructor()  {}

    modifier isEvent(uint eventId) {
        require(eventId <= totalvotingEvents, "eventId not exist");
        _;
    }
   

    function createtNewEvent(IERC721 _votingAddress, string[] memory _choices) external onlyOwner {
       totalvotingEvents++;
       VotingDetails storage votingevent = votingeventDetails[totalvotingEvents];
       votingevent.votingAddress = _votingAddress;

        for (uint i=0; i<_choices.length; i++) {
         votingevent.choices.push(bytes32(abi.encodePacked(_choices[i])));
         votingevent.totalVotes.push(0);
        }

       emit OpenNewVotingEvent(totalvotingEvents, _votingAddress);
    }


    function castVote(uint eventId, uint ticketId, uint option) external isEvent(eventId) {
       VotingDetails storage vd = votingeventDetails[eventId];
       require(!vd.ticketIdUsed[ticketId], "casteVote: ticketId already used");
       require(vd.votingAddress.ownerOf(ticketId) == msg.sender, "castVote: user not the owner of ticketid");
       // require(!vd.iswinnerAnnounced, "casteVote: event ended");
       require(vd.isVotinglive, "casteVote: event not live");
       vd.totalVotes[option] += 1;
       vd.ticketIdUsed[ticketId] = true;
       emit CasteVote(eventId, ticketId, option);
    }


    function startEvent(uint eventId) external onlyOwner isEvent(eventId) {
        VotingDetails storage vd = votingeventDetails[eventId];
        vd.isVotinglive = true;
    }


    function stopEvent(uint eventId) external onlyOwner isEvent(eventId) {
        VotingDetails storage vd = votingeventDetails[eventId];
        vd.isVotinglive = false;
    }


    function getMaxVotes(uint eventId) public view isEvent(eventId) returns(uint) {
        VotingDetails storage vd = votingeventDetails[eventId];
        uint[] memory totalvoteslocal = vd.totalVotes;

        (, uint maxvote) = totalvoteslocal.getMaxElementandIndex();
        return (maxvote);    
    }

    function checkWinner(uint eventId) public view isEvent(eventId) returns(string[] memory) {
        VotingDetails storage vd = votingeventDetails[eventId];
        uint[] memory totalvoteslocal = vd.totalVotes;

        (uint index, uint maxvote) = totalvoteslocal.getMaxElementandIndex();
        uint duplicate = totalvoteslocal.getNoofDuplicates(maxvote);
        
        uint[] memory indexes = new uint[](1);
        uint[] memory maxvotes = new uint[](1);

        if (duplicate >1) {
        (indexes, maxvotes) = totalvoteslocal.getAllDuplicateValue(maxvote,duplicate);
        }
        else {
        indexes[0] = index;
        maxvotes[0] = maxvote;
        }

        bytes32[] memory choiceslocal = vd.choices;       
        string[] memory winners = indexes.getWinners(choiceslocal);

        return winners; 
    }

    function getOptionsofEvent(uint eventId) public view isEvent(eventId) returns(string[] memory) {
        VotingDetails storage vd = votingeventDetails[eventId];
        bytes32[] memory choiceslocal = vd.choices;       
        string[] memory alloptions = vd.totalVotes.getAllchoices(choiceslocal);

        return alloptions;
    }   

    function getEventDetails(uint eventId) public view isEvent(eventId) returns (IERC721, string[] memory, uint[] memory, bool ) {
       VotingDetails storage vd = votingeventDetails[eventId];
       string[] memory allchoices = getOptionsofEvent(eventId);
       return (vd.votingAddress,allchoices,vd.totalVotes,vd.isVotinglive);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}