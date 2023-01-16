// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

contract BitcoinBingo is Ownable {
  using SafeERC20 for IERC20;

  AggregatorV3Interface public priceFeed;
  IERC20 public prizeToken;

  uint256 public prizeFee;
  uint256 public feeDecimal;
  uint8 public bingoDecimal;
  uint256 public bufferSeconds;
  uint256 public intervalLockSeconds; // interval in seconds till Friday midnight
  uint256 public intervalCloseSeconds; // interval in seconds till Sunday midnight

  address public operatorAddress; // address of the operator

  uint256 public currentEpoch; // current epoch for prediction round
  uint256 public oracleLatestRoundId; // converted from uint80 (Chainlink)
  uint256 public oracleUpdateAllowance = 300; // seconds

  uint256 public companyPrize = 1000_00_0000_0000_0000_0000; // 1000 * 10e18

  address public accumulator;
  address public prizeDepositer;


  struct Round {
    uint256 epoch;
    uint256 startTimestamp;
    uint256 lockTimestamp;
    uint256 closeTimestamp;
    int256 closePrice;
    uint256 closeOracleId;
    uint256 totalAmount;
    bool bingoLocked; // default false
    bool oracleCalled; // default false
    bool prizeDeposited;
  }

  struct ManagerObj {
    uint256 index;
    bool exist;
  }

  // epoch => Round
  mapping(uint256 => Round) public rounds;
  // account => epoch => number of bingo
  mapping(address => mapping(uint256 => uint8)) public userRounds;
  mapping(address => mapping(uint256 => bool)) public userFreeRounds;
  // twitter, discord, telegram
  mapping(string => uint8) public socialDic;
  mapping(address => mapping(uint256 => mapping (uint8 => bool))) public userSocialFreeRounds;
  // epoch => price => accounts
  mapping(uint256 => mapping(int256 => address[])) public priceRounds;
  
  mapping (address => ManagerObj) private _manageAccess;
  address[] private _managerLists;

  // number of extra bingo => USDC
  mapping (uint8 => uint256) public extraStrategies;
  uint8[] public availableExtraBingos;

  event StartRound(uint256 indexed epoch);
  event EndRound(uint256 indexed epoch);
  event LockRound(uint256 indexed epoch, uint256 indexed roundId, int256 price);
  event BingoEvt(address user, uint256 indexed epoch, uint256 indexed roundId, int256 price);

  modifier onlyManager() {
    require(msg.sender == owner() || _manageAccess[msg.sender].exist, "!manager");
    _;
  }

  modifier onlyOperator() {
    require(msg.sender == operatorAddress, "Not operator");
    _;
  }

  modifier notContract() {
    require(!_isContract(msg.sender), "Contract not allowed");
    require(msg.sender == tx.origin, "Proxy contract not allowed");
    _;
  }

  constructor(address _priceFeed, address _prizeToken) {
    priceFeed = AggregatorV3Interface(_priceFeed);
    prizeToken = IERC20(_prizeToken);

    prizeFee = 500;
    feeDecimal = 1000;
    bingoDecimal = 6;
    
    bufferSeconds = 30;
    intervalLockSeconds = 432000;
    intervalCloseSeconds = 604800;

    operatorAddress = 0x5e1f49A1349dd35FACA241eB192c6c2EDF47EF46;
    accumulator = 0x75c6D683A7d45bbb0A31F2249c12a11fA26bE9eA;
    prizeDepositer = 0x320e75Db7D2a624bd9DEa117C3092D69F20D8988;
    _manageAccess[0x320e75Db7D2a624bd9DEa117C3092D69F20D8988] = ManagerObj(0, true);
    _managerLists.push(0x320e75Db7D2a624bd9DEa117C3092D69F20D8988);

    availableExtraBingos.push(1);
    availableExtraBingos.push(5);
    extraStrategies[1] = 1_00_0000_0000_0000_0000;
    extraStrategies[5] = 3_00_0000_0000_0000_0000;

    socialDic["twitter"] = 1;
    socialDic["discord"] = 2;
    socialDic["telegram"] = 3;
    socialDic["tvl"] = 4;

    _startRound(companyPrize);
  }

  function bingoBTC(uint256 epoch, int256[] memory prices, uint8 index) external notContract {
    require(epoch == currentEpoch, "Bet is too early/late");
    require(_bettable(epoch), "Round not bettable");

    uint256 bingoBetAmount = extraStrategies[index];
    uint256 bingoLen = prices.length;
    require(bingoLen == index, "Wrong prices");
    require(bingoBetAmount > 0, "No extra free bingo");

    require(prizeToken.allowance(msg.sender, address(this)) >= bingoBetAmount, 'Btcbingo: Bingo token is not approved');
    prizeToken.safeTransferFrom(msg.sender, address(this), bingoBetAmount);
    uint256 treasurySplit = bingoBetAmount * prizeFee / feeDecimal;
    prizeToken.safeTransfer(accumulator, treasurySplit);
    Round storage round = rounds[epoch];
    round.totalAmount = round.totalAmount + bingoBetAmount - treasurySplit;

    userRounds[msg.sender][epoch] += uint8(bingoLen);
    
    for (uint256 i=0; i<bingoLen; i++) {
      int256 price = prices[i];
      priceRounds[epoch][price].push(msg.sender);
      emit BingoEvt(msg.sender, epoch, userRounds[msg.sender][epoch]-i, price);
    }
  }

  function bingoBTCViaOperator(uint256 epoch, int256 price, address account) external onlyOperator {
    require(epoch == currentEpoch, "Bet is too early/late");
    require(_bettable(epoch), "Round not bettable");
    
    require(userFreeRounds[account][epoch] == false, "Btcbingo: You can do only once bingo");

    userRounds[msg.sender][epoch] += 1;
    userFreeRounds[account][epoch] = true;

    priceRounds[epoch][price].push(account);

    emit BingoEvt(account, epoch, 0, price);
  }

  function bingoBTCViaOperatorSocial(uint256 epoch, int256 price, address account, string memory social) external onlyOperator {
    require(epoch == currentEpoch, "Bet is too early/late");
    require(_bettable(epoch), "Round not bettable");
    
    require(socialDic[social] != 0, "Btcbingo: Not registered social");
    uint8 socialIndex = socialDic[social];
    require(userSocialFreeRounds[account][epoch][socialIndex] == false, "Btcbingo: You can do only once social bingo");

    userRounds[msg.sender][epoch] += 1;
    userSocialFreeRounds[account][epoch][socialIndex] = true;

    priceRounds[epoch][price].push(account);

    emit BingoEvt(account, epoch, 0, price);
  }

  function executeRound() external onlyOperator {
    // CurrentEpoch refers to previous round (n-1)
    require(rounds[currentEpoch].lockTimestamp != 0, "Can only end round after round has locked");
    require(block.timestamp >= rounds[currentEpoch].closeTimestamp, "Can only end round after closeTimestamp");
    require(
      block.timestamp <= rounds[currentEpoch].closeTimestamp + bufferSeconds,
      "Can only end round within bufferSeconds"
    );

    Round storage round = rounds[currentEpoch];
    round.closeTimestamp = block.timestamp;
    emit EndRound(currentEpoch);

    uint256 nextJackpot = companyPrize;
    uint256 winnerLen = priceRounds[currentEpoch][round.closePrice].length;
    if (winnerLen > 0) {
      uint256 rewardAmount = round.totalAmount / winnerLen;
      for (uint256 i=0; i<winnerLen; i++) {
        address acc = priceRounds[currentEpoch][round.closePrice][i];
        uint256 prizeBal2 = prizeToken.balanceOf(address(this));
        if (prizeBal2 >= rewardAmount) {
          prizeToken.safeTransfer(acc, rewardAmount);
        }
      }
    }
    else {
      nextJackpot = round.totalAmount + companyPrize;
    }

    // Increment currentEpoch to current round (n)
    currentEpoch = currentEpoch + 1;
    _startRound(nextJackpot);
  }

  function forceExecuteRound(uint256 _intervalLockSeconds, uint256 _intervalCloseSeconds, uint256 _jackpotSize) external onlyOperator {
    int256 currentPrice = 0;
    Round storage round = rounds[currentEpoch];
    round.closeTimestamp = block.timestamp;
    round.closePrice = currentPrice;
    round.closeOracleId = 0;
    round.oracleCalled = false;

    emit EndRound(currentEpoch);

    currentEpoch = currentEpoch + 1;

    Round storage cround = rounds[currentEpoch];
    cround.startTimestamp = block.timestamp;
    cround.lockTimestamp = block.timestamp + _intervalLockSeconds;
    cround.closeTimestamp = block.timestamp + _intervalCloseSeconds;
    cround.epoch = currentEpoch;
    cround.totalAmount = _jackpotSize;

    emit StartRound(currentEpoch);
  }

  /**
    * @notice Lock running round
    * @dev Callable by operator
    */
  function genesisLockRound() external onlyOperator {
    (uint80 currentRoundId, int256 currentPrice) = _getPriceFromOracle();

    oracleLatestRoundId = uint256(currentRoundId);

    require(rounds[currentEpoch].startTimestamp != 0, "Can only lock round after round has started");
    require(block.timestamp >= rounds[currentEpoch].lockTimestamp, "Can only lock round after lockTimestamp");
    require(
      block.timestamp <= rounds[currentEpoch].lockTimestamp + bufferSeconds,
      "Can only lock round within bufferSeconds"
    );

    currentPrice = currentPrice / (int256(10) ** bingoDecimal) * (int256(10) ** bingoDecimal);
    
    Round storage round = rounds[currentEpoch];
    round.lockTimestamp = block.timestamp;
    round.bingoLocked = true;
    round.closePrice = currentPrice;
    round.closeOracleId = currentRoundId;
    round.oracleCalled = true;

    emit LockRound(currentEpoch, currentRoundId, currentPrice);
  }

  function depoistPrizeFromSupplyer() public onlyOperator {
    _depoistPrize(prizeDepositer);
  }

  function depoistPrize() public {
    _depoistPrize(msg.sender);
  }

  function _depoistPrize(address _funder) private {
    Round storage round = rounds[currentEpoch];
    require(round.prizeDeposited == false, 'Btcbingo: Prize token is deposited');
    uint256 curBal = prizeToken.balanceOf(address(this));
    uint256 fundingBal = prizeToken.balanceOf(_funder);
    uint256 amount = round.totalAmount - curBal;
    if (amount > fundingBal) {
      amount = fundingBal;
    }

    require(prizeToken.allowance(_funder, address(this)) >= amount, 'Btcbingo: Prize token is not approved');

    prizeToken.safeTransferFrom(_funder, address(this), amount);
    curBal = prizeToken.balanceOf(address(this));
    if (curBal >= round.totalAmount) {
      round.prizeDeposited = true;
    }
  }

  function removePrizeToken() public onlyOwner {
    prizeToken.safeTransfer(msg.sender, prizeToken.balanceOf(address(this)));
  }

  function getAllExtraBingos() public view returns(uint8[] memory) {
    return availableExtraBingos;
  }


  function setManager(address usraddress, bool access) public onlyOwner {
    if (access == true) {
      if ( ! _manageAccess[usraddress].exist) {
        uint256 newId = _managerLists.length;
        _manageAccess[usraddress] = ManagerObj(newId, true);
        _managerLists.push(usraddress);
      }
    }
    else {
      if (_manageAccess[usraddress].exist) {
        address lastObj = _managerLists[_managerLists.length - 1];
        _managerLists[_manageAccess[usraddress].index] = _managerLists[_manageAccess[lastObj].index];
        _managerLists.pop();
        delete _manageAccess[usraddress];
      }
    }
  }

  function setPriceFeed(address _priceFeed) public onlyManager {
    priceFeed = AggregatorV3Interface(_priceFeed);
  }
  function setPrizeToken(address _prizeToken) public onlyManager {
    prizeToken = IERC20(_prizeToken);
  }
  function setTreasuryFee(uint256 _prizeFee, uint256 _feeDecimal) public onlyManager {
    prizeFee = _prizeFee;
    feeDecimal = _feeDecimal;
  }
  function setBingoDecimal(uint8 _bingoDecimal) public onlyManager {
    bingoDecimal = _bingoDecimal;
  }
  function setBufferSeconds(uint256 _bufferSeconds) public onlyManager {
    bufferSeconds = _bufferSeconds;
  }
  function setIntervalLockSeconds(uint256 _intervalLockSeconds) public onlyManager {
    intervalLockSeconds = _intervalLockSeconds;
  }
  function setIntervalCloseSeconds(uint256 _intervalCloseSeconds) public onlyManager {
    require(_intervalCloseSeconds >= intervalLockSeconds, "Btcbingo: Wrong close timestamp");
    intervalCloseSeconds = _intervalCloseSeconds;
  }
  function setCompanyPrize(uint256 _companyPrize) public onlyManager {
    Round storage round = rounds[currentEpoch];
    round.totalAmount = round.totalAmount - companyPrize + _companyPrize;
    companyPrize = _companyPrize;
  }
  function setAccumulator(address _accumulator) public onlyManager {
    accumulator = _accumulator;
  }
  function setPrizeDepositer(address _prizeDepositer) public onlyManager {
    prizeDepositer = _prizeDepositer;
  }
  function setOperator(address _operatorAddress) public onlyManager {
    operatorAddress = _operatorAddress;
  }
  function changeExtraStrategy(uint8 index, uint256 amount) public onlyManager {
    require(extraStrategies[index] != 0, "Not Exist strategy");
    extraStrategies[index] = amount;
  }
  function addExtraStrategy(uint8 index, uint256 amount) public onlyManager {
    require(extraStrategies[index] == 0, "Already Exist strategy");
    extraStrategies[index] = amount;
    availableExtraBingos.push(index);
  }
  function removedExtraStrategy(uint8 index) public onlyManager {
    require(extraStrategies[index] != 0, "Not Exist strategy");
    uint256 last = availableExtraBingos.length - 1;
    for (uint i=0; i<=last; i++) {
      if (availableExtraBingos[i] == index) {
        availableExtraBingos[i] = availableExtraBingos[last];
        break;
      }
    }
    availableExtraBingos.pop();
    extraStrategies[index] = 0;
  }
  function addSocial(string memory _social, uint8 _index) public onlyManager {
    require(socialDic[_social] == 0, "Already Exist Social");
    socialDic[_social] = _index;
  }
  function removeSocial(string memory _social) public onlyManager {
    require(socialDic[_social] != 0, "Not Existing Social");
    socialDic[_social] = 0;
  }

  function _startRound(uint256 _jackpotSize) internal {
    Round storage cround = rounds[currentEpoch];
    cround.startTimestamp = block.timestamp;
    cround.lockTimestamp = block.timestamp + intervalLockSeconds;
    cround.closeTimestamp = block.timestamp + intervalCloseSeconds;
    cround.epoch = currentEpoch;
    cround.totalAmount = _jackpotSize;

    emit StartRound(currentEpoch);
  }

  /**
    * @notice Determine if a round is valid for receiving bets
    * Round must have started and locked
    * Current timestamp must be within startTimestamp and closeTimestamp
    */
  function _bettable(uint256 epoch) internal view returns (bool) {
    return
      rounds[epoch].startTimestamp != 0 &&
      rounds[epoch].lockTimestamp != 0 &&
      block.timestamp > rounds[epoch].startTimestamp &&
      block.timestamp < rounds[epoch].lockTimestamp;
  }

  /**
    * @notice Get latest recorded price from oracle
    * If it falls below allowed buffer or has not updated, it would be invalid.
    */
  function _getPriceFromOracle() internal view returns (uint80, int256) {
    uint256 leastAllowedTimestamp = block.timestamp + oracleUpdateAllowance;
    (uint80 roundId, int256 price, , uint256 timestamp, ) = priceFeed.latestRoundData();
    require(timestamp <= leastAllowedTimestamp, "Oracle update exceeded max timestamp allowance");
    require(
      uint256(roundId) > oracleLatestRoundId,
      "Oracle update roundId must be larger than oracleLatestRoundId"
    );
    return (roundId, price);
  }

  /**
    * @notice Returns true if `account` is a contract.
    * @param account: account address
    */
  function _isContract(address account) internal view returns (bool) {
    uint256 size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
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

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}