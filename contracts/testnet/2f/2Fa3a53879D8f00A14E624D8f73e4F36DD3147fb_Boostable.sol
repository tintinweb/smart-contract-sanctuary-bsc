/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.9;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
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

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
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

struct Boost {
    uint256 duration;
    uint256 endTimestamp;
    uint256 percent;
}

contract Boostable is Context, Ownable {
    mapping (address => bool) private _boostAdmins;
    mapping (address => Boost) private _boosts;
    bool private _boostEnable = false;

    constructor() {
        _boostAdmins[msg.sender] = true;
    }

    function addBoostAdmin(address admin) external onlyOwner{
        _boostAdmins[admin] = true;
    }

    function removeBoostAdmin(address admin) external onlyOwner{
        delete _boostAdmins[admin];
    }

    modifier onlyBoostAdmins(){
        require(_boostAdmins[msg.sender] == true, "caller is not boostAdmin");
        _;
    }

    function enableBoost(bool boostEnable) external onlyOwner{
        _boostEnable = boostEnable;
    }

    function getBoostFor(address adr) external view returns(uint256) {
        if (_boosts[adr].endTimestamp < block.timestamp || !_boostEnable) {
            return 0;
        } 
        return _boosts[adr].percent; 
    }
    
    function addBoost(address adr, uint256 duration, uint256 percent) public onlyBoostAdmins{
        require(_boostEnable);
        uint256 endTimestamp = block.timestamp + duration;
        if (percent > 25) {
            percent = 25;
        }
        if (_boosts[adr].endTimestamp == 0) {
            Boost memory boost = Boost(duration, endTimestamp, percent);
            _boosts[adr] = boost;
        }
    }

    function addMultipleBoost(address[] memory adrs, uint256[] memory durations, uint256[] memory percents) external onlyBoostAdmins{
        require(_boostEnable);
        require(adrs.length == durations.length || durations.length == 1);
        require(adrs.length == percents.length || percents.length == 1); 
        for (uint i=0; i< adrs.length; i++) {
            uint256 duration = durations[0];
            if (durations.length > 1) {
                duration = durations[i];
            }
            uint256 percent = percents[0];
            if (percents.length > 1) {
                percent = percents[i];
            }
            addBoost(adrs[i], duration, percent);
        }
    }

    function removeBoostFor(address[] memory adrs) external onlyBoostAdmins{
         for (uint i=0; i<adrs.length; i++) {
            delete _boosts[adrs[i]];
        }  
    }
    
    function calculateGainedstarsWithBoost(uint256 nbMiners, address adr) internal returns(uint256) {
        uint256 starsAmount = 0;
        if (_boosts[adr].endTimestamp == 0 || !_boostEnable) {
            return starsAmount;
        } else if (_boosts[adr].endTimestamp > block.timestamp) {
            uint256 remainingBoostTime = _boosts[adr].endTimestamp - block.timestamp;
            uint256 consumedBoostTime = _boosts[adr].duration - remainingBoostTime;
            starsAmount += (consumedBoostTime * nbMiners) * (_boosts[adr].percent * 100) / 10000;
            _boosts[adr].duration = remainingBoostTime;
        } else {
            starsAmount += (_boosts[adr].duration * nbMiners) * (_boosts[adr].percent * 100) / 10000;
            delete _boosts[adr];  
        }
        return starsAmount;
    }
}

