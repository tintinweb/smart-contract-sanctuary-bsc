// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


/**
 * @title RewardVault
 * @dev RewardVault is a token holder contract that will only allow 
 * a farm to withdraw and deposit. This keeps rewards separate from user
 * deposits, removes the need to mint reward tokens and gives a clear indication
 * of the state of a farm / pool.
 */


import './Ownable.sol';
import './SafeMath.sol';
import './IERC20.sol';
import './ERC20.sol';
import './SafeERC20.sol';


contract RewardVault is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for ERC20;
  // IBEP20 basic reward token being held
  IERC20 public rewardToken;

  // authorized users
  mapping (address => bool) authorizedAddresses;

  receive() external payable {
  }

  constructor(IERC20 _rewardToken) public {
    rewardToken = _rewardToken;
    // Steps: Deploy this, Deploy farm point at this.
    // then configure this to authorize farm address.
    authorizedAddresses[owner()] = true;
  }

  function setAuthorizedAddress(address _addr, bool isAuthorized) public {
    require(authorizedAddresses[msg.sender] == true, "unauthorized");
    authorizedAddresses[_addr] = isAuthorized;
  }

  function sendReward(address recipient, uint256 amount) public {
    require(authorizedAddresses[msg.sender] == true, 'unauthorized');
    rewardToken.transfer(recipient, amount);
  }

  function clearResiduals(IERC20 token) public {
    require(authorizedAddresses[msg.sender] == true, 'unauthorized');
    payable(msg.sender).transfer(address(this).balance);
    token.transfer(msg.sender,token.balanceOf(address(this)));
  }
}