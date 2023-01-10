// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "./SafeMath.sol";
import "./BDAONFT.sol";

contract BDAODailyStaking is Ownable {
    using SafeMath for uint256;
    
    struct StakingOption {
        //the name of the NFT tier
        string name;

        //the id of the NFT tier
        uint256 id;

        //indicates wether the NFT tier supports daily rewards
        bool supportsRewardsPerDayNoLockup;

        //indicates wether the NFT tier supports daily rewards
        bool supportsRewardsPerDaySevenDayLockup;

        //indicates wether the NFT tier supports daily rewards
        bool supportsRewardsPerDayFourteenDayLockup;

        //indicates wether the NFT tier supports daily rewards
        bool supportsRewardsPerDayTwentyEightDayLockup;
    }

    struct StakedToken {
        //token id of the NFT
        uint256 tokenId;

        //the wallet address of the staker
        address staker;

        //amount of tokens to be staked with the NFT
        uint256 tokenAmount;

        //the time at which the NFT started to stake
        uint256 stakeTime;

        //the time period for which we want to lock the staking
        uint256 lockupDays;

        //the time when the NFT unlocks
        uint256 unlockTime;
    }

    //staking options
    mapping(uint256 => StakingOption) public stakingOptions;

    //the staked tokens/NFTs
    mapping(uint256 => StakedToken) public stakedTokens;

    //the ERC721 tokens that represent the NFTs
    BDAONFT public nftCollection;

    //the ERC20 token that will be used to stake
    IERC20 public stakingToken;

    //the amount of tokens that the user will get daily as reward for staking with no lockup
    uint256 public rewardsPerDayNoLockupPercentage = 10; //1.0%

    //the amount of tokens that the user will get daily as reward for staking with lockup for 7 days
    uint256 public rewardsPerDaySevenDayLockupPercentage = 20; //2.0%

    //the amount of tokens that the user will get daily as reward for staking with lockup for 14 days
    uint256 public rewardsPerDayFourteenDayLockupPercentage = 30; //3.0%

    //the amount of tokens that the user will get daily as reward for staking with lockup for 28 days
    uint256 public rewardsPerDayTwentyEightDayLockupPercentage = 40; //4.0%

    //indicate the minimum amount of tokens that the user should deposit to access staking
    uint256 public minimumStakingAmount = 1000;

    //indicate the maximum amount of tokens that the user can deposit to access staking
    uint256 public maximumStakingAmount = 10000;

    //indicate the penalty fee percentage
    uint256 public penaltyPercentage = 100; //10.0%

    //indicate whether NFTs are depositable
    bool public areNFTsDepositable = true;

    //indicate whether NFTs are withdrawable after depositing
    bool public areNFTsWithdrawable = true;
    
    //indicate whether new users can stake their NFTs
    bool public isStakingEnabled = true;

    //indicate whether users can unstake their NFT
    bool public isUnstakingEnabled = true;

    //indicate whether users can withdraw their rewards
    bool public areTokensWithdrawable = true;

    event depositedNFT(
        uint256 _tokenId,
        address _from,
        address _to
    );

    event withdrawnNFT(
        uint256 _tokenId,
        address _from,
        address _to
    );

    event staked(
        uint256 _tokenId,
        address _from,
        address _to,
        uint256 _tokenAmount,
        uint256 _stakeTime,
        uint256 _lockupDays,
        uint256 _unlockTime
    );

    event unstaked(
        uint256 _tokenId,
        address _from,
        address _to
    );

    event withdrawnTokens(
        uint256 _tokenId,
        address _from,
        address _to,
        uint256 _tokenAmount,
        uint256 _stakeTime,
        uint256 _lockupDays,
        uint256 _unlockTime,
        uint256 _withdrawTokensTime,
        uint256 _totalWithdrawnTokens,
        uint256 _reward,
        uint256 _penalty
    );

    constructor(address _nftCollectionAddr, address _stakingTokenAddr) {
        nftCollection = BDAONFT(_nftCollectionAddr);
        stakingToken = IERC20(_stakingTokenAddr);

        stakingOptions[0] = StakingOption("ENTRY", 0, true, true, true, true);
        stakingOptions[1] = StakingOption("FRIENDS", 1, true, true, true, true);
        stakingOptions[2] = StakingOption("HODLER", 2, true, true, true, true);
        stakingOptions[3] = StakingOption("WARRIOR", 3, true, true, true, true);
        stakingOptions[4] = StakingOption("WAR", 4, true, true, true, true);
        stakingOptions[5] = StakingOption("COUNCIL", 5, true, true, true, true);
    }

    function depositNFT(uint256 _tokenId) external {
        //check if new users can deposit NFTs
        require(areNFTsDepositable == true, "NFTs are not depositable");

        //check if the NFT is already deposited
        require(stakedTokens[_tokenId].tokenId == 0, "The NFT is already deposited");

        //check if the caller is the nft owner
        require(nftCollection.ownerOf(_tokenId) == msg.sender, "Not owner of the NFT");

        //transfer the NFT to this contract
        nftCollection.transferFrom(msg.sender, address(this), _tokenId);

        //create a new staked token
        stakedTokens[_tokenId] = StakedToken(_tokenId, msg.sender, 0, 0, 0, 0);
    
        //event
        emit depositedNFT(
            _tokenId,
            msg.sender,
            address(this)
        );
    }

    function withdrawNFT(uint256 _tokenId) external {
        //check if the NFTs can be withdrawn after depositing
        require(areNFTsWithdrawable == true, "NFTs are not withdrawable");

        //check if the NFT is deposited
        require(stakedTokens[_tokenId].tokenId != 0, "The NFT is not deposited");

        //check if the caller is the NFT depositor
        require(stakedTokens[_tokenId].staker == msg.sender, "Not staker of the NFT");

        //check if the NFT is staking
        require(stakedTokens[_tokenId].stakeTime == 0, "The NFT is already staking");

        //transfer NFT to the user
        nftCollection.transferFrom(address(this), msg.sender, _tokenId);

        //remove NFT from stakedTokens
        delete stakedTokens[_tokenId];

        //event
        emit withdrawnNFT(
            _tokenId,
            msg.sender,
            address(this)
        );
    }

    function stake(uint256 _tokenId, uint256 _tokenAmount, uint256 _lockupDays) external {
        //check if new users have the ability to stake
        require(isStakingEnabled == true, "Staking is not available");

        //check if the NFT is deposited
        require(stakedTokens[_tokenId].tokenId != 0, "The NFT is not deposited");

        //check if the caller is the NFT staker
        require(stakedTokens[_tokenId].staker == msg.sender, "Not staker of the NFT");

        //check if the NFT is staking
        require(stakedTokens[_tokenId].stakeTime == 0, "The NFT is staking");

        //check if a valid lockup time period was chosen
        require(_lockupDays == 0 || _lockupDays == 7 || _lockupDays == 14 || _lockupDays == 28, "Invalid lockup time period");

        //get the id of the tokenId in the NFT collection contract
        (string memory _name, uint256 _id,,) = nftCollection.tokenIdToTierInfo(_tokenId);

        if (stakingOptions[_id].supportsRewardsPerDayNoLockup == false) {
            require(_lockupDays != 0, "Daily rewards are not supported for this NFT");
        }

        if (stakingOptions[_id].supportsRewardsPerDaySevenDayLockup == false) {
            require(_lockupDays != 7, "Seven day lockup rewards are not supported for this NFT");
        }

        if (stakingOptions[_id].supportsRewardsPerDayFourteenDayLockup == false) {
            require(_lockupDays != 14, "Fourteen day lockup rewards are not supported for this NFT");
        }

        if (stakingOptions[_id].supportsRewardsPerDayTwentyEightDayLockup == false) {
            require(_lockupDays != 28, "Twenty eight day lockup rewards are not supported for this NFT");
        }

        //check if the user is trying to deposit negative or zero amount of token for staking
        require(_tokenAmount >= minimumStakingAmount, "Not enough tokens to stake");

        //check if the user is trying to deposit more tokens than allowed
        require(_tokenAmount <= maximumStakingAmount, "Too many tokens to stake");

        //check if the caller has enough tokens to deposit
        require(stakingToken.balanceOf(msg.sender) >= _tokenAmount, "Not enough tokens to deposit");

        //transfer tokens to this contract
        stakingToken.transferFrom(msg.sender, address(this), _tokenAmount);

        //update the staked token
        stakedTokens[_tokenId].tokenAmount = _tokenAmount;
        stakedTokens[_tokenId].stakeTime = block.timestamp;
        stakedTokens[_tokenId].lockupDays = _lockupDays;
        stakedTokens[_tokenId].unlockTime = stakedTokens[_tokenId].stakeTime + (_lockupDays * 60 * 60 * 24);

        //event
        emit staked(
            _tokenId,
            msg.sender,
            address(this),
            stakedTokens[_tokenId].tokenAmount,
            stakedTokens[_tokenId].stakeTime,
            stakedTokens[_tokenId].lockupDays,
            stakedTokens[_tokenId].unlockTime
        );
    }

    function withdrawTokens(uint256 _tokenId) external {
        //check if users can withdraw tokens
        require(areTokensWithdrawable == true, "Tokens are not withdrawable currently");

        //check if the NFT is deposited
        require(stakedTokens[_tokenId].tokenId != 0, "The NFT is not deposited");

        //check if the caller is the NFT staker
        require(stakedTokens[_tokenId].staker == msg.sender, "Not staker of the NFT");

        //check if the NFT is staking
        require(stakedTokens[_tokenId].stakeTime != 0, "NFT is not staking yet");

        //check if the stakedToken has tokens
        require(stakedTokens[_tokenId].tokenAmount != 0, "Tokens are withdrawn");

        uint256 tokens = stakedTokens[_tokenId].tokenAmount;
        uint256 penalty = 0;
        uint256 reward = calculateTotalReward(_tokenId);

        //add penalty to the withdrawn amount if there was a lockup and tokens are withdrawn before the lockup expiration
        if (stakedTokens[_tokenId].lockupDays != 0 && block.timestamp < stakedTokens[_tokenId].unlockTime) {
            penalty = calculatePenalty(_tokenId);
            reward = 0;
        }

        stakedTokens[_tokenId].tokenAmount = 0;

        //send back tokens to the user his initial investment minus the penalty plus the rewards
        stakingToken.transfer(msg.sender, tokens - penalty + reward);

        //event
        emit withdrawnTokens(
            _tokenId,
            address(this),
            msg.sender,
            tokens,
            stakedTokens[_tokenId].stakeTime,
            stakedTokens[_tokenId].lockupDays,
            stakedTokens[_tokenId].unlockTime,
            block.timestamp,
            tokens - penalty + reward,
            reward,
            penalty
        );
    }

    function unstake(uint256 _tokenId) external {
        //check whether users can unstake their NFT
        require(isUnstakingEnabled == true, "Unstaking is not currently available");

        //check if the NFT is deposited
        require(stakedTokens[_tokenId].tokenId != 0, "The NFT is not deposited");

        //check if the caller is the NFT staker
        require(stakedTokens[_tokenId].staker == msg.sender, "Not staker of the NFT");

        //check if the NFT is staking
        require(stakedTokens[_tokenId].stakeTime != 0, "NFT is not staking yet");

        //check if the tokens are withdrawn because this indicates that penalty and rewards are paid out
        require(stakedTokens[_tokenId].tokenAmount == 0, "Penalty or rewards have not been paid out yet");
        
        //send back the NFT to the user
        nftCollection.transferFrom(address(this), msg.sender, _tokenId);

        //remove NFT from stakedTokens
        delete stakedTokens[_tokenId];

        //event
        emit unstaked(
            _tokenId,
            address(this),
            msg.sender
        );
    }

    function calculatePenalty(uint256 _tokenId) public view returns(uint256) {
        return stakedTokens[_tokenId].tokenAmount.mul(penaltyPercentage).div(1000); 
    }

    function calculateTotalReward(uint256 _tokenId) public view returns(uint256) {
        uint256 dailyReward = calculateDailyReward(_tokenId);
        uint256 daysPassed = stakedTokens[_tokenId].lockupDays;
        
        if (stakedTokens[_tokenId].lockupDays == 0) {
            daysPassed = calculateDaysPassed(_tokenId);
        }
        
        return dailyReward * daysPassed;
    }

    function calculateTotalRewardSoFar(uint256 _tokenId) public view returns(uint256) {
        uint256 dailyReward = calculateDailyReward(_tokenId);
        uint256 daysPassed = calculateDaysPassed(_tokenId);
        
        if (stakedTokens[_tokenId].lockupDays != 0 && daysPassed > stakedTokens[_tokenId].lockupDays) {
            daysPassed = stakedTokens[_tokenId].lockupDays;
        }
        
        return dailyReward * daysPassed;
    }

    function calculateDailyReward(uint256 _tokenId) public view returns(uint256) {
        uint256 dailyReward = 0;

        if (stakedTokens[_tokenId].lockupDays == 0) {
            dailyReward = stakedTokens[_tokenId].tokenAmount.mul(rewardsPerDayNoLockupPercentage).div(1000);
        } else if (stakedTokens[_tokenId].lockupDays == 7) {
            dailyReward = stakedTokens[_tokenId].tokenAmount.mul(rewardsPerDaySevenDayLockupPercentage).div(1000);
        } else if (stakedTokens[_tokenId].lockupDays == 14) {
            dailyReward = stakedTokens[_tokenId].tokenAmount.mul(rewardsPerDayFourteenDayLockupPercentage).div(1000);
        } else {
            dailyReward = stakedTokens[_tokenId].tokenAmount.mul(rewardsPerDayTwentyEightDayLockupPercentage).div(1000);
        }

        return dailyReward;
    }

    function calculateDaysPassed(uint256 _tokenId) public view returns(uint256) {
        uint256 diff = block.timestamp - stakedTokens[_tokenId].stakeTime;
        return diff / (60 * 60 * 24);
    }

    function calculateHoursPassed(uint256 _tokenId) public view returns(uint256) {
        uint256 diff = block.timestamp - stakedTokens[_tokenId].stakeTime;
        return diff / (60 * 60);
    }

    function calculateMinutesPassed(uint256 _tokenId) public view returns(uint256) {
        uint256 diff = block.timestamp - stakedTokens[_tokenId].stakeTime;
        return diff / 60;
    }

    //
    // GETTERS
    //

    function getStakedTokensOfStaker(address staker) public view returns(uint256[] memory _stakedTokens) {
        uint256 supply = nftCollection.totalSupply();
        uint256[] memory tmp = new uint256[](supply);
        uint256 index = 0;

        for(uint tokenId = 1; tokenId <= supply; tokenId++) {
            if (stakedTokens[tokenId].staker == staker) {
                tmp[index] = stakedTokens[tokenId].tokenId;
                index +=1;
            }
        }

        uint256[] memory tokens = new uint256[](index);

        for(uint i = 0; i < index; i++) {
            tokens[i] = tmp[i];
        }

        return tokens;
    }

    //
    // SETTERS
    //

    function setStakingOptions(uint256 _id,
     bool _supportsRewardsPerDayNoLockup,
     bool _supportsRewardsPerDaySevenDayLockup,
     bool _supportsRewardsPerDayFourteenDayLockup,
     bool _supportsRewardsPerDayTwentyEightDayLockup) external onlyOwner {
         stakingOptions[_id].supportsRewardsPerDayNoLockup = _supportsRewardsPerDayNoLockup;
         stakingOptions[_id].supportsRewardsPerDaySevenDayLockup = _supportsRewardsPerDaySevenDayLockup;
         stakingOptions[_id].supportsRewardsPerDayFourteenDayLockup = _supportsRewardsPerDayFourteenDayLockup;
         stakingOptions[_id].supportsRewardsPerDayTwentyEightDayLockup = _supportsRewardsPerDayTwentyEightDayLockup;
    }

    function setRewardsPerDayNoLockupPercentage(uint256 _percentage) external onlyOwner {
        rewardsPerDayNoLockupPercentage = _percentage;
    }

    function setRewardsPerDaySevenDayLockupPercentage(uint256 _percentage) external onlyOwner {
        rewardsPerDaySevenDayLockupPercentage = _percentage;
    }

    function setRewardsPerDayFourteenDayLockupPercentage(uint256 _percentage) external onlyOwner {
        rewardsPerDayFourteenDayLockupPercentage = _percentage;
    }

    function setRewardsPerDayTwentyEightDayLockupPercentage(uint256 _percentage) external onlyOwner {
        rewardsPerDayTwentyEightDayLockupPercentage = _percentage;
    }

    function setMinimumStakingAmount(uint256 _amount) external onlyOwner {
        minimumStakingAmount = _amount;
    }

    function setMaximumStakingAmount(uint256 _amount) external onlyOwner {
        maximumStakingAmount = _amount;
    }

    function setPenaltyPercentage(uint256 _percentage) external onlyOwner {
        penaltyPercentage = _percentage;
    }

    function setNFTsDepositable(bool _depositable) external onlyOwner {
        areNFTsDepositable = _depositable;
    }

    function setNFTsWithdrawable(bool _withdrawable) external onlyOwner {
        areNFTsWithdrawable = _withdrawable;
    }

    function setStakingEnabled(bool _enabled) external onlyOwner {
        isStakingEnabled = _enabled;
    }

    function setUnstakingEnabled(bool _enabled) external onlyOwner {
        isUnstakingEnabled = _enabled;
    }

    function setTokensWithdrawable(bool _withdrawable) external onlyOwner {
        areTokensWithdrawable = _withdrawable;
    }

    function recoverTokens() external onlyOwner {
        stakingToken.transfer(msg.sender, stakingToken.balanceOf(address(this)));
    }

    function recoverEth() external onlyOwner {
        payable(address(msg.sender)).transfer(address(this).balance);
    }
}