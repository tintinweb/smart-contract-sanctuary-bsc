/**
 *Submitted for verification at BscScan.com on 2023-01-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Owner {
  address private owner;

  // event for EVM logging
  event OwnerSet(address indexed oldOwner, address indexed newOwner);

  // modifier to check if caller is owner
  modifier isOwner() {
    // If the first argument of 'require' evaluates to 'false', execution terminates and all
    // changes to the state and to Ether balances are reverted.
    // This used to consume all gas in old EVM versions, but not anymore.
    // It is often a good idea to use 'require' to check if functions are called correctly.
    // As a second argument, you can also provide an explanation about what went wrong.
    require(msg.sender == owner, 'Caller is not owner');
    _;
  }

  /**
   * @dev Set contract deployer as owner
   */
  constructor() {
    owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
    emit OwnerSet(address(0), owner);
  }

  /**
   * @dev Change owner
   * @param newOwner address of new owner
   */
  function changeOwner(address newOwner) public isOwner {
    emit OwnerSet(owner, newOwner);
    owner = newOwner;
  }

  /**
   * @dev Return owner address
   * @return address of owner
   */
  function getOwner() external view returns (address) {
    return owner;
  }
}

contract CouponsContract is Owner {
  mapping(string => mapping(bytes32 => uint256)) private collectionCoupons;
  mapping(string => bool) private collections;
  mapping(bytes32 => uint256) private coupons;
  mapping(address => bool) private allowedList;

  constructor(address[] memory _allowedList, bool[] memory _status) {
    setAllowedList(_allowedList, _status);
  }

  function setAllowedList(address[] memory _allowedList, bool[] memory _status) public isOwner { // _status (true = allowed)
    for (uint256 i=0; i<_allowedList.length; i++) {
      allowedList[_allowedList[i]] = _status[i];
    }
  }

  function includeCollections(
    string[] memory _idCollections
  ) external isOwner {
    for (uint256 i=0; i<_idCollections.length; i++) {
      collections[_idCollections[i]] = true;
    }
  }

  function excludeCollections(
    string[] memory _idCollections
  ) external isOwner {
    for (uint256 i=0; i<_idCollections.length; i++) {
      collections[_idCollections[i]] = false;
    }
  }

  function addCoupons(
    bytes32[] memory _codes,
    uint256[] memory _max_prices
  ) external isOwner {
    for (uint256 i=0; i<_codes.length; i++) {
      coupons[_codes[i]] = _max_prices[i];
    }
  }

  function getCollections(string[] memory _idCollections) external view isOwner returns (string[] memory, bool[] memory) {
    string[] memory collection = new string[](_idCollections.length);
    bool[] memory isActivated = new bool[](_idCollections.length);

    for (uint256 i=0; i<_idCollections.length; i++) {
      collection[i] = _idCollections[i];
      isActivated[i] = collections[_idCollections[i]];
    }
    return (collection, isActivated);
  }

  function getCoupons(bytes32[] memory _codes) external view isOwner returns (bytes32[] memory, uint256[] memory) {
    bytes32[] memory code = new bytes32[](_codes.length);
    uint256[] memory max_price = new uint256[](_codes.length);

    for (uint256 i = 0; i < _codes.length; i++) {
      code[i] = _codes[i];
      max_price[i] = coupons[_codes[i]];
    }
    return (code, max_price);
  }

  function addCollectionCoupons(
    string memory _id_collection,
    bytes32[] memory _codes,
    uint256[] memory _max_prices
  ) external isOwner {
    for (uint256 i = 0; i < _codes.length; i++) {
      collectionCoupons[_id_collection][_codes[i]] = _max_prices[i];
    }
  }

  function getCollectionCoupons(
    string memory _id_collection,
    bytes32[] memory _codes
  ) external view isOwner returns (bytes32[] memory, uint256[] memory) {
    bytes32[] memory code = new bytes32[](_codes.length);
    uint256[] memory max_price = new uint256[](_codes.length);

    for (uint256 i = 0; i < _codes.length; i++) {
      code[i] = _codes[i];
      max_price[i] = collectionCoupons[_id_collection][_codes[i]];
    }
    return (code, max_price);
  }

  function checkCoupon(
    string memory _id_collection,
    string memory _coupon_code,
    uint256 _tokenPrice
  ) public returns (bool) {
    require(allowedList[msg.sender] == true, 'Wallet not authorized to verify coupons');
    bytes32 hashedCode = sha256(abi.encodePacked(_coupon_code));
    if(collectionCoupons[_id_collection][hashedCode] < _tokenPrice){
      require(coupons[hashedCode] > 0, "this coupon code is not valid");
      require(coupons[hashedCode] >= _tokenPrice, "the coupon is worth less than the NFT price");
      require(collections[_id_collection], "this coupon is not valid in this collection");
    }
    collectionCoupons[_id_collection][hashedCode] = 0;
    coupons[hashedCode] = 0;
    return true;
  }
}