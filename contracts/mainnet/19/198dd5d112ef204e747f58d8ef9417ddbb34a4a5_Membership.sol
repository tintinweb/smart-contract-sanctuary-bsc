/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

pragma solidity ^0.8.17;

//SPDX-License-Identifier: MIT

interface ITOKEN {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Membership {
    // ADMIN
    address public admin;

    // BUSD
    ITOKEN public BUSD;

    // Define a mapping to store the membership information
    mapping(address => uint256) public memberships;

    // Define a mapping to store the membership plans and their prices
    mapping(uint256 => uint256) public plans;

    // Define a mapping of dynamic arrays to store the addresses of members in each plan
    mapping(uint256 => address[]) public membersByPlan;

    // Define a mapping to store the reward details of each plan with the token address
    mapping(uint256 => mapping(address => uint256)) public rewards;

    // Define a mapping to store the reward details of user for each plan with the token address
    mapping(address => mapping(uint256 => mapping(address => uint256))) public userRewards;

    // Define a mapping to see if a token is already added
    mapping(address => bool) public isTokenAdded;

    // Define a array to store the token address
    address[] public tokens;



    // Constructor to set the admin
    constructor(address usdt) {
        //admin
        admin = 0xB205dfa1af8a322FDB54C2b6B21685cbBda43c44;
        // 3 membership plans
        plans[1] = 300 ether;
        plans[2] = 500 ether;
        plans[3] = 1000 ether;
        //token
        BUSD = ITOKEN(usdt);
    }

    // Function to update membership plan
    function updateMembershipPlan(uint256 plan, uint256 price) public {
        require(msg.sender == admin, "Only admin can update membership plan");
        plans[plan] = price;
    }

    // Function to purchase or upgrade membership
    function buyOrUpgradeMembership(uint256 plan) public {
        require(plans[plan] > 0, "Invalid membership plan");

        uint256 currentPlan = memberships[msg.sender];
        uint256 cost;
        if (currentPlan == 0) {
            // New member
            cost = plans[plan];
            BUSD.transferFrom(msg.sender, admin, cost);
            memberships[msg.sender] = plan;
            membersByPlan[plan].push(msg.sender);
        } else {
            // Existing member
            require(plan > currentPlan, "Cannot downgrade membership plan");
            cost = plans[plan] - plans[currentPlan];
            BUSD.transferFrom(msg.sender, admin, cost);

            memberships[msg.sender] = plan;
            uint256 index = 0;
            for (uint256 i = 0; i < membersByPlan[currentPlan].length; i++) {
                if (membersByPlan[currentPlan][i] == msg.sender) {
                    index = i;
                    break;
                }
            }
            delete membersByPlan[currentPlan][index];
            membersByPlan[plan].push(msg.sender);
        }
    }

    // FUNCTION TO SEND REWARD TO MEMBERS 
    function sendRewardToMembers(uint256 plan, uint256 amount , ITOKEN token) public {
        if(!isTokenAdded[address(token)]){
            tokens.push(address(token));
            isTokenAdded[address(token)] = true;
        }
        require(msg.sender == admin, "Only admin can send reward to members");
        require(plans[plan] > 0, "Invalid membership plan");
        for (uint256 i = 0; i < membersByPlan[plan].length; i++) {
            token.transferFrom(admin,membersByPlan[plan][i], amount);
            rewards[plan][address(token)] += amount;
            userRewards[membersByPlan[plan][i]][plan][address(token)] += amount;
        }
    }

}