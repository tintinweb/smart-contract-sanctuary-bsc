/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 * @author OutDev Team
 * @title Distribution
 * @notice Contract that distribute initial earns in agreed slices.
 */
contract Distribution {
  address private constant RECEIVER_1 = 0x31c248a799131Ee0e7D0055E7829b8487c16911a;
  address private constant RECEIVER_2 = 0xdD82cFaD3176AFc326996f16Ff56ae876Dc8918f;

  uint256 private constant PERCENT_RECEIVER_1 = 20;
  uint256 private constant PERCENT_RECEIVER_2 = 80;

  uint256 public amountReceiver1;
  uint256 public amountReceiver2;

  uint256 private constant _NOT_ENTERED = 1;
  uint256 private constant _ENTERED = 2;

  uint256 private _status;

  constructor() {
    _status = _NOT_ENTERED;
  }

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   */
  modifier nonReentrant() {
    _nonReentrantBefore();
    _;
    _nonReentrantAfter();
  }

  /**
   * @dev Set state of reentrancy state to True
   * @custom:restriction Cannot be accessed if reentrancy
   *  state is True already
   */
  function _nonReentrantBefore() private {
    require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
    _status = _ENTERED;
  }

  /**
   * @dev Set state of reentrancy state to False
   */
  function _nonReentrantAfter() private {
    _status = _NOT_ENTERED;
  }

  /**
   * @dev Prevent a contract from be called for no members
   */
  modifier onlyMembers() {
    require(msg.sender == RECEIVER_1 || msg.sender == RECEIVER_2, "You are not allowed to execute this method");
    _;
  }

  /**
   * @dev Get caller's balance in the contract.
   * @custom:restriction Cannot be accessed if caller is not member.
   * @return amount returns caller's ether available.
   */
  function balance() external view onlyMembers returns (uint256 amount) {
    uint256 percent = msg.sender == RECEIVER_1 ? PERCENT_RECEIVER_1 : PERCENT_RECEIVER_2;
    amount = (address(this).balance * percent) / 100;
    return amount;
  }

  /**
   * @dev Transfer caller's available balance.
   * @custom:restriction Cannot be accessed if caller is not member.
   */
  function getProfits() external onlyMembers nonReentrant {
    uint256 amount1 = (address(this).balance * PERCENT_RECEIVER_1) / 100;
    uint256 amount2 = (address(this).balance * PERCENT_RECEIVER_2) / 100;

    amountReceiver1 += amount1;
    amountReceiver2 += amount2;

    (bool sent1, ) = payable(RECEIVER_1).call{value: amount1}("");
    (bool sent2, ) = payable(RECEIVER_2).call{value: amount2}("");

    require(sent1 && sent2, "Error at transfer.");
  }

  receive() external payable {}

  fallback() external payable {}
}