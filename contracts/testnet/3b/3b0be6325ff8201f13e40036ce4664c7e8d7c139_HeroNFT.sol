// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./BaseNFT.sol";
import "../libs/fota/ArrayUtil.sol";
import "../libs/fota/StringUtil.sol";
import "../interfaces/IEnergyManager.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../interfaces/IFOTAPricer.sol";
import "../interfaces/IMarketPlace.sol";

contract HeroNFT is BaseNFT {
  using StringUtil for string;
  using ArrayUtil for uint[];

  struct Hero {
    uint16 id;
    uint createdAt;
    uint8 level;
    uint32 experience;
    uint ownPrice;
    uint failedUpgradingAmount;
    uint[3] skills;
    uint totalProfited;
  }

  mapping (uint => Hero) public heroes;
  mapping (bytes24 => bool) private heroNames;
  mapping (uint16 => string) public mappingHeroRace;
  mapping (uint16 => string) public mappingHeroClass;
  mapping (uint16 => string) public mappingHeroName;
  mapping (uint16 => uint[7]) private strengthIndexReferences;
  mapping (uint16 => uint[7]) private strengthBonuses;
  mapping (uint8 => uint32) public experienceCheckpoint;

  uint16 public countId;
  IEnergyManager public energyManager;
  uint public totalSupply;
  uint public profitRate;
  mapping (address => uint[]) private ownerHeroes;
  bool beforeTokenTransferLogicEnabled; // TODO remove on mainnet upgrading
  mapping (address => bool) exclusives;
  IMarketPlace public marketPlace;
  mapping (uint => uint) public fotaOwnPrices;
  mapping (uint => uint) public heroTotalProfitedInFota;
  IFOTAPricer public fotaPricer;
  uint public fotaProfitRate;
  mapping (uint => bool) public lockedFromMKP;

  event NewClassAdded(
    uint16 classId,
    string klass,
    uint[7] strengths
  );
  event LevelUp(
    uint tokenId,
    uint level,
    uint nextLevelCheckpoint
  );
  event ExperienceUp(
    uint tokenId,
    uint32 experience
  );
  event ExperienceCheckpointUpdated(
    uint16 level,
    uint32 experience
  );
  event BaseStrengthUpdated(
    uint16 classId,
    uint[7] baseStrength
  );
  event StrengthBonusUpdated(
    uint16 classId,
    uint[7] strengthBonus
  );
  event SkillUp(
    uint tokenId,
    uint index,
    uint level
  );
  event HeroRaceUpdated(
    uint16 classId,
    string race
  );
  event HeroClassUpdated(
    uint16 classId,
    string klass
  );
  event HeroNameUpdated(
    uint16 classId,
    string name
  );
  event HeroInfoUpdated(
    uint tokenId,
    uint8 level,
    uint32 experience,
    uint[3] skills
  );
  event TotalProfitedUpdated(
    uint tokenId,
    uint totalProfited
  );
  event FOTATotalProfitedUpdated(
    uint tokenId,
    uint fotaTotalProfited
  );
  event ProfitRateUpdated(
    uint profitRate
  );
  event LockedFromMKPStatusUpdated(
    uint[] tokenIds,
    bool locked
  );

  function initialize(
    address _mainAdmin,
    string calldata _name,
    string calldata _symbol
  ) override public initializer {
    BaseNFT.initialize(_mainAdmin, _name, _symbol);
  }

  function mintHero(address _owner, uint16 _classId, uint _price, uint _index) onlyMintAdmin public returns (uint) {
    return _mint(_owner, _classId, _price, _index);
  }

  function mintHeroes(address _owner, uint16 _classId, uint _price, uint _quantity) onlyMintAdmin external {
    for(uint i = 0; i < _quantity; i++) {
      _mint(_owner, _classId, _price, i);
    }
  }

  function getHero(uint _tokenId) external view returns (string memory, string memory, string memory, uint16, uint, uint8, uint32) {
    return (
      mappingHeroRace[heroes[_tokenId].id],
      mappingHeroClass[heroes[_tokenId].id],
      mappingHeroName[heroes[_tokenId].id],
      heroes[_tokenId].id,
      heroes[_tokenId].createdAt,
      heroes[_tokenId].level,
      heroes[_tokenId].experience
    );
  }

  function getHeroSkills(uint _tokenId) external view returns (uint, uint, uint) {
    return (
      heroes[_tokenId].skills[0],
      heroes[_tokenId].skills[1],
      heroes[_tokenId].skills[2]
    );
  }

  function getClassId(uint _tokenId) external view returns (uint16) {
    return heroes[_tokenId].id;
  }

  function getCreator(uint _tokenId) override external view returns (address) {
    return creators[heroes[_tokenId].id];
  }

  function getStrengthIndexReferences(uint16 _classId) external view returns (uint, uint, uint, uint, uint, uint, uint) {
    return (
      strengthIndexReferences[_classId][0],
      strengthIndexReferences[_classId][1],
      strengthIndexReferences[_classId][2],
      strengthIndexReferences[_classId][3],
      strengthIndexReferences[_classId][4],
      strengthIndexReferences[_classId][5],
      strengthIndexReferences[_classId][6]
    );
  }

  function getStrengthBonuses(uint16 _classId) external view returns (uint, uint, uint, uint, uint, uint, uint) {
    return (
      strengthBonuses[_classId][0],
      strengthBonuses[_classId][1],
      strengthBonuses[_classId][2],
      strengthBonuses[_classId][3],
      strengthBonuses[_classId][4],
      strengthBonuses[_classId][5],
      strengthBonuses[_classId][6]
    );
  }

  function reachMaxProfit(uint _tokenId) public view returns (bool) {
    require(_exists(_tokenId), "Hero not found");
    Hero storage hero = heroes[_tokenId];
    return hero.totalProfited >= _getMaxProfitable(_tokenId);
  }

  function _beforeTokenTransfer(
    address _from,
    address _to,
    uint256 _tokenId
  ) internal override {
    super._beforeTokenTransfer(_from, _to, _tokenId);
    if (_to == address(0)) {
      delete heroes[_tokenId];
      totalSupply--;
    } else {
      if (!exclusives[_to]) {
//        if (_from == address(0) || !reachMaxProfit(_tokenId)) {
//          energyManager.updatePoint(_to, 1);
//        }
        ownerHeroes[_to].push(_tokenId);
      }
    }
    if (_from == address(0)) {
      totalSupply++;
    } else if (!exclusives[_from]) {
//      if (!reachMaxProfit(_tokenId)) {
//        energyManager.updatePoint(_from, -1);
//      }
      ownerHeroes[_from].removeElementFromArray(_tokenId);
    }
  }

  // PRIVATE FUNCTIONS

  function _mint(address _owner, uint16 _classId, uint _price, uint _index) private returns (uint) {
    require(_classId >= 1 && _classId <= countId, 'NFT: Invalid class');
    uint newId = _genNewId(_index);
    _mint(_owner, newId);
    heroes[newId].id = _classId;
    heroes[newId].level = 1;
    heroes[newId].createdAt = block.timestamp;
    heroes[newId].ownPrice = _price;
    heroes[newId].skills = [1, 0, 0];
    return newId;
  }

  function _levelUp(uint _tokenId, uint steps) private {
    heroes[_tokenId].level += uint8(steps);
    emit LevelUp(_tokenId, heroes[_tokenId].level, experienceCheckpoint[heroes[_tokenId].level + 1]);
  }

  function getOwnerHeroes(address _owner) external view returns(uint[] memory) {
    return ownerHeroes[_owner];
  }

  function getOwnerTotalHeroThatNotReachMaxProfit(address _owner) external view returns(uint) {
    uint totalHero;
    uint[] memory ids = ownerHeroes[_owner];
    for(uint i = 0; i < ids.length; i++) {
      if (!reachMaxProfit(ids[i])) {
        totalHero += 1;
      }
    }
    return totalHero;
  }

  function tokenURI(uint _tokenId) public view override returns (string memory) {
    require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
    uint16 classId = heroes[_tokenId].id;
    string memory classIdStr = Strings.toString(classId);
    string memory domain = block.chainid == 56 ? 'https://marketplace.fota.io' : 'https://dev-marketplace.fota.io';

    return string(abi.encodePacked(domain, '/metadata/heroes/', classIdStr, '.json'));
  }

  // ADMIN FUNCTIONS

  function updateBaseStrengths(uint16 _classId, uint[7] calldata _strengths) external onlyMainAdmin {
    strengthIndexReferences[_classId] = _strengths;
    emit BaseStrengthUpdated(_classId, _strengths);
  }

  function updateStrengthBonus(uint16 _classId, uint[7] calldata _strengthBonuses) external onlyMainAdmin {
    strengthBonuses[_classId] = _strengthBonuses;
    emit StrengthBonusUpdated(_classId, _strengthBonuses);
  }

  function updateExperienceCheckpoint(uint8 _level, uint32 _experience) external onlyMainAdmin {
    experienceCheckpoint[_level] = _experience;
    emit ExperienceCheckpointUpdated(_level, _experience);
  }

  function updateOwnPrice(uint _tokenId, uint _ownPrice) override onlyMintAdmin external {
    Hero storage hero = heroes[_tokenId];
    hero.ownPrice = _ownPrice;
    emit OwnPriceUpdated(_tokenId, _ownPrice);
  }

  function increaseTotalProfited(uint[] memory _tokenIds, uint[] memory _amounts) onlyMintAdmin external {
    for (uint i = 0; i < _tokenIds.length; i++) {
      Hero storage hero = heroes[_tokenIds[i]];
      uint maxProfitable = _getMaxProfitable(_tokenIds[i]);

      if (hero.totalProfited + _amounts[i] >= maxProfitable) {
        hero.totalProfited = maxProfitable;
      } else {
        hero.totalProfited += _amounts[i];
      }
      emit TotalProfitedUpdated(_tokenIds[i], hero.totalProfited);
    }
  }

  function updateProfitRate(uint _profitRate) onlyMainAdmin external {
    profitRate = _profitRate;
    emit ProfitRateUpdated(_profitRate);
  }

  function experienceUp(uint[] memory _tokenIds, uint32[] memory _experiences) external onlyGameContract {
    for (uint i = 0; i < _tokenIds.length; i++) {
      for (uint j = 26; j > heroes[_tokenIds[i]].level; j--) {
        if (heroes[_tokenIds[i]].experience + _experiences[i] >= experienceCheckpoint[uint8(j)]) {
          _levelUp(_tokenIds[i], j - heroes[_tokenIds[i]].level);
        }
      }
      heroes[_tokenIds[i]].experience += _experiences[i];
      emit ExperienceUp(_tokenIds[i], heroes[_tokenIds[i]].experience);

      uint8 levelMod5 = uint8(heroes[_tokenIds[i]].level % 5);
      if (levelMod5 != 1 && levelMod5 != 3) {
        uint skillIndex = levelMod5 == 0 ? 0 : levelMod5 == 2 ? 1 : 2;
        heroes[_tokenIds[i]].skills[skillIndex] += 1;
        emit SkillUp(_tokenIds[i], skillIndex, heroes[_tokenIds[i]].skills[skillIndex]);
      }
    }
  }

  function addHeroClass(string calldata _race, string calldata _class, string calldata _name, uint[7] calldata _strengths, address _creator) external onlyMainAdmin {
    require(!heroNames[_name.toBytes24()], "Name exists");
    heroNames[_name.toBytes24()] = true;
    countId += 1;

    mappingHeroRace[countId] = _race;
    mappingHeroClass[countId] = _class;
    mappingHeroName[countId] = _name;
    strengthIndexReferences[countId] = _strengths;
    creators[countId] = _creator;
    emit NewClassAdded(countId, _class, _strengths);
  }

  function updateHeroRace(uint16 _classId, string calldata _race) external onlyMainAdmin {
    mappingHeroRace[_classId] = _race;
    emit HeroRaceUpdated(_classId, _race);
  }

  function updateHeroClass(uint16 _classId, string calldata _class) external onlyMainAdmin {
    mappingHeroClass[_classId] = _class;
    emit HeroClassUpdated(_classId, _class);
  }

  function updateHeroName(uint16 _classId, string calldata _name) external onlyMainAdmin {
    require(!heroNames[_name.toBytes24()], "Name exists");
    heroNames[mappingHeroName[_classId].toBytes24()] = false;
    heroNames[_name.toBytes24()] = true;
    mappingHeroName[_classId] = _name;
    emit HeroNameUpdated(_classId, _name);
  }

  function updateHeroInfo(uint _tokenId, uint8 _level, uint32 _experience, uint[3] calldata _skills) external onlyMintAdmin {
    require(_level > 0, "400");
    heroes[_tokenId].level = _level;
    heroes[_tokenId].experience = _experience;
    heroes[_tokenId].skills = _skills;
    emit HeroInfoUpdated(_tokenId, _level, _experience, _skills);
  }

  function updateExclusive(address _address, bool _status) external onlyMainAdmin {
    exclusives[_address] = _status;
  }

  function setFOTAPricer(address _fotaPricer) external onlyMainAdmin {
    fotaPricer = IFOTAPricer(_fotaPricer);
  }

  function updateLockedFromMKPStatus(uint[] calldata _tokenIds, bool _status) external onlyMintAdmin {
    for(uint i = 0; i < _tokenIds.length; i++) {
      lockedFromMKP[_tokenIds[i]] = _status;
    }
    emit LockedFromMKPStatusUpdated(_tokenIds, _status);
  }

  // PRIVATE FUNCTIONS

  function _getMaxProfitable(uint _tokenId) private view returns (uint) {
    Hero storage hero = heroes[_tokenId];
    return hero.ownPrice * profitRate / 100;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

library StringUtil {
  struct slice {
    uint _length;
    uint _pointer;
  }

  function validateUserName(string calldata _username)
  internal
  pure
  returns (bool)
  {
    uint8 len = uint8(bytes(_username).length);
    if ((len < 4) || (len > 21)) return false;

    // only contain A-Z 0-9
    for (uint8 i = 0; i < len; i++) {
      if (
        (uint8(bytes(_username)[i]) < 48) ||
        (uint8(bytes(_username)[i]) > 57 && uint8(bytes(_username)[i]) < 65) ||
        (uint8(bytes(_username)[i]) > 90)
      ) return false;
    }
    // First char != '0'
    return uint8(bytes(_username)[0]) != 48;
  }

  function toBytes24(string memory source)
  internal
  pure
  returns (bytes24 result)
  {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
      return 0x0;
    }

    assembly {
      result := mload(add(source, 24))
    }
  }
}

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "./Auth.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

abstract contract NFTAuth is Auth, ContextUpgradeable {
  mapping(address => bool) public mintAdmins;
  mapping(address => bool) public transferable;
  mapping(address => bool) public gameContracts;
  address public upgradingContract;

  function initialize(address _mainAdmin) virtual override public {
    Auth.initialize(_mainAdmin);
  }

  modifier onlyMintAdmin() {
    require(_isMintAdmin() || _isMainAdmin(), "NFTAuth: Only mint admin");
    _;
  }

  modifier onlyTransferAdmin() {
    require(_isTransferAble() || _isMainAdmin(), "NFTAuth: Only transfer admin");
    _;
  }

  modifier onlyGameContract() {
    require(_isGameContracts() || _isMainAdmin(), "NFTAuth: Only game contract");
    _;
  }

  modifier onlyUpgradingContract() {
    require(_isUpgradingContract() || _isMainAdmin(), "NFTAuth: Only upgrading Contract");
    _;
  }

  function _isMintAdmin() internal view returns (bool) {
    return mintAdmins[_msgSender()];
  }

  function _isTransferAble() internal view returns (bool) {
    return transferable[_msgSender()];
  }

  function _isGameContracts() internal view returns (bool) {
    return gameContracts[_msgSender()];
  }

  function _isUpgradingContract() internal view returns (bool) {
    return _msgSender() == upgradingContract;
  }

  function updateMintAdmin(address _address, bool _mintAble) onlyMainAdmin external {
    require(_address != address(0), "NFTAuth: Address invalid");
    mintAdmins[_address] = _mintAble;
  }

  function updateTransferable(address _address, bool _transferable) onlyMainAdmin external {
    require(_address != address(0), "NFTAuth: Address invalid");
    transferable[_address] = _transferable;
  }

  function updateGameContract(address _contract, bool _status) onlyMainAdmin external {
    require(_contract != address(0), "NFTAuth: Address invalid");
    gameContracts[_contract] = _status;
  }

  function updateUpgradingContract(address _contract) onlyMainAdmin external {
    require(_contract != address(0), "NFTAuth: Address invalid");
    upgradingContract = _contract;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract Auth is Initializable {

  address public mainAdmin;
  address public contractAdmin;

  event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);
  event ContractAdminUpdated(address indexed _newOwner);

  function initialize(address _mainAdmin) virtual public initializer {
    mainAdmin = _mainAdmin;
    contractAdmin = _mainAdmin;
  }

  modifier onlyMainAdmin() {
    require(_isMainAdmin(), "onlyMainAdmin");
    _;
  }

  modifier onlyContractAdmin() {
    require(_isContractAdmin() || _isMainAdmin(), "onlyContractAdmin");
    _;
  }

  function transferOwnership(address _newOwner) onlyMainAdmin external {
    require(_newOwner != address(0x0));
    mainAdmin = _newOwner;
    emit OwnershipTransferred(msg.sender, _newOwner);
  }

  function updateContractAdmin(address _newAdmin) onlyMainAdmin external {
    require(_newAdmin != address(0x0));
    contractAdmin = _newAdmin;
    emit ContractAdminUpdated(_newAdmin);
  }

  function _isMainAdmin() public view returns (bool) {
    return msg.sender == mainAdmin;
  }

  function _isContractAdmin() public view returns (bool) {
    return msg.sender == contractAdmin;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

library ArrayUtil {
  function removeElementFromArray(uint[] storage _array, uint _element) internal returns (uint[] memory) {
    uint index = _getElementIndex(_array, _element);
    if (index >= 0 && index < _array.length) {
      _array[index] = _array[_array.length - 1];
      _array.pop();
    }
    return _array;
  }

  function _getElementIndex(uint[] memory _array, uint _element) private pure returns (uint) {
    for(uint i = 0; i < _array.length; i++) {
      if (_array[i] == _element) return i;
    }
    return type(uint).max;
  }
}

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "./IGameNFT.sol";

interface IMarketPlace {
  enum OrderType {
    trading,
    renting
  }
  enum OrderKind {
    hero,
    item,
    land
  }
  enum PaymentType {
    fota,
    usd,
    all
  }
  enum PaymentCurrency {
    fota,
    busd,
    usdt
  }
  function fotaToken() external view returns (address);
  function busdToken() external view returns (address);
  function usdtToken() external view returns (address);
  function citizen() external view returns (address);
  function takeOrder(OrderKind _kind, uint _tokenId, PaymentCurrency _paymentCurrency) external;
  function paymentType() external view returns (PaymentType);
  function currentRentedHeroCounter(address _user) external view returns (uint);
  function currentRentingHero(uint _heroId) external view returns (address);
  function currentRentingItem(uint _itemId) external view returns (address);
  function increaseCurrentRentedHeroCounter(uint _heroId) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import '@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol';

interface IGameNFT is IERC721Upgradeable {
  function mintHero(address _owner, uint16 _classId, uint _price, uint _index) external returns (uint);
  function mintHeroes(address _owner, uint16 _classId, uint _price, uint _quantity) external;
  function heroes(uint _tokenId) external returns (uint16, uint, uint8, uint32, uint, uint, uint);
  function getHero(uint _tokenId) external view returns (string memory, string memory, string memory, uint16, uint, uint8, uint32);
  function getHeroStrength(uint _tokenId) external view returns (uint, uint, uint, uint, uint);
  function getOwnerHeroes(address _owner) external view returns(uint[] memory);
  function getOwnerTotalHeroThatNotReachMaxProfit(address _owner) external view returns(uint);
  function increaseTotalProfitedMulti(uint[] memory _tokenIds, uint[] memory _amounts) external;
  function increaseTotalProfited(uint _tokenId, uint _amount) external returns (uint);
  function lockedFromMKP(uint _tokenId) external view returns (bool);
  function reachMaxProfit(uint _tokenId) external view returns (bool);
  function mintItem(address _owner, uint8 _gene, uint16 _class, uint _price, uint _index) external returns (uint);
  function getItem(uint _tokenId) external view returns (uint8, uint16, uint, uint, uint);
  function getClassId(uint _tokenId) external view returns (uint16);
  function burn(uint _tokenId) external;
  function getCreator(uint _tokenId) external view returns (address);
  function countId() external view returns (uint16);
  function updateOwnPrice(uint _tokenId, uint _ownPrice) external;
  function updateAllOwnPrices(uint _tokenId, uint _ownPrice, uint _fotaOwnPrice) external;
  function updateFailedUpgradingAmount(uint _tokenId, uint _amount) external;
  function skillUp(uint _tokenId, uint8 _index) external;
  function experienceUp(uint[] memory _tokenIds, uint32[] memory _experiences) external;
  function experienceCheckpoint(uint8 _level) external view returns (uint32);
  function fotaOwnPrices(uint _tokenId) external view returns (uint);
  function fotaFailedUpgradingAmount(uint _tokenId) external view returns (uint);
  function updateLockedFromMKPStatus(uint[] calldata _tokenIds, bool _status) external;
}

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

interface IFOTAPricer {
  function fotaPrice() external view returns (uint);
}

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

interface IEnergyManager {
  function updateEnergy(uint[] memory _heroIds, uint[] memory _energies) external returns (uint totalIdValue);
  function updatePoint(address _user, int _point) external;
  function getUserCurrentEnergy(address _user) external view returns (uint);
  function energies(address _user) external view returns (uint, uint, uint, int, uint);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "../libs/fota/ArrayUtil.sol";
import "../libs/fota/NFTAuth.sol";

abstract contract BaseNFT is NFTAuth, ERC721Upgradeable {

  mapping (uint16 => address) public creators;
  mapping (address => uint) public nonces;

  uint private constant idDivider = 100000000;
  bool burning;

  event OwnPriceUpdated(
    uint tokenId,
    uint ownPrice
  );
  event AllOwnPriceUpdated(
    uint tokenId,
    uint ownPrice,
    uint fotaOwnPrice
  );
  event MinPriceUpdated(
    uint tokenId,
    uint minPrice
  );

  function initialize(
    address _mainAdmin,
    string calldata _name,
    string calldata _symbol
  ) virtual public {
    NFTAuth.initialize(_mainAdmin);
    ERC721Upgradeable.__ERC721_init(_name, _symbol);
  }

  function setCreator(uint16 _class, address _creator) onlyMainAdmin external {
    creators[_class] = _creator;
  }

  function burn(uint256 tokenId) public virtual {
    require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
    burning = true;
    _burn(tokenId);
    burning = false;
  }

  function _beforeTokenTransfer(
    address _from,
    address _to,
    uint _tokenId
  ) virtual internal override {
    if (!burning) {
      require(_isMintAdmin() || _isTransferAble(), "NFT: no transferable right");
    }
    _from;
    _to;
    _tokenId;
  }

  function _genNewId(uint _index) internal view returns (uint) {
    uint tokenId = block.timestamp % idDivider + _index;
    while(_exists(tokenId)) {
      tokenId = block.timestamp % idDivider * 10 + ++_index;
    }
    return tokenId;
  }

  function updateOwnPrice(uint _tokenId, uint _ownPrice) virtual external;
  function getCreator(uint _tokenId) virtual external returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

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
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/ERC721.sol)

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
     * by default, can be overriden in child contracts.
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
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
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
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}