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
    
    function hashString(string memory data) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(data));
    }

    function hash(bytes32 data) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(data));
    }

    function packAndHash(address addr, bytes32 data) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(addr, data));
    }
    
}

// Adventure Awaits: find all 4 clues, solve the puzzle and claim the reward
// #0xPoland #0xPolandHeist
contract Puzzle {
    uint256 constant BLOCKS_TO_WAIT = 5;

    bytes32 public _hash;
    address public winner;
    address private hashedHashSetter;
    mapping(address => bytes32) public commits;
    mapping(address => uint256) public commitBlock;

    event Winner(address winner, string solution);
    event Loser(address loser, string solution);

    modifier isHashedSetter() {
        require(
            msg.sender == hashedHashSetter,
            'Only Hash Setter'
        );
        _;
    }

    constructor(bytes32 hash_) {
        _hash = hash_;
        hashedHashSetter = msg.sender;
    }

    function setHash(bytes32 newHash) external isHashedSetter {
        _hash = newHash;
        if (winner != address(0)) {
            delete commits[winner];
            delete commitBlock[winner];
            delete winner;
        }
    }

    function setHashSetter(address newSetter) external isHashedSetter {
        hashedHashSetter = newSetter;
    }

    function commit(bytes32 hash_) public {
        commits[msg.sender] = hash_;
        commitBlock[msg.sender] = block.number;
    }

    function reveal(string calldata _solution) public returns(bool won) {
        bytes32 solutionHash = hashString(_solution);
        bytes32 solutionDoubleHash = hash(solutionHash);
        bytes32 commitHash = packAndHash(msg.sender, solutionHash);
        if (
            winner == address(0) &&
            block.number > commitBlock[msg.sender] + BLOCKS_TO_WAIT &&
            solutionDoubleHash == _hash &&
            commitHash == commits[msg.sender]
        ) {
            winner = msg.sender;
            won = true;
            emit Winner(msg.sender, _solution);
        } else {
            delete commitBlock[msg.sender];
            delete commits[msg.sender];
            emit Loser(msg.sender, _solution);
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

    function hashString(string memory data) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(data));
    }

    function hash(bytes32 data) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(data));
    }

    function packAndHash(address addr, bytes32 data) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(addr, data));
    }
}