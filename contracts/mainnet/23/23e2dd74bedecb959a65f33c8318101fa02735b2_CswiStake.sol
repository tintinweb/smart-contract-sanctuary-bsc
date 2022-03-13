// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./IBEP721.sol";
import "./IERC721Receiver.sol";
import "./AccessControlEnumerable.sol";

contract CswiStake is AccessControlEnumerable {

    IBEP721 public parentNFT;

    uint256 public rate;

    struct StakerHolder {
        address owner;
        NftStake[] nftStakes;
    }

    struct NftStake {
        uint256 uniqueId;
        uint256 tokenId;
        uint256 startTime;
        uint256 endTime;
        uint256 reward;
        bool active;
        bool locked;
        uint256 lockedPeriod;
        uint256 expectedEndTime;
    }

    bool internal enabled = true;

    uint256 internal defaultScore = 1;

    uint256 internal defaultBoost = 1;

    uint256 internal totalStakedSupply;

    StakerHolder[] internal stakeholders;

    mapping(address => uint256) internal stakesHolderIdMappings;

    mapping(uint256 => uint256) internal nftStakeIdMappings;

    mapping(uint256 => uint256) internal nftBoostMappings;

    mapping(uint256 => uint256) internal lockedPeriodDayMappings;

    mapping(uint256 => uint256) internal lockedPeriodRewardMappings;

    mapping(uint256 => uint256) internal nftScoreMappings;

    constructor() {
        parentNFT = IBEP721(0x9c09F1Fba6b1dc5Fd92C706235188387b271aBcA);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        rate = 10000;

        lockedPeriodDayMappings[0] = 0 days;
        lockedPeriodDayMappings[1] = 7 days;
        lockedPeriodDayMappings[2] = 14 days;
        lockedPeriodDayMappings[3] = 30 days;
        lockedPeriodDayMappings[4] = 90 days;

        lockedPeriodRewardMappings[0] = 0;
        lockedPeriodRewardMappings[1] = 2;
        lockedPeriodRewardMappings[2] = 5;
        lockedPeriodRewardMappings[3] = 15;
        lockedPeriodRewardMappings[4] = 50;
    }

    // Check if staking is enabled
    function isEnabled() public view returns (bool) {
        return enabled;
    }

    // Enable staking
    function start() public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Staking: must have admin role to enable staking");
        enabled = true;
    }

    // Disable staking
    function disable() public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Staking: must have admin role to disable staking");
        enabled = false;
    }

    // Change Parrent
    function changeParent(address _parent) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Staking: must have admin role to change parent");
        parentNFT = IBEP721(_parent);
    }

    // Stake multiple NFTs
    function batchStake(uint256[] calldata _tokenIds, bool _locked, uint256 _lockedPeriod) public {
        uint256 numTokens = _tokenIds.length;
        require(numTokens != 0, "Staking: no tokens");

        for (uint256 index = 0; index < numTokens; ++index) {
            stake(_tokenIds[index], _locked, _lockedPeriod);
        }
    }

    // Get active NFts count
    function activeStakeCountOf(address _owner) public view returns (uint256) {
        NftStake[] memory stakes = stakeholders[stakesHolderIdMappings[_owner]].nftStakes;
        if(stakes.length == 0) {
            return 0;
        }

        uint256 activeNFtsCount;
        for (uint256 index = 0; index < stakes.length; ++index) {
            if(stakes[index].active) {
                ++activeNFtsCount;
            }
        }
        return activeNFtsCount;
    }

    // Return only active stakes
    function activeStakesOf(address _owner) public view returns (NftStake[] memory) {
        uint256 activeStakeCount = activeStakeCountOf(_owner);
        require(activeStakeCount > 0, "Staking: no active stake to show");

        NftStake[] memory stakes = stakeholders[stakesHolderIdMappings[_owner]].nftStakes;

        // Create Array with active nfts
        NftStake[] memory activeNftStakes = new NftStake[](activeStakeCount);

        uint256 activeIndex = 0;
        for (uint256 index = 0; index < stakes.length; ++index) {
            if(stakes[index].active) {
                //Add active stakes to array
                activeNftStakes[activeIndex] = stakes[index];
                ++activeIndex;
            }
        }
        return activeNftStakes;
    }

    // Active Stake of
    function activeStakeOf(address _owner, uint256 _activeIndex) public view returns (NftStake memory) {
        return activeStakesOf(_owner)[_activeIndex];
    }

    // Active Stake start time of
    function activeStakeValuesOf(address _owner, uint256 _activeIndex) public view returns(uint256 uniqueId, uint256 tokenId, uint256 startTime, uint256 endTime, uint256 reward, bool active, bool locked, uint256 lockedPeriod, uint256 expectedEndTime) {
        NftStake memory nftStake = activeStakeOf(_owner, _activeIndex);
        return (nftStake.uniqueId, nftStake.tokenId, nftStake.startTime, nftStake.endTime, nftStake.reward, nftStake.active, nftStake.locked, nftStake.lockedPeriod, nftStake.expectedEndTime);
    } 
    
    // Get stakeholders count
    function totalStakeholders() public view returns (uint256) {
        return stakeholders.length;
    }

    // Get staked nfts count
    function totalStakedNfts() public view returns (uint256) {
        return totalStakedSupply;
    }

    // Check if address is stakeholder
    function isStakeholder(address _address) public view returns(bool) {
       for (uint256 index = 0; index < stakeholders.length; index += 1){
           if (_address == stakeholders[index].owner) return true;
       }
       return false;
    }

    // Check if token is staked
    function isTokenStaked(uint256 _tokenId) public view returns(bool) {
        for (uint256 index = 0; index < stakeholders.length; index += 1){
            NftStake[] memory stakes = stakeholders[index].nftStakes;
            for(uint256 nftIndex = 0; nftIndex < stakes.length; nftIndex += 1) {
                if(stakes[nftIndex].tokenId == _tokenId && stakes[nftIndex].active) {
                    return true;
                }
            }
        }
        return false;
    }

    // Stake Nft
    function stake(uint256 _tokenId, bool _locked, uint256 _lockedPeriod) public {
        require(enabled, "Staking: contract is not enabled");
        require(_lockedPeriod < 5, "Staking: unknow locked period");

        parentNFT.safeTransferFrom(msg.sender, address(this), _tokenId);

        if(!isStakeholder(msg.sender)) {
            stakeholders.push();
            uint256 index = stakeholders.length -1;
            stakeholders[index].owner = msg.sender;
            stakesHolderIdMappings[msg.sender] = index;
        }

        stakeholders[stakesHolderIdMappings[msg.sender]].nftStakes.push();
        uint256 nftIndex = stakeholders[stakesHolderIdMappings[msg.sender]].nftStakes.length - 1;
        nftStakeIdMappings[_tokenId] = nftIndex;

        stakeholders[stakesHolderIdMappings[msg.sender]].nftStakes[nftStakeIdMappings[_tokenId]] = NftStake(nftIndex, _tokenId, block.timestamp, 0, 0, true, _locked, _lockedPeriod, block.timestamp + lockedPeriodDayMappings[_lockedPeriod]);
        ++totalStakedSupply;
    }

    // Unstake Nft
    function unstake(uint256 _tokenId) public {       
        parentNFT.safeTransferFrom(address(this), msg.sender, _tokenId);
        claimRewardOf(msg.sender, _tokenId); 

        stakeholders[stakesHolderIdMappings[msg.sender]].nftStakes[nftStakeIdMappings[_tokenId]].endTime = block.timestamp;
        stakeholders[stakesHolderIdMappings[msg.sender]].nftStakes[nftStakeIdMappings[_tokenId]].active = false;
        --totalStakedSupply;
    }

    // Emergency Unstake
    function emergencyUnstakeAll() public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Staking: must have admin role to emergency unstake");
        for(uint256 stakeholderIndex = 0; stakeholderIndex < stakeholders.length; stakeholderIndex += 1) {
            NftStake[] memory nftStakes = activeStakesOf(stakeholders[stakeholderIndex].owner);
            for(uint256 nftIndex = 0; nftIndex < stakeholders.length; nftIndex += 1) {
                unstake(nftStakes[nftIndex].tokenId);
            }
        }
    }

    // Real locked period of
    function lockedPeriodOf(uint256 _rawLockedPeriod) public view returns (uint256) {
        return lockedPeriodDayMappings[_rawLockedPeriod];
    }

    // Update real locked period of
    function updateLockedPeriodOf(uint256 _rawLockedPeriod, uint256 _lockedPeriodValue) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Staking: must have admin role to update locked period");
        lockedPeriodDayMappings[_rawLockedPeriod] = _lockedPeriodValue;
    }

    // Real locked period bonus of
    function lockedPeriodBonusOf(uint256 _rawLockedPeriodBonus) public view returns (uint256) {
        return lockedPeriodRewardMappings[_rawLockedPeriodBonus];
    }

    // Update real locked period bonus of
    function updateLockedPeriodBonusOf(uint256 _rawLockedPeriodBonus, uint256 _lockedPeriodBonusValue) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Staking: must have admin role to update locked bonus period");
        lockedPeriodRewardMappings[_rawLockedPeriodBonus] = _lockedPeriodBonusValue;
    }

    // History length of
    function historyLengthOf(address _owner) public view returns (uint256) {
        NftStake[] memory nftStakes = stakeholders[stakesHolderIdMappings[_owner]].nftStakes;

        uint256 historyLength = 0;
        for(uint256 nftIndex = 0; nftIndex < nftStakes.length; nftIndex += 1) {
            if(nftStakes[nftIndex].endTime != 0) {
                ++historyLength;
            }
        }
        return historyLength;
    }

    // History stakes of
    function historyStakesOf(address _owner) public view returns (NftStake[] memory) {
        uint256 historyLength = historyLengthOf(_owner);
        require(historyLength > 0, "Staking: no history to show");

        NftStake[] memory stakes = stakeholders[stakesHolderIdMappings[_owner]].nftStakes;

        // Create Array with active nfts
        NftStake[] memory historyNftStakes = new NftStake[](historyLength);

        uint256 historyIndex = 0;
        for (uint256 index = 0; index < stakes.length; ++index) {
            if(stakes[index].endTime != 0) {
                //Add active stakes to array
                historyNftStakes[historyIndex] = stakes[index];
                ++historyIndex;
            }
        }
        return historyNftStakes;
    }

    // Get stake history of
    function stakeHistoryOf(address _owner, uint256 _historyIndex) public view returns (NftStake memory) {
        return historyStakesOf(_owner)[_historyIndex];
    }

    function stakeHistoryValuesOf(address _owner, uint256 _historyIndex) public view returns (uint256 uniqueId, uint256 tokenId, uint256 startTime, uint256 endTime, uint256 reward, bool active, bool locked, uint256 lockedPeriod, uint256 expectedEndTime) {
        NftStake memory nftStake = stakeHistoryOf(_owner, _historyIndex);
        return (nftStake.uniqueId, nftStake.tokenId, nftStake.startTime, nftStake.endTime, nftStake.reward, nftStake.active, nftStake.locked, nftStake.lockedPeriod, nftStake.expectedEndTime);
    }

    // Batch instake nfts
    function batchUnstake(uint256[] calldata _tokenIds) public {
        uint256 numTokens = _tokenIds.length;
        require(numTokens != 0, "Staking: no tokens");

        for (uint256 index = 0; index < numTokens; ++index) {
            unstake(_tokenIds[index]);
        }
    }

    // Get active stake time of nft
    function stakeTimeOf(address _owner, uint256 _tokenId) public view returns (uint256) {
        require(isStakeholder(_owner), "Staking: owner is not stakeholder");
        require(isTokenStaked(_tokenId), "Staking: token is not staked");
        return block.timestamp - stakeholders[stakesHolderIdMappings[_owner]].nftStakes[nftStakeIdMappings[_tokenId]].startTime;
    }

    // Reward of token by owner
    function rewardOf(address _owner, uint256 _tokenId) public view returns(uint256, uint256) {
        uint256 id = nftStakeIdMappings[_tokenId];
        require(isStakeholder(_owner), "Staking: owner is not stakeholder");
        require(isTokenStaked(_tokenId), "Staking: token is not staked");

        NftStake memory nftStake = stakeholders[stakesHolderIdMappings[_owner]].nftStakes[id];

        uint256 earned = 1 ether * scoreOf(_tokenId) * (block.timestamp - nftStake.startTime) / 1 days;
        uint256 boost = boostOf(_tokenId);
        earned = stakedSupply() * boost * earned / rate;

        uint256 earnRatePerSecond = scoreOf(_tokenId) * 1 ether / 1 days;
        earnRatePerSecond = stakedSupply() * boost * earnRatePerSecond / rate;

        if(nftStake.locked && nftStake.lockedPeriod != 0) {
            uint256 lockedBonus = lockedPeriodRewardMappings[nftStake.lockedPeriod] / 100;
            earned += earned * lockedBonus;
            earnRatePerSecond += earnRatePerSecond * lockedBonus;
        }

        return (earned, earnRatePerSecond);
    }

    function rewardPerSecond() public view returns(uint256) {
        uint256 earnRatePerSecond = defaultScore * 1 ether / 1 days;
        earnRatePerSecond = stakedSupply() * defaultBoost * earnRatePerSecond / rate;
        return earnRatePerSecond;
    }

    // Rewards of owner
    function totalRewardOf(address _owner) public view returns (uint256) {
        require(isStakeholder(_owner), "Staking: owner is not stakeholder");

        uint256 _totalRewards = 0;
        NftStake[] memory activeStake = activeStakesOf(_owner);
        for (uint256 index = 0; index < activeStake.length; index += 1){
            (uint256 reward, ) = rewardOf(_owner, activeStake[index].tokenId);
            _totalRewards += reward;
        }
        return _totalRewards;
    }

    // Update rate
    function updateRate(uint256 _rate) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Staking: must have admin role to update rate");
        rate = _rate;
    }

    // Set score
    function setScore(uint256 _tokenId, uint256 _score) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Staking: must have admin role to update score");
        nftScoreMappings[_tokenId] = _score;
    }

    // Get score of
    function scoreOf(uint256 _tokenId) public view returns(uint256) {
        uint256 score = nftScoreMappings[_tokenId];
        if(score == 0) {
            return defaultScore;
        }
        return score;
    }

    // Set boost
    function setBoost(uint256 _tokenId, uint256 _boost) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Staking: must have admin role to update boost");
        nftBoostMappings[_tokenId] = _boost;
    }

    // get boost of
    function boostOf(uint256 _tokenId) public view returns(uint256) {
        uint256 score = nftBoostMappings[_tokenId];
        if(score == 0) {
            return defaultBoost;
        }
        return score;
    }

    // Claim Rewards
    function claimRewardOf(address _owner, uint256 _tokenId) public returns(uint256) {
        (uint256 reward, ) = rewardOf(_owner, _tokenId);
        stakeholders[stakesHolderIdMappings[_owner]].nftStakes[nftStakeIdMappings[_tokenId]].reward += reward;
        stakeholders[stakesHolderIdMappings[_owner]].nftStakes[nftStakeIdMappings[_tokenId]].startTime = block.timestamp;
        return reward;
    }

    // Claim all rewards of all tokens
    function claimAllRewardsOf(address _owner) public {
        require(isStakeholder(_owner), "Staking: owner is not stakeholder");
        NftStake[] memory nftStakes = stakeholders[stakesHolderIdMappings[_owner]].nftStakes;
        for (uint256 index = 0; index < nftStakes.length; ++index) {
            if(nftStakes[index].active) {
                claimRewardOf(_owner, nftStakes[index].tokenId);
            }
        }
    }

    // Staked supply
    function stakedSupply() public view returns (uint256) {
        return parentNFT.totalSupply() / totalStakedSupply;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}