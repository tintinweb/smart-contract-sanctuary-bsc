/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface IERC20 {
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
}

interface IOracle {
  function getPrice() external view returns (uint256);
}

contract LiquidityPool {
  IERC20 public BNB;
  IERC20 public USDC;
  IOracle public oracle;

  address public owner;
  mapping (address => uint256) public allowed;

  constructor(address _BNB, address _USDC, address _oracle) {
    BNB = IERC20(_BNB);
    USDC = IERC20(_USDC);
    oracle = IOracle(_oracle);
    owner = msg.sender;
  }

  function addLiquidity(uint256 _BNBAmount, uint256 _USDCAmount) public {
    require(BNB.transferFrom(msg.sender, address(this), _BNBAmount), "transfer BNB failed");
    require(USDC.transferFrom(msg.sender, address(this), _USDCAmount), "transfer USDC failed");
  }

  function removeLiquidity(uint256 _BNBAmount, uint256 _USDCAmount) public {
    require(BNB.balanceOf(address(this)) >= _BNBAmount, "BNB balance insufficient");
    require(USDC.balanceOf(address(this)) >= _USDCAmount, "USDC balance insufficient");
    require(BNB.transfer(msg.sender, _BNBAmount), "transfer BNB failed");
    require(USDC.transfer(msg.sender, _USDCAmount), "transfer USDC failed");
  }

  function checkPrice() public view returns (uint256) {
    return oracle.getPrice();
  }

  function buyBNB(uint256 _USDCAmount) public {
    uint256 price = checkPrice();
    uint256 BNBAmount = _USDCAmount / price;
    require(USDC.transferFrom(msg.sender, address(this), _USDCAmount), "transfer USDC failed");
    require(BNB.transfer(msg.sender, BNBAmount), "transfer BNB failed");
  }

  function sellBNB(uint256 _BNBAmount) public {
    uint256 price = checkPrice();
    uint256 USDCAmount = _BNBAmount * price;
    require(BNB.transferFrom(msg.sender, address(this), _BNBAmount), "transfer BNB failed");
    require(USDC.transfer(msg.sender, USDCAmount), "transfer USDC failed");
  }

  function buyUSDC(uint256 _BNBAmount) public {
    uint256 price = checkPrice();
    uint256 USDCAmount = _BNBAmount * price;
    require(BNB.transferFrom(msg.sender, address(this), _BNBAmount), "transfer BNB failed");
require(USDC.transfer(msg.sender, USDCAmount), "transfer USDC failed");
}

function sellUSDC(uint256 _USDCAmount) public {
uint256 price = checkPrice();
uint256 BNBAmount = _USDCAmount / price;
require(USDC.transferFrom(msg.sender, address(this), _USDCAmount), "transfer USDC failed");
require(BNB.transfer(msg.sender, BNBAmount), "transfer BNB failed");
}

function approve(address spender, uint256 amount) public returns (bool) {
require(spender != address(0), "invalid spender");
allowed[spender] = amount;
return true;
}

function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
require(sender != address(0), "invalid sender");
require(recipient != address(0), "invalid recipient");
require(amount <= allowed[sender], "amount exceeds allowance");
allowed[sender] -= amount;
return true;
}
}