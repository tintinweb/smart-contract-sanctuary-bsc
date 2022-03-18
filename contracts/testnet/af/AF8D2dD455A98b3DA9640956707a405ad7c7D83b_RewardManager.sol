// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

interface ICitizen {
  function isCitizen(address _address) external view returns (bool);
  function register(address _address, string memory _userName, address _inviter) external returns (uint);
  function getInviter(address _address) external returns (address);
}

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

interface IFOTAGame {
  function validateInviter(address _inviter) external view returns (bool);
  function totalWinInDay(address _user) external view returns (uint);
}

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

interface IFOTAPricer {
  function fotaPrice() external view returns (uint);
}

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

interface IGameMiningPool {
  function releaseGameAllocation(address _gamerAddress, uint _amount) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import '@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol';

interface IGameNFT is IERC721Upgradeable {
  function mintHero(address _owner, uint16 _classId, uint _price, uint _index) external returns (uint);
  function getHero(uint _tokenId) external view returns (string memory, string memory, string memory, uint16, uint, uint8, uint32);
  function getHeroPrices(uint _tokenId) external view returns (uint, uint);
  function getHeroStrength(uint _tokenId) external view returns (uint, uint, uint, uint, uint);
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

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "../libs/fota/RewardAuth.sol";
import "../interfaces/IGameMiningPool.sol";
import "../interfaces/IFOTAGame.sol";
import "../interfaces/ICitizen.sol";
import "../interfaces/IFOTAPricer.sol";
import "../interfaces/IGameNFT.sol";

contract RewardManager is RewardAuth {
  struct Reward {
    uint userAmount;
    uint farmShareAmount;
    uint referralShareAmount;
    uint landLordShareAmount;
  }
  struct ClaimCondition {
    uint minHero;
    uint[] numberOfHero;
    uint[] maxRewardAccordingToHero;
    uint maxClaimPerDay;
  }
  IGameNFT public heroNft;
  IGameMiningPool public gameMiningPool;
  IFOTAGame public gameProxyContract;
  IFOTAGame public gamePve;
  IFOTAGame public gamePvp;
  IFOTAGame public gameDual;
  ICitizen public citizen;
  IFOTAPricer public fotaPricer;
  ClaimCondition public claimCondition;
  uint public farmShare; // decimal 3
  uint public referralShare; // decimal 3
  uint public landLordShare; // decimal 3
  uint public startTime;
  uint public secondInADay;
  uint public rewardingDays;
  uint public dailyQuestReward;
  uint public pveWinDailyQuestCondition;
  uint public pvpWinDailyQuestCondition;
  uint public dualWinDailyQuestCondition;
  uint public todayClaimed;
  address public treasuryAddress;
  address public farmAddress;
  mapping (address => mapping (uint => Reward[])) public rewards;
  mapping (uint => address) landLord;
  mapping (address => bool) blockedUsers;

  event DailyQuestRewardUpdated(uint amount, uint timestamp);
  event DailyQuestConditionUpdated(uint pve, uint pvp, uint dual, uint timestamp);
  event UserBlockUpdated(address indexed _user, bool blocked, uint timestamp);
  event ClaimConditionUpdated(uint minHero, uint[] numberOfHero, uint[] maxRewardAccordingToHero, uint maxReward, uint timestamp);

  function initialize(address _mainAdmin, address _citizen, address _fotaPricer) public initializer {
    super.initialize(_mainAdmin);
    citizen = ICitizen(_citizen);
    fotaPricer = IFOTAPricer(_fotaPricer);
//    gameMiningPool = IFOTAToken(0x0A4E1BdFA75292A98C15870AeF24bd94BFFe0Bd4);
//    rewardingDays = 14; // TODO
//    secondInADay = 86400; // 24 * 60 * 60
    rewardingDays = 3;
    secondInADay = 600; // 24 * 60 * 60
    dailyQuestReward = 1e18;
  }

  function claim() public {
    _validateUser();
    uint dayPassed = getDaysPassed();
    require(rewards[msg.sender][dayPassed].length > 0, "RewardManager: you have no reward to claim today");
    for (uint i = 0; i < rewards[msg.sender][dayPassed].length; i++) {
      gameMiningPool.releaseGameAllocation(msg.sender, _convertUsdToFota(rewards[msg.sender][dayPassed][i].userAmount));
      gameMiningPool.releaseGameAllocation(farmAddress, _convertUsdToFota(rewards[msg.sender][dayPassed][i].farmShareAmount));
      address inviter = citizen.getInviter(msg.sender);
      bool validInviter = _validateInviter(inviter);
      if (validInviter) {
        gameMiningPool.releaseGameAllocation(inviter, _convertUsdToFota(rewards[msg.sender][dayPassed][i].referralShareAmount));
      } else {
        gameMiningPool.releaseGameAllocation(treasuryAddress, _convertUsdToFota(rewards[msg.sender][dayPassed][i].referralShareAmount));
      }
      // TODO check landLord and share holders
    }
  }

  function addPVEReward(uint _mission, address _user, uint _reward) external onlyGameContract {
    uint farmShareAmount = _reward * farmShare / 100000;
    uint referralShareAmount = _reward * referralShare / 100000;
    uint userShare = _reward - farmShareAmount - referralShareAmount;
    uint landLordShareAmount;
    if (landLord[_mission] != address(0)) {
      landLordShareAmount = userShare * landLordShare / 100000;
      userShare -= landLordShareAmount;
    }
    uint dayPassed = getDaysPassed();
    // TODO check daily quest
    if (_checkCompleteDailyQuest(_user)) {
      userShare += dailyQuestReward;
    }
    rewards[_user][dayPassed].push(Reward(userShare, farmShareAmount, referralShareAmount, landLordShareAmount));
  }

  function getDaysPassed() public view returns (uint) {
    if (startTime == 0) {
      return 0;
    }
    uint timePassed = block.timestamp - startTime;
    return timePassed / secondInADay;
  }

  // PRIVATE FUNCTIONS

  function _validateUser() private returns (uint) {
    require(!blockedUsers[msg.sender], "RewardManager: you can't do this now");
    uint userHero = heroNft.balanceOf(msg.sender);
    require(userHero >= claimCondition.minHero, "RewardManager: invalid hero condition");
    uint userMaxReward = _getUserMaxRewardAccordingToHero(userHero);
    require(userMaxReward > 0, "RewardManager: reward or hero condition invalid");
    if (todayClaimed + userMaxReward >= claimCondition.maxClaimPerDay) {
      userMaxReward = claimCondition.maxClaimPerDay - todayClaimed;
    }
    todayClaimed += userMaxReward;
    return userMaxReward;
  }

  function _getUserMaxRewardAccordingToHero(uint _userHero) private view returns (uint) {
    for(uint i = claimCondition.numberOfHero.length - 1; i >= 0 ; i--) {
      if (_userHero > claimCondition.numberOfHero[i]) {
        return claimCondition.maxRewardAccordingToHero[i];
      }
    }
    return 0;
  }

  function _checkCompleteDailyQuest(address _user) private view returns (bool){
    uint winPVE = gamePve.totalWinInDay(_user);
    uint winPVP = gamePvp.totalWinInDay(_user);
    uint winDUAL = gameDual.totalWinInDay(_user);
    return winPVE >= pveWinDailyQuestCondition && winPVP >= pvpWinDailyQuestCondition && winDUAL >= dualWinDailyQuestCondition;
  }

  function _validateInviter(address _inviter) private view returns (bool) {
    return gameProxyContract.validateInviter(_inviter);
  }

  function _convertUsdToFota(uint _usdAmount) private view returns (uint) {
    return _usdAmount / fotaPricer.fotaPrice() / 1000;
  }

  // ADMIN FUNCTIONS

  function start(uint _startTime) external onlyMainAdmin {
    require(startTime == 0, "FOTAFarm: startTime had been initialized");
    require(_startTime >= 0 && _startTime < block.timestamp - secondInADay, "FOTAFarm: must be earlier yesterday");
    startTime = _startTime;
  }

  function updateSecondInADay(uint _secondInDay) external onlyMainAdmin {
    secondInADay = _secondInDay;
  }

  function updateTreasuryAddress(address _newAddress) external onlyMainAdmin {
    require(_newAddress != address(0), "Invalid address");
    treasuryAddress = _newAddress;
  }

  function updateFarmAddress(address _newAddress) external onlyMainAdmin {
    require(_newAddress != address(0), "Invalid address");
    farmAddress = _newAddress;
  }

  function updateGameProxyContract(address _gameProxy) external onlyMainAdmin {
    gameProxyContract = IFOTAGame(_gameProxy);
  }

  function setShares(uint _referralShare, uint _farmShare, uint _landLordShare) external onlyMainAdmin {
    require(_referralShare > 0 && _referralShare <= 10000);
    referralShare = _referralShare;
    require(_farmShare > 0 && _farmShare <= 10000);
    farmShare = _farmShare;
    require(_landLordShare > 0 && _landLordShare <= 10000);
    landLordShare = _landLordShare;
  }

  function updateDailyQuestReward(uint _newReward) external onlyMainAdmin {
    dailyQuestReward = _newReward;
    emit DailyQuestRewardUpdated(dailyQuestReward, block.timestamp);
  }

  function updateDailyQuestCondition(uint _pveWinDailyQuestCondition, uint _pvpWinDailyQuestCondition, uint _dualWinDailyQuestCondition) external onlyMainAdmin {
    pveWinDailyQuestCondition = _pveWinDailyQuestCondition;
    pvpWinDailyQuestCondition = _pvpWinDailyQuestCondition;
    dualWinDailyQuestCondition = _dualWinDailyQuestCondition;
    emit DailyQuestConditionUpdated(pveWinDailyQuestCondition, pvpWinDailyQuestCondition, dualWinDailyQuestCondition, block.timestamp);
  }

  function setContracts(address _heroNft, address _gameMiningPool) external onlyMainAdmin {
    heroNft = IGameNFT(_heroNft);
    gameMiningPool = IGameMiningPool(_gameMiningPool);
  }

  function setGameAddresses(address _pve, address _pvp, address _dual) external onlyMainAdmin {
    require(_pve != address(0) && _pvp != address(0) && _dual != address(0), "Invalid address");
    gamePve = IFOTAGame(_pve);
    gamePvp = IFOTAGame(_pvp);
    gameDual = IFOTAGame(_dual);
  }

  function updateFotaPricer(address _pricer) external onlyMainAdmin {
    require(_pricer != address(0), "Invalid address");
    fotaPricer = IFOTAPricer(_pricer);
  }

  function updateBlockedUser(address _user, bool _blocked) external onlyMainAdmin {
    blockedUsers[_user] = _blocked;
    emit UserBlockUpdated(_user, _blocked, block.timestamp);
  }

  function updateClaimCondition(
    uint _minHero,
    uint[] calldata _numberOfHero,
    uint[] calldata _maxRewardAccordingToHero,
    uint _maxClaimPerDay
  ) external onlyMainAdmin {
    claimCondition.minHero = _minHero;
    claimCondition.numberOfHero = _numberOfHero;
    claimCondition.maxRewardAccordingToHero = _maxRewardAccordingToHero;
    claimCondition.maxClaimPerDay = _maxClaimPerDay;
    emit ClaimConditionUpdated(_minHero, _numberOfHero, _maxRewardAccordingToHero, _maxClaimPerDay, block.timestamp);
  }
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