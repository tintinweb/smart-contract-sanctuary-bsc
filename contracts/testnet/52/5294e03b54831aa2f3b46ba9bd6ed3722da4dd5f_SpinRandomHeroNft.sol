// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "./libs/fota/Auth.sol";
import "./libs/fota/Math.sol";
import "./libs/zeppelin/token/BEP20/IBEP20.sol";
import "./interfaces/IGameNFT.sol";
import "./interfaces/ILPToken.sol";
import "./interfaces/IFOTAPricer.sol";
import "./interfaces/IFOTAToken.sol";
import "./interfaces/IMarketPlace.sol";

contract SpinRandomHeroNft is Auth, PausableUpgradeable {

  struct Collection {
    string name;
    uint numberHeroReceive;
    uint price; // USDF
    bool canUpdate;
    bool enable;
    uint[] rates;
    uint16[] heroClassIds;
    uint[] heroPrices;
  }

  mapping (uint => Collection) public collections;

  uint public collectionIndex;
  uint constant ONE_HUNDRED_PERCENTAGE_DECIMAL3 = 100000;
  uint constant MAX_TURN = 5;

  string private seed;
  address public fundAdmin;

  IGameNFT public heroNFT;
  ILPToken public lpToken;
  IFOTAPricer public fotaPricer;
  IFOTAToken public fotaToken;
  IBEP20 public busdToken;
  IBEP20 public usdtToken;
  IMarketPlace.PaymentType public paymentType;
  mapping (address => bool) public lockedUser;


  event CollectionCreated(uint collectionId, string name, uint16[] classIds, uint[] rates, uint[] heroPrices, uint numberHeroReceive, uint price, uint timestamp);
  event CollectionUpdated(uint collectionId, string name, uint16[] classIds, uint[] rates, uint[] heroPrices, uint numberHeroReceive, uint price, uint timestamp);
  event CollectionEnabled(uint collectionId, bool enabled, uint timestamp);
  event SpinBonus(address user, uint collectionId, uint16[] heroClassIds, uint spinPrice, uint timestamp);
  event PaymentTypeChanged(IMarketPlace.PaymentType _newMethod);
  event RandomResult(uint result);
  event UserLocked(address user, bool locked);

  modifier canUpdate(uint _collectionId) {
    require(collections[_collectionId].canUpdate, "SpinRandomHeroNft: can't update data");
    _;
  }

  function initialize(
    address _fundAdmin,
    address _heroNFT,
    address _lpToken,
    address _fotaPricer,
    string memory _seed
  ) public initializer {
    Auth.initialize(msg.sender);
    heroNFT = IGameNFT(_heroNFT);
    lpToken = ILPToken(_lpToken);
    fundAdmin = _fundAdmin;
    fotaPricer = IFOTAPricer(_fotaPricer);

    fotaToken = IFOTAToken(0x0A4E1BdFA75292A98C15870AeF24bd94BFFe0Bd4);
    busdToken = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    usdtToken = IBEP20(0x55d398326f99059fF775485246999027B3197955);

    seed = _seed;
    paymentType = IMarketPlace.PaymentType.all;
  }

  // ADMIN FUNCTION

  function createCollection(string calldata _name, uint16[] calldata _classIds, uint[] calldata _rates, uint[] calldata _heroPrices, uint _numberHeroReceive, uint _price) external onlyMainAdmin {
    require(uint8(bytes(_name).length) > 0 && _classIds.length == _rates.length && _rates.length == _heroPrices.length, "SpinRandomHeroNft: data invalid");
    collectionIndex++;
    Collection storage collection = collections[collectionIndex];
    collection.name = _name;
    collection.numberHeroReceive = _numberHeroReceive;
    collection.price = _price;
    collection.canUpdate = true;
    collection.enable = true;

    _updateCollectionHeroInfo(collectionIndex, _classIds, _rates, _heroPrices);
    _sortRatesHeroClassIdsAndHeroPrices(collectionIndex);

    emit CollectionCreated(collectionIndex, _name, _classIds, _rates, _heroPrices, _numberHeroReceive, _price, block.timestamp);
  }

  function updateCollection(uint _collectionId, string calldata _name, uint16[] calldata _classIds, uint[] calldata _rates, uint[] calldata _heroPrices, uint _numberHeroReceive, uint _price) external onlyMainAdmin canUpdate(_collectionId) {
    require(_collectionId <= collectionIndex && uint8(bytes(_name).length) > 0 && _classIds.length == _rates.length && _rates.length == _heroPrices.length, "SpinRandomHeroNft: data invalid");
    Collection storage collection = collections[_collectionId];
    collection.name = _name;
    collection.numberHeroReceive = _numberHeroReceive;
    collection.price = _price;

    _updateCollectionHeroInfo(_collectionId, _classIds, _rates, _heroPrices);
    _sortRatesHeroClassIdsAndHeroPrices(_collectionId);

    emit CollectionUpdated(_collectionId, _name, _classIds, _rates, _heroPrices, _numberHeroReceive, _price, block.timestamp);
  }

  function enableCollection(uint _collectionId, bool _enabled) onlyMainAdmin external {
    collections[_collectionId].enable = _enabled;
    emit CollectionEnabled(_collectionId, _enabled, block.timestamp);
  }

  function updateFundAdmin(address _address) onlyMainAdmin external {
    require(_address != address(0), "SpinRandomHeroNft: invalid address");
    fundAdmin = _address;
  }

  // TODO remove on mainnet deployment
  function setPaymentCurrencyToken(address _busd, address _usdt, address _fota) external onlyMainAdmin {
    require(_busd != address(0) && _usdt != address(0) && _fota != address(0), "SpinRandomHeroNft: invalid address");

    busdToken = IBEP20(_busd);
    usdtToken = IBEP20(_usdt);
    fotaToken = IFOTAToken(_fota);
  }

  function updatePaymentType(IMarketPlace.PaymentType _type) external onlyMainAdmin {
    paymentType = _type;
    emit PaymentTypeChanged(_type);
  }

  function updateFotaPricerAndLpToken(address _fotaPricer, address _lpToken) external onlyMainAdmin {
    require(_fotaPricer != address(0) && _lpToken != address(0), "SpinRandomHeroNft: invalid address");
    fotaPricer = IFOTAPricer(_fotaPricer);
    lpToken = ILPToken(_lpToken);
  }

  function updatePauseStatus(bool _paused) external onlyMainAdmin {
    if(_paused) {
      _pause();
    } else {
      _unpause();
    }
  }

  function updateLockUserStatus(address _user, bool _locked) external onlyMainAdmin {
    lockedUser[_user] = _locked;
    emit UserLocked(_user, _locked);
  }

  // USER FUNCTION
  function spin(uint _collectionId, IMarketPlace.PaymentCurrency _paymentCurrency) external whenNotPaused {
    require(!lockedUser[msg.sender], "user locked");
    require(collections[_collectionId].enable, "SpinRandomHeroNft: collection locked");
    require(collections[_collectionId].heroClassIds.length > 0, "SpinRandomHeroNft: collection not found");

    (uint amount) = _takeFund(collections[_collectionId].price, _paymentCurrency);
    uint[] memory pickedIndexes = _giveReward(_collectionId);
    uint16[] memory classIds = _mintHeroNft(_collectionId, pickedIndexes);

    collections[_collectionId].canUpdate = false;
    emit SpinBonus(msg.sender, _collectionId, classIds, amount, block.timestamp);
  }

  function getCollectionDetail(uint _collectionId) public view returns(string memory name, uint16[] memory classIds, uint[] memory rates, uint[] memory heroPrices, uint numberHeroReceive, uint price) {
    require(collections[_collectionId].enable, "SpinRandomHeroNft: collection locked");
    Collection storage collection = collections[_collectionId];
    return (collection.name, collection.heroClassIds, collection.rates, collection.heroPrices, collection.numberHeroReceive, collection.price);
  }

  // PRIVATE FUNCTION

  function _takeFund(uint _price, IMarketPlace.PaymentCurrency _paymentCurrency) private returns (uint) {
    if (paymentType == IMarketPlace.PaymentType.fota) {
      require(_paymentCurrency == IMarketPlace.PaymentCurrency.fota, "SpinRandomHeroNft: invalid currency");
    } else if (paymentType == IMarketPlace.PaymentType.usd) {
      require(_paymentCurrency != IMarketPlace.PaymentCurrency.fota, "SpinRandomHeroNft: invalid currency");
    }

    uint amount = _price;

    if (paymentType == IMarketPlace.PaymentType.fota) {
      amount = amount * 1000 / fotaPricer.fotaPrice();
      _takeFundFOTA(amount);
    } else if (paymentType == IMarketPlace.PaymentType.usd) {
      _takeFundUSD(amount, _paymentCurrency);
    } else if (_paymentCurrency == IMarketPlace.PaymentCurrency.fota) {
      amount = amount * 1000 / fotaPricer.fotaPrice();
      _takeFundFOTA(amount);
    } else {
      _takeFundUSD(amount, _paymentCurrency);
    }

    return amount;
  }

  function _takeFundUSD(uint _amount, IMarketPlace.PaymentCurrency _paymentCurrency) private {
    IBEP20 usdToken = _paymentCurrency == IMarketPlace.PaymentCurrency.busd ? busdToken : usdtToken;
    require(usdToken.allowance(msg.sender, address(this)) >= _amount, "SpinRandomHeroNft: please approve token first");
    require(usdToken.balanceOf(msg.sender) >= _amount, "SpinRandomHeroNft: please fund your account");
    require(usdToken.transferFrom(msg.sender, fundAdmin, _amount), "SpinRandomHeroNft: transfer token failed");
  }

  function _takeFundFOTA(uint _amount) private {
    require(fotaToken.allowance(msg.sender, address(this)) >= _amount, "SpinRandomHeroNft: please approve token first");
    require(fotaToken.balanceOf(msg.sender) >= _amount, "SpinRandomHeroNft: please fund your account");
    require(fotaToken.transferFrom(msg.sender, fundAdmin, _amount), "SpinRandomHeroNft: transfer token failed");
  }

  function _mintHeroNft(uint _collectionId, uint[] memory _pickedIndexes) private returns (uint16[] memory classIds) {
    classIds = new uint16[](_pickedIndexes.length);
    for (uint i = 0; i < _pickedIndexes.length; i += 1) {
      classIds[i] = collections[_collectionId].heroClassIds[_pickedIndexes[i]];
      heroNFT.mintHero(msg.sender, classIds[i], collections[_collectionId].heroPrices[i], i);
    }
  }

  function _updateCollectionHeroInfo(uint _collectionId, uint16[] calldata _classIds, uint[] calldata _rates, uint[] calldata _heroPrices) private {
    require(_classIds.length == _rates.length, "SpinRandomHeroNft: invalid classIds or rate");

    Collection storage collection = collections[_collectionId];
    require(_rates.length >= collection.numberHeroReceive, "SpinRandomHeroNft: invalid number hero receive");

    uint totalRatePercentage;

    for (uint i = 0; i < _classIds.length; i += 1) {
      require(_classIds[i] <= heroNFT.countId(), "SpinRandomHeroNft: class id not found");
      require(_rates[i] > 0 && _rates[i] <= ONE_HUNDRED_PERCENTAGE_DECIMAL3, "SpinRandomHeroNft: rate must be great than 0 and less than or equal 100000");
      require(_heroPrices[i] > 0, "SpinRandomHeroNft: price must be greater than 0");
      if (i + 1 < _classIds.length) {
        require(_classIds[i] < _classIds[i + 1], "SpinRandomHeroNft: invalid class id");
      }

      totalRatePercentage += _rates[i];
    }

    require(totalRatePercentage == collection.numberHeroReceive * ONE_HUNDRED_PERCENTAGE_DECIMAL3, "SpinRandomHeroNft: invalid total rate");

    collection.rates = _rates;
    collection.heroClassIds = _classIds;
    collection.heroPrices = _heroPrices;
  }

  function _sortRatesHeroClassIdsAndHeroPrices(uint _collectionId) private {
    Collection storage collection = collections[_collectionId];

    for (uint i = 0; i < collection.rates.length - 1; i++) {
      for (uint j = collection.rates.length - 1; j > i ; j--) {
        if (collection.rates[j] > collection.rates[j - 1]) {
          (collection.rates[j], collection.rates[j - 1]) = (collection.rates[j - 1], collection.rates[j]);
          (collection.heroClassIds[j], collection.heroClassIds[j - 1]) = (collection.heroClassIds[j - 1], collection.heroClassIds[j]);
          (collection.heroPrices[j], collection.heroPrices[j - 1]) = (collection.heroPrices[j - 1], collection.heroPrices[j]);
        }
      }
    }
  }

  function _giveReward(uint _collectionId) private returns (uint[] memory pickedIndexes) {
    Collection storage collection = collections[_collectionId];
    pickedIndexes = new uint[](collection.numberHeroReceive);
    uint totalHeroAssigned;
    uint totalPicks = collection.rates.length * MAX_TURN;
    uint index = 0;

    for (uint i = 0; i < totalPicks; i++) {
      index = i % collection.rates.length;
      if (!_isInArray(index, pickedIndexes, totalHeroAssigned)) {
        if (_genRandomRate(collection.rates[index] + i) <= collection.rates[index]) {
          pickedIndexes[totalHeroAssigned] = index;
          totalHeroAssigned++;
          if (totalHeroAssigned == collection.numberHeroReceive) {
            break;
          }
        }
      }
    }

    if (totalHeroAssigned < collection.numberHeroReceive) {
      for (uint i = totalHeroAssigned; i < collection.numberHeroReceive; i++) {
        if (totalHeroAssigned == collection.numberHeroReceive) {
          break;
        }
        for (uint j = 0; j < collection.rates.length; j++) {
          if (!_isInArray(j, pickedIndexes, totalHeroAssigned)) {
            pickedIndexes[totalHeroAssigned] = j;
            totalHeroAssigned++;
            if (totalHeroAssigned == collection.numberHeroReceive) {
              break;
            }
          }
        }
      }
    }
  }

  function _isInArray(uint _value, uint[] memory _array, uint _totalHeroAssigned) private pure returns (bool) {
    for(uint i = 0; i < _array.length; i++) {
      if (i == _totalHeroAssigned) {
        return false;
      } else if (_array[i] == _value) {
        return true;
      }
    }
    return false;
  }

  function _genRandomRate(uint rate) private returns (uint) {
    (uint reserve0, uint reserve1) = lpToken.getReserves();

    uint result = Math.genRandomNumberInRangeUint(seed, (reserve0 + reserve1 + rate) * ONE_HUNDRED_PERCENTAGE_DECIMAL3, 1, ONE_HUNDRED_PERCENTAGE_DECIMAL3);
    emit RandomResult(result);
    return result;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IBEP20 {

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

library Math {

  function add(uint a, uint b) internal pure returns (uint) {
    unchecked {
      uint256 c = a + b;
      require(c >= a, "SafeMath: addition overflow");

      return c;
    }
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    unchecked {
      require(b <= a, "Math: sub underflow");
      uint256 c = a - b;

      return c;
    }
  }

  function mul(uint a, uint b) internal pure returns (uint) {
    unchecked {
      if (a == 0) {
        return 0;
      }

      uint256 c = a * b;
      require(c / a == b, "SafeMath: multiplication overflow");

      return c;
    }
  }

  function div(uint a, uint b) internal pure returns (uint) {
    unchecked {
      require(b > 0, "SafeMath: division by zero");
      uint256 c = a / b;

      return c;
    }
  }

  function genRandomNumber(string memory _seed, uint _dexRandomSeed) internal view returns (uint8) {
    return genRandomNumberInRange(_seed, _dexRandomSeed, 0, 99);
  }

  function genRandomNumberInRange(string memory _seed, uint _dexRandomSeed, uint _from, uint _to) internal view returns (uint8) {
    require(_to > _from, 'Math: Invalid range');
    uint randomNumber = uint(
      keccak256(
        abi.encodePacked(
          keccak256(
            abi.encodePacked(
              block.number,
              block.difficulty,
              block.timestamp,
              msg.sender,
              _seed,
              _dexRandomSeed
            )
          )
        )
      )
    ) % (_to - _from + 1);
    return uint8(randomNumber + _from);
  }

  function genRandomNumberInRangeUint(string memory _seed, uint _dexRandomSeed, uint _from, uint _to) internal view returns (uint) {
    require(_to > _from, 'Math: Invalid range');
    uint randomNumber = uint(
      keccak256(
        abi.encodePacked(
          block.number,
          block.difficulty,
          block.timestamp,
          msg.sender,
          _seed,
          _dexRandomSeed
        )
      )
    ) % (_to - _from + 1);
    return randomNumber + _from;
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

import "../libs/zeppelin/token/BEP20/IBEP20.sol";

interface ILPToken is IBEP20 {
  function getReserves() external view returns (uint, uint);
  function totalSupply() external view returns (uint);
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
  function increaseTotalProfited(uint _tokenId, uint _amount) external returns (uint);
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
  function experienceUp(uint _tokenId, uint32 _experience) external;
  function experienceCheckpoint(uint8 _level) external view returns (uint32);
  function fotaOwnPrices(uint _tokenId) external view returns (uint);
  function fotaFailedUpgradingAmount(uint _tokenId) external view returns (uint);
}

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "../libs/zeppelin/token/BEP20/IBEP20.sol";

interface IFOTAToken is IBEP20 {
  function releaseGameAllocation(address _gamerAddress, uint _amount) external returns (bool);
  function releasePrivateSaleAllocation(address _buyerAddress, uint _amount) external returns (bool);
  function releaseSeedSaleAllocation(address _buyerAddress, uint _amount) external returns (bool);
  function releaseStrategicSaleAllocation(address _buyerAddress, uint _amount) external returns (bool);
  function burn(uint _amount) external;
}

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

interface IFOTAPricer {
  function fotaPrice() external view returns (uint);
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
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}