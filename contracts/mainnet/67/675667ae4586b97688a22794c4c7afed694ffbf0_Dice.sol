/**
 *Submitted for verification at BscScan.com on 2022-09-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

interface VRFCoordinatorV2Interface {

    function getRequestConfig()
      external
      view
      returns (
        uint16,
        uint32,
        bytes32[] memory
      );

    function requestRandomWords(
      bytes32 keyHash,
      uint64 subId,
      uint16 minimumRequestConfirmations,
      uint32 callbackGasLimit,
      uint32 numWords
    ) external returns (uint256 requestId);
  
    function createSubscription() external returns (uint64 subId);
  
    function getSubscription(uint64 subId)
      external
      view
      returns (
        uint96 balance,
        uint64 reqCount,
        address owner,
        address[] memory consumers
    );
  
    function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;
  
    function acceptSubscriptionOwnerTransfer(uint64 subId) external;
  
    function addConsumer(uint64 subId, address consumer) external;
  
    function removeConsumer(uint64 subId, address consumer) external;
  
    function cancelSubscription(uint64 subId, address to) external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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

abstract contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

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

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

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

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

abstract contract Multicall {
    function multicall(bytes[] calldata data) external virtual returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = Address.functionDelegateCall(address(this), data[i]);
        }
        return results;
    }
}

interface IReferral {
    /**
     * @dev Record referral.
     */
    function recordReferral(address user, address referrer) external;

    /**
     * @dev Get the referrer address that referred the user.
     */
    function getReferrer(address user) external view returns (address);
}

