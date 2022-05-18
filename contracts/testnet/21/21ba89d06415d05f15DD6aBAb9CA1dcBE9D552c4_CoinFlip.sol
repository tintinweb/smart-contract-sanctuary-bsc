// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IHousePool.sol";
import "./Ownable.sol";
import "./IERC20.sol";

contract CoinFlip
{
    bytes32 private _keyHash;
    uint32 private _callbackGasLimit;
    uint16 private _requestConfirmations;
    uint64 private _subscriptionId;

    bool private _vrfLock;

    address public requestor;

    uint256 public requestId;

    IHousePool public immutable housePool;

    constructor()
    {
        //Get HousePool contract
        housePool = IHousePool(0x13800cAcccA2A76050645f60322E8b99cCD5D90B);

        //Set VRF request parameters
        _keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;
        _subscriptionId = 690;
        _requestConfirmations = 3;
        _callbackGasLimit = 100000;
    }

    receive() external payable {}

    function flipCoin() external payable returns (bool)
    {
        require(msg.value > 0);
        require(_vrfLock == false);

        // Build bets array for request
        uint256[5][][] memory bets = new uint256[5][][](1);
        bets[0] = new uint256[5][](1);

        bets[0][0] = [msg.value, 100, 1, 246, 500];

        requestId = housePool.requestETHRoll{value : msg.value}(
            bets, 
            _keyHash, 
            _subscriptionId, 
            _requestConfirmations, 
            _callbackGasLimit
        );

        requestor = msg.sender;
        _vrfLock = true;

        return true;
    }

    function coinFlipResult() external returns (bool)
    {
        //Check a request been made
        require(requestId != 0);

        housePool.withdrawRoll(requestId);

        //Get request result
        bool isWinner = housePool.isWinningBet(requestId, 0, 0);

        if(isWinner)
        {
            //Get the bet values
            (,,,uint256[5][][] memory bets) = housePool.getRoll(requestId);

            //Bet amount is multiplied by the payout odds 
            //which is then divided by 100, because the 
            //payout odds are returned like a 2 point floating number
            //Read more about this in further documentation
            uint256 winnings = bets[0][0][0];
            winnings += (bets[0][0][0] * bets[0][0][1]) / 100;

            //Send winnings
            (bool success,) = requestor.call{value: winnings}("");
            require(success);
        }

        //Reset game
        requestId = 0;
        _vrfLock = false;

        return isWinner;
    }
}