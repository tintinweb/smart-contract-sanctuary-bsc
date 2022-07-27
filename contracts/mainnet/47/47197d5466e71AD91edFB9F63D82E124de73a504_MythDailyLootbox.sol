// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;
import "ERC20.sol";

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

contract MythProfiles {
    //mapping from address to string nickname

    address public owner;
    mapping(address => string) public mythNickNames;
    mapping(address => string) public mythPFPUrl;
    //mapping from string to true/false
    mapping(string => bool) public activeNickNames;
    mapping(string => bool) public takenAffiliateCodeNames;
    mapping(string => address) public addressOfAffiliateCodeNames;
    mapping(address => string) public codeNameFromAddress;
    mapping(address => address) public affiliateAddress;
    mapping(address => bool) public partnerAddress;
    mapping(address => bool) public identityBlacklist;
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this action");
        _;
    }

    constructor() {
        owner = msg.sender;
        mythNickNames[address(0)] = "BOB";
        mythPFPUrl[
            address(0)
        ] = "https://imgs.search.brave.com/7VYNMq4_ZlrBRj-aejnye5b_4Y0NX813goCpglRRHJM/rs:fit:570:640:1/g:ce/aHR0cHM6Ly9tZWxt/YWdhemluZS5jb20v/d3AtY29udGVudC91/cGxvYWRzLzIwMjEv/MDEvNjZmLTEtNTcw/eDY0MC5qcGc";
    }

    function updateBob(string calldata _url, string calldata _name)
        external
        onlyOwner
    {
        mythNickNames[address(0)] = _name;
        mythPFPUrl[address(0)] = _url;
    }

    function setPFPUrl(string calldata url) external {
        require(identityBlacklist[msg.sender] == false, "You cannot set a pfp");
        mythPFPUrl[msg.sender] = url;
    }

    //read only function to recieve affiliate percent
    function getAffiliatePercent(address _address) public view returns (bool) {
        return partnerAddress[affiliateAddress[_address]];
    }

    function setPFPUrlOverride(string calldata url, address _address)
        external
        onlyOwner
    {
        identityBlacklist[_address] = true;
        mythPFPUrl[_address] = url;
    }

    //function that allows a user to set their affiliate address
    function setAffiliate(address _address) external {
        affiliateAddress[msg.sender] = _address;
    }

    function setAffiliateByName(string calldata codeName) external {
        require(
            addressOfAffiliateCodeNames[codeName] != address(0),
            "CodeName Doesnt Exist"
        );
        affiliateAddress[msg.sender] = addressOfAffiliateCodeNames[codeName];
    }

    function setCodeName(string calldata codeName) external {
        require(
            takenAffiliateCodeNames[codeName] == false,
            "Name already used"
        );

        delete takenAffiliateCodeNames[codeNameFromAddress[msg.sender]];
        delete addressOfAffiliateCodeNames[codeNameFromAddress[msg.sender]];
        codeNameFromAddress[msg.sender] = codeName;

        takenAffiliateCodeNames[codeName] = true;
        addressOfAffiliateCodeNames[codeName] = msg.sender;
    }

    function updatePartner(address _address) external onlyOwner {
        partnerAddress[_address] = !partnerAddress[_address];
    }

    //function that allows users to set a new nickname for their address
    function setNickName(string memory _newName) external {
        require(activeNickNames[_newName] == false, "Name already used");
        activeNickNames[_newName] = true;
        activeNickNames[mythNickNames[msg.sender]] = false;
        mythNickNames[msg.sender] = _newName;
    }
}

///////////////////////////    WHITE LIST
///////////////////////////    WHITE LIST
///////////////////////////    WHITE LIST

