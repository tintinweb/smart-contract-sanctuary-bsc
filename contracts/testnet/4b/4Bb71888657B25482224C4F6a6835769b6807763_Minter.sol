/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// SPDX-License-Identifier: MIT
// Sources flattened with hardhat v2.9.6 https://hardhat.org

// File contracts/utils/ApprovalsGuard.sol

pragma solidity ^0.8.4;

abstract contract ApprovalsGuard {
  // Mapping of approved address to write storage
  mapping(address => bool) private _approvals;
  address internal owner;

  constructor() {
    owner = msg.sender;
  }

  // Modifier to allow only approvals to execute methods
  modifier onlyApprovals() {
    require(_approvals[msg.sender], "You are not allowed to execute this method");
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "You are not allowed to execute this method");
    _;
  }

  modifier onlyApprovalsOrOwner() {
    require((msg.sender == owner || _approvals[msg.sender]), "You are not allowed to execute this method");
    _;
  }

  function setApproval(address approveAddress, bool approved) public onlyOwner {
    require(msg.sender == owner, "You are not allowed to execute this function");
    _approvals[approveAddress] = approved;
  }
}

// File contracts/ERC721OA/IERC721Royalties.sol

pragma solidity ^0.8.4;

interface IERC721Royalties {
  function createToken(string memory tokenURI) external returns (uint256);

  function createToken(
    string memory tokenURI,
    uint256 royaltiesPercent,
    address royaltiesReceiver
  ) external returns (uint256);

  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external;
}

// File contracts/NFTMarketOA/StorageOA/IStorageOATrusted.sol

pragma solidity ^0.8.4;

interface IStorageOA {
  function trustedCreateItem(
    address nftContract,
    uint256 tokenId,
    bool isActive,
    address ownerItem,
    bool onSale,
    bool onAuction,
    uint256 endTime,
    address currency,
    uint256 price,
    address highestBidder,
    uint256 highestBid
  ) external;
}

// File contracts/Minter/Minter.sol

pragma solidity ^0.8.4;

contract Minter is ApprovalsGuard {
  address private _minterWallet;
  address private _storage;
  address private _adminWallet;

  constructor(
    address minterWallet,
    address storageAddress,
    address adminWallet
  ) {
    _minterWallet = minterWallet;
    _storage = storageAddress;
    _adminWallet = adminWallet;
    setApproval(minterWallet, true);
  }

  struct MintData {
    address contractAddress;
    string urlAsset;
    bool onSale;
    bool onAuction;
    bool isActive;
    uint256 endTime;
    address currency;
    uint256 price;
    address highestBidder;
    uint256 highestBid;
    address royaltiesReceiver;
    uint256 royaltiesPercent;
    bool useRoyalties;
  }

  function mint(MintData memory mintData) external onlyApprovals {
    IERC721Royalties erc721 = IERC721Royalties(mintData.contractAddress);
    uint256 tokenId;
    if (mintData.useRoyalties) {
      tokenId = erc721.createToken(mintData.urlAsset, mintData.royaltiesPercent, mintData.royaltiesReceiver);
    } else {
      tokenId = erc721.createToken(mintData.urlAsset);
    }
    IStorageOA(_storage).trustedCreateItem(
      mintData.contractAddress,
      tokenId,
      mintData.isActive,
      _adminWallet,
      mintData.onSale,
      mintData.onAuction,
      mintData.endTime,
      mintData.currency,
      mintData.price,
      mintData.highestBidder,
      mintData.highestBid
    );
    erc721.transferFrom(address(this), _storage, tokenId);
  }

  /* Events from external contracts */
  event ItemCreated(uint256 indexed itemId, address indexed nftContract, uint256 indexed tokenId, address owner);
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
}