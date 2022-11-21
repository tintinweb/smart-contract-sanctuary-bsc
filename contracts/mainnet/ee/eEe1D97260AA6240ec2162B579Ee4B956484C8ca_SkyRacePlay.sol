// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


interface ISkyRace {
    function ownerOf(uint256) external view returns (address); 
    function getInvite(address) external view returns (address);
    function getLeader(address) external view returns (address);
}


contract SkyRacePlay is Ownable {

    using SafeERC20 for IERC20;

    IERC20 public platformToken;
    IERC20 public usdtToken;
    ISkyRace public skyRace;
    uint256 public platformTax;
    uint256 public oneLevelTax;
    uint256 public twoLevelTax;
    uint256 public threeLevelTax;
    uint256 public platformAmount;
    uint256 public minDeposit;
    uint256 public maxRoomTax;

    struct QuizItem {
        uint256 status;
        uint256 result;
        uint256 allowCreationTime;
        uint256 beginTime;
        uint256 endTime;
    }

    struct RoomItem {
        uint256 quizID;
        uint256 oddsType;
        uint256 odds;
        uint256 nftID;
        address creator;
        uint256 resultOneTotal;
        uint256 resultTwoTotal;
        uint256 resultOneFixedOdds;
        uint256 resultTwoFixedOdds;
        uint256 roomDeposit;
        uint256 nowRoomNumber;
        uint256 maxRoomNumber;
        uint256 roomTax;
        uint256 minUserJoinAmount;
    }

    struct UserRecord {
        uint256 quizID;
        uint256 roomID;
        uint256 amount;
        uint256 result;
        uint256 withdrawalState;
    }

    mapping (address => bool) private operators;
    mapping (uint256 => QuizItem) public quizList;
    mapping (uint256 => RoomItem) public roomList;
    mapping (address => UserRecord[]) public userRecordList;

    event LogReceived(address, uint);
    event LogFallback(address, uint);
    event LogCreatQuizRoom(address, uint);
    event LogAddMargin(address, uint, uint);

    constructor() {
        skyRace = ISkyRace(0xC5219bf9Ac99720B5154997A8038d52D630E38F7);
        platformToken = IERC20(0x0DBEb7df568fb4cf91a62C1D9F6D1c29ED95693E);
        usdtToken = IERC20(0x55d398326f99059fF775485246999027B3197955);
        minDeposit = 1000000000000000000000;
        platformTax = 10;
        oneLevelTax = 10;
        twoLevelTax = 10;
        threeLevelTax = 10;
        maxRoomTax = 60;
    }


    function setSkyRace (address _address) public onlyOwner {
        skyRace = ISkyRace(_address);
    }


    function setMinDeposit (uint256 _minDeposit) public onlyOwner {
        minDeposit = _minDeposit;
    }


    function setOperators(address _address, bool _bool) public onlyOwner {
        operators[_address] = _bool;
    }


    function setPlatformToken (IERC20 _token) public onlyOwner {
        platformToken = _token;
    }


    function setUsdtToken (IERC20 _token) public onlyOwner {
         usdtToken = _token;
    }


    function setTax (uint256 _index, uint256 _tax) public onlyOwner {
        if (_index == 0) {
            platformTax = _tax;
        }
        else if (_index == 1) {
            oneLevelTax = _tax;
        }
        else if (_index == 2) {
            twoLevelTax = _tax;
        }
        else if (_index == 3) {
            threeLevelTax = _tax;
        }
        else if (_index == 5) {
            maxRoomTax = _tax;
        }
    }


    function createQuizProject (uint256 _quizID, uint256 _beginTime, uint256 _endTime, uint256 _allowCreationTime) public {
        require(operators[msg.sender], "Operators only");
        require(quizList[_quizID].status == 0, "The ID has been occupied");
        require(_beginTime < _endTime, "Time anomaly");

        quizList[_quizID].status = 1;
        quizList[_quizID].beginTime = _beginTime;
        quizList[_quizID].endTime = _endTime;
        quizList[_quizID].allowCreationTime = _allowCreationTime;
    }


    function editQuizProject (uint256 _quizID, uint256 _beginTime, uint256 _endTime, uint256 _result, uint256 _allowCreationTime) public {
        require(operators[msg.sender], "Operators only");
        require(quizList[_quizID].status == 1, "The ID has been occupied");
        require(_beginTime < _endTime, "Time anomaly");
        
        quizList[_quizID].beginTime = _beginTime;
        quizList[_quizID].endTime = _endTime;
        quizList[_quizID].result = _result;
        quizList[_quizID].allowCreationTime = _allowCreationTime;
    }


    function assistCreateQuizRoom (address _roomOwner, uint256 _roomId, uint256 _quizID, uint256 _nftID, uint256 _oddsType, uint256 _maxRoomNumber, uint256 _roomTax, uint256 _minUserJoinAmount, uint256 _resultOneFixedOdds, uint256 _resultTwoFixedOdds, uint256 _roomDeposit) public {
        require(operators[msg.sender], "Operators only");
        require(roomList[_roomId].quizID == 0, "Room ID already exists");
        require(skyRace.ownerOf(_nftID) == _roomOwner, "You are not the owner");
        require(quizList[_quizID].status == 1, "Abnormal state");
        require(quizList[_quizID].result == 0, "The results have been announced");
        require(block.timestamp >= quizList[_quizID].allowCreationTime && block.timestamp < quizList[_quizID].endTime, "Out of time");
        require(_roomTax <= maxRoomTax, "Room Tax exceeds the limit");

        if (_oddsType == 2) {
            require(_roomDeposit >= minDeposit, "It needs to be more than the minimum amount");
            platformToken.safeTransferFrom(msg.sender, address(this), _roomDeposit);
            roomList[_roomId].resultOneFixedOdds = _resultOneFixedOdds;
            roomList[_roomId].resultTwoFixedOdds = _resultTwoFixedOdds;
            roomList[_roomId].roomDeposit = _roomDeposit;
        }

        roomList[_roomId].quizID = _quizID;
        roomList[_roomId].creator = _roomOwner;
        roomList[_roomId].oddsType = _oddsType;
        roomList[_roomId].nftID = _nftID;
        roomList[_roomId].maxRoomNumber = _maxRoomNumber;
        roomList[_roomId].roomTax = _roomTax;
        roomList[_roomId].minUserJoinAmount = _minUserJoinAmount;

        emit LogCreatQuizRoom(_roomOwner, _roomId);
    } 


    function createQuizRoom (uint256 _roomId, uint256 _quizID, uint256 _nftID, uint256 _oddsType, uint256 _maxRoomNumber, uint256 _roomTax, uint256 _minUserJoinAmount, uint256 _resultOneFixedOdds, uint256 _resultTwoFixedOdds, uint256 _roomDeposit) public {
        require(roomList[_roomId].quizID == 0, "Room ID already exists");
        require(skyRace.ownerOf(_nftID) == msg.sender, "You are not the owner");
        require(quizList[_quizID].status == 1, "Abnormal state");
        require(quizList[_quizID].result == 0, "The results have been announced");
        require(block.timestamp >= quizList[_quizID].allowCreationTime && block.timestamp < quizList[_quizID].endTime, "Out of time");
        require(_roomTax <= maxRoomTax, "Room Tax exceeds the limit");

        if (_oddsType == 2) {
            require(_roomDeposit >= minDeposit, "It needs to be more than the minimum amount");
            platformToken.safeTransferFrom(msg.sender, address(this), _roomDeposit);
            roomList[_roomId].resultOneFixedOdds = _resultOneFixedOdds;
            roomList[_roomId].resultTwoFixedOdds = _resultTwoFixedOdds;
            roomList[_roomId].roomDeposit = _roomDeposit;
        }


        roomList[_roomId].quizID = _quizID;
        roomList[_roomId].creator = msg.sender;
        roomList[_roomId].oddsType = _oddsType;
        roomList[_roomId].nftID = _nftID;
        roomList[_roomId].maxRoomNumber = _maxRoomNumber;
        roomList[_roomId].roomTax = _roomTax;
        roomList[_roomId].minUserJoinAmount = _minUserJoinAmount;

        emit LogCreatQuizRoom(msg.sender, _roomId);
    }


    function editQuizRoom (uint256 _roomId, uint256 _maxRoomNumber, uint256 _minUserJoinAmount) public {
        require(roomList[_roomId].creator == msg.sender, "Not Creator");
        roomList[_roomId].maxRoomNumber = _maxRoomNumber;
        roomList[_roomId].minUserJoinAmount = _minUserJoinAmount;
    }


    function addMargin (uint256 _roomId, uint256 _amount) public {
        require(roomList[_roomId].oddsType == 2, "Types of abnormal");
        platformToken.safeTransferFrom(msg.sender, address(this), _amount);
        roomList[_roomId].roomDeposit = roomList[_roomId].roomDeposit + _amount;

        emit LogAddMargin(msg.sender, _roomId, _amount);
    }


    function creatorWithdrawalMargin (uint256 _roomId, uint256 _amount, uint256 _withdrawalType) public {
        require(roomList[_roomId].oddsType == 2, "Types of abnormal");
        require(roomList[_roomId].creator == msg.sender, "Not Creator");
        require(roomList[_roomId].roomDeposit >= _amount, "Lack of balance");

        uint256 _quizID = roomList[_roomId].quizID;
        require(block.timestamp >= quizList[_quizID].endTime, "Out of time");

        if (quizList[_quizID].result == 3) {
            platformToken.safeTransfer(msg.sender, roomList[_roomId].roomDeposit);
            roomList[_roomId].roomDeposit = 0;
        }
        else {
            if (_withdrawalType == 1) {
                uint256 _oneFinal = roomList[_roomId].resultOneTotal + roomList[_roomId].roomDeposit - _amount;
                require(_oneFinal * roomList[_roomId].resultTwoFixedOdds == roomList[_roomId].resultTwoTotal * roomList[_roomId].resultOneFixedOdds, "The amount is wrong [1]");
                platformToken.safeTransfer(msg.sender, _amount);
                roomList[_roomId].roomDeposit = roomList[_roomId].roomDeposit - _amount;
            } 
            else if (_withdrawalType == 2) {
                uint256 _twoFinal = roomList[_roomId].resultTwoTotal + roomList[_roomId].roomDeposit - _amount;
                require(roomList[_roomId].resultOneTotal * roomList[_roomId].resultTwoFixedOdds == _twoFinal * roomList[_roomId].resultOneFixedOdds, "The amount is wrong [2]");
                platformToken.safeTransfer(msg.sender, _amount);
                roomList[_roomId].roomDeposit = roomList[_roomId].roomDeposit - _amount;
            }
        }
    }

    function assistUserJoin (address _userAddress, uint256 _roomId, uint256 _amount, uint256 _result) public {
        require(operators[msg.sender], "Operators only");
        require(skyRace.getInvite(_userAddress) != address(0), "Please register first");
        require(_result > 0 && _result < 3, "The betting result is wrong");
        require(roomList[_roomId].nowRoomNumber < roomList[_roomId].maxRoomNumber, "Exceeding the number limit");
        require(_amount >= roomList[_roomId].minUserJoinAmount, "Less than the minimum participation quota");

        uint256 _quizID = roomList[_roomId].quizID;
        require(block.timestamp >= quizList[_quizID].beginTime && block.timestamp < quizList[_quizID].endTime, "It's not in the time frame");
        require(quizList[_quizID].result == 0, "The results have been announced");

        if (roomList[_roomId].oddsType == 2) {
            if (_result == 1) {
                uint256 _oneEexpected = roomList[_roomId].resultOneTotal + _amount;
                uint256 _twoEexpected = roomList[_roomId].resultTwoTotal + roomList[_roomId].roomDeposit;

                require((_oneEexpected * roomList[_roomId].resultTwoFixedOdds) <= (roomList[_roomId].resultOneFixedOdds * _twoEexpected), "The amount exceeded the odds limit [1]");
            }
            else if (_result == 2) {
                uint256 _oneEexpected = roomList[_roomId].resultOneTotal + roomList[_roomId].roomDeposit;
                uint256 _twoEexpected = roomList[_roomId].resultTwoTotal + _amount;

                require((_twoEexpected * roomList[_roomId].resultOneFixedOdds) <= (_oneEexpected * roomList[_roomId].resultTwoFixedOdds), "The amount exceeded the odds limit [2]");
            }
        }

        platformToken.safeTransferFrom(msg.sender, address(this), _amount);

        if (_result == 1) {
            roomList[_roomId].resultOneTotal = roomList[_roomId].resultOneTotal + _amount;
        }
        else if (_result == 2) {
            roomList[_roomId].resultTwoTotal = roomList[_roomId].resultTwoTotal + _amount;
        }

        userRecordList[_userAddress].push(
            UserRecord({
                quizID: _quizID,
                roomID: _roomId,
                amount: _amount,
                result: _result,
                withdrawalState: 0
            })
        );

        roomList[_roomId].nowRoomNumber = roomList[_roomId].nowRoomNumber + 1;
    }


    function userJoin (uint256 _roomId, uint256 _amount, uint256 _result) public {
        require(skyRace.getInvite(msg.sender) != address(0), "Please register first");
        require(_result > 0 && _result < 3, "The betting result is wrong");
        require(roomList[_roomId].nowRoomNumber < roomList[_roomId].maxRoomNumber, "Exceeding the number limit");
        require(_amount >= roomList[_roomId].minUserJoinAmount, "Less than the minimum participation quota");

        uint256 _quizID = roomList[_roomId].quizID;
        require(block.timestamp >= quizList[_quizID].beginTime && block.timestamp < quizList[_quizID].endTime, "It's not in the time frame");
        require(quizList[_quizID].result == 0, "The results have been announced");

        if (roomList[_roomId].oddsType == 2) {
            if (_result == 1) {
                uint256 _oneEexpected = roomList[_roomId].resultOneTotal + _amount;
                uint256 _twoEexpected = roomList[_roomId].resultTwoTotal + roomList[_roomId].roomDeposit;

                require((_oneEexpected * roomList[_roomId].resultTwoFixedOdds) <= (roomList[_roomId].resultOneFixedOdds * _twoEexpected), "The amount exceeded the odds limit [1]");
            }
            else if (_result == 2) {
                uint256 _oneEexpected = roomList[_roomId].resultOneTotal + roomList[_roomId].roomDeposit;
                uint256 _twoEexpected = roomList[_roomId].resultTwoTotal + _amount;

                require((_twoEexpected * roomList[_roomId].resultOneFixedOdds) <= (_oneEexpected * roomList[_roomId].resultTwoFixedOdds), "The amount exceeded the odds limit [2]");
            }
        }

        platformToken.safeTransferFrom(msg.sender, address(this), _amount);

        if (_result == 1) {
            roomList[_roomId].resultOneTotal = roomList[_roomId].resultOneTotal + _amount;
        }
        else if (_result == 2) {
            roomList[_roomId].resultTwoTotal = roomList[_roomId].resultTwoTotal + _amount;
        }

        userRecordList[msg.sender].push(
            UserRecord({
                quizID: _quizID,
                roomID: _roomId,
                amount: _amount,
                result: _result,
                withdrawalState: 0
            })
        );

        roomList[_roomId].nowRoomNumber = roomList[_roomId].nowRoomNumber + 1;
    }


    function userWithdrawal (address _address, uint256[] memory _indexList) public {
        require(_indexList.length > 0, "Abnormal data");

        uint256 _totalAmount = 0;
        uint256 _oneLevelTotalAmount;
        uint256 _twoLevelTotalAmount;
        uint256 _threeLevelTotalAmount;
        uint256 _platformTotalAmount;

        for (uint256 _index = 0; _index < _indexList.length; _index = _index + 1) {

            uint256 _recordIndex = _indexList[_index];
            uint256 _quizID = userRecordList[_address][_recordIndex].quizID;
            uint256 _roomID = userRecordList[_address][_recordIndex].roomID;
            uint256 _amount = userRecordList[_address][_recordIndex].amount;

            require(userRecordList[_address][_recordIndex].withdrawalState == 0, "Abnormal recording status");

            if (quizList[_quizID].result == 3) {
                _totalAmount = _totalAmount + _amount;
                updateRecordState(_address, _recordIndex);
            }
            else if ((roomList[_roomID].resultOneTotal == 0 || roomList[_roomID].resultTwoTotal == 0) && roomList[_roomID].oddsType == 1) {
                if (block.timestamp > quizList[_quizID].endTime && quizList[_quizID].result != 0) {
                    _totalAmount = _totalAmount + _amount;
                }
                updateRecordState(_address, _recordIndex);
            }
            else if (quizList[_quizID].result == userRecordList[_address][_recordIndex].result) {

                uint256 _winAmount = getWinAmount(_roomID, quizList[_quizID].result, _amount);

                uint256 _roomAmount = 0;

                if (roomList[_roomID].roomTax > 0) {
                    _roomAmount = _winAmount / 1000 * roomList[_roomID].roomTax;
                    platformToken.safeTransfer(roomList[_roomID].creator, _roomAmount);
                }

                _platformTotalAmount = _platformTotalAmount + _winAmount / 1000 * platformTax;
                _oneLevelTotalAmount = _oneLevelTotalAmount + _winAmount / 1000 * oneLevelTax;
                _twoLevelTotalAmount = _twoLevelTotalAmount + _winAmount / 1000 * twoLevelTax;
                _threeLevelTotalAmount = _threeLevelTotalAmount + _winAmount / 1000 * threeLevelTax;

                _totalAmount = _totalAmount + _amount + _winAmount - _roomAmount;
                updateRecordState(_address, _recordIndex);
            }
            
        }

        platformAmount = platformAmount + _platformTotalAmount;

        _totalAmount = _totalAmount - _oneLevelTotalAmount - _twoLevelTotalAmount - _threeLevelTotalAmount;
        platformToken.safeTransfer(_address, _totalAmount);

        levelBonus(_oneLevelTotalAmount, _twoLevelTotalAmount, _threeLevelTotalAmount, _address);
    }


    function getWinAmount (uint256 _roomID, uint256 _result, uint256 _amount) public view returns (uint256) {
        uint256 _winAmount = 0;
        if (roomList[_roomID].oddsType == 1) {
            if (_result == 1) {
                _winAmount = _amount * roomList[_roomID].resultTwoTotal / roomList[_roomID].resultOneTotal;
            }
            else if (_result == 2) {
                _winAmount = _amount * roomList[_roomID].resultOneTotal / roomList[_roomID].resultTwoTotal;
            }
        }
        else if (roomList[_roomID].oddsType == 2) {
            if (_result == 1) {
                _winAmount = _amount * roomList[_roomID].resultTwoFixedOdds / roomList[_roomID].resultOneFixedOdds;
            }
            else if (_result == 2) {
                _winAmount = _amount * roomList[_roomID].resultOneFixedOdds / roomList[_roomID].resultTwoFixedOdds;
            }
        }
        return _winAmount;
    }


    function updateRecordState (address _address, uint256 _recordIndex) private {
        userRecordList[_address][_recordIndex].withdrawalState = 1;
    }

    function levelBonus (uint256 _oneLevelTotalAmount, uint256 _twoLevelTotalAmount, uint256 _threeLevelTotalAmount, address _address) private {

        address _levelOneAddress = skyRace.getInvite(_address);

         if (_oneLevelTotalAmount > 0) {
            platformToken.safeTransfer(_levelOneAddress, _oneLevelTotalAmount);
        }

        if (_twoLevelTotalAmount > 0) {

            address _levelTwoAddress = skyRace.getInvite(_levelOneAddress);

            if (_levelTwoAddress != address(0)) {
                platformToken.safeTransfer(_levelTwoAddress, _twoLevelTotalAmount);
            }
            else {
                platformAmount = platformAmount + _twoLevelTotalAmount;
            }

            if (_threeLevelTotalAmount > 0) {

                address _levelThreeAddress = skyRace.getInvite(_levelTwoAddress);

                if (_levelThreeAddress != address(0)) {
                    platformToken.safeTransfer(_levelThreeAddress, _threeLevelTotalAmount);
                } else {
                    platformAmount = platformAmount + _threeLevelTotalAmount;
                }
            }
        }
    }


    function ownerOperationU (uint256 _amount, address _to) public onlyOwner {
        usdtToken.safeTransfer(_to, _amount);
    }


    function platformWithdrawal (address _to) public onlyOwner {
        platformToken.safeTransfer(_to, platformAmount);
        platformAmount = 0;
    }


    receive() external payable {
        emit LogReceived(msg.sender, msg.value);
    }


    fallback() external payable {
        emit LogFallback(msg.sender, msg.value);
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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

import "../IERC20.sol";
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