// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Interfaces.sol";

contract OpenAndCloseCenter is Ownable {
    IERC20 BZAI;
    IAddresses public gameAddresses;

    uint256 maturityHousesDuration = 3 days;
    uint256 closingHousesDuration = 3 days;

    mapping(uint256 => string) public nurseryName;
    mapping(uint256 => string) public laboratoryName;
    mapping(uint256 => string) public trainingCenterName;

    constructor(address _BZAI){
        BZAI = IERC20(_BZAI);
    }    

    struct ClosingProcess {
        bool isClosing;
        bool destructed;
        uint256 timestampClosedActed;
    }

    string[5] housesStates = ["Doesn't_Exist","Under_Construction","Open","Under_Destroyment","Destroyed"];

    //closingProcesses[1 (nursery) ][1 (tokenId)] => Nursery = 1 ; TrainingCenter = 2 ; Laboratory = 3
    mapping(uint256 => mapping(uint256 => ClosingProcess)) public closingProcesses;

    mapping(uint256 => uint256) nurseryMaturityTime;
    mapping(uint256 => uint256) public lockedInNurseryID; // BZAI locked in this Nursery instance
    uint256 public nurseryPrice = 1000000 * 1E18;

    mapping(uint256 => uint256) trainingCenterMaturityTime;
    mapping(uint256 => uint256) public lockedInTrainingCenterID; // BZAI locked in this CENTER instance
    uint256 public trainingCenterPrice = 1000000 * 1E18;

    mapping(uint256 => uint256) laboratoryMaturityTime;
    mapping(uint256 => uint256) public lockedInLaboID; // BZAI locked in this labo instance
    uint256 public laboratoryPrice = 1000000 * 1E18;

    function setMaturityDuration(uint256 _numbersOfDays) external onlyOwner{
        require(_numbersOfDays < 10, "Too long");
        maturityHousesDuration = _numbersOfDays * 1 days;
    }

    function setClosingDuration(uint256 _numbersOfDays) external onlyOwner{
        require(_numbersOfDays < 10, "Too long");
        closingHousesDuration = _numbersOfDays * 1 days;
    }

    function setGameAddresses(address _address) public onlyOwner {
        gameAddresses = IAddresses(_address);
    }

    function setNurseryPrice(uint256 _price) external onlyOwner {
        nurseryPrice = _price;
    }

    function setTrainingCenterPrice(uint256 _price) external onlyOwner {
        trainingCenterPrice = _price;
    }

    function setLaboratoryPrice(uint256 _price) external onlyOwner {
        nurseryPrice = _price;
    }

    function getNurseryName(uint256 _tokenId) external view returns(string memory) {
        return nurseryName[_tokenId];
    }

    function getLaboratoryName(uint256 _tokenId) external view returns(string memory) {
        return laboratoryName[_tokenId];
    }

    function getTrainingCenterName(uint256 _tokenId) external view returns(string memory) {
        return trainingCenterName[_tokenId];
    }    

    function createNursery(string memory _name, uint256 _bronzePrice, uint256 _silverPrice, uint256 _goldPrice, uint256 _platinumPrice) external returns (uint256) {
        require(BZAI.transferFrom(msg.sender, address(this), nurseryPrice));
        uint256 nurseryId = INursery(gameAddresses.getNurseryAddress()).mintNursery(
            msg.sender,
            _bronzePrice,
            _silverPrice, 
            _goldPrice,
            _platinumPrice
        );
        lockedInNurseryID[nurseryId] = nurseryPrice;
        nurseryMaturityTime[nurseryId] = block.timestamp + maturityHousesDuration;
        nurseryName[nurseryId] = _name;
        return nurseryId;
    }

    function changeNurseryName(string memory _name, uint256 _tokenId) external {
        require(
            IERC721(gameAddresses.getNurseryAddress()).ownerOf(_tokenId) == msg.sender ||
            msg.sender == owner(),
            "Not authorized");
        
        nurseryName[_tokenId] = _name;
    }

    function createTrainingCenter(string memory _name) external returns (uint256) {
        require(BZAI.transferFrom(msg.sender, address(this), trainingCenterPrice));
        uint256 trainingId = ITraining(gameAddresses.getTrainingNFTAddress()).mintTrainingCenter(
            msg.sender
        );
        lockedInTrainingCenterID[trainingId] = trainingCenterPrice;
        trainingCenterMaturityTime[trainingId] = block.timestamp + maturityHousesDuration;
        trainingCenterName[trainingId] = _name;
        return trainingId;
    }

    function changeTrainingCenterName(string memory _name, uint256 _tokenId) external {
        require(
            IERC721(gameAddresses.getTrainingCenterAddress()).ownerOf(_tokenId) == msg.sender ||
            msg.sender == owner(),
            "Not authorized");
        
        trainingCenterName[_tokenId] = _name;
    }

    function createLaboratory(string memory _name) external returns(uint256) {
        require(BZAI.transferFrom(msg.sender, address(this), laboratoryPrice));
        uint256 laboId = ILaboratory(gameAddresses.getLaboratoryNFTAddress()).mintLaboratory(
            msg.sender
        );
        lockedInLaboID[laboId] = laboratoryPrice;
        laboratoryMaturityTime[laboId] = block.timestamp + maturityHousesDuration;
        laboratoryName[laboId] = _name;
        return laboId;
    }

    function changeLaboratoryName(string memory _name, uint256 _tokenId) external {
        require(
            IERC721(gameAddresses.getLaboratoryAddress()).ownerOf(_tokenId) == msg.sender ||
            msg.sender == owner(),
            "Not authorized");
        
        laboratoryName[_tokenId] = _name;
    }

    function getNurseryState(uint256 _tokenId) external view returns (string memory) {
        string memory result;
        if(nurseryMaturityTime[_tokenId] == 0){
            result = housesStates[0];
        }else {
            if(block.timestamp < nurseryMaturityTime[_tokenId]){
                result = housesStates[1];
            }else{
                if(closingProcesses[1][_tokenId].isClosing){
                    result = housesStates[3];
                }
                if(closingProcesses[1][_tokenId].destructed){
                    result = housesStates[4];
                }
                else{
                    result = housesStates[2];
                }
            }
        }
        return result;
    }

    function getTrainingCenterState(uint256 _tokenId) external view returns (string memory) {
        string memory result;
        if(trainingCenterMaturityTime[_tokenId] == 0){
            result = housesStates[0];
        }else {
            if(block.timestamp < trainingCenterMaturityTime[_tokenId]){
                result = housesStates[1];
            }else{
                if(closingProcesses[1][_tokenId].isClosing){
                    result = housesStates[3];
                }
                if(closingProcesses[1][_tokenId].destructed){
                    result = housesStates[4];
                }
                else{
                    result = housesStates[2];
                }
            }
        }
        return result;
    }

    function getLaboratoryState(uint256 _tokenId) external view returns (string memory) {
        string memory result;
        if(laboratoryMaturityTime[_tokenId] == 0){
            result = housesStates[0];
        }else {
            if(block.timestamp < laboratoryMaturityTime[_tokenId]){
                result = housesStates[1];
            }else{
                if(closingProcesses[1][_tokenId].isClosing){
                    result = housesStates[3];
                }
                if(closingProcesses[1][_tokenId].destructed){
                    result = housesStates[4];
                }
                else{
                    result = housesStates[2];
                }
            }

        }
        return result;
    }

    function getNurseryMaturityTime(uint256 _tokenId) external view returns(uint256){
        return nurseryMaturityTime[_tokenId];
    } 

    function getTrainingCenterMaturityTime(uint256 _tokenId) external view returns(uint256){
        return trainingCenterMaturityTime[_tokenId];
    } 
     
    function getLaboMaturityTime(uint256 _tokenId) external view returns(uint256){
        return laboratoryMaturityTime[_tokenId];
    }

    function canNurserySell(uint256 _tokenId) external view returns (bool) {
        bool result;
        if(_tokenId > 0 && _tokenId < 20){
            result = true;
        }else if(
            nurseryMaturityTime[_tokenId] == 0 ||
            block.timestamp < nurseryMaturityTime[_tokenId] || 
            closingProcesses[1][_tokenId].isClosing ||
            closingProcesses[1][_tokenId].destructed
             ){
            result = false;
        }else{
            result = true;
        }

        return result;
    }

    function canTrain(uint256 _tokenId) external view returns (bool) {
        bool result;
        if(_tokenId > 0 && _tokenId < 20){
            result = true;
        }else if(
            trainingCenterMaturityTime[_tokenId] == 0 ||
            block.timestamp < trainingCenterMaturityTime[_tokenId] || 
            closingProcesses[2][_tokenId].isClosing ||
            closingProcesses[2][_tokenId].destructed
             ){
            result = false;
        }else{
            result = true;
        }

        return result;
    }

    function canLaboSell(uint256 _tokenId) external view returns (bool) {
        bool result;
        if(_tokenId > 0 && _tokenId < 20){
            result = true;
        }else if(
            laboratoryMaturityTime[_tokenId] == 0 ||
            block.timestamp < laboratoryMaturityTime[_tokenId] ||
            closingProcesses[3][_tokenId].isClosing ||
            closingProcesses[3][_tokenId].destructed
             ){
            result = false;
        }else{
            result = true;
        }

        return result;
    }

    function closeNursery(uint256 _tokenId) external {
        require(_tokenId >= 20, "This center can't be closed");
        ClosingProcess storage c = closingProcesses[1][_tokenId];
        require(
            IERC721(gameAddresses.getNurseryAddress()).ownerOf(_tokenId) == msg.sender,
            "Not your Nursery"
        );
        require(!c.isClosing, "Already in closing process");
        c.isClosing = true;
        c.timestampClosedActed = block.timestamp + closingHousesDuration;
    }

    function getBZAIBackFromClosingNursery(uint256 _tokenId) external {
        ClosingProcess storage c = closingProcesses[1][_tokenId];
        require(
            IERC721(gameAddresses.getNurseryAddress()).ownerOf(_tokenId) == msg.sender,
            "Not your Nursery"
        );
        require(c.isClosing, "Not in closing process");
        require(
            block.timestamp >= c.timestampClosedActed,
            "Closing process not finish, please wait "
        );

        uint256 _amount = lockedInNurseryID[_tokenId];
        lockedInNurseryID[_tokenId] = 0;
        require(BZAI.transfer( msg.sender, _amount));

        //Burn
        INursery(gameAddresses.getNurseryAddress()).burn(_tokenId);
        c.isClosing = false;
        c.destructed = true;
    }

    function closeTrainingCenter(uint256 _tokenId) external {
        require(_tokenId >= 20, "This center can't be closed");
        ClosingProcess storage c = closingProcesses[2][_tokenId];
        require(IERC721(gameAddresses.getTrainingCenterAddress()).ownerOf(_tokenId) == msg.sender, "not your Center");
        require(!c.isClosing, "Already in closing process");
        c.isClosing = true;
        c.timestampClosedActed = block.timestamp + closingHousesDuration;
    }

    function getBZAIBackFromClosingTraining(uint256 _tokenId) external {
        ClosingProcess storage c = closingProcesses[2][_tokenId];
        require(IERC721(gameAddresses.getTrainingCenterAddress()).ownerOf(_tokenId) == msg.sender, "not your Center");
        require(c.isClosing, "Not in closing process");
        require(
            block.timestamp >= c.timestampClosedActed,
            "Closing process not finished, please wait "
        );
        uint256 _amount = lockedInTrainingCenterID[_tokenId];
        lockedInTrainingCenterID[_tokenId] = 0;
        require(BZAI.transfer( msg.sender, _amount));

        //Burn
        ITraining(gameAddresses.getTrainingCenterAddress()).burn(_tokenId);
        c.isClosing = false;
        c.destructed = true;
    }

    function closeLabo(uint256 _tokenId) public {
        require(_tokenId >= 20, "This center can't be closed");
        ClosingProcess storage c = closingProcesses[3][_tokenId];
        require(
            IERC721(gameAddresses.getLaboratoryNFTAddress()).ownerOf(_tokenId) == msg.sender,
            "Not your labo"
        );
        require(!c.isClosing, "Already in closing process");
        c.isClosing = true;
        c.timestampClosedActed = block.timestamp + closingHousesDuration;
    }

    function getBZAIBackFromClosingLabo(uint256 _tokenId) public {
        ClosingProcess storage c = closingProcesses[3][_tokenId];
        require(
            IERC721(gameAddresses.getLaboratoryNFTAddress()).ownerOf(_tokenId) == msg.sender,
            "Not your labo"
        );
        require(c.isClosing, "Not in closing process");
        require(
            block.timestamp >= c.timestampClosedActed,
            "Closing process during Not finished, please wait "
        );
        uint256 amount = lockedInLaboID[_tokenId];
        lockedInLaboID[_tokenId] = 0;
        require(BZAI.transfer(msg.sender, amount));

        ILaboratory(gameAddresses.getLaboratoryNFTAddress()).burn(_tokenId);
        c.isClosing = false;
        c.destructed = true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

library MonsterStruct {
        // Monster powers
    struct Powers {
        uint256 water;
        uint256 fire;
        uint256 metal;
        uint256 air;
        uint256 stone;
    }

    struct Monster {
        string name;
        uint256 state; // _states index
        uint256 xp; 
        uint256 alchemyXp;
        uint256 level;
        Powers powers;
        uint256 creditForUpgrade; // credit to use to raise powers
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
}

interface IOracle {
    function getRandom(bytes32 _id) external returns (uint256);
}

interface IBandZaiNFT is IERC721Enumerable {

    function monster(uint256 _tokenId) external view returns(MonsterStruct.Monster memory);

    function mintMonster(address _to,string memory _name,uint256 _state) external returns (uint256);
   
    function updateMonster(uint256 _id,uint256 _attack,uint256 _defense,uint256 _xp) external returns (uint256);

    function burnMonster(uint256 _tokenId) external;

    function getMonsterState(uint256 _tokenId) external view returns (uint256);

    function updateStatus(uint256 _tokenId, uint256 _newStatusID, uint256 _center) external;

    function updateXp(uint256 _id,uint256 _xp) external returns (uint256 level);

    function updateAttackAndDefense(uint256 _id,uint256 _attack,uint256 _defense) external;

    function isFree(uint256 _tokenId) external view returns(bool);

    function updateAlchemyXp(uint256 _tokenId, uint256 _xpRaised) external;

    function getMonster(uint256 _tokenId)external view returns (
            uint256 level,
            uint256 xp,
            uint256 alchemyXp,
            string memory state,
            string memory uriAndName,
            uint256[5] memory powers 
        );

    function getNextLevelUpPoints(uint256 _level) external view returns(uint256);

    function getStatus(uint256 _tokenId) external view returns(uint256[2] memory);
    
}

interface IipfsIdStorage {
    function getTokenURI(uint256 _season, uint256 _state, uint256 _id) external view returns(string memory);

    function getNextIpfsId(uint256 _state) external returns(uint256);

    function getCurrentSeason() external view returns(uint256);
}

interface ILaboratory is IERC721Enumerable{
    function mintLaboratory(address _to) external returns (uint256);

    function burn(uint256 _tokenId) external;

    function getCreditLastUpdate(uint256 _tokenId) external view returns(uint256);

    function updateCreditLastUpdate(uint256 _tokenId) external returns(bool);

    function numberOfWorkingSpots(uint256 _tokenId) external view returns(uint256);

    function updateNumberOfWorkingSpots(uint256 _tokenId) external returns(bool);
}

interface ITraining is IERC721Enumerable{
    function mintTrainingCenter(address _to) external returns (uint256);

    function burn(uint256 _tokenId) external;

    function numberOfTrainingSpots(uint256 _tokenId) external view returns(uint256);

    function addTrainingSpots(uint256 _tokenId, uint256 _amount) external returns(bool);
}

interface INursery is IERC721Enumerable{
    function mintNursery(address _to, uint256 _bronzePrice, uint256 _silverPrice, uint256 _goldPrice, uint256 _platinumPrice) external returns (uint256);

    function burnNursery(uint256 _tokenId) external;

    function burn(uint256 _tokenId) external;

    function nextStateToMint(uint256 _tokenId) external view returns (uint256);

    function getEggsPrices(uint256 _nursId) external view returns(MonsterStruct.EggsPrices memory);

    function getNurseryMintedDatas(uint256 _tokenId) external view returns (MonsterStruct.MintedData memory);

    function getNextUnlock(uint256 _tokenId) external view returns (uint256);
}

interface ILottery is IERC721Enumerable{
    function getLotteryPrices() external view returns(uint256 _ticket, uint256 _bronze, uint256 _silver, uint256 _gold);
}

interface IStaking {
    function receiveFees(uint256 _amount) external;
}

interface IBZAIToken {
    function burnToken(uint256 _amount) external;
}

interface IPayments {
    function payOwner(address _owner, uint256 _value) external returns(bool);

    function distributeFees(uint256 _amount) external returns(bool);
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

    function getPotionPowers(uint256 _tokenId) external view returns(uint256[7] memory);

    function buyPotion(address _to, uint256 _type) external returns (uint256);

    function mintMultiplePotion(uint256[7] memory _powers, address _owner) external returns(uint256);
}

interface IAddresses {
    function getBZAIAddress() external view returns(address);

    function getOracleAddress() external view returns(address);

    function getStakingAddress() external view returns(address); 

    function getMonsterAddress() external view returns(address);

    function getIpfsStorageAddress() external view returns(address);

    function getLaboratoryAddress() external view returns(address);

    function getLaboratoryNFTAddress() external view returns(address);

    function getTrainingCenterAddress() external view returns(address);

    function getTrainingNFTAddress() external view returns(address);

    function getNurseryAddress() external view returns(address);

    function getPotionAddress() external view returns(address);

    function getTeamAddress() external view returns(address);

    function getGameAddress() external view returns(address);

    function getEggsAddress() external view returns(address);

    function getLotteryAddress() external view returns(address);

    function getPaymentsAddress() external view returns(address);

    function getChallengeRewardsAddress() external view returns(address);

    function getWinRewardsAddress() external view returns(address);

    function getOpenAndCloseAddress() external view returns(address);

    function getAlchemyAddress() external view returns(address);

    function getChickenAddress() external view returns(address);

    function getReserveChallengeAddress() external view returns(address);

    function getReserveWinAddress() external view returns(address);

    function getWinChallengeAddress() external view returns(address);

    function isAuthToManagedNFTs(address _address) external view returns(bool);

    function isAuthToManagedPayments(address _address) external view returns(bool);

    function getLevelStorageAddress() external view returns(address);

    function getRankingContract() external view returns(address);

    function getAuthorizedSigner() external view returns(address);

    function getDelegateMonsterAddress() external view returns(address);

    function getZaiStatsAddress() external view returns(address);

    function getLootAddress() external view returns(address);
}

interface IOpenAndClose {

    function getLaboCreatingTime(uint256 _tokenId) external view returns(uint256);

    function getNurseryCreatingTime(uint256 _tokenId) external view returns(uint256);

    function canLaboSell(uint256 _tokenId) external view returns (bool);

    function canTrain(uint256 _tokenId) external view returns (bool);

    function canNurserySell(uint256 _tokenId) external view returns (bool);

    function nurseryMinted()external view returns(uint256);

    function laboratoryMinted()external view returns(uint256);

    function trainingCenterMinted()external view returns(uint256);

    function getLaboratoryName(uint256 _tokenId) external view returns(string memory);

    function getNurseryName(uint256 _tokenId) external view returns(string memory);

    function getTrainingCenterName(uint256 _tokenId) external view returns(string memory);

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
     function addFighter(uint256 _level, uint256 _monsterId) external returns(bool);

     function removeFighter(uint256 _level, uint256 _monsterId) external returns (bool);

     function getLevelLength(uint256 _level) external view returns(uint256);
     
     function getRandomMonsterFromLevel(uint256 _level) external returns(uint256 _monsterId, uint256 _diffLevel);
}

interface IRewardsRankingFound {
    function getDailyRewards() external returns(uint256);

    function getWeeklyRewards() external returns(uint256);
}

interface IRewardsWinningFound {
    function getWinningRewards() external returns(uint256);
}

interface IRanking {
    function updatePlayerRankings(address _user) external returns(bool);

    function getDayBegining() external view returns(uint256);
}

interface IDelegate {
    function gotDelegationForMonster(uint256 _monsterId) external view returns(bool);

    function getDelegateDatasByMonster(uint256 _monsterId) external view returns(
        address scholarAddress,
        address monsterOwner,
        uint256 contractDuration,
        uint256 contractEnd,
        uint256 percentageForScholar,
        uint256 lastScholarPlayed
        );

    function isMonsterDelegated(uint256 _monsterId) external view returns(bool);

    function updateLastScholarPlayed(uint256 _monsterId) external returns(bool);
}

interface IStats {
    function updateCounterWinLoss(uint256 _monsterId,uint256[27] memory _fightProgress) external returns(bool result);

    function getMonsterStats(uint256 _monsterId) external view returns(uint256[5] memory);
}

interface IFighting{
    function getFighterStamina(uint256 _monsterId) external view returns(uint256);
}

interface ILootProgress {
    function updateUserProgress(address _user) external;
}

// SPDX-License-Identifier: MIT

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
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}