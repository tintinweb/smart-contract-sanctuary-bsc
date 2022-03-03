/*
 *  Oblivion :: NFT Market Collection Manager
 *
 *  This contract is responsible for managing the details of the collections.
 *
 *  SPDX-License-Identifier: MIT
 */

pragma solidity ^0.8.4;

import "./access/Ownable.sol";
import "./NftMarketObjects.sol";
import "./NftMarketInterfaces.sol";

contract NftMarketCollectionManager is Ownable, ICollection {
    address                                 public market;                      // The address of the market contract
    Collection[]                            public collections;                 // Array storing all of the collections
    mapping(address => NftCollectionInfo)   public nftCollectionInfo;           // Mapping that returns the collection id of an nft
    mapping(address => address)             public override nftModerators;      // Mapping to store a list of moderators who have the power to add a NFT to a collection
    mapping(address => uint[])              public override userCollections;    // Mapping to store references to a user's collections
    mapping(address => bool)                public ownerLockout;                // Mapping to store if NFT owner has locked market owner from setting moderator
    
    mapping(uint => mapping(string => string)) public metadata;                 // Mapping that stores metadata information for a collection

    // Events for sending notifications when things happen
    event SetModerator(address indexed nft, address indexed newModerator);
    event PopulateCollection(uint indexed id, address indexed owner, string name, address treasury, uint royalties);
    event TransferCollectionOwnership(uint indexed id, address indexed newOwner);
    event AddNftToCollection(uint indexed id, uint index, address nft);
    event RemoveNftFromCollection(uint indexed id, uint index, address nft);

    // Function to set the market address
    function setMarket(address _market) public onlyOwner() {
        market = _market;
    }

    // Functions for reading contract data
    function totalCollections() public override view returns (uint) { return collections.length; }
    function totalCollectionNfts(uint _collection) public override view returns (uint) { return collections[_collection].nfts.length; }
    function collectionNfts(uint _collection) public override view returns (address[] memory) { return collections[_collection].nfts; }
    function nftInfo(address _nft) public override view returns (NftCollectionInfo memory) { return nftCollectionInfo[_nft]; }
    function getCollection(uint _id) public override view returns (Collection memory) { return collections[_id]; }
    function totalUserCollections(address _user) public override view returns (uint) { return userCollections[_user].length; }

    // Function to set the moderator of a NFT contract from the NFT contract owner plus allows the NFT market contract owner to set the
    // moderator for instances where the NFT contract has been renounced and the team has manually verified to our team they own the contract
    function setModerator(address _nft, address _moderator, address _requester) public override {
        require(msg.sender == market, 'must be market');
        require(INft(_nft).owner() == _requester || (_requester == owner() && !ownerLockout[_nft]), 'must be owner');
        nftModerators[_nft] = _moderator;
        emit SetModerator(_nft, _moderator);
    }

    // Function for an NFT owner to set a block preventing market contract owner from setting moderator flag
    function setOwnerLockout(address _nft, bool _lockedOut, address _requester) public override {
        require(msg.sender == market, 'must be market');
        require(INft(_nft).owner() == _requester, 'must be owner');
        ownerLockout[_nft] = _lockedOut;
    }

    // Function to set a metadata field for a collection
    function setMetadata(uint _id, string[] memory _keys, string[] memory _values, address _requester) public override {
        require(msg.sender == market, 'must be market');
        require(collections[_id].owner == _requester, 'must be owner');
        require(_keys.length > 0, 'no metadata provided');
        require(_keys.length == _values.length, 'parameters failure');
        for (uint i = 0; i < _keys.length; i++) metadata[_id][_keys[i]] = _values[i];
    }

    // Function to get a metadata field for a collection
    function getMetadata(uint _id, string memory _key) public override view returns (string memory) {
        return metadata[_id][_key];
    }

    // Function for creating a collection
    function createCollection(string memory _name, address _treasury, uint _royalties, uint _maxRoyalties, address _requestor) public override {
        require(msg.sender == market, 'must be market');
        require(_royalties <= _maxRoyalties, 'must be <= the max');
        address[] memory nfts;
        collections.push(Collection({owner: _requestor, treasury: _treasury, royalties: _royalties, nfts: nfts, createBlock: block.number}));
        uint256 id = collections.length - 1;
        metadata[id]['name'] = _name;
        userCollections[_requestor].push(id);
        emit PopulateCollection(id, _requestor, metadata[id]['name'], _treasury, _royalties);
    }

    // Function for the collection owner to transfer ownership to another wallet
    function transferCollectionOwnership(uint _id, address _newOwner, address _requestor) public override {
        require(msg.sender == market, 'must be market');
        Collection storage info = collections[_id];
        require(info.owner == _requestor, 'must be owner');
        
        for (uint i = 0; i < userCollections[_requestor].length; i++) {
            if (userCollections[_requestor][i] == _id) {
                userCollections[_requestor][i] = userCollections[_requestor][userCollections[_requestor].length - 1];
                userCollections[_requestor].pop();
            }
        }

        info.owner = _newOwner;
        userCollections[_newOwner].push(_id);
        emit TransferCollectionOwnership(_id, _newOwner);
    }

    // Function for updating a collections details
    function updateCollection(uint _id, string memory _name, address _treasury, uint _royalties, uint _maxRoyalties, address _requestor) public override {
        require(msg.sender == market, 'must be market');
        Collection storage info = collections[_id];
        require(info.owner == _requestor, 'must be owner');
        require(_royalties <= _maxRoyalties, 'must be <= the max');
        info.treasury = _treasury;
        info.royalties = _royalties;
        metadata[_id]['name'] = _name;
        emit PopulateCollection(_id, _requestor, metadata[_id]['name'], _treasury, _royalties);
    }

    // Function for adding a NFT to a collection
    function addNftToCollection(uint _id, address _nft, address _requestor) public override {
        require(msg.sender == market, 'must be market');
        Collection storage collection = collections[_id];
        require(collection.owner == _requestor && (nftModerators[_nft] == _requestor || INft(_nft).owner() == _requestor), 'must be owner');
        NftCollectionInfo storage info = nftCollectionInfo[_nft];
        require(!info.inCollection, 'already belongs to a collection');
        collection.nfts.push(_nft);
        info.collectionId = _id;
        info.inCollection = true;
        info.index = collection.nfts.length - 1;
        emit AddNftToCollection(_id, info.index, _nft);
    }

    // Function for removing an NFT from a collection
    function removeNftFromCollection(address _nft, address _requestor) public override {
        require(msg.sender == market, 'must be market');
        NftCollectionInfo storage info = nftCollectionInfo[_nft];
        require(info.inCollection, 'does not belong to a collection');
        require(collections[nftCollectionInfo[_nft].collectionId].owner == _requestor, 'must be owner');

        address[] storage nfts = collections[info.collectionId].nfts;
        address lastNft = nfts[nfts.length - 1];
        nfts[info.index] = lastNft;
        nfts.pop();
        nftCollectionInfo[lastNft].index = info.index;

        emit RemoveNftFromCollection(info.collectionId, info.index, _nft);

        info.inCollection = false;
        info.index = 0;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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

    function _msgData() internal view virtual returns ( bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
    constructor()  {
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

/*
 *  Oblivion :: NFT Market Objects
 *
 *  This file contains objects that are used between multiple market contracts.
 *
 *  SPDX-License-Identifier: MIT
 */

pragma solidity ^0.8.4;

// This struct holds the details of a NFT collection
struct Collection {
    address[] nfts;                 // Array of addressed for the NFTs that belong to this collection
    address owner;                  // The address of the owner of the collection
    address treasury;               // The address that the royalty payments should be sent to
    uint royalties;                 // The percentage of royalties that should be collected
    uint createBlock;               // The block that the collection was created
}

// This struct is used to reference an NFT address to the collection it belongs to
struct NftCollectionInfo {
    uint collectionId;              // The ID of the collection this NFT belongs to
    uint index;                     // The index of the collection array where this NFT is
    bool inCollection;              // Flag tracking if this NFT is part of a collection
}

/*
 *  Oblivion :: NFT Market Interfaces
 *
 *  This contract defines the interfaces that the NFT market contract uses to interface with other contracts.
 *  Some of these are abridged versions of standard interfaces in order to save contract size.
 *
 *  SPDX-License-Identifier: MIT
 */

pragma solidity ^0.8.4;

import "./NftMarketObjects.sol";

/*
 *  Interface for interacting with a NFT
 */
interface INft {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
    function owner() external view returns (address);
}

/*
 *  Interface for interacting with a BEP20 token
 */
interface IToken {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

/*
 *  Interface for interacting with a PCS compatible DEX router
 */
interface IDexRouter {
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function WETH() external pure returns (address);
}

/*
 *  Interface for interacting with the rebates contract
 */
interface IRebates {
    function addUserRebate(address _user, uint _amount) external;
}

/*
 *  Interface for interacting with the discounts contract
 */
interface IDiscount {
    function isApplicable(address _user) external view returns (bool);
}

/*
 *  Interface for interacting with the collection contract
 */
interface ICollection {
    function totalCollections() external view returns (uint);
    function totalCollectionNfts(uint _collection) external view returns (uint);
    function totalUserCollections(address _user) external view returns (uint);
    function collectionNfts(uint _collection) external view returns (address[] memory);
    function setModerator(address _nft, address _moderator, address _requester) external;
    function nftModerators(address _nft) external view returns (address);
    function nftInfo(address _nft) external view returns (NftCollectionInfo memory);
    function getCollection(uint _id) external view returns (Collection memory);
    function userCollections(address _user, uint _index) external view returns(uint);
    function createCollection(string memory _name, address _treasury, uint _royalties, uint _maxRoyalties, address _requestor) external;
    function transferCollectionOwnership(uint _id, address _newOwner, address _requestor) external;
    function updateCollection(uint _id, string memory _name, address _treasury, uint _royalties, uint _maxRoyalties, address _requestor) external;
    function addNftToCollection(uint _id, address _nft, address _requestor) external;
    function removeNftFromCollection(address _nft, address _requestor) external;
    function setOwnerLockout(address _nft, bool _lockedOut, address _requester) external;
    function setMetadata(uint _id, string[] memory _keys, string[] memory _values, address _requester) external;
    function getMetadata(uint _id, string memory _key) external view returns (string memory);
}