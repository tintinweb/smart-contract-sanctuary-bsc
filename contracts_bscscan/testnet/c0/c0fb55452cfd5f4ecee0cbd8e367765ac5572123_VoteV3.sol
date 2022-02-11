/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

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
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
interface StrongPoolInterface {
  function mineFor(address miner, uint256 amount) external;
}
interface ServiceInterface {
  function claimingFeeNumerator() external view returns(uint256);

  function claimingFeeDenominator() external view returns(uint256);

  function doesNodeExist(address entity, uint128 nodeId) external view returns (bool);

  function getNodeId(address entity, uint128 nodeId) external view returns (bytes memory);

  function getReward(address entity, uint128 nodeId) external view returns (uint256);

  function getRewardByBlock(address entity, uint128 nodeId, uint256 blockNumber) external view returns (uint256);

  function getTraunch(address entity) external view returns (uint256);

  function isEntityActive(address entity) external view returns (bool);

  function claim(uint128 nodeId, uint256 blockNumber, bool toStrongPool) external payable;
}
library rewards {

    using SafeMath for uint256;

    function blocks(uint256 lastClaimedOnBlock, uint256 newRewardBlock, uint256 blockNumber) internal pure returns (uint256[2] memory) {
        if (lastClaimedOnBlock >= blockNumber) return [uint256(0), uint256(0)];

        if (blockNumber <= newRewardBlock || newRewardBlock == 0) {
            return [blockNumber.sub(lastClaimedOnBlock), uint256(0)];
        }
        else if (lastClaimedOnBlock >= newRewardBlock) {
            return [uint256(0), blockNumber.sub(lastClaimedOnBlock)];
        }
        else {
            return [newRewardBlock.sub(lastClaimedOnBlock), blockNumber.sub(newRewardBlock)];
        }
    }

}

