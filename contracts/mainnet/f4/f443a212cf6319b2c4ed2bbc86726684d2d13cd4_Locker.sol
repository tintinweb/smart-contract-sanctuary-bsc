//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.8;

import "./Ownable.sol";
import "./IERC20.sol";
import "./SafeMath.sol";

contract Locker is Ownable {
  using SafeMath for uint256;
  IERC20 public _token;

  address public _receiver;

  uint256 public _depositedAt = 0;
  uint256 public _lastWithdraw = 0;
  uint256 public _receivedByDeposit = 0;

  constructor(address token_) {
    _token = IERC20(token_);
  }

  function setReceiver(address receiver_) external onlyOwner {
    _receiver = receiver_;
  }

  function deposit(uint256 amount) external {
    require(_depositedAt == 0, "Already has deposit");
    IERC20(_token).transferFrom(_msgSender(), address(this), amount);
    _depositedAt = block.timestamp;
    _lastWithdraw = _depositedAt;
    _receivedByDeposit = amount;
  }

  function getNextWithdrawTimestamp() external view returns(uint256) {
    uint256 i = _lastWithdraw.sub(_depositedAt).div(30 days) + 1;
    uint256 nextWithdrawTimestamp = 0;
    uint256 counter = 1;
    for (i; i <= 12; i++) {
      nextWithdrawTimestamp = _lastWithdraw.add(counter.mul(30 days));
      if (block.timestamp < nextWithdrawTimestamp) break;
      counter++;
    }
    return nextWithdrawTimestamp;
  }

  function getWithdrawable() public view returns (uint256) {
    uint256 i = _lastWithdraw.sub(_depositedAt).div(30 days) + 1;
    uint256 withdrawable = 0;
    uint256 counter = 1;
    for (i; i <= 12; i++) {
      uint256 nextWithdrawTimestamp = _lastWithdraw.add(counter.mul(30 days));
      if (block.timestamp > nextWithdrawTimestamp) {
        if (i == 12) {
          withdrawable = IERC20(_token).balanceOf(address(this));
        } else {
          withdrawable = withdrawable.add(_receivedByDeposit.div(12));
        }
      }
      counter++;
    }
    return withdrawable;
  }

  function withdraw() external {
    require(_receiver != address(0), "Set receiver first");
    uint256 withdrawable = getWithdrawable();
    IERC20(_token).transfer(_receiver, withdrawable);
    _lastWithdraw = block.timestamp;
  }
}