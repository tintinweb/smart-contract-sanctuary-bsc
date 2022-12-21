/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

//SPDX-License-Identifier: MIT Licensed
pragma solidity ^0.8.6;

interface IERC20 {
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

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ClaimableContract {
    IERC20 public TOKEN;

    address public owner;
    uint256 public amountPerUser = 24131274131274131274;


    mapping(address => uint256) public wallets;
    mapping(address => bool) public claimed;

    modifier onlyOwner() {
        require(msg.sender == owner, "Airdrop: Not an owner");
        _;
    }

    constructor(address _owner, address _TOKEN) {
        owner = _owner;
        TOKEN = IERC20(_TOKEN);
    }

    function Airdrop(address[] memory participants) public onlyOwner {
        for (uint256 i = 0; i < participants.length; i++) {
            address add = participants[i];
            wallets[add] = amountPerUser;
            TOKEN.transfer(add, amountPerUser);
        }
    }

    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    // change tokens
    function changeToken(address _token) external onlyOwner {
        TOKEN = IERC20(_token);
    }

    // change amountper user
    function changePerUsrAmount(uint256 _amount) external onlyOwner {
        amountPerUser = _amount;
    }

    // to draw out tokens
    function transferStuckTokens(IERC20 token, uint256 _value)
        external
        onlyOwner
    {
        token.transfer(msg.sender, _value);
    }

 
}