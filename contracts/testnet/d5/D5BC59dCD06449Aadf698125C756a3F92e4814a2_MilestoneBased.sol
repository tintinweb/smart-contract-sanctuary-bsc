// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./Roadmap.sol";
import "./Voting.sol";
import "./WhiteList.sol";
import "./interfaces/IEntityFactory.sol";

/// @title A factory for roadmap deployment.
/// @dev Contains upgradable beacon proxies of other contracts for a Dapp.
contract MilestoneBased is Ownable {
  /// @notice Struct RoadmapInitializationSettings - contain roadmap settings to create a new Roadmap.
  /// @param id id of roadmap to deploy;
  /// @param fundingToken ERC20 contract to be used for a funding functionality;
  /// @param fundsReleaseType chooses a funds release type logic from a MilestoneStartDate(0), MilestoneEndDate(1) set;
  /// @param projectEntity address of a projectEntity contract who is able to withdraw funds from withdrawable milestones.
  struct RoadmapInitializationSettings {
    uint256 id;
    IERC20 fundingToken;
    Roadmap.FundsReleaseType fundsReleaseType;
    address projectEntity;
  }

  /// @notice Struct RoadmapInitializationSettings - contain voting settings to create a new Voting for Roadmap.
  /// @param votingStrategy IVotingStrategy contract to be used to check vote validity;
  /// @param ipfsVotingDetails IPFS hash of complementary voting settings information;
  /// @param votingDuration duration for a voting stage of each proposal, in seconds;
  /// @param minConsensusVotingPower minimal threshold of voting power in a proposal in order for it to be executable.
  struct VotingInitializationSettings {
    IVotingStrategy votingStrategy;
    bytes ipfsVotingDetails;
    uint64 votingDuration;
    uint256 minConsensusVotingPower;
  }
  /// @notice Stores the address of an white list contract.
  /// @return Address of a white list contract.
  WhiteList public whiteList;
  /// @notice Stores the address of an entity factory contract.
  /// @return Address of a entity factory contract.
  EntityFactory public entityFactory;
  /// @notice Stores the address of an upgradable beacon proxy for a roadmap contract.
  /// @return Address of an upgradable beacon proxy for a roadmap contract.
  UpgradeableBeacon public roadmapBeacon;
  /// @notice Stores the address of an upgradable beacon proxy for a voting contract.
  /// @return Address of an upgradable beacon proxy for a voting contract.
  UpgradeableBeacon public votingBeacon;
  /// @notice Stores the refunding address used for roadmaps creation.
  /// @return Refunding address used for roadmaps creation.
  address public refunding;
  /// @notice Stores the refunding address used for roadmaps creation.
  bool private _initialized;
  /// @notice Stores if a particular address is a roadmap created by this factory.
  /// @return Boolean value which is true if provided address is a roadmap created by this factory.
  mapping(address => bool) public isRoadmapByAddress;

  /// @notice Emits on each successful roadmap deployment.
  /// @dev Id parameter does not have to be unique.
  /// @param id id passed to a deployment process;
  /// @param roadmap deployed roadmap address.
  event RoadmapCreated(uint256 id, address roadmap);

  /// @notice Emits on each updating of whiteList contract.
  /// @param oldWhiteList address of old whiteList contract;
  /// @param newWhiteList address of new whiteList contract.
  event UpdateWhiteList(address oldWhiteList, address newWhiteList);

  /// @notice Emits on each updating of entityFactory contract.
  /// @param oldEntityFactory address of old entityFactory contract;
  /// @param newEntityFactory address of new entityFactory contract.
  event UpdateEntityFactory(address oldEntityFactory, address newEntityFactory);

  modifier initializer() {
    require(!_initialized, "Contract instance has already been initialized");

    _initialized = true;

    _;
  }

  /// @param _roadmapBeacon roadmap upgradable beacon proxy address;
  /// @param _votingBeacon voting upgradable beacon proxy address;
  /// @param _whiteList white list contract address.
  /// @param _entityFactory EntityFactory address contract.
  function initialize(
    address _roadmapBeacon,
    address _votingBeacon,
    address _whiteList,
    address _refunding,
    address _entityFactory
  ) external initializer {
    require(_entityFactory != address(0), "Address cannot be zero");

    whiteList = WhiteList(_whiteList);
    roadmapBeacon = UpgradeableBeacon(_roadmapBeacon);
    votingBeacon = UpgradeableBeacon(_votingBeacon);
    refunding = _refunding;
    entityFactory = EntityFactory(_entityFactory);
  }

  /// @notice Creates a roadmap and a corresponding voting contract by provided parameters.
  /// @param roadmapSettings roadmap settings containing:
  /// uint256 id - id of roadmap to deploy.
  /// address fundingToken - ERC20 contract to be used for a funding functionality.
  /// Roadmap.FundsReleaseType fundsReleaseType - chooses a funds release type logic from a MilestoneStartDate(0), MilestoneEndDate(1) set.
  /// address admin - address of a first admin who is able to withdraw funds from withdrawable milestones.
  /// Can be as an externally owned account address, as a contract address(for example, multi-signature wallet).
  /// @param votingSettings voting settings containing:
  /// address votingStrategy - IVotingStrategy contract to be used to check vote validity.
  /// bytes ipfsVotingDetails - IPFS hash of complementary voting settings information.
  /// uint256 votingDuration - duration for a voting stage of each proposal, in seconds.
  /// uint256 minConsensusVotingPower - minimal threshold of voting power in a proposal in order for it to be executable.
  function createRoadmap(
    RoadmapInitializationSettings calldata roadmapSettings,
    VotingInitializationSettings calldata votingSettings
  ) external {
    require(
      entityFactory.getEntityType(msg.sender) ==
        uint256(IEntityFactory.EntityType.ProjectEntity),
      "The owner is not project entity"
    );
    BeaconProxy roadmap = new BeaconProxy(address(roadmapBeacon), "");
    BeaconProxy voting = new BeaconProxy(address(votingBeacon), "");

    Roadmap(address(roadmap)).initialize(
      address(voting),
      refunding,
      roadmapSettings.projectEntity,
      roadmapSettings.fundingToken,
      roadmapSettings.fundsReleaseType
    );

    Voting(address(voting)).initialize(
      address(roadmap),
      votingSettings.votingStrategy,
      votingSettings.ipfsVotingDetails,
      0,
      votingSettings.votingDuration,
      0,
      0,
      votingSettings.minConsensusVotingPower
    );
    whiteList.addNewAddress(address(roadmap));
    whiteList.addNewAddress(address(voting));
    isRoadmapByAddress[address(roadmap)] = true;
    emit RoadmapCreated(roadmapSettings.id, address(roadmap));
  }

  /// @dev Set new address of WhiteList contract.
  /// @param _whiteList new address of WhiteList contract.
  function setWhiteList(address _whiteList) external onlyOwner {
    require(_whiteList != address(0), "Address cannot be zero");
    address oldWhiteList = address(whiteList);
    whiteList = WhiteList(_whiteList);
    emit UpdateWhiteList(oldWhiteList, _whiteList);
  }

  /// @dev Sets new address of EntityFactory contract.
  /// @param _entityFactory new address of EntityFactory contract.
  function setEntityFactory(address _entityFactory) external onlyOwner {
    require(_entityFactory != address(0), "Address cannot be zero");
    address oldEntityFactory = address(entityFactory);
    entityFactory = EntityFactory(_entityFactory);
    emit UpdateEntityFactory(oldEntityFactory, _entityFactory);
  }
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

import "./IBeacon.sol";
import "../Proxy.sol";
import "../ERC1967/ERC1967Upgrade.sol";

/**
 * @dev This contract implements a proxy that gets the implementation address for each call from a {UpgradeableBeacon}.
 *
 * The beacon address is stored in storage slot `uint256(keccak256('eip1967.proxy.beacon')) - 1`, so that it doesn't
 * conflict with the storage layout of the implementation behind the proxy.
 *
 * _Available since v3.4._
 */
contract BeaconProxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Initializes the proxy with `beacon`.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon. This
     * will typically be an encoded function call, and allows initializating the storage of the proxy like a Solidity
     * constructor.
     *
     * Requirements:
     *
     * - `beacon` must be a contract with the interface {IBeacon}.
     */
    constructor(address beacon, bytes memory data) payable {
        assert(_BEACON_SLOT == bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1));
        _upgradeBeaconToAndCall(beacon, data, false);
    }

    /**
     * @dev Returns the current beacon address.
     */
    function _beacon() internal view virtual returns (address) {
        return _getBeacon();
    }

    /**
     * @dev Returns the current implementation address of the associated beacon.
     */
    function _implementation() internal view virtual override returns (address) {
        return IBeacon(_getBeacon()).implementation();
    }

    /**
     * @dev Changes the proxy to use a new beacon. Deprecated: see {_upgradeBeaconToAndCall}.
     *
     * If `data` is nonempty, it's used as data in a delegate call to the implementation returned by the beacon.
     *
     * Requirements:
     *
     * - `beacon` must be a contract.
     * - The implementation returned by `beacon` must be a contract.
     */
    function _setBeacon(address beacon, bytes memory data) internal virtual {
        _upgradeBeaconToAndCall(beacon, data, false);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IBeacon.sol";
import "../../access/Ownable.sol";
import "../../utils/Address.sol";

/**
 * @dev This contract is used in conjunction with one or more instances of {BeaconProxy} to determine their
 * implementation contract, which is where they will delegate all function calls.
 *
 * An owner is able to change the implementation the beacon points to, thus upgrading the proxies that use this beacon.
 */
contract UpgradeableBeacon is IBeacon, Ownable {
    address private _implementation;

    /**
     * @dev Emitted when the implementation returned by the beacon is changed.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Sets the address of the initial implementation, and the deployer account as the owner who can upgrade the
     * beacon.
     */
    constructor(address implementation_) {
        _setImplementation(implementation_);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function implementation() public view virtual override returns (address) {
        return _implementation;
    }

    /**
     * @dev Upgrades the beacon to a new implementation.
     *
     * Emits an {Upgraded} event.
     *
     * Requirements:
     *
     * - msg.sender must be the owner of the contract.
     * - `newImplementation` must be a contract.
     */
    function upgradeTo(address newImplementation) public virtual onlyOwner {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Sets the implementation contract address for this beacon
     *
     * Requirements:
     *
     * - `newImplementation` must be a contract.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "UpgradeableBeacon: implementation is not a contract");
        _implementation = newImplementation;
    }
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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./EntityFactory.sol";
import "./ProjectEntity.sol";

/// @title Contract for managing milestones and their funding.
contract Roadmap is Initializable {
  using SafeERC20 for IERC20;
  // Because we aren't using short time durations for milestones it's safe to compare with block.timestamp in our case
  // solhint-disable not-rely-on-time

  /// @notice Enumerator FundsReleaseType - release type of funds for a milestone.
  /// @param MilestoneStartDate 0 - funds release after a milestone started;
  /// @param MilestoneEndDate 1 - funds release after a milestone finished.
  enum FundsReleaseType {
    MilestoneStartDate,
    MilestoneEndDate
  }
  /// @notice Enumerator State - state of a milestone.
  /// @param Funding 0 - milestone is funding;
  /// @param Refunding 1 - milestone is refunding.
  enum State {
    Funding,
    Refunding
  }
  /// @notice Enumerator VotingStatus - voting status of a milestone.
  /// @param Active 0 - milestone is active;
  /// @param Suspended 1 - milestone had been suspended;
  /// @param Finished 2 - milestone has been finished by voting.
  enum VotingStatus {
    Active,
    Suspended,
    Finished
  }

  /// @notice Struct Milestone - contain information about milestone.
  /// @param amount amount of funds reserved for this milestone;
  /// @param withdrawnAmount amount of already withdrawn funds from this milestone;
  /// @param startDate start timestamps of milestone;
  /// @param endDate end timestamps of milestone;
  /// @param votingStatus current status of milestone;
  /// @param isCreated has this milestone been created.
  struct Milestone {
    uint256 amount;
    uint256 withdrawnAmount;
    uint64 startDate;
    uint64 endDate;
    VotingStatus votingStatus;
    FundsReleaseType withdrawalStrategy;
    bool isCreated;
  }

  /// @notice Stores the admin role key hash that is used for accessing the withdrawal call.
  /// @return Bytes representing admin role key hash.
  bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");

  /// @notice Stores IERC20 compatible contract that is used for funding this roadmap.
  /// @return Address of a funding contract.
  IERC20 public fundingToken;
  /// @notice Stores voting contract address which has privileged access for some functions of this roadmap.
  /// @return Address of a voting contract.
  address public voting;
  /// @notice Stores refunding contract address which is used to transfer remaining funds in a case of this roadmap refunding.
  /// @return Address of a refunding contract.
  address public refunding;
  /// @notice Stores funds release strategy for this roadmap.
  /// @return 0 - withdrawal is available after a start timestamp of the milestone,
  /// 1 - withdrawal is available after an end timestamp of the milestone.
  FundsReleaseType public fundsReleaseType;
  /// @notice Stores if a roadmap has been refunded.
  /// @return 0 - roadmap have not been refunded,
  /// 1 - roadmap is refunded and most operations are blocked.
  State public state;
  /// @notice Stores amount of locked funds for currently added milestones.
  /// @return Amount of locked funds for currently added milestones.
  uint256 public lockedFunds;
  /// @notice Stores milestone information by a milestone id.
  /// @return amount - amount of funds reserved for this milestone,
  /// withdrawnAmount - amount of already withdrawn funds from this milestone,
  /// startDate - Start timestamps of a milestone,
  /// endDate - End timestamps of a milestone,
  /// votingStatus - current status of a milestone,
  /// isCreated - has this milestone been created.
  mapping(uint256 => Milestone) public milestones;
  /// @notice Stores the address of an ProjectEntity contract.
  /// @return Address of a ProjectEntity based contract.
  ProjectEntity public projectEntity;

  /// @notice Emits when the roadmap has been funded.
  /// @param sender address of a funder;
  /// @param amount funds amount.
  event Funded(address indexed sender, uint256 amount);
  /// @notice Emits when the roadmap is set to be refunded.
  /// @param sender address of a caller;
  /// @param amount amount of funds refunded.
  event Refunded(address indexed sender, uint256 amount);
  /// @notice Emits when funds are withdrawn from the milestone.
  /// @param id milestone id;
  /// @param recipient recipient address for withdrawn funds;
  /// @param amount amount of funds withdrawn.
  event Withdrawn(
    uint256 indexed id,
    address indexed recipient,
    uint256 amount
  );
  /// @notice Emits when refunding address is changed.
  /// @param refunding new refunding address.
  event RefundingContractChanged(address refunding);
  /// @notice Emits when voting contract is changed.
  /// @param voting new voting contract address.
  event VotingContractChanged(address voting);
  /// @notice Emits when funds release strategy is changed.
  /// @param fundsReleaseType new funds release type.
  event FundsReleaseTypeChanged(FundsReleaseType fundsReleaseType);
  /// @notice Emits when milestone is added.
  /// @param id id of an added milestone;
  /// @param amount funds amount to be reserved for an added milestone;
  /// @param startDate start timestamp of an added milestone;
  /// @param endDate end timestamp of an added milestone.
  event MilestoneAdded(
    uint256 indexed id,
    uint256 amount,
    uint64 startDate,
    uint64 endDate
  );
  /// @notice Emits when milestone information is updated.
  /// @param id id of an updated milestone;
  /// @param amount New funds amount to be reserved for an updated milestone;
  /// @param startDate new start timestamp of an updated milestone;
  /// @param endDate new end timestamp of an updated milestone.
  event MilestoneUpdated(
    uint256 indexed id,
    uint256 amount,
    uint64 startDate,
    uint64 endDate
  );
  /// @notice Emits when milestone is removed.
  /// @param id id of a removed milestone.
  event MilestoneRemoved(uint256 indexed id);
  /// @notice Emits when milestone voting is changed.
  /// @param id id of a milestone;
  /// @param votingStatus new voting status of a milestone.
  event MilestoneVotingStatusUpdated(
    uint256 indexed id,
    VotingStatus votingStatus
  );

  modifier onlyVoter() {
    require(msg.sender == voting, "OV");
    _;
  }

  modifier onlyAdminOrVoter() {
    if (msg.sender != voting) {
      require(
        projectEntity.isOwner(msg.sender),
        "Msg.sender is not Admin or Voter"
      );
    }
    _;
  }

  modifier inState(State _state) {
    require(state == _state, "RS");
    _;
  }

  function initialize(
    address _voting,
    address _refunding,
    address _projectEntity,
    IERC20 _fundingToken,
    FundsReleaseType _fundsReleaseType
  ) external initializer {
    require(_voting != address(0), "Address Voting cannot be zero");
    require(_refunding != address(0), "Address Refunding cannot be zero");
    require(
      _projectEntity != address(0),
      "Address ProjectEntity cannot be zero"
    );
    require(
      address(_fundingToken) != address(0),
      "Address FundingToken cannot be zero"
    );

    voting = _voting;
    refunding = _refunding;
    projectEntity = ProjectEntity(_projectEntity);
    fundingToken = _fundingToken;
    fundsReleaseType = _fundsReleaseType;
  }

  /// @notice Change release type of funds for a milestone used in this roadmap.
  /// @param _fundsReleaseType new release type
  function setFundsReleaseType(FundsReleaseType _fundsReleaseType)
    external
    onlyVoter
    inState(State.Funding)
  {
    fundsReleaseType = _fundsReleaseType;
    emit FundsReleaseTypeChanged(_fundsReleaseType);
  }

  /// @notice Fund this roadmap. Allowance for amount of fund tokens should be set prior to this transaction.
  /// @param _funds amount of fund tokens.
  function fundRoadmap(uint256 _funds) external inState(State.Funding) {
    fundingToken.safeTransferFrom(msg.sender, address(this), _funds);
    emit Funded(msg.sender, _funds);
  }

  /// @notice Withdraw funds from a particular milestone. Can be called by a roadmap admin or via voting.
  /// @param _id id of a milestone to withdraw from;
  /// @param _recipient address to send withdrawn funds;
  /// @param _funds amount of fund tokens to withdraw.
  function withdraw(
    uint256 _id,
    address _recipient,
    uint256 _funds
  ) external inState(State.Funding) onlyAdminOrVoter {
    require(milestones[_id].votingStatus != VotingStatus.Suspended, "MSS");
    require(checkIsMilestoneWithdrawable(_id), "MNW");
    require(
      milestones[_id].amount - milestones[_id].withdrawnAmount >= _funds,
      "MF"
    );

    milestones[_id].withdrawnAmount = milestones[_id].withdrawnAmount + _funds;
    lockedFunds -= _funds;
    fundingToken.safeTransfer(_recipient, _funds);
    emit Withdrawn(_id, _recipient, _funds);
  }

  /// @notice Change refunding contract used in this roadmap. Can only be called from a voting contract.
  /// @param _refunding new refunding contract address.
  function setRefundingContract(address _refunding)
    external
    onlyVoter
    inState(State.Funding)
  {
    require(_refunding != address(0), "ZA");
    refunding = _refunding;
    emit RefundingContractChanged(_refunding);
  }

  /// @notice Change voting contract used in this roadmap. Can only be called from a voting contract.
  /// @param _voting new voting contract address.
  function setVotingContract(address _voting)
    external
    onlyVoter
    inState(State.Funding)
  {
    require(_voting != address(0), "ZA");
    voting = _voting;
    emit VotingContractChanged(_voting);
  }

  /// @notice Adds a new milestone. Can only be called from a voting.
  /// @param _id id of a milestone to be added;
  /// @param _amount amount of fund tokens for a milestone to be added;
  /// @param _startDate start timestamps of a milestone to be added;
  /// @param _endDate end timestamps of a milestone to be added.
  function addMilestone(
    uint256 _id,
    uint256 _amount,
    uint64 _startDate,
    uint64 _endDate
  ) external onlyVoter inState(State.Funding) {
    require(!doesMilestoneExist(_id), "ME");
    require(_startDate >= block.timestamp, "MS");
    require(areDatesCorrect(_startDate, _endDate), "DI");
    require(
      fundingToken.balanceOf(address(this)) >= lockedFunds + _amount,
      "RF"
    );

    milestones[_id].amount = _amount;
    milestones[_id].startDate = _startDate;
    milestones[_id].endDate = _endDate;
    milestones[_id].votingStatus = VotingStatus.Active;
    milestones[_id].withdrawalStrategy = fundsReleaseType;
    milestones[_id].isCreated = true;
    lockedFunds += _amount;
    emit MilestoneAdded(_id, _amount, _startDate, _endDate);
  }

  /// @notice Updates information of an already existing milestone. Can only be called from a voting contract.
  /// @param _id id of a milestone to update;
  /// @param _amount new amount of reserved fund tokens amount for this milestone, if started should be bigger than withdrawnAmount;
  /// @param _startDate new start timestamp for this milestone, if started _startDate couldn't be updated;
  /// @param _endDate new end timestamp for this milestone, if started should be bigger than now.
  function updateMilestone(
    uint256 _id,
    uint256 _amount,
    uint64 _startDate,
    uint64 _endDate
  ) external onlyVoter inState(State.Funding) {
    require(doesMilestoneExist(_id), "MNE");
    if (milestones[_id].amount < _amount) {
      require(
        fundingToken.balanceOf(address(this)) >=
          _amount - milestones[_id].amount + lockedFunds,
        "RF"
      );
    }

    bool isStarted = isMilestoneStarted(_id);

    if (isStarted) {
      require(_startDate == milestones[_id].startDate, "MS");
      require(_endDate > block.timestamp, "DI");
      require(_amount >= milestones[_id].withdrawnAmount, "IFA");
    } else {
      require(areDatesCorrect(_startDate, _endDate), "DI");
      milestones[_id].startDate = _startDate;
    }

    lockedFunds -= milestones[_id].amount - milestones[_id].withdrawnAmount;
    lockedFunds += _amount - milestones[_id].withdrawnAmount;
    milestones[_id].amount = _amount;

    milestones[_id].endDate = _endDate;
    emit MilestoneUpdated(_id, _amount, _startDate, _endDate);
  }

  /// @notice Removes milestone from a roadmap. Can only be called from a voting contract.
  /// @param _id id of a milestone to remove.
  function removeMilestone(uint256 _id)
    external
    onlyVoter
    inState(State.Funding)
  {
    require(doesMilestoneExist(_id), "MNE");
    require(!isMilestoneStarted(_id), "MS");

    lockedFunds -= milestones[_id].amount;
    delete milestones[_id];
    emit MilestoneRemoved(_id);
  }

  /// @notice Updates voting status of a milestone. Can only be called from a voting contract.
  /// Currently supported transitions of a voting status - Active(0) -> Suspended(1), Active(0) -> Finished(2)
  /// @param _id id of a milestone to update;
  /// @param _votingStatus new voting status for a milestone.
  function updateMilestoneVotingStatus(uint256 _id, VotingStatus _votingStatus)
    external
    onlyVoter
    inState(State.Funding)
  {
    require(doesMilestoneExist(_id), "MNE");
    require(isMilestoneStarted(_id), "MNS");

    require(
      isVotingStatusTransitionValid(
        milestones[_id].votingStatus,
        _votingStatus
      ),
      "VI"
    );

    if (_votingStatus == VotingStatus.Suspended)
      lockedFunds -= milestones[_id].amount - milestones[_id].withdrawnAmount;

    milestones[_id].votingStatus = _votingStatus;
    emit MilestoneVotingStatusUpdated(_id, _votingStatus);
  }

  /// @notice Updates roadmap state. Can only be called from a voting contract.
  /// Currently supported transitions of a roadmap state - Funding(1) -> Refunding(0).
  /// @param _state new roadmap state.
  function updateRoadmapState(State _state)
    external
    onlyVoter
    inState(State.Funding)
  {
    if (_state == State.Refunding) {
      state = _state;
      uint256 balance = fundingToken.balanceOf(address(this));
      refund(balance);
    }
  }

  /// @notice Check if a particular milestone is withdrawable according to roadmap funds release strategy.
  /// @param _id id of a milestone.
  /// @return Boolean representing if a milestone is withdrawable.
  function checkIsMilestoneWithdrawable(uint256 _id)
    public
    view
    returns (bool)
  {
    Milestone storage milestone = milestones[_id];

    if (milestone.withdrawalStrategy == FundsReleaseType.MilestoneStartDate) {
      return milestone.startDate <= block.timestamp;
    } else if (
      milestone.withdrawalStrategy == FundsReleaseType.MilestoneEndDate
    ) {
      return milestone.endDate <= block.timestamp;
    }

    return false;
  }

  function doesMilestoneExist(uint256 _id) public view returns (bool) {
    return milestones[_id].isCreated;
  }

  function refund(uint256 _funds) private inState(State.Refunding) {
    fundingToken.safeTransfer(refunding, _funds);
    emit Refunded(msg.sender, _funds);
  }

  function areDatesCorrect(uint64 _startDate, uint64 _endDate)
    private
    pure
    returns (bool)
  {
    return _endDate > _startDate && _startDate > 0;
  }

  function isMilestoneStarted(uint256 _id) private view returns (bool) {
    return milestones[_id].startDate < block.timestamp;
  }

  function isVotingStatusTransitionValid(VotingStatus from, VotingStatus to)
    internal
    pure
    returns (bool)
  {
    return
      (from == VotingStatus.Active && to == VotingStatus.Finished) ||
      (from == VotingStatus.Active && to == VotingStatus.Suspended);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./interfaces/IVotingStrategy.sol";

/// @title Contract for storing proposals, voting and executing them.
contract Voting is Initializable, ReentrancyGuardUpgradeable {
  // Because we aren't using short time durations for milestones it's safe to compare with block.timestamp in our case
  // solhint-disable not-rely-on-time

  /// @notice Struct Option - contain information about option.
  /// @param callTargets options addresses which would be used for a call on execution;
  /// @param callDataList options call data which would be used for a call on execution;
  /// @param votingPower voting power for options;
  /// @param votingPowerByAddress voting power of a vote by voter.
  struct Option {
    address[] callTargets;
    bytes[] callDataList;
    uint256 votingPower;
    mapping(address => uint256) votingPowerByAddress;
  }
  /// @notice Struct Proposal - contain information about a proposal.
  /// @param createdAt timestamp of a proposal creation time;
  /// @param overallVotingPower total voting power in this proposal;
  /// @param overallVoters total voters in this proposal;
  /// @param votingDelay duration of a window after the proposal is created before the voting stage starts;
  /// @param votingDuration duration of a voting stage in this proposal;
  /// @param executionDelay duration of a window after the voting stage before the execution stage starts;
  /// @param minConsensusVotersCount minimal amount of voters in this proposal for it to be executable;
  /// @param minConsensusVotingPower minimal amount of voting power in this proposal for it to be executable;
  /// @param options array of options in this proposal;
  /// @param selectedOptions selected option by voter;
  /// @param executed if this proposal was already executed.
  struct Proposal {
    uint256 createdAt;
    uint256 overallVotingPower;
    uint256 overallVoters;
    uint64 votingDelay;
    uint64 votingDuration;
    uint64 executionDelay;
    uint64 minConsensusVotersCount;
    uint256 minConsensusVotingPower;
    Option[] options;
    mapping(address => uint256) selectedOptions;
    bool executed;
  }
  /// @notice Enumerator ProposalTimeInterval - time interval for proposal.
  /// @param LockBeforeVoting 0 - proposal locked before voting;
  /// @param Voting 1 - proposal ready for voting;
  /// @param LockBeforeExecution 2 - proposal locked before execution;
  /// @param Execution 3 - proposal can be executed;
  /// @param AfterExecution 4 - proposal has been executed.
  enum ProposalTimeInterval {
    LockBeforeVoting,
    Voting,
    LockBeforeExecution,
    Execution,
    AfterExecution
  }

  /// @notice Stores the duration of an execution stage.
  /// @return Seconds that are the duration of an execution stage.
  uint256 public constant EXECUTION_DURATION = 7 days;

  /// @notice Stores a voting strategy used to check vote validity.
  /// @return Address of a voting strategy used to check vote validity.
  IVotingStrategy public votingStrategy;
  /// @notice Stores a IPFS hash containing additional information about this voting.
  /// @return Bytes representing the IPFS hash containing additional information about this voting.
  bytes public ipfsVotingDetails;
  /// @notice Stores a roadmap this voting is related to.
  /// @return Address of a roadmap this voting is related to.
  address public roadmap;
  /// @notice Stores duration of a window after the proposal is created before the voting stage starts.
  /// @return Seconds that are the duration of a window after the proposal is created before the voting stage starts.
  uint64 public timeLockBeforeVoting;
  /// @notice Stores duration of a voting stage.
  /// @return Seconds that are the duration of a voting stage.
  uint64 public votingDuration;
  /// @notice Stores duration of a window after the voting stage before the execution stage starts.
  /// @return Seconds that are the duration of a window after the voting stage before the execution stage starts.
  uint64 public timeLockBeforeExecution;
  /// @notice Stores minimal amount of voters in a proposal for it to be executable.
  /// @return Minimal amount of voters in a proposal for it to be executable.
  uint64 public minConsensusVotersCount;
  /// @notice Stores minimal amount of voting power in a proposal for it to be executable.
  /// @return Minimal voting power of voters in a proposal for it to be executable.
  uint256 public minConsensusVotingPower;
  /// @notice Stores proposal information by a proposal id.
  /// @return createdAt - timestamp of a proposal creation time,
  /// overallVotingPower - total voting power in this proposal,
  /// overallVoters - total voters in this proposal,
  /// options - array of options in this proposal,
  /// selectedOptions - selected option by voter,
  /// executed - if this proposal was already executed.
  Proposal[] public proposals;

  /// @notice Emits on each proposal creation.
  /// @param id id of a created proposal.
  event ProposalAdded(uint256 indexed id);
  /// @notice Emits on each vote.
  /// @param proposalId id of a voted proposal;
  /// @param optionId id of a voted option;
  /// @param voter address of a voter;
  /// @param votingPower voting power of a vote;
  /// @param ipfsHash IPFS hash with additional information about the vote.
  event ProposalVoted(
    uint256 indexed proposalId,
    uint256 indexed optionId,
    address indexed voter,
    uint256 votingPower,
    bytes ipfsHash
  );
  /// @notice Emits on a cancel of the vote.
  /// @param proposalId id of a proposal for the cancelled vote;
  /// @param optionId id of an option for the cancelled vote;
  /// @param voter Address of a voter for the cancelled vote;
  /// @param votingPower Voting power of a cancelled vote.
  event ProposalVoteCancelled(
    uint256 indexed proposalId,
    uint256 indexed optionId,
    address indexed voter,
    uint256 votingPower
  );
  /// @notice Emits on a successful execution of the proposal.
  /// @param proposalId id of an executed proposal;
  /// @param optionId id of an executed option.
  event ProposalExecuted(uint256 indexed proposalId, uint256 indexed optionId);
  /// @notice Emits when IPFS hash is changed.
  /// @param ipfsVotingDetails new IPFS hash.
  event IpfsVotingDetailsChanged(bytes ipfsVotingDetails);
  /// @notice Emits when lock time before voting is changed.
  /// @param timeLockBeforeVoting new lock time.
  event TimeLockBeforeVotingChanged(uint64 timeLockBeforeVoting);
  /// @notice Emits when duration of a voting stage is changed.
  /// @param votingDuration new voting duration.
  event VotingDurationChanged(uint64 votingDuration);
  /// @notice Emits when lock time before execution stage is changed.
  /// @param timeLockBeforeExecution new lock time.
  event TimeLockBeforeExecutionChanged(uint64 timeLockBeforeExecution);
  /// @notice Emits when minimal amount of voters is changed.
  /// @param minConsensusVotersCount new minimal amount.
  event MinConsensusVotersCountChanged(uint64 minConsensusVotersCount);
  /// @notice Emits when minimal amount of voting power is changed.
  /// @param minConsensusVotingPower new voting power.
  event MinConsensusVotingPowerChanged(uint256 minConsensusVotingPower);

  modifier inProposalTimeInterval(
    uint256 proposalId,
    ProposalTimeInterval timeInterval
  ) {
    require(proposalExists(proposalId), "PNE");
    require(proposalTimeInterval(proposalId) == timeInterval, "PT");
    _;
  }

  modifier onlyVoting() {
    require(msg.sender == address(this), "NV");
    _;
  }

  function initialize(
    address _roadmap,
    IVotingStrategy _votingStrategy,
    bytes calldata _ipfsVotingDetails,
    uint64 _timeLockBeforeVoting,
    uint64 _votingDuration,
    uint64 _timeLockBeforeExecution,
    uint64 _minConsensusVotersCount,
    uint256 _minConsensusVotingPower
  ) external initializer {
    __ReentrancyGuard_init();

    roadmap = _roadmap;
    votingStrategy = _votingStrategy;
    ipfsVotingDetails = _ipfsVotingDetails;
    timeLockBeforeVoting = _timeLockBeforeVoting;
    votingDuration = _votingDuration;
    timeLockBeforeExecution = _timeLockBeforeExecution;
    minConsensusVotersCount = _minConsensusVotersCount;
    minConsensusVotingPower = _minConsensusVotingPower;
  }

  /// @notice Change a IPFS hash containing additional information about this voting.
  /// @param _ipfsVotingDetails new IPFS hash
  function setIpfsVotingDetails(bytes calldata _ipfsVotingDetails)
    external
    onlyVoting
  {
    ipfsVotingDetails = _ipfsVotingDetails;
    emit IpfsVotingDetailsChanged(_ipfsVotingDetails);
  }

  /// @notice Change duration of a window after the proposal is created before the voting stage starts.
  /// @param _timeLockBeforeVoting new window duration
  function setTimeLockBeforeVoting(uint64 _timeLockBeforeVoting)
    external
    onlyVoting
  {
    timeLockBeforeVoting = _timeLockBeforeVoting;
    emit TimeLockBeforeVotingChanged(_timeLockBeforeVoting);
  }

  /// @notice Change duration of a voting stage.
  /// @param _votingDuration new voting duration
  function setVotingDuration(uint64 _votingDuration) external onlyVoting {
    votingDuration = _votingDuration;
    emit VotingDurationChanged(_votingDuration);
  }

  /// @notice Change duration of a window after the voting stage before the execution stage starts.
  /// @param _timeLockBeforeExecution new window duration
  function setTimeLockBeforeExecution(uint64 _timeLockBeforeExecution)
    external
    onlyVoting
  {
    timeLockBeforeExecution = _timeLockBeforeExecution;
    emit TimeLockBeforeExecutionChanged(_timeLockBeforeExecution);
  }

  /// @notice Change minimal amount of voters in a proposal for it to be executable.
  /// @param _minConsensusVotersCount new minimal amount
  function setMinConsensusVotersCount(uint64 _minConsensusVotersCount)
    external
    onlyVoting
  {
    minConsensusVotersCount = _minConsensusVotersCount;
    emit MinConsensusVotersCountChanged(_minConsensusVotersCount);
  }

  /// @notice Change minimal amount of voting power in a proposal for it to be executable.
  /// @param _minConsensusVotingPower new minimal amount
  function setMinConsensusVotingPower(uint256 _minConsensusVotingPower)
    external
    onlyVoting
  {
    minConsensusVotingPower = _minConsensusVotingPower;
    emit MinConsensusVotingPowerChanged(_minConsensusVotingPower);
  }

  /// @notice Creates a proposal.
  /// @dev Creates an empty option with id 0, options passed in callTargets and callDataList get indecies equal
  /// to their index in corresponding arrays + 1.
  /// @param callTargets list of options each containing addresses which would be used for a call on execution;
  /// @param callDataList list of options each containing call data lists which would be used for a call on execution.
  function addProposal(
    address[][] calldata callTargets,
    bytes[][] calldata callDataList
  ) external {
    require(callTargets.length == callDataList.length, "AL");
    uint256 optionsCount = callTargets.length;
    require(optionsCount > 0, "OZ");

    Proposal storage proposal = proposals.push();
    proposal.createdAt = block.timestamp;
    proposal.votingDelay = timeLockBeforeVoting;
    proposal.votingDuration = votingDuration;
    proposal.executionDelay = timeLockBeforeExecution;
    proposal.minConsensusVotersCount = minConsensusVotersCount;
    proposal.minConsensusVotingPower = minConsensusVotingPower;
    proposal.options.push(); // empty option

    for (uint256 i = 0; i < optionsCount; i++) {
      Option storage option = proposal.options.push();
      require(callTargets[i].length == callDataList[i].length, "OAL");
      option.callTargets = callTargets[i];
      for (uint256 j = 0; j < callDataList[i].length; j++) {
        option.callDataList.push(callDataList[i][j]);
      }
    }

    emit ProposalAdded(proposals.length - 1);
  }

  /// @notice Votes for an option in the proposal. Supports revoting if a vote already have been submitted by a caller address.
  /// @param proposalId id of a voted proposal;
  /// @param optionId id of a voted option;
  /// @param votingPower Voting power of a vote;
  /// @param ipfsHash Ipfs hash with additional information about the vote;
  /// @param argumentsU256 Array of uint256 which should be used to pass signature information;
  /// @param argumentsB32 Array of bytes32 which should be used to pass signature information.
  function vote(
    uint256 proposalId,
    uint256 optionId,
    uint256 votingPower,
    bytes calldata ipfsHash,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  ) external inProposalTimeInterval(proposalId, ProposalTimeInterval.Voting) {
    require(
      votingStrategy.isValid(
        IVotingStrategy.Vote({
          voter: msg.sender, // shouldn't be removed as it prevents votes reusage by other actors
          roadmap: roadmap,
          proposalId: proposalId,
          optionId: optionId,
          votingPower: votingPower,
          ipfsHash: ipfsHash
        }),
        argumentsU256,
        argumentsB32
      ),
      "VI"
    );
    require(votingPower > 0, "VPZ");

    Proposal storage proposal = proposals[proposalId];
    require(optionId < proposal.options.length, "ONE");

    {
      (bool previousVoteExists, uint256 previousOptionId) = getSelectedOption(
        proposal
      );
      require(!previousVoteExists || previousOptionId != optionId, "OAV");
      if (previousVoteExists) {
        cancelPreviousVote(proposal, proposalId, previousOptionId);
      }
    }

    setSelectedOption(proposal, optionId);
    proposal.overallVotingPower += votingPower;
    proposal.overallVoters += 1;

    {
      Option storage option = proposal.options[optionId];
      option.votingPower += votingPower;
      option.votingPowerByAddress[msg.sender] = votingPower;
    }

    emit ProposalVoted(proposalId, optionId, msg.sender, votingPower, ipfsHash);
  }

  /// @notice Cancels a vote previously submitted by a caller address.
  /// @param proposalId id of a proposal to cancel vote for.
  function cancelVote(uint256 proposalId)
    external
    inProposalTimeInterval(proposalId, ProposalTimeInterval.Voting)
  {
    Proposal storage proposal = proposals[proposalId];
    (bool exists, uint256 previousOptionId) = getSelectedOption(proposal);
    require(exists, "VNE");

    cancelPreviousVote(proposal, proposalId, previousOptionId);
  }

  /// @notice Execute an option in a proposal. Would fail if this option doesn't have a maximum voting power in this proposal.
  /// @param proposalId id of an executed proposal;
  /// @param optionId id of an executed option.
  function execute(uint256 proposalId, uint256 optionId)
    external
    nonReentrant
    inProposalTimeInterval(proposalId, ProposalTimeInterval.Execution)
  {
    (bool haveMax, uint256 maxOptionId) = maxVotingPowerOption(proposalId);
    require(haveMax && optionId == maxOptionId, "ONM");

    Proposal storage proposal = proposals[proposalId];
    require(!proposal.executed, "PE");
    require(
      proposal.overallVotingPower >= proposal.minConsensusVotingPower,
      "PPE"
    );
    require(proposal.overallVoters >= proposal.minConsensusVotersCount, "PCE");
    Option storage option = proposal.options[optionId];

    proposal.executed = true;

    uint256 calls = option.callTargets.length;
    for (uint256 i = 0; i < calls; i++) {
      address callTarget = option.callTargets[i];
      bytes storage callData = option.callDataList[i];
      (bool success, bytes memory data) = callTarget.call(callData); // solhint-disable-line avoid-low-level-calls
      require(success, getRevertMsg(data));
    }

    emit ProposalExecuted(proposalId, optionId);
  }

  /// @notice Returns options count for a particular proposal.
  /// @param proposalId id of a proposal.
  /// @return Options count.
  function getOptionCount(uint256 proposalId) external view returns (uint256) {
    require(proposalExists(proposalId), "PNE");
    return proposals[proposalId].options.length;
  }

  /// @notice Returns information about options for a particular proposal.
  /// @param proposalId id of a proposal.
  /// @return callTargets List of options addresses which would be used for a call on execution. Option id is index,
  /// callDataList List of options call data which would be used for a call on execution. Option id is index,
  /// votingPowers List of voting power for options. Option id is index.
  function getOptions(uint256 proposalId)
    external
    view
    returns (
      address[][] memory callTargets,
      bytes[][] memory callDataList,
      uint256[] memory votingPowers
    )
  {
    require(proposalExists(proposalId), "PNE");
    Proposal storage proposal = proposals[proposalId];
    uint256 optionsCount = proposal.options.length;
    callTargets = new address[][](optionsCount);
    callDataList = new bytes[][](optionsCount);
    votingPowers = new uint256[](optionsCount);

    for (uint256 i = 0; i < optionsCount; i++) {
      Option storage option = proposal.options[i];
      callTargets[i] = option.callTargets;
      callDataList[i] = option.callDataList;
      votingPowers[i] = option.votingPower;
    }
  }

  /// @notice Returns total count of created proposals.length.
  /// @return Total count of proposals.
  function proposalsCount() external view returns (uint256) {
    return proposals.length;
  }

  /// @notice Returns if a particular proposal exists.
  /// @param id id of a proposal.
  /// @return True if a proposal exists.
  function proposalExists(uint256 id) public view returns (bool) {
    return id < proposals.length;
  }

  /// @notice Returns current time interval for a particular proposal.
  /// @param id id of a proposal.
  /// @return Current time interval for a proposal.
  function proposalTimeInterval(uint256 id)
    public
    view
    returns (ProposalTimeInterval)
  {
    uint256 timeElapsed = block.timestamp - proposals[id].createdAt;
    if (timeElapsed < proposals[id].votingDelay) {
      return ProposalTimeInterval.LockBeforeVoting;
    }

    timeElapsed -= proposals[id].votingDelay;
    if (timeElapsed < proposals[id].votingDuration) {
      return ProposalTimeInterval.Voting;
    }

    timeElapsed -= proposals[id].votingDuration;
    if (timeElapsed < proposals[id].executionDelay) {
      return ProposalTimeInterval.LockBeforeExecution;
    }

    timeElapsed -= proposals[id].executionDelay;
    if (timeElapsed < EXECUTION_DURATION) {
      return ProposalTimeInterval.Execution;
    } else {
      return ProposalTimeInterval.AfterExecution;
    }
  }

  /// @notice Returns information about option with a maximum voting power for a particular proposal.
  /// @param proposalId id of a proposal.
  /// @return haveMax Does such option exists,
  /// maxOptionId id of a such option.
  function maxVotingPowerOption(uint256 proposalId)
    public
    view
    returns (bool haveMax, uint256 maxOptionId)
  {
    Proposal storage proposal = proposals[proposalId];
    uint256 optionsCount = proposal.options.length;
    uint256 maxVotingPower = 0;
    for (uint256 i = 0; i < optionsCount; i++) {
      Option storage option = proposal.options[i];
      if (option.votingPower > maxVotingPower) {
        maxVotingPower = option.votingPower;
        maxOptionId = i;
        haveMax = true;
      } else if (option.votingPower == maxVotingPower) {
        haveMax = false;
      }
    }
  }

  function getSelectedOption(Proposal storage proposal)
    private
    view
    returns (bool exists, uint256 optionId)
  {
    uint256 stored = proposal.selectedOptions[msg.sender];
    if (stored > 0) {
      return (true, stored - 1);
    } else {
      return (false, 0);
    }
  }

  function setSelectedOption(Proposal storage proposal, uint256 optionId)
    private
  {
    proposal.selectedOptions[msg.sender] = optionId + 1;
  }

  function cancelPreviousVote(
    Proposal storage proposal,
    uint256 proposalId,
    uint256 previousOptionId
  ) private {
    Option storage previousOption = proposal.options[previousOptionId];
    uint256 previousVotingPower = previousOption.votingPowerByAddress[
      msg.sender
    ];
    previousOption.votingPower -= previousVotingPower;
    delete previousOption.votingPowerByAddress[msg.sender];
    delete proposal.selectedOptions[msg.sender];

    proposal.overallVotingPower -= previousVotingPower;
    proposal.overallVoters -= 1;

    emit ProposalVoteCancelled(
      proposalId,
      previousOptionId,
      msg.sender,
      previousVotingPower
    );
  }

  function getRevertMsg(bytes memory returnData)
    internal
    pure
    returns (string memory)
  {
    if (returnData.length < 68) return "Transaction reverted silently";

    // solhint-disable-next-line no-inline-assembly
    assembly {
      returnData := add(returnData, 0x04)
    }
    return abi.decode(returnData, (string));
  }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./interfaces/IWhiteList.sol";

/// @title The contract keep addresses of all contracts which are using on MilestoneBased platform.
/// @dev It is used by sMILE token for transactions restriction.
contract WhiteList is IWhiteList, AccessControl {
  using EnumerableSet for EnumerableSet.AddressSet;
  /// @notice Stores the factory role key hash.
  /// @return Bytes representing fectory role key hash.
  bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");

  /// @notice Stores a set of all contracts which are using on MilestoneBased platform.
  EnumerableSet.AddressSet private _whiteList;

  modifier onlyAdminOrFactory() {
    require(
      hasRole(DEFAULT_ADMIN_ROLE, msg.sender) ||
        hasRole(FACTORY_ROLE, msg.sender),
      "The caller must be admin or factory contract"
    );
    _;
  }

  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  /// @notice Add new address to the contract.
  /// @param newAddress address to add.
  function addNewAddress(address newAddress) public onlyAdminOrFactory {
    _whiteList.add(newAddress);
    emit AddedNewAddress(newAddress);
  }

  /// @notice Add new addresses to the contract.
  /// @param newAddresses array of new addresses.
  function addNewAddressesBatch(address[] memory newAddresses)
    external
    onlyAdminOrFactory
  {
    for (uint256 i = 0; i < newAddresses.length; i++) {
      _whiteList.add(newAddresses[i]);
      emit AddedNewAddress(newAddresses[i]);
    }
  }

  /// @notice Remove passed address from the contract.
  /// @param invalidAddress address for removing.
  function removeAddress(address invalidAddress) public onlyAdminOrFactory {
    _whiteList.remove(invalidAddress);
    emit RemovedAddress(invalidAddress);
  }

  /// @notice Remove passed addresses from the contract.
  /// @param invalidAddresses array of addresses to remove.
  function removeAddressesBatch(address[] memory invalidAddresses)
    external
    onlyAdminOrFactory
  {
    for (uint256 i = 0; i < invalidAddresses.length; i++) {
      _whiteList.remove(invalidAddresses[i]);
      emit RemovedAddress(invalidAddresses[i]);
    }
  }

  /// @notice Return all addresses of MB platform.
  /// @return White list addresses array.
  function getAllAddresses() external view returns (address[] memory) {
    address[] memory addresses = new address[](_whiteList.length());
    for (uint256 i = 0; i < _whiteList.length(); i++) {
      addresses[i] = _whiteList.at(i);
    }
    return addresses;
  }

  /// @notice Return true if contract has such address, and false if doesn’t.
  /// @param accountAddress address to check.
  /// @return The presence of the address in the list.
  function isValidAddress(address accountAddress) external view returns (bool) {
    return _whiteList.contains(accountAddress);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

interface IEntityFactory {
  enum EntityType {
    UserEntity,
    CompanyEntity,
    ProjectEntity
  }
  event UpdatedUpgradeableBeacon(address newBeacon, EntityType entityType);
  event CreatedNewEntity(
    uint256 indexed id,
    address indexed creator,
    address entity,
    EntityType entityType
  );
  event UpdatedWhiteList(address oldWhiteList, address newWhiteList);

  event UpdatedEntityStrategy(address oldStrategy, address newStrategy);

  event AddedOwnerOfEntity(address newOwner);

  event RemovedOwnerOfEntity(address owner);

  function updateUpgradeableBeacon(address newBeacon, EntityType entityType)
    external;

  function updateWhiteList(address newWhiteList) external;

  function updatedStrategy(address newEntityStrategy) external;

  function createUserEntity(
    uint256 id,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  ) external returns (address);

  function createCompanyEntity(
    uint256 id,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  ) external returns (address);

  function createProjectEntity(
    uint256 id,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  ) external returns (address);

  function addUser(address entityOwner) external;

  function removeUser(address entityOwner) external;

  function isOwnerOfUserEntity(address user) external view returns (bool);

  function getEntityType(address entity) external view returns (uint256);

  function getUserEntityOfOwner(address owner) external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeacon {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the virtual {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    /**
     * @dev This is a virtual function that should be overriden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback () external payable virtual {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive () external payable virtual {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overriden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "../beacon/IBeacon.sol";
import "../../utils/Address.sol";
import "../../utils/StorageSlot.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967Upgrade {
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallSecure(address newImplementation, bytes memory data, bool forceCall) internal {
        address oldImplementation = _getImplementation();

        // Initial upgrade and setup call
        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }

        // Perform rollback test if not already in progress
        StorageSlot.BooleanSlot storage rollbackTesting = StorageSlot.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            // Trigger rollback using upgradeTo from the new implementation
            rollbackTesting.value = true;
            Address.functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature(
                    "upgradeTo(address)",
                    oldImplementation
                )
            );
            rollbackTesting.value = false;
            // Check rollback was effective
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            // Finally reset to the new implementation and log the upgrade
            _setImplementation(newImplementation);
            emit Upgraded(newImplementation);
        }
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(address newBeacon, bytes memory data, bool forceCall) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(
            Address.isContract(newBeacon),
            "ERC1967: new beacon is not a contract"
        );
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
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

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./UserEntity.sol";
import "./CompanyEntity.sol";
import "./ProjectEntity.sol";
import "./interfaces/IWhiteList.sol";
import "./interfaces/IEntityFactory.sol";
import "./interfaces/IEntityStrategy.sol";

/// @title A factory for entity deployment.
/// @dev Contains upgradable beacon proxies of other contracts for a Dapp.
contract EntityFactory is IEntityFactory, OwnableUpgradeable {
  /// @notice Stores the address of an upgradable beacon proxy for a user entity contract.
  /// @return Address of an upgradable beacon proxy for a user entity contract.
  UpgradeableBeacon public userEntityBeacon;
  /// @notice Stores the address of an upgradable beacon proxy for a company entity contract.
  /// @return Address of an upgradable beacon proxy for a company entity contract.
  UpgradeableBeacon public companyEntityBeacon;
  /// @notice Stores the address of an upgradable beacon proxy for a project entity contract.
  /// @return Address of an upgradable beacon proxy for a project entity contract.
  UpgradeableBeacon public projectEntityBeacon;
  /// @notice Stores a entity strategy used to check entity validity.
  /// @return Address of a entity strategy used to check entity validity.
  IEntityStrategy public entityStrategy;

  address public swapMile;

  address public mileToken;

  address public sMileToken;

  address public milestoneBased;

  IWhiteList public whiteList;

  /// @notice Stores if a particular address is a entity created by this factory.
  /// @return Boolean value which is true if provided address is a entity created by this factory.
  mapping(address => bool) public isEntityByAddress;
  /// @notice Stores if a particular address is a user entity created by this factory.
  /// @return Boolean value which is true if provided address is a user entity.
  mapping(address => bool) public usersEntities;
  /// @notice Stores if a particular address is a company entity created by this factory.
  /// @return Boolean value which is true if provided address is a company entity.
  mapping(address => bool) public companiesEntities;
  /// @notice Stores if a particular address is a project entity created by this factory.
  /// @return Boolean value which is true if provided address is a project entity.
  mapping(address => bool) public projectsEntities;
  /// @notice Stores if a particular address is the owner of user entity.
  /// @return Address of user entity which belongs to provided address.
  mapping(address => address) public ownersOfUserEntity;

  modifier onlyUserEntity() {
    require(
      usersEntities[_msgSender()],
      "EntityFactory: caller is not the userEntity"
    );
    _;
  }

  modifier onlyValidSignature(
    address entityOwner,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  ) {
    require(
      entityStrategy.isValid(
        IEntityStrategy.Entity({
          owner: entityOwner,
          swapMile: swapMile,
          mileToken: mileToken,
          sMileToken: sMileToken,
          entityFactory: address(this)
        }),
        deadline,
        argumentsU256,
        argumentsB32
      ),
      "Invalid signature"
    );
    _;
  }

  /// @param userEntityBeacon_ user entity upgradable beacon proxy address;
  /// @param companyEntityBeacon_ company entity upgradable beacon proxy address;
  /// @param projectEntityBeacon_ project entity upgradable beacon proxy address;
  /// @param entityStrategy_ address of entity voting strategy;
  /// @param swapMile_ address of SwapMILE contract;
  /// @param mileToken_ address of MILE token;
  /// @param sMileToken_ address of sMILE token;
  /// @param whiteList_ address of white list contract.
  /// @param milestoneBased_ ddress of milestoneBased contract.
  function initialize(
    UpgradeableBeacon userEntityBeacon_,
    UpgradeableBeacon companyEntityBeacon_,
    UpgradeableBeacon projectEntityBeacon_,
    IEntityStrategy entityStrategy_,
    address swapMile_,
    address mileToken_,
    address sMileToken_,
    address whiteList_,
    address milestoneBased_
  ) external initializer {
    __Ownable_init();
    require(
      address(userEntityBeacon_) != address(0) &&
        address(companyEntityBeacon_) != address(0) &&
        address(projectEntityBeacon_) != address(0),
      "Entity's Upgradeable Beacon address cannot be zero"
    );
    require(
      address(entityStrategy_) != address(0),
      "EntityStrategy address cannot be zero"
    );
    require(swapMile_ != address(0), "SwapMILE address cannot be zero");
    require(
      mileToken_ != address(0) && sMileToken_ != address(0),
      "Token addresses cannot be zero"
    );
    require(whiteList_ != address(0), "WhiteList address cannot be zero");
    require(
      milestoneBased_ != address(0),
      "MilestoneBased address cannot be zero"
    );

    userEntityBeacon = userEntityBeacon_;
    companyEntityBeacon = companyEntityBeacon_;
    projectEntityBeacon = projectEntityBeacon_;
    entityStrategy = entityStrategy_;
    swapMile = swapMile_;
    mileToken = mileToken_;
    sMileToken = sMileToken_;
    whiteList = IWhiteList(whiteList_);
    milestoneBased = milestoneBased_;
  }

  /// @dev Owner set new address of Entity’s Upgradeable Beacon contract.
  /// @param newBeacon address of new Upgradeable Beacon contract;
  /// @param entityType the type of contract that needs to be changed.
  function updateUpgradeableBeacon(address newBeacon, EntityType entityType)
    external
    onlyOwner
  {
    require(
      newBeacon != address(0),
      "Entity's Upgradeable Beacon address cannot be zero"
    );
    if (entityType == EntityType.UserEntity) {
      userEntityBeacon = UpgradeableBeacon(newBeacon);
    } else if (entityType == EntityType.CompanyEntity) {
      companyEntityBeacon = UpgradeableBeacon(newBeacon);
    } else {
      projectEntityBeacon = UpgradeableBeacon(newBeacon);
    }
    emit UpdatedUpgradeableBeacon(newBeacon, entityType);
  }

  /// @dev Owner set new address of WhiteList contract.
  /// @param newWhiteList new address of WhiteList contract.
  function updateWhiteList(address newWhiteList) external onlyOwner {
    require(newWhiteList != address(0), "WhiteList address cannot be zero");
    address oldWhiteList = address(whiteList);
    whiteList = IWhiteList(newWhiteList);

    emit UpdatedWhiteList(oldWhiteList, newWhiteList);
  }

  function updatedStrategy(address newEntityStrategy) external onlyOwner {
    require(newEntityStrategy != address(0), "Strategy address cannot be zero");
    address oldEntityStrategy = address(entityStrategy);
    entityStrategy = IEntityStrategy(newEntityStrategy);
    emit UpdatedEntityStrategy(oldEntityStrategy, newEntityStrategy);
  }

  /// @notice Creates a user entity.
  /// @param id Id of entity sended from BE;
  /// @param deadline Signature deadline;
  /// @param argumentsU256 Array of uint256 which should be used to pass signature information;
  /// @param argumentsB32 Array of bytes32 which should be used to pass signature information;
  /// @return the address of the created proxy.
  function createUserEntity(
    uint256 id,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  )
    external
    onlyValidSignature(msg.sender, deadline, argumentsU256, argumentsB32)
    returns (address)
  {
    require(
      ownersOfUserEntity[msg.sender] == address(0),
      "The caller has already created a UserEntity"
    );

    BeaconProxy entity = new BeaconProxy(address(userEntityBeacon), "");

    UserEntity(address(entity)).initialize(
      msg.sender,
      swapMile,
      mileToken,
      sMileToken,
      address(this)
    );
    whiteList.addNewAddress(address(entity));
    isEntityByAddress[address(entity)] = true;
    usersEntities[address(entity)] = true;
    ownersOfUserEntity[msg.sender] = address(entity);
    emit CreatedNewEntity(
      id,
      msg.sender,
      address(entity),
      EntityType.UserEntity
    );

    return address(entity);
  }

  /// @notice Creates a company entity.
  /// @param id Id of entity sended from BE;
  /// @param deadline Signature deadline;
  /// @param argumentsU256 Array of uint256 which should be used to pass signature information;
  /// @param argumentsB32 Array of bytes32 which should be used to pass signature information;
  /// @return the address of the created proxy.
  function createCompanyEntity(
    uint256 id,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  )
    external
    onlyUserEntity
    onlyValidSignature(msg.sender, deadline, argumentsU256, argumentsB32)
    returns (address)
  {
    BeaconProxy entity = new BeaconProxy(address(companyEntityBeacon), "");

    CompanyEntity(address(entity)).initialize(
      msg.sender,
      swapMile,
      mileToken,
      sMileToken,
      address(this)
    );

    whiteList.addNewAddress(address(entity));
    isEntityByAddress[address(entity)] = true;
    companiesEntities[address(entity)] = true;
    emit CreatedNewEntity(
      id,
      msg.sender,
      address(entity),
      EntityType.CompanyEntity
    );

    return address(entity);
  }

  /// @notice Creates a project entity.
  /// @param id Id of entity sended from BE;
  /// @param deadline Signature deadline;
  /// @param argumentsU256 Array of uint256 which should be used to pass signature information;
  /// @param argumentsB32 Array of bytes32 which should be used to pass signature information;
  /// @return the address of the created proxy.
  function createProjectEntity(
    uint256 id,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  )
    external
    onlyUserEntity
    onlyValidSignature(msg.sender, deadline, argumentsU256, argumentsB32)
    returns (address)
  {
    BeaconProxy entity = new BeaconProxy(address(projectEntityBeacon), "");

    ProjectEntity(address(entity)).initialize(
      msg.sender,
      swapMile,
      mileToken,
      sMileToken,
      address(this),
      milestoneBased
    );

    whiteList.addNewAddress(address(entity));
    isEntityByAddress[address(entity)] = true;
    projectsEntities[address(entity)] = true;
    emit CreatedNewEntity(
      id,
      msg.sender,
      address(entity),
      EntityType.ProjectEntity
    );

    return address(entity);
  }

  /// @notice Add new address of entity owner for validating creating userEntities.
  /// @param entityOwner address of entityContract owner to add
  function addUser(address entityOwner) external onlyUserEntity {
    require(
      ownersOfUserEntity[entityOwner] == address(0),
      "User already has user entity"
    );
    ownersOfUserEntity[entityOwner] = msg.sender;
    emit AddedOwnerOfEntity(entityOwner);
  }

  /// @notice Remove address of entity owner for validating creating userEntities.
  /// @param entityOwner address of entityContract owner to remove
  function removeUser(address entityOwner) external onlyUserEntity {
    ownersOfUserEntity[entityOwner] = address(0);
    emit RemovedOwnerOfEntity(entityOwner);
  }

  function isOwnerOfUserEntity(address user) external view returns (bool) {
    return ownersOfUserEntity[user] != address(0);
  }

  function getUserEntityOfOwner(address entityOwner)
    external
    view
    returns (address)
  {
    return ownersOfUserEntity[entityOwner];
  }

  function getEntityType(address entity) external view returns (uint256) {
    if (usersEntities[entity]) {
      return uint256(EntityType.UserEntity);
    } else if (companiesEntities[entity]) {
      return uint256(EntityType.CompanyEntity);
    } else if (projectsEntities[entity]) {
      return uint256(EntityType.ProjectEntity);
    } else {
      return 3;
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

import "./BaseEntity.sol";
import "./MilestoneBased.sol";
import "./interfaces/IEntityFactory.sol";
import "./interfaces/IUserEntity.sol";

contract ProjectEntity is BaseEntity {
  using SafeERC20 for IERC20;

  IEntityFactory public entityFactory;
  /// @notice Stores the address of an MilestoneBased contract.
  /// @return Address of a Milestone based contract.
  MilestoneBased public milestoneBased;

  /// @notice Emits on each updating of milestoneBased contract.
  /// @param oldMilestoneBased address of old milestoneBased contract;
  /// @param newMilestoneBased address of new milestoneBased contract.
  event UpdateMilestoneBased(
    address oldMilestoneBased,
    address newMilestoneBased
  );

  function initialize(
    address owner_,
    address swapMile_,
    address mileToken_,
    address sMileToken_,
    address entityFactory_,
    address milestoneBased_
  ) external initializer {
    require(
      entityFactory_ != address(0),
      "EntityFactory address cannot be zero"
    );
    require(milestoneBased_ != address(0), "Address cannot be zero");
    __BaseEntity_init(swapMile_, mileToken_, sMileToken_, owner_);
    entityFactory = IEntityFactory(entityFactory_);
    milestoneBased = MilestoneBased(milestoneBased_);
  }

  /// @dev Sets new address of MilestoneBased contract.
  /// @param _milestoneBased new address of MilestoneBased contract
  function setMilestoneBased(address _milestoneBased) external onlyOwner {
    require(_milestoneBased != address(0), "Address cannot be zero");
    address oldMilestoneBased = address(milestoneBased);
    milestoneBased = MilestoneBased(_milestoneBased);
    emit UpdateMilestoneBased(oldMilestoneBased, _milestoneBased);
  }

  /// @dev Override function "swapOwner" of BaseEntity contract by adding additional code.
  /// @param prevOwner address of owner that pointed to the owner to be removed in the linked list;
  /// @param oldOwner address of owner to remove from UserEntity and EntityFactory;
  /// @param newOwner address of new Owner of UserEntity contract.
  function swapOwner(
    address prevOwner,
    address oldOwner,
    address newOwner
  ) external onlyOwner {
    require(
      entityFactory.getEntityType(newOwner) == 0,
      "Owner of project entity can be only user entity"
    );
    _swapOwner(prevOwner, oldOwner, newOwner);
  }

  function isOwner(address owner) public view override returns (bool) {
    return BaseEntity(_getCurrentOwner()).isOwner(owner);
  }

  function isAdmin(address admin) public view override returns (bool) {
    bool isAdminOfUserEntity = BaseEntity(_getCurrentOwner()).isAdmin(admin);
    address adminEntity = IEntityFactory(entityFactory).getUserEntityOfOwner(
      admin
    );
    if (adminEntity == address(0)) {
      return false;
    }
    return administrators[adminEntity] || isAdminOfUserEntity;
  }

  /// @notice Stake amount of MILE tokens to SwapMILE contract.
  /// @param amount amount of MILE tokens to stake;
  /// @param sourceType flag to define whose tokens will be used for staking,
  /// 0 - tokens from user's wallet
  /// 1 - tokens from parent userEntity
  /// 2 - from the current entity
  function stake(uint256 amount, TokenSourceType sourceType)
    external
    onlyOwnerOrAdmin
  {
    _managingTokenSupply(mileToken, amount, sourceType);
    _stake(amount);
  }

  /// @dev The same function like "stake" but the BaseEntity contract call function "stakeTo" instead of "stake" of SwapMILE contract.
  /// @param amount amount of MILE tokens to stake;
  /// @param recipient recipient of sMILE tokens from SwapMILE contract.
  /// @param sourceType flag to define whose tokens will be used for staking,
  /// 0 - tokens from user's wallet
  /// 1 - tokens from parent userEntity
  /// 2 - from the current entity
  function stakeTo(
    uint256 amount,
    address recipient,
    TokenSourceType sourceType
  ) external onlyOwnerOrAdmin {
    _managingTokenSupply(mileToken, amount, sourceType);
    _stakeTo(amount, recipient);
  }

  /// @notice Stake amount of ERC20 token to the SwapMILE contract.
  /// @param amount amount of “erc20token “ tokens for transfer;
  /// @param erc20token address of custom token for converting on SwapMILE contract;
  /// @param sourceType flag to define whose tokens will be used for staking,
  /// 0 - tokens from user's wallet
  /// 1 - tokens from parent userEntity
  /// 2 - from the current entity
  function swapStake(
    uint256 amount,
    address erc20token,
    TokenSourceType sourceType,
    uint256 validTill,
    uint256 amountOutMin
  ) external onlyOwnerOrAdmin {
    _managingTokenSupply(erc20token, amount, sourceType);
    _swapStake(amount, erc20token, validTill, amountOutMin);
  }

  /// @dev The same function like "swapStake" but the BaseEntity contract call
  /// function "swapStakeTo" instead of "swapStake" of SwapMILE contract.
  /// @param amount amount of "erc20token" tokens for transfer;
  /// @param erc20token address of custom token for converting on SwapMILE contract;
  /// @param recipient recipient of sMILE tokens from SwapMILE contract.
  /// @param sourceType flag to define whose tokens will be used for staking,
  /// 0 - tokens from user's wallet
  /// 1 - tokens from parent userEntity
  /// 2 - from the current entity
  function swapStakeTo(
    uint256 amount,
    address erc20token,
    address recipient,
    TokenSourceType sourceType,
    uint256 validTill,
    uint256 amountOutMin
  ) external onlyOwnerOrAdmin {
    _managingTokenSupply(erc20token, amount, sourceType);
    _swapStakeTo(amount, erc20token, recipient, validTill, amountOutMin);
  }

  function createRoadmap(
    MilestoneBased.RoadmapInitializationSettings calldata roadmapSettings,
    MilestoneBased.VotingInitializationSettings calldata votingSettings
  ) external onlyOwner {
    milestoneBased.createRoadmap(roadmapSettings, votingSettings);
  }

  function _getCurrentOwner() internal view returns (address) {
    address[] memory ownersArray = getOwners();
    return ownersArray[0];
  }

  function _managingTokenSupply(
    address token,
    uint256 amount,
    TokenSourceType sourceType
  ) internal {
    if (sourceType == TokenSourceType.UserWallet) {
      IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
    } else if (sourceType == TokenSourceType.UserEntity) {
      address userEntity = IEntityFactory(entityFactory).getUserEntityOfOwner(
        msg.sender
      );
      IERC20(token).safeTransferFrom(userEntity, address(this), amount);
    }
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";
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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

import "./BaseEntity.sol";
import "./interfaces/IEntityFactory.sol";
import "./interfaces/IUserEntity.sol";

contract UserEntity is BaseEntity, IUserEntity {
  using SafeERC20 for IERC20;

  IEntityFactory public entityFactory;

  /// @param swapMile_ address of SwapMILE contract;
  /// @param mileToken_ address of MILE token;
  /// @param sMileToken_ address of sMILE token;
  /// @param entityFactory_ address of EntityFactory contract.
  function initialize(
    address owner_,
    address swapMile_,
    address mileToken_,
    address sMileToken_,
    address entityFactory_
  ) external initializer {
    require(
      entityFactory_ != address(0),
      "EntityFactory address cannot be zero"
    );
    __BaseEntity_init(swapMile_, mileToken_, sMileToken_, owner_);

    entityFactory = IEntityFactory(entityFactory_);
  }

  /// @dev Override function "addOwner" of BaseEntity contract by adding additional code.
  /// @param owner address of new Owner of UserEntity contract.
  function addOwner(address owner) external onlyOwner {
    _addOwner(owner);
    entityFactory.addUser(owner);
  }

  /// @dev Override function "removeOwner" of BaseEntity contract by adding additional code.
  /// @param prevOwner address of owner that pointed to the owner to be removed in the linked list;
  /// @param owner address of owner to remove from UserEntity and EntityFactory.
  function removeOwner(address prevOwner, address owner) external onlyOwner {
    _removeOwner(prevOwner, owner);
    entityFactory.removeUser(owner);
  }

  /// @dev Override function "swapOwner" of BaseEntity contract by adding additional code.
  /// @param prevOwner address of owner that pointed to the owner to be removed in the linked list;
  /// @param oldOwner address of owner to remove from UserEntity and EntityFactory;
  /// @param newOwner address of new Owner of UserEntity contract.
  function swapOwner(
    address prevOwner,
    address oldOwner,
    address newOwner
  ) external onlyOwner {
    _swapOwner(prevOwner, oldOwner, newOwner);
    entityFactory.removeUser(oldOwner);
    entityFactory.addUser(newOwner);
  }

  /// @dev This function calls function "createCompanyEntity()" EntityFactory contract.
  /// @return the address of the created CompanyEntity proxy.
  function createCompanyEntity(
    uint256 id,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  ) external onlyOwner returns (address) {
    address newEntity = entityFactory.createCompanyEntity(
      id,
      deadline,
      argumentsU256,
      argumentsB32
    );
    emit CreatedEntity(id, newEntity, 1);
    return newEntity;
  }

  /// @dev This function calls function "createProjectEntity()" EntityFactory contract.
  /// @return the address of the created ProjectEntity proxy.
  function createProjectEntity(
    uint256 id,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  ) external onlyOwner returns (address) {
    address newEntity = entityFactory.createProjectEntity(
      id,
      deadline,
      argumentsU256,
      argumentsB32
    );
    emit CreatedEntity(id, newEntity, 2);
    return newEntity;
  }

  /// @notice Stake amount of MILE tokens to SwapMILE contract.
  /// @param amount amount of MILE tokens to stake;
  /// @param fromSender flag to define whose tokens will be used for staking,
  /// tokens from user's wallet or from this entity
  function stake(uint256 amount, bool fromSender) external onlyOwnerOrAdmin {
    if (fromSender) {
      IERC20(mileToken).safeTransferFrom(msg.sender, address(this), amount);
    }
    _stake(amount);
  }

  /// @dev The same function like "stake" but the BaseEntity contract call function "stakeTo" instead of "stake" of SwapMILE contract.
  /// @param amount amount of MILE tokens to stake;
  /// @param recipient recipient of sMILE tokens from SwapMILE contract.
  /// @param fromSender flag to define whose tokens will be used for staking,
  /// tokens from user's wallet or from this entity
  function stakeTo(
    uint256 amount,
    address recipient,
    bool fromSender
  ) external onlyOwnerOrAdmin {
    if (fromSender) {
      IERC20(mileToken).safeTransferFrom(msg.sender, address(this), amount);
    }

    _stakeTo(amount, recipient);
  }

  /// @notice Stake amount of ERC20 token to the SwapMILE contract.
  /// @param amount amount of “erc20token “ tokens for transfer;
  /// @param erc20token address of custom token for converting on SwapMILE contract;
  /// @param fromSender flag to define whose tokens will be used for staking,
  /// tokens from user's wallet or from this entity
  function swapStake(
    uint256 amount,
    address erc20token,
    bool fromSender,
    uint256 validTill,
    uint256 amountOutMin
  ) external onlyOwnerOrAdmin {
    if (fromSender) {
      IERC20(erc20token).safeTransferFrom(msg.sender, address(this), amount);
    }

    _swapStake(amount, erc20token, validTill, amountOutMin);
  }

  /// @dev The same function like "swapStake" but the BaseEntity contract call
  /// function "swapStakeTo" instead of "swapStake" of SwapMILE contract.
  /// @param amount amount of "erc20token" tokens for transfer;
  /// @param erc20token address of custom token for converting on SwapMILE contract;
  /// @param recipient recipient of sMILE tokens from SwapMILE contract.
  /// @param fromSender flag to define whose tokens will be used for staking,
  /// tokens from user's wallet or from this entity
  function swapStakeTo(
    uint256 amount,
    address erc20token,
    address recipient,
    bool fromSender,
    uint256 validTill,
    uint256 amountOutMin
  ) external onlyOwnerOrAdmin {
    if (fromSender) {
      IERC20(erc20token).safeTransferFrom(msg.sender, address(this), amount);
    }

    _swapStakeTo(amount, erc20token, recipient, validTill, amountOutMin);
  }

  function approve(
    address token,
    address spenderEntity,
    uint256 amount
  ) external onlyOwner {
    uint256 spenderType = IEntityFactory(entityFactory).getEntityType(
      spenderEntity
    );
    require(
      0 < spenderType && spenderType < 3,
      "Address of spender isn't address of entity"
    );
    IERC20(token).safeIncreaseAllowance(spenderEntity, amount);
    emit ApprovedTokens(token, spenderEntity, spenderType, amount);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

import "./BaseEntity.sol";
import "./interfaces/IEntityFactory.sol";
import "./interfaces/IUserEntity.sol";

contract CompanyEntity is BaseEntity {
  using SafeERC20 for IERC20;

  IEntityFactory public entityFactory;

  function initialize(
    address owner_,
    address swapMile_,
    address mileToken_,
    address sMileToken_,
    address entityFactory_
  ) external initializer {
    require(
      entityFactory_ != address(0),
      "EntityFactory address cannot be zero"
    );
    __BaseEntity_init(swapMile_, mileToken_, sMileToken_, owner_);
    entityFactory = IEntityFactory(entityFactory_);
  }

  /// @dev Override function "swapOwner" of BaseEntity contract by adding additional code.
  /// @param prevOwner address of owner that pointed to the owner to be removed in the linked list;
  /// @param oldOwner address of owner to remove from UserEntity and EntityFactory;
  /// @param newOwner address of new Owner of UserEntity contract.
  function swapOwner(
    address prevOwner,
    address oldOwner,
    address newOwner
  ) external onlyOwner {
    require(
      entityFactory.getEntityType(newOwner) == 0,
      "Owner of company entity can be only user entity"
    );
    _swapOwner(prevOwner, oldOwner, newOwner);
  }

  function isOwner(address owner) public view override returns (bool) {
    return BaseEntity(_getCurrentOwner()).isOwner(owner);
  }

  function isAdmin(address admin) public view override returns (bool) {
    bool isAdminOfUserEntity = BaseEntity(_getCurrentOwner()).isAdmin(admin);
    address adminEntity = IEntityFactory(entityFactory).getUserEntityOfOwner(
      admin
    );
    if (adminEntity == address(0)) {
      return false;
    }
    return administrators[adminEntity] || isAdminOfUserEntity;
  }

  /// @notice Stake amount of MILE tokens to SwapMILE contract.
  /// @param amount amount of MILE tokens to stake;
  /// @param sourceType flag to define whose tokens will be used for staking,
  /// 0 - tokens from user's wallet
  /// 1 - tokens from parent userEntity
  /// 2 - from the current entity
  function stake(uint256 amount, TokenSourceType sourceType)
    external
    onlyOwnerOrAdmin
  {
    _managingTokenSupply(mileToken, amount, sourceType);
    _stake(amount);
  }

  /// @dev The same function like "stake" but the BaseEntity contract call function "stakeTo" instead of "stake" of SwapMILE contract.
  /// @param amount amount of MILE tokens to stake;
  /// @param recipient recipient of sMILE tokens from SwapMILE contract.
  /// @param sourceType flag to define whose tokens will be used for staking,
  /// 0 - tokens from user's wallet
  /// 1 - tokens from parent userEntity
  /// 2 - from the current entity
  function stakeTo(
    uint256 amount,
    address recipient,
    TokenSourceType sourceType
  ) external onlyOwnerOrAdmin {
    _managingTokenSupply(mileToken, amount, sourceType);
    _stakeTo(amount, recipient);
  }

  /// @notice Stake amount of ERC20 token to the SwapMILE contract.
  /// @param amount amount of “erc20token “ tokens for transfer;
  /// @param erc20token address of custom token for converting on SwapMILE contract;
  /// @param sourceType flag to define whose tokens will be used for staking,
  /// 0 - tokens from user's wallet
  /// 1 - tokens from parent userEntity
  /// 2 - from the current entity
  function swapStake(
    uint256 amount,
    address erc20token,
    TokenSourceType sourceType,
    uint256 validTill,
    uint256 amountOutMin
  ) external onlyOwnerOrAdmin {
    _managingTokenSupply(erc20token, amount, sourceType);
    _swapStake(amount, erc20token, validTill, amountOutMin);
  }

  /// @dev The same function like "swapStake" but the BaseEntity contract call
  /// function "swapStakeTo" instead of "swapStake" of SwapMILE contract.
  /// @param amount amount of "erc20token" tokens for transfer;
  /// @param erc20token address of custom token for converting on SwapMILE contract;
  /// @param recipient recipient of sMILE tokens from SwapMILE contract.
  /// @param sourceType flag to define whose tokens will be used for staking,
  /// 0 - tokens from user's wallet
  /// 1 - tokens from parent userEntity
  /// 2 - from the current entity
  function swapStakeTo(
    uint256 amount,
    address erc20token,
    address recipient,
    TokenSourceType sourceType,
    uint256 validTill,
    uint256 amountOutMin
  ) external onlyOwnerOrAdmin {
    _managingTokenSupply(erc20token, amount, sourceType);
    _swapStakeTo(amount, erc20token, recipient, validTill, amountOutMin);
  }

  function _getCurrentOwner() internal view returns (address) {
    address[] memory ownersArray = getOwners();
    return ownersArray[0];
  }

  function _managingTokenSupply(
    address token,
    uint256 amount,
    TokenSourceType sourceType
  ) internal {
    if (sourceType == TokenSourceType.UserWallet) {
      IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
    } else if (sourceType == TokenSourceType.UserEntity) {
      address userEntity = IEntityFactory(entityFactory).getUserEntityOfOwner(
        msg.sender
      );
      IERC20(token).safeTransferFrom(userEntity, address(this), amount);
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

interface IWhiteList {
  /// @notice Emits when MilestoneBased contract or owner adds new address to the contract.
  /// @param newAddress address of new contract to add.
  event AddedNewAddress(address newAddress);
  /// @notice Emits when owner remove address from the contract.
  /// @param invalidAddress address of contract for removing.
  event RemovedAddress(address invalidAddress);

  function addNewAddress(address newAddress) external;

  function addNewAddressesBatch(address[] memory newAddresses) external;

  function removeAddress(address invalidAddress) external;

  function removeAddressesBatch(address[] memory invalidAddresses) external;

  function getAllAddresses() external view returns (address[] memory);

  function isValidAddress(address accountAddress) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

/// @title Interface for a generic voting strategy contract
interface IEntityStrategy {
  struct Entity {
    address owner;
    address swapMile;
    address mileToken;
    address sMileToken;
    address entityFactory;
  }

  function isValid(
    Entity calldata entity,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  ) external returns (bool);

  function getNonce(address owner) external returns (uint256);
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/ISwapMILE.sol";
import "./interfaces/IBaseEntity.sol";

contract BaseEntity is IBaseEntity, Initializable {
  using SafeERC20 for IERC20;

  address public constant SENTINEL_OWNERS = address(0x1);

  ISwapMILE public swapMile;

  address public mileToken;

  address public sMileToken;

  uint256 public ownerCount;

  mapping(address => address) public owners;

  mapping(address => bool) public administrators;

  modifier onlyOwner() {
    require(isOwner(msg.sender), "Caller must be owner");
    _;
  }
  modifier onlyOwnerOrAdmin() {
    require(
      isOwner(msg.sender) || isAdmin(msg.sender),
      "Caller must be admin or owner"
    );
    _;
  }

  // solhint-disable-next-line
  function __BaseEntity_init(
    address swapMile_,
    address mileToken_,
    address sMileToken_,
    address owner_
  ) public initializer {
    require(swapMile_ != address(0), "SwapMILE address cannot be zero");
    require(
      mileToken_ != address(0) && sMileToken_ != address(0),
      "Token addresses cannot be zero"
    );
    require(owner_ != address(0), "Owner can't be zero address");
    swapMile = ISwapMILE(swapMile_);
    mileToken = mileToken_;
    sMileToken = sMileToken_;
    IERC20(sMileToken).safeIncreaseAllowance(swapMile_, type(uint256).max);

    owners[SENTINEL_OWNERS] = owner_;
    owners[owner_] = SENTINEL_OWNERS;
    ownerCount++;
    emit AddedOwner(owner_);
  }

  /// @notice Create withdraw request to SwapMILE contract.
  /// @param amount amount to withdraw.
  /// @return id of the created request.
  function requestWithdraw(uint256 amount)
    external
    onlyOwnerOrAdmin
    returns (uint256)
  {
    uint256 requestId = swapMile.requestWithdraw(amount);
    emit CreatedRequestWithdraw(msg.sender, amount, requestId);

    return requestId;
  }

  /// @notice Cancel request of withdraw from SwapMILE contract.
  /// @param requestId id of withdrawal request.
  function cancelWithdraw(uint256 requestId) external onlyOwnerOrAdmin {
    swapMile.cancelWithdraw(requestId);
  }

  /// @notice Withdraw MILE token from SwapMILE contract to the Entity contract.
  /// @param requestId withdrawal request id.
  function withdrawFromStaking(uint256 requestId) external onlyOwnerOrAdmin {
    swapMile.withdraw(requestId);
  }

  /// @notice Withdraw token from the Entity contract to the recipient address.
  /// @param token address of token to transfer;
  /// @param amount amount of tokens to transfer;
  /// @param recipient recipient of transferred tokens.
  function withdrawFromEntity(
    address token,
    uint256 amount,
    address recipient
  ) external onlyOwner {
    require(
      IERC20(token).balanceOf(address(this)) >= amount,
      "Not enough tokens to withdraw"
    );
    IERC20(token).safeTransfer(recipient, amount);

    emit Withdrawn(recipient, amount);
  }

  /// @dev Checks if the address is in the linked list.
  /// @param owner Address of owner.
  /// @return True if passed address is address of owner, else - return false.
  function isOwner(address owner) public view virtual returns (bool) {
    return owner != SENTINEL_OWNERS && owners[owner] != address(0);
  }

  /// @dev Checks if the address has administrator role.
  /// @param admin Address of user.
  /// @return True if passed address is address of administrator, else - return false.
  function isAdmin(address admin) public view virtual returns (bool) {
    return administrators[admin];
  }

  /// @dev Returns array of owners.
  /// @return Array of owners.
  function getOwners() public view returns (address[] memory) {
    address[] memory array = new address[](ownerCount);

    // populate return array
    uint256 index = 0;
    address currentOwner = owners[SENTINEL_OWNERS];
    while (currentOwner != SENTINEL_OWNERS) {
      array[index] = currentOwner;
      currentOwner = owners[currentOwner];
      index++;
    }
    return array;
  }

  function _addAdmin(address newAdministrator) internal {
    administrators[newAdministrator] = true;
    emit AddedAdmin(newAdministrator);
  }

  function _removeAdmin(address administrator) internal {
    administrators[administrator] = false;
    emit RemovedAdmin(administrator);
  }

  /// @notice Stake amount of MILE tokens to SwapMILE contract.
  /// @param amount amount of MILE tokens to stake;
  function _stake(uint256 amount) internal {
    IERC20(mileToken).safeIncreaseAllowance(address(swapMile), amount);
    swapMile.stake(amount);

    emit StakeMile(msg.sender, mileToken, amount);
  }

  /// @dev The same function like "stake" but the BaseEntity contract call function "stakeTo" instead of "stake" of SwapMILE contract.
  /// @param amount amount of MILE tokens to stake;
  /// @param recipient recipient of sMILE tokens from SwapMILE contract.
  function _stakeTo(uint256 amount, address recipient) internal {
    IERC20(mileToken).safeIncreaseAllowance(address(swapMile), amount);
    swapMile.stakeTo(recipient, amount);

    emit StakeMile(msg.sender, mileToken, amount);
  }

  /// @notice Stake amount of ERC20 token to the SwapMILE contract.
  /// @param amount amount of “erc20token “ tokens for transfer;
  /// @param erc20token address of custom token for converting on SwapMILE contract;
  function _swapStake(
    uint256 amount,
    address erc20token,
    uint256 validTill,
    uint256 amountOutMin
  ) internal {
    IERC20(erc20token).safeIncreaseAllowance(address(swapMile), amount);
    swapMile.swapStake(amount, erc20token, validTill, amountOutMin);
  }

  /// @dev The same function like "swapStake" but the BaseEntity contract call
  /// function "swapStakeTo" instead of "swapStake" of SwapMILE contract.
  /// @param amount amount of "erc20token" tokens for transfer;
  /// @param erc20token address of custom token for converting on SwapMILE contract;
  /// @param recipient recipient of sMILE tokens from SwapMILE contract.
  function _swapStakeTo(
    uint256 amount,
    address erc20token,
    address recipient,
    uint256 validTill,
    uint256 amountOutMin
  ) internal {
    IERC20(erc20token).safeIncreaseAllowance(address(swapMile), amount);
    swapMile.swapStakeTo(
      amount,
      erc20token,
      recipient,
      validTill,
      amountOutMin
    );
  }

  /// @dev Allows to add a new owner to the Safe.
  /// @notice Adds the owner `owner` to the Safe.
  /// @param owner New owner address.
  function _addOwner(address owner) internal {
    // Owner address cannot be null, the sentinel or the Safe itself.
    require(
      owner != address(0) && owner != SENTINEL_OWNERS && owner != address(this),
      "Invalid owner address provided"
    );
    // No duplicate owners allowed.
    require(owners[owner] == address(0), "Address is already an owner");
    owners[owner] = owners[SENTINEL_OWNERS];
    owners[SENTINEL_OWNERS] = owner;
    ownerCount++;
    emit AddedOwner(owner);
  }

  /// @dev Allows to remove an owner from the Safe.
  /// @notice Removes the owner `owner` from the Safe.
  /// @param prevOwner Owner that pointed to the owner to be removed in the linked list
  /// @param owner Owner address to be removed.
  function _removeOwner(address prevOwner, address owner) internal {
    // Validate owner address and check that it corresponds to owner index.
    require(
      owner != address(0) && owner != SENTINEL_OWNERS,
      "Invalid owner address provided"
    );
    require(
      owners[prevOwner] == owner,
      "Invalid prevOwner, owner pair provided"
    );
    require(ownerCount > 1, "The contract must have at least one owner");
    owners[prevOwner] = owners[owner];
    owners[owner] = address(0);
    ownerCount--;
    emit RemovedOwner(owner);
  }

  /// @dev Allows to swap/replace an owner from the Safe with another address.
  /// @notice Replaces the owner `oldOwner` in the Safe with `newOwner`.
  /// @param prevOwner Owner that pointed to the owner to be replaced in the linked list
  /// @param oldOwner Owner address to be replaced.
  /// @param newOwner New owner address.
  function _swapOwner(
    address prevOwner,
    address oldOwner,
    address newOwner
  ) internal {
    // Owner address cannot be null, the sentinel or the Safe itself.
    require(
      newOwner != address(0) &&
        newOwner != SENTINEL_OWNERS &&
        newOwner != address(this),
      "Invalid owner address provided"
    );
    // No duplicate owners allowed.
    require(owners[newOwner] == address(0), "Address is already an owner");
    // Validate oldOwner address and check that it corresponds to owner index.
    require(
      oldOwner != address(0) && oldOwner != SENTINEL_OWNERS,
      "Invalid owner address provided"
    );
    require(
      owners[prevOwner] == oldOwner,
      "Invalid prevOwner, owner pair provided"
    );
    owners[newOwner] = owners[oldOwner];
    owners[prevOwner] = newOwner;
    owners[oldOwner] = address(0);
    emit RemovedOwner(oldOwner);
    emit AddedOwner(newOwner);
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[49] private ___gap;
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

interface IUserEntity {
  event CreatedEntity(
    uint256 indexed id,
    address newEntity,
    uint256 entityType
  );

  event ApprovedTokens(
    address token,
    address spender,
    uint256 spenderType,
    uint256 amount
  );

  function initialize(
    address owner_,
    address swapMile_,
    address mileToken_,
    address sMileToken_,
    address entityFactory_
  ) external;

  function addOwner(address owner) external;

  function removeOwner(address prevOwner, address owner) external;

  function swapOwner(
    address prevOwner,
    address oldOwner,
    address newOwner
  ) external;

  function createCompanyEntity(
    uint256 id,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  ) external returns (address);

  function createProjectEntity(
    uint256 id,
    uint256 deadline,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  ) external returns (address);

  function stake(uint256 amount, bool fromSender) external;

  function stakeTo(
    uint256 amount,
    address recipient,
    bool fromSender
  ) external;

  function swapStake(
    uint256 amount,
    address erc20token,
    bool fromSender,
    uint256 validTill,
    uint256 amountOutMin
  ) external;

  function swapStakeTo(
    uint256 amount,
    address erc20token,
    address recipient,
    bool fromSender,
    uint256 validTill,
    uint256 amountOutMin
  ) external;

  function approve(
    address token,
    address spenderEntity,
    uint256 amount
  ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

interface ISwapMILE {
  enum RequestWithdrawStatus {
    Active,
    Canceled,
    Expired,
    Done
  }

  struct WithdrawRequest {
    uint256 id;
    uint256 amountOfsMILE;
    uint256 creationTimestamp;
    uint256 coolDownEnd;
    uint256 withdrawEnd;
    RequestWithdrawStatus status;
    uint256 statusUpdateTimestamp;
    uint256 transferedAmount;
  }

  event Staked(
    address indexed caller,
    address indexed recipient,
    uint256 stakedMILE,
    uint256 swappedSMILE,
    uint256 callerEntityType,
    uint256 recipientEntityType
  );

  event CreatedWithdrawRequest(
    uint256 indexed withdrawalId,
    address recipient,
    uint256 recipientEntityType,
    uint256 amountOfsMILE,
    uint256 timestampOfCreation
  );

  event Withdrawn(
    uint256 indexed withdrawalId,
    address recipient,
    uint256 recipientEntityType,
    uint256 amountOfsMILE,
    uint256 amountOfMILE,
    uint256 fee,
    bool success
  );

  event WithdrawCanceled(
    uint256 indexed withdrawalId,
    uint256 amountOfsMILE,
    address recipient,
    uint256 recipientEntityType
  );

  event AddMILE(address sender, uint256 callerEntityType, uint256 amount);

  event WithdrawnUnusedMILE(
    uint256 amount,
    address recipient,
    uint256 recipientEntityType
  );

  event WithdrawnUnusedSMILE(
    uint256 amount,
    address recipient,
    uint256 recipientEntityType
  );

  event UpdatedCoolDownPeriod(uint256 oldPeriod, uint256 newPeriod);

  event UpdatedWithdrawPeriod(uint256 oldPeriod, uint256 newPeriod);

  event UpdatedEntityContract(address oldAddress, address newAddress);

  event PriceUpdated(
    uint256 milePrice,
    uint256 smilePrice,
    uint256 mileBusdPrice,
    uint256 mileBnbPrice,
    uint256 smileBusdPrice,
    uint256 smileBnbPrice,
    uint256 timestamp
  );

  function setCoolDownPeriod(uint256 newValue) external;

  function setWithdrawPeriod(uint256 newValue) external;

  function setEntityFactoryContract(address entity) external;

  function getMILEPrice() external returns (uint256);

  function getSMILEPrice() external returns (uint256);

  function getLiquidityAmount() external returns (uint256, uint256);

  function stake(uint256 amount) external;

  function stakeTo(address to, uint256 amount) external;

  function swapStake(
    uint256 amount,
    address erc20Token,
    uint256 validTill,
    uint256 amountOutMin
  ) external;

  function swapStakeTo(
    uint256 amount,
    address erc20Token,
    address to,
    uint256 validTill,
    uint256 amountOutMin
  ) external;

  function getRequestAmountByEntity(address entity) external returns (uint256);

  function getRequestIdsByEntity(address entity)
    external
    returns (uint256[] memory, uint256);

  function getRequestsByEntity(
    address entity,
    uint256 offset,
    uint256 limit,
    bool ascOrder
  ) external returns (WithdrawRequest[] memory, uint256);

  function getAvailableSMILEToWithdraw(address entity)
    external
    returns (uint256);

  function getRequestedSMILE(address entity) external returns (uint256);

  function requestWithdraw(uint256 amount) external returns (uint256);

  function withdraw(uint256 withdrawalId) external returns (bool);

  function cancelWithdraw(uint256 withdrawalId) external;

  function addRewards(uint256 amount) external;

  function withdrawUnusedMILE(uint256 amount, address to) external;

  function withdrawUnusedSMILE(uint256 amount, address to) external;
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

interface IBaseEntity {
  enum TokenSourceType {
    UserWallet,
    UserEntity,
    CurrentContract
  }

  struct WithdrawRequest {
    uint256 id;
    uint256 amountOfMILE;
    uint256 creationTimestamp;
  }

  event StakeMile(address staker, address token, uint256 amount);

  event CreatedRequestWithdraw(
    address staker,
    uint256 amount,
    uint256 indexed requestId
  );

  event Withdrawn(address recipient, uint256 amount);

  event AddedOwner(address owner);

  event RemovedOwner(address owner);

  event AddedAdmin(address admin);

  event RemovedAdmin(address admin);

  // function addAdmin(address newAdministrator) external;

  // function removeAdmin(address administrator) external;

  function requestWithdraw(uint256 amount) external returns (uint256);

  function cancelWithdraw(uint256 requestId) external;

  function withdrawFromStaking(uint256 requestId) external;

  function withdrawFromEntity(
    address token,
    uint256 amount,
    address recipient
  ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

/// @title Interface for a generic voting strategy contract
interface IVotingStrategy {
  struct Vote {
    address voter;
    address roadmap;
    uint256 proposalId;
    uint256 optionId;
    uint256 votingPower;
    bytes ipfsHash;
  }

  /// @notice Used to get url of signature generation resource
  /// @return String representing signature generation resource url
  function url() external returns (string memory);

  /// @notice Checks validity of a vote signature
  /// @param vote Structure containing vote data which is being signed. Fields:
  /// address voter - address of a voter for this vote
  /// address roadmap - address of a roadmap voting is related to
  /// uint256 proposalId - id of a proposal for this vote
  /// uint256 optionId - id of a option being voted
  /// uint256 votingPower - voting power of this vote
  /// bytes ipfsHash - bytes representing ipfs hash which contains additional information about this vote
  /// @param argumentsU256 Array of uint256 which should be used to pass signature information
  /// @param argumentsB32 Array of bytes32 which should be used to pass signature information
  /// @return True if a signature is valid, false otherwise
  function isValid(
    Vote calldata vote,
    uint256[] calldata argumentsU256,
    bytes32[] calldata argumentsB32
  ) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}

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
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

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
     * bearer except when using {_setupRole}.
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
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(uint160(account), 20),
                " is missing role ",
                Strings.toHexString(uint256(role), 32)
            )));
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
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
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
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
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
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
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}

// SPDX-License-Identifier: MIT

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