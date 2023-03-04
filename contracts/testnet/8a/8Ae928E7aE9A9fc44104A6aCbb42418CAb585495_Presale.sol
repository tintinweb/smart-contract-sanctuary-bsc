/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
}

contract Presale {
    address public owner;
    IERC20 public token;
    uint256 public tokenPrice;
    uint256 public totalTokens;
    uint256 public totalBNB;
    mapping(address => uint256) public contributions;
    bool public presaleClosed;

    event TokensPurchased(address indexed purchaser, uint256 value, uint256 amount);
    event PresaleClosed(bool presaleClosed);

    constructor(address _token, uint256 _tokenPrice, uint256 _totalTokens) {
        owner = msg.sender;
        token = IERC20(_token);
        tokenPrice = _tokenPrice;
        totalTokens = _totalTokens;
        presaleClosed = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function buyToken() public payable {
        require(!presaleClosed, "Presale is closed");
        require(msg.value > 0, "You need to send some BNB");
        require(contributions[msg.sender] + msg.value <= 3 ether, "You can't contribute more than 3 BNB");
        uint256 tokens = (msg.value * tokenPrice) / 1 ether;
        require(tokens <= totalTokens, "Not enough tokens left for sale");
        contributions[msg.sender] += msg.value;
        totalTokens -= tokens;
        totalBNB += msg.value;
        token.transfer(msg.sender, tokens);
        emit TokensPurchased(msg.sender, msg.value, tokens);
    }

    function closePresale() public onlyOwner {
        require(!presaleClosed, "Presale is already closed");
        presaleClosed = true;
        emit PresaleClosed(true);
    }

    function withdrawTokens(uint256 amount) public onlyOwner {
        require(presaleClosed, "Presale is still open");
        require(amount <= token.balanceOf(address(this)), "Not enough tokens in the contract");
        token.transfer(owner, amount);
    }

    function withdrawBNB(uint256 amount) public onlyOwner {
        require(presaleClosed, "Presale is still open");
        require(amount <= address(this).balance, "Not enough BNB in the contract");
        payable(owner).transfer(amount);
    }
}