// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "./libs/fota/Auth.sol";
import "./libs/fota/MerkelProof.sol";
import "./interfaces/IFOTAToken.sol";

contract Reward is Auth {

  struct User {
    uint lastClaimedAt;
    uint allocated;
    uint totalClaimed;
  }

  bytes32 public rootHash;
  IFOTAToken public fotaToken;
  uint public constant secondsInOneMonth = 86400 * 30;
  uint public constant tgeRatio = 20;
  uint public startVestingAt;
  mapping(address => User) public users;

  event Claimed(address indexed user, uint amount, uint timestamp);
  event VestingStated(uint timestamp);

  function initialize(address _mainAdmin, address _fotaToken) public initializer {
    Auth.initialize(_mainAdmin);
    fotaToken = IFOTAToken(_fotaToken);
    rootHash = 0x8b209080c12f17ba0f81f82b1a76f07bcad049c52152255cf396ae49595a1039;
  }

  function setRootHash(bytes32 _rootHash) onlyMainAdmin external {
    rootHash = _rootHash;
  }

  function startVesting() onlyMainAdmin external {
    require(startVestingAt == 0, "Reward: vesting had started");
    startVestingAt = block.timestamp;
    emit VestingStated(startVestingAt);
  }

  function claim(uint _allocated, bytes32[] calldata _path) external {
    require(startVestingAt > 0, "Reward: please wait more time");
    _verifyUser(_allocated, _path);
    User storage user = users[msg.sender];
    uint claimingAmount;
    if (user.lastClaimedAt == 0) {
      user.allocated = _allocated;
      user.lastClaimedAt = startVestingAt;
      claimingAmount = user.allocated * tgeRatio / 100;
    } else {
      require(block.timestamp - user.lastClaimedAt >= secondsInOneMonth, "Reward: please comeback later");
      user.lastClaimedAt += secondsInOneMonth;
      claimingAmount = (user.allocated - user.totalClaimed) * 20 / 100;
    }
    user.totalClaimed += claimingAmount;
    require(fotaToken.balanceOf(address(this)) >= claimingAmount, "Reward: contract is insufficient balance");
    fotaToken.transfer(msg.sender, claimingAmount);
    emit Claimed(msg.sender, claimingAmount, block.timestamp);
  }

  // PRIVATE FUNCTIONS

  function _verifyUser(uint _allocated, bytes32[] calldata _path) private view {
    bytes32 hash = keccak256(abi.encodePacked(msg.sender, _allocated));
    require(MerkleProof.verify(_path, rootHash, hash), 'Reward: 400');
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

library MerkleProof {
  function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
    bytes32 computedHash = leaf;
    for (uint256 i = 0; i < proof.length; i++) {
      bytes32 proofElement = proof[i];

      if (computedHash <= proofElement) {
        computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
      } else {
        computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
      }
    }
    return computedHash == root;
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

import "../libs/zeppelin/token/BEP20/IBEP20.sol";

interface IFOTAToken is IBEP20 {
  function releaseGameAllocation(address _gamerAddress, uint _amount) external returns (bool);
  function releasePrivateSaleAllocation(address _buyerAddress, uint _amount) external returns (bool);
  function releaseSeedSaleAllocation(address _buyerAddress, uint _amount) external returns (bool);
  function releaseStrategicSaleAllocation(address _buyerAddress, uint _amount) external returns (bool);
  function burn(uint _amount) external;
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