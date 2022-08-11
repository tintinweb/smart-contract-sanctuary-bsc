// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.5;
pragma abicoder v2;

import {IGovernanceStrategy} from '../interfaces/IGovernanceStrategy.sol';
import {IGovernancePowerDelegationToken} from '../interfaces/IGovernancePowerDelegationToken.sol';

/**
 * @title Governance Strategy contract
 * @dev Smart contract containing logic to measure users' relative power to propose and vote.
 * User Power = User Power from OceanDrive Token + User Power from stkOceanDrive Token.
 * User Power from Token = Token Power + Token Power as Delegatee [- Token Power if user has delegated]
 * Two wrapper functions linked to OceanDrive Tokens's GovernancePowerDelegationERC20.sol implementation
 * - getPropositionPowerAt: fetching a user Proposition Power at a specified block
 * - getVotingPowerAt: fetching a user Voting Power at a specified block
 * @author Aave
 **/
contract GovernanceStrategy is IGovernanceStrategy {
  address public override immutable OCDR;
  address public immutable STK_OCDR;

  /**
   * @dev Constructor, register tokens used for Voting and Proposition Powers.
   * @param ocdr The address of the OCDR Token contract.
   * @param stkOcdr The address of the stkOCDR Token Contract
   **/
  constructor(address ocdr, address stkOcdr) {
    OCDR = ocdr;
    STK_OCDR = stkOcdr;
  }

  /**
   * @dev Returns the total supply of Proposition Tokens Available for Governance
   * = OCDR Available for governance      + stkOCDR available
   * The supply of OCDR staked in stkOCDR are not taken into account so:
   * = (Supply of OCDR - OCDR in stkOCDR) + (Supply of stkOCDR)
   * = Supply of OCDR, Since the supply of stkOCDR is equal to the number of OCDR staked
   * @param blockNumber Blocknumber at which to evaluate
   * @return total supply at blockNumber
   **/
  function getTotalPropositionSupplyAt(uint256 blockNumber) public view override returns (uint256) {
    return IGovernancePowerDelegationToken(OCDR).totalSupplyAt(blockNumber);
  }

  /**
   * @dev Returns the total supply of Outstanding Voting Tokens 
   * @param blockNumber Blocknumber at which to evaluate
   * @return total supply at blockNumber
   **/
  function getTotalVotingSupplyAt(uint256 blockNumber) public view override returns (uint256) {
    return getTotalPropositionSupplyAt(blockNumber);
  }

  /**
   * @dev Returns the Proposition Power of a user at a specific block number.
   * @param user Address of the user.
   * @param blockNumber Blocknumber at which to fetch Proposition Power
   * @return Power number
   **/
  function getPropositionPowerAt(address user, uint256 blockNumber)
    public
    view
    override
    returns (uint256)
  {
    return
      _getPowerByTypeAt(user, blockNumber, IGovernancePowerDelegationToken.DelegationType.PROPOSITION_POWER);
  }

  /**
   * @dev Returns the Vote Power of a user at a specific block number.
   * @param user Address of the user.
   * @param blockNumber Blocknumber at which to fetch Vote Power
   * @return Vote number
   **/
  function getVotingPowerAt(address user, uint256 blockNumber)
    public
    view
    override
    returns (uint256)
  {
    return _getPowerByTypeAt(user, blockNumber, IGovernancePowerDelegationToken.DelegationType.VOTING_POWER);
  }

  function _getPowerByTypeAt(
    address user,
    uint256 blockNumber,
    IGovernancePowerDelegationToken.DelegationType powerType
  ) internal view returns (uint256) {
    return
      IGovernancePowerDelegationToken(OCDR).getPowerAtBlock(user, blockNumber, powerType) +
      IGovernancePowerDelegationToken(STK_OCDR).getPowerAtBlock(user, blockNumber, powerType);
  }
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.5;
pragma abicoder v2;

interface IGovernanceStrategy {
  /**
   * @return OCDR token address
   */
  function OCDR() external view returns (address);
  /**
   * @dev Returns the Proposition Power of a user at a specific block number.
   * @param user Address of the user.
   * @param blockNumber Blocknumber at which to fetch Proposition Power
   * @return Power number
   **/
  function getPropositionPowerAt(address user, uint256 blockNumber) external view returns (uint256);
  /**
   * @dev Returns the total supply of Outstanding Proposition Tokens 
   * @param blockNumber Blocknumber at which to evaluate
   * @return total supply at blockNumber
   **/
  function getTotalPropositionSupplyAt(uint256 blockNumber) external view returns (uint256);
  /**
   * @dev Returns the total supply of Outstanding Voting Tokens 
   * @param blockNumber Blocknumber at which to evaluate
   * @return total supply at blockNumber
   **/
  function getTotalVotingSupplyAt(uint256 blockNumber) external view returns (uint256);
  /**
   * @dev Returns the Vote Power of a user at a specific block number.
   * @param user Address of the user.
   * @param blockNumber Blocknumber at which to fetch Vote Power
   * @return Vote number
   **/
  function getVotingPowerAt(address user, uint256 blockNumber) external view returns (uint256);
}

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.5;

interface IGovernancePowerDelegationToken {
  /// @dev snapshot of a value on a specific block, used for votes
  struct Snapshot {
    uint128 blockNumber;
    uint128 value;
  }

  /// @dev snapshot of a total supply on a specific block, used for votes
  struct TotalSupplySnapshot {
    mapping(uint256 => Snapshot) snapshots;
    uint256 snapshotsCount;
  }

  enum DelegationType {VOTING_POWER, PROPOSITION_POWER}

  /**
   * @dev emitted when a user delegates to another
   * @param delegator the delegator
   * @param delegatee the delegatee
   * @param delegationType the type of delegation (VOTING_POWER, PROPOSITION_POWER)
   **/
  event DelegateChanged(
    address indexed delegator,
    address indexed delegatee,
    DelegationType delegationType
  );

  /**
   * @dev emitted when an action changes the delegated power of a user
   * @param user the user which delegated power has changed
   * @param amount the amount of delegated power for the user
   * @param delegationType the type of delegation (VOTING_POWER, PROPOSITION_POWER)
   **/
  event DelegatedPowerChanged(address indexed user, uint256 amount, DelegationType delegationType);

  /**
   * @dev delegates the specific power to a delegatee
   * @param delegatee the user which delegated power has changed
   * @param delegationType the type of delegation (VOTING_POWER, PROPOSITION_POWER)
   **/
  function delegateByType(address delegatee, DelegationType delegationType) external virtual;
  /**
   * @dev delegates all the powers to a specific user
   * @param delegatee the user to which the power will be delegated
   **/
  function delegate(address delegatee) external virtual;
  /**
   * @dev returns the delegatee of an user
   * @param delegator the address of the delegator
   **/
  function getDelegateeByType(address delegator, DelegationType delegationType)
    external
    virtual
    view
    returns (address);

  /**
   * @dev returns the current delegated power of a user. The current power is the
   * power delegated at the time of the last snapshot
   * @param user the user
   **/
  function getPowerCurrent(address user, DelegationType delegationType)
    external
    virtual
    view
    returns (uint256);

  /**
   * @dev returns the delegated power of a user at a certain block
   * @param user the user
   **/
  function getPowerAtBlock(
    address user,
    uint256 blockNumber,
    DelegationType delegationType
  ) external virtual view returns (uint256);

  /**
   * @dev returns the total supply at a certain block number
   * used by the voting strategy contracts to calculate the total votes needed for threshold/quorum
   * In this initial implementation with no OCDR minting, only with OCDR burn
   * A function should to be changed in case a mint function is added to the OCDR token in the future
   **/
  function totalSupplyAt(uint256 blockNumber) external virtual view returns (uint256);
}