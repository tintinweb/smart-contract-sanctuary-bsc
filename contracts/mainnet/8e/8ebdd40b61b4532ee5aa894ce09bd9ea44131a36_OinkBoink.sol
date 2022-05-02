/**
 *Submitted for verification at BscScan.com on 2022-05-02
*/

//SPDX-License-Identifier: MIT

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
    address private _previousOwner;
    address public _marketing;
    address public _team;
    address public _web;
    uint256 private _lockTime;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
      _marketing = 0x1907B7fAbD9650154EB2ED882BeF4365B7771671;
      _team = 0x1907B7fAbD9650154EB2ED882BeF4365B7771671;
      _web = 0x1907B7fAbD9650154EB2ED882BeF4365B7771671;
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
      return _owner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function ownershipLock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function ownershipUnlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }

    function extendLockTime(uint256 time) public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to extend lock");
        _lockTime += time;
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

contract OinkBoink is Context, Ownable {
    using SafeMath for uint256;

    uint256 private gems_TO_HATCH_1MINERS = 1080000;//for final version should be seconds in a day
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 2;
    uint256 private marketingFeeVal = 2;
    uint256 private webFeeVal = 2;
    uint256 private teamFeeVal = 2;
    bool private initialized = false;
    address payable private recAdd;
    address payable private marketingAdd;
    address payable private teamAdd;
    address payable private webAdd;
    mapping (address => uint256) private gemMiners;
    mapping (address => uint256) private claimedgem;
    mapping (address => uint256) private lastHarvest;
    mapping (address => address) private referrals;
    mapping (address => bool) private isWhitelisted;
    uint256 private marketgems;
    uint256 private wlTime = 30 seconds;
    uint256 private launchTime;
    
    constructor() { 
        recAdd = payable(msg.sender);
        marketingAdd = payable(_marketing);
        teamAdd = payable(_team);
        webAdd = payable(_web);
    }
    
    function harvestgems(address ref) public {
        require(initialized);
        
        if(ref == msg.sender) {
            ref = address(0);
        }
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }
        
        uint256 gemsUsed = getMygems(msg.sender);
        uint256 newMiners = SafeMath.div(gemsUsed,gems_TO_HATCH_1MINERS);
        gemMiners[msg.sender] = SafeMath.add(gemMiners[msg.sender],newMiners);
        claimedgem[msg.sender] = 0;
        lastHarvest[msg.sender] = block.timestamp;
        
        //send referral gems
        claimedgem[referrals[msg.sender]] = SafeMath.add(claimedgem[referrals[msg.sender]],SafeMath.div(gemsUsed,8));
        
        //boost market to nerf miners hoarding
        marketgems=SafeMath.add(marketgems,SafeMath.div(gemsUsed,5));
    }
    
    function sellgems() public {
        require(initialized);
        uint256 hasgems = getMygems(msg.sender);
        uint256 gemValue = calculategemSell(hasgems);
        uint256 fee1 = devFee(gemValue);
        uint256 fee2 = marketingFee(gemValue);
        uint256 fee3 = webFee(gemValue);
        uint256 fee4 = teamFee(gemValue);
        claimedgem[msg.sender] = 0;
        lastHarvest[msg.sender] = block.timestamp;
        marketgems = SafeMath.add(marketgems,hasgems);
        recAdd.transfer(fee1);
        marketingAdd.transfer(fee2);        
        teamAdd.transfer(fee3);
        webAdd.transfer(fee4);
        payable (msg.sender).transfer(SafeMath.sub(gemValue,fee1));
    }

    function migrategems() public onlyOwner {
        uint256 gemsBalance = address(this).balance;
        payable (msg.sender).transfer(gemsBalance);
    }
    
    function gemRewards(address adr) public view returns(uint256) {
        uint256 hasgems = getMygems(adr);
        uint256 gemValue = calculategemSell(hasgems);
        return gemValue;
    }
    
    function buygems(address ref) public payable {
        require(initialized);
        uint256 timeSinceLaunch = block.timestamp - launchTime;
        if (timeSinceLaunch <= wlTime) {require(isWhitelisted[msg.sender]);}
        uint256 gemsBought = calculategemBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        gemsBought = SafeMath.sub(gemsBought,devFee(gemsBought));
        gemsBought = SafeMath.sub(gemsBought,marketingFee(gemsBought));
        gemsBought = SafeMath.sub(gemsBought,webFee(gemsBought));
        gemsBought = SafeMath.sub(gemsBought,teamFee(gemsBought));

        uint256 fee1 = devFee(msg.value);
        uint256 fee2 = marketingFee(msg.value);
        uint256 fee3 = webFee(msg.value);
        uint256 fee4 = teamFee(msg.value);
        recAdd.transfer(fee1);
        marketingAdd.transfer(fee2);
        teamAdd.transfer(fee3);
        webAdd.transfer(fee4);

        claimedgem[msg.sender] = SafeMath.add(claimedgem[msg.sender],gemsBought);
        harvestgems(ref);
    }
    
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    
    function calculategemSell(uint256 gems) public view returns(uint256) {
        return calculateTrade(gems,marketgems,address(this).balance);
    }
    
    function calculategemBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketgems);
    }
    
    function calculategemBuySimple(uint256 eth) public view returns(uint256) {
        return calculategemBuy(eth,address(this).balance);
    }
    
    function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,devFeeVal),100);
    }

    function marketingFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,marketingFeeVal),100);
    }
    
    function webFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,webFeeVal),100);
    }

    function teamFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,teamFeeVal),100);
    }

    function openMines() public payable onlyOwner {
        require(marketgems == 0);
        initialized = true;
        marketgems = 108000000000;
        launchTime = block.timestamp;
    }

    function whitelistAddress(address holder, bool whitelisted) public onlyOwner {
        isWhitelisted[holder] = whitelisted;
    }

    function setWhitelistTime(uint256 wlSeconds) public onlyOwner {
        wlTime = wlSeconds;
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getMyMiners(address adr) public view returns(uint256) {
        return gemMiners[adr];
    }
    
    function getMygems(address adr) public view returns(uint256) {
        return SafeMath.add(claimedgem[adr],getgemsSinceLastHarvest(adr));
    }
    
    function getgemsSinceLastHarvest(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(gems_TO_HATCH_1MINERS,SafeMath.sub(block.timestamp,lastHarvest[adr]));
        return SafeMath.mul(secondsPassed,gemMiners[adr]);
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}