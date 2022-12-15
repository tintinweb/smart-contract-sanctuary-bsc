// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "../libs/fota/RewardAuth.sol";
import "../interfaces/IGameMiningPool.sol";
import "../interfaces/IFOTAGame.sol";
import "../interfaces/ICitizen.sol";
import "../interfaces/IFOTAPricer.sol";
import "../interfaces/IGameNFT.sol";
import "../libs/fota/Math.sol";
import "../interfaces/IFarm.sol";
import "../interfaces/IFOTAToken.sol";
import "../interfaces/ILandLordManager.sol";

contract RewardManager is RewardAuth, PausableUpgradeable {
  using Math for uint;
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

  IGameNFT public heroNft;
  IGameMiningPool public gameMiningPool;
  IFOTAGame public gameProxyContract;
  ICitizen public citizen;
  IFOTAPricer public fotaPricer;
  IFarm public farm;
  IFOTAToken public fotaToken;
  IBEP20 public busdToken;
  IBEP20 public usdtToken;
  PaymentType public paymentType;
  address public fundAdmin;
  ILandLordManager public landLordManager;
  uint public farmShare; // decimal 3
  uint public referralShare; // decimal 3
  uint public landLordShare; // decimal 3
  uint public dailyQuestReward;
  address public treasuryAddress;
  mapping (address => uint) public userRewards;
  uint public treasuryShareAmount;
  uint public farmShareAmount;
  uint public fotaDiscount; // decimal 3
  uint constant oneHundredPercentageDecimal3 = 100000;

  event DailyQuestRewardUpdated(uint amount, uint timestamp);
  event FotaDiscountUpdated(uint fotaDiscount);
  event RewardRecorded(address indexed user, uint reward);
  event Deposited(address indexed user, uint amount, uint timestamp);
  event StoreDeposited(address indexed user, uint amount, uint timestamp);
  event UserRewardChanged(address indexed user, uint amount, uint remainingAmount);
  event ShareUpdated(uint referralShare, uint farmShare, uint landLordShare);
  event PaymentTypeUpdated(PaymentType newMethod);

  function initialize(address _mainAdmin, address _citizen, address _fotaPricer) public initializer {
    super.initialize(_mainAdmin);
    citizen = ICitizen(_citizen);
    fotaPricer = IFOTAPricer(_fotaPricer);
//    fotaToken = IFOTAToken(0x0A4E1BdFA75292A98C15870AeF24bd94BFFe0Bd4);
//    gameMiningPool = IFOTAToken(0x0A4E1BdFA75292A98C15870AeF24bd94BFFe0Bd4);
    dailyQuestReward = 1e18;
    farmShare = 3000;
    referralShare = 2000;
    landLordShare = 1000;
  }

  // _data: 0: userReward, 1: referralReward, 2: farmShare, 3: biggestFinishMission, 4: timestamp, 5->n: landLord
  function addPVEReward(address _user, uint[] memory _data) external onlyGameContract {
    // add user reward
    userRewards[_user] += _data[0];
    // inviter or treasury
    address inviterOrTreasury = citizen.getInviter(_user);
    if (inviterOrTreasury == address(0)) {
      inviterOrTreasury = treasuryAddress;
    }
    bool validInviter = gameProxyContract.validateInviter(inviterOrTreasury);
    if (validInviter) {
      userRewards[inviterOrTreasury] += _data[1];
    } else {
      treasuryShareAmount += _data[1];
    }
    // farm
    farmShareAmount += _data[2];
    // land lord
    uint halfLandlordLength = (_data.length - 5) / 2;
    uint endForLoop = 4 + halfLandlordLength;
    for(uint i = 5; i <= endForLoop; i++) {
      landLordManager.giveReward(_data[i], _data[i + halfLandlordLength]);
    }
    emit RewardRecorded(_user, _data[0]);
  }

  function deposit(uint _amount, PaymentCurrency _paymentCurrency) external {
    if(_paymentCurrency == PaymentCurrency.fota) {
      _takeFund(_convertUsdToFota(_amount) * (oneHundredPercentageDecimal3 - fotaDiscount) / oneHundredPercentageDecimal3, _paymentCurrency);
    } else {
      _takeFund(_amount, _paymentCurrency);
    }
    userRewards[msg.sender] += _amount;
    emit Deposited(msg.sender, _amount, block.timestamp);
  }

  function storeDeposit(address _user, uint _amount) external onlyMainAdmin {
    userRewards[_user] += _amount;
    emit StoreDeposited(_user, _amount, block.timestamp);
  }

  // ADMIN FUNCTIONS

  function updatePaymentType(PaymentType _type) external onlyMainAdmin {
    paymentType = _type;
    emit PaymentTypeUpdated(_type);
  }

  function updateTreasuryAddress(address _newAddress) external onlyMainAdmin {
    require(_newAddress != address(0), "Invalid address");
    treasuryAddress = _newAddress;
  }

  function updateDailyQuestReward(uint _reward) external onlyMainAdmin {
    dailyQuestReward = _reward;
    emit DailyQuestRewardUpdated(_reward, block.timestamp);
  }

  function updateGameProxyContract(address _gameProxy) external onlyMainAdmin {
    gameProxyContract = IFOTAGame(_gameProxy);
  }

  function updateFundAdmin(address _address) external onlyMainAdmin {
    require(_address != address(0));
    fundAdmin = _address;
  }

  function updateFotaDiscount(uint _fotaDiscount) external onlyMainAdmin {
    require(_fotaDiscount >= 0 && fotaDiscount <= oneHundredPercentageDecimal3, "Invalid data");
    fotaDiscount = _fotaDiscount;
    emit FotaDiscountUpdated(fotaDiscount);
  }

  function setShares(uint _referralShare, uint _farmShare, uint _landLordShare) external onlyMainAdmin {
    require(_referralShare > 0 && _referralShare <= 10000);
    referralShare = _referralShare;
    require(_farmShare > 0 && _farmShare <= 10000);
    farmShare = _farmShare;
    require(_landLordShare > 0 && _landLordShare <= 10000);
    landLordShare = _landLordShare;
    emit ShareUpdated(referralShare, farmShare, landLordShare);
  }

  function setContracts(address _heroNft, address _fotaToken, address _landLordManager, address _farmAddress) external onlyMainAdmin {
    heroNft = IGameNFT(_heroNft);
    fotaToken = IFOTAToken(_fotaToken);
    landLordManager = ILandLordManager(_landLordManager);
    require(_farmAddress != address(0), "Invalid address");
    farm = IFarm(_farmAddress);
    fotaToken.approve(_landLordManager, type(uint).max);
    fotaToken.approve(_farmAddress, type(uint).max);
  }

  function updatePauseStatus(bool _paused) external onlyMainAdmin {
    if(_paused) {
      _pause();
    } else {
      _unpause();
    }
  }

  function useTreasuryShareAmount(uint _amount) external onlyMainAdmin {
    require(_amount <= treasuryShareAmount, "Data invalid");
    treasuryShareAmount -= _amount;
    gameMiningPool.releaseGameAllocation(treasuryAddress, _convertUsdToFota(_amount));
  }

  function useFarmShareAmount(uint _amount) external onlyMainAdmin {
    require(_amount <= farmShareAmount, "Data invalid");
    farmShareAmount -= _amount;
    uint distributedToFarm = _convertUsdToFota(_amount);
    gameMiningPool.releaseGameAllocation(address(this), distributedToFarm);
    farm.fundFOTA(distributedToFarm);
  }

  function summonHero(address _user, uint _amount) external onlyContractAdmin {
    require(userRewards[_user] >= _amount, "RewardManager: insufficient balance");
    userRewards[_user] -= _amount;
    emit UserRewardChanged(_user, _amount, userRewards[_user]);
  }

  // PRIVATE FUNCTIONS

  function _convertUsdToFota(uint _amount) private view returns (uint) {
    return _amount * 1000 / fotaPricer.fotaPrice();
  }

  function _takeFund(uint _amount, PaymentCurrency _paymentCurrency) private {
    if (paymentType == PaymentType.fota) {
      _takeFundFOTA(_amount);
    } else if (paymentType == PaymentType.usd) {
      _takeFundUSD(_amount, _paymentCurrency);
    } else if (_paymentCurrency == PaymentCurrency.fota) {
      _takeFundFOTA(_amount);
    } else {
      _takeFundUSD(_amount, _paymentCurrency);
    }
  }

  function _takeFundUSD(uint _amount, PaymentCurrency _paymentCurrency) private {
    require(_paymentCurrency != PaymentCurrency.fota, "RewardManagerV2: paymentCurrency invalid");
    IBEP20 usdToken = _paymentCurrency == PaymentCurrency.busd ? busdToken : usdtToken;
    require(usdToken.allowance(msg.sender, address(this)) >= _amount, "RewardManagerV2: insufficient balance");
    require(usdToken.balanceOf(msg.sender) >= _amount, "RewardManagerV2: allowance invalid");
    require(usdToken.transferFrom(msg.sender, fundAdmin, _amount), "RewardManagerV2: transfer error");
  }

  function _takeFundFOTA(uint _amount) private {
    require(fotaToken.allowance(msg.sender, address(this)) >= _amount, "RewardManagerV2: allowance invalid");
    require(fotaToken.balanceOf(msg.sender) >= _amount, "RewardManagerV2: insufficient balance");
    require(fotaToken.transferFrom(msg.sender, fundAdmin, _amount), "RewardManagerV2: transfer error");
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

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "./Auth.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

abstract contract RewardAuth is Auth, ContextUpgradeable {
  mapping(address => bool) public gameContracts;

  function initialize(address _mainAdmin) virtual override public {
    Auth.initialize(_mainAdmin);
  }

  modifier onlyGameContract() {
    require(_isGameContracts() || _isMainAdmin(), "NFTAuth: Only game contract");
    _;
  }

  function _isGameContracts() internal view returns (bool) {
    return gameContracts[_msgSender()];
  }

  function updateGameContract(address _contract, bool _status) onlyMainAdmin external {
    require(_contract != address(0), "NFTAuth: Address invalid");
    gameContracts[_contract] = _status;
  }
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
    return uint(randomNumber + _from);
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

interface ILandLordManager {
  function giveReward(uint _mission, uint _amount) external;
  function syncLandLord(uint _mission) external;
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
}

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

interface IGameMiningPool {
  function releaseGameAllocation(address _gamerAddress, uint _amount) external returns (bool);
}

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

interface IFarm {
  function fundFOTA(uint _amount) external;
  function farmers(address _farmer) external view returns (uint, uint, uint, uint, uint, uint);
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
  function updateLandLord(uint _mission, address _landLord) external;
}

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

interface ICitizen {
  function isCitizen(address _address) external view returns (bool);
  function register(address _address, string memory _userName, address _inviter) external returns (uint);
  function getInviter(address _address) external returns (address);
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