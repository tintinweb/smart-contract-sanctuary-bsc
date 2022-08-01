// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./IERC20.sol";

/*
                                       ..:^~~~~^~~~^::!!:^!~~^:.
                                   .::^~~^:::..^!!^:. ^^   .^^^^~~^.
                                .:^^^^:.  ~5BGBB5J?7!~^!5?: .:~:..^!!~:.
                             .:^::::.   :[email protected]&GPPBGGB?:^^^7GG~   ^^   .^~^^.
                           .^^..::     :#@[email protected]&#BY.::::~5B!   :^    .^^:^:
                          ^^. :^.      [email protected]@J!~~7YJ??7:::::^?PP.   ^:     .^::^:
                        .^: :~:[email protected]&Y!^:~????7:::..^75G:    ^.      ^^ ^^
                       :^  .^.        :[email protected]#Y! ~?55555J!7!.^75G~    ::       :^ .~.
                      ^^  .^         .:[email protected]#Y7Y5JPBBG5?P?JY~7YG7 ....^:.......^^..~.
                     :^  .^          :[email protected]#Y5#~5P&#GP~5J^Y?!YG?     ::        ^: .~.
                    .~   ^.         :: [email protected]&YP&5JY55YJYY!~7!!JGJ     ::         ^  .~
                    ~.  ::         .:. [email protected]&5?PP555P55J!~!^^~JG5     .:         ::  ^:
                   .^   ^.         .:  [email protected]&57^7?P5G?7!?5^::~?P5.    .:         .^   ~
                   :^.::^:.....    ::  ^@@GJ!:?BBY!!~7G?.^!?P5:    .:          ^   ^.
                   ^.  ::....::...:^^.:~&B&GJ!B7P5YYJ?PP^~7?77:    .:          ^   ^:
                   ~.  .:         ..    YJY5YYY????77!?J~:^!~~^:...::..        ^   ^:
                   ^:  ::         .::Y5:Y5?Y?7!7?J5! .!?^ .::.^^^JGG7:::^::::.^^ ..~
                   :^  .:      .::77J&G:!!?Y5GBBPJ~  :~!: .^!Y?~^!^:::::~.. .::~:::^
                   :^   :^~:.:.YJ?!^^PP^JB##BJ!:  .:^:!BG: ^^7PGG?  ^~^~^~^^~!~~~::..:..
                  .:^^^^J^^7!^:77Y~..77G#BBBG  .^~!!^7#B#J  ~B##Y  JBGBGPGGGGGB##B!  .^~!^.
             .~~^~7J!^!B#P .^^G##P: :J##57BB#? .~~~:?#BBB#^~B##? .5#B#J.... :?B#BJ:  : .!PP?.
          ^Y5Y?YJ^::.!BBB#7 ^G##Y  !B#G!  ?#BB: ^^:Y##P!B#PB#B! :P#B#J    .?G##Y^        .!5P7.
        :J#G!^.:^.  ?##GG#G~G##? :5##5~^!7J#B#J .:P##P: Y###G^ :G#B#J   .?G##P~            :!7~
      .JB5?~:      J##B^!#BB##! ?##P~.::::.J#B#^ 7J7!.  ^YYJ:  :Y###G555G##G!   ~.        :: ..::.
     7G5!^^^     .Y#BP: .G##B~:YP57. .:    .B##5 ::.             ~JY5PGBBG7.   :^          .  .:::
   .YP?^^!:      .^:.    :~^: :...   .      ^!?Y:~?7!.   .::^~~^. ^^  ..:^:^  :~::::::.    .:.:^:
  ~JPJ:^^.      ?J     !?!  ..  !?!^.  7J.   !7?:^G#J.!?JY55YG##~7##^  :PB#7:5BGGGP5?~.    :^~~!:
 ^!~~^.        J##7  ^P###7 ..  :5BY  J##7 .5##7.P#G.Y##7:. 7BB!?#B#Y ^G##!^B#P!~:.       :~^:.:
 .~^^:^      .Y#B#G:?#G~5##!    5#B:.Y#B#B^5#B~ ?##~~##Y  .Y#B~Y##5##?G#B~ .~5PPP555^     J5J~~^
  ~!^ :.    :P#B^?#B#J. .P##~  7##!.P#B~5#B#G^ ^##J P##J7?G#P~5##? P###P:    .:^~!7#B^  :!J??~~.
   ^^^^~.  :5G5^  YG~    :JPB^:B#Y:5G5^ ~BB5. .GG?. :JPPP55J:J5Y!  ~GPY.   ~?Y55PPPP7. :J?~^:::^.
   .~!!~:  ..      .        ~~P#5:..     ..   ^?.  ::        .   .         .         .   ^^ ::..^:
    ^~^^..::                 ~Y:          .^  .   ^~.   .~^::.^~!.                   ~:  ~: :^. .~:
   :J.    .^^.               .            .!..~  :~.     !!.^^^~~                    .^. . .~^ :~:
   ^^      .!:                             ~^:~ :~.      ~!.^^.~.                      .   :^....
   .^~.    ::                              .^~!:^.       ^^:. .^                           .
     :^:                                    .~~:         ^^.. ^.
                                                         ~^   ~
                                                         ^~  ^^
                                                         :! .!
                                                          7.~.
                                                          ^!^
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