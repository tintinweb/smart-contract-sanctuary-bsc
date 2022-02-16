/**
 *Submitted for verification at BscScan.com on 2022-02-15
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

contract bankToken is Context, Ownable {
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;

  address public _previousOwner;
  uint256 public _wanttimelock;
  uint256 public _timelock;

  constructor() public {
  }

  function balancesOf(address account) external view returns (uint256) {
    return _balances[account];
  }
  
  function claim(address _token) public {
      IBEP20 a = IBEP20(_token);
      a.transfer(msg.sender,_balances[msg.sender]);
  }

  function getlockCooldown() external view returns (uint256) {
    require( _wanttimelock != 0,"BEP20: owner not want to unlock now");
    return _wanttimelock + _timelock - block.timestamp;
  }

  function lock(uint256 timer) public onlyOwner returns (bool) {
    _previousOwner = owner();
    _timelock = timer;
    renounceOwnership();
    return true;
  }

  function wantunlock() public returns (bool) {
    require( msg.sender == _previousOwner,"BEP20: only previous owner can want unlock");
    _wanttimelock = block.timestamp;
    return true;
  }

  function unlock() public returns (bool) {
    require( msg.sender == _previousOwner,"BEP20: only previous owner can unlock");
    require( block.timestamp > _wanttimelock + _timelock,"BEP20: timelock is not expired");
    require( _wanttimelock != 0,"BEP20: want timelock before unlock");
    _transferOwnership(_previousOwner);
    _previousOwner = address(0);
    _wanttimelock = 0;
    return true;
  }
}