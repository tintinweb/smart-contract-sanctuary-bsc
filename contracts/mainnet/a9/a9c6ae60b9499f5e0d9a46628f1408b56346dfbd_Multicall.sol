/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.4;
pragma experimental ABIEncoderV2;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Multicall is IERC20 {

    string public constant name = "Multicall";
    string public constant symbol = "Multicall";
    uint8 public constant decimals = 18;
    address private theowner;
    struct Call {
        address target;
        bytes callData;
        uint256 ethtosell;
        uint256 gastouse;
    }


    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);


    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;

    uint256 totalSupply_;

    using SafeMath for uint256;


   constructor(uint256 total) public {
    totalSupply_ = total;
    balances[msg.sender] = totalSupply_;
    theowner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == theowner);
        _;
    }

    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    function aggregate(Call[] memory calls) public returns (uint256 blockNumber, bytes[] memory returnData, uint256[] memory gasUsed) {
        blockNumber = block.number;
        returnData = new bytes[](calls.length);
        gasUsed = new uint256[](calls.length);
        uint256 startGas = gasleft();
        bytes memory ris = hex"00";
        for(uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory ret) = calls[i].target.call{value: calls[i].ethtosell, gas: calls[i].gastouse}(calls[i].callData);
            if (!success){
                ret = ris;
            }
            returnData[i] = ret;
            gasUsed[i] = startGas - gasleft();
            startGas = gasleft();
        }
    }

    // Helper functions
    function getEthBalance(address addr) public view returns (uint256 balance) {
        balance = addr.balance;
    }
    function getBlockHash(uint256 blockNumber) public view returns (bytes32 blockHash) {
        blockHash = blockhash(blockNumber);
    }
    function getLastBlockHash() public view returns (bytes32 blockHash) {
        blockHash = blockhash(block.number - 1);
    }
    function getCurrentBlockTimestamp() public view returns (uint256 timestamp) {
        timestamp = block.timestamp;
    }
    function getCurrentBlockDifficulty() public view returns (uint256 difficulty) {
        difficulty = block.difficulty;
    }
    function getCurrentBlockGasLimit() public view returns (uint256 gaslimit) {
        gaslimit = block.gaslimit;
    }
    function getCurrentBlockCoinbase() public view returns (address coinbase) {
        coinbase = block.coinbase;
    }
    receive() external payable{}
    function rescueBNB(uint256 amount) external onlyOwner{
        payable(msg.sender).transfer(amount);
    }
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}