/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

/**
 *project dreams presale
 */

pragma solidity ^0.8.6;

//SPDX-License-Identifier: MIT Licensed

interface IBEP20 {
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

contract ProjectDreamsSale {
    IBEP20 public ProjectDreams =
        IBEP20(0x83e575d69397541Cf89f80758eeE63bdA8345Bf6);

    address payable public owner;

    uint256 public tokenPerBnb = 1_000_000_000_000 ether;
    uint256 public preSaleEndDate;
    uint256 public startDate;
    uint256 public soldToken;
    uint256 public amountRaisedBnb;
    uint256 public totalSupply = 600_000_000_000_000 ether;
    uint256 public constant divider = 100;
    struct user {
        uint256 Bnb_balance;
        uint256 token_balance;
    }

    mapping(address => user) public users;

    modifier onlyOwner() {
        require(msg.sender == owner, "PRESALE: Not an owner");
        _;
    }

    event BuyToken(address indexed _user, uint256 indexed _amount);

    constructor() {
        owner = payable(0xaD7f4232371416FdFD8f7E5D1C43E2B90CdB50cA);
        startDate = block.timestamp;
        preSaleEndDate = startDate + 60 days;
    }

    receive() external payable {}

    // to buy token during preSale time with ETH => for web3 use

    function buyToken() public payable {
        require(soldToken <= totalSupply, "All Sold");
        require(block.timestamp >= startDate, "SALE: not started yet");
        require(block.timestamp <= preSaleEndDate, "SALE: sale ended");

        uint256 numberOfTokens;
        numberOfTokens = BnbToToken(msg.value);
        ProjectDreams.transferFrom(owner, msg.sender, numberOfTokens);
        soldToken = soldToken + (numberOfTokens);
        amountRaisedBnb = amountRaisedBnb + (msg.value);
        users[msg.sender].Bnb_balance =
            users[msg.sender].Bnb_balance +
            (msg.value);
        users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens);
    }

    // to check number of token for given bnb
    function BnbToToken(uint256 _amount) public view returns (uint256) {
        uint256 numberOfTokens = (_amount * tokenPerBnb) / (1 ether);
        return numberOfTokens;
    }

    // to change preSale time duration
    function setPreSaleTime(uint256 _startDate, uint256 _endTime)
        external
        onlyOwner
    {
        startDate = _startDate;
        preSaleEndDate = _endTime;
    }

    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    // to draw funds for liquidity
    function transferFundsBnb(uint256 _value) external onlyOwner {
        owner.transfer(_value);
    }

    // to draw out tokens
    function transferStuckTokens(IBEP20 token, uint256 _value)
        external
        onlyOwner
    {
        token.transfer(msg.sender, _value);
    }

    // to get contract bnb balance
    function contractBalanceBnb() external view returns (uint256) {
        return address(this).balance;
    }

    // change tokens
    function changeToken(address _token) external onlyOwner {
        ProjectDreams = IBEP20(_token);
    }
}