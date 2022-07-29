// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./IERC20.sol";

contract NanoBotLottery {

    // constants
    IERC20 BUSD = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);

    // attributes
    uint public winnerCountLimit;
    uint public participateCountLimit;
    uint public poolMinimumThreshold;
    uint public participateEndTime;
    address public nanoBotContact;
    address public owner;
    uint[] numberResults;
    address[] playerList;
    address[] winnerPlayerList;
    mapping(uint => bool) checkRepeatNumber;

    // modifiers
    modifier onlyOwner {
        require(msg.sender == owner, "not owner");
        _;
    }

    modifier onlyNanoBot {
        require(msg.sender == nanoBotContact, "not nanoBot");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Participate
    function participate(address _player) public onlyNanoBot {
        require(playerList.length <= participateCountLimit, "not participate time");
        require(block.timestamp <= participateEndTime, "not start lottery time");
        playerList.push(_player);
    }

    function getPlayerList() external view returns(address[] memory) {
       return playerList;
    }

    function getWinnerPlayer() external view returns(address[] memory) {
        return winnerPlayerList;
    }

    // only owner
    function startLottery() external onlyOwner {
        require(playerList.length >= winnerCountLimit, "not enough player");

        removeLastList();

        uint randomNumber = random();
        numberResults.push(randomNumber);
        winnerPlayerList.push(playerList[randomNumber]);
        checkRepeatNumber[randomNumber] = true;

        while (numberResults.length < winnerCountLimit) {
            randomNumber = random();

            if (!checkRepeatNumber[randomNumber]) {
                numberResults.push(randomNumber);
                winnerPlayerList.push(playerList[randomNumber]);
                checkRepeatNumber[randomNumber] = true;
            }
        }
    }

    function autoSendReward() external onlyOwner {
        uint reward = getPoolAmount() / winnerPlayerList.length;
        for (uint i = 0; i < winnerPlayerList.length; i++) {
            BUSD.transfer(winnerPlayerList[i], reward);
        }
    }

    function autoSendReward(uint _amount) external onlyOwner {
        uint reward = _amount / winnerPlayerList.length;
        for (uint i = 0; i < winnerPlayerList.length; i++) {
            BUSD.transfer(winnerPlayerList[i], reward);
        }
    }

    function manualSendReward(address _player, uint _amount) external onlyOwner {
        BUSD.transfer(_player, _amount);
    }

    function removeLastPlayerList() external onlyOwner {
        delete playerList;
    }

    function removeLastWinnerPlayerList() external onlyOwner {
        delete winnerPlayerList;
    }

    function setNanoBotContact(address _contractAddress) external onlyOwner {
        nanoBotContact = _contractAddress;
    }

    function setWinnerCount(uint _winnerCountLimit) external onlyOwner {
        winnerCountLimit = _winnerCountLimit;
    }

    function setParticipateCount(uint _participateCountLimit) external onlyOwner {
        participateCountLimit = _participateCountLimit;
    }

    function setPoolMinimumThreshold(uint _poolMinimumThreshold) external onlyOwner {
        poolMinimumThreshold = _poolMinimumThreshold;
    }

    function setParticipateEndTime(uint _participateEndTime) external onlyOwner {
        participateEndTime = _participateEndTime;
        removeLastList();
    }

    function getPoolAmount() public view returns (uint) {
        return BUSD.balanceOf(address(this));
    }

    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender, block.number, block.timestamp))) % playerList.length;
    }

    function removeLastList() private {
        for (uint i = 0; i < numberResults.length; i++) {
            delete checkRepeatNumber[numberResults[i]];
        }
        delete numberResults;
        delete winnerPlayerList;
        delete playerList;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}