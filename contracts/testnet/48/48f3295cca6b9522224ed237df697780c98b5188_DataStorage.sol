/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStorage {
    
    function setIntAddress(uint256 _keyId, address _value) external;
    function setStrAddress(string memory _keyName, address _value) external;
    function setAdrString(address _address, string memory _value) external;
    function setAdrByte32(address _address, bytes32 _value) external;
    function setAdrUint(address _address, uint256 _value) external;
    function setAdrBool(address _address, bool _value) external;
    
    function setIntStrAddress(uint256 _keyId, string memory _name, address _value) external;
    function setIntStrString(uint256 _keyId, string memory _name, string memory _value) external;
    function setIntStrByte32(uint256 _keyId, string memory _name, bytes32 _value) external;
    function setIntStrUint(uint256 _keyId, string memory _name, uint256 _value) external;
    function setIntStrBool(uint256 _keyId, string memory _name, bool _value) external;
    
    function setIntStrIntAddress(uint256 _keyId, string memory _name, uint256 _refId, address _value) external;
    function setIntStrIntString(uint256 _keyId, string memory _name, uint256 _refId, string memory _value) external;
    function setIntStrIntByte32(uint256 _keyId, string memory _name, uint256 _refId, bytes32 _value) external;
    function setIntStrIntUint(uint256 _keyId, string memory _name, uint256 _refId, uint256 _value) external;
    function setIntStrIntBool(uint256 _keyId, string memory _name, uint256 _refId, bool _value) external;
    
    function setAdrStrIntAddress(address _address, string memory _name, uint256 _refId, address _value) external;
    function setAdrStrIntString(address _address, string memory _name, uint256 _refId, string memory _value) external;
    function setAdrStrIntByte32(address _address, string memory _name, uint256 _refId, bytes32 _value) external;
    function setAdrStrIntUint(address _address, string memory _name, uint256 _refId, uint256 _value) external;
    function setAdrStrIntBool(address _address, string memory _name, uint256 _refId, bool _value) external;
    
    function setAdrStrAddress(address _address, string memory _name, address _value) external;
    function setAdrStrString(address _address, string memory _name, string memory _value) external;
    function setAdrStrByte32(address _address, string memory _name, bytes32 _value) external;
    function setAdrStrUint(address _address, string memory _name, uint256 _value) external;
    function setAdrStrBool(address _address, string memory _name, bool _value) external;
    
    function setIntStrManyAddress(uint256 _keyId, string memory _name, address _value) external;
    function setIntStrManyString(uint256 _keyId, string memory _name, string memory _value) external;
    function setIntStrManyByte32(uint256 _keyId, string memory _name, bytes32 _value) external;
    function setIntStrManyUint(uint256 _keyId, string memory _name, uint256 _value) external;
    function setIntStrManyBool(uint256 _keyId, string memory _name, bool _value) external;
    
    function setAdrStrManyAddress(address _address, string memory _name, address _value) external;
    function setAdrStrManyString(address _address, string memory _name, string memory _value) external;
    function setAdrStrManyByte32(address _address, string memory _name, bytes32 _value) external;
    function setAdrStrManyUint(address _address, string memory _name, uint256 _value) external;
    function setAdrStrManyBool(address _address, string memory _name, bool _value) external;
    
    function getIntAddress(uint256 _keyId) external view returns(address);
    function getStrAddress(string memory _keyName) external view returns(address);
    function getAdrString(address _address) external view returns(string memory);
    function getAdrByte32(address _address) external view returns(bytes32);
    function getAdrUint(address _address) external view returns(uint256);
    function getAdrBool(address _address) external view returns(bool);
    
    function getAdrStrAddress(address _address, string memory _keyName) external view returns(address);
    function getAdrStrString(address _address, string memory _keyName) external view returns(string memory);
    function getAdrStrByte32(address _address, string memory _keyName) external view returns(bytes32);
    function getAdrStrUint(address _address, string memory _keyName) external view returns(uint256);
    function getAdrStrBool(address _address, string memory _keyName) external view returns(bool);
    
    function getIntStrAddress(uint256 _keyId, string memory _keyName) external view returns(address);
    function getIntStrString(uint256 _keyId, string memory _keyName) external view returns(string memory);
    function getIntStrByte32(uint256 _keyId, string memory _keyName) external view returns(bytes32);
    function getIntStrUint(uint256 _keyId, string memory _keyName) external view returns(uint256);
    function getIntStrBool(uint256 _keyId, string memory _keyName) external view returns(bool);
    
    function getIntStrIntAddress(uint256 _keyId, string memory _keyName, uint256 _refId) external view returns(address);
    function getIntStrIntString(uint256 _keyId, string memory _keyName, uint256 _refId) external view returns(string memory);
    function getIntStrIntByte32(uint256 _keyId, string memory _keyName, uint256 _refId) external view returns(bytes32);
    function getIntStrIntUint(uint256 _keyId, string memory _keyName, uint256 _refId) external view returns(uint256);
    function getIntStrIntBool(uint256 _keyId, string memory _keyName, uint256 _refId) external view returns(bool);
    
    function getAdrStrIntAddress(address _address, string memory _keyName, uint256 _refId) external view returns(address);
    function getAdrStrIntString(address _address, string memory _keyName, uint256 _refId) external view returns(string memory);
    function getAdrStrIntByte32(address _address, string memory _keyName, uint256 _refId) external view returns(bytes32);
    function getAdrStrIntUint(address _address, string memory _keyName, uint256 _refId) external view returns(uint256);
    function getAdrStrIntBool(address _address, string memory _keyName, uint256 _refId) external view returns(bool);
    
    function getIntStrManyAddresses(uint256 _keyId, string memory _keyName) external view returns(address[] memory);
    function getIntStrManyStrings(uint256 _keyId, string memory _keyName) external view returns(string[] memory);
    function getIntStrManyByte32(uint256 _keyId, string memory _keyName) external view returns(bytes32[] memory);
    function getIntStrManyUint(uint256 _keyId, string memory _keyName) external view returns(uint256[] memory);
    
    function getAdrStrManyAddresses(address _address, string memory _keyName) external view returns(address[] memory);
    function getAdrStrManyStrings(address _address, string memory _keyName) external view returns(string[] memory);
    function getAdrStrManyByte32(address _address, string memory _keyName) external view returns(bytes32[] memory);
    function getAdrStrManyUint(address _address, string memory _keyName) external view returns(uint256[] memory);

}

