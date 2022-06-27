/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

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

abstract contract Game is Ownable, Pausable, Multicall, VRFConsumerBaseV2 {
    using SafeERC20 for IERC20;

    struct Bet {
        bool resolved;
        address payable user;
        address token;
        uint256 id;
        uint256 amount;
        uint256 blockNumber;
    }

    struct ChainlinkConfig {
        uint64 subId;
        uint32 callbackGasLimit;
        uint16 requestConfirmations;
        bytes32 keyHash;
    }

    ChainlinkConfig public chainlinkConfig;
    VRFCoordinatorV2Interface public chainlinkCoordinator;
    uint16 private immutable _numRandomWords;
    uint256[] public betBlockNumbers;
    mapping(uint256 => Bet) public bets;
    mapping(address => uint256[]) internal _userBets;
    mapping(address => uint256) public tokensMinBetAmount;
    mapping(address => uint256) public tokensMaxBetAmount;


    event SetTokenBetAmount(address indexed token, uint256 minBetAmount, uint256 maxBetAmount);
    event BetRefunded(uint256 id, address user, uint256 amount);
    error WrongBetAmount(address token, uint256 value);
    error NotPendingBet(uint256 id);
    error NotFulfilled(uint256 id);

    constructor(address chainlinkCoordinatorAddress, uint16 numRandomWords) VRFConsumerBaseV2(chainlinkCoordinatorAddress) {
        chainlinkCoordinator = VRFCoordinatorV2Interface(
            chainlinkCoordinatorAddress
        );
        _numRandomWords = numRandomWords;
    }

    function betLength() external view returns (uint256) {
        return betBlockNumbers.length;
    }

    function _newBet(address token,uint256 tokenAmount,uint256 multiplier) internal whenNotPaused returns (Bet memory) {
        
        uint256 betAmount = tokenAmount;
        if (betAmount < tokensMinBetAmount[token] || betAmount > tokensMaxBetAmount[token]) {
            revert WrongBetAmount(token, betAmount);
        }

        // Create bet
        address user = msg.sender;
        uint256 id = chainlinkCoordinator.requestRandomWords(
            chainlinkConfig.keyHash,
            chainlinkConfig.subId,
            chainlinkConfig.requestConfirmations,
            chainlinkConfig.callbackGasLimit,
            _numRandomWords
        );
        Bet memory newBet = Bet(false, payable(user), token, id, betAmount, block.number);
        betBlockNumbers.push(block.number);
        _userBets[user].push(id);
        bets[id] = newBet;
        IERC20(token).safeTransferFrom(user, address(this), betAmount);
        return newBet;
    }

    function _resolveBet(Bet storage bet, bool wins, uint256 payout) internal returns (uint256) {
        address payable user = bet.user;
        if (bet.resolved == true || user == address(0)) {
            revert NotPendingBet(bet.id);
        }
        address token = bet.token;

        bet.resolved = true;

        // Check for the result
        if (wins) {
            IERC20(token).transfer(user, payout);
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

    function refundBet(uint256 id) external {
        Bet storage bet = bets[id];
        if (bet.resolved == true) {
            revert NotPendingBet(id);
        } else if (block.number < bet.blockNumber + 30) {
            revert NotFulfilled(id);
        }

        bet.resolved = true;
        IERC20(bet.token).safeTransfer(bet.user, bet.amount);

        emit BetRefunded(id, bet.user, bet.amount);
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
    mapping(address => uint8) public tokensMinCapRange;

    event PlaceBet(uint256 id, address indexed user, address indexed token, uint8 cap1, uint8 cap2);
    event Roll(uint256 id, address indexed user, address indexed token, uint256 amount, uint8 cap1, uint8 cap2, uint8 rolled, uint256 payout);
    event SetMinCapRange(address indexed token, uint256 minCapRange);

    error CapRangeNotInRange(uint8 capRange, uint8 minCapRange, uint8 maxCapRange);

    constructor(address chainlinkCoordinatorAddress) Game(chainlinkCoordinatorAddress, 1) {}

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

    function wager(uint8 cap1, uint8 cap2, address token, uint256 tokenAmount) external payable whenNotPaused {
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

        Bet memory bet = _newBet(token, tokenAmount, getPayout(10000, capRange));

        if (cap2 > cap1) {
            diceBets[bet.id] = cap1;
            diceBets2[bet.id] = cap2;    
        }
        else {
            diceBets[bet.id] = cap2;
            diceBets2[bet.id] = cap1;  
        }
        
        emit PlaceBet(bet.id, bet.user, bet.token, cap1, cap2);
    }

    function fulfillRandomWords(uint256 id, uint256[] memory randomWords) internal override {
        uint8 cap1 = diceBets[id];
        uint8 cap2 = diceBets2[id];
        Bet storage bet = bets[id];
        uint256 rolled = (randomWords[0] % 100) + 1;
        bool wins;
        if (rolled > cap1 && rolled < cap2) {
            wins = true;
        }
        else {
            wins = false;
        }
        uint8 capRange = cap2 - cap1 + 1;
        uint256 payout = _resolveBet(bet, wins, getPayout(bet.amount, capRange));
        emit Roll(bet.id, bet.user, bet.token, bet.amount, cap1, cap2, uint8(rolled), payout);
    }

    function getLastUserBets(address user, uint256 dataLength) external view returns (DiceBet[] memory) {
        Bet[] memory lastBets = _getLastUserBets(user, dataLength);
        DiceBet[] memory lastDiceBets = new DiceBet[](lastBets.length);
        for (uint256 i; i < lastBets.length; i++) {
            lastDiceBets[i] = DiceBet(lastBets[i], diceBets[lastBets[i].id], diceBets2[lastBets[i].id]);
        }
        return lastDiceBets;
    }

    function getPayout(uint256 betAmount, uint8 capRange) public pure returns (uint256) {
        return (betAmount * MAX_CAP_Range) / capRange;
    }
}