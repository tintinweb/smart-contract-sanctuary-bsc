/**
 *Submitted for verification at BscScan.com on 2022-05-01
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-28
*/

// SPDX-License-Identifier: MIT

/*
FrostFlakes
*/

library Math {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

pragma solidity 0.8.13;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract FrostFlakes is Context {
    address private _owner;
    using Math for uint256;

    struct CampaignReferral {
        address refAdr;
        uint256 referrals_count;
        uint256 campaignId;
        bool claimed;
    }

    uint256 private MAX_FROST_FLAKES = 108000; // 30 hours
    uint256 private BNB_PER_FROSTFLAKE = 6048000000;
    uint256 private SECONDS_PER_DAY = 86400;
    uint256 private LEVEL_1_REWARD = 3;
    uint256 private LEVEL_2_REWARD = 5;
    uint256 private LEVEL_3_REWARD = 7;
    uint256 private LEVEL_4_REWARD = 10;
    uint256 private LEVEL_5_REWARD = 13;
    uint256 private REQUIRED_FREEZES_BEFORE_DEFROST = 6;
    uint256 private LIQUIDITY_FEE = 1;
    uint256 private CF = 2;
    uint256 private REF_BONUS = 10;
    uint256 private FIRST_DEPOSIT_REF_BONUS = 5; // 5 for this bonus + 10 on ref bonus = 15 total on first deposit
    uint256 private USE_OWNER_AS_REF_DEPOSITLINE_BONUS = 2;
    uint256 private DEPOSIT_BONUS = 0;
    uint256 private TENTH_MULTIPLIER = 100000;
    uint256 private MAX_DEPOSITLINE = 10;
    uint256 private MIN_DEPOSIT = 100000000000000000; // 0.1 BNB
    uint256 private BNB_THRESHOLD_FOR_DEPOSIT_REWARD = 5000000000000000000; // 5 BNB
    uint256 private MIN_CAMPAIGN_DEPOSIT = 250000000000000000; // 0.25 BNB
    uint256 private MIN_CAMPAIGN_REF_COUNT_FOR_CLAIM = 5;
    uint256 private CAMPAIGN_PERMANENT_REWARD_INCREASE = 2;
    uint256 private TOTAL_USERS;
    bool private initialized = false;
    bool private presaleInitialized = false;
    bool private presaleEnded = false;
    uint256 private presaleEndedAt;
    bool private depositBonusesEnabled = false;
    bool private cFEnabled = false;
    bool private mCFEnabled = false;
    bool private airdropEnabled = false;
    bool private permanentRewardFromDownlineEnabled = true;
    bool private permanentRewardFromDepositEnabled = true;
    bool private rewardPercentCalculationEnabled = true;
    bool private aHProtocolInitialized = false;
    uint256 private activeCampaignId = 0;
    string private activeCampaignName = "Init";
    bool private campaignRunning = false;
    address payable private cfmAddress;
    mapping (address => address) private sender;
    mapping (address => uint256) private lockedFrostFlakes;
    mapping (address => uint256) private lastFreeze;
    mapping (address => uint256) private lastDefrost;
    mapping (address => uint256) private firstDeposit;
    mapping (address => uint256) private freezesSinceLastDefrost;
    mapping (address => bool) private hasReferred;
    mapping (address => CampaignReferral[]) private campaignReferrals;
    mapping (address => address) private upline;
    mapping (address => address[]) private referrals;
    mapping (address => uint256) private downLineCount;
    mapping (address => uint256) private depositLineCount;
    mapping (address => uint256) private totalAirdrops;
    mapping (address => uint256) private totalDeposit;
    mapping (address => uint256) private totalPayout;
    mapping (address => uint256) private airdrops_sent;
    mapping (address => uint256) private airdrops_sent_count;
    mapping (address => uint256) private airdrops_received;
    mapping (address => uint256) private airdrops_received_count;

    event EmitBoughtFrostFlakes(address indexed adr, address indexed ref, uint256 bnbamount, uint256 frostflakesamount);
    event EmitFroze(address indexed adr, address indexed ref, uint256 frostflakesamount);
    event EmitDeFroze(address indexed adr, uint256 bnbamount, uint256 frostflakesamount);
    event EmitAirDropped(address indexed adr, address indexed reviever, uint256 bnbamount, uint256 frostflakesamount);
    event EmitInitialized(bool initialized);
    event EmitPresaleInitialized(bool initialized);
    event EmitPresaleEnded(bool presaleEnded);
    
    constructor() {
        _owner = _msgSender();
        cfmAddress = payable(msg.sender);
    }

    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function isOwner(address adr) public view returns(bool) {
      return adr == _owner;
    }

    function buyFrostFlakes(address ref) public payable {
        require(initialized || presaleInitialized, "Contract or presale for Deposit isn't live yet");
        require(aHProtocolInitialized == false, "AH is active");
        require(msg.value >= MIN_DEPOSIT, "Deposit doesn't meet the minimum requirements");

        sender[msg.sender] = msg.sender;

        uint256 frostFlakesBought = calcBuyFrostFlakes(msg.value);
        frostFlakesBought = Math.sub(frostFlakesBought,calcPercentAmount(frostFlakesBought, CF));

        if (depositBonusesEnabled) {
            frostFlakesBought = Math.add(frostFlakesBought,calcPercentAmount(frostFlakesBought, DEPOSIT_BONUS));
        }

        lockedFrostFlakes[msg.sender] = Math.add(lockedFrostFlakes[msg.sender],frostFlakesBought);

        if (!hasReferred[msg.sender] && ref != msg.sender && ref != address(0)) {
            if (sender[ref] == address(0)) {
                revert("Referral not found as a user in the system");
            }
            upline[msg.sender] = ref;
            hasReferred[msg.sender] = true;
            referrals[upline[msg.sender]].push(msg.sender);
            downLineCount[upline[msg.sender]] = Math.add(downLineCount[upline[msg.sender]],1);
            handleActiveCampaign(msg.value);
            if(firstDeposit[msg.sender] == 0 && !isOwner(ref)) {
                lockedFrostFlakes[upline[msg.sender]] = Math.add(lockedFrostFlakes[upline[msg.sender]],calcPercentAmount(frostFlakesBought,FIRST_DEPOSIT_REF_BONUS));
            }
            if(isOwner(ref)) {
                depositLineCount[msg.sender] = Math.add(depositLineCount[msg.sender], USE_OWNER_AS_REF_DEPOSITLINE_BONUS);
            }
        }

        if(firstDeposit[msg.sender] == 0) {
            firstDeposit[msg.sender] = block.timestamp;
            TOTAL_USERS++;
        }

        if (msg.value >= BNB_THRESHOLD_FOR_DEPOSIT_REWARD) {
            depositLineCount[msg.sender] = Math.add(depositLineCount[msg.sender], Math.div(msg.value, BNB_THRESHOLD_FOR_DEPOSIT_REWARD));
        }

        totalDeposit[msg.sender] = Math.add(totalDeposit[msg.sender], msg.value);

        handleFreeze(true);

        emit EmitBoughtFrostFlakes(msg.sender, ref, msg.value, frostFlakesBought);
    }


    function freeze() public payable {
        require(initialized, "Contract isn't live yet");
        require(aHProtocolInitialized == false, "AH is active");
        require(!isOwner(msg.sender), "Owner cannot freeze");
        handleFreeze(false);
    }

    function handleFreeze(bool postDeposit) private {
        uint256 frostFlakes = getFrostFlakesSincelastFreeze(msg.sender);

        if (upline[msg.sender] != address(0) && upline[msg.sender] != msg.sender) {
            if ((postDeposit && !isOwner(upline[msg.sender])) || !postDeposit) {
                lockedFrostFlakes[upline[msg.sender]] = Math.add(lockedFrostFlakes[upline[msg.sender]],calcPercentAmount(frostFlakes,REF_BONUS));
            }
        }
        lockedFrostFlakes[msg.sender] = Math.add(lockedFrostFlakes[msg.sender],frostFlakes);

        lastFreeze[msg.sender] = block.timestamp;
        freezesSinceLastDefrost[msg.sender] = Math.add(freezesSinceLastDefrost[msg.sender], 1);

        emit EmitFroze(msg.sender, upline[msg.sender], frostFlakes);
    }
    
    function defrost() public {
        require(initialized, "Contract isn't live yet for Defrost");
        require(aHProtocolInitialized == false, "AH is active");
        require(canDefrost(), "Can't defrost at this moment");
        
        uint256 frostFlakes = getFrostFlakesSincelastFreeze(msg.sender);
        uint256 frostFlakesInBnb = calcSellFrostFlakes(frostFlakes);

        uint256 cfFee = calcPercentAmount(frostFlakesInBnb, CF);
        frostFlakesInBnb = Math.sub(frostFlakesInBnb, cfFee);

        uint256 marketingFee = calcPercentAmount(frostFlakesInBnb, LIQUIDITY_FEE);
        frostFlakesInBnb = Math.sub(frostFlakesInBnb, marketingFee);
        cfmAddress.transfer(marketingFee);

        lockedFrostFlakes[msg.sender] = 0;
        lastDefrost[msg.sender] = block.timestamp;
        freezesSinceLastDefrost[msg.sender] = 0;

        payable (msg.sender).transfer(frostFlakesInBnb);
        totalPayout[msg.sender] = Math.add(totalPayout[msg.sender], frostFlakesInBnb);

        emit EmitDeFroze(msg.sender, frostFlakesInBnb, frostFlakes);
    }

    function airdrop(address reciever) payable external {
        require(initialized, "Contract isn't live yet for Airdrop");
        require(aHProtocolInitialized == false, "AH is active");
        require(airdropEnabled, "Airdrop not Enabled.");
        require(sender[reciever] != address(0), "Upline not found as a user in the system");
        require(reciever != msg.sender, "You cannot airdrop yourself");

        uint256 frostFlakesToAirdrop = calcBuyFrostFlakes(msg.value);
        totalDeposit[reciever] = Math.add(totalDeposit[reciever], msg.value);

        frostFlakesToAirdrop = Math.sub(frostFlakesToAirdrop, calcPercentAmount(frostFlakesToAirdrop, CF));
        lockedFrostFlakes[reciever] = Math.add(lockedFrostFlakes[reciever], frostFlakesToAirdrop);

        airdrops_sent[msg.sender] = Math.add(airdrops_sent[msg.sender], msg.value);
        airdrops_sent_count[msg.sender] = airdrops_sent_count[msg.sender].add(1);
        airdrops_received[reciever] = Math.add(airdrops_received[msg.sender], msg.value);
        airdrops_received_count[reciever] = airdrops_received_count[reciever].add(1);

        emit EmitAirDropped(msg.sender, reciever, msg.value, frostFlakesToAirdrop);
    }

    function claimCampaignReward(uint256 campaignId) public payable {
        require(initialized, "Contract isn't live yet for Campaign claim");
        require(aHProtocolInitialized == false, "AH is active");
        require(campaignRunning == false, "Campaign is still running");

        bool canClaim = canClaimCampaign(campaignId);
        if (!canClaim) {
            revert("Sorry, you cannot claim from this campaign");
        }

        for (uint i = 0; i < campaignReferrals[upline[msg.sender]].length; i++) {
            if (campaignReferrals[upline[msg.sender]][i].campaignId == campaignId) {
                campaignReferrals[upline[msg.sender]][i].claimed = true;
                canClaim = false;
            }
        }

        depositLineCount[msg.sender] = Math.add(depositLineCount[msg.sender], CAMPAIGN_PERMANENT_REWARD_INCREASE);
    }

    function initialize() public payable onlyOwner {
        require(aHProtocolInitialized == false, "AH is active");
        initialized = true;
        presaleInitialized = false;
        presaleEnded = true;
        presaleEndedAt = block.timestamp;
        emit EmitInitialized(initialized);
        emit EmitPresaleEnded(true);
    }

    function presaleInitialize() public payable onlyOwner {
        require(!initialized);
        require(aHProtocolInitialized == false, "AH is active");
        presaleInitialized = true;
        emit EmitPresaleInitialized(presaleInitialized);
    }

    function canDefrost() public view returns(bool) {
        if (isOwner(msg.sender)) {
            return true;
        }
        return defrostFreezeRequirementReached() && defrostTimeRequirementReached();
    }

    function defrostTimeRequirementReached() public view returns(bool) {
        uint256 lastDefrostOrFirstDeposit = lastDefrost[msg.sender];
        if(lastDefrostOrFirstDeposit == 0) {
            lastDefrostOrFirstDeposit = firstDeposit[msg.sender];
        }
        return block.timestamp >= (lastDefrostOrFirstDeposit +6 days);
    }

    function defrostFreezeRequirementReached() public view returns(bool) {
        return freezesSinceLastDefrost[msg.sender] >= REQUIRED_FREEZES_BEFORE_DEFROST;
    }

    function canClaimCampaign(uint256 campaignId) public view returns(bool) {
        require(campaignRunning == false, "Campaign is still running");
        for (uint i = 0; i < campaignReferrals[msg.sender].length; i++) {
            if (campaignReferrals[msg.sender][i].campaignId == campaignId) {
                if (campaignReferrals[msg.sender][i].claimed) {
                    return false;
                }
                if (campaignReferrals[msg.sender][i].referrals_count >= MIN_CAMPAIGN_REF_COUNT_FOR_CLAIM) {
                    return true;
                }
            }
        }
        return false;
    }

    function getMyReferrals() public view returns(address[] memory myReferrals) {
        return referrals[msg.sender];
    }

    function getReferrals(address adr) public view onlyOwner returns(address[] memory myReferrals) {
        return referrals[adr];
    }

    function getMyCampaignReferralsCountByCampaignId(uint256 id) public view returns(uint256 myReferrals) {
        for (uint i = 0; i < campaignReferrals[msg.sender].length; i++) {
            if (campaignReferrals[msg.sender][i].campaignId == id) {
                return campaignReferrals[msg.sender][i].referrals_count;
            }
        }
        return 0;
    }

    function getUserCampaignReferralsCountByCampaignId(uint256 id, address adr) public view onlyOwner returns(uint256 myReferrals) {
        for (uint i = 0; i < campaignReferrals[adr].length; i++) {
            if (campaignReferrals[adr][i].campaignId == id) {
                return campaignReferrals[adr][i].referrals_count;
            }
        }
        return 0;
    }

    function userHasActiveCampaign(address adr) private view returns(bool hasActiveCampaign) {
        for (uint i = 0; i < campaignReferrals[adr].length; i++) {
            if (campaignReferrals[adr][i].campaignId == activeCampaignId) {
                return true;
            }
        }
        return false;
    }

    function handleActiveCampaign(uint256 deposit) private {
        if (campaignRunning && deposit >= MIN_CAMPAIGN_DEPOSIT) {
            bool hasActiveCampaign = userHasActiveCampaign(upline[msg.sender]);
            if (!hasActiveCampaign) {
                CampaignReferral memory newCampaignReferrals = CampaignReferral(msg.sender, 1, activeCampaignId, false);
                campaignReferrals[upline[msg.sender]].push(newCampaignReferrals);
            } else {
                for (uint i = 0; i < campaignReferrals[upline[msg.sender]].length; i++) {
                    if (campaignReferrals[upline[msg.sender]][i].campaignId == activeCampaignId && campaignReferrals[upline[msg.sender]][i].claimed == false) {
                        campaignReferrals[upline[msg.sender]][i].referrals_count = Math.add(campaignReferrals[upline[msg.sender]][i].referrals_count, 1);
                    }
                }
            }
        }
    }

    function getMyInfo() public view returns(address myUpline, 
                                                uint256 myReferrals, 
                                                uint256 myTotalDeposit,
                                                uint256 myTotalPayouts) {
        return getUserInfo(msg.sender);
    }

    function getUserInfoOwner(address adr) public view onlyOwner returns(address myUpline, 
                                                                            uint256 myReferrals, 
                                                                            uint256 myTotalDeposit,
                                                                            uint256 myTotalPayouts) {
        return getUserInfo(adr);
    }

    function getMyAirdropInfo() public view returns(uint256 MyAirdropsSent,
                                                        uint256 MyAirdropsSentCount,
                                                        uint256 MyAirdropsReceived,
                                                        uint256 MyAirdropsReceivedCount) {
        return getUserAirdropInfo(msg.sender);
    }

    function getUserInfo(address adr) private view returns(address myUpline, 
                                                            uint256 myReferrals, 
                                                            uint256 myTotalDeposit,
                                                            uint256 myTotalPayouts) {
        return (upline[adr], 
                downLineCount[adr], 
                totalDeposit[adr], 
                totalPayout[adr]);
    }

    function getUserAirdropInfoOwner(address adr) public view onlyOwner returns(uint256 MyAirdropsSent,
                                                                                    uint256 MyAirdropsSentCount,
                                                                                    uint256 MyAirdropsReceived,
                                                                                    uint256 MyAirdropsReceivedCount) {
        return getUserAirdropInfo(adr);
    }

    function getUserAirdropInfo(address adr) private view returns(uint256 MyAirdropsSent,
                                                                    uint256 MyAirdropsSentCount,
                                                                    uint256 MyAirdropsReceived,
                                                                    uint256 MyAirdropsReceivedCount) {
        return (airdrops_sent[adr], 
                airdrops_sent_count[adr], 
                airdrops_received[adr], 
                airdrops_received_count[adr]);
    }

    function userExists(address adr) public view returns(bool) {
        return sender[adr] != address(0);
    }

    function getTotalUsers() public view returns(uint256) {
        return TOTAL_USERS;
    }
    
    function getBnbRewards(address adr) public view returns(uint256) {
        uint256 frostFlakes = getFrostFlakesSincelastFreeze(adr);
        uint256 bnbinWei = calcSellFrostFlakes(frostFlakes);
        return bnbinWei;
    }

    function getUserTVL(address adr) public view returns(uint256) {
        uint256 frostFlakes = getFrostFlakesSincelastFreeze(adr);
        frostFlakes = Math.add(frostFlakes, lockedFrostFlakes[adr]);
        uint256 bnbinWei = calcSellFrostFlakes(frostFlakes);
        return bnbinWei;
    }

    function getMinDeposit() public view returns(uint256) {
        return MIN_DEPOSIT;
    }

    function setMinDeposit(uint256 newMinDeposit) public payable onlyOwner returns(uint256) {
        MIN_DEPOSIT = newMinDeposit;
        return MIN_DEPOSIT;
    }

    function getLevel1Reward() public view returns(uint256) {
        return LEVEL_1_REWARD;
    }

    function setLevel1Reward(uint256 newReward) public payable onlyOwner returns(uint256) {
        LEVEL_1_REWARD = newReward;
        return LEVEL_1_REWARD;
    }

    function getLevel2Reward() public view returns(uint256) {
        return LEVEL_2_REWARD;
    }

    function setLevel2Reward(uint256 newReward) public payable onlyOwner returns(uint256) {
        LEVEL_2_REWARD = newReward;
        return LEVEL_2_REWARD;
    }

    function getLevel3Reward() public view returns(uint256) {
        return LEVEL_3_REWARD;
    }

    function setLevel3Reward(uint256 newReward) public payable onlyOwner returns(uint256) {
        LEVEL_3_REWARD = newReward;
        return LEVEL_3_REWARD;
    }

    function getLevel4Reward() public view returns(uint256) {
        return LEVEL_4_REWARD;
    }

    function setLevel4Reward(uint256 newReward) public payable onlyOwner returns(uint256) {
        LEVEL_4_REWARD = newReward;
        return LEVEL_4_REWARD;
    }

    function getLevel5Reward() public view returns(uint256) {
        return LEVEL_5_REWARD;
    }

    function setLevel5Reward(uint256 newReward) public payable onlyOwner returns(uint256) {
        LEVEL_5_REWARD = newReward;
        return LEVEL_5_REWARD;
    }

    function getRewardLevels() public view returns(uint256 rewardLevel1, uint256 rewardLevel2, uint256 rewardLevel3, uint256 rewardLevel4, uint256 rewardLevel15) {
        return (LEVEL_1_REWARD, LEVEL_2_REWARD, LEVEL_3_REWARD, LEVEL_4_REWARD, LEVEL_5_REWARD);
    }

    function getFirstDepositRefBonus() public view returns(uint256) {
        return FIRST_DEPOSIT_REF_BONUS;
    }

    function setFirstDepositRefBonus(uint256 newRefBonus) public payable onlyOwner returns(uint256) {
        FIRST_DEPOSIT_REF_BONUS = newRefBonus;
        return FIRST_DEPOSIT_REF_BONUS;
    }

    function getOwnerAsRefDepositBonus() public view returns(uint256) {
        return USE_OWNER_AS_REF_DEPOSITLINE_BONUS;
    }

    function setOwnerAsRefDepositBonus(uint256 newRefBonus) public payable onlyOwner returns(uint256) {
        USE_OWNER_AS_REF_DEPOSITLINE_BONUS = newRefBonus;
        return USE_OWNER_AS_REF_DEPOSITLINE_BONUS;
    }

    function getMinCampaignDeposit() public view returns(uint256) {
        return MIN_CAMPAIGN_DEPOSIT;
    }

    function setMinCampaignDeposit(uint256 newMinDeposit) public payable onlyOwner returns(uint256) {
        MIN_CAMPAIGN_DEPOSIT = newMinDeposit;
        return MIN_CAMPAIGN_DEPOSIT;
    }

    function getRequiredFreezesBeforeDefrost() public view returns(uint256) {
        return REQUIRED_FREEZES_BEFORE_DEFROST;
    }

    function setRequiredFreezesBeforeDefrost(uint256 newMinRequirement) public payable onlyOwner returns(uint256) {
        REQUIRED_FREEZES_BEFORE_DEFROST = newMinRequirement;
        return REQUIRED_FREEZES_BEFORE_DEFROST;
    }

    function getMinCampaignRefCount() public view returns(uint256) {
        return MIN_CAMPAIGN_REF_COUNT_FOR_CLAIM;
    }

    function setMinCampaignRefCount(uint256 newMinDeposit) public payable onlyOwner returns(uint256) {
        MIN_CAMPAIGN_REF_COUNT_FOR_CLAIM = newMinDeposit;
        return MIN_CAMPAIGN_REF_COUNT_FOR_CLAIM;
    }

    function getCampaignReward() public view returns(uint256) {
        return CAMPAIGN_PERMANENT_REWARD_INCREASE;
    }

    function setCampaignReward(uint256 newReward) public payable onlyOwner returns(uint256) {
        CAMPAIGN_PERMANENT_REWARD_INCREASE = newReward;
        return CAMPAIGN_PERMANENT_REWARD_INCREASE;
    }

    function createNewCampaign(string memory name, bool startNow) public payable onlyOwner {
        activeCampaignId = Math.add(activeCampaignId, 1);
        activeCampaignName = name;
        campaignRunning = startNow;
    }

    function getActiveCampaignName() public view returns(string memory) {
        return activeCampaignName;
    }

    function setActiveCampaignName(string memory name) public payable onlyOwner {
        activeCampaignName = name;
    }

    function getActiveCampaignId() public view returns(uint256) {
        return activeCampaignId;
    }

    function isCampaignRunning() public view returns(bool) {
        return campaignRunning;
    }

    function isPresaleInitialized() public view returns(bool) {
        return presaleInitialized;
    }

    function isPresaleEnded() public view returns(bool) {
        return presaleEnded;
    }

    function getPresaleEndedAt() public view returns(uint256) {
        return presaleEndedAt;
    }

    function isContractInitialized() public view returns(bool) {
        return initialized;
    }

    function startCampaign() public payable onlyOwner returns(bool) {
        campaignRunning = true;
        return campaignRunning;
    }

    function stopCampaign() public payable onlyOwner returns(bool) {
        campaignRunning = false;
        return campaignRunning;
    }

    function getMyUpline() public view returns(address) {
        return upline[msg.sender];
    }

    function setMyUpline(address myUpline) public payable returns(address) {
        require(upline[msg.sender] == address(0), "Upline already set");
        require(sender[msg.sender] != address(0), "Upline user does not exists");
        require(upline[myUpline] != msg.sender, "Cross referencing is not allowed");

        upline[msg.sender] = myUpline;
        hasReferred[msg.sender] = true;
        referrals[upline[msg.sender]].push(msg.sender);
        downLineCount[upline[msg.sender]] = Math.add(downLineCount[upline[msg.sender]],1);

        if(isOwner(myUpline)) {
            depositLineCount[msg.sender] = Math.add(depositLineCount[msg.sender], USE_OWNER_AS_REF_DEPOSITLINE_BONUS);
        }

        return upline[msg.sender];
    }

    function getMyTotalDeposit() public view returns(uint256) {
        return totalDeposit[msg.sender];
    }

    function getMyTotalPayout() public view returns(uint256) {
        return totalPayout[msg.sender];
    }

    function togglepPermanentRewardFromDownline(bool enabled) public payable onlyOwner returns(bool) {
        permanentRewardFromDownlineEnabled = enabled;
        return permanentRewardFromDownlineEnabled;
    }

    function togglepPermanentRewardFromDeposit(bool enabled) public payable onlyOwner returns(bool) {
        permanentRewardFromDepositEnabled = enabled;
        return permanentRewardFromDepositEnabled;
    }

    function togglepRewardPercentCalculation(bool enabled) public payable onlyOwner returns(bool) {
        rewardPercentCalculationEnabled = enabled;
        return rewardPercentCalculationEnabled;
    }

    function toggleDepositBonus(bool enabled) public payable onlyOwner returns(bool) {
        depositBonusesEnabled = enabled;
        return depositBonusesEnabled;
    }

    function toggleAirdrops(bool enabled) public payable onlyOwner returns(bool) {
        airdropEnabled = enabled;
        return depositBonusesEnabled;
    }

    function getToggledValues() public view returns(bool permanentRewardFromDownlineToggled, 
                                                        bool permanentRewardFromDepositToggled, 
                                                        bool depositBonusesToggled,
                                                        bool airdropToggled,
                                                        bool ahProtocalToggled) {
        return (permanentRewardFromDownlineEnabled,
                permanentRewardFromDepositEnabled,
                depositBonusesEnabled,
                airdropEnabled,
                aHProtocolInitialized);
    }

    function getDepositBonus() public view returns(uint256) {
        return DEPOSIT_BONUS;
    }

    function setDepositBonus(uint256 newDepositBonus) public payable onlyOwner returns(uint256) {
        DEPOSIT_BONUS = newDepositBonus;
        return DEPOSIT_BONUS;
    }

    function getBnBThresholdForDepositReward() public view returns(uint256) {
        return BNB_THRESHOLD_FOR_DEPOSIT_REWARD;
    }

    function setBnBThresholdForDepositReward(uint256 newRewardThreshold) public payable onlyOwner returns(uint256) {
        BNB_THRESHOLD_FOR_DEPOSIT_REWARD = newRewardThreshold;
        return BNB_THRESHOLD_FOR_DEPOSIT_REWARD;
    }

    function handleDownLineBonus(address adr, uint256 build) public payable onlyOwner returns(uint256) {
        downLineCount[adr] = build;
        return downLineCount[adr];
    }

    function handleDepositLineBonus(address adr, uint256 build) public payable onlyOwner returns(uint256) {
        depositLineCount[adr] = build;
        return depositLineCount[adr];
    }

    function getRefBonus() public view returns(uint256) {
        return REF_BONUS;
    }

    function setRefBonus(uint256 newRefBonus) public payable onlyOwner returns(uint256) {
        REF_BONUS = newRefBonus;
        return REF_BONUS;
    }

    function toggleMCF(bool enabled) public payable onlyOwner returns(bool) {
        mCFEnabled = enabled;
        return mCFEnabled;
    }

    function getMCFEnabled() public view returns(bool) {
        return mCFEnabled;
    }

    function toggleCF(bool enabled) public payable onlyOwner returns(bool) {
        cFEnabled = enabled;
        return cFEnabled;
    }

    function getCFEnabled() public view returns(bool) {
        return cFEnabled;
    }

    function getCF() public view returns(uint256) {
        return CF;
    }

    function setCF(uint256 newCF) public payable onlyOwner returns(uint256) {
        CF = newCF;
        return CF;
    }

    function getMaxDepositLine() public view returns(uint256) {
        return MAX_DEPOSITLINE;
    }

    function setMaxDepositLine(uint256 newMaxDepositLine) public payable onlyOwner returns(uint256) {
        MAX_DEPOSITLINE = newMaxDepositLine;
        return MAX_DEPOSITLINE;
    }

    function calcDepositLineBonus (address adr) private view returns(uint256) {
        if (depositLineCount[adr] >= MAX_DEPOSITLINE) {
            return MAX_DEPOSITLINE;
        }

        return depositLineCount[adr];
    }

    function getMyDownlineCount() public view returns(uint256) {
        return downLineCount[msg.sender];
    }

    function getMyDepositLineCount() public view returns(uint256) {
        return depositLineCount[msg.sender];
    }

    function toggleAHProtocol(bool start) public payable onlyOwner {
        require(initialized, "Contract isn't live yet");
        aHProtocolInitialized = start;
    }

    function calcReferralBonus (address adr) private view returns(uint256) {
        uint256 myReferrals = downLineCount[adr];

        if (myReferrals >= 160) {
            return 10;
        }
        if (myReferrals >= 80) {
            return 9;
        }
        if (myReferrals >= 40) {
            return 8;
        }
        if (myReferrals >= 20) {
            return 7;
        }
        if (myReferrals >= 10) {
            return 6;
        }
        if (myReferrals >= 5) {
            return 5;
        }

        return 0;
    }

    function resolveCFFlakes(uint256 frostFlakes) private returns(uint256) {
        if (cFEnabled) {
            uint256 cf = calcPercentAmount(frostFlakes, CF);
            uint256 frostFlakesTotal = Math.sub(frostFlakes, cf);
            if (mCFEnabled) {
                uint256 cfV = calcSellFrostFlakes(cf);
                cfmAddress.transfer(cfV);
            }
            return frostFlakesTotal;
        }
        return frostFlakes;
    }

    function calcSellFrostFlakes(uint256 frostFlakes) public view returns(uint256) {
        uint256 bnbInWei = Math.mul(frostFlakes, BNB_PER_FROSTFLAKE);
        return bnbInWei;
    }

    function calcBuyFrostFlakes(uint256 bnbInWei) public view returns(uint256) {
        uint256 frostFlakes = Math.div(bnbInWei, BNB_PER_FROSTFLAKE);
        return frostFlakes;
    }
    
    function calcPercentAmount(uint256 amount, uint256 fee) private pure returns(uint256) {
        return Math.div(Math.mul(amount,fee),100);
    }

    function getContractBalance() public view returns(uint256) {
        return address(this).balance; // the complete balance of the contract in wei
    }

    function getConcurrentFreezes(address adr) public view returns(uint256) {
        return freezesSinceLastDefrost[adr];
    }

    function getLastFreeze(address adr) public view returns(uint256) {
        return lastFreeze[adr];
    }

    function getLastDefrost(address adr) public view returns(uint256) {
        return lastDefrost[adr];
    }

    function getFirstDeposit(address adr) public view returns(uint256) {
        return firstDeposit[adr];
    }

    function getLockedFrostFlakes(address adr) public view returns(uint256) {
        return lockedFrostFlakes[adr];
    }

    function getMyExtraRewards() public view returns(uint256 downlineExtraReward, uint256 depositlineExtraReward) {
        uint256 extraDownlinePercent = calcReferralBonus(msg.sender);
        uint256 extraDepositLinePercent = calcDepositLineBonus(msg.sender);
        return (extraDownlinePercent, extraDepositLinePercent);
    }

    function getExtraRewards(address adr) public view onlyOwner returns(uint256 downlineExtraReward, uint256 depositlineExtraReward) {
        uint256 extraDownlinePercent = calcReferralBonus(adr);
        uint256 extraDepositLinePercent = calcDepositLineBonus(adr);
        return (extraDownlinePercent, extraDepositLinePercent);
    }

    function getExtraBonuses(address adr) private view returns(uint256) {
        uint256 extraBonus = 0;
        if (downLineCount[adr] > 0 && permanentRewardFromDownlineEnabled) {
            uint256 extraRefBonusPercent = calcReferralBonus(adr);
            extraBonus = Math.add(extraBonus, extraRefBonusPercent);
        }
        if (depositLineCount[adr] > 0 && permanentRewardFromDepositEnabled) {
            uint256 extraDepositLineBonusPercent = calcDepositLineBonus(adr);
            extraBonus = Math.add(extraBonus, extraDepositLineBonusPercent);
        }
        return extraBonus;
    }
    
    function getFrostFlakesSincelastFreeze(address adr) public view returns(uint256) {
        if (!presaleEnded) {
            return 0;
        }

        uint256 lastFreezeOrPresaleEnded = lastFreeze[adr];
        if (presaleEndedAt > lastFreeze[adr]) {
            lastFreezeOrPresaleEnded = presaleEndedAt;
        }

        uint256 secondsPassed=Math.min(MAX_FROST_FLAKES,Math.sub(block.timestamp,lastFreezeOrPresaleEnded));
        uint256 frostFlakes = accumulateFrostFlakesRewards(secondsPassed, adr);

        uint256 extraBonus = getExtraBonuses(adr);
        if (extraBonus > 0) {
            uint256 extraBonusFrostFlakes = calcPercentAmount(frostFlakes, extraBonus);
            frostFlakes = Math.add(frostFlakes, extraBonusFrostFlakes);
        }
        
        return frostFlakes;
    }

    function calcDailyRewardLevel(address adr) private view returns(uint256) {
        uint256 secondsPassedSinceLastDeFrost = Math.sub(block.timestamp,lastDefrost[adr]);
        uint256 daysPassed = Math.div(secondsPassedSinceLastDeFrost, SECONDS_PER_DAY);

        if (daysPassed >= 168) {
            return LEVEL_5_REWARD;
        } 
        if (daysPassed >= 84) {
            return LEVEL_4_REWARD;
        }
        if (daysPassed >= 28) {
            return LEVEL_3_REWARD;
        }
        if (daysPassed >= 7) {
            return LEVEL_2_REWARD;
        }

        return LEVEL_1_REWARD;
    }

    function accumulateFrostFlakesRewards(uint256 secondsPassedSinceLastFreeze, address adr) private view returns(uint256) {
        uint256 secondsPassedSinceLastDeFrost = Math.sub(block.timestamp,lastDefrost[adr]);
        uint256 daysPassedSinceDeFrost = Math.div(secondsPassedSinceLastDeFrost, SECONDS_PER_DAY);

        if (daysPassedSinceDeFrost >= 168) {
            return calcFrostFlakesReward(secondsPassedSinceLastFreeze, LEVEL_5_REWARD, adr);
        } 
        if (daysPassedSinceDeFrost >= 84) {
            return calcFrostFlakesReward(secondsPassedSinceLastFreeze, LEVEL_4_REWARD, adr);
        }
        if (daysPassedSinceDeFrost >= 28) {
            return calcFrostFlakesReward(secondsPassedSinceLastFreeze, LEVEL_3_REWARD, adr);
        }
        if (daysPassedSinceDeFrost >= 7) {
            return calcFrostFlakesReward(secondsPassedSinceLastFreeze, LEVEL_2_REWARD, adr);
        }

        return calcFrostFlakesReward(secondsPassedSinceLastFreeze, LEVEL_1_REWARD, adr);
    }

    function calcFrostFlakesReward(uint256 secondsPassed, uint256 dailyReward, address adr) private view returns(uint256) {
        uint256 rewardsPerDay = calcPercentAmount(lockedFrostFlakes[adr], dailyReward);
        uint256 rewardsPerSecond = Math.div(rewardsPerDay, SECONDS_PER_DAY);
        uint256 frostFlakes = Math.mul(rewardsPerSecond, secondsPassed);
        return frostFlakes;
    }
}