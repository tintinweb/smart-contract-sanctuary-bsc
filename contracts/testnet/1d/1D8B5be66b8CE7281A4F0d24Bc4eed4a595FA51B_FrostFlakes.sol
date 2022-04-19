/**
 *Submitted for verification at BscScan.com on 2022-04-19
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

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }
    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function isOwner(address adr) public view returns(bool) {
      return adr == _owner;
    }
}

contract FrostFlakes is Context, Ownable {
    using Math for uint256;

    struct CampaignReferral {
        address refAdr;
        uint256 referrals_count;
        uint256 campaignId;
        bool claimed;
    }

    struct User {
        address sender;
        address upline;
        uint256 referrals_count;
        address[] referrals;
        CampaignReferral[] campaignReferrals;
        uint256 payouts;
        uint256 total_deposit;
        uint256 deposit_payouts;
        uint256 total_direct_deposits;
        uint256 total_payouts;
        uint256 last_freeze_reward_percent;
        bool halted;
    }

    struct Airdrop {
        uint256 airdrops_sent;
        uint256 airdrops_sent_count;
        uint256 airdrops_received;
        uint256 airdrops_received_count;
    }

    // uint256 private FROSTFLAKES_FOR_1_MINER = 1080000; // 12.5 days
    uint256 private FROSTFLAKES_FOR_1_MINER = 604800; // 1 week
    uint256 private MAX_FROST_FLAKES = 604800; // 1 week
    uint256 private BNB_PER_FROSTFLAKE = 6048000000;
    uint256 private DAILY_REWARD = 5;
    uint256 private REQUIRED_FREEZES_BEFORE_DEFROST = 6;
    uint256 private MARKETING_FEE = 1;
    uint256 private CF = 2;
    uint256 private REF_BONUS = 10;
    uint256 private FIRST_DEPOSIT_REF_BONUS = 5; // 5 for this bonus + 10 on ref bonus = 15 total on first deposit
    uint256 private USE_OWNER_AS_REF_DEPOSITLINE_BONUS = 2;
    uint256 private DEPOSIT_BONUS = 0;
    uint256 private TENTH_MULTIPLIER = 10000;
    // uint256 private FIFTH_MULTIPLIER = 5000;
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
    uint256 private marketFrostFlakes;
    uint256 private activeCampaignId = 0;
    string private activeCampaignName = "Init";
    bool private campaignRunning = false;
    address payable private cfmAddress;
    mapping (address => User) public users;
    mapping (address => Airdrop) public airdrops;
    mapping (address => uint256) private activeMiners;
    mapping (address => uint256) private availableFrostFlakes;
    mapping (address => uint256) private lastFreeze;
    mapping (address => uint256) private lastDefrost;
    mapping (address => uint256) private firstDeposit;
    mapping (address => uint256) private freezesSinceLastDefrost;
    mapping (address => bool) private hasReferred;
    mapping (address => uint256) private downline;
    mapping (address => uint256) private depositLine;
    mapping (address => uint256) private totalAirdrops;

    event BoughtFrostFlakes(address indexed adr, address indexed ref, uint256 bnbamount, uint256 frostflakesamount);
    event Froze(address indexed adr, address indexed ref, uint256 frostflakesamount);
    event DeFroze(address indexed adr, uint256 bnbamount, uint256 frostflakesamount);
    event AirDropped(address indexed adr, address indexed reviever, uint256 bnbamount, uint256 frostflakesamount);
    event Initialized(bool initialized);
    event PresaleInitialized(bool initialized);
    event PresaleEnded(bool presaleEnded);
    
    constructor() {
        cfmAddress = payable(msg.sender);
    }

    function buyFrostFlakes(address ref) public payable {
        require(initialized || presaleInitialized, "Contract or presale for Deposit isn't live yet");
        require(aHProtocolInitialized == false, "AH is active");
        require(msg.value >= MIN_DEPOSIT, "Deposit doesn't meet the minimum requirements");
        require(!users[msg.sender].halted, "User has been halted");

        users[msg.sender].sender = msg.sender;

        // uint256 frostFlakesBought = calcBuyTrade(msg.value);
        uint256 frostFlakesBought = calcBuyFrostFlakes(msg.value);
        frostFlakesBought = Math.sub(frostFlakesBought,calcPercentAmount(frostFlakesBought, CF));

        if (depositBonusesEnabled) {
            frostFlakesBought = Math.add(frostFlakesBought,calcPercentAmount(frostFlakesBought, DEPOSIT_BONUS));
        }

        availableFrostFlakes[msg.sender] = Math.add(availableFrostFlakes[msg.sender],frostFlakesBought);

        if (!hasReferred[msg.sender] && ref != msg.sender && ref != address(0)) {
            if (users[ref].sender == address(0)) {
                revert("Referral not found as a user in the system");
            }
            users[msg.sender].upline = ref;
            hasReferred[msg.sender] = true;
            users[users[msg.sender].upline].referrals_count++;
            users[users[msg.sender].upline].referrals.push(msg.sender);
            downline[users[msg.sender].upline] = Math.add(downline[users[msg.sender].upline],1);
            handleActiveCampaign(msg.value);
            if(firstDeposit[msg.sender] == 0) {
                availableFrostFlakes[users[msg.sender].upline] = Math.add(availableFrostFlakes[users[msg.sender].upline],calcPercentAmount(frostFlakesBought,FIRST_DEPOSIT_REF_BONUS));
            }
            if(isOwner(ref)) {
                depositLine[msg.sender] = Math.add(depositLine[msg.sender], USE_OWNER_AS_REF_DEPOSITLINE_BONUS);
            }
        }

        if(firstDeposit[msg.sender] == 0) {
            firstDeposit[msg.sender] = block.timestamp;
            TOTAL_USERS++;
        }

        if (msg.value >= BNB_THRESHOLD_FOR_DEPOSIT_REWARD) {
            depositLine[msg.sender] = Math.add(depositLine[msg.sender], Math.div(msg.value, BNB_THRESHOLD_FOR_DEPOSIT_REWARD));
        }

        users[msg.sender].total_deposit = Math.add(users[msg.sender].total_deposit, msg.value);

        handleFreeze();

        emit BoughtFrostFlakes(msg.sender, ref, msg.value, frostFlakesBought);
    }


    function freeze() public payable {
        require(initialized, "Contract isn't live yet");
        require(aHProtocolInitialized == false, "AH is active");
        require(!users[msg.sender].halted, "User has been halted");
        handleFreeze();
    }

    function handleFreeze() private {
        uint256 currentActiveMiners = activeMiners[msg.sender];
        
        uint256 frostFlakes = getFrostFlakes(msg.sender);

        if (users[msg.sender].upline != address(0) && users[msg.sender].upline != msg.sender) {
            availableFrostFlakes[users[msg.sender].upline] = Math.add(availableFrostFlakes[users[msg.sender].upline],calcPercentAmount(frostFlakes,REF_BONUS));
        }

        uint256 newMiners = Math.div(frostFlakes,FROSTFLAKES_FOR_1_MINER);
        activeMiners[msg.sender] = Math.add(activeMiners[msg.sender], newMiners);
        availableFrostFlakes[msg.sender] = 0;
        lastFreeze[msg.sender] = block.timestamp;
        freezesSinceLastDefrost[msg.sender] = Math.add(freezesSinceLastDefrost[msg.sender], 1);
        marketFrostFlakes=Math.add(marketFrostFlakes,calcPercentAmount(frostFlakes, 20));

        if (currentActiveMiners != 0 && rewardPercentCalculationEnabled) {
            uint256 diff = Math.div(Math.mul(newMiners, TENTH_MULTIPLIER), currentActiveMiners);
            if (diff != 0) {
                uint256 totalPercentRewards = Math.div(diff, TENTH_MULTIPLIER);
                users[msg.sender].last_freeze_reward_percent = totalPercentRewards;
            }
        }

        emit Froze(msg.sender, users[msg.sender].upline, frostFlakes);
    }
    
    function defrost() public {
        require(initialized, "Contract isn't live yet for Defrost");
        require(aHProtocolInitialized == false, "AH is active");
        require(canDefrost(), "Can't defrost at this moment");
        require(!users[msg.sender].halted, "User has been halted");

        uint256 frostFlakes = getFrostFlakes(msg.sender);
        // uint256 frostFlakesInBnb = calcSellTrade(frostFlakes);
        uint256 frostFlakesInBnb = calcSellFrostFlakes(frostFlakes);

        uint256 cfFee = calcPercentAmount(frostFlakesInBnb, CF);
        frostFlakesInBnb = Math.sub(frostFlakesInBnb, cfFee);

        uint256 marketingFee = calcPercentAmount(frostFlakesInBnb, MARKETING_FEE);
        frostFlakesInBnb = Math.sub(frostFlakesInBnb, marketingFee);
        cfmAddress.transfer(marketingFee);

        availableFrostFlakes[msg.sender] = 0;
        lastDefrost[msg.sender] = block.timestamp;
        freezesSinceLastDefrost[msg.sender] = 0;

        marketFrostFlakes = Math.add(marketFrostFlakes,frostFlakes);

        payable (msg.sender).transfer(frostFlakesInBnb);

        emit DeFroze(msg.sender, frostFlakesInBnb, frostFlakes);
    }

    function airdrop(address reciever) payable external {
        require(initialized, "Contract isn't live yet for Airdrop");
        require(aHProtocolInitialized == false, "AH is active");
        require(airdropEnabled, "Airdrop not Enabled.");
        require(users[reciever].sender != address(0), "Upline not found as a user in the system");
        require(reciever != msg.sender, "You cannot airdrop yourself");
        require(!users[msg.sender].halted, "User has been halted");

        // uint256 frostFlakesToAirdrop = calcBuyTrade(msg.value);
        uint256 frostFlakesToAirdrop = calcBuyFrostFlakes(msg.value);
        users[reciever].total_deposit = Math.add(users[reciever].total_deposit, msg.value);

        frostFlakesToAirdrop = Math.sub(frostFlakesToAirdrop, calcPercentAmount(frostFlakesToAirdrop, CF));
        availableFrostFlakes[reciever] = Math.add(availableFrostFlakes[reciever], frostFlakesToAirdrop);

        airdrops[msg.sender].airdrops_sent = Math.add(airdrops[msg.sender].airdrops_sent, msg.value);
        airdrops[msg.sender].airdrops_sent_count = airdrops[msg.sender].airdrops_sent_count.add(1);
        airdrops[reciever].airdrops_received = Math.add(airdrops[msg.sender].airdrops_received, msg.value);
        airdrops[reciever].airdrops_received_count = airdrops[reciever].airdrops_received_count.add(1);

        emit AirDropped(msg.sender, reciever, msg.value, frostFlakesToAirdrop);
    }

    function claimCampaignReward(uint256 campaignId) public payable {
        require(initialized, "Contract isn't live yet for Campaign claim");
        require(aHProtocolInitialized == false, "AH is active");
        require(campaignRunning == false, "Campaign is still running");
        require(!users[msg.sender].halted, "User has been halted");

        bool canClaim = canClaimCampaign(campaignId);
        if (!canClaim) {
            revert("Sorry, you cannot claim from this campaign");
        }

        for (uint i = 0; i < users[users[msg.sender].upline].campaignReferrals.length; i++) {
            if (users[users[msg.sender].upline].campaignReferrals[i].campaignId == campaignId) {
                users[users[msg.sender].upline].campaignReferrals[i].claimed = true;
                canClaim = false;
            }
        }

        depositLine[msg.sender] = Math.add(depositLine[msg.sender], CAMPAIGN_PERMANENT_REWARD_INCREASE);
    }

    function initialize() public payable onlyOwner {
        require(marketFrostFlakes == 0, "Market frostflakes isn't 0");
        require(aHProtocolInitialized == false, "AH is active");
        initialized = true;
        presaleInitialized = false;
        presaleEnded = true;
        presaleEndedAt = block.timestamp;
        marketFrostFlakes = 108000000000;
        emit Initialized(initialized);
        emit PresaleEnded(true);
    }

    function presaleInitialize() public payable onlyOwner {
        require(!initialized);
        require(aHProtocolInitialized == false, "AH is active");
        presaleInitialized = true;
        emit PresaleInitialized(presaleInitialized);
    }

    function canDefrost() public view returns(bool) {
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
        for (uint i = 0; i < users[msg.sender].campaignReferrals.length; i++) {
            if (users[msg.sender].campaignReferrals[i].campaignId == campaignId) {
                if (users[msg.sender].campaignReferrals[i].claimed) {
                    return false;
                }
                if (users[msg.sender].campaignReferrals[i].referrals_count >= MIN_CAMPAIGN_REF_COUNT_FOR_CLAIM) {
                    return true;
                }
            }
        }
        return false;
    }

    function getMyReferrals() public view returns(address[] memory referrals) {
        return users[msg.sender].referrals;
    }

    function getReferrals(address adr) public view onlyOwner returns(address[] memory referrals) {
        return users[adr].referrals;
    }

    function getMyCampaignReferralsCountByCampaignId(uint256 id) public view returns(uint256 referrals) {
        for (uint i = 0; i < users[msg.sender].campaignReferrals.length; i++) {
            if (users[msg.sender].campaignReferrals[i].campaignId == id) {
                return users[msg.sender].campaignReferrals[i].referrals_count;
            }
        }
        return 0;
    }

    function getUserCampaignReferralsCountByCampaignId(uint256 id, address adr) public view onlyOwner returns(uint256 referrals) {
        for (uint i = 0; i < users[adr].campaignReferrals.length; i++) {
            if (users[adr].campaignReferrals[i].campaignId == id) {
                return users[adr].campaignReferrals[i].referrals_count;
            }
        }
        return 0;
    }

    function userHasActiveCampaign(address adr) private view returns(bool hasActiveCampaign) {
        for (uint i = 0; i < users[adr].campaignReferrals.length; i++) {
            if (users[adr].campaignReferrals[i].campaignId == activeCampaignId) {
                return true;
            }
        }
        return false;
    }

    function handleActiveCampaign(uint256 deposit) private {
        if (campaignRunning && deposit >= MIN_CAMPAIGN_DEPOSIT) {
            bool hasActiveCampaign = userHasActiveCampaign(users[msg.sender].upline);
            if (!hasActiveCampaign) {
                CampaignReferral memory newCampaignReferrals = CampaignReferral(msg.sender, 1, activeCampaignId, false);
                users[users[msg.sender].upline].campaignReferrals.push(newCampaignReferrals);
            } else {
                for (uint i = 0; i < users[users[msg.sender].upline].campaignReferrals.length; i++) {
                    if (users[users[msg.sender].upline].campaignReferrals[i].campaignId == activeCampaignId && users[users[msg.sender].upline].campaignReferrals[i].claimed == false) {
                        users[users[msg.sender].upline].campaignReferrals[i].referrals_count = Math.add(users[users[msg.sender].upline].campaignReferrals[i].referrals_count, 1);
                    }
                }
            }
        }
    }

    function getMyUserLastRewardPercent() public view returns(uint256) {
        return users[msg.sender].last_freeze_reward_percent;
    }

    function getMyInfo() public view returns(address upline, 
                                                uint256 referrals, 
                                                uint256 payouts, 
                                                uint256 total_deposit,
                                                uint256 deposit_payouts, 
                                                uint256 total_direct_deposits, 
                                                uint256 total_payouts) {
        return getUserInfo(msg.sender);
    }

    function getUserInfoOwner(address adr) public view onlyOwner returns(address upline, 
                                                                            uint256 referrals, 
                                                                            uint256 payouts, 
                                                                            uint256 total_deposit,
                                                                            uint256 deposit_payouts, 
                                                                            uint256 total_direct_deposits, 
                                                                            uint256 total_payouts) {
        return getUserInfo(adr);
    }

    function getMyAirdropInfo() public view returns(uint256 airdrops_sent,
                                                        uint256 airdrops_sent_count,
                                                        uint256 airdrops_received,
                                                        uint256 airdrops_received_count) {
        return getUserAirdropInfo(msg.sender);
    }

    function getUserAirdropInfoOwner(address adr) public view onlyOwner returns(uint256 airdrops_sent,
                                                                                    uint256 airdrops_sent_count,
                                                                                    uint256 airdrops_received,
                                                                                    uint256 airdrops_received_count) {
        return getUserAirdropInfo(adr);
    }

    function getUserInfo(address adr) private view returns(address upline, 
                                                            uint256 referrals, 
                                                            uint256 payouts, 
                                                            uint256 total_deposit,
                                                            uint256 deposit_payouts, 
                                                            uint256 total_direct_deposits, 
                                                            uint256 total_payouts) {
        return (users[adr].upline, 
                users[adr].referrals_count, 
                users[adr].payouts, 
                users[adr].total_deposit, 
                users[adr].deposit_payouts, 
                users[adr].total_direct_deposits, 
                users[adr].total_payouts);
    }

    function getUserAirdropInfo(address adr) private view returns(uint256 airdrops_sent,
                                                                    uint256 airdrops_sent_count,
                                                                    uint256 airdrops_received,
                                                                    uint256 airdrops_received_count) {
        return (airdrops[adr].airdrops_sent, 
                airdrops[adr].airdrops_sent_count, 
                airdrops[adr].airdrops_received, 
                airdrops[adr].airdrops_received_count);
    }

    function userExists(address adr) public view returns(bool) {
        return users[adr].sender != address(0);
    }

    function getTotalUsers() public view returns(uint256) {
        return TOTAL_USERS;
    }
    
    function getBnbRewards(address adr) public view returns(uint256) {
        uint256 frostFlakes = getFrostFlakes(adr);
        // uint256 bnbinWei = calcSellTrade(frostFlakes);
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

    function getDailyReward() public view returns(uint256) {
        return DAILY_REWARD;
    }

    function setDailyReward(uint256 newDailyReward) public payable onlyOwner returns(uint256) {
        DAILY_REWARD = newDailyReward;
        return DAILY_REWARD;
    }

    function toggleUserHalt(bool halt) public payable onlyOwner returns(bool) {
        users[msg.sender].halted = halt;
        return users[msg.sender].halted;
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

    function handleDownline(address adr, uint256 build) public payable onlyOwner returns(uint256) {
        downline[adr] = build;
        return downline[adr];
    }

    function handleDepositline(address adr, uint256 build) public payable onlyOwner returns(uint256) {
        depositLine[adr] = build;
        return depositLine[adr];
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
        if (depositLine[adr] >= MAX_DEPOSITLINE) {
            return MAX_DEPOSITLINE;
        }

        return depositLine[adr];
    }

    function getMyDownlineCount() public view returns(uint256) {
        return downline[msg.sender];
    }

    function getMyDepositlineCount() public view returns(uint256) {
        return depositLine[msg.sender];
    }

    function toggleAHProtocol(bool start) public payable onlyOwner {
        require(initialized, "Contract isn't live yet");
        aHProtocolInitialized = start;
    }

    function calcReferralBonus (address adr) private view returns(uint256) {
        uint256 referrals = downline[adr];

        if (referrals >= 160) {
            return 10;
        }
        if (referrals >= 80) {
            return 9;
        }
        if (referrals >= 40) {
            return 8;
        }
        if (referrals >= 20) {
            return 7;
        }
        if (referrals >= 10) {
            return 6;
        }
        if (referrals >= 5) {
            return 5;
        }

        return 0;
    }

    function resolveCFFlakes(uint256 frostFlakes) private returns(uint256) {
        if (cFEnabled) {
            uint256 cf = calcPercentAmount(frostFlakes, CF);
            uint256 frostFlakesTotal = Math.sub(frostFlakes, cf);
            if (mCFEnabled) {
                // uint256 cfV = calcSellTrade(cf);
                uint256 cfV = calcSellFrostFlakes(cf);
                cfmAddress.transfer(cfV);
            }
            return frostFlakesTotal;
        }
        return frostFlakes;
    }

    // function calcTradeAmount(uint256 amount,uint256 marketAmount, uint256 balance) private view returns(uint256) {
    //     return Math.div(Math.mul(TENTH_MULTIPLIER,balance),Math.add(FIFTH_MULTIPLIER,Math.div(Math.add(Math.mul(TENTH_MULTIPLIER,marketAmount),Math.mul(FIFTH_MULTIPLIER,amount)),amount)));
    // }
    
    // function calcSellTrade(uint256 frostFlakes) public view returns(uint256) {
    //     // Calculate from frostflakes to bnb
    //     return calcTradeAmount(frostFlakes,marketFrostFlakes,getContractBalance());
    // }
    
    // function calcBuyTrade(uint256 bnbInWei) public view returns(uint256) {
    //     uint256 bnbContracBalanceWithoutBuyAmount = Math.sub(getContractBalance(),bnbInWei);
    //     // Calculate from bnb to frostflakes
    //     return calcTradeAmount(bnbInWei,bnbContracBalanceWithoutBuyAmount,marketFrostFlakes);
    // }

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
    
    function getMiners(address adr) public view returns(uint256) {
        return activeMiners[adr];
    }
    
    function getFrostFlakes(address adr) public view returns(uint256) {
        return Math.add(availableFrostFlakes[adr],getFrostFlakesSincelastFreeze(adr));
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
        if (downline[adr] > 0 && permanentRewardFromDownlineEnabled) {
            uint256 extraRefBonusPercent = calcReferralBonus(adr);
            extraBonus = Math.add(extraBonus, extraRefBonusPercent);
        }
        if (depositLine[adr] > 0 && permanentRewardFromDepositEnabled) {
            uint256 extraDepositLineBonusPercent = calcDepositLineBonus(adr);
            extraBonus = Math.add(extraBonus, extraDepositLineBonusPercent);
        }
        return extraBonus;
    }
    
    function getFrostFlakesSincelastFreeze(address adr) public view returns(uint256) {
        uint256 secondsPerDay = 86400;

        if (!presaleEnded) {
            return 0;
        }

        uint256 lastFreezeOrPresaleEnded = lastFreeze[adr];
        if (presaleEndedAt > lastFreeze[adr]) {
            lastFreezeOrPresaleEnded = presaleEndedAt;
        }

        uint256 secondsPassed=Math.min(MAX_FROST_FLAKES,Math.sub(block.timestamp,lastFreezeOrPresaleEnded));
        uint256 rewardMultiplier = Math.mul(Math.div(secondsPassed, secondsPerDay), DAILY_REWARD);
        uint256 frostFlakes = Math.mul(Math.mul(secondsPassed,activeMiners[adr]), rewardMultiplier);

        uint256 extraBonus = getExtraBonuses(adr);
        if (extraBonus > 0) {
            uint256 extraBonusFrostFlakes = calcPercentAmount(frostFlakes, extraBonus);
            frostFlakes = Math.add(frostFlakes, extraBonusFrostFlakes);
        }
        
        return frostFlakes;
    }
}