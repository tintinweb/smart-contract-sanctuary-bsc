/**
 *Submitted for verification at BscScan.com on 2022-05-12
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

// Get a link to BEP20 token contract
interface BEP20 {
  // Transfer tokens on behalf
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  ) external returns (bool success);

  // Transfer tokens
  function transfer(
    address _to,
    uint256 _value
  ) external returns (bool success);
}

// Get a link to random feed contract
interface IRandomFeed {
  // Get random number
  function getRandomFeed(uint256 salt, uint256 length) external returns(uint256 index);
}

/**
 * @title NftreeBox Version 2.0
 *
 * @author Treedefi
 */
contract NftreeBoxV2_1 {
  //---sell parameters---//
  uint256 public price;
  uint256 public specialPrice;
  uint16 public nftPerBox;
  address public paymentToken;

  //---Set of addresses---//
  address public admin;
  address public immutable treasury;
  address public immutable nftContract;
  address private randomFeed;

  // List of trees offered via Nftreebox
  uint256[] public trees;

  // Mapping from address to whitelist  
  mapping(address => bool) public isWhitelisted;

  /**
   * @dev Fired in configSell()
   *
   * @param _by an address who executes the function
   * @param _nftPerBox number of NFTs offered per box 
   * @param _mintPrice minting price per box
   * @param _specialMintPrice minting price for whitelisted users per box
   * @param _paymentToken address of BEP20 token in which payment will be accepted
   */
  event Configured(
    address indexed _by,
    uint16 _nftPerBox,
    uint256 _mintPrice,
    uint256 _specialMintPrice,
    address _paymentToken
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
   * @dev Fired in addToWhitelist() and removeFromWhitelist() when address is added into/removed from
   *      whitelist
   *
   * @param account an address of user
   * @param isAllowed defines if address is added or removed
   */
    event Whitelist(address account, bool isAllowed);

  /**
   * @dev Creates/deploys NftreeBox Version 2.0
   *
   * @param admin_ address of admin
   * @param treasury_ address of treasury
   * @param nftContract_ address of treedefi collectibles smart contract
   * @param paymentToken_ address of BEP20 token in which payment will be accepted
   * @param randomFeed_ address of randomFeed contract
   */
  constructor(
      address admin_,
      address treasury_,
      address nftContract_,
      address paymentToken_,
      address randomFeed_
    )
  {
    //---Setup smart contract internal state---//
    admin = admin_;
    treasury = treasury_;
    nftContract = nftContract_;
    paymentToken = paymentToken_;
    randomFeed = randomFeed_;
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
   * @param paymentToken_ address of BEP20 token in which payment will be accepted
   */
  function configSell(
      uint16 nftPerBox_,
      uint256 mintPrice_,
      uint256 specialMintPrice_,
      address paymentToken_
    )
    external
  {
    require(msg.sender == admin, "Only admin can configure sell");

    // Set up sell parameters
    nftPerBox = nftPerBox_;
    price = mintPrice_;
    specialPrice = specialMintPrice_;
    paymentToken = paymentToken_;

    // Emits an event
    emit Configured(msg.sender, nftPerBox_, mintPrice_, specialMintPrice_, paymentToken_);  
  }
  
  /**
   * @dev Sets random feed contract address
   * 
   * @param randomFeed_ random feed contract address
   */
  function setRandomFeedAddress(address randomFeed_)
    external
  {
    require(msg.sender == admin, "Only admin can set randomFeed");
    
    // Set randomFeed address
    randomFeed = randomFeed_;
  }

  /**
   * @dev Adds addresses to whitelist 
   *
   * @notice restricted function, should be called by owner only
   * @param allowed_ address list that will be added to the whitelist
   */
  function addToWhitelist(address[] memory allowed_) external {
    require(msg.sender == admin, "Access denied");

    for(uint8 i; i < allowed_.length; i++) {
        // Add address to the list
        isWhitelisted[allowed_[i]] = true;

        // Emit an event
        emit Whitelist(allowed_[i], true);
    }
  }

  /**
   * @dev Removes addresses from whitelist
   *
   * @notice restricted function, should be called by owner only
   * @param notAllowed_ address list that will be removed from the whitelist
   */
  function removeFromWhitelist(address[] memory notAllowed_) external {
    require(msg.sender == admin, "Access denied");

    for(uint8 i; i < notAllowed_.length; i++) {
        // Remove address from the list
        isWhitelisted[notAllowed_[i]] = false;

        // Emit an event
        emit Whitelist(notAllowed_[i], false);
    }
  }

  /**
   * @dev Buys nftreeBox by paying price set by an admin 
   * 
   * @param amount_ number preSaleBox to buy
   */
  function buy(uint16 amount_) external {    
    require(amount_ > 0, "Invalid amount");

    require(amount_ * nftPerBox <= trees.length, "Not enough trees left");

    // Transfer proceedings to treasury address
    BEP20(paymentToken).transferFrom(msg.sender, treasury, price * amount_);

    // Get random index
    uint256 _index = IRandomFeed(randomFeed).getRandomFeed(trees.length, trees.length);

    // Bound index
    _index = (_index < amount_ * nftPerBox - 1) ? amount_ * nftPerBox - 1 : _index;

    for(uint i=0; i < amount_ * nftPerBox; i++) {
      // Transfer Nftree to user
      NFT(nftContract).transferFrom(address(this), msg.sender, trees[_index - i]);

      // Update tree list
      trees[_index - i] = trees[trees.length - 1];

      // Remove element from tree list
      trees.pop();
    }

    // Emits an event
    emit Bought(msg.sender, amount_, price * amount_);
  }

  /**
   * @dev Buys nftreeBox by paying spaecial price set by an admin 
   * 
   * @param amount_ number preSaleBox to buy
   */
  function buyAtSpecialPrice(uint16 amount_) external {
    require(amount_ > 0, "Invalid amount");

    require(amount_ * nftPerBox <= trees.length, "Not enough trees left");

    require(isWhitelisted[msg.sender], "Not whitelisted");

    // Transfer proceedings to treasury address
    BEP20(paymentToken).transferFrom(msg.sender, treasury, specialPrice * amount_);
    
    // Get random index
    uint256 _index = IRandomFeed(randomFeed).getRandomFeed(trees.length, trees.length);

    // Bound index
    _index = (_index < amount_ * nftPerBox - 1) ? amount_ * nftPerBox - 1 : _index;

    for(uint i=0; i < amount_ * nftPerBox; i++) {
      // Transfer Nftree to user
      NFT(nftContract).transferFrom(address(this), msg.sender, trees[_index - i]);

      // Update tree list
      trees[_index - i] = trees[trees.length - 1];

      // Remove element from tree list
      trees.pop();
    }

    // Emits an event
    emit Bought(msg.sender, amount_, specialPrice * amount_);
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
   * @dev Withdraw BEP20 tokens
   *
   * @param token_ address of BEP20 token to withdraw
   * @param amount_ number of tokens to withdraw
   */
  function withdrawTokens(address token_, uint256 amount_) external {
    require(msg.sender == admin, "Only admin can withdraw tokens");

	  // send the tokens to the admin
	  BEP20(token_).transfer(admin, amount_);
  }

  /**
   * @dev Returns number of trees available via nftreebox
   */
  function treesLength() external view returns(uint256) {
    return trees.length;
  }
}