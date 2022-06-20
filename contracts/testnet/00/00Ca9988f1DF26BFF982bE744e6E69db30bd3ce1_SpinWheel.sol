//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Chainlink-VRF-V2.sol";
import "./VRF-consume-baseV2.sol";
import "./Ownable.sol";
import "./IERC20.sol";

contract SpinWheel is VRFConsumerBaseV2, Ownable {
    enum Outcomes {
        BetterLuckNextTime,
        OneMoreSpin,
        TokenReward1,
        TokenReward2,
        TokenReward3
    }

    struct User {
        uint256 lastCalled;
        uint8 count; //To keep track of repeat
        Outcomes lastOutcome; //Last won price
    }

    VRFCoordinatorV2Interface internal immutable COORDINATOR;
    uint64 internal s_subscriptionId;
    address internal constant vrfCoordinator =
        0x6A2AAd07396B36Fe02a22b33cf443582f682c82f;
    bytes32 internal constant keyHash =
        0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;
    uint32 callbackGasLimit = 1000000;
    uint8 requestConfirmations = 3;
    uint8 numWords = 1;

    uint256 public lastRandom;
    uint16[] public chances; //Percentage for each wins
    IERC20 private token; //Price token
    uint256[3] public tokenRewards; //Reward for each win

    mapping(uint256 => address) internal requestToUser;
    mapping(address => User) public users;

    event WheelSpin(address userAdd, uint8 outcome, uint256 lastRandom);

    constructor(uint64 subscriptionId, address _token)
        VRFConsumerBaseV2(vrfCoordinator)
    {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        token = IERC20(_token);
        s_subscriptionId = subscriptionId;

        /*Chance work like this : 
        If random num is between 0-400, better luck next time
        If random num is between 401-700, free spin
        Likewise
        */
        chances.push(0);
        chances.push(400);
        chances.push(700);
        chances.push(800);
        chances.push(900);
        chances.push(1000);

        tokenRewards[0] = 10 * 10**18;
        tokenRewards[1] = 100 * 10**18;
        tokenRewards[2] = 1000 * 10**18;
    }

    function setTokenRewards(uint256[3] memory newRewards) external onlyOwner {
      tokenRewards = newRewards;
    }

    function setChances(uint16[] memory newChances) external onlyOwner {
      for(uint8 i = 1; i < newChances.length; i++){
        require(newChances[i] > newChances[i-1],"Invalid chance");
        chances[i] = newChances[i];
      }
    }

     function spinWheel() external {
        if (users[msg.sender].lastOutcome == Outcomes.OneMoreSpin) {
            if (users[msg.sender].count >= 4) {
                require(
                    block.timestamp >= users[msg.sender].lastCalled + 48 hours,
                    "Bad luck for you :), You can spin after 48 hours"
                );
            users[msg.sender].count = 0;    
            }
        } else {
            require(
                block.timestamp >= users[msg.sender].lastCalled + 24 hours,
                "Time limit not expired yet, try after sometime"
            );
            users[msg.sender].count = 0;
        }


        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        requestToUser[requestId] = msg.sender;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        lastRandom = randomWords[0] % 1000; //0-999
        address userAddress = requestToUser[requestId];
        User storage user = users[userAddress];

        user.lastCalled = block.timestamp;
        handleOutcome(userAddress);
    }

    function handleOutcome(address userAdd) internal {
        uint8 outcome;
        User storage user = users[userAdd];
        uint256 len = chances.length;

        for (uint8 i = 0; i < len - 1; i++) {
            if (lastRandom >= chances[i] && lastRandom < chances[i + 1]) {
                outcome = i;
                break;
            }
        }

        if (outcome == 0) {
            user.lastOutcome = Outcomes.BetterLuckNextTime;
        } else if (outcome == 1) {
            user.count++;
            user.lastOutcome = Outcomes.OneMoreSpin;
        } else if (outcome == 2) {
            user.lastOutcome = Outcomes.TokenReward1;
            token.transfer(userAdd, tokenRewards[0]);
        } else if (outcome == 3) {
            user.lastOutcome = Outcomes.TokenReward2;
            token.transfer(userAdd, tokenRewards[1]);
        } else if (outcome == 4) {
            user.lastOutcome = Outcomes.TokenReward3;
            token.transfer(userAdd, tokenRewards[2]);
        }

        emit WheelSpin(userAdd, outcome, lastRandom);
    }
}