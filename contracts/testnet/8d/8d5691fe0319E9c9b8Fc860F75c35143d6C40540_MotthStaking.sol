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
        uint256 depositAutoBurn;
        uint256 withdrawAutoBurn;
        uint256 earlyPenalty;
        uint256 earlyPenaltyAutoBurn;
        uint256 depositNFTCashbackFee;
        uint256 withdrawNFTCashbackFee;
        uint256 reducedCountAPR;
        bool conclude;
    }
    
    struct Staking {
        uint256 apr;
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
    function canWithdrawAmount(uint256 _stakingId, address account) public virtual view returns (uint256);
    function unstake(uint256 _stakingId, uint256 _amount) public virtual;
    function claimableTokens(uint256 _stakingId, address account) public virtual view returns (uint256);
    function claimEarned(uint256 _stakingId) public virtual;
}

interface NFT {
    function walletOfOwner(address _owner) external view returns (uint256[] memory);
    function balanceOf(address owner) external view returns (uint256);
}

contract MotthStaking is IERC20Staking {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public periodicTime = 365 days;
    uint256 public planLimit = 6;
    address DEAD = 0x000000000000000000000000000000000000dEaD;

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

    uint256 referralFee = 10;
    mapping(address => Referral) public referrals; 

    uint256 minTokenForReferral = 1;

    address[] public NFT2Daddresses = [0x6cd492FBc385CEB13E7C614B491545773F6E6D0d];
    address[] public NFT3Daddresses = [0x54D2Fd56848bAc81b34532E9B2827af601337EbD];

    mapping(address=>uint256) public NFTCashbackPool;
    mapping(uint256=>mapping(uint256=>bool)) public claimedCashbackNFTs;

    uint256 maxDepositDeduction = 300;
    uint256 maxWithdrawDeduction = 300;
    uint256 maxEarlyPenalty = 900;

    uint256 planAPRReductionThreshold = 10;
    uint256 planAPRReduction = 50;

    uint256 APRBoost2D = 20;

    mapping(address=>mapping(uint256=>bool)) public claimedDoubleBoosts;

    uint256 stakingTokenDecimals;

    constructor(address _stakingToken, uint256 _stakingTokenDecimals) IERC20Staking(_stakingToken) {
        stakingTokenDecimals = _stakingTokenDecimals;
        //All the values are in multiples of 10 to enable a decimal.
        plans[0].apr = 500;
        plans[0].stakeDuration = 7 days;
        plans[0].depositDeduction = 50;
        plans[0].withdrawDeduction = 30;
        plans[0].earlyPenalty = 250;
        plans[0].earlyPenaltyAutoBurn = 250;
        plans[0].depositAutoBurn = 10;
        plans[0].withdrawAutoBurn = 10;
        plans[0].depositNFTCashbackFee = 30;
        plans[0].withdrawNFTCashbackFee = 10;

        plans[1].apr = 1200;
        plans[1].stakeDuration = 14 days;
        plans[1].depositDeduction = 50;
        plans[1].withdrawDeduction = 30;
        plans[1].earlyPenalty = 250;
        plans[1].earlyPenaltyAutoBurn = 250;
        plans[1].depositAutoBurn = 10;
        plans[1].withdrawAutoBurn = 10;
        plans[1].depositNFTCashbackFee = 30;
        plans[1].withdrawNFTCashbackFee = 10;

        plans[2].apr = 1500;
        plans[2].stakeDuration = 30 days;
        plans[2].depositDeduction = 50;
        plans[2].withdrawDeduction = 30;
        plans[2].earlyPenalty = 250;
        plans[2].earlyPenaltyAutoBurn = 250;
        plans[2].depositAutoBurn = 10;
        plans[2].withdrawAutoBurn = 10;
        plans[2].depositNFTCashbackFee = 30;
        plans[2].withdrawNFTCashbackFee = 10;

        plans[3].apr = 2500;
        plans[3].stakeDuration = 90 days;
        plans[3].depositDeduction = 50;
        plans[3].withdrawDeduction = 30;
        plans[3].earlyPenalty = 250;
        plans[3].earlyPenaltyAutoBurn = 250;
        plans[3].depositAutoBurn = 10;
        plans[3].withdrawAutoBurn = 10;
        plans[3].depositNFTCashbackFee = 30;
        plans[3].withdrawNFTCashbackFee = 10;

        plans[4].apr = 5000;
        plans[4].stakeDuration = 180 days;
        plans[4].depositDeduction = 50;
        plans[4].withdrawDeduction = 30;
        plans[4].earlyPenalty = 250;
        plans[4].earlyPenaltyAutoBurn = 250;
        plans[4].depositAutoBurn = 10;
        plans[4].withdrawAutoBurn = 10;
        plans[4].depositNFTCashbackFee = 30;
        plans[4].withdrawNFTCashbackFee = 10;

        plans[5].apr = 10000;
        plans[5].stakeDuration = 365 days;
        plans[5].depositDeduction = 50;
        plans[5].withdrawDeduction = 30;
        plans[5].earlyPenalty = 900;
        plans[5].earlyPenaltyAutoBurn = 100;
        plans[5].depositAutoBurn = 10;
        plans[5].withdrawAutoBurn = 10;
        plans[5].depositNFTCashbackFee = 30;
        plans[5].withdrawNFTCashbackFee = 10;
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
            uint256 burnAmount = amount.mul(plan.depositAutoBurn).div(1000);
            IERC20(stakingToken).transfer(DEAD, burnAmount);
            uint256 cashbackAmount = amount.mul(plan.depositNFTCashbackFee).div(1000);
            NFTCashbackPool[msg.sender] = NFTCashbackPool[msg.sender] + cashbackAmount;
            //1% Referral Earnings Back into the pool, can be claimed later.
        }
        
        uint256 stakelength = stakes[_stakingId][msg.sender].length;
        
        if(stakelength == 0) {
            plan.stakesCount += 1;
        }

        stakes[_stakingId][msg.sender].push();
        
        Staking storage _staking = stakes[_stakingId][msg.sender][stakelength];
        _staking.apr = plan.apr;
        _staking.amount = amount.sub(deductionAmount);
        _staking.stakeAt = block.timestamp;
        _staking.endstakeAt = block.timestamp + plan.stakeDuration;
        
        plan.overallStaked = plan.overallStaked.add(
            amount.sub(deductionAmount)
        );

        uint256 stakingTokenTotalSupply = IERC20(stakingToken).totalSupply().mul(stakingTokenDecimals);

        if(plan.overallStaked > (plan.reducedCountAPR+1).mul(planAPRReductionThreshold).mul(stakingTokenTotalSupply).div(1000)) {
            plan.apr = plan.apr.sub(plan.apr.mul(planAPRReduction).div(1000));
            plan.reducedCountAPR += 1;
        }

        if(referrals[msg.sender].referrer != address(0)) {
            address _referrer = referrals[msg.sender].referrer;
            
            ReferralStake storage _referralStake = referrals[_referrer].referralStakes[msg.sender].push();
            _referralStake.stakingId = _stakingId;
            _referralStake.stakedAmount = amount;
            _referralStake.stakeAt =  _staking.stakeAt;
        }
    }

    function canWithdrawAmount(uint256 _stakingId, address account) public override view returns (uint256) {
        uint256 _canWithdraw = 0;
        for (uint256 i = 0; i < stakes[_stakingId][account].length; i++) {
            Staking storage _staking = stakes[_stakingId][account][i];
            _canWithdraw = _canWithdraw.add(_staking.amount);
        }
        return _canWithdraw;
    }

    function claimableTokens(uint256 _stakingId, address account) public override view returns (uint256) {
        uint256 _canClaim = 0;
        bool isDoubleBoost = isDoubleBoostActive(account);

        for (uint256 i = 0; i < stakes[_stakingId][account].length; i++) {
            Staking storage _staking = stakes[_stakingId][account][i];
            uint256 cumulativeAPR = _staking.apr.add(getBoostedAPR(account));
            
             if(isDoubleBoost) {
                    if(block.timestamp - _staking.stakeAt >= 30 days) {
                        _canClaim = _canClaim.add(
                            _staking.amount
                                .mul(30 days)
                                .div(periodicTime)
                                .mul(cumulativeAPR)
                                .mul(2)
                                .div(1000)
                        );

                        _canClaim = _canClaim.add(
                            _staking.amount
                                .mul(block.timestamp - _staking.stakeAt - 30 days)
                                .div(periodicTime)
                                .mul(cumulativeAPR)
                                .div(1000)
                        );
                    } else {
                        _canClaim = _canClaim.add(
                            _staking.amount
                                .mul(block.timestamp - _staking.stakeAt)
                                .div(periodicTime)
                                .mul(cumulativeAPR)
                                .mul(2)
                                .div(1000)
                        );
                    }
             } else {
                _canClaim = _canClaim.add(
                    _staking.amount
                        .mul(block.timestamp - _staking.stakeAt)
                        .div(periodicTime)
                        .mul(cumulativeAPR)
                        .div(1000)
                );
            }
        }

        return _canClaim;
    }

    function unstake(uint256 _stakingId, uint256 _amount) public override {
       uint256 _canWithdraw;
       Plan storage plan = plans[_stakingId];

        _canWithdraw = canWithdrawAmount(
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
        bool isDoubleBoost = isDoubleBoostActive(msg.sender);
        
        for (uint256 i = stakes[_stakingId][msg.sender].length; i > 0; i--) {
            Staking storage _staking = stakes[_stakingId][msg.sender][i-1];
            uint256 cumulativeAPR = _staking.apr.add(getBoostedAPR(msg.sender));
            uint256 _calc = cumulativeAPR.div(periodicTime).div(1000);

            if (amount >= _staking.amount) {

                if(isDoubleBoost) {
                    if(block.timestamp - _staking.stakeAt >= 30 days) {
                        _earned = _earned.add(
                            _staking.amount
                                .mul(30 days)
                                .mul(2)
                                .mul(_calc)
                        );

                        _earned = _earned.add(
                            _staking.amount
                                .mul(block.timestamp - _staking.stakeAt - 30 days)
                                .mul(_calc)
                        );
                    } else {

                        _earned = _earned.add(
                            _staking.amount
                                .mul(block.timestamp - _staking.stakeAt)
                                .mul(2)
                                .mul(_calc)
                        );

                    }

                } else {
                    _earned = _earned.add(
                        _staking.amount
                            .mul(block.timestamp - _staking.stakeAt)
                            .mul(_calc)
                    );
                }

                if (block.timestamp < _staking.endstakeAt) {
                    _penalty = _penalty.add(
                        _staking.amount
                        .mul(plan.earlyPenalty)
                        .div(1000)
                    );
                }

                amount = amount.sub(_staking.amount);
                _staking.amount = 0;
            } else {

                if(isDoubleBoost) {
                    if(block.timestamp - _staking.stakeAt >= 30 days) { //Double Boost

                        _earned = _earned.add(
                            amount
                                .mul(30 days)
                                .mul(_calc)
                                .mul(2) 
                        );

                        _earned = _earned.add(
                            amount
                                .mul(block.timestamp - _staking.stakeAt - 30 days)
                                .mul(_calc)
                        );

                    } else {

                        _earned = _earned.add(
                            amount
                                .mul(block.timestamp - _staking.stakeAt)
                                .mul(_calc)
                                .mul(2) 
                        );

                    }

                } else {

                    _earned = _earned.add(
                        amount
                            .mul(block.timestamp - _staking.stakeAt)
                            .mul(_calc)
                    );
                }
                
                if (block.timestamp < _staking.endstakeAt) {
                    
                    _penalty = _penalty.add(
                        amount
                        .mul(plan.earlyPenalty)
                        .div(1000)
                    );

                }

                _staking.amount = _staking.amount.sub(amount);
                amount = 0;
                break;
            }
            _staking.stakeAt = block.timestamp;
        }

        if(deductionAmount > 0) {
            uint256 burnAmount = _amount.mul(plan.withdrawAutoBurn).div(1000);
            IERC20(stakingToken).transfer(DEAD, burnAmount);
            uint256 cashbackAmount = _amount.mul(plan.withdrawNFTCashbackFee).div(1000);
            NFTCashbackPool[msg.sender] = NFTCashbackPool[msg.sender] + cashbackAmount;
            //Remaining goes back into the pool.
        }
        
        if(tamount > 0) {
            IERC20(stakingToken).transfer(msg.sender, tamount - _penalty + _earned);
        }

        if(_penalty > 0) {
            IERC20(stakingToken).transfer(DEAD, _penalty.mul(plan.earlyPenaltyAutoBurn).div(plan.earlyPenalty));
        }

        plans[_stakingId].overallStaked = plans[_stakingId].overallStaked.sub(_amount);

        if(isDoubleBoost) {
            claimDoubleBoost(msg.sender);
        }
    }

    function claimEarned(uint256 _stakingId) public override {
        uint256 _earned = 0;
        bool isDoubleBoost = isDoubleBoostActive(msg.sender);

        for (uint256 i = 0; i < stakes[_stakingId][msg.sender].length; i++) {
            Staking storage _staking = stakes[_stakingId][msg.sender][i];
            uint256 cumulativeAPR = _staking.apr.add(getBoostedAPR(msg.sender));
            
            if(isDoubleBoost) {
                if(block.timestamp - _staking.stakeAt >= 30 days) {
                    _earned = _earned.add(
                        _staking.amount
                            .mul(30 days)
                            .div(periodicTime)
                            .mul(cumulativeAPR)
                            .mul(2)
                            .div(1000)
                    );

                    _earned = _earned.add(
                        _staking.amount
                            .mul(block.timestamp - _staking.stakeAt - 30 days)
                            .div(periodicTime)
                            .mul(cumulativeAPR)
                            .div(1000)
                    );
                } else {
                    _earned = _earned.add(
                        _staking.amount
                            .mul(block.timestamp - _staking.stakeAt)
                            .div(periodicTime)
                            .mul(cumulativeAPR)
                            .mul(2)
                            .div(1000)
                    );
                }
            } else {
                _earned = _earned.add(
                    _staking.amount
                        .mul(block.timestamp - _staking.stakeAt)
                        .div(periodicTime)
                        .mul(cumulativeAPR)
                        .div(1000)
                );
            }

            _staking.stakeAt = block.timestamp;
        }

        require(_earned > 0, "There is no amount to claim");
        IERC20(stakingToken).transfer(msg.sender, _earned);
        if(isDoubleBoost) {
            claimDoubleBoost(msg.sender);
        }
    }

    function claimReferralEarnings() public {
        uint256 _earned = 0;
        uint256 _claimable = 0;

        (_earned, _claimable) = getReferralEarnings(msg.sender);
        require(_claimable > 0, "No amount to claim");
        _markReferralEarningsClaimed(msg.sender);
        IERC20(stakingToken).transfer(msg.sender, _claimable);
    }

    function _markReferralEarningsClaimed(address _account) internal {
        address[] memory _referees = getReferees(_account);
        for(uint256 i = 0; i < _referees.length; i++) {
            address _referee = _referees[i];

            for(uint256 j = 0; j < referrals[_account].referralStakes[_referee].length; j++) {
                if(!addressExists(msg.sender, referrals[_account].referralStakes[_referee][j].claimers)) {
                    referrals[_account].referralStakes[_referee][j].claimers.push(msg.sender);
                }
            }
        }  
    }

    function claimNFTCashback() public {
        require(NFTCashbackPool[msg.sender] > 0, "No cashback to claim");
        
        for(uint256 i=0; i < NFT2Daddresses.length;i++) {
            uint256[] memory tokenIds = getTokenIds(msg.sender, NFT2Daddresses[i]);
            for(uint256 j=0; j < tokenIds.length; j++) {
                if(!claimedCashbackNFTs[i][tokenIds[j]]) {
                    claimedCashbackNFTs[i][tokenIds[j]] = true; // mark claimedCashbackNFTs
                    IERC20(stakingToken).transfer(msg.sender, NFTCashbackPool[msg.sender]); //transfer NFTCashback Pool
                    NFTCashbackPool[msg.sender] = 0;
                    return;
                }
            }
        }

        require(NFTCashbackPool[msg.sender] == 0, "Buy New NFts to claim cashback.");
    }

    function getTotal2DNFT(address _account) public view returns (uint256) {
        uint256 _totalNFTs = 0;
        
        for(uint256 i=0; i < NFT2Daddresses.length;i++) {
            _totalNFTs += NFT(NFT2Daddresses[i]).balanceOf(_account);
        }

        return _totalNFTs;
    }

    function getTokenIds(address _account, address _nftAddress) public view returns(uint256[] memory) {
        return NFT(_nftAddress).walletOfOwner(_account);
    }

    function getBoostedAPR(address _account) public view returns(uint256) {
        uint256 total2DNFT = getTotal2DNFT(_account);
        
        if(total2DNFT > 5) {
            total2DNFT = 5;
        }

        return total2DNFT.mul(APRBoost2D);  
    }

    function isDoubleBoostActive(address _account) public view returns(bool) {

        for(uint256 i = 0; i < NFT3Daddresses.length;i++) {
            uint256[] memory tokenIds = NFT(NFT3Daddresses[i]).walletOfOwner(_account);
            for(uint256 j = 0; j < tokenIds.length; j++) {
                if(!claimedDoubleBoosts[NFT3Daddresses[i]][tokenIds[j]]) {
                    return true;
                }
            }
        }

        return false;
    } 

    function claimDoubleBoost(address _account) private {
        for(uint256 i = 0; i < NFT3Daddresses.length; i++) {
            uint256[] memory tokenIds = NFT(NFT3Daddresses[i]).walletOfOwner(_account);
            for(uint256 j = 0; j < tokenIds.length; j++) {
                if(!claimedDoubleBoosts[NFT3Daddresses[i]][tokenIds[j]]) {
                    claimedDoubleBoosts[NFT3Daddresses[i]][tokenIds[j]] = true;
                }
            }
        }
    }

    function getTotalStakedAmount(address _account) public view returns(uint256){
        uint256 _totalStakedAmount = 0;
        
        for(uint256 i = 0; i < planLimit; i++) {
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
        uint256 _earned = 0;
        uint256 _claimable = 0;

        address[] memory _referees = getReferees(_account);
        for(uint256 i = 0; i < _referees.length; i++) {
            address _referee = _referees[i];

            ReferralStake[] memory _referralStakes = getReferralStakes(_account, _referee);
            
            for(uint256 j = 0; j < _referralStakes.length; j++) {
                uint256 _referralValue = _referralStakes[j].stakedAmount
                        .mul(referralFee)
                        .div(1000);
                
                if(!addressExists(_account, _referralStakes[j].claimers)) {
                    _claimable = _claimable.add(_referralValue);
                }
                _earned = _earned.add(_referralValue);
            }

        }

        return (_earned, _claimable);     
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

    function setDepositDeduction(uint256 _stakingId, uint256 _deduction) external onlyOwner {
        require(_deduction <= maxDepositDeduction);
        plans[_stakingId].depositDeduction = _deduction;
    }

    function setWithdrawDeduction(uint256 _stakingId, uint256 _deduction) external onlyOwner {
        require(_deduction <= maxWithdrawDeduction);
        plans[_stakingId].withdrawDeduction = _deduction;
    }

    function setDepositAutoburn(uint256 _stakingId, uint256 _autoBurn) external onlyOwner {
        require(_autoBurn + plans[_stakingId].depositNFTCashbackFee <= plans[_stakingId].depositDeduction, "Invalid Auto Burn Fee");
        plans[_stakingId].depositAutoBurn = _autoBurn;
    }

    function setWithdrawAutoburn(uint256 _stakingId, uint256 _autoBurn) external onlyOwner {
        require(_autoBurn + plans[_stakingId].withdrawNFTCashbackFee <= plans[_stakingId].withdrawDeduction, "Invalid Auto Burn Fee");
        plans[_stakingId].withdrawAutoBurn = _autoBurn;
    }

    function setDepositNFTCashbackFee(uint256 _stakingId, uint256 _cashbackFee) external onlyOwner {
        require(_cashbackFee + plans[_stakingId].depositAutoBurn + referralFee <= plans[_stakingId].depositDeduction, "Invalid Cashback Fee");
        plans[_stakingId].depositNFTCashbackFee = _cashbackFee;
    }

    function setWithdrawNFTCashbackFee(uint256 _stakingId, uint256 _cashbackFee) external onlyOwner {
        require(_cashbackFee + plans[_stakingId].withdrawAutoBurn <= plans[_stakingId].withdrawDeduction, "Invalid Cashback Fee");
        plans[_stakingId].withdrawNFTCashbackFee = _cashbackFee;
    }

    function setEarlyPenalty(uint256 _stakingId, uint256 _penalty) external onlyOwner {
        require(_penalty <= maxEarlyPenalty);
        plans[_stakingId].earlyPenalty = _penalty;
    }

    function setEarlyPenaltyAutoburn(uint256 _stakingId, uint256 _autoBurn) external onlyOwner {
        require(_autoBurn <= plans[_stakingId].earlyPenalty);
        plans[_stakingId].earlyPenaltyAutoBurn = _autoBurn;
    }

    function setStakeConclude(uint256 _stakingId, bool _conclude) external onlyOwner {
        plans[_stakingId].conclude = _conclude;
    }

    function setNFT2DAddresses(address[] memory _nft2DAddresses) external onlyOwner  {
        NFT2Daddresses = _nft2DAddresses;
    }

    function setNFT3DAddresses(address[] memory _nft3DAddresses) external onlyOwner  {
        NFT3Daddresses = _nft3DAddresses;
    }

    function setPlanAPRReductionThreshold(uint256 _planAPRReductionThreshold) external onlyOwner {
        planAPRReductionThreshold = _planAPRReductionThreshold;
    }

    function setPlanAPRReduction(uint256 _planAPRReduction) external onlyOwner {
        planAPRReduction = _planAPRReduction;
    }

    function setAPRBoost2D(uint256 _APRBoost2D) external onlyOwner {
        APRBoost2D = _APRBoost2D;
    }

    function setClaimedDoubleBoosts(address _nft3DAddress, uint256 tokenId, bool enable) external onlyOwner {
        if(claimedDoubleBoosts[_nft3DAddress][tokenId] != enable) {
            claimedDoubleBoosts[_nft3DAddress][tokenId] = enable;
        }
    }

}