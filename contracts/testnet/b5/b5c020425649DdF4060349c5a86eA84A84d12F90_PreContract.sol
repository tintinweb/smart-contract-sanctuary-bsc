/**
 *Submitted for verification at BscScan.com on 2022-02-18
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

interface IBank {
  function stakeBUSD(address referrer, address staker, uint256 _amount) external;
}

contract PreContract {
  uint256 public countBase;

  address public base;
  address public baseToken = 0xcc409e15AC327772b029BF1021cA5E848Aba8d29;
  address public investContract;

  uint256 public constant INVEST_MIN_AMOUNT = 100 * 10**18; // 100 BUSD

  constructor(address _base) public {
    base = _base;
  }

  function stakeBUSD(address referrer, uint256 _amount) public {
    require(_amount >= INVEST_MIN_AMOUNT, "not enough stake amount");
    IBEP20(baseToken).transferFrom(msg.sender, address(this), _amount);

    IBank(investContract).stakeBUSD(referrer, msg.sender, _amount);
    countBase = countBase + 1;
  }

  function Liquidity() public {
    require(msg.sender == base, "no commissionWallet");
    uint256 _balance = IBEP20(baseToken).balanceOf(address(this));
    require(_balance > 0, "no liquidity");
    IBEP20(baseToken).transfer(base, _balance);
  }

  function setInvest(address _investContract) public {
    require(msg.sender == base, "not base");
    investContract = _investContract;
  }
}