contract AccessControl {
    address public owner;
    mapping(address => bool) whitelistController;
    event OwnershipTransferred(address indexed _from, address indexed _to);

    modifier onlyOwner {
        require(msg.sender == owner, "invalid owner");
        _;
    }
    modifier onlyController {
        require(whitelistController[msg.sender] == true, "invalid controller");
        _;
    }
    
    function WhitelistController(address _controller) public onlyOwner {
        whitelistController[_controller] = true;
    }
    function BlacklistController(address _controller) public onlyOwner {
        whitelistController[_controller] = false;
    }
    
    function Controller(address _controller) public view returns(bool) {
        return whitelistController[_controller];
    }
}

contract DataStorage is IStorage, AccessControl {

  mapping(uint256 => address) intAddress;
  mapping(string => address) strAddress;
  mapping(address => string) adrString;
  mapping(address => uint256) adrUint256;
  mapping(address => bytes32) adrBytes32;
  mapping(address => bool) adrBool;
  
  mapping(address => mapping(string => uint256)) adrStr_dataUint256;
  mapping(address => mapping(string => string)) adrStr_dataString;
  mapping(address => mapping(string => bool)) adrStr_dataBool;
  mapping(address => mapping(string => address)) adrStr_dataAddress;
  mapping(address => mapping(string => bytes32)) adrStr_dataByte32;
  mapping(address => mapping(string => string)) adrStr_dataStr;
  
  mapping(uint256 => mapping(string => mapping (uint256 => address))) strUint_dataAddress;
  mapping(uint256 => mapping(string => mapping (uint256 => string))) strUint_dataString;
  mapping(uint256 => mapping(string => mapping (uint256 => bytes32))) strUint_dataBytes32;
  mapping(uint256 => mapping(string => mapping (uint256 => uint256))) strUint_dataUint256;
  mapping(uint256 => mapping(string => mapping (uint256 => bool))) strUint_dataBool;
  
  mapping(address => mapping(string => mapping (uint256 => address))) adrStrUint_dataAddress;
  mapping(address => mapping(string => mapping (uint256 => string))) adrStrUint_dataString;
  mapping(address => mapping(string => mapping (uint256 => bytes32))) adrStrUint_dataBytes32;
  mapping(address => mapping(string => mapping (uint256 => uint256))) adrStrUint_dataUint256;
  mapping(address => mapping(string => mapping (uint256 => bool))) adrStrUint_dataBool;
  
  mapping(uint256 => mapping(string => address)) str_dataAddress;
  mapping(uint256 => mapping(string => string)) str_dataString;
  mapping(uint256 => mapping(string => bytes32)) str_dataBytes32;
  mapping(uint256 => mapping(string => uint256)) str_dataUint256;
  mapping(uint256 => mapping(string => bool)) str_dataBool;

  mapping(uint256 => mapping(string => address[])) str_dataManyAddresses;
  mapping(uint256 => mapping(string => bytes32[])) str_dataManyBytes32s;
  mapping(uint256 => mapping(string => string[])) str_dataManyStrings;
  mapping(uint256 => mapping(string => uint256[])) str_dataManyUint256;
  mapping(uint256 => mapping(string => bool[])) str_dataManyBool;
  
  mapping(address => mapping(string => address[])) adr_dataManyAddresses;
  mapping(address => mapping(string => bytes32[])) adr_dataManyBytes32s;
  mapping(address => mapping(string => string[])) adr_dataManyStrings;
  mapping(address => mapping(string => uint256[])) adr_dataManyUint256;
  mapping(address => mapping(string => bool[])) adr_dataManyBool;
  
  
  constructor() {
        AccessControl.owner = msg.sender;
    }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //set int  => data type
  function setIntAddress(uint256 _keyId, address _value) onlyController override external virtual  {
      intAddress[_keyId] = _value;
  }
  
  function setStrAddress(string memory _keyName, address _value) onlyController override external virtual  {
      strAddress[_keyName] = _value;
  }
  function setAdrString(address _address, string memory _value) onlyController override external virtual  {
      adrString[_address] = _value;
  }
  function setAdrByte32(address _address,bytes32 _value) onlyController override external virtual  {
      adrBytes32[_address]  = _value;
  }
  function setAdrUint(address _address, uint256 _value) onlyController override external virtual  {
      adrUint256[_address] = _value;
  }
  function setAdrBool(address _address, bool _value) onlyController override external virtual  {
      adrBool[_address] = _value;
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //set int => string => data type
  
  function setIntStrAddress(uint256 _keyId, string memory _name, address _value) onlyController override external virtual  {
      str_dataAddress[_keyId][_name] = _value;
  }
  function setIntStrString(uint256 _keyId, string memory _name, string memory _value) onlyController override external virtual  {
      str_dataString[_keyId][_name] = _value;
  }
  function setIntStrByte32(uint256 _keyId, string memory _name, bytes32 _value) onlyController override external virtual  {
      str_dataBytes32[_keyId][_name] = _value;
  }
  function setIntStrUint(uint256 _keyId, string memory _name, uint256 _value) onlyController override external virtual  {
      str_dataUint256[_keyId][_name] = _value;
  }
  function setIntStrBool(uint256 _keyId, string memory _name, bool _value) onlyController override external virtual  {
      str_dataBool[_keyId][_name] = _value;
  }
  
   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //set int => string => int => data type
  
  function setIntStrIntAddress(uint256 _keyId, string memory _name, uint256 _refId, address _value) onlyController override external virtual  {
      strUint_dataAddress[_keyId][_name][_refId] = _value;
  }
  function setIntStrIntString(uint256 _keyId, string memory _name, uint256 _refId, string memory _value) onlyController override external virtual  {
      strUint_dataString[_keyId][_name][_refId] = _value;
  }
  function setIntStrIntByte32(uint256 _keyId, string memory _name, uint256 _refId, bytes32 _value) onlyController override external virtual  {
      strUint_dataBytes32[_keyId][_name][_refId] = _value;
  }
  function setIntStrIntUint(uint256 _keyId, string memory _name, uint256 _refId, uint256 _value) onlyController override external virtual  {
      strUint_dataUint256[_keyId][_name][_refId] = _value;
  }
  function setIntStrIntBool(uint256 _keyId, string memory _name, uint256 _refId, bool _value) onlyController override external virtual  {
      strUint_dataBool[_keyId][_name][_refId] = _value;
  }
  
   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //set address => string => int => data type
  
  function setAdrStrIntAddress(address _address, string memory _name, uint256 _refId, address _value) onlyController override external virtual  {
      adrStrUint_dataAddress[_address][_name][_refId] = _value;
  }
  function setAdrStrIntString(address _address, string memory _name, uint256 _refId, string memory _value) onlyController override external virtual  {
      adrStrUint_dataString[_address][_name][_refId] = _value;
  }
  function setAdrStrIntByte32(address _address, string memory _name, uint256 _refId, bytes32 _value) onlyController override external virtual  {
      adrStrUint_dataBytes32[_address][_name][_refId] = _value;
  }
  function setAdrStrIntUint(address _address, string memory _name, uint256 _refId, uint256 _value) onlyController override external virtual  {
      adrStrUint_dataUint256[_address][_name][_refId] = _value;
  }
  function setAdrStrIntBool(address _address, string memory _name, uint256 _refId, bool _value) onlyController override external virtual  {
      adrStrUint_dataBool[_address][_name][_refId] = _value;
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //set address => string => data type
  
  function setAdrStrAddress(address _address, string memory _name, address _value) onlyController override external virtual  {
      adrStr_dataAddress[_address][_name] = _value;
  }
  function setAdrStrString(address _address, string memory _name, string memory _value) onlyController override external virtual  {
      adrStr_dataString[_address][_name] = _value;
  }
  function setAdrStrByte32(address _address, string memory _name, bytes32 _value) onlyController override external virtual  {
      adrStr_dataByte32[_address][_name] = _value;
  }
  function setAdrStrUint(address _address, string memory _name, uint256 _value) onlyController override external virtual  {
      adrStr_dataUint256[_address][_name] = _value;
  }
  function setAdrStrBool(address _address, string memory _name, bool _value) onlyController override external virtual  {
      adrStr_dataBool[_address][_name] = _value;
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //set int => string => many 
  function setIntStrManyAddress(uint256 _keyId, string memory _name, address _value) onlyController override external  virtual  {
      str_dataManyAddresses[_keyId][_name].push(_value);
  }
  function setIntStrManyString(uint256 _keyId, string memory _name, string memory _value) onlyController override external virtual  {
      str_dataManyStrings[_keyId][_name].push(_value);
  }
  function setIntStrManyByte32(uint256 _keyId, string memory _name, bytes32 _value) onlyController override external virtual  {
      str_dataManyBytes32s[_keyId][_name].push(_value);
  }
  function setIntStrManyUint(uint256 _keyId, string memory _name, uint256 _value) onlyController override external virtual  {
      str_dataManyUint256[_keyId][_name].push(_value);
  }
  function setIntStrManyBool(uint256 _keyId, string memory _name, bool _value)  onlyController override external virtual  {
      str_dataManyBool[_keyId][_name].push(_value);
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //set address => string => many 
  function setAdrStrManyAddress(address _address, string memory _name, address _value) onlyController override external  virtual  {
      adr_dataManyAddresses[_address][_name].push(_value);
  }
  function setAdrStrManyString(address _address, string memory _name, string memory _value) onlyController override external virtual  {
      adr_dataManyStrings[_address][_name].push(_value);
  }
  function setAdrStrManyByte32(address _address, string memory _name, bytes32 _value) onlyController override external virtual  {
      adr_dataManyBytes32s[_address][_name].push(_value);
  }
  function setAdrStrManyUint(address _address, string memory _name, uint256 _value) onlyController override external virtual  {
      adr_dataManyUint256[_address][_name].push(_value);
  }
  function setAdrStrManyBool(address _address, string memory _name, bool _value)  onlyController override external virtual  {
      adr_dataManyBool[_address][_name].push(_value);
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //get
  
  function getIntAddress(uint256 _keyId) override public view virtual returns(address){
      return intAddress[_keyId];
  }
  
  function getStrAddress(string memory _keyName) override public view virtual returns(address){
      return strAddress[_keyName];
  }
  function getAdrString(address _address)  override public view virtual  returns(string memory){
      return adrString[_address];
  }
  function getAdrByte32(address _address) override public view virtual returns(bytes32) {
      return adrBytes32[_address];
  }
  function getAdrUint(address _address) override public view virtual  returns(uint256){
      return adrUint256[_address];
  }
  function getAdrBool(address _address) override public view virtual  returns(bool){
      return adrBool[_address];
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //returns single data
  
  function getIntStrAddress(uint256 _keyId, string memory _keyName) override public view virtual returns(address){
      return str_dataAddress[_keyId][_keyName];
  }
  
  function getIntStrString(uint256 _keyId, string memory _keyName)  override public view virtual  returns(string memory){
      return str_dataString[_keyId][_keyName];
  }
  function getIntStrByte32(uint256 _keyId, string memory _keyName) override public view virtual returns(bytes32) {
      return str_dataBytes32[_keyId][_keyName];
  }
  function getIntStrUint(uint256 _keyId, string memory _keyName) override public view virtual  returns(uint256){
      return str_dataUint256[_keyId][_keyName];
  }
  function getIntStrBool(uint256 _keyId, string memory _keyName) override public view virtual  returns(bool){
      return str_dataBool[_keyId][_keyName];
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //returns single data
  
  function getIntStrIntAddress(uint256 _keyId, string memory _keyName, uint256 _refId) override public view virtual returns(address){
      return strUint_dataAddress[_keyId][_keyName][_refId];
  }
  
  function getIntStrIntString(uint256 _keyId, string memory _keyName, uint256 _refId)  override public view virtual  returns(string memory){
      return strUint_dataString[_keyId][_keyName][_refId];
  }
  function getIntStrIntByte32(uint256 _keyId, string memory _keyName, uint256 _refId) override public view virtual returns(bytes32) {
      return strUint_dataBytes32[_keyId][_keyName][_refId];
  }
  function getIntStrIntUint(uint256 _keyId, string memory _keyName, uint256 _refId) override public view virtual  returns(uint256){
      return strUint_dataUint256[_keyId][_keyName][_refId];
  }
  function getIntStrIntBool(uint256 _keyId, string memory _keyName, uint256 _refId) override public view virtual  returns(bool){
      return strUint_dataBool[_keyId][_keyName][_refId];
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //returns single data
  
  function getAdrStrIntAddress(address _address, string memory _keyName, uint256 _refId) override public view virtual returns(address){
      return adrStrUint_dataAddress[_address][_keyName][_refId];
  }
  
  function getAdrStrIntString(address _address, string memory _keyName, uint256 _refId)  override public view virtual  returns(string memory){
      return adrStrUint_dataString[_address][_keyName][_refId];
  }
  function getAdrStrIntByte32(address _address, string memory _keyName, uint256 _refId) override public view virtual returns(bytes32) {
      return adrStrUint_dataBytes32[_address][_keyName][_refId];
  }
  function getAdrStrIntUint(address _address, string memory _keyName, uint256 _refId) override public view virtual  returns(uint256){
      return adrStrUint_dataUint256[_address][_keyName][_refId];
  }
  function getAdrStrIntBool(address _address, string memory _keyName, uint256 _refId) override public view virtual  returns(bool){
      return adrStrUint_dataBool[_address][_keyName][_refId];
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //returns single data
  
  function getAdrStrAddress(address _address, string memory _keyName) override public view virtual returns(address){
      return adrStr_dataAddress[_address][_keyName];
  }
  
  function getAdrStrString(address _address, string memory _keyName)  override public view virtual  returns(string memory){
      return adrStr_dataString[_address][_keyName];
  }
  function getAdrStrByte32(address _address, string memory _keyName) override public view virtual returns(bytes32) {
      return adrStr_dataByte32[_address][_keyName];
  }
  function getAdrStrUint(address _address, string memory _keyName) override public view virtual  returns(uint256){
      return adrStr_dataUint256[_address][_keyName];
  }
  function getAdrStrBool(address _address, string memory _keyName) override public view virtual  returns(bool){
      return adrStr_dataBool[_address][_keyName];
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //returns array
  
  function getIntStrManyAddresses(uint256 _keyId, string memory _keyName) override public view virtual returns(address[] memory){
      return str_dataManyAddresses[_keyId][_keyName];
  }
  
  function getIntStrManyStrings(uint256 _keyId, string memory _keyName)  override public view virtual  returns(string[] memory){
      return str_dataManyStrings[_keyId][_keyName];
  }
  function getIntStrManyByte32(uint256 _keyId, string memory _keyName) override public view virtual returns(bytes32[] memory) {
      return str_dataManyBytes32s[_keyId][_keyName];
  }
  function getIntStrManyUint(uint256 _keyId, string memory _keyName) override public view virtual  returns(uint256[] memory){
      return str_dataManyUint256[_keyId][_keyName];
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //returns array
  
  function getAdrStrManyAddresses(address _address, string memory _keyName) override public view virtual returns(address[] memory){
      return adr_dataManyAddresses[_address][_keyName];
  }
  
  function getAdrStrManyStrings(address _address, string memory _keyName)  override public view virtual  returns(string[] memory){
      return adr_dataManyStrings[_address][_keyName];
  }
  function getAdrStrManyByte32(address _address, string memory _keyName) override public view virtual returns(bytes32[] memory) {
      return adr_dataManyBytes32s[_address][_keyName];
  }
  function getAdrStrManyUint(address _address, string memory _keyName) override public view virtual  returns(uint256[] memory){
      return adr_dataManyUint256[_address][_keyName];
  }


}