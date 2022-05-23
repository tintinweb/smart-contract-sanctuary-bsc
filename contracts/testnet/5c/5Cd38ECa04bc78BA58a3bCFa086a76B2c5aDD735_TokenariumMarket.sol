// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";

interface ITokenariumNft {

  struct MemberType {
    string name;
    bool isSpecial;
    uint8 minTotalPoints;
  }

  function mint(
    address _addr,
    uint16 _memberType,
    uint16 concept,
    uint16 develop,
    uint16 design,
    uint16 promo,
    uint16 trust
  ) external returns (uint256);

  function getMemberType(uint16 typeId) external view returns (MemberType memory);

  function getMemberRarity(uint16 pointsSum) external view returns (string memory);

}

interface ITokenarium {

  function balanceOf(address account) external returns (uint256);
  function transfer(address to, uint256 amount) external returns (bool);
  function transferFrom(address from, address to, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external returns (uint256);

}

contract TokenariumMarket is Ownable {

  // The nft contract
  ITokenariumNft public nftContract;

  ITokenarium public tokenContract;

  // Address where funds are collected
  address public wallet;

  // Amount of tokens raised
  uint256 public tokenRaised;

  uint16 public MEMBER_ITEM_COUNTER;

  uint16 public LOOT_BOX_COUNTER;

  uint256 randNonce = 0;

  bool public isActive = true;

  struct MemberItem {
    uint16 memberType;
    // "special", "basic", "common", "uncommon", "rare", "epic", "legendary"
    uint8 rarity;
    uint8 category;
    uint16[5] points;
  }

  struct LootBox {
    uint256 price;
    string name;
    uint8 category;
    uint8 limit;
    // ["special", "basic", "common", "uncommon", "rare", "epic", "legendary"]
    uint8[7] rarity;
  }

  mapping(uint16 => MemberItem) public MemberItems;

  mapping(uint16 => LootBox) public LootBoxes;

  mapping(uint8 => uint16[]) public categoryFilter;

  mapping(uint8 => uint16[]) public rarityFilter;

  mapping(uint8 => uint256) public rarityPrices;

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param memberId member Id
   * @param value weis paid for purchase
   */
  event MemberPurchase(
    address indexed purchaser,
    uint256 memberId,
    uint256 value
  );

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param lootBoxId lootbox Id
   * @param memberIds member Ids
   * @param value weis paid for purchase
   */
  event LootBoxPurchase(
    address indexed purchaser,
    uint256 indexed lootBoxId,
    uint256[] memberIds,
    uint256 value
  );

  /**
   * @param _wallet Address where collected funds will be forwarded to
   * @param _nftContract Address of the token being sold
   */
  constructor(address _wallet, address _nftContract, address _tokenContract)
  {
    require(_wallet != address(0));
    require(_nftContract != address(0));
    wallet = _wallet;
    nftContract = ITokenariumNft(_nftContract);
    tokenContract = ITokenarium(_tokenContract);
  }

  // -----------------------------------------
  // Market external interface
  // -----------------------------------------

  function rescueBNB() external onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
  }

  function rescueTokens() external onlyOwner {
    tokenContract.transfer(msg.sender, tokenContract.balanceOf(address(this)));
  }

