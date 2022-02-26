/**
 *Submitted for verification at BscScan.com on 2022-02-25
*/

// SPDX-License-Identifier: MIT

/*

 Forked from something that I've been trying so hard to solve in the past.
 By the most retarded dev with 0 promises, who has been called as extremely-lazy dev, suspicious af, and being told to leave as I will break Cronos due to my existence.

*/

pragma solidity ^0.6.10;

interface ERC20 {
    function balanceOf(address account) external returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

////////////////////////////////////////////////////////////////////
// CroAVAX Puzzle - Find the clues, win small CRO just for fun^^ //
//////////////////////////////////////////////////////////////////
contract CroAVAX_Puzzle {

    bytes32 public hash;
    address public winner;

    constructor(bytes32 _hash) public payable {
        hash = _hash;
    }

    function answer(string memory _solution) public {
        bytes32 solutionHash = keccak256(abi.encodePacked(_solution));
        bytes32 solutionDoubleHash = keccak256(abi.encodePacked(solutionHash));
        require(winner == address(0), 'Already won!');
        require(solutionDoubleHash == hash, 'Invalid solution!');
        winner = msg.sender;
    }

    function withdraw() public {
        require(msg.sender == winner, 'Not a winner');
        msg.sender.transfer(address(this).balance);
    }

    function withdrawToken(ERC20 token) public {
        require(msg.sender == winner, 'Not a winner');
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    receive() external payable {}
}