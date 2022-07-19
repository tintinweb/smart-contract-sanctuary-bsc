// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Interfaces.sol";

contract Staking is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 pendingRewards;
    }

    struct PoolInfo {
        IERC20 lpToken;
        uint256 lastRewardBlock;
        uint256 accBZAIPerShare;
    }

    IAddresses public gameAddresses;
    IERC20 public BZAI;

    mapping(address => uint256) _lastIndexUserReceivedFees;
    mapping(uint256 => uint256) _feesReceivedAtBlock;
    mapping(uint256 => uint256) _totalLpsAtBlock;
    uint256 public totalHistoryFees;
    uint256[] _blockReceivedFees;

    uint256 public BZAIPerBlock = 317 * 1E16; // 3,17 BZAI per block => 50M initial reward / 365 / 43200(block per day in polygon mainnet); 
    uint256 public remainingBZAIReward = 50000000 * 1E18;

    uint256 public minGasNeeded = 12000;

    PoolInfo public liquidityMining;
    mapping(address => UserInfo) public userInfo;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount);

    modifier onlyGame() {
        require(msg.sender == IAddresses(gameAddresses).getPaymentsAddress(), "Only game allowed");
        _;
    }

    //set Platform
    function setGameAddresses(address _gameAddress) public onlyOwner {
        gameAddresses = IAddresses(_gameAddress);
    }

    function setMinGasNeeded(uint256 _minGasNeeded) public onlyOwner {
        minGasNeeded = _minGasNeeded;
    }

    function setTokensAddress(IERC20 _bzai, IERC20 _lpToken) external onlyOwner {
        require(address(BZAI) == address(0) && address(liquidityMining.lpToken) == address(0), 'Tokens already set!');
        BZAI = _bzai;
        liquidityMining =
            PoolInfo({
                lpToken: _lpToken,
                lastRewardBlock: 0,
                accBZAIPerShare: 0
        });
    }
    
    function startMining(uint256 startBlock) external onlyOwner {
        require(liquidityMining.lastRewardBlock == 0, 'Mining already started');
        liquidityMining.lastRewardBlock = startBlock;
        _blockReceivedFees.push(startBlock);
    }

    function getMiningStarted() external view returns(bool){
        return liquidityMining.lastRewardBlock == 0;
    }

    function pendingRewards(address _user) external view returns (uint256) {
        require(liquidityMining.lastRewardBlock > 0 && block.number >= liquidityMining.lastRewardBlock, 'Mining not yet started');
        UserInfo storage user = userInfo[_user];
        uint256 accBZAIPerShare = liquidityMining.accBZAIPerShare;
        uint256 lpSupply = liquidityMining.lpToken.balanceOf(address(this));

        if (block.number > liquidityMining.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = block.number - liquidityMining.lastRewardBlock;
            uint256 bzaiReward = multiplier * BZAIPerBlock;
            accBZAIPerShare = liquidityMining.accBZAIPerShare + (bzaiReward * 1e12 / lpSupply);
        }
        return user.amount * accBZAIPerShare / 1e12 - user.rewardDebt + user.pendingRewards;
    }

    function updatePool() internal {
        require(liquidityMining.lastRewardBlock > 0 && block.number >= liquidityMining.lastRewardBlock, 'Mining not yet started');
        if (block.number <= liquidityMining.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = liquidityMining.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            liquidityMining.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = block.number - liquidityMining.lastRewardBlock;
        uint256 bzaiReward = multiplier * BZAIPerBlock;
        liquidityMining.accBZAIPerShare = liquidityMining.accBZAIPerShare + (bzaiReward * 1e12 / lpSupply);
        liquidityMining.lastRewardBlock = block.number;
    }

    function deposit(uint256 amount) external {
        UserInfo storage user = userInfo[msg.sender];
        updatePool();
        if (user.amount > 0) {
            _harvestFees(msg.sender);
            uint256 pending = user.amount * liquidityMining.accBZAIPerShare / 1e12 - user.rewardDebt;
            if (pending > 0) {
                user.pendingRewards += pending;
            }
        }
        if (amount > 0) {
            liquidityMining.lpToken.safeTransferFrom(address(msg.sender), address(this), amount);
            user.amount += amount;
            remainingBZAIReward -= amount;
            _lastIndexUserReceivedFees[msg.sender] = _blockReceivedFees.length - 1;
        }
        user.rewardDebt = user.amount * liquidityMining.accBZAIPerShare / 1e12;
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= amount, "Withdrawing more than you have!");
        updatePool();
        _harvestFees(msg.sender);
        uint256 pending = user.amount * liquidityMining.accBZAIPerShare / 1e12 - user.rewardDebt;
        if (pending > 0) {
            user.pendingRewards += pending;
        }
        if (amount > 0) {
            user.amount -= amount;
            liquidityMining.lpToken.safeTransfer(address(msg.sender), amount);
            remainingBZAIReward -= amount;
        }
        user.rewardDebt = user.amount * liquidityMining.accBZAIPerShare / 1e12;
        emit Withdraw(msg.sender, amount);
    }

    function claim() external {
        UserInfo storage user = userInfo[msg.sender];
        updatePool();
        _harvestFees(msg.sender);
        uint256 pending = user.amount * liquidityMining.accBZAIPerShare / 1e12 - user.rewardDebt;
        if (pending > 0 || user.pendingRewards > 0) {
            user.pendingRewards += pending;
            uint256 claimedAmount = _safeBzaiTransfer(msg.sender, user.pendingRewards);
            remainingBZAIReward -= claimedAmount;

            emit Claim(msg.sender, claimedAmount);
            user.pendingRewards -= claimedAmount;
        }
        user.rewardDebt = user.amount * liquidityMining.accBZAIPerShare / 1e12;
    }

    function _safeBzaiTransfer(address to, uint256 amount) internal returns (uint256) {
        if (amount > remainingBZAIReward) {
            BZAI.safeTransfer(to, remainingBZAIReward);
            return remainingBZAIReward;
        } else {
            BZAI.safeTransfer(to, amount);
            return amount;
        }
    }

