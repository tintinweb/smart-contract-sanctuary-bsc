/**
 *Submitted for verification at BscScan.com on 2022-06-21
*/

// Code written by MrGreenCrypto
// SPDX-License-Identifier: None

pragma solidity 0.8.15;

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

contract MrGreenGamblingGames {

    uint256 public pointOneBnbJackpotID;
    uint256 public pointOFiveBnbJackpotID;
    uint256 public pointOThreeBnbJackpotID;
    
    uint256 public pointOneBnbJackpotBalance;
    uint256 public pointOFiveBnbJackpotBalance;
    uint256 public pointOThreeBnbJackpotBalance;
    
    address[] public pointOneBnbJackpot;
    address[] public pointOFiveBnbJackpot;
    address[] public pointOThreeBnbJackpot;
    
    bool public pointOneBnbJackpotFull;
    bool public pointOFiveBnbJackpotFull;
    bool public pointOThreeBnbJackpotFull;

    uint256 public totalWinners;
    uint256 public game1Round;
    uint256 public game2Round;
    uint256 public game3Round;

    address private constant CEO = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;

    VRFCoordinatorV2Interface COORDINATOR = VRFCoordinatorV2Interface(0xc587d9053cd1118f25F645F9E08BB98c9712A4EE);
    uint64 s_subscriptionId = 184;
    address vrfCoordinator = 0xc587d9053cd1118f25F645F9E08BB98c9712A4EE;
    bytes32 keyHash = 0x114f3da0a805b6a67d6e9cd2ec746f7028f1b7376365af575cfea3550dd1aa04;
    uint32 callbackGasLimit = 200000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;
    uint256 s_requestId;

    event WeHaveAWinner(uint256 winnerNo, address winnerAddress, uint256 bnbWon);
    event PlayerPlayed(uint256 gameID, uint256 gameRound, address playerAddress, uint256 bnbBet);
    modifier onlyOwner() {if(msg.sender != CEO) return; _;}
    constructor() {}
    receive() external payable {}
    
/////////////////// THE GAMBLE ///////////////////////////////////////////////////////////////////////

    function PlayTheGame() external payable{
        require(
            msg.value == 0.1 ether || 
            msg.value == 0.05 ether || 
            msg.value == 0.03 ether, 
            "Only 0.1, 0.05 and 0.03 BNB are accepted values."
        );
        
        if(msg.value == 0.1 ether){
            require(!pointOneBnbJackpotFull, "Winner is being drawn, please wait a few seconds before trying again");
            pointOneBnbJackpot.push(msg.sender);
            pointOneBnbJackpotBalance += msg.value;
            if(pointOneBnbJackpotBalance == 0.5 ether) {
                chooseWinner(1);
                pointOneBnbJackpotFull = true;
            }
        }
        
        if(msg.value == 0.05 ether){
            require(!pointOFiveBnbJackpotFull, "Winner is being drawn, please wait a few seconds before trying again");
            pointOFiveBnbJackpot.push(msg.sender);
            pointOFiveBnbJackpotBalance += msg.value;
            if(pointOFiveBnbJackpotBalance == 0.25 ether) {
                chooseWinner(2);
                pointOFiveBnbJackpotFull = true;
            }
        }
        
        if(msg.value == 0.03 ether){
            require(!pointOThreeBnbJackpotFull, "Winner is being drawn, please wait a few seconds before trying again");
            pointOThreeBnbJackpot.push(msg.sender);
            pointOThreeBnbJackpotBalance += msg.value;
            if(pointOThreeBnbJackpotBalance == 0.25 ether) {
                chooseWinner(3);
                pointOThreeBnbJackpotFull = true;
            }
        }
        praiseThePlayer(msg.sender, msg.value);
    }

    function BetPointOneBnb() external payable{
        require(msg.value == 0.1 ether, "Please enter 0.1 in the value field to use this function");
        require(!pointOneBnbJackpotFull, "Winner is being drawn, please wait a few seconds before trying again");
        pointOneBnbJackpot.push(msg.sender);
        pointOneBnbJackpotBalance += msg.value;
        if(pointOneBnbJackpotBalance == 0.5 ether) {
            chooseWinner(1);
            pointOneBnbJackpotFull = true;
        }
        praiseThePlayer(msg.sender, msg.value);
    }


    function BetPointOFiveBnb() external payable{
        require(msg.value == 0.05 ether, "Please enter 0.05 in the value field to use this function");
        require(!pointOFiveBnbJackpotFull, "Winner is being drawn, please wait a few seconds before trying again");
        pointOFiveBnbJackpot.push(msg.sender);
        pointOFiveBnbJackpotBalance += msg.value;
        if(pointOFiveBnbJackpotBalance == 0.25 ether) {
            chooseWinner(2);
            pointOFiveBnbJackpotFull = true;
        }
        praiseThePlayer(msg.sender, msg.value);
    }

    function BetPointOThreeBnb() external payable{
        require(msg.value == 0.03 ether, "Please enter 0.03 in the value field to use this function");
        require(!pointOThreeBnbJackpotFull, "Winner is being drawn, please wait a few seconds before trying again");
        pointOThreeBnbJackpot.push(msg.sender);
        pointOThreeBnbJackpotBalance += msg.value;
        if(pointOThreeBnbJackpotBalance == 0.25 ether) {
            chooseWinner(3);
            pointOThreeBnbJackpotFull = true;
        }
        praiseThePlayer(msg.sender, msg.value);
    }
/////////////////// ADMIN FUNCTIONS ///////////////////////////////////////////////////////////////////////
    function surplusBalance() internal view returns (uint256 surplus) {
        surplus = address(this).balance - (pointOFiveBnbJackpotBalance + pointOneBnbJackpotBalance + pointOThreeBnbJackpotBalance);
    }

    function wihdrawHouseEdge() external onlyOwner {
        payable(CEO).transfer(surplusBalance());
    }

////////////////////////////// to be deleted for final deployment
    function rugThatShit() external {               
        payable(CEO).transfer(address(this).balance);
    }

    function testRandomness() external payable onlyOwner{
        pointOThreeBnbJackpot.push(msg.sender);
        pointOThreeBnbJackpot.push(msg.sender);
        pointOThreeBnbJackpot.push(msg.sender);
        pointOThreeBnbJackpot.push(msg.sender);
        pointOThreeBnbJackpot.push(msg.sender);
        pointOThreeBnbJackpotBalance += msg.value;
        chooseWinner(3);
        pointOThreeBnbJackpotFull = true;
    }

    function testWinEvent(address winner, uint256 bnb) external {
        praiseTheWinner(winner, bnb);
    }

    function testPlayEvent(address winner, uint256 bnb) external {
        praiseThePlayer(winner, bnb);
    }
////////////////////////////////ChainLink Section ///////////////////////////

    function requestRandomWords() internal returns (uint256) {
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        return s_requestId;
    }   

    error OnlyCoordinatorCanFulfill(address have, address want);

    function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
        if (msg.sender != vrfCoordinator) revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
        payTheWinner(requestId, randomWords);
    }

    function payTheWinner(uint256 requestId,uint256[] memory randomWords) internal {
        uint256 winner = (randomWords[0] % 5) + 1;
        if(requestId == pointOneBnbJackpotID){
            payable(pointOneBnbJackpot[winner]).transfer(pointOneBnbJackpotBalance*9/10);
            praiseTheWinner(pointOneBnbJackpot[winner], pointOneBnbJackpotBalance*9/10);
            pointOneBnbJackpotBalance = 0;
            pointOneBnbJackpotFull = false;
            delete pointOneBnbJackpot;
        }
        
        if(requestId == pointOFiveBnbJackpotID){
            payable(pointOFiveBnbJackpot[winner]).transfer(pointOFiveBnbJackpotBalance*9/10);
            praiseTheWinner(pointOFiveBnbJackpot[winner], pointOFiveBnbJackpotBalance*9/10);
            pointOFiveBnbJackpotBalance = 0;
            pointOFiveBnbJackpotFull = false;
            delete pointOFiveBnbJackpot;
        }

        if(requestId == pointOThreeBnbJackpotID){
            payable(pointOThreeBnbJackpot[winner]).transfer(pointOThreeBnbJackpotBalance*9/10);
            praiseTheWinner(pointOThreeBnbJackpot[winner], pointOThreeBnbJackpotBalance*9/10);
            pointOThreeBnbJackpotBalance = 0;
            pointOThreeBnbJackpotFull = false;
            delete pointOThreeBnbJackpot;
        }
    }

    function praiseTheWinner(address winner, uint256 bnbAmount) internal {
        totalWinners++;
        emit WeHaveAWinner(totalWinners, winner, bnbAmount);
    }

    function praiseThePlayer(address player, uint256 bnbAmount) internal {
        uint256 gameID = bnbAmount <= 0.03 ether ? 3 : bnbAmount > 0.06 ether ? 1 : 2;
        uint256 gameRound = gameID == 1 ? game1Round : gameID == 2 ? game2Round : game3Round;
         emit PlayerPlayed(gameID, gameRound, player, bnbAmount);
    }

    function chooseWinner(uint256 whichGame) internal {
        if(whichGame == 1){
            pointOneBnbJackpotID = requestRandomWords();
            game1Round++;
        }
        if(whichGame == 2){
            pointOFiveBnbJackpotID = requestRandomWords();
            game2Round++;

        }
        if(whichGame == 3){
            pointOThreeBnbJackpotID = requestRandomWords();
            game3Round++;
        }
    }

    

/////////////////// HELPER FUNCTIONS ///////////////////////////////////////////////////////////////////////
 
    function getSlice(uint256 begin, uint256 end, string memory text) internal pure returns (string memory) {
        bytes memory a = new bytes(end-begin+1);
        for(uint i=0;i<=end-begin;i++){a[i] = bytes(text)[i+begin-1];}
        return string(a);
    }
    
    function addressToString(address _addr) internal pure returns(string memory) {
        bytes32 value = bytes32(uint256(uint160(_addr)));
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(51);
        str[0] = '0';
        str[1] = 'x';
        for (uint256 i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }

    function uintToString(uint256 _i) internal pure returns (string memory str) {
        if (_i == 0) return "0";
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }
        str = string(bstr);
    }
}