contract MythWhiteList {
    //This contract is the Liquidity Pool, the balance of this SC is the LP

    //mapping from address to true/false (whitelisted)
    mapping(address => bool) public dailyCaseAddresses;
    //mapping from user address to affiliate address
    mapping(address => bool) public resolveableAddresses;
    mapping(address => uint256) public rewardBalances;
    mapping(uint256 => mapping(address => uint256))
        public lootboxCountersBalance;

    mapping(address => uint256) public totalBetsPlaced;
    mapping(address => uint256) public totalClaimedRewards;
    mapping(address => uint256) public previousBlockClaimed;

    uint256 public bobBalance;
    //myth contract
    MythLP public mythLPContract;
    Utilitytoken public mythContract;
    MythProfiles public mythProfiles;
    uint256 public maxBet = 0 * 10**17;
    uint256 public minBet = 1 * 10**16;
    uint256 public dailyBlockTime = 28800;
    //contract name
    string public name = "Myth WhiteList";
    //owner address
    address payable public owner;
    address public marketingWallet;
    bool public paused;
    uint256 public gameCount;
    mapping(uint256 => gameStruct) public placedGameLobby;
    mapping(uint256 => uint256) public gameCountsPerBlock;
    mapping(uint256 => mapping(uint256 => uint256))
        public gameIdOfBlockNumberAndBlockNonce;
    mapping(uint256 => bool) public resolvedBlocks;

    event gameLobbyCreated(
        address gameCreator,
        address lootboxAddress,
        uint256 gameID,
        uint256 gameCost,
        uint256 initializationBlock,
        string gameCreatorNickName,
        RoundType roundType,
        uint8 creatorSide
    );

    event claimedWinnings(address claimer, uint256 claimedAmount);
    event lootboxReward(address winner, uint256 lootboxID, uint256 amount);

    event gameLobbyCalled(
        address gameCaller,
        uint256 gameID,
        uint256 initializationBlock,
        string gameCallerNickName
    );

    event gameLobbyResolved(
        bytes32 resolutionSeed,
        bool creatorWinner,
        uint256 gameWinnings,
        uint256 gameID,
        uint256 rolledTicket
    );

    event dailyCaseAdded(address _address, string _name, uint256 _minPlaced);

    event dailyPrizeAdded(
        address _address,
        uint256 _lowTicket,
        uint256 _highTicket,
        uint256 _caseID,
        uint256 _prizeAmount
    );
    event gameLobbyCancelled(uint256 gameID);
    event depositBobBalance(uint256 amount);
    event withdrawBobBalance(uint256 amount);

    enum RoundState {
        PLACED,
        INITIALIZED,
        RESOLVED,
        CANCELLED
    }
    enum RoundType {
        COINFLIP,
        DICEDUEL,
        DEATHROLL,
        DAILY
    }

    struct roundStruct {
        uint8 betterSide;
        address resolutionScript;
        uint256 roundCost;
        uint256 betterWinnings;
        uint256 callerWinnings;
    }

    struct gameStruct {
        bool creatorWinner;
        RoundState roundState;
        RoundType roundType;
        address creator;
        address caller;
        address lootboxAddress;
        uint256 blockNumberInitialized;
        bytes32 resolutionSeed;
        uint256 gameCost;
        uint8 creatorSide;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this action");
        _;
    }
    modifier notPaused() {
        require(paused == false, "Initializing Lobbys is paused");
        _;
    }

    //constructor
    constructor() {
        resolveableAddresses[msg.sender] = true;
        owner = payable(msg.sender);
        marketingWallet = msg.sender;
    }

    function viewFreeCases(uint256 _caseId, address _address)
        external
        view
        returns (uint256)
    {
        return lootboxCountersBalance[_caseId][_address];
    }

    function editResolver(address _address) external onlyOwner {
        resolveableAddresses[_address] = !resolveableAddresses[_address];
    }

    function setPause(bool _paused) external onlyOwner {
        paused = _paused;
    }

    function changeMaxBet(uint256 _amount) external onlyOwner {
        maxBet = _amount;
    }

    function changeTotalBetsPlaced(uint256 _amount, address _address)
        external
        onlyOwner
    {
        totalBetsPlaced[_address] = _amount;
    }

    function changeMinBet(uint256 _amount) external onlyOwner {
        minBet = _amount;
    }

    function changeDailyBlock(uint256 _amount) external onlyOwner {
        dailyBlockTime = _amount;
    }

    function giveFreeLootbox(
        address _address,
        uint256 _caseId,
        uint256 _amount
    ) external onlyOwner {
        emit lootboxReward(_address, _caseId, _amount);
        lootboxCountersBalance[_caseId][_address] += _amount;
    }

    function blocksLeftForDaily(address _address)
        external
        view
        returns (uint256)
    {
        return block.number - previousBlockClaimed[_address];
    }

    //Function to claim winnings
    function withdrawWinnings() external payable {
        require(msg.value == 0, "Dont send bnb");
        require(
            rewardBalances[msg.sender] <= address(this).balance &&
                rewardBalances[msg.sender] > 0,
            "Smart Contract Doesnt have enough funds"
        );
        uint256 rewardsForPlayer = rewardBalances[msg.sender];
        rewardBalances[msg.sender] = 0;
        uint256 rewardPerCent = ((rewardsForPlayer -
            (rewardsForPlayer % 10000)) / 100);
        (bool successUser, ) = msg.sender.call{value: (rewardPerCent * 95)}("");
        require(successUser, "Transfer to user failed");
        mythLPContract.recieve{value: (rewardPerCent * 5)}();
        bool successMyth = mythContract.mintMythForRewards(
            rewardsForPlayer,
            msg.sender
        );
        require(successMyth, "Myth Minted");
        // event to show address claimed amount
        emit claimedWinnings(msg.sender, rewardPerCent * 95);
        totalClaimedRewards[msg.sender] += rewardPerCent * 95;
    }

    function resolveCoinFlip(
        bytes32 _resolutionSeed,
        uint8 _side,
        uint256 _nonce1
    ) public pure returns (bool) {
        uint8 roll = uint8(
            uint256(keccak256(abi.encodePacked(_resolutionSeed, _nonce1))) % 2
        );
        return roll == _side;
    }

    function resolveDiceDuel(
        bytes32 _resolutionSeed,
        uint8 _side,
        uint256 _nonce1
    ) public pure returns (bool) {
        uint256 localNonce = 0;
        uint256 rollBetter1 = 0;
        uint256 rollBetter2 = 0;
        uint256 rollCaller1 = 0;
        uint256 rollCaller2 = 0;
        while (true) {
            rollBetter1 =
                (uint256(
                    keccak256(
                        abi.encodePacked(
                            _resolutionSeed,
                            _nonce1,
                            localNonce + 1
                        )
                    )
                ) % 6) +
                1;
            rollBetter2 =
                (uint256(
                    keccak256(
                        abi.encodePacked(
                            _resolutionSeed,
                            _nonce1,
                            localNonce + 2
                        )
                    )
                ) % 6) +
                1;
            rollCaller1 =
                (uint256(
                    keccak256(
                        abi.encodePacked(
                            _resolutionSeed,
                            _nonce1,
                            localNonce + 3
                        )
                    )
                ) % 6) +
                1;
            rollCaller2 =
                (uint256(
                    keccak256(
                        abi.encodePacked(
                            _resolutionSeed,
                            _nonce1,
                            localNonce + 4
                        )
                    )
                ) % 6) +
                1;

            if (rollBetter1 + rollBetter2 == rollCaller1 + rollCaller2) {
                localNonce += 4;
            } else {
                if (_side == 0) {
                    return
                        rollBetter1 + rollBetter2 > rollCaller1 + rollCaller2;
                } else {
                    return
                        rollCaller1 + rollCaller2 > rollBetter1 + rollBetter2;
                }
            }
        }
        return false;
    }

    function resolveDeathRoll(
        bytes32 _resolutionSeed,
        uint8 _side,
        uint256 _nonce1
    ) public pure returns (bool) {
        uint256 localNonce = 0;
        uint256 currentNumber = 1000;
        while (true) {
            uint256 roll = uint256(
                keccak256(
                    abi.encodePacked(_resolutionSeed, _nonce1, localNonce)
                )
            ) % currentNumber;
            localNonce++;
            if (roll == 0) {
                break;
            } else {
                currentNumber = roll;
            }
        }
        return (localNonce + _side) % 2 == 0;
    }

    function getRoll(bytes32 _resolutionSeed, uint256 _nonce1)
        external
        view
        returns (uint256)
    {
        return
            uint256(keccak256(abi.encodePacked(_resolutionSeed, _nonce1))) %
            100;
    }

    function resolveLootBox(
        bytes32 _resolutionSeed,
        uint256 _nonce1,
        address _lootboxAddress,
        address _opener
    ) internal returns (uint256) {
        uint256 _roll = uint256(
            keccak256(abi.encodePacked(_resolutionSeed, _nonce1))
        ) % 100;
        (uint256 _lootboxID, uint256 _prizeCount) = MythDailyLootbox(
            _lootboxAddress
        ).getWinningPrize(_roll);
        //event to show address won lootbox ID X amount
        lootboxCountersBalance[_lootboxID][_opener] += _prizeCount;
        emit lootboxReward(_opener, _lootboxID, _prizeCount);
        return _roll;
    }

    function withdrawFunds(uint256 _amount) external onlyOwner {
        owner.transfer(_amount);
    }

    function initializeGameLobby(
        bool _pvp,
        uint8 _side,
        address _gameAddresses,
        uint8 _gameType
    ) external payable notPaused returns (bool) {
        require(_gameType >= 0 && _gameType <= 3, "Set appropriate game type");
        if (_gameType != uint8(RoundType.DAILY)) {
            require(msg.value >= minBet, "Bet Must be above minimum bet");
        } else {
            require(
                block.number - previousBlockClaimed[msg.sender] >
                    dailyBlockTime,
                "Need to wait to claim daily case"
            );
            require(
                MythDailyLootbox(_gameAddresses).minPlaced() <=
                    totalBetsPlaced[msg.sender],
                "Not enough wagered"
            );
            previousBlockClaimed[msg.sender] = block.number;
        }
        if (!_pvp) {
            require(bobBalance >= msg.value, "Bob doesnt have enough");
            require(msg.value <= maxBet, "Bet is above Max Bet");
        }
        uint256 _gameCount = gameCount;
        placedGameLobby[_gameCount].creator = msg.sender;
        if (_gameType == 0) {
            placedGameLobby[_gameCount].roundType = RoundType.COINFLIP;
        } else if (_gameType == 1) {
            placedGameLobby[_gameCount].roundType = RoundType.DICEDUEL;
        } else if (_gameType == 2) {
            placedGameLobby[_gameCount].roundType = RoundType.DEATHROLL;
        } else if (_gameType == 3) {
            require(
                dailyCaseAddresses[_gameAddresses],
                "Daily case not available"
            );
            gameIdOfBlockNumberAndBlockNonce[block.number][
                gameCountsPerBlock[block.number]
            ] = _gameCount;
            gameCountsPerBlock[block.number] += 1;
            placedGameLobby[_gameCount].roundState = RoundState.INITIALIZED;
            placedGameLobby[_gameCount].blockNumberInitialized = block.number;
            placedGameLobby[_gameCount].roundType = RoundType.DAILY;
            placedGameLobby[_gameCount].lootboxAddress = _gameAddresses;
        }
        placedGameLobby[_gameCount].gameCost = msg.value;
        placedGameLobby[_gameCount].creatorSide = _side;
        if (!_pvp) {
            totalBetsPlaced[msg.sender] += msg.value;
            gameIdOfBlockNumberAndBlockNonce[block.number][
                gameCountsPerBlock[block.number]
            ] = _gameCount;
            gameCountsPerBlock[block.number] += 1;
            bobBalance -= msg.value;
            placedGameLobby[_gameCount].roundState = RoundState.INITIALIZED;
            placedGameLobby[_gameCount].blockNumberInitialized = block.number;
        }
        // event to show game lobby placed
        emit gameLobbyCreated(
            msg.sender,
            _gameAddresses,
            _gameCount,
            msg.value,
            placedGameLobby[_gameCount].blockNumberInitialized,
            mythProfiles.mythNickNames(msg.sender),
            placedGameLobby[_gameCount].roundType,
            _side
        );
        // creator address, bet type, block number initialized, game id, lootbox address,
        gameCount++;
        return true;
    }

    function callBob(uint256 _gameId) external {
        require(
            placedGameLobby[_gameId].creator == msg.sender,
            "Only better can call Bob"
        );
        require(
            placedGameLobby[_gameId].roundState == RoundState.PLACED,
            "Only placed Games can be called"
        );
        require(
            placedGameLobby[_gameId].gameCost <= bobBalance,
            "Bob doesn't have enough to cover bet"
        );
        require(
            placedGameLobby[_gameId].gameCost <= maxBet,
            "Bet is above Max Bet"
        );
        //event game
        emit gameLobbyCalled(
            address(0),
            _gameId,
            block.number,
            mythProfiles.mythNickNames(address(0))
        );
        bobBalance -= placedGameLobby[_gameId].gameCost;
        placedGameLobby[_gameId].roundState = RoundState.INITIALIZED;
        placedGameLobby[_gameId].blockNumberInitialized = block.number;
        gameIdOfBlockNumberAndBlockNonce[block.number][
            gameCountsPerBlock[block.number]
        ] = _gameId;
        gameCountsPerBlock[block.number] += 1;
        totalBetsPlaced[msg.sender] += placedGameLobby[_gameId].gameCost;
    }

    function callBet(uint256 _gameId) external payable {
        require(
            placedGameLobby[_gameId].roundState == RoundState.PLACED,
            "Only placed Games can be called"
        );
        require(
            placedGameLobby[_gameId].gameCost == msg.value,
            "Send exact Game Cost"
        );
        //event game id, address caller, block number,
        emit gameLobbyCalled(
            msg.sender,
            _gameId,
            block.number,
            mythProfiles.mythNickNames(msg.sender)
        );
        placedGameLobby[_gameId].caller = msg.sender;
        placedGameLobby[_gameId].roundState = RoundState.INITIALIZED;
        placedGameLobby[_gameId].blockNumberInitialized = block.number;
        gameIdOfBlockNumberAndBlockNonce[block.number][
            gameCountsPerBlock[block.number]
        ] = _gameId;
        gameCountsPerBlock[block.number] += 1;
        totalBetsPlaced[msg.sender] += msg.value;
        totalBetsPlaced[placedGameLobby[_gameId].creator] += msg.value;
    }

    function resolveBlock(uint256 _blockNumber, bytes32 _resolutionSeed)
        external
    {
        require(
            resolveableAddresses[msg.sender],
            "only dedicated resolvers can resolve blocks"
        );
        require(
            resolvedBlocks[_blockNumber] == false,
            "Block Number Already Resolved"
        );

        uint256 gameCountOfBlock = gameCountsPerBlock[_blockNumber];
        uint256 counter = 0;

        while (counter < gameCountOfBlock) {
            uint256 rolledTicket = 0;
            uint256 _currentGameID = gameIdOfBlockNumberAndBlockNonce[
                _blockNumber
            ][counter];
            gameStruct memory currentGame = placedGameLobby[_currentGameID];
            if (currentGame.roundState != RoundState.INITIALIZED) {
                continue;
            }
            currentGame.resolutionSeed = _resolutionSeed;
            if (currentGame.roundType == RoundType.COINFLIP) {
                currentGame.creatorWinner = resolveCoinFlip(
                    _resolutionSeed,
                    currentGame.creatorSide,
                    _currentGameID
                );
            } else if (currentGame.roundType == RoundType.DICEDUEL) {
                currentGame.creatorWinner = resolveDiceDuel(
                    _resolutionSeed,
                    currentGame.creatorSide,
                    _currentGameID
                );
            } else if (currentGame.roundType == RoundType.DEATHROLL) {
                currentGame.creatorWinner = resolveDeathRoll(
                    _resolutionSeed,
                    currentGame.creatorSide,
                    _currentGameID
                );
            }

            if (currentGame.roundType == RoundType.DAILY) {
                rolledTicket = resolveLootBox(
                    _resolutionSeed,
                    _currentGameID,
                    currentGame.lootboxAddress,
                    currentGame.creator
                );
            } else {
                if (currentGame.creatorWinner) {
                    rewardBalances[currentGame.creator] +=
                        currentGame.gameCost *
                        2;
                } else {
                    if (currentGame.caller != address(0)) {
                        rewardBalances[currentGame.caller] +=
                            currentGame.gameCost *
                            2;
                    } else {
                        bobBalance += currentGame.gameCost * 2;
                    }
                }
            }
            //event game id, better winner, resolutionSeed, ticketRolled
            emit gameLobbyResolved(
                _resolutionSeed,
                currentGame.creatorWinner,
                currentGame.gameCost * 2,
                _currentGameID,
                rolledTicket
            );
            currentGame.roundState = RoundState.RESOLVED;
            placedGameLobby[_currentGameID] = currentGame;
            counter++;
        }
        resolvedBlocks[_blockNumber] = true;
    }

    function cancelBet(uint256 _gameId) external payable {
        require(msg.value == 0, "Don't send money to cancel a bet");
        require(
            placedGameLobby[_gameId].roundState == RoundState.PLACED,
            "Only placed bets can be cancelled"
        );
        require(
            placedGameLobby[_gameId].creator == msg.sender,
            "Only the one who placed this bet can cancel it"
        );
        //event game id
        emit gameLobbyCancelled(_gameId);
        placedGameLobby[_gameId].roundState = RoundState.CANCELLED;
        (bool successUser, ) = msg.sender.call{
            value: placedGameLobby[_gameId].gameCost
        }("");
        require(successUser, "Transfer to user failed");
        emit gameLobbyCancelled(_gameId);
    }

    function depoBob() external payable onlyOwner {
        bobBalance += msg.value;
        emit depositBobBalance(msg.value);
        //event bob deposit
    }

    function withdrawBob(uint256 _amount) external onlyOwner {
        require(bobBalance >= _amount, "Bob does not have that much");
        bobBalance -= _amount;
        emit withdrawBobBalance(_amount);
        owner.transfer(_amount);
        //event bob withdrawn
    }

    function changeMarketingWallet(address _address) external onlyOwner {
        marketingWallet = _address;
    }

    function changeMythLPAddress(address _address) external onlyOwner {
        mythLPContract = MythLP(_address);
    }

    //function for the owner address to set address of myth erc20
    function setMythAddress(address _address) external onlyOwner {
        mythContract = Utilitytoken(_address);
    }

    function setProfilesAddress(address _profilesAddress) external onlyOwner {
        mythProfiles = MythProfiles(_profilesAddress);
    }

    //function that other SC call to send ETHER to the LP
    function recieve() external payable {}

    //function that simply returns Ether balance of this SC
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    //function that only owner can call. Adds address to whitelist, these will be the SC games made later on
    function addToDailyCaseList(address _address) external onlyOwner {
        require(
            !dailyCaseAddresses[_address],
            "This address is already whitelisted"
        );
        MythDailyLootbox _tempLootbox = MythDailyLootbox(_address);
        //event daily case added
        emit dailyCaseAdded(
            _address,
            _tempLootbox.name(),
            _tempLootbox.minPlaced()
        );
        for (uint256 i = 0; i < _tempLootbox.prizeCount(); i++) {
            MythDailyLootbox.prize memory _tempPrize = _tempLootbox.getPrize(i);
            emit dailyPrizeAdded(
                _address,
                _tempPrize.lowticket,
                _tempPrize.highticket,
                _tempPrize.lootboxID,
                _tempPrize.prizeCount
            );
        }
        dailyCaseAddresses[_address] = true;
    }

    //function that only owner can call. Removes address from whitelist, these will be the SC games made later on
    function removeFromDailyCaseList(address _address) external onlyOwner {
        require(
            dailyCaseAddresses[_address],
            "This address is already not whitelisted"
        );
        //event daily case removed
        dailyCaseAddresses[_address] = false;
    }
}