abstract contract Game is Ownable, Pausable, Multicall, VRFConsumerBaseV2 {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct Bet {
        bool resolved;
        address payable user;
        address token;
        uint256 randomNumber;
        uint256 amount;
        uint256 blockNumber;
        uint256 rolled;
        bool result;
        uint256 payout;
    }

    struct ChainlinkConfig {
        uint64 subId;
        uint32 callbackGasLimit;
        uint16 requestConfirmations;
        bytes32 keyHash;
    }

    struct BetResult {
        uint256 randomNumber;
    }

    BetResult[] public betResults;
    mapping(address => uint256) public totalBetAmount;

    ChainlinkConfig public chainlinkConfig;
    VRFCoordinatorV2Interface public chainlinkCoordinator;
    uint16 private immutable _numRandomWords;
    mapping(uint256 => Bet) public bets;
    mapping(address => uint256[]) internal _userBets;
    mapping(address => uint256) public tokensMinBetAmount;
    mapping(address => uint256) public tokensMaxBetAmount;

    event SetTokenBetAmount(address indexed token, uint256 minBetAmount, uint256 maxBetAmount);
    event BetRefunded(uint256 randomNumber, address user, uint256 amount);
    error WrongBetAmount(address token, uint256 value);
    error NotPendingBet(uint256 randomNumber);
    error NotFulfilled(uint256 randomNumber);

    // BetCash referral contract address.
    IReferral public referral;
    // Referral commission rate in basis points.
    uint16 public referralCommissionRate = 200;
    // Max referral commission rate: 5%.
    uint16 public constant MAXIMUM_REFERRAL_COMMISSION_RATE = 500;

    event SetReferralCommissionRate( uint256 indexed referralCommissionRate);
    event SetReferralAddress(address indexed user, IReferral indexed newAddress);
    event ReferralCommissionPaid(address indexed user, address indexed referrer, uint256 commissionAmount);

    constructor(address chainlinkCoordinatorAddress, uint16 numRandomWords, IReferral _referral) VRFConsumerBaseV2(chainlinkCoordinatorAddress) {
        chainlinkCoordinator = VRFCoordinatorV2Interface(
            chainlinkCoordinatorAddress
        );
        _numRandomWords = numRandomWords;
        referral = _referral;
    }

    function getTotalBets() external view returns (uint256) {
        return betResults.length;
    }

    function _newBet(address token,uint256 tokenAmount) internal whenNotPaused returns (Bet memory) {
        
        uint256 betAmount = tokenAmount;
        if (betAmount < tokensMinBetAmount[token] || betAmount > tokensMaxBetAmount[token]) {
            revert WrongBetAmount(token, betAmount);
        }

        // Create bet
        address user = msg.sender;
        uint256 randomNumber = chainlinkCoordinator.requestRandomWords(
            chainlinkConfig.keyHash,
            chainlinkConfig.subId,
            chainlinkConfig.requestConfirmations,
            chainlinkConfig.callbackGasLimit,
            _numRandomWords
        );
        Bet memory newBet = Bet(false, payable(user), token, randomNumber, betAmount, block.number, 101, false, 0);
        totalBetAmount[token] += betAmount;
        _userBets[user].push(randomNumber);
        betResults.push(BetResult({randomNumber: randomNumber}));
        bets[randomNumber] = newBet;
        IERC20(token).safeTransferFrom(user, address(this), betAmount);
        return newBet;
    }

    function _resolveBet(Bet storage bet, bool wins, uint256 rolled, uint256 payout) internal returns (uint256) {
        address payable user = bet.user;
        if (bet.resolved == true || user == address(0)) {
            revert NotPendingBet(bet.randomNumber);
        }
        address token = bet.token;

        bet.resolved = true;
        bet.rolled = rolled;
        bet.result = wins;
        bet.payout = payout;

        // Check for the result
        address referrer = referral.getReferrer(msg.sender);

        if (wins) {
            if (referrer != address(0)) {
                IERC20(token).transfer(user, payout.mul(10000 - referralCommissionRate).div(10000));
                payReferralCommission(token, msg.sender, payout.mul(referralCommissionRate).div(10000));
            } else {
                IERC20(token).transfer(user, payout);
            }
        }
        
        return payout;
    }

    function _getLastUserBets(address user, uint256 dataLength) internal view returns (Bet[] memory) {
        uint256[] memory userBetsIds = _userBets[user];
        uint256 betsLength = userBetsIds.length;

        if (betsLength < dataLength) {
            dataLength = betsLength;
        }

        Bet[] memory userBets = new Bet[](dataLength);
        if (dataLength > 0) {
            uint256 userBetsIndex = 0;
            for (uint256 i = betsLength; i > betsLength - dataLength; i--) {
                userBets[userBetsIndex] = bets[userBetsIds[i - 1]];
                userBetsIndex++;
            }
        }

        return userBets;
    }

    function setTokenBetAmount(address token, uint256 tokenMinBetAmount, uint256 tokenMaxBetAmount) external onlyOwner {
        tokensMinBetAmount[token] = tokenMinBetAmount;
        tokensMaxBetAmount[token] = tokenMaxBetAmount;
        emit SetTokenBetAmount(token, tokenMinBetAmount, tokenMaxBetAmount);
    }

    function pause() external onlyOwner {
        if (paused()) {
            _unpause();
        } else {
            _pause();
        }
    }

    function setChainlinkConfig(uint64 subId, uint32 callbackGasLimit, uint16 requestConfirmations, bytes32 keyHash) external onlyOwner {
        chainlinkConfig.subId = subId;
        chainlinkConfig.callbackGasLimit = callbackGasLimit;
        chainlinkConfig.requestConfirmations = requestConfirmations;
        chainlinkConfig.keyHash = keyHash;
    }

    function refundBet(uint256 randomNumber) external {
        Bet storage bet = bets[randomNumber];
        if (bet.resolved == true) {
            revert NotPendingBet(randomNumber);
        } else if (block.number < bet.blockNumber + 30) {
            revert NotFulfilled(randomNumber);
        }

        bet.resolved = true;
        IERC20(bet.token).safeTransfer(bet.user, bet.amount);

        emit BetRefunded(randomNumber, bet.user, bet.amount);
    }

    // Update referral commission rate by the owner
    function setReferralCommissionRate(uint16 _referralCommissionRate) external onlyOwner {
        require(_referralCommissionRate <= MAXIMUM_REFERRAL_COMMISSION_RATE, "setReferralCommissionRate: invalid referral commission rate basis points");
        referralCommissionRate = _referralCommissionRate;
        emit SetReferralCommissionRate(_referralCommissionRate);
    }

    // Pay referral commission to the referrer who referred this user.
    function payReferralCommission(address _token, address _user, uint256 _amount) internal {
        if (address(referral) != address(0) && referralCommissionRate > 0) {
            address referrer = referral.getReferrer(_user);
            uint256 commissionAmount = _amount.mul(referralCommissionRate).div(10000);

            if (referrer != address(0) && commissionAmount > 0) {
                // IBCT(Bct).mint(referrer, commissionAmount);
                IERC20(_token).safeTransfer(referrer, commissionAmount);
                emit ReferralCommissionPaid(_user, referrer, commissionAmount);
            }
        }
    }

}

