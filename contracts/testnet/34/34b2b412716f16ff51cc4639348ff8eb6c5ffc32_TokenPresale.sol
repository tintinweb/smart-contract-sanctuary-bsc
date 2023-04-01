/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address owner) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
}

contract TokenPresale {
    address private owner = 0x1f27b5b63b2dc9A48C8e8C45aC3c445f6ABf33e7;
    address private tokenAddress = 0x2976a43491aA86d04f80baF8E3210fC9fa6CE3EE;
    uint256 private rate = 60_000;
    uint256 private bbrate = 150_000;
    uint256 private totalBNB;
    bool private buybackStarted = false;
    bool private preSaleStarted = true;
    mapping(address => uint256) public purchases;
    mapping(address => bool) public referrals;

    uint256 private REFERRAL_TOKEN_PERCENTAGE = 10;
    uint256 private REFERRAL_BNB_PERCENTAGE = 10;
    uint256 private constant BNB_Buy_OPT1 = 0.05 ether;
    uint256 private constant BNB_Buy_OPT2 = 0.1 ether;
    uint256 private constant BNB_Buy_OPT3 = 0.5 ether;
    uint256 private constant BNB_Buy_OPT4 = 1 ether;
    uint256 private constant BNB_Buy_OPT5 = 2 ether;
    uint256 private constant BNB_Sell_OPT1 = 3000;
    uint256 private constant BNB_Sell_OPT2 = 6000;
    uint256 private constant BNB_Sell_OPT3 = 30000;
    uint256 private constant BNB_Sell_OPT4 = 60000;
    uint256 private constant BNB_Sell_OPT5 = 120000;
    event BoughtTokens(address buyer, uint256 amount);
    event Withdrawn(address owner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function buy(address payable referrer) public payable returns (bool) {
        require(preSaleStarted, "PreSale has not started yet");
        IERC20 token = IERC20(tokenAddress);
        uint256 _bnb05 = msg.value;
        require(_bnb05 >= BNB_Buy_OPT1 && _bnb05 <= BNB_Buy_OPT5, "Incorrect Value!!");
        uint256 _bnbTokens = _bnb05 * rate * 1_000_000_000_000_000_000;
        require(token.transfer(msg.sender, _bnbTokens), "Token transfer failed");

        // Ref
        uint256 rewardAmount = _bnbTokens * REFERRAL_TOKEN_PERCENTAGE / 100; 
        uint256 referralBNBAmount = _bnb05 * REFERRAL_BNB_PERCENTAGE / 100;
        require(token.transfer(referrer, rewardAmount));
        referrer.transfer(referralBNBAmount);

        return true;
    }

    function withdrawBNB(address payable _to) public onlyOwner {
        _to.transfer(address(this).balance);
    }
    function withdrawTokens(uint256 _tokenAmount) public onlyOwner {
        require(_tokenAmount > 0, "Transaction recovery");
        IERC20 token = IERC20(tokenAddress);
        uint256 _tokens = _tokenAmount;
        require(token.transfer(msg.sender, _tokens), "Token transfer failed");
    }

    function setRate(uint256 _rate) public onlyOwner {
        rate = _rate;
    }

    function setBBRate(uint256 _bbrate) public onlyOwner {
        bbrate = _bbrate;
    }

    function setReferralRewards(uint256 _referralTokenPercentage, uint256 _referralBNBPercentage) public onlyOwner {
        REFERRAL_TOKEN_PERCENTAGE = _referralTokenPercentage;
        REFERRAL_BNB_PERCENTAGE = _referralBNBPercentage;
    }

    // -------------- BuyBack --------------
    
    function startBuyback() public {
        require(!buybackStarted, "Buyback has already started");
        buybackStarted = true;
    }

    function endBuyback() public {
        require(buybackStarted, "Buyback has not started yet");
        buybackStarted = false;
    }
    
    function buyBack(uint256 tokenAmount) public returns (bool) {
        require(buybackStarted, "Buyback has not started yet");
        require(tokenAmount < BNB_Sell_OPT1 && tokenAmount > BNB_Sell_OPT5, "Incorrect Value!!");
        uint256 transTokenAmt = tokenAmount * 1_000_000_000_000_000_000;
        require(IERC20(tokenAddress).balanceOf(msg.sender) >= transTokenAmt, "Insufficient token balance");
        uint256 bnbAmount = tokenAmount / bbrate;
        require(address(this).balance >= bnbAmount, "Insufficient BNB balance in the contract");
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), transTokenAmt);
        payable(msg.sender).transfer(bnbAmount);
        return true;
    }

    function endPreSale() public {
        require(preSaleStarted, "PreSale has not started yet");
        preSaleStarted = false;
    }

    function startPreSale() public {
        require(!preSaleStarted, "PreSale has already started");
        preSaleStarted = true;
    }
    receive() external payable {
    totalBNB += msg.value;
    }

}