contract VoteV3 {
  event Voted(address indexed voter, address indexed service, address indexed entity, uint256 amount);
  event RecalledVote(address indexed voter, address indexed service, address indexed entity, uint256 amount);
  event Claimed(address indexed claimer, uint256 amount);
  event VotesAdded(address indexed miner, uint256 amount);
  event VotesSubtracted(address indexed miner, uint256 amount);
  event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

  using SafeMath for uint256;

  StrongPoolInterface public strongPool;
  IERC20 public strongToken;

  bool public initDone;
  address public admin;
  address public pendingAdmin;
  address public superAdmin;
  address public pendingSuperAdmin;
  address public parameterAdmin;

  uint256 public rewardBalance;

  uint256 public voterRewardPerBlockNumerator;
  uint256 public voterRewardPerBlockDenominator;
  uint256 public entityRewardPerBlockNumerator;
  uint256 public entityRewardPerBlockDenominator;

  mapping(address => uint96) public balances;
  mapping(address => address) public delegates;

  mapping(address => mapping(uint32 => uint32)) public checkpointsFromBlock;
  mapping(address => mapping(uint32 => uint96)) public checkpointsVotes;
  mapping(address => uint32) public numCheckpoints;

  mapping(address => uint256) public voterVotesOut;
  uint256 public totalVotesOut;

  mapping(address => uint256) public serviceVotes;
  mapping(address => mapping(address => uint256)) public serviceEntityVotes;
  mapping(address => mapping(address => mapping(address => uint256))) public voterServiceEntityVotes;

  mapping(address => address[]) public voterServices;
  mapping(address => mapping(address => uint256)) public voterServiceIndex;

  mapping(address => mapping(address => address[])) public voterServiceEntities;
  mapping(address => mapping(address => mapping(address => uint256))) public voterServiceEntityIndex;

  mapping(address => uint256) public voterBlockLastClaimedOn;
  mapping(address => mapping(address => uint256)) public serviceEntityBlockLastClaimedOn;

  address[] public serviceContracts;
  mapping(address => uint256) public serviceContractIndex;
  mapping(address => bool) public serviceContractActive;

  uint256 public voterRewardPerBlockNumeratorNew;
  uint256 public voterRewardPerBlockDenominatorNew;
  uint256 public entityRewardPerBlockNumeratorNew;
  uint256 public entityRewardPerBlockDenominatorNew;
  uint256 public rewardPerBlockNewEffectiveBlock;

  function init(
    address strongTokenAddress,
    address strongPoolAddress,
    address adminAddress,
    address superAdminAddress,
    uint256 voterRewardPerBlockNumeratorValue,
    uint256 voterRewardPerBlockDenominatorValue,
    uint256 entityRewardPerBlockNumeratorValue,
    uint256 entityRewardPerBlockDenominatorValue
  ) public {
    require(!initDone, "init done");
    strongToken = IERC20(strongTokenAddress);
    strongPool = StrongPoolInterface(strongPoolAddress);
    admin = adminAddress;
    superAdmin = superAdminAddress;
    voterRewardPerBlockNumerator = voterRewardPerBlockNumeratorValue;
    voterRewardPerBlockDenominator = voterRewardPerBlockDenominatorValue;
    entityRewardPerBlockNumerator = entityRewardPerBlockNumeratorValue;
    entityRewardPerBlockDenominator = entityRewardPerBlockDenominatorValue;
    initDone = true;
  }

  // ADMIN
  // *************************************************************************************
  function updateParameterAdmin(address newParameterAdmin) public {
    require(newParameterAdmin != address(0), "zero");
    require(msg.sender == superAdmin);
    parameterAdmin = newParameterAdmin;
  }

  function setPendingAdmin(address newPendingAdmin) public {
    require(newPendingAdmin != address(0), "zero");
    require(msg.sender == admin, "not admin");
    pendingAdmin = newPendingAdmin;
  }

  function acceptAdmin() public {
    require(msg.sender == pendingAdmin && msg.sender != address(0), "not pendingAdmin");
    admin = pendingAdmin;
    pendingAdmin = address(0);
  }

  function setPendingSuperAdmin(address newPendingSuperAdmin) public {
    require(newPendingSuperAdmin != address(0), "zero");
    require(msg.sender == superAdmin, "not superAdmin");
    pendingSuperAdmin = newPendingSuperAdmin;
  }

  function acceptSuperAdmin() public {
    require(msg.sender == pendingSuperAdmin && msg.sender != address(0), "not pendingSuperAdmin");
    superAdmin = pendingSuperAdmin;
    pendingSuperAdmin = address(0);
  }

  // SERVICE CONTRACTS
  // *************************************************************************************
  function addServiceContract(address contr) public {
    require(contr != address(0), "zero");
    require(msg.sender == admin || msg.sender == parameterAdmin || msg.sender == superAdmin, "not an admin");
    if (serviceContracts.length != 0) {
      uint256 index = serviceContractIndex[contr];
      require(serviceContracts[index] != contr, "exists");
    }
    uint256 len = serviceContracts.length;
    serviceContractIndex[contr] = len;
    serviceContractActive[contr] = true;
    serviceContracts.push(contr);
  }

  function updateServiceContractActiveStatus(address contr, bool activeStatus) public {
    require(contr != address(0), "zero");
    require(msg.sender == admin || msg.sender == parameterAdmin || msg.sender == superAdmin, "not an admin");
    require(serviceContracts.length > 0, "zero");
    uint256 index = serviceContractIndex[contr];
    require(serviceContracts[index] == contr, "not exists");
    serviceContractActive[contr] = activeStatus;
  }

  function getServiceContracts() public view returns (address[] memory) {
    return serviceContracts;
  }

  // REWARD
  // *************************************************************************************
  function updateVoterRewardPerBlock(uint256 numerator, uint256 denominator) public {
    require(msg.sender == admin || msg.sender == parameterAdmin || msg.sender == superAdmin, "not an admin");
    require(denominator != 0, "invalid value");
    voterRewardPerBlockNumerator = numerator;
    voterRewardPerBlockDenominator = denominator;
  }

  function updateEntityRewardPerBlock(uint256 numerator, uint256 denominator) public {
    require(msg.sender == admin || msg.sender == parameterAdmin || msg.sender == superAdmin, "not an admin");
    require(denominator != 0, "invalid value");
    entityRewardPerBlockNumerator = numerator;
    entityRewardPerBlockDenominator = denominator;
  }

  function deposit(uint256 amount) public {
    require(msg.sender == superAdmin, "not an admin");
    require(amount > 0, "zero");
    strongToken.transferFrom(msg.sender, address(this), amount);
    rewardBalance = rewardBalance.add(amount);
  }

  function withdraw(address destination, uint256 amount) public {
    require(msg.sender == superAdmin, "not an admin");
    require(amount > 0, "zero");
    require(rewardBalance >= amount, "not enough");
    strongToken.transfer(destination, amount);
    rewardBalance = rewardBalance.sub(amount);
  }

  // CORE
  // *************************************************************************************
  function getVoterServices(address voter) public view returns (address[] memory) {
    return voterServices[voter];
  }

  function getVoterServiceEntities(address voter, address service) public view returns (address[] memory) {
    return voterServiceEntities[voter][service];
  }

  function getVoterReward(address voter) public view returns (uint256) {
    uint256 blockLastClaimedOn = voterBlockLastClaimedOn[voter];

    if (totalVotesOut == 0) return 0;
    if (blockLastClaimedOn == 0) return 0;

    uint256[2] memory rewardBlocks = rewards.blocks(blockLastClaimedOn, rewardPerBlockNewEffectiveBlock, block.number);
    uint256 rewardOld = voterRewardPerBlockNumerator > 0 ? rewardBlocks[0].mul(voterRewardPerBlockNumerator).div(voterRewardPerBlockDenominator) : 0;
    uint256 rewardNew = voterRewardPerBlockNumeratorNew > 0 ? rewardBlocks[1].mul(voterRewardPerBlockNumeratorNew).div(voterRewardPerBlockDenominatorNew) : 0;

    return rewardOld.add(rewardNew).mul(voterVotesOut[voter]).div(totalVotesOut);
  }

  function getEntityReward(address service, address entity) public view returns (uint256) {
    uint256 blockLastClaimedOn = serviceEntityBlockLastClaimedOn[service][entity];

    if (serviceVotes[service] == 0) return 0;
    if (blockLastClaimedOn == 0) return 0;

    uint256[2] memory rewardBlocks = rewards.blocks(blockLastClaimedOn, rewardPerBlockNewEffectiveBlock, block.number);
    uint256 rewardOld = entityRewardPerBlockNumerator > 0 ? rewardBlocks[0].mul(entityRewardPerBlockNumerator).div(entityRewardPerBlockDenominator) : 0;
    uint256 rewardNew = entityRewardPerBlockNumeratorNew > 0 ? rewardBlocks[1].mul(entityRewardPerBlockNumeratorNew).div(entityRewardPerBlockDenominatorNew) : 0;

    return rewardOld.add(rewardNew).mul(serviceEntityVotes[service][entity]).div(serviceVotes[service]);
  }

  function vote(
    address service,
    address entity,
    uint256 amount
  ) public {
    require(amount > 0, "zero");
    require(uint256(_getAvailableServiceEntityVotes(msg.sender)) >= amount, "not enough");
    require(serviceContractActive[service], "service not active");
    require(ServiceInterface(service).isEntityActive(entity), "entity not active");

    uint256 serviceIndex = voterServiceIndex[msg.sender][service];
    if (voterServices[msg.sender].length == 0 || voterServices[msg.sender][serviceIndex] != service) {
      uint256 len = voterServices[msg.sender].length;
      voterServiceIndex[msg.sender][service] = len;
      voterServices[msg.sender].push(service);
    }

    uint256 entityIndex = voterServiceEntityIndex[msg.sender][service][entity];
    if (
      voterServiceEntities[msg.sender][service].length == 0 ||
      voterServiceEntities[msg.sender][service][entityIndex] != entity
    ) {
      uint256 len = voterServiceEntities[msg.sender][service].length;
      voterServiceEntityIndex[msg.sender][service][entity] = len;
      voterServiceEntities[msg.sender][service].push(entity);
    }

    if (block.number > voterBlockLastClaimedOn[msg.sender]) {
      uint256 reward = getVoterReward(msg.sender);
      if (reward > 0) {
        rewardBalance = rewardBalance.sub(reward);
        strongToken.approve(address(strongPool), reward);
        strongPool.mineFor(msg.sender, reward);
        voterBlockLastClaimedOn[msg.sender] = block.number;
      }
    }

    if (block.number > serviceEntityBlockLastClaimedOn[service][entity]) {
      uint256 reward = getEntityReward(service, entity);
      if (reward > 0) {
        rewardBalance = rewardBalance.sub(reward);
        strongToken.approve(address(strongPool), reward);
        strongPool.mineFor(entity, reward);
        serviceEntityBlockLastClaimedOn[service][entity] = block.number;
      }
    }

    serviceVotes[service] = serviceVotes[service].add(amount);
    serviceEntityVotes[service][entity] = serviceEntityVotes[service][entity].add(amount);
    voterServiceEntityVotes[msg.sender][service][entity] = voterServiceEntityVotes[msg.sender][service][entity].add(
      amount
    );

    voterVotesOut[msg.sender] = voterVotesOut[msg.sender].add(amount);
    totalVotesOut = totalVotesOut.add(amount);

    if (voterBlockLastClaimedOn[msg.sender] == 0) {
      voterBlockLastClaimedOn[msg.sender] = block.number;
    }

    if (serviceEntityBlockLastClaimedOn[service][entity] == 0) {
      serviceEntityBlockLastClaimedOn[service][entity] = block.number;
    }

    emit Voted(msg.sender, service, entity, amount);
  }

  function recallVote(
    address service,
    address entity,
    uint256 amount
  ) public {
    require(amount > 0, "zero");
    require(voterServiceEntityVotes[msg.sender][service][entity] >= amount, "not enough");

    if (block.number > voterBlockLastClaimedOn[msg.sender]) {
      uint256 reward = getVoterReward(msg.sender);
      if (reward > 0) {
        rewardBalance = rewardBalance.sub(reward);
        strongToken.approve(address(strongPool), reward);
        strongPool.mineFor(msg.sender, reward);
        voterBlockLastClaimedOn[msg.sender] = block.number;
      }
    }

    if (block.number > serviceEntityBlockLastClaimedOn[service][entity]) {
      uint256 reward = getEntityReward(service, entity);
      if (reward > 0) {
        rewardBalance = rewardBalance.sub(reward);
        strongToken.approve(address(strongPool), reward);
        strongPool.mineFor(entity, reward);
        serviceEntityBlockLastClaimedOn[service][entity] = block.number;
      }
    }

    serviceVotes[service] = serviceVotes[service].sub(amount);
    serviceEntityVotes[service][entity] = serviceEntityVotes[service][entity].sub(amount);
    voterServiceEntityVotes[msg.sender][service][entity] = voterServiceEntityVotes[msg.sender][service][entity].sub(
      amount
    );

    voterVotesOut[msg.sender] = voterVotesOut[msg.sender].sub(amount);
    totalVotesOut = totalVotesOut.sub(amount);

    if (voterVotesOut[msg.sender] == 0) {
      voterBlockLastClaimedOn[msg.sender] = 0;
    }

    if (serviceEntityVotes[service][entity] == 0) {
      serviceEntityBlockLastClaimedOn[service][entity] = 0;
    }
    emit RecalledVote(msg.sender, service, entity, amount);
  }

  function voterClaim() public {
    require(voterBlockLastClaimedOn[msg.sender] != 0, "error");
    require(block.number > voterBlockLastClaimedOn[msg.sender], "too soon");
    uint256 reward = getVoterReward(msg.sender);
    require(reward > 0, "no reward");
    rewardBalance = rewardBalance.sub(reward);
    strongToken.approve(address(strongPool), reward);
    strongPool.mineFor(msg.sender, reward);
    voterBlockLastClaimedOn[msg.sender] = block.number;
    emit Claimed(msg.sender, reward);
  }

  function entityClaim(address service) public {
    require(serviceEntityBlockLastClaimedOn[service][msg.sender] != 0, "error");
    require(block.number > serviceEntityBlockLastClaimedOn[service][msg.sender], "too soon");
    require(ServiceInterface(service).isEntityActive(msg.sender), "not active");
    uint256 reward = getEntityReward(service, msg.sender);
    require(reward > 0, "no reward");
    rewardBalance = rewardBalance.sub(reward);
    strongToken.approve(address(strongPool), reward);
    strongPool.mineFor(msg.sender, reward);
    serviceEntityBlockLastClaimedOn[service][msg.sender] = block.number;
    emit Claimed(msg.sender, reward);
  }

  function updateVotes(
    address voter,
    uint256 rawAmount,
    bool adding
  ) public {
    require(msg.sender == address(strongPool), "not strongPool");
    uint96 amount = _safe96(rawAmount, "amount exceeds 96 bits");
    if (adding) {
      _addVotes(voter, amount);
    } else {
      require(_getAvailableServiceEntityVotes(voter) >= amount, "recall votes");
      _subVotes(voter, amount);
    }
  }

  function getCurrentProposalVotes(address account) external view returns (uint96) {
    return _getCurrentProposalVotes(account);
  }

  function getPriorProposalVotes(address account, uint256 blockNumber) external view returns (uint96) {
    require(blockNumber < block.number, "not yet determined");
    uint32 nCheckpoints = numCheckpoints[account];
    if (nCheckpoints == 0) {
      return 0;
    }
    if (checkpointsFromBlock[account][nCheckpoints - 1] <= blockNumber) {
      return checkpointsVotes[account][nCheckpoints - 1];
    }
    if (checkpointsFromBlock[account][0] > blockNumber) {
      return 0;
    }
    uint32 lower = 0;
    uint32 upper = nCheckpoints - 1;
    while (upper > lower) {
      uint32 center = upper - (upper - lower) / 2;
      uint32 fromBlock = checkpointsFromBlock[account][center];
      uint96 votes = checkpointsVotes[account][center];
      if (fromBlock == blockNumber) {
        return votes;
      } else if (fromBlock < blockNumber) {
        lower = center;
      } else {
        upper = center - 1;
      }
    }
    return checkpointsVotes[account][lower];
  }

  function getAvailableServiceEntityVotes(address account) public view returns (uint96) {
    return _getAvailableServiceEntityVotes(account);
  }

  // SUPPORT
  // *************************************************************************************
  function _addVotes(address voter, uint96 amount) internal {
    require(voter != address(0), "zero address");
    balances[voter] = _add96(balances[voter], amount, "vote amount overflows");
    _addDelegates(voter, amount);
    emit VotesAdded(voter, amount);
  }

  function _subVotes(address voter, uint96 amount) internal {
    balances[voter] = _sub96(balances[voter], amount, "vote amount exceeds balance");
    _subtractDelegates(voter, amount);
    emit VotesSubtracted(voter, amount);
  }

  function _addDelegates(address miner, uint96 amount) internal {
    if (delegates[miner] == address(0)) {
      delegates[miner] = miner;
    }
    address currentDelegate = delegates[miner];
    _moveDelegates(address(0), currentDelegate, amount);
  }

  function _subtractDelegates(address miner, uint96 amount) internal {
    address currentDelegate = delegates[miner];
    _moveDelegates(currentDelegate, address(0), amount);
  }

  function _moveDelegates(
    address srcRep,
    address dstRep,
    uint96 amount
  ) internal {
    if (srcRep != dstRep && amount > 0) {
      if (srcRep != address(0)) {
        uint32 srcRepNum = numCheckpoints[srcRep];
        uint96 srcRepOld = srcRepNum > 0 ? checkpointsVotes[srcRep][srcRepNum - 1] : 0;
        uint96 srcRepNew = _sub96(srcRepOld, amount, "vote amount underflows");
        _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
      }
      if (dstRep != address(0)) {
        uint32 dstRepNum = numCheckpoints[dstRep];
        uint96 dstRepOld = dstRepNum > 0 ? checkpointsVotes[dstRep][dstRepNum - 1] : 0;
        uint96 dstRepNew = _add96(dstRepOld, amount, "vote amount overflows");
        _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
      }
    }
  }

  function _writeCheckpoint(
    address delegatee,
    uint32 nCheckpoints,
    uint96 oldVotes,
    uint96 newVotes
  ) internal {
    uint32 blockNumber = _safe32(block.number, "block number exceeds 32 bits");
    if (nCheckpoints > 0 && checkpointsFromBlock[delegatee][nCheckpoints - 1] == blockNumber) {
      checkpointsVotes[delegatee][nCheckpoints - 1] = newVotes;
    } else {
      checkpointsFromBlock[delegatee][nCheckpoints] = blockNumber;
      checkpointsVotes[delegatee][nCheckpoints] = newVotes;
      numCheckpoints[delegatee] = nCheckpoints + 1;
    }

    emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
  }

  function _safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {
    require(n < 2**32, errorMessage);
    return uint32(n);
  }

  function _safe96(uint256 n, string memory errorMessage) internal pure returns (uint96) {
    require(n < 2**96, errorMessage);
    return uint96(n);
  }

  function _add96(
    uint96 a,
    uint96 b,
    string memory errorMessage
  ) internal pure returns (uint96) {
    uint96 c = a + b;
    require(c >= a, errorMessage);
    return c;
  }

  function _sub96(
    uint96 a,
    uint96 b,
    string memory errorMessage
  ) internal pure returns (uint96) {
    require(b <= a, errorMessage);
    return a - b;
  }

  function _getCurrentProposalVotes(address account) internal view returns (uint96) {
    uint32 nCheckpoints = numCheckpoints[account];
    return nCheckpoints > 0 ? checkpointsVotes[account][nCheckpoints - 1] : 0;
  }

  function _getAvailableServiceEntityVotes(address account) internal view returns (uint96) {
    uint96 proposalVotes = _getCurrentProposalVotes(account);
    return proposalVotes == 0 ? 0 : proposalVotes - _safe96(voterVotesOut[account], "voterVotesOut exceeds 96 bits");
  }

  function updateRewardPerBlockNew(
    uint256 numeratorVoter,
    uint256 denominatorVoter,
    uint256 numeratorEntity,
    uint256 denominatorEntity,
    uint256 effectiveBlock
  ) public {
    require(msg.sender == admin || msg.sender == parameterAdmin || msg.sender == superAdmin, "not admin");

    voterRewardPerBlockNumeratorNew = numeratorVoter;
    voterRewardPerBlockDenominatorNew = denominatorVoter;
    entityRewardPerBlockNumeratorNew = numeratorEntity;
    entityRewardPerBlockDenominatorNew = denominatorEntity;
    rewardPerBlockNewEffectiveBlock = effectiveBlock != 0 ? effectiveBlock : block.number;
  }
}