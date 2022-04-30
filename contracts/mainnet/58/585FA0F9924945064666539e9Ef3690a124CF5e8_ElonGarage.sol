// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "@openzeppelin/contracts/access/Ownable.sol";

contract ElonGarage is Ownable {

    uint256 public constant TESLA_TO_HIRE_1DRIVER = 100 *1 days /9;//960k teslas to hire 1 driver, 9%apr daily
    uint256 private constant PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private constant devFeeVal = 3;
    bool private _initialized;
    mapping (address => uint256) public teslaDrivers;
    mapping (address => uint256) private claimedTesla;
    mapping (address => uint256) private lastHireTime;
    mapping (address => address) private referrals;
    uint256 private marketTesla = 100000*TESLA_TO_HIRE_1DRIVER;

    mapping (address => bool) private hasParticipated;
    uint256 public uniqueUsers;

    modifier initialized {
      require(_initialized, "Contract not initialized");
      _;
   }
    
    function hireDriver(address ref) public initialized {
        
        if(ref != msg.sender && referrals[msg.sender] == address(0) && ref!= address(0)) {
            referrals[msg.sender] = ref;
        }
        
        uint256 teslaUsed = getMyTesla(msg.sender);
        uint256 myTeslaRewards = getTeslaSincelastHireTime(msg.sender);
        claimedTesla[msg.sender] += myTeslaRewards;

        uint256 newDrivers = claimedTesla[msg.sender]/TESLA_TO_HIRE_1DRIVER;
        
        claimedTesla[msg.sender] -=(TESLA_TO_HIRE_1DRIVER * newDrivers);
        teslaDrivers[msg.sender] += newDrivers;
        
        lastHireTime[msg.sender] = block.timestamp;
        
        //send referral tesla
        claimedTesla[referrals[msg.sender]] += teslaUsed/8;
        
        //boost market to nerf miners hoarding
        marketTesla += teslaUsed/5;

        if(!hasParticipated[msg.sender]) {
            hasParticipated[msg.sender] = true;
            uniqueUsers++;
        }
        if(!hasParticipated[ref] && ref!= address(0)) {
            hasParticipated[ref] = true;
            uniqueUsers++;
        }
    }
    
    function sellTesla() public initialized{
        sellTesla(getMyTesla(msg.sender));
    }

    function sellTesla(uint256 amount) public initialized{
        uint256 hasTesla = getMyTesla(msg.sender);
        uint256 teslaValue = calculateTeslaSell(amount);
        uint256 fee = devFee(teslaValue);
        claimedTesla[msg.sender] = hasTesla-amount;
        lastHireTime[msg.sender] = block.timestamp;
        marketTesla += amount;
        payable(owner()).transfer(fee);
        payable (msg.sender).transfer(teslaValue-fee);
        if(teslaDrivers[msg.sender] == 0) uniqueUsers--;
    }
    
    function buyTesla(address ref) external payable initialized {
        _buyTesla(ref,msg.value);
    }

    //to prevent sniping
    function seedMarket() public payable onlyOwner  {
        require(!_initialized, "Already initialized");
        _initialized = true;
        _buyTesla(0x0000000000000000000000000000000000000000,msg.value);
    }
    
    function _buyTesla(address ref, uint256 amount) private
    {
        uint256 teslaBought = calculateTeslaBuy(amount,address(this).balance-amount);
        teslaBought -= devFee(teslaBought);
        uint256 fee = devFee(amount);
        payable(owner()).transfer(fee);
        claimedTesla[msg.sender] += teslaBought;

        hireDriver(ref);
    }
    function teslaRewardsToBNB(address adr) external view returns(uint256) {
        uint256 hasTesla = getMyTesla(adr);
        uint256 teslaValue;
        try  this.calculateTeslaSell(hasTesla) returns (uint256 value) {teslaValue=value;} catch{}
        return teslaValue;
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return (PSN*bs)/(PSNH+(PSN*rs+PSNH*rt)/rt);
    }
    
    function calculateTeslaSell(uint256 tesla) public view returns(uint256) {
        return calculateTrade(tesla,marketTesla,address(this).balance);
    }
    
    function calculateTeslaBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketTesla);
    }
    
    function calculateTeslaBuySimple(uint256 eth) external view returns(uint256) {
        return calculateTeslaBuy(eth,address(this).balance);
    }
    
    function devFee(uint256 amount) private pure returns(uint256) {
        return amount*devFeeVal/100;
    }
    
    function getMyTesla(address adr) public view returns(uint256) {
        return claimedTesla[adr]+ getTeslaSincelastHireTime(adr);
    }
    
    function getTeslaSincelastHireTime(address adr) public view returns(uint256) {
        return getTeslaAccumulationValue(adr)*teslaDrivers[adr];
    }
    
    /*for the front end, it returns a value between 0 and TESLA_TO_HIRE_1DRIVER, when reached TESLA_TO_HIRE_1DRIVER 
    user will stop accumulating tesla and should compound or sell to get others
    */
    function getTeslaAccumulationValue(address adr) public view returns(uint256) {
        uint256 timePassed = block.timestamp - lastHireTime[adr];
        return TESLA_TO_HIRE_1DRIVER<timePassed? TESLA_TO_HIRE_1DRIVER: timePassed;
    }
    
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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