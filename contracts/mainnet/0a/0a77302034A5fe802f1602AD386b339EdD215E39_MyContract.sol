/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

pragma solidity ^0.5.4;

interface IERC20 {
  function transfer(address recipient, uint256 amount) external;
  function balanceOf(address account) external view returns (uint256);
  function transferFrom(address sender, address recipient, uint256 amount) external ;
  function decimals() external view returns (uint8);
}

contract Context {
    constructor() internal {}

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

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
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
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract  MyContract is Ownable{
  IERC20 public usdt;
  IERC20 public ft;
  address public guiji;
  constructor(IERC20 _usdt,IERC20 _ft,address _guiji) public  {
    usdt = _usdt;
    ft = _ft;
    guiji = _guiji;
  }

  event TransferUsdtOut(address toAddr, uint amount);
  event TransferFtOut(address toAddr, uint amount);
  event TransferUsdtIn(address sender,address fromAddr, uint amount);

  function updateGuiji(address newGuiji) public onlyOwner {
    guiji = newGuiji;
  }
  
  
  function transferUsdtOut(address toAddr, uint amount) onlyOwner external {
    usdt.transfer(toAddr, amount);
    emit TransferUsdtOut(toAddr, amount);
  }

  function transferFtOut(address toAddr, uint amount) onlyOwner external {
    ft.transfer(toAddr, amount);
    emit TransferFtOut(toAddr, amount);
  }
  
  function transferUsdtIn(uint amount) external {
    ft.transferFrom(msg.sender, guiji, amount);
    emit TransferUsdtIn(msg.sender, guiji, amount);
  }
  
}