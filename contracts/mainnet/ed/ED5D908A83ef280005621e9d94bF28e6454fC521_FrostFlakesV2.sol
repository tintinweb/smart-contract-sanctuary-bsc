// SPDX-License-Identifier: MIT

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

    function pow(uint256 a, uint256 b) internal pure returns (uint256) {
        return a**b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract FrostFlakesV2 is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    ///@dev no constructor in upgradable contracts. Instead we have initializers
    function initialize() public initializer {
        ///@dev as there is no constructor, we need to initialise the OwnableUpgradeable explicitly
        __Ownable_init();
        _owner = _msgSender();
        teamAddress = payable(TEAM_ADDRESS);
        ownerAddress = payable(_msgSender());
        TEAM_ADDRESS = 0x787ef4419cc2fA2633942E42AF602B5a6ED734fd;
        MAX_FROST_FLAKES_TIMER = 108000; // 30 hours
        MAX_FROST_FLAKES_AUTOCOMPOUND_TIMER = 518400; // 144 hours / 6 days
        FREEZE_LIMIT_TIMER = 21600; // 6 hours
        BNB_PER_FROSTFLAKE = 6048000000;
        SECONDS_PER_DAY = 86400;
        DAILY_REWARD = 2;
        REQUIRED_FREEZES_BEFORE_DEFROST = 6;
        TEAM_AND_CONTRACT_FEE = 3;
        REF_BONUS = 5;
        FIRST_DEPOSIT_REF_BONUS = 5; // 5 for this bonus + 5 on ref bonus = 10 total on first deposit
        MAX_DEPOSITLINE = 10;
        MIN_DEPOSIT = 50000000000000000; // 0.05 BNB
        BNB_THRESHOLD_FOR_DEPOSIT_REWARD = 5000000000000000000; // 5 BNB
        MAX_PAYOUT = 260000000000000000000; // 260 BNB
        MAX_DEFROST_FREEZE_IN_BNB = 5000000000000000000; // 5 BNB
        MAX_WALLET_TVL_IN_BNB = 250000000000000000000; // 250 BNB
        DEPOSIT_BONUS_REWARD_PERCENT = 10;
        depositAndAirdropBonusEnabled = true;
        requireReferralEnabled = false;
        airdropEnabled = true;
        defrostEnabled = false;
        permanentRewardFromDownlineEnabled = true;
        permanentRewardFromDepositEnabled = true;
        rewardPercentCalculationEnabled = true;
        aHProtocolInitialized = false;
    }

    ///@dev required by the OZ UUPS module
    function _authorizeUpgrade(address) internal override onlyOwner {}

    address internal _owner;
    using Math for uint256;

    struct DetailedReferral {
        address adr;
        uint256 totalDeposit;
        string userName;
        bool hasMigrated;
    }

    address internal TEAM_ADDRESS;
    uint256 internal MAX_FROST_FLAKES_TIMER;
    uint256 internal MAX_FROST_FLAKES_AUTOCOMPOUND_TIMER;
    uint256 internal FREEZE_LIMIT_TIMER;
    uint256 internal BNB_PER_FROSTFLAKE;
    uint256 internal SECONDS_PER_DAY;
    uint256 internal DAILY_REWARD;
    uint256 internal REQUIRED_FREEZES_BEFORE_DEFROST;
    uint256 internal TEAM_AND_CONTRACT_FEE;
    uint256 internal REF_BONUS;
    uint256 internal FIRST_DEPOSIT_REF_BONUS;
    uint256 internal MAX_DEPOSITLINE;
    uint256 internal MIN_DEPOSIT;
    uint256 internal BNB_THRESHOLD_FOR_DEPOSIT_REWARD;
    uint256 internal MAX_PAYOUT;
    uint256 internal MAX_DEFROST_FREEZE_IN_BNB;
    uint256 internal MAX_WALLET_TVL_IN_BNB;
    uint256 internal DEPOSIT_BONUS_REWARD_PERCENT;
    uint256 internal TOTAL_USERS;
    bool internal depositAndAirdropBonusEnabled;
    bool internal requireReferralEnabled;
    bool internal airdropEnabled;
    bool internal defrostEnabled;
    bool internal permanentRewardFromDownlineEnabled;
    bool internal permanentRewardFromDepositEnabled;
    bool internal rewardPercentCalculationEnabled;
    bool internal aHProtocolInitialized;
    address payable internal teamAddress;
    address payable internal ownerAddress;
    mapping(address => address) internal sender;
    mapping(address => uint256) internal lockedFrostFlakes;
    mapping(address => uint256) internal lastFreeze;
    mapping(address => uint256) internal lastDefrost;
    mapping(address => uint256) internal firstDeposit;
    mapping(address => uint256) internal freezesSinceLastDefrost;
    mapping(address => bool) internal hasReferred;
    mapping(address => bool) internal migrationRequested;
    mapping(address => uint256) internal lastMigrationRequest;
    mapping(address => bool) internal userInfoMigrated;
    mapping(address => bool) internal userDataMigrated;
    mapping(address => bool) internal isNewUser;
    mapping(address => address) internal upline;
    mapping(address => address[]) internal referrals;
    mapping(address => uint256) internal downLineCount;
    mapping(address => uint256) internal depositLineCount;
    mapping(address => uint256) internal totalDeposit;
    mapping(address => uint256) internal totalPayout;
    mapping(address => uint256) internal airdrops_sent;
    mapping(address => uint256) internal airdrops_sent_count;
    mapping(address => uint256) internal airdrops_received;
    mapping(address => uint256) internal airdrops_received_count;
    mapping(address => string) internal userName;
    mapping(address => bool) internal autoCompoundEnabled;
    mapping(address => uint256) internal autoCompoundStart;

    event EmitBoughtFrostFlakes(
        address indexed adr,
        address indexed ref,
        uint256 bnbamount,
        uint256 frostflakesamount
    );
    event EmitFroze(
        address indexed adr,
        address indexed ref,
        uint256 frostflakesamount
    );
    event EmitDeFroze(
        address indexed adr,
        uint256 bnbamount,
        uint256 frostflakesamount
    );
    event EmitAirDropped(
        address indexed adr,
        address indexed reviever,
        uint256 bnbamount,
        uint256 frostflakesamount
    );
    event EmitInitialized(bool initialized);
    event EmitPresaleInitialized(bool initialized);
    event EmitPresaleEnded(bool presaleEnded);
    event EmitMigrationRequested(address investor);
    event EmitMigrationCompleted(address investor);

    function isOwner(address adr) public view returns (bool) {
        return adr == _owner;
    }

    function ownerDeposit() public payable onlyOwner {}

    function buyFrostFlakes(address ref) public payable {
        require(aHProtocolInitialized == false, "AH is active");
        require(
            msg.value >= MIN_DEPOSIT,
            "Deposit doesn't meet the minimum requirements"
        );
        require(
            requireReferralEnabled == false ||
                (requireReferralEnabled &&
                    (sender[msg.sender] != address(0) ||
                        sender[ref] != address(0))),
            "Sender or ref must be a current user"
        );
        require(
            totalPayout[msg.sender] < MAX_PAYOUT,
            "Total payout must be lower than max payout"
        );
        require(
            lockedFrostFlakes[msg.sender] <
                calcBuyFrostFlakes(MAX_WALLET_TVL_IN_BNB),
            "Total wallet TVL reached"
        );
        require(
            autoCompoundEnabled[msg.sender] == false,
            "Can't deposit while autocompounding is active"
        );
        require(
            upline[ref] != msg.sender,
            "You are upline of the ref. Ref can therefore not be your upline."
        );

        sender[msg.sender] = msg.sender;

        uint256 marketingFee = calcPercentAmount(
            msg.value,
            TEAM_AND_CONTRACT_FEE
        );
        uint256 bnbValue = Math.sub(msg.value, marketingFee);
        uint256 frostFlakesBought = calcBuyFrostFlakes(bnbValue);

        if (depositAndAirdropBonusEnabled) {
            frostFlakesBought = Math.add(
                frostFlakesBought,
                calcPercentAmount(
                    frostFlakesBought,
                    DEPOSIT_BONUS_REWARD_PERCENT
                )
            );
        }

        uint256 totalFrostFlakesBought = calcMaxLockedFrostFlakes(
            msg.sender,
            frostFlakesBought
        );
        lockedFrostFlakes[msg.sender] = totalFrostFlakesBought;

        uint256 amountToLP = Math.div(bnbValue, 2);

        if (
            !hasReferred[msg.sender] &&
            ref != msg.sender &&
            ref != address(0) &&
            upline[ref] != msg.sender
        ) {
            if (sender[ref] == address(0)) {
                revert("Referral not found as a user in the system");
            }
            upline[msg.sender] = ref;
            hasReferred[msg.sender] = true;
            referrals[upline[msg.sender]].push(msg.sender);
            downLineCount[upline[msg.sender]] = Math.add(
                downLineCount[upline[msg.sender]],
                1
            );
            if (firstDeposit[msg.sender] == 0 && !isOwner(ref)) {
                uint256 frostFlakesRefBonus = calcPercentAmount(
                    frostFlakesBought,
                    FIRST_DEPOSIT_REF_BONUS
                );
                uint256 totalRefFrostFlakes = calcMaxLockedFrostFlakes(
                    upline[msg.sender],
                    frostFlakesRefBonus
                );
                lockedFrostFlakes[upline[msg.sender]] = totalRefFrostFlakes;
            }
        }

        if (firstDeposit[msg.sender] == 0) {
            firstDeposit[msg.sender] = block.timestamp;
            isNewUser[msg.sender] = true;
            TOTAL_USERS++;
        }

        if (msg.value >= BNB_THRESHOLD_FOR_DEPOSIT_REWARD) {
            depositLineCount[msg.sender] = Math.add(
                depositLineCount[msg.sender],
                Math.div(msg.value, BNB_THRESHOLD_FOR_DEPOSIT_REWARD)
            );
        }

        totalDeposit[msg.sender] = Math.add(
            totalDeposit[msg.sender],
            msg.value
        );

        teamAddress.transfer(marketingFee);
        ownerAddress.transfer(amountToLP);

        handleFreeze(true);

        emit EmitBoughtFrostFlakes(
            msg.sender,
            ref,
            msg.value,
            frostFlakesBought
        );
    }

    function freeze() public payable {
        require(aHProtocolInitialized == false, "AH is active");
        require(
            totalPayout[msg.sender] < MAX_PAYOUT,
            "Total payout must be lower than max payout"
        );
        require(
            lockedFrostFlakes[msg.sender] <
                calcBuyFrostFlakes(MAX_WALLET_TVL_IN_BNB),
            "Total wallet TVL reached"
        );
        require(canFreeze(), "Now must exceed time limit for next freeze");
        require(
            autoCompoundEnabled[msg.sender] == false,
            "Can't freeze while autocompounding is active"
        );

        handleFreeze(false);
    }

    function calcAutoCompoundReturn(address adr)
        private
        view
        returns (uint256)
    {
        uint256 secondsPassed = Math.sub(
            block.timestamp,
            autoCompoundStart[adr]
        );
        uint256 daysStarted = Math.add(
            1,
            Math.div(secondsPassed, SECONDS_PER_DAY)
        );

        uint256 rewardFactor = Math.pow(102, daysStarted);
        uint256 maxTvlAfterRewards = Math.div(
            Math.mul(rewardFactor, lockedFrostFlakes[adr]),
            Math.pow(10, Math.mul(2, daysStarted))
        );
        uint256 maxRewards = Math.mul(
            Math.sub(maxTvlAfterRewards, lockedFrostFlakes[adr]),
            100000
        );
        uint256 rewardsPerSecond = Math.div(
            maxRewards,
            Math.min(
                Math.mul(SECONDS_PER_DAY, daysStarted),
                MAX_FROST_FLAKES_AUTOCOMPOUND_TIMER
            )
        );
        uint256 currentRewards = Math.mul(
            rewardsPerSecond,
            Math.min(secondsPassed, MAX_FROST_FLAKES_AUTOCOMPOUND_TIMER)
        );
        currentRewards = Math.div(currentRewards, 100000);
        return currentRewards;
    }

    function handleFreeze(bool postDeposit) private {
        uint256 frostFlakes = getFrostFlakesSincelastFreeze(msg.sender);

        if (
            upline[msg.sender] != address(0) && upline[msg.sender] != msg.sender
        ) {
            if ((postDeposit && !isOwner(upline[msg.sender])) || !postDeposit) {
                uint256 frostFlakesRefBonus = calcPercentAmount(
                    frostFlakes,
                    REF_BONUS
                );
                uint256 totalRefFrostFlakes = calcMaxLockedFrostFlakes(
                    upline[msg.sender],
                    frostFlakesRefBonus
                );
                lockedFrostFlakes[upline[msg.sender]] = totalRefFrostFlakes;
            }
        }

        uint256 totalFrostFlakes = calcMaxLockedFrostFlakes(
            msg.sender,
            frostFlakes
        );
        lockedFrostFlakes[msg.sender] = totalFrostFlakes;

        lastFreeze[msg.sender] = block.timestamp;
        freezesSinceLastDefrost[msg.sender] = Math.add(
            freezesSinceLastDefrost[msg.sender],
            1
        );

        emit EmitFroze(msg.sender, upline[msg.sender], frostFlakes);
    }

    function defrost() public payable {
        require(aHProtocolInitialized == false, "AH is active");
        require(defrostEnabled, "Defrost isn't enabled at this moment");
        require(canDefrost(), "Can't defrost at this moment");
        require(
            totalPayout[msg.sender] < MAX_PAYOUT,
            "Total payout must be lower than max payout"
        );
        require(
            autoCompoundEnabled[msg.sender] == false,
            "Can't defrost while autocompounding is active"
        );

        uint256 frostFlakes = getFrostFlakesSincelastFreeze(msg.sender);
        uint256 frostFlakesInBnb = sellFrostFlakes(frostFlakes);

        uint256 marketingAndContractFee = calcPercentAmount(
            frostFlakesInBnb,
            TEAM_AND_CONTRACT_FEE
        );
        frostFlakesInBnb = Math.sub(frostFlakesInBnb, marketingAndContractFee);
        uint256 marketingFee = Math.div(marketingAndContractFee, 2);

        frostFlakesInBnb = Math.sub(frostFlakesInBnb, marketingFee);

        bool totalPayoutHigherThanMax = Math.add(
            totalPayout[msg.sender],
            frostFlakesInBnb
        ) > MAX_PAYOUT;
        if (totalPayoutHigherThanMax) {
            uint256 payout = Math.sub(MAX_PAYOUT, totalPayout[msg.sender]);
            frostFlakesInBnb = payout;
        }

        lastDefrost[msg.sender] = block.timestamp;
        lastFreeze[msg.sender] = block.timestamp;
        freezesSinceLastDefrost[msg.sender] = 0;

        totalPayout[msg.sender] = Math.add(
            totalPayout[msg.sender],
            frostFlakesInBnb
        );

        teamAddress.transfer(marketingFee);
        payable(msg.sender).transfer(frostFlakesInBnb);

        emit EmitDeFroze(msg.sender, frostFlakesInBnb, frostFlakes);
    }

    function airdrop(address receiver) public payable {
        require(aHProtocolInitialized == false, "AH is active");
        require(airdropEnabled, "Airdrop not Enabled.");

        handleAirdrop(receiver, msg.value);
    }

    function massAirdrop() public payable {
        require(aHProtocolInitialized == false, "AH is active");
        require(airdropEnabled, "Airdrop not Enabled.");
        require(msg.value > 0, "You must state an amount to be airdropped.");

        uint256 sharedAmount = Math.div(
            msg.value,
            referrals[msg.sender].length
        );
        require(sharedAmount > 0, "Shared amount cannot be 0.");

        for (uint256 i = 0; i < referrals[msg.sender].length; i++) {
            address refAdr = referrals[msg.sender][i];
            if (hasMigratedOrIsNewUser(refAdr)) {
                handleAirdrop(refAdr, sharedAmount);
            }
        }
    }

    function handleAirdrop(address receiver, uint256 amount) private {
        require(
            sender[receiver] != address(0),
            "Upline not found as a user in the system"
        );
        require(receiver != msg.sender, "You cannot airdrop yourself");

        uint256 frostFlakesToAirdrop = calcBuyFrostFlakes(amount);

        uint256 marketingAndContractFee = calcPercentAmount(
            frostFlakesToAirdrop,
            TEAM_AND_CONTRACT_FEE
        );
        uint256 frostFlakesMarketingFee = Math.div(marketingAndContractFee, 2);
        uint256 marketingFeeInBnb = calcSellFrostFlakes(
            frostFlakesMarketingFee
        );

        frostFlakesToAirdrop = Math.sub(
            frostFlakesToAirdrop,
            marketingAndContractFee
        );

        if (depositAndAirdropBonusEnabled) {
            frostFlakesToAirdrop = Math.add(
                frostFlakesToAirdrop,
                calcPercentAmount(
                    frostFlakesToAirdrop,
                    DEPOSIT_BONUS_REWARD_PERCENT
                )
            );
        }

        uint256 totalFrostFlakesForReceiver = calcMaxLockedFrostFlakes(
            receiver,
            frostFlakesToAirdrop
        );
        lockedFrostFlakes[receiver] = totalFrostFlakesForReceiver;

        airdrops_sent[msg.sender] = Math.add(
            airdrops_sent[msg.sender],
            Math.sub(amount, calcPercentAmount(amount, TEAM_AND_CONTRACT_FEE))
        );
        airdrops_sent_count[msg.sender] = Math.add(
            airdrops_sent_count[msg.sender],
            1
        );
        airdrops_received[receiver] = Math.add(
            airdrops_received[receiver],
            Math.sub(amount, calcPercentAmount(amount, TEAM_AND_CONTRACT_FEE))
        );
        airdrops_received_count[receiver] = Math.add(
            airdrops_received_count[receiver],
            1
        );

        teamAddress.transfer(marketingFeeInBnb);

        emit EmitAirDropped(msg.sender, receiver, amount, frostFlakesToAirdrop);
    }

    function updateUpline(address senderToChange, address newUpline)
        public
        payable
        onlyOwner
    {
        require(
            sender[senderToChange] != address(0),
            "SenderToChange not found as a user in the system"
        );
        require(
            sender[newUpline] != address(0),
            "New upline not found as a user in the system"
        );
        upline[senderToChange] = newUpline;
    }

    function calcAutoCompoundServiceFee(address adr)
        public
        view
        returns (uint256)
    {
        uint256 tvlInBnB = calcSellFrostFlakes(lockedFrostFlakes[adr]);
        uint256 minTvlEligibleForFee = 500000000000000000;

        if (tvlInBnB <= minTvlEligibleForFee) {
            return 0;
        }

        uint256 feeLevel = calcPercentAmount(tvlInBnB, 1);
        uint256 fee = Math.div(feeLevel, 5);
        return fee;
    }

    function enableAutoCompounding() public payable {
        autoCompoundEnabled[msg.sender] = true;
        autoCompoundStart[msg.sender] = block.timestamp;
        handleFreeze(false);

        uint256 serviceFee = calcAutoCompoundServiceFee(msg.sender);
        if (serviceFee > 0) {
            teamAddress.transfer(serviceFee);
        }
    }

    function disableAutoCompounding() public payable {
        uint256 secondsPassed = Math.sub(
            block.timestamp,
            autoCompoundStart[msg.sender]
        );
        uint256 daysPassed = Math.div(secondsPassed, SECONDS_PER_DAY);
        uint256 freezes = daysPassed;
        if (freezes > 5) {
            freezes = 5;
        }
        if (freezes > 0) {
            freezesSinceLastDefrost[msg.sender] = Math.add(
                freezesSinceLastDefrost[msg.sender],
                freezes
            );
        }
        handleFreeze(false);
        autoCompoundEnabled[msg.sender] = false;
    }

    function requestMigration() public payable {
        require(
            msg.value >= 3500000000000000,
            "Gas fee for migration is too low"
        );
        if (migrationRequested[msg.sender] == false) {
            ownerAddress.transfer(msg.value);
        }
        TOTAL_USERS++;
        migrationRequested[msg.sender] = true;
        lastMigrationRequest[msg.sender] = block.timestamp;
        emit EmitMigrationRequested(msg.sender);
    }

    function reRequestMigration() public payable {
        require(
            migrationRequested[msg.sender] == true,
            "Initial migration request is required"
        );
        require(
            canReRequestMigration(),
            "1 hour must pass between each re-request of migration"
        );
        lastMigrationRequest[msg.sender] = block.timestamp;
        emit EmitMigrationRequested(msg.sender);
    }

    function canReRequestMigration() public view returns (bool) {
        return
            migrationRequested[msg.sender] == true &&
            block.timestamp > Math.add(lastMigrationRequest[msg.sender], 1);
    }

    function migrationCompleted(address userAdr) public payable onlyOwner {
        emit EmitMigrationCompleted(userAdr);
    }

    function migrateUserInfo(
        address user,
        uint256 myLockedFrostFlakes,
        uint256 myConcurrentFreezes,
        uint256 myLastDefrost,
        address[] memory myReferralsList,
        uint256 myLastFreeze,
        uint256 myFirstDeposit
    ) public payable onlyOwner returns (bool) {
        require(
            userInfoMigrated[user] == false,
            "Can't migrate more than once"
        );

        sender[user] = user;

        lastFreeze[user] = myLastFreeze;
        firstDeposit[user] = myFirstDeposit;

        lockedFrostFlakes[user] = myLockedFrostFlakes;
        freezesSinceLastDefrost[user] = myConcurrentFreezes;
        lastDefrost[user] = myLastDefrost;

        for (uint256 i = 0; i < myReferralsList.length; i++) {
            referrals[user].push(myReferralsList[i]);
        }

        userInfoMigrated[user] = true;

        return userInfoMigrated[user];
    }

    function migrateDepositPayoutAndAirdrop(
        address user,
        address myUpline,
        uint256 myReferrals,
        uint256 myTotalDeposit,
        uint256 myTotalPayouts,
        uint256 depositlineExtraReward,
        uint256 myAirdropsSent,
        uint256 myAirdropsSentCount,
        uint256 myAirdropsReceived,
        uint256 myAirdropsReceivedCount
    ) public payable onlyOwner returns (bool) {
        require(
            userDataMigrated[user] == false,
            "Can't migrate more than once"
        );

        depositLineCount[user] = depositlineExtraReward;
        downLineCount[user] = myReferrals;

        totalDeposit[user] = myTotalDeposit;
        totalPayout[user] = myTotalPayouts;

        upline[user] = myUpline;
        if (myUpline != address(0)) {
            hasReferred[user] = true;
        } else {
            hasReferred[user] = false;
        }

        airdrops_sent[user] = myAirdropsSent;
        airdrops_sent_count[user] = myAirdropsSentCount;
        airdrops_received[user] = myAirdropsReceived;
        airdrops_received_count[user] = myAirdropsReceivedCount;

        userDataMigrated[user] = true;
        return userDataMigrated[user];
    }

    function calcMaxLockedFrostFlakes(address adr, uint256 frostFlakesToAdd)
        public
        view
        returns (uint256)
    {
        uint256 totalFrostFlakes = Math.add(
            lockedFrostFlakes[adr],
            frostFlakesToAdd
        );
        uint256 maxLockedFrostFlakes = calcBuyFrostFlakes(
            MAX_WALLET_TVL_IN_BNB
        );
        if (totalFrostFlakes >= maxLockedFrostFlakes) {
            return maxLockedFrostFlakes;
        }
        return totalFrostFlakes;
    }

    function hasMigratedOrIsNewUser(address adr)
        public
        view
        returns (bool)
    {
        if (userExists(adr) && isNewUser[adr] == true) {
            return true;
        }

        if (userExists(adr) && migrationRequested[adr] && userInfoMigrated[adr] && userDataMigrated[adr]) {
            return true;
        }

        return false;
    }

    function setReferralRequirement(bool requireReferral)
        public
        payable
        onlyOwner
        returns (bool)
    {
        requireReferralEnabled = requireReferral;
        return requireReferralEnabled;
    }

    function getReferralRequirement() public view returns (bool) {
        return requireReferralEnabled;
    }

    function enableDefrost() public payable onlyOwner returns (bool) {
        defrostEnabled = true;
        return defrostEnabled;
    }

    function getDefrostEnabled() public view returns (bool) {
        return defrostEnabled;
    }

    function canFreeze() public view returns (bool) {
        uint256 lastAction = lastFreeze[msg.sender];
        if (lastAction == 0) {
            lastAction = firstDeposit[msg.sender];
        }
        return block.timestamp >= Math.add(lastAction, FREEZE_LIMIT_TIMER);
    }

    function canDefrost() public view returns (bool) {
        if (
            lockedFrostFlakes[msg.sender] >=
            calcBuyFrostFlakes(MAX_WALLET_TVL_IN_BNB)
        ) {
            return defrostTimeRequirementReached();
        }
        return
            defrostFreezeRequirementReached() &&
            defrostTimeRequirementReached();
    }

    function defrostTimeRequirementReached() public view returns (bool) {
        uint256 lastDefrostOrFirstDeposit = lastDefrost[msg.sender];
        if (lastDefrostOrFirstDeposit == 0) {
            lastDefrostOrFirstDeposit = firstDeposit[msg.sender];
        }

        if (
            lockedFrostFlakes[msg.sender] >=
            calcBuyFrostFlakes(MAX_WALLET_TVL_IN_BNB)
        ) {
            return block.timestamp >= (lastDefrostOrFirstDeposit + 7 days);
        }

        return block.timestamp >= (lastDefrostOrFirstDeposit + 6 days);
    }

    function defrostFreezeRequirementReached() public view returns (bool) {
        return
            freezesSinceLastDefrost[msg.sender] >=
            REQUIRED_FREEZES_BEFORE_DEFROST;
    }

    function maxPayoutReached(address adr) public view returns (bool) {
        return totalPayout[adr] >= MAX_PAYOUT;
    }

    function getReferrals(address adr)
        public
        view
        returns (address[] memory myReferrals)
    {
        return referrals[adr];
    }

    function getDetailedReferrals(address adr)
        public
        view
        returns (DetailedReferral[] memory myReferrals)
    {
        uint256 resultCount = referrals[adr].length;
        DetailedReferral[] memory result = new DetailedReferral[](resultCount);

        for (uint256 i = 0; i < referrals[adr].length; i++) {
            address refAddress = referrals[adr][i];
            result[i] = DetailedReferral(
                refAddress,
                totalDeposit[refAddress],
                userName[refAddress],
                hasMigratedOrIsNewUser(refAddress)
            );
        }

        return result;
    }

    function getMigrationInfo(address adr)
        public
        view
        returns (
            bool didMigrateInfo,
            bool didMigrateData,
            bool didRequestMigration,
            uint256 didLastRequestMigration
        )
    {
        return (
            userInfoMigrated[adr],
            userDataMigrated[adr],
            migrationRequested[adr],
            lastMigrationRequest[adr]
        );
    }

    function getUserInfo(address adr)
        public
        view
        returns (
            string memory myUserName,
            address myUpline,
            uint256 myReferrals,
            uint256 myTotalDeposit,
            uint256 myTotalPayouts
        )
    {
        return (
            userName[adr],
            upline[adr],
            downLineCount[adr],
            totalDeposit[adr],
            totalPayout[adr]
        );
    }

    function getDepositAndAirdropBonusInfo()
        public
        view
        returns (bool enabled, uint256 bonus)
    {
        return (depositAndAirdropBonusEnabled, DEPOSIT_BONUS_REWARD_PERCENT);
    }

    function getUserAirdropInfo(address adr)
        public
        view
        returns (
            uint256 MyAirdropsSent,
            uint256 MyAirdropsSentCount,
            uint256 MyAirdropsReceived,
            uint256 MyAirdropsReceivedCount
        )
    {
        return (
            airdrops_sent[adr],
            airdrops_sent_count[adr],
            airdrops_received[adr],
            airdrops_received_count[adr]
        );
    }

    function userExists(address adr) public view returns (bool) {
        return sender[adr] != address(0);
    }

    function getTotalUsers() public view returns (uint256) {
        return TOTAL_USERS;
    }

    function getBnbRewards(address adr) public view returns (uint256) {
        uint256 frostFlakes = getFrostFlakesSincelastFreeze(adr);
        uint256 bnbinWei = sellFrostFlakes(frostFlakes);
        return bnbinWei;
    }

    function getUserTLV(address adr) public view returns (uint256) {
        uint256 bnbinWei = calcSellFrostFlakes(lockedFrostFlakes[adr]);
        return bnbinWei;
    }

    function getUserName(address adr) public view returns (string memory) {
        return userName[adr];
    }

    function setUserName(string memory name)
        public
        payable
        returns (string memory)
    {
        userName[msg.sender] = name;
        return userName[msg.sender];
    }

    function getMyUpline() public view returns (address) {
        return upline[msg.sender];
    }

    function setMyUpline(address myUpline) public payable returns (address) {
        require(upline[msg.sender] == address(0), "Upline already set");
        require(
            sender[msg.sender] != address(0),
            "Upline user does not exists"
        );
        require(
            upline[myUpline] != msg.sender,
            "Cross referencing is not allowed"
        );

        upline[msg.sender] = myUpline;
        hasReferred[msg.sender] = true;
        referrals[upline[msg.sender]].push(msg.sender);
        downLineCount[upline[msg.sender]] = Math.add(
            downLineCount[upline[msg.sender]],
            1
        );

        return upline[msg.sender];
    }

    function getMyTotalDeposit() public view returns (uint256) {
        return totalDeposit[msg.sender];
    }

    function getMyTotalPayout() public view returns (uint256) {
        return totalPayout[msg.sender];
    }

    function togglepPermanentRewardFromDownline(bool enabled)
        public
        payable
        onlyOwner
        returns (bool)
    {
        permanentRewardFromDownlineEnabled = enabled;
        return permanentRewardFromDownlineEnabled;
    }

    function togglepPermanentRewardFromDeposit(bool enabled)
        public
        payable
        onlyOwner
        returns (bool)
    {
        permanentRewardFromDepositEnabled = enabled;
        return permanentRewardFromDepositEnabled;
    }

    function togglepRewardPercentCalculation(bool enabled)
        public
        payable
        onlyOwner
        returns (bool)
    {
        rewardPercentCalculationEnabled = enabled;
        return rewardPercentCalculationEnabled;
    }

    function getToggledValues()
        public
        view
        returns (
            bool permanentRewardFromDownlineToggled,
            bool permanentRewardFromDepositToggled,
            bool airdropToggled,
            bool ahProtocalToggled
        )
    {
        return (
            permanentRewardFromDownlineEnabled,
            permanentRewardFromDepositEnabled,
            airdropEnabled,
            aHProtocolInitialized
        );
    }

    function getAutoCompoundValues()
        public
        view
        returns (bool isAutoCompoundEnabled, uint256 autoCompoundStartValue)
    {
        return (autoCompoundEnabled[msg.sender], autoCompoundStart[msg.sender]);
    }

    function setBnBThresholdForDepositReward(uint256 newRewardThreshold)
        public
        payable
        onlyOwner
        returns (uint256)
    {
        BNB_THRESHOLD_FOR_DEPOSIT_REWARD = newRewardThreshold;
        return BNB_THRESHOLD_FOR_DEPOSIT_REWARD;
    }

    function getRefBonus() public view returns (uint256) {
        return REF_BONUS;
    }

    function getMarketingAndContractFee() public view returns (uint256) {
        return TEAM_AND_CONTRACT_FEE;
    }

    function getMaxDepositLine() public view returns (uint256) {
        return MAX_DEPOSITLINE;
    }

    function setMaxDepositLine(uint256 newMaxDepositLine)
        public
        payable
        onlyOwner
        returns (uint256)
    {
        MAX_DEPOSITLINE = newMaxDepositLine;
        return MAX_DEPOSITLINE;
    }

    function calcDepositLineBonus(address adr) private view returns (uint256) {
        if (depositLineCount[adr] >= MAX_DEPOSITLINE) {
            return MAX_DEPOSITLINE;
        }

        return depositLineCount[adr];
    }

    function getMyDownlineCount() public view returns (uint256) {
        return downLineCount[msg.sender];
    }

    function getMyDepositLineCount() public view returns (uint256) {
        return depositLineCount[msg.sender];
    }

    function toggleAHProtocol(bool start) public payable onlyOwner {
        aHProtocolInitialized = start;
    }

    function toggleDepositBonus(bool toggled) public payable onlyOwner {
        depositAndAirdropBonusEnabled = toggled;
    }

    function toggleAirdrops(bool enabled)
        public
        payable
        onlyOwner
        returns (bool)
    {
        airdropEnabled = enabled;
        return airdropEnabled;
    }

    function setDepositBonus(uint256 bonus) public payable onlyOwner {
        if (bonus >= 15) {
            DEPOSIT_BONUS_REWARD_PERCENT = 15;
        } else {
            DEPOSIT_BONUS_REWARD_PERCENT = bonus;
        }
    }

    function calcReferralBonus(address adr) private view returns (uint256) {
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

    function sellFrostFlakes(uint256 frostFlakes)
        public
        view
        returns (uint256)
    {
        uint256 bnbInWei = calcSellFrostFlakes(frostFlakes);
        bool bnbToSellGreateThanMax = bnbInWei > MAX_DEFROST_FREEZE_IN_BNB;
        if (bnbToSellGreateThanMax) {
            bnbInWei = MAX_DEFROST_FREEZE_IN_BNB;
        }
        return bnbInWei;
    }

    function calcSellFrostFlakes(uint256 frostFlakes)
        internal
        view
        returns (uint256)
    {
        uint256 bnbInWei = Math.mul(frostFlakes, BNB_PER_FROSTFLAKE);
        return bnbInWei;
    }

    function calcBuyFrostFlakes(uint256 bnbInWei)
        public
        view
        returns (uint256)
    {
        uint256 frostFlakes = Math.div(bnbInWei, BNB_PER_FROSTFLAKE);
        return frostFlakes;
    }

    function calcPercentAmount(uint256 amount, uint256 fee)
        private
        pure
        returns (uint256)
    {
        return Math.div(Math.mul(amount, fee), 100);
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getConcurrentFreezes(address adr) public view returns (uint256) {
        return freezesSinceLastDefrost[adr];
    }

    function getLastFreeze(address adr) public view returns (uint256) {
        return lastFreeze[adr];
    }

    function getLastDefrost(address adr) public view returns (uint256) {
        return lastDefrost[adr];
    }

    function getFirstDeposit(address adr) public view returns (uint256) {
        return firstDeposit[adr];
    }

    function getLockedFrostFlakes(address adr) public view returns (uint256) {
        return lockedFrostFlakes[adr];
    }

    function getMyExtraRewards()
        public
        view
        returns (uint256 downlineExtraReward, uint256 depositlineExtraReward)
    {
        uint256 extraDownlinePercent = calcReferralBonus(msg.sender);
        uint256 extraDepositLinePercent = calcDepositLineBonus(msg.sender);
        return (extraDownlinePercent, extraDepositLinePercent);
    }

    function updateMigrationStatus(address userAdr, bool migrateValue)
        public
        payable
        onlyOwner
        returns (bool)
    {
        userInfoMigrated[userAdr] = migrateValue;
        userDataMigrated[userAdr] = migrateValue;
        return userInfoMigrated[userAdr] && userDataMigrated[userAdr];
    }

    function getExtraRewards(address adr)
        public
        view
        returns (uint256 downlineExtraReward, uint256 depositlineExtraReward)
    {
        uint256 extraDownlinePercent = calcReferralBonus(adr);
        uint256 extraDepositLinePercent = calcDepositLineBonus(adr);
        return (extraDownlinePercent, extraDepositLinePercent);
    }

    function getExtraBonuses(address adr) private view returns (uint256) {
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

    function getFrostFlakesSincelastFreeze(address adr)
        public
        view
        returns (uint256)
    {
        uint256 maxFrostFlakes = MAX_FROST_FLAKES_TIMER;
        uint256 lastFreezeOrFirstDeposit = lastFreeze[adr];
        if (lastFreeze[adr] == 0) {
            lastFreezeOrFirstDeposit = firstDeposit[adr];
        }

        uint256 secondsPassed = Math.min(
            maxFrostFlakes,
            Math.sub(block.timestamp, lastFreezeOrFirstDeposit)
        );

        uint256 frostFlakes = calcFrostFlakesReward(
            secondsPassed,
            DAILY_REWARD,
            adr
        );

        if (autoCompoundEnabled[adr]) {
            frostFlakes = calcAutoCompoundReturn(adr);
        }

        uint256 extraBonus = getExtraBonuses(adr);
        if (extraBonus > 0) {
            uint256 extraBonusFrostFlakes = calcPercentAmount(
                frostFlakes,
                extraBonus
            );
            frostFlakes = Math.add(frostFlakes, extraBonusFrostFlakes);
        }

        return frostFlakes;
    }

    function calcFrostFlakesReward(
        uint256 secondsPassed,
        uint256 dailyReward,
        address adr
    ) private view returns (uint256) {
        uint256 rewardsPerDay = calcPercentAmount(
            Math.mul(lockedFrostFlakes[adr], 100000),
            dailyReward
        );
        uint256 rewardsPerSecond = Math.div(rewardsPerDay, SECONDS_PER_DAY);
        uint256 frostFlakes = Math.mul(rewardsPerSecond, secondsPassed);
        frostFlakes = Math.div(frostFlakes, 100000);
        return frostFlakes;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}