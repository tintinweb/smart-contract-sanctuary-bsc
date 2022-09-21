// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import "../interfaces/IGameNFT.sol";
import "../interfaces/IItemUpgradingMap.sol";
import "../interfaces/IMarketPlace.sol";
import "../interfaces/IGameNFT.sol";
import "../interfaces/IMarketPlace.sol";
import "../interfaces/IFOTAPricer.sol";
import "../interfaces/ILPToken.sol";
import "../libs/fota/Auth.sol";
import "../libs/fota/Math.sol";
import "../libs/zeppelin/token/BEP20/IBEP20.sol";

contract ItemUpgrading is Auth, EIP712Upgradeable {
  using Math for uint;

  struct UpgradingInfo {
    uint16 itemClass;
    uint[] materials;
    uint eatherId;
    IMarketPlace.PaymentCurrency paymentCurrency;
    uint8 acceptedRatio;
  }

  IGameNFT public itemNft;
  IItemUpgradingMap itemMap;
  IBEP20 public busdToken;
  IBEP20 public usdtToken;
  IBEP20 public fotaToken;
  IFOTAPricer public fotaPricer;
  IMarketPlace.PaymentType public paymentType;
  ILPToken[] public lpTokens;
  address[] public pools;
  address public fundAdmin;
  uint constant decimal3 = 1000;
  mapping (address => uint) public nonces;

  event PaymentTypeChanged(IMarketPlace.PaymentType newMethod);
  event Upgraded(address indexed _user, uint8 _gene, UpgradingInfo upgradingInfo, uint _newTokenId, uint _fee, uint8 _acceptedRatio, bool success);

  function initialize(
    string memory _name,
    string memory _version,
    address _mainAdmin,
    address _fundAdmin,
    address _itemNft,
    address _itemMap,
    address _fotaPricer,
    address[] calldata _pools
  ) public initializer {
    Auth.initialize(_mainAdmin);
    EIP712Upgradeable.__EIP712_init(_name, _version);
    itemNft = IGameNFT(_itemNft);
    itemMap = IItemUpgradingMap(_itemMap);
    fotaPricer = IFOTAPricer(_fotaPricer);
    busdToken = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    usdtToken = IBEP20(0x55d398326f99059fF775485246999027B3197955);
    fotaToken = IBEP20(0x0A4E1BdFA75292A98C15870AeF24bd94BFFe0Bd4);
    lpTokens = new ILPToken[](3);
    lpTokens[0] = ILPToken(0x16b9a82891338f9bA80E2D6970FddA79D1eb0daE);
    lpTokens[1] = ILPToken(0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16);
    lpTokens[2] = ILPToken(0xd5F81B5B84ea7b5157A72d3Fe32154dF8efC8B01);
    pools = _pools;
    fundAdmin = _fundAdmin;
  }

  function upgradeItem(
    uint16 _itemClass,
    uint[] calldata _materials,
    uint _eatherId,
    IMarketPlace.PaymentCurrency _paymentCurrency,
    uint8 _acceptedRatio,
    string calldata _seed,
    bytes memory _signature
  ) external {
    _validateSeed(_seed, _signature);
    _validateRatio(_itemClass, _acceptedRatio);
    (uint ownPriceFeeWhenSuccess, uint fee, uint totalOwnPrice, uint eatherOwnPrice) = _validateMaterials(_itemClass, _materials, _eatherId, _paymentCurrency, _acceptedRatio);
    UpgradingInfo memory upgradingInfo = UpgradingInfo(_itemClass, _materials, _eatherId, _paymentCurrency, _acceptedRatio);
    bool success = _upgradeItem(upgradingInfo, _acceptedRatio, _seed, ownPriceFeeWhenSuccess, fee);

    _finishUpgrade(success, _materials, fee, totalOwnPrice, eatherOwnPrice);
  }

  function setContracts(address _itemNft, address _itemMap) external onlyMainAdmin {
    itemNft = IGameNFT(_itemNft);
    itemMap = IItemUpgradingMap(_itemMap);
  }

  function updateFundAdmin(address _address) onlyMainAdmin external {
    require(_address != address(0), "MarketPlace: invalid address");
    fundAdmin = _address;
  }

  function updatePaymentType(IMarketPlace.PaymentType _type) external onlyMainAdmin {
    paymentType = _type;
    emit PaymentTypeChanged(_type);
  }

  function updateLPToken(address _tokenAddress0, address _tokenAddress1, address _tokenAddress2) external onlyMainAdmin {
    require(_tokenAddress0 != address(0), "Invalid address");
    lpTokens[0] = ILPToken(_tokenAddress0);
    lpTokens[1] = ILPToken(_tokenAddress1);
    lpTokens[2] = ILPToken(_tokenAddress2);
  }

  function updatePoolAddress(address[] calldata _pools) external onlyMainAdmin {
    pools = _pools;
  }

  function drainToken(address _tokenAddress) external onlyMainAdmin {
    IBEP20 token = IBEP20(_tokenAddress);
    token.transfer(msg.sender, token.balanceOf(address(this)));
  }

  // PRIVATE FUNCTIONS

  function _validateSeed(
    string calldata _seed,
    bytes memory _signature
  ) private {
    bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
        keccak256("UpgradeItem(address user,string seed,uint256 nonce)"),
        msg.sender,
        keccak256(bytes(_seed)),
        nonces[msg.sender]
      )));
    nonces[msg.sender]++;
    address signer = ECDSAUpgradeable.recover(digest, _signature);
    require(signer == contractAdmin, "MessageVerifier: invalid signature");
    require(signer != address(0), "ECDSAUpgradeable: invalid signature");
  }

  function _validateMaterials(
    uint16 _itemClass,
    uint[] calldata _suppliedMaterialIds,
    uint _eatherId,
    IMarketPlace.PaymentCurrency _paymentCurrency,
    uint8 _acceptedRatio
  ) private returns (uint ownPriceFeeWhenSuccess, uint fee, uint totalOwnPrice, uint eatherOwnPrice) {
    ownPriceFeeWhenSuccess = 0;
    fee = 0;
    totalOwnPrice = 0;
    (uint16[] memory materials,,) = itemMap.getItem(_itemClass);
    require(materials.length == _suppliedMaterialIds.length, "Upgrading: invalid input");
    for(uint i = 0; i < _suppliedMaterialIds.length; i++) {
      uint tokenId = _suppliedMaterialIds[i];
      _requireItemRight(tokenId);
      (,uint16 suppliedMaterialClass,,uint suppliedItemOwnPrice,uint suppliedFailedUpgradingAmount) = itemNft.getItem(tokenId);
      ownPriceFeeWhenSuccess += suppliedItemOwnPrice;
      ownPriceFeeWhenSuccess += suppliedFailedUpgradingAmount;
      totalOwnPrice += suppliedItemOwnPrice;
      require(suppliedMaterialClass == materials[i], "Upgrading: invalid class");
    }
    eatherOwnPrice = _validateEather(_eatherId);
    fee = _takeFund(_paymentCurrency, _itemClass, _acceptedRatio);
    ownPriceFeeWhenSuccess += eatherOwnPrice;
    ownPriceFeeWhenSuccess += fee;
  }

  function _validateEather(uint _eatherId) private view returns (uint) {
    _requireItemRight(_eatherId);
    (uint16 eatherGene,,,uint eatherOwnPrice,) = itemNft.getItem(_eatherId);
    require(eatherGene == 0, "Upgrading: invalid eather item");
    return eatherOwnPrice;
  }

  function _requireItemRight(uint _tokenId) private view {
    require(itemNft.ownerOf(_tokenId) == msg.sender, "Upgrading: not owner of item");
    bool approved = itemNft.isApprovedForAll(msg.sender, address(this)) || itemNft.getApproved(_tokenId) == address(this);
    require(approved, "Upgrading: please approve token first");
  }

  function _takeFund(IMarketPlace.PaymentCurrency _paymentCurrency, uint16 _itemClass, uint8 _acceptedRatio) private returns (uint _upgradingFee){
    (,uint fee,uint8 successRatio) = itemMap.getItem(_itemClass);
    _upgradingFee = fee * uint(_acceptedRatio) / uint(successRatio);
    if (paymentType == IMarketPlace.PaymentType.fota) {
      _takeFundFOTA(_upgradingFee * decimal3 / fotaPricer.fotaPrice());
    } else if (paymentType == IMarketPlace.PaymentType.usd) {
      _takeFundUSD(_paymentCurrency, _upgradingFee);
    } else if (_paymentCurrency == IMarketPlace.PaymentCurrency.fota) {
      _takeFundFOTA(_upgradingFee * decimal3 / fotaPricer.fotaPrice());
    } else {
      _takeFundUSD(_paymentCurrency, _upgradingFee);
    }
  }

  function _takeFundUSD(IMarketPlace.PaymentCurrency _paymentCurrency, uint _upgradingFee) private {
    require(_paymentCurrency != IMarketPlace.PaymentCurrency.fota, "payment currency invalid");
    IBEP20 usdToken = _paymentCurrency == IMarketPlace.PaymentCurrency.busd ? busdToken : usdtToken;
    require(usdToken.allowance(msg.sender, address(this)) >= _upgradingFee, "Upgrading: please approve usd token first");
    require(usdToken.balanceOf(msg.sender) >= _upgradingFee, "Upgrading: insufficient balance");
    require(usdToken.transferFrom(msg.sender, address(this), _upgradingFee), "Upgrading: transfer usd token failed");
    require(usdToken.transfer(fundAdmin, _upgradingFee), "Upgrading: transfer usd token failed");
  }

  function _takeFundFOTA(uint _upgradingFee) private {
    require(fotaToken.allowance(msg.sender, address(this)) >= _upgradingFee, "please approve fota first");
    require(fotaToken.balanceOf(msg.sender) >= _upgradingFee, "please fund your account");
    require(fotaToken.transferFrom(msg.sender, address(this), _upgradingFee), "transfer fota failed");
    uint dividend = _upgradingFee / pools.length;
    for(uint i = 0; i < pools.length; i++) {
      fotaToken.transfer(pools[i], dividend);
    }
  }

  function _upgradeItem(
    UpgradingInfo memory _upgradingInfo,
    uint8 _acceptedRatio,
    string calldata _seed,
    uint _ownPrice,
    uint _fee
  ) private returns (bool success) {
    success = _isSuccess(_seed, _acceptedRatio);
    uint8 gene = uint8(_upgradingInfo.itemClass / 100);
    if (success) {
      uint newTokenId = itemNft.mintItem(msg.sender, gene, _upgradingInfo.itemClass, _ownPrice, 0);
      emit Upgraded(msg.sender, gene, _upgradingInfo, newTokenId, _fee, _acceptedRatio, success);
    } else {
      emit Upgraded(msg.sender, gene, _upgradingInfo, 0, _fee, _acceptedRatio, success);
    }
    itemNft.burn(_upgradingInfo.eatherId);
  }

  function _isSuccess(string calldata _seed, uint8 _acceptedRatio) private view returns (bool) {
    uint dexSeed = _getDexSeed();
    uint8 randomNumber = Math.genRandomNumber(_seed, dexSeed);
    return randomNumber < _acceptedRatio;
  }

  function _getDexSeed() private view returns (uint) {
    (uint reserve00,) = lpTokens[0].getReserves();
    (uint reserve01,) = lpTokens[1].getReserves();
    (uint reserve02,) = lpTokens[2].getReserves();
    return reserve00.add(reserve01).add(reserve02);
  }

  function _validateRatio(uint16 _itemClass, uint8 _acceptedRatio) private view {
    (,,uint8 successRatio) = itemMap.getItem(_itemClass);
    require(_acceptedRatio <= successRatio, "Upgrading: invalid ratio");
  }

  function _finishUpgrade(
    bool _success,
    uint[] memory _materials,
    uint _fee,
    uint _totalMaterialOwnPrice,
    uint _eatherOwnPrice
  ) private {
    if (_success) {
      for(uint i = 0; i < _materials.length; i++) {
        itemNft.burn(_materials[i]);
      }
    } else {
      uint _totalFee = _fee + _eatherOwnPrice;
      for(uint i = 0; i < _materials.length; i++) {
        (,,,uint suppliedItemOwnPrice, uint failedUpgradingAmount) = itemNft.getItem(_materials[i]);
        uint itemFee = _totalFee.mul(suppliedItemOwnPrice).div(_totalMaterialOwnPrice);
        itemNft.updateFailedUpgradingAmount(_materials[i], failedUpgradingAmount.add(itemFee));
      }
    }
  }

  // TODO for testing purpose
  function setToken(address _fotaToken, address _busdToken, address _usdtToken, address _lpToken) external onlyMainAdmin {
    fotaToken = IBEP20(_fotaToken);
    busdToken = IBEP20(_busdToken);
    usdtToken = IBEP20(_usdtToken);
    lpTokens[0] = ILPToken(_lpToken);
    lpTokens[1] = ILPToken(_lpToken);
    lpTokens[2] = ILPToken(_lpToken);
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

  function genRandomNumber(string calldata _seed, uint _dexRandomSeed) internal view returns (uint8) {
    return genRandomNumberInRange(_seed, _dexRandomSeed, 0, 99);
  }

  function genRandomNumberInRange(string calldata _seed, uint _dexRandomSeed, uint _from, uint _to) internal view returns (uint8) {
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

interface IItemUpgradingMap {
  function getItem(uint16 _itemClass) external view returns (uint16[] memory, uint, uint8);
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

interface IFOTAPricer {
  function fotaPrice() external view returns (uint);
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
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSAUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712Upgradeable is Initializable {
    /* solhint-disable var-name-mixedcase */
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private constant _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    function __EIP712_init(string memory name, string memory version) internal onlyInitializing {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal onlyInitializing {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSAUpgradeable.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev The hash of the name parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712NameHash() internal virtual view returns (bytes32) {
        return _HASHED_NAME;
    }

    /**
     * @dev The hash of the version parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712VersionHash() internal virtual view returns (bytes32) {
        return _HASHED_VERSION;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../StringsUpgradeable.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSAUpgradeable {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", StringsUpgradeable.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

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
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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