// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "./libs/fota/Auth.sol";
import "./interfaces/IRewardManager.sol";
import "./interfaces/IGameNFT.sol";
import "./libs/zeppelin/token/BEP20/IBEP20.sol";
import "./interfaces/IFOTAPricer.sol";

contract MarketPlaceV2Auth is Auth {
  address public gamePVE;

  function initialize(address _mainAdmin, address _gamePVE) internal {
    super.initialize(_mainAdmin);
    gamePVE = _gamePVE;
  }

  function updatePVE(address _gamePVE) external onlyMainAdmin {
    gamePVE = _gamePVE;
  }

  modifier onlyPVE() {
    require(msg.sender == gamePVE || _isMainAdmin(), "Only PVE");
    _;
  }
}

contract MarketPlaceV2 is MarketPlaceV2Auth, EIP712Upgradeable, PausableUpgradeable {
  struct Order {
    address maker;
    address taker;
    uint[] tokenIds;
    uint takerShare; // decimal 3
    uint startAt;
    uint duration;
    uint orderTrustFee;
    PaymentCurrency paymentCurrency;
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
  IRewardManager public rewardManager;
  IGameNFT public heroNft;
  mapping (uint => Order) public orders;
  mapping (address => bool) public lockedUser;
  uint public signatureTimeOut;
  mapping (address => uint) public nonces;
  mapping (uint => address) public authorizations;
  uint constant heroPrice = 50 ether;
  uint constant oneHundredPercentageDecimal3 = 100000;
  uint private orderCounter;
  uint public orderTrustFee;
  IBEP20 public fotaToken;
  IGameNFT public itemNft;
  mapping (uint => bool) public heroInOrder;
  uint public summonTime;
  mapping (uint => uint) public expiredSummons;
  PaymentType public paymentType;
  IFOTAPricer public fotaPricer;
  IBEP20 public busdToken;
  IBEP20 public usdtToken;
  bool public allowMaxProfitTrading;

  event HeroSummoned(address indexed owner, address usingRight, uint tokenId, uint timestamp, uint summonExpired, uint gemAmount, uint eatherNumber);
  event HeroesRevoked(uint[] tokenIds, uint timestamp);
  event OrderCreated(uint indexed id, address maker, uint[] tokenIds, uint takerShare, uint rentingTime, uint orderTrustFee, uint timestamp);
  event OrderCanceled(uint indexed id);
  event OrderTaken(uint indexed id, address indexed taker, uint[] tokenIds, uint amount, PaymentType paymentType, PaymentCurrency paymentCurrency);
  event OrderRevoked(uint[] ids, uint timestamp);
  event OrderRevokedByOwner(uint id, uint timestamp);
  event PrestigeHeroSummoned(address indexed owner, uint tokenId, uint timestamp, uint summonExpired, uint gemAmount, uint prestigeShardNumber, uint eatherNumber);
  event SignatureTimeOutUpdated(uint timeOut);
  event UserLocked(address user, bool locked);
  event OrderTrustFeeUpdated(uint orderTrustFee, uint timestamp);
  event SummonTimeUpdated(uint second);
  event PaymentTypeChanged(PaymentType newMethod);

  function initialize(string memory _name, string memory _version, address _mainAdmin, address _rewardManager, address _heroNft, address _itemNft, address _gamePVE) public initializer {
    super.initialize(_mainAdmin, _gamePVE);
    EIP712Upgradeable.__EIP712_init(_name, _version);
    rewardManager = IRewardManager(_rewardManager);
    heroNft = IGameNFT(_heroNft);
    itemNft = IGameNFT(_itemNft);
    fotaToken = IBEP20(0x0A4E1BdFA75292A98C15870AeF24bd94BFFe0Bd4);
    signatureTimeOut = 300;
    summonTime = 86400;
  }

  function makeOrder(uint[] calldata _tokenIds, uint _takerShare, uint _duration) external whenNotPaused {
    require(_takerShare <= oneHundredPercentageDecimal3, "MarketPlaceV2: taker share invalid");
    _validateUser();
    _validateHeroRight(_tokenIds);
    Order memory order = Order(
      msg.sender,
      address(0),
      _tokenIds,
      _takerShare,
      0,
      _duration,
      orderTrustFee * _tokenIds.length,
      PaymentCurrency.fota
    );
    orders[++orderCounter] = order;
    heroNft.updateLockedFromMKPStatus(order.tokenIds, true);
    emit OrderCreated(orderCounter, msg.sender, _tokenIds, _takerShare, _duration, orderTrustFee * _tokenIds.length, block.timestamp);
  }

  function cancelOrder(uint _orderId) external whenNotPaused {
    Order storage order = orders[_orderId];
    require(order.maker == msg.sender && order.taker == address(0), "EatherTrading: order invalid");
    heroNft.updateLockedFromMKPStatus(order.tokenIds, false);
    for(uint i = 0; i < order.tokenIds.length; i++) {
      delete heroInOrder[order.tokenIds[i]];
    }
    delete orders[_orderId];
    emit OrderCanceled(_orderId);
  }

  function takeOrder(uint _orderId, PaymentCurrency _paymentCurrency) external whenNotPaused {
    _validateUser();
    Order storage order = orders[_orderId];
    _takeFund(order, _paymentCurrency);
    require(order.maker != msg.sender, "MarketplaceV2: self trading");
    require(order.maker != address(0) && order.taker == address(0), "MarketplaceV2: order invalid");
    order.taker = msg.sender;
    order.startAt = block.timestamp;
    order.paymentCurrency = _paymentCurrency;
    for (uint i = 0; i < order.tokenIds.length; i++) {
      authorizations[order.tokenIds[i]] = msg.sender;
    }
    emit OrderTaken(_orderId, msg.sender, order.tokenIds, order.orderTrustFee, paymentType, _paymentCurrency);
  }

  function summonShardHero(uint16 _classId, bytes memory _signature, uint _timestamp) external whenNotPaused {
    (uint gemAmount) = rewardManager.summonHero(msg.sender, heroPrice);
    _validateSignature(_classId, _timestamp, _signature);
    uint tokenId = heroNft.mintHero(address(this), _classId, heroPrice, 0);
    authorizations[tokenId] = msg.sender;
    uint expiredTime = _setTimeExpiredForSummonHero(tokenId);
    emit HeroSummoned(address(this), msg.sender, tokenId, block.timestamp, expiredTime, gemAmount, 0);
  }

  function summonHero(uint16 _classId, uint _eatherId, bytes memory _signature, uint _timestamp) external whenNotPaused {
    (uint gemAmount) = rewardManager.summonHero(msg.sender, heroPrice);
    _validateSignature(_classId, _timestamp, _signature);
    _validateEatherRightAndBurn(_eatherId);
    uint tokenId = heroNft.mintHero(msg.sender, _classId, heroPrice, 0);
    emit HeroSummoned(msg.sender, msg.sender, tokenId, block.timestamp, 0, gemAmount, 1);
  }

  function summonPrestigeHero(uint16 _classId, uint _eatherId, bytes memory _signature, uint _timestamp) external whenNotPaused {
    (uint gemAmount) = rewardManager.summonPrestigeHero(msg.sender, heroPrice);
    _validateSignature(_classId, _timestamp, _signature);
    _validateEatherRightAndBurn(_eatherId);
    uint tokenId = heroNft.mintHero(msg.sender, _classId, heroPrice, 0);
    emit PrestigeHeroSummoned(msg.sender, tokenId, block.timestamp, 0, gemAmount, 1, 1);
  }

  function ownerRevokeOrder(uint _orderId, bytes memory _signature, uint _timestamp) external {
    Order storage order = orders[_orderId];
    _validateRevokeHeroesSignature(_orderId, _timestamp, _signature);
    for (uint i = 0; i < order.tokenIds.length; i++) {
      delete authorizations[order.tokenIds[i]];
      delete heroInOrder[order.tokenIds[i]];
    }
    _refund(order.maker, order.paymentCurrency, order.orderTrustFee);
    heroNft.updateLockedFromMKPStatus(order.tokenIds, false);
    delete orders[_orderId];
    emit OrderRevokedByOwner(_orderId, block.timestamp);
  }

  function _validateEatherRightAndBurn(uint _eatherId) private {
    require(itemNft.ownerOf(_eatherId) == msg.sender, "MarketPlaceV2: not owner of item");
    bool approved = itemNft.isApprovedForAll(msg.sender, address(this)) || itemNft.getApproved(_eatherId) == address(this);
    require(approved, "MarketPlaceV2: please approve eather item first");
    itemNft.burn(_eatherId);
  }

  // ADMIN FUNCTIONS

  function revokeOrders(uint[] calldata _orderIds) external onlyPVE {
    Order storage order;
    for (uint i = 0; i < _orderIds.length; i++) {
      order = orders[_orderIds[i]];
      require(order.taker != address(0), "MarketPlaceV2: order invalid");
      for (uint j = 0; j < order.tokenIds.length; j++) {
        delete authorizations[order.tokenIds[j]];
      }
      _refund(order.taker, order.paymentCurrency, order.orderTrustFee);
      heroNft.updateLockedFromMKPStatus(order.tokenIds, false);
      delete orders[_orderIds[i]];
    }
    emit OrderRevoked(_orderIds, block.timestamp);
  }

  function revokeHeroes(uint[] calldata _heroIds) external onlyPVE {
    for (uint i = 0; i < _heroIds.length; i++) {
      require(block.timestamp >= expiredSummons[_heroIds[i]], "MarketPlaceV2: hero not expired");
      heroNft.burn(_heroIds[i]);
      delete authorizations[_heroIds[i]];
    }
    emit HeroesRevoked(_heroIds, block.timestamp);
  }

  function updateLockUserStatus(address _user, bool _locked) external onlyMainAdmin {
    lockedUser[_user] = _locked;
    emit UserLocked(_user, _locked);
  }

  function updatePauseStatus(bool _paused) external onlyMainAdmin {
    if(_paused) {
      _pause();
    } else {
      _unpause();
    }
  }

  function updateSignatureTimeout(uint _timeOut) external onlyMainAdmin {
    signatureTimeOut = _timeOut;
    emit SignatureTimeOutUpdated(_timeOut);
  }

  function updateOrderTrustFee(uint _orderTrustFee) external onlyMainAdmin {
    orderTrustFee = _orderTrustFee;
    emit OrderTrustFeeUpdated(_orderTrustFee, block.timestamp);
  }

  function updatePaymentType(PaymentType _type) external onlyMainAdmin {
    paymentType = _type;
    emit PaymentTypeChanged(_type);
  }

  function setContracts(address _rewardManager, address _heroNft, address _itemNft, address _gamePVE, address _fotaToken, address _busdToken, address _usdtToken, address _fotaPricer) external onlyMainAdmin {
    rewardManager = IRewardManager(_rewardManager);
    heroNft = IGameNFT(_heroNft);
    itemNft = IGameNFT(_itemNft);
    gamePVE = _gamePVE;
    fotaToken = IBEP20(_fotaToken);
    busdToken = IBEP20(_busdToken);
    usdtToken = IBEP20(_usdtToken);
    fotaPricer = IFOTAPricer(_fotaPricer);
  }

  function updateSummonTime(uint _summonTime) external onlyMainAdmin {
    summonTime = _summonTime;

    emit SummonTimeUpdated(_summonTime);
  }

  // PRIVATE FUNCTIONS

  function _validateUser() private view {
    require(!lockedUser[msg.sender], "MarketPlaceV2: user locked");
  }

  function _takeFund(Order storage _order, PaymentCurrency _paymentCurrency) private {
    if (paymentType == PaymentType.fota) {
      _order.orderTrustFee = _order.orderTrustFee * 1000 / fotaPricer.fotaPrice();
      _takeFundFOTA(_order.orderTrustFee);
    } else if (paymentType == PaymentType.usd) {
      _takeFundUSD(_order.orderTrustFee, _paymentCurrency);
    } else if (_paymentCurrency == PaymentCurrency.fota) {
      _order.orderTrustFee = _order.orderTrustFee * 1000 / fotaPricer.fotaPrice();
      _takeFundFOTA(_order.orderTrustFee);
    } else {
      _takeFundUSD(_order.orderTrustFee, _paymentCurrency);
    }
  }

  function _refund(address _taker, PaymentCurrency _paymentCurrency, uint _amount) private {
    if (_paymentCurrency == PaymentCurrency.fota) {
      require(fotaToken.balanceOf(address(this)) >= _amount, "MarketPlaceV2: contract insufficient balance");
      fotaToken.transfer(_taker, _amount);
    } else if (_paymentCurrency == PaymentCurrency.busd) {
      require(busdToken.balanceOf(address(this)) >= _amount, "MarketPlaceV2: contract insufficient balance");
      busdToken.transfer(_taker, _amount);
    } else {
      require(usdtToken.balanceOf(address(this)) >= _amount, "MarketPlaceV2: contract insufficient balance");
      usdtToken.transfer(_taker, _amount);
    }
  }

  function _takeFundUSD(uint _amount, PaymentCurrency _paymentCurrency) private {
    require(_paymentCurrency != PaymentCurrency.fota, "MarketPlaceV2: paymentCurrency invalid");
    IBEP20 usdToken = _paymentCurrency == PaymentCurrency.busd ? busdToken : usdtToken;
    require(usdToken.allowance(msg.sender, address(this)) >= _amount, "MarketPlaceV2: insufficient balance");
    require(usdToken.balanceOf(msg.sender) >= _amount, "MarketPlaceV2: allowance invalid");
    require(usdToken.transferFrom(msg.sender, address(this), _amount), "MarketPlaceV2: transfer error");
  }

  function _takeFundFOTA(uint _amount) private {
    require(fotaToken.allowance(msg.sender, address(this)) >= _amount, "MarketPlaceV2: please approve fota first");
    require(fotaToken.balanceOf(msg.sender) >= _amount, "MarketPlaceV2: insufficient balance");
    require(fotaToken.transferFrom(msg.sender, address(this), _amount), "MarketPlaceV2: transfer fota failed");
  }

  function _validateHeroRight(uint[] calldata _tokenIds) private {
    require(_tokenIds.length == 3 || _tokenIds.length == 6 || _tokenIds.length == 9, "MarketPlaceV2: quantity invalid");
    for (uint i = 0; i < _tokenIds.length; i++) {
      require(!heroInOrder[_tokenIds[i]], "MarketPlaceV2: hero is in order");
      heroInOrder[_tokenIds[i]] = true;
      require(!heroNft.lockedFromMKP(_tokenIds[i]), "MarketPlaceV2: hero locked");
      if(!allowMaxProfitTrading) {
        require(!heroNft.reachMaxProfit(_tokenIds[i]), "MarketPlaceV2: hero reached max profit");
      }
      address owner = heroNft.ownerOf(_tokenIds[i]);
      require(owner == msg.sender, "MarketPlaceV2: hero invalid");
      if (i > 0) {
        require(_tokenIds[i] > _tokenIds[i - 1], "MarketPlaceV2: hero order invalid");
      }
    }
  }

  function _validateSignature(uint16 _classId, uint _timestamp, bytes memory _signature) private {
    require(_timestamp + signatureTimeOut >= block.timestamp, "MarketPlaceV2: signature time out");
    bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
        keccak256("SummonHero(address user,uint256 nonce,uint16 classId,uint256 timestamp)"),
        msg.sender,
        nonces[msg.sender],
        _classId,
        _timestamp
      )));
    nonces[msg.sender]++;
    address signer = ECDSAUpgradeable.recover(digest, _signature);
    require(signer == contractAdmin, "MessageVerifier: invalid signature");
    require(signer != address(0), "ECDSAUpgradeable: invalid signature");
  }

  function _validateRevokeHeroesSignature(uint _orderId, uint _timestamp, bytes memory _signature) private {
    require(_timestamp + signatureTimeOut >= block.timestamp, "MarketPlaceV2: signature time out");
    bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
        keccak256("RevokeHeroes(address user,uint256 nonce,uint256 orderId,uint256 timestamp)"),
        msg.sender,
        nonces[msg.sender],
        _orderId,
        _timestamp
      )));
    nonces[msg.sender]++;
    address signer = ECDSAUpgradeable.recover(digest, _signature);
    require(signer == contractAdmin, "MessageVerifier: invalid signature");
    require(signer != address(0), "ECDSAUpgradeable: invalid signature");
  }

  function _setTimeExpiredForSummonHero(uint _tokenId) private returns (uint) {
    expiredSummons[_tokenId] = block.timestamp + summonTime;

    return block.timestamp + summonTime;
  }

  function updateAllowMaxProfitTrading(bool _allowed) external onlyMainAdmin {
    allowMaxProfitTrading = _allowed;
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

interface IRewardManager {
  function addPVEReward(address _user, uint[] memory _data) external;
  function addPVPReward(address _user, int _gem) external;
  function getDaysPassed() external view returns (uint);
  function gemRate() external view returns (uint);
  function summonHero(address _user, uint _amount) external returns (uint);
  function summonPrestigeHero(address _user, uint _amount) external returns (uint);
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
  function increaseTotalProfited(uint[] memory _tokenIds, uint[] memory _amounts) external;
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
    function __EIP712_init(string memory name, string memory version) internal initializer {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal initializer {
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
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSAUpgradeable {
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
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
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
            return recover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return recover(hash, r, vs);
        } else {
            revert("ECDSA: invalid signature length");
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return recover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`, `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        require(
            uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ECDSA: invalid signature 's' value"
        );
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
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

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/*
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