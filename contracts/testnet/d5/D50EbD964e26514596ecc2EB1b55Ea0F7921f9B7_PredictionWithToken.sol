// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../access/Ownable.sol";
import "../../utils/Pausable.sol";
import "../../utils/ReentrancyGuard.sol";
import "../../token/ERC20/IERC20.sol";
import "../../utils/libraries/SafeERC20.sol";

contract PredictionWithToken is Ownable, Pausable, ReentrancyGuard {
  using SafeERC20 for IERC20;

  enum Position {
    Team1,
    Team2
  }

  struct Match {
    string matchName;
    uint256 epoch;
    uint256 startTime;
    uint256 endTime;
    uint256 totalAmount;
    uint256 team1Amount;
    uint256 team2Amount;
    uint256 rewardBaseCalAmount;
    uint256 rewardAmount;
    uint256[2] scores;
    bool finalized;
  }

  struct PredictInfo {
    Position position;
    uint256 amount;
    bool claimed;
  }

  uint256 public constant MAX_PROTOCOL_FEE = 1000;
  uint256 public constant BUFFER_SECOND = 300;

  IERC20 public immutable token;
  IERC20 public immutable ssp;
  address public admin;
  address public treasury;
  uint256 public minPredictAmount;
  uint256 public sspFee;
  uint256 public protocolFee;
  uint256 public protocolAmount;
  uint256 public currentEpoch;

  mapping(uint256 => mapping(address => PredictInfo)) public ledger;
  mapping(uint256 => Match) public matches;
  mapping(address => uint256[]) public userMatches;

  event Predict(address indexed sender, uint256 indexed epoch, uint256 amount, Position position);
  event Claim(address indexed sender, uint256 indexed epoch, uint256 indexed amount);
  event MatchCreated(uint256 indexed epoch, string matchName);
  event MatchFinalized(uint256 indexed epoch, uint256[2] scores);
  event RewardsCalculated(uint256 indexed epoch, uint256 rewardBaseCalAmount, uint256 rewardAmount, uint256 protocolAmount);

  event NewAdmin(address admin);
  event NewMinPredictAmount(uint256 indexed epoch, uint256 minPredictAmount);
  event NewProtocolFee(uint256 timestamp, uint256 protocolFee);
  event NewSSPFee(uint256 timestamp, uint256 sspFee);
  event NewTreasury(address treasury);
  event Pause(uint256 indexed epoch);
  event Unpause(uint256 indexed epoch);
  event ProtocolClaim(uint256 amount);
  event WithdrawToken(address indexed token, uint256 amount);

  modifier onlyAdmin() {
    require(_msgSender() == admin, "PWT: not admin");
    _;
  }

  modifier notContract() {
    require(!_isContract(_msgSender()), "PWT: is contract");
    require(_msgSender() == tx.origin, "PWT: proxy contract");
    _;
  }

  constructor(
    address _token,
    address _ssp,
    address _admin,
    address _treasury,
    uint256 _protocolFee
  ) {
    require(_protocolFee <= MAX_PROTOCOL_FEE, "PWT: high protocol fee");
    token = IERC20(_token);
    ssp = IERC20(_ssp);
    admin = _admin;
    treasury = _treasury;
    minPredictAmount = 1e9;
    sspFee = 1e19;
    protocolFee = _protocolFee;
  }

  function getUserMatches(address user, uint256 cursor, uint256 size) external view returns (uint256[] memory, PredictInfo[] memory, uint256) {
    uint256 length = size;
    if (length > userMatches[user].length - cursor) {
      length = userMatches[user].length - cursor;
    }

    uint256[] memory values = new uint256[](length);
    PredictInfo[] memory predictInfo = new PredictInfo[](length);

    for (uint256 i = 0; i < length; i++) {
      values[i] = userMatches[user][cursor + i];
      predictInfo[i] = ledger[values[i]][user];
    }

    return (values, predictInfo, cursor + length);
  }

  function getUserRoundsLength(address user) external view returns (uint256) {
    return userMatches[user].length;
  }

  function claimable(uint256 epoch, address user) public view returns (bool) {
    PredictInfo memory predictInfo = ledger[epoch][user];
    Match memory _match = matches[epoch];

    return _match.finalized &&
      predictInfo.amount != 0 &&
      !predictInfo.claimed &&
      (_match.scores[0] == _match.scores[1] ||
      (_match.scores[0] > _match.scores[1] && predictInfo.position == Position.Team1) ||
      (_match.scores[0] < _match.scores[1] && predictInfo.position == Position.Team2));
  }

  function refundable(uint256 epoch, address user) public view returns (bool) {
    PredictInfo memory predictInfo = ledger[epoch][user];
    Match memory _match = matches[epoch];
    return !_match.finalized &&
      !predictInfo.claimed &&
      block.timestamp < _match.endTime + BUFFER_SECOND &&
      predictInfo.amount != 0;
  }

  function pause() external whenNotPaused onlyAdmin {
    _pause();
    emit Pause(currentEpoch);
  }

  function unpause() external whenPaused onlyAdmin {
    _unpause();
    emit Unpause(currentEpoch);
  }

  function setAdmin(address _admin) external onlyOwner {
    require(_admin != address(0), "PWT: zero address");
    admin = _admin;
    emit NewAdmin(_admin);
  }

  function setSSPFee(uint256 fee) public whenPaused onlyAdmin {
    sspFee = fee;
    emit NewSSPFee(block.timestamp, fee);
  }

  function setProtocolFee(uint256 fee) public whenPaused onlyAdmin {
    require(fee <= MAX_PROTOCOL_FEE, "PWT: high protocol fee");
    protocolFee = fee;
    emit NewProtocolFee(block.timestamp, fee);
  }

  function setTreasury(address _treasury) external onlyAdmin {
    require(_treasury != address(0), "PWT: zero address");
    treasury = _treasury;
    emit NewTreasury(_treasury);
  }

  function setMinPredictAmount(uint256 _minPredictAmount) external whenPaused onlyAdmin {
    require(_minPredictAmount != 0, "PWT: 0 amount");
    minPredictAmount = _minPredictAmount;
    emit NewMinPredictAmount(currentEpoch, _minPredictAmount);
  }

  function claimProtocol() external onlyAdmin nonReentrant {
    uint256 currentprotocolAmount = protocolAmount;
    token.safeTransfer(treasury, currentprotocolAmount);
    protocolAmount = 0;

    emit ProtocolClaim(currentprotocolAmount);
  }

  function withdrawToken(address _token, uint256 _amount) external onlyOwner {
    require(_token != address(token), "PWT: base token");
    IERC20(_token).safeTransfer(address(_msgSender()), _amount);
    emit WithdrawToken(_token, _amount);
  }

  function createMatch(string memory matchName, uint256 startTime) external whenNotPaused onlyAdmin {
    ++currentEpoch;
    _createMatch(currentEpoch, matchName, startTime);
  }

  function finaliseMatch(uint256 epoch, uint256[2] memory scores) external whenNotPaused onlyAdmin {
    _finaliseMatch(epoch, scores);
    _calculateRewards(epoch);
  }

  function predict(uint256 epoch, Position position, uint256 amount) external whenNotPaused nonReentrant notContract {
    require(_predictable(epoch), "PWT: match not predictable");
    require(amount >= minPredictAmount, "PWT: < minPredictAmount");
    require(ledger[epoch][_msgSender()].amount == 0, "PWT: only one predict");

    if (epoch > 1) {
      ssp.safeTransferFrom(_msgSender(), treasury, sspFee);
    }

    token.safeTransferFrom(_msgSender(), address(this), amount);
    Match storage _match = matches[epoch];
    _match.totalAmount += amount;
    if (position == Position.Team1) {
      _match.team1Amount += amount;
    } else {
      _match.team2Amount += amount;
    }

    PredictInfo storage predictInfo = ledger[epoch][_msgSender()];
    predictInfo.position = position;
    predictInfo.amount = amount;
    userMatches[_msgSender()].push(epoch);

    emit Predict(_msgSender(), epoch, amount, position);
  }

  function claim(uint256[] calldata epochs) external nonReentrant notContract {
    uint256 reward;
    for (uint256 i = 0; i < epochs.length; i++) {
      require(matches[epochs[i]].startTime != 0, "PWT: not started");
      require(block.timestamp > matches[epochs[i]].endTime, "PWT: not ended");

      uint256 addedReward = 0;
      if (matches[epochs[i]].finalized) {
        require(claimable(epochs[i], _msgSender()), "PWT: not eligible to claim");
        Match memory _match = matches[epochs[i]];
        addedReward = (ledger[epochs[i]][_msgSender()].amount * _match.rewardAmount) / _match.rewardBaseCalAmount;
      } else {
        require(refundable(epochs[i], _msgSender()), "PWT: not eligible to refund");
        addedReward = ledger[epochs[i]][_msgSender()].amount;
      }

      ledger[epochs[i]][_msgSender()].claimed = true;
      reward += addedReward;
      emit Claim(_msgSender(), epochs[i], addedReward);
    }

    if (reward > 0) {
      token.safeTransfer(_msgSender(), reward);
    }
  }

  function _createMatch(
    uint256 _epoch,
    string memory _matchName,
    uint256 _startTime
  ) internal {
    Match storage _match = matches[_epoch];
    _match.matchName = _matchName;
    _match.startTime = _startTime;
    _match.endTime = _startTime + 90 * 1;
    _match.epoch = _epoch;
    _match.totalAmount = 0;

    emit MatchCreated(_epoch, _matchName);
  }

  function _finaliseMatch(uint256 _epoch, uint256[2] memory _scores) internal {
    require(_epoch <= currentEpoch, "PWT: invalid epoch");
    require(block.timestamp >= matches[_epoch].endTime, "PWT: match not ended");

    Match storage _match = matches[_epoch];
    _match.scores = _scores;
    _match.finalized = true;

    emit MatchFinalized(_epoch, _scores);
  }

  function _predictable(uint256 _epoch) internal view returns (bool) {
    return !matches[_epoch].finalized &&
      matches[_epoch].startTime != 0 &&
      block.timestamp < matches[_epoch].startTime;
  }

  function _calculateRewards(uint256 _epoch) internal {
    require(
      matches[_epoch].rewardBaseCalAmount == 0 &&
      matches[_epoch].rewardAmount == 0,
      "PWT: reward calculated"
    );

    Match storage _match = matches[_epoch];
    uint256 rewardBaseCalAmount;
    uint256 protocolAmt = (_match.totalAmount * protocolFee) / 10000;

    if (_match.scores[0] == _match.scores[1]) {
      rewardBaseCalAmount = _match.totalAmount;
    } else if (_match.scores[0] > _match.scores[1]) {
      rewardBaseCalAmount = _match.team1Amount;
    } else {
      rewardBaseCalAmount = _match.team2Amount;
    }

    _match.rewardBaseCalAmount = rewardBaseCalAmount;
    _match.rewardAmount = _match.totalAmount - protocolAmt;
    protocolAmount += protocolAmt;

    emit RewardsCalculated(_epoch, rewardBaseCalAmount, _match.totalAmount, protocolAmt);
  }

  function _isContract(address _account) internal view returns (bool) {
    uint256 size;
    assembly {
      size := extcodesize(_account)
    }
    return size > 0;
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Context.sol";

abstract contract Pausable is Context {
  bool private _paused;

  event Paused(address account);
  event Unpaused(address account);

  modifier whenNotPaused() {
    require(!paused(), "Pausable: paused");
    _;
  }

  modifier whenPaused() {
    require(paused(), "Pausable: not paused");
    _;
  }

  constructor() {
    _paused = false;
  }

  /**
   * @dev Return true if the contract is paused, and false otherwise
   */
  function paused() public virtual view returns (bool) {
    return _paused;
  }

  function _pause() internal virtual whenNotPaused {
    _paused = true;
    emit Paused(_msgSender());
  }

  /**
   * @dev Return to normal state
   */
  function _unpause() internal virtual whenPaused {
    _paused = false;
    emit Unpaused(_msgSender());
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 */

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../token/ERC20/IERC20.sol";
import "./Address.sol";

library SafeERC20 {
  using Address for address;

  function safeTransfer(IERC20 token, address to, uint256 value) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {
    _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  function safeApprove(IERC20 token, address spender, uint256 value) internal {
    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      "SafeERC20: 0 allowance"
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
      require(oldAllowance >= value, "SafeERC20: value excceed");
      uint256 newAllowance = oldAllowance - value;
      _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
  }

  function _callOptionalReturn(IERC20 token, bytes memory data) private {
    bytes memory returndata = address(token).functionCall(data, "SafeERC20: low level call failed");
    if (returndata.length > 0) {
      require(abi.decode(returndata, (bool)), "SafeERC20: operation did not succeed");
    }
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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
        assembly {
            size := extcodesize(account)
        }
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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