contract Dice is Game {
    struct DiceBet {
        Bet bet; 
        uint8 cap1;
        uint8 cap2;
    }

    mapping(uint256 => uint8) public diceBets;
    mapping(uint256 => uint8) public diceBets2;

    uint8 public constant MAX_CAP_Range = 95;
    uint256 public fee = 0; // receive bnb instead of using link token. Link token is used to get random number from vrf
    mapping(address => uint8) public tokensMinCapRange;

    event PlaceBet(uint256 id, address indexed user, address indexed token, uint8 cap1, uint8 cap2);
    event Roll(uint256 id, address indexed user, address indexed token, uint256 amount, uint8 cap1, uint8 cap2, uint8 rolled, uint256 payout);
    event SetMinCapRange(address indexed token, uint256 minCapRange);

    error CapRangeNotInRange(uint8 capRange, uint8 minCapRange, uint8 maxCapRange);

    constructor(address chainlinkCoordinatorAddress) Game(chainlinkCoordinatorAddress, 1, referral) {}

    function setMinCapRange(address token) external onlyOwner {
        uint8 oldMinCapRange = tokensMinCapRange[token];
        uint8 newMinCapRange;
        uint8 maxCapRange = MAX_CAP_Range;
        uint256 amount = 10000;
        for (uint8 capRange = 1; capRange < maxCapRange; capRange++) {
            uint256 payout = getPayout(amount, capRange);
            if (amount / payout < 1) {
                newMinCapRange = tokensMinCapRange[token] = capRange;
                break;
            }
        }
        if (oldMinCapRange != newMinCapRange) {
            emit SetMinCapRange(token, newMinCapRange);
        }
    }

    function wager(uint8 cap1, uint8 cap2, address token, uint256 tokenAmount, address _referrer) external payable whenNotPaused {
        require(msg.value >= fee, "wager: You must send enough bnb amount than fee!");
        
        if (tokenAmount > 0 && address(referral) != address(0) && _referrer != address(0) && _referrer != msg.sender) {
            referral.recordReferral(msg.sender, _referrer);
        }
        
        uint8 capRange;
        if (cap1 > cap2) {
            capRange = cap1 - cap2 + 1;
        }
        else {
            capRange = cap2 - cap1 + 1;
        }
        if (capRange < tokensMinCapRange[token] || capRange > MAX_CAP_Range) {
            revert CapRangeNotInRange(capRange, tokensMinCapRange[token], MAX_CAP_Range);
        }

        Bet memory bet = _newBet(token, tokenAmount);

        if (cap2 > cap1) {
            diceBets[bet.randomNumber] = cap1;
            diceBets2[bet.randomNumber] = cap2;    
        }
        else {
            diceBets[bet.randomNumber] = cap2;
            diceBets2[bet.randomNumber] = cap1;  
        }
        
        emit PlaceBet(bet.randomNumber, bet.user, bet.token, cap1, cap2);
    }

    function fulfillRandomWords(uint256 randomNumber, uint256[] memory randomWords) internal override {
        uint8 cap1 = diceBets[randomNumber];
        uint8 cap2 = diceBets2[randomNumber];
        Bet storage bet = bets[randomNumber];
        uint256 rolled = randomWords[0] % 101;
        bool wins;
        if (rolled >= cap1 && rolled <= cap2) {
            wins = true;
        }
        else {
            wins = false;
        }
        uint8 capRange = cap2 - cap1 + 1;
        uint256 payout = _resolveBet(bet, wins, rolled, getPayout(bet.amount, capRange));

        emit Roll(bet.randomNumber, bet.user, bet.token, bet.amount, cap1, cap2, uint8(rolled), payout);
    }

    function getLastUserBets(address user, uint256 dataLength) external view returns (DiceBet[] memory) {
        Bet[] memory lastBets = _getLastUserBets(user, dataLength);
        DiceBet[] memory lastDiceBets = new DiceBet[](lastBets.length);
        for (uint256 i; i < lastBets.length; i++) {
            lastDiceBets[i] = DiceBet(lastBets[i], diceBets[lastBets[i].randomNumber], diceBets2[lastBets[i].randomNumber]);
        }
        return lastDiceBets;
    }

    function getPayout(uint256 betAmount, uint8 capRange) public pure returns (uint256) {
        return (betAmount * MAX_CAP_Range) / capRange;
    }

    function setFee(uint256 _fee) external onlyOwner {
        require(_fee <= 1e16, "fee: can't set bigger amount than 0.01BNB");
        fee = _fee;
    }

    receive() external payable {}

    function withdrawFee() external onlyOwner {
        uint256 amount = address(this).balance;
        payable(owner()).transfer(amount);
    }

}