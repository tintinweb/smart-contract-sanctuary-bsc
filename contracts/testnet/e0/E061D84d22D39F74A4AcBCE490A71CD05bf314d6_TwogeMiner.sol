/**
 *Submitted for verification at BscScan.com on 2023-01-02
*/

/**
  _______   _      _     _____     ______      _____  
/\_______)\/_/\  /\_\   ) ___ (   /_/\___\   /\_____\ 
\(___  __\/) ) )( ( (  / /\_/\ \  ) ) ___/  ( (_____/ 
  / / /   /_/ //\\ \_\/ /_/ (_\ \/_/ /  ___  \ \__\   
 ( ( (    \ \ /  \ / /\ \ )_/ / /\ \ \_/\__\ / /__/_  
  \ \ \    )_) /\ (_(  \ \/_\/ /  )_)  \/ _/( (_____\ 
  /_/_/    \_\/  \/_/   )_____(   \_\____/   \/_____/ 
                                                      
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface TwogeMinerConfigIface {
    //Apply ROI event boost to the amount specified
    function applyROIEventBoost(uint256 amount) external view returns (uint256); 
    //Is needed to update CA timestamps?
    function needUpdateEventBoostTimestamps() external view returns (bool); 
    //Update CA timestamps
    function updateEventsBoostTimestamps() external; 
}

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

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

abstract contract MinerBasic {

    event Hire(address indexed adr, uint256 greens, uint256 amount);
    event Sell(address indexed adr, uint256 greens, uint256 amount, uint256 penalty);
    event RehireMachines(address _investor, uint256 _newMachines, uint256 _hiredMachines, uint256 _nInvestors, uint256 _referralGreens, uint256 _marketGreens, uint256 _GreensUsed);

    bool internal renounce_unstuck = false; //Testing/security meassure, owner should renounce after checking everything is working fine
    uint32 internal rewardsPercentage = 15; //Rewards increase to apply (hire/sell)
    uint32 internal GREENS_TO_HATCH_1MACHINE = 576000; //576000/24*60*60 = 6.666 days to recover your investment (6.666*15 = 100%)
    uint16 internal PSN = 10000;
    uint16 internal PSNH = 5000;
    bool internal initialized = false;
    uint256 internal marketGreens; //This variable is responsible for inflation.
                                   //Number of greens on market (sold) rehire adds 20% of greens rehired

    address payable internal recAdd;
    uint8 internal devFeeVal = 1; //Dev fee
    uint8 internal marketingFeeVal = 4; //Tax used to cost the auto executions
    address payable public marketingAdd; //Wallet used for auto executions
    uint256 public maxBuy = (0.7 ether);

    uint256 public maxSellNum = 10; //Max sell TVL num
    uint256 public maxSellDiv = 1000; //Max sell TVL div //For example: 10 and 1000 -> 10/1000 = 1/100 = 1% of TVL max sell

    // This function is called by anyone who want to contribute to TVL
    function ContributeToTVL() public payable { }

    //Open/close miner
    bool public openPublic = false;
    function openToPublic(bool _openPublic) public virtual;

    function calculateMarketingTax(uint256 amount) internal view returns(uint256) { return SafeMath.div(SafeMath.mul(amount, marketingFeeVal), 100); }
    function calculateDevTax(uint256 amount) internal view returns(uint256) { return SafeMath.div(SafeMath.mul(amount, devFeeVal), 100); }
    function calculateFullTax(uint256 amount) internal view returns(uint256) { return SafeMath.div(SafeMath.mul(amount, devFeeVal + marketingFeeVal), 100); }

    constructor () {}
}

abstract contract Airdrop {
    
    address public airdropToken = address(0); //Will be used for performing airdrops
    bool public claimEnabled = false;

    event ClaimMachines(address _sender, uint256 _machinesToClaim, uint256 _mmBNB);

    //Enable/disable claim
    function enableClaim(bool _enableClaim) public virtual;

    //Used for people in order to claim their machines, the fake token is burned
    function claimMachines(address ref) public virtual;

    function setAirdropToken(address _airdropToken) public virtual;

    constructor() {}
}

abstract contract EmergencyWithdrawal {

    uint256 public emergencyWithdrawPenalty = 25;
    event EmergencyWithdraw(uint256 _investments, uint256 _withdrawals, uint256 _amountToWithdraw, uint256 _amountToWithdrawAfterTax, uint256 _amountToWithdrawTaxed);

    //Users can use emergencyWithdraw to withdraw the (100 - emergencyWithdrawPenalty)% of the investment they did not recover
    //Simple example, if you invested 5 BNB, recovered 1 BNB, and you use emergencyWithdraw with 25% tax you will recover 3 BNB
    //---> (5 - 1) * (100 - 25) / 100 = 3 BNB
    ////////////////////////////////////////////////////////////////////////////////////////////
    //WARNING!!!!! when we talk about BNB investment presale/airdrops are NOT taken into account
    //////////////////////////////////////////////////////////////////////////////////////////// 
    function emergencyWithdraw() public virtual;

    function setEmergencyWithdrawPenalty(uint256 _penalty) public virtual;

    constructor() {}
}

/**
 * @title Base class that provides time overrides, but only if being run in test mode.
 */