// ========================================================
//           BZAI fees for stakers               
// ========================================================

    function getBZAIRewardForUser(address _user) external view returns (uint256 amount){
        (amount, ) = _getBZAIRewardForUser(_user);
    }

    function _harvestFees(address _user) internal nonReentrant{
        (uint256 _toSend, uint256 _lastBlockReceivedFees) = _getBZAIRewardForUser(_user);
        _lastIndexUserReceivedFees[_user] = _lastBlockReceivedFees;
        if(_toSend > 0){
           _safeBzaiTransfer(_user,_toSend);
        }
    }

        // get the reward value user can claim
    function _getBZAIRewardForUser(address _user) internal view returns (uint256 value, uint256 lastIndexReceivedFees) {
        lastIndexReceivedFees = _blockReceivedFees.length - 1;
        if(
            userInfo[_user].amount > 0 && 
            _lastIndexUserReceivedFees[_user] < _blockReceivedFees.length - 1
          ) {
            uint256 length = _blockReceivedFees.length;

            for (uint256 i = _lastIndexUserReceivedFees[_user] + 1; i < length; ) {
                value += 
                    _feesReceivedAtBlock[_blockReceivedFees[i]] 
                    * userInfo[_user].amount 
                    / _totalLpsAtBlock[_blockReceivedFees[i]];

                if(gasleft() <= minGasNeeded){
                    lastIndexReceivedFees = i;
                    break;
                }

                unchecked{ ++i; }
            }
        }
    }

    // =========================================================================================
    // Where contract received fees from platform
    // =========================================================================================

    function receiveFees(uint256 _amount) external onlyGame{
        totalHistoryFees += _amount;
        _feesReceivedAtBlock[block.number] = _amount;
        _totalLpsAtBlock[block.number] = liquidityMining.lpToken.balanceOf(address(this));
        _blockReceivedFees.push(block.number);
    }
    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library ZaiStruct {
        // Zai powers
    // Zai powers
    struct Powers {
        uint256 water;
        uint256 fire;
        uint256 metal;
        uint256 air;
        uint256 stone;
    }

    // A zai can work in a center , training or coaching. He can't fight if he isn't free
    //string[4] _status = ["Free","Training","Coaching","Working"];
    struct Activity{
        uint256 statusId;
        uint256 onCenter;
    }

    struct ZaiMetaData{
        uint256 state; // _states index
        uint256 ipfsPathId;
        uint256 seasonOf;
    }

    struct Zai {
        string name;
        uint256 xp; 
        uint256 manaMax;
        uint256 mana;
        uint256 level;
        uint256 creditForUpgrade; // credit to use to raise powers
        Powers powers;
        Activity activity;
        ZaiMetaData metadata;
    }

    struct Stats {
        uint256 zaiTotalWins;
        uint256 zaiTotalDraw;
        uint256 zaiTotalLoss;
        uint256 zaiTotalFights;
        uint256 zaiTotalRandomSelected;  
        uint256 zaiNumberOfWinThisDay;
    }

    struct EggsPrices {
        uint256 bronzePrice;
        uint256 silverPrice;
        uint256 goldPrice;
        uint256 platinumPrice;
    }

    struct MintedData {
        uint256 bronzeMinted;
        uint256 silverMinted;
        uint256 goldMinted;
        uint256 platinumMinted;
    }

    struct WorkInstance {
        uint256 zaiId;
        uint256 beginingAt;
    }

    struct DelegateData{
        address scholarAddress;
        address ownerAddress;
        uint256 contractDuration;
        uint256 contractEnd;
        uint256 percentageForScholar;
        uint256 lastScholarPlayed;
        bool renewable;
    } 

    struct GuildeDatas {
        address renterOf;
        address masterOf;
        address platformAddress;
        uint256 percentageForScholar;
        uint256 percentageForGuilde;
        uint256 percentagePlatformFees;
    }

    struct ScholarDatas{
        GuildeDatas guildeDatas;
        DelegateData delegateDatas;
    }

}

