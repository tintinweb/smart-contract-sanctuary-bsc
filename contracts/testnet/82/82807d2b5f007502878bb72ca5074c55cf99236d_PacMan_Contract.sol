/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    uint256 private GHOSTS_TO_HATCH_1MINERS = 1080000;
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 25;
    bool private initialized = false;
    address payable private recAdd;
    mapping (address => uint256) private hatcheryMiners;
    mapping (address => uint256) private claimedGhosts;
    mapping (address => uint256) private lastHatch;
    mapping(address => Rewards) public rewards;
    uint256 private marketGhosts;
    struct Rewards {
        address ref;
        address upline1;
        address upline2;
        address upline3;
        address upline4;
    }
    event NewUpline(address referal, address indexed upline1, address indexed upline2, address indexed upline3, address uplline4);
    
    constructor() {
        recAdd = payable(msg.sender);
    }
    function buyGhosts(address ref) public payable {
        require(initialized);
        uint256 ghostsBought = calculateGhostBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        ghostsBought = SafeMath.sub(ghostsBought,devFee(ghostsBought));
        uint256 fee = devFee(msg.value);
        recAdd.transfer(fee);
        claimedGhosts[msg.sender] = SafeMath.add(claimedGhosts[msg.sender],ghostsBought);
        address _upline1 = rewards[ref].ref;
        address _upline2 = rewards[_upline1].upline1;
        address _upline3 = rewards[_upline2].upline1;
        address _upline4 = rewards[_upline3].upline1;
        rewards[msg.sender] = Rewards(msg.sender, ref, _upline2, _upline3, _upline4);
        emit NewUpline(msg.sender, ref, _upline2, _upline3, _upline4);
        hatchGhosts(ref);
    }
    function ghostRewards(address adr) public view returns(uint256) {
        uint256 hasGhosts = getMyGhosts(adr);
        uint256 ghostValue = calculateGhostSell(hasGhosts);
        return ghostValue;
    }
    function hatchGhosts(address ref) public {
        require(initialized);
        if(ref == msg.sender) {
            ref = address(0);
        }        
        uint256 ghostsUsed = getMyGhosts(msg.sender);
        uint256 newMiners = SafeMath.div(ghostsUsed,GHOSTS_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender] = SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedGhosts[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        address upline1reward = rewards[msg.sender].upline1;
        address upline2reward = rewards[msg.sender].upline2;
        address upline3reward = rewards[msg.sender].upline3;
        address upline4reward = rewards[msg.sender].upline4;
        if (upline1reward != address(0)) {
            claimedGhosts[upline1reward] = SafeMath.add(
                claimedGhosts[upline1reward],
                SafeMath.div((ghostsUsed * 6), 100)
            );
        }
        if (upline2reward != address(0)) {
            claimedGhosts[upline2reward] = SafeMath.add(
                claimedGhosts[upline2reward],
                SafeMath.div((ghostsUsed * 3), 100)
            );
        }
        if (upline3reward != address(0)) {
            claimedGhosts[upline3reward] = SafeMath.add(
                claimedGhosts[upline3reward],
                SafeMath.div((ghostsUsed * 2), 100)
            );
        }
        if (upline4reward != address(0)) {
            claimedGhosts[upline4reward] = SafeMath.add(
                claimedGhosts[upline4reward],
                SafeMath.div((ghostsUsed * 1), 100)
            );
        }
        marketGhosts=SafeMath.add(marketGhosts,SafeMath.div(ghostsUsed,5));
    }
    function sellGhosts() public {
        require(initialized);
        uint256 hasGhosts = getMyGhosts(msg.sender);
        uint256 ghostValue = calculateGhostSell(hasGhosts);
        uint256 fee = devFee(ghostValue);
        claimedGhosts[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        marketGhosts = SafeMath.add(marketGhosts,hasGhosts);
        recAdd.transfer(fee);
        payable (msg.sender).transfer(SafeMath.sub(ghostValue,fee));
    }
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateGhostSell(uint256 ghosts) public view returns(uint256) {
        return calculateTrade(ghosts,marketGhosts,address(this).balance);
    }
    function calculateGhostBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketGhosts);
    }
    function calculateGhostBuySimple(uint256 eth) public view returns(uint256) {
        return calculateGhostBuy(eth,address(this).balance);
    }
    function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,devFeeVal),1000);
    }
    function seedMarket() public payable onlyOwner {
        require(marketGhosts == 0);
        initialized = true;
        marketGhosts = 108000000000;
    }
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    function getMyMiners(address adr) public view returns(uint256) {
        return hatcheryMiners[adr];
    }
    function getMyGhosts(address adr) public view returns(uint256) {
        return SafeMath.add(claimedGhosts[adr],getGhostsSinceLastHatch(adr));
    }
    function getGhostsSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(GHOSTS_TO_HATCH_1MINERS,SafeMath.sub(block.timestamp,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,hatcheryMiners[adr]);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}