// abstract contract Testable {
//     // If the contract is being run on the test network, then `timerAddress` will be the 0x0 address.
//     // Note: this variable should be set on construction and never modified.
//     address public timerAddress;

//     /**
//      * @notice Constructs the Testable contract. Called by child contracts.
//      * @param _timerAddress Contract that stores the current time in a testing environment.
//      * Must be set to 0x0 for production environments that use live time.
//      */
//     constructor(address _timerAddress) {
//         timerAddress = _timerAddress;
//     }

//     /**
//      * @notice Reverts if not running in test mode.
//      */
//     modifier onlyIfTest {
//         require(timerAddress != address(0x0));
//         _;
//     }

//     /**
//      * @notice Sets the current time.
//      * @dev Will revert if not running in test mode.
//      * @param time timestamp to set current Testable time to.
//      */
//     // function setCurrentTime(uint256 time) external onlyIfTest {
//     //     Timer(timerAddress).setCurrentTime(time);
//     // }

//     /**
//      * @notice Gets the current time. Will return the last time set in `setCurrentTime` if running in test mode.
//      * Otherwise, it will return the block timestamp.
//      * @return uint for the current Testable timestamp.
//      */
//     function getCurrentTime() public view returns (uint256) {
//         if (timerAddress != address(0x0)) {
//             return Timer(timerAddress).getCurrentTime();
//         } else {
//             return block.timestamp;
//         }
//     }
// }

// /**
//  * @title Universal store of current contract time for testing environments.
//  */
// contract Timer is Auth {
//     using SafeMath for uint256;
//     uint256 private currentTime;

//     bool enabled = false;

//     constructor() Auth(msg.sender) { }

//     /**
//      * @notice Sets the current time.
//      * @dev Will revert if not running in test mode.
//      * @param time timestamp to set `currentTime` to.
//      */
//     function setCurrentTime(uint256 time) external authorized {
//         require(time >= currentTime, "Return to the future Doc!");
//         currentTime = time;
//     }

//     function enable(bool _enabled) external authorized {
//         require(enabled == false, 'Can not be disabled');
//         enabled = _enabled;
//     }

//     function increaseDays(uint256 _days) external authorized {
//         currentTime = getCurrentTime().add(uint256(1 days).mul(_days));
//     }

//     function increaseMinutes(uint256 _minutes) external authorized {
//         currentTime = getCurrentTime().add(uint256(1 minutes).mul(_minutes));
//     }

//     function increaseSeconds(uint256 _seconds) external authorized {
//         currentTime = getCurrentTime().add(uint256(1 seconds).mul(_seconds));
//     }

//     /**
//      * @notice Gets the current time. Will return the last time set in `setCurrentTime` if running in test mode.
//      * Otherwise, it will return the block timestamp.
//      * @return uint256 for the current Testable timestamp.
//      */
//     function getCurrentTime() public view returns (uint256) {
//         if(enabled){
//             return currentTime;
//         }
//         else{
//             return block.timestamp;
//         }
//     }
// }

