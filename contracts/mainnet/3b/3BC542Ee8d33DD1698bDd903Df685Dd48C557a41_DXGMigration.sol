// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IDXGNFTOld.sol";
import "./interfaces/IERC721TokenCreator.sol";

contract DXGMigration is Ownable {
  IDXGNFTOld private oldNftContract;
  IERC721TokenCreator private newNftContract;

  // Struct of the NFT for migration
  struct Token {
    uint256 tokenId;
    string tokenUri;
  }

  event MigrateToken(
    uint256 newId,
    uint256 oldId,
    string tokenUri,
    IDXGNFTOld.NFT_TYPE nftType,
    address creator,
    bool listed,
    uint256 royalty,
    uint256 price,
    uint256 minBidPrice,
    uint256 startTimestamp,
    uint256 endTimestamp
  );

  constructor(address _oldNftContractAddress, address _newNftContractAddress) {
    oldNftContract = IDXGNFTOld(_oldNftContractAddress);
    newNftContract = IERC721TokenCreator(_newNftContractAddress);
  }

  function migrateTokens(Token[] memory tokens) external {
    for(uint i = 0; i < tokens.length; i++) {
      _migrateToken(tokens[i]);
    }
  }

  function _migrateToken(Token memory token) internal {
    (
      IDXGNFTOld.NFT_TYPE nftType,
      address creator,
      bool listed,
      uint256 royalty,
      uint256 price,
      uint256 minBidPrice,
      uint256 startTimestamp,
      uint256 endTimestamp
    ) = oldNftContract.mapNFTAttribute(token.tokenId);

    uint256 newId = newNftContract.mint(msg.sender, token.tokenUri, royalty);
    oldNftContract.transferFrom(msg.sender, owner(), token.tokenId);

    emit MigrateToken(
      newId,
      token.tokenId,
      token.tokenUri,
      nftType,
      creator,
      listed,
      royalty,
      price,
      minBidPrice,
      startTimestamp,
      endTimestamp
    );
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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IDXGNFTOld {
  enum NFT_TYPE {NONE, FIXED_PRICE, AUCTION, UNLIMITED_AUCTION}

  function mapNFTAttribute(uint256 tokenId) external view returns (
    NFT_TYPE nftType,
    address creator,
    bool listed,
    uint256 royalty,
    uint256 price,
    uint256 minBidPrice,
    uint256 startTimestamp,
    uint256 endTimestamp
  );

  function tokenURI(uint256 tokenId) external view returns (string memory);

  function transferFrom(address from, address to, uint256 tokenId) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

/**
 * @dev Interface of extension of the ERC721 standard to allow `creator` method.
 */
interface IERC721TokenCreator {
    /**
     * @dev Returns the creator of tokens in existence.
     */
    function creator(uint256 tokenId) external view returns(address);

    /**
     * @dev Returns the royalty of tokens in existence.
     */
    function royalty(uint256 tokenId) external view returns(uint256);

    /**
     * @notice Safely mints new token and sets its `_tokenURI`.
     *
     * Emits a {Transfer} event.
     */
    function mint(address to, string memory _tokenURI, uint256 _royalty) external returns (uint256);
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