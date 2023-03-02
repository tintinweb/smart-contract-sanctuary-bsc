/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

interface AggregatorV3Interface {

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

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success,) = recipient.call{value : amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
    internal
    returns (bytes memory)
    {
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
        return
        functionCallWithValue(
            target,
            data,
            value,
            "Address: low-level call with value failed"
        );
    }

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
        (bool success, bytes memory returndata) = target.call{value : value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

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

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
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
            if (returndata.length > 0) {
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
abstract contract ReentrancyGuard {
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

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function initOwner() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() external view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() external onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
    */
    function pause() external onlyOwner whenNotPaused {
        paused = true;
        Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() external onlyOwner whenPaused {
        paused = false;
        Unpause();
    }
}

contract Bet is Pausable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    struct UserInfo {
        uint256 balance;
        uint256 rewardAlreadyClaim;
        uint256 roundBet;
    }

    struct UserBetInfo {
        uint256 amountBetUp;
        uint256 amountBetDown;
        bool status;
    }

    struct Round {
        uint256 startBetTimestamp;
        uint256 closeBetTimestamp;
        int256 openPrice;
        int256 closePrice;
        uint80 openOracleId;
        uint80 closeOracleId;
        uint256 totalAmount;
        uint256 totalBetUp;
        uint256 totalBetDown;
        uint256 totalAmountBetUp;
        uint256 totalAmountBetDown;
        uint256 win; // 1 is down win,2 is up win
    }

    bool public genesisStartOnce = false;
    uint256 public currentEpoch;
    bool public initialized;
    address public tokenBet;
    uint256 public intervalSeconds; // interval in seconds between two prediction rounds

    uint256 minBetAmount;
    uint256 maxBetAmount;
    uint256 treasuryFee; // %

    AggregatorV3Interface public oracle;
    uint256 public oracleLatestRoundId; // converted from uint80 (Chainlink)

    mapping(uint256 => Round) public roundInfo;
    //user => round => info user bet
    mapping(address => mapping(uint256 => UserBetInfo)) public userBetInfo;
    mapping(address => UserInfo) public userInfo;

    event Bet(address user, uint256 round, uint256 bet, uint256 amount, uint256 totalBet);
    event Deposit(address user, uint256 amount);
    event Withdraw(address user, uint256 amount);
    event StartRound(uint256 indexed epoch);
    event EndRound(uint256 indexed epoch);
    event Win(uint256 indexed epoch, uint256 win);

    function init(address _oracleAddress, address _tokenBet, uint256 _intervalSeconds, uint256 _minBetAmount, uint256 _maxBetAmount, uint256 _treasuryFee) public {
        require(initialized == false);

        oracle = AggregatorV3Interface(_oracleAddress);

        minBetAmount = _minBetAmount;
        maxBetAmount = _maxBetAmount;
        treasuryFee = _treasuryFee;
        intervalSeconds = _intervalSeconds;

        initOwner();
        tokenBet = _tokenBet;
        initialized = true;
    }
    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }
    function setTokenPlay(address _tokenBet) public onlyOwner {
        tokenBet = _tokenBet;
    }

    function setMinBetAmount(uint256 _minBetAmount) public onlyOwner {
        minBetAmount = _minBetAmount;
    }

    function setMaxBetAmount(uint256 _maxBetAmount) public onlyOwner {
        maxBetAmount = _maxBetAmount;
    }

    function setOracle(address _oracleAddress) public onlyOwner {
        oracle = AggregatorV3Interface(_oracleAddress);
    }

    function setTreasuryFeeBet(uint256 _treasuryFee) public onlyOwner {
        treasuryFee = _treasuryFee;
    }

    function genesisStartRound() public onlyOwner {
        require(!genesisStartOnce, "Can only run genesisStartRound once");
        (uint80 oracleRoundId, int256 oraclePrice,uint256 oracleStartedAt) = _getPriceFromOracle();


        currentEpoch = currentEpoch + 1;
        _startRound(currentEpoch, oraclePrice, oracleRoundId);
        genesisStartOnce = true;
    }

    function executeRound() public onlyOwner {
        require(block.timestamp > roundInfo[currentEpoch].closeBetTimestamp, "betting round");
        (uint80 oracleRoundId, int256 oraclePrice,uint256 oracleStartedAt) = _getPriceFromOracle();

        require(uint256(oracleRoundId) > oracleLatestRoundId, "chainlink round old");
        require(roundInfo[currentEpoch].closeBetTimestamp < oracleStartedAt, "round oracle invalid");

        roundInfo[currentEpoch].closePrice = oraclePrice;
        roundInfo[currentEpoch].closeOracleId = oracleRoundId;

        _setWin(currentEpoch);
        emit EndRound(currentEpoch);

        currentEpoch = currentEpoch + 1;
        _startRound(currentEpoch, oraclePrice, oracleRoundId);

    }

    function _startRound(uint256 epoch, int256 _openPrice, uint80 _openRoundId) internal {
        Round storage round = roundInfo[epoch];
        require(round.openPrice == 0, "round already create");

        round.startBetTimestamp = block.timestamp;
        round.closeBetTimestamp = block.timestamp + intervalSeconds;
        round.openPrice = _openPrice;
        round.openOracleId = _openRoundId;

        oracleLatestRoundId = uint256(_openRoundId);

        emit StartRound(epoch);
    }

    function _setWin(uint256 epoch) internal {
        Round storage round = roundInfo[epoch];
        require(roundInfo[epoch].win == 0, "already set win");

        // Up wins
        if (round.openPrice > round.closePrice) {
            round.win = 1;
        }
        // Bear wins
        else if (round.openPrice < round.closePrice) {
            round.win = 2;
        } else {
            round.win = 3;
        }

        emit Win(epoch, round.win);
    }

    function withdraw(uint256 _amount) public {
        update(msg.sender);
        require(userInfo[msg.sender].balance >= _amount, "not enough");
        IBEP20(tokenBet).safeTransfer(msg.sender, _amount);

        emit Withdraw(msg.sender, _amount);
    }

    // _bet = 1 is down , 2 is up
    function bet(uint256 _amount, uint256 _bet) whenNotPaused notContract external {
        require(_amount >= minBetAmount, "min bet");
        require(_amount <= maxBetAmount, "max bet");
        require(_bet == 1 || _bet == 2, "1 or 2");
        require(roundInfo[currentEpoch].closeBetTimestamp > block.timestamp, "close bet");

        update(msg.sender);

        uint256 balance = userInfo[msg.sender].balance;
        if (_amount > balance) {
            IBEP20(tokenBet).safeTransferFrom(msg.sender, address(this), _amount - balance);
            userInfo[msg.sender].balance = 0;
        } else {
            userInfo[msg.sender].balance = userInfo[msg.sender].balance.sub(_amount);
        }

        uint256 totalFee = (_amount.mul(treasuryFee)).div(1e5);
        uint256 totalBet = _amount.sub(totalFee);

        if (_bet == 1) {
            roundInfo[currentEpoch].totalBetDown = roundInfo[currentEpoch].totalBetDown.add(1);
            roundInfo[currentEpoch].totalAmountBetDown = roundInfo[currentEpoch].totalAmountBetDown.add(totalBet);
            userBetInfo[msg.sender][currentEpoch].amountBetDown = userBetInfo[msg.sender][currentEpoch].amountBetDown.add(totalBet);
        }
        if (_bet == 2) {
            roundInfo[currentEpoch].totalBetUp = roundInfo[currentEpoch].totalBetUp.add(1);
            roundInfo[currentEpoch].totalAmountBetUp = roundInfo[currentEpoch].totalAmountBetUp.add(totalBet);
            userBetInfo[msg.sender][currentEpoch].amountBetUp = userBetInfo[msg.sender][currentEpoch].amountBetUp.add(totalBet);
        }

        userInfo[msg.sender].roundBet = currentEpoch;
        emit Bet(msg.sender, currentEpoch, _bet, _amount, totalBet);
    }

    function update(address _user) internal {
        if (!userBetInfo[_user][userInfo[_user].roundBet].status && userInfo[_user].roundBet != currentEpoch) {
            (uint256 reward,uint256 totalRefund) = calculatorReward(_user, userInfo[_user].roundBet);
            userInfo[_user].balance = userInfo[_user].balance.add(reward).add(totalRefund);
            userBetInfo[_user][userInfo[_user].roundBet].status = true;
        }
    }

    function getBalanceOfUser(address user) public view returns (uint256){
        UserInfo memory info = userInfo[user];
        uint256 totalBalance = info.balance;
        if (info.roundBet != currentEpoch && userBetInfo[user][info.roundBet].status == false) {
            (uint256 reward,uint256 totalRefund) = calculatorReward(user, info.roundBet);
            totalBalance = totalBalance.add(reward).add(totalRefund);
        }
        return totalBalance;
    }

    function calculatorReward(address user, uint256 _round) public view returns (uint256, uint256){
        UserBetInfo memory _userBetInfo = userBetInfo[user][_round];
        uint256 reward;
        uint256 totalRefund;

        if (roundInfo[_round].win == 1) {
            totalRefund = _userBetInfo.amountBetDown;
            reward = (((totalRefund.mul(1e12)).div(roundInfo[_round].totalAmountBetDown)).mul(roundInfo[_round].totalAmountBetUp)).div(1e12);
        } else if (roundInfo[_round].win == 2) {
            totalRefund = _userBetInfo.amountBetUp;
            reward = (((totalRefund.mul(1e12)).div(roundInfo[_round].totalAmountBetUp)).mul(roundInfo[_round].totalAmountBetDown)).div(1e12);
        } else if (roundInfo[_round].win == 3) {
            totalRefund = _userBetInfo.amountBetDown.add(_userBetInfo.amountBetUp);
        }
        return (reward, totalRefund);
    }

    function _getPriceFromOracle() public view returns (uint80, int256, uint256 startedAt) {
        (uint80 roundId, int256 price, , uint256 startedAt,) = oracle.latestRoundData();
        return (roundId, price, startedAt);
    }

    function claim(
        IBEP20 token,
        address to,
        uint256 amount
    ) external onlyOwner {
        token.safeTransfer(to, amount);
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