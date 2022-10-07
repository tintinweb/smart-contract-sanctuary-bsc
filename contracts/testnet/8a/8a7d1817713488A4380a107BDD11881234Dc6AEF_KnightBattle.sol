//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './KnightFamily.sol';
import "../Libraries/HistoryBattle.sol";

contract KnightBattle is KnightFamily {

    event BattleResults(bool _result, uint _knightWin, uint _knightLose);
    event TriggerCoolDown(uint knightID, uint timeOut);

    mapping(uint => HistoryBattle.Info[]) internal historyBattleOfKnight;
    mapping(address => HistoryBattle.Info[]) internal historyBattleOfOwner;

    uint feeToMission = 300 *10 ** 18;

    constructor(
        IKnightNFT _knightNFT ,
        IKnightItems _contractItem,
        IKnightToken _knighToken,
        IMinter _minter,
        IMAL _mal,
        string memory _baseUri,
        string memory _baseImg
    ) {
        Item = _contractItem; 
        KnightToken = _knighToken;
        Minter = _minter;
        MAL = _mal;
        knightNFT = _knightNFT;
        baseURI = _baseUri;
        baseImage = _baseImg;
    }
    function attack(uint _attackknightID, uint _defenseKnightID) external {
        require(IKnightNFT(knightNFT).checkOwner(_attackknightID, msg.sender), "Invalid owner");
        Knight.Power memory myKnight    = IKnightNFT(knightNFT).getPowerKnight(_attackknightID);
        Knight.Power memory enemyKnight = IKnightNFT(knightNFT).getPowerKnight(_defenseKnightID);
        Knight.Info  memory infoKnightAtt  = IKnightNFT(knightNFT).getInfoKnight(_attackknightID);
        Knight.Info  memory infoKnightDef  = IKnightNFT(knightNFT).getInfoKnight(_defenseKnightID);
        require(_isReady(infoKnightAtt) && msg.sender != infoKnightDef.owner); //"Knight can't fight yet" // "You can't attack your knight"
        uint[] memory emptyList;
        if(_battle(myKnight, enemyKnight)) {
            (uint rewardBattle, uint[] memory listElixirId) = IKnightNFT(knightNFT).rewardForBattle(_attackknightID, msg.sender);
            if(infoKnightAtt.level < 100) {
                _levelUp(_attackknightID);
            } else {
                IKnightNFT(knightNFT).mintElixir(1, 3, msg.sender);
            }
            historyBattleOfKnight[_attackknightID].push(HistoryBattle.Info(_attackknightID, _defenseKnightID, true, block.timestamp, rewardBattle , listElixirId));
            historyBattleOfOwner[infoKnightAtt.owner].push(HistoryBattle.Info(_attackknightID, _defenseKnightID, true, block.timestamp, rewardBattle , listElixirId));
            emit BattleResults(true, _attackknightID, _defenseKnightID);
        } else {
            historyBattleOfKnight[_defenseKnightID].push(HistoryBattle.Info(_attackknightID, _defenseKnightID, true, block.timestamp, 0, emptyList));
            historyBattleOfOwner[infoKnightDef.owner].push(HistoryBattle.Info(_attackknightID, _defenseKnightID, true, block.timestamp, 0, emptyList));
            emit BattleResults(false, _defenseKnightID, _attackknightID);
        }
        _triggerCoolDown(_attackknightID);

    }

    function _isReady(Knight.Info memory _knight) internal view returns(bool) {
        return _knight.attackTime <= block.timestamp;
    }

    function _triggerCoolDown(uint _knightId) internal {
        Knight.Info  memory myKnight  = IKnightNFT(knightNFT).getInfoKnight(_knightId);
        myKnight.attackTime = uint32(block.timestamp + coolDownTime - myKnight.defaultAttack);
        IKnightNFT(knightNFT).saveInfoKnight(myKnight, myKnight.id);
        emit TriggerCoolDown(myKnight.id, myKnight.attackTime);
    }

    function _battle(Knight.Power memory _one, Knight.Power memory _two) 
        internal view returns(bool) 
    {
        Knight.Equipment memory oneEquipment = IKnightNFT(knightNFT).getEquipment(_one.equipmentId);
        Knight.Equipment memory twoEquipment = IKnightNFT(knightNFT).getEquipment(_two.equipmentId);
        int powerMyKnight    =  int(int32(_one.healthPoint) +
                                    int32(_one.defense) + 
                                    int32(oneEquipment.defense) +
                                    int32(oneEquipment.healthPoint) +
                                    int32(_one.excitementPoint) -  
                                    int32(_two.damage + twoEquipment.damage) * 10);
                                    
        int powerEnemyKnight =  int(int32(_two.healthPoint) + 
                                    int32(twoEquipment.defense) +
                                    int32(twoEquipment.healthPoint) +
                                    int32(_two.defense) - 
                                    int32(_one.damage + oneEquipment.damage) * 10);
        if(powerMyKnight >= powerEnemyKnight) {
            return true;
        } else {
            return false;
        }
    }
    // require cooldown time
    function battleTraining(uint _knightId, uint _mission, uint _deposit) 
        external 
    {
        require(IKnightNFT(knightNFT).checkOwner(_knightId, msg.sender) && 
        _deposit == _mission * feeToMission &&
        _mission <= 5 && _mission > 0, "Invalid input");
        Knight.Power memory myKnight    = IKnightNFT(knightNFT).getPowerKnight(_knightId);
        Knight.Power memory enemyKnight = IKnightNFT(knightNFT).getPowerKnight(_mission);
        Knight.Info  memory infoKnightAtt  = IKnightNFT(knightNFT).getInfoKnight(_knightId);
        require(_isReady(infoKnightAtt));
        if(_battle(myKnight, enemyKnight)) {
          IKnightNFT(knightNFT).rewardForMission(_mission, _deposit, msg.sender);
        } 
        _triggerCoolDown(_knightId);
        IMAL(MAL).burnByOperator(msg.sender, _deposit);
    }

    function _getHistoryBattle(HistoryBattle.Info[] memory _listBattle) 
        internal pure
        returns(HistoryBattle.Info[] memory )
    {
        uint lengthList = _listBattle.length;
        HistoryBattle.Info[] memory history = new HistoryBattle.Info[](lengthList);
        for (uint256 i = 0; i < lengthList; i++) {
            history[i] = _listBattle[i];
        }
        return history;
    }

    function getHistoryBattleKnight(uint _knightId) 
        external 
        returns(HistoryBattle.Info[] memory ) 
    {
        require(IKnightNFT(knightNFT).checkOwner(_knightId, msg.sender), "Invalid owner");
        return _getHistoryBattle(historyBattleOfKnight[_knightId]);
    }

    function getHistoryBattleAllKnight() 
        external view
        returns(HistoryBattle.Info[] memory ) 
    {
        address owner = _msgSender();
        return _getHistoryBattle(historyBattleOfOwner[owner]);
    }
    function setFeetoMission(uint _newfee) external onlyRole(OPERATOR_ROLE) {
        feeToMission = _newfee;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library HistoryBattle {

    struct Info {
        uint IdAttack;
        uint IdDefense;
        bool result;
        uint timeAt;
        uint reward;
        uint[] listElixirId;
    }
    
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './KnightUpgrade.sol';
import "../Libraries/Random.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
contract KnightFamily is KnightUpgrade {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter internal _marriageIdCounter;
    uint weddingExpenses = 100 * 10 ** 18;
    uint minAmountgift   = 600 * 10 ** 18;

    // mapping idknightrequest => idknightresponse => id register marry
    mapping(uint => mapping(uint => uint)) public registerMarry; 
    //mapping knightid => isEngaged 
    mapping(uint => bool) public KnightEngaged;

    event RequestMarry (uint IDknightRequest, uint IDknightResponse, address from, address to, uint amountGift, uint marriageID);
    event ApprovalMarry(uint IDknightRequest, uint IDknightResponse, bool resoult);
    event TriggerTired (uint knightID, uint timeOut);
    event ReproductionKnight(bool result, uint knightIdReq, uint knightIdRes, uint knightBaby);
    struct Marriage {
        uint32    idMarriage;
        uint32    idKinghtRequest;
        uint32    idKinghtResponse;
        uint32    timeWedding;
        address   ownerKnightRequest;
        address   ownerKnightResponse;
        bool      status;
        uint      giftAmount;
    }

    Marriage[] public listMarriage;

    modifier isBetrothed(uint _IDknightRequest, uint _IDknightResponse) {
        require(KnightEngaged[_IDknightRequest] && KnightEngaged[_IDknightResponse], "Not betrothed");
        _;
    }

    function requestMarry(uint32 _IDknightRequest, uint32 _IDknightResponse, uint _diposit) 
        external 
    {
        Knight.Info memory reqKnight =   IKnightNFT(knightNFT).getInfoKnight(_IDknightRequest);
        Knight.Info memory resKnight =   IKnightNFT(knightNFT).getInfoKnight(_IDknightResponse);
        require(reqKnight.level >= 20 && resKnight.level >= 18, "Invalid level");
        require(reqKnight.owner == msg.sender, "Invalid owner");
        require(_diposit >= minAmountgift && !KnightEngaged[_IDknightRequest] && !KnightEngaged[_IDknightResponse]); //  "Gift <= 600 STICoin"
        uint256 marriageID = _marriageIdCounter.current();
        registerMarry[_IDknightRequest][_IDknightResponse] = marriageID;
        listMarriage.push(Marriage(uint32(marriageID), _IDknightRequest, _IDknightResponse, 0, reqKnight.owner , resKnight.owner, false, _diposit));
        KnightEngaged[_IDknightRequest]  = true;
        KnightEngaged[_IDknightResponse] = true;
        _marriageIdCounter.increment();
        emit RequestMarry(_IDknightRequest, _IDknightResponse, reqKnight.owner , resKnight.owner,  _diposit, marriageID);
    }

    function approveMarry(uint _IDknightRequest, uint _IDknightResponse, bool _resoult) 
        external 
        isBetrothed(_IDknightRequest, _IDknightResponse)
    {
        require(IKnightNFT(knightNFT).checkOwner(_IDknightResponse, msg.sender), "Invalid owner");
        address ownerRequest  = IKnightNFT(knightNFT).getOwnerKnight(_IDknightRequest);
        address ownerResponse = IKnightNFT(knightNFT).getOwnerKnight(_IDknightResponse);
        uint  marriageID = registerMarry[_IDknightRequest][_IDknightResponse];
        Marriage storage myMarriage = listMarriage[marriageID];
        require(myMarriage.status == false); // "This marriage is consensual"
        if(_resoult) {
            uint moneyWedding = myMarriage.giftAmount;
            myMarriage.status = true;
            myMarriage.timeWedding = uint32(block.timestamp) + 7 days;
            uint gift = moneyWedding - weddingExpenses;
           IMAL(MAL).burnByOperator(ownerRequest, weddingExpenses);
           IMAL(MAL).transferByOperator(ownerRequest, ownerResponse, gift);
        } else {
            _destroyMarry(_IDknightRequest, _IDknightResponse, false);
        }
       
        emit ApprovalMarry(_IDknightRequest, _IDknightResponse, _resoult);
    }

    function destroyMarry(uint _IDknightRequest, uint _IDknightResponse) 
        external  
    {
        address ownerRequest  = IKnightNFT(knightNFT).getOwnerKnight(_IDknightRequest);
        address ownerResponse = IKnightNFT(knightNFT).getOwnerKnight(_IDknightResponse);
        address AOE = _msgSender();
        require(ownerRequest == AOE || ownerResponse == AOE, "Invalid owner");
        if(ownerRequest == AOE) {
            _destroyMarry(_IDknightRequest, _IDknightResponse, false);
        } else if(ownerResponse == AOE)
        {
            _destroyMarry(_IDknightRequest, _IDknightResponse, true);
        }
    }

    function _destroyMarry(uint _IDknightRequest, uint _IDknightResponse, bool _checkTime) 
        internal  
    {
        if(_checkTime) {
            uint  marriageID = registerMarry[_IDknightRequest][_IDknightResponse];
            Marriage storage myMarriage = listMarriage[marriageID];
            require(myMarriage.timeWedding < block.timestamp); //  "Cancel after 7 days of marriage"
            delete listMarriage [registerMarry[_IDknightRequest][_IDknightResponse]];
            delete registerMarry[_IDknightRequest][_IDknightResponse];    
            delete KnightEngaged[_IDknightRequest];
            delete KnightEngaged[_IDknightResponse];
        } else {
            delete listMarriage [registerMarry[_IDknightRequest][_IDknightResponse]];
            delete registerMarry[_IDknightRequest][_IDknightResponse];    
            delete KnightEngaged[_IDknightRequest];
            delete KnightEngaged[_IDknightResponse];
        }
    }

    function checkAcceptedMarry(uint _IDknightRequest, uint _IDknightResponse) internal view {
        uint  marriageID = registerMarry[_IDknightRequest][_IDknightResponse];
        require(listMarriage[marriageID].idKinghtRequest == _IDknightRequest && listMarriage[marriageID].idKinghtResponse == _IDknightResponse, "KnightFamily: invalid knight in this marriage");
        require(listMarriage[marriageID].status == true); // "Married before running this function"
    }

    function interCourseKnight(uint _knightIdOne, uint _knightIdTwo) 
        external   
    {
        checkAcceptedMarry(_knightIdOne, _knightIdTwo);
        require(_isReadySex(IKnightNFT(knightNFT).getInfoKnight(_knightIdOne)) && _isReadySex(IKnightNFT(knightNFT).getInfoKnight(_knightIdTwo)) ,"Knight can't fight yet");
        _reproductionKnight(_knightIdOne, _knightIdTwo);
    }

    function _isReadySex(Knight.Info memory _knight) 
        internal view 
        returns(bool) 
    {
        return _knight.sexTime <= block.timestamp;
    }

    function _reproductionKnight(uint _IDknightRequest, uint _IDknightResponse) 
        internal 
    {
        uint randWhoParent = Random._randMod(100);
        uint randReproduction = Random._randMod(1000);
        Knight.Info memory father = IKnightNFT(knightNFT).getInfoKnight(_IDknightRequest);
        Knight.Info memory mother = IKnightNFT(knightNFT).getInfoKnight(_IDknightResponse);
        if(randReproduction <= 625) {
            uint32 avgLevel = uint32(father.level +  mother.level) / 4;
            uint   id;
            Knight.Equipment memory skin   = Knight.Equipment(0, 0, 0, 0, 0, address(0),"");
            Knight.Power     memory attack = Knight.Power(0, 0, 0, 0, 0);
            Knight.Info      memory info   =  Knight.Info(address(0), "", 0, 0, avgLevel, 0, 0, 0, 0, 1, 0);
            if(avgLevel <= 30) {
                info.defaultAttack   = avgLevel * 480;
                info.defaultSex      = avgLevel * 600;
                attack.healthPoint       = avgLevel * 20;
                attack.damage            = avgLevel * 5;
                attack.defense           = avgLevel * 2;
            } else if(avgLevel <= 70) {
                info.defaultAttack       = 30 * 480   + ((avgLevel - 30) * 540);
                info.defaultSex          = 30 * 600 + ((avgLevel - 30) * 540);
                attack.healthPoint       = 30 * 20 + ((avgLevel - 30) * 30);
                attack.damage            = 30 * 5  + ((avgLevel - 30) * 10);
                attack.defense           = 30 * 2  + ((avgLevel - 30) * 5);
            }
            address owner = IKnightNFT(knightNFT).getOwnerKnight(_IDknightResponse);
            if(randWhoParent <= 50) 
            {
                owner = IKnightNFT(knightNFT).getOwnerKnight(_IDknightRequest);
                id = IKnightNFT(knightNFT).createKnight(info, attack, skin, owner);
            } else  {
                id = IKnightNFT(knightNFT).createKnight(info, attack, skin, owner);
            }
            emit ReproductionKnight(true, _IDknightRequest, _IDknightResponse, id);
        } else {
            emit ReproductionKnight(false, _IDknightRequest, _IDknightResponse, 999_999_999_999);
        }
        _triggerTired(father);
        _triggerTired(mother);
    }
    function _triggerTired(Knight.Info memory _knight) 
        internal 
    {
        _knight.sexTime = uint32(block.timestamp + coolDownSex - _knight.defaultSex);
        IKnightNFT(knightNFT).saveInfoKnight(_knight, _knight.id);
        emit  TriggerTired(_knight.id, _knight.sexTime);
    }

    function setMinAmountgift(uint _newPrice) 
        external 
        onlyRole(OPERATOR_ROLE)
    {
        minAmountgift = _newPrice;
    }

    function setWeddingExpenses(uint _newPrice) 
        external 
        onlyRole(OPERATOR_ROLE) 
    {
        weddingExpenses = _newPrice;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library Random {
    function _computerSeed() internal view returns (uint256) {
        uint256 seed =
        uint256(
            keccak256(
                abi.encodePacked(
                    (block.timestamp)
                    + block.gaslimit
                    + uint256(keccak256(abi.encodePacked(blockhash(block.number)))) / (block.timestamp)
                    + uint256(keccak256(abi.encodePacked(block.coinbase))) / (block.timestamp)
                    + (uint256(keccak256(abi.encodePacked(tx.origin)))) / (block.timestamp)
                )
            )
        );
        return seed;
    }

    function _randMod(uint _modulus) 
        internal view returns(uint) 
    {
        return _computerSeed() % _modulus;
    }

}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;  
import "../Libraries/Knight.sol";
import "../Interface/IKnightNFT.sol";
import "../Interface/IKnightItems.sol";
import "../Interface/IKnightToken.sol";
import "../Interface/IEquipmentToken.sol";
import "../Interface/IMinter.sol";
import "../Interface/IInGameToken.sol";
import "../Libraries/Elixir.sol";
import "../Libraries/LuckyCharm.sol";
import "../Libraries/Random.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
contract KnightUpgrade is AccessControl {
    IKnightNFT knightNFT;
    IKnightItems internal Item;
    IKnightToken internal KnightToken;
    IMinter internal Minter;
    IMAL    internal MAL;
    // uint32 timeGiftOne = 480 seconds; // 30 * 480 = 4 hours
    // uint32 timeGiftTwo = 540 seconds; // 40 * 540 = 6 hours
    // uint32 timeGiftThree = 600 seconds; // 30 * 600 = 5 hours
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    uint256 public constant ELIXIR = 0;
    uint256 public constant CHARM = 1; 
    uint coolDownTime = 1 days;
    uint coolDownSex =  3 days;
    string baseURI;
    string baseImage;
    uint payTolevelUp = 100 * 10 ** 18;
    
    event LevelUp(uint _knightID, uint _newlevel);
    event UpgradeStar(uint numberFee, uint lucky);

    function setBaseImg(string memory _newImg)  external onlyRole(OPERATOR_ROLE) {
        baseImage = _newImg;
    }

    function setBaseURI(string memory _newUri)  external onlyRole(OPERATOR_ROLE) {
        baseURI = _newUri;
    }

    function levelUp(uint _knightID, uint _deposit) 
        external  
    {
        Knight.Info memory myKnight = IKnightNFT(knightNFT).getInfoKnight(_knightID);
        require(_deposit == payTolevelUp * (myKnight.rank + 1), "insufficient token");
        _levelUp(_knightID);
        IMAL(MAL).burnByOperator(_msgSender(), _deposit);
    }

    function _levelUp(uint _knightID) internal  {
        Knight.Info memory  myKnight      = IKnightNFT(knightNFT).getInfoKnight(_knightID);
        Knight.Power memory powerOfKnight = IKnightNFT(knightNFT).getPowerKnight(_knightID);
        if(myKnight.level == 30) {
            revert("< 2 stars");
        } else if(myKnight.level == 70 ){
            revert("< 3 stars");
        }
        require(myKnight.level < 100, "max level");
        if(  myKnight.level < 30) {
            myKnight.level             += 1;
            myKnight.defaultAttack     += 480;
            myKnight.defaultSex        += 600;
            powerOfKnight.healthPoint     += 20 * (myKnight.rank + 1);  // 1000 + 29 * 100 = 3900
            powerOfKnight.damage          += 5  * (myKnight.rank + 1);  // 100 + 29 * 25 = 825
            powerOfKnight.defense         += 2  * (myKnight.rank + 1);  // 100 + 29 * 10 = 390
        } else if( myKnight.level < 70) {
            myKnight.level             += 1;
            myKnight.defaultAttack     += 540;
            myKnight.defaultSex        += 540;
            powerOfKnight.healthPoint     += 30 * (myKnight.rank + 1); // 3900 + 39 *150 = 9750
            powerOfKnight.damage          += 10 * (myKnight.rank + 1); // 825 + 39 * 50 = 2775
            powerOfKnight.defense         += 5  * (myKnight.rank + 1); // 390 + 39 * 25 = 1365
        } else {
            myKnight.level             += 1;
            myKnight.defaultAttack     += 600;
            myKnight.defaultSex        += 480;
            powerOfKnight.healthPoint     += 50 * (myKnight.rank + 1); // 9750 + 50 * 5 * 29 = 17000
            powerOfKnight.damage          += 25 * (myKnight.rank + 1); // 2775 + 29 * 25 *5 = 6400
            powerOfKnight.defense         += 15 * (myKnight.rank + 1); // 1365 + 15 * 5* 29 = 3540
        }
        IKnightNFT(knightNFT).saveInfoKnight(myKnight, _knightID);
        IKnightNFT(knightNFT).savePowerKnight(powerOfKnight, _knightID);
        emit LevelUp(_knightID, myKnight.level);
    }

    function _findMaximum(uint[] memory _ids, address _owner) 
        internal returns(uint32, uint32[] memory)
    {
        LuckyCharm.Info[] memory listCharm = IKnightNFT(knightNFT).getCharm(_owner);
        uint8 lengthCharm = uint8(listCharm.length);
        uint8 lengthArr   = uint8(_ids.length); 
        uint32 max = 0;
        uint32[] memory listLucky = new uint32[](lengthArr);
        for (uint32 i = 0; i < lengthArr; i++) {
           uint id = _ids[i];
           for (uint32 j = 0; j < lengthCharm; j++) {
                LuckyCharm.Info memory charm = listCharm[j];
                if(charm.id == id){
                    if(charm.lucky > max) {
                        max = charm.lucky;
                    }
                    listLucky[i] = charm.lucky;    
                    break;
                } 
           }
        }
        return (max, listLucky);
    }

    function _totalLucky(uint32[] memory _listLucky, uint32 _max ) 
        internal pure returns(uint32) 
    {
        uint32 totalLucky;
        for (uint256 i = 0; i < _listLucky.length; i++) {
            if(_listLucky[i] != _max) {
                totalLucky += uint32(_listLucky[i]) * 2 / 10;
            } else {
                totalLucky += _listLucky[i];
            }
        }
        return totalLucky;
    }

    function upgradeStar(uint _knightID, uint[] memory _charmIDs) 
        external  
        returns(bool ,  Knight.Info memory)
    {
        bool checkCharm = IKnightNFT(knightNFT).checkOwnerCharm(_charmIDs, msg.sender);
        bool checkOwner = IKnightNFT(knightNFT).checkOwner(_knightID, msg.sender);
        require(checkOwner,"Invalid owner");
        require(checkCharm,"Invalid owner");
        Knight.Info memory  myKnight      = IKnightNFT(knightNFT).getInfoKnight(_knightID);
        uint8 lenght = uint8(_charmIDs.length);
        require(myKnight.star < 3, "max star");
        if(myKnight.level < 30) {
            revert("upgrade level 30");
        } else if(myKnight.level < 70 && myKnight.level > 30) {
            revert("upgrade level 70");
        }
        uint32 numberfee = uint32(Random._randMod(1000));
        (uint32 maxCharm , uint32[] memory listLucky) = _findMaximum(_charmIDs, msg.sender);
        uint totalLucky =_totalLucky(listLucky, maxCharm);

        if(numberfee <= totalLucky){
            if(myKnight.level == 30) {
                myKnight.star  = 2;
                myKnight.level = 31;
                myKnight.image = string(abi.encodePacked(baseImage,'knight/', Strings.toString(myKnight.indexImg), "/" , "2.png"));
            } else if(myKnight.level == 70) {
                myKnight.star  = 3;
                myKnight.level = 71;
                myKnight.image = string(abi.encodePacked(baseImage,'knight/', Strings.toString(myKnight.indexImg), "/" , "3.png"));
            }
            IKnightToken(KnightToken).setTokenURI(myKnight.id, string(abi.encodePacked(baseURI,'knight/', Strings.toString(myKnight.rank), "/" , Strings.toString(myKnight.indexImg), "/", Strings.toString(myKnight.star), '.json')));
            IKnightNFT(knightNFT).destroyCharm(_charmIDs);
            IKnightItems(Item).burnByERC721(msg.sender, CHARM, lenght);
            IKnightNFT(knightNFT).saveInfoKnight(myKnight, _knightID);
            emit UpgradeStar(numberfee, totalLucky);
            return (true, myKnight);
        } else {
           IKnightNFT(knightNFT).destroyCharm(_charmIDs);
            IKnightItems(Item).burnByERC721(msg.sender, CHARM, lenght);
            emit UpgradeStar(numberfee, totalLucky);
            return (false, myKnight);
        }
    }

    function setPaytoLevelUp(uint _newPrice) 
        external 
        onlyRole(OPERATOR_ROLE) 
    {
        payTolevelUp = _newPrice;
    }

    function useElixir(uint _knightID, uint _elixirID) 
        external 
    {
        require(IKnightNFT(knightNFT).checkOwner(_knightID, msg.sender) && 
                IKnightNFT(knightNFT).ownerOfElixir(_elixirID) == msg.sender,"Invalid owner");
        Knight.Power memory powerOfKnight = IKnightNFT(knightNFT).getPowerKnight(_knightID);
        Knight.Info memory  myKnight      = IKnightNFT(knightNFT).getInfoKnight(_knightID);
        Elixir.Info  memory myElixir      = IKnightNFT(knightNFT).getElixir(_elixirID);
        if(myElixir.level == Elixir.Level.LevelThree ) {
           unchecked {
                powerOfKnight.healthPoint += 100 * (myKnight.rank + 1);
                powerOfKnight.damage      += 60  * (myKnight.rank + 1);
                powerOfKnight.defense     += 20  * (myKnight.rank + 1);
           }
        } else if(myElixir.level == Elixir.Level.LevelTwo ) {
            unchecked {
                powerOfKnight.healthPoint += 50  * (myKnight.rank + 1);
                powerOfKnight.damage      += 20  * (myKnight.rank + 1);
                powerOfKnight.defense     += 10  * (myKnight.rank + 1);
            }
        } else if(myElixir.level == Elixir.Level.LevelOne) {
            unchecked {
                powerOfKnight.healthPoint += 20  * (myKnight.rank + 1);
                powerOfKnight.damage      += 10  * (myKnight.rank + 1);
                powerOfKnight.defense     += 5   * (myKnight.rank + 1);
            }
        }
        IKnightNFT(knightNFT).savePowerKnight(powerOfKnight, _knightID);
        IKnightNFT(knightNFT).destroyElixir(_elixirID, msg.sender);
        IKnightItems(Item).burnByERC721(msg.sender, ELIXIR, 1);
    }

    function useEquipment(uint _knightId, uint32 _equipmentId) 
        external 
    {
        IKnightNFT(knightNFT).useEquipment(_knightId, _equipmentId, msg.sender);
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
pragma solidity ^0.8.9;

library Knight {
    struct Info {
        address owner;
        string  image;
        uint    id;
        uint    indexImg;
        uint32  level;
        uint32  attackTime;
        uint32  sexTime;
        uint32  defaultAttack;
        uint32  defaultSex;
        uint8   star;
        uint8   rank;
    }

    struct Power {
        uint32 healthPoint;
        uint32 damage;
        uint32 defense;
        uint32 excitementPoint;
        uint32 equipmentId;
    }

    struct Equipment {
        uint id;
        uint32 healthPoint;
        uint32 damage;
        uint32 defense;
        uint32 rank;
        address owner;
        string  image;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 < 0.9.0;
import "../Libraries/Knight.sol";
import "../Libraries/LuckyCharm.sol";
import "../Libraries/Elixir.sol";
interface IKnightNFT {
    
    function checkOwner( uint, address ) external returns(bool);

    function getInfoKnight(uint) external returns(Knight.Info memory);

    function getPowerKnight(uint) external returns(Knight.Power memory); 

    function saveInfoKnight(Knight.Info memory , uint) external;

    function checkOwnerCharm(uint[] memory, address) external returns(bool);

    function getCharm(address) external returns(LuckyCharm.Info[] memory);

    function destroyCharm(uint[] memory _ids) external;

    function ownerOfElixir(uint _elixirID) external view returns(address); 

    function getElixir(uint ) external view returns(Elixir.Info memory);

    function destroyElixir(uint , address) external;

    function savePowerKnight(Knight.Power memory , uint) external;

    function useEquipment(uint , uint32, address) external;

    // function checkLevel(uint , uint) external view  returns(bool);

    function getOwnerKnight(uint) external view  returns(address);

    function createKnight(Knight.Info memory , Knight.Power memory , Knight.Equipment memory , address ) external returns(uint);

    function rewardForBattle(uint, address) external  returns(uint , uint[] memory);

    function mintElixir(uint, uint, address) external;

    function getEquipment(uint ) external view  returns(Knight.Equipment memory);

    function rewardForMission(uint, uint, address) external ;
}

//SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 < 0.9.0;

interface IKnightToken {

    function safeMintKnight(address, uint, uint, uint ) external;

    function getImgToken(uint) external returns(string memory);
    
    function setTokenURI(uint ,string memory) external;

    function getCurrentId() external view  returns(uint);
}

//SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 < 0.9.0;
import "../Libraries/Elixir.sol";

interface IKnightItems {

    function mintByERC721(address, uint256 , uint256, bytes memory) external;
    function mintBatchByERC721(address , uint256[] memory, uint256[] memory, bytes memory) external;
    function burnByERC721(address, uint, uint) external;
    function transferByERC721 (address ,address ,uint256 ,uint256 ,bytes memory) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
pragma experimental ABIEncoderV2;

interface IMinter {
    function transfer(address, uint256) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
pragma experimental ABIEncoderV2;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMAL is IERC20{
    function mint(address, uint256) external;
    function burnByOperator(address, uint256) external;
    function transferByOperator(address, address, uint256) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library LuckyCharm {
    enum Level{ Nonlevel ,One ,Two, Three, Four, Five, Six, Seven}

    struct Info {
        Level level;
        uint id;
        address owner;
        uint32 lucky;
    }

    
}

//SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 < 0.9.0;

interface IEquipmentToken {

    function safeMintEquipment(address, uint) external;

    function getImgToken(uint) external returns(string memory);
    
    function setTokenURI(uint ,string memory) external;

    function getCurrentId() external view  returns(uint);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library Elixir {
    enum Level{ Nonlevel , LevelOne , LevelTwo, LevelThree}

    struct Info {
        Level level;
        uint id;
        address owner;
    }
    
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
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
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
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