///////////////////////////    WHITE LIST
///////////////////////////    WHITE LIST
///////////////////////////    WHITE LIST

contract MythDailyLootbox {
    address public owner;
    string public name = "LEVEL 4 DAILY";
    uint256 public prizeCount;
    mapping(uint256 => prize) public prizes;
    uint256 public minPlaced = 5 * 10**18;
    struct prize {
        uint256 lowticket;
        uint256 highticket;
        uint256 lootboxID;
        uint256 prizeCount;
    }

    constructor() {
        owner = msg.sender;
        prizes[0] = prize(0, 24, 0, 0);
        prizes[1] = prize(25, 39, 1, 2);
        prizes[2] = prize(40, 54, 2, 1);
        prizes[3] = prize(55, 79, 2, 2);
        prizes[4] = prize(80, 90, 2, 3);
        prizes[5] = prize(91, 94, 3, 1);
        prizes[6] = prize(95, 97, 3, 2);
        prizes[7] = prize(98, 99, 4, 1);

        prizeCount = 8;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this action");
        _;
    }

    function changeMinPlaced(uint256 _amount) external onlyOwner {
        minPlaced = _amount;
    }

    function getPrize(uint256 _id) external view returns (prize memory) {
        return prizes[_id];
    }

    function getPrizes() external view returns (prize[8] memory) {
        prize[8] memory temp;
        temp[0] = prizes[0];
        temp[1] = prizes[1];
        temp[2] = prizes[2];
        temp[3] = prizes[3];
        temp[4] = prizes[4];
        temp[5] = prizes[5];
        temp[6] = prizes[6];
        temp[7] = prizes[7];

        return temp;
    }

    function getWinningPrize(uint256 _ticket)
        external
        view
        returns (uint256, uint256)
    {
        for (uint256 i = 0; i < prizeCount; i++) {
            if (
                prizes[i].lowticket <= _ticket &&
                prizes[i].highticket >= _ticket
            ) {
                return (prizes[i].lootboxID, prizes[i].prizeCount);
            }
        }
        return (0, 0);
    }
}

