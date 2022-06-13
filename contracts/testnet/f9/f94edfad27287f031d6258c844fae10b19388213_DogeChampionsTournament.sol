// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol"; // to prevent reentry attacks

import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol"; // automation for tournament
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "contracts/VRFConsumerBaseV2Upgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "contracts/DogeChampionsNFT.sol";
import "contracts/ITournament.sol";

contract DogeChampionsTournament is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable, VRFConsumerBaseV2Upgradeable, ITournament, KeeperCompatibleInterface
{
    event TournamentCreated(uint256 tournamentId);
    event TournamentEnded(uint256 tournamentId, address winner, uint256 date, uint256 tournamentType);

    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private tournamentIds;
    CountersUpgradeable.Counter private currentTournamentId;
    CountersUpgradeable.Counter private mintCounter;

    mapping(uint256 => Tournament) private tournamentIdToTournament;
    mapping(uint256 => uint256) private tournamentIdToParticipantCount;

    mapping(uint256 => mapping(address => uint256)) private tournamentIdToParticipants;
    mapping(uint256 => mapping(uint256 => bool)) private tournamentIdToRegisteredTokenIds;

    mapping(uint256 => address) private tournamentIdToWinnerCandidate;
    mapping(uint256 => uint256) private tournamentIdToMaximumOverallScore;

    mapping(uint256 => address) private tournamentIdToWinner;

    mapping(address => uint256) private userToUncommonReward;
    mapping(address => uint256) private userToCommonReward;
    mapping(address => uint256) private userToRareReward;
    mapping(address => uint256) private userToEpicReward;
    mapping(address => uint256) private userToLegendaryReward;

    mapping(address => uint256) private userToConsumableReward;

    mapping(uint256 => bool) private tournamentIdToIsPaid;

    mapping(address => bool) private blackList;
    mapping(address => bool) private adminList;

    uint256 private consumableRewardCountForWinner;
    uint256 private consumableRewardCountForParticipant;

    uint256 private paidTournamentEntranceFee;

    uint256 constant private tournamentMintLimit = 9200; // with 20800 DogeChampionsNFTs minted from sales and giveaways, we will have 30K total supply

    bool private isPaidTournamentOngoing;
    
    DogeChampionsNFT private dogeChampionsNFT;
    address private dogeChampionsNFTContractAddress;
    address private dogeChampionsConsumableContractAddress;

    /// @dev VRF

    VRFCoordinatorV2Interface COORDINATOR;

    uint64 s_subscriptionId;
    address vrfCoordinator;
    bytes32 keyHash;
    uint32 callbackGasLimit;
    uint16 requestConfirmations;
    uint32 numWords;

    uint256[] public s_randomWords;
    uint256 public s_requestId;
    address s_owner;
    bool shouldMultiplyRandom;

    bool keepersEnabled;
    uint256 keepersDelay; // in seconds

    /// @dev VRF

    /*
     * @author struct to store tournament values that are fetched from DogeChampionsNFT
     */
    struct TournamentValues {
        uint256[4] actualAttackPowers;
        uint256[4] defensePowers;
        uint256[4] CRTRates;
        uint256[4] passiveSkills;
    }

    /*
     * @author modifier that prevents calls from addresses rather than admins and owner
     */
    modifier onlyAdmin
    {
        require(msg.sender == owner() || adminList[msg.sender] == true, "You are not allowed to perform this action.");
        _;
    }

    /*
     * @author modifier that prevents calls from addresses rather than DogeChampionsNFT contract
     */
    modifier onlyDogeChampionsNFT
    {
        require(msg.sender == dogeChampionsNFTContractAddress, "Only DogeChampionsNFT contract can access this function.");
        _;
    }

    /*
     * @author modifier that prevents calls from addresses rather than DogeChampionsConsumable contract
     */
    modifier onlyDogeChampionsConsumable
    {
        require(msg.sender == dogeChampionsConsumableContractAddress, "Only DogeChampionsConsumable contract can access this function.");
        _;
    }

    /*
     * @author plain good old constructor
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor()
    {
        _disableInitializers();
    }

    function initialize() initializer public {
        __Ownable_init();
        __ReentrancyGuard_init();

        vrfCoordinator = 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f;
        __VRFConsumberBaseV2_init(vrfCoordinator);
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_subscriptionId = 1034;
        s_owner = msg.sender;
        

        currentTournamentId.increment();
        consumableRewardCountForWinner = 5;
        consumableRewardCountForParticipant = 1;
        paidTournamentEntranceFee = 0.02 ether;
        isPaidTournamentOngoing = false;

        
        keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;
        callbackGasLimit = 100000;
        requestConfirmations = 3;
        numWords = 1;
        keepersEnabled = true;
        keepersDelay = 600;
        shouldMultiplyRandom = true;
    }

    /*
     * @author ChainLink upkeep validator function that checks if upkeep is needed
     * We don't need checkData and performData as they both exist in the contract state, hence they are commented out
     */
    function checkUpkeep(bytes calldata /*checkData*/) external view override returns (bool upkeepNeeded, bytes memory /*performData*/) {
        uint256 endDate = tournamentIdToTournament[currentTournamentId.current()].endTimestamp;
        upkeepNeeded = keepersEnabled && endDate != 0 && block.timestamp > (endDate + keepersDelay);
    }

    /*
     * @author ChainLink upkeep processor function that performs upkeep when needed
     * We don't need performData as it exists in the contract state, hence it is commented out
     */
    function performUpkeep(bytes calldata /* performData */) external override {
        if (block.timestamp > (tournamentIdToTournament[currentTournamentId.current()].endTimestamp + keepersDelay))
        {
            endCurrentTournament();
        }
    }

    /*
     * @author registers user to given tournamentId
     */
    function register(uint256 tournamentId, uint256[4] memory tokenIds) public payable override nonReentrant
    {
        require(blackList[msg.sender] == false, "You are black listed from tournaments. Contact to owner.");
        require(tournamentId <= tournamentIds.current(), "There is no such tournament with given tournament ID.");
        require(int256(tournamentIdToTournament[tournamentId].endTimestamp) - int256(block.timestamp) > 0, "Can't register to tournament that is already over.");
        require(tournamentIdToParticipants[tournamentId][msg.sender] == 0, "You already registered to this tournament.");
        require(dogeChampionsNFT.validatePlayability(msg.sender, tokenIds), "Can't enter tournament without an actual NFT, nor without owning given NFT.");
        require(validateTokenIds(tournamentId, tokenIds), "Can't register to given tournament id with already registered NFTs.");

        (uint256[4] memory elements, uint256[4] memory rarities) = dogeChampionsNFT.getElementsAndRarities(tokenIds);

        uint256 i;
        uint256 j;

        for(i = 0; i < 4; i++)
        {
            require(rarities[i] <= tournamentIdToTournament[tournamentId].tournamentType, "Can't register to tournament with higher rarity NFTs.");
        }

        for(i = 0; i < 4; i++)
        {
            if(tokenIds[i] == 0)
                continue;
                
            require(tournamentIdToTournament[tournamentId].elements[elements[i]] == 1, "Can't register to tournament with restricted element NFTs.");
        }

        
        if(tournamentIdToIsPaid[tournamentId])
        {
            require(msg.value == paidTournamentEntranceFee, "Please send the exact entrance amount.");
        }

        tournamentIdToParticipantCount[tournamentId] = tournamentIdToParticipantCount[tournamentId] + 1;

        uint256 overallScore = 0;

        uint256[4] memory increasedAttackPowers = dogeChampionsNFT.getAttackPowers(tokenIds);

        TournamentValues memory tournamentValues = getTournamentValues(tokenIds);

        uint256 additionalNormalTurn = 0;
        uint256 additionalCRTTurn = 0;

        for(i = 0; i < 4; i++)
        {
            if(tournamentValues.passiveSkills[i] == 0) continue;

            if(tournamentValues.passiveSkills[i] == 1)
            {
                additionalNormalTurn += 3;
            }
            else if(tournamentValues.passiveSkills[i] == 2)
            {
                additionalCRTTurn += 1;
            }
            else if(tournamentValues.passiveSkills[i] == 3)
            {
                for(j = 0; j < 4; j++)
                    increasedAttackPowers[j] += tournamentValues.actualAttackPowers[j] / 20;
            }
            else if(tournamentValues.passiveSkills[i] == 4)
            {
                for(j = 0; j < 4; j++)
                    increasedAttackPowers[j] += tournamentValues.actualAttackPowers[j] / 10;
            }
            else if(tournamentValues.passiveSkills[i] == 5)
            {
                for(j = 0; j < 4; j++)
                    if(elements[i] == elements[j])
                        increasedAttackPowers[j] += tournamentValues.actualAttackPowers[j] / 10;
            }
            else if(tournamentValues.passiveSkills[i] == 6)
            {
                for(j = 0; j < 4; j++)
                    if(elements[i] == elements[j])
                        increasedAttackPowers[j] += tournamentValues.actualAttackPowers[j] / 5;
            }
        }

        for(i = 0; i < 4; i++)
        {
            if(tokenIds[i] != 0)
            {
                for(j = 0; j < 3; j++)
                {
                    if(calculateCRTChance(block.timestamp * (i + j + currentTournamentId.current() + tournamentIds.current()), i, j) < 25) // 25% chance to hit CRT
                    {
                        overallScore += increasedAttackPowers[i] * tournamentValues.CRTRates[i];
                    }
                    else
                    {
                        overallScore += increasedAttackPowers[i];
                    }
                }
                overallScore += tournamentValues.defensePowers[i];
            }
        }

        for(i = 0; i < additionalNormalTurn; i++)
        {
            for(j = 0; j < 4; j++)
            {
                overallScore += increasedAttackPowers[j];
            }
        }

        for(i = 0; i < additionalCRTTurn; i++)
        {
            for(j = 0; j < 4; j++)
            {
                overallScore += increasedAttackPowers[j] * tournamentValues.CRTRates[j];
            }
        }

        finalizeResult(overallScore, tournamentId, msg.sender, tokenIds);
    }

    function getTournamentValues(uint256[4] memory tokenIds) internal view returns(TournamentValues memory tournamentValues)
    {
        (uint256[4] memory actualAttackPowers,
         uint256[4] memory defensePowers,
         uint256[4] memory CRTRates,
         uint256[4] memory passiveSkills) = dogeChampionsNFT.getTournamentValues(tokenIds);

         tournamentValues.actualAttackPowers = actualAttackPowers;
         tournamentValues.defensePowers = defensePowers;
         tournamentValues.CRTRates = CRTRates;
         tournamentValues.passiveSkills = passiveSkills;

         return tournamentValues;
    }

    /*
     * @author finalizes latest ended tournament
     */
    function endCurrentTournament() public override
    {
        uint256 currentId = currentTournamentId.current();
        require(int256(tournamentIdToTournament[currentId].endTimestamp) - int256(block.timestamp) <= 0, "Current tournament should expire first.");

        tournamentIdToWinner[currentId] = tournamentIdToWinnerCandidate[currentId];
        tournamentIdToMaximumOverallScore[currentId] = 0;

        if(tournamentIdToIsPaid[currentId])// paid tournament
        {
            isPaidTournamentOngoing = false;
            uint balanceTenPercent = address(this).balance / 10;
            payable(tournamentIdToWinner[currentId]).transfer(balanceTenPercent * 9); // 90% of the collected amount
            payable(owner()).transfer(balanceTenPercent); // 10% of the collected amount
        }

        setReward(tournamentIdToTournament[currentId].rewardId, tournamentIdToWinner[currentId]);

        currentTournamentId.increment();

        emit TournamentEnded(currentId, tournamentIdToWinner[currentId], block.timestamp, tournamentIdToTournament[currentId].tournamentType);
    }

    /*
     * @author decreases reward count of given wallet address - DogeChampionsNFT consumes this function after user mints tournament reward
     */
    function decreaseReward(uint256 tournamentType, address walletAddress) external override onlyDogeChampionsNFT
    {
        if(tournamentType == 0)
        {
            require(userToUncommonReward[walletAddress] > 0, "There are already no uncommon rewards to decrease.");
            userToUncommonReward[walletAddress] = userToUncommonReward[walletAddress] - 1;
        }
        else if(tournamentType == 1)
        {
            require(userToCommonReward[walletAddress] > 0, "There are already no common rewards to decrease.");
            userToCommonReward[walletAddress] = userToCommonReward[walletAddress] - 1;
        }
        else if(tournamentType == 2)
        {
            require(userToRareReward[walletAddress] > 0, "There are already no rare rewards to decrease.");
            userToRareReward[walletAddress] = userToRareReward[walletAddress] - 1;
        }
        else if(tournamentType == 3)
        {
            require(userToEpicReward[walletAddress] > 0, "There are already no epic rewards to decrease.");
            userToEpicReward[walletAddress] = userToEpicReward[walletAddress] - 1;
        }
        else if(tournamentType == 4)
        {
            require(userToLegendaryReward[walletAddress] > 0, "There are already no legendary rewards to decrease.");
            userToLegendaryReward[walletAddress] = userToLegendaryReward[walletAddress] - 1;
        }
    }

    /*
     * @author decreases consumable reward count of given wallet address - DogeChampionsConsumable consumes this function after user mints consumable
     */
    function decreaseConsumableReward(uint256 amount, address walletAddress) external override onlyDogeChampionsConsumable
    {
        require(userToConsumableReward[walletAddress] >= amount, "Not enough Consumable rewards to decrease.");
        userToConsumableReward[walletAddress] = userToConsumableReward[walletAddress] - amount;
    }

    /*
     * @author deposits sent BNB value to contract to be sent to next paid tournament winner
     */
    function depositBNBReward() payable public{}

    // @author Following region is for setter functions

    function setKeepersEnabled(bool value) public onlyOwner
    {
        keepersEnabled = value;
    }

    function setKeepersDelay(uint256 delay) public onlyOwner
    {
        keepersDelay = delay;
    }

    /*
     * @author sets given wallet address admin list with given value
     */
    function setUserAdminState(address walletAddress, bool isAdmin) public onlyOwner
    {
        adminList[walletAddress] = isAdmin;
    }

    /*
     * @author sets given wallet address to black list with given value
     */
    function setUserBlacklistState(address walletAddress, bool isBlacklist) public onlyAdmin
    {
        blackList[walletAddress] = isBlacklist;
    }

    /*
     * @author sets reward count for winner
     */
    function setWinnerRewardCount(uint256 count) public override onlyOwner
    {
        require(count > 0, "Reward count should at least 1.");
        consumableRewardCountForWinner = count;
    }

    /*
     * @author sets reward count for participation
     */
    function setParticipationRewardCount(uint256 count) public override onlyOwner
    {
        require(count > 0, "Reward count should at least 1.");
        consumableRewardCountForParticipant = count;
    }

    /*
     * @author sets DogeChampionsNFT contract related fields
     */
    function setNFTContract(address contractAddress) public override onlyOwner
    {
        dogeChampionsNFT = DogeChampionsNFT(contractAddress);
        dogeChampionsNFTContractAddress = contractAddress;
    }

    /*
     * @author sets DogeChampionsConsumable contract related fields
     */
    function setConsumableContract(address contractAddress) public override onlyOwner
    {
        dogeChampionsConsumableContractAddress = contractAddress;
    }

    /*
     * @author sets entrance fee for paid BNB tournaments. Send x1000 of the value to set.
     */
    function setPaidTournamentEntranceFee(uint256 fee) public override onlyOwner
    {
        paidTournamentEntranceFee = fee * (0.001 ether);
    }

    function setVRFSubscriptionId(uint64 subscriptionId) public onlyOwner
    {
        s_subscriptionId = subscriptionId;
    }

    /*
     * @author sets / creates a brand new tournament
     */
    function setTournament(uint256 endTimestamp, uint256 tournamentType, uint256[4] memory elements, bool isPaid, uint256 rewardId) public override onlyAdmin
    {
        require(!(isPaid && rewardId == 5), "Tournament can't be paid and consumable only at the same time.");
        if(isPaid)
        {
            require(!isPaidTournamentOngoing, "Can't start another paid tournament while there is already live one.");
            isPaidTournamentOngoing = true;
        }
        
        int256 timeUntilEnd = int256(endTimestamp) - int256(block.timestamp);
        //require(timeUntilEnd >= 3600, "A new tournament can be set for after 1 hour minimum.");
        //require(timeUntilEnd < 1209600, "A new tournament ca be set to 2 weeks later maximum.");
        //require(int256(endTimestamp) - int256(tournamentIdToTournament[tournamentIds.current()].endTimestamp) >= 3600, "A new tournament can only be set after 1 hour passed from last set tournament.");

        tournamentIds.increment();
        uint256 currentId = tournamentIds.current();

        tournamentIdToTournament[currentId] = Tournament(
            currentId,
            endTimestamp,
            tournamentType,
            elements,
            isPaid,
            rewardId
        );

        tournamentIdToIsPaid[currentId] = isPaid;
        tournamentIdToWinnerCandidate[currentId] = address(0);
        tournamentIdToMaximumOverallScore[currentId] = 0;
        
        emit TournamentCreated(currentId);
    }

    // @author Following region is for getter functions

    /*
     * @author returns contract balance
     */
    function getContractBalance() public override view returns(uint256)
    {
        return address(this).balance;
    }

    /*
     * @author returns ongoing tournament's winner candidate
     */
    function getOngoingTournamentWinnerCandidate(uint256 tournamentId) public view returns (address)
    {
        return tournamentIdToWinnerCandidate[tournamentId];
    }

    /*
     * @author returns active tournaments
     */
    function getActiveTournaments() external override view returns(Tournament[] memory)
    {
        uint256 tournamentCount = tournamentIds.current();
        uint256 activeTournamentCount = tournamentIds.current() - (currentTournamentId.current() - 1);

        Tournament[] memory activeTournaments = new Tournament[](activeTournamentCount);

        uint256 currentId = currentTournamentId.current();
        uint256 currentIndex = 0;

        for (uint256 i = currentId; i < tournamentCount + 1; i++)
        {
            activeTournaments[currentIndex] = tournamentIdToTournament[i];
            currentIndex += 1;
        }
        return activeTournaments;
    }

    /*
     * @author returns latest ended 10 tournament
     */
    function getLatestEndedTournaments() external override view returns(Tournament[] memory endedTournaments, address[] memory winners)
    {
        uint256 endedTournamentCount;
        uint256 startId;

        if(currentTournamentId.current() < 11)
        {
            endedTournamentCount = currentTournamentId.current() - 1;
            startId = 1;
        }
        else
        {
            endedTournamentCount = 10;
            startId = currentTournamentId.current() - 10;
        }

        endedTournaments = new Tournament[](endedTournamentCount);
        winners = new address[](endedTournamentCount);

        for (uint256 i = 0; i < endedTournamentCount; i++)
        {
            endedTournaments[i] = tournamentIdToTournament[startId];
            winners[i] = tournamentIdToWinner[startId];
            startId += 1;
        }
        return (endedTournaments, winners);
    }

    /*
     * @author returns tournament of given tournamentId
     */
    function getTournament(uint256 tournamentId) external override view returns(Tournament memory)
    {
        return tournamentIdToTournament[tournamentId];
    }

    /*
     * @author returns winner of given tournamentId
     */
    function getTournamentWinner(uint256 tournamentId) external override view returns(address)
    {
        return tournamentIdToWinner[tournamentId];
    }

    /*
     * @author returns current tournament
     */
    function getCurrentTournament() external override view returns(Tournament memory)
    {
        return tournamentIdToTournament[currentTournamentId.current()];
    }

    /*
     * @author returns paid tournament entrance fee
     */
    function getPaidTournamentEntryFee() external override view returns(uint256)
    {
        return paidTournamentEntranceFee;
    }

    /*
     * @author returns participant count of given tournamentId
     */
    function getParticipantCount(uint256 tournamentId) external view override returns(uint256)
    {
        return tournamentIdToParticipantCount[tournamentId];
    }

    /*
     * @author returns all rewards of given wallet address
     */
    function getRewards(address walletAddress) external view override returns(uint256[] memory)
    {
        uint256[] memory rewards = new uint256[](6);

        rewards[0] = userToUncommonReward[walletAddress];
        rewards[1] = userToCommonReward[walletAddress];
        rewards[2] = userToRareReward[walletAddress];
        rewards[3] = userToEpicReward[walletAddress];
        rewards[4] = userToLegendaryReward[walletAddress];
        rewards[5] = userToConsumableReward[walletAddress];

        return rewards;
    }

    /*
     * @author returns if user is joined to given tournamentId or not
     */
    function getIsJoined(uint256 tournamentId, address walletAddress) public override view returns(bool)
    {
        return tournamentIdToParticipants[tournamentId][walletAddress] == 0 ? false : true;
    }

    // @author Following region is for internal functions

    /*
     * @author helper function that sets tournament reward of the winner
     */
    function setReward(uint256 rewardId, address walletAddress) internal
    {
        if(tournamentIdToIsPaid[currentTournamentId.current()]) return;

        if(rewardId == 5) // consumable only tournament
        {
            // this tournament rewards user with only consumables - 30 consumables in total
            userToConsumableReward[walletAddress] = userToConsumableReward[walletAddress] + consumableRewardCountForWinner * 6;
            return;
        }

        if(mintCounter.current() >= tournamentMintLimit)
        {
            // in this case, we hit the tournament mint limit.
            // reward user with 30 consumables instead of 1 NFT & 5 consumables
            userToConsumableReward[walletAddress] = userToConsumableReward[walletAddress] + consumableRewardCountForWinner * 6;
            return;
        }

        if(rewardId == 0)
        {
            userToUncommonReward[walletAddress] = userToUncommonReward[walletAddress] + 1;
        }
        else if(rewardId == 1)
        {
            userToCommonReward[walletAddress] = userToCommonReward[walletAddress] + 1;
        }
        else if(rewardId == 2)
        {
            userToRareReward[walletAddress] = userToRareReward[walletAddress] + 1;
        }
        else if(rewardId == 3)
        {
            userToEpicReward[walletAddress] = userToEpicReward[walletAddress] + 1;
        }
        else if(rewardId == 4)
        {
            userToLegendaryReward[walletAddress] = userToLegendaryReward[walletAddress] + 1;
        }

        userToConsumableReward[walletAddress] = userToConsumableReward[walletAddress] + consumableRewardCountForWinner;

        mintCounter.increment();
    }

    /*
     * @author helper function that determines CRT chance randomly
     */
    function calculateCRTChance(uint256 nonce, uint256 tokenOrder, uint256 hitTurn) internal view returns(uint256)
    {
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce, s_randomWords[3 * tokenOrder + hitTurn]))) % 100;
    }

    /*
     * @author helper function that checks if given tokenIds are already registered to the given tournament id
     */
    function validateTokenIds(uint256 tournamentId, uint256[4] memory tokenIds) internal view returns(bool)
    {
        for(uint256 i = 0; i < 4; i++)
        {
            if(tokenIds[i] != 0 && tournamentIdToRegisteredTokenIds[tournamentId][tokenIds[i]])
                return false;
        }

        return true;
    }

    /*
     * @author helper function to prevent stack too deep error during tournament registration
     */
    function finalizeResult(uint256 overallScore, uint256 tournamentId, address user, uint256[4] memory tokenIds) internal
    {
        if(overallScore > tournamentIdToMaximumOverallScore[tournamentId])
        {
            // we have a new winner candidate
            tournamentIdToWinnerCandidate[tournamentId] = user;
            tournamentIdToMaximumOverallScore[tournamentId] = overallScore;
        }

        tournamentIdToParticipants[tournamentId][user] = overallScore;
        for(uint256 i = 0; i < 4; i++)
        {
            if(tokenIds[i] != 0)
                tournamentIdToRegisteredTokenIds[tournamentId][tokenIds[i]] = true;
        }

        userToConsumableReward[user] = userToConsumableReward[user] + consumableRewardCountForParticipant;

        updateRandomWords();
    }

    function updateRandomWords() internal {
        for(uint256 i = 0; i < numWords; i++) {
            if(shouldMultiplyRandom) {
                s_randomWords[0] *= block.timestamp; 
            } else {
                s_randomWords[0] /= block.timestamp;
            }
        }

        shouldMultiplyRandom = !shouldMultiplyRandom;
    }

    function requestRandomWords() external onlyOwner {
        // Will revert if subscription is not set and funded.
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
        ) internal override {
            s_randomWords = randomWords;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library CountersUpgradeable {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KeeperBase.sol";
import "./interfaces/KeeperCompatibleInterface.sol";

abstract contract KeeperCompatible is KeeperBase, KeeperCompatibleInterface {}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2Upgradeable is Initializable, ContextUpgradeable {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  function __VRFConsumberBaseV2_init(address _vrfCoordinator) internal onlyInitializing {
    vrfCoordinator = _vrfCoordinator;
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
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
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "contracts/ITournament.sol";
import "contracts/DogeChampionsConsumable.sol";

contract DogeChampionsNFT is Initializable, OwnableUpgradeable, ERC721URIStorageUpgradeable, ERC721EnumerableUpgradeable
{
    event Mint(address minter, uint256 tokenId);
    event Enhance(uint256 tokenId, uint256 consumableId, int256 valueChange);
    event PlayableIdRemoved(address walletAddress, uint256 tokenId);
    event PlayableIdAdded(address walletAddress, uint256 tokenId);
    event BaseURIChanged(string newBaseURI);

    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter public _tokenIds;
    CountersUpgradeable.Counter private randomizationNonce;
    CountersUpgradeable.Counter public numberOfNormalMints;
    CountersUpgradeable.Counter public numberOfTournamentMints;
    CountersUpgradeable.Counter public mintPhase;

    mapping(address => uint256) private initialMintDiscountWhitelist;
    mapping(address => uint256) private finalMintDiscountWhitelist;
    mapping(address => uint256) private collaboratorWhitelist;

    mapping(uint256 => uint256) public tokenIdToAttackPower;
    mapping(uint256 => uint256) public tokenIdToDefensePower;
    mapping(uint256 => uint256) public tokenIdToCRTRate;
    mapping(uint256 => uint256) public tokenIdToPassive;
    mapping(uint256 => uint256) public tokenIdToElement;
    mapping(uint256 => uint256) public tokenIdToRarity;
    mapping(uint256 => address) public tokenIdToMinter;

    mapping(address => uint256[]) public walletToPlayableTokenIds;

    mapping(uint256 => address) public playableTokenIdToUser;

    mapping(uint256 => uint256[]) public tokenIdToUsedConsumableHistory;
    mapping(uint256 => int256[]) public tokenIdToPropertyValueChangeHistory;

    uint256 public discountedMintPrice;
    uint256 public initialMintPrice;
    uint256 public finalMintPrice;

    /*
     * @author finite total supply is 30,000
     * First Mint Phase: 10,400 mint
     * Second Mint Phase: 10,400 mint
     * Total Tournament Mint: 9,200
     */
    uint256 constant normalMintLimit = 10400; // 10K sale and 400 giveaway for each phase
    uint256 constant tournamentMintLimit = 9200; // total tournament mint count

    address private marketplaceAddress;

    bool private isMintAvailable;

    bool private ignoreDiscountWhitelist;

    bool public isMigrationOver;

    ITournament private dogeChampionsTournament;
    DogeChampionsConsumable private dogeChampionsConsumable;

    // percentage rates of property determination. These will be used to set Boost Events
    uint256 public firstChancePercent;
    uint256 public secondChancePercent;
    uint256 public thirdChancePercent;
    uint256 public forthChancePercent;

    string private baseURIOverride; // format => ipfs://CustomCIDHashToBeSet/

    /*
     * @author required override for ERC721Enumerable
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /*
     * @author required override for ERC721Enumerable
     */
    function _burn(uint256 tokenId) internal override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
    {
        super._burn(tokenId);
    }

    /*
     * @author required override for ERC721Enumerable
     */
    function tokenURI(uint256 tokenId) public view override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    /*
     * @author required override for ERC721Enumerable
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721Upgradeable, ERC721EnumerableUpgradeable) returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /*
     * @author optional override for baseURI.
     */
    function _baseURI() internal view override returns (string memory)
    {
        return baseURIOverride;
    }

    /*
     * @author override for transfer to update 
     */
    function _transfer(address from, address to, uint256 tokenId) internal override {
        super._transfer(from, to, tokenId);
        if(to == marketplaceAddress ||from == marketplaceAddress)
            return;
            
        _removeFromPlayableIds(from, tokenId);
        _pushToPlayableIds(to, tokenId);
    }

    /*
     * @author modifier that prevents calls from addresses rather than DogeChampionsMarketplace contract
     */
    modifier onlyMarketplace
    {
        require(msg.sender == marketplaceAddress, "Only DogeChampionsMarketplace contract can access this function.");
        _;
    }

    /*
     * @author plain good old constructor
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor()
    {
        _disableInitializers();
    }

    function initialize() initializer public {
        __Ownable_init();
        __ERC721_init("DogeChampionsNFT", "DOGECHMP");
        __ERC721Enumerable_init();
        __ERC721URIStorage_init();

        configureMint();

        firstChancePercent = 60;
        secondChancePercent = 90;
        thirdChancePercent = 98;
        forthChancePercent = 100;

        discountedMintPrice = 0.11 ether;
        initialMintPrice = 0.22 ether;
        finalMintPrice = 0.55 ether;

        isMintAvailable = false;
        ignoreDiscountWhitelist = false;
        isMigrationOver = false;
    }

    /*
     * @author configures the mint phase. No more than 2 mint phases can be established
     */
    function configureMint() public onlyOwner
    {
        require(mintPhase.current() < 2, "No more mint phase can be started. We already ran 2 mint phases.");
        mintPhase.increment();

        numberOfNormalMints.reset();
    }
    
    /*
     * @author calculates random number full on-chain using randomized nonce and keccak
     */
    function calculateRandomness(uint256 modulus) internal returns(uint256)
    {
        randomizationNonce.increment(); 
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, randomizationNonce.current()))) % modulus;
    }

    /*
     * @author validates if given tokenId is playable by user
     */
    function validatePlayability(address walletAddress, uint256 tokenId) public view returns(bool)
    {
        return playableTokenIdToUser[tokenId] == walletAddress;
    }

    /*
     * @author validates if given tokenIds are playable by user
     */
    function validatePlayability(address walletAddress, uint256[4] memory tokenIds) public view returns(bool)
    {
        bool zeroValidation = false;
        bool containsNonPlayableTokenId = false;
        for(uint256 i = 0; i < 4; i++)
        {
            if(tokenIds[i] != 0)
            {
                zeroValidation = true;
                if(playableTokenIdToUser[tokenIds[i]] != walletAddress)
                {
                    containsNonPlayableTokenId = true;
                    break;
                }
            }
        }

        return zeroValidation && !containsNonPlayableTokenId;
    }

    /*
     * @author re-evaluates given tokenId's property depending on consumableTokenId
     */
    function enhanceProperty(uint256 tokenId, uint256 consumableTokenId) public
    {
        require(tokenId <= _tokenIds.current(), "There is no such NFT.");
        require(consumableTokenId >= 0 && consumableTokenId < 6, "There is no such consumable type.");
        require(dogeChampionsConsumable.balanceOf(msg.sender, consumableTokenId) > 0, "You don't have enough consumable.");
        require(ownerOf(tokenId) == msg.sender, "Can't enhance properties of not owned NFT.");

        dogeChampionsConsumable.burn(consumableTokenId, msg.sender);

        if(consumableTokenId < 3)
        {
            enhance(tokenId, consumableTokenId, false);
        }
        else
        {
            enhance(tokenId, consumableTokenId, true);
        }
    }

    /*
     * @author helper internal function for enhancing properties using normal consumable
     */
    function enhance(uint256 tokenId, uint256 consumableTokenId, bool isPremium) internal
    {
        int256 valueChange;
        if(consumableTokenId % 3 == 0)
        {
            valueChange = determinePower(true, tokenId, isPremium);
        }
        else if(consumableTokenId % 3 == 1)
        {
            valueChange = determinePower(false, tokenId, isPremium);
        }
        else if(consumableTokenId % 3 == 2)
        {
            valueChange = determineCRTRate(tokenId, isPremium);
        }

        tokenIdToUsedConsumableHistory[tokenId].push(consumableTokenId); 
        tokenIdToPropertyValueChangeHistory[tokenId].push(valueChange);

        emit Enhance(tokenId, consumableTokenId, valueChange);
    }

    // @author following region is for mint related functions

    /*
     * @author mints a DogeChampionsNFT for regular mint price on current mint phase
     */
    function publicMint(bool isDiscountMint, uint256 amount) public payable returns (uint256)
    {
        require(isMintAvailable == true, "Minting is not started yet.");
        require(numberOfNormalMints.current() + amount <= normalMintLimit, "Decrease amount of mint, not enough supply left.");

        if (isDiscountMint) {
            require(!ignoreDiscountWhitelist, "Discount period ended.");
            if(mintPhase.current() < 2)
            {
                require(initialMintDiscountWhitelist[msg.sender] >= amount, "You don't have enough WL credit.");
                initialMintDiscountWhitelist[msg.sender] = initialMintDiscountWhitelist[msg.sender] - amount;
            }
            else
            {
                require(finalMintDiscountWhitelist[msg.sender] >= amount, "You don't have enough WL credit.");
                finalMintDiscountWhitelist[msg.sender] = finalMintDiscountWhitelist[msg.sender] - amount;
            }
            require(msg.value == discountedMintPrice * amount, "Please submit the exact price to mint a Doge Champion.");
        } else {
            if(mintPhase.current() < 2)
            {
                require(msg.value == initialMintPrice * amount, "Please submit the exact price to mint DogeChampionsNFT.");
            }
            else
            {
                require(msg.value == finalMintPrice * amount, "Please submit the exact price to mint DogeChampionsNFT.");
            }
        }
        
        payable(owner()).transfer(msg.value);

        for(uint256 i = 0; i < amount; i++)
        {
            _tokenIds.increment();
            numberOfNormalMints.increment();
            mint(false, 0);
        }

        return _tokenIds.current();
    }

    /*
     * @author mints a DogeChampionsNFT for free - only tournament winners and collaborators
     */
    function freeMint(bool isTournamentMint, uint256 amount, uint256 rarity) public
    {
        require(isMintAvailable == true, "Minting is not started yet.");
        require(numberOfNormalMints.current() + amount <= normalMintLimit, "Decrease amount of mint, not enough supply left.");

        if (isTournamentMint) {
            require(numberOfTournamentMints.current() < tournamentMintLimit, "We hit tournament mint limit.");
            uint256[] memory rewards = dogeChampionsTournament.getRewards(msg.sender);
            require(rarity < 5, "There is no such NFT rarity.");
            require(rewards[rarity] >= amount, "You don't have NFT rewards.");

            for(uint256 i = 0; i < amount; i++)
            {
                _tokenIds.increment();
                numberOfTournamentMints.increment();
                mint(true, rarity);
            }

            dogeChampionsTournament.decreaseReward(rarity, msg.sender);
        } else {
            require(collaboratorWhitelist[msg.sender] >= amount, "You don't have enough credit.");

            for(uint256 i = 0; i < amount; i++)
            {
                _tokenIds.increment();
                numberOfNormalMints.increment();
                mint(false, 0);
            }

            collaboratorWhitelist[msg.sender] = collaboratorWhitelist[msg.sender] - amount;
        }

    }

    /*
     * @author this function is going to be used by owner during the version 2 update migration. After all NFTs
     * from DogeChampions V1 migrated, we will set isMigrationOver flag to false and this function won't be
     * available for further use.
     */
    function migrationMint(uint256 rarity, uint256 element, uint256 attack, uint256 defense, uint256 crt, uint256 passive, string memory uri, address tokenOwner, bool isOnSale) public onlyOwner
    {
        require(!isMigrationOver, "This function can only be called during V2 migration.");
        uint256 newItemId = _tokenIds.current();

        tokenIdToRarity[newItemId] = rarity;
        tokenIdToElement[newItemId] = element;
        tokenIdToAttackPower[newItemId] = attack;
        tokenIdToDefensePower[newItemId] = defense;
        tokenIdToCRTRate[newItemId] = crt;
        tokenIdToPassive[newItemId] = passive;

        if(isOnSale)
        {
            _mint(marketplaceAddress, newItemId);
        }
        else
        {
            _mint(tokenOwner, newItemId);
        }
        
        _setTokenURI(newItemId, uri);
        setApprovalForAll(marketplaceAddress, true);

        _pushToPlayableIds(tokenOwner, newItemId);

        tokenIdToMinter[_tokenIds.current()] = tokenOwner;
    }

    /*
     * @author generic mint function for different price mints functions to consume
     */
    function mint(bool isTournamentMint, uint256 tournamentMintRarity) internal 
    {
        uint256 newItemId = _tokenIds.current();

        determineRarity(newItemId, isTournamentMint, tournamentMintRarity);
        determineElement(newItemId);
        determinePower(true, newItemId, false);
        determinePower(false, newItemId, false);
        determineCRTRate(newItemId, false);
        determinePassive(newItemId);

        string memory firstPart = string(abi.encodePacked(StringsUpgradeable.toString(determineBackgroundLayer(newItemId)), "-", StringsUpgradeable.toString(calculateRandomness(18)/*weapon*/), "-", StringsUpgradeable.toString(tokenIdToElement[newItemId]/*skin*/), "-"));
        string memory secondPart = string(abi.encodePacked(StringsUpgradeable.toString(calculateRandomness(16)/*face*/), "-", StringsUpgradeable.toString(calculateRandomness(8)/*eye*/), "-", StringsUpgradeable.toString(calculateRandomness(12)/*mouth*/), "-"));
        string memory thirdPart = string(abi.encodePacked(StringsUpgradeable.toString(calculateRandomness(23)/*glasses*/), "-", StringsUpgradeable.toString(calculateRandomness(116)/*outfit*/), "-", StringsUpgradeable.toString(calculateRandomness(93)/*head*/), ".json"));

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, string(abi.encodePacked(firstPart, secondPart, thirdPart)));
        setApprovalForAll(marketplaceAddress, true);

        _pushToPlayableIds(msg.sender, newItemId);

        tokenIdToMinter[_tokenIds.current()] = msg.sender;

        emit Mint(msg.sender, _tokenIds.current());
    }

    // @author following region is for determining a DogeChampionsNFT's properties during mint

    /*
     * @author determines rarity of user's DogeChampionsNFT randomly on-chain during mint
     */
    function determineRarity(uint256 tokenId, bool isTournamentMint, uint256 tournamentRarity) internal
    {
        if(isTournamentMint)
        {
            tokenIdToRarity[tokenId] = tournamentRarity;
            return;
        }

        uint256 randomNumber = calculateRandomness(200); // using 200 as limit to be more precise on floating points

        if(randomNumber >= 0 && randomNumber < 80) // 40% chance
            tokenIdToRarity[tokenId] = 0; // un-common
        else if(randomNumber >= 80 && randomNumber < 140) // 30% chance
            tokenIdToRarity[tokenId] = 1; // common
        else if(randomNumber >= 140 && randomNumber < 180) // 20% chance
            tokenIdToRarity[tokenId] = 2; // rare
        else if(randomNumber >= 180 && randomNumber < 199) // 9.5% chance
            tokenIdToRarity[tokenId] = 3; // epic
        else if(randomNumber >= 199 && randomNumber < 200) // 0.5% chance
            tokenIdToRarity[tokenId] = 4; // legendary
    }

    /*
     * @author determines element of user's DogeChampionsNFT randomly on-chain during mint
     */
    function determineElement(uint256 tokenId) internal
    {
        uint256 randomNumber = calculateRandomness(40);

        if(randomNumber >= 0 && randomNumber < 9)
            tokenIdToElement[tokenId] = 0;
        else if(randomNumber >= 9 && randomNumber < 19)
            tokenIdToElement[tokenId] = 1;
        else if(randomNumber >= 19 && randomNumber < 29)
            tokenIdToElement[tokenId] = 2;
        else if(randomNumber >= 29 && randomNumber < 39)
            tokenIdToElement[tokenId] = 3;
    }

    /*
     * @author determines background layer of user's DogeChampionsNFT randomly on-chain during mint
     */
    function determineBackgroundLayer(uint256 tokenId) internal returns (uint256)
    {
        uint256 rarityIndicator = tokenIdToRarity[tokenId];
        uint256 randomNumber = calculateRandomness(100);
        uint256 candidateBackgroundLayer;


        if(rarityIndicator == 4) // legendary card
        {
            if(randomNumber >= 0 && randomNumber < 33)
                candidateBackgroundLayer = 10;
            else if(randomNumber >= 33 && randomNumber < 66)
                candidateBackgroundLayer = 11;
            else if(randomNumber >= 66 && randomNumber < 100)
                candidateBackgroundLayer = 12;
        }
        else if(rarityIndicator == 3) // epic card
        {
            if(randomNumber >= 0 && randomNumber < 50)
                candidateBackgroundLayer = 8;
            else if(randomNumber >= 50 && randomNumber < 100)
                candidateBackgroundLayer = 9;
        }
        else if(rarityIndicator == 2) // rare card
        {
            if(randomNumber >= 0 && randomNumber < 50)
                candidateBackgroundLayer = 6;
            else if(randomNumber >= 50 && randomNumber < 100)
                candidateBackgroundLayer = 7;
        }
        else if(rarityIndicator == 1) // uncommon card
        {
            if(randomNumber >= 0 && randomNumber < 50)
                candidateBackgroundLayer = 4;
            else if(randomNumber >= 50 && randomNumber < 100)
                candidateBackgroundLayer = 5;
        }
        else // common card
        {
            if(randomNumber >= 0 && randomNumber < 25)
                candidateBackgroundLayer = 0;
            else if(randomNumber >= 25 && randomNumber < 50)
                candidateBackgroundLayer = 1;
            else if(randomNumber >= 50 && randomNumber < 75)
                candidateBackgroundLayer = 2;
            else if(randomNumber >= 75 && randomNumber < 100)
                candidateBackgroundLayer = 3;
        }

        return candidateBackgroundLayer;
    }

    /*
     * @author determines attack & defense power peoperty of user's DogeChampionsNFT randomly on-chain during mint
     */
    function determinePower(bool isAttack, uint256 tokenId, bool isPremiumEnhance) internal returns (int256)
    {
        uint256 rarityIndicator = tokenIdToRarity[tokenId];
        uint256 powerCandidate;

        uint256 percent = calculateRandomness(100);

        if(percent < firstChancePercent) // 60% chance
        {
            powerCandidate = calculateRandomness(20) + 50; // 50 - 69 power
        }
        else if(percent < secondChancePercent) // 30% chance
        {
            powerCandidate = calculateRandomness(10) + 70; // 70 - 79 power
        }
        else if(percent < thirdChancePercent) // 8% chance
        {
            powerCandidate = calculateRandomness(10) + 80; // 80 - 89 power
        }
        else if(percent < forthChancePercent) // 2% chance
        {
            powerCandidate = calculateRandomness(10) + 90; // 90 - 99 power
        }

        if(powerCandidate == 99)
            powerCandidate = 100;

        for(uint256 i = 0; i < rarityIndicator; i++)
            powerCandidate *= 2;

        if(isAttack) {
            if(isPremiumEnhance)
            {
                if(powerCandidate > tokenIdToAttackPower[tokenId])
                {
                    uint256 oldValue = tokenIdToAttackPower[tokenId];
                    tokenIdToAttackPower[tokenId] = powerCandidate;
                    return int256(powerCandidate) - int256(oldValue);
                }
                return 0;
            }
            else
            {
                uint256 oldValue = tokenIdToAttackPower[tokenId];
                tokenIdToAttackPower[tokenId] = powerCandidate;
                return int256(powerCandidate) - int256(oldValue);
            }
        } else {
            if(isPremiumEnhance)
            {
                if(powerCandidate > tokenIdToDefensePower[tokenId])
                {
                    uint256 oldValue = tokenIdToDefensePower[tokenId];
                    tokenIdToDefensePower[tokenId] = powerCandidate;
                    return int256(powerCandidate) - int256(oldValue);
                }
                return 0;
            }
            else
            {
                uint256 oldValue = tokenIdToDefensePower[tokenId];
                tokenIdToDefensePower[tokenId] = powerCandidate;
                return int256(powerCandidate) - int256(oldValue);
            }
        }
    }

    /*
     * @author determines CRT rate peoperty of user's DogeChampionsNFT randomly on-chain during mint
     */
    function determineCRTRate(uint256 tokenId, bool isPremiumEnhance) internal returns(int256)
    {
        uint256 CRTRateCandidate;

        uint256 percent = calculateRandomness(100);

        if(percent < 60) // 60% chance
        {
            CRTRateCandidate = calculateRandomness(4) + 2; // 2 - 5 CRT rate
        }
        else if(percent < 90) // 30% chance
        {
            CRTRateCandidate = calculateRandomness(3) + 6; // 6 - 8 CRT rate
        }
        else if(percent < 98) // 8% chance
        {
            CRTRateCandidate = calculateRandomness(2) + 9; // 9 - 10 CRT rate
        }
        else if(percent < 100) // 2% chance
        {
            CRTRateCandidate = calculateRandomness(2) + 11; // 11 - 12 CRT rate
        }

        if(isPremiumEnhance)
        {
            if(CRTRateCandidate > tokenIdToCRTRate[tokenId])
            {
                uint256 oldValue = tokenIdToCRTRate[tokenId];
                tokenIdToCRTRate[tokenId] = CRTRateCandidate;
                return int256(CRTRateCandidate) - int256(oldValue);
            }
            return 0;
        }
        else
        {
            uint256 oldValue = tokenIdToCRTRate[tokenId];
            tokenIdToCRTRate[tokenId] = CRTRateCandidate;
            return int256(CRTRateCandidate) - int256(oldValue);
        }
    }

    /*
     * @author determines passive skill of user's DogeChampionsNFT randomly on-chain during mint
     */
    function determinePassive(uint256 tokenId) internal
    {
        uint256 randomNumber = calculateRandomness(100);

        if(randomNumber >= 0 && randomNumber < 25) // 25% chance
            tokenIdToPassive[tokenId] = 1; // additional 3 normal turns for each Doge Champion
        else if(randomNumber >= 25 && randomNumber < 40) // 15% chance
            tokenIdToPassive[tokenId] = 2; // additional 1 CRT turn for each Doge Champion
        else if(randomNumber >= 40 && randomNumber < 65) // 25% chance
            tokenIdToPassive[tokenId] = 3; // everyone 5% more attack power
        else if(randomNumber >= 65 && randomNumber < 80) // 15% chance
            tokenIdToPassive[tokenId] = 4; // everyone 10% more attack power
        else if(randomNumber >= 80 && randomNumber < 95) // 15% chance
            tokenIdToPassive[tokenId] = 5; // same element 10% more attack power
        else if(randomNumber >= 95 && randomNumber < 100) // 5% chance
            tokenIdToPassive[tokenId] = 6; // same element 20% more attack power

    }

    // @author following region is for altering playable tokenIds of given user

    /*
     * @author adds a new tokenId for given user into playable ids map
     */
    function pushToPlayableIds(address walletAddress, uint256 tokenId) public onlyMarketplace
    {
        _pushToPlayableIds(walletAddress, tokenId);
    }

    /*
     * @author adds a new tokenId for given user into playable ids map internally
     */
    function _pushToPlayableIds(address walletAddress, uint256 tokenId) internal
    {
        walletToPlayableTokenIds[walletAddress].push(tokenId);
        playableTokenIdToUser[tokenId] = walletAddress;
        emit PlayableIdAdded(walletAddress, tokenId);
    }

    /*
     * @author removes given tokenId for given user from playable ids map
     */
    function removeFromPlayableIds(address walletAddress, uint256 tokenId) public onlyMarketplace
    {
        _removeFromPlayableIds(walletAddress, tokenId);
    }

    /*
     * @author removes given tokenId for given user from playable ids map internally
     */
    function _removeFromPlayableIds(address walletAddress, uint256 tokenId) internal
    {
        uint256[] memory playableIdArray = walletToPlayableTokenIds[walletAddress];

        if(playableIdArray.length == 0)
            return;
            
        uint256[] memory newArray = new uint256[](playableIdArray.length - 1);

        uint256 j = 0;
        for(uint256 i = 0; i < playableIdArray.length; i++)
        {
            if(playableIdArray[i] != tokenId)
            {
                newArray[j] = playableIdArray[i];
                j += 1;
            }
        }

        walletToPlayableTokenIds[walletAddress] = newArray;
        emit PlayableIdRemoved(walletAddress, tokenId);
    }

    /*
     * @author sets isMigrationOver flag to false to cancel usage of migration mint function
     */
    function finalizeMigration() public onlyOwner
    {
        require(!isMigrationOver, "Migration mint flag can be set only once to false.");
        isMigrationOver = true;
    }

    // @author Following region is for getter functions

    /*
     * @author returns attack powers of given tokenIds. This is consumed by tournament contract
     */
    function getAttackPowers(uint256[4] memory tokenIds) public view returns(uint256[4] memory result)
    {
        result = [tokenIdToAttackPower[tokenIds[0]],
                  tokenIdToAttackPower[tokenIds[1]],
                  tokenIdToAttackPower[tokenIds[2]],
                  tokenIdToAttackPower[tokenIds[3]]];
        
        return result;
    }

    /*
     * @author returns rarity of given token id
     */
    function getRarity(uint256 tokenId) public view returns(uint256)
    {    
        return tokenIdToRarity[tokenId];
    }

    /*
     * @author returns elements and rarities for given tokenIds. This is consumed by tournament contract
     */
    function getElementsAndRarities(uint256[4] memory tokenIds) public view returns(uint256[4] memory elements, uint256[4] memory rarities)
    {
        elements = [tokenIdToElement[tokenIds[0]],
                    tokenIdToElement[tokenIds[1]],
                    tokenIdToElement[tokenIds[2]],
                    tokenIdToElement[tokenIds[3]]];

        rarities = [tokenIdToRarity[tokenIds[0]],
                  tokenIdToRarity[tokenIds[1]],
                  tokenIdToRarity[tokenIds[2]],
                  tokenIdToRarity[tokenIds[3]]];
        
        return (elements, rarities);
    }

    /*
     * @author returns attack, defense, CRT and passive skills for given tokenIds. This is consumed by tournament contract
     */
    function getTournamentValues(uint256[4] memory tokenIds) public view returns(uint256[4] memory attackPowers, uint256[4] memory defensePowers, uint256[4] memory crtRates, uint256[4] memory passiveSkills)
    {
        attackPowers = [tokenIdToAttackPower[tokenIds[0]],
                    tokenIdToAttackPower[tokenIds[1]],
                    tokenIdToAttackPower[tokenIds[2]],
                    tokenIdToAttackPower[tokenIds[3]]];

        defensePowers = [tokenIdToDefensePower[tokenIds[0]],
                  tokenIdToDefensePower[tokenIds[1]],
                  tokenIdToDefensePower[tokenIds[2]],
                  tokenIdToDefensePower[tokenIds[3]]];

        crtRates = [tokenIdToCRTRate[tokenIds[0]],
                  tokenIdToCRTRate[tokenIds[1]],
                  tokenIdToCRTRate[tokenIds[2]],
                  tokenIdToCRTRate[tokenIds[3]]];

        passiveSkills = [tokenIdToPassive[tokenIds[0]],
                  tokenIdToPassive[tokenIds[1]],
                  tokenIdToPassive[tokenIds[2]],
                  tokenIdToPassive[tokenIds[3]]];
        
        return (attackPowers, defensePowers, crtRates, passiveSkills);
    }

    /*
     * @author returns all values for given tokenId.
     */
    function getAllValues(uint256[] memory tokenIds) public view returns(uint256[] memory attacks,
                                                               uint256[] memory defenses,
                                                               uint256[] memory crts,
                                                               uint256[] memory passives,
                                                               uint256[] memory rarities,
                                                               uint256[] memory elements,
                                                               string[] memory uris)
    {
        attacks = new uint[](tokenIds.length);
        defenses = new uint[](tokenIds.length);
        crts = new uint[](tokenIds.length);
        passives = new uint[](tokenIds.length);
        rarities = new uint[](tokenIds.length);
        elements = new uint[](tokenIds.length);
        uris = new string[](tokenIds.length);

        for(uint256 i = 0; i < tokenIds.length; i++)
        {
            attacks[i] = tokenIdToAttackPower[tokenIds[i]];
            defenses[i] = tokenIdToDefensePower[tokenIds[i]];
            crts[i] = tokenIdToCRTRate[tokenIds[i]];
            passives[i] = tokenIdToPassive[tokenIds[i]];
            rarities[i] = tokenIdToRarity[tokenIds[i]];
            elements[i] = tokenIdToElement[tokenIds[i]];
            uris[i] = tokenURI(tokenIds[i]);
        }

        return (attacks,
                defenses,
                crts,
                passives,
                rarities,
                elements,
                uris);
    }

    /*
     * @author returns history of used consumables on given tokenId
     */
    function getConsumableHistory(uint256 tokenId) public view returns(uint256[] memory, int256[] memory)
    {
        uint256[] memory usedConsumableHistoryArray = tokenIdToUsedConsumableHistory[tokenId];
        int256[] memory valueChangeHistoryArray = tokenIdToPropertyValueChangeHistory[tokenId];
        uint256 length = usedConsumableHistoryArray.length;

        if(length < 10)
        {
            uint256[] memory history = new uint256[](length);
            int256[] memory valueChange = new int256[](length);
            for(uint256 i = 0; i < length; i++)
            {
                history[i] = usedConsumableHistoryArray[i];
                valueChange[i] = valueChangeHistoryArray[i];
            }
            return (history, valueChange);
        }
        else
        {
            uint256[] memory history = new uint256[](10);
            int256[] memory valueChange = new int256[](10);
            uint256 historyIndex = length - 10;
            for(uint256 i = 0; i < 10; i++)
            {
                history[i] = usedConsumableHistoryArray[historyIndex];
                valueChange[i] = valueChangeHistoryArray[historyIndex];
                historyIndex++;
            }
            return (history, valueChange);
        }
    }

    /*
     * @author returns minter of given tokenId
     */
    function getMinterOfToken(uint256 tokenId) public view returns(address)
    {
        return tokenIdToMinter[tokenId];
    }

    /*
     * @author returns playable tokenIds of given user. After users mint / purchase
     * DogeChampionsNFT, they will be able to see minted / purchased tokenId even
     * if they start selling their NFTs on marketplace. This is to prevent users
     * stop their sales on our marketplace to enter tournaments.
     */
    function getPlayableIds(address walletAddress) public view returns(uint256[] memory)
    {
        return walletToPlayableTokenIds[walletAddress];
    }

    // @author Following region is for setter functions

    /*
     * @author sets property determination rates. We are going to use this method for setting Boost Events
     */
    function setPropertyDeterminationRates(uint256 first, uint256 second, uint256 third) public onlyOwner
    {
        require(first > 0, "Minimum percent should be 1.");
        require(first < second && second < third && third < 100, "Percentages should be in order and less than 100.");
        require(isMintAvailable == false, "This can't be changed during the mint.");

        firstChancePercent = first;
        secondChancePercent = second;
        thirdChancePercent = third;
    }

    /*
     * @author resets property determination rates to default. Should be called to end current Boost Event
     */
    function resetPropertyDeterminationRates() public onlyOwner
    {
        firstChancePercent = 60;
        secondChancePercent = 90;
        thirdChancePercent = 98;
    }

    /*
     * @author sets mint price. Send x1000 of the value for price
     */
    function setMintPrices(uint256 price, uint256 discountPrice) public onlyOwner
    {
        require(price >= 0, "Price should be greater than or equal to 0.");
        require(discountPrice >= 0, "Discount price should be greater than or equal to 0.");
        if(mintPhase.current() < 2)
            initialMintPrice = price * (0.001 ether);
        else
            finalMintPrice = price * (0.001 ether);

        discountedMintPrice = price * (0.001 ether);
    }

    /*
     * @author sets baseURIOverride with given uri
     */
    function setBaseURI(string memory uri) public onlyOwner
    {
        baseURIOverride = uri;
        emit BaseURIChanged(baseURIOverride);
    }

    /*
     * @author sets ignoreDiscountWhitelist flag
     */
    function setIgnoreDiscountFlag(bool shouldIgnore) public onlyOwner
    {
        ignoreDiscountWhitelist = shouldIgnore;
    }

    function setContracts(address tournamentContract, address consumableContract, address marketplaceContract) public onlyOwner {
        dogeChampionsTournament = ITournament(tournamentContract);
        dogeChampionsConsumable = DogeChampionsConsumable(consumableContract);
        marketplaceAddress = marketplaceContract;
    }

    /*
     * @author sets availability flag of public mint. If set to false, nobody can mint NFTs
     */
    function setMintAvailability(bool isAvailable) public onlyOwner
    {
        isMintAvailable = isAvailable;
    }

    /*
     * @author sets number of free mints for given user into collaborator whitelist map
     */
    function setAddressToCollaboratorWhitelist(address walletAddress, uint256 amount) public onlyOwner
    {
        collaboratorWhitelist[walletAddress] = amount;
    }

    /*
     * @author puts given user into presale whitelist map according to mint phase
     */
    function setAddressToDiscountWhitelist(address walletAddress, uint256 amount) public onlyOwner
    {
        if(mintPhase.current() < 2){
            initialMintDiscountWhitelist[walletAddress] = amount;
        }else {
            finalMintDiscountWhitelist[walletAddress] = amount;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ITournament
{
    /*
     * @author data model for tournaments
     */
    struct Tournament
    {
        uint256 tournamentId;
        uint256 endTimestamp;
        uint256 tournamentType;
        uint256[4] elements;
        bool isPaid;
        uint256 rewardId;
    }

    /*
     * @author sets reward count for winner
     */
    function setWinnerRewardCount(uint256 count) external;

    /*
     * @author sets reward count for participation
     */
    function setParticipationRewardCount(uint256 count) external;

    /*
     * @author sets target NFT contract address
     */
    function setNFTContract(address contractAddress) external;

    /*
     * @author sets target consumable / collectible contract address
     */
    function setConsumableContract(address contractAddress) external;

    /*
     * @author sets entrance fee for paid BNB tournaments
     */
    function setPaidTournamentEntranceFee(uint256 fee) external;

    /*
     * @author registers given tokenIds to given tournament
     */
    function register(uint256 tournamentId, uint256[4] memory tokenIds) external payable;

    /*
     * @author sets new tournament
     */
    function setTournament(uint256 endTimestamp, uint256 tournamentType, uint256[4] memory elements, bool isPaid, uint256 rewardId) external;

    /*
     * @author finalizes latest ended tournament
     */
    function endCurrentTournament() external;

    /*
     * @author returns contract balance
     */
    function getContractBalance() external view returns(uint256);

    /*
     * @author returns active tournaments
     */
    function getActiveTournaments() external view returns(Tournament[] memory);

    /*
     * @author returns latest n ended tournaments
     */
    function getLatestEndedTournaments() external view returns(Tournament[] memory, address[] memory);

    /*
     * @author returns tournament of given tournamentId
     */
    function getTournament(uint256 tournamentId) external view returns(Tournament memory);

    /*
     * @author returns tournament winner of given tournamentId
     */
    function getTournamentWinner(uint256 tournamentId) external view returns(address);

    /*
     * @author returns current tournament
     */
    function getCurrentTournament() external view returns(Tournament memory);

    /*
     * @author returns paid tournament entrance fee
     */
    function getPaidTournamentEntryFee() external view returns(uint256);

    /*
     * @author returns participant count of given tournamentId
     */
    function getParticipantCount(uint256 tournamentId) external view returns(uint256);

    /*
     * @author returns rewards for given wallet address
     */
    function getRewards(address walletAddress) external view returns(uint256[] memory);

    /*
     * @author returns if user is joined to given tournamentId or not
     */
    function getIsJoined(uint256 tournamentId, address walletAddress) external view returns(bool);

    /*
     * @author decreases rewards for given wallet address
     */
    function decreaseReward(uint256 tournamentType, address walletAddress) external;

    /*
     * @author decreases consumable rewards for given wallet address
     */
    function decreaseConsumableReward(uint256 amount, address walletAddress) external;
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
pragma solidity ^0.8.0;

contract KeeperBase {
  error OnlySimulatedBackend();

  /**
   * @notice method that allows it to be simulated via eth_call by checking that
   * the sender is the zero address.
   */
  function preventExecution() internal view {
    if (tx.origin != address(0)) {
      revert OnlySimulatedBackend();
    }
  }

  /**
   * @notice modifier that allows it to be simulated via eth_call by checking
   * that the sender is the zero address.
   */
  modifier cannotExecute() {
    preventExecution();
    _;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface KeeperCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easily be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity ^0.8.0;

import "../ERC721Upgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStorageUpgradeable is Initializable, ERC721Upgradeable {
    function __ERC721URIStorage_init() internal onlyInitializing {
    }

    function __ERC721URIStorage_init_unchained() internal onlyInitializing {
    }
    using StringsUpgradeable for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721Upgradeable.sol";
import "./IERC721EnumerableUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721EnumerableUpgradeable is Initializable, ERC721Upgradeable, IERC721EnumerableUpgradeable {
    function __ERC721Enumerable_init() internal onlyInitializing {
    }

    function __ERC721Enumerable_init_unchained() internal onlyInitializing {
    }
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC721Upgradeable) returns (bool) {
        return interfaceId == type(IERC721EnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Upgradeable.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721EnumerableUpgradeable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721Upgradeable.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721Upgradeable.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[46] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "contracts/ITournament.sol";

contract DogeChampionsConsumable is Initializable, ERC1155Upgradeable, OwnableUpgradeable
{
    uint256 private constant ATTACK_NORMAL = 0;
    uint256 private constant DEFENSE_NORMAL = 1;
    uint256 private constant CRT_NORMAL = 2;
    uint256 private constant ATTACK_PREMIUM = 3;
    uint256 private constant DEFENSE_PREMIUM = 4;
    uint256 private constant CRT_PREMIUM = 5;

    mapping(uint256 => uint256) private bundleIdToBundle;
    mapping(uint256 => uint256) private bundleIdToPrice;

    uint256 private premiumPrice;

    address private marketplaceAddress;

    bool private areBundlesAvailable;

    ITournament private dogeChampionsTournament;
    address private dogeChampionsNFTContractAddress;
    mapping(address => bool) public dogeChampionsProtocolMap;

    // events related fields

    bool isConsumeFrenzyEventActive;
    uint256 activeConsumeFrenzyEventId;
    uint256 consumeFrenzyEventEntranceCount;
    uint256 consumeFrenzyEventRewardCount;
    mapping(uint256 => mapping(address => uint256)) userToUsedConsumable;

    bool isPremiumEventActive;
    uint256 premiumEventEntranceCount;
    uint256 premiumEventRewardCount;

    /*
     * @author modifier that prevents calls from addresses rather than DogeChampionsNFT contract
     */
    modifier onlyDogeChampionsNFT
    {
        require(msg.sender == dogeChampionsNFTContractAddress, "Only DogeChampionsNFT contract can access this function.");
        _;
    }

    /*
     * @author modifier that prevents calls from addresses rather than DogeChampionsNFT contract
     */
    modifier onlyDogeChampionsProtocols
    {
        require(dogeChampionsProtocolMap[msg.sender], "Only DogeChampions protocols can access this function.");
        _;
    }

    /*
     * @author plain good old constructor
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor()
    {
        _disableInitializers();
    }

    function initialize() initializer public {
        __ERC1155_init("ipfs://QmesZgjyaa4R1Jm88XtBzXB7BE77zQVc4bMrT8mHbqYj1D/{id}.json");
        __Ownable_init();

        // mint 20 unit from each consumable type to deployer for testing purposes on production
        _mint(msg.sender, ATTACK_NORMAL, 20, "");
        _mint(msg.sender, DEFENSE_NORMAL, 20, "");
        _mint(msg.sender, CRT_NORMAL, 20, "");
        _mint(msg.sender, ATTACK_PREMIUM, 20, "");
        _mint(msg.sender, DEFENSE_PREMIUM, 20, "");
        _mint(msg.sender, CRT_PREMIUM, 20, "");

        bundleIdToBundle[0] = 5;
        bundleIdToPrice[0] = 0.25 ether;

        bundleIdToBundle[1] = 10;
        bundleIdToPrice[1] = 2 ether;

        bundleIdToBundle[2] = 20;
        bundleIdToPrice[2] = 3 ether;

        bundleIdToBundle[3] = 30;
        bundleIdToPrice[3] = 4 ether;

        bundleIdToBundle[4] = 40;
        bundleIdToPrice[4] = 5 ether;

        areBundlesAvailable = false;

        isConsumeFrenzyEventActive = false;
        isPremiumEventActive = false;

        activeConsumeFrenzyEventId = 0;

        premiumPrice = 0.1 ether;
    }

    /*
     * @author sets marketplace contract related fields
     */
    function setMarketplaceContractAddress(address contractAddress) public onlyOwner
    {
        marketplaceAddress = contractAddress;
    }

    /*
     * @author sets tournament contract related fields
     */
    function setTournamentContract(address contractAddress) public onlyOwner
    {
        dogeChampionsTournament = ITournament(contractAddress);
    }

    /*
     * @author sets DogeChampionsNFT contract related fields
     */
    function setNFTContract(address contractAddress) public onlyOwner
    {
        dogeChampionsNFTContractAddress = contractAddress;
    }

    /*
     * @author sets DogeChampionsProtocol map state
     */
    function setStakeProtocolContract(address contractAddress, bool value) public onlyOwner
    {
        dogeChampionsProtocolMap[contractAddress] = value;
    }

    /*
     * @author sets premium consumable price. Send x1000 higher value for price in parameter.
     */
    function setPremiumPrice(uint256 price) public onlyOwner
    {
        require(price >= 0, "Price should be greater than or equal to 0.");
        premiumPrice = price * (0.001 ether);
    }

    /*
     * @author mints random consumables to user if he / she has enough consumable reward
     */
    function mint(uint256 amount) public 
    {
        uint256[] memory rewards = dogeChampionsTournament.getRewards(msg.sender);
        require(rewards[5] >= amount, "You don't have enough Consumable rewards.");

        for(uint256 i = 0; i < amount; i++)
        {
            uint256 tokenId = calculateConsumableType(i + 1 + amount);
            _mint(msg.sender, tokenId, 1, "");
        }

        dogeChampionsTournament.decreaseConsumableReward(amount, msg.sender);

        setApprovalForAll(marketplaceAddress, true);
    }

    /*
     * @author mints given premium consumable to user for a price
     */
    function premiumMint(uint256 tokenId, uint256 amount) public payable
    {
        require(tokenId > 2 && tokenId < 6, "There is no such premium consumable type.");
        require(msg.value == premiumPrice * amount, "Please send exact price.");

        _mint(msg.sender, tokenId, amount, "");

        payable(owner()).transfer(msg.value);

        setApprovalForAll(marketplaceAddress, true);
    }

    /*
     * @author mints given bundle
     */
    function bundleMint(uint256 tokenId, uint256 bundleId) public payable
    {
        require(areBundlesAvailable == true, "Bundle sales are closed.");
        require(tokenId > 2 && tokenId < 6, "There is no such premium consumable type.");
        require(bundleId >= 0 && bundleId < 5, "There are only 5 bundles.");
        require(msg.value == bundleIdToPrice[bundleId], "Please send exact price.");

        _mint(msg.sender, tokenId, bundleIdToBundle[bundleId], "");

        payable(owner()).transfer(msg.value);

        setApprovalForAll(marketplaceAddress, true);
    }

    /*
     * @author mints consume frenzy event reward
     */
    function consumeFrenzyEventMint(uint256 premiumTokenId) public
    {
        require(isConsumeFrenzyEventActive == true, "Consume frenzy event is not active.");
        require(premiumTokenId >= 3 && premiumTokenId < 6, "There is no such premium type.");
        require(userToUsedConsumable[activeConsumeFrenzyEventId][msg.sender] >= consumeFrenzyEventEntranceCount, "Not enough consumables.");

        _mint(msg.sender, premiumTokenId, consumeFrenzyEventRewardCount, "");
        userToUsedConsumable[activeConsumeFrenzyEventId][msg.sender] = userToUsedConsumable[activeConsumeFrenzyEventId][msg.sender] - consumeFrenzyEventEntranceCount;
    }

    /*
     * @author mints premium consumable from premium event
     */
    function premiumEventMint(uint256 consumableId) public
    {
        require(isPremiumEventActive == true, "Premium event is not active.");
        require(consumableId >= 0 && consumableId < 3, "There is no such consumable type.");
        require(balanceOf(msg.sender, consumableId) >= premiumEventEntranceCount, "Not enough consumables.");

        _burn(msg.sender, consumableId, premiumEventEntranceCount);
        _mint(msg.sender, consumableId + 3, premiumEventRewardCount, "");
    }

    /*
     * @author mints consumable as rewards of DogeChampions playable content
     */
    function rewardMint(address walletAddress, uint256 amount, bool isPremium) public onlyDogeChampionsProtocols
    {
        if(isPremium)
        {
            _mint(walletAddress, calculateConsumableType(block.timestamp) + 3, amount, "");
        }
        else
        {
            _mint(walletAddress, calculateConsumableType(block.timestamp) + 3, amount, "");
        }
        
    }

    /*
     * @author burns consumable after user uses it onto a Doge Champion
     */
    function burn(uint256 tokenId, address walletAddress) public onlyDogeChampionsNFT
    {
        if(isConsumeFrenzyEventActive)
        {
            userToUsedConsumable[activeConsumeFrenzyEventId][walletAddress] = userToUsedConsumable[activeConsumeFrenzyEventId][walletAddress] + 1;
        }

        _burn(walletAddress, tokenId, 1);
    }

    /*
     * @author sets bundle availability
     */
    function setBundlesAvailability(bool isAvailable) public onlyOwner
    {
        areBundlesAvailable = isAvailable;
    }

    /*
     * @author sets consume frenzy event state
     */
    function setConsumeFrenzyEventState(bool isActive) public onlyOwner
    {
        require(isConsumeFrenzyEventActive != isActive, "State is the same.");
        isConsumeFrenzyEventActive = isActive;
        if(!isActive)
        {
            activeConsumeFrenzyEventId = activeConsumeFrenzyEventId + 1;
        }
    }

    /*
     * @author sets premium event state
     */
    function setPremiumEventState(bool isActive) public onlyOwner
    {
        isPremiumEventActive = isActive;
    }

    /*
     * @author sets consume frenzy event data
     */
    function setConsumeFrenzyEventData(uint256 entranceCount, uint256 rewardCount) public onlyOwner
    {
        consumeFrenzyEventEntranceCount = entranceCount;
        consumeFrenzyEventRewardCount = rewardCount;
    }

    /*
     * @author sets premium event data
     */
    function setPremiumEventData(uint256 entranceCount, uint256 rewardCount) public onlyOwner
    {
        premiumEventEntranceCount = entranceCount;
        premiumEventRewardCount = rewardCount;
    }

    /*
     * @author sets bundle amount and price of given bundle Id. Send bundle price x1000 of the value.
     */
    function setBundleDetails(uint256 bundleId, uint256 bundleAmount, uint256 bundlePrice) public onlyOwner
    {
        require(bundleId >= 0 && bundleId < 5, "There are only 5 bundles.");
        bundleIdToBundle[bundleId] = bundleAmount;
        bundleIdToBundle[bundleId] = bundlePrice * (0.001 ether);
    }

    /*
     * @author returns user progress for consume frenzy event
     */
    function getConsumeFrenzyEventProgress() public view returns(uint256 progress, uint256)
    {
        return (userToUsedConsumable[activeConsumeFrenzyEventId][msg.sender], consumeFrenzyEventEntranceCount);
    }

    /*
     * @author helper function to determine consumable type randomly
     */
    function calculateConsumableType(uint256 nonce) internal view returns(uint256)
    {
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % 3;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721Upgradeable.sol";
import "./IERC721ReceiverUpgradeable.sol";
import "./extensions/IERC721MetadataUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../utils/StringsUpgradeable.sol";
import "../../utils/introspection/ERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[44] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721Upgradeable.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721EnumerableUpgradeable is IERC721Upgradeable {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;

import "./IERC1155Upgradeable.sol";
import "./IERC1155ReceiverUpgradeable.sol";
import "./extensions/IERC1155MetadataURIUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../utils/introspection/ERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC1155Upgradeable, IERC1155MetadataURIUpgradeable {
    using AddressUpgradeable for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    function __ERC1155_init(string memory uri_) internal onlyInitializing {
        __ERC1155_init_unchained(uri_);
    }

    function __ERC1155_init_unchained(string memory uri_) internal onlyInitializing {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC1155Upgradeable).interfaceId ||
            interfaceId == type(IERC1155MetadataURIUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[47] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../IERC1155Upgradeable.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURIUpgradeable is IERC1155Upgradeable {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}