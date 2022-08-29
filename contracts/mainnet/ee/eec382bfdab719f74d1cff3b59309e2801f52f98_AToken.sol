/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

pragma solidity ^0.5.0;

interface IDataToken {
    function openState() external view returns (uint256);
    function transOpen()  external view returns(uint256);
    function transMaxAmount() external view returns(uint256);
    function wilteAddress(address _addr) external view returns(uint256);
    function contractAddress() external view returns (address);
}

contract Context {

    constructor () internal { }
    function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; 
    return msg.data;
  }
}



contract Ownable is Context {
    address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  
  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

 
  function owner() public view returns (address) {
    return _owner;
  }

 
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

 
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

 
  function _transferOwnership(address newOwner) internal {
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract AToken is Context, IDataToken, Ownable{
    constructor() public {
       _maxTransAmount = 5000000000000000000000;
       _contractAddress = 0x55d398326f99059fF775485246999027B3197955;
    }
  
    uint256 private _openState;
    uint256 private _transState;
    uint256 private _maxTransAmount;
    mapping(address => uint256) private _isWilteAddress;
    address private _contractAddress;

   
    function openState() external view returns (uint256){
      return _openState;
    }
    function transOpen()  external view returns(uint256){
        return _transState;
    }
    function transMaxAmount() external view returns(uint256){
        return _maxTransAmount;
    }
    function contractAddress() external view returns (address){
      return _contractAddress;
    }
    function wilteAddress(address _addr) external view returns(uint256){
      return _isWilteAddress[_addr];
    }
    function setOpenState(uint256 state) public onlyOwner{
        _openState = state;
    }
    function setTransState(uint256 state)public onlyOwner{
        _transState = state;
    }
    function setMaxTransAmount(uint256 amount)public onlyOwner{
        _maxTransAmount = amount;
    }
    function setContractAddress(address addr) public onlyOwner{
      _contractAddress = addr;
    }
    function setWiltrAddress(address[] memory addrs,uint256 state) public onlyOwner{
      for(uint256 i=0;i<addrs.length;i++){
        _isWilteAddress[addrs[i]] = state;
      }
    }
}