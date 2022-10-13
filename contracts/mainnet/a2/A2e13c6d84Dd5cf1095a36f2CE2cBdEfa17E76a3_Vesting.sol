/**
 *Submitted for verification at BscScan.com on 2022-10-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Vesting{

  event Released(uint256 amount);

  mapping(address => address) beneficiary;
  uint256 public cliff;
  uint256 public start;
  uint256 public duration;
  mapping (address => uint256) public released;
  address owner;

  constructor(
    address _token01,
    address _token02,
    address _beneficiary01,
    address _beneficiary02,
    uint256 _start,
    uint256 _cliff,
    uint256 _duration
  )
  {
    require(_beneficiary01 != address(0));
    require(_beneficiary02 != address(0));
    require(_cliff <= _duration);
    beneficiary[_token01] = _beneficiary01;
    beneficiary[_token02] = _beneficiary02;
    duration = _duration;
    cliff = _start + _cliff;
    start = _start;
    owner = msg.sender;
  }

  /**
   * @notice Transfers vested tokens to beneficiary.
   * @param _token Colorbay token which is being vested
   */
  function release(address _token) public {
    uint256 unreleased = releasableAmount(_token);

    require(unreleased > 0);

    released[_token] = released[_token] + unreleased;

    require(IERC20(_token).transfer(beneficiary[_token], unreleased));

    emit Released(unreleased);
  }

  /**
   * @dev Calculates the amount that has already vested but hasn't been released yet.
   * @param _token Colorbay token which is being vested
   */
  function releasableAmount(address _token) public view returns (uint256) {
    return vestedAmount(_token) - released[_token];
  }

  /**
   * @dev Calculates the amount that has already vested.
   * @param _token ERC20 token which is being vested
   */
  function vestedAmount(address _token) public view returns (uint256) {
    uint256 currentBalance = IERC20(_token).balanceOf(address(this));
    uint256 totalBalance = currentBalance + released[_token];
    if (block.timestamp < cliff) {
      return 0;
    } else if (block.timestamp >= start + duration) {
      return totalBalance;
    } else {
      return totalBalance * (block.timestamp - start) / duration;
    }
  }

  function withdraw(address token,address to,uint256 amount) external{
    require(owner == msg.sender);
    require(IERC20(token).transfer(to, amount));
  }

}