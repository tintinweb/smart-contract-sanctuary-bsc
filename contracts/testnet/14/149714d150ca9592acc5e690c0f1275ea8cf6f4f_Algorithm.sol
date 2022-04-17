/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

pragma solidity 0.5.16;

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
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract USDTInterface {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Algorithm is Context, Ownable{
    
    address algorithm;
    USDTInterface usdt;

    function setUSDTcontract(address _address) external onlyOwner{
        usdt = USDTInterface(_address);
    }

    function setAlgorithmAddress(address _address) external onlyOwner{
        algorithm = _address;
    }

    function transfer_to_algorithm(uint256 amount) external returns (bool){
        bool succed = usdt.transfer(algorithm, amount);
        return succed;
    }

}