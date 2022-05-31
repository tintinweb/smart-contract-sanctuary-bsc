// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/INftMinter.sol";
import "./interfaces/ILandNFT.sol";
import "./interfaces/ICowNFT.sol";
import "./interfaces/IBullNFT.sol";
import "./interfaces/IMasterChef.sol";
import "./interfaces/IHappyCow.sol";

contract Farming is ReentrancyGuard, Ownable {
    //address constant HAPPY_COW_ADDRESS = 0xf470C4B8564B1069E34Eaf00B26e6892A5391d80;
    //address constant AIR_NFT_ADDRESS = 0xF5db804101d8600c26598A1Ba465166c33CdAA4b;
    //address constant COW_TOKEN_ADDRESS = 0x8B6fA031c7D2E60fbFe4E663EC1B8f37Df1ba483;
    //address constant MASTERCHEF_ADDRESS = 0x94098E24FCf4701237CF58ef2A222C1cF5003c86;
    //address constant MILK_TOKEN_ADDRESS = 0xe5bd6C5b1c2Df8f499847a545838C09E45f4A262;
    //address constant SECRET_LP_ADDRESS = ;
    uint constant COW_TOKEN_DECIMALS = 9;
    uint constant MASTERCHEF_PID =5;
    
    address constant HAPPY_COW_ADDRESS = 0xD220d3E1bab3A30f170E81b3587fa382BB4A6263; // Deployed on testnet, For TEST
    address constant AIR_NFT_ADDRESS = 0x74A9Bb4F6b05236507614cA70d32f65436064786; // Deployed on testnet, For TEST
    address constant COW_TOKEN_ADDRESS = 0x562d2BFc80FD1afF3bF5e4Bd8Fa5312E65305C14; // Deployed on testnet, For TEST
    address constant MILK_TOKEN_ADDRESS = 0x3eFA66aB2b1690e9BE8e82784EDfF2cF2dc150e0; // Deployed on testnet, For TEST
    address constant MASTERCHEF_ADDRESS = 0xB11C302675FD4a0bD725ecB7e0c3b9F6a3caEa8b; // Deployed on testnet, For TEST
    address constant SECRET_LP_ADDRESS = 0xC25e8b265Ee64A0CDE09347dC8d3e40419E8311f; // Deployed on testnet, For TEST
    
    
    
    address public minterAddr; // NftMinter contract address

    // Structure of FarmingVault
    struct CowInfo {
        uint256 tokenId;
        uint256 rarity;
        uint256 birth;
        uint256 breed;
    }
    struct FarmingVault {
        uint[] landTokenIds; // Array of Lands to be staked
        // uint[] cowTokenIds; // Array of Cows to be staked
        uint[] bullTokenIds; // Array of Cows to be staked
        address owner; // Owner of the farm. Can be used as primary key of the farm.
        uint lastReward; // block time of last reward
        CowInfo[] cows;
    }
    // FarmingVault[] public farms; // Array of farms
    mapping(uint256 => uint256 ) public initMilkPower;
    mapping(address => FarmingVault) public userFarms;
    mapping(uint256 => uint256) public cowLimitPerLand;
    mapping(uint256 => uint256) public bullLimitPerLand;

    mapping(uint256 => uint256) public baseMilkPower; // Base MilkPower of Cows by rarity
    
    uint public maxAge = 200 days; // Maximum age of Cow and Bull. Used to change the aging speed.
    uint256 public totalMilkPower;
    uint256[] public happyCowNftBreeds;
    uint[] public genesisTokenIds;
    uint256 public happyCowNumber = 336;
    uint256 public milkPerBlock;
    event DepositLand(address _owner, uint _tokenId);
    event WithdrawLand(address _owner, uint _tokenId);
    event DepositCow(address _owner, uint _tokenId);
    event WithdrawCow(address _owner, uint _tokenId);
    event DepositBull(address _owner, uint _tokenId);
    event WithdrawBull(address _owner, uint _tokenId);

    // From here, state variables for test
    //address public genesisNftContractAddr; // For TEST
    //address public happyCowNftContractAddr; // For TEST
    //address public cowTokenAddr; // For TEST
    // To here, state variables for test

    // Initialize the contract. This is for Proxy functionality.  Can be called only by the owner.
    function initialize(address _minterAddr) public onlyOwner {
        require(_minterAddr != address(0), "Initializing by zero address");
        minterAddr = _minterAddr;

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
        require(_totalBullLimitOf(msg.sender) - bullLimitPerLand[attr.rarity] >= _userFarm.cows.length, "Bull Limit: Withdraw Bulls first");
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
        ICowNFT.CattleAttr memory cowAttr = cowNfts.attrOf(_tokenId);
        // _userFarm.cowTokenIds.push(_tokenId);
        CowInfo memory _cows = CowInfo(_tokenId, cowAttr.rarity, cowAttr.birth, cowAttr.breed);
        _userFarm.cows.push(_cows);
        uint256 _milkpower = milkPowerOf(msg.sender);
        totalMilkPower += _milkpower;
        initMilkPower[_tokenId] = _milkpower;
        emit DepositCow(msg.sender, _tokenId);
    }

    // Withdraw(Unstake) a Cow NFT.
    function withdrawCow(uint _tokenId) public {
        FarmingVault storage _userFarm = userFarms[msg.sender];
        INftMinter minter = INftMinter(address(minterAddr));
        ICowNFT cowNfts = ICowNFT(address(minter.cowNftColl()));
        cowNfts.transferFrom(address(this), _userFarm.owner, _tokenId);
        CowInfo[] storage userCows = _userFarm.cows;
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

    // Deposit(Stake)  Bull NFT.
    function depositBull(uint _tokenId) public {
        FarmingVault storage _userFarm = userFarms[msg.sender];

        require(_totalBullLimitOf(msg.sender) >= _userFarm.bullTokenIds.length + 1, "Limit of Bulls");

        INftMinter minter = INftMinter(address(minterAddr));
        IBullNFT bullNfts = IBullNFT(address(minter.bullNftColl()));
        bullNfts.transferFrom(msg.sender, address(this), _tokenId);
       _userFarm.bullTokenIds.push(_tokenId);

        emit DepositBull(msg.sender, _tokenId);
    }

    // Withdraw(Unstake) a Bull NFT.
    function withdrawBull(uint _tokenId) public {
        FarmingVault storage _userFarm = userFarms[msg.sender];
        INftMinter minter = INftMinter(address(minterAddr));
        IBullNFT bullNfts = IBullNFT(address(minter.bullNftColl()));
        bullNfts.transferFrom(address(this), _userFarm.owner, _tokenId);
        uint256[] storage userBulls = _userFarm.bullTokenIds;
        for(uint idx = 0;idx < userBulls.length;idx ++) {
            if(userBulls[idx] == _tokenId) {
                userBulls[idx] = userBulls[userBulls.length - 1];
                userBulls.pop();
                break;
            }
        }

        emit WithdrawBull(msg.sender, _tokenId);
    }

    function harvest() external {

        uint userMilkPower = milkPowerOf(msg.sender);
        IMasterChef masterChef = IMasterChef(address(MASTERCHEF_ADDRESS));
        masterChef.deposit(MASTERCHEF_PID, 0);
        IERC20 milkTokenContract = IERC20(address(MILK_TOKEN_ADDRESS));

        uint256 _rewardTime = block.timestamp - userFarms[msg.sender].lastReward;
        if(block.timestamp >= userFarms[msg.sender].lastReward + 1 days) {
            _rewardTime = 1 days;
        }
        uint256 _reward = milkPerBlock * _rewardTime  * userMilkPower / totalMilkPower / 3;
        milkTokenContract.transfer(msg.sender, _reward);
        userFarms[msg.sender].lastReward = block.timestamp;
    }
    function getUserRewardAmount() public view returns (uint256 ) {
        uint userMilkPower = milkPowerOf(msg.sender);

        uint256 _rewardTime = 0;
        if(block.timestamp >= userFarms[msg.sender].lastReward + 1 days) {
            _rewardTime = 1 days;
        } else {
            _rewardTime = block.timestamp - userFarms[msg.sender].lastReward;
        }
        uint256 _reward = milkPerBlock * _rewardTime  * userMilkPower / totalMilkPower / 3;
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
        // INftMinter minter = INftMinter(address(minterAddr));
        // ICowNFT cowNfts = ICowNFT(address(minter.cowNftColl()));
        FarmingVault storage _userFarm = userFarms[_farmer];
        CowInfo[] storage userCow = _userFarm.cows;
        uint genesisNftHolderBonusMultiplier = _genesisNftHolderBonusOf(_farmer);
        uint cowTokenHolderBonusMultiplier = _cowTokenHolderBonusOf(_farmer);
        uint[5] memory landNftTypeBonus = _landNftTypeBonusOf(_farmer);
        uint[5] memory happyCowNftHolderBonus = _happyCowNftHolderBonusOf(_farmer);
        uint farmerMilkPower = 0;
        for(uint cowIdx = 0; cowIdx < _userFarm.cows.length;cowIdx ++) {
            // ICowNFT.CattleAttr memory attr = cowNfts.attrOf(_userFarm.cows[cowIdx].tokenId);
            uint cowTotalMilkPower = baseMilkPower[userCow[cowIdx].rarity];
            uint cowAgingMultiplier = 0;
            if(maxAge > (block.timestamp - userCow[cowIdx].birth)){
                cowAgingMultiplier = maxAge - (block.timestamp - userCow[cowIdx].birth);
            }
            // uint cowAgingMultiplier = maxAge - 3 days; // For TEST
            cowTotalMilkPower = cowTotalMilkPower * landNftTypeBonus[userCow[cowIdx].breed] * happyCowNftHolderBonus[userCow[cowIdx].breed] * cowAgingMultiplier;
            cowTotalMilkPower = cowTotalMilkPower ;
            farmerMilkPower += cowTotalMilkPower;
        }

        return farmerMilkPower * genesisNftHolderBonusMultiplier * cowTokenHolderBonusMultiplier / 10000 / maxAge;
    }

    function landTokenIdsOf(address _owner) public view returns (uint[] memory){
        uint256[] storage userLands = userFarms[_owner].landTokenIds;
        uint[] memory tids = new uint[](userLands.length);
        for(uint iii = 0;iii < userLands.length;iii ++) {
            tids[iii] = userLands[iii];
        }
        return tids;
    }

    function cowTokenIdsOf(address _owner) public view returns (uint[] memory){
        CowInfo[] storage userCows = userFarms[_owner].cows;

        uint[] memory tids = new uint[](userCows.length);
        for(uint iii = 0;iii < userCows.length;iii ++) {
            tids[iii] = userCows[iii].tokenId;
        }
        return tids;
    }

    function bullTokenIdsOf(address _owner) public view returns (uint[] memory){
        uint256[] storage userBulls = userFarms[_owner].bullTokenIds;
        uint[] memory tids = new uint[](userBulls.length);
        for(uint iii = 0;iii < userBulls.length;iii ++) {
            tids[iii] = userBulls[iii];
        }
        return tids;
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

    // Set Genesis NFTs' tokenIds.
    function setGenesisTokenIds(uint256[] calldata _genesisTokenIds) public onlyOwner {
        genesisTokenIds = _genesisTokenIds;
    }

    // Set HappyCow NFTs' Breed attributes.
    function setHappyCowNftBreeds(uint256[] calldata _happyCowNftBreeds) public onlyOwner {
        happyCowNftBreeds= _happyCowNftBreeds;
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
        IERC20 cowTokenContract = IERC20(address(COW_TOKEN_ADDRESS));
        uint amount = cowTokenContract.balanceOf(_farmer);

        if(amount < 10*10**COW_TOKEN_DECIMALS) {
            return 10;
        }
        if(amount < 20*10**COW_TOKEN_DECIMALS) {
            return 11;
        }
        if(amount < 30*10**COW_TOKEN_DECIMALS) {
            return 12;
        }
        if(amount < 50*10**COW_TOKEN_DECIMALS) {
            return 13;
        }
        if(amount < 80*10**COW_TOKEN_DECIMALS) {
            return 14;
        }
        if(amount < 130*10**COW_TOKEN_DECIMALS) {
            return 15;
        }
        if(amount < 210*10**COW_TOKEN_DECIMALS) {
            return 16;
        }
        if(amount < 340*10**COW_TOKEN_DECIMALS) {
            return 17;
        }
        if(amount < 550*10**COW_TOKEN_DECIMALS) {
            return 18;
        }
        if(amount < 890*10**COW_TOKEN_DECIMALS) {
            return 19;
        }
        return 20;
    }

    // Calculate CashCow Genesis NFT Holder Bonus. 10 or 15
    function _genesisNftHolderBonusOf(address _farmer) public view returns(uint) {
        IERC721 genesisNfts = IERC721(address(AIR_NFT_ADDRESS));
        uint256 _balance = genesisNfts.balanceOf(_farmer);
        if(_balance >0) {
            return 15;
        }
        // for(uint idx = 0;idx < genesisTokenIds.length;idx ++) {
        //     //IERC721 genesisNfts = IERC721(address(genesisNftContractAddr)); // For TEST
        //     if(genesisNfts.ownerOf(genesisTokenIds[idx]) == _farmer) {
        //         return 15;
        //     }
        // }
        return 10;
    }

    // Calculate CashCow HappyCow NFT Holder Bonus. 10 or 15
    function _happyCowNftHolderBonusOf(address _farmer) public view returns(uint[5] memory) {
        uint[5] memory bonuses = [(uint)(10), 10, 10, 10, 10];
        IHappyCow happyCowNfts = IHappyCow(address(HAPPY_COW_ADDRESS));
        uint256[] memory mynfts = happyCowNfts.fetchMyNfts();
        for(uint idx = 0;idx < mynfts.length;idx ++) {
            if(happyCowNfts.ownerOf(mynfts[idx]) == _farmer) {
                bonuses[happyCowNftBreeds[mynfts[idx]]] = 15;
            }
        }
    
        return bonuses;
    }

    // Calculate Land NFT Type Bonus.
    function _landNftTypeBonusOf(address _farmer) public view returns(uint[5] memory) {

        FarmingVault storage _userFarm = userFarms[_farmer];
        uint[5] memory bonuses = [(uint)(10), 10, 10, 10, 10];
        INftMinter minter = INftMinter(address(minterAddr));
        ILandNFT landNfts = ILandNFT(address(minter.landNftColl()));
        for(uint landIdx = 0;landIdx < _userFarm.landTokenIds.length;landIdx ++) {
            ILandNFT.LandAttr memory attr = landNfts.attrOf(_userFarm.landTokenIds[landIdx]);
            bonuses[attr.landType] = 15;
        }
        return bonuses;
    }

    function sethappyCowTotalSupply(uint256 newValue) external onlyOwner {
        happyCowNumber = newValue;
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
  function MilkPerBlock() external view returns(uint256);
  function totalAllocPoint() external view returns(uint256);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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