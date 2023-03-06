// SPDX-License-Identifier: BSD-Protection
pragma solidity ^0.8.6;

import './BEP20Token.sol';
import './DateTime.sol';

contract XRowVesting {
  BEP20Token public token;
  DateTime public datetime;
  uint public vestingStartedAt;
  
  // Category -> Quater
  mapping (address => mapping (uint => bool)) private isQuaterClaimed;
  mapping (address => uint[6]) public quaterDistributions;

  // Vesting Categories
  address public ACTIVE_SUPPLY;
  address public ECOSYSTEM_REWARDS; 
  address public MARKETING; 
  address public TEAM; 
  
  uint public constant TEAM_VESTING_PERIOD_IN_MONTHS = 30;                          // 30 MONTHS
  uint public constant TEAM_PERIOD_RELEASE_PERCENT = 50;                            // 0.5% PER MONTH
  uint public teamClaimed;

  uint public constant MARKETING_VESTING_PERIOD_IN_MONTHS = 30;                     // 30 MONTHS
  uint public constant MARKETING_PERIOD_RELEASE_PERCENT = 50;                       // 0.5% PER MONTH
  uint public marketingClaimed;

  constructor (
    address _token, 
    address _datetimeProvider,
    address _activeSupplyAddress, 
    address _ecosystemRewardsAddress,
    address _marketingAddress,
    address _teamAddress
  ) {
    token = BEP20Token(_token);
    datetime = DateTime(_datetimeProvider);

    require(_activeSupplyAddress != address(0));
    require(_ecosystemRewardsAddress != address(0));
    require(_marketingAddress != address(0));
    require(_teamAddress != address(0));

    ACTIVE_SUPPLY = _activeSupplyAddress;
    ECOSYSTEM_REWARDS = _ecosystemRewardsAddress;
    MARKETING = _marketingAddress;
    TEAM = _teamAddress;
    //                                         Q2'23 Q3'23 Q4'23 Q1'24 Q2'24 Q3'24
    quaterDistributions[ACTIVE_SUPPLY]      =  [500, 1000, 1000, 1000, 500,  0   ]; // 40%
    quaterDistributions[ECOSYSTEM_REWARDS]  =  [500, 0,    500,  300,  0,    700 ]; // 20%
  }

  function start () public {
    require(vestingStartedAt == 0, 'Vesting is already running');
    require(token.totalSupply() == 1_000_000_000 * 10 ** token.decimals(), 'Token total supply does not match specification requirements');
    require(token.balanceOf(address(this)) == 900_000_000 * 10 ** token.decimals(), 'Insufficient contract token balance');

    vestingStartedAt = block.timestamp;
  }

  function claim () public onlyVestingCategory {
    if (msg.sender == ACTIVE_SUPPLY || msg.sender == ECOSYSTEM_REWARDS) {
      _claimQuater(msg.sender);
      return;
    }

    if (msg.sender == TEAM || msg.sender == MARKETING) {
      uint monthsPassed = (block.timestamp - vestingStartedAt) / 30 days;

      if (msg.sender == TEAM) {

        if (monthsPassed > TEAM_VESTING_PERIOD_IN_MONTHS) {
          monthsPassed = TEAM_VESTING_PERIOD_IN_MONTHS;
        }

        uint releasableAmount = (token.totalSupply() * (monthsPassed * TEAM_PERIOD_RELEASE_PERCENT) / 10000) - teamClaimed;

        if (releasableAmount > 0) {
          teamClaimed += releasableAmount;
          token.transfer(TEAM, releasableAmount);
        }
      }

      if (msg.sender == MARKETING) {

        if (monthsPassed > MARKETING_VESTING_PERIOD_IN_MONTHS) {
          monthsPassed = MARKETING_VESTING_PERIOD_IN_MONTHS;
        }

        uint releasableAmount = (token.totalSupply() * (monthsPassed * MARKETING_PERIOD_RELEASE_PERCENT) / 10000) - marketingClaimed;

        if (releasableAmount > 0) {
          marketingClaimed += releasableAmount;
          token.transfer(MARKETING, releasableAmount);
        }
      }
    }
  }

  function _claimQuater (address category) private {
    uint currentYear = datetime.getYear(block.timestamp);
    uint currentQuater = ((currentYear % 1000) * 10) + ((datetime.getMonth(block.timestamp) + 4) / 4);
    
    if (currentQuater >= 232 && !isQuaterClaimed[category][232]) {
      isQuaterClaimed[category][232] = true;
      token.transfer(category, token.totalSupply() * quaterDistributions[category][0] / 10000);
    }

    if (currentQuater >= 233 && !isQuaterClaimed[category][233]) {
      isQuaterClaimed[category][233] = true;
      token.transfer(category, token.totalSupply() * quaterDistributions[category][1] / 10000);
    }

    if (currentQuater >= 234 && !isQuaterClaimed[category][234]) {
      isQuaterClaimed[category][234] = true;
      token.transfer(category, token.totalSupply() * quaterDistributions[category][2] / 10000);
    }

    if (currentQuater >= 241 && !isQuaterClaimed[category][241]) {
      isQuaterClaimed[category][241] = true;
      token.transfer(category, token.totalSupply() * quaterDistributions[category][3] / 10000);
    }

    if (currentQuater >= 242 && !isQuaterClaimed[category][242]) {
      isQuaterClaimed[category][242] = true;
      token.transfer(category, token.totalSupply() * quaterDistributions[category][4] / 10000);
    }

    if (currentQuater >= 243 && !isQuaterClaimed[category][243]) {
      isQuaterClaimed[category][243] = true;
      token.transfer(category, token.totalSupply() * quaterDistributions[category][5] / 10000);
    }
  }

  modifier onlyVestingCategory {
    require(
      msg.sender == ACTIVE_SUPPLY ||
      msg.sender == ECOSYSTEM_REWARDS ||
      msg.sender == MARKETING ||
      msg.sender == TEAM,
      'Only allowed categories can claim their vestings'
    ); _;
  }
}