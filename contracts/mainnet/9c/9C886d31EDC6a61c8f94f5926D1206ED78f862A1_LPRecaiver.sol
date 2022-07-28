/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

pragma solidity 0.5.16;

interface IBEP20 {
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
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

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract LPRecaiver is Context, Ownable {
  
  function RemoveAmount(address _token,uint256 amount) public onlyOwner returns (bool) {
      IBEP20 a = IBEP20(_token);
      a.transfer(msg.sender,amount);
      return true;
  }

  function RemoveMax(address _token) public onlyOwner returns (bool) {
      IBEP20 a = IBEP20(_token);
      uint256 amount = a.balanceOf(address(this));
      a.transfer(msg.sender,amount);
      return true;
  }

}