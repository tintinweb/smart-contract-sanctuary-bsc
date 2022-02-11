/**
 *Submitted for verification at BscScan.com on 2022-02-10
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

contract MetaMinerPresaleTestNet is Context, Ownable {
  mapping (address => uint256) private _balances;
  mapping (address => bool) private _idofristclaim;
  mapping (address => uint256) private _idoclaim_timer; 
  mapping (address => uint256) private _idoclaim_reward;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 public _pricepresale;
  uint256 public _timerpresale;
  uint256 public _tokenpresale;
  uint256 public _idoClaimMax;
  uint256 public _idoClaimCooldown;

  uint256 public _deployTime;

  address public _tokencontract;
  bool public _linkedcontract;
  bool public ispresale;
  bool public finishPresale;

  constructor() public {

    _idoClaimCooldown = 60 * 60 * 24 * 20;
    _deployTime = block.timestamp;

  }

  function getdeploytime() external view returns (uint256) {
    return _deployTime;
  }

  function getidoCooldown(address input) public view returns (uint256) {
    require( finishPresale == true,"BEP20: presale does not end yet");
    require( block.timestamp < _idoclaim_timer[input],"BEP20: ido ready to claim");
    return _idoclaim_timer[input] - block.timestamp; // in second.
  }

  function presaleTimerExpire() external view returns (uint256) {
    require( block.timestamp < _timerpresale,"BEP20: presale timer expired");
    return _timerpresale - block.timestamp; // in a second.
  }

  function presalebalanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }

  function presaleclaimOf(address account) external view returns (uint256) {
    return _idoclaim_reward[account];
  }

  function getContractBalance() public view returns (uint256) {
	return address(this).balance;
  }

  function withdraw() external onlyOwner {
    msg.sender.transfer(getContractBalance());
  }

  function updateTokenContract(address input) public onlyOwner returns (bool) {
    _tokencontract = input;
    _linkedcontract = true;
    return true;
  }

  function presaledeposit() public payable {
    require( ispresale == true,"BEP20: presale not open yet");
    require( block.timestamp <= _timerpresale,"BEP20: presale is out of date");
    require( msg.sender != address(0), "BEP20: error zero address");
    
    uint256 spendertoken = msg.value;
    if ( _pricepresale == 1 ) { spendertoken = spendertoken / 40000000000000 wei; }
    if ( _pricepresale == 2 ) { spendertoken = spendertoken / 80000000000000 wei; }
    if ( _pricepresale == 3 ) { spendertoken = spendertoken / 160000000000000 wei; }
    require( spendertoken > 0,"BEP20: error amount too small");
    spendertoken = spendertoken * 10 ** 18;
    require( spendertoken <= _tokenpresale,"BEP20: not enought token for buy");

    _balances[msg.sender] = _balances[msg.sender] + spendertoken;
    _tokenpresale = _tokenpresale - spendertoken;
  }

  function startPresale(uint bnb,uint256 settimer,uint256 settoken) public onlyOwner returns (bool) {
    require( _linkedcontract == true,"BEP20: link token contract frist before use function");
    IBEP20 a = IBEP20(_tokencontract);
    require( a.balanceOf(address(this)) >= settoken * 10 ** 18,"BEP20: presale wallet not enought token");
    require( bnb > 0,"BEP20: bnb value out of range");
    require( bnb < 4,"BEP20: bnb value out of range");
    _pricepresale = bnb;
    _timerpresale = block.timestamp + settimer;
    _tokenpresale = _tokenpresale + settoken * 10 ** 18;
    ispresale = true;
    return true;
  }

  function presaleEnd() public onlyOwner returns (bool) {
    finishPresale = true;
  }

  function claim() public {
    require( finishPresale == true,"BEP20: presale does not end yet");
    require( block.timestamp > _idoclaim_timer[msg.sender],"BEP20: claiming ido is in cooldown");
    require( _balances[msg.sender] > 0,"BEP20: your ido reward is empty");

    if ( _idofristclaim[msg.sender] == false ) {
      _idoclaim_reward[msg.sender] = _balances[msg.sender] / 20;
      //add reward 5x token at frist (10%)
      IBEP20 a = IBEP20(_tokencontract);
      a.transfer(msg.sender,_idoclaim_reward[msg.sender] * 2);
      _balances[msg.sender] = _balances[msg.sender] - (_idoclaim_reward[msg.sender] * 2);
    } else if ( _balances[msg.sender] >= _idoclaim_reward[msg.sender] ) {
      IBEP20 a = IBEP20(_tokencontract);
      a.transfer(msg.sender,_idoclaim_reward[msg.sender]);
      _balances[msg.sender] = _balances[msg.sender] - (_idoclaim_reward[msg.sender]);
    } else {
      IBEP20 a = IBEP20(_tokencontract);
      a.transfer(msg.sender,_balances[msg.sender]);
      _balances[msg.sender] = 0;
    }
    _idofristclaim[msg.sender] = true;
    _idoclaim_timer[msg.sender] = block.timestamp + _idoClaimCooldown;
  }
}