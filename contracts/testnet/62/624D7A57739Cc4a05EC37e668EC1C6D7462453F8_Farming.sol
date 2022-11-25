// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./interfaces/INftMinter.sol";
import "./interfaces/ILandNFT.sol";
import "./interfaces/ICowNFT.sol";
import "./interfaces/IBullNFT.sol";
import "./interfaces/IMasterChef.sol";
import "./interfaces/IHappyCow.sol";

contract Farming is ReentrancyGuard, Ownable {
    uint COW_TOKEN_DECIMALS = 9;
    // uint MASTERCHEF_PID = 5;
    uint MASTERCHEF_PID = 6;
    
    // address HAPPY_COW_ADDRESS = 0xD220d3E1bab3A30f170E81b3587fa382BB4A6263; // Deployed on testnet, For TEST
    // address AIR_NFT_ADDRESS = 0x74A9Bb4F6b05236507614cA70d32f65436064786; // Deployed on testnet, For TEST
    // address COW_TOKEN_ADDRESS = 0x562d2BFc80FD1afF3bF5e4Bd8Fa5312E65305C14; // Deployed on testnet, For TEST
    // address MILK_TOKEN_ADDRESS = 0x3eFA66aB2b1690e9BE8e82784EDfF2cF2dc150e0; // Deployed on testnet, For TEST
    // address MASTERCHEF_ADDRESS = 0xB11C302675FD4a0bD725ecB7e0c3b9F6a3caEa8b; // Deployed on testnet, For TEST
    // address SECRET_LP_ADDRESS = 0xC25e8b265Ee64A0CDE09347dC8d3e40419E8311f; // Deployed on testnet, For TEST
    // address SECRET_LP_ADDRESS = 0xFED350e5e65FDe282d9164297316B781BA1bEa94; // Deployed on testnet, For TEST
    
    address public minterAddr; // NftMinter contract address

    // Structure of CowBullInfo
    struct CowBullInfo {
        uint256 tokenId;
        uint8 rarity;
        uint256 birth;
        uint8 breed;
        bool isBreeding;
    }

    // Structure of FarmingVault
    struct FarmingVault {
        uint[] landTokenIds; // Array of Lands to be staked
        CowBullInfo[] cows;
        CowBullInfo[] bulls; // Array of Cows to be staked
        uint256[] happyCowIds; // Array of Happy Cows to be staked
        uint256[] airIds; // Array of Genesis to be staked
        address owner; // Owner of the farm. Can be used as primary key of the farm.
        uint lastReward; // block time of last reward
        uint256 stakedCow; //Cow Tokens to be staked by user
    }

    mapping(uint256 => uint256 ) public initMilkPower;
    mapping(address => FarmingVault) public userFarms;
    mapping(uint256 => uint256) public cowLimitPerLand;
    mapping(uint256 => uint256) public bullLimitPerLand;
    mapping(uint256 => uint256) public baseMilkPower; // Base MilkPower of Cows by rarity
    
    uint public maxAge; // Maximum age of Cow and Bull. Used to change the aging speed.
    uint256 public totalMilkPower;
    uint[] public happyCowNftBreeds;
    uint[] public genesisTokenIds;
    uint256 public milkPerBlock;
    bool private initialized;
    uint256 public daysToHarvest;
    // User Happy Cow Bonus When Deposit
    mapping(address => uint256[5]) public happyCowBonus;
    mapping(address => uint256) public airNftBonus;

    // Breeding Individual Status
    mapping(uint => bool) public breedingCows;
    mapping(uint => bool) public breedingBulls;

    // Public Variables for initialize the Contract
    address public HAPPY_COW_ADDRESS;
    address public AIR_NFT_ADDRESS;
    address public COW_TOKEN_ADDRESS;
    address public MILK_TOKEN_ADDRESS;
    address public MASTERCHEF_ADDRESS;
    address public SECRET_LP_ADDRESS;
    // address SECRET_LP_ADDRESS = 0xC25e8b265Ee64A0CDE09347dC8d3e40419E8311f;

    struct BreedingVault {
        CowBullInfo cowTokenInfo; // Staked Cow tokenId
        CowBullInfo bullTokenInfo; // Staked Bull tokenId
        uint unlockTime; // Breeding time
        address owner; // Owner of the couple
    }

    BreedingVault[] public breedingVaults; // Array of BreedingVault

    mapping(address => BreedingVault) public userBreedings;

    uint public maxRecoveryTime;
    uint[5] public baseRecoveryTime;
    uint public breedingPrice;
    uint256 public rarityProbability;
    uint256 public breedProbability;
    uint256 public cowProbability;
    mapping(address => uint256) public reserveAmount;

    event DepositLand(address _owner, uint _tokenId);
    event WithdrawLand(address _owner, uint _tokenId);
    event DepositCow(address _owner, uint _tokenId);
    event WithdrawCow(address _owner, uint _tokenId);
    event DepositBull(address _owner, uint _tokenId);
    event WithdrawBull(address _owner, uint _tokenId);

    // Initialize the contract. This is for Proxy functionality.  Can be called only by the owner.
    function initialize(address _minterAddr, address _happyCowAddress, address _airNftAddress,address _cowTokenAddress, address _milkTokenAddress, address _masterChefAddress, address _secretLpAddress) public {

        require(_minterAddr != address(0), "Initializing by zero address");
        require(!initialized, "already initialized");
        initialized = true;
        minterAddr = _minterAddr;

        HAPPY_COW_ADDRESS = _happyCowAddress;
        AIR_NFT_ADDRESS = _airNftAddress;
        COW_TOKEN_ADDRESS = _cowTokenAddress;
        MILK_TOKEN_ADDRESS = _milkTokenAddress;
        MASTERCHEF_ADDRESS = _masterChefAddress;
        SECRET_LP_ADDRESS = _secretLpAddress;

        _transferOwnership(msg.sender);

        daysToHarvest = 1 days;

        maxAge = 200 days;
        cowLimitPerLand[0] = 40;
        cowLimitPerLand[1] = 80;
        cowLimitPerLand[2] = 120;
        cowLimitPerLand[3] = 200;
        cowLimitPerLand[4] = 320;

        bullLimitPerLand[0] = 2;
        bullLimitPerLand[1] = 4;
        bullLimitPerLand[2] = 6;
        bullLimitPerLand[3] = 10;
        bullLimitPerLand[4] = 16;

        baseMilkPower[0] = 2000;
        baseMilkPower[1] = 3000;
        baseMilkPower[2] = 5000;
        baseMilkPower[3] = 8000;
        baseMilkPower[4] = 13000;

        COW_TOKEN_DECIMALS = 9;
        MASTERCHEF_PID = 6;

        maxRecoveryTime = 200 days;
        breedingPrice = 90*10**18;
        rarityProbability = 80;
        breedProbability = 50;
        cowProbability = 90;

        baseRecoveryTime[0] = 50 minutes;
        baseRecoveryTime[1] = 40 minutes;
        baseRecoveryTime[2] = 30 minutes;
        baseRecoveryTime[3] = 20 minutes;
        baseRecoveryTime[4] = 10 minutes;

        _transferOwnership(msg.sender);
    }

    function depositLP() external onlyOwner{
        IMasterChef masterChef = IMasterChef(address(MASTERCHEF_ADDRESS));
        IERC20 secretLpTokenContract = IERC20(address(SECRET_LP_ADDRESS));
        secretLpTokenContract.approve(MASTERCHEF_ADDRESS, secretLpTokenContract.balanceOf(address(this)));
        masterChef.deposit(MASTERCHEF_PID, secretLpTokenContract.balanceOf(address(this)));
    }
    
    function withdrawLp(uint256 _amount) external onlyOwner{
        IMasterChef masterChef = IMasterChef(address(MASTERCHEF_ADDRESS));
        IERC20 secretLpTokenContract = IERC20(address(SECRET_LP_ADDRESS));
        secretLpTokenContract.approve(MASTERCHEF_ADDRESS, secretLpTokenContract.balanceOf(address(this)));
        masterChef.withdraw(MASTERCHEF_PID, _amount);
        milkPerBlock = 0;
    }

    // Deposit(Stake) Land NFT.
    function setMilkPerBlock(uint256 newValue) external onlyOwner {
        milkPerBlock = newValue;
    }

    function setDaysToHarvest(uint256 _days) external onlyOwner {
        daysToHarvest = _days * 1 days;
    }

    function depositLand(uint _tokenId) public {
        INftMinter minter = INftMinter(address(minterAddr));
        ILandNFT landNfts = ILandNFT(address(minter.landNftColl()));
        FarmingVault storage _userFarm = userFarms[msg.sender];
        _userFarm.landTokenIds.push(_tokenId);
        _userFarm.owner = msg.sender;
        landNfts.transferFrom(msg.sender, address(this), _tokenId);

        emit DepositLand(msg.sender, _tokenId);
    }

    // Withdraw(Unstake) Land NFT.
    function withdrawLand(uint _tokenId) public {
        INftMinter minter = INftMinter(address(minterAddr));
        ILandNFT landNfts = ILandNFT(address(minter.landNftColl()));
        ILandNFT.LandAttr memory attr = landNfts.attrOf(_tokenId);
        FarmingVault storage _userFarm = userFarms[msg.sender];

        require(_totalCowLimitOf(msg.sender) - cowLimitPerLand[attr.rarity] >= _userFarm.cows.length, "Cow Limit: Withdraw Cows first");
        require(_totalBullLimitOf(msg.sender) - bullLimitPerLand[attr.rarity] >= _userFarm.bulls.length, "Bull Limit: Withdraw Bulls first");
        landNfts.transferFrom(address(this), _userFarm.owner, _tokenId);
        uint256[] storage userLands = _userFarm.landTokenIds;
        for(uint idx = 0;idx < userLands.length;idx ++) {
            if(userLands[idx] == _tokenId) {
                userLands[idx] = userLands[userLands.length - 1];
                userLands.pop();
                break;
            }
        }

        emit WithdrawLand(msg.sender, _tokenId);
    }

    // Deposit(Stake) a Cow NFT.
    function depositCow(uint _tokenId) external {
        FarmingVault storage _userFarm = userFarms[msg.sender];
        require(_totalCowLimitOf(msg.sender) >= _userFarm.cows.length + 1, "Limit of Cows");
        INftMinter minter = INftMinter(address(minterAddr));
        ICowNFT cowNfts = ICowNFT(address(minter.cowNftColl()));
        cowNfts.transferFrom(msg.sender, address(this), _tokenId);
        // Set Last Reward When User Deposit COW
        // If is 0, initialize it
        if (_userFarm.lastReward == 0) {
            _userFarm.lastReward = block.timestamp;
        }
        ICowNFT.CattleAttr memory cowAttr = cowNfts.attrOf(_tokenId);
        // _userFarm.cowTokenIds.push(_tokenId);
        CowBullInfo memory _cows = CowBullInfo(_tokenId, cowAttr.rarity, cowAttr.birth, cowAttr.breed, false);
        // Milk Power of farmer before deposit
        uint256 _beforeMilkpower = milkPowerOf(msg.sender);
        _userFarm.cows.push(_cows);
        // Milk Power Of Farmer after Deposit
        uint256 _milkpower = milkPowerOf(msg.sender) - _beforeMilkpower;
        totalMilkPower += _milkpower;
        initMilkPower[_tokenId] = _milkpower;
        emit DepositCow(msg.sender, _tokenId);
    }

    // Withdraw(Unstake) a Cow NFT.
    function withdrawCow(uint _tokenId) public {
        // Check if COW is breeding
        require(breedingCows[_tokenId] == false, "Cow is still breeding");

        FarmingVault storage _userFarm = userFarms[msg.sender];

        INftMinter minter = INftMinter(address(minterAddr));
        ICowNFT cowNfts = ICowNFT(address(minter.cowNftColl()));

        cowNfts.transferFrom(address(this), _userFarm.owner, _tokenId);
        harvest();

        CowBullInfo[] storage userCows = _userFarm.cows;

        for(uint idx = 0;idx < userCows.length;idx ++) {
            if(userCows[idx].tokenId == _tokenId) {
                userCows[idx] = userCows[userCows.length - 1];
                userCows.pop();
                break;
            }
        }

        totalMilkPower -= initMilkPower[_tokenId];

        emit WithdrawCow(msg.sender, _tokenId);
    }

    // Deposit (stake) Cow Tokens
    function depositCowTokens(uint256 _amount) public {
        FarmingVault storage _userFarm = userFarms[msg.sender];
        // Define Milk Power Before Staking Tokens
        uint256 _beforeMilkpower = milkPowerOf(msg.sender);
        IERC20 cowTokenContract = IERC20(address(COW_TOKEN_ADDRESS));
        cowTokenContract.transferFrom(msg.sender, address(this), _amount);
        _userFarm.stakedCow += _amount;
        uint256 _milkpower = milkPowerOf(msg.sender) - _beforeMilkpower;
        totalMilkPower += _milkpower;
    }

    function withdrawCowTokens(uint256 _amount) public {
        FarmingVault storage _userFarm = userFarms[msg.sender];
        require(_userFarm.stakedCow >= _amount, "Not enough COW");
        uint256 _beforeMilkpower = milkPowerOf(msg.sender);
        IERC20 cowTokenContract = IERC20(address(COW_TOKEN_ADDRESS));
        cowTokenContract.transfer(msg.sender, _amount);
        harvest();
        _userFarm.stakedCow -= _amount;
        // Update the Total Milk Power:
        uint256 _milkpower = milkPowerOf(msg.sender);
        totalMilkPower = totalMilkPower + _milkpower - _beforeMilkpower;
    }

    // Deposit (Stake) Bull NFT.
    function depositBull(uint _tokenId) public {
        FarmingVault storage _userFarm = userFarms[msg.sender];

        require(_totalBullLimitOf(msg.sender) >= _userFarm.bulls.length + 1, "Limit of Bulls");

        INftMinter minter = INftMinter(address(minterAddr));
        IBullNFT bullNfts = IBullNFT(address(minter.bullNftColl()));
        bullNfts.transferFrom(msg.sender, address(this), _tokenId);
        IBullNFT.CattleAttr memory bullAttr = bullNfts.attrOf(_tokenId);
        // _userFarm.cowTokenIds.push(_tokenId);
        CowBullInfo memory _bulls = CowBullInfo(_tokenId, bullAttr.rarity, bullAttr.birth, bullAttr.breed, false);
        _userFarm.bulls.push(_bulls);

        emit DepositBull(msg.sender, _tokenId);
    }

    // Withdraw (Unstake) a Bull NFT.
    function withdrawBull(uint _tokenId) public {
        require(breedingBulls[_tokenId] == false, "Bull is still breeding");
        FarmingVault storage _userFarm = userFarms[msg.sender];
        INftMinter minter = INftMinter(address(minterAddr));
        IBullNFT bullNfts = IBullNFT(address(minter.bullNftColl()));
        bullNfts.transferFrom(address(this), _userFarm.owner, _tokenId);
        CowBullInfo[] storage userBulls = _userFarm.bulls;
        for(uint idx = 0;idx < userBulls.length;idx ++) {
            if(userBulls[idx].tokenId == _tokenId) {
                userBulls[idx] = userBulls[userBulls.length - 1];
                userBulls.pop();
                break;
            }
        }

        emit WithdrawBull(msg.sender, _tokenId);
    }

    // for the happycow nft
    function depositHappyCow(uint _tokenId) public returns (uint256) {
        FarmingVault storage _userFarm = userFarms[msg.sender];
        IHappyCow nfts = IHappyCow(HAPPY_COW_ADDRESS);

        nfts.transferFrom(msg.sender, address(this), _tokenId);
        uint256 _beforeMilkpower = milkPowerOf(msg.sender);
        _userFarm.happyCowIds.push(_tokenId);
        
        uint256[] storage happyCows = _userFarm.happyCowIds;
        // happyCows = [3, 6]
        // const happyCowBreeds = [2, 0, 1, 2, 4, 2, 0, 2, 1, 3, 2,...
        happyCowBonus[msg.sender] = [0,0,0,0,0];

        for(uint idx = 0 ; idx < happyCows.length; idx ++) {
            // idx = 0
            // idx = 1
            if(happyCowBonus[msg.sender][happyCowNftBreeds[happyCows[idx]]] != 15) {
                // si [0,0,0,0,0] <- 2 = 0
                // si [0,0,15,0,0] 
                happyCowBonus[msg.sender][happyCowNftBreeds[happyCows[idx]]] = 15;
            }
            // [0, 0, 15, 0, 0]
            // [15, 0, 15, 0, 0]
        }
        // Update the Total Milk Power:
        uint256 _milkpower = milkPowerOf(msg.sender) - _beforeMilkpower;
        totalMilkPower += _milkpower;

        return happyCows.length;
    }

    function withdrawHappyCow(uint _tokenId) public {
        FarmingVault storage _userFarm = userFarms[msg.sender];
        uint256 prevWithdrawalReward = getUserRewardAmount();
        uint256 _beforeMilkpower = milkPowerOf(msg.sender);
        IERC721 happycowNft = IERC721(HAPPY_COW_ADDRESS);
        happycowNft.transferFrom(address(this), _userFarm.owner, _tokenId);
        harvest();
        uint256[] storage userHappycows = _userFarm.happyCowIds;
        for(uint idx = 0;idx < userHappycows.length;idx ++) {
            if(userHappycows[idx] == _tokenId) {
                userHappycows[idx] = userHappycows[userHappycows.length - 1];
                userHappycows.pop();
                break;
            }
        }
        uint256[5] memory  _bonus = [uint256(0),0,0,0,0];
        for(uint i = 0 ; i <userHappycows.length; i ++) {
            _bonus[happyCowNftBreeds[userHappycows[i]]] = 15;
        }
        // Recalculate milk power of the game
        uint256 _milkpower = milkPowerOf(msg.sender);
        totalMilkPower = totalMilkPower - _beforeMilkpower + _milkpower;
        uint256 postWithdrawalReward = getUserRewardAmount();
        reserveAmount[msg.sender] = prevWithdrawalReward - postWithdrawalReward;
        happyCowBonus[msg.sender] = _bonus;
    }

    // for the genesis nft
    function depositAirNft(uint _tokenId) public {
        FarmingVault storage _userFarm = userFarms[msg.sender];
        uint256 _beforeMilkpower = milkPowerOf(msg.sender);
        IERC721 airNft = IERC721(AIR_NFT_ADDRESS);
        airNft.transferFrom(msg.sender, address(this), _tokenId);
       _userFarm.airIds.push(_tokenId);
       airNftBonus[msg.sender] = 15;
        // Recalculate milk power of the game
       uint256 _milkpower = milkPowerOf(msg.sender) - _beforeMilkpower;
       totalMilkPower += _milkpower;
    }

    function withdrawAirNft(uint _tokenId) public {
        FarmingVault storage _userFarm = userFarms[msg.sender];
        uint256 prevWithdrawalReward = getUserRewardAmount();
        uint256 _beforeMilkpower = milkPowerOf(msg.sender);
        IERC721 airNft = IERC721(AIR_NFT_ADDRESS);
        airNft.transferFrom(address(this), _userFarm.owner, _tokenId);
        harvest();
        uint256[] storage userAirs = _userFarm.airIds;
        for(uint idx = 0;idx < userAirs.length;idx ++) {
            if(userAirs[idx] == _tokenId) {
                userAirs[idx] = userAirs[userAirs.length - 1];
                userAirs.pop();
                airNftBonus[msg.sender] = 0;
                break;
            }
        }
        uint256 _milkpower = milkPowerOf(msg.sender);
        totalMilkPower = totalMilkPower - _beforeMilkpower + _milkpower;
        uint256 postWithdrawalReward = getUserRewardAmount();
        reserveAmount[msg.sender] = prevWithdrawalReward - postWithdrawalReward;
    }

    function harvest() public {
        // Fetch user milkPower
        uint userMilkPower = milkPowerOf(msg.sender);
        IMasterChef masterChef = IMasterChef(address(MASTERCHEF_ADDRESS));
        masterChef.deposit(MASTERCHEF_PID, 0);
        IERC20 milkTokenContract = IERC20(address(MILK_TOKEN_ADDRESS));

        uint256 _rewardTime = block.timestamp - userFarms[msg.sender].lastReward;
        // If daysToHarvest day or more has passed from last claim
        if(block.timestamp >= userFarms[msg.sender].lastReward + daysToHarvest) {
            _rewardTime = daysToHarvest;
        }
        // If last reward is 0 (is not initialized)
        if(userFarms[msg.sender].lastReward == 0) {
            _rewardTime = 0;
        }
        
        uint256 _reward = milkPerBlock * _rewardTime  * userMilkPower / totalMilkPower;
        milkTokenContract.transfer(msg.sender, _reward);
        userFarms[msg.sender].lastReward = block.timestamp;
        reserveAmount[msg.sender] = 0;
    }

    function getUserReserveAmount() public view returns (uint256) {
        return reserveAmount[msg.sender];
    }

    function getUserRewardAmount() public view returns (uint256) {
        uint userMilkPower = milkPowerOf(msg.sender);

        uint256 _rewardTime = block.timestamp - userFarms[msg.sender].lastReward;

        if(block.timestamp >= userFarms[msg.sender].lastReward + daysToHarvest) {
            _rewardTime = daysToHarvest;
        }

        if(totalMilkPower == 0 ) {
            return 0;
        }

        uint256 _reward = milkPerBlock * _rewardTime  * userMilkPower / totalMilkPower;
        return _reward;
    }

    function getUserDailyMilk() public view returns (uint256 ) {
        uint userMilkPower = milkPowerOf(msg.sender);
        uint256 _rewardTime = 1 days;
        uint256 _reward = milkPerBlock * _rewardTime  * userMilkPower / totalMilkPower / 3;
        return _reward;
    }

    function burnMilk(uint _amount) external onlyOwner {
        IERC20 milkTokenContract = IERC20(address(MILK_TOKEN_ADDRESS));
        uint totalAmount = milkTokenContract.balanceOf(address(this));
        require(totalAmount >= _amount, "Over balance");
        milkTokenContract.transfer(msg.sender, _amount);
    }

    // Calculate MilkPower of a farmer
    function milkPowerOf(address _farmer) public view returns (uint) {
        // Define Farming and Info about cows
        FarmingVault storage _userFarm = userFarms[_farmer];
        CowBullInfo[] storage userCows = _userFarm.cows;

        // Fetch User Bonus Based on Qty of COW TOKEN
        uint cowTokenHolderBonusMultiplier = _cowTokenHolderBonusOf(_farmer);

        // Fetch User Bonus Based on Type of LAND
        uint[5] memory landNftTypeBonus = _landNftTypeBonusOf(_farmer);

        // Define Base Variable for Milk Power
        uint farmerMilkPower = 0;

        // Interating along common cows
        for(uint cowIdx = 0; cowIdx < _userFarm.cows.length; cowIdx ++) {

            // Milk Power based on Rarity
            uint cowTotalMilkPower = baseMilkPower[userCows[cowIdx].rarity];
            uint cowAgingMultiplier = 0;

            // Milk Power affected by Cow Age
            if(maxAge > (block.timestamp - userCows[cowIdx].birth)){
                cowAgingMultiplier = maxAge - (block.timestamp - userCows[cowIdx].birth);
            }
            // Milk Power based on Happy Cows Bonus (deposited on smart contract)
            // [1,1,1,1,1]
            if(happyCowBonus[_farmer][userCows[cowIdx].breed] == 0) {
                // Case 1: If this user has not a happy cow of the specified breed
                cowTotalMilkPower = cowTotalMilkPower * landNftTypeBonus[userCows[cowIdx].breed] * 10 * cowAgingMultiplier;
            } else {
                // Case 2: If this user has a happy cow of the specified breed
                cowTotalMilkPower = cowTotalMilkPower * landNftTypeBonus[userCows[cowIdx].breed] * 15 * cowAgingMultiplier;
            }

            // Add to farmerMilkPower the unitary cow milk power
            farmerMilkPower += cowTotalMilkPower;
        }

        // Milk Power based on Genesis NFT Staked
        if(airNftBonus[_farmer] == 0) {
            // Case 1: User has no Genesis Staked
            return farmerMilkPower * 10 * cowTokenHolderBonusMultiplier / 10000 / maxAge;
        } else {
            // Case 2: User has genesis staked
            return farmerMilkPower * airNftBonus[_farmer] * cowTokenHolderBonusMultiplier / 10000 / maxAge;
        }
    }

    // Calculate the milk power of all the farmers
    // function milkPowerOfGame() public view returns (uint) {
    //     for(uint farmIdx = 0; farmIdx < farms.length; farmIdx ++) {
    //         milkPowerSum += milkPowerOf(userFarms[farmIdx].owner);
    //     }
    //     return 123445;
    // }

    function landTokenIdsOf(address _owner) public view returns (uint[] memory){
        uint256[] storage userLands = userFarms[_owner].landTokenIds;
        uint[] memory tids = new uint[](userLands.length);
        for(uint iii = 0;iii < userLands.length;iii ++) {
            tids[iii] = userLands[iii];
        }
        return tids;
    }

    function cowTokenIdsOf(address _owner) public view returns (uint[] memory){
        CowBullInfo[] storage userCows = userFarms[_owner].cows;

        uint[] memory tids = new uint[](userCows.length);
        for(uint iii = 0;iii < userCows.length;iii ++) {
            tids[iii] = userCows[iii].tokenId;
        }
        return tids;
    }

    function breedingCowTokenIdsOf(address _owner) public view returns (uint[] memory){
        CowBullInfo[] storage userCows = userFarms[_owner].cows;

        uint256 count = 0;
        for(uint i = 0 ; i < userCows.length; i ++) {
            if(!userCows[i].isBreeding) {
                count +=1;
            }
        }
        uint[] memory tids = new uint[](count);
        uint k = 0 ;
        for(uint iii = 0;iii < userCows.length;iii ++) {
            if(!userCows[iii].isBreeding) {
                tids[k] =  userCows[iii].tokenId;
                k++;
            }
        }
        return tids;
    }


    function bullTokenIdsOf(address _owner) public view returns (uint[] memory){
        CowBullInfo[] storage userBulls = userFarms[_owner].bulls;
        uint[] memory tids = new uint[](userBulls.length);
        for(uint iii = 0;iii < userBulls.length;iii ++) {
            tids[iii] = userBulls[iii].tokenId;
        }
        return tids;
    }

    function breedingBullTokenIdsOf(address _owner) public view returns (uint[] memory){
        CowBullInfo[] storage userBulls = userFarms[_owner].bulls;
        uint256 count = 0;
        for(uint i = 0 ; i < userBulls.length; i ++) {
            if(!userBulls[i].isBreeding) {
                count +=1;
            }
        }
        uint[] memory tids = new uint[](count);
        uint k = 0 ;
        for(uint iii = 0;iii < userBulls.length;iii ++) {
            if(!userBulls[iii].isBreeding) {
                tids[k] = userBulls[iii].tokenId;
                k++;
            }
        }
        return tids;
    }

    // Fetch Happy Cows Deposited by User
    function happyCowTokenIdsOf(address _owner) public view returns (uint[] memory){
        FarmingVault storage _userFarm = userFarms[_owner];
        return _userFarm.happyCowIds;
    }

    // Fetch Genesis Tokens Deposited by User
    function genesisTokenIdsOf(address _owner) public view returns (uint[] memory){
        FarmingVault storage _userFarm = userFarms[_owner];
        return _userFarm.airIds;
    }

    // Fetch Staked Cow From User
    function stakedCowOf(address _owner) public view returns (uint) {
        FarmingVault storage _userFarm = userFarms[_owner];
        return _userFarm.stakedCow;
    }

    // Set NftMinter contract address. Can be called only by the owner.
    function setMinterContract(address _newMinterAddr) public onlyOwner {
        require(_newMinterAddr != address(0), "Set by zero address");
        minterAddr = _newMinterAddr;
    }

    // Set MaxAge
    function setMaxAge(uint _newMaxAge) public onlyOwner {
        require(_newMaxAge > 0, "Must be non-zero");
        maxAge = _newMaxAge;
    }

    // // Set Genesis NFTs' tokenIds.
    function setGenesisTokenIds(uint256[] calldata _genesisTokenIds) public onlyOwner {
        genesisTokenIds = _genesisTokenIds;
    }

    // // Set HappyCow NFTs' Breed attributes.
    function setHappyCowNftBreeds(uint[] calldata _happyCowNftBreeds) public onlyOwner {
        happyCowNftBreeds = _happyCowNftBreeds;
    }

    // Get total Cow limits of a farmer.
    function _totalCowLimitOf(address _farmer) public view returns (uint) {
        uint256[] storage userLands = userFarms[_farmer].landTokenIds;
        uint totalCowLimit = 0;
        INftMinter minter = INftMinter(address(minterAddr));
        ILandNFT landNfts = ILandNFT(address(minter.landNftColl()));
        for(uint idx = 0;idx < userLands.length;idx ++) {
            ILandNFT.LandAttr memory attr = landNfts.attrOf(userLands[idx]);
            totalCowLimit += cowLimitPerLand[attr.rarity];
        }
        return totalCowLimit;
    }

    // Get total Bull limits of a farmer.
    function _totalBullLimitOf(address _farmer) public view returns (uint) {
        uint256[] storage userLands = userFarms[_farmer].landTokenIds;
        uint totalBullLimit = 0;
        INftMinter minter = INftMinter(address(minterAddr));
        ILandNFT landNfts = ILandNFT(address(minter.landNftColl()));
        for(uint idx = 0;idx < userLands.length;idx ++) {
            ILandNFT.LandAttr memory attr = landNfts.attrOf(userLands[idx]);
            totalBullLimit += bullLimitPerLand[attr.rarity];
        }
        return totalBullLimit;
    }

    // Calculate $COW Holder Bonus. 11 - 20
    function _cowTokenHolderBonusOf(address _farmer) private view returns(uint) {
        FarmingVault storage _userFarm = userFarms[_farmer];
        uint amount = _userFarm.stakedCow*10**COW_TOKEN_DECIMALS;

        if(amount < 10*10**COW_TOKEN_DECIMALS) {
            return 10;
        } else if(amount < 20*10**COW_TOKEN_DECIMALS) {
            return 11;
        } else if(amount < 30*10**COW_TOKEN_DECIMALS) {
            return 12;
        } else if(amount < 50*10**COW_TOKEN_DECIMALS) {
            return 13;
        } else if(amount < 80*10**COW_TOKEN_DECIMALS) {
            return 14;
        } else if(amount < 130*10**COW_TOKEN_DECIMALS) {
            return 15;
        } else if(amount < 210*10**COW_TOKEN_DECIMALS) {
            return 16;
        } else if(amount < 340*10**COW_TOKEN_DECIMALS) {
            return 17;
        } else if(amount < 550*10**COW_TOKEN_DECIMALS) {
            return 18;
        } else if(amount < 890*10**COW_TOKEN_DECIMALS) {
            return 19;
        } else if (amount >= 890*10**COW_TOKEN_DECIMALS) {
            return 20;
        } else {
            return 10;
        }
    }

    // Calculate CashCow Genesis NFT Holder Bonus. 10 or 15
    // function _genesisNftHolderBonusOf(address _farmer) public view returns(uint) {
    //     uint256 airCount = userFarms[_farmer].airIds.length;
    //     if(airCount >0) {
    //         return 15;
    //     }
    //     return 10;
    // }

    // Calculate CashCow HappyCow NFT Holder Bonus. 10 or 15
    // function _happyCowNftHolderBonusOf(address _farmer) public view returns(uint[5] memory) {
    //     uint[5] memory bonuses = [(uint)(10), 10, 10, 10, 10];
    //     uint256[] storage mynfts = userFarms[_farmer].happyCowIds;
    //     for(uint idx = 0;idx < mynfts.length;idx ++) {
    //         bonuses[happyCowNftBreeds[mynfts[idx]]] = 15;
    //     }
    
    //     return bonuses;
    // }

    // Calculate Land NFT Type Bonus.
    function _landNftTypeBonusOf(address _farmer) public view returns(uint[5] memory) {

        FarmingVault storage _userFarm = userFarms[_farmer];
        uint[5] memory bonuses = [(uint)(10), 10, 10, 10, 10];
        // uint[5] memory bonuses = [10, 10, 10, 10, 10];
        INftMinter minter = INftMinter(address(minterAddr));
        ILandNFT landNfts = ILandNFT(address(minter.landNftColl()));
        for(uint landIdx = 0;landIdx < _userFarm.landTokenIds.length;landIdx ++) {
            ILandNFT.LandAttr memory attr = landNfts.attrOf(_userFarm.landTokenIds[landIdx]);
            bonuses[attr.landType] = 15;
        }
        return bonuses;
    }

    function breed(uint _cowTokenId, uint _bullTokenId) public {
        FarmingVault storage _userFarm = userFarms[msg.sender];
        CowBullInfo[] storage cows = _userFarm.cows;
        CowBullInfo[] storage bulls = _userFarm.bulls;
        bool isCowAvailable = false;
        bool isBullAvailable = false;
        uint256 cowIdx = 0;
        uint256 bullIdx = 0;

        for(uint256 i = 0 ; i < cows.length; i++) {
            if(cows[i].tokenId == _cowTokenId && !cows[i].isBreeding) {
                cows[i].isBreeding = true;
                isCowAvailable = true;
                cowIdx = i;
            }
        }

        for(uint256 j = 0 ; j < bulls.length; j++) {
            if(bulls[j].tokenId == _bullTokenId && !bulls[j].isBreeding) {
                bulls[j].isBreeding = true;
                isBullAvailable = true;
                bullIdx = j;
            }
        }

        CowBullInfo storage cowInfo = cows[cowIdx];
        CowBullInfo storage bullInfo = bulls[bullIdx];
        require(isCowAvailable, "unstaked cow token");
        require(isBullAvailable, "unStaked bull token");
        uint256 _old = block.timestamp - bullInfo.birth;

        require(cowInfo.rarity == bullInfo.rarity, "Breeding is impossible between different rarity");
        require(maxRecoveryTime > _old, "Bull is too old");
        // Set Breeding Status on true (experimental feature)
        breedingCows[_cowTokenId] = true;
        breedingBulls[_bullTokenId] = true;

        IERC20(address(MILK_TOKEN_ADDRESS)).transferFrom(msg.sender, address(this), breedingPrice);

        BreedingVault memory newBreeding;
        newBreeding.cowTokenInfo = cowInfo;
        newBreeding.bullTokenInfo = bullInfo;
        newBreeding.owner = msg.sender;

        uint256 weight =1e8 - ((maxRecoveryTime - _old) * 1e8) / maxRecoveryTime;
        newBreeding.unlockTime = block.timestamp + baseRecoveryTime[bullInfo.rarity] + (baseRecoveryTime[bullInfo.rarity] * weight) /1e8;
        breedingVaults.push(newBreeding);
    }

    function _indexOfBreedingByBull(uint _bullTokenId) private view returns (uint) {
        uint idx = 0;
        for(idx = 0;idx < breedingVaults.length;idx ++){
            if(breedingVaults[idx].bullTokenInfo.tokenId == _bullTokenId) {
                return idx;
            }
        }
        return idx;
    }

    function setBreedingPrice(uint _price) public onlyOwner {
        breedingPrice = _price;
    }

    function withdrawMilk() public onlyOwner{
        IERC20 payToken = IERC20(address(MILK_TOKEN_ADDRESS));
        uint amountOf = payToken.balanceOf(address(this));
        payToken.transfer(msg.sender, amountOf);
    }

    function _rand(uint _modulus, uint256 _seed) internal view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _seed))) % _modulus;
    }

    function claimCattle(uint _bullTokenId, uint256[] memory _seed) public {
        uint breedingIdx = _indexOfBreedingByBull(_bullTokenId);
        address _owner = breedingVaults[breedingIdx].owner;
        CowBullInfo storage cowInfo = breedingVaults[breedingIdx].cowTokenInfo;
        CowBullInfo storage bullInfo = breedingVaults[breedingIdx].bullTokenInfo;
        // uint256 _cowTokenId = cowInfo.tokenId;
        // uint256 _bullTokenId = bullInfo.tokenId;
        require(_owner == msg.sender, "Not owner");
        require(block.timestamp > breedingVaults[breedingIdx].unlockTime, "Wait until Recovery");

        INftMinter minter = INftMinter(address(minterAddr));

        uint8 rarityOfNew = 0;
        uint8 breedOfNew = bullInfo.breed;

        uint randProbability = _rand(100, _seed[0]);
        if(randProbability < rarityProbability || bullInfo.rarity == 4) {
            rarityOfNew = bullInfo.rarity;
        } else {
            rarityOfNew = bullInfo.rarity + 1;
        }
        randProbability = _rand(100, _seed[1]);
        if(randProbability < breedProbability) {
            breedOfNew = cowInfo.breed;
        }
        randProbability = _rand(100, _seed[2]);
        if(randProbability < cowProbability) {
            minter.mintCow(_owner, rarityOfNew, breedOfNew);
        } else {
            minter.mintBull(_owner, rarityOfNew, breedOfNew);
        }

        // Breeding Mapping
        breedingCows[cowInfo.tokenId] = false;
        breedingBulls[bullInfo.tokenId] = false;

        // cowInfo.isBreeding = false;
        // bullInfo.isBreeding = false;

        CowBullInfo[] storage _cows = userFarms[msg.sender].cows;
        CowBullInfo[] storage _bulls = userFarms[msg.sender].bulls;

        for(uint i = 0 ; i < _cows.length; i ++) {
            if(_cows[i].tokenId == cowInfo.tokenId) {
                _cows[i].isBreeding = false;
            }
        }

        for(uint j = 0 ; j < _bulls.length; j ++) {
            if(_bulls[j].tokenId == bullInfo.tokenId) {
                _bulls[j].isBreeding = false;
            }
        }

        breedingVaults[breedingIdx] = breedingVaults[breedingVaults.length - 1];
        breedingVaults.pop();
    }

    // function getUserBreedingInfo(address _owner) public view returns (uint[] memory) {
    //     return userBreedings[_owner];
    // }

    function getBreedingItems(address userAddress) public view 
    returns(
        uint256[] memory ,
        uint256[] memory ,
        uint256[] memory ,
        uint256[] memory ,
        uint256[] memory ,
        uint256[] memory 
    ) {
        uint k = 0;
        uint ownedCount = 0;
        for(uint j = 0 ; j< breedingVaults.length ; j ++ ) {
            if(breedingVaults[j].owner == userAddress) {
                ownedCount +=1;
            }
        }
        uint256[] memory cowTokenIds = new uint256[](ownedCount);
        uint256[] memory raritis = new uint256[](ownedCount);
        uint256[] memory cowBreeds = new uint256[](ownedCount);
        uint256[] memory bullTokenIds = new uint256[](ownedCount);
        uint256[] memory bullBreeds = new uint256[](ownedCount);
        uint256[] memory unLockTimes = new uint256[](ownedCount);
        for(uint i = 0 ; i < breedingVaults.length; i++) {
            if(breedingVaults[i].owner == userAddress) {
                cowTokenIds[k] = breedingVaults[i].cowTokenInfo.tokenId;
                raritis[k] = breedingVaults[i].cowTokenInfo.rarity;
                cowBreeds[k] = breedingVaults[i].cowTokenInfo.breed;
                bullTokenIds[k] = breedingVaults[i].bullTokenInfo.tokenId;
                bullBreeds[k] = breedingVaults[i].bullTokenInfo.breed;
                unLockTimes[k] = breedingVaults[i].unlockTime;
                k +=1;
            }
        }
        return (cowTokenIds, raritis,cowBreeds,bullTokenIds,bullBreeds,unLockTimes);
    }

    function setProbabilities(uint256 _rarityP, uint256 _breedP, uint256 _cowP) public onlyOwner {
        rarityProbability = _rarityP;
        breedProbability = _breedP;
        cowProbability = _cowP;
    }


}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface INftMinter{

  function initialize(address _landCollAddr, address _cowCollAddr, address _bullCollAddr) external;

  function mintLand(address _owner, uint8 _rarity, uint8 _type) external;
  function mintCow(address _owner, uint8 _rarity, uint8 _breed) external;
  function mintBull(address _owner, uint8 _rarity, uint8 _breed) external;

  function landNftColl() external view returns (address);
  function setLandNftColl(address) external;
  function cowNftColl() external view returns (address);
  function setCowNftColl(address) external;
  function bullNftColl() external view returns (address);
  function setBullNftColl(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface IMasterChef {
  function deposit(uint256 _pid, uint256 _amount) external;
  function withdraw(uint256 _pid, uint256 _amount) external;
  function emergencyWithdraw(uint256 _pid) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ILandNFT is IERC721 {
  struct LandAttr{
    uint8 rarity;
    uint8 landType;
  }
  function mint(uint8 _rarity, uint8 _landType, address) external;
  function setBaseTokenURI(string memory _baseUri) external;
  function attrOf(uint _tokenId) external view returns (LandAttr memory);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IHappyCow is IERC721{
  function totalSupply() external view returns (uint256);
  function fetchMyNfts() external view returns (uint256[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ICowNFT is IERC721 {
  struct CattleAttr{
    uint8 rarity;
    uint8 breed;
    uint256 birth;
  }
  function mint(uint8 _rarity, uint8 _breed, address _owner) external;
  function burn(uint _tokenId) external;
  function setBaseTokenURI(string memory _baseUri) external;
  function attrOf(uint _tokenId) external view returns (CattleAttr memory);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IBullNFT is IERC721 {
  struct CattleAttr{
    uint8 rarity;
    uint8 breed;
    uint256 birth;
  }
  function mint(uint8 _rarity, uint8 _breed, address _owner) external;
  function burn(uint _tokenId) external;
  function setBaseTokenURI(string memory _baseUri) external;
  function attrOf(uint _tokenId) external view returns (CattleAttr memory);
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