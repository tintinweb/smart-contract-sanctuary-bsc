// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./IMarketAccessManagerV2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MarketAccessManagerV2 is IMarketAccessManagerV2, Ownable {
    struct NFTAccess {
        mapping(bytes32 => mapping(address => bool)) whilelists;
        bool valid;
    }

    mapping(address => NFTAccess) NFTAccesses;

    function setNFT(address[] memory _nfts, bool[]memory _valids) external onlyOwner {
        require(_nfts.length == _valids.length, "Error: input inlivad");
        
        for (uint8 i = 0; i < _nfts.length; i++){
            require(_nfts[i] != address(0), "Error: NFT address(0)");
            NFTAccesses[_nfts[i]].valid = _valids[i];
        }
        
    }

    function setWhilelist(
        address _nft,
        bytes32[] memory _roles,
        address[] memory _tos,
        bool[] memory _whilelists
    ) external onlyOwner {
        require(NFTAccesses[_nft].valid, "Error: NFT invalid");
        require(_roles.length == _tos.length, "Error: input invalid");
        require(_roles.length == _whilelists.length, "Error: input invalid");

        for (uint8 i = 0; i < _roles.length; i++) {
            NFTAccesses[_nft].whilelists[_roles[i]][_tos[i]] = _whilelists[i];
        }
    }

    function isAllowed(
        address _nft,
        uint256 _nftId,
        bytes32 _role,
        address _caller
    ) external view override returns (bool) {
        return
            NFTAccesses[_nft].whilelists[_role][address(0)] || // public all
            NFTAccesses[_nft].whilelists[_role][_caller];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface IMarketAccessManagerV2 {
    function isAllowed(
        address _nft,
        uint256 _nftId,
        bytes32 _role,
        address _caller
    ) external view returns (bool);
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