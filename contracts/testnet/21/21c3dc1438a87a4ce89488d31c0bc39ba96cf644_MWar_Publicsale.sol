// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "./ReentrancyGuard.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract MWar_Publicsale is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    uint256 public startTime;
    uint256 public saleDuration = 24 hours;
    //100000 * 10**6 * 10**9
    uint256 public rate;
    uint256 public cap = 500 * 10**9;
    uint256 public tokensSold;

    uint256 public maxSell = 2 ether;
    uint256 public minSell = 0.1 ether;

    uint256 public contributed;
    uint256 public contributorsCount;

    mapping(address => uint256) public balances;

    bool public isWhitelistEnabled = true;
    mapping(address => bool) public whitelist;

    event RateChanged(uint256 newRate);
    event StartChanged(uint256 newStartTime);
    event DurationChanged(uint256 newDuration);
    event WhitelistChanged(bool newEnabled);
    event CapChanged(uint256 newCap);

    /**
     * Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    constructor(uint256 _startTime, uint256 _rate, uint256 _cap) public {
        startTime = _startTime;
        rate = _rate;
        cap = _cap;
        whitelist[msg.sender] = true;
    }

    function batchAddWhitelisted(address[] calldata addresses) external onlyOwner {
        for (uint i = 0; i < addresses.length; i++) {
            whitelist[addresses[i]] = true;
        }
    }

    function isLive() public view returns (bool) {
        return block.timestamp > startTime && block.timestamp < startTime.add(saleDuration);
    }

    function getCap() public view returns(uint256) {
        return cap;
    }
    
    function getRate() public view returns(uint256) {
        return rate;
    }
    modifier ongoingSale(){
        require(isLive(), "Presale is not live");
        _;
    }

    function setRate(uint256 newRate) public onlyOwner {
        require(!isLive(), "Presale is live, rate change not allowed");
        rate = newRate;
        emit RateChanged(rate);
    }

    function setCap(uint256 newCap) public onlyOwner {
        require(!isLive(), "Presale is live, cap change not allowed");
        cap = newCap;
        emit CapChanged(cap);
    }
    function setStartTime(uint256 newStartTime) public onlyOwner {
        startTime = newStartTime;
        emit StartChanged(startTime);
    }

    function setSaleDuration(uint256 newDuration) public onlyOwner {
        saleDuration = newDuration;
        emit DurationChanged(saleDuration);
    }

    function setWhitelistEnabled(bool enabled) public onlyOwner {
        isWhitelistEnabled = enabled;
        emit WhitelistChanged(enabled);
    }

    function calculatePurchaseAmount(uint purchaseAmountWei) public view returns (uint256) {
        return purchaseAmountWei.mul(rate).div(1e18);
    }

    receive() external payable {
        buyTokens(msg.sender);
    }

    function buyTokens(address beneficiary) public payable ongoingSale nonReentrant returns (bool) {
        require(beneficiary != address(0), "Sale: to the zero address");
        require(!isWhitelistEnabled || whitelist[msg.sender], "Sale: not in whitelist");

        uint256 amount = calculatePurchaseAmount(msg.value);
        require(msg.value >= minSell, "Sale: amount is too small");
        require(amount != 0, "Sale: amount is 0");
        require(tokensSold.add(amount) <= cap, "Sale: cap reached");

        tokensSold = tokensSold.add(amount);
        balances[beneficiary] = balances[beneficiary].add(amount);

        require(balances[beneficiary] <= calculatePurchaseAmount(maxSell), "Sale: amount exceeds max");

        contributed = contributed.add(msg.value);
        contributorsCount = contributorsCount + 1;

        emit TokensPurchased(_msgSender(), beneficiary, msg.value, amount);
        return true;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    /**
     * Withdraw ether from the sale contract after sale is ended
     * param amount amount to withdraw
     */
    function withdrawBalance(uint256 amount) external onlyOwner {
        payable(owner()).transfer(amount);
    }

}