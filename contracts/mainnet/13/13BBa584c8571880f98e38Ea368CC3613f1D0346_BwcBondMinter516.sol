/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

pragma solidity 0.5.10;

interface IBEP20 {
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface INFT {
  function MintFor(address account,uint256 amount) external returns (bool);
}

contract Context {
  constructor () internal { }
  function _msgSender() internal view returns (address payable) { return msg.sender; }
  function _msgData() internal view returns (bytes memory) { this; return msg.data; }
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
    require(b > 0, errorMessage);
    uint256 c = a / b;
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

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

}

contract BwcBondMinter516 is Context, Ownable {
  using SafeMath for uint256;

  bool public notpause;
  bool public autodistribute = true;

  address public bwcAddress;
  address public busdAddress;
  address public nftAddress;
  uint256 public bwcPrice;
  uint256 public busdPrice;

  address public receiver;
  address public treasury;

  constructor() public {}

  function changeState() public onlyOwner returns (bool) {
    notpause = !notpause;
    return true;
  }

  function autodistrib() public onlyOwner returns (bool) {
    autodistribute = !autodistribute;
    return true;
  }

  function changeMintingState(address _bwc, address _busd, address _nft, uint256 _bwc_price, uint256 _busd_price) public onlyOwner returns (bool) {
    bwcAddress = _bwc;
    busdAddress = _busd;
    nftAddress = _nft;
    bwcPrice = _bwc_price;
    busdPrice = _busd_price;
    return true;
  }

  function setupReceiver(address[] memory accounts) public onlyOwner returns (bool) {
    receiver = accounts[0];
    treasury = accounts[1];
    return true;
  }

  function MintNew(address account,uint256 amount) external returns (bool) {
    require(notpause,"MINTING CONTRACT WAS PAUSE");
    IBEP20 bwc = IBEP20(bwcAddress);
    bwc.transferFrom(msg.sender,address(this),bwcPrice.mul(amount));
    IBEP20 busd = IBEP20(busdAddress);
    busd.transferFrom(msg.sender,address(this),busdPrice.mul(amount));
    INFT nft = INFT(nftAddress);
    nft.MintFor(account,amount);
    if(autodistribute){ distribute(); }
    return true;
  }

  function distribute() public {
    IBEP20 busd = IBEP20(busdAddress);
    uint256 busdamount = busd.balanceOf(address(this)); 
    if(busdamount>0){
      uint256 mainamount = busdamount.mul(900).div(1000);
      uint256 secamount = busdamount.mul(100).div(1000);
      busd.transfer(receiver,mainamount);
      busd.transfer(treasury,secamount);
    }
  }

  function rescue(address adr) external onlyOwner {
    IBEP20 a = IBEP20(adr);
    a.transfer(msg.sender,a.balanceOf(address(this)));
  }

  function purge() external onlyOwner {
    address(uint160(msg.sender)).transfer(address(this).balance);
  }

}