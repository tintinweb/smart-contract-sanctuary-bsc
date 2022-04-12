/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

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

interface IBEP20 
{
    function redeembalance(uint256 amount) external;
    function balances(address _addr) external view returns(uint256);
    function getstakeTime(address _addr) external view returns(uint256);
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



contract Road_Staking is Ownable {


    //////////////////////////////////////
    
    using SafeMath for uint256;
    IERC20 public Token;
    IERC20 public LpToken;
    address public NFTcontract;

    //////////////////////////////////////

    modifier onlyNFTContract {
        require(msg.sender == NFTcontract,"Only Call By The NFT Contract");
        _;
    }

    
    constructor(IERC20 _Token,IERC20 _LpToken)
    {
        Token = _Token;
        LpToken = _LpToken;   
    }

    /*                           STRUCTURES                                */

    struct users {

    uint256 Tamount;
    uint256 Deposit_time;
    uint256 withdrawnToken;
    uint256 redeemedBP;

    }

    struct usersLP { 
    uint256 Tamount;
    uint256 Deposit_time;
    uint256 withdrawnToken;
    uint256 redeemedBP;

    }

    /*                           MAPPING                                */

    mapping(address => users) public User;
    mapping(address => usersLP) public UserLP;
    mapping(address => uint256) public staketime;
    mapping (address => uint256) public _balances;

    uint256 mintlockTime = 5 minutes;

 
    uint256 public time = 30 seconds;
    uint256 public LPlocktime= 1 hours;
    uint256 public THBpercent=1000000000000000000;
    uint256 public Lppercent= 444444444444000000000;
   

    uint256 public maxBPToken=40000000000000000000000000;

    function setmaxBPTOKEN(uint256 _amount) external onlyOwner{
        maxBPToken = _amount;
    }
   
    uint256 public currentBP;

    
    function Stake( uint256 _amount) external {   
     
    require(User[msg.sender].Deposit_time == 0,"user already exists" );
    Token.transferFrom(msg.sender,address(this),_amount);
    User[msg.sender].Tamount += _amount;
    User[msg.sender].Deposit_time = block.timestamp;
    staketime[msg.sender]=block.timestamp + mintlockTime;
    User[msg.sender].redeemedBP=0;
    
    }

    
    function mintlocktimee(uint256 _time) public onlyOwner{
        mintlockTime = _time;
    }

  
    function BPcalculator(address addr) public view returns(uint256){

    require(currentBP<=maxBPToken,"Max Brawl Points Limit Exceeded!");
    uint256 remainingenergy;
    if(User[addr].Deposit_time!=0) {

         remainingenergy= (((block.timestamp.sub(User[addr].Deposit_time)).div(time)).mul(User[addr].Tamount));        
    }
         return remainingenergy;
    }


    function redeem() public {

    // require(BPcalculator(msg.sender) > 0 ,"no energy found!");
    uint point=BPcalculator(msg.sender);
    currentBP+=point;
    User[msg.sender].redeemedBP +=point ;
    _balances[msg.sender]+=point ;
    User[msg.sender].Deposit_time=block.timestamp;
    
    }
    
    function withdrawtoken (uint256 _amount) public {

    require(User[msg.sender].Tamount > 0 ,"No Staking Found!" );
    redeem();

    User[msg.sender].withdrawnToken = _amount;
    Token.transfer(msg.sender,_amount); 
    User[msg.sender].Tamount -= _amount;
    User[msg.sender].Tamount>0?User[msg.sender].Deposit_time = block.timestamp:User[msg.sender].Deposit_time=0;
    
    if(User[msg.sender].Tamount==0 && UserLP[msg.sender].Tamount==0  ){
    staketime[msg.sender]=0;
    }

    }
    
    function AddNFTContractAddress(address _add) external onlyOwner {
        
    NFTcontract=_add;

    }

    function balances(address _addr) external view returns(uint256) {

    return _balances[_addr];

    }

    function getstakeTime(address _addr) external view returns(uint256) {

    return staketime[_addr];

    }


    function redeembalance(uint256 amount) external onlyNFTContract {

    require( _balances[tx.origin]>0,"no energy found!");
    _balances[tx.origin]-=amount;
    currentBP-=amount;
        
    }



     ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //                                                      LP 
     ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    function StakeforLP( uint256 _amount) external {   
     
    require(UserLP[msg.sender].Deposit_time == 0,"user already exists" );
    LpToken.transferFrom(msg.sender,address(this),_amount);
    UserLP[msg.sender].Tamount += _amount;
    UserLP[msg.sender].Deposit_time = block.timestamp;
    staketime[msg.sender]=block.timestamp + mintlockTime;
    UserLP[msg.sender].redeemedBP=0;
    
    }



    function BPcalculatorforLP(address addr) public view returns(uint256) {
    require(currentBP<=maxBPToken,"Max Brawl Points Limit Exceeded!");
    uint256 remainingenergy;
    if(UserLP[addr].Deposit_time!=0) {
        
        uint256 reward = ((block.timestamp.sub(UserLP[addr].Deposit_time)).div(time)).mul((UserLP[addr].Tamount.mul(Lppercent)));
        remainingenergy= (reward.div(1 ether));
        
        }
    return remainingenergy;
    }
    
    function redeemforLp() public {

        // require(BPcalculatorforLP(msg.sender) > 0 ,"no energy found!");
    uint point=BPcalculatorforLP(msg.sender);
    currentBP+=point;
    UserLP[msg.sender].redeemedBP +=point ;
    _balances[msg.sender]+=point ;
    UserLP[msg.sender].Deposit_time=block.timestamp;

    }


    function withdrawLPtoken (uint256 _amount)  public  {
        
    require(UserLP[msg.sender].Tamount > 0 ,"No Staking Found!" );
    require(block.timestamp>=(UserLP[msg.sender].Deposit_time.add(LPlocktime)),"UnLock time not reached");
    redeemforLp();
    UserLP[msg.sender].withdrawnToken =_amount;
    LpToken.transfer(msg.sender,_amount); 
    UserLP[msg.sender].Tamount -= _amount;
    UserLP[msg.sender].Tamount>0?UserLP[msg.sender].Deposit_time = block.timestamp:UserLP[msg.sender].Deposit_time=0;
    
    if(UserLP[msg.sender].Tamount==0 && User[msg.sender].Tamount==0  ){
    staketime[msg.sender]=0;
    }
    
    }

    function setLPlocktime(uint256 _LPlocktime) external onlyOwner {
    
    LPlocktime=_LPlocktime;

    }

    uint256 BPPrice=275000000000000;
    uint256 Bppercent=500000000000000000;

    function BNBToBP(uint256 amount)  public view returns(uint256) {
    
    return amount/BPPrice;

    }

    function BuywithBNb() public payable {
        
    uint256 BPAmount = BNBToBP(msg.value);
    uint256 Bpamount = BPAmount.mul(Bppercent);
    require(maxBPToken>=currentBP+Bpamount,"Max Brawl Points Limit Exceed!, try with low value");
    _balances[msg.sender]+=Bpamount;
    currentBP+=Bpamount;

    }

    function setBNBtoBPPrice(uint256 value,uint256 percentage) external onlyOwner {

    BPPrice=value;
    Bppercent=percentage;

    }

}

//  TOKEN:      0x7e8ea2b90b916f3faba56162e89a11ddd160aa49
// LP-TOKEN:    0x632fBf93eC0913d30F489602eAEa83CC9Ac5148e