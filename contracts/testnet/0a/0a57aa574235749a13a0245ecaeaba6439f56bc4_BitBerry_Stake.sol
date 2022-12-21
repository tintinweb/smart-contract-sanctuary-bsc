/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
  
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IBEP20 {
    function redeembalance(uint256 amount) external;
    function balances(address _addr) external view returns(uint256);
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

contract Ownable {
    
    address public _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor()  {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract BitBerry_Stake is Ownable {

    ///////////////////////    VARIABLES    ////////////////////////
    // 500000000000000000000
    using SafeMath for uint256;
    IERC20 public Token;
    IERC20 public LpToken;
    address public NFTcontract;
    uint256 public time = 1 minutes;
    // uint256 public LPlocktime = 4 minutes;   // 10 days (14400)
    // uint256 public lpLockTimeSlot = 4 ;   // 14400 (10 days)

    
    uint256 public LPlocktime = 7 minutes;   // 10 days (14400)
    uint256 public lpLockTimeSlot = 7 ;   // 14400 (10 days)


    uint256 public bbrLockTime = 5 minutes;   // 10080 (7 days)
    uint256 public bbrLockTimeSlot = 5 ;   // 10080 (7 days)

    uint256 public minBBRStake = 500000000000000000000;
    uint256 public minLPStake = 30000000000000000000;

    // uint256 public BBR_Perecent = 4960317460317460000;
    // uint256 public Lppercent = 6944444444440000000;

    uint256 public BBR_Perecent = 10000000000000000000000;
    uint256 public Lppercent = 14285714285714290000000;
    
    uint256 public currentRP;

    ///////////////////////////////////////////////////////////////
    ///////////////////////    MAPPING    /////////////////////////

    mapping(address => uint256) public _balances;

    //////////////////////////////////////////////////////////////
    ///////////////////////    EVENTS    /////////////////////////

    event Staker(address indexed from, uint256 indexed StakingAmount);
    event Redeem_Points(address indexed from, uint256 indexed redeem_Points);
    event WithdrawTokens(address indexed from, uint256 indexed withdrawnTokens);
    event RedeemBalance(address indexed from, uint256 indexed _CurrentRP);
    event LP_Staker(address indexed from, uint256 indexed stakedAmount);
    event LP_Redeem_Points(address indexed from, uint256 indexed LP_Points);
    event WithdrawLP(address indexed from, uint256 indexed tokenWithDraw);
    event NFTAddress(address indexed from, address indexed nft_Contract);
    event LP_Lock_Time(address indexed from, uint256 indexed lockTime);
    event EpochTime(address indexed from, uint256 indexed Time);

    ///////////////////////////////////////////////////////////////
    ///////////////////////    MODIFIER    /////////////////////////

    modifier onlyNFTContract {
        require(msg.sender == NFTcontract,"Only Call By The NFT Contract");
        _;
    }

    // Owner has to set BBR's "Token" and "LP_token" address
    constructor(IERC20 _Token,IERC20 _LpToken)
    {
        Token = _Token;
        LpToken = _LpToken;   
    }
    ///////////////////////////////////////////////////////////
    /////////////////    STRUCTURES     //////////////////////

    struct users {
        uint256 BBR_Amount;
        uint256 depositeTime;
        uint256 unFreezeTime;
        uint256 withdrawnToken;
        bool isWithdrawl;
    }

    struct usersLP { 
        uint256 LP_Amount;
        uint256 Deposit_time;
        uint256 withdrawnToken;
        uint256 unFreezeTime;
        bool isWithdrawl;
    }

    ////////////////////////////////////////////////////

    mapping(address => uint256) public userRedeemedBBp;
    mapping(address => uint256) public userRedeemedLP;

    mapping(address => users[]) public userBBRInfo;
    mapping(address => usersLP[]) public userLPInfo;

    mapping(address => uint256) private userBBRStaked;
    mapping(address => uint256) private userLPStaked;


    //////////////////////////////////////////////////////////////////////////
    ////////////////////////        FUNCTIONS       //////////////////////////
    
    /*
    ==> User will stake the amount.
    =>  before staking, function will check if the staking address is already existing or not.
    =>  enterd amount will be transfered from users' address to this contract and also stored in the mapping(User)
    =>  User stakes token_amount, which then stores in a mapping(User) against user's address
    ==> When uer Stake the amount, redeemedRP will be set to zero.
    */

    function Stake( uint256 _amount) external {
        require(minBBRStake <= _amount, "less BBR amount than expected!");
        Token.transferFrom(msg.sender,address(this),_amount);
        uint256 unFreezeTime = block.timestamp + bbrLockTime;
        userBBRInfo[msg.sender].push(users(
            _amount,
            block.timestamp,
            unFreezeTime,
            0,
            false
        ));
        userBBRStaked[msg.sender] = userBBRStaked[msg.sender].add(_amount);
        emit Staker(msg.sender, _amount);
    }
    

    // User will enter the address to calculate its BBR Points according to 1 DAY.
    function rewCalculator(address addr) public view returns(uint256){

        uint256 remainingenergy;
        uint256 _timeSlot =0;
        uint256 reward = 0;
        uint256 amount_;
        uint256 total;

        for(uint256 i=0; i< userBBRInfo[addr].length; i++){
            _timeSlot = (block.timestamp.sub(userBBRInfo[addr][i].depositeTime)).div(time);
            amount_ = userBBRInfo[addr][i].BBR_Amount;
            if(_timeSlot >= bbrLockTimeSlot){
                _timeSlot = bbrLockTimeSlot;
            }
            reward += (_timeSlot).mul((amount_).mul(BBR_Perecent));
        }
        total = reward;
        reward = 0;
        // remainingenergy += (total.div(1 ether)).sub((userRedeemedBBp[addr]));
        remainingenergy += (total).sub((userRedeemedBBp[addr]));
        return (remainingenergy.div(1e18));
    }

    // USER call this function to store its points in _balances "Mapping"
    function redeem() public {

        uint256 point = rewCalculator(msg.sender);
        currentRP += point;
        userRedeemedBBp[msg.sender] = userRedeemedBBp[msg.sender].add(point);

        _balances[msg.sender] += point;
        emit Redeem_Points(msg.sender, point);
    }

    function getBBRInfo(address _user) public view returns(users[] memory){
        return userBBRInfo[_user];
    }
//////////////////////////////////////////// / /////////////   ///////////////////////////

    /*
    ==> user call "WITHDRAW" function to transfer amount to the user's address
    =>  User's amount will be set to zero
    =>  User's time will be set to zero
    ==> These tokens will be removed from user's address
    */


    function withdrawtoken () public {

        redeem();
        uint256 totalWithdrawn =0;
        for(uint256 i; i< userBBRInfo[msg.sender].length; i++){

            if(block.timestamp >= (userBBRInfo[msg.sender][i].unFreezeTime) && (userBBRInfo[msg.sender][i].isWithdrawl) == false){
                
                userBBRInfo[msg.sender][i].withdrawnToken = userBBRInfo[msg.sender][i].BBR_Amount;
                totalWithdrawn += userBBRInfo[msg.sender][i].BBR_Amount;
                userBBRStaked[msg.sender] = (userBBRStaked[msg.sender]).sub(userBBRInfo[msg.sender][i].BBR_Amount);
                userBBRInfo[msg.sender][i].isWithdrawl = true;
            }
        }
        Token.transfer(msg.sender,totalWithdrawn);

        emit WithdrawTokens(msg.sender, totalWithdrawn);
    }

    function totalBBRStaked(address _user) public view returns(uint256 ){
        return userBBRStaked[_user];
    }

    // Users can see thier balances by passing their addresses
    function balances(address _addr) external view returns(uint256) {
    return _balances[_addr];
    }


    /*
    ==> User pass the amount, and that amount will be minus from "balances" mapping and "currentRP" varaible
    ==> This function will check if the function caller has the NFT or not.
    */

    function redeembalance(uint256 amount) external onlyNFTContract {

    require( _balances[tx.origin]>0," No Energy Found! ");
    _balances[tx.origin]-=amount;
    currentRP-=amount;
    emit RedeemBalance(msg.sender, currentRP);
    }
    
    /*
    ==> Users will be checked if it is already exists or not 
    =>  LP_TOKENS will be transfered from users address to this contract
    =>  Enterd amount will be stored in User's mapping against user's address
    ==> redeemedRP will be set to zero.
    */

    function StakeforLP( uint256 _amount) external {
        LpToken.transferFrom(msg.sender,address(this),_amount);
        uint256 unFreez = block.timestamp.add(LPlocktime);
        userLPInfo[msg.sender].push(usersLP(
            _amount,
            block.timestamp,
            0,
            unFreez,
            false
        ));

        userLPStaked[msg.sender] = userLPStaked[msg.sender].add(_amount);
        
        emit LP_Staker(msg.sender, _amount);
    }

    // User will pass the address to calculate its RP_energy
    
    function RPcalculatorforLP(address user) public view returns(uint256) {
        uint256 remainingenergy;
        uint256 total;
        uint256 _timeSlot =0;
        uint256 reward = 0;

        for(uint256 i; i< userLPInfo[user].length; i++){
            _timeSlot = (block.timestamp.sub(userLPInfo[user][i].Deposit_time)).div(time);
            if(_timeSlot >= lpLockTimeSlot){
                _timeSlot = lpLockTimeSlot;
            }
            reward += (_timeSlot).mul((userLPInfo[user][i].LP_Amount).mul(Lppercent));
        }
        total = reward;
        reward = 0;
        remainingenergy += (total).sub((userRedeemedLP[user]));
        return (remainingenergy.div(1 ether));
    }

    // The user will get his BBR points after calling this function.
   
    function redeemforLp() public {

        uint256 point=RPcalculatorforLP(msg.sender);
        currentRP+=point;
        userRedeemedLP[msg.sender] = userRedeemedLP[msg.sender].add(point);
        _balances[msg.sender]+=point;

        emit LP_Redeem_Points(msg.sender, point);
    }

    /*
    ==> User's amount should be greater than zero
    =>  Withdrawl time should begreater than deposit_Time+LP_LockTime
    ==> After withdrawl Token time and amount will be set to zero
    */

    function withdrawLPtoken ()  public  {
        
        redeemforLp();
        uint256 totalWithdrawn;
        for(uint256 i; i< userLPInfo[msg.sender].length; i++){

            if(block.timestamp >= (userLPInfo[msg.sender][i].unFreezeTime) && (userLPInfo[msg.sender][i].isWithdrawl) == false){
                
                userLPInfo[msg.sender][i].withdrawnToken = userLPInfo[msg.sender][i].LP_Amount;
                totalWithdrawn += userLPInfo[msg.sender][i].LP_Amount;
                userLPStaked[msg.sender] = (userLPStaked[msg.sender]).sub(userLPInfo[msg.sender][i].LP_Amount);
                userLPInfo[msg.sender][i].isWithdrawl = true;
            }
        }
        LpToken.transfer(msg.sender,totalWithdrawn);

        emit WithdrawTokens(msg.sender, totalWithdrawn);
    }

    
    function totalLPStaked(address _user) public view returns(uint256 ){
        return userLPStaked[_user];
    }

    function getLPInfo(address _user) public view returns(usersLP[] memory){
        return userLPInfo[_user];
    }

    //////////////////////////////////////////////////////////////////////////
    ////////////////////////        ONLYOWNER       //////////////////////////  

    //  owner will set NFT contract Address

    function AddNFTContractAddress(address NFT_Address) external onlyOwner {
        NFTcontract=NFT_Address;
    }

    // Owner will set LPlockTime
  
    function setLPlocktime(uint256 _LPlocktime) external onlyOwner {
        LPlocktime=_LPlocktime;
        lpLockTimeSlot = _LPlocktime.div(60);
    }

    function setBBRLockTime(uint256 _locktime) external onlyOwner {         // input in seconds
        bbrLockTime = _locktime;
        bbrLockTimeSlot = _locktime.div(60);
    }

    function setBBRPercent(uint256 _bbrAmount) public onlyOwner{
        BBR_Perecent = _bbrAmount;
    }

    function setLPPercent(uint256 _lpAmount) public onlyOwner{
        Lppercent = _lpAmount;
    }

    //  Owner will set Time
    
    function setTime(uint256 _epoch) external onlyOwner {
    time = _epoch;
    }

}

//  TOKEN:      0x1F2B9a0813B334b2dfba9f742EBb90bD2fDB2a74
// LP-TOKEN:    0xea43eFa4Cd998370aC9f82DdF2fE3f8133985B5C