pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

import "./IContract.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./EnumerableSet.sol";
import "./IterableMapping.sol";

contract CloverDarkSeedStake is Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    using IterableMapping for IterableMapping.Map;

    uint256 public CloverFieldCarbonRewardRate = 15e18;
    uint256 public CloverFieldPearlRewardRate = 3e19;
    uint256 public CloverFieldRubyRewardRate = 2e20;
    uint256 public CloverFieldDiamondRewardRate = 4e20;

    uint256 public CloverYardCarbonRewardRate = 1e17;
    uint256 public CloverYardPearlRewardRate = 2e17;
    uint256 public CloverYardRubyRewardRate = 12e17;
    uint256 public CloverYardDiamondRewardRate = 24e17;

    uint256 public CloverPotCarbonRewardRate = 8e15;
    uint256 public CloverPotPearlRewardRate = 12e15;
    uint256 public CloverPotRubyRewardRate = 6e16;
    uint256 public CloverPotDiamondRewardRate = 12e16;

    uint256 public rewardInterval = 1 days;
    uint256 public marketingFee = 1000;
    uint256 public totalClaimedRewards;
    uint256 public marketingFeeTotal;
    uint256 public waterInterval = 2 days;

    address public DarkSeedToken;
    address public DarkSeedNFT;
    address public DarkSeedController;
    address public DarkSeedPicker;

    address public marketingWallet;

    
    bool public isStakingEnabled = false;
    bool public isMarketingFeeActivated = false;
    bool public canClaimReward = false;

    EnumerableSet.AddressSet private CloverDiamondFieldAddresses;
    EnumerableSet.AddressSet private CloverDiamondYardAddresses;
    EnumerableSet.AddressSet private CloverDiamondPotAddresses;
    EnumerableSet.AddressSet private holders;

    mapping (address => uint256) public depositedCloverFieldCarbon;
    mapping (address => uint256) public depositedCloverFieldPearl;
    mapping (address => uint256) public depositedCloverFieldRuby;
    mapping (address => uint256) public depositedCloverFieldDiamond;

    mapping (address => uint256) public depositedCloverYardCarbon;
    mapping (address => uint256) public depositedCloverYardPearl;
    mapping (address => uint256) public depositedCloverYardRuby;
    mapping (address => uint256) public depositedCloverYardDiamond;

    mapping (address => uint256) public depositedCloverPotCarbon;
    mapping (address => uint256) public depositedCloverPotPearl;
    mapping (address => uint256) public depositedCloverPotRuby;
    mapping (address => uint256) public depositedCloverPotDiamond;

    mapping (address => uint256) public claimableRewards;

    mapping (address => uint256) public stakingTime;
    mapping (address => uint256) public totalDepositedTokens;
    mapping (address => uint256) public totalEarnedTokens;
    mapping (address => uint256) public lastClaimedTime;
    mapping (address => uint256) public lastWatered;
    mapping (address => bool) public noMarketingList;

    IterableMapping.Map private _owners;
    // mapping(uint256 => address) private _owners;

    event RewardsTransferred(address holder, uint256 amount);

    constructor(address _marketingWallet, address _DarkSeedToken, address _DarkSeedNFT, address _DarkSeedController, address _DarkSeedPicker) {
        DarkSeedPicker = _DarkSeedPicker;
        DarkSeedToken = _DarkSeedToken;
        DarkSeedNFT = _DarkSeedNFT;
        DarkSeedController = _DarkSeedController;
        marketingWallet = _marketingWallet;

        CloverDiamondFieldAddresses.add(address(0));
        CloverDiamondYardAddresses.add(address(0));
        CloverDiamondPotAddresses.add(address(0));
    }
    
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners.get(tokenId);
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function randomNumberForCloverField() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
    }

    function getLuckyWalletForCloverField() public view returns (address) {
        require (msg.sender == DarkSeedController, "Only controller can call this function");
        uint256 luckyWallet = randomNumberForCloverField() % CloverDiamondFieldAddresses.length();
        return CloverDiamondFieldAddresses.at(luckyWallet);
    }

    function randomNumberForCloverYard() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
    }

    function getLuckyWalletForCloverYard() public view returns (address) {
        require (msg.sender == DarkSeedController, "Only controller can call this function");
        uint256 luckyWallet = randomNumberForCloverYard() % CloverDiamondYardAddresses.length();
        return CloverDiamondYardAddresses.at(luckyWallet);
    }

    function randomNumberForCloverPot() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
    }

    function getLuckyWalletForCloverPot() public view returns (address) {
        require (msg.sender == DarkSeedController, "Only controller can call this function");
        uint256 luckyWallet = randomNumberForCloverPot() % CloverDiamondPotAddresses.length();
        return CloverDiamondPotAddresses.at(luckyWallet);
    }

    function updateAccount(address account) private {
        uint256 pendingDivs = getPendingDivs(account);
        lastClaimedTime[account] = block.timestamp;
        claimableRewards[account] += pendingDivs;
    }

    function estimateRewards(address account) public returns(uint256) {
        updateAccount(account);
        return claimableRewards[account];
    }
    
    function getPendingDivs(address _holder) public view returns (uint256) {
        
        uint256 pendingDivs = getPendingDivsField(_holder)
        .add(getPendingDivsYard(_holder))
        .add(getPendingDivsPot(_holder));
            
        return pendingDivs;
    }
    
    function getNumberOfHolders() public view returns (uint256) {
        return holders.length();
    }
    
    function claimDivs() public {
        require(canClaimReward, "Please waite to enable this function..");
        address account = msg.sender;
        updateAccount(account);
        if (claimableRewards[account] > 0){
            uint256 rewards = claimableRewards[account];
            uint256 _marketingFee = rewards * marketingFee / 10000;
            uint256 afterFee = rewards - _marketingFee;
            if (!isMarketingFeeActivated || noMarketingList[account]) {
                require(IContract(DarkSeedToken).sendToken2Account(account, rewards), "Can't transfer tokens!");
                totalEarnedTokens[account] = totalEarnedTokens[account].add(rewards);
                totalClaimedRewards = totalClaimedRewards.add(rewards);
                emit RewardsTransferred(account, rewards);
            } else {
                require(IContract(DarkSeedToken).sendToken2Account(account, afterFee), "Can't transfer tokens!");
                require(IContract(DarkSeedToken).sendToken2Account(marketingWallet, marketingFee), "Can't transfer tokens.");
                totalEarnedTokens[account] = totalEarnedTokens[account].add(afterFee);
                totalClaimedRewards = totalClaimedRewards.add(rewards);
                emit RewardsTransferred(account, afterFee);
            }
        }
        claimableRewards[account] = 0;
    }

    function updateRewardInterval(uint256 _sec) public onlyOwner {
        rewardInterval = _sec;
    }

    function updateCloverField_Carbon_Pearl_Ruby_Diamond_RewardRate(uint256 _carbon, uint256 _pearl, uint256 _ruby, uint256 _diamond) public onlyOwner {
        CloverFieldCarbonRewardRate = _carbon;
        CloverFieldPearlRewardRate = _pearl;
        CloverFieldRubyRewardRate = _ruby;
        CloverFieldDiamondRewardRate = _diamond;
    }

    function updateCloverYard_Carbon_Pearl_Ruby_Diamond_RewardRate(uint256 _carbon, uint256 _pearl, uint256 _ruby, uint256 _diamond) public onlyOwner {
        CloverYardCarbonRewardRate = _carbon;
        CloverYardPearlRewardRate = _pearl;
        CloverYardRubyRewardRate = _ruby;
        CloverYardDiamondRewardRate = _diamond;
    }

    function updateCloverPot_Carbon_Pearl_Ruby_Diamond_RewardRate(uint256 _carbon, uint256 _pearl, uint256 _ruby, uint256 _diamond) public onlyOwner {
        CloverPotCarbonRewardRate = _carbon;
        CloverPotPearlRewardRate = _pearl;
        CloverPotRubyRewardRate = _ruby;
        CloverPotDiamondRewardRate = _diamond;
    }

    function getTimeDiff(address _holder) internal view returns (uint256) {
        require(holders.contains(_holder), "You are not a holder!");
        require(totalDepositedTokens[_holder] > 0, "You have no tokens!");
        uint256 wastedTime = 0;
        if (block.timestamp - lastWatered[msg.sender] > waterInterval) {
            wastedTime = block.timestamp - lastWatered[msg.sender] - waterInterval;
        } 
        uint256 timeDiff = block.timestamp.sub(lastClaimedTime[_holder]);
        if (timeDiff > wastedTime) {
            timeDiff -= wastedTime;
        } 
        return timeDiff;
    }

    function getCloverFieldCarbonReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverFieldCarbon = depositedCloverFieldCarbon[_holder];
        uint256 CloverFieldCarbonReward = cloverFieldCarbon.mul(CloverFieldCarbonRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverFieldCarbonReward;
    }

    function getCloverFieldPearlReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverFieldPearl = depositedCloverFieldPearl[_holder];
        uint256 CloverFieldPearlReward = cloverFieldPearl.mul(CloverFieldPearlRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverFieldPearlReward;
    }

    function getCloverFieldRubyReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverFieldRuby = depositedCloverFieldRuby[_holder];
        uint256 CloverFieldRubyReward = cloverFieldRuby.mul(CloverFieldRubyRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverFieldRubyReward;
    }

    function getCloverFieldDiamondReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverFieldDiamond = depositedCloverFieldDiamond[_holder];
        uint256 CloverFieldDiamondReward = cloverFieldDiamond.mul(CloverFieldDiamondRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverFieldDiamondReward;
    }

    function getCloverYardCarbonReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverYardCarbon = depositedCloverYardCarbon[_holder];
        uint256 CloverYardCarbonReward = cloverYardCarbon.mul(CloverYardCarbonRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverYardCarbonReward;
    }

    function getCloverYardPearlReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverYardPearl = depositedCloverYardPearl[_holder];
        uint256 CloverYardPearlReward = cloverYardPearl.mul(CloverYardPearlRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverYardPearlReward;
    }

    function getCloverYardRubyReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverYardRuby = depositedCloverYardRuby[_holder];
        uint256 CloverYardRubyReward = cloverYardRuby.mul(CloverYardRubyRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverYardRubyReward;
    }

    function getCloverYardDiamondReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverYardDiamond = depositedCloverYardDiamond[_holder];
        uint256 CloverYardDiamondReward = cloverYardDiamond.mul(CloverYardDiamondRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverYardDiamondReward;
    }

    function getCloverPotCarbonReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverPotCarbon = depositedCloverPotCarbon[_holder];
        uint256 CloverPotCarbonReward = cloverPotCarbon.mul(CloverPotCarbonRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverPotCarbonReward;
    }

    function getCloverPotPearlReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverPotPearl = depositedCloverPotPearl[_holder];
        uint256 CloverPotPearlReward = cloverPotPearl.mul(CloverPotPearlRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverPotPearlReward;
    }

    function getCloverPotRubyReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverPotRuby = depositedCloverPotRuby[_holder];
        uint256 CloverPotRubyReward = cloverPotRuby.mul(CloverPotRubyRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverPotRubyReward;
    }

    function getCloverPotDiamondReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 cloverPotDiamond = depositedCloverPotDiamond[_holder];
        uint256 CloverPotDiamondReward = cloverPotDiamond.mul(CloverPotDiamondRewardRate).div(rewardInterval).mul(getTimeDiff(_holder));

        return CloverPotDiamondReward;
    }
    
    function getPendingDivsField(address _holder) private view returns (uint256) {
        
        uint256 pendingDivs = getCloverFieldCarbonReward(_holder)
        .add(getCloverFieldPearlReward(_holder))
        .add(getCloverFieldRubyReward(_holder))
        .add(getCloverFieldDiamondReward(_holder));
            
        return pendingDivs;
    }
    
    function getPendingDivsYard(address _holder) private view returns (uint256) {
        
        uint256 pendingDivs = getCloverYardCarbonReward(_holder)
        .add(getCloverYardPearlReward(_holder))
        .add(getCloverYardRubyReward(_holder))
        .add(getCloverYardDiamondReward(_holder));
            
        return pendingDivs;
    }
    
    function getPendingDivsPot(address _holder) private view returns (uint256) {
        
        uint256 pendingDivs = getCloverPotCarbonReward(_holder)
        .add(getCloverPotPearlReward(_holder))
        .add(getCloverPotRubyReward(_holder))
        .add(getCloverPotDiamondReward(_holder));
            
        return pendingDivs;
    }

    function stake(uint256[] memory tokenId) public {
        require(isStakingEnabled, "Staking is not activeted yet..");

        updateAccount(msg.sender);
        
        for (uint256 i = 0; i < tokenId.length; i++) {

            IContract(DarkSeedNFT).setApprovalForAll_(address(this));
            IContract(DarkSeedNFT).safeTransferFrom(msg.sender, address(this), tokenId[i]);

            if (tokenId[i] <= 1e3) {
                if (IContract(DarkSeedController).isCloverFieldCarbon_(tokenId[i])) {
                    depositedCloverFieldCarbon[msg.sender]++;
                } else if (IContract(DarkSeedController).isCloverFieldPearl_(tokenId[i])) {
                    depositedCloverFieldPearl[msg.sender]++;
                } else if (IContract(DarkSeedController).isCloverFieldRuby_(tokenId[i])) {
                    depositedCloverFieldRuby[msg.sender]++;
                } else if (IContract(DarkSeedController).isCloverFieldDiamond_(tokenId[i])) {
                    depositedCloverFieldDiamond[msg.sender]++;
                    if (!CloverDiamondFieldAddresses.contains(msg.sender)) {
                        CloverDiamondFieldAddresses.add(msg.sender);
                    }
                }
            }

            if (tokenId[i] > 1e3 && tokenId[i] <= 11e3) {
                if (IContract(DarkSeedController).isCloverYardCarbon_(tokenId[i])) {
                    depositedCloverYardCarbon[msg.sender]++;
                } else if (IContract(DarkSeedController).isCloverYardPearl_(tokenId[i])) {
                    depositedCloverYardPearl[msg.sender]++;
                } else if (IContract(DarkSeedController).isCloverYardRuby_(tokenId[i])) {
                    depositedCloverYardRuby[msg.sender]++;
                } else if (IContract(DarkSeedController).isCloverYardDiamond_(tokenId[i])) {
                    depositedCloverYardDiamond[msg.sender]++;
                    if (!CloverDiamondYardAddresses.contains(msg.sender)) {
                        CloverDiamondYardAddresses.add(msg.sender);
                    }
                }
            }

            if (tokenId[i] > 11e3 && tokenId[i] <= 111e3) {
                if (IContract(DarkSeedController).isCloverPotCarbon_(tokenId[i])) {
                    depositedCloverPotCarbon[msg.sender]++;
                } else if (IContract(DarkSeedController).isCloverPotPearl_(tokenId[i])) {
                    depositedCloverPotPearl[msg.sender]++;
                } else if (IContract(DarkSeedController).isCloverPotRuby_(tokenId[i])) {
                    depositedCloverPotRuby[msg.sender]++;
                } else if (IContract(DarkSeedController).isCloverPotDiamond_(tokenId[i])) {
                    depositedCloverPotDiamond[msg.sender]++;
                    if (!CloverDiamondPotAddresses.contains(msg.sender)) {
                        CloverDiamondPotAddresses.add(msg.sender);
                    }
                }
            }

            if (tokenId[i] > 0) {
                _owners.set(tokenId[i], msg.sender);
            }

            totalDepositedTokens[msg.sender]++;
        }

        if (!holders.contains(msg.sender) && totalDepositedTokens[msg.sender] > 0) {
            holders.add(msg.sender);
            stakingTime[msg.sender] = block.timestamp;
            lastWatered[msg.sender] = block.timestamp;
        }
    }
    
    function unstake(uint256[] memory tokenId) public {
        require(totalDepositedTokens[msg.sender] > 0, "Stake: You don't have staked token..");
        updateAccount(msg.sender);

        for (uint256 i = 0; i < tokenId.length; i++) {
            require(_owners.get(tokenId[i]) == msg.sender, "Stake: Please enter correct tokenId..");
            
            if (tokenId[i] > 0) {
                IContract(DarkSeedNFT).safeTransferFrom(address(this), msg.sender, tokenId[i]);
            }
            totalDepositedTokens[msg.sender] --;

            if (tokenId[i] <= 1e3) {
                if (IContract(DarkSeedController).isCloverFieldCarbon_(tokenId[i])) {
                    depositedCloverFieldCarbon[msg.sender] --;
                } else if(IContract(DarkSeedController).isCloverFieldPearl_(tokenId[i])) {
                    depositedCloverFieldPearl[msg.sender] --;
                } else if(IContract(DarkSeedController).isCloverFieldRuby_(tokenId[i])) {
                    depositedCloverFieldRuby[msg.sender] --;
                } else if(IContract(DarkSeedController).isCloverFieldDiamond_(tokenId[i])) {
                    depositedCloverFieldDiamond[msg.sender] --;
                    if (depositedCloverFieldDiamond[msg.sender] == 0) {
                        CloverDiamondFieldAddresses.remove(msg.sender);
                    }
                }
            }

            if (tokenId[i] > 1e3 && tokenId[i] <= 11e3) {
                if (IContract(DarkSeedController).isCloverYardCarbon_(tokenId[i])) {
                    depositedCloverYardCarbon[msg.sender] --;
                } else if(IContract(DarkSeedController).isCloverYardPearl_(tokenId[i])) {
                    depositedCloverYardPearl[msg.sender] --;
                } else if(IContract(DarkSeedController).isCloverYardRuby_(tokenId[i])) {
                    depositedCloverYardRuby[msg.sender] --;
                } else if(IContract(DarkSeedController).isCloverYardDiamond_(tokenId[i])) {
                    depositedCloverYardDiamond[msg.sender] --;
                    if (depositedCloverYardDiamond[msg.sender] == 0) {
                        CloverDiamondYardAddresses.remove(msg.sender);
                    }
                }
            }

            if (tokenId[i] > 11e3 && tokenId[i] <= 111e3) {
                if (IContract(DarkSeedController).isCloverPotCarbon_(tokenId[i])) {
                    depositedCloverPotCarbon[msg.sender] --;
                } else if(IContract(DarkSeedController).isCloverPotPearl_(tokenId[i])) {
                    depositedCloverPotPearl[msg.sender] --;
                } else if(IContract(DarkSeedController).isCloverPotRuby_(tokenId[i])) {
                    depositedCloverPotRuby[msg.sender] --;
                } else if(IContract(DarkSeedController).isCloverPotDiamond_(tokenId[i])) {
                    depositedCloverPotDiamond[msg.sender] --;
                    if (depositedCloverPotDiamond[msg.sender] == 0) {
                        CloverDiamondPotAddresses.remove(msg.sender);
                    }
                }
            }

            if (tokenId[i] > 0) {
                _owners.remove(tokenId[i]);
            }
        }
        
        if (holders.contains(msg.sender) && totalDepositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }

    function water() public {
        updateAccount(msg.sender);
        lastWatered[msg.sender] = block.timestamp;
    }

    function updateWaterInterval(uint256 sec) public onlyOwner {
        waterInterval = sec;
    }
    
    function enableStaking() public onlyOwner {
        isStakingEnabled = true;
    }

    function disableStaking() public onlyOwner {
        isStakingEnabled = false;
    }

    function enableClaimFunction() public onlyOwner {
        canClaimReward = true;
    }

    function disableClaimFunction() public onlyOwner {
        canClaimReward = false;
    }

    function enableMarketingFee() public onlyOwner {
        isMarketingFeeActivated = true;
    }

    function disableMarketingFee() public onlyOwner {
        isMarketingFeeActivated = false;
    }

    function setDarkSeedPicker(address _DarkSeedPicker) public onlyOwner {
        DarkSeedPicker = _DarkSeedPicker;
    }

    function set_Seed_Controller(address _wallet) public onlyOwner {
        DarkSeedController = _wallet;
    }

    function set_DarkSeedToken(address SeedsToken) public onlyOwner {
        DarkSeedToken = SeedsToken;
    }

    function set_DarkSeedNFT(address nftToken) public onlyOwner {
        DarkSeedNFT = nftToken;
    }

       // function to allow admin to transfer *any* BEP20 tokens from this contract..
    function transferAnyBEP20Tokens(address tokenAddress, address recipient, uint256 amount) public onlyOwner {
        require(amount > 0, "SEED$ Stake: amount must be greater than 0");
        require(recipient != address(0), "SEED$ Stake: recipient is the zero address");
        IContract(tokenAddress).transfer(recipient, amount);
    }

    function stakedTokensByOwner(address account) public view returns (uint[] memory) {
        uint[] memory tokenIds = new uint[](totalDepositedTokens[account]);
        uint counter = 0;
        for (uint i = 0; i < _owners.size(); i++) {
            uint tokenId = _owners.getKeyAtIndex(i);
            if (_owners.get(tokenId) == account) {
                tokenIds[counter] = tokenId;
                counter++;
            }
        }
        return tokenIds;
    }

    function totalStakedCloverFieldsByOwner(address account) public view returns (uint) {
        return depositedCloverFieldCarbon[account] 
        + depositedCloverFieldDiamond[account]
        + depositedCloverFieldPearl[account]
        + depositedCloverFieldRuby[account]; 
    }

    function totalStakedCloverYardsByOwner(address account) public view returns (uint) {
        return depositedCloverYardCarbon[account] 
        + depositedCloverYardDiamond[account]
        + depositedCloverYardPearl[account]
        + depositedCloverYardRuby[account]; 
    }

    function totalStakedCloverPotsByOwner(address account) public view returns (uint) {
        return depositedCloverPotCarbon[account] 
        + depositedCloverPotDiamond[account]
        + depositedCloverPotPearl[account]
        + depositedCloverPotRuby[account]; 
    }

    function totalStakedCloverFields() public view returns (uint) {
        uint counter = 0;
        for (uint i = 0; i < holders.length(); i++) {
            counter += totalStakedCloverFieldsByOwner(holders.at(i));
        }
        return  counter;
    }

    function totalStakedCloverYards() public view returns (uint) {
        uint counter = 0;
        for (uint i = 0; i < holders.length(); i++) {
            counter += totalStakedCloverYardsByOwner(holders.at(i));
        }
        return  counter;
    }

    function totalStakedCloverPots() public view returns (uint) {
        uint counter = 0;
        for (uint i = 0; i < holders.length(); i++) {
            counter += totalStakedCloverPotsByOwner(holders.at(i));
        }
        return  counter;
    }

    function passedTime(address account) public view returns (uint) {
        if (totalDepositedTokens[account] == 0) {
          return 0;  
        } else {
            return block.timestamp - lastWatered[account];
        }
    }

    function readRewardRates() public view returns(
        uint fieldCarbon, uint fieldPearl, uint fieldRuby, uint fieldDiamond,
        uint yardCarbon, uint yardPearl, uint yardRuby, uint yardDiamond,
        uint potCarbon, uint potPearl, uint potRuby, uint potDiamond
    ){
        fieldCarbon = CloverFieldCarbonRewardRate;
        fieldPearl = CloverFieldPearlRewardRate;
        fieldRuby = CloverFieldRubyRewardRate;
        fieldDiamond = CloverFieldDiamondRewardRate;

        yardCarbon = CloverYardCarbonRewardRate;
        yardPearl = CloverYardPearlRewardRate;
        yardRuby = CloverYardRubyRewardRate;
        yardDiamond = CloverYardDiamondRewardRate;

        potCarbon = CloverPotCarbonRewardRate;
        potPearl = CloverPotPearlRewardRate;
        potRuby = CloverPotRubyRewardRate;
        potDiamond = CloverPotDiamondRewardRate;
    }

    function setNoMarketingAddress(address acc) public onlyOwner {
        noMarketingList[acc] = true;
    }
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

interface IContract {
    function balanceOf(address) external returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function mint(address, uint256) external;
    function Approve(address, uint256) external returns (bool);
    function sendToken2Account(address, uint256) external returns(bool);
    function AddFeeS(uint256, uint256, uint256) external returns (bool);
    function addAsNFTBuyer(address) external returns (bool);
    function addMintedTokenId(uint256) external returns (bool);
    function addAsCloverFieldCarbon(uint256) external returns (bool);
    function addAsCloverFieldPearl(uint256) external returns (bool);
    function addAsCloverFieldRuby(uint256) external returns (bool);
    function addAsCloverFieldDiamond(uint256) external returns (bool);
    function addAsCloverYardCarbon(uint256) external returns (bool);
    function addAsCloverYardPearl(uint256) external returns (bool);
    function addAsCloverYardRuby(uint256) external returns (bool);
    function addAsCloverYardDiamond(uint256) external returns (bool);
    function addAsCloverPotCarbon(uint256) external returns (bool);
    function addAsCloverPotPearl(uint256) external returns (bool);
    function addAsCloverPotRuby(uint256) external returns (bool);
    function addAsCloverPotDiamond(uint256) external returns (bool);
    function randomLayer(uint256) external returns (bool);
    function randomNumber(uint256) external returns (uint256);
    function safeTransferFrom(address, address, uint256) external;
    function setApprovalForAll_(address) external;
    function isCloverFieldCarbon_(uint256) external returns (bool);
    function isCloverFieldPearl_(uint256) external returns (bool);
    function isCloverFieldRuby_(uint256) external returns (bool);
    function isCloverFieldDiamond_(uint256) external returns (bool);
    function isCloverYardCarbon_(uint256) external returns (bool);
    function isCloverYardPearl_(uint256) external returns (bool);
    function isCloverYardRuby_(uint256) external returns (bool);
    function isCloverYardDiamond_(uint256) external returns (bool);
    function isCloverPotCarbon_(uint256) external returns (bool);
    function isCloverPotPearl_(uint256) external returns (bool);
    function isCloverPotRuby_(uint256) external returns (bool);
    function isCloverPotDiamond_(uint256) external returns (bool);
    function getLuckyWalletForCloverField() external returns (address);
    function getLuckyWalletForCloverYard() external returns (address);
    function getLuckyWalletForCloverPot() external returns (address);
    function setTokenURI(uint256, string memory) external;
    function tokenURI(uint256) external view returns (string memory);
    function getCSNFTsByOwner(address) external returns (uint256[] memory);
    //functions for potion
    function burn(address, bool) external;
    //function for token
    function burnForNFT(uint256) external;
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

import "./Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/OpenZeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        uint[] keys;
        mapping(uint => address) values;
        mapping(uint => uint) indexOf;
        mapping(uint => bool) inserted;
    }

    function get(Map storage map, uint key) public view returns (address) {
        return map.values[key];
    }

    function getKeyAtIndex(Map storage map, uint index) public view returns (uint) {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        uint key,
        address val
    ) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, uint key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        uint lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}