/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract GetHash {
    function get(string calldata addr) public pure returns (bytes32) {
        return(keccak256(abi.encodePacked(addr)));
    }
}

// Adventure Awaits: find all 4 clues, solve the puzzle and claim the reward
// #0xPoland #0xPolandHeist
contract Puzzle {
    uint256 constant BLOCKS_TO_WAIT = 10;

    bytes32 public hash;
    address public winner;
    address private hashedHashSetter;
    mapping(address => bytes32) public commits;
    mapping(address => uint256) public commitBlock;

    modifier isHashedSetter() {
        require(
            msg.sender == hashedHashSetter,
            'Only Hash Setter'
        );
        _;
    }

    constructor(bytes32 hash_) {
        hash = hash_;
        hashedHashSetter = msg.sender;
    }

    function setHash(bytes32 newHash, address newHashSetter) external isHashedSetter {
        hashedHashSetter = newHashSetter;
        hash = newHash;
        if (winner != address(0)) {
            delete commits[winner];
            delete commitBlock[winner];
            delete winner;
        }
    }

    function setHashSetter(address newSetter) external isHashedSetter {
        hashedHashSetter = newSetter;
    }

    function commit(bytes32 _hash) public {
        commits[msg.sender] = _hash;
        commitBlock[msg.sender] = block.number;
    }

    function reveal(string memory _solution) public returns(bool won) {
        bytes32 solutionHash = keccak256(abi.encodePacked(_solution));
        bytes32 solutionDoubleHash = keccak256(abi.encodePacked(solutionHash));
        bytes32 commitHash = keccak256(abi.encodePacked(msg.sender, solutionHash));
        if (
            winner == address(0) &&
            block.number > commitBlock[msg.sender] + BLOCKS_TO_WAIT &&
            solutionDoubleHash == hash &&
            commitHash == commits[msg.sender]
        ) {
            winner = msg.sender;
            won = true;
        } else {
            delete commitBlock[msg.sender];
            delete commits[msg.sender];
        }
    }

    function withdraw() public {
        require(msg.sender == winner, 'Not a winner');
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s, 'ETH Transfer Fail');
    }

    function withdrawToken(IERC20 token) public {
        require(msg.sender == winner, 'Not a winner');
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    receive() external payable {}

    function get(address addr) public pure returns (bytes32) {
        return(keccak256(abi.encodePacked(addr)));
    }
}