library PotionStruct {
    struct Powers {
        uint256 water;
        uint256 fire;
        uint256 metal;
        uint256 air;
        uint256 stone;
        uint256 rest;
        uint256 xp;
        uint256 mana;
    }

    struct Potion {
        Powers powers;
        uint256 potionType; // 0: water ; 1: fire ; 2:metal ; 3:air ; 4:stone  ; 5:rest ; 6:xp ; 7:multiple
        address seller;
        uint256 listingPrice;
        uint256 fromLab;
        uint256 potionId;
        uint256 saleTimestamp;
    }
}

interface IOracle {
    function getRandom(bytes32 _id) external returns (uint256);
}

interface IZaiMeta {
    function getState(uint256 state) external view returns(string memory);

    function godNames(uint256 _ipfsId) external view returns(string memory);

    function getRandomPowers(uint256 level, uint256 _points, uint256 random) external view returns(ZaiStruct.Powers memory);

    function getGodsPowers(uint256 _ipfsId) external view returns(ZaiStruct.Powers memory);

    function updatePowers(uint256 level, ZaiStruct.Powers memory powers, ZaiStruct.Powers memory toAdd, bool isGod) external view returns(ZaiStruct.Powers memory);

    function getLevel(uint256 _xp) external view returns (uint256);

    function getNextLevelUpPoints(uint256 _level) external view returns(uint256);
}

interface IZaiNFT is IERC721Enumerable {

    function mintZai(address _to,string memory _name,uint256 _state) external returns (uint256);

    function burnZai(uint256 _tokenId) external;

    function updateStatus(uint256 _tokenId, uint256 _newStatusID, uint256 _center) external;

    function updateXp(uint256 _id,uint256 _xp) external returns (uint256 level);

    function isFree(uint256 _tokenId) external view returns(bool);

    function updateMana(uint256 _tokenId, uint256 _manaUp, uint256 _manaDown, uint256 _maxUp) external returns(bool);

    function getZai(uint256 _tokenId) external view returns(ZaiStruct.Zai memory);
    
    function getNextLevelUpPoints(uint256 _level) external view returns(uint256);
    
}

interface IipfsIdStorage {
    function getTokenURI(uint256 _season, uint256 _state, uint256 _id) external view returns(string memory);

    function getNextIpfsId(uint256 _state, uint256 _nftId) external returns(uint256);

    function getCurrentSeason() external view returns(uint256);
}

interface ILaboratory is IERC721Enumerable{
    function mintLaboratory(address _to) external returns (uint256);

    function burn(uint256 _tokenId) external;

    function getCreditLastUpdate(uint256 _tokenId) external view returns(uint256);

    function updateCreditLastUpdate(uint256 _tokenId) external returns(bool);

    function numberOfWorkingSpots(uint256 _tokenId) external view returns(uint256);

    function updateNumberOfWorkingSpots(uint256 _tokenId) external returns(bool);

    function getPreMintNumber() external view returns(uint256);
}

interface ILabManagement{
    function createdPotionsForLab(uint256 _tokenId) external view returns(uint256);

    function laboratoryRevenues(uint256 _tokenId) external view returns(uint256);

    function getCredit(uint256 _laboId) external view returns(uint256);

    function workingSpot(uint256 _laboId, uint256 _slotId) external view returns(ZaiStruct.WorkInstance memory);

    function cleanSlotsBeforeClosing(uint256 _laboId) external returns(bool);

}

interface IBZAI is IERC20{
    function burn(uint256 _amount) external returns(bool);
}

interface ITraining is IERC721Enumerable{
    function mintTrainingCenter(address _to) external returns (uint256);

    function burn(uint256 _tokenId) external;

    function numberOfTrainingSpots(uint256 _tokenId) external view returns(uint256);

