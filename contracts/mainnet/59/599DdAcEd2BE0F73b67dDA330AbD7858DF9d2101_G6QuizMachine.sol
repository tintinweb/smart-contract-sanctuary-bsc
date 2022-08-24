/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

/*
#######################################################################################################################
#######################################################################################################################

Copyright CryptIT GmbH

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on aln "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

#######################################################################################################################
#######################################################################################################################

*/

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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

library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function initOwner() public {
        require(_owner == address(0), "Already initialized owner");
        _setOwner(_msgSender());
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public onlyOwner {
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

contract G6QuizMachine is Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _quizesCount;
    mapping(uint256 => Quiz) private _quizMap;
    mapping(address => uint256) private _winnerToQuizId;
    mapping(uint256 => mapping(address => PlayerStatus))
        private _quizToPlayerStatus;
        
    mapping(address => uint256[]) private _playerToParticipations;
    mapping(address => uint256[]) private _playerToWins;

    mapping(address => uint256) private _playerFirstPlaceCount;

    address private _beneficiary;
    address private _operations;

    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public PERMIT_TYPEHASH;

    uint16 public maxPlayer;
    uint256 public startQuizDelay;

    enum PlayerStatus {
        NON_PLAYER,
        PLAYER,
        WINNER
    }

    struct Quiz {
        uint256 quizId;
        uint256 entryCost;
        address paymentToken;
        uint256 startTime;
        uint16 playerCount;
        uint16 winnersCount;
        address winnerKey;
        bool isLive;
        uint256 potSize;
        uint8[] rewardLimits;
        uint8[] rewardMultipliers;
    }

    function initialize() external {
        initOwner();
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("G6QuizMachine")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );

        //keccak256("Permit(address winner,address player)")
        PERMIT_TYPEHASH = 0xc90f75e00ff69097c29fa2d6b798b77d22323d4e389cc0af11e58d2e7d492be9;
        
        _beneficiary = 0x9cb34044A8139EEd288dF9556B398e91c76f2C64;
        _operations = 0x9cb34044A8139EEd288dF9556B398e91c76f2C64;

        maxPlayer = 3;
        startQuizDelay = 6 hours;
    }

    function setMaxPlayer(uint16 _max) external onlyOwner {
        maxPlayer = _max;
    }

    function setStartQuizDelay(uint16 _newDelay) external onlyOwner {
        require(_newDelay > 0, "Invalid delay");
        startQuizDelay = _newDelay;
    }

    function _safeTransferETH(address to, uint256 value) internal {
        (bool sentETH, ) = payable(to).call{value: value}("");
        require(sentETH, "Failed to send ETH");
    }

    function _safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "Failed to send token"
        );
    }

    function _safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "Failed to transfer from"
        );
    }

    function createQuiz(
        uint256 entryCost,
        address paymentToken,
        uint256 startTime,
        address winnerKey,
        uint8[] memory rewardLimits,
        uint8[] memory rewardMultipliers
    ) external {
        // require(startTime > (block.timestamp + 1 hours), "Invalid startime"); //TODO put back in after testing !!!
        require(_winnerToQuizId[winnerKey] == 0, "Winnerkey duplicate");

        uint256 tReward = 0;
        uint256 cAmount = entryCost.mul(maxPlayer);

        for (uint8 i; i < rewardLimits.length; i++) {
            uint256 tierReward = entryCost.mul(rewardMultipliers[i]);
            tReward.add(tierReward.mul(rewardLimits[i]));
        }

        uint256 pAmount = cAmount.sub(tReward);
        _quizesCount.increment();
        uint256 newID = _quizesCount.current();

        Quiz memory _newQuiz = Quiz({
            quizId: newID,
            entryCost: entryCost,
            paymentToken: paymentToken,
            startTime: startTime,
            playerCount: 0,
            winnersCount: 0,
            winnerKey: winnerKey,
            isLive: true,
            potSize: pAmount,
            rewardLimits: rewardLimits,
            rewardMultipliers: rewardMultipliers
        });

        _quizMap[newID] = _newQuiz;
        _winnerToQuizId[winnerKey] = newID;
    }

    function stopQuiz(uint256 quizId) external onlyOwner {
        Quiz memory _quiz = _quizMap[quizId];
        require(_quiz.playerCount == 0, "Cannot stop");
        require(_quiz.isLive, "Already stopped");
        _quizMap[quizId].isLive = false;
    }

    function participate(uint256 quizId) external payable {
        require(!_isParticipating(quizId, msg.sender), "Already in quiz");

        Quiz memory _quiz = _quizMap[quizId];
        require(_quiz.isLive, "Invalid quiz");
        require((_quiz.playerCount + 1) <= maxPlayer, "Player limit");
        require(_quiz.startTime < block.timestamp, "Cannot participate yet");

        if (_quiz.paymentToken == address(0)) {
            require(_quiz.entryCost == msg.value, "Invalid value");
        } else {
            _safeTransferFrom(
                _quiz.paymentToken,
                msg.sender,
                address(this),
                _quiz.entryCost
            );
        }

        _quizMap[quizId].playerCount++;
        _quizToPlayerStatus[quizId][msg.sender] = PlayerStatus.PLAYER;
        _playerToParticipations[msg.sender].push(quizId);

        if (_quizMap[quizId].playerCount == maxPlayer) {
            _quizMap[quizId].startTime = block.timestamp + startQuizDelay;
        }
    }

    function claimPrize(uint256 quizId, uint8 v, bytes32 r, bytes32 s) external {
        
        require(
            _isParticipating(quizId, msg.sender),
            "Cannot claim without participation"
        );

        Quiz memory _quiz = _quizMap[quizId];

        require(_quiz.playerCount == maxPlayer, "Not enough players");
        require(
            _quiz.startTime <= block.timestamp,
            "Cannot claim yet"
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        _quiz.winnerKey,
                        msg.sender
                    )
                )
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);

        require(
            recoveredAddress == _quiz.winnerKey,
            "Invalid Auth"
        );

        uint16 winnersCount = _quiz.winnersCount;
        uint256 rewardAmount = 0;

        uint8 currentLimit = 0;

        for (uint8 i; i < _quiz.rewardLimits.length; i++) {
            currentLimit += _quiz.rewardLimits[i];

            if (winnersCount < currentLimit) {
                rewardAmount = _quiz.entryCost.mul(_quiz.rewardMultipliers[i]);
                break;
            }
        }

        require(rewardAmount > 0, "Max claim reached");

        if (_quiz.paymentToken == address(0)) {
            _safeTransferETH(msg.sender, rewardAmount);
        } else {
            _safeTransfer(_quiz.paymentToken, msg.sender, rewardAmount);
        }

        if (winnersCount == 0) {
            uint256 opFee = _quiz.potSize.div(100);
            if (_quiz.paymentToken == address(0)) {
                _safeTransferETH(_beneficiary, _quiz.potSize.sub(opFee));
                _safeTransferETH(_operations, opFee);
            } else {
                _safeTransfer(
                    _quiz.paymentToken,
                    _beneficiary,
                    _quiz.potSize.sub(opFee)
                );
                _safeTransfer(_quiz.paymentToken, _operations, opFee);
            }

            _playerFirstPlaceCount[msg.sender]++;
        }

        _quizMap[quizId].winnersCount++;
        _quizToPlayerStatus[quizId][msg.sender] = PlayerStatus.WINNER;
        _playerToWins[msg.sender].push(quizId);
    }

    function getQuizCount() external view returns (uint256) {
        return _quizesCount.current();
    }

    function getQuiz(uint256 quizId) external view returns (Quiz memory) {
        return _quizMap[quizId];
    }
    
    function getQuizByWinner(address winnerKey) external view returns (Quiz memory) {
        return _quizMap[_winnerToQuizId[winnerKey]];
    }

    function _isParticipating(uint256 quizId, address user)
        internal
        view
        returns (bool)
    {
        return _quizToPlayerStatus[quizId][user] == PlayerStatus.PLAYER;
    }

    function isParticipating(uint256 quizId, address user)
        external
        view
        returns (bool)
    {
        return _isParticipating(quizId, user);
    }

    function _isWinner(uint256 quizId, address user)
        internal
        view
        returns (bool)
    {
        return _quizToPlayerStatus[quizId][user] == PlayerStatus.WINNER;
    }

    function isWinner(uint256 quizId, address user)
        external
        view
        returns (bool)
    {
        return _isWinner(quizId, user);
    }

    function getPlayerStatus(uint256 quizId, address user)
        external
        view
        returns (uint8)
    {
        return uint8(_quizToPlayerStatus[quizId][user]);
    }
    
    function getPlayerParticipations(address user)
        external
        view
        returns (uint256[] memory)
    {
        return _playerToParticipations[user];
    }

    function getPlayerWinns(address user)
        external
        view
        returns (uint256[] memory)
    {
        return _playerToWins[user];
    }

    function getPlayerFirstPlaceCount(address user)
        external
        view
        returns (uint256)
    {
        return _playerFirstPlaceCount[user];
    }

    function getBeneficiary() external view returns (address, address) {
        return (_beneficiary, _operations);
    }

    function setBeneficiary(address newAddress) external onlyOwner {
        _beneficiary = newAddress;
    }

    function setOperations(address newAddress) external onlyOwner {
        _operations = newAddress;
    }
}