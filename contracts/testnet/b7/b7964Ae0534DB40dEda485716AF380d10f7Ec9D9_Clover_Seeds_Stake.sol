pragma solidity 0.8.11;

// SPDX-License-Identifier: MIT

import "./interfaces/IContract.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Clover_Seeds_Stake is Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 public CloverFieldCarbonRewardRate = 4e20;
    uint256 public CloverFieldPearlRewardRate = 5e20;
    uint256 public CloverFieldRubyRewardRate = 6e20;
    uint256 public CloverFieldDiamondRewardRate = 15e20;

    uint256 public CloverYardCarbonRewardRate = 2e19;
    uint256 public CloverYardPearlRewardRate = 25e18;
    uint256 public CloverYardRubyRewardRate = 3e19;
    uint256 public CloverYardDiamondRewardRate = 6e19;

    uint256 public CloverPotCarbonRewardRate = 1e18;
    uint256 public CloverPotPearlRewardRate = 15e17;
    uint256 public CloverPotRubyRewardRate = 2e18;
    uint256 public CloverPotDiamondRewardRate = 4e18;

    uint256 public rewardInterval = 1 days;
    uint256 public teamFee = 1000;
    uint256 public totalClaimedRewards;
    uint256 public teamFeeTotal;
    uint256 public waterInterval = 2 days;

    address public Seeds_Token;
    address public Seeds_NFT_Token;
    address public Clover_Seeds_Controller;
    address public Clover_Seeds_Picker;
    address public teamWallet;
    
    bool public isStakingEnabled = false;
    bool public isTeamFeeActiveted = false;
    bool public canClaimReward = false;

    address[] public CloverField;

    address[] public CloverYard;

    address[] public CloverPot;

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

    mapping (address => uint256) public stakingTime;
    mapping (address => uint256) public totalDepositedTokens;
    mapping (address => uint256) public totalEarnedTokens;
    mapping (address => uint256) public lastClaimedTime;
    mapping (address => uint256) public lastWatered;
    mapping (address => uint256) public wastedTime;

    mapping(uint256 => address) private _owners;

    event RewardsTransferred(address holder, uint256 amount);

    constructor(address _teamWallet, address _Seeds_Token, address _Seeds_NFT_Token, address _Clover_Seeds_Controller, address _Clover_Seeds_Picker) {
        Clover_Seeds_Picker = _Clover_Seeds_Picker;
        Seeds_Token = _Seeds_Token;
        Seeds_NFT_Token = _Seeds_NFT_Token;
        Clover_Seeds_Controller = _Clover_Seeds_Controller;
        teamWallet = _teamWallet;

        CloverField.push(address(0));
        CloverYard.push(address(0));
        CloverPot.push(address(0));
    }
    
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function randomNumberForCloverField() public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, CloverField)));
    }

    function getLuckyWalletForCloverField() public view returns (address) {
        uint256 luckyWallet = randomNumberForCloverField() % CloverField.length;
        return CloverField[luckyWallet];
    }

    function randomNumberForCloverYard() public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, CloverYard)));
    }

    function getLuckyWalletForCloverYard() public view returns (address) {
        uint256 luckyWallet = randomNumberForCloverYard() % CloverYard.length;
        return CloverYard[luckyWallet];
    }

    function randomNumberForCloverPot() public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, CloverPot)));
    }

    function getLuckyWalletForCloverPot() public view returns (address) {
        uint256 luckyWallet = randomNumberForCloverPot() % CloverPot.length;
        return CloverPot[luckyWallet];
    }

    function updateAccount(address account) private {
        uint256 _lastWatered = block.timestamp.sub(lastWatered[account]);
        uint256 pendingDivs = getPendingDivs(account);
        uint256 _teamFee = pendingDivs.mul(teamFee).div(1e4);
        uint256 afterFee = pendingDivs.sub(_teamFee);

        require(_lastWatered <= waterInterval, "Please give water your plant..");

        if (pendingDivs > 0 && !isTeamFeeActiveted) {
            require(IContract(Seeds_Token).transfer(account, pendingDivs), "Could not transfer tokens.");
            totalEarnedTokens[account] = totalEarnedTokens[account].add(pendingDivs);
            totalClaimedRewards = totalClaimedRewards.add(pendingDivs);
            emit RewardsTransferred(account, pendingDivs);
        }

        if (pendingDivs > 0 && isTeamFeeActiveted) {
            require(IContract(Seeds_Token).transfer(account, afterFee), "Could not transfer tokens.");
            require(IContract(Seeds_Token).transfer(account, teamFee), "Could not transfer tokens.");
            totalEarnedTokens[account] = totalEarnedTokens[account].add(afterFee);
            totalClaimedRewards = totalClaimedRewards.add(afterFee);
            emit RewardsTransferred(account, afterFee);
        }

        lastClaimedTime[account] = block.timestamp;
        wastedTime[account] = 0;
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
        updateAccount(msg.sender);
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

    function getCloverFieldCarbonReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;
        
        uint256 time = wastedTime[_holder];
        uint256 timeDiff = block.timestamp.sub(lastClaimedTime[_holder]).sub(time);
        uint256 cloverFieldCarbon = depositedCloverFieldCarbon[_holder];
        uint256 CloverFieldCarbonReward = cloverFieldCarbon.mul(CloverFieldCarbonRewardRate).div(rewardInterval).mul(timeDiff);

        return CloverFieldCarbonReward;
    }

    function getCloverFieldPearlReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 time = wastedTime[_holder];
        uint256 timeDiff = block.timestamp.sub(lastClaimedTime[_holder]).sub(time);
        uint256 cloverFieldPearl = depositedCloverFieldPearl[_holder];
        uint256 CloverFieldPearlReward = cloverFieldPearl.mul(CloverFieldPearlRewardRate).div(rewardInterval).mul(timeDiff);

        return CloverFieldPearlReward;
    }

    function getCloverFieldRubyReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 time = wastedTime[_holder];
        uint256 timeDiff = block.timestamp.sub(lastClaimedTime[_holder]).sub(time);
        uint256 cloverFieldRuby = depositedCloverFieldRuby[_holder];
        uint256 CloverFieldRubyReward = cloverFieldRuby.mul(CloverFieldRubyRewardRate).div(rewardInterval).mul(timeDiff);

        return CloverFieldRubyReward;
    }

    function getCloverFieldDiamondReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 time = wastedTime[_holder];
        uint256 timeDiff = block.timestamp.sub(lastClaimedTime[_holder]).sub(time);
        uint256 cloverFieldDiamond = depositedCloverFieldDiamond[_holder];
        uint256 CloverFieldDiamondReward = cloverFieldDiamond.mul(CloverFieldDiamondRewardRate).div(rewardInterval).mul(timeDiff);

        return CloverFieldDiamondReward;
    }

    function getCloverYardCarbonReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 time = wastedTime[_holder];
        uint256 timeDiff = block.timestamp.sub(lastClaimedTime[_holder]).sub(time);
        uint256 cloverYardCarbon = depositedCloverYardCarbon[_holder];
        uint256 CloverYardCarbonReward = cloverYardCarbon.mul(CloverYardCarbonRewardRate).div(rewardInterval).mul(timeDiff);

        return CloverYardCarbonReward;
    }

    function getCloverYardPearlReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 time = wastedTime[_holder];
        uint256 timeDiff = block.timestamp.sub(lastClaimedTime[_holder]).sub(time);
        uint256 cloverYardPearl = depositedCloverYardPearl[_holder];
        uint256 CloverYardPearlReward = cloverYardPearl.mul(CloverYardPearlRewardRate).div(rewardInterval).mul(timeDiff);

        return CloverYardPearlReward;
    }

    function getCloverYardRubyReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 time = wastedTime[_holder];
        uint256 timeDiff = block.timestamp.sub(lastClaimedTime[_holder]).sub(time);
        uint256 cloverYardRuby = depositedCloverYardRuby[_holder];
        uint256 CloverYardRubyReward = cloverYardRuby.mul(CloverYardRubyRewardRate).div(rewardInterval).mul(timeDiff);

        return CloverYardRubyReward;
    }

    function getCloverYardDiamondReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 time = wastedTime[_holder];
        uint256 timeDiff = block.timestamp.sub(lastClaimedTime[_holder]).sub(time);
        uint256 cloverYardDiamond = depositedCloverYardDiamond[_holder];
        uint256 CloverYardDiamondReward = cloverYardDiamond.mul(CloverYardDiamondRewardRate).div(rewardInterval).mul(timeDiff);

        return CloverYardDiamondReward;
    }

    function getCloverPotCarbonReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 time = wastedTime[_holder];
        uint256 timeDiff = block.timestamp.sub(lastClaimedTime[_holder]).sub(time);
        uint256 cloverPotCarbon = depositedCloverPotCarbon[_holder];
        uint256 CloverPotCarbonReward = cloverPotCarbon.mul(CloverPotCarbonRewardRate).div(rewardInterval).mul(timeDiff);

        return CloverPotCarbonReward;
    }

    function getCloverPotPearlReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 time = wastedTime[_holder];
        uint256 timeDiff = block.timestamp.sub(lastClaimedTime[_holder]).sub(time);
        uint256 cloverPotPearl = depositedCloverPotPearl[_holder];
        uint256 CloverPotPearlReward = cloverPotPearl.mul(CloverPotPearlRewardRate).div(rewardInterval).mul(timeDiff);

        return CloverPotPearlReward;
    }

    function getCloverPotRubyReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 time = wastedTime[_holder];
        uint256 timeDiff = block.timestamp.sub(lastClaimedTime[_holder]).sub(time);
        uint256 cloverPotRuby = depositedCloverPotRuby[_holder];
        uint256 CloverPotRubyReward = cloverPotRuby.mul(CloverPotRubyRewardRate).div(rewardInterval).mul(timeDiff);

        return CloverPotRubyReward;
    }

    function getCloverPotDiamondReward(address _holder) private view returns (uint256) {
        if (!holders.contains(_holder)) return 0;
        if (totalDepositedTokens[_holder] == 0) return 0;

        uint256 time = wastedTime[_holder];
        uint256 timeDiff = block.timestamp.sub(lastClaimedTime[_holder]).sub(time);
        uint256 cloverPotDiamond = depositedCloverPotDiamond[_holder];
        uint256 CloverPotDiamondReward = cloverPotDiamond.mul(CloverPotDiamondRewardRate).div(rewardInterval).mul(timeDiff);

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

        uint256 pendingDivs = getPendingDivs(msg.sender);

        if (pendingDivs > 0) {
            updateAccount(msg.sender);
        }

        if (pendingDivs == 0) {
            lastClaimedTime[msg.sender] = block.timestamp;
            lastWatered[msg.sender] = block.timestamp;
        }

        for (uint256 i = 0; i < tokenId.length; i++) {

            IContract(Seeds_NFT_Token).setApprovalForAll_(address(this));
            IContract(Seeds_NFT_Token).safeTransferFrom(msg.sender, address(this), tokenId[i]);
            if (tokenId[i] <= 1e3) {
                if (IContract(Clover_Seeds_Controller).isCloverFieldCarbon_(tokenId[i])) {
                    depositedCloverFieldCarbon[msg.sender]++;
                } else if (IContract(Clover_Seeds_Controller).isCloverFieldPearl_(tokenId[i])) {
                    depositedCloverFieldPearl[msg.sender]++;
                } else if (IContract(Clover_Seeds_Controller).isCloverFieldRuby_(tokenId[i])) {
                    depositedCloverFieldRuby[msg.sender]++;
                } else if (IContract(Clover_Seeds_Controller).isCloverFieldDiamond_(tokenId[i])) {
                    depositedCloverFieldDiamond[msg.sender]++;
                }
            }

            if (tokenId[i] > 1e3 && tokenId[i] <= 11e3) {
                if (IContract(Clover_Seeds_Controller).isCloverYardCarbon_(tokenId[i])) {
                    depositedCloverYardCarbon[msg.sender]++;
                } else if (IContract(Clover_Seeds_Controller).isCloverYardPearl_(tokenId[i])) {
                    depositedCloverYardPearl[msg.sender]++;
                } else if (IContract(Clover_Seeds_Controller).isCloverYardRuby_(tokenId[i])) {
                    depositedCloverYardRuby[msg.sender]++;
                } else if (IContract(Clover_Seeds_Controller).isCloverYardDiamond_(tokenId[i])) {
                    depositedCloverYardDiamond[msg.sender]++;
                }
            }

            if (tokenId[i] > 11e3 && tokenId[i] <= 111e3) {
                if (IContract(Clover_Seeds_Controller).isCloverPotCarbon_(tokenId[i])) {
                    depositedCloverPotCarbon[msg.sender]++;
                } else if (IContract(Clover_Seeds_Controller).isCloverPotPearl_(tokenId[i])) {
                    depositedCloverPotPearl[msg.sender]++;
                } else if (IContract(Clover_Seeds_Controller).isCloverPotRuby_(tokenId[i])) {
                    depositedCloverPotRuby[msg.sender]++;
                } else if (IContract(Clover_Seeds_Controller).isCloverPotDiamond_(tokenId[i])) {
                    depositedCloverPotDiamond[msg.sender]++;
                }
            }

            if (tokenId[i] > 0) {
                _owners[tokenId[i]] = msg.sender;
            }

            if (tokenId[i] <= 1e3) {
                CloverField.push(msg.sender);
            }

            if (tokenId[i] > 1e3 && tokenId[i] <= 11e3) {
                CloverYard.push(msg.sender);
            }

            if (tokenId[i] > 11e3 && tokenId[i] <= 111e3) {
                CloverPot.push(msg.sender);
            }

            totalDepositedTokens[msg.sender]++;
        }

        if (!holders.contains(msg.sender) && totalDepositedTokens[msg.sender] > 0) {
            holders.add(msg.sender);
            stakingTime[msg.sender] = block.timestamp;
        }
    }
    
    function unstake(uint256[] memory tokenId) public {
        require(totalDepositedTokens[msg.sender] > 0, "Stake: You don't have staked token..");
        updateAccount(msg.sender);

        withdraw(tokenId);
    }
    
    function withdraw(uint256[] memory tokenId) public {
        require(totalDepositedTokens[msg.sender] > 0, "Stake: You don't have staked token..");

        for (uint256 i = 0; i < tokenId.length; i++) {
            require(_owners[tokenId[i]] == msg.sender, "Stake: Please enter correct tokenId..");
            
            if (tokenId[i] > 0) {
                IContract(Seeds_NFT_Token).safeTransferFrom(address(this), msg.sender, tokenId[i]);
            }
            totalDepositedTokens[msg.sender] --;

            if (tokenId[i] <= 1e3) {
                if (IContract(Clover_Seeds_Controller).isCloverFieldCarbon_(tokenId[i])) {
                    depositedCloverFieldCarbon[msg.sender] --;
                } else if(IContract(Clover_Seeds_Controller).isCloverFieldPearl_(tokenId[i])) {
                    depositedCloverFieldPearl[msg.sender] --;
                } else if(IContract(Clover_Seeds_Controller).isCloverFieldRuby_(tokenId[i])) {
                    depositedCloverFieldRuby[msg.sender] --;
                } else if(IContract(Clover_Seeds_Controller).isCloverFieldDiamond_(tokenId[i])) {
                    depositedCloverFieldDiamond[msg.sender] --;
                }
            }

            if (tokenId[i] > 1e3 && tokenId[i] <= 11e3) {
                if (IContract(Clover_Seeds_Controller).isCloverYardCarbon_(tokenId[i])) {
                    depositedCloverYardCarbon[msg.sender] --;
                } else if(IContract(Clover_Seeds_Controller).isCloverYardPearl_(tokenId[i])) {
                    depositedCloverYardPearl[msg.sender] --;
                } else if(IContract(Clover_Seeds_Controller).isCloverYardRuby_(tokenId[i])) {
                    depositedCloverYardRuby[msg.sender] --;
                } else if(IContract(Clover_Seeds_Controller).isCloverYardDiamond_(tokenId[i])) {
                    depositedCloverYardDiamond[msg.sender] --;
                }
            }

            if (tokenId[i] > 11e3 && tokenId[i] <= 111e3) {
                if (IContract(Clover_Seeds_Controller).isCloverPotPearl_(tokenId[i])) {
                    depositedCloverPotPearl[msg.sender] = depositedCloverPotPearl[msg.sender].sub(1);
                } else if(IContract(Clover_Seeds_Controller).isCloverPotPearl_(tokenId[i])) {
                    depositedCloverPotPearl[msg.sender] --;
                } else if(IContract(Clover_Seeds_Controller).isCloverPotRuby_(tokenId[i])) {
                    depositedCloverPotRuby[msg.sender] --;
                } else if(IContract(Clover_Seeds_Controller).isCloverPotDiamond_(tokenId[i])) {
                    depositedCloverPotDiamond[msg.sender] --;
                }
            }

            if (tokenId[i] > 0) {
                delete _owners[tokenId[i]];
            }
        }
        
        if (holders.contains(msg.sender) && totalDepositedTokens[msg.sender] == 0) {
            holders.remove(msg.sender);
        }
    }

    function water() public {
        uint256 _lastWatered = block.timestamp.sub(lastWatered[msg.sender]);
        
        if (_lastWatered > waterInterval) {
            uint256 time = _lastWatered.sub(waterInterval);
            wastedTime[msg.sender] = wastedTime[msg.sender].add(time);
        }

        lastWatered[msg.sender] = block.timestamp;
    }

    function updateWaterInterval(uint256 sec) public onlyOwner {
        waterInterval = sec;
    }
    
    function enableStaking() public onlyOwner {
        isStakingEnabled = true;
    }
    
    function enableClaimFunction() public onlyOwner {
        canClaimReward = true;
    }

    function disableStaking() public onlyOwner {
        isStakingEnabled = false;
    }
    
    function enableTeamFee() public onlyOwner {
        isTeamFeeActiveted = true;
    }

    function disableTeamFee() public onlyOwner {
        isTeamFeeActiveted = false;
    }

    function setClover_Seeds_Picker(address _Clover_Seeds_Picker) public onlyOwner {
        Clover_Seeds_Picker = _Clover_Seeds_Picker;
    }

    function set_Seed_Controller(address _wallet) public onlyOwner {
        Clover_Seeds_Controller = _wallet;
    }

    function set_Seeds_Token(address SeedsToken) public onlyOwner {
        Seeds_Token = SeedsToken;
    }

    function set_Seeds_NFT_Token(address nftToken) public onlyOwner {
        Seeds_NFT_Token = nftToken;
    }

    function set_TeamWallet(address _teamWallet) public onlyOwner {
        teamWallet = _teamWallet;
    }
    
    // function to allow admin to transfer *any* BEP20 tokens from this contract..
    function transferAnyBEP20Tokens(address tokenAddress, address recipient, uint256 amount) public onlyOwner {
        require(amount > 0, "SEED$ Stake: amount must be greater than 0");
        require(recipient != address(0), "SEED$ Stake: recipient is the zero address");
        IContract(tokenAddress).transfer(recipient, amount);
    }
}

pragma solidity 0.8.11;

// SPDX-License-Identifier: MIT

interface IContract {
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function mint(address, uint256) external;
    function Approve(address, uint256) external returns (bool);
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
    function getCSNFTsByOwner(address) external returns (uint256[] memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
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
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
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

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
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

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}