    function addTrainingSpots(uint256 _tokenId, uint256 _amount) external returns(bool);

    function getPreMintNumber() external view returns(uint256);

}

interface ITrainingManagement {
    function cleanSlotsBeforeClosing(uint256 _laboId) external returns(bool);

    function getZaiLastTrainBegining(uint256 _zaiId) external view returns(uint256);

}



interface INursery is IERC721Enumerable{
    function mintNursery(address _to, uint256 _bronzePrice, uint256 _silverPrice, uint256 _goldPrice, uint256 _platinumPrice) external returns (uint256);

    function burnNursery(uint256 _tokenId) external;

    function burn(uint256 _tokenId) external;

    function nextStateToMint(uint256 _tokenId) external view returns (uint256);

    function getEggsPrices(uint256 _nursId) external view returns(ZaiStruct.EggsPrices memory);

    function getNurseryMintedDatas(uint256 _tokenId) external view returns (ZaiStruct.MintedData memory);

    function getNextUnlock(uint256 _tokenId) external view returns (uint256);

    function getPreMintNumber() external view returns(uint256);

    function nurseryRevenues(uint256 _tokenId) external view returns(uint256);

    function nurseryMintedDatas(uint256 _tokenId) external view returns(ZaiStruct.MintedData memory);

}

interface IStaking {
    function receiveFees(uint256 _amount) external;

    function getMiningStarted() external view returns(bool);
}

interface IBZAIToken {
    function burnToken(uint256 _amount) external;
}

interface IPayments {
    function payOwner(address _owner, uint256 _value) external returns(bool);

    function distributeFees(uint256 _amount) external returns(bool);

    function getMyReward(address _user) external view returns(uint256);

    function useReward(address _user, uint256 _amount) external returns(bool);

    function rewardPlayer(address _user, uint256 _amount) external returns(bool);

    function getMyCentersRevenues(address _user) external view returns(uint256);

    function burnRevenuesForEggs(address _owner, uint256 _amount) external returns(bool);

    function payNFTOwner(address _owner, uint256 _amount) external returns(bool);

    function payRNFT(uint256 _amount) external returns(bool);
}

interface IEggs is IERC721Enumerable{

    function mintEgg(address _to,uint256 _state,uint256 _maturityDuration) external returns (uint256);

    function burnEgg(uint256 _tokenId) external returns(bool);

    function isMature(uint256 _tokenId) external view returns(bool);

    function getStateIndex(uint256 _tokenId) external view returns (uint256);
}

interface IPotions is IERC721Enumerable{
    function mintPotionForSale(uint256 _fromLab,uint256 _price,uint256 _type, uint256 _power) external returns (uint256);

    function offerPotion(uint256 _type,uint256 _power,address _to) external returns (uint256);

    function updatePotion(uint256 _tokenId) external; 

    function burnPotion(uint256 _tokenId) external returns(bool);

    function getPotion(uint256 _tokenId) external view returns(address seller, uint256 price, uint256 fromLab);

    function buyPotion(address _to, uint256 _type) external returns (uint256);

    function mintMultiplePotion(uint256[6] memory _powers, address _owner) external returns(uint256);

    function changePotionPrice(uint256 _tokenId, uint256 _laboId, uint256 _price) external returns(bool);

    function updatePotionSaleTimestamp(uint256 _tokenId) external returns(bool);

    function getFullPotion(uint256 _tokenId) external view returns(PotionStruct.Potion memory);
}

interface IAddresses {
    function getBZAIAddress() external view returns(address);

    function getOracleAddress() external view returns(address);

    function getStakingAddress() external view returns(address); 

    function getZaiAddress() external view returns(address);

    function getIpfsStorageAddress() external view returns(address);

    function getLaboratoryAddress() external view returns(address);

    function getLaboratoryNFTAddress() external view returns(address);

    function getTrainingCenterAddress() external view returns(address);

    function getTrainingNFTAddress() external view returns(address);

    function getNurseryAddress() external view returns(address);

    function getPotionAddress() external view returns(address);

    function getTeamAddress() external view returns(address);

    function getFightAddress() external view returns(address);

    function getEggsAddress() external view returns(address);

    function getMarketZaiAddress() external view returns(address);

    function getPaymentsAddress() external view returns(address);

    function getChallengeRewardsAddress() external view returns(address);

    function getWinRewardsAddress() external view returns(address);

    function getOpenAndCloseAddress() external view returns(address);

    function getAlchemyAddress() external view returns(address);

    function getReserveChallengeAddress() external view returns(address);

    function getReserveWinAddress() external view returns(address);

    function getWinChallengeAddress() external view returns(address);

