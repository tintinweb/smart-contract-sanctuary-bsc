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

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
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

contract HokbSwapV2 is Context, Ownable {

  IDEXRouter public router;
  address public pcv2 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
  address public token = 0x3d02B82ACBC64dAD2c4d82768dfA42B12E26a74a;
  
  address public receiver;
  uint256 public fee = 80;
  uint256 denominator = 1000;

  bool reentrantcy;
  modifier noReentrant() {
    require(!reentrantcy, "!REENTRANTCY");
    reentrantcy = true;
    _;
    reentrantcy = false;
  }

  constructor() {
    router = IDEXRouter(pcv2);
    receiver = 0x18AF0D83f20AF6A00e8796dCEEde5117A42C0C50;
  }

  function HokkenSwap(uint amountOutMin,address[] calldata path,address to,uint deadline) public payable noReentrant returns (bool) {
    router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value : msg.value }(
    amountOutMin,
    path,
    address(this),
    deadline
    );
    uint256 amount = IERC20(token).balanceOf(address(this));
    uint256 amountA = amount * fee / denominator;
    uint256 amountB = amount - amountA;
    IERC20(token).transfer(receiver,amountA);
    IERC20(token).transfer(to,amountB);
    return true;
  }

  function setting(address _receiver,address _token,uint256 _fee) public onlyOwner returns (bool) {
    receiver = _receiver;
    token = _token;
    fee = _fee;
    return true;
  }

  function excretion(address adr,address to,uint256 amount) external onlyOwner returns (bool) {
    IERC20(adr).transfer(to,amount);
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