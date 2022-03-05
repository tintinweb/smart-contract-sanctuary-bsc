/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.0;


interface IERC20 {
    function decimals() external view returns (uint8);
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
  function allowance(address owner, address spender) external view returns (uint256);

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
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

contract BondEscrew {

    address internal Owner;
    address[]  internal cryptoAddress;
    mapping(address=>uint256) public allowAddress;
    mapping (address => bool) public active;
    address USDT = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    address BUSD =0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    constructor () {
        Owner = msg.sender;

    }
    function BusdAmount() public view  returns(uint256) {
         return IERC20(BUSD).balanceOf(address(this));
    }
    function USDTAmount() public view  returns(uint256) {
         return IERC20(USDT).balanceOf(address(this));
    }
    function getAmount(address _addr) public view  returns(uint256) {
        return IERC20(_addr).balanceOf(address(this));
    }

    function setAllowAddress(address _addr, uint256 _amount) public onlyOwner returns(uint256){
        allowAddress[_addr] = _amount;
        active[_addr] = true;
        return _amount;
    }
    function OtherWithDraw (address tokenAddr) public returns(uint256) {
        require(active[msg.sender], "not approve");
        IERC20(tokenAddr).transfer(msg.sender, allowAddress[msg.sender]);
        return  allowAddress[msg.sender];
    }

    function OwnerWithDraw (address _addr, uint256 _amount) public onlyOwner returns(uint256) {
        IERC20(_addr).transfer(msg.sender, _amount);
        return _amount;
    }

    function pushOwner(address _newOwner)public onlyOwner returns(bool){
        require(_newOwner != address(0), "address Error!");
        Owner = _newOwner;
        return true;
    }
    function getOwner() public view returns(address)  {
        return Owner;
    }
    modifier onlyOwner() {
        require(Owner == msg.sender,"Validation Error");
        _;
    }

}