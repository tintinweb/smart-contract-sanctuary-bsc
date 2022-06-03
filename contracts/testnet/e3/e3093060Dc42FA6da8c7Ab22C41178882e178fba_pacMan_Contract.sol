/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./SafeMath.sol";
import "./Ownable.sol";

contract pacMan_Contract is Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private hatcheryMiners;
    mapping (address => uint256) private claimedGhosts;
    mapping (address => uint256) private lastHatch;
    mapping (address => Rewards) public rewards;
    mapping (address => uint256) public rewardsAmount;
    uint256 private constant GHOSTS_TO_HATCH_1MINERS = 100 *1 days /8;
    uint256 public marketGhosts = 100000*GHOSTS_TO_HATCH_1MINERS;
    uint256 private constant PSN = 10000;
    uint256 private constant PSNH = 5000;
    uint256 private constant PROJECTFEES = 25;
    address payable private projectAddress;
    bool private initialized = false;
    struct Rewards {
        address referrer;
        address upline1;
        address upline2;
        address upline3;
        address upline4;
    }
    event NewUpline(address referal, address indexed upline1, address indexed upline2, address indexed upline3, address upline4);
    
    constructor() {
        projectAddress = payable(msg.sender);
    }

    receive() external payable{}
    function initializeMarket() public onlyOwner {
        initialized = true;
    }
    function buyGhosts(address referrer) external payable {
        require(initialized, "Not initialized");
        require(referrer != msg.sender,"User can't refer themselves");
        uint256 ghostsBought = calculateBoughtGhosts(msg.value, SafeMath.sub(address(this).balance, msg.value));
        ghostsBought = SafeMath.sub(ghostsBought, projectFee(ghostsBought));
        uint256 fee = projectFee(msg.value);
        projectAddress.transfer(fee);
        claimedGhosts[msg.sender] = SafeMath.add(claimedGhosts[msg.sender], ghostsBought);
        address _upline1 = rewards[referrer].referrer;
        address _upline2 =  rewards[_upline1].upline1;
        address _upline3 =  rewards[_upline2].upline1; 
        address _upline4 =  rewards[_upline3].upline1;
        rewards[msg.sender] = Rewards(msg.sender, referrer, _upline2, _upline3, _upline4);
        emit NewUpline(msg.sender, referrer, _upline2, _upline3, _upline4);
        hatchGhosts();
    }
    function hatchGhosts() public {
        require(initialized, "Not initialized");
        uint256 ghostsUsed = getMyGhosts(msg.sender);
        uint256 newMiners = SafeMath.div(ghostsUsed, GHOSTS_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender] = SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedGhosts[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        address upline1reward = rewards[msg.sender].upline1;
        address upline2reward = rewards[msg.sender].upline2;
        address upline3reward = rewards[msg.sender].upline3;
        address upline4reward = rewards[msg.sender].upline4;
        if(upline1reward != address(0)) {
            claimedGhosts[upline1reward] = SafeMath.add(claimedGhosts[upline1reward],SafeMath.div(SafeMath.mul(ghostsUsed, 6), 100));
            rewardsAmount[upline1reward] = SafeMath.add(rewardsAmount[upline1reward],SafeMath.div(SafeMath.mul(ghostsUsed, 6), 100));
        }
        if(upline2reward != address(0)) {
            claimedGhosts[upline2reward] = SafeMath.add(claimedGhosts[upline2reward],SafeMath.div(SafeMath.mul(ghostsUsed, 3), 100));
            rewardsAmount[upline2reward] = SafeMath.add(rewardsAmount[upline2reward],SafeMath.div(SafeMath.mul(ghostsUsed, 3), 100));
        }
        if(upline3reward != address(0)) {
            claimedGhosts[upline3reward] = SafeMath.add(claimedGhosts[upline3reward],SafeMath.div(SafeMath.mul(ghostsUsed, 2), 100));
            rewardsAmount[upline3reward] = SafeMath.add(rewardsAmount[upline3reward],SafeMath.div(SafeMath.mul(ghostsUsed, 2), 100));
        }
        if(upline4reward != address(0)) {
            claimedGhosts[upline4reward] = SafeMath.add(claimedGhosts[upline4reward],SafeMath.div(SafeMath.mul(ghostsUsed, 1), 100));
            rewardsAmount[upline4reward] = SafeMath.add(rewardsAmount[upline4reward],SafeMath.div(SafeMath.mul(ghostsUsed, 1), 100));
        }
        marketGhosts = SafeMath.add(marketGhosts, SafeMath.div(ghostsUsed, 5));
    }
    function sellGhosts() external {
        require(initialized, "Not initialized");
        uint256 hasGhosts = getMyGhosts(msg.sender);
        uint256 ghostValue = calculateSoldGhosts(hasGhosts);
        uint256 fee = projectFee(ghostValue);
        claimedGhosts[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        marketGhosts = SafeMath.add(marketGhosts, hasGhosts);
        projectAddress.transfer(fee);
        payable (msg.sender).transfer(SafeMath.sub(ghostValue,fee));
    }
    function ghostRewards(address _address) external view returns(uint256) {
        uint256 hasGhosts = getMyGhosts(_address);
        uint256 ghostValue = calculateSoldGhosts(hasGhosts);
        return ghostValue;
    }
    function calculateTrade(uint256 rt, uint256 rs, uint256 bs) private pure returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN, bs), SafeMath.add(PSNH, SafeMath.div(SafeMath.add(SafeMath.mul(PSN, rs), SafeMath.mul(PSNH, rt)), rt)));
    }
    function calculateSoldGhosts(uint256 ghosts) public view returns(uint256) {
        return calculateTrade(ghosts, marketGhosts, address(this).balance);
    }
    function calculateBoughtGhosts(uint256 bnb, uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(bnb, contractBalance, marketGhosts);
    }
    function calculateGhostBuySimple(uint256 bnb) external view returns(uint256) {
        return calculateBoughtGhosts(bnb, address(this).balance);
    }
    function projectFee(uint256 amount) private pure returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount, PROJECTFEES), 1000);
    }
    function getBalance() external view returns(uint256) {
        return address(this).balance;
    }
    function getMyMiners(address _address) external view returns(uint256) {
        return hatcheryMiners[_address];
    }
    function getMyGhosts(address _address) public view returns(uint256) {
        return SafeMath.add(claimedGhosts[_address], getGhostsSinceLastHatch(_address));
    }
    function getGhostsSinceLastHatch(address _address) public view returns(uint256) {
        uint256 secondsPassed = min(GHOSTS_TO_HATCH_1MINERS, SafeMath.sub(block.timestamp, lastHatch[_address]));
        return SafeMath.mul(secondsPassed, hatcheryMiners[_address]);
    }   
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}