contract InvestorsManager {

    //INVESTORS DATA
    uint64 private nInvestors = 0;
    uint64 private totalReferralsUses = 0;
    uint256 private totalReferralsGreens = 0;
    mapping (address => investor) private investors; //Investor data mapped by address
    mapping (uint64 => address) private investors_addresses; //Investors addresses mapped by index

    struct investor {
        address investorAddress;//Investor address
        uint256 investment;     //Total investor investment on miner (real BNB, presales/airdrops not taken into account)
        uint256 withdrawal;     //Total investor withdraw BNB from the miner
        uint256 hiredMachines;  //Total hired machines (miners)
        uint256 claimedGreens;  //Total greens claimed (produced by machines)
        uint256 lastHire;       //Last time you hired machines
        uint256 sellsTimestamp; //Last time you sold your greens
        uint256 nSells;         //Number of sells you did
        uint256 referralGreens; //Number of greens you got from people that used your referral address
        address referral;       //Referral address you used for joining the miner
        uint256 lastSellAmount; //Last sell amount
        uint256 customSellTaxes;//Custom tax set by admin
        uint256 referralUses;   //Number of addresses that used his referral address
    }

    function initializeInvestor(address adr) internal {
        if(investors[adr].investorAddress != adr){
            investors_addresses[nInvestors] = adr;
            investors[adr].investorAddress = adr;
            investors[adr].sellsTimestamp = block.timestamp;
            nInvestors++;
        }
    }

    function getNumberInvestors() public view returns(uint64) { return nInvestors; }

    function getTotalReferralsUses() public view returns(uint64) { return totalReferralsUses; }

    function getTotalReferralsGreens() public view returns(uint256) { return totalReferralsGreens; }

    function getInvestorData(uint64 investor_index) public view returns(investor memory) { return investors[investors_addresses[investor_index]]; }

    function getInvestorData(address addr) public view returns(investor memory) { return investors[addr]; }

    function getInvestorMachines(address addr) public view returns(uint256) { return investors[addr].hiredMachines; }

    function getReferralData(address addr) public view returns(investor memory) { return investors[investors[addr].referral]; }

    function getReferralUses(address addr) public view returns(uint256) { return investors[addr].referralUses; }

    function setInvestorAddress(address addr) internal { investors[addr].investorAddress = addr; }

    function addInvestorInvestment(address addr, uint256 investment) internal { investors[addr].investment += investment; }

    function addInvestorWithdrawal(address addr, uint256 withdrawal) internal { investors[addr].withdrawal += withdrawal; }

    function setInvestorHiredMachines(address addr, uint256 hiredMachines) internal { investors[addr].hiredMachines = hiredMachines; }

    function setInvestorClaimedGreens(address addr, uint256 claimedGreens) internal { investors[addr].claimedGreens = claimedGreens; }

    function setInvestorGreensByReferral(address addr, uint256 greens) internal { 
        if(addr != address(0)){
            totalReferralsGreens += greens; 
            totalReferralsGreens -= investors[addr].referralGreens; 
        }
        investors[addr].referralGreens = greens; 
    }

    function setInvestorLastHire(address addr, uint256 lastHire) internal { investors[addr].lastHire = lastHire; }

    function setInvestorSellsTimestamp(address addr, uint256 sellsTimestamp) internal { investors[addr].sellsTimestamp = sellsTimestamp; }

    function setInvestorNsells(address addr, uint256 nSells) internal { investors[addr].nSells = nSells; }

    function setInvestorReferral(address addr, address referral) internal { investors[addr].referral = referral; investors[referral].referralUses++; totalReferralsUses++; }

    function setInvestorLastSell(address addr, uint256 amount) internal { investors[addr].lastSellAmount = amount; }

    function setInvestorCustomSellTaxes(address addr, uint256 customTax) internal { investors[addr].customSellTaxes = customTax; }

    function increaseReferralUses(address addr) internal { investors[addr].referralUses++; }

    constructor(){}
}

