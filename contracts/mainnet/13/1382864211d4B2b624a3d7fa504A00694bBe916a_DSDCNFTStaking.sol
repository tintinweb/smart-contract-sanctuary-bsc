//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./SafeERC20.sol";
import "./SafeMath.sol";
import "./IERC721.sol";
import "./EnumerableSet.sol";

abstract contract NFTStaking is ReentrancyGuard, Ownable {

    struct Plan {
        uint256 overallStaked;
        uint256 apr;
        uint256 stakeDuration;
        bool conclude;
    }
    
    struct Staking {
        EnumerableSet.UintSet tokenIds;
        mapping(uint256 => uint256) stakeAt;
        mapping(uint256 => uint256) endstakeAt;
    }

    mapping(uint256 => mapping(address => Staking)) internal stakes;

    address public stakingToken;
    address public rewardToken;
    mapping(uint256 => Plan) public plans;

    constructor(address _stakingToken, address _rewardToken) {
        stakingToken = _stakingToken;
        rewardToken = _rewardToken;
    }

    function stake(uint256 _stakingId, uint256[] memory tokenIds) public virtual;
    function unstake(uint256 _stakingId, uint256[] memory tokenIds) public virtual;
    function getEarnedRewards(uint256 _stakingId, address account) public virtual view returns (uint256, uint256);
    function claimEarnedReward(uint256 _stakingId) public virtual;
    function getStakedTokens(uint256 _stakingId, address _account) public virtual view returns (uint256[] memory);
}

contract DSDCNFTStaking is NFTStaking {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;

    uint256 public periodicTime = 365 days;
    uint256 public planLimit = 1;
    uint256 minAPR = 10;

    constructor(address _stakingToken, address _rewardToken) NFTStaking(_stakingToken, _rewardToken) {
        plans[0].apr = 399675000000;
        plans[0].stakeDuration = 0 days;
    }

    function stake(uint256 _stakingId, uint256[] memory tokenIds) public override {

        require(_stakingId < planLimit, "Staking is unavailable");

        Plan storage plan = plans[_stakingId];
        require(!plan.conclude, "Staking in this pool is concluded");
        
        Staking storage _staking = stakes[_stakingId][msg.sender];

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(IERC721(stakingToken).ownerOf(tokenIds[i]) == msg.sender, "You can only stake NFTs which you own");
            _staking.tokenIds.add(tokenIds[i]);
            _staking.stakeAt[tokenIds[i]] = block.timestamp;
            _staking.endstakeAt[tokenIds[i]] = block.timestamp + plan.stakeDuration;

            // Transfer the deposited token to this contract
            IERC721(stakingToken).transferFrom(msg.sender, address(this), tokenIds[i]);
            plan.overallStaked = plan.overallStaked + 1;
        }
    }

    function getEarnedRewards(uint256 _stakingId, address _account) public override view returns (uint256, uint256) {
        uint256 _canClaim = 0;
        uint256 _earned = 0;
        Plan storage plan = plans[_stakingId];
        Staking storage _staking = stakes[_stakingId][_account];
        
        for (uint256 i = 0; i < _staking.tokenIds.length(); i++) {
            uint256 tokenId = _staking.tokenIds.at(i);
            if (block.timestamp >= _staking.endstakeAt[tokenId])
                _canClaim = _canClaim.add(
                    plan.apr
                        .div(100)
                        .mul(block.timestamp - _staking.stakeAt[tokenId])
                        .div(periodicTime)
                );
            _earned = _earned.add(
                plan.apr
                    .div(100)
                    .mul(block.timestamp - _staking.stakeAt[tokenId])
                    .div(periodicTime)
            );
        }

        return (_earned, _canClaim);
    }

    function unstake(uint256 _stakingId, uint256[] memory tokenIds) public override {
        
        Plan storage plan = plans[_stakingId];
        Staking storage _staking = stakes[_stakingId][msg.sender];
        uint256 _rewards = 0;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(_staking.tokenIds.contains(tokenIds[i]), "Query for a token you haven't staked");
            
            if (block.timestamp >= _staking.endstakeAt[tokenIds[i]]) {
                _rewards = _rewards.add(
                        plan.apr
                            .div(100)
                            .mul(block.timestamp - _staking.stakeAt[tokenIds[i]])
                            .div(periodicTime)
                );
            }

            _staking.tokenIds.remove(tokenIds[i]);
            delete _staking.stakeAt[tokenIds[i]];
            delete _staking.endstakeAt[tokenIds[i]];

            IERC721(stakingToken).safeTransferFrom(address(this), msg.sender, tokenIds[i]);
            plan.overallStaked = plan.overallStaked - 1;
        }
        
        if(_rewards > 0) {
            IERC20(rewardToken).transfer(msg.sender, _rewards);
        }
    }

    function claimEarnedReward(uint256 _stakingId) public override {
        uint256 _rewards = 0;
        Plan storage plan = plans[_stakingId];
        Staking storage _staking = stakes[_stakingId][msg.sender];

        for (uint256 i = 0; i < _staking.tokenIds.length(); i++) {
            uint256 tokenId = _staking.tokenIds.at(i);
            if (block.timestamp >= _staking.endstakeAt[tokenId]) {
                _rewards = _rewards.add(
                        plan.apr
                            .div(100)
                            .mul(block.timestamp - _staking.stakeAt[tokenId])
                            .div(periodicTime)
                );
                _staking.stakeAt[tokenId] = block.timestamp;
            }
        }
        require(_rewards > 0, "There is no amount to claim");
        IERC20(rewardToken).transfer(msg.sender, _rewards);
    }

    function getStakedTokens(uint256 _stakingId, address _account) public override view returns (uint256[] memory) {
        Staking storage _staking = stakes[_stakingId][_account];
        uint256[] memory stakedTokenIds = new uint256[](_staking.tokenIds.length());
        
        for (uint256 i = 0; i < _staking.tokenIds.length(); i++) {
            stakedTokenIds[i] = _staking.tokenIds.at(i);
        }

        return stakedTokenIds;
    }

    function setAPR(uint256 _stakingId, uint256 _percent) external onlyOwner {
        require(_percent >= minAPR);
        plans[_stakingId].apr = _percent;
    }

    function setStakeConclude(uint256 _stakingId, bool _conclude) external onlyOwner {
        plans[_stakingId].conclude = _conclude;
    }

}