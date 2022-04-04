// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import "../libs/fota/Auth.sol";
import "../interfaces/IEnergyManager.sol";
import "../interfaces/IRewardManager.sol";
import "../interfaces/IGameNFT.sol";
import "../interfaces/IPVP.sol";

contract FOTAGamePVE is Auth, EIP712Upgradeable {

  struct Mission {
    uint id;
    uint mainReward;
    uint subReward;
    uint32 experience;
    address owner;
  }
  IEnergyManager public energyManager;
  IRewardManager public rewardManager;
  IGameNFT public heroNft;
  IPVP public pvp;

  uint public totalMissions;
  uint public energyConsumption;
  uint public maxReward;
  uint public extraMissionWhenRunOutOfEnergyRatio;
  mapping (address => uint) public nonces;
  mapping (address => uint) public rewarded;
  mapping (address => uint) public todayFreeMissionFinished;
  mapping (address => uint) public biggestFinishMission;
  mapping (address => uint) public totalWinInDay;
  mapping (uint => Mission) public missions;

  event MissionAdded(uint id, uint mainReward, uint subReward, uint32 experience, address owner, uint timestamp);
  event MissionUpdated(uint id, uint mainReward, uint subReward, uint32 experience, address owner, uint timestamp);
  event EnergyConsumptionUpdated(uint energyConsumption);
  event MaxRewardUpdated(uint maxReward, uint timestamp);
  event ExtraMissionWhenRunOutOfEnergyRatioUpdated(uint ratio, uint timestamp);
  event RewardedRecorded(address indexed user, uint reward);
  event GameFinished(address indexed user, uint mission, uint userReward, uint currentEnergy, bool dailyQuestCompleted, uint timestamp);

  function initialize(
    string memory _name,
    string memory _version,
    address _mainAdmin,
    address _energyManager,
    address _rewardManager,
    address _heroNft
  ) public initializer {
    Auth.initialize(_mainAdmin);
    EIP712Upgradeable.__EIP712_init(_name, _version);
    energyManager = IEnergyManager(_energyManager);
    rewardManager = IRewardManager(_rewardManager);
    heroNft = IGameNFT(_heroNft);
    _initData();
  }

  function validateInviter(address _inviter) external view returns (bool) {
    _inviter;
    return mainAdmin != address(0);
  }

  function finishGame(uint _mission, uint[] calldata _heroIds, bytes memory _signature) external {
    bool firstCompleteMission = _validateFinishGame(_mission, _heroIds, _signature);
    uint energy = energyManager.getUserCurrentEnergy(msg.sender);
    bool firstConsumeInDay = energyManager.updateEnergy(msg.sender, energyConsumption);
    if (firstConsumeInDay) {
      todayFreeMissionFinished[msg.sender] = 0;
      totalWinInDay[msg.sender] = 0;
    }
    totalWinInDay[msg.sender]++;
    uint userReward;
    bool dailyQuestCompleted;
    if (firstConsumeInDay || energy >= energyConsumption) {
      (userReward, dailyQuestCompleted) = _giveReward(_mission, firstConsumeInDay, firstCompleteMission);
      _experienceUp(_mission, _heroIds);
    } else {
      _validateFreeMission();
      (userReward, dailyQuestCompleted) = _giveReward(_mission, firstConsumeInDay, firstCompleteMission);
    }
    emit GameFinished(msg.sender, _mission, userReward, energy - energyConsumption, dailyQuestCompleted, block.timestamp);
  }

  // TODO remove this on mainnet
  function finishGameByPassSignature(uint _mission, uint[] calldata _heroIds) external {
    bool firstCompleteMission = _validateFinishGameBypassSignature(_mission, _heroIds);
    uint energy = energyManager.getUserCurrentEnergy(msg.sender);
    bool firstConsumeInDay = energyManager.updateEnergy(msg.sender, energyConsumption);
    if (firstConsumeInDay) {
      todayFreeMissionFinished[msg.sender] = 0;
      totalWinInDay[msg.sender] = 0;
    }
    totalWinInDay[msg.sender]++;
    uint userReward;
    bool dailyQuestCompleted;
    if (firstConsumeInDay || energy >= energyConsumption) {
      (userReward, dailyQuestCompleted) = _giveReward(_mission, firstConsumeInDay, firstCompleteMission);
      _experienceUp(_mission, _heroIds);
    } else {
      _validateFreeMission();
      (userReward, dailyQuestCompleted) = _giveReward(_mission, firstConsumeInDay, firstCompleteMission);
    }
    emit GameFinished(msg.sender, _mission, userReward, energy - energyConsumption, dailyQuestCompleted, block.timestamp);
  }

  function haveTodayFreeMission(address _user) public view returns (bool) {
    uint todayFreeMission = getTodayFreeMission(_user);
    return todayFreeMission > todayFreeMissionFinished[_user];
  }

  function getTodayFreeMission(address _user) public view returns (uint) {
    return pvp.getUserTodayLose(_user) * extraMissionWhenRunOutOfEnergyRatio;
  }

  // PRIVATE FUNCTIONS

  function _validateFreeMission() private {
    require(haveTodayFreeMission(msg.sender), "PVE: run out of free mission");
    todayFreeMissionFinished[msg.sender]++;
  }

  function _giveReward(uint _mission, bool _firstConsumeInDay, bool _firstCompleteMission) private returns (uint, bool) {
    uint userReward;
    bool dailyQuestCompleted;
    uint reward = _calculateReward(_mission, _firstConsumeInDay, _firstCompleteMission);
    (userReward, dailyQuestCompleted) = rewardManager.addPVEReward(_mission, msg.sender, reward);
    emit RewardedRecorded(msg.sender, reward);
    return (userReward, dailyQuestCompleted);
  }

  function _calculateReward(uint _mission, bool _firstConsumeInDay, bool _firstCompleteMission) private returns (uint) {
    uint reward = missions[_mission].subReward;
    if (_firstCompleteMission) {
      reward = missions[_mission].mainReward;
    }
    if (_firstConsumeInDay) {
      if (reward > maxReward) {
        reward = maxReward;
      }
      rewarded[msg.sender] = reward;
    } else {
      if (rewarded[msg.sender] + reward >= maxReward) {
        reward = maxReward - rewarded[msg.sender];
      }
      rewarded[msg.sender] += reward;
    }
    return reward;
  }

  function _experienceUp(uint _mission, uint[] calldata _heroIds) private {
    for(uint i = 0; i < _heroIds.length; i++) {
      heroNft.experienceUp(_heroIds[i], missions[_mission].experience);
    }
  }

  function _validateFinishGame(uint _mission, uint[] calldata _heroIds, bytes memory _signature) private returns (bool) {
    require(_heroIds.length >= 3 && _heroIds.length <= 5, "PVE: HeroIds is invalid");
    for (uint i = 0; i < _heroIds.length - 1; i++) {
      require(_heroIds[i] < _heroIds[i + 1], "PVE: hero id is duplicated or wrong order");
    }
    require(_mission <= totalMissions, "PVE: Mission invalid");
    require(_mission <= biggestFinishMission[msg.sender] + 1, "PVE: please finish lower missions first");
    _validateHeroRight(_heroIds);

    bool firstCompleteMission = _mission == biggestFinishMission[msg.sender] + 1;
    if (firstCompleteMission) {
      biggestFinishMission[msg.sender] = _mission;
    }
    bytes32 digest = _buildDigest(_mission, _heroIds);
    nonces[msg.sender]++;
    address signer = ECDSAUpgradeable.recover(digest, _signature);
    require(signer == contractAdmin, "MessageVerifier: invalid signature");
    require(signer != address(0), "ECDSAUpgradeable: invalid signature");
    return firstCompleteMission;
  }

  // TODO remove
  function validateSignature(uint _mission, uint[] calldata _heroIds, bytes memory _signature) external view returns (bool) {
    bytes32 digest = _buildDigest(_mission, _heroIds);
    address signer = ECDSAUpgradeable.recover(digest, _signature);
    require(signer == contractAdmin, "MessageVerifier: invalid signature");
    require(signer != address(0), "ECDSAUpgradeable: invalid signature");
    return true;
  }

  function _validateFinishGameBypassSignature(uint _mission, uint[] calldata _heroIds) private returns (bool) {
    require(_heroIds.length >= 3 && _heroIds.length <= 5, "PVE: HeroIds is invalid");
    for (uint i = 0; i < _heroIds.length - 1; i++) {
      require(_heroIds[i] < _heroIds[i + 1], "PVE: hero id is duplicated or wrong order");
    }
    require(_mission <= totalMissions, "PVE: Mission invalid");
    require(_mission <= biggestFinishMission[msg.sender] + 1, "PVE: please finish lower missions first");
    _validateHeroRight(_heroIds);
    bool firstCompleteMission = _mission == biggestFinishMission[msg.sender] + 1;
    if (firstCompleteMission) {
      biggestFinishMission[msg.sender] = _mission;
    }
    return firstCompleteMission;
  }

  function _validateHeroRight(uint[] calldata _heroIds) private view {
    for(uint i = 0; i < _heroIds.length; i++) {
      require(heroNft.ownerOf(_heroIds[i]) == msg.sender, "PVE: hero invalid");
      bool approved = heroNft.isApprovedForAll(msg.sender, address(this)) || heroNft.getApproved(_heroIds[i]) == address(this);
      require(approved, "PVE: please approve token first");
    }
  }

  function _buildDigest(uint _mission, uint[] calldata _heroIds) private view returns (bytes32) {
    if (_heroIds.length == 3) {
      return _hashTypedDataV4(keccak256(abi.encode(
        keccak256("FinishGamePVE(address user,uint256 nonce,uint256 mission,uint256 hero1,uint256 hero2,uint256 hero3)"),
        msg.sender,
        nonces[msg.sender],
        _mission,
        _heroIds[0],
        _heroIds[1],
        _heroIds[2]
      )));
    } else if (_heroIds.length == 4) {
      return _hashTypedDataV4(keccak256(abi.encode(
        keccak256("FinishGamePVE(address user,uint256 nonce,uint256 mission,uint256 hero1,uint256 hero2,uint256 hero3,uint256 hero4)"),
        msg.sender,
        nonces[msg.sender],
        _mission,
        _heroIds[0],
        _heroIds[1],
        _heroIds[2],
        _heroIds[3]
      )));
    } else {
      return _hashTypedDataV4(keccak256(abi.encode(
        keccak256("FinishGamePVE(address user,uint256 nonce,uint256 mission,uint256 hero1,uint256 hero2,uint256 hero3,uint256 hero4,uint256 hero5)"),
        msg.sender,
        nonces[msg.sender],
        _mission,
        _heroIds[0],
        _heroIds[1],
        _heroIds[2],
        _heroIds[3],
        _heroIds[4]
      )));
    }
  }

  function _initData() private {
    totalMissions = 30;
    energyConsumption = 1;
    extraMissionWhenRunOutOfEnergyRatio = 1;
    maxReward = 100e18;
    for(uint i = 1; i <= totalMissions; i++) {
      missions[i] = Mission(i, i * 1e18, i * 1e18 / 2, uint32(i), address(0));
    }
  }

  // ADMIN FUNCTIONS

  function addMission(uint _mainReward, uint _subReward, uint32 _experience, address _owner) external onlyMainAdmin {
    totalMissions++;
    missions[totalMissions] = Mission(totalMissions, _mainReward, _subReward, _experience, _owner);
    emit MissionAdded(totalMissions, _mainReward, _subReward, _experience, _owner, block.timestamp);
  }

  function updateMission(uint _id, uint _mainReward, uint _subReward, uint32 _experience, address _owner) external onlyMainAdmin {
    missions[_id].mainReward = _mainReward;
    missions[_id].subReward = _subReward;
    missions[_id].experience = _experience;
    missions[_id].owner = _owner;
    emit MissionUpdated(_id, _mainReward, _subReward, _experience, _owner, block.timestamp);
  }

  function updateEnergyConsumption(uint _energyConsumption) external onlyMainAdmin {
    energyConsumption = _energyConsumption;
    emit EnergyConsumptionUpdated(energyConsumption);
  }

  function updateMaxReward(uint _maxReward) external onlyMainAdmin {
    require(_maxReward > 0, "401");
    maxReward = _maxReward;
    emit MaxRewardUpdated(maxReward, block.timestamp);
  }

  function updateExtraMissionWhenRunOutOfEnergyRatio(uint _ratio) external onlyMainAdmin {
    require(_ratio > 0, "401");
    extraMissionWhenRunOutOfEnergyRatio = _ratio;
    emit ExtraMissionWhenRunOutOfEnergyRatioUpdated(extraMissionWhenRunOutOfEnergyRatio, block.timestamp);
  }

  function setPVPAddress(address _pvp) external onlyMainAdmin {
    pvp = IPVP(_pvp);
  }

  function setContracts(address _heroNft, address _energyManager, address _rewardManager) external onlyMainAdmin {
    require(_heroNft != address(0), "401");
    heroNft = IGameNFT(_heroNft);
    energyManager = IEnergyManager(_energyManager);
    rewardManager = IRewardManager(_rewardManager);
  }
}

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

interface IEnergyManager {
  function updateEnergy(address _user, uint _consumeAmount) external returns (bool);
  function updatePoint(address _user, int _point) external;
  function getUserCurrentEnergy(address _user) external view returns (uint);
  function energies(address _user) external view returns (uint, uint, uint);
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

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

interface IPVP {
  function getUserTodayLose(address _user) external view returns (uint);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

interface IRewardManager {
  function addPVEReward(uint _mission, address _user, uint _amount) external returns (uint, bool);
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
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
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