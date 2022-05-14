/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
      return _owner;
    }    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }
    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

contract PacMan_Contract is Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private hatcheryMiners;
    mapping (address => uint256) private claimedGhosts;
    mapping (address => uint256) private lastHatch;
    mapping(address => Rewards) public rewards;
    uint256 public marketGhosts = 108000000000;
    uint256 private GHOSTS_TO_HATCH_1MINERS = 86400;
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private projectFees = 25;
    uint256 private dailyReturn = 125;
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
    function buyGhosts(address referrer) public payable {
        require(initialized);
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
    }
    function hatchGhosts() public {
        require(initialized);
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
            claimedGhosts[upline1reward] = SafeMath.add(claimedGhosts[upline1reward],SafeMath.div(ghostsUsed, 6));
        }
        if(upline2reward != address(0)) {
            claimedGhosts[upline2reward] = SafeMath.add(claimedGhosts[upline2reward],SafeMath.div(ghostsUsed, 3));
        }
        if(upline3reward != address(0)) {
            claimedGhosts[upline3reward] = SafeMath.add(claimedGhosts[upline3reward],SafeMath.div(ghostsUsed, 2));
        }
        if(upline4reward != address(0)) {
            claimedGhosts[upline4reward] = SafeMath.add(claimedGhosts[upline4reward],SafeMath.div(ghostsUsed, 1));
        }
        marketGhosts = SafeMath.add(marketGhosts, SafeMath.div(ghostsUsed, 5));
    }
    function sellGhosts() public {
        require(initialized);
        uint256 hasGhosts = getMyGhosts(msg.sender);
        uint256 ghostValue = calculateSoldGhosts(hasGhosts);
        uint256 fee = projectFee(ghostValue);
        uint256 soldGhost = ghostValue.mul(dailyReturn).div(10**3);
        uint256 transferGhost = SafeMath.sub(ghostValue, soldGhost);
        claimedGhosts[msg.sender] = soldGhost;
        lastHatch[msg.sender] = block.timestamp;
        marketGhosts = SafeMath.add(marketGhosts, hasGhosts);
        projectAddress.transfer(fee);
        payable (msg.sender).transfer(SafeMath.sub(transferGhost, fee));
    }
    function ghostRewards(address _address) public view returns(uint256) {
        uint256 hasGhosts = getMyGhosts(_address);
        uint256 ghostValue = calculateSoldGhosts(hasGhosts);
        return ghostValue;
    }
    function calculateTrade(uint256 rt, uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN, bs), SafeMath.add(PSNH, SafeMath.div(SafeMath.add(SafeMath.mul(PSN, rs), SafeMath.mul(PSNH, rt)), rt)));
    }
    function calculateSoldGhosts(uint256 ghosts) public view returns(uint256) {
        return calculateTrade(ghosts, marketGhosts, address(this).balance);
    }
    function calculateBoughtGhosts(uint256 bnb, uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(bnb, contractBalance, marketGhosts);
    }
    function calculateGhostBuySimple(uint256 bnb) public view returns(uint256) {
        return calculateBoughtGhosts(bnb, address(this).balance);
    }
    function projectFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount, projectFees), 1000);
    }
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    function getMyMiners(address _address) public view returns(uint256) {
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