contract UAPYminer is Context, Ownable, Boostable {
    uint256 private constant stars_REQ_PER_BUNNY = 1_080_000; 
    uint256 private constant INITIAL_MARKET_stars = 108_000_000_000;
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 1000;
    bool private initialized = false;
    address payable private devWallet;
    address private _initialeBalanceOwner;
    mapping (address => uint256) private moon;
    mapping (address => uint256) private claimedstars;
    mapping (address => uint256) private lastHatch;
    mapping (address => address) private referrals;
    uint256 private marketstars;
    uint256 private maximumBalanceBuy = 30;
    uint256 private _neededBalanceToRemoveMaxBuy = 100_000 * 10 ** 18;
    uint256 private currentBalance = 0;

    error FeeTooLow();

    constructor(address initialeBalanceOwner) {
        devWallet = payable(msg.sender);
        _initialeBalanceOwner = initialeBalanceOwner;
    }
    
    function updateMaxBuy(uint256 _maximumBalanceBuy) public onlyOwner {
        maximumBalanceBuy = _maximumBalanceBuy;
    }

    function updateDevWallet(address payable _devWallet) public onlyOwner {
        devWallet = _devWallet;
    }

    function layMarketstars() public payable onlyOwner {
        require(marketstars == 0);
        initialized = true;
        marketstars = INITIAL_MARKET_stars;
    }

    function buymoon(address ref) external payable {
        require(initialized);
        require((msg.value < (currentBalance*maximumBalanceBuy)/100 || maximumBalanceBuy == 0) || (currentBalance == 0 && msg.sender == _initialeBalanceOwner));
        
        uint256 starsBought = calculateEggBuy(msg.value, address(this).balance - msg.value);

        uint256 eggDevFee = devFee(starsBought);
        if(eggDevFee == 0) revert FeeTooLow();

        starsBought -= eggDevFee;

        uint256 bunnyDevFee = devFee(msg.value);
        
        devWallet.transfer(bunnyDevFee);
        claimedstars[msg.sender] += starsBought;
        hatchstars(ref);
        currentBalance += msg.value - bunnyDevFee;
        if (currentBalance > _neededBalanceToRemoveMaxBuy && maximumBalanceBuy != 0) {
            maximumBalanceBuy = 0 ;
        }
    }
 
    function hatchstars(address ref) public {
        require(initialized);
        require(getMystars(msg.sender) > stars_REQ_PER_BUNNY);

        if (ref == msg.sender) {
            ref = address(0);
        }
        
        if (referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }

        uint256 gainedstars = calculateGainedstarsWithBoost(getMymoon(msg.sender), msg.sender);

        uint256 starsUsed = getMystars(msg.sender);
        starsUsed += gainedstars;

        uint256 mystarsRewards = getstarsSinceLastHatch(msg.sender);
        mystarsRewards += gainedstars;

        claimedstars[msg.sender] += mystarsRewards;

        uint256 newMiners = claimedstars[msg.sender] / stars_REQ_PER_BUNNY;
        claimedstars[msg.sender] -= (stars_REQ_PER_BUNNY * newMiners);

        moon[msg.sender] += newMiners;
        lastHatch[msg.sender] = block.timestamp;

        //send referral stars
        claimedstars[referrals[msg.sender]] += starsUsed / 8;
        
        //boost market to nerf miners hoarding
        marketstars += starsUsed / 5;
    }
    
    function sellstars() external {
        require(initialized);
        uint256 gainedstars = calculateGainedstarsWithBoost(getMymoon(msg.sender), msg.sender);
        uint256 hasstars = getMystars(msg.sender);
        hasstars += gainedstars;
        uint256 eggValue = calculatestarsell(hasstars);
        uint256 fee = devFee(eggValue);
        claimedstars[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        marketstars += hasstars;
        devWallet.transfer(fee);
        payable (msg.sender).transfer(eggValue - fee);
        currentBalance -= eggValue;
    }
    
    function eggRewards(address adr) external view returns(uint256) {
        uint256 hasstars = getMystars(adr);
        uint256 eggValue = calculatestarsell(hasstars);
        return eggValue;
    }
    
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return (PSN * bs) / (PSNH + (((PSN * rs) + (PSNH * rt)) / rt));
    }
    
    function calculatestarsell(uint256 stars) public view returns(uint256) {
        return calculateTrade(stars,marketstars,address(this).balance);
    }
    
    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketstars);
    }
    
    function devFee(uint256 amount) private view returns(uint256) {
        return amount * devFeeVal / 10000;
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getMymoon(address adr) public view returns(uint256) {
        return moon[adr];
    }
    
    function getMystars(address adr) public view returns(uint256) {
        return claimedstars[adr] + getstarsSinceLastHatch(adr);
    }
    
    function getstarsSinceLastHatch(address adr) public view returns(uint256) {
        return min(stars_REQ_PER_BUNNY, block.timestamp - lastHatch[adr]) * moon[adr];
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}