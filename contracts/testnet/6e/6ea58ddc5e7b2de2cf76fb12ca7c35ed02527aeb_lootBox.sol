// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721URIStorage.sol";
import "./IBEP20.sol";
import "./Ownable.sol";

contract lootBox is ERC721URIStorage, Ownable {

  IBEP20 token;
  uint256 tokenIds;
  address private _owner;
  uint256 public numItems = 9;
  uint256 public priceAnyCoin = 4*10**16;
  uint256 public priceAnyToken = 400;
  uint256[] public priceTypeCoin = [3*10**16, 4*10**16, 5*10**16, 6*10**16, 7*10**16];
  uint256[] public priceTypeToken = [300, 400, 500, 600, 700];
  mapping(uint256 => uint256) public priceItemCoin;
  mapping(uint256 => uint256) public priceItemToken;
  uint256 totalSupply = 1000000;
  bool is_active = false;

  constructor(
    string memory _name,
    string memory _symbol,
    address _token_address
  ) ERC721 (_name, _symbol) {
    _owner = msg.sender;
    token = IBEP20(_token_address);
  }

  function buyItem(uint256 _type, uint256 _item) external payable returns (uint256) {
    require(is_active, "Store is not open now");
    require(_type < 5, "There is not this type of item");
    require(_item < numItems, "There is not this item");
    tokenIds++;
    require(tokenIds < totalSupply, "All items has been sold");

    if (msg.value == 0) {
      require(priceItemToken[_type * totalSupply + _item] != 0, "This item has not price in token");
      uint256 allowance = token.allowance(msg.sender, address(this));
      require(allowance >= priceItemToken[_type * totalSupply + _item], "Check the token allowance");
      token.transferFrom(msg.sender, address(this), priceItemToken[_type * totalSupply + _item]);
    } else {
      require(priceItemCoin[_type * totalSupply + _item] != 0, "This item has not price in coins");
      require(msg.value >= priceItemCoin[_type * totalSupply + _item], "Not send anought coins");
    }

    uint256 newItemId = tokenIds + _type * totalSupply * 10 + _item * totalSupply;
    _mint(msg.sender, newItemId);

    return newItemId;

  }

  function buyType(uint256 _type) external payable returns(uint256) {
    require(_type < 5, "There is not this type of item");
    tokenIds++;
    require(tokenIds < totalSupply, "All items has been sold");

    if (msg.value == 0) {
      require(priceTypeToken[_type] != 0, "This item has not price in token");
      uint256 allowance = token.allowance(msg.sender, address(this));
      require(allowance >= priceTypeToken[_type], "Check the token allowance");
      token.transferFrom(msg.sender, address(this), priceTypeToken[_type]);
    } else {
      require(priceTypeCoin[_type] != 0, "This item has not price in coins");
      require(msg.value >= priceTypeCoin[_type], "Not send anought coins");
    }

    uint seed;
    seed = block.timestamp;
    uint item = (uint(keccak256(abi.encodePacked(blockhash(block.number - 1), seed)))%(numItems));

    uint256 newItemId = tokenIds + totalSupply * _type * 10 + item * totalSupply;
    _mint(msg.sender, newItemId);

    return newItemId;

  }

  function buyAny() external payable returns (uint256) {
    require(is_active, "Store is not open now");
    tokenIds++;
    require(tokenIds < totalSupply, "All items has been sold");
    if (msg.value == 0) {
      require(priceAnyToken != 0, "This item has not price in token");
      uint256 allowance = token.allowance(msg.sender, address(this));
      require(allowance >= priceAnyToken, "Check the token allowance");
      token.transferFrom(msg.sender, address(this), priceAnyToken);
    } else {
      require(priceAnyCoin != 0, "This item has not price in coins");
      require(msg.value >= priceAnyCoin, "Not send anought coins");
    }

    uint seed;
    seed = block.timestamp;
    uint item = (uint(keccak256(abi.encodePacked(blockhash(block.number - 1), seed)))%(numItems)) + 1;
    uint rnd = (uint(keccak256(abi.encodePacked(blockhash(block.number - 1), seed)))%10000);
    uint typeOfItem;

    if (rnd <= 25){
      typeOfItem = 4;
    }
    if (rnd > 25 && rnd < 1025){
      typeOfItem = 3;
    }
    if (rnd > 1025 && rnd < 2525){
      typeOfItem = 3;
    }
    if (rnd > 2525 && rnd < 5025){
      typeOfItem = 2;
    }
    if (rnd >= 5025 ){
      typeOfItem = 1;
    }

    uint256 newItemId = tokenIds + typeOfItem * totalSupply * 10 + item * totalSupply;
    _mint(msg.sender, newItemId);

    return newItemId;

  }

  function setNumItems(uint256 _numItems) external onlyOwner {
    require(_numItems < 9, "Numbers of items must be less then 9");
    numItems = _numItems;
  }

  function getNumItems() external view returns(uint256) {
    return numItems;
  }

  function setPriceAnyCoin(uint256 _priceAnyCoin) external onlyOwner {
    priceAnyCoin = _priceAnyCoin;
  }

  function getPriceAnyCoin() external view returns(uint256) {
    return priceAnyCoin;
  }

  function setPriceAnyToken(uint256 _priceAnyToken) external onlyOwner {
    priceAnyToken = _priceAnyToken;
  }

  function getPriceAnyToken() external view returns(uint256) {
    return priceAnyToken;
  }

  function setPriceTypeCoin(uint256 _type, uint256 _priceTypeCoin) external onlyOwner {
    require(_type < 5, "There is not this type of item");
    priceTypeCoin[_type] = _priceTypeCoin;
  }

  function getPriceTypeCoin(uint256 _type) external view returns(uint256) {
    require(_type < 5, "There is not this type of item");
    return priceTypeCoin[_type];
  }

  function setPriceTypeToken(uint256 _type, uint256 _priceTypeToken) external onlyOwner {
    require(_type < 5, "There is not this type of item");
    priceTypeToken[_type] = _priceTypeToken;
  }

  function getPriceTypeToken(uint256 _type) external view returns(uint256) {
    require(_type < 5, "There is not this type of item");
    return priceTypeToken[_type];
  }

  function setPriceItemCoin(uint256 tokenId, uint256 price) external onlyOwner {
    priceItemCoin[tokenId] = price;
  }

  function getPriceItemCoin(uint256 tokenId) external view returns(uint256) {
    return priceItemCoin[tokenId];
  }

  function setPriceItemToken(uint256 tokenId, uint256 price) external onlyOwner {
    priceItemCoin[tokenId] = price;
  }

  function getPriceItemToken(uint256 tokenId) external view returns(uint256) {
    return priceItemCoin[tokenId];
  }

  function setURI(string memory _TokenURI, uint256 _newItemId) external onlyOwner {
    _setTokenURI(_newItemId, _TokenURI);
  }

  function getURI(uint256 _newItemId) view external returns (string memory) {
    return tokenURI(_newItemId);
  }

  function setActive(bool active) external onlyOwner  {
    is_active = active;
  }

  function burn(uint256 tokenId) external {
    require(_isApprovedOrOwner(_msgSender(), tokenId), "Caller is not owner nor approved");
    _burn(tokenId);
  }

}