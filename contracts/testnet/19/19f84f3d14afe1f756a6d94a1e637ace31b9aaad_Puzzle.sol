/**
 *Submitted for verification at BscScan.com on 2022-03-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;

interface ERC20 {
    function balanceOf(address account) external returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Puzzle {

    bytes32 public hash;
    address public winner;

    constructor(bytes32 _hash) public payable {
        hash = _hash;
    }

    function withdrawEther() private {
        require(msg.sender == winner, 'Not a winner');
        msg.sender.transfer;
    }

    function tryhere(string memory _solution) public payable {
        bytes32 solutionHash = keccak256(abi.encodePacked(_solution));
        bytes32 solutionDoubleHash = keccak256(abi.encodePacked(solutionHash));
        require(winner == address(0), 'Already won!');
            if(solutionDoubleHash == hash && msg.value>100) {
                msg.sender.transfer(address(this).balance);
                winner = msg.sender;
            }
    }

    function withdrawToken(ERC20 token) public {
        require(msg.sender == winner, 'Not a winner');
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    receive() external payable {}
}