/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Address {
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }


    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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

library SafeBEP20 {
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
    unchecked {
        uint256 oldAllowance = token.allowance(address(this), spender);
        require(oldAllowance >= value, "SafeBEP20: decreased allowance below zero");
        uint256 newAllowance = oldAllowance - value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

contract OraculaGames is Context, Ownable {
    using SafeBEP20 for IBEP20;

    struct EventInfo {
        bool exists;
        uint256 depositMultiplier;
        bool finished;
        uint256 realOutcome;
        bool outcomeSet;
        uint256 startTime;
        uint256 endTime;
        uint256 totalBets;
        address creator;
        uint256 oraculaFee;
        uint256 creatorFee;
        uint256[] outcomeIds;
        uint256[] bets;
        uint256[] legacyCoefficients;
        bool refundAllowed;
        // info
        uint256 totalNumOfBets;
        uint256 totalNumOfPlayers;
    }

    struct PlayerInfo {
        bool inGame;
        uint256[] betAmount;
        uint256 totalBet;
        uint256[] timestamp;
        uint256 outcome;
        bool winClaimed;
    }

    IBEP20 public oraculaToken;
    mapping(IBEP20 => bool) private allowedTokens;
    mapping(uint256 => IBEP20) private eventToken;
    IBEP20[] private arrayOfEventTokens;

    EventInfo[] public eventInfo;

    mapping(uint256 => mapping(address => PlayerInfo)) public playerInfo;

    address[] allPlayers;
    mapping (address => bool) private addedToAllPlayers;


    mapping(uint256 => mapping(uint256 => uint256)) public eventOutcomeIds;
    mapping(uint256 => mapping(uint256 => uint256)) private reverseOutcomes;
    mapping(uint256 => mapping(uint256 => bool)) private eventOutcomeExists;

    uint256 immutable denominator = 1000;
    address oraculaSystem;
    address betMarket;

    bool public contractActive = true;
    bool public activeCouldBeChanged = true;
    uint256 private emergencyStopCount;

    event BetPlaced(address user, uint256 amount, uint256 outcomeId);
    event EventCreated(uint256 eventId, address creator, uint256 creatorFee, uint256 oraculaFee);
    event EventFinished(uint256 eventId, uint256 realOutcome);
    event WinClaimed(address user, uint256 eventId);
    event BetTransferres(address from, address to);
    event RefundClaimed(address user, uint256 eventId);

    modifier onlyOracula() {
        require(_msgSender() == oraculaSystem || _msgSender() == owner(), "Contract: Authorisation failed");
        _;
    }

    modifier verifyEvent(uint256 _eventId) {
        require(eventInfo[_eventId].exists, "Event does not exist!");
        _;
    }

    constructor(address _oraculaSystem) {
        oraculaSystem = _oraculaSystem;
    }

    /// @dev MAIN FUNCTIONS

    /// @dev VIEW

    function getAllPlayersInfo() external view returns (address[] memory players, uint256[] memory eventIds, uint256[] memory outcomeIds, uint256[] memory betAmounts, uint256[] memory timestamps) {
        uint256 counter0;
        for (uint i; i < allPlayers.length; i++) {
            for (uint256 a; a < eventInfo.length; a++) {
                if (playerInfo[a][allPlayers[i]].inGame) {
                    counter0 += playerInfo[a][allPlayers[i]].betAmount.length;
                }
            }
        }

        players = new address[](counter0);
        eventIds = new uint256[](counter0);
        outcomeIds = new uint256[](counter0);
        betAmounts = new uint256[](counter0);
        timestamps = new uint256[](counter0);

        uint256 counter1;
        for (uint b; b < allPlayers.length; b++) {
            for (uint256 i; i < eventInfo.length; i++) {
                if (playerInfo[i][allPlayers[b]].inGame) {
                    for (uint256 x; x < playerInfo[i][allPlayers[b]].betAmount.length; x ++) {
                        players[counter1] = allPlayers[b];
                        eventIds[counter1] = i;
                        outcomeIds[counter1] = reverseOutcomes[i][playerInfo[i][allPlayers[b]].outcome];
                        betAmounts[counter1] = playerInfo[i][allPlayers[b]].betAmount[x];
                        timestamps[counter1] = playerInfo[i][allPlayers[b]].timestamp[x];
                        counter1 ++;
                    }
                }
            }
        }
        
    }

    function getAllBetsInEvent(uint256 _eventId) external view verifyEvent(_eventId) returns (address[] memory players, uint256[] memory outcomeIds, uint256[] memory betAmounts, uint256[] memory timestamps) {
        uint256 counter0;
        for (uint i; i < allPlayers.length; i++) {
            if (playerInfo[_eventId][allPlayers[i]].inGame) {
                counter0 += playerInfo[_eventId][allPlayers[i]].betAmount.length;
            }
        }
        players = new address[](counter0);
        outcomeIds = new uint256[](counter0);
        betAmounts = new uint256[](counter0);
        timestamps = new uint256[](counter0);

        uint256 counter1;
        for (uint i; i < allPlayers.length; i++) {
            if (playerInfo[_eventId][allPlayers[i]].inGame) {
                for (uint x; x < playerInfo[_eventId][allPlayers[i]].betAmount.length; x ++) {
                    players[counter1] = allPlayers[i];
                    outcomeIds[counter1] = reverseOutcomes[_eventId][playerInfo[_eventId][allPlayers[i]].outcome];
                    betAmounts[counter1] = playerInfo[_eventId][allPlayers[i]].betAmount[x];
                    timestamps[counter1] = playerInfo[_eventId][allPlayers[i]].timestamp[x];
                    counter1 ++;
                }
            }
        }

    } 

    function getReverseOutcome(uint256 _eventId, uint256 _outcomeId) external view verifyEvent(_eventId) returns (uint256) {
        return reverseOutcomes[_eventId][_outcomeId];
    }

    function getAllUserBets(address user) external view returns (uint256[] memory eventIds, uint256[] memory outcomeIds, uint256[] memory betAmounts, uint256[] memory timestamps) {
        uint256 counter1;
        for (uint256 a; a < eventInfo.length; a++) {
            if (playerInfo[a][user].inGame) {
                counter1 += playerInfo[a][user].betAmount.length;
            }
        }
        eventIds = new uint256[](counter1);
        outcomeIds = new uint256[](counter1);
        betAmounts = new uint256[](counter1);
        timestamps = new uint256[](counter1);
        uint256 counter2;
        for (uint256 i; i < eventInfo.length; i++) {
            if (playerInfo[i][user].inGame) {
                for (uint256 x; x < playerInfo[i][user].betAmount.length; x ++) {
                    eventIds[counter2] = i;
                    outcomeIds[counter2] = reverseOutcomes[i][playerInfo[i][user].outcome];
                    betAmounts[counter2] = playerInfo[i][user].betAmount[x];
                    timestamps[counter2] = playerInfo[i][user].timestamp[x];
                    counter2 ++;
                }
            }
        }
    }

    function getEventOutcomeIds(uint256 _eventId) external view verifyEvent(_eventId) returns (uint256[] memory)  {
        uint256[] memory outcomeIds = new uint256[](eventInfo[_eventId].outcomeIds.length);
        for (uint256 i; i < eventInfo[_eventId].outcomeIds.length; i++) {
            outcomeIds[i] = reverseOutcomes[_eventId][i];
        }
        return outcomeIds;
    }

    function getCoefficients(uint256 _eventId) public view verifyEvent(_eventId) returns (uint256[] memory, uint256[] memory) {
        uint256[] memory outcomes = new uint256[](eventInfo[_eventId].outcomeIds.length);
        for (uint256 x; x < eventInfo[_eventId].outcomeIds.length; x++) {
            outcomes[x] = reverseOutcomes[_eventId][x];
        }
        if (eventInfo[_eventId].outcomeSet) {
            return (outcomes, eventInfo[_eventId].legacyCoefficients);
        } else {
            uint256 noOfOutcomes = eventInfo[_eventId].outcomeIds.length;
            uint256[] memory coefficients = new uint256[](noOfOutcomes);
            for (uint256 i = 0; i < eventInfo[_eventId].outcomeIds.length; i++) {
                if (eventInfo[_eventId].bets[i] > 0) {
                    coefficients[i] = _getTotalForOutcome(_eventId, i);
                } else {
                    coefficients[i] = 0;
                }
            }
            return (outcomes, coefficients);
        }
    }

    function getFutureCoefficient(uint256 _eventId, uint256 _outcomeId, uint256 _amount) external view verifyEvent(_eventId) returns (uint256 futureCoefficient) {
        EventInfo storage _event = eventInfo[_eventId];
        uint256 notId = _event.totalBets - _event.bets[eventOutcomeIds[_eventId][_outcomeId]];
        uint256 forOutcome = _event.bets[eventOutcomeIds[_eventId][_outcomeId]] + _amount;
        futureCoefficient = ((notId - notId*(_event.creatorFee+_event.oraculaFee)/denominator) + forOutcome) * 10**18 / forOutcome;
    }

    function getAllEventsByToken(IBEP20 _token) external view returns (uint256[] memory _eventIds) {
        uint256 counter;
        for (uint256 i; i < eventInfo.length; i++) {
            if (eventToken[i] == _token) {
                _eventIds[counter] = i;
                counter ++;
            }
        }
    }

    /// @dev Player Functions

    function placeBet(uint256 _eventId, uint256 _betAmount, uint256 _outcomeID) external verifyEvent(_eventId) {
        require(contractActive, "Contract has been paused");
        EventInfo storage _event = eventInfo[_eventId];
        PlayerInfo storage _player = playerInfo[_eventId][_msgSender()];
        require(block.timestamp >= _event.startTime, "Event has not started");
        require(block.timestamp <= _event.endTime, "Event has ended");
        require(eventOutcomeExists[_eventId][_outcomeID], "Outcome doesn't exist");
        uint256 contractId = eventOutcomeIds[_eventId][_outcomeID];
        if (_player.inGame) {
            require(contractId == _player.outcome, "Trying to bet on a different outcome");
        }
        _processBet(_msgSender(), _eventId, _betAmount, contractId);
        emit BetPlaced(_msgSender(), _betAmount, _outcomeID);
    }

    function claimReward(uint256 _eventId) external verifyEvent(_eventId) {
        EventInfo storage _event = eventInfo[_eventId];
        PlayerInfo storage _player = playerInfo[_eventId][_msgSender()];
        require(_player.inGame, "Address not participated");
        require(!_player.winClaimed, "Already claimed");
        require(_event.outcomeSet, "Outcome has not been set");
        require(_player.outcome == _event.realOutcome, "Your bet has lost");

        uint256 claimAmount;
        uint256 tempoDenom = _event.bets[_event.realOutcome] - _player.totalBet;
        if (tempoDenom > 0) {
            claimAmount = (_event.totalBets - _event.bets[_event.realOutcome]) * 10**18 / (_event.bets[_event.realOutcome] - _player.totalBet) + _player.totalBet;
        } else {
            claimAmount = _event.totalBets - _event.bets[_event.realOutcome] + _player.totalBet;
        }

        _player.winClaimed = true;
        eventToken[_eventId].safeTransfer(_msgSender(), claimAmount);
        emit WinClaimed(_msgSender(), claimAmount);
    }

    function claimRefund(uint256 _eventId) external verifyEvent(_eventId) {
        EventInfo storage _event = eventInfo[_eventId];
        PlayerInfo storage _player = playerInfo[_eventId][_msgSender()];
        require(_player.inGame, "Address has not participated");
        require(!_player.winClaimed, "Win has already been claimed");
        require(_event.refundAllowed, "Refunds are not enabled for this event");
        require(_player.totalBet > 0);

        uint256 refundAmount = _player.totalBet;
        _event.bets[_player.outcome] -= refundAmount;
        _event.totalBets -= refundAmount;
        _player.inGame = false;
        _player.totalBet = 0;
        eventToken[_eventId].safeTransfer(_msgSender(), refundAmount);

        emit RefundClaimed(_msgSender(), _eventId);
    }

    /// @dev System Functions

    // 50 fee = 5%
    function initializeGame(IBEP20 _token, uint256[] memory _outcomeIds, uint256 _startTime, uint256 _endTime, address _creator, uint256 _oraculaFee, uint256 _creatorFee, uint256 _depositMultiplier) external onlyOracula returns (uint256) {
        require(contractActive, "Contract has been paused");
        require(allowedTokens[_token], "Token is not valid");
        if (address(_token) == address(0)) {
            _token = oraculaToken;
        }
        if (_depositMultiplier == 0) {
            _depositMultiplier = 100;
        }
        uint256 _numberOfOutcomes = _outcomeIds.length;
        eventInfo.push(EventInfo({
            exists : true,
            depositMultiplier: _depositMultiplier,
            finished: false,
            realOutcome : 0,
            outcomeSet : false,
            startTime : _startTime,
            endTime : _endTime,
            totalBets : 0,
            creator : _creator,
            oraculaFee: _oraculaFee,
            creatorFee: _creatorFee,
            outcomeIds: _outcomeIds,
            bets : new uint256[](_numberOfOutcomes),
            legacyCoefficients: new uint256[](_numberOfOutcomes),
            refundAllowed: false,
            totalNumOfBets: 0,
            totalNumOfPlayers: 0
        }));
        uint256 eventId = eventInfo.length - 1;
        eventToken[eventId] = _token;
        for (uint256 i = 0; i < _numberOfOutcomes; i++) {
            eventOutcomeIds[eventId][_outcomeIds[i]] = i;
            eventOutcomeExists[eventId][_outcomeIds[i]] = true;
            reverseOutcomes[eventId][i] = _outcomeIds[i];
        }
        emit EventCreated(eventId, _creator, _creatorFee, _oraculaFee);
        return eventId;
    }

    function changeEventTime(uint256 _eventId, uint256 _startTime, uint256 _endTime) external onlyOracula {
        require(eventInfo.length >= _eventId, "Event does not exist");
        EventInfo storage _event = eventInfo[_eventId];
        if (_event.endTime < block.timestamp) {
            require(!_event.outcomeSet, "Event outcome has already been set");
        }
        _event.startTime = _startTime;
        _event.endTime = _endTime;
    }

    function changeEventCreatorAddress(uint256 _eventId, address newCreator) external onlyOracula {
        require(eventInfo.length >= _eventId, "Event does not exist");
        EventInfo storage _event = eventInfo[_eventId];
        if (_event.endTime < block.timestamp) {
            require(!_event.outcomeSet, "Fees have been already distributed");
        }
        _event.creator = newCreator;
    }

    function changeEventFees(uint256 _eventId, uint256 _creatorFee, uint256 _oraculaFee) external onlyOwner {
        require(eventInfo.length >= _eventId, "Event does not exist");
        EventInfo storage _event = eventInfo[_eventId];
        if (_event.endTime < block.timestamp) {
            require(!_event.outcomeSet, "Fees have been already distributed");
        }
        _event.oraculaFee = _oraculaFee;
        _event.creatorFee = _creatorFee;
    }

    function setEventOutcome(uint256 _eventId, uint256 _realOutcome) external onlyOracula {
        EventInfo storage _event = eventInfo[_eventId];
        require(_event.exists, "Event does not exist");
        require(_event.endTime <= block.timestamp, "Event has not finished");
        require(eventOutcomeExists[_eventId][_realOutcome], "Outcome doesn't exist");
        require(!_event.refundAllowed, "Refunds issued for this event");
        uint256 contractId = eventOutcomeIds[_eventId][_realOutcome];
        (,_event.legacyCoefficients) = getCoefficients(_eventId);
        _event.realOutcome = contractId;
        _event.outcomeSet = true;

        if (_event.creatorFee > 0 || _event.oraculaFee > 0) {
            uint256 deductFrom = _event.totalBets - _event.bets[_event.realOutcome];
            uint256 deducted;
            if (_event.creatorFee > 0 && deductFrom > 0) {
                uint256 cFee = deductFrom * _event.creatorFee / denominator;
                deducted += cFee;
                eventToken[_eventId].safeTransfer(_event.creator, cFee);
            }
            if (_event.oraculaFee > 0 && deductFrom > 0) {
                uint256 oFee = deductFrom * _event.oraculaFee / denominator;
                deducted += oFee;
                eventToken[_eventId].safeTransfer(oraculaSystem, oFee);
            }
            _event.totalBets -= deducted;
        }
        emit EventFinished(_eventId, _realOutcome);
    }

    function setRefundStatus(uint256 _eventId, bool value) external onlyOracula {
        eventInfo[_eventId].refundAllowed = value;
    }

    /// @dev onlyOwner

    function addTokensToAllowList(IBEP20[] memory tokens) external onlyOwner {
        for (uint256 i; i < tokens.length; i++) {
            allowedTokens[tokens[i]] = true;
            arrayOfEventTokens.push(tokens[i]);
        }
    }

    function removeTokensFromAllowList(IBEP20[] memory tokens) external onlyOwner {
        for (uint256 i; i < tokens.length; i++) {
            allowedTokens[tokens[i]] = false;
            for (uint256 x = 0; x < arrayOfEventTokens.length; x++) {
                if (arrayOfEventTokens[x] == tokens[i]) {
                    for (uint256 z = x; z < arrayOfEventTokens.length - 1; z++) {
                        arrayOfEventTokens[z] = arrayOfEventTokens[z+1];
                    }
                    arrayOfEventTokens.pop();
                }
            }
        }
    }

    function changeOraculaAddress(address _newOracula) external onlyOwner {
        oraculaSystem = _newOracula;
    }

    function changeBetMarketAddress(address _newBetMarket) external onlyOwner {
        betMarket = _newBetMarket;
    }

    function emergencyWithdraw(IBEP20 token) external onlyOwner {
        token.safeTransfer(owner(), token.balanceOf(address(this)));
    }

    function pauseContract(bool value) external onlyOwner {
        require(activeCouldBeChanged, "Contract has been permanently closed");
        contractActive = value;
    }

    /// TODO: Change function to allow for multiple tokens
    function emergencyStop() external onlyOwner {
        if (activeCouldBeChanged) {
            contractActive = false;
            activeCouldBeChanged = false;
        } 
        require(!contractActive, "Contract is still active, idk how");
        uint256 _emergencyStopCount = emergencyStopCount;
        uint256 gasUsed;
        uint256 gasLeft = gasleft();
        for (uint256 i = emergencyStopCount; gasUsed < 5000000 && i < allPlayers.length; i ++) {
            uint256[] memory refundPerToken = new uint256[](arrayOfEventTokens.length);
            for (uint256 x; x < eventInfo.length; x++) {
                if (playerInfo[x][allPlayers[i]].inGame && playerInfo[x][allPlayers[i]].betAmount.length > 0 && !playerInfo[x][allPlayers[i]].winClaimed) {
                    refundPerToken[_getIndexOfToken(eventToken[x])] = refundPerToken[_getIndexOfToken(eventToken[x])] + playerInfo[x][allPlayers[i]].totalBet;
                    playerInfo[x][allPlayers[i]].inGame = false;
                }
            }
            for (uint256 y; y < refundPerToken.length; y++) {
                if (refundPerToken[y] > 0) {
                    IBEP20(arrayOfEventTokens[y]).safeTransfer(allPlayers[i], refundPerToken[y]);
                }
            }
            gasUsed += gasLeft - gasleft();
            gasLeft = gasleft();
            _emergencyStopCount ++;
        }
        emergencyStopCount = _emergencyStopCount;
    }

    /// @dev Internal 

    function _processBet(address user, uint256 _eventId, uint256 _betAmount, uint256 _contractId) internal {
        EventInfo storage _event = eventInfo[_eventId];
        PlayerInfo storage _player = playerInfo[_eventId][user];
        eventToken[_eventId].safeTransferFrom(_msgSender(), address(this), _betAmount);
        if (!_player.inGame) {
            _event.totalNumOfPlayers += 1;
        }
        _event.totalNumOfBets ++;
        if ( _event.depositMultiplier > 100) {
            _betAmount = _betAmount *  _event.depositMultiplier / 100;
        }
        _event.totalBets += _betAmount;
        _event.bets[_contractId] += _betAmount;
        if (!addedToAllPlayers[_msgSender()]) {
            allPlayers.push(_msgSender());
            addedToAllPlayers[_msgSender()] = true;
        }

        _player.inGame = true;
        _player.totalBet += _betAmount;
        _player.betAmount.push(_betAmount);
        _player.timestamp.push(block.timestamp);
        _player.outcome = _contractId;
    }

    function _getTotalForOutcome(uint256 _eventId, uint256 _outcome) internal view returns (uint256 coefficient) {
        EventInfo storage _event = eventInfo[_eventId];
        uint256 total = _event.totalBets;
        uint256 forOutcome = _event.bets[_outcome];
        uint256 notId = total - forOutcome;

        coefficient = ((notId - notId*(_event.creatorFee+_event.oraculaFee)/denominator) + forOutcome) * 10**18 / forOutcome;
    }

    function _getIndexOfToken(IBEP20 token) internal view returns (uint256 i) {
        for (i; i < arrayOfEventTokens.length; i++) {
            if (token == arrayOfEventTokens[i]) {
                return i;
            }
        }
    }

}