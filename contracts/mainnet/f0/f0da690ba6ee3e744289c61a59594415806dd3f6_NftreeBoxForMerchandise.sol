/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

// SPDX-License-Identifier: --🌲--

pragma solidity ^0.8.0;

// Get a link to NFT contract
interface NFT {
  // Transfer Nftree
  function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

// Get a link to whitelist manager contract
interface IWhitelist {
  // Returns `true` if address is whitelisted
  function isWhitelisted(address user) external returns(bool);
}

/**
 * @title NftreeBox Merchandise Version 1.0
 *
 * @author Treedefi
 */
contract NftreeBoxForMerchandise {
  //---sell parameters---//
  uint256 public price;
  uint256 public specialPrice;
  uint16 public nftPerBox;

  //---Set of addresses---//
  address public admin;
  address public immutable treasury;
  address public immutable nftContract;
  address public immutable whitelistManager;

  // List of trees offered via Nftreebox
  uint256[] public trees;

  /**
   * @dev Fired in configSell()
   *
   * @param _by an address who executes the function
   * @param _nftPerBox number of NFTs offered per box 
   * @param _mintPrice minting price per box
   * @param _specialMintPrice minting price for whitelisted users per box
   */
  event Configured(
    address indexed _by,
    uint16 _nftPerBox,
    uint256 _mintPrice,
    uint256 _specialMintPrice
  );

  /**
   * @dev Fired in buy()
   *
   * @param _by an address who executes the function
   * @param _amount number of nftreebox bought
   * @param _price amount paid by an address to buy given amount of boxes 
   */
  event Bought(
    address indexed _by,
    uint16 _amount,
    uint256 _price
  );

  /**
   * @dev Fired in transferAdminship() when ownership is transferred
   *
   * @param _previousAdmin an address of previous owner
   * @param _newAdmin an address of new owner
   */
  event AdminshipTransferred(address indexed _previousAdmin, address indexed _newAdmin);

  /**
   * @dev Creates/deploys NftreeBox Merchandise Version 1.0
   *
   * @param admin_ address of admin
   * @param treasury_ address of treasury
   * @param nftContract_ address of treedefi collectibles smart contract
   * @param whitelist_ address of whitelist manager contract
   */
  constructor(
      address admin_,
      address treasury_,
      address nftContract_,
      address whitelist_
    )
  {
    //---Setup smart contract internal state---//
    admin = admin_;
    treasury = treasury_;
    nftContract = nftContract_;
    whitelistManager = whitelist_;
  }

  /**
   * @dev Transfer adminship to given address
   *
   * @notice restricted function, should be called by admin only
   * @param newAdmin_ address of new owner
   */
  function transferAdminship(address newAdmin_) external {
    require(msg.sender == admin, "Only admin can transfer ownership");

    // Update admin address
    admin = newAdmin_;
    
    // Emits an event
    emit AdminshipTransferred(msg.sender, newAdmin_);
  }

  /**
   * @dev Configure sell parameters
   *
   * @param nftPerBox_ number of NFTs offered per box 
   * @param mintPrice_ minting price per box
   * @param specialMintPrice_ minting price for whitelisted users per box
   */
  function configSell(
      uint16 nftPerBox_,
      uint256 mintPrice_,
      uint256 specialMintPrice_
    )
    external
  {
    require(msg.sender == admin, "Only admin can configure sell");

    // Set up sell parameters
    nftPerBox = nftPerBox_;
    price = mintPrice_;
    specialPrice = specialMintPrice_;

    // Emits an event
    emit Configured(msg.sender, nftPerBox_, mintPrice_, specialMintPrice_);  
  }

  /**
   * @dev Buys nftreeBox by paying price set by an admin 
   * 
   * @param amount_ number preSaleBox to buy
   */
  function buy(uint16 amount_) external payable {    
    require(msg.value >= price * amount_ && amount_ > 0, "Must send correct price");

    require(amount_ * nftPerBox <= trees.length, "Not enough trees left");

    // Transfer proceedings to treasury address
    payable(treasury).transfer(msg.value);

    // Get index
    uint256 _index = trees.length - 1;

    for(uint i=0; i < amount_ * nftPerBox; i++) {
      // Transfer Nftree to user
      NFT(nftContract).transferFrom(address(this), msg.sender, trees[_index - i]);

      // Remove element from tree list
      trees.pop();
    }

    // Emits an event
    emit Bought(msg.sender, amount_, msg.value);
  }

  /**
   * @dev Buys nftreeBox by paying spaecial price set by an admin 
   * 
   * @param amount_ number preSaleBox to buy
   */
  function buyAtSpecialPrice(uint16 amount_) external payable {
    require(msg.value >= specialPrice * amount_ && amount_ > 0, "Must send correct price");

    require(amount_ * nftPerBox <= trees.length, "Not enough trees left");

    require(IWhitelist(whitelistManager).isWhitelisted(msg.sender), "Not whitelisted");

    // Transfer proceedings to treasury address
    payable(treasury).transfer(msg.value);
    
    // Get index
    uint256 _index = trees.length - 1;

    for(uint i=0; i < amount_ * nftPerBox; i++) {
      // Transfer Nftree to user
      NFT(nftContract).transferFrom(address(this), msg.sender, trees[_index - i]);

      // Remove element from tree list
      trees.pop();
    }

    // Emits an event
    emit Bought(msg.sender, amount_, msg.value);
  }

  /**
   * @dev Deposits nftrees
   *
   * @param tokenId_ tokenId of trees to be deposited
   */
  function depositTokens(uint256[] memory tokenId_) external {    
    for(uint i; i < tokenId_.length; i++) {
      // transfer nftrees to box contract 
      NFT(nftContract).transferFrom(msg.sender, address(this), tokenId_[i]);

      // Update tree list
      trees.push(tokenId_[i]);
    }
  }

  /**
   * @dev Withdraw nftrees
   *
   * @param index_ Index of tree to be withdrawn
   */
  function withdrawTokens(uint256[] memory index_) external {
    require(msg.sender == admin, "Only admin can withdraw nftrees");

    for(uint i; i < index_.length; i++) {
      // Transfer nftree to admin
      NFT(nftContract).transferFrom(address(this), admin, trees[index_[i]]);

      // Update tree list
      trees[index_[i]] = trees[trees.length - 1];

      // Remove element from tree list
      trees.pop();
    }      
  }

  /**
   * @dev Withdraw Funds
   */
  function withdraw() external {
    require(msg.sender == admin, "Only admin can withdraw funds");

	  // Value to send
	  uint256 _value = address(this).balance;

	  // verify balance is positive (non-zero)
	  require(_value > 0, "zero balance");

	  // send the entire balance to the transaction sender
	  payable(admin).transfer(_value);
  }

  /**
   * @dev Returns number of trees available via nftreebox
   */
  function treesLength() external view returns(uint256) {
    return trees.length;
  }
}