/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

pragma solidity 0.5.16;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract ScammeStore is Context, Ownable {
  
  mapping (uint256 => string) public data_name;
  mapping (uint256 => string) public data_symbol;
  mapping (uint256 => uint256) public data_supply;
  mapping (uint256 => address) public data_owner;
  mapping (uint256 => uint256) public data_stat;

  uint256 public orderindex;
  uint256 public tokenprice;

  constructor() public {
  tokenprice = 300000000000000000;
  //status 0:error 1:pending 2:success
  }

  function getBNB() public view returns (uint256) {
	return address(this).balance;
  }

  function settokenprice(uint256 _price) public onlyOwner {
    tokenprice = _price;
  }

  function updatestat(uint256 index,uint256 _flag) public onlyOwner {
    data_stat[index] = _flag;
  }

  function withdraw() external onlyOwner {
    msg.sender.transfer(getBNB());
  }

  function ordertoken(string memory _name,string memory _symbol,uint256 _supply,address _owner) public payable {
    if ( msg.value >= tokenprice ) {
        orderindex = orderindex + 1;
        data_name[orderindex] = _name;
        data_symbol[orderindex] = _symbol;
        data_supply[orderindex] = _supply;
        data_owner[orderindex] = _owner;
        data_stat[orderindex] = 1;
    }
  }

  function getCurrentOrder() external view returns (uint256) {
    uint256 result = 0;
    for (uint i = 0; i <= orderindex; i++) {
      if ( data_stat[i] == 1 ) {
        result = result + 1;
      }
    }
    return result;
  }

  function getNextOrder() external view returns (uint256) {
    for (uint i = 0; i <= orderindex; i++) {
      if ( data_stat[i] == 1 ) {
        return i;
      }
    }
  }

}