///////////////////////////     MYTH TOKEN
///////////////////////////     MYTH TOKEN
///////////////////////////     MYTH TOKEN
contract Utilitytoken is ERC20 {
    //This contract is the Myth Token ERC20
    //mapping from affiliate address to total rewards
    mapping(address => uint256) public totalAffiliateRewards;
    address payable public owner;
    address public owner2;
    address public marketingWallet;
    MythProfiles public mythProfiles;
    mapping(address => uint256) public totalMythMinted;
    mapping(address => uint256) public totalMythBurned;
    mapping(address => uint256) public totalMythMintedPerAddress;
    mapping(address => bool) public whitelistedAddresses;

    constructor(
        address _address,
        address _profileAddress,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        owner = payable(msg.sender);
        marketingWallet = msg.sender;
        mythProfiles = MythProfiles(_profileAddress);
        owner2 = msg.sender;
    }

    function changeProfilesAddress(address _address) external {
        require(msg.sender == owner, "Only owner");
        mythProfiles = MythProfiles(_address);
    }

    //This function can only be called by whitelisted address but not the owner
    function mint(address to, uint256 amount) external {
        require(
            whitelistedAddresses[msg.sender] == true && msg.sender != owner,
            "Only whitelisted address can mint tokens"
        );
        _mint(to, amount);
        totalMythMintedPerAddress[to] += amount;
        totalMythMinted[to] += amount;
    }

    function withdraw() external {
        require(msg.sender == owner, "Not owner");
        owner.transfer(address(this).balance);
    }

    function alterWhitelist(address _address) external {
        require(msg.sender == owner, "Not owner");
        whitelistedAddresses[_address] = !whitelistedAddresses[_address];
    }

    function recieve() external payable {}

    function changeMarketingWallet(address _address) external {
        require(
            msg.sender == owner,
            "Only the owner can change marketing Wallet"
        );
        marketingWallet = _address;
    }

    function setOwner2(address _address) external {
        require(
            msg.sender == owner,
            "Only the owner can change marketing Wallet"
        );
        owner2 = _address;
    }

    function mintMythForRewards(uint256 rewardAmount, address _address)
        external
        returns (bool)
    {
        require(
            whitelistedAddresses[msg.sender] == true && msg.sender != owner,
            "Only whitelisted addresses can mint bets"
        );
        uint256 mintUnit = SafeMath.div(rewardAmount, 1000);
        _mint(owner, mintUnit * 10);
        _mint(owner2, mintUnit * 10);
        uint256 marketShare = 10;
        if (mythProfiles.getAffiliatePercent(_address)) {
            _mint(_address, mintUnit * 6);
            _mint(mythProfiles.affiliateAddress(_address), mintUnit * 4);
        } else {
            _mint(_address, mintUnit * 5);
            marketShare += 5;
        }
        _mint(marketingWallet, mintUnit * marketShare);
        return true;
    }

    //This function can only be called by whitelisted address but not the owner
    function burn(address to, uint256 amount) external {
        require(
            whitelistedAddresses[msg.sender] == true && msg.sender != owner,
            "Only whitelisted address can burn tokens"
        );
        _burn(to, amount);
        totalMythBurned[to] += amount;
    }
}

