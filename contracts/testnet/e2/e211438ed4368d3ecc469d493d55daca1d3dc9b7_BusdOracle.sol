/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

// SPDX-License-Identifier: MIT

// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol


pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// File: Oracle/busdoracle.sol

/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

pragma solidity 0.8.7;



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

contract BusdOracle is Context, Ownable {
    AggregatorV3Interface internal priceFeed;

    uint256 public constant min = 20 ether;
    uint256 public constant max = 20000 ether;
    uint256 public roi = 30;
    uint256 public constant fee = 6;
    uint256 public constant withdraw_fee = 4;
    uint256 public constant ref_fee = 5;
    int256 public pricediff;
    int256 public lastprice;
    address public dev = 0x22269bABdce6185BF259B402E512Ff0eD29442Ae;
    IERC20 private BusdInterface;
    address public tokenAdress;
    bool public init = false;
    bool public alreadyInvested = false;

    constructor() {
        // priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE); //BNB usd pricefeed mainnet
        priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526); //BNB usd pricefeed testnet
        tokenAdress = 0x25C7c87B42ec086b01528eE72465F1e3c49B7B9D; //testnet
        //tokenAdress = 0x9388E2A62557E8814E68e00786064f149bA22B67; //Mainnet
        BusdInterface = IERC20(tokenAdress);
        lastprice = getLatestPrice();
        }

    struct refferal_system {
        address ref_address;
        uint256 reward;
    }

    struct refferal_withdraw {
        address ref_address;
        uint256 totalWithdraw;
    }

    struct user_investment_details {
        address user_address;
        uint256 invested;
    }

    struct weeklyWithdraw {
        address user_address;
        uint256 startTime;
        uint256 deadline;
    }

    struct claimDaily {
        address user_address;
        uint256 startTime;
        uint256 deadline;
    }

    struct userWithdrawal {
        address user_address;
        uint256 amount;
    }

    struct userTotalWithdraw {
        address user_address;
        uint256 amount;
    }
     struct userTotalRewards {
        address user_address;
        uint256 amount;
    } 
    struct userUnlock {
        address user_address;
        bool lock;
    } 

    mapping(address => refferal_system) public refferal;
    mapping(address => user_investment_details) public investments;
    mapping(address => weeklyWithdraw) public weekly;
    mapping(address => claimDaily) public claimTime;
    mapping(address => userWithdrawal) public approvedWithdrawal;
    mapping(address => userTotalWithdraw) public totalWithdraw;
    mapping(address => userTotalRewards) public totalRewards; //hhnew 
    mapping(address => refferal_withdraw) public refTotalWithdraw;
    mapping(address => userUnlock) public unlock;

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function getLatestPrice() public view returns (int) {
        (
            ,
            /*uint80 roundID*/ int price /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/,
            ,
            ,
        ) = priceFeed.latestRoundData();
        return price;
    }

    function ChangeROI() internal {
        int pricechange = getLatestPrice() - lastprice;
        if (pricechange < 0 && roi <= 50) {roi += 1;}
        else if (pricechange > 0 && roi >= 10 ) { roi -= 1;}
        lastprice = getLatestPrice();
    }

    // invest function 
    function deposit(address _ref, uint256 _amount) public  {
        require(init && !isContract(msg.sender));
        require(_amount >= min && _amount <= max, "Cannot Deposit");
       
        if(!checkAlready()){
            uint256 ref_fee_add = refFee(_amount);
        if(_ref != address(0) && _ref != msg.sender) {
            uint256 ref_last_balance = refferal[_ref].reward;
            uint256 totalRefFee = ref_fee_add + ref_last_balance;   
            refferal[_ref] = refferal_system(_ref,totalRefFee);
        }
        else {
            uint256 ref_last_balance = refferal[dev].reward;
            uint256 totalRefFee = ref_fee_add + ref_last_balance;  
            refferal[dev] = refferal_system(dev,totalRefFee);
            }
        }
        
        // investment details
        uint256 userLastInvestment = investments[msg.sender].invested;
        uint256 userCurrentInvestment = _amount;
        uint256 totalInvestment = userLastInvestment + userCurrentInvestment;
        investments[msg.sender] = user_investment_details(msg.sender,totalInvestment);

        // fees 
        uint256 total_fee = depositFee(_amount);
        uint256 total_contract = _amount - total_fee;
        BusdInterface.transferFrom(msg.sender,dev,total_fee);
        BusdInterface.transferFrom(msg.sender,address(this),total_contract);

        ChangeROI();
        UpdateTime();        
    }

    function UpdateTime() internal {
        if (unlock[msg.sender].lock == false){
        uint256 claimTimeStart = block.timestamp;
        uint256 claimTimeEnd = block.timestamp + 1 minutes;
        claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);

        // weekly withdraw 
        uint256 weeklyStart = block.timestamp;
        uint256 deadline_weekly = block.timestamp + 7 minutes;
        weekly[msg.sender] = weeklyWithdraw(msg.sender,weeklyStart,deadline_weekly);
        } 
        else if (unlock[msg.sender].lock == true){
        uint256 claimTimeStart = block.timestamp;
        uint256 claimTimeEnd = block.timestamp + 120 minutes;
        claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);

        // weekly withdraw 
        uint256 weeklyStart = block.timestamp;
        uint256 deadline_weekly = block.timestamp + 120 minutes;
        weekly[msg.sender] = weeklyWithdraw(msg.sender,weeklyStart,deadline_weekly);
        }
    }

    function userReward(address _userAddress) public view returns(uint256) {
        uint256 userInvestment = investments[_userAddress].invested;
        uint256 userDailyReturn;
        if (unlock[_userAddress].lock == true){
            userDailyReturn = DailyRoi(userInvestment) * 120;
        } 
        else {
            userDailyReturn = DailyRoi(userInvestment);
        } 
    
        // invested time
        uint256 claimInvestTime = claimTime[_userAddress].startTime;
        uint256 claimInvestEnd = claimTime[_userAddress].deadline;

        uint256 totalTime = claimInvestEnd - claimInvestTime;
        uint256 value = userDailyReturn / totalTime;
        uint256 nowTime = block.timestamp;

        if(claimInvestEnd >= nowTime) {  //|| unlock[msg.sender].lock == true
        uint256 earned = nowTime - claimInvestTime;
        uint256 totalEarned = earned * value;

        return totalEarned;
        }
        else {
            return userDailyReturn;
        }
    }

    function withdrawal() public {
    require(init, "Not Started Yet");   
    if (unlock[msg.sender].lock == false){
            require(weekly[msg.sender].deadline <= block.timestamp, "You cant withdraw");    
            uint256 weeklyStart = block.timestamp;
            uint256 deadline_weekly = block.timestamp + 7 minutes;
            weekly[msg.sender] = weeklyWithdraw(msg.sender,weeklyStart,deadline_weekly);
        } 
    
    uint256 aval_withdraw = approvedWithdrawal[msg.sender].amount;
    uint256 wFee = withdrawFee(aval_withdraw); // changed from aval_withdraw
    uint256 totalAmountToWithdraw = aval_withdraw - wFee; // changed from aval_withdraw to aval_withdraw2
    BusdInterface.transfer(msg.sender,totalAmountToWithdraw);
    BusdInterface.transfer(dev,wFee);
    approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender , 0 ); // changed from 0 to half of the amount stay in in his contract

    uint256 amount = totalWithdraw[msg.sender].amount;
    uint256 totalAmount = amount + aval_withdraw; // it will add one of his half to total withdraw
    totalWithdraw[msg.sender] = userTotalWithdraw(msg.sender,totalAmount);

    ChangeROI();
    }
    
    function compound() public {
    require(init, "Not Started Yet");   
    if (unlock[msg.sender].lock == false){
            require(weekly[msg.sender].deadline <= block.timestamp, "You can't compound");    
            uint256 weeklyStart = block.timestamp;
            uint256 deadline_weekly = block.timestamp + 7 minutes;
            weekly[msg.sender] = weeklyWithdraw(msg.sender,weeklyStart,deadline_weekly);
        } 
    
    uint256 aval_withdraw = approvedWithdrawal[msg.sender].amount;
    approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender , 0); // changed from 0 to half of the amount stay in in his contract
    
    // investment details
    uint256 userLastInvestment = investments[msg.sender].invested;
    uint256 userCurrentInvestment = aval_withdraw;
    uint256 totalInvestment = userLastInvestment + userCurrentInvestment;
    investments[msg.sender] = user_investment_details(msg.sender,totalInvestment);

    ChangeROI();
    }
    
    function claimDailyRewards() public {
        require(init, "Not Started Yet");
        
        uint256 rewards = userReward(msg.sender);
        if (unlock[msg.sender].lock == false){
            require(claimTime[msg.sender].deadline <= block.timestamp, "You cant claim");    
            uint256 claimTimeStart = block.timestamp;
            uint256 claimTimeEnd = block.timestamp + 1 minutes;
            claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);
        }
        else if (unlock[msg.sender].lock == true){
            uint256 claimTimeStart = block.timestamp;
            claimTime[msg.sender].startTime = claimTimeStart;
        }
        
        uint256 currentApproved = approvedWithdrawal[msg.sender].amount;
        uint256 value = rewards + currentApproved;

        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender,value);
        uint256 amount = totalRewards[msg.sender].amount; //hhnew
        uint256 totalRewardAmount = amount + rewards; //hhnew
        totalRewards[msg.sender].amount = totalRewardAmount;

        ChangeROI();
    }

    function unlockTime() external {
        require(unlock[msg.sender].lock == false, "Already unlocked");
        BusdInterface.transferFrom(msg.sender,address(this), 150 ether);
        
        uint256 rewards = userReward(msg.sender);
        uint256 currentApproved = approvedWithdrawal[msg.sender].amount;
        uint256 value = rewards + currentApproved;

        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender,value);
        uint256 amount = totalRewards[msg.sender].amount;
        uint256 totalRewardAmount = amount + rewards;
        totalRewards[msg.sender].amount = totalRewardAmount;

        uint256 claimTimeStart = block.timestamp;
        uint256 claimTimeEnd = block.timestamp + 120 minutes;
        claimTime[msg.sender] = claimDaily(msg.sender,claimTimeStart,claimTimeEnd);

        uint256 weeklyStart = block.timestamp;
        uint256 deadline_weekly = block.timestamp + 120 minutes;
        weekly[msg.sender] = weeklyWithdraw(msg.sender,weeklyStart,deadline_weekly);

        unlock[msg.sender].lock = true;
    }

    function Ref_Withdraw() external {
        require(init, "Not Started Yet");
        uint256 value = refferal[msg.sender].reward;

        BusdInterface.transfer(msg.sender,value);
        refferal[msg.sender] = refferal_system(msg.sender,0);

        uint256 lastWithdraw = refTotalWithdraw[msg.sender].totalWithdraw;
        uint256 totalValue = value + lastWithdraw;

        refTotalWithdraw[msg.sender] = refferal_withdraw(msg.sender,totalValue);
    }

    // initialized the market

    function signal_market(uint256 _amount) external onlyOwner {
        init = true;
        unlock[msg.sender].lock = true;
        deposit(msg.sender, _amount);
    }


    // other functions

    function DailyRoi(uint256 _amount) public view returns(uint256) {
            return _amount * roi / 1000;
    }

     function checkAlready() public view returns(bool) {
         address _address= msg.sender;
        if(investments[_address].user_address == _address){
            return true;
        }
        else{
            return false;
        }
    }

    function depositFee(uint256 _amount) public pure returns(uint256){
     return _amount * fee / 100;
    }

    function refFee(uint256 _amount) public pure returns(uint256) {
        return _amount * ref_fee / 100;
    }

    function withdrawFee(uint256 _amount) public pure returns(uint256) {
        return _amount * withdraw_fee / 100;
    }

    function getBalance() public view returns(uint256){
         return BusdInterface.balanceOf(address(this));
    }
    function checkLock(address _address) public view returns(bool){
         return unlock[_address].lock;
    }

}