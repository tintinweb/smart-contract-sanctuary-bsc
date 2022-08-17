/**
 *Submitted for verification at BscScan.com on 2022-08-16
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 * @author OutDev Team
 * @title Distribution
 * @notice Contract that distribute initial earns in agreed slices.
 */
contract Distribution {
  address private immutable PROMOTER;
  address private immutable OPENART;
  address private immutable CREATOR;

  uint256 private constant PERCENT_PROMOTER = 0;
  uint256 private constant PERCENT_OPENART = 40;
  uint256 private constant PERCENT_CREATOR = 60;

  uint256 public amountReceiver1;
  uint256 public amountReceiver2;
  uint256 public amountReceiver3;

  uint256 private constant _NOT_ENTERED = 1;
  uint256 private constant _ENTERED = 2;

  uint256 private _status;

  constructor(
    address openartAddress_,
    address promoterAddress_,
    address creatorAddress_
  ) {
    _status = _NOT_ENTERED;
    PROMOTER = promoterAddress_;
    OPENART = openartAddress_;
    CREATOR = creatorAddress_;
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
    require(
      msg.sender == PROMOTER || msg.sender == OPENART || msg.sender == CREATOR,
      "You are not allowed to execute this method"
    );
    _;
  }

  /**
   * @dev Get caller's balance in the contract.
   * @custom:restriction Cannot be accessed if caller is not member.
   * @return amount returns caller's ether available.
   */
  function balance() external view onlyMembers returns (uint256 amount) {
    uint256 percent;
    if (msg.sender == PROMOTER) {
      amount = PERCENT_PROMOTER;
    }

    if (msg.sender == OPENART) {
      amount = PERCENT_OPENART;
    }

    if (msg.sender == CREATOR) {
      amount = PERCENT_CREATOR;
    }
    amount = (address(this).balance * percent) / 100;
    return amount;
  }

  /**
   * @dev Transfer caller's available balance.
   * @custom:restriction Cannot be accessed if caller is not member.
   */
  function getProfits() external onlyMembers nonReentrant {
    uint256 amount1 = (address(this).balance * PERCENT_PROMOTER) / 100;
    uint256 amount2 = (address(this).balance * PERCENT_OPENART) / 100;
    uint256 amount3 = (address(this).balance * PERCENT_CREATOR) / 100;

    amountReceiver1 += amount1;
    amountReceiver2 += amount2;
    amountReceiver3 += amount3;

    bool sent1 = true;
    if (PERCENT_PROMOTER > 0) {
      (sent1, ) = payable(PROMOTER).call{value: amount1}("");
    }

    (bool sent2, ) = payable(OPENART).call{value: amount2}("");
    (bool sent3, ) = payable(CREATOR).call{value: amount3}("");

    require(sent1 && sent2 && sent3, "Error at transfer.");
  }

  receive() external payable {}

  fallback() external payable {}
}