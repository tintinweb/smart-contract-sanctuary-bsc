// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
import "./wins.sol";
import "./Ownable.sol";

interface IBSC {
	function totalSupply() external view returns (uint256);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint256);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract WinSwap_Airdrop is Ownable {
  struct Claimer {
    address referer;
    uint256 tier1;
    uint256 tier2;
    uint256 tier3;
    uint256 totalRef;
    uint256 claimed;
  }
  IBSC public claimToken;
  address public support;
  uint[] public rewards;
  uint256 public totalclaimers;
  uint256 public _claimTokenRegister = 300000 * 1e18;
  uint256 public _claimTokenTier1 = 30000 * 1e18;
  uint256 public _claimTokenTier2 = 5000 * 1e18;
  uint256 public _claimTokenTier3 = 1000 * 1e18;
  uint256 public totalrewards;
  mapping (address => Claimer) public claimers;
  event Claim(address user, address referer);
  event Reward(address user, uint256 amount);

  constructor(address _claimToken) public {
    rewards.push(_claimTokenTier1);
    rewards.push(_claimTokenTier2);
    rewards.push(_claimTokenTier3);
    support = msg.sender;
    claimToken = IBSC(_claimToken);
  }

  function claim(address referer) external {
    if (claimers[msg.sender].claimed == 0) {
      claimers[msg.sender].claimed = _claimTokenRegister;
      totalclaimers++;
      if (claimers[referer].claimed != 0 && referer != msg.sender) {
        address rec = referer;
        claimers[msg.sender].referer = referer;
        for (uint256 i = 0; i < rewards.length; i++) {
          if (claimers[rec].claimed == 0) {
            break;
          }
          if (i == 0) {
            claimers[rec].tier1++;
          }
          if (i == 1) {
            claimers[rec].tier2++;
          }
          if (i == 2) {
            claimers[rec].tier3++;
          }
          if (i == 3) {
            claimers[rec].tier3++;
          }
          rec = claimers[rec].referer;
        }
        rewardReferers(referer);
      }
      require(IBSC(claimToken).transfer(msg.sender, _claimTokenRegister), 'Claim token is failed');
      emit Claim(msg.sender, referer);
    }
  }

  function rewardReferers(address referer) internal {
    address rec = referer;
    for (uint256 i = 0; i < rewards.length; i++) {
      if (claimers[rec].claimed == 0) {
        break;
      }
      uint256 a = rewards[i];
      claimers[rec].claimed += a;
      totalrewards += a;
      require(IBSC(claimToken).transfer(rec, a), 'Claim reward token is failed');
      emit Reward(rec, a);
      rec = claimers[rec].referer;
    }
  }
  function balanceOf(address user) public view returns (uint256) {
    return claimers[user].claimed;
  }
  function availabe() public view returns (uint256) {
    return IBSC(claimToken).balanceOf(address(this));
  }
}