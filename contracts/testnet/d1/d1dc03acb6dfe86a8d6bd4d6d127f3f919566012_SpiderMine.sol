/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract ReentrancyGuard is Ownable{
    bool internal locked;

    modifier nonReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
    
        _;
        locked = false;
          
    }
}

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

contract SpiderMine is Context, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    uint256 private EGGS_TO_HATCH_1SPIDER = 864000;
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 4;
    uint256 private marketFeeVal = 2;
    uint256 private minInvest = 0.01 ether;
    bool private initialized = false;
    address payable private recAdd;
    address payable private mktAdd;
    mapping (address => uint256) private hatcherySpiders;
    mapping (address => uint256) private claimedEggs;
    mapping (address => uint256) private lastHatch;
    mapping (address => address) private referrals;
    mapping (address => bool) private spiderBonus;
    uint256 private marketEggs;
    
    constructor(address payable mktAddr) {
		require(!contractAddress(msg.sender) && !contractAddress(mktAddr));
        recAdd = payable(msg.sender);
        mktAdd = payable(mktAddr);
    }
    
    // all investors will can get 0.05 bnb worth of spiderEggs once!
    function spiderEggsGiveAway() internal {
        require(initialized,"contract not live.");
        require(!contractAddress(msg.sender),"address is not valid.");    
        require(hatcherySpiders[msg.sender] > 0, "user should be invested."); 
        if(spiderBonus[msg.sender] = false){
            hatcherySpiders[msg.sender] = SafeMath.add(SafeMath.div(calculateEggBuySimple(0.05 ether),EGGS_TO_HATCH_1SPIDER),hatcherySpiders[msg.sender]); //0.05 giveaway.
            spiderBonus[msg.sender] = true;
        }else return;
    }
    
    function hatchEggs(address ref) public {
        require(initialized,"contract not live.");
        require(!contractAddress(msg.sender),"address is not valid.");
        
        if(ref == msg.sender) {
            ref = address(0);
        }
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }
        
        uint256 eggsUsed = getMyEggs(msg.sender);
        uint256 newSpiderlings = SafeMath.div(eggsUsed,EGGS_TO_HATCH_1SPIDER);
        hatcherySpiders[msg.sender] = SafeMath.add(hatcherySpiders[msg.sender],newSpiderlings);
        claimedEggs[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        claimedEggs[referrals[msg.sender]] = SafeMath.add(claimedEggs[referrals[msg.sender]],SafeMath.div(eggsUsed,10));
        marketEggs=SafeMath.add(marketEggs,SafeMath.div(eggsUsed,20));
    }
    
    function sellSpiders() public nonReentrant{
        require(initialized,"contract not live.");
        require(!contractAddress(msg.sender),"address is not valid.");
        uint256 hasEggs = getMyEggs(msg.sender);
        uint256 eggValue = calculateEggSell(hasEggs);
        uint256 fee = devFee(eggValue);
        uint256 fee2 = marketFee(eggValue);
        claimedEggs[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        marketEggs = SafeMath.add(marketEggs,SafeMath.div(hasEggs,20));
        recAdd.transfer(fee);
        mktAdd.transfer(fee2);
        payable(msg.sender).transfer(SafeMath.sub(eggValue,SafeMath.add(fee,fee2)));
    }
    
    function eggRewards(address adr) public view returns(uint256) {
        uint256 hasEggs = getMyEggs(adr);
        uint256 eggValue = calculateEggSell(hasEggs);
        return eggValue;
    }
    
    function buyEggs(address ref) public payable nonReentrant{
        require(initialized,"contract not live.");
        require(!contractAddress(msg.sender),"address is not valid.");
        require(msg.value >= minInvest, "please input min invest amount.");
        uint256 eggsBought = calculateEggBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        eggsBought = SafeMath.sub(eggsBought,devFee(eggsBought));
        uint256 fee = devFee(msg.value);
        uint256 fee2 = marketFee(msg.value);
        recAdd.transfer(fee);
        mktAdd.transfer(fee2);
        claimedEggs[msg.sender] = SafeMath.add(claimedEggs[msg.sender],eggsBought);
        hatchEggs(ref);
        spiderEggsGiveAway(); //give miner bonus for first deposits only.
    }
    
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    
    function calculateEggSell(uint256 eggs) public view returns(uint256) {
        return calculateTrade(eggs,marketEggs,address(this).balance);
    }
    
    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketEggs);
    }
    
    function calculateEggBuySimple(uint256 eth) public view returns(uint256) {
        return calculateEggBuy(eth,address(this).balance);
    }
    
    function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,devFeeVal),100);
    }
    
    function marketFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,marketFeeVal),100);
    }
    
    function seedMarket(address ref) public payable onlyOwner {
        require(marketEggs == 0);
        initialized = true;
        marketEggs = 86400000000;
        buyEggs(ref);
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getMySpiders(address adr) public view returns(uint256) {
        return hatcherySpiders[adr];
    }
    
    function getMyEggs(address adr) public view returns(uint256) {
        return SafeMath.add(claimedEggs[adr],getEggsSinceLastHatch(adr));
    }
    
    function getEggsSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(EGGS_TO_HATCH_1SPIDER,SafeMath.sub(block.timestamp,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,hatcherySpiders[adr]);
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

	function contractAddress(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}