contract TwogeMiner is Ownable, MinerBasic, Airdrop, InvestorsManager, EmergencyWithdrawal {
    using SafeMath for uint256;
    using SafeMath for uint64;
    using SafeMath for uint32;
    using SafeMath for uint8;

    //External config iface (Roi events)
    // TwogeMinerConfigIface reIface;

    //From milkfarmV1
    mapping (address => uint256[]) private sellsTimestamps;
    mapping (address => uint256) private customSellTaxes;

    constructor(address _marketingAdd) {
        recAdd = payable(msg.sender);
        marketingAdd = payable(_marketingAdd);
        // airdropToken = _airdropToken;
        // reIface = TwogeMinerConfigIface(address(_recIface));
    }


    //CONFIG////////////////
    function setAirdropToken(address _airdropToken) public override onlyOwner { airdropToken =_airdropToken; }
    function enableClaim(bool _enableClaim) public override onlyOwner { claimEnabled = _enableClaim; }
    function openToPublic(bool _openPublic) public override onlyOwner { openPublic = _openPublic; }
    // function setExternalConfigAddress(address _recIface) public onlyOwner { reIface = TwogeMinerConfigIface(address(_recIface)); }
    function setMarketingTax(uint8 _marketingFeeVal, address _marketingAdd) public onlyOwner {
        require(_marketingFeeVal <= 5);
        marketingFeeVal = _marketingFeeVal;
        marketingAdd = payable(_marketingAdd);
    }
    function setDevTax(uint8 _devFeeVal, address _devAdd) public onlyOwner {
        require(_devFeeVal <= 5);
        devFeeVal = _devFeeVal;
        recAdd = payable(_devAdd);
    }
    function setEmergencyWithdrawPenalty(uint256 _penalty) public override onlyOwner {
        require(_penalty < 100);
        emergencyWithdrawPenalty = _penalty;
    }
    function setMaxSellPc(uint256 _maxSellNum, uint256 _maxSellDiv) public onlyOwner {
        require(_maxSellDiv <= 1000 && _maxSellDiv >= 10, "Invalid values");
        require(_maxSellNum < _maxSellDiv && uint256(1000).mul(_maxSellNum) >= _maxSellDiv, "Min max sell is 0.1% of TLV");
        maxSellNum = _maxSellNum;
        maxSellDiv = _maxSellDiv;
    }
    function setRewardsPercentage(uint32 _percentage) public onlyOwner {
        require(_percentage >= 15, 'Percentage cannot be less than 15');
        rewardsPercentage = _percentage;
    }
    function setMaxBuy(uint256 _maxBuyTwoDecs) public onlyOwner {
        maxBuy = _maxBuyTwoDecs.mul(1 ether).div(100);
    }
    ////////////////////////



    //AIRDROPS//////////////
    function claimMachines(address ref) public override {
        require(initialized);
        require(claimEnabled, 'Claim still not available');

        uint256 airdropTokens = IBEP20(airdropToken).balanceOf(msg.sender);
        IBEP20(airdropToken).transferFrom(msg.sender, address(this), airdropTokens); //The token has to be approved first
        IBEP20(airdropToken).burn(airdropTokens); //Tokens burned

        //BNB is used to buy machines (miners)
        // uint256 machinesClaimed = calculateHireMachines(airdropTokens, address(this).balance);
        uint256 machinesClaimed = calculateHireMachinesNoEvent(airdropTokens, address(this).balance);

        setInvestorClaimedGreens(msg.sender, SafeMath.add(getInvestorData(msg.sender).claimedGreens, machinesClaimed));
        _rehireMachines(msg.sender, ref, true);

        emit ClaimMachines(msg.sender, machinesClaimed, airdropTokens);
    }
    ////////////////////////


    //Emergency withdraw////
    function emergencyWithdraw() public override {
        require(initialized);
        require(getInvestorData(msg.sender).withdrawal < getInvestorData(msg.sender).investment, 'You already recovered your investment');
        require(getInvestorData(msg.sender).hiredMachines > 1, 'You cant use this function');
        uint256 amountToWithdraw = getInvestorData(msg.sender).investment.sub(getInvestorData(msg.sender).withdrawal);
        uint256 amountToWithdrawAfterTax = amountToWithdraw.mul(uint256(100).sub(emergencyWithdrawPenalty)).div(100);
        require(amountToWithdrawAfterTax > 0, 'There is nothing to withdraw');
        uint256 amountToWithdrawTaxed = amountToWithdraw.sub(amountToWithdrawAfterTax);

        addInvestorWithdrawal(msg.sender, amountToWithdraw);
        setInvestorHiredMachines(msg.sender, 1); //Burn

        if(amountToWithdrawTaxed > 0){
            recAdd.transfer(amountToWithdrawTaxed);
        }

        payable (msg.sender).transfer(amountToWithdrawAfterTax);

        emit EmergencyWithdraw(getInvestorData(msg.sender).investment, getInvestorData(msg.sender).withdrawal, amountToWithdraw, amountToWithdrawAfterTax, amountToWithdrawTaxed);
    }
    ////////////////////////


    //BASIC/////////////////
    function seedMarket() public payable onlyOwner {
        require(marketGreens == 0);
        initialized = true;
        marketGreens = 108000000000;
    }

    function hireMachines(address ref) public payable {
        require(initialized,"Not initalized");
        require(openPublic, 'Miner still not opened');
        require(maxBuy == 0 || msg.value <= maxBuy,"Max buy exceeds");

        _hireMachines(ref, msg.sender, msg.value);
    }

    function rehireMachines() public {
        _rehireMachines(msg.sender, address(0), false);
    }

    function sellGreens() public {
        _sellGreens(msg.sender);
    }

    function _rehireMachines(address _sender, address ref, bool isClaim) private {
        require(initialized);

        if(ref == _sender) {
            ref = address(0);
        }
                
        if(getInvestorData(_sender).referral == address(0) && getInvestorData(_sender).referral != _sender && getInvestorData(_sender).referral != ref) {
            setInvestorReferral(_sender, ref);
        }
        
        uint256 greensUsed = getMyGreens(_sender);
        uint256 newMachines = SafeMath.div(greensUsed, GREENS_TO_HATCH_1MACHINE);

        if(newMachines > 0 && getInvestorData(_sender).hiredMachines == 0){            
            initializeInvestor(_sender);
        }

        setInvestorHiredMachines(_sender, SafeMath.add(getInvestorData(_sender).hiredMachines, newMachines));
        setInvestorClaimedGreens(_sender, 0);
        setInvestorLastHire(_sender, block.timestamp);
        
        //send referral greens
        setInvestorGreensByReferral(getReferralData(_sender).investorAddress, getReferralData(_sender).referralGreens.add(SafeMath.div(greensUsed, 8)));
        setInvestorClaimedGreens(getReferralData(_sender).investorAddress, SafeMath.add(getReferralData(_sender).claimedGreens, SafeMath.div(greensUsed, 8))); 

        //boost market to nerf miners hoarding
        if(isClaim == false){
            marketGreens = SafeMath.add(marketGreens, SafeMath.div(greensUsed, 5));
        }

        emit RehireMachines(_sender, newMachines, getInvestorData(_sender).hiredMachines, getNumberInvestors(), getReferralData(_sender).claimedGreens, marketGreens, greensUsed);
    }
    
    function _sellGreens(address _sender) private {
        require(initialized);

        uint256 greensLeft = 0;
        uint256 hasGreens = getMyGreens(_sender);
        uint256 greensValue = calculateGreenSell(hasGreens);
        (greensValue, greensLeft) = capToMaxSell(greensValue, hasGreens);
        uint256 sellTax = calculateBuySellTax(greensValue, _sender);
        uint256 penalty = getBuySellPenalty(_sender);

        setInvestorClaimedGreens(_sender, greensLeft);
        setInvestorLastHire(_sender, block.timestamp);
        marketGreens = SafeMath.add(marketGreens,hasGreens);
        payBuySellTax(sellTax);
        addInvestorWithdrawal(_sender, SafeMath.sub(greensValue, sellTax));
        setInvestorLastSell(_sender, SafeMath.sub(greensValue, sellTax));
        payable (_sender).transfer(SafeMath.sub(greensValue,sellTax));

        // Push the timestamp
        setInvestorSellsTimestamp(_sender, block.timestamp);
        setInvestorNsells(_sender, getInvestorData(_sender).nSells.add(1));
        //From milkfarmV1
        sellsTimestamps[msg.sender].push(block.timestamp);

        emit Sell(_sender, greensValue, SafeMath.sub(greensValue,sellTax), penalty);
    }

    function _hireMachines(address _ref, address _sender, uint256 _amount) private {        
        // uint256 greensBought = calculateHireMachines(_amount, SafeMath.sub(address(this).balance, _amount));
        uint256 greensBought = calculateHireMachinesNoEvent(_amount, SafeMath.sub(address(this).balance, _amount));
        
        // if(reIface.needUpdateEventBoostTimestamps()){
        //     reIface.updateEventsBoostTimestamps();
        // }

        uint256 greensBSFee = calculateBuySellTax(greensBought, _sender);
        greensBought = SafeMath.sub(greensBought, greensBSFee);
        uint256 fee = calculateBuySellTax(_amount, _sender);        
        payBuySellTax(fee);
        setInvestorClaimedGreens(_sender, SafeMath.add(getInvestorData(_sender).claimedGreens, greensBought));
        addInvestorInvestment(_sender, _amount);
        _rehireMachines(_sender, _ref, false);

        emit Hire(_sender, greensBought, _amount);
    }

    function capToMaxSell(uint256 greensValue, uint256 greens) public view returns(uint256, uint256){
        uint256 maxSell = address(this).balance.mul(maxSellNum).div(maxSellDiv);
        if(maxSell >= greensValue){
            return (greensValue, 0);
        }
        else{
            uint256 greensMaxSell = maxSell.mul(greens).div(greensValue);
            if(greens > greensMaxSell){
                return (maxSell, greens.sub(greensMaxSell));
            }else{
                return (maxSell, 0);
            }
        }     
    }

    function getRewardsPercentage() public view returns (uint32) { return rewardsPercentage; }

    function getMarketGreens() public view returns (uint256) {
        return marketGreens;
    }
    
    function greensRewards(address adr) public view returns(uint256) {
        uint256 hasGreens = getMyGreens(adr);
        uint256 greensValue = calculateGreenSell(hasGreens);
        return greensValue;
    }

    function greensRewardsIncludingTaxes(address adr) public view returns(uint256) {
        uint256 hasGreens = getMyGreens(adr);
        (uint256 greensValue,) = calculateGreenSellIncludingTaxes(hasGreens, adr);
        return greensValue;
    }

    function getBuySellPenalty(address adr) public view returns (uint256) {
        return getSellPenalty(adr);
        //return SafeMath.add(marketingFeeVal, devFeeVal);
    }

    function calculateBuySellTax(uint256 amount, address _sender) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount, getBuySellPenalty(_sender)), 100);
    }

    function payBuySellTax(uint256 amountTaxed) private {  
        uint256 fullTax = devFeeVal.add(marketingFeeVal);         
        payable(recAdd).transfer(amountTaxed.mul(devFeeVal).div(fullTax));        
        payable(marketingAdd).transfer(amountTaxed.mul(marketingFeeVal).div(fullTax));        
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        uint256 valueTrade = SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
        if(rewardsPercentage > 15) {
            return SafeMath.div(SafeMath.mul(valueTrade,rewardsPercentage), 15);
        }

        return valueTrade;
    }
    
    function calculateGreenSell(uint256 greens) public view returns(uint256) {
        if(greens > 0){
            return calculateTrade(greens, marketGreens, address(this).balance);
        }
        else{
            return 0;
        }
    }

    function calculateGreenSellIncludingTaxes(uint256 greens, address adr) public view returns(uint256, uint256) {
        if(greens == 0){
            return (0,0);
        }
        uint256 totalTrade = calculateTrade(greens, marketGreens, address(this).balance);
        uint256 penalty = getBuySellPenalty(adr);
        uint256 sellTax = calculateBuySellTax(totalTrade, adr);

        return (
            SafeMath.sub(totalTrade, sellTax),
            penalty
        );
    }
    
    // function calculateHireMachines(uint256 eth,uint256 contractBalance) public view returns(uint256) {
    //     return reIface.applyROIEventBoost(calculateHireMachinesNoEvent(eth, contractBalance));
    // }

    function calculateHireMachinesNoEvent(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth, contractBalance, marketGreens);
    }
    
    // function calculateHireMachinesSimple(uint256 eth) public view returns(uint256) {
    //     return calculateHireMachines(eth, address(this).balance);
    // }

    function calculateHireMachinesSimpleNoEvent(uint256 eth) public view returns(uint256) {
        return calculateHireMachinesNoEvent(eth, address(this).balance);
    }
    
    function isInitialized() public view returns (bool) {
        return initialized;
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getMyGreens(address adr) public view returns(uint256) {
        return SafeMath.add(getInvestorData(adr).claimedGreens, getGreensSinceLastHire(adr));
    }
    
    function getGreensSinceLastHire(address adr) public view returns(uint256) {        
        uint256 secondsPassed=min(GREENS_TO_HATCH_1MACHINE, SafeMath.sub(block.timestamp, getInvestorData(adr).lastHire));
        return SafeMath.mul(secondsPassed, getInvestorData(adr).hiredMachines);
    }

    function getSellPenalty(address addr) public view returns (uint256) {

        // If there is custom sell tax for this address, then return it
        if(customSellTaxes[addr] > 0) {
            return customSellTaxes[addr];
        }

        uint256 sellsInRow = getSellsInRow(addr);
        uint256 numberOfSells = sellsTimestamps[addr].length;
        uint256 _sellTax = marketingFeeVal;

        if(numberOfSells > 0) {
            uint256 lastSell = sellsTimestamps[addr][numberOfSells - 1];

            if(sellsInRow == 0) {
                if((block.timestamp - 30 days) > lastSell) { // 1% sell tax for everyone who hold / rehire during 30+ days
                    _sellTax = 0;
                } else if((lastSell + 4 days) <= block.timestamp) { // 5% sell tax for everyone who sell after 4 days of last sell
                    _sellTax = marketingFeeVal;
                } else if((lastSell + 3 days) <= block.timestamp) { // 8% sell tax for everyone who sell after 3 days of last sell
                    _sellTax = 7;
                } else { // otherwise 10% sell tax
                    _sellTax = 9;
                }
            } else if(sellsInRow == 1) {  // 20% sell tax for everyone who sell 2 days in a row
                _sellTax = 19;
            } else if(sellsInRow >= 2) {  // 40% sell tax for everyone who sell 3 or more days in a row
                _sellTax = 39;
            }
        }

        return SafeMath.add(_sellTax, devFeeVal);
    }

    function setCustomSellTaxForAddress(address adr, uint256 percentage) public onlyOwner {
        customSellTaxes[adr] = percentage;
    }

    function getCustomSellTaxForAddress(address adr) public view returns (uint256) {
        return customSellTaxes[adr];
    }

    function removeCustomSellTaxForAddress(address adr) public onlyOwner {
        delete customSellTaxes[adr];
    }

    function getSellsInRow(address addr) public view returns(uint256) {
        uint256 sellsInRow = 0;
        uint256 numberOfSells = sellsTimestamps[addr].length;
        if(numberOfSells == 1) {
            if(sellsTimestamps[addr][0] >= (block.timestamp - 1 days)) {
                return 1;
            }
        } else if(numberOfSells > 1) {
            uint256 lastSell = sellsTimestamps[addr][numberOfSells - 1];

            if((lastSell + 1 days) <= block.timestamp) {
                return 0;
            } else {

                for(uint256 i = numberOfSells - 1; i > 0; i--) {
                    if(isSellInRow(sellsTimestamps[addr][i-1], sellsTimestamps[addr][i])) {
                        sellsInRow++;
                    } else {
                        if(i == (numberOfSells - 1))
                            sellsInRow = 0;

                        break;
                    }
                }

                if((lastSell + 1 days) > block.timestamp) {
                    sellsInRow++;
                }
            }
        }

        return sellsInRow;
    }

    function isSellInRow(uint256 previousDay, uint256 currentDay) private pure returns(bool) {
        return currentDay <= (previousDay + 1 days);
    }
    /////////////////

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? b : a;
    }

    receive() external payable {}
    ////////////////////////
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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