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
import "./interfaces/IPriceConsumerV3.sol";
import "./utils/ReentrancyGuard.sol";

contract NftMarketCollectionManager is Ownable, ICollection, ReentrancyGuard {
    address payable                         public treasury;            // The treasury address for sending fees
    uint                                    public maxRoyalties = 1000; // Maximum royalites
    uint                                    public createFee;           // The fee for creating a collection
    IPriceConsumerV3                        public priceConsumer;       // The price consumer
    Collection[]                            public collections;         // Array storing all of the collections
    mapping(address => NftCollectionInfo)   public nftCollectionInfo;   // Mapping that returns the collection id of an nft
    mapping(address => address)             public nftModerators;       // Mapping to store a list of moderators who have the power to add a NFT to a collection
    mapping(address => uint[])              public userCollections;     // Mapping to store references to a user's collections
    mapping(address => bool)                public ownerLockout;        // Mapping to store if NFT owner has locked market owner from setting moderator
    mapping(address => bool)                public feeWhitelist;        // Mapping to store addresses that are exempt from collection creation fee
    
    mapping(uint => mapping(string => string)) public metadata;         // Mapping that stores metadata information for a collection

    // Constructor for initialzing the contract values
    constructor (address _treasury, address _priceConsumer, uint _createFee) {
        treasury = payable(_treasury);
        priceConsumer = IPriceConsumerV3(_priceConsumer);
        createFee = _createFee;
    }

    // Events for sending notifications when things happen
    event SetModerator(address indexed nft, address indexed newModerator);
    event PopulateCollection(uint indexed id, address indexed owner, string name, address treasury, uint royalties);
    event TransferCollectionOwnership(uint indexed id, address indexed newOwner);
    event AddNftToCollection(uint indexed id, uint index, address nft);
    event RemoveNftFromCollection(uint indexed id, uint index, address nft);

    // Functions for reading contract data
    function totalCollections() public view returns (uint) { return collections.length; }
    function totalCollectionNfts(uint _collection) public view returns (uint) { return collections[_collection].nfts.length; }
    function collectionNfts(uint _collection) public view returns (address[] memory) { return collections[_collection].nfts; }
    function nftInfo(address _nft) public override view returns (NftCollectionInfo memory) { return nftCollectionInfo[_nft]; }
    function getCollection(uint _id) public override view returns (Collection memory) { return collections[_id]; }
    function totalUserCollections(address _user) public view returns (uint) { return userCollections[_user].length; }
    function feeInBnb() public view returns (uint) { return priceConsumer.usdToBnb(createFee); }

    // Function to set the treasury address
    function setTreasury(address _treasury) public onlyOwner() { treasury = payable(_treasury); }

    // Function to set the price consumer
    function setPriceConsumer(address _priceConsumer) public onlyOwner() { priceConsumer = IPriceConsumerV3(_priceConsumer); }

    // Function to set the create fee
    function setCreateFee(uint _fee) public onlyOwner() { createFee = _fee; }

    // Function to set the whitelist state for an address
    function setFeeWhitelist(address _wallet, bool _whitelisted) public onlyOwner() { feeWhitelist[_wallet] = _whitelisted; }

    // Function to set the moderator of a NFT contract from the NFT contract owner plus allows the NFT market contract owner to set the
    // moderator for instances where the NFT contract has been renounced and the team has manually verified to our team they own the contract
    function setModerator(address _nft, address _moderator) public {
        require(INft(_nft).owner() == msg.sender || (msg.sender == owner() && !ownerLockout[_nft]), 'must be owner');
        nftModerators[_nft] = _moderator;
        emit SetModerator(_nft, _moderator);
    }

    // Function for an NFT owner to set a block preventing market contract owner from setting moderator flag
    function setMarketOwnerRevoked(address _nft, bool _lockedOut) public {
        require(INft(_nft).owner() == msg.sender, 'must be owner');
        ownerLockout[_nft] = _lockedOut;
    }

    // Function to set a metadata field for a collection
    function setMetadata(uint _id, string[] memory _keys, string[] memory _values) public {
        require(collections[_id].owner == msg.sender, 'must be owner');
        require(_keys.length > 0, 'no metadata provided');
        require(_keys.length == _values.length, 'parameters failure');
        for (uint i = 0; i < _keys.length; i++) metadata[_id][_keys[i]] = _values[i];
    }

    // Function to get a metadata field for a collection
    function getMetadata(uint _id, string memory _key) public view returns (string memory) {
        return metadata[_id][_key];
    }

    // Function for creating a collection
    function createCollection(string memory _name, address _treasury, uint _royalties) public payable nonReentrant() {
        require(_royalties <= maxRoyalties, 'must be <= the max');
        address[] memory nfts;
        collections.push(Collection({owner: msg.sender, treasury: _treasury, royalties: _royalties, nfts: nfts, createBlock: block.number}));
        uint256 id = collections.length - 1;
        metadata[id]['name'] = _name;
        userCollections[msg.sender].push(id);

        if (!feeWhitelist[msg.sender]) {
            require(msg.value == feeInBnb(), 'insufficient BNB for fee');
            _safeTransfer(treasury, msg.value);
        }

        emit PopulateCollection(id, msg.sender, metadata[id]['name'], _treasury, _royalties);
    }

    // Function for the collection owner to transfer ownership to another wallet
    function transferCollectionOwnership(uint _id, address _newOwner) public {
        Collection storage info = collections[_id];
        require(info.owner == msg.sender, 'must be owner');
        
        for (uint i = 0; i < userCollections[msg.sender].length; i++) {
            if (userCollections[msg.sender][i] == _id) {
                userCollections[msg.sender][i] = userCollections[msg.sender][userCollections[msg.sender].length - 1];
                userCollections[msg.sender].pop();
            }
        }

        info.owner = _newOwner;
        userCollections[_newOwner].push(_id);
        emit TransferCollectionOwnership(_id, _newOwner);
    }

    // Function for updating a collections details
    function updateCollection(uint _id, string memory _name, address _treasury, uint _royalties) public {
        Collection storage info = collections[_id];
        require(info.owner == msg.sender, 'must be owner');
        require(_royalties <= maxRoyalties, 'must be <= the max');
        info.treasury = _treasury;
        info.royalties = _royalties;
        metadata[_id]['name'] = _name;
        emit PopulateCollection(_id, msg.sender, metadata[_id]['name'], _treasury, _royalties);
    }

    // Function for adding a NFT to a collection
    function addNftToCollection(uint _id, address _nft) public {
        Collection storage collection = collections[_id];
        require(collection.owner == msg.sender && (nftModerators[_nft] == msg.sender || INft(_nft).owner() == msg.sender), 'must be owner');
        NftCollectionInfo storage info = nftCollectionInfo[_nft];
        require(!info.inCollection, 'already belongs to a collection');
        collection.nfts.push(_nft);
        info.collectionId = _id;
        info.inCollection = true;
        info.index = collection.nfts.length - 1;
        emit AddNftToCollection(_id, info.index, _nft);
    }

    // Function for removing an NFT from a collection
    function removeNftFromCollection(address _nft) public {
        NftCollectionInfo storage info = nftCollectionInfo[_nft];
        require(info.inCollection, 'does not belong to a collection');
        require(collections[nftCollectionInfo[_nft].collectionId].owner == msg.sender || nftModerators[_nft] == msg.sender || INft(_nft).owner() == msg.sender, 'must be owner');

        address[] storage nfts = collections[info.collectionId].nfts;
        address lastNft = nfts[nfts.length - 1];
        nfts[info.index] = lastNft;
        nfts.pop();
        nftCollectionInfo[lastNft].index = info.index;

        emit RemoveNftFromCollection(info.collectionId, info.index, _nft);

        info.inCollection = false;
        info.index = 0;
    }

    // Function to safely transfer BNB to an address
    function _safeTransfer(address _recipient, uint _amount) private {
        (bool _success,) = _recipient.call{value : _amount}("");
        require(_success, "transfer failed");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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

interface IPriceConsumerV3 {
    function getLatestPrice() external view returns (uint);
    function unlockFeeInBnb(uint) external view returns (uint);
    function usdToBnb(uint) external view returns (uint);
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
    function nftInfo(address _nft) external view returns (NftCollectionInfo memory);
    function getCollection(uint _id) external view returns (Collection memory);    
}