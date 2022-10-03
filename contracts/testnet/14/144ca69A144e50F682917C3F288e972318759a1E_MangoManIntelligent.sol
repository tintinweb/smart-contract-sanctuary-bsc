//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./SafeERC20.sol";
import "./SafeMath.sol";

abstract contract IERC20Staking is ReentrancyGuard, Ownable {

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

    address public stakingToken;
    mapping(uint256 => Plan) public plans;

    constructor(address _stakingToken) {
        stakingToken = _stakingToken;
    }

    function stake(uint256 _stakingId, uint256 _amount) public virtual;
    function canWithdrawAmount(uint256 _stakingId, address account) public virtual view returns (uint256, uint256);
    function unstake(uint256 _stakingId, uint256 _amount) public virtual;
      function earnedToken(uint256 _stakingId, address account) public virtual view returns (uint256, uint256);
    function claimEarned(uint256 _stakingId) public virtual;
    function getStakedPlans(address _account) public virtual view returns (bool[] memory);
}

contract MangoManIntelligent is IERC20Staking {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public periodicTime = 365 days;
    uint256 planLimit = 3;

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
    
    uint256 referralLevels = 3;
    mapping(uint256 => uint256) public referralLevelEarnings;
   
    uint256 minTokenForReferral = 1;

    constructor(address _stakingToken) IERC20Staking(_stakingToken) {
        plans[0].apr = 90;
        plans[0].stakeDuration = 30 days;
        plans[0].earlyPenalty = 7;

        plans[1].apr = 120;
        plans[1].stakeDuration = 60 days;
        plans[1].earlyPenalty = 7;

        plans[2].apr = 150;
        plans[2].stakeDuration = 90 days;
        plans[2].earlyPenalty = 7;

        referralLevelEarnings[0] = 3;
        referralLevelEarnings[1] = 2;
        referralLevelEarnings[2] = 1;
    }

    function referralStake(uint256 _stakingId, uint256 _amount, address _referrer) public {
        require(_referrer!=msg.sender, "You can't refer yourself");

        if(referrals[msg.sender].referrer == address(0) && getTotalStakedAmount(_referrer) >= minTokenForReferral) {
            referrals[msg.sender].referrer = _referrer;
            referrals[_referrer].referees.push(msg.sender);
        }

        stake(_stakingId, _amount);
    }

    function stake(uint256 _stakingId, uint256 _amount) public override {
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
        
        uint256 deductionAmount = amount.mul(plan.depositDeduction).div(1000);
        if(deductionAmount > 0) {
            IERC20(stakingToken).transfer(stakingToken, deductionAmount);
        }
        
        uint256 stakelength = stakes[_stakingId][msg.sender].length;
        
        if(stakelength == 0) {
            plan.stakesCount += 1;
        }

        stakes[_stakingId][msg.sender].push();
        
        Staking storage _staking = stakes[_stakingId][msg.sender][stakelength];
        _staking.amount = amount.sub(deductionAmount);
        _staking.stakeAt = block.timestamp;
        _staking.endstakeAt = block.timestamp + plan.stakeDuration;
        
        plan.overallStaked = plan.overallStaked.add(
            amount.sub(deductionAmount)
        );

        if(referrals[msg.sender].referrer != address(0)) {
            address _referrer = referrals[msg.sender].referrer;
            
            ReferralStake storage _referralStake = referrals[_referrer].referralStakes[msg.sender].push();
            _referralStake.stakingId = _stakingId;
            _referralStake.stakedAmount = _staking.amount;
            _referralStake.stakeAt =  _staking.stakeAt;
        }
    }

    function canWithdrawAmount(uint256 _stakingId, address _account) public override view returns (uint256, uint256) {
        uint256 _stakedAmount = 0;
        uint256 _canWithdraw = 0;
        for (uint256 i = 0; i < stakes[_stakingId][_account].length; i++) {
            Staking storage _staking = stakes[_stakingId][_account][i];
            _stakedAmount = _stakedAmount.add(_staking.amount);
            _canWithdraw = _canWithdraw.add(_staking.amount);
        }
        
        return (_stakedAmount, _canWithdraw);
    }

    function earnedToken(uint256 _stakingId, address _account) public override view returns (uint256, uint256) {
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

    function unstake(uint256 _stakingId, uint256 _amount) public override {
        uint256 _stakedAmount;
        uint256 _canWithdraw;
        Plan storage plan = plans[_stakingId];

        (_stakedAmount, _canWithdraw) = canWithdrawAmount(
            _stakingId,
            msg.sender
        );
        require(
            _canWithdraw >= _amount,
            "Withdraw Amount is not enough"
        );
        uint256 deductionAmount = _amount.mul(plans[_stakingId].withdrawDeduction).div(1000);
        uint256 tamount = _amount - deductionAmount;
        uint256 amount = _amount;
        uint256 _earned = 0;
        uint256 _penalty = 0;
        for (uint256 i = stakes[_stakingId][msg.sender].length; i > 0; i--) {
            Staking storage _staking = stakes[_stakingId][msg.sender][i-1];
            
            if (amount >= _staking.amount) {
                
                if (block.timestamp >= _staking.endstakeAt) {
                    _earned = _earned.add(
                        _staking.amount
                            .mul(block.timestamp - _staking.stakeAt)
                            .mul(plan.apr)
                            .div(100)
                            .div(periodicTime)
                    );
                } else {
                    _penalty = _penalty.add(
                        _staking.amount
                        .mul(plan.earlyPenalty)
                        .div(100)
                    );
                }

                amount = amount.sub(_staking.amount);
                _staking.amount = 0;
            } else {
                
                if (block.timestamp >= _staking.endstakeAt) {
                    _earned = _earned.add(
                        amount
                            .mul(block.timestamp - _staking.stakeAt)
                            .mul(plan.apr)
                            .div(100)
                            .div(periodicTime)
                    );
                } else {
                    _penalty = _penalty.add(
                        amount
                        .mul(plan.earlyPenalty)
                        .div(100)
                    );
                }

                _staking.amount = _staking.amount.sub(amount);
                amount = 0;
                break;
            }
            _staking.stakeAt = block.timestamp;
        }

        if(deductionAmount > 0) {
            IERC20(stakingToken).transfer(stakingToken, deductionAmount);
        }
        if(tamount > 0) {
            IERC20(stakingToken).transfer(msg.sender, tamount - _penalty);
        }
        if(_earned > 0) {
            IERC20(stakingToken).transfer(msg.sender, _earned);
        }

        plans[_stakingId].overallStaked = plans[_stakingId].overallStaked.sub(_amount);
    }

    function claimEarned(uint256 _stakingId) public override {
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

    function claimReferralEarnings() public {
        uint256 _earned = 0;
        uint256 _claimable = 0;

        (_earned, _claimable) = getReferralEarnings(msg.sender);
        require(_claimable > 0, "No amount to claim");
        claimLevelsReferralEarnings(msg.sender, 0);
        IERC20(stakingToken).transfer(msg.sender, _claimable);
    }

    function claimLevelsReferralEarnings(address _account, uint256 _level) internal {
        
        if(_level == referralLevels) {
            return;
        }

        address[] memory _referees = getReferees(_account);
        for(uint256 i = 0; i < _referees.length; i++) {
            address _referee = _referees[i];
            claimLevelsReferralEarnings(_referee, _level + 1);
            claimSingleLevelReferralEarnings(_account, _referee);
        }  
    }

    function claimSingleLevelReferralEarnings(address _referrer, address _referee) internal {
        for(uint256 j = 0; j < referrals[_referrer].referralStakes[_referee].length; j++) {
            if(!addressExists(msg.sender, referrals[_referrer].referralStakes[_referee][j].claimers)) {
                referrals[_referrer].referralStakes[_referee][j].claimers.push(msg.sender);
            }
        }
    }

    function getStakedPlans(address _account) public override view returns (bool[] memory) {
        bool[] memory walletPlans = new bool[](planLimit);
        for (uint256 i = 0; i < planLimit; i++) {
            walletPlans[i] = stakes[i][_account].length == 0 ? false : true;
        }
        return walletPlans;
    }

    function getTotalStakedAmount(address _account) public view returns(uint256){
        uint256 _totalStakedAmount = 0;
        
        for(uint256 i = 0; i < referralLevels; i++) {
            for(uint256 j = 0; j < stakes[i][_account].length; j++) {
                Staking storage _staking = stakes[i][_account][j];
                _totalStakedAmount = _totalStakedAmount.add(_staking.amount);
            }
        }
        
        return _totalStakedAmount;
    }

    function getReferees(address _account) public view returns (address[] memory) {
        return referrals[_account].referees;
    }

    function getReferralStakes(address _referrer, address _referee) public view returns (ReferralStake[] memory) {
        return referrals[_referrer].referralStakes[_referee];
    }

    function getReferralEarnings(address _account) public view returns(uint256, uint256) {
        return getLevelsReferralEarning(_account, _account, 0);         
    }

    function getLevelsReferralEarning(address _account, address _referrer, uint256 _level) public view returns(uint256, uint256) {
        uint256 _earned = 0;
        uint256 _claimable = 0;
        
        if(_level == referralLevels) {
            return (_earned, _claimable);
        }

        address[] memory _referees = getReferees(_referrer);
        for(uint256 i = 0; i < _referees.length; i++) {
            address _referee = _referees[i];
            uint256 _nexEarned;
            uint256 _nextClaimable;
            (_nexEarned, _nextClaimable) = getLevelsReferralEarning(_account, _referee, _level + 1);
            _earned = _earned.add(_nexEarned);
            _claimable = _claimable.add(_nextClaimable);
            
            (_nexEarned, _nextClaimable) = getSingleLevelReferralEarning(_account, _referrer, _referee, _level);
            _earned = _earned.add(_nexEarned);
            _claimable = _claimable.add(_nextClaimable);

        }

        return (_earned, _claimable);     
    }

    function getSingleLevelReferralEarning(address _account, address _referrer, address _referee, uint256 _level) public view returns (uint256, uint256) {
        ReferralStake[] memory _referralStakes = getReferralStakes(_referrer, _referee);
        uint256 _earned = 0;
        uint256 _claimable = 0;

        for(uint256 j = 0; j < _referralStakes.length; j++) {
            uint256 _referralValue = _referralStakes[j].stakedAmount
                    .mul(referralLevelEarnings[_level])
                    .div(100);
            
            if(!addressExists(_account, _referralStakes[j].claimers)) {
                _claimable = _claimable.add(_referralValue);
            }
            _earned = _earned.add(_referralValue);
        }

        return (_earned, _claimable);
    }

    function getReferralEarningsData(address _account) public view returns(
        address[] memory, 
        uint256[] memory, 
        ReferralStake[][] memory
    ) {
        return getLevelReferralEarningsData(_account, 0);         
    }

    function getLevelReferralEarningsData(address _referrer, uint256 _level) public view returns(
        address[] memory, 
        uint256[] memory,
        ReferralStake[][] memory
    ) {
        address[] memory _referees;
        uint256[] memory _levels;
        ReferralStake[][] memory _referralStakes;
        if(_level <= referralLevels - 1) {
        
            (_referees, _levels, _referralStakes) = getSingleLevelReferralEarningsData(_referrer, _level);
      
            address[] memory _nextReferees;
            uint256[] memory _nextLevels;
            ReferralStake[][] memory _nextReferralStakes;
            for(uint256 i = 0; i < _referees.length; i++) {
                (_nextReferees, _nextLevels, _nextReferralStakes) = getLevelReferralEarningsData(_referees[i], _level + 1);
                _referees = concatenateAddresses(_referees, _nextReferees);
                _levels = concatenateIntegers(_levels, _nextLevels);
                _referralStakes = concatenateReferralStakes(_referralStakes, _nextReferralStakes);   
            }
        }

        return (_referees, _levels, _referralStakes);    
    }

    function getSingleLevelReferralEarningsData(address _referrer, uint256 _level) public view returns(
        address[] memory, 
        uint256[] memory,
        ReferralStake[][] memory
    ) {
        address[] memory _referees = getReferees(_referrer);
        uint256[] memory _levels = new uint256[](_referees.length);
        ReferralStake[][] memory _referralStakes = new ReferralStake[][](_referees.length);

        for(uint256 i = 0; i < _referees.length; i++) {
            _levels[i] = _level;
            _referralStakes[i] = referrals[_referrer].referralStakes[_referees[i]];
        }

        return (_referees, _levels, _referralStakes);    
    }

    function concatenateAddresses(address[] memory a1, address[] memory a2) internal pure returns(address[] memory) {
        address[] memory returnArr = new address[](a1.length + a2.length);

        uint256 i = 0;
        for (; i < a1.length; i++) {
            returnArr[i] = a1[i];
        }

        for (uint256 j = 0; j < a2.length; j++) {
            returnArr[i++] = a2[j];
        }

        return returnArr;
    }

    function concatenateIntegers(uint256[] memory a1, uint256[] memory a2) internal pure returns(uint256[] memory) {
        uint256[] memory returnArr = new uint256[](a1.length + a2.length);

        uint256 i = 0;
        for (; i < a1.length; i++) {
            returnArr[i] = a1[i];
        }

        for (uint256 j = 0; j < a2.length; j++) {
            returnArr[i++] = a2[j];
        }

        return returnArr;
    }

    function concatenateReferralStakes(ReferralStake[][] memory a1, ReferralStake[][] memory a2) internal pure returns(ReferralStake[][] memory) {
        ReferralStake[][] memory returnArr = new ReferralStake[][](a1.length + a2.length);

        uint256 i = 0;
        for (; i < a1.length; i++) {
            returnArr[i] = a1[i];
        }

        for (uint256 j = 0; j < a2.length; j++) {
            returnArr[i++] = a2[j];
        }

        return returnArr;
    } 

    function addressExists(address add, address[] memory array) internal pure returns (bool) {
        for (uint i = 0; i < array.length; i++) {
            if (array[i] == add) {
                return true;
            }
        }
        return false;
    }

    function setAPR(uint256 _stakingId, uint256 _percent) external onlyOwner {
        plans[_stakingId].apr = _percent;
    }

    function setStakeDuration(uint256 _stakingId, uint256 _duration) external onlyOwner {
        plans[_stakingId].stakeDuration = _duration;
    }

    function setDepositDeduction(uint256 _stakingId, uint256 _deduction) external onlyOwner {
        plans[_stakingId].depositDeduction = _deduction;
    }

    function setWithdrawDeduction(uint256 _stakingId, uint256 _deduction) external onlyOwner {
        plans[_stakingId].withdrawDeduction = _deduction;
    }

    function setEarlyPenalty(uint256 _stakingId, uint256 _penalty) external onlyOwner {
        plans[_stakingId].earlyPenalty = _penalty;
    }

    function setStakeConclude(uint256 _stakingId, bool _conclude) external onlyOwner {
        plans[_stakingId].conclude = _conclude;
    }

    function setReferralLevelEarnings(uint256 _level, uint256 _earning) external onlyOwner {
        referralLevelEarnings[_level] = _earning;
    }

    function setMinTokenForReferral(uint256 _minTokenForReferral) external onlyOwner {
        minTokenForReferral = _minTokenForReferral;
    }

    function removeStuckToken() external onlyOwner {
        IERC20(stakingToken).transfer(owner(), IERC20(stakingToken).balanceOf(address(this)));
    }
}