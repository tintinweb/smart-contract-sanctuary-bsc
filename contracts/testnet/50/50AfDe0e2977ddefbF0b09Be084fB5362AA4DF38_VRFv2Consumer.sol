//This is a Rinkeby version of the code
// The contract address is 0x50AfDe0e2977ddefbF0b09Be084fB5362AA4DF38

// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.

pragma solidity ^0.8.7;

import "./VRFCoordinatorV2Interface.sol";
import "./VRFConsumerBaseV2.sol";

contract VRFv2Consumer is VRFConsumerBaseV2
{
    VRFCoordinatorV2Interface COORDINATOR;

    uint64 s_subscriptionId;
    // Rinkeby coordinator. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator = 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f;
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;

   uint32                     callbackGasLimit = 100000;
    uint16                     requestConfirmations = 3;
    uint32                     numWords =  3;
    uint256[]           public s_randomWords;
    uint256             public s_requestId;
    address                    deployer;

    address payable[]   public players;                           
    address payable[]   public winners;  
    address                    deployerWallet = 0x6b9B8137f58aa8156cD856d17fB03bcA29f3C1fF;//0xf0530819923Ad79cFA21511eC394E68a21e160b8;                         
    bool                       gameAllowed = true;
    uint16                     minPlayers = 1;
    uint72                     minEntry = 1000000000000000;
    uint[]              public index;
    uint                       winner;
    uint                       second;
    uint                       third;
    uint                       tax;
    uint                       firstAmount;
    uint                       secondAmount;
    uint                       thirdAmount;
    uint                       drawStatus = 0;
    mapping(address => uint) public   adressToTicketQty;



//Function modifiers restrict the execution of the function until the condition is met
    modifier restricted()       //only manager can execute a function
        {
        require(msg.sender == deployer, "Only deployer can perform this operation");
        _;
        }
    modifier minimumPlayers()   //minumum number of participants
        {
        require(players.length >minPlayers, "Not enough players");
        _;
        }
    modifier minimumEth()       //minimum amount to enter the lottery
        {
        require(msg.value >= minEntry, "Not enough tokens sent"); //0.01 eth
        _;
        }
    modifier allowedGame()       //game needs to be allowed 
        {
        require(gameAllowed != false, "Entering game not allowed");
        _;
        }

    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) 
        {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        deployer = msg.sender;
        s_subscriptionId = subscriptionId;
        }

    function allowGame(bool gameState)
        public
        restricted
            {
            gameAllowed = gameState;
            }

    function SetMinPlayers(uint16 setMinPlayers)
        public
        restricted  
            {
            minPlayers = setMinPlayers;
            }

    function seMinimumEntry(uint72 setMinEntry)
        public
        restricted 
            {
            minEntry = setMinEntry;
            }

    // Assumes the subscription is funded sufficiently.
     function requestRandomWords() 
        external 
        restricted 
            {
            // Will revert if subscription is not set and funded.
                s_requestId = COORDINATOR.requestRandomWords 
                (
                keyHash,
                s_subscriptionId,
                requestConfirmations,
                callbackGasLimit,
                numWords
                );
            }
    function fulfillRandomWords(uint256, /* requestId */ uint256[] memory randomWords) 
        internal 
        override 
            {
            s_randomWords = randomWords;
            }

    receive()            //Function that allows receving >0.01 ETH into the contract  
        external
        payable
        minimumEth
        allowedGame
            {
            players.push(payable(msg.sender));
            adressToTicketQty[msg.sender] += 1;
            }

    function participate(uint _ticketQty)
        external
        payable
        minimumEth
        allowedGame
            {
            require(_ticketQty >=1);
            require(msg.value >= minEntry*_ticketQty, "Not enough tokens sent");
            for (uint i = 0; i<_ticketQty; i++)    
                {
                players.push(payable(msg.sender));
                adressToTicketQty[msg.sender] += 1;
                }
            }

    function pickWinner()
        private
        minimumPlayers
            {
            uint _temp1 = players.length;
            uint _temp2 = players.length-1;
            uint _temp3 = players.length-2;
            uint win = s_randomWords[0] % _temp1;
            winners.push(players[win]);  

            players[win] = players[_temp2];
           
            uint sec = s_randomWords[1] % _temp2;
            winners.push(players[sec]);
            players[sec] = players[_temp3];
            
            uint trd = s_randomWords[2] % _temp3;
            winners.push(players[trd]);            
            }
    
    function lotteryDraw()
        public
        restricted
            {
            winners = new address payable[] (0);
            pickWinner();


            tax          =    address(this).balance * 15 / 100;
            firstAmount  =    address(this).balance * 60 / 100;
            secondAmount =    address(this).balance * 20 / 100;
            thirdAmount  =    address(this).balance *  5 / 100;

            drawStatus = 1;
            resetTickets();
            }

    function sendRewards()
        public
        restricted
            {
            require(drawStatus !=0, "No winners picked");
            winners[0].transfer(firstAmount);
            winners[1].transfer(secondAmount);
            winners[2].transfer(thirdAmount);
            payable(deployerWallet).transfer(tax);

            players = new address payable[] (0);
            }

    function resetTickets()
        private 
            {
            for (uint i=0; i< players.length ; i++)
                {
                adressToTicketQty[players[i]] = 0;
                }
            }

    function changeDeployerAddress(address _newDeployerAddress)
        public
        restricted
            {
            deployerWallet = _newDeployerAddress;
            }

    function showWinner()
        public
        view
        returns(address)
            {
            return winners[0];
            }

    function showSecond()
        public
        view
        returns(address)
            {
            return winners[1];
            }
    function showThird()
        public
        view
        returns(address)
            {
            return winners[2];
            }

    function showAllPlayers()
        public
        view
        returns(address payable[] memory)
            {
            return players;
            }
    

}