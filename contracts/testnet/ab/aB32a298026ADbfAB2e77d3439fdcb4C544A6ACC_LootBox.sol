/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

// File: contracts/common/interfaces/IOperator.sol

pragma solidity ^0.8.0;

interface IOperator {
    event AddNewOperator(address indexed operator);

    function operators(address) external view returns (bool);

    function addOperator(address account) external;

    function removeOperator(address account) external;
}

// File: contracts/interfaces/IAccessoryManager.sol

pragma solidity ^0.8.0;

interface IAccessoryManager {
    struct Accessory {
		bool active;
		string name;
        uint8 maxStar;
	}
    function getAllAccessory() view external returns (Accessory[] memory accessories);
    function addAccessory(string memory name, uint8 maxStar) external returns(uint256 id);
    function isExitedAccessory(uint256 id) view external returns(bool);
    function deactiveAccessory(uint256 id) external;
    function activeAccessory(uint256 id) external;
    function getMaxStar(uint id) view external returns(uint8);
}
// File: @openzeppelin/contracts/utils/introspection/IERC165.sol



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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol



pragma solidity ^0.8.0;


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

// File: contracts/interfaces/IAccessory.sol

pragma solidity ^0.8.0;




interface IAccessory is IOperator, IERC721 {
    struct Metadata {
        uint256 accessoryType;
        uint8 star;
        uint16 level;
    }
    function manager() external view returns (IAccessoryManager);
    function infomations(uint256 _id) external view returns (uint256 accessoryType_, uint8 star_, uint16 level_);
    function getAccessoryInfo(uint256 _id) external view returns (uint8 star_, uint16 level_, uint8 maxStar_, string memory name_);
    function mint(address to, uint accessoryType, uint8 star) external returns(uint tokenId);
    function updateInformation(uint256 _id, uint8 _newStar, uint16 _level) external;
    function burn(uint256 tokenId) external;
    function totalSupply() external view returns (uint);
    function setURI(string memory _uri) external;
}

// File: contracts/interfaces/ILootBox.sol


pragma solidity ^0.8.0;

interface ILootBox {

  struct RewardInfo{
    uint8 star;
    uint16 totalRandom;
    uint16 guaranteeForEach;
  }
  
  struct Metadata{
    // uint8 id;
    string name;
    uint8 accessoryType;
    uint16 itemQuantityForEach;
    uint16 boxQuantity;
    uint16 totalItemRandom;
    uint16 totalItemGuarantee;
  }

  event Unbox(address indexed _user, uint8 indexed _type);
  function boxTypesCount() external view returns (uint8);
  function unbox(address _for, uint8 _type) external returns(uint[] memory accessoryIds);
}
// File: @openzeppelin/contracts/utils/Context.sol



pragma solidity ^0.8.0;

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
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol



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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/LootBox.sol

pragma solidity ^0.8.0;



contract LootBox is ILootBox, Ownable{

  IAccessory public accessory;
  address public vendor;

  mapping (uint8 => Metadata) public boxTypes;
  mapping (uint8 => RewardInfo[]) public rewards;

  uint8 public override boxTypesCount;

  modifier onlyVendor() {
    require(_msgSender() == vendor, "only vendor");
    _;
  }

  modifier onlyExistedBoxType(uint8 boxType) {
    require(boxType < boxTypesCount, "box is not existed");
    _;
  }

  constructor(address _accessory) Ownable() {
    accessory = IAccessory(_accessory);
  }

  function unbox(address receiver, uint8 boxType) external override onlyVendor onlyExistedBoxType(boxType) returns(uint[] memory accessoryIds) {
    return _unbox(receiver, boxType);
  }

  function _unbox(address receiver, uint8 boxType) internal returns(uint[] memory accessoryIds) {
    Metadata storage box = boxTypes[boxType];
    require(box.boxQuantity > 0, "Sold out");
    RewardInfo[] storage reward = rewards[boxType];
    box.boxQuantity--;

    uint16 minted;
    accessoryIds = new uint[](box.itemQuantityForEach);
    // mint guarantee
    for (uint256 i = 0; i < reward.length; i++) {
      if (reward[i].guaranteeForEach > 0) {
        for (uint256 j = 0; j < reward[i].guaranteeForEach; j++) {
          accessoryIds[minted] = accessory.mint(receiver, box.accessoryType, reward[i].star);
          minted++;
        }
        box.totalItemGuarantee -= reward[i].guaranteeForEach;
      }
    }

    // mint random
    for (minted; minted < box.itemQuantityForEach; minted++) {
      uint256 greatness = _random(box.totalItemRandom, accessory.totalSupply());
      uint256 _temp;
      uint8 star;
      while (star < reward.length && _temp <= greatness) {
        _temp += reward[star].totalRandom;
        star++;
      }
      accessoryIds[minted] = accessory.mint(receiver, box.accessoryType, star);
      reward[star - 1].totalRandom--;
      box.totalItemRandom--;
    }
  }

  function setVendor(address _vendor) external onlyOwner {
    vendor = _vendor;
  }

  function addNewType(
    string memory name, 
    uint8 accessoryType,
    uint8 boxQuantity,
    uint16 itemQuantityForEach,
    uint16[] memory guaranteeForEach,
    uint16[] memory totalRandom
  ) external onlyOwner returns (uint8 id) {
    require(
      guaranteeForEach.length > 0 && totalRandom.length == guaranteeForEach.length,
      "LootBox: mismatch length"
    );

    id = boxTypesCount;
    boxTypesCount++;

    Metadata storage boxType = boxTypes[id];
    RewardInfo[] storage reward = rewards[id];

    boxType.name = name;
    boxType.accessoryType = accessoryType;
    boxType.boxQuantity = boxQuantity;
    boxType.itemQuantityForEach = itemQuantityForEach;

    // push reward
    uint16 totalItemRandom;
    uint16 totalItemGuarantee;
    for (uint8 i = 0; i < guaranteeForEach.length; i++) {
      totalItemRandom += totalRandom[i];
      totalItemGuarantee += guaranteeForEach[i] * boxQuantity;
      reward.push(RewardInfo({
        star: i + 1,
        totalRandom: totalRandom[i],
        guaranteeForEach: guaranteeForEach[i]
      }));
    }
    require(totalItemRandom + totalItemGuarantee == itemQuantityForEach * boxQuantity, "reward amount is invalid");
    boxType.totalItemRandom = totalItemRandom;
    boxType.totalItemGuarantee = totalItemGuarantee;
  }

  function _random(uint16 maximum, uint256 seed) private view returns (uint16 randomNumber){
    randomNumber = uint16(uint(keccak256(abi.encodePacked(block.difficulty, seed, block.timestamp))) % maximum);
  }

}