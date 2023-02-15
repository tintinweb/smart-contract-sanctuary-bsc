/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BritCoin {
    address public owner;
    string public name = "BritCoin";
    string public symbol = "BRT";
    uint8 public decimals = 8;
    uint256 public totalSupply = 21000000 * (10 ** decimals);
    uint256 public remainingSupply = totalSupply;
    uint256 public constant halvingInterval = 1460 days;
    uint256 public lastHalvingTime = block.timestamp;
    mapping(address => uint256) public balances;

    // Rewards to choose from for each halving event
    uint256[] public rewardAmounts = [500000 * (10 ** decimals), 1000000 * (10 ** decimals), 1500000 * (10 ** decimals), 2000000 * (10 ** decimals)];

    constructor() {
        owner = msg.sender;
        balances[msg.sender] = 100000 * (10 ** decimals); // Give the contract creator 100,000 tokens
        balances[address(this)] = totalSupply - balances[msg.sender];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        require(balances[_to] + _value >= balances[_to]);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function halveSupply() public {
        require(msg.sender == owner);
        require(block.timestamp >= lastHalvingTime + halvingInterval);
        require(remainingSupply > totalSupply / (2**16)); // Ensure a minimum of 1/65536th of the total supply remains after each halving

        // Select a random reward amount from the rewardAmounts array
        uint256 rewardIndex = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, remainingSupply))) % rewardAmounts.length;
        uint256 rewardAmount = rewardAmounts[rewardIndex];

        remainingSupply = totalSupply - (totalSupply / (2**((block.timestamp - lastHalvingTime) / halvingInterval)));
        lastHalvingTime = block.timestamp;
        balances[address(this)] = remainingSupply;
        emit Halving(lastHalvingTime, remainingSupply, rewardAmount);
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(tokenId < totalSupply, "Invalid token ID");
        return string(abi.encodePacked("https://www.linkpicture.com/view.php?img=LPic63ece6a4d3c35808822209", tokenId));
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Halving(uint256 indexed time, uint256 remainingSupply, uint256 rewardAmount);
}