///////////////////////////     MYTH TOKEN
///////////////////////////     MYTH TOKEN
///////////////////////////     MYTH TOKEN

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////// MYTH LP
/////////////////////////// MYTH LP
/////////////////////////// MYTH LP

contract MythLP {
    address public owner;

    //mapping from address to claimed bnb from lp
    mapping(address => uint256) public totalLPClaimed;
    Utilitytoken public mythContract;

    constructor(address _mythAddress) {
        owner = msg.sender;
        mythContract = Utilitytoken(_mythAddress);
    }

    event redeemMyth(address user, uint256 amountMyth, uint256 amountBNB);

    //function that other SC call to send ETHER to the LP
    function recieve() external payable {}

    //function for users to claim their myth, myth is burned while BNB is sent from the LP to the user
    function redeemMythTokens(uint256 _amount) external {
        uint256 totalSupply = mythContract.totalSupply();
        require(
            _amount <= mythContract.balanceOf(msg.sender),
            "You dont have enough myth to claim"
        );
        require(_amount >= 10000000, "Must claim more myth");
        uint256 claimableRewards = (((_amount * 1e18) / totalSupply) *
            address(this).balance) / 1e18;
        emit redeemMyth(msg.sender, _amount, claimableRewards);
        mythContract.burn(msg.sender, _amount);
        payable(msg.sender).transfer(claimableRewards);
        totalLPClaimed[msg.sender] += claimableRewards;
    }

    //function that simply returns Ether balance of this SC
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "IERC20.sol";
import "IERC20Metadata.sol";
import "Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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