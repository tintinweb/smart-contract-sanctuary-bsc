// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "../libs/fota/Auth.sol";
import "../libs/zeppelin/token/BEP20/IBEP20.sol";
import "../interfaces/IFOTAGame.sol";
import "../interfaces/IFOTAToken.sol";
import "../interfaces/IMarketPlace.sol";
import "../interfaces/IFOTAPricer.sol";
import "../interfaces/ILandNFT.sol";

contract LandLordManager is Auth {
  struct Land {
    address landLord;
    uint landLordPercentage;
    uint pendingReward;
    uint totalRewarded;
    uint foundingPrice;
    address[] shareHolders;
    mapping (address => uint) shareHolderPercentage;
  }
  struct ShareOrder {
    uint mission;
    address maker;
    address taker;
    uint sharePercentage; // decimal 3
    uint price;
    bool active;
  }
  struct LandOrder {
    uint mission;
    uint nftId;
    address maker;
    address taker;
    uint price;
    bool active;
  }
  enum OrderType {
    land,
    shareHolder
  }
  IMarketPlace.PaymentType public paymentType;
  IFOTAGame public gamePve;
  IFOTAToken public fotaToken;
  IFOTAPricer public fotaPricer;
  IBEP20 public busdToken;
  IBEP20 public usdtToken;
  ILandNFT public landNFT;
  mapping (uint => Land) public lands;
  mapping (uint => ShareOrder) public shareOrders;
  mapping (uint => LandOrder) public landOrders;
  uint private totalOrder;

  event Claimed(address indexed landLord, uint amount, uint landLordAmount);
  event OrderCreated(OrderType orderType, address indexed maker, uint orderId, uint sharePercentage, uint price);
  event OrderTaken(address indexed taker, uint orderId, address maker, IMarketPlace.PaymentCurrency paymentCurrency);
  event OrderCanceled(uint orderId);
  event FoundingPriceUpdated(uint mission, uint price);
  event ShareHolderChanged(uint mission, address oldHolder, address newHolder);
  event PaymentTypeChanged(IMarketPlace.PaymentType newMethod);
  event LandLordGranted(uint mission, address landLord, uint price);

  modifier onlyLandLord(uint _mission) {
    require(_isLandLord(_mission, msg.sender), "Only land lord");
    _;
  }

  function initialize(address _mainAdmin, address _fotaToken, address _pve, address _fotaPricer, address _landNFT) public initializer {
    super.initialize(_mainAdmin);
    fotaToken = IFOTAToken(_fotaToken);
    gamePve = IFOTAGame(_pve);
    fotaPricer = IFOTAPricer(_fotaPricer);
    landNFT = ILandNFT(_landNFT);
    syncLandLords();
  }

  function takeFounding(uint _mission, IMarketPlace.PaymentCurrency _paymentCurrency) external {
    require(lands[_mission].foundingPrice > 0, "Land is not available");
    require(lands[_mission].landLord == address(0), "Land has occupied");
    _validatePaymentMethod(_paymentCurrency);
    uint currentPrice = lands[_mission].foundingPrice;
    if (_isFotaPayment(_paymentCurrency)) {
      currentPrice = currentPrice * 1000 / fotaPricer.fotaPrice();
    }
    _takeFund(currentPrice, _paymentCurrency, address(this));
    // TODO move money to main admin?
    gamePve.updateLandLord(_mission, msg.sender);
    landNFT.mintLand(msg.sender);
    emit LandLordGranted(_mission, msg.sender, lands[_mission].foundingPrice);
  }

  function claim(uint _mission) external onlyLandLord(_mission) {
    uint pendingReward = lands[_mission].pendingReward;
    if (pendingReward > 0) {
      lands[_mission].pendingReward = 0;
      lands[_mission].totalRewarded += pendingReward;
      uint landLordAmount = pendingReward * lands[_mission].landLordPercentage / 100000;
      fotaToken.transfer(msg.sender, landLordAmount);
      for(uint i = 0; i < lands[_mission].shareHolders.length; i++) {
        address shareHolder = lands[_mission].shareHolders[i];
        uint shareAmount = pendingReward * lands[_mission].shareHolderPercentage[shareHolder] / 100000;
        fotaToken.transfer(shareHolder, shareAmount);
      }
      emit Claimed(msg.sender, pendingReward, landLordAmount);
    }
  }

  function giveReward(uint _mission, uint _amount) external {
    _takeFundFOTA(_amount, address(this));
    lands[_mission].pendingReward += _amount;
  }

  function makeLandOrder(uint _mission, uint _price) external onlyLandLord(_mission) {
    require(landNFT.isApprovedForAll(msg.sender, address(this)) || landNFT.getApproved(_mission) == address(this), "Please call approve first");
    landOrders[totalOrder] = LandOrder(_mission, _mission, msg.sender, address(0), _price, true);
    emit OrderCreated(OrderType.land, msg.sender, totalOrder, 0, _price);
    totalOrder += 1;
  }

  function makeShareOrder(uint _mission, uint _sharePercent, uint _price) external {
    _validateMaker(_mission, _sharePercent);
    shareOrders[totalOrder] = ShareOrder(_mission, msg.sender, address(0), _sharePercent, _price, true);
    emit OrderCreated(OrderType.shareHolder, msg.sender, totalOrder, _sharePercent, _price);
    totalOrder += 1;
  }

  function cancelOrder(uint _id) external {
    ShareOrder storage shareOrder = shareOrders[_id];
    if (shareOrder.active) {
      shareOrder.active = false;
    } else {
      LandOrder storage landOrder = landOrders[_id];
      require(landOrder.active, "Order invalid");
      landOrder.active = false;
    }
    emit OrderCanceled(_id);
  }

  function takeLandOrder(uint _id, IMarketPlace.PaymentCurrency _paymentCurrency) external {
    _validatePaymentMethod(_paymentCurrency);
    LandOrder storage order = landOrders[_id];
    require(order.active && order.taker == address(0), "Order is invalid");
    require(landNFT.isApprovedForAll(order.maker, address(this)) || landNFT.getApproved(order.nftId) == address(this), "Owner has canceled order");
    uint price = order.price;
    if (_isFotaPayment(_paymentCurrency)) {
      price = price * 1000 / fotaPricer.fotaPrice();
    }
    order.taker = msg.sender;
    landNFT.transferFrom(order.maker, order.taker, order.nftId);
    gamePve.updateLandLord(order.mission, msg.sender);
    _takeFund(price, _paymentCurrency, order.maker);
    emit OrderTaken(msg.sender, _id, order.maker, _paymentCurrency);
  }

  function takeShareOrder(uint _id, IMarketPlace.PaymentCurrency _paymentCurrency) external {
    _validatePaymentMethod(_paymentCurrency);
    ShareOrder storage order = shareOrders[_id];
    require(order.active && order.taker == address(0), "Order is invalid");
    uint price = order.price;
    if (_isFotaPayment(_paymentCurrency)) {
      price = price * 1000 / fotaPricer.fotaPrice();
    }
    require(order.sharePercentage > 0, "Invalid order");
    if(_isLandLord(order.mission, order.maker)) {
      lands[order.mission].landLordPercentage -= order.sharePercentage;
    } else {
      lands[order.mission].shareHolderPercentage[order.maker] -= order.sharePercentage;
    }
    if (_isHolders(lands[order.mission], msg.sender)) {
      lands[order.mission].shareHolderPercentage[msg.sender] += order.sharePercentage;
    } else {
      lands[order.mission].shareHolderPercentage[msg.sender] = order.sharePercentage;
      lands[order.mission].shareHolders.push(msg.sender);
    }
    order.taker = msg.sender;
    _takeFund(price, _paymentCurrency, order.maker);
    emit OrderTaken(msg.sender, _id, order.maker, _paymentCurrency);
  }

  function syncLandLords() public {
    for(uint i = 1; i <= 30; i++) {
      syncLandLord(i);
    }
  }

  function syncLandLord(uint _mission) public {
    address landLord = gamePve.getLandLord(_mission);
    if (lands[_mission].landLord == address(0) && landLord != address(0)) {
      lands[_mission].landLordPercentage = 100000;
    }
    lands[_mission].landLord = landLord;
  }

  function getShareHolderInfo(uint _mission, address _shareHolder) external view returns (uint, uint) {
    Land storage land = lands[_mission];
    return(
      land.shareHolders.length,
      land.shareHolderPercentage[_shareHolder]
    );
  }

  // ADMINS FUNCTIONS

  function updatePaymentType(IMarketPlace.PaymentType _type) external onlyMainAdmin {
    paymentType = _type;
    emit PaymentTypeChanged(_type);
  }

  function setFoundingPrice(uint _mission, uint _price) external onlyMainAdmin {
    lands[_mission].foundingPrice = _price;
    emit FoundingPriceUpdated(_mission, _price);
  }

  function updateShareHolder(uint _mission, address _old, address _new) external onlyMainAdmin {
    Land storage land = lands[_mission];
    require(land.shareHolderPercentage[_old] > 0, "Invalid old holder");
    land.shareHolderPercentage[_new] = land.shareHolderPercentage[_old];
    uint oldIndex = _indexOf(land, _old);
    land.shareHolders[oldIndex] = _new;
    emit ShareHolderChanged(_mission, _old, _new);
  }

  function setContracts(address _fotaToken, address _busdToken, address _usdtToken, address _pve, address _fotaPricer, address _landNFT) external onlyMainAdmin {
    fotaToken = IFOTAToken(_fotaToken);
    busdToken = IBEP20(_busdToken);
    usdtToken = IBEP20(_usdtToken);
    gamePve = IFOTAGame(_pve);
    fotaPricer = IFOTAPricer(_fotaPricer);
    landNFT = ILandNFT(_landNFT);
  }

  // PRIVATE FUNCTIONS

  function _isFotaPayment(IMarketPlace.PaymentCurrency _paymentCurrency) private view returns (bool) {
    return paymentType == IMarketPlace.PaymentType.fota || (paymentType == IMarketPlace.PaymentType.all && _paymentCurrency == IMarketPlace.PaymentCurrency.fota);
  }

  function _validatePaymentMethod(IMarketPlace.PaymentCurrency _paymentCurrency) private view {
    if (paymentType == IMarketPlace.PaymentType.fota) {
      require(_paymentCurrency == IMarketPlace.PaymentCurrency.fota, "400");
    } else if (paymentType == IMarketPlace.PaymentType.usd) {
      require(_paymentCurrency != IMarketPlace.PaymentCurrency.fota, "400");
    }
  }

  function _takeFund(uint _amount, IMarketPlace.PaymentCurrency _paymentCurrency, address _to) private {
    if (paymentType == IMarketPlace.PaymentType.fota) {
      _takeFundFOTA(_amount, _to);
    } else if (paymentType == IMarketPlace.PaymentType.usd) {
      _takeFundUSD(_amount, _paymentCurrency, _to);
    } else if (_paymentCurrency == IMarketPlace.PaymentCurrency.fota) {
      _takeFundFOTA(_amount, _to);
    } else {
      _takeFundUSD(_amount, _paymentCurrency, _to);
    }
  }

  function _takeFundUSD(uint _amount, IMarketPlace.PaymentCurrency _paymentCurrency, address _to) private {
    require(_paymentCurrency != IMarketPlace.PaymentCurrency.fota, "401");
    IBEP20 usdToken = _paymentCurrency == IMarketPlace.PaymentCurrency.busd ? busdToken : usdtToken;
    require(usdToken.allowance(msg.sender, address(this)) >= _amount, "402");
    require(usdToken.balanceOf(msg.sender) >= _amount, "403");
    require(usdToken.transferFrom(msg.sender, _to, _amount), "404");
  }

  function _takeFundFOTA(uint _amount, address _to) private {
    require(fotaToken.allowance(msg.sender, address(this)) >= _amount, "401");
    require(fotaToken.balanceOf(msg.sender) >= _amount, "402");
    require(fotaToken.transferFrom(msg.sender, _to, _amount), "403");
  }

  function _validateMaker(uint _mission, uint _sharePercent) private view {
    require(_sharePercent <= 100000, "Share percentage invalid");
    if (_isLandLord(_mission, msg.sender)) {
      require(lands[_mission].landLordPercentage >= _sharePercent, "Maker invalid");
    } else {
      require(lands[_mission].shareHolderPercentage[msg.sender] >= _sharePercent, "Maker invalid");
    }
  }

  function _isLandLord(uint _mission, address _landLord) private view returns (bool) {
    return lands[_mission].landLord == _landLord;
  }

  function _isHolders(Land storage _land, address _address) private view returns (bool) {
    for(uint i = 0; i < _land.shareHolders.length; i++) {
      if (_land.shareHolders[i] == _address) {
        return true;
      }
    }
    return false;
  }

  function _indexOf(Land storage _land, address _address) private view returns (uint) {
    for(uint i = 0; i < _land.shareHolders.length; i++) {
      if (_land.shareHolders[i] == _address) {
        return i;
      }
    }
    return 0;
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
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import '@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol';

interface ILandNFT is IERC721Upgradeable {
  function mintLand(address _owner) external returns (uint);
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
  function getOwnerTotalLevelThatNotReachMaxProfit(address _owner) external view returns(uint);
  function increaseTotalProfited(uint _tokenId, uint _totalProfited) external;
  function reachMaxProfit(uint _tokenId) external view returns (bool);
  function mintItem(address _owner, uint8 _gene, uint16 _class, uint _price, uint _index) external returns (uint);
  function getItem(uint _tokenId) external view returns (uint8, uint16, uint, uint, uint);
  function getClassId(uint _tokenId) external view returns (uint16);
  function burn(uint _tokenId) external;
  function getCreator(uint _tokenId) external view returns (address);
  function countId() external view returns (uint16);
  function updateOwnPrice(uint _tokenId, uint _ownPrice) external;
  function updateFailedUpgradingAmount(uint _tokenId, uint _amount) external;
  function skillUp(uint _tokenId, uint8 _index) external;
  function experienceUp(uint _tokenId, uint32 _experience) external;
  function experienceCheckpoint(uint8 _level) external view returns (uint32);
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

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

interface IFOTAGame {
  function validateInviter(address _inviter) external view returns (bool);
  function getTotalWinInDay(address _user) external view returns (uint);
  function getTotalPVEWinInDay(address _user) external view returns (uint);
  function getTotalPVPWinInDay(address _user) external view returns (uint);
  function getTotalDUALWinInDay(address _user) external view returns (uint);
  function getLandLord(uint _mission) external view returns (address);
  function updateLandLord(uint _mission, address _landLord) external;
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