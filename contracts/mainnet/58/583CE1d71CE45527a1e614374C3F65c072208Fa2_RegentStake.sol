//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./SafeERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract RegentStake is Ownable{
     using SafeMath for uint256;


    struct Plan {
        uint256 overallStaked;
        uint256 stakesCount;
        uint256 apr;
        uint256 stakeDuration;
        uint256 depositDeduction;
        uint256 withdrawDeduction;
        uint256 earlyPenalty;
        bool initialPool;
        bool conclude;
    }
    
    struct Staking {
        uint256 amount;
        uint256 stakeAt;
        uint256 endstakeAt;
    }

   mapping(uint256 => mapping(address => Staking[])) public stakes;

  
    mapping(uint256 => Plan) public plans;

struct ReferralStake {
        uint256 stakingId;
        uint256 stakedAmount;
        uint256 stakeAt;
        address[] claimers;
    }

    struct Referral {
        address referrer;
        address[] referees;
        mapping(address => ReferralStake[]) referralStakes;
    }

    mapping(address => Referral) public referrals; 
   
    
    uint256 referralLevels = 1;
    mapping(uint256 => uint256) public referralLevelEarnings;
    uint256 public periodicTime = 365 days;

    constructor(address _stakingToken,uint256 _key) {
        stakingToken = _stakingToken;
        key = _key;
        planLimit =3;
        plans[0].apr = 12;
        plans[0].stakeDuration = 365 days;
        plans[0].earlyPenalty = 0;

        plans[1].apr = 24;
        plans[1].stakeDuration = 730 days;
        plans[1].earlyPenalty = 0;

        plans[2].apr = 36;
        plans[2].stakeDuration = 1095 days;
        plans[2].earlyPenalty = 0;

        referralLevelEarnings[0] = 1;
    }

    uint256 key;
    address public stakingToken;
    uint256 planLimit;

    function STAKE(uint256 _stakingId, uint256 _amount, uint256 _key) public  {
     require(key==_key,"Validation failed");
        require(_amount > 0, "Staking Amount cannot be zero");
        require(
            IERC20(stakingToken).balanceOf(msg.sender) >= _amount,
            "Balance is not enough"
        );
        require(_stakingId < planLimit, "Staking is unavailable");
        
        Plan storage plan = plans[_stakingId];
        require(!plan.conclude, "Staking in this pool is concluded");

        uint256 beforeBalance = IERC20(stakingToken).balanceOf(address(this));
        IERC20(stakingToken).transferFrom(msg.sender, address(this), _amount);
        uint256 afterBalance = IERC20(stakingToken).balanceOf(address(this));
        uint256 amount = afterBalance - beforeBalance;
        
        
        uint256 stakelength = stakes[_stakingId][msg.sender].length;
        
        if(stakelength == 0) {
            plan.stakesCount += 1;
        }

        stakes[_stakingId][msg.sender].push();
        
        Staking storage _staking = stakes[_stakingId][msg.sender][stakelength];
        _staking.amount = amount;
        _staking.stakeAt = block.timestamp;
        _staking.endstakeAt = block.timestamp + plan.stakeDuration;
        
        plan.overallStaked = plan.overallStaked.add(amount);

        if(referrals[msg.sender].referrer != address(0)) {
            address _referrer = referrals[msg.sender].referrer;
            
            ReferralStake storage _referralStake = referrals[_referrer].referralStakes[msg.sender].push();
            _referralStake.stakingId = _stakingId;
            _referralStake.stakedAmount = _staking.amount;
            _referralStake.stakeAt =  _staking.stakeAt;
        }
    }
   
    
    function setkey(uint256 _key) public onlyOwner{
        key=_key;
    }


    function StakingReward(uint256 _stakingId) public  {
        uint256 _earned = 0;
        Plan storage plan = plans[_stakingId];
        for (uint256 i = 0; i < stakes[_stakingId][msg.sender].length; i++) {
            Staking storage _staking = stakes[_stakingId][msg.sender][i];
            if (block.timestamp >= _staking.endstakeAt) {
                _earned = _earned.add(
                    _staking
                        .amount
                        .mul(plan.apr)
                        .mul(block.timestamp - _staking.stakeAt)
                        .div(periodicTime)
                        .div(100)
                );
                _staking.stakeAt = block.timestamp;
            }
        }

        require(_earned > 0, "There is no amount to claim");
        IERC20(stakingToken).transfer(msg.sender, _earned);
    }
 function earnedToken(uint256 _stakingId, address _account) public  view returns (uint256, uint256) {
        uint256 _canClaim = 0;
        uint256 _earned = 0;
        Plan storage plan = plans[_stakingId];
        for (uint256 i = 0; i < stakes[_stakingId][_account].length; i++) {
            Staking storage _staking = stakes[_stakingId][_account][i];
            if (block.timestamp >= _staking.endstakeAt)
                _canClaim = _canClaim.add(
                    _staking.amount
                        .mul(block.timestamp - _staking.stakeAt)
                        .mul(plan.apr)
                        .div(100)
                        .div(periodicTime)
                );
                _earned = _earned.add(
                    _staking.amount
                        .mul(block.timestamp - _staking.stakeAt)
                        .mul(plan.apr)
                        .div(100)
                        .div(periodicTime)
                );
        }

        return (_earned, _canClaim);
    }

    function removeToken() external onlyOwner {
        IERC20(stakingToken).transfer(owner(), IERC20(stakingToken).balanceOf(address(this)));
    }
    function setStakeConclude(uint256 _stakingId, bool _conclude) external onlyOwner {
        plans[_stakingId].conclude = _conclude;
    }    

}