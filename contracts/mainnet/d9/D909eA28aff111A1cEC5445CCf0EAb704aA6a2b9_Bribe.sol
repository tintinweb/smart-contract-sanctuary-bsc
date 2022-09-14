// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "../../interface/IBribe.sol";
import "../../interface/IERC721.sol";
import "../../interface/IVoter.sol";
import "../../interface/IVe.sol";
import "./MultiRewardsPoolBase.sol";

/// @title Bribes pay out rewards for a given pool based on the votes
///        that were received from the user (goes hand in hand with Gauges.vote())
contract Bribe is IBribe, MultiRewardsPoolBase {

  /// @dev Only voter can modify balances (since it only happens on vote())
  address public immutable voter;
  address public immutable ve;

  // Assume that will be created from voter contract through factory
  constructor(
    address _voter,
    address[] memory _allowedRewardTokens
  ) MultiRewardsPoolBase(address(0), _voter, _allowedRewardTokens) {
    voter = _voter;
    ve = IVoter(_voter).ve();
  }

  function getReward(uint tokenId, address[] memory tokens) external {
    require(IVe(ve).isApprovedOrOwner(msg.sender, tokenId), "Not token owner");
    _getReward(_tokenIdToAddress(tokenId), tokens, msg.sender);
  }

  /// @dev Used by Voter to allow batched reward claims
  function getRewardForOwner(uint tokenId, address[] memory tokens) external override {
    require(msg.sender == voter, "Not voter");
    address owner = IERC721(ve).ownerOf(tokenId);
    _getReward(_tokenIdToAddress(tokenId), tokens, owner);
  }

  /// @dev This is an external function, but internal notation is used
  ///      since it can only be called "internally" from Gauges
  function _deposit(uint amount, uint tokenId) external override {
    require(msg.sender == voter, "Not voter");
    require(amount > 0, "Zero amount");

    address adr = _tokenIdToAddress(tokenId);
    _increaseBalance(adr, amount);
    emit Deposit(adr, amount);
  }

  function _withdraw(uint amount, uint tokenId) external override {
    require(msg.sender == voter, "Not voter");
    require(amount > 0, "Zero amount");

    address adr = _tokenIdToAddress(tokenId);
    _decreaseBalance(adr, amount);
    emit Withdraw(adr, amount);
  }

  /// @dev Used to notify a gauge/bribe of a given reward,
  ///      this can create griefing attacks by extending rewards
  function notifyRewardAmount(address token, uint amount) external override {
    _notifyRewardAmount(token, amount);
  }

  // use tokenId instead of address for

  function tokenIdToAddress(uint tokenId) external pure returns (address) {
    return _tokenIdToAddress(tokenId);
  }

  function _tokenIdToAddress(uint tokenId) internal pure returns (address) {
    address adr = address(uint160(tokenId));
    require(_addressToTokenId(adr) == tokenId, "Wrong convert");
    return adr;
  }

  function addressToTokenId(address adr) external pure returns (uint) {
    return _addressToTokenId(adr);
  }

  function _addressToTokenId(address adr) internal pure returns (uint) {
    return uint(uint160(adr));
  }

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IBribe {

  function notifyRewardAmount(address token, uint amount) external;

  function _deposit(uint amount, uint tokenId) external;

  function _withdraw(uint amount, uint tokenId) external;

  function getRewardForOwner(uint tokenId, address[] memory tokens) external;

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IVoter {

  function ve() external view returns (address);

  function attachTokenToGauge(uint _tokenId, address account) external;

  function detachTokenFromGauge(uint _tokenId, address account) external;

  function emitDeposit(uint _tokenId, address account, uint amount) external;

  function emitWithdraw(uint _tokenId, address account, uint amount) external;

  function distribute(address _gauge) external;

  function notifyRewardAmount(uint amount) external;

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "./IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
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

pragma solidity 0.8.15;

interface IVe {

  enum DepositType {
    DEPOSIT_FOR_TYPE,
    CREATE_LOCK_TYPE,
    INCREASE_LOCK_AMOUNT,
    INCREASE_UNLOCK_TIME,
    MERGE_TYPE
  }

  struct Point {
    int128 bias;
    int128 slope; // # -dweight / dt
    uint ts;
    uint blk; // block
  }
  /* We cannot really do block numbers per se b/c slope is per time, not per block
  * and per block could be fairly bad b/c Ethereum changes blocktimes.
  * What we can do is to extrapolate ***At functions */

  struct LockedBalance {
    int128 amount;
    uint end;
  }

  function token() external view returns (address);

  function balanceOfNFT(uint) external view returns (uint);

  function isApprovedOrOwner(address, uint) external view returns (bool);

  function createLockFor(uint, uint, address) external returns (uint);

  function userPointEpoch(uint tokenId) external view returns (uint);

  function epoch() external view returns (uint);

  function userPointHistory(uint tokenId, uint loc) external view returns (Point memory);

  function pointHistory(uint loc) external view returns (Point memory);

  function checkpoint() external;

  function depositFor(uint tokenId, uint value) external;

  function attachToken(uint tokenId) external;

  function detachToken(uint tokenId) external;

  function voting(uint tokenId) external;

  function abstain(uint tokenId) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "../../interface/IERC20.sol";
import "../../interface/IMultiRewardsPool.sol";
import "../../lib/Math.sol";
import "../../lib/SafeERC20.sol";
import "../../lib/CheckpointLib.sol";
import "../Reentrancy.sol";

abstract contract MultiRewardsPoolBase is Reentrancy, IMultiRewardsPool {
  using SafeERC20 for IERC20;
  using CheckpointLib for mapping(uint => CheckpointLib.Checkpoint);

  /// @dev Operator can add/remove reward tokens
  address public operator;

  /// @dev The LP token that needs to be staked for rewards
  address public immutable override underlying;

  uint public override derivedSupply;
  mapping(address => uint) public override derivedBalances;

  /// @dev Rewards are released over 7 days
  uint internal constant DURATION = 7 days;
  uint internal constant PRECISION = 10 ** 18;
  uint internal constant MAX_REWARD_TOKENS = 10;

  /// Default snx staking contract implementation
  /// https://github.com/Synthetixio/synthetix/blob/develop/contracts/StakingRewards.sol

  /// @dev Reward rate with precision 1e18
  mapping(address => uint) public rewardRate;
  mapping(address => uint) public periodFinish;
  mapping(address => uint) public lastUpdateTime;
  mapping(address => uint) public rewardPerTokenStored;

  mapping(address => mapping(address => uint)) public lastEarn;
  mapping(address => mapping(address => uint)) public userRewardPerTokenStored;

  uint public override totalSupply;
  mapping(address => uint) public override balanceOf;

  address[] public override rewardTokens;
  mapping(address => bool) public override isRewardToken;

  /// @notice A record of balance checkpoints for each account, by index
  mapping(address => mapping(uint => CheckpointLib.Checkpoint)) public checkpoints;
  /// @notice The number of checkpoints for each account
  mapping(address => uint) public numCheckpoints;
  /// @notice A record of balance checkpoints for each token, by index
  mapping(uint => CheckpointLib.Checkpoint) public supplyCheckpoints;
  /// @notice The number of checkpoints
  uint public supplyNumCheckpoints;
  /// @notice A record of balance checkpoints for each token, by index
  mapping(address => mapping(uint => CheckpointLib.Checkpoint)) public rewardPerTokenCheckpoints;
  /// @notice The number of checkpoints for each token
  mapping(address => uint) public rewardPerTokenNumCheckpoints;

  event Deposit(address indexed from, uint amount);
  event Withdraw(address indexed from, uint amount);
  event NotifyReward(address indexed from, address indexed reward, uint amount);
  event ClaimRewards(address indexed from, address indexed reward, uint amount, address recepient);

  constructor(address _stake, address _operator, address[] memory _allowedRewardTokens) {
    underlying = _stake;
    operator = _operator;
    for (uint i; i < _allowedRewardTokens.length; i++) {
      if (_allowedRewardTokens[i] != address(0)) {
        _registerRewardToken(_allowedRewardTokens[i]);
      }
    }
  }

  modifier onlyOperator() {
    require(msg.sender == operator, "Not operator");
    _;
  }

  //**************************************************************************
  //************************ VIEWS *******************************************
  //**************************************************************************

  function rewardTokensLength() external view override returns (uint) {
    return rewardTokens.length;
  }

  function rewardPerToken(address token) external view returns (uint) {
    return _rewardPerToken(token);
  }

  function _rewardPerToken(address token) internal view returns (uint) {
    if (derivedSupply == 0) {
      return rewardPerTokenStored[token];
    }
    return rewardPerTokenStored[token]
    + (
    (_lastTimeRewardApplicable(token) - Math.min(lastUpdateTime[token], periodFinish[token]))
    * rewardRate[token]
    / derivedSupply
    );
  }

  function derivedBalance(address account) external view override returns (uint) {
    return _derivedBalance(account);
  }

  function left(address token) external view override returns (uint) {
    if (block.timestamp >= periodFinish[token]) return 0;
    uint _remaining = periodFinish[token] - block.timestamp;
    return _remaining * rewardRate[token] / PRECISION;
  }

  function earned(address token, address account) external view override returns (uint) {
    return _earned(token, account);
  }

  //**************************************************************************
  //************************ OPERATOR ACTIONS ********************************
  //**************************************************************************

  function registerRewardToken(address token) external onlyOperator {
    _registerRewardToken(token);
  }

  function _registerRewardToken(address token) internal {
    require(rewardTokens.length < MAX_REWARD_TOKENS, "Too many reward tokens");
    require(!isRewardToken[token], "Already registered");
    isRewardToken[token] = true;
    rewardTokens.push(token);
  }

  function removeRewardToken(address token) external onlyOperator {
    require(periodFinish[token] < block.timestamp, "Rewards not ended");
    require(isRewardToken[token], "Not reward token");

    isRewardToken[token] = false;
    uint length = rewardTokens.length;
    require(length > 3, "First 3 tokens should not be removed");
    // keep 3 tokens as guarantee against malicious actions
    // assume it will be CONE + pool tokens
    uint i = 3;
    bool found = false;
    for (; i < length; i++) {
      address t = rewardTokens[i];
      if (t == token) {
        found = true;
        break;
      }
    }
    require(found, "First tokens forbidden to remove");
    rewardTokens[i] = rewardTokens[length - 1];
    rewardTokens.pop();
  }

  //**************************************************************************
  //************************ USER ACTIONS ************************************
  //**************************************************************************

  function _deposit(uint amount) internal virtual lock {
    require(amount > 0, "Zero amount");
    _increaseBalance(msg.sender, amount);
    IERC20(underlying).safeTransferFrom(msg.sender, address(this), amount);
    emit Deposit(msg.sender, amount);
  }

  function _increaseBalance(address account, uint amount) internal virtual {
    _updateRewardForAllTokens();

    totalSupply += amount;
    balanceOf[account] += amount;

    _updateDerivedBalanceAndWriteCheckpoints(account);
  }

  function _withdraw(uint amount) internal lock virtual {
    _decreaseBalance(msg.sender, amount);
    IERC20(underlying).safeTransfer(msg.sender, amount);
    emit Withdraw(msg.sender, amount);
  }

  function _decreaseBalance(address account, uint amount) internal virtual {
    _updateRewardForAllTokens();

    totalSupply -= amount;
    balanceOf[account] -= amount;

    _updateDerivedBalanceAndWriteCheckpoints(account);
  }

  /// @dev Implement restriction checks!
  function _getReward(address account, address[] memory tokens, address recipient) internal lock virtual {

    for (uint i = 0; i < tokens.length; i++) {
      (rewardPerTokenStored[tokens[i]], lastUpdateTime[tokens[i]]) = _updateRewardPerToken(tokens[i], type(uint).max, true);

      uint _reward = _earned(tokens[i], account);
      lastEarn[tokens[i]][account] = block.timestamp;
      userRewardPerTokenStored[tokens[i]][account] = rewardPerTokenStored[tokens[i]];
      if (_reward > 0) {
        IERC20(tokens[i]).safeTransfer(recipient, _reward);
      }

      emit ClaimRewards(msg.sender, tokens[i], _reward, recipient);
    }

    _updateDerivedBalanceAndWriteCheckpoints(account);
  }

  function _updateDerivedBalanceAndWriteCheckpoints(address account) internal {
    uint __derivedBalance = derivedBalances[account];
    derivedSupply -= __derivedBalance;
    __derivedBalance = _derivedBalance(account);
    derivedBalances[account] = __derivedBalance;
    derivedSupply += __derivedBalance;

    _writeCheckpoint(account, __derivedBalance);
    _writeSupplyCheckpoint();
  }

  //**************************************************************************
  //************************ REWARDS CALCULATIONS ****************************
  //**************************************************************************

  // earned is an estimation, it won't be exact till the supply > rewardPerToken calculations have run
  function _earned(address token, address account) internal view returns (uint) {
    // zero checkpoints means zero deposits
    if (numCheckpoints[account] == 0) {
      return 0;
    }
    // last claim rewards time
    uint _startTimestamp = Math.max(lastEarn[token][account], rewardPerTokenCheckpoints[token][0].timestamp);

    // find an index of the balance that the user had on the last claim
    uint _startIndex = _getPriorBalanceIndex(account, _startTimestamp);
    uint _endIndex = numCheckpoints[account] - 1;

    uint reward = 0;

    // calculate previous snapshots if exist
    if (_endIndex > 0) {
      for (uint i = _startIndex; i <= _endIndex - 1; i++) {
        CheckpointLib.Checkpoint memory cp0 = checkpoints[account][i];
        CheckpointLib.Checkpoint memory cp1 = checkpoints[account][i + 1];
        (uint _rewardPerTokenStored0,) = _getPriorRewardPerToken(token, cp0.timestamp);
        (uint _rewardPerTokenStored1,) = _getPriorRewardPerToken(token, cp1.timestamp);
        reward += cp0.value * (_rewardPerTokenStored1 - _rewardPerTokenStored0) / PRECISION;
      }
    }

    CheckpointLib.Checkpoint memory cp = checkpoints[account][_endIndex];
    (uint _rewardPerTokenStored,) = _getPriorRewardPerToken(token, cp.timestamp);
    reward += cp.value * (_rewardPerToken(token) - Math.max(_rewardPerTokenStored, userRewardPerTokenStored[token][account])) / PRECISION;
    return reward;
  }

  function _derivedBalance(address account) internal virtual view returns (uint) {
    // supposed to be implemented in a parent contract
    return balanceOf[account];
  }

  /// @dev Update stored rewardPerToken values without the last one snapshot
  ///      If the contract will get "out of gas" error on users actions this will be helpful
  function batchUpdateRewardPerToken(address token, uint maxRuns) external {
    (rewardPerTokenStored[token], lastUpdateTime[token]) = _updateRewardPerToken(token, maxRuns, false);
  }

  function _updateRewardForAllTokens() internal {
    uint length = rewardTokens.length;
    for (uint i; i < length; i++) {
      address token = rewardTokens[i];
      (rewardPerTokenStored[token], lastUpdateTime[token]) = _updateRewardPerToken(token, type(uint).max, true);
    }
  }

  /// @dev Should be called only with properly updated snapshots, or with actualLast=false
  function _updateRewardPerToken(address token, uint maxRuns, bool actualLast) internal returns (uint, uint) {
    uint _startTimestamp = lastUpdateTime[token];
    uint reward = rewardPerTokenStored[token];

    if (supplyNumCheckpoints == 0) {
      return (reward, _startTimestamp);
    }

    if (rewardRate[token] == 0) {
      return (reward, block.timestamp);
    }
    uint _startIndex = _getPriorSupplyIndex(_startTimestamp);
    uint _endIndex = Math.min(supplyNumCheckpoints - 1, maxRuns);

    if (_endIndex > 0) {
      for (uint i = _startIndex; i <= _endIndex - 1; i++) {
        CheckpointLib.Checkpoint memory sp0 = supplyCheckpoints[i];
        if (sp0.value > 0) {
          CheckpointLib.Checkpoint memory sp1 = supplyCheckpoints[i + 1];
          (uint _reward, uint _endTime) = _calcRewardPerToken(
            token,
            sp1.timestamp,
            sp0.timestamp,
            sp0.value,
            _startTimestamp
          );
          reward += _reward;
          _writeRewardPerTokenCheckpoint(token, reward, _endTime);
          _startTimestamp = _endTime;
        }
      }
    }

    // need to override the last value with actual numbers only on deposit/withdraw/claim/notify actions
    if (actualLast) {
      CheckpointLib.Checkpoint memory sp = supplyCheckpoints[_endIndex];
      if (sp.value > 0) {
        (uint _reward,) = _calcRewardPerToken(token, _lastTimeRewardApplicable(token), Math.max(sp.timestamp, _startTimestamp), sp.value, _startTimestamp);
        reward += _reward;
        _writeRewardPerTokenCheckpoint(token, reward, block.timestamp);
        _startTimestamp = block.timestamp;
      }
    }

    return (reward, _startTimestamp);
  }

  function _calcRewardPerToken(
    address token,
    uint lastSupplyTs1,
    uint lastSupplyTs0,
    uint supply,
    uint startTimestamp
  ) internal view returns (uint, uint) {
    uint endTime = Math.max(lastSupplyTs1, startTimestamp);
    uint _periodFinish = periodFinish[token];
    return (
    (Math.min(endTime, _periodFinish) - Math.min(Math.max(lastSupplyTs0, startTimestamp), _periodFinish))
    * rewardRate[token] / supply
    , endTime);
  }

  /// @dev Returns the last time the reward was modified or periodFinish if the reward has ended
  function _lastTimeRewardApplicable(address token) internal view returns (uint) {
    return Math.min(block.timestamp, periodFinish[token]);
  }

  //**************************************************************************
  //************************ NOTIFY ******************************************
  //**************************************************************************

  function _notifyRewardAmount(address token, uint amount) internal lock virtual {
    require(token != underlying, "Wrong token for rewards");
    require(amount > 0, "Zero amount");
    require(isRewardToken[token], "Token not allowed");
    if (rewardRate[token] == 0) {
      _writeRewardPerTokenCheckpoint(token, 0, block.timestamp);
    }
    (rewardPerTokenStored[token], lastUpdateTime[token]) = _updateRewardPerToken(token, type(uint).max, true);

    if (block.timestamp >= periodFinish[token]) {
      IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
      rewardRate[token] = amount * PRECISION / DURATION;
    } else {
      uint _remaining = periodFinish[token] - block.timestamp;
      uint _left = _remaining * rewardRate[token];
      // not sure what the reason was in the original solidly implementation for this restriction
      // however, by design probably it is a good idea against human errors
      require(amount > _left / PRECISION, "Amount should be higher than remaining rewards");
      IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
      rewardRate[token] = (amount * PRECISION + _left) / DURATION;
    }

    periodFinish[token] = block.timestamp + DURATION;
    emit NotifyReward(msg.sender, token, amount);
  }

  //**************************************************************************
  //************************ CHECKPOINTS *************************************
  //**************************************************************************

  function getPriorBalanceIndex(address account, uint timestamp) external view returns (uint) {
    return _getPriorBalanceIndex(account, timestamp);
  }

  /// @notice Determine the prior balance for an account as of a block number
  /// @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
  /// @param account The address of the account to check
  /// @param timestamp The timestamp to get the balance at
  /// @return The balance the account had as of the given block
  function _getPriorBalanceIndex(address account, uint timestamp) internal view returns (uint) {
    uint nCheckpoints = numCheckpoints[account];
    if (nCheckpoints == 0) {
      return 0;
    }
    return checkpoints[account].findLowerIndex(nCheckpoints, timestamp);
  }

  function getPriorSupplyIndex(uint timestamp) external view returns (uint) {
    return _getPriorSupplyIndex(timestamp);
  }

  function _getPriorSupplyIndex(uint timestamp) internal view returns (uint) {
    uint nCheckpoints = supplyNumCheckpoints;
    if (nCheckpoints == 0) {
      return 0;
    }
    return supplyCheckpoints.findLowerIndex(nCheckpoints, timestamp);
  }

  function getPriorRewardPerToken(address token, uint timestamp) external view returns (uint, uint) {
    return _getPriorRewardPerToken(token, timestamp);
  }

  function _getPriorRewardPerToken(address token, uint timestamp) internal view returns (uint, uint) {
    uint nCheckpoints = rewardPerTokenNumCheckpoints[token];
    if (nCheckpoints == 0) {
      return (0, 0);
    }
    mapping(uint => CheckpointLib.Checkpoint) storage cps = rewardPerTokenCheckpoints[token];
    uint lower = cps.findLowerIndex(nCheckpoints, timestamp);
    CheckpointLib.Checkpoint memory cp = cps[lower];
    return (cp.value, cp.timestamp);
  }

  function _writeCheckpoint(address account, uint balance) internal {
    uint _timestamp = block.timestamp;
    uint _nCheckPoints = numCheckpoints[account];

    if (_nCheckPoints > 0 && checkpoints[account][_nCheckPoints - 1].timestamp == _timestamp) {
      checkpoints[account][_nCheckPoints - 1].value = balance;
    } else {
      checkpoints[account][_nCheckPoints] = CheckpointLib.Checkpoint(_timestamp, balance);
      numCheckpoints[account] = _nCheckPoints + 1;
    }
  }

  function _writeRewardPerTokenCheckpoint(address token, uint reward, uint timestamp) internal {
    uint _nCheckPoints = rewardPerTokenNumCheckpoints[token];

    if (_nCheckPoints > 0 && rewardPerTokenCheckpoints[token][_nCheckPoints - 1].timestamp == timestamp) {
      rewardPerTokenCheckpoints[token][_nCheckPoints - 1].value = reward;
    } else {
      rewardPerTokenCheckpoints[token][_nCheckPoints] = CheckpointLib.Checkpoint(timestamp, reward);
      rewardPerTokenNumCheckpoints[token] = _nCheckPoints + 1;
    }
  }

  function _writeSupplyCheckpoint() internal {
    uint _nCheckPoints = supplyNumCheckpoints;
    uint _timestamp = block.timestamp;

    if (_nCheckPoints > 0 && supplyCheckpoints[_nCheckPoints - 1].timestamp == _timestamp) {
      supplyCheckpoints[_nCheckPoints - 1].value = derivedSupply;
    } else {
      supplyCheckpoints[_nCheckPoints] = CheckpointLib.Checkpoint(_timestamp, derivedSupply);
      supplyNumCheckpoints = _nCheckPoints + 1;
    }
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

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

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

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
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

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

pragma solidity 0.8.15;

interface IMultiRewardsPool {

  function underlying() external view returns (address);

  function derivedSupply() external view returns (uint);

  function derivedBalances(address account) external view returns (uint);

  function totalSupply() external view returns (uint);

  function balanceOf(address account) external view returns (uint);

  function rewardTokens(uint id) external view returns (address);

  function isRewardToken(address token) external view returns (bool);

  function rewardTokensLength() external view returns (uint);

  function derivedBalance(address account) external view returns (uint);

  function left(address token) external view returns (uint);

  function earned(address token, address account) external view returns (uint);

  function registerRewardToken(address token) external;

  function removeRewardToken(address token) external;

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

library CheckpointLib {

  /// @notice A checkpoint for uint value
  struct Checkpoint {
    uint timestamp;
    uint value;
  }

  function findLowerIndex(mapping(uint => Checkpoint) storage checkpoints, uint size, uint timestamp) internal view returns (uint) {
    require(size != 0, "Empty checkpoints");

    // First check most recent value
    if (checkpoints[size - 1].timestamp <= timestamp) {
      return (size - 1);
    }

    // Next check implicit zero value
    if (checkpoints[0].timestamp > timestamp) {
      return 0;
    }

    uint lower = 0;
    uint upper = size - 1;
    while (upper > lower) {
      // ceil, avoiding overflow
      uint center = upper - (upper - lower) / 2;
      Checkpoint memory cp = checkpoints[center];
      if (cp.timestamp == timestamp) {
        return center;
      } else if (cp.timestamp < timestamp) {
        lower = center;
      } else {
        upper = center - 1;
      }
    }
    return lower;
  }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity 0.8.15;

import "../interface/IERC20.sol";
import "./Address.sol";

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

  function safeTransfer(
    IERC20 token,
    address to,
    uint value
  ) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint value
  ) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint value
  ) internal {
    uint newAllowance = token.allowance(address(this), spender) + value;
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
    if (returndata.length > 0) {
      // Return data is optional
      require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
  }

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

abstract contract Reentrancy {

  /// @dev simple re-entrancy check
  uint internal _unlocked = 1;

  modifier lock() {
    require(_unlocked == 1, "Reentrant call");
    _unlocked = 2;
    _;
    _unlocked = 1;
  }

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

library Math {

  function max(uint a, uint b) internal pure returns (uint) {
    return a >= b ? a : b;
  }

  function min(uint a, uint b) internal pure returns (uint) {
    return a < b ? a : b;
  }

  function positiveInt128(int128 value) internal pure returns (int128) {
    return value < 0 ? int128(0) : value;
  }

  function closeTo(uint a, uint b, uint target) internal pure returns (bool) {
    if (a > b) {
      if (a - b <= target) {
        return true;
      }
    } else {
      if (b - a <= target) {
        return true;
      }
    }
    return false;
  }

  function sqrt(uint y) internal pure returns (uint z) {
    if (y > 3) {
      z = y;
      uint x = y / 2 + 1;
      while (x < z) {
        z = x;
        x = (y / x + x) / 2;
      }
    } else if (y != 0) {
      z = 1;
    }
  }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity 0.8.15;

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

  function functionCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal returns (bytes memory) {
    require(isContract(target), "Address: call to non-contract");
    (bool success, bytes memory returndata) = target.call(data);
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