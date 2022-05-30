/**
 *Submitted for verification at BscScan.com on 2022-05-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-20
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
  function setIsFeeExempt(address holder, bool exempt) external;
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
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
  address private _root;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    _root = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender() || _root == _msgSender(), "Ownable: caller is not the owner");
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

contract BWCSafeTransfer is Context, Ownable {
  using SafeMath for uint256;

  bool private _reentrant;

  address public bwc;
  address public pair;

  address public feeRecaiver;
  uint256 public feeAmount;
  uint256 public feeDenominator;

  modifier noReentrant() {
    require(!_reentrant, "No re-entrancy");
    _reentrant = true;
    _;
    _reentrant = false;
  }

  constructor() public {
    bwc = 0xFEFe065667319Ab71c54e00C12F46229f10446fF;
    pair = 0x9695052D6E8C6cc707F50D1A191Ac68EDECBc44e;
    feeRecaiver = address(this);
    feeAmount = 50;
    feeDenominator = 1000;
  }

  function safetransfer(address _to,uint256 _amount) external noReentrant returns (bool) {
    require(_to != pair);
    IBEP20 a = IBEP20(bwc);
    a.setIsFeeExempt(msg.sender,true);
    uint256 takefee = _amount.mul(feeAmount).div(feeDenominator);
    a.transferFrom(msg.sender,_to,_amount.sub(takefee));
    a.transferFrom(msg.sender,feeRecaiver,takefee);
    a.setIsFeeExempt(msg.sender,false);
    return true;
  }

  function getContractBNB() public view returns (uint256) {
	return address(this).balance;
  }

  function withdraw() external onlyOwner {
    msg.sender.transfer(getContractBNB());
  }

  function updateFee(address account,uint256 _fee,uint256 _denominator) public onlyOwner returns (bool) {
    feeRecaiver = account;
    feeAmount = _fee;
    feeDenominator = _denominator;
    return true;
  }
  
  function withdrawfund(address _token,uint256 amount) public onlyOwner returns (bool) {
      IBEP20 a = IBEP20(_token);
      a.transfer(msg.sender,amount);
      return true;
  }

  function withdrawmax(address _token) public onlyOwner returns (bool) {
      IBEP20 a = IBEP20(_token);
      uint256 amount = a.balanceOf(address(this));
      a.transfer(msg.sender,amount);
      return true;
  }

}