/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

// Code written by MrGreenCrypto
// SPDX-License-Identifier: None

pragma solidity 0.8.15;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ICCVRF {
    function requestRandomness(uint256 requestID, uint256 howManyNumbers) external payable;
}

contract CodeCraftersVrfSample {

    struct QuestForRandomness {
        address personLookingForRandomness;
        uint256 randomnessFrom;
        uint256 randomnessTo;
        uint256 randomNumberYouSoDesperatelyNeeded;
    }

    QuestForRandomness[] public iveBeenLookingForRandomness; 

    address public constant CEO = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;
    ICCVRF public randomnessSupplier = ICCVRF(0xC0de0aB6E25cc34FB26dE4617313ca559f78C0dE);
    uint256 totalRandomnessRequests;
    uint256 s_requestId;
    uint256 vrfCost = 0.001 ether;
    mapping (address => bool) internal playingAGame;

    event RandomnessServed(address personLookingForRandomness, uint256 randomnessFrom, uint256 randomnessTo, uint256 randomNumberYouSoDesperatelyNeeded);

    modifier onlyVRF() {if(msg.sender != address(randomnessSupplier)) return; _;}

    constructor() {}
    receive() external payable {}

    function getATotallyRandomNumberJustForLaughsAndGiggles(uint256 randomnessFrom, uint256 randomnessTo) external payable {
        require(msg.value >= vrfCost, "Randomness has a price!");
        require(!playingAGame[msg.sender], "Please wait for the result of your last game");
        QuestForRandomness memory newQuest;
        newQuest.personLookingForRandomness = msg.sender;
        newQuest.randomnessFrom = randomnessFrom;
        newQuest.randomnessTo = randomnessTo;
        randomnessSupplier.requestRandomness{value: vrfCost}(totalRandomnessRequests, 1);
        totalRandomnessRequests++;
        playingAGame[msg.sender] = true;
        iveBeenLookingForRandomness.push(newQuest);
    }

    function supplyRandomness(uint256 gameID,uint256[] memory randomNumbers) external onlyVRF {
        QuestForRandomness memory thisRandomRequest = iveBeenLookingForRandomness[gameID];
        uint256 moduloWhat = thisRandomRequest.randomnessTo - thisRandomRequest.randomnessFrom;
        uint256 randomNumberWithinBoundaries = randomNumbers[0] % moduloWhat + thisRandomRequest.randomnessFrom;
        emit RandomnessServed(thisRandomRequest.personLookingForRandomness, thisRandomRequest.randomnessFrom, thisRandomRequest.randomnessTo, randomNumberWithinBoundaries);
        iveBeenLookingForRandomness[gameID].randomNumberYouSoDesperatelyNeeded = randomNumberWithinBoundaries;
        playingAGame[thisRandomRequest.personLookingForRandomness] = false;
    }

    function rescueToken(address token) external {
        IBEP20(token).transfer(CEO, IBEP20(token).balanceOf(address(this)));    
    }

    function rescueBNB() external {
        payable(CEO).transfer(address(this).balance);
    }

    function setVRFCost(uint256 cost) external {
        require(msg.sender == CEO, "Only MrGreen can do this");
        vrfCost = cost;
    }
}