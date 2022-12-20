// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";

import "./BillionsNFT.sol";
import "./ScalarNFT.sol";

contract BattleContract is ERC2771Context, Ownable, ReentrancyGuard {
    enum BattleState {
        Betting,
        Started,
        Ended,
        Expired
    }

    uint256[4] rankPercent = [5, 10, 20, 45]; // x100
    uint256[4] rewardPercent = [30, 20, 20, 30]; // x100
    uint256[5] bonusPercent = [500, 250, 150, 75, 25]; // x1000

    uint256 public baseEnterFee = 5;
    uint256 public battlePeriod = 1 days;

    address private adminAddress;
    address public playTokenAddress;
    address public billionsNftAddress;
    address public scalarNftAddress;

    uint256 public totalWithdrawAmount = 0;

    uint256 public battleId = 0;
    uint256 public currentEpoch = 0;

    struct PlayerInfo {
        uint256[] nftIds;
        uint256[] scalarIds;
    }

    mapping(uint256 => mapping(address => PlayerInfo)) enteredPlayerInfos; // (battle id => (player address => PlayerInfo))
    mapping(uint256 => address[]) enteredPlayerAddress; // (battle id => player address)

    mapping(uint256 => mapping(address => uint256)) rewardsEveryBattle; // (battle id => (player address => reward))
    mapping(uint256 => mapping(address => uint256)) bonusesEveryBattle; // (battle id => (player address => bonus))

    mapping(address => bool) verifiedPlayers;

    struct BattleInfo {
        uint256 contestType;
        uint256 battleId;
        uint256 nftCount;
        address creatorAddress;
        uint256 enterFee;
        uint256 startTimestamp;
        uint256 battleType;
        uint256 state;
    }
    mapping(uint256 => BattleInfo) battles;
    mapping(uint256 => uint256[]) battlesEveryEpoch;    // epoch id => array of battle ids
    mapping(uint256 => mapping(uint256 => bool)) billionsNftsEveryBattle; // battle id => (nft id => state)

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "Not administrator");
        _;
    }

    modifier onlyVerifiedPlayer() {
        require(verifiedPlayers[msg.sender] == true, "No verified player");
        _;
    }

    /**
    player can only bet when the battle is in betting status
     */
    modifier Bettable(uint256 _battleId) {
        require(_battleId < battleId, "Battle identification error");
        BattleInfo memory battle = battles[_battleId];
        require(
            battle.state == uint256(BattleState.Betting),
            "You is not available to bet to Battle"
        );
        _;
    }

    /**
    player can only claim when the battle is ended
     */
    modifier Claimable(uint256 _battleId) {
        require(_battleId < battleId, "Battle identification error");
        BattleInfo memory battle = battles[_battleId];
        require(
            battle.state == uint256(BattleState.Ended),
            "Battle is not ended yet"
        );
        _;
    }

    event _CreateBattle(uint256 _contestType, uint256 _battleId, address _creator, uint256 _battleType);
    event _BetBattle(uint256 _battleId, address _playerAddress, uint256[] _nftIds, uint256[] _scalarIds);
    event _ClaimedReward(uint256 _battleId, address _player, uint256 _amount);
    event _ClaimedBonus(uint256 _battleId, address _player, uint256 _amount);
    event _SendReward2Admin(
        uint256 _battleId,
        address _creator,
        address _admin,
        uint256 _amount
    );
    event _Withdraw(address _addr, uint256 _amount);

    /**
    '_addr' is wallet address of administrator

    timestamp of 1 day is 60 * 60 * 24 = 86400
     */
    constructor(address _addr) 
    ERC2771Context(_addr)
    {
        adminAddress = _addr;
        currentEpoch = (block.timestamp / 86400) * 86400;
    }

    /// @notice Overrides _msgSender() function from Context.sol
    /// @return address The current execution context's sender address
    function _msgSender() internal view override(Context, ERC2771Context) returns (address){
        return ERC2771Context._msgSender();
    }

    /// @notice Overrides _msgData() function from Context.sol
    /// @return address The current execution context's data
    function _msgData() internal view override(Context, ERC2771Context) returns (bytes calldata){
        return ERC2771Context._msgData();
    }


    /**
    '_battleType': 0 -> health battle, 1 -> blood battle
    '_enterFee' is new entry fee defined by creator.

    - If 'battle.creatorAddress' is equal to 'adminAddress', we can know this battle is created by administrator.

    - this function is called from backend(Game system create 2 types of battle, health and blood as default) or frontend(verified player create battle).
     */
    function CreateBattle(
        uint256 _contestType,
        uint256 _battleType,
        uint256 _enterFee,
        uint256 _nftCount,
        uint256 _epoch
    ) external onlyVerifiedPlayer {
        battleId += 1;

        BattleInfo storage battle = battles[battleId];

        battle.contestType = _contestType;
        battle.battleId = battleId;
        battle.nftCount = _nftCount;
        battle.creatorAddress = msg.sender;
        battle.enterFee = _enterFee;
        if (_enterFee == 0) {
            battle.enterFee = baseEnterFee;
        }
        battle.startTimestamp = _epoch;
        if (_epoch == 0 || _epoch < currentEpoch) {
            battle.startTimestamp = currentEpoch;
        }
        battle.battleType = _battleType;
        battle.state = uint256(BattleState.Betting);

        battlesEveryEpoch[currentEpoch].push(battleId);
        emit _CreateBattle(_contestType, battleId, msg.sender, _battleType);
    }

    /**
    '_battleId' is the battle's ID the player is betting
    '_nftIds' is the NFT's IDs selected by the palyer
    '_scalarType' is the type of scalar, 0: non scalar, 1: multiflier, 2: negator, 3: index scalar

    - player must to pay fee before betting.
     */
    function BetBattle(
        uint256 _battleId,
        uint256[] memory _nftIds,
        uint256[] memory _scalarIds
    ) external Bettable(_battleId) {
        BattleInfo memory battle = battles[_battleId];
        mapping(uint256 => bool) storage billionsNftsInBattle = billionsNftsEveryBattle[
            _battleId
        ];

        // nft check
        BillionsNFT billionsNFT = BillionsNFT(billionsNftAddress);
        ScalarNFT scalarNFT = ScalarNFT(scalarNftAddress);

        uint256 nftCount = _nftIds.length;
        require(battle.nftCount == nftCount, "NFT count error");

        PlayerInfo storage player = enteredPlayerInfos[_battleId][msg.sender];

        for (uint256 i = 0; i < nftCount; i++) {
            uint256 _nftId = _nftIds[i];
            address userAddress = billionsNFT.userOf(_nftId);
            if (userAddress != address(0)) {
                // rented nft
                require(
                    userAddress == msg.sender,
                    "This nft is rented by another"
                );
                require(
                    billionsNFT.ownerOf(_nftId) != msg.sender,
                    "This nft is loanded to another"
                );
                require(
                    billionsNFT.userExpires(_nftId) >=
                        battle.startTimestamp + battlePeriod,
                    "You seem to be using an expired nft"
                );
            } else {
                require(
                    billionsNFT.ownerOf(_nftId) == msg.sender,
                    "This nft is oned by another"
                );
            }
            require(
                billionsNftsInBattle[_nftId] == false,
                "You're using a nft that someone else is using."
            );
            billionsNftsInBattle[_nftId] = true;
            
            player.nftIds.push(_nftId);
        }

        for (uint256 i = 0; i < _scalarIds.length; i++) {
            require(scalarNFT.isAvailableScalar(msg.sender, _scalarIds[i]) == true, "This scalar is owned by another player");
            player.scalarIds.push(_scalarIds[i]);
        }

        // Pay enter fee
        IERC20 payToken = IERC20(playTokenAddress);
        payToken.transferFrom(msg.sender, address(this), battle.enterFee);

        enteredPlayerAddress[_battleId].push(msg.sender);

        emit _BetBattle(_battleId, msg.sender, _nftIds, _scalarIds);
    }

    /**
    
    - All battle states of the current epoch are changed to the starting state.
    - If the number of players in battle is less than 4, this battle is ended. players can claim entry fee.
     */
    function StartBattles() public onlyAdmin {
        uint256[] memory battlesOfEpoch = battlesEveryEpoch[currentEpoch];
        uint256 battleCount = battlesOfEpoch.length;

        for (uint256 i = 0; i < battleCount; i++) {
            uint256 _battleId = battlesOfEpoch[i];
            uint256 playerCount = enteredPlayerAddress[_battleId].length;
            if (playerCount < 4) {
                mapping(address => uint256)
                    storage players = rewardsEveryBattle[_battleId];
                for (uint256 j = 0; j < playerCount; j++) {
                    players[enteredPlayerAddress[_battleId][j]] = battles[
                        _battleId
                    ].enterFee;
                }
                battles[_battleId].state = uint256(BattleState.Ended);
            } else {
                battles[_battleId].state = uint256(BattleState.Started);
            }
        }

        currentEpoch += battlePeriod;
    }

    /**
    '_battleId' is the ended battle's ID.
    '_rank' is the ranked array of player address. it is not related battle type.
     */
    function EndBattle(uint256 _battleId, address[] memory _rank)
        external
        onlyAdmin
    {
        require(_battleId < battleId, "Battle identification error");
        BattleInfo storage battle = battles[_battleId];
        require(battle.state == uint256(BattleState.Started), "Battle have not started yet"); // check that battle status is started state

        battle.state = uint256(BattleState.Ended); // set battle status to ended state

        ScalarNFT scalarNFT = ScalarNFT(scalarNftAddress);

        address[] memory playerAddrs = enteredPlayerAddress[_battleId];
        uint256 playerCount = playerAddrs.length;
        uint256 totalAmount = playerCount * battle.enterFee;

        mapping(address => PlayerInfo) storage playerInfos = enteredPlayerInfos[
            _battleId
        ];

        // calculate rewards
        uint256[5] memory rank = [
            0,
            (playerCount * rankPercent[0]) / 100 + 1,
            (playerCount * rankPercent[1]) / 100 + 1,
            (playerCount * rankPercent[2]) / 100 + 1,
            (playerCount * rankPercent[3]) / 100 + 1
        ];

        mapping(address => uint256)
            storage rewardOfPlayers = rewardsEveryBattle[_battleId];
        uint256 prizePool = totalAmount * 93;
        for (uint256 i = 0; i < playerCount; i++) {
            if (i < rank[4]) {
                for (uint256 j = 1; j < 5; j++) {
                    if (i < rank[j]) {
                        rewardOfPlayers[_rank[i]] =
                            (prizePool * uint256(rewardPercent[j - 1])) /
                            10000 /
                            (rank[j] - rank[j - 1]);
                        break;
                    }
                }
            }

            // clear scalars that owned by players
            address addr = playerAddrs[i];
            PlayerInfo memory player = playerInfos[addr];
            uint256[] memory scalars = player.scalarIds;
            uint256 scalarCount = scalars.length;
            for (uint256 j = 0; j < scalarCount; j++) {
                scalarNFT.clearRandomData(scalars[j]);
            }
        }

        // calculate bonus
        mapping(address => uint256) storage bonusOflayers = bonusesEveryBattle[
            _battleId
        ];
        uint256 bonusCount = uint256(playerCount < 5 ? playerCount : 5);
        for (uint256 i = 0; i < bonusCount; i++) {
            if (i < rank[4]) {
                // current rank in 45% of total rank
                bonusOflayers[_rank[i]] =
                    (totalAmount * 2 * bonusPercent[i]) /
                    100000; // 2% * bonus percent
            }
        }

        if (adminAddress != battle.creatorAddress) {
            uint256 fee;
            IERC20 payToken = IERC20(playTokenAddress);

            totalWithdrawAmount += (totalAmount * 5 * 75) / 10000;

            fee = (totalAmount * 5 * 25) / 10000;
            payToken.transfer(battle.creatorAddress, fee);
            emit _SendReward2Admin(
                _battleId,
                address(this),
                battle.creatorAddress,
                fee
            );
        } else {
            totalWithdrawAmount += (totalAmount * 5) / 100;
        }
    }

    /// player can claim reward in *_battleId game
    function ClaimReward(uint256 _battleId)
        external
        nonReentrant
        Claimable(_battleId)
    {
        uint256 reward;

        mapping(address => uint256) storage players = rewardsEveryBattle[
            _battleId
        ];

        reward = players[msg.sender];
        require(reward > 0, "You may have already claimed or not entered");

        IERC20 payToken = IERC20(playTokenAddress);
        uint256 _balance = payToken.balanceOf(address(this));
        require(_balance >= reward, "empty wallet");

        payToken.transfer(msg.sender, reward);

        emit _ClaimedBonus(_battleId, msg.sender, reward);

        players[msg.sender] = 0;
    }

    /// player can claim reward in *_battleId game
    function ClaimBonus(uint256 _battleId)
        external
        nonReentrant
        Claimable(_battleId)
        onlyVerifiedPlayer
    {
        uint256 bonus;

        mapping(address => uint256) storage players = bonusesEveryBattle[
            _battleId
        ];

        bonus = players[msg.sender];
        require(bonus > 0, "You may have already claimed or not entered");

        IERC20 payToken = IERC20(playTokenAddress);
        uint256 _balance = payToken.balanceOf(address(this));
        require(_balance >= bonus, "empty wallet");

        payToken.transfer(msg.sender, bonus);

        emit _ClaimedBonus(_battleId, msg.sender, bonus);

        players[msg.sender] = 0;
    }

    /// contract owner can withdraw earned fund
    /// *_amount is amount of claim
    function WithdrawRevenue(uint256 _amount) external nonReentrant onlyOwner {
        require(
            totalWithdrawAmount >= _amount,
            "You may be a unverified player"
        );

        IERC20 payToken = IERC20(playTokenAddress);

        uint256 _balance = payToken.balanceOf(address(this));
        require(_balance >= totalWithdrawAmount, "empty wallet");

        payToken.transfer(msg.sender, _amount);
        totalWithdrawAmount -= _amount;

        emit _Withdraw(msg.sender, _amount);
    }

    /// *_palyer can claim bonus and create battle
    function AddVerifiedPlayer(address _player) public onlyAdmin {
        verifiedPlayers[_player] = true;
    }

    function RemoveVerifiedPlayer(address _player) public onlyAdmin {
        verifiedPlayers[_player] = false;
    }

    function SetAdminAddress(address _address) external onlyOwner {
        adminAddress = _address;
    }

    function SetPlayTokenAddress(address _address) external onlyAdmin {
        playTokenAddress = _address;
    }

    function SetBillionsNftAddress(address _addr) external onlyAdmin {
        billionsNftAddress = _addr;
    }

    function SetScalarNftAddress(address _addr) external onlyAdmin {
        scalarNftAddress = _addr;
    }

    /// get all players information in *_battleId game
    /// return arrays of player address and player infos
    function GetPlayersInBattle(uint256 _battleId)
        external
        view
        returns (address[] memory addrs, PlayerInfo[] memory infos)
    {
        addrs = enteredPlayerAddress[_battleId];
        uint256 playerCount = addrs.length;
        infos = new PlayerInfo[](playerCount);

        mapping(address => PlayerInfo)
            storage dumpPlayerInfo = enteredPlayerInfos[_battleId];

        for (uint256 i = 0; i < playerCount; i++) {
            infos[i] = dumpPlayerInfo[addrs[i]];
        }
    }

    /// get player information with *_address from *_battleId game
    function GetPlayer(uint256 _battleId, address _address)
        external
        view
        returns (PlayerInfo memory)
    {
        return enteredPlayerInfos[_battleId][_address];
    }

    /// get total number of palyers in *_battleId game
    function GetPlayerCountInBattle(uint256 _battleId)
        public
        view
        returns (uint256)
    {
        return enteredPlayerAddress[_battleId].length;
    }

    /// get array of reward that can be claimed in *_battleId game
    function GetRewardsInBattle(uint256 _battleId)
        public
        view
        returns (address[] memory, uint256[] memory)
    {
        address[] memory dumpAddrs = enteredPlayerAddress[_battleId];
        uint256 playerCount = dumpAddrs.length;

        address[] memory addrs = new address[]((playerCount * 45) / 100 + 1);
        uint256[] memory rewards = new uint256[]((playerCount * 45) / 100 + 1);

        mapping(address => uint256) storage dumpRewards = rewardsEveryBattle[
            _battleId
        ];

        uint256 idx = 0;
        for (uint256 i = 0; i < playerCount; i++) {
            if (dumpRewards[dumpAddrs[i]] == 0) {
                continue;
            }

            addrs[idx] = dumpAddrs[i];
            rewards[idx] = dumpRewards[dumpAddrs[i]];
            idx += 1;
        }

        return (addrs, rewards);
    }

    /// get amount of reward that *_userAddress can be claimed in *_battleId game
    function GetPlayerReward(uint256 _battleId, address _userAddress)
        public
        view
        returns (uint256 claimableAmount)
    {
        claimableAmount = rewardsEveryBattle[_battleId][_userAddress];
    }

    /// get array of bonus that can be claimed in *_battleId game
    function GetBonusesInBattle(uint256 _battleId)
        public
        view
        returns (address[] memory, uint256[] memory)
    {
        address[] memory dumpAddrs = enteredPlayerAddress[_battleId];
        uint256 playerCount = dumpAddrs.length;

        address[] memory addrs = new address[](5);
        uint256[] memory bonuses = new uint256[](5);

        mapping(address => uint256) storage dumpBonuses = bonusesEveryBattle[
            _battleId
        ];

        uint256 idx = 0;
        for (uint256 i = 0; i < playerCount; i++) {
            if (dumpBonuses[dumpAddrs[i]] == 0) {
                continue;
            }

            addrs[idx] = dumpAddrs[i];
            bonuses[idx] = dumpBonuses[dumpAddrs[i]];
            idx += 1;

            if (idx >= 5) break;
        }

        return (addrs, bonuses);
    }

    /// get amount of bonus that *_userAddress can be claimed in *_battleId game
    function GetPlayerBonus(uint256 _battleId, address _userAddress)
        public
        view
        returns (uint256 claimableAmount)
    {
        claimableAmount = bonusesEveryBattle[_battleId][_userAddress];
    }

    /// get array of battle started/ended at time of *_epoch
    function GetBattles(uint256 _epoch)
        public
        view
        returns (BattleInfo[] memory _battles)
    {
        uint256 epoch = _epoch;
        if (epoch == 0) epoch = currentEpoch;
        uint256[] memory battleIds = battlesEveryEpoch[epoch];
        uint256 battleCount = battleIds.length;

        for (uint256 i = 0; i < battleCount; i++) {
            _battles[i] = battles[battleIds[i]];
        }
    }

    /** //////////////////////////////// **
    //////////////////////////////////// */
    function GetBattle(uint256 _battleId)
        public
        view
        returns (BattleInfo memory)
    {
        return battles[_battleId];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./ERC4907.sol";
import "./BillionsBaseContract.sol";

contract BillionsNFT is ERC4907, BillionsBaseContract, ReentrancyGuard {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private nftId;
    uint256 public totalSupply = 0;

    address public packSaleAddress;

    uint256 public mintPrice = 3 * 10 ** decimals;

    string private baseURI = "https://ipfs.io/billions/nfts";

    struct NFTInfo {
        uint256 nftType;
        uint256 symbolId;
    }

    mapping(uint256 => NFTInfo) private nftInfos;       // nftId => NFT
    mapping(uint256 => mapping(uint256 => bool)) public usedSymbolId;   // nftType => (symbolId => used)
    mapping(address => uint256[]) public nftIdsOfPlayer;    // player => Array of nft id

    mapping(uint256 => uint256[]) public availableSymbolIds;    // nft type => Array of symbolId

    // Check if caller have enough fund to mint
    modifier Mintable() {

        require(msg.value >= mintPrice, "Not enough funds");
        _;
    }

    event _BillionsNftMint(uint256 _nftId, address _owner);

    constructor(string memory _name, string memory _symbol)
    ERC4907(_name, _symbol)
    {}

    function mint(
        uint256 _type,
        uint256 _symbolId 
    ) 
    external payable Mintable returns (uint256) {
        require(msg.value >= getMaticAmountFromUSDC(mintPrice - mintPrice * slippage / 100) , "Not enough funds to mint");
        require(!usedSymbolId[_type][_symbolId], "not available");

        uint256[] memory symbolIds = availableSymbolIds[_type];
        uint256 _availableCount = symbolIds.length;
        require(_availableCount > 0, "Not enough count");
 
        nftId.increment();
        uint256 _nftId = nftId.current();
        totalSupply += 1;

        _safeMint(msg.sender, _nftId);

        nftInfos[_nftId].nftType = _type;
        nftInfos[_nftId].symbolId = _symbolId;

        usedSymbolId[_type][_symbolId] = true;
        nftIdsOfPlayer[msg.sender].push(_nftId);

        for(uint256 i = 0; i < _availableCount; i ++) {
            if(symbolIds[i] == _symbolId) {
                availableSymbolIds[_type][i] = availableSymbolIds[_type][_availableCount - 1];
                availableSymbolIds[_type].pop();

                break;
            }
        }

        emit _BillionsNftMint(_nftId, msg.sender);
        return _nftId;
    }

    function mintByERC20(uint256 _type, uint256 _symbolId) 
    external returns (uint256) {
        require(!usedSymbolId[_type][_symbolId], "not available");

        uint256[] memory symbolIds = availableSymbolIds[_type];
        uint256 _availableCount = symbolIds.length;
        require(_availableCount > 0, "Not enough count");

        nftId.increment();
        uint256 _nftId = nftId.current();
        totalSupply += 1;

        IERC20 payToken = IERC20(payTokenAddress);
        require(payToken.transferFrom(msg.sender, address(this), mintPrice), "must pay token" );

        _safeMint(msg.sender, _nftId);

        nftInfos[_nftId].nftType = _type;
         nftInfos[_nftId].symbolId = _symbolId;

        usedSymbolId[_type][_symbolId] = true;
        nftIdsOfPlayer[msg.sender].push(_nftId);

        for(uint256 i = 0; i < _availableCount; i ++) {
            if(symbolIds[i] == _symbolId) {
                availableSymbolIds[_type][i] = availableSymbolIds[_type][_availableCount - 1];
                availableSymbolIds[_type].pop();

                break;
            }
        }

        emit _BillionsNftMint(_nftId, msg.sender);

        return _nftId;
    }

    function mintByPack(uint256 _type) public  {
        uint256 _availableCount = availableSymbolIds[_type].length;
        require(msg.sender == packSaleAddress, "No permission");
        require(_availableCount >= 3, "Not enough count");

        uint256 _rand = block.timestamp;
        for(uint256 idx = 0; idx < 3; idx ++) {
            _rand = random(_rand);
            _availableCount = availableSymbolIds[_type].length;
            uint256 _symbolId = availableSymbolIds[_type][_rand % _availableCount];

            nftId.increment();
            uint256 _nftId = nftId.current();
            totalSupply += 1;

            _safeMint(tx.origin, _nftId);
            nftInfos[_nftId] = NFTInfo(_type, _symbolId);
            usedSymbolId[_type][_symbolId] = true;
            nftIdsOfPlayer[tx.origin].push(_nftId);

            availableSymbolIds[_type][_rand % _availableCount] = availableSymbolIds[_type][_availableCount - 1];
            availableSymbolIds[_type].pop();
        
            emit _BillionsNftMint(_nftId, tx.origin);
        }
    }

    function getBaseURI() public view returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _uri) public onlyOwner {
        baseURI = _uri;
    }

    function tokenURI(uint256 _nftId) public view virtual override returns (string memory uri) {
        _requireMinted(_nftId);
        
        string memory _baseURI = getBaseURI();
        NFTInfo memory nft = nftInfos[_nftId];
        if(nft.nftType == 0) {
            uri = bytes(_baseURI).length > 0 ? string(abi.encodePacked(_baseURI, "/company", nft.symbolId)) : "";
        } else if (nft.nftType == 1) {
            uri = bytes(_baseURI).length > 0 ? string(abi.encodePacked(_baseURI, "/crypto", nft.symbolId)) : "";
        }
    }

    function getMintPrice() public view returns (uint256) {
        return mintPrice;
    }

    function setMintPrice(uint256 _price) public onlyOwner {
        mintPrice = _price;
    }

    function setPackSaleAddress(address _addr) public onlyOwner {
        packSaleAddress = _addr;
    }

    function clearAvailableSymbolIds(uint256 _type) external onlyOwner {
        delete availableSymbolIds[_type];
    }

    function setAvailableSymbolIds(uint256 _type, uint256[] memory _ids) external onlyOwner {
        availableSymbolIds[_type] = _ids;
    }

    function addAvailableSymbolId(uint256 _type, uint256 _id) external onlyOwner {
        availableSymbolIds[_type].push(_id);
    }

    function getNftIdsOfPlayer(address _addr) external view returns (uint256[] memory) {
        return nftIdsOfPlayer[_addr];
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./BillionsBaseContract.sol";

contract ScalarNFT is ERC721, VRFConsumerBaseV2, BillionsBaseContract {
    using Counters for Counters.Counter;
    Counters.Counter private nftId;
    uint256 public totalSupply = 0;

    string private baseURI = "https://ipfs.io/billions/scalar/";

    uint256 public mintPrice = 2 * 10 ** decimals;
    uint256 public refillPrice = 1 * 10 ** decimals;

    address public operatorContract;    
    address public packSaleAddress;

    bytes32 internal keyHash;
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 public subscriptionId;
    uint32 callbackGasLimit;
    uint16 requestConfirmations;
    uint32 numWords;
    mapping(uint256 => uint256) public randomIds;

    struct ScalarInfo {
        address player;
        uint8 scalarType;
        uint8 scalarValue;
    }
    mapping(uint256 => ScalarInfo) public scalarNfts;
    mapping(address => uint256[]) public scalarIdsOfPlayer;

    // Check if caller have enough fund to mint
    modifier Mintable() {
        require(msg.value >= getMaticAmountFromUSDC(mintPrice - mintPrice * slippage / 100) , "Not enough funds to mint");
        _;
    }

    // Check if caller have enough fund to refill
    modifier Refillable() {
        require(msg.value >= getMaticAmountFromUSDC(refillPrice - refillPrice * slippage / 100), "Not enough funds to refill");
        _;
    }

    // check if caller is operator
    modifier OnlyOperator() {
        require(msg.sender == operatorContract, "No operator");
        _;
    }

    event _RequestedRandomness(uint256 requestId);
    event _FulfilledRandomness(uint256 requestId);
    event _ScalarChanged(uint256 _scalarId, address _player, uint8 _type, uint8 _value);

    /**
    * https://docs.chain.link/docs/vrf/v2/subscription/supported-networks/
    * we can choose proper value there.
    **/
    constructor(address _vrfCoordinator, bytes32 _keyHash, uint32 _callbackGasLimit)  
        ERC721("Billions Scalar NFT", "BSN") 
        VRFConsumerBaseV2(_vrfCoordinator) 
    {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        keyHash = _keyHash;
        callbackGasLimit = _callbackGasLimit;
        requestConfirmations = 3;
        numWords = 1;
    }

    /**
    * '_id' is the subscription id that administrator have create in https://vrf.chain.link/
    * 1. add funds(Token Link) on '_id' Subscription
    * 2. add consumer(address of this contract)
    **/
    function setSubscriptionId(uint64 _id) external {
        subscriptionId = _id;
    }

    /**
    * mint scalar nft with matic(Matic) 
    * 
    **/
    function mint(uint8 scalarType) public payable Mintable returns (uint256) {
        require(scalarType < 2, "");

        nftId.increment();

        uint256 id = nftId.current();
        _mint(msg.sender, id);
        totalSupply += 1;
        scalarIdsOfPlayer[msg.sender].push(id);

        uint256 reqId = getRandomNumber();

        scalarNfts[id].player = msg.sender;
        scalarNfts[id].scalarType = scalarType;
        randomIds[reqId] = id;
        return id;
    }

    /**
    * mint scalar nft with USDC
    * 
    **/
    function mintByERC20(uint8 scalarType) external returns (uint256) {
        nftId.increment();

        IERC20 payToken = IERC20(payTokenAddress);
        require(payToken.transferFrom(msg.sender, address(this), mintPrice), "must pay token" );

        uint256 id = nftId.current();
        _mint(msg.sender, id);
        totalSupply += 1;
        scalarIdsOfPlayer[msg.sender].push(id);

        uint256 reqId = getRandomNumber();

        scalarNfts[id].player = msg.sender;
        scalarNfts[id].scalarType = scalarType;
        randomIds[reqId] = id;
        return id;
    }

    function mintByPack() public {
        require(msg.sender == packSaleAddress, "No permission");

        uint256 _rand = block.timestamp;
        for(uint256 idx = 0; idx < 2; idx ++) {
            _rand = random(_rand);

            nftId.increment();

            uint256 id = nftId.current();
            _mint(tx.origin, id);
            totalSupply += 1;
            scalarIdsOfPlayer[tx.origin].push(id);

            uint256 reqId = getRandomNumber();

            scalarNfts[id].player = tx.origin;
            scalarNfts[id].scalarType = uint8(_rand % 2);
            randomIds[reqId] = id;
        }
    }
    /**
    * update the value of '_nftId' scalar nft
    * payment : matic(Matic)
     */
    function refill(uint256 _nftId) external payable Refillable {
        _requireMinted(_nftId);

        uint256 reqId = getRandomNumber();
        randomIds[reqId] = _nftId;
    }

     /**
    * update the value of '_nftId' scalar nft
    * payment : USDC
     */
    function refillByERC20(uint256 _nftId) external  {
        _requireMinted(_nftId);

        IERC20 payToken = IERC20(payTokenAddress);
        require(payToken.transferFrom(msg.sender, address(this), refillPrice), "must be paid" );

        uint256 reqId = getRandomNumber();
        randomIds[reqId] = _nftId;
    }

    /**
    * send request to chainlink
     */
    function getRandomNumber() internal returns (uint256 _requestId){
        _requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        emit _RequestedRandomness(_requestId);
    }

    /**
    * store value from 20 to 100 step by 5 to minted scalr nft
     */
    function fulfillRandomWords(uint256 _requestId, uint256[] memory randomWords)
        internal
        override
    {
        uint8 randnumber = uint8(20 + (randomWords[0] % 85) / 5 * 5);

        scalarNfts[randomIds[_requestId]].scalarValue = randnumber;

        emit _ScalarChanged(
            randomIds[_requestId], 
            scalarNfts[randomIds[_requestId]].player, 
            scalarNfts[randomIds[_requestId]].scalarType,
            randnumber
            );

        emit _FulfilledRandomness(_requestId);
    }

    /**
    * store the address of the operator who manage this contract
     */
    function setOperatorContract(address _operator) external onlyOwner {
        require(_operator != address(0));
        operatorContract = _operator;
    }

    /**
    * update the value of the used scalar
    * only operator can update
     */
    function clearRandomData(uint256 _nftId) public OnlyOperator {
        _requireMinted(_nftId);
        scalarNfts[_nftId].scalarValue = 0;
    }

    /**
    * update the address of the BillionsPackSale contract
    * Only BillionsPackSale can call mintByPack function
     */
    function setPackSaleAddress(address _addr) public onlyOwner {
        packSaleAddress = _addr;
    }
    /**
    * store the price to mint(USDC)
    */
    function setMintPrice(uint256 _price) external onlyOwner {
        mintPrice = _price;
    }

    /**
    * store the price to refill(USDC)
     */
    function setRefillPrice(uint256 _price) external onlyOwner {
        refillPrice = _price;
    }

    /**
    * return the type and value of '_nftId' scalar nft
     */
    function getScalar(uint256 _nftId) public view returns (uint8 sType, uint8 sValue) {
        if(_exists(_nftId)) {
            sType = scalarNfts[_nftId].scalarType;
            sValue = scalarNfts[_nftId].scalarValue;
        } else {
            return (0, 0);
        }
    }

    /**
    * store base of uri of ipfs for scalar nfts
     */
    function setBaseURI(string memory _uri) public onlyOwner {
        baseURI = _uri;
    }

    /**
    * return base of uri of ipfs for scalar nfts
     */
    function getBaseURI() public view returns (string memory) {
        return baseURI;
    }

    /**
    * return the uri of '_nftId' scalar nft
     */
    function tokenURI(uint256 _nftId) public view virtual override returns (string memory) {
        _requireMinted(_nftId);
        
        string memory _baseURI = getBaseURI();
        return bytes(_baseURI).length > 0 ? string(abi.encodePacked(_baseURI, scalarNfts[_nftId].scalarType)) : "";
    }

    /**
    * return scalar info(scalarType, sclarValue) that '_user' player own
     */
    function getScalarsOfPlayer(address _user) public view returns (ScalarInfo[] memory) {
        uint256[] memory scalarIds = scalarIdsOfPlayer[_user];
        uint256 count = scalarIds.length;
        ScalarInfo[] memory scalarInfos = new ScalarInfo[](count);

        for(uint256 i = 0; i < count; i ++) {
            scalarInfos[i] = scalarNfts[scalarIds[i]];
        }

        return scalarInfos;
    }

    /**
    * return scalar ids that '_user' player own
     */
    function getScalarIdsOfPlayer(address _user) public view returns (uint256[] memory) {
        return scalarIdsOfPlayer[_user];
    }

    /**
    * return scalar ids that '_user' player own
     */
    function isAvailableScalar(address _user, uint256 _id) public view returns (bool) {
        uint256[] memory ids = scalarIdsOfPlayer[_user];
        bool isAvailable = false;
        for(uint256 i = 0; i < ids.length; i ++) {
            if(_id == ids[i]) {
                isAvailable = true;
                break;
            }
        }
        return isAvailable;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (metatx/ERC2771Context.sol)

pragma solidity ^0.8.9;

import "../utils/Context.sol";

/**
 * @dev Context variant with ERC2771 support.
 */
abstract contract ERC2771Context is Context {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    address private immutable _trustedForwarder;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address trustedForwarder) {
        _trustedForwarder = trustedForwarder;
    }

    function isTrustedForwarder(address forwarder) public view virtual returns (bool) {
        return forwarder == _trustedForwarder;
    }

    function _msgSender() internal view virtual override returns (address sender) {
        if (isTrustedForwarder(msg.sender)) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            /// @solidity memory-safe-assembly
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return super._msgSender();
        }
    }

    function _msgData() internal view virtual override returns (bytes calldata) {
        if (isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length - 20];
        } else {
            return super._msgData();
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BillionsBaseContract is Ownable {
    address public payTokenAddress;
    address public aggregatorV3Address;
    uint256 public slippage = 1;
    uint256 public decimals = 18;
    uint256 public maticDecimals = 18;

    AggregatorV3Interface public priceFeed;

    event _Withdraw(address, uint256);

    constructor() {

    }

    function setDecimals(uint256 _decimal) public {
        decimals = _decimal;
    }

    function setPayTokenAddress(address _addr) public {
        payTokenAddress = _addr;
    }

    function setSlippage(uint256 _slippage) public {
        slippage = _slippage;
    }

    function setAggregatorV3Address(address _addr) public {
        aggregatorV3Address = _addr;
        priceFeed = AggregatorV3Interface(aggregatorV3Address);
        maticDecimals = priceFeed.decimals();
    }
    /**
    * calculate the amount of matic from USDC 
     */
    function getMaticAmountFromUSDC(uint256 amount) public view returns(uint) {
        uint256 bnbPrice =uint256( getMaticPrice() );
        uint256 bnbAmount = uint256( (amount * (10 ** maticDecimals)) / bnbPrice ) ;
        return bnbAmount;
    }

    /**
    * https://docs.chain.link/docs/data-feeds/price-feeds/addresses/
    * get price of 1 Matic for test
     */
    function getMaticPrice() public view returns(int) {
        (,int256 answer,,,) = priceFeed.latestRoundData();
        int usd = answer; // per 1 Matic (18 decimals)
        return usd;
    }

    function isContract(address _addr) private view returns (bool){
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    /// @notice Generates a random number using hash of the encoded imput string
    /// @param _input The string used in generating random number
    /// @return uint256 The random number generated
    function random(uint256 _input) internal pure returns(uint256) {
        return uint256(keccak256(abi.encodePacked(_input)));
    }

    /**
    * operator can withdraw revenue(USDC) of this contract
     */
    function WithdrawERC20(uint256 _amount) external onlyOwner {
        IERC20 payToken = IERC20(payTokenAddress);

        uint256 _balance = payToken.balanceOf(address(this));
        require(_balance >= _amount, "No enough fund");

        payToken.transfer(msg.sender, _amount);

        emit _Withdraw(msg.sender, _amount);
    }

    /**
    * operator can withdraw revenue(matic) of this contract
     */
    function Withdraw(uint256 _amount) external onlyOwner {
        uint256 _balance = address(this).balance;
        require(_balance >= _amount, "No enough fund");

        payable(msg.sender).transfer(_amount);

        emit _Withdraw(msg.sender, _amount);
    }
}

// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./IERC4907.sol";

contract ERC4907 is ERC721, IERC4907 {
    struct UserInfo
    {
        address user;   // address of user role
        uint64 expires; // unix timestamp, user expires
    }

    mapping (uint256  => UserInfo) internal _users;

    constructor(string memory name_, string memory symbol_)
     ERC721(name_,symbol_)
     {
     }

    /// @notice set the user and expires of a NFT
    /// @dev The zero address indicates there is no user
    /// Throws if `tokenId` is not valid NFT
    /// @param user  The new user of the NFT
    /// @param expires  UNIX timestamp, The new user could use the NFT before expires
    function setUser(uint256 tokenId, address user, uint64 expires) public virtual{
        require(_isApprovedOrOwner(msg.sender, tokenId),"ERC721: transfer caller is not owner nor approved");
        UserInfo storage info =  _users[tokenId];
        info.user = user;
        info.expires = expires;
        emit UpdateUser(tokenId,user,expires);
    }

    /// @notice Get the user address of an NFT
    /// @dev The zero address indicates that there is no user or the user is expired
    /// @param tokenId The NFT to get the user address for
    /// @return The user address for this NFT
    function userOf(uint256 tokenId)public view virtual returns(address){
        if( uint256(_users[tokenId].expires) >=  block.timestamp){
            return  _users[tokenId].user;
        }
        else{
            return address(0);
        }
    }

    /// @notice Get the user expires of an NFT
    /// @dev The zero value indicates that there is no user
    /// @param tokenId The NFT to get the user expires for
    /// @return The user expires for this NFT
    function userExpires(uint256 tokenId) public view virtual returns(uint256){
        return _users[tokenId].expires;
    }

    /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC4907).interfaceId || super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from != to && _users[tokenId].user != address(0)) {
            delete _users[tokenId];
            emit UpdateUser(tokenId, address(0), 0);
        }
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
library Counters {
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
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
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

// SPDX-License-Identifier: CC0-1.0
 
pragma solidity ^0.8.0;
 
interface IERC4907 {
    // Logged when the user of a token assigns a new user or updates expires
    /// @notice Emitted when the `user` of an NFT or the `expires` of the `user` is changed
    /// The zero address for user indicates that there is no user address
    event UpdateUser(uint256 indexed tokenId, address indexed user, uint64 expires);
 
    /// @notice set the user and expires of a NFT
    /// @dev The zero address indicates there is no user 
    /// Throws if `tokenId` is not valid NFT
    /// @param user  The new user of the NFT
    /// @param expires  UNIX timestamp, The new user could use the NFT before expires
    function setUser(uint256 tokenId, address user, uint64 expires) external ;
 
    /// @notice Get the user address of an NFT
    /// @dev The zero address indicates that there is no user or the user is expired
    /// @param tokenId The NFT to get the user address for
    /// @return The user address for this NFT
    function userOf(uint256 tokenId) external view returns(address);
 
    /// @notice Get the user expires of an NFT
    /// @dev The zero value indicates that there is no user 
    /// @param tokenId The NFT to get the user expires for
    /// @return The user expires for this NFT
    function userExpires(uint256 tokenId) external view returns(uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

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
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
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
        _requireMinted(tokenId);

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
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

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
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");

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
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
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
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
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
        address owner = ERC721.ownerOf(tokenId);
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
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
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
        address owner = ERC721.ownerOf(tokenId);

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
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
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
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
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
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
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
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
interface IERC721Receiver {
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

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
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
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
interface IERC165 {
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
pragma solidity ^0.8.4;

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
abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) {
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
pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}

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

  /*
   * @notice Check to see if there exists a request commitment consumers
   * for all consumers and keyhashes for a given sub.
   * @param subId - ID of the subscription
   * @return true if there exists at least one unfulfilled request for the subscription, false
   * otherwise.
   */
  function pendingRequestExists(uint64 subId) external view returns (bool);
}