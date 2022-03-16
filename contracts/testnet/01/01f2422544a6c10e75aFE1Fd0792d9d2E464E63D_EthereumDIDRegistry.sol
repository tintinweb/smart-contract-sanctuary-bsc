/* SPDX-License-Identifier: MIT */
pragma solidity ^0.8.6;

// import "hardhat/console.sol";

contract EthereumDIDRegistry {

  struct DelegateParam {
    bytes32 delegateType;
    address delegate;
    uint validity;
  }

  struct DelegateParamSigned {
    address identity;
    uint8 sigV;
    bytes32 sigR; 
    bytes32 sigS;
    bytes32 delegateType;
    address delegate;
    uint validity;
  }

  struct RevokeDelegateParam {
    bytes32 delegateType;
    address delegate;
  }

  struct RevokeDelegateParamSigned {
    address identity;
    uint8 sigV;
    bytes32 sigR; 
    bytes32 sigS;
    bytes32 delegateType;
    address delegate;
  }

  struct AttributeParam{
    bytes32 name;
    bytes value;
    uint validity;
  }

  struct AttributeParamSigned{
    address identity;
    uint8 sigV;
    bytes32 sigR; 
    bytes32 sigS;
    bytes32 name;
    bytes value;
    uint validity;
  }

  struct RevokeAttributeParam{
    bytes32 name;
    bytes value;
  }

  struct RevokeAttributeParamSigned{
    address identity;
    uint8 sigV;
    bytes32 sigR; 
    bytes32 sigS;
    bytes32 name;
    bytes value;
  }

  mapping(address => address) public owners;
  mapping(address => mapping(bytes32 => mapping(address => uint))) public delegates;
  mapping(address => uint) public changed;
  mapping(address => uint) public nonce;

  modifier onlyOwner(address identity, address actor) {
    require (actor == identityOwner(identity), "bad_actor");
    _;
  }

  event DIDOwnerChanged(
    address indexed identity,
    address owner,
    uint previousChange
  );

  event DIDDelegateChanged(
    address indexed identity,
    bytes32 delegateType,
    address delegate,
    uint validTo,
    uint previousChange
  );

  event DIDAttributeChanged(
    address indexed identity,
    bytes32 name,
    bytes value,
    uint validTo,
    uint previousChange
  );

  function identityOwner(address identity) public view returns(address) {
     address owner = owners[identity];
     if (owner != address(0x00)) {
       return owner;
     }
     return identity;
  }

  function checkSignature(address identity, uint8 sigV, bytes32 sigR, bytes32 sigS, bytes32 hash) internal returns(address) {
    address signer = ecrecover(hash, sigV, sigR, sigS);
    require(signer == identityOwner(identity), "bad_signature");
    nonce[signer]++;
    return signer;
  }

  function validDelegate(address identity, bytes32 delegateType, address delegate) public view returns(bool) {
    uint validity = delegates[identity][keccak256(abi.encode(delegateType))][delegate];
    return (validity > block.timestamp);
  }

  function changeOwner(address identity, address actor, address newOwner) internal onlyOwner(identity, actor) {
    owners[identity] = newOwner;
    emit DIDOwnerChanged(identity, newOwner, changed[identity]);
    changed[identity] = block.number;
  }

  function changeOwner(address identity, address newOwner) public {
    changeOwner(identity, msg.sender, newOwner);
  }

  function changeOwnerSigned(address identity, uint8 sigV, bytes32 sigR, bytes32 sigS, address newOwner) public {
    bytes32 hash = keccak256(abi.encodePacked(bytes1(0x19), bytes1(0), this, nonce[identityOwner(identity)], identity, "changeOwner", newOwner));
    changeOwner(identity, checkSignature(identity, sigV, sigR, sigS, hash), newOwner);
  }

  function addDelegate(address identity, address actor, bytes32 delegateType, address delegate, uint validity) internal onlyOwner(identity, actor) {
    // console.log("addDelegate", identity);
    delegates[identity][keccak256(abi.encode(delegateType))][delegate] = block.timestamp + validity;
    emit DIDDelegateChanged(identity, delegateType, delegate, block.timestamp + validity, changed[identity]);
    changed[identity] = block.number;
  }

  function addDelegate(address identity, bytes32 delegateType, address delegate, uint validity) public {
    addDelegate(identity, msg.sender, delegateType, delegate, validity);
  }

  function addDelegateSigned(address identity, uint8 sigV, bytes32 sigR, bytes32 sigS, bytes32 delegateType, address delegate, uint validity) public {
    bytes32 hash = keccak256(abi.encodePacked(bytes1(0x19), bytes1(0), this, nonce[identityOwner(identity)], identity, "addDelegate", delegateType, delegate, validity));
    addDelegate(identity, checkSignature(identity, sigV, sigR, sigS, hash), delegateType, delegate, validity);
  }

  function revokeDelegate(address identity, address actor, bytes32 delegateType, address delegate) internal onlyOwner(identity, actor) {
    delegates[identity][keccak256(abi.encode(delegateType))][delegate] = block.timestamp;
    emit DIDDelegateChanged(identity, delegateType, delegate, block.timestamp, changed[identity]);
    changed[identity] = block.number;
  }

  function revokeDelegate(address identity, bytes32 delegateType, address delegate) public {
    revokeDelegate(identity, msg.sender, delegateType, delegate);
  }

  function revokeDelegateSigned(address identity, uint8 sigV, bytes32 sigR, bytes32 sigS, bytes32 delegateType, address delegate) public {
    bytes32 hash = keccak256(abi.encodePacked(bytes1(0x19), bytes1(0), this, nonce[identityOwner(identity)], identity, "revokeDelegate", delegateType, delegate));
    revokeDelegate(identity, checkSignature(identity, sigV, sigR, sigS, hash), delegateType, delegate);
  }

  function setAttribute(address identity, address actor, bytes32 name, bytes memory value, uint validity ) internal onlyOwner(identity, actor) {
    emit DIDAttributeChanged(identity, name, value, block.timestamp + validity, changed[identity]);
    changed[identity] = block.number;
  }

  function setAttribute(address identity, bytes32 name, bytes memory value, uint validity) public {
    setAttribute(identity, msg.sender, name, value, validity);
  }

  function setAttributeSigned(address identity, uint8 sigV, bytes32 sigR, bytes32 sigS, bytes32 name, bytes memory value, uint validity) public {
    bytes32 hash = keccak256(abi.encodePacked(bytes1(0x19), bytes1(0), this, nonce[identityOwner(identity)], identity, "setAttribute", name, value, validity));
    setAttribute(identity, checkSignature(identity, sigV, sigR, sigS, hash), name, value, validity);
  }

  function revokeAttribute(address identity, address actor, bytes32 name, bytes memory value ) internal onlyOwner(identity, actor) {
    emit DIDAttributeChanged(identity, name, value, 0, changed[identity]);
    changed[identity] = block.number;
  }

  function revokeAttribute(address identity, bytes32 name, bytes memory value) public {
    revokeAttribute(identity, msg.sender, name, value);
  }

  function revokeAttributeSigned(address identity, uint8 sigV, bytes32 sigR, bytes32 sigS, bytes32 name, bytes memory value) public {
    bytes32 hash = keccak256(abi.encodePacked(bytes1(0x19), bytes1(0), this, nonce[identityOwner(identity)], identity, "revokeAttribute", name, value));
    revokeAttribute(identity, checkSignature(identity, sigV, sigR, sigS, hash), name, value);
  }

  // Bulk Add
  function _bulkAdd(
    address identity,
    DelegateParam[] memory delegateParams,
    AttributeParam[] memory attributeParams
  ) internal {
    for (uint i = 0; i < delegateParams.length; i++) {
      addDelegate(
        identity, 
        // delegateParams[i].actor,
        delegateParams[i].delegateType,
        delegateParams[i].delegate,
        delegateParams[i].validity);
    }

    for (uint i = 0; i < attributeParams.length; i++) {
      setAttribute(
        identity, 
        // attributeParams[i].actor,
        attributeParams[i].name,
        attributeParams[i].value,
        attributeParams[i].validity);
    }
  }

  function _bulkAddSigned(
    address identity,
    DelegateParamSigned[] memory signedDelegateParams,
    AttributeParamSigned[] memory signedAttributeParams
  ) internal {
    for (uint i = 0; i < signedDelegateParams.length; i++) {
      addDelegateSigned(
        signedDelegateParams[i].identity,
        signedDelegateParams[i].sigV,
        signedDelegateParams[i].sigR,
        signedDelegateParams[i].sigS,
        signedDelegateParams[i].delegateType,
        signedDelegateParams[i].delegate,
        signedDelegateParams[i].validity);
    }

    for (uint i = 0; i < signedAttributeParams.length; i++) {
      setAttributeSigned(
        signedAttributeParams[i].identity, 
        signedAttributeParams[i].sigV,
        signedAttributeParams[i].sigR,
        signedAttributeParams[i].sigS,
        signedAttributeParams[i].name,
        signedAttributeParams[i].value,
        signedAttributeParams[i].validity);
    }
  }

  function bulkAdd(
    address identity,
    DelegateParam[] memory delegateParams,
    AttributeParam[] memory attributeParams,
    DelegateParamSigned[] memory signedDelegateParams,
    AttributeParamSigned[] memory signedAttributeParams
  ) external {
    // general addDelegate, setAttribute
    _bulkAdd(identity, delegateParams, attributeParams);

    // signed transaction
    _bulkAddSigned(identity, signedDelegateParams, signedAttributeParams);
  }

  function _bulkRevoke(
    address identity,
    RevokeDelegateParam[] memory delegateParams,
    RevokeAttributeParam[] memory attributeParams
  ) internal {
    for (uint i = 0; i < delegateParams.length; i++) {
      revokeDelegate(identity, delegateParams[i].delegateType, delegateParams[i].delegate);
    }

    for (uint i = 0; i < attributeParams.length; i++) {
      revokeAttribute(identity, attributeParams[i].name, attributeParams[i].value);
    }
  }

  function _bulkRevokeSigned(
    address identity,
    RevokeDelegateParamSigned[] memory signedDelegateParams,
    RevokeAttributeParamSigned[] memory signedAttributeParams
  ) internal {
    for (uint i = 0; i < signedDelegateParams.length; i++) {
      revokeDelegateSigned(
        signedDelegateParams[i].identity,
        signedDelegateParams[i].sigV, 
        signedDelegateParams[i].sigR, 
        signedDelegateParams[i].sigS, 
        signedDelegateParams[i].delegateType, 
        signedDelegateParams[i].delegate);
    }

    for (uint i = 0; i < signedAttributeParams.length; i++) {
      revokeAttributeSigned(
        signedAttributeParams[i].identity, 
        signedAttributeParams[i].sigV, 
        signedAttributeParams[i].sigR, 
        signedAttributeParams[i].sigS, 
        signedAttributeParams[i].name, 
        signedAttributeParams[i].value);
    }
  }

  function bulkRevoke(
    address identity,
    RevokeDelegateParam[] memory delegateParams,
    RevokeAttributeParam[] memory attributeParams,
    RevokeDelegateParamSigned[] memory signedDelegateParams,
    RevokeAttributeParamSigned[] memory signedAttributeParams
  ) external {
    _bulkRevoke(identity, delegateParams, attributeParams);
    _bulkRevokeSigned(identity, signedDelegateParams, signedAttributeParams);
  }
}