  function setRarityPrice(uint8 _rarity, uint256 _price) public onlyOwner {
    rarityPrices[_rarity] = _price;
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param _memberItemId member itemID
   * @return uint256
   */
  function buyMember(uint16 _memberItemId) public payable returns (uint256) {
    require(isActive, "Market is not active");
    require(msg.sender != address(0));
    MemberItem storage memberItem = MemberItems[_memberItemId];
    require(memberItem.rarity > 0, "Member type does not exist");
    uint256 price = rarityPrices[memberItem.rarity];
    if (price > 0) {
      require(tokenContract.allowance(msg.sender, address(this)) >= price, "Not enough allowance");
    }
    return _generateMember(msg.sender, price, memberItem);
  }

  /**
   * @dev low level lootbox purchase ***DO NOT OVERRIDE***
   * @param _lootBoxId lootbox ID
   * @return uint256[] memory
   */
  function buyLootBox(uint16 _lootBoxId) public payable returns (uint256[] memory) {
    require(isActive, "Market is not active");
    require(msg.sender != address(0));
    LootBox storage lootBox = LootBoxes[_lootBoxId];
    require(lootBox.price > 0, "Loot Box does not exist");
    require(tokenContract.allowance(msg.sender, address(this)) >= lootBox.price, "Not enough allowance");
    return _generateLootBox(_lootBoxId, msg.sender, lootBox.price, lootBox);
  }

  function assignLootBox(uint16 _lootBoxId, address addr) public onlyOwner returns (uint256[] memory) {
    require(addr != address(0));
    LootBox storage lootBox = LootBoxes[_lootBoxId];
    require(lootBox.price > 0, "Loot Box does not exist");
    return _generateLootBox(_lootBoxId, addr, 0, lootBox);
  }

  /**
   * @dev Generate member
   */
  function _generateMember(
    address addr,
    uint256 value,
    MemberItem storage memberItem
  ) internal returns(uint256)
  {
    // update state
    uint256 memberId = nftContract.mint(
      addr,
      memberItem.memberType,
      memberItem.points[0],
      memberItem.points[1],
      memberItem.points[2],
      memberItem.points[3],
      memberItem.points[4]
    );

    emit MemberPurchase(
      addr,
      memberId,
      value
    );

    // forward funds
    if (value > 0) {
      tokenRaised += value;
      _forwardFunds(value);
    }

    return memberId;
  }

  /**
   * @dev Generate loot box
   */
  function _generateLootBox(
    uint256 lootBoxId,
    address addr,
    uint256 value,
    LootBox storage lootBox
  ) internal returns(uint256[] memory)
  {
    uint256[] memory itemIds = new uint256[](lootBox.limit);

    for (uint16 i = 0; i < lootBox.limit; i++) {
      uint256 memberId = _generateLootBoxMember(addr, lootBox);
      itemIds[i] = memberId;
    }

    emit LootBoxPurchase(
      addr,
      lootBoxId,
      itemIds,
      value
    );

    // forward funds
    if (value > 0) {
      tokenRaised += value;
      _forwardFunds(value);
    }

    return itemIds;
  }

  function _generateLootBoxMember(
    address addr,
    LootBox storage lootBox
  ) internal returns(uint256)
  {
    uint256 memberItemId = 0;
    if (lootBox.category > 0) {
      memberItemId = categoryFilter[lootBox.category][randMod(categoryFilter[lootBox.category].length)];
    } else {
      uint8 rand = uint8(randMod(100));
      uint8 rarity = 0;
      for (; rarity < 6; rarity++) {
        if (lootBox.rarity[rarity] > 0 && rand <= lootBox.rarity[rarity]) {
          break;
        }
      }
      memberItemId = rarityFilter[rarity][randMod(rarityFilter[rarity].length)];
    }
    MemberItem storage memberItem = MemberItems[uint16(memberItemId)];
    return _generateMember(addr, 0, memberItem);
  }

  function addMemberItem(
    uint16 _memberType,
    uint8 _rarity,
    uint8 _category,
    uint16[5] memory _points
  ) external onlyOwner {
    MemberItem memory newItem = MemberItem(_memberType, _rarity, _category, _points);
    MemberItems[MEMBER_ITEM_COUNTER] = newItem;
    rarityFilter[_rarity].push(MEMBER_ITEM_COUNTER);
    categoryFilter[_category].push(MEMBER_ITEM_COUNTER);
    MEMBER_ITEM_COUNTER++;
  }

  function updateMemberItem(
    uint16 _itemID,
    uint16 _memberType,
    uint8 _rarity,
    uint8 _category,
    uint16[5] memory _points
  ) external onlyOwner {
    MemberItem storage memberItem = MemberItems[_itemID];
    memberItem.memberType = _memberType;
    memberItem.rarity = _rarity;
    memberItem.category = _category;
    memberItem.points = _points;
  }

  function addLootBox(
    uint256 _price,
    string memory _name,
    uint8 _category,
    uint8 _limit,
    uint8[7] memory _rarity
  ) external onlyOwner {
    LootBox memory newLootBox = LootBox(_price, _name, _category, _limit, _rarity);
    LootBoxes[LOOT_BOX_COUNTER] = newLootBox;
    LOOT_BOX_COUNTER++;
  }

  function updateLootBox(
    uint16 _lootBoxID,
    uint256 _price,
    string memory _name,
    uint8 _category,
    uint8 _limit,
    uint8[7] memory _rarity
  ) external onlyOwner {
    LootBox storage lootBox = LootBoxes[_lootBoxID];
    lootBox.price = _price;
    lootBox.name = _name;
    lootBox.category = _category;
    lootBox.limit = _limit;
    lootBox.rarity = _rarity;
  }

  function getLootBox(
    uint16 _lootBoxID
  ) external view returns (LootBox memory) {
    return LootBoxes[_lootBoxID];
  }

  function getMemberItem(
    uint16 _memberItemID
  ) external view returns (MemberItem memory) {
    return MemberItems[_memberItemID];
  }

  /**
   * @dev set active status
   */
  function setActive(bool _active) onlyOwner public {
    isActive = _active;
  }

  function setRarityFilter(uint8 _rarity, uint16[] memory _memberItemIds) onlyOwner public {
    rarityFilter[_rarity] = _memberItemIds;
  }

  function setCategoryFilter(uint8 _category, uint16[] memory _memberItemIds) onlyOwner public {
    categoryFilter[_category] = _memberItemIds;
  }

  function getMembersItems(uint8 category, uint16 page, uint16 pageLimit) external view returns (
    uint256[] memory,
    MemberItem[] memory,
    uint256[] memory,
    string[] memory
  ) {
    uint256[] memory ids = new uint256[](pageLimit);
    MemberItem[] memory items = new MemberItem[](pageLimit);
    uint256[] memory prices = new uint256[](pageLimit);
    string[] memory names = new string[](pageLimit);
    uint16 endPage = page * pageLimit;
    uint16 index = 0;
    for (uint16 i = 0; i < pageLimit; i++) {
      ids[index] = categoryFilter[category][endPage + i];
      items[index] = MemberItems[uint16(ids[index])];
      prices[index] = rarityPrices[items[index].rarity];
      names[index] = nftContract.getMemberType(items[index].memberType).name;
      index++;
    }
    return (ids, items, prices, names);
  }

  function getMembersItemsCount(uint8 category) external view returns (uint256) {
    return categoryFilter[category].length;
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds(uint256 tokenAmount) internal {
    tokenContract.transferFrom(msg.sender, owner(), tokenAmount);
  }

  /**
   * @dev Generate a random number
   */
  function randMod(uint _modulus) internal returns(uint)
  {
    randNonce++;
    return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % _modulus;
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