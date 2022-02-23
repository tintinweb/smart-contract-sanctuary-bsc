//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/ICollection.sol";

contract MiranaCollection is Ownable, ICollection {
  mapping(address => Collection[]) public userCollections;

  Collection[] public collections;

  address[] public addressCollections;

  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    assembly {
      size := extcodesize(addr)
    }
    return size > 0;
  }

  function getCollection(address addr)
    public
    view
    override
    returns (Collection[] memory)
  {
    return userCollections[addr];
  }

  function setCollection(
    string memory collectionType,
    string memory logoImage,
    string memory collectionBanner,
    string memory collectionName,
    string memory collectionDescription,
    uint256 numberOfView,
    string memory categoryName
  ) public override {
    require(!isContract(_msgSender()), "caller is not contract");
    require(
      keccak256(abi.encodePacked((collectionType))) !=
        keccak256(abi.encodePacked((""))),
      "collectionType is requried"
    );
    require(
      keccak256(abi.encodePacked((logoImage))) !=
        keccak256(abi.encodePacked((""))),
      "logoImage is requried"
    );
    require(
      keccak256(abi.encodePacked((collectionBanner))) !=
        keccak256(abi.encodePacked((""))),
      "collectionBanner is requried"
    );
    require(
      keccak256(abi.encodePacked((collectionName))) !=
        keccak256(abi.encodePacked((""))),
      "collectionName is requried"
    );
    require(
      keccak256(abi.encodePacked((collectionDescription))) !=
        keccak256(abi.encodePacked((""))),
      "collectionDescription is requried"
    );
    require(
      keccak256(abi.encodePacked((categoryName))) !=
        keccak256(abi.encodePacked((""))),
      "categoryName is requried"
    );
    require(numberOfView >= 0, "numberOfView is required");

    uint256 _id = block.timestamp;
    address sellerAddress = _msgSender();

    Collection memory collection = Collection({
      _id: _id,
      collectionType: collectionType,
      logoImage: logoImage,
      collectionBanner: collectionBanner,
      collectionName: collectionName,
      collectionDescription: collectionDescription,
      numberOfView: numberOfView,
      categoryName: categoryName,
      sellerAddress: sellerAddress
    });
    userCollections[sellerAddress].push(collection);
    collections.push(collection);
  }
}

// SPDX-License-Identifier: MIT

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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICollection {
  struct Collection {
    uint256 _id;
    string collectionType;
    string logoImage;
    string collectionBanner;
    string collectionName;
    string collectionDescription;
    uint256 numberOfView;
    string categoryName;
    address sellerAddress;
  }

  function getCollection(address addr)
    external
    view
    returns (Collection[] memory);

  function setCollection(
    string memory collectionType,
    string memory logoImage,
    string memory collectionBanner,
    string memory collectionName,
    string memory collectionDescription,
    uint256 numberOfView,
    string memory categoryName
  ) external;
}

// SPDX-License-Identifier: MIT

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