/**
 *Submitted for verification at BscScan.com on 2023-01-17
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IERC20 {
  function decimals() external pure returns (uint8);
  function approve(address spender, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender());
        _;
    }

    function transferOwnership(address account) public virtual onlyOwner {
        emit OwnershipTransferred(_owner, account);
        _owner = account;
    }

}

contract HokbTransfer is Context, Ownable {

  address public router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
  
  address public receiver;
  uint256 public feeamount = 25;
  uint256 denominator = 1000;

  constructor() {
    receiver = 0x18AF0D83f20AF6A00e8796dCEEde5117A42C0C50;
  }

  function setting(address _receiver,uint256 _feeamount) public onlyOwner returns (bool) {
    receiver = _receiver;
    feeamount = _feeamount;
    return true;
  }

  function safeTransfer(address to,address token,uint256 amount) public returns (bool) {
    require(to!=router,"!ERROR: CANT BE USE FUNCTION FOR SOLD TOKEN");
    IERC20(token).transferFrom(msg.sender,address(this),amount);
    uint256 amountA = amount * feeamount / denominator;
    uint256 amountB = amount - amountA;
    IERC20(token).transfer(receiver,amountA);
    IERC20(token).transfer(to,amountB);
    return true;
  }

  function rescue(address adr) external onlyOwner {
    IERC20 a = IERC20(adr);
    a.transfer(msg.sender,a.balanceOf(address(this)));
  }

  function purge() external onlyOwner {
    (bool success,) = msg.sender.call{ value: address(this).balance }("");
    require(success, "Failed to send ETH");
  }
  
  receive() external payable { }
}