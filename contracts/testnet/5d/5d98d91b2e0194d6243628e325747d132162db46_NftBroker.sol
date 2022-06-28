/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

/**
 *Submitted for verification at Etherscan.io on 2022-03-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IERC721 {
    function ownerOf(uint256 id) external view returns (address);
    function transferFrom(address from, address to, uint256 tokenId) external returns (bool);
    function transfer(address to, uint256 tokenId) external returns (bool);
}

interface IERC20 {
    function transferFrom(address from, address to, uint256 tokenId) external returns (bool);
}

contract NftBroker {
  
  struct sell {
    address seller;
    uint256 price;
    bool isErc20;
    uint256 timestamp;
  }

  mapping (address => mapping (uint256 => sell)) private _listings;

  struct broke {
    address broker;
    uint256 expiry;
  }

  mapping (address => mapping (uint256 => broke)) private _brokerages;

  address token;
  address owner;
  uint256 ethListFee;
  uint256 ercListFee;

  mapping (string => bool) private promoCodes;

  // events
  event AddPromoCode(string _promoCode);
  event RemovePromoCode(string _promoCode);
  event _SellNFT(address _seller, address _address, uint256 _id, uint256 _price, bool _isErc20, string _promoCode);
  event _brokeNft(address _broker, address _address, uint256 _id, uint256 _expiry);
  event _cancelBrokeNft(address _broker, address _address, uint256 _id);
  event _buyNft(address _buyer, address _address, uint256 _id);

  function addPromoCode(string memory _promoCode) public {
    require(msg.sender == owner);
    promoCodes[_promoCode] = true;
    emit AddPromoCode(_promoCode);
  }

  function removePromoCode(string memory _promoCode) public {
    require(msg.sender == owner);
    promoCodes[_promoCode] = false;
    emit RemovePromoCode(_promoCode);
  }

  function setEthListFee (uint256 _fee) public {
    require(msg.sender == owner);
    ethListFee = _fee;
  }

  function setErcListFee (uint256 _fee) public {
    require(msg.sender == owner);
    ercListFee = _fee;
  }

  constructor() {
    token = address(0);
    owner = msg.sender;
  }

  function sellNft (address _address, uint256 _id, uint256 _price, bool _isErc20, string memory _promoCode) public payable {
    if (!promoCodes[_promoCode]) {
      if (msg.value > 0)
        require(msg.value >= ethListFee);
      else {
        require(IERC20(token).transferFrom(msg.sender, address(this), ercListFee), "list fee required");
      }
    }
    require(IERC721(_address).transferFrom(msg.sender, address(this), _id), "escrow failed");
    _listings[_address][_id].seller = msg.sender;
    _listings[_address][_id].price = _price;
    _listings[_address][_id].isErc20 = _isErc20;
    emit _SellNFT(msg.sender, _address, _id, _price, _isErc20, _promoCode);
  }

  function brokeNft(address _address, uint256 _id) public {
    if (_brokerages[_address][_id].expiry > 0) {
      if (_brokerages[_address][_id].expiry < block.timestamp)
        delete _brokerages[_address][_id];
      else
        revert("brokerage exists");
    }
    _brokerages[_address][_id].broker = msg.sender;
    _brokerages[_address][_id].expiry = block.timestamp + (21 * 24 * 60 * 60);
    emit _brokeNft(msg.sender, _address, _id, _brokerages[_address][_id].expiry);
  }

  function cancelBrokeNft(address _address, uint256 _id) public {
    require(_brokerages[_address][_id].broker == msg.sender, "invalid request");
    delete _brokerages[_address][_id];
    emit _cancelBrokeNft(msg.sender, _address, _id);
  }

  function buyNft(address _address, uint256 _id) public payable {
    require(_brokerages[_address][_id].expiry > block.timestamp, "invalid brokerage");
    if (_listings[_address][_id].isErc20) {
      uint256 fee = (_listings[_address][_id].price * 95) / 100;
      uint256 priceAfterFee = _listings[_address][_id].price - fee;
      require(IERC20(token).transferFrom(msg.sender, _listings[_address][_id].seller, priceAfterFee));
      require(IERC20(token).transferFrom(msg.sender, _brokerages[_address][_id].broker, fee));
    }
    else {
      require(msg.value >= _listings[_address][_id].price);
      uint256 brokerFee = (_listings[_address][_id].price * 50) / 1000;
      uint256 companyFee = (_listings[_address][_id].price * 25) / 1000;
      uint256 priceAfterFee = _listings[_address][_id].price - brokerFee - companyFee;
      (bool sentToSeller, ) = _listings[_address][_id].seller.call{value: priceAfterFee}("");
      require(sentToSeller, "Failed to send Ether");
      (bool sentToBroker, ) = _brokerages[_address][_id].broker.call{value: brokerFee}("");
      require(sentToBroker, "Failed to send Ether");
    }
    delete _listings[_address][_id];
    delete _brokerages[_address][_id];
    emit _buyNft(msg.sender, _address, _id);
  }
}