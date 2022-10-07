//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './KnightReward.sol';
import "../Libraries/HistoryBattle.sol";
contract KnightQuery is KnightReward {
    
    constructor(IKnightItems _contractItem, IKnightToken _knighToken, IMinter _minter, IMAL _mal, IEquipmentToken _equipmentToken) {
        Item = _contractItem; 
        KnightToken = _knighToken;
        Minter = _minter;
        MAL = _mal;
        EquipmentToken = _equipmentToken;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
        //convert 5 level rank with rate common: 55%, rare: 30%, super-rare: 10%, epic: 4%, legendary: 1%
        rarities[0] = [255, 143, 128, 51, 18];
        aliases[0]  = [0, 0, 0, 0, 1];
    }


    function getKnightbyOwner(address _owner) 
        external  view
        returns(Knight.Info[] memory knights)
    {
        knights = knightOfOwner[_owner];
        for(uint i = 0; i < knights.length; i++){
            if(infoOfKnight[knights[i].id].owner == _owner) {
                knights[i] = infoOfKnight[knights[i].id];
            }
        }
        return knights;
    }
 
    function getKnightDetail() 
        external view  
        returns(Knight.Info[] memory listKnight, Knight.Power[] memory listAttack) 
    {
        listKnight = knightOfOwner[_msgSender()];
        listAttack = new Knight.Power[](listKnight.length);
        for(uint i = 0; i < listKnight.length; i++){
            if(infoOfKnight[ listKnight[i].id].owner == _msgSender()) {
                listKnight[i] = infoOfKnight [listKnight[i].id];
                listAttack[i] = powerOfKnight[listKnight[i].id];
            }
        }

        return (listKnight, listAttack);
    }


    function getElixirbyOwner()
        external view
        returns(Elixir.Info[] memory elixirs)
    {
        elixirs = elixirOfOwner[_msgSender()];
        uint32 lenght = uint32(elixirs.length);
        for(uint i = 0; i < lenght; i++){
            elixirs[i] = listElixir[elixirs[i].id];
        }
        return elixirs;
    }

    function getEquipmentbyOwner() 
        external view
        returns(Knight.Equipment[] memory equipments)
    {
        address owner = _msgSender();
        equipments = equipmentOfOwner[owner];
        for(uint i = 0; i < equipments.length; i++){
            equipments[i] = equipmentList[equipments[i].id];
        }
        return equipments;
    }

    function getInfoKnight(uint _knightId) external view returns(Knight.Info memory) {
        return infoOfKnight[_knightId];
    }

    function getPowerKnight(uint _knightId) external view  returns(Knight.Power memory) {
        require(hasRole(OPERATOR_ROLE, msg.sender) || infoOfKnight[_knightId].owner == msg.sender , 'invalid role');
        return powerOfKnight[_knightId];
    }

    function getEquipment(uint _idEquipment) external view  returns(Knight.Equipment memory) {
        require(hasRole(OPERATOR_ROLE, msg.sender) || equipmentList[_idEquipment].owner == msg.sender , 'invalid role');
        return equipmentList[_idEquipment];
    }

    function getOwnerKnight(uint _knightId) external view onlyRole(OPERATOR_ROLE) returns(address) {
        return infoOfKnight[_knightId].owner;
    }

    function saveInfoKnight(Knight.Info memory _info, uint _knightId) external onlyRole(OPERATOR_ROLE) {
        infoOfKnight[_knightId] = _info;
    }

    function savePowerKnight(Knight.Power memory _power, uint _knightId) external onlyRole(OPERATOR_ROLE) {
        powerOfKnight[_knightId] = _power;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './KnightItems.sol';
contract KnightReward is KnightItems {
   
    uint rewardIndex = 10; 
    mapping(address => uint) public  userReward; 
  
    modifier onlyOwnerOfKnight(uint _knightID) {
        require(_ownerOf(_knightID) == msg.sender,"Invalid owner");
        _;
    }

    function setReward(uint _newReward) external onlyRole(OPERATOR_ROLE) {
        rewardIndex = _newReward;
    }

    function rewardForBattle(uint _knightID, address _owner) external onlyRole(OPERATOR_ROLE) returns(uint rewardBattle, uint[] memory listElixir) {
        Knight.Power     memory attack = Knight.Power(1000, 100, 100, 0, 0);
        Knight.Equipment memory skin   = Knight.Equipment(0, 0, 0, 0, 0, msg.sender, "");
        Knight.Info      memory info   = Knight.Info(msg.sender, "", 0, 0, 1, 0, 0, 0, 0, 1, 0);
        uint luckyNumber = Random._randMod(1000);
        if(luckyNumber <= 700) {
            listElixir = _mintElixir(3, 1, _owner);
            rewardBattle = 20 * rewardIndex;
            userReward[infoOfKnight[_knightID].owner] += rewardBattle; 
        } else if(luckyNumber <= 950 && luckyNumber > 700) {
            listElixir = _mintElixir(2, 2, _owner);
            rewardBattle = 25 * rewardIndex;
            userReward[infoOfKnight[_knightID].owner] += rewardBattle; 
        }else if(luckyNumber <= 999 && luckyNumber > 950) {
            listElixir = _mintElixir(1, 3, _owner);
            rewardBattle = 30 * rewardIndex;
            userReward[infoOfKnight[_knightID].owner] += rewardBattle; 
        }
        _createKnight(info , attack, skin, _owner);
        return (rewardBattle, listElixir);
    } 

    function withdrawReward() external {
        address owner = _msgSender();
        require(userReward[owner] > 0 , "KnightReward: you have no reward");
        Minter.transfer(owner, userReward[owner]);
    }


    function rewardForMission(uint _mission, uint _deposit, address _owner) 
        external 
        onlyRole(OPERATOR_ROLE)
    {
            uint equipId =  IEquipmentToken(EquipmentToken).getCurrentId();
            uint seed = Random._randMod(10000000);
            Knight.Equipment memory myEquipment = Knight.Equipment(equipId, 0, 0, 0, 0, _owner,"");
            uint32 rarity  = _selectTrait(uint16(seed & 0xFFFF), 0);
            myEquipment.rank = rarity;
            myEquipment.damage = uint32(524 * _mission) * (rarity + 1) ;
            myEquipment.defense = uint32(476 * _mission) * (rarity + 1);
            myEquipment.healthPoint = uint32(1348 * _mission) * (rarity + 1);
             IEquipmentToken(EquipmentToken).safeMintEquipment(_owner, rarity);
            myEquipment.image =   IEquipmentToken(EquipmentToken).getImgToken(equipId);
            equipmentOfOwner[_owner].push(myEquipment);
            equipmentList[equipId] = myEquipment;
            IMAL(MAL).burnByOperator(_owner, _deposit);
            IMinter(Minter).transfer(_owner, _deposit + 2 * _mission * 10**18);
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

import "./KnightMission.sol";
import "../Libraries/Elixir.sol";
import "../Libraries/LuckyCharm.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
contract KnightItems is KnightMission {
    
    using Strings for uint256;
    using Counters for Counters.Counter;
    
    Counters.Counter internal _elixirIdCounter;
    Counters.Counter internal _charmCounter; 

    uint priceDefault = 500 * 10**18;

                 
    mapping(uint => Elixir.Info)      internal listElixir;   
    mapping(uint => address)          internal balancesElixir;
    mapping(address => Elixir.Info[]) internal elixirOfOwner;

    event BuyElixir(address account, uint8 level, uint[] elixirID, uint amount);

    LuckyCharm.Info[] internal listLuckyCharm;

    mapping(uint => address)         internal balancesCharm;
    mapping(address => LuckyCharm.Info[]) internal charmOfOwner; // internal 

    event BuyLuckyCharm(address account, uint8 level, uint[] charmID, uint amount);

    function buyElixir(uint8 _level, uint8 _amount, uint _deposit) 
        external  
    {
        require(_level <= 3 && _level > 0, "Invalid level elixir");
        require(_deposit / _amount == priceDefault || _deposit / _amount == priceDefault * 2 || _deposit / _amount == priceDefault * 3, "insufficient supply of token");
        IMAL(MAL).burnByOperator(_msgSender(), _deposit);
        emit BuyElixir(msg.sender, uint8(_level), _mintElixir(_amount, uint8(_level), _msgSender()), _amount);
    }

    function _mintElixir(uint8 _amount, uint8 _level, address _owner) 
        internal returns (uint[]  memory ) 
    {
        uint[] memory  listID = new uint[](_amount);
        for (uint8 i = 0; i < _amount; i++) {
            uint elixirID  = _elixirIdCounter.current(); 
            listElixir[elixirID] = Elixir.Info(Elixir.Level(_level), elixirID, _owner);
            listID[i] = elixirID;
            elixirOfOwner[_owner].push(Elixir.Info(Elixir.Level(_level), elixirID, _owner));
            balancesElixir[elixirID] = _owner;
            _elixirIdCounter.increment();
        }
        IKnightItems(Item).mintByERC721(_owner, ELIXIR, _amount, "");
        return listID;
    }

    function mintElixir(uint8 _amount,uint8 _level,address _owner) external onlyRole(OPERATOR_ROLE) {
        _mintElixir(_amount, _level, _owner);
    }

    function ownerOfElixir(uint _elixirID) 
        external view returns(address) 
    {
        address owner = balancesElixir[_elixirID];
        require(owner != address(0), "ERC721: invalid elixir ID");
        return owner;
    }

    function buyCharm(uint8 _level, uint8 _amount, uint _deposit) 
        external  
    {
        require(_level <= uint8(LuckyCharm.Level.Seven) , " Invalid level elixir");
        require(_amount <= 10, "Invalid amount");
        require(_deposit / _amount == priceDefault || 
                _deposit / _amount == priceDefault * 2 || 
                _deposit / _amount == priceDefault * 3 ||
                _deposit / _amount == priceDefault * 4 ||
                _deposit / _amount == priceDefault * 5 ||
                _deposit / _amount == priceDefault * 6 ||
                _deposit / _amount == priceDefault * 7, "insufficient supply of STI Coin");
        IMAL(MAL).burnByOperator(_msgSender(), _deposit);
        emit BuyLuckyCharm(msg.sender, uint8(_level), _mintCharm(_amount, uint(_level)) , _amount);
    }

    function _mintCharm(uint _amount, uint _level) 
        internal returns (uint[]  memory ) 
    {
        uint[] memory  listID = new uint[](_amount);
        for (uint256 i = 0; i < _amount; i++) {
            uint charmID  = _charmCounter.current(); 
            uint lucky    =  Random._randMod(300); 
            listLuckyCharm.push(LuckyCharm.Info(LuckyCharm.Level(_level), charmID, msg.sender, uint32(lucky + _level * 50)));
            listID[i] = charmID;
            charmOfOwner[msg.sender].push(LuckyCharm.Info(LuckyCharm.Level(_level), charmID, msg.sender, uint32(lucky + _level * 50)));
            balancesCharm[charmID] = msg.sender;
            _charmCounter.increment();
        }
        IKnightItems(Item).mintByERC721(msg.sender, CHARM, _amount, "");
        return listID;
    }

    function checkOwnerCharm(uint[] memory _charmId, address _owner) external view returns(bool) {
        uint lenghtCharm = _charmId.length;
        require(lenghtCharm > 0, "Please!, Providing charm is not enough");
        for (uint256 i = 0; i < lenghtCharm; i++) {
          if(balancesCharm[_charmId[i]] != _owner){
            return false;
          }
        } 
        return true;
    }

    function getCharm(address _owner) external view returns(LuckyCharm.Info[] memory) {
        return charmOfOwner[_owner];
    }

    function getElixir(uint _elixirId) external view returns(Elixir.Info memory) {
        return listElixir[_elixirId];
    }

    function destroyCharm(uint[] memory _ids) external onlyRole(OPERATOR_ROLE) {
        LuckyCharm.Info[] memory listCharm = charmOfOwner[msg.sender];
        uint lengthCharm  = listCharm.length;
        uint lengthId     = _ids.length; 
        for (uint256 i = 0; i < lengthId; i++) {
            for (uint256 j = 0; j < lengthCharm; j++) {
                if(listCharm[j].id == _ids[i]) {
                    delete listLuckyCharm[_ids[i]];
                    delete charmOfOwner[msg.sender][j];
                }
            }
        }
    }

    function destroyElixir(uint _elixirId, address _owner) external onlyRole(OPERATOR_ROLE) {
        uint lenght = elixirOfOwner[_owner].length;
        for (uint256 index = 0; index < lenght; index++) {
            if(elixirOfOwner[_owner][index].id == _elixirId)
            {
                delete elixirOfOwner[_owner][index];
            }
        }
        delete listElixir[_elixirId];
        delete balancesElixir[_elixirId];
    }
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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './KnightFactory.sol';
import "../Libraries/Knight.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
contract KnightMission is KnightFactory , ERC721Holder{
    
    function initMission() public onlyRole(OPERATOR_ROLE) {
        Knight.Equipment   memory equipmentO   = Knight.Equipment(0, 0, 0, 0, 0, address(this), "");
        equipmentList[ IEquipmentToken(EquipmentToken).getCurrentId() ] = equipmentO;
        limitKnight[address(this)] = 10000;
        IEquipmentToken(EquipmentToken).safeMintEquipment(address(this), 0);
        for (uint32 i = 1; i <= 5 ; i++) {
            uint EquipId =  IEquipmentToken(EquipmentToken).getCurrentId();
            Knight.Power     memory attack    = Knight.Power(1542 * i, 96 * i, 46 * i, 901, uint32(EquipId));
            Knight.Equipment memory equipment = Knight.Equipment(EquipId, 1127 * i,  124 * i, 75 * i,  i - 1 , address(this),"");
            Knight.Info      memory info      = Knight.Info(address(this), "", 0, 0, 100, 0, 0, 0, 0, 3, 0);
            IEquipmentToken(EquipmentToken).safeMintEquipment(address(this), i - 1);
            equipment.image =  IEquipmentToken(EquipmentToken).getImgToken(EquipId);
            _createKnight(info, attack, equipment, address(this));
            equipmentList[EquipId] = equipment;
        }
    }

    function useEquipment(uint _knightId, uint32 _idEquipment, address _owner) external onlyRole(OPERATOR_ROLE) {
        checkOwner(_knightId, _owner);
        require(equipmentList[_idEquipment].owner == _owner, "Invalid owner");
        powerOfKnight[_knightId].equipmentId = _idEquipment;
    }

    // function checkLevel(uint _knightId, uint _level) external view onlyRole(OPERATOR_ROLE) returns(bool) {
    //     return infoOfKnight[_knightId].level >= _level;
    // }
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

//SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 <0.9.0;

import "../Interface/IKnightItems.sol";
import "../Interface/IKnightToken.sol";
import "../Interface/IEquipmentToken.sol";
import "../Interface/IMinter.sol";
import "../Interface/IInGameToken.sol";
import "../Libraries/Knight.sol";
import "../Libraries/Random.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
contract KnightFactory is AccessControl {
    using Strings for uint256;
    uint256 public constant ELIXIR = 0;
    uint256 public constant CHARM = 1; 
    address internal  boss;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    string baseExtentionJson = ".json";  
    string baseExtentionImage = ".png";  
    uint coolDownTime = 1 days;
    uint randNonce = 0;
    uint coolDownSex =  3 days;
    uint maxReleaseKnight = 2 * 10;
   
    IKnightItems internal Item;
    IKnightToken internal KnightToken;
    IMinter internal Minter;
    IMAL    internal MAL;
    IEquipmentToken internal EquipmentToken;
    uint8[][18] public rarities;
    uint8[][18] public aliases;
    uint  public feePaytoLimit = 1000 * 10 ** 18;
    uint  public feePaytoMint  = 1000 * 10 ** 18;
    event NewKnight(Knight.Info newKnight);


    mapping(uint => Knight.Info) public infoOfKnight;
    mapping(address => bool) private initKnight;
    mapping(address => Knight.Info[]) internal knightOfOwner;
    mapping(address => Knight.Equipment[]) internal equipmentOfOwner;
    mapping(address => uint) public countKnight;
    mapping(address => uint) internal limitKnight;
    mapping(uint => address) internal ownerKnight;
    mapping(uint =>  Knight.Power) internal powerOfKnight;
    mapping(uint =>  Knight.Equipment) internal equipmentList;

    function _selectTrait(uint16 seed, uint8 traitType) 
        internal view returns (uint8) 
    {
        uint8 trait = uint8(seed) % uint8(rarities[traitType].length);// 0 -> 4
        if (seed >> 8 < rarities[traitType][trait]) return trait; // seed / 2 **8 
        return aliases[traitType][trait];
    }

    function _selectTraits(uint256 seed, Knight.Info memory _info) 
        internal view returns(Knight.Info memory)
    { 
        seed >>= 16; // seed = seed / 2**16
        _info.rank = _selectTrait(uint16(seed & 0xFFFF), 0);
        seed >>= 16;
        _info.indexImg = (uint8(seed & 0xFFFF) % 2**5) + 1;
        return _info;
    }

    function _createKnight(Knight.Info memory _info, Knight.Power memory _attack, Knight.Equipment memory _equipment, address _owner) 
        internal 
        returns(uint _knightId)
    {
        require(countKnight[_owner] < limitKnight[_owner], "max limit knight");
        _knightId = IKnightToken(KnightToken).getCurrentId();
        uint seed = Random._randMod(10000000);
        _info.rank = _selectTrait(uint16(seed & 0xFFFF), 0);
        _info.owner = _owner;
        _info.indexImg = (uint8(seed & 0xFFFF) % maxReleaseKnight);
        IKnightToken(KnightToken).safeMintKnight(_owner,  _info.rank,  _info.indexImg, 1);
        _info.attackTime = uint32(block.timestamp);
        _info.sexTime = uint32(block.timestamp);
        _info.id = _knightId;
        _info.image = IKnightToken(KnightToken).getImgToken(_knightId);
        if(_equipment.id != 0) {
            equipmentOfOwner[_owner].push(_equipment);
        }
        infoOfKnight[_knightId]  = _info;
        powerOfKnight[_knightId] = _attack;
        knightOfOwner[_owner].push(_info);
        countKnight[_owner] =  knightOfOwner[_owner].length;
        ownerKnight[_knightId] = _owner;
        IKnightToken(KnightToken).setTokenURI(_knightId, _info.image);
        emit NewKnight(_info);
        return _knightId;
    }

    function _ownerOf(uint _knightid) internal view returns(address){
        address owner = ownerKnight[_knightid];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    function checkOwner(uint _knightid, address _owner) public view onlyRole(OPERATOR_ROLE) returns (bool) {
        return _ownerOf(_knightid) == _owner;
    }

    function setReleaseKnight(uint _newRelease) public onlyRole(OPERATOR_ROLE) {
        maxReleaseKnight = _newRelease;
    }
    
    function createKnight(Knight.Info memory _info, Knight.Power memory _attack, Knight.Equipment memory _equipment, address _owner) external onlyRole(OPERATOR_ROLE) returns(uint) {
        return  _createKnight(_info, _attack, _equipment, _owner);
    }

    function initialKnight() 
        external
    {
        address owner = _msgSender();
        require(getInitKnight(owner) == false, "Only the first time");
        Knight.Power memory attack =  Knight.Power(1000, 100, 100, 0, 0);
        Knight.Equipment   memory equipment   = Knight.Equipment(0, 0, 0, 0, 0, address(0),"");
        Knight.Info   memory info   = Knight.Info(owner, "", 0, 0, 1, 0, 0, 0, 0, 1, 0);
        limitKnight[owner] = 5;
        _createKnight(info, attack, equipment, owner);
        initKnight[owner] = true; 
        IMinter(Minter).transfer(owner, 100 * 10 ** 18);
    }

    function safeMint(uint _deposit) external {
        require(_deposit == feePaytoMint, "Invalid deposit");
        address owner = _msgSender();
        Knight.Power     memory attack    = Knight.Power(1000, 100, 100, 0, 0);
        Knight.Equipment memory equipment = Knight.Equipment(0, 0, 0, 0, 0, address(0),"");
        Knight.Info      memory info      = Knight.Info(owner, "", 0, 0, 1, 0, 0, 0, 0, 1, 0);
        _createKnight(info, attack, equipment, owner); 
        IMAL(MAL).burnByOperator(owner, _deposit);
    }

    function incrementLimitKnight(uint _deposit) external {
        require(_deposit == feePaytoLimit, "Invalid deposit");
        limitKnight[_msgSender()]++;
    }

    function getInitKnight(address _owner)
        public view returns(bool) 
    {
        return initKnight[_owner];
    }    

    function setFeeLimitKnight(uint _newFee) public onlyRole(OPERATOR_ROLE) {
        feePaytoLimit = _newFee;
    }

    function setFeeMintKnight(uint _newFee)  public onlyRole(OPERATOR_ROLE) {
        feePaytoMint = _newFee;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
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
pragma experimental ABIEncoderV2;

interface IMinter {
    function transfer(address, uint256) external;
}

//SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 < 0.9.0;

interface IKnightToken {

    function safeMintKnight(address, uint, uint, uint ) external;

    function getImgToken(uint) external returns(string memory);
    
    function setTokenURI(uint ,string memory) external;

    function getCurrentId() external view  returns(uint);
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