/**
 *Submitted for verification at BscScan.com on 2022-03-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
interface IERC20{
  function transfer(address to, uint256 amount) external returns (bool);
  function transferFrom(address from, address to, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
}
interface IERC721{
  function ownerOf(uint256 tokenId) external view returns (address owner);
  function safeTransferFrom(address from, address to, uint256 tokenId) external;
  function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
interface IERC1155{
  function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
  function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
interface IERC721Receiver{
  function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}
interface IERC1155Receiver{
  function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns(bytes4);
}
contract NftBroker is IERC721Receiver,IERC1155Receiver{
  address public token;
  address public owner;
  uint256 public ethListFee;
  uint256 public ercListFee;
  struct broke {
    address broker;
    uint256 expiry;
  }
  struct sell {
    address seller;
    uint256 price;
    bool isErc20;
  }
  mapping (string => bool) public promoCodes;
  mapping (address => mapping (uint256 => sell)) public _listings;
  mapping (address => mapping (uint256 => broke)) public _brokerages;
  constructor() {
    owner = msg.sender;
  }
  function setToken(address _token) public{
    require(msg.sender == owner);
    token = _token;
  }
  function setEthListFee (uint256 _fee) public{
    require(msg.sender == owner);
    ethListFee = _fee;
  }
  function setErcListFee (uint256 _fee) public{
    require(msg.sender == owner);
    ercListFee = _fee;
  }
  function addPromoCode(string memory _promoCode) public{
    require(msg.sender == owner);
    promoCodes[_promoCode] = true;
  }
  function removePromoCode(string memory _promoCode) public{
    require(msg.sender == owner);
    promoCodes[_promoCode] = false;
  }
  function sellNft (address _address, uint256 _id, uint256 _price, string memory _promoCode, bool isERC721) public payable{
    if(!promoCodes[_promoCode]){
    if(msg.value > 0) require(msg.value >= ethListFee, "1");
    else{
    require(IERC20(token).transferFrom(msg.sender, address(this), ercListFee), "2");
    _listings[_address][_id].isErc20 = true; } }
    if(isERC721) IERC721(_address).safeTransferFrom(msg.sender, address(this), _id);
    else IERC1155(_address).safeTransferFrom(msg.sender, address(this), _id, 1, "");
    _listings[_address][_id].seller = msg.sender;
    _listings[_address][_id].price = _price;
  }
  function cancelSellNft(address _address, uint256 _id) public{
    require(msg.sender == _listings[_address][_id].seller, "3");
    if(_brokerages[_address][_id].expiry > 0) require(_brokerages[_address][_id].expiry < block.timestamp, "4");
    delete _listings[_address][_id];
    delete _brokerages[_address][_id];
  }
  function brokeNft(address _address, uint256 _id, string memory _promoCode) public payable{
    if(!promoCodes[_promoCode]){
    if(msg.value > 0) require(msg.value >= ethListFee, "1");
    else{
    require(IERC20(token).transferFrom(msg.sender, address(this), ercListFee), "2");}
    }
    if(_brokerages[_address][_id].expiry > 0){
      if(_brokerages[_address][_id].expiry < block.timestamp) delete _brokerages[_address][_id];
      else revert("5"); }
    _brokerages[_address][_id].broker = msg.sender;
    _brokerages[_address][_id].expiry = block.timestamp + (21 * 24 * 60 * 60);
  }
  function cancelBrokeNft(address _address, uint256 _id) public{
    require(_brokerages[_address][_id].broker == msg.sender, "5");
    delete _brokerages[_address][_id];
  }
  function buyNft(address _address, uint256 _id, bool isERC721) public payable{
    require(_brokerages[_address][_id].expiry > block.timestamp, "5");
    if(_listings[_address][_id].isErc20){
      uint256 fee = (_listings[_address][_id].price * 95) / 100;
      uint256 priceAfterFee = _listings[_address][_id].price - fee;
      require(IERC20(token).transferFrom(msg.sender, _listings[_address][_id].seller, priceAfterFee));
      require(IERC20(token).transferFrom(msg.sender, _brokerages[_address][_id].broker, fee));
    }else{
      require(msg.value >= _listings[_address][_id].price);
      uint256 brokerFee = (_listings[_address][_id].price * 50) / 1000;
      uint256 companyFee = (_listings[_address][_id].price * 25) / 1000;
      uint256 priceAfterFee = _listings[_address][_id].price - brokerFee - companyFee;
      (bool sentToSeller, ) = _listings[_address][_id].seller.call{value: priceAfterFee}("");
      require(sentToSeller, "6");
      (bool sentToBroker, ) = _brokerages[_address][_id].broker.call{value: brokerFee}("");
      require(sentToBroker, "6");
    }
    if (isERC721) IERC721(_address).safeTransferFrom(address(this), msg.sender, _id);
    else IERC1155(_address).safeTransferFrom(address(this), msg.sender, _id, 1, "");
    delete _listings[_address][_id];
    delete _brokerages[_address][_id];
  }
  function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external virtual override returns (bytes4){
    return this.onERC721Received.selector;
  }
  function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external virtual override returns (bytes4){
    return this.onERC1155Received.selector;
  }
  function manageEth(address payable _to) public {
    require(msg.sender == owner);
    (bool sent, ) = _to.call{value: address(this).balance}("");
    require(sent, "Failed to manage Ether");
  }
  function manageErc(address _to) public {
    require(msg.sender == owner);
    uint256 ercBal = IERC20(token).balanceOf(address(this));
    require(IERC20(token).transfer(_to, ercBal), "Failed to manage Erc");
  }
}