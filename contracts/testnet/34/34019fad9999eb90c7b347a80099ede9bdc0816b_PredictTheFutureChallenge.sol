/**
 *Submitted for verification at BscScan.com on 2022-09-03
*/

pragma solidity ^0.8.1;

contract PredictTheFutureChallenge {
    address public guesser;
    uint8 public guess;
    uint256 public settlementBlockNumber;

    constructor() payable {
        require(msg.value == 5 gwei);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function lockInGuess(uint8 n) public payable {
//        require(guesser == address(0));
        require(msg.value == 1 gwei);

        guesser = msg.sender;
        guess = n;
        settlementBlockNumber = block.number + 1;
    }

    function settle() public {
        require(msg.sender == guesser);
        require(block.number > settlementBlockNumber);

        uint256 answer = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))) % 10;

        guesser = address(0);
        if (guess == answer) {
            payable(msg.sender).transfer(2 gwei);
        }
    }
}