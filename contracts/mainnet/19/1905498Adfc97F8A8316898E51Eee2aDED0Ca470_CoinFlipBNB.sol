// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./external/gelato/OpsReady.sol";
import "./interfaces/ICoinFlipBNBRNG.sol";
import "./interfaces/IWETH.sol";

// contract that allows users to bet on a coin flip. RNG contract must be deployed first. 

contract CoinFlipBNB is Ownable, ReentrancyGuard, OpsReady {

    //----- Interfaces/Addresses -----

    ICoinFlipBNBRNG public CoinFlipBNBRNG;
    address CoinFlipBNBRNGAddress;
    address payable VRFSubscription;
    address payable devWallet;
    address public weth;

    //----- Mappings -----------------

    mapping(address => mapping(uint256 => Bet)) public Bets; // keeps track of each players bet for each sessionId
    mapping(address => mapping(uint256 => bool)) public HasBet; // keeps track of whether or not a user has bet in a certain session #
    mapping(address => mapping(uint256 => bool)) public HasClaimed; // keeps track of users and whether or not they have claimed reward for a session
    mapping(address => mapping(uint256 => bool)) public HasBeenRefunded; // keeps track of whether or not a user has been refunded for a particular session
    mapping(address => mapping(uint256 => uint256)) public PlayerRewardPerSession; // keeps track of player rewards per session
    mapping(address => mapping(uint256 => uint256)) public PlayerRefundPerSession; // keeps track of player refunds per session
    mapping(address => uint256) public TotalRewards; // a user's total collected payouts (lifetime)
    mapping(uint256 => Session) public _sessions; // mapping for session id to unlock corresponding session params
    mapping(address => bool) public Operators; // contract operators 
    mapping(address => uint256[]) public EnteredSessions; // list of session ID's that a particular address has bet in
    mapping(uint256 => bytes32) public settleTaskId;
   
    //----- Lottery State Variables ---------------

    uint32 private maxDuration = 600;
    uint32 private minDuration = 0;
    uint128 public devFee = 500; // 500 = 5%
    uint32 public currentSessionId;
    uint256 public SEED_COST = 0.00025 ether;
    uint256 public AUTO_COST = .00025 ether;
    uint128 constant accuracyFactor = 1 * 10**12;
    bool public autoStartSessionEnabled = true; // automatic bool to determine whether or not new sessions start automatically when closeSession is called
    bool public autoSettle = true;

    //----- Default Parameters for Session -------

    uint32 private defaultLength = 5 minutes; 
    uint80 private defaultMaxBet = 1000000 ether; 
    uint80 private defaultMinBet = .0001 ether; // > 0

    // status for betting sessions
    enum Status {
        Closed,
        Open,
        Standby,
        Voided,
        Claimable
    }

    // player bet
    struct Bet {
        address player;
        uint80 amount; 
        uint8 choice; // (0) heads or (1) tails;
    }
    
    // params for each bet session
    struct Session {
        uint32 sessionId;
        uint32 startTime;
        uint32 endTime;
        uint80 minBet;
        uint80 maxBet;
        uint128 headsBNB;
        uint128 tailsBNB;
        uint128 collectedBNB;
        uint128 BNBForDisbursal;
        uint128 totalPayouts;
        uint128 totalRefunds;
        uint16 headsCount;
        uint16 tailsCount;
        uint8 flipResult;
        Status status;
    }

    //----- Events --------------

    event SessionOpened(
        uint256 indexed sessionId,
        uint256 startTime,
        uint256 endTime,
        uint256 minBet,
        uint256 maxBet
    );

    event BetPlaced(
        address indexed player, 
        uint256 indexed sessionId, 
        uint256 amount,
        uint8 choice
    );

    event SessionClosed(
        uint256 indexed sessionId, 
        uint256 endTime,
        uint256 headsCount,
        uint256 tailsCount,
        uint256 headsBNB,
        uint256 tailsBNB,
        uint256 collectedBNB
    );

    event SessionVoided(
        uint256 indexed sessionId,
        uint256 endTime,
        uint256 headsCount,
        uint256 tailsCount,
        uint256 headsBNB,
        uint256 tailsBNB,
        uint256 collectedBNB
    );

    event CoinFlipped(
        uint256 indexed sessionId,
        uint256 flipResult
    );

    event RewardClaimed(
        address indexed player,
        uint256 indexed sessionId,
        uint256 amount
    );

    event RefundClaimed(
        address indexed player,
        uint256 indexed sessionId,
        uint256 amount
    );

    event AppleBurned(
        uint256 indexed sessionId,
        uint256 amount
    );

    event Received(
        address indexed From, 
        uint256 Amount
    );

    event EmergencyVoid(
        uint80 timestamp,
        uint256 sessionId
    );

    constructor(
        address _RNG,
        address payable _VRFSub,
        address payable _ops,
        address _weth
    ) OpsReady(_ops) {
        CoinFlipBNBRNGAddress = _RNG;
        CoinFlipBNBRNG = ICoinFlipBNBRNG(_RNG);
        VRFSubscription = _VRFSub;
        devWallet = payable(msg.sender);
        Operators[msg.sender] = true;
        Operators[_ops] = true;
        Operators[_RNG] = true;
        weth = _weth;
    }

    //---------------------------- MODIFIERS-------------------------

    // @dev: disallows contracts from entering
    modifier notContract() {
        require(!_isContract(msg.sender), "no contract");
        require(msg.sender == tx.origin, "no proxy");
        _;
    }

    modifier onlyOwnerOrOperator() {
        require(msg.sender == owner() || Operators[msg.sender] , "Not owner or operator");
        _;
    }

    modifier onlyBNBRNG() {
        require(msg.sender == CoinFlipBNBRNGAddress, "Only BNB RNG allowed");
        _;
    }

    // @dev: returns the size of the code of an address. If > 0, address is a contract.
    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    // ------------------- Setters/Getters ------------------------

    function setDefaultParams(uint32 _defaultLength, uint80 _defaultMinBet, uint80 _defaultMaxBet) external onlyOwner {
        require(_defaultLength >= minDuration && _defaultLength <= maxDuration , "Not within max/min time");
        require(_defaultMinBet > 0 , "Min bet must be > 0");
        defaultLength = _defaultLength;
        defaultMaxBet = _defaultMaxBet;
        defaultMinBet = _defaultMinBet;
    }

    // dev: set the address of the RNG contract interface
    function setCoinFlipBNBRNGAddress(address _address) external onlyOwner {
        CoinFlipBNBRNGAddress = _address;
        CoinFlipBNBRNG = ICoinFlipBNBRNG(_address);
        Operators[_address] = true;
    }

    function setVRFSubscription(address payable _address) external onlyOwner {
        VRFSubscription = _address;
    }

    function setWETH(address _weth) external onlyOwner {
        weth = _weth;
    }

    function setDevWallet(address _address) external onlyOwner {
        devWallet = payable(_address);
    }

    function setMaxMinDuration(uint32 _max, uint32 _min) external onlyOwner {
        maxDuration = _max;
        minDuration = _min;
    }

    function setAutoSessionStart(bool _bool) external onlyOwner {
        autoStartSessionEnabled = _bool;
    }

    function setAutoSettle(bool _bool) external onlyOwner {
        autoSettle = _bool;
    }

    function setCosts(uint256 _cost, uint256 _auto) external onlyOwner {
        SEED_COST = _cost;
        AUTO_COST = _auto;
    }

    function viewSessionById(uint256 _sessionId) external view returns (Session memory) {
        return _sessions[_sessionId];
    }

    function setDevFee(uint128 _devFee) external onlyOwner {
        require(_devFee > 99 && _devFee < 1001 , "fee must be between 1 and 10%");
        devFee = _devFee;
    }

    function setOperator(address _operator, bool _bool) external onlyOwner {
        Operators[_operator] = _bool;
    }

    function getEnteredSessionsLength(address _better) external view returns (uint256) {
        return EnteredSessions[_better].length;
    }

    function getBetHistory(address _better, uint256 _sessionId) external view returns 
    (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        return (Bets[_better][_sessionId].amount, 
                Bets[_better][_sessionId].choice,
                _sessions[_sessionId].startTime,
                _sessions[_sessionId].endTime,
                _sessions[_sessionId].headsBNB,
                _sessions[_sessionId].tailsBNB,
                _sessions[_sessionId].flipResult);
    }

    // ------------------- Coin Flip Function ----------------------

    // @dev: return 1 or 0
    function flipCoin() internal returns (uint8) {
        uint8 result = uint8(CoinFlipBNBRNG.flipCoin());
        _sessions[currentSessionId].status = Status.Standby;
        return result;
    }

    // ------------------- AutoSessionFxn ---------------------

    function autoStartSession() internal {
        require(autoStartSessionEnabled , "enable auto start");
        startSession(uint32(block.timestamp) + defaultLength, defaultMinBet, defaultMaxBet);
    }

    // ------------------- Start Session ---------------------- 

    function startSession(
        uint32 _endTime,
        uint80 _minBet,
        uint80 _maxBet) 
        public
        onlyOwnerOrOperator()
        {
        require(
            (currentSessionId == 0) || 
            (_sessions[currentSessionId].status == Status.Claimable) || 
            (_sessions[currentSessionId].status == Status.Voided),
            "Session must be closed, claimable, or voided"
        );

        require(
            ((_endTime - block.timestamp) >= minDuration) && ((_endTime - block.timestamp) <= maxDuration),
            "Session length outside of range"
        );

        
        currentSessionId++;

        _sessions[currentSessionId] = Session({
            status: Status.Open,
            sessionId: currentSessionId,
            startTime: uint32(block.timestamp),
            endTime: _endTime,
            minBet: _minBet,
            maxBet: _maxBet,
            headsCount: 0,
            tailsCount: 0,
            headsBNB: 0,
            tailsBNB: 0,
            collectedBNB: 0,
            BNBForDisbursal: 0,
            totalPayouts: 0,
            totalRefunds: 0,
            flipResult: 2 // init to 2 to avoid conflict with 0 (heads) or 1 (tails). is set to 0 or 1 later depending on coin flip result.
        });

        if(autoSettle) { startTask(currentSessionId); }
        
        emit SessionOpened(
            currentSessionId,
            block.timestamp,
            _endTime,
            _minBet,
            _maxBet
        );
    }

    // ------------------- Bet Function ----------------------

    // heads = 0, tails = 1
    function bet(uint128 _amount, uint8 _choice) external payable nonReentrant notContract() {
        require(msg.value == (_amount + SEED_COST + AUTO_COST), "invalid eth");
        require(_sessions[currentSessionId].status == Status.Open , "not open");
        require(_amount >= _sessions[currentSessionId].minBet && _amount <= _sessions[currentSessionId].maxBet , "Bet not within limits");
        require(_choice == 1 || _choice == 0, "0 or 1");
        require(!HasBet[msg.sender][currentSessionId] , "already bet");
        require(block.timestamp <= _sessions[currentSessionId].endTime, "Betting has ended!");
        
        if (_choice == 0) {
            Bets[msg.sender][currentSessionId].player = msg.sender;
            Bets[msg.sender][currentSessionId].amount = uint80(_amount);
            Bets[msg.sender][currentSessionId].choice = 0;
            _sessions[currentSessionId].headsCount++;
            _sessions[currentSessionId].headsBNB += _amount;
        } else {
            Bets[msg.sender][currentSessionId].player = msg.sender;
            Bets[msg.sender][currentSessionId].amount = uint80(_amount);
            Bets[msg.sender][currentSessionId].choice = 1;  
            _sessions[currentSessionId].tailsCount++;
            _sessions[currentSessionId].tailsBNB+= _amount;
        }

        _sessions[currentSessionId].collectedBNB += _amount;
        HasBet[msg.sender][currentSessionId] = true;
        EnteredSessions[msg.sender].push(currentSessionId);

        _safeTransferETHWithFallback(VRFSubscription, SEED_COST);
        
        emit BetPlaced(
            msg.sender,
            currentSessionId,
            _amount,
            _choice
        );
    }

    // --------------------- CLOSE SESSION -----------------

    function closeSession(uint256 _sessionId, bool shouldStopTask) external nonReentrant {
        require(_sessions[_sessionId].status == Status.Open , "Session must be open first");
        require(block.timestamp > _sessions[_sessionId].endTime, "Lottery not over");
        
        if (_sessions[_sessionId].headsCount == 0 || _sessions[_sessionId].tailsCount == 0) {
            _sessions[_sessionId].status = Status.Voided;
            if (autoStartSessionEnabled) {autoStartSession();}
            emit SessionVoided(
                _sessionId,
                block.timestamp,
                _sessions[_sessionId].headsCount,
                _sessions[_sessionId].tailsCount,
                _sessions[_sessionId].headsBNB,
                _sessions[_sessionId].tailsBNB,
                _sessions[_sessionId].collectedBNB
            );
        } else {
            CoinFlipBNBRNG.requestRandomWords(_sessionId);
            _sessions[_sessionId].status = Status.Closed;
            emit SessionClosed(
                _sessionId,
                block.timestamp,
                _sessions[_sessionId].headsCount,
                _sessions[_sessionId].tailsCount,
                _sessions[_sessionId].headsBNB,
                _sessions[_sessionId].tailsBNB,
                _sessions[_sessionId].collectedBNB
            );
        }

        if(shouldStopTask) { stopTask(settleTaskId[_sessionId]); }
    }

    // -------------------- Flip Coin & Announce Result ----------------

    function flipCoinAndMakeClaimable(uint32 _sessionId) external nonReentrant onlyOwnerOrOperator returns (uint8) {
        require(_sessionId <= currentSessionId , "Nonexistent session!");
        require(_sessions[_sessionId].status == Status.Closed , "Session must be closed first!");
        uint8 sessionFlipResult = flipCoin();
        _sessions[_sessionId].flipResult = sessionFlipResult;

        uint256 amountToDev;
        
        if (sessionFlipResult == 0) { // if heads wins
            _sessions[_sessionId].BNBForDisbursal = ((_sessions[_sessionId].tailsBNB) * (10000 - devFee)) / 10000;
            amountToDev = (_sessions[_sessionId].tailsBNB) - (_sessions[_sessionId].BNBForDisbursal);
        } else { // if tails..
            _sessions[_sessionId].BNBForDisbursal = ((_sessions[_sessionId].headsBNB) * (10000 - devFee)) / 10000;
            amountToDev = (_sessions[_sessionId].headsBNB) - (_sessions[_sessionId].BNBForDisbursal);
        }

        _safeTransferETHWithFallback(devWallet, amountToDev);     
        _sessions[_sessionId].status = Status.Claimable;
        emit CoinFlipped(_sessionId, sessionFlipResult);
        if (autoStartSessionEnabled) {autoStartSession();}
        return sessionFlipResult;
    }

    // -------------------- Automation Functions ----------------

    function startTask(uint256 _sessionId) internal {
        settleTaskId[_sessionId] = IOps(ops).createTaskNoPrepayment(
            address(this), 
            this.autoCloseSession.selector,
            address(this),
            abi.encodeWithSelector(this.canAutoCloseChecker.selector, _sessionId),
            ETH
        );
    }

    function canAutoCloseChecker(uint256 _sessionId) external view returns (bool canExec, bytes memory execPayload) {
        canExec = (_sessions[_sessionId].status == Status.Open && block.timestamp > _sessions[_sessionId].endTime);
        
        execPayload = abi.encodeWithSelector(
            this.autoCloseSession.selector,
            _sessionId
        );
    }

    function autoCloseSession(uint256 _sessionId) external onlyOps {
        require(_sessions[_sessionId].status == Status.Open , "Session must be open first");
        require(block.timestamp > _sessions[_sessionId].endTime, "Lottery not over");
        
        (uint256 fee, address feeToken) = IOps(ops).getFeeDetails();
        _transfer(fee, feeToken);

        if (_sessions[_sessionId].headsCount == 0 || _sessions[_sessionId].tailsCount == 0) {
            _sessions[_sessionId].status = Status.Voided;
            if (autoStartSessionEnabled) {autoStartSession();}
            emit SessionVoided(
                _sessionId,
                block.timestamp,
                _sessions[_sessionId].headsCount,
                _sessions[_sessionId].tailsCount,
                _sessions[_sessionId].headsBNB,
                _sessions[_sessionId].tailsBNB,
                _sessions[_sessionId].collectedBNB
            );
        } else {
            CoinFlipBNBRNG.requestRandomWords(_sessionId);
            _sessions[_sessionId].status = Status.Closed;
            emit SessionClosed(
                _sessionId,
                block.timestamp,
                _sessions[_sessionId].headsCount,
                _sessions[_sessionId].tailsCount,
                _sessions[_sessionId].headsBNB,
                _sessions[_sessionId].tailsBNB,
                _sessions[_sessionId].collectedBNB
            );
        }

        stopTask(settleTaskId[_sessionId]);
    }

    function autoFlip(uint256 _sessionId, uint8 _flipResult) external nonReentrant onlyBNBRNG {
        require(_sessionId <= currentSessionId , "Nonexistent session!");
        require(_sessions[_sessionId].status == Status.Closed , "Session must be closed first!");
        require(_flipResult == 0 || _flipResult == 1, "Invalid result");

        _sessions[_sessionId].status = Status.Standby;
        _sessions[_sessionId].flipResult = _flipResult;

        uint256 amountToDev;

        if (_flipResult == 0) { // if heads wins
            _sessions[_sessionId].BNBForDisbursal = ((_sessions[_sessionId].tailsBNB) * (10000 - devFee)) / 10000;
            amountToDev = (_sessions[_sessionId].tailsBNB) - (_sessions[_sessionId].BNBForDisbursal);
        } else { // if tails..
            _sessions[_sessionId].BNBForDisbursal = ((_sessions[_sessionId].headsBNB) * (10000 - devFee)) / 10000;
            amountToDev = (_sessions[_sessionId].headsBNB) - (_sessions[_sessionId].BNBForDisbursal);
        }

        _safeTransferETHWithFallback(devWallet, amountToDev);     
        _sessions[_sessionId].status = Status.Claimable;
        emit CoinFlipped(_sessionId, _flipResult);
        if (autoStartSessionEnabled) {autoStartSession();}
    }

    function stopTask(bytes32 taskId) internal {
        IOps(ops).cancelTask(taskId);
    }

    function manualStopTask(bytes32 taskId) external onlyOwnerOrOperator {
        stopTask(taskId);
    }

    // ------------------ Claim Reward Function ---------------------

    function claimRewardPerSession(uint32 _sessionId) external nonReentrant notContract() {
        require(_sessions[_sessionId].status == Status.Claimable , "Session is not claimable!");
        require(HasBet[msg.sender][_sessionId] , "didn't bet in this session"); // make sure they've bet
        require(!HasClaimed[msg.sender][_sessionId] , "Already claimed"); // make sure they can't claim twice
        require(Bets[msg.sender][_sessionId].choice == _sessions[_sessionId].flipResult , "didn't win"); // make sure they won

            uint128 playerWeight;
            uint128 playerBet = Bets[msg.sender][_sessionId].amount; // how much a user bet

            if (_sessions[_sessionId].flipResult == 0) {
                playerWeight = (playerBet * accuracyFactor) / (_sessions[_sessionId].headsBNB); 
            } else if (_sessions[_sessionId].flipResult == 1) {
                playerWeight = (playerBet * accuracyFactor) / (_sessions[_sessionId].tailsBNB); 
            }

            uint128 payout = ((playerWeight * (_sessions[_sessionId].BNBForDisbursal)) / accuracyFactor) + playerBet;
            _safeTransferETHWithFallback(msg.sender, payout);    
            
            _sessions[_sessionId].totalPayouts += payout;
            PlayerRewardPerSession[msg.sender][_sessionId] = payout;
            TotalRewards[msg.sender] += payout;
            HasClaimed[msg.sender][_sessionId] = true;
            emit RewardClaimed(msg.sender, _sessionId, payout);   
    }

    // ------------------ Refund Fxn for Voided Sessions ----------------

    // sessions are voided if there isn't at least one tails bet and one heads bet. In this case, betters receive full refunds
    function claimRefundForVoidedSession(uint256 _sessionId) external nonReentrant notContract() {
        require(_sessions[_sessionId].status == Status.Voided , "session not voided");
        require(HasBet[msg.sender][_sessionId] , "didnt bet");
        require(PlayerRewardPerSession[msg.sender][_sessionId] == 0 && !HasBeenRefunded[msg.sender][_sessionId], "Already claimed reward/refund!"); 

        uint128 refundAmount = Bets[msg.sender][_sessionId].amount;
        _safeTransferETHWithFallback(msg.sender, refundAmount);    

        HasBeenRefunded[msg.sender][_sessionId] = true;
        PlayerRefundPerSession[msg.sender][_sessionId] += refundAmount;
        _sessions[_sessionId].totalRefunds += refundAmount;
        emit RefundClaimed(msg.sender, _sessionId, refundAmount); 

    }

    // ------------------ EMERGENCY VOID ----------------

    // emergency fxn to void a session immediately
    function emergencyVoid(bool _startNew) external onlyOwnerOrOperator() {
        require(_sessions[currentSessionId].status == Status.Open , "session must be open");
        _sessions[currentSessionId].status = Status.Voided;
        if (_startNew) {autoStartSession();}
        emit EmergencyVoid(uint80(block.timestamp), currentSessionId);
    }

    // ------------------ Read Fxn to Calculate Payout ------------------

    function calculatePayout(address _address, uint256 _sessionId) external view returns (uint256) {
        uint256 calculatedPayout;

        if (_sessions[_sessionId].status != Status.Claimable ||
            !HasBet[_address][_sessionId] ||
            Bets[_address][_sessionId].choice != _sessions[_sessionId].flipResult) {
            calculatedPayout = 0; 
            return calculatedPayout;
        } else {
            uint256 playerWeight;
            uint256 playerBet = Bets[_address][_sessionId].amount; // how much a user bet

            if (_sessions[_sessionId].flipResult == 0) {
                playerWeight = (playerBet * accuracyFactor) / (_sessions[_sessionId].headsBNB); 
            } else if (_sessions[_sessionId].flipResult == 1) {
                playerWeight = (playerBet * accuracyFactor) / (_sessions[_sessionId].tailsBNB); 
            }

            uint256 payout = ((playerWeight * (_sessions[_sessionId].BNBForDisbursal)) / accuracyFactor) + playerBet;
            return payout;
        }
    }

    /**
     * @notice Transfer ETH. If the ETH transfer fails, wrap the ETH and try send it as WETH.
     */
    function _safeTransferETHWithFallback(address to, uint256 amount) internal {
        if (!_safeTransferETH(to, amount)) {
            IWETH(weth).deposit{ value: amount }();
            IERC20(weth).transfer(to, amount);
        }
    }

    /**
     * @notice Transfer ETH and return the success status.
     * @dev This function only forwards 30,000 gas to the callee.
     */
    function _safeTransferETH(address to, uint256 value) internal returns (bool) {
        (bool success, ) = to.call{ value: value, gas: 30_000 }(new bytes(0));
        return success;
    }

    receive() external payable onlyOwnerOrOperator() {
        require(msg.value <= 0.1 ether , "too much BNB");
        emit Received(msg.sender, msg.value);
    }

    fallback() external payable {revert();}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ICoinFlipBNBRNG {
    
    // returns 1, or 0, randomly. 
    function flipCoin() external view returns (uint256);

    // generates new random number.
    function requestRandomWords(uint256 session) external;
    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {
    SafeERC20,
    IERC20
} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IOps {
    function gelato() external view returns (address payable);
    function createTaskNoPrepayment(address _execAddress, bytes4 _execSelector, address _resolverAddress, bytes calldata _resolverData, address _feeToken) external returns (bytes32 task);
    function getFeeDetails() external view returns (uint256, address);
    function cancelTask(bytes32 task) external;
}

abstract contract OpsReady {
    address public immutable ops;
    address payable public immutable gelato;
    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    modifier onlyOps() {
        require(msg.sender == ops, "OpsReady: onlyOps");
        _;
    }

    constructor(address _ops) {
        ops = _ops;
        gelato = IOps(_ops).gelato();
    }

    function _transfer(uint256 _amount, address _paymentToken) internal {
        if (_paymentToken == ETH) {
            (bool success, ) = gelato.call{value: _amount}("");
            require(success, "_transfer: ETH transfer failed");
        } else {
            SafeERC20.safeTransfer(IERC20(_paymentToken), gelato, _amount);
        }
    }
}

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
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

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
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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