// SPDX-License-Identifier: Unlicensed
pragma solidity  ^0.8.16;

import "./Token.sol";





contract NetworkTest {
    string public name = "Network Miner";
    Token public testToken;
    address public owner;

    

    event AddUser(address indexed user,uint256 indexed id, uint256 amount,uint256 box);
    // event Upgrade(address indexed user,uint256 indexed id, uint256 amount,uint256 level);
    event Upgrade(uint256 id,address indexed user, uint256 indexed amount,uint256 level);
    event UpgradeUser(address indexed user,uint256 indexed id, uint256 amount,uint256 level);

    constructor(Token _testToken)  payable {
        testToken = _testToken;

        //assigning owner on deployment
        owner = msg.sender;
    }

       modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }


    function testUser() external {
        uint256 id = 0;
        address user = 0x30412AC7f7F4D4E6D3fdBBF0890461039B32fBC8;
        uint256 amount = 100;
        emit AddUser(user,id,amount,1);
        emit Upgrade(id,user,amount,1);
        emit UpgradeUser(user,id,amount,1);
    }


    
}