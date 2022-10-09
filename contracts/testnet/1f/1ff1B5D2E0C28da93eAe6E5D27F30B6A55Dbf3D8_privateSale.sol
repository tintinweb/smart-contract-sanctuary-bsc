/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

pragma solidity ^0.8.6;

//SPDX-License-Identifier: MIT Licensed

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

contract privateSale {
    IERC20 public GaddaFi = IERC20(0x73445033cEA2d4b74c1c6119E1514da7B6a28739);

    address payable public owner;

    uint256 public tokenPerEth = 10000 ether;
    uint256 public preSaleEndDate;
    uint256 public soldToken;
    uint256 public amountRaisedEth;
    uint256 public totalSupply = 150000 ether;
    uint256 public constant divider = 100;
    struct user {
        uint256 Eth_balance;
        uint256 token_balance;
    }

    mapping(address => user) public users;

    modifier onlyOwner() {
        require(msg.sender == owner, "PRESALE: Not an owner");
        _;
    }

    event BuyToken(address indexed _user, uint256 indexed _amount);

    constructor() {
        owner = payable(0x7863d1C6f74Ebb0d4C7c0bdBE40EEB963dE005A0);
        preSaleEndDate = block.timestamp + 2 days;
    }

    receive() external payable {}

    // to buy token during preSale time with BNB => for web3 use

    function buyTokenbnb() public payable {
        require(soldToken <= totalSupply, "All Sold");
        require(block.timestamp <= preSaleEndDate, "SALE: sale ended");
        uint256 numberOfTokens;
        numberOfTokens = EthToToken(msg.value);

        soldToken = soldToken + (numberOfTokens);
        amountRaisedEth = amountRaisedEth + (msg.value);
        users[msg.sender].Eth_balance =
            users[msg.sender].Eth_balance +
            (msg.value);
        users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens);
    }

    // to check number of token for given bnb
    function EthToToken(uint256 _amount) public view returns (uint256) {
        uint256 numberOfTokens = (_amount * tokenPerEth) / (1 ether);
        return numberOfTokens;
    }

    // to change preSale time duration
    function setPreSaleTime(uint256 _endTime) external onlyOwner {
        preSaleEndDate = _endTime;
    }

    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    // to draw funds for liquidity
    function transferFundsBNB(uint256 _value) external onlyOwner {
        owner.transfer(_value);
    }

    // to draw out tokens
    function transferStuckTokens(IERC20 token, uint256 _value)
        external
        onlyOwner
    {
        token.transfer(msg.sender, _value);
    }

    // to get contract ETH balance
    function contractBalanceETh() external view returns (uint256) {
        return address(this).balance;
    }
}