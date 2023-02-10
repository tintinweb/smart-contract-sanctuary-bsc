// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
pragma solidity ^0.8.4;


interface IWishlist {
    event WishAdded(address indexed user, string indexed wish);

    function baseNode() external view returns (bytes32);

    function wishCounts(bytes32 namehash) external view returns (uint256);

    function addWishes(string[] memory name) external;

    function needAuction(string memory name) external view returns (bool);

    function userWishes(address user) external view returns (string[] memory);

    function userHasWish(address user, string memory name) external view returns (bool);

    // Dev side will add some globally reserved domains to let all users be able to join the 
    // auction for the added domains
    function addReservedNames(string[] memory names) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../cidregistrar/StringUtils.sol";
import "./IWishlist.sol";

contract Wishlist is Ownable, IWishlist {
    using StringUtils for *;

    mapping (bytes32 => uint256) override public wishCounts;

    mapping (address => string[]) public wishes;

    bytes32 override public baseNode;

    // wish list limit per user
    uint256 public wishCap;

    // wishlist phrase period
    uint256 public wishPhraseStart;
    uint256 public wishPhraseEnd;

    // reserved names for global auction, token id => availability
    mapping (bytes32 => bool) public reservedNameMap;
    string[] public reservedNames;

    constructor(uint256 wishCap_, uint256 wishPhraseStart_, uint256 wishPhraseEnd_, bytes32 baseNode_) {
        setWishCap(wishCap_);
        setWishPhraseTime(wishPhraseStart_, wishPhraseEnd_);
        setBaseNode(baseNode_);
    }

    function setWishCap(uint256 wishCap_) public onlyOwner {
        require(wishCap_ > 0, "invalid parameters");
        wishCap = wishCap_;
    }

    function setWishPhraseTime(uint256 wishPhraseStart_, uint256 wishPhraseEnd_) public onlyOwner {
        require(wishPhraseStart_ > 0 && wishPhraseStart_ < wishPhraseEnd_, "invalid parameters");
        wishPhraseStart = wishPhraseStart_;
        wishPhraseEnd = wishPhraseEnd_;
    }

    function setBaseNode(bytes32 baseNode_) public onlyOwner {
        require(baseNode_ != bytes32(0), "invalid parameters");
        baseNode = baseNode_;
    }

    function blocktime() public view returns (uint) {
        return block.timestamp;
    } 

    function addWishes(string[] memory names) override external {
        require(block.timestamp > wishPhraseStart && block.timestamp < wishPhraseEnd, "not wishlist phrase");
        for (uint256 i = 0; i < names.length; ++i) {
            addWish_(names[i]);
        }
    }

    // note: name is label name without suffix
    function addWish_(string memory name) internal {
        // empty name not allowed
        require(name.strlen() > 0, "empty name");

        bytes32 namehash = keccak256(bytes(name));
        require(wishes[msg.sender].length < wishCap, "exceed wish cap");

        // duplicated wish is not allowed
        string[] storage names = wishes[msg.sender];
        for (uint256 i = 0; i < names.length; i++) {
            require(keccak256(bytes(names[i])) != namehash, "duplicated wish"); 
        }

        wishes[msg.sender].push(name);
        wishCounts[namehash]++;
        emit WishAdded(msg.sender, name);
    }

    // if more than 1 user wished this name, this name need auction
    function needAuction(string memory name) override external view returns (bool) {
        return wishCounts[keccak256(bytes(name))] > 1;
    }

    function userWishes(address user) override external view returns (string[] memory) {
        return wishes[user];
    }

    function userHasWish(address user, string memory name) override public view returns (bool) {
        bytes32 namehash = keccak256(bytes(name));
        string[] storage names = wishes[user];
        for (uint256 i = 0; i < names.length; i++) {
            if(keccak256(bytes(names[i])) == namehash) {
                return true;
            }
        }
        return false;
    }

    function addReservedNames(string[] memory names) override external onlyOwner {
        for (uint256 i = 0; i < names.length; ++i) {
            bytes32 namehash = keccak256(bytes(names[i]));
            require(!reservedNameMap[namehash], "duplicated name");
            reservedNameMap[namehash] = true;
            reservedNames.push(names[i]);
        }
    }

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

library StringUtils {
    /**
     * @dev Returns the length of a given string
     *
     * @param s The string to measure the length of
     * @return The length of the input string
     */
    function strlen(string memory s) internal pure returns (uint) {
        uint len;
        uint i = 0;
        uint bytelength = bytes(s).length;
        for(len = 0; i < bytelength; len++) {
            bytes1 b = bytes(s)[i];
            if(b < 0x80) {
                i += 1;
            } else if (b < 0xE0) {
                i += 2;
            } else if (b < 0xF0) {
                i += 3;
            } else if (b < 0xF8) {
                i += 4;
            } else if (b < 0xFC) {
                i += 5;
            } else {
                i += 6;
            }
        }
        return len;
    }
}