    function isAuthToManagedNFTs(address _address) external view returns(bool);

    function isAuthToManagedPayments(address _address) external view returns(bool);

    function getLevelStorageAddress() external view returns(address);

    function getRankingContract() external view returns(address);

    function getAuthorizedSigner() external view returns(address);

    function getDelegateZaiAddress() external view returns(address);

    function getZaiStatsAddress() external view returns(address);

    function getLootAddress() external view returns(address);

    function getClaimNFTsAddress() external view returns(address);

    function getRentMyNftAddress() external view returns(address);

    function getChickenAddress() external view returns(address);
}

interface IOpenAndClose {

    function getLaboCreatingTime(uint256 _tokenId) external view returns(uint256);

    function canLaboSell(uint256 _tokenId) external view returns (bool);

    function canTrain(uint256 _tokenId) external view returns (bool);

    function laboratoryMinted()external view returns(uint256);

    function trainingCenterMinted()external view returns(uint256);

    function getLaboratoryName(uint256 _tokenId) external view returns(string memory);

    function getNurseryName(uint256 _tokenId) external view returns(string memory);

    function getTrainingCenterName(uint256 _tokenId) external view returns(string memory);

    function getLaboratoryState(uint256 _tokenId) external view returns (string memory);

}

interface IReserveForChalengeRewards {
    function getNextUpdateTimestamp() external view returns(uint256);

    function getRewardFinished() external view returns(bool);

    function updateRewards() external returns(bool);
}

interface IReserveForWinRewards {
    function getNextUpdateTimestamp() external view returns(uint256);

    function getRewardFinished() external view returns(bool);

    function updateRewards() external returns(bool);
}

interface ILevelStorage {
     function addFighter(uint256 _level, uint256 _zaiId) external returns(bool);

     function removeFighter(uint256 _level, uint256 _zaiId) external returns (bool);

     function getLevelLength(uint256 _level) external view returns(uint256);
     
     function getRandomZaiFromLevel(uint256 _level, uint256 _idForbiden) external returns(uint256 _zaiId);
}

interface IRewardsRankingFound {
    function getDailyRewards(address _rewardStoringAddress) external returns(uint256);

    function getWeeklyRewards(address _rewardStoringAddress) external returns(uint256);
}

interface IRewardsWinningFound {
    function getWinningRewards(uint256 level) external returns(uint256);
}

interface IRanking {
    function updatePlayerRankings(address _user, uint256 _xpWin) external returns(bool);

    function getDayBegining() external view returns(uint256);

    function getDayAndWeekRankingCounter() external view returns(uint256 dayNumber, uint256 weekNumber);
}

interface IDelegate {
    function gotDelegationForZai(uint256 _zaiId) external view returns(ZaiStruct.ScholarDatas memory scholarDatas);

    function canUseZai(uint256 _zaiId, address _user) external view returns(bool);

    function getDelegateDatasByZai(uint256 _zaiId) external view returns(ZaiStruct.DelegateData memory);

    function isZaiDelegated(uint256 _zaiId) external view returns(bool);

    function updateLastScholarPlayed(uint256 _zaiId) external returns(bool);
}

interface IStats {
    function updateCounterWinLoss(uint256 _zaiId,uint256 _challengerId, uint256[30] memory _fightProgress, IRanking IRank) external returns(bool);

    function getZaiStats(uint256 _zaiId) external view returns(uint256[5] memory);

    function updateAllPowersInGame(ZaiStruct.Powers memory toAdd) external returns(bool);
}

interface IFighting{
    function getZaiStamina(uint256 _zaiId) external view returns(uint256);

    function getDayWinByZai(uint256 zaiId) external view returns(uint256);
}

interface IFightingLibrary{
    function updateFightingProgress(uint256[30] memory _toReturn, uint256[9] memory _elements, uint256[9] memory _powers) external pure returns (uint256[30] memory);

    function getUsedPowersByElement(uint256[9] memory _elements,uint256[9] memory _powers)external pure returns(uint256[5] memory);

    function isPowersUsedCorrect(uint256[5] memory _got, uint256[5] memory _used ) external pure returns(bool);

    function getNewPattern(uint256 _random,ZaiStruct.Zai memory c,uint256[30] memory _toReturn) external pure returns(uint256[30] memory result);
}

interface ILootProgress {
    function updateUserProgress(address _user) external;
}

interface IGuildeDelegation{
    function getRentingDatas(address _nftAddress, uint256 _tokenId) external view returns(ZaiStruct.GuildeDatas memory);
}

interface IChicken{
    function mintChicken(address _to) external returns (uint256); 
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
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