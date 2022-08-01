// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./IERC20.sol";

/*
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&#BGGGGBGGGB##PP#BPGGB#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&##BGGB###&&BPPB#&@[email protected]@@&BBBBGGB&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#BBBB#&@@G7^~^^7JY5PGBP7Y#@&#G#&&BPPG#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#B####&@@@#! .~!!^~~^Y#[email protected]@@[email protected]@@&BGBB&@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@&BB&&##@@@@@#: ^JY5! .:^?&####G7^[email protected]@@#[email protected]@@@&BB#B#@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@BB&@#B&@@@@@@7  JPGG5?JYY5#####BY!!&@@@B#@@@@@&B##B#@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@&B#@#G#&&&&&&&&~ .?PB#GYYYY5###&&B57~#@@@@B&@@@@@@[email protected]@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@#[email protected]@&B&@@@@@@@@#! :[email protected]&[email protected]@@@##@@@@@@@#[email protected]&G&@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@[email protected]@&[email protected]@@@@@@@@&#7 :?5?7J!^^[email protected]&&&&B#&&&&&&&BB&&G&@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@#[email protected]@&[email protected]@@@@@@@@@#&J :?7:G7!.:[email protected]@@@@##@@@@@@@@B#@&G&@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@&[email protected]@@B&@@@@@@@@@##@Y [email protected]@@@@##@@@@@@@@@[email protected]@&[email protected]@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@G&@@##@@@@@@@@@&#&@P [email protected]@@@@&#@@@@@@@@@##@@B#@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@&[email protected]@@B&@@@@@@@@@&#@@G .75B5Y!7~Y5PY7B##GY!7&@@@@&#@@@@@@@@@&[email protected]@@[email protected]@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@#B&##B#&&&&&@@@@##@@B  ~JP#Y^^?PPG5~Y&BPY!7#@@@@&#@@@@@@@@@@[email protected]@@B&@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@B&@@##&&&&##&&&#BB&#G.^.~JP^5!7??JY!!BG5Y55#@@@@&#@@@@@@@@@@[email protected]@@B#@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@G&@@&#@@@@@@@@@&&@@@@?J?7???YYYY55PYJG#BPGGB#&&&##&&@@@@@@@@[email protected]@@B#@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@B#@@##@@@@@@@@@&##?7#[email protected]&[email protected]&##&BBBJ~~5###B####&[email protected]&&[email protected]@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@#[email protected]@&#@@@@@@&##55J.~#PPY?7~^^[email protected]@#GP#@&BP?YGBPB#####G&&@&##G###[email protected]@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@#[email protected]@@#BG#&#&?JYPBB!!BJ^::^JP#@@&#B#P^~#@[email protected]@BGBGBGBBGPGGG##&&#&&@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@&#BBBBJBB5PB#55?G&&55~:^^^[email protected]@&BGPPB5:^:[email protected]@G^::[email protected]@J^~^~!~~~~~^::^[email protected]@&BGPB&@@@@@@@@@
@@@@@@@@@@@@@&GGBG5JPBP^:[email protected]&BB~::!#@#J::75^^:[email protected]&GGG#Y:^^^:BG^::[email protected]&7:^:J&&&&@#Y^:^J#@@#@&P!!Y&@@@@@@@
@@@@@@@@@@B?7?Y?JB##&P^^^:[email protected]~::[email protected]@P^:[email protected]@Y:^^#@BB#?::!P^:!^:^[email protected]#!:^:[email protected]@@@&Y~::[email protected]@@@@@@@&P7!5&@@@@@
@@@@@@@@#J:~PB&#B&@@Y::~~:~G~::[email protected]#7::7GBP5J:^:[email protected]&#!::!#@?:::[email protected]#~:^:[email protected]@@&Y~::[email protected]@@@@@@@@@@@#[email protected]@@@@
@@@@@@&J^7YG#@@@@@@J::^BP:^^::[email protected]::!G&####&J:^:[email protected]&@@B??J#@@#?:::~777~::[email protected]@@G&@@@@@@@@##@&&##&@@
@@@@@[email protected]@@@@&?:^!#@&~::^G#?!75&@&#@@@@&^::[email protected]##&@@@@@@@@@@@@@GJ?7!~^^~5&@@@#[email protected]@@@@@@@@@&@@&###@@
@@@&?!YBBP#@@@@@@&B#&@@@@#GB#@#&&&@@@&@@@@@@BPY?#GY5P&@@@&##BGGB&@[email protected]@&&#B#[email protected]@#G######&@@@@&#&#B#@@@
@@GJ!J#BB&@@@@@@[email protected]@@@@[email protected]@&&@@PYPB&@@5J&@@@P5Y#B~:J&PYJ?77?~::G5::[email protected]@#!^:5#7^~~~!7YG&@@@@#BGGP#@@@
@BPGGB&@@@@@@@@J::[email protected]@B!:::[email protected]&&@@#7^[email protected]@J::[email protected]&7::5&!:~&?::5#&@5^^PY:^:[email protected]~::PB^:!PG#&@@@@@@@#GB#&#@@@@
@&GBB#[email protected]@@@@@&?:^:~#Y:~G7::[email protected]@@@7:^#&?:^:^B7:^[email protected]::GG::[email protected]@&?:^G?::7::Y~:^[email protected]&[email protected]@@@@[email protected]@@@
@@[email protected]#&@@@@#!:^BY:^:J&@&!::[email protected]@5::P&!:^G7:^:[email protected]::[email protected]!::J5Y~:!G7::[email protected]!:::!#@@@@&#BGP5:^[email protected]@#PJYYGG&@@@@
@@@BBBBG&@@#[email protected]@[email protected]@@@#J!^B#^:?#[email protected]^^7&@&~~Y&@#J!!!77J#[email protected]@G~!?&@@@GY?77!!!!5&@#JYGB###B&@@@
@@@&GPPG#@@&&@@@@@@&@@@@@@@@GG!:7#&&@@@@@&&@@@BY&@@##@@@@@@@@&@@@&@@@@@@@@@&@@@@@@@@@&@@@[email protected]##&&B#@@
@@@@BGBB&&##@@@@@@@@@@@@@@@@@G?#@@@@@@@@@@&[email protected]@&@@@BG&@@@&GB##&BGP&@@@@@@@@@@@@@@@@@@@G#@@G#@#B&@&G#@
@@@#J&@@@@&BB&@@@@@@@@@@@@@@@&@@@@@@@@@@@@&P&&[email protected]@#G&@@@@@PP&[email protected]@@@@@@@@@@@@@@@@@@@&B&@&@&[email protected]#G#@@
@@@[email protected]@@@@@&P#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@GB#[email protected]#G&@@@@@@GP&BB&G&@@@@@@@@@@@@@@@@@@@@@@&@@@#B&&&&@@@
@@@&BG&@@@@##@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&BGP#B&@@@@@@@BB#&@&[email protected]@@@@@@@@@@@@@@@@@@@@@@@@@@&@@@@@@@@
@@@@@#B#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&GG#@@@@@@@@@BB&&@B&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@[email protected]@@[email protected]@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@[email protected]@[email protected]@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#[email protected]&[email protected]@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@5&G&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@[email protected]@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
*/

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

    // only owner
    function startLottery() external onlyOwner {
        require(playerList.length >= winnerCountLimit, "not enough player");

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

    function getPlayerList() external view returns(address[] memory) {
        return playerList;
    }

    function getWinnerPlayer() external view returns(address[] memory) {
        return winnerPlayerList;
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
        delete playerList;
        delete winnerPlayerList;
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