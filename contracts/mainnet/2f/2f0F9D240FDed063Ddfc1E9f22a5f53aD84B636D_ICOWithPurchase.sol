/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

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

abstract contract owned {
    uint256[] public level_commision;

    struct User {
        uint256 id;
        address myaddress;
        address sponsor;
        uint40 directs;
        uint40 team;
        uint256 total_commision;
        uint256 direct_commision;
        uint256 deposit_amount;
        uint256 claimed_income;
        uint256 cashback;        
        uint40 deposit_time;        
        uint40 upto;
    }    

    address payable owner; 
    
    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Nothing For You!"
        );
        _;
    }

    constructor()  {
        owner = payable(msg.sender); 
        level_commision.push(1000); //1st generation 
        level_commision.push(350); //2nd generation 
        level_commision.push(100); //3rd generation  
        level_commision.push(100); //4th generation 
        level_commision.push(50); //5th generation 
        level_commision.push(50); //6th generation 
        level_commision.push(50); //7th generation 
        level_commision.push(50); //8th generation 
        level_commision.push(25); //9th generation 
        level_commision.push(25); //10th generation
    }    
   
}

contract ICOWithPurchase is owned {

    event Buy(uint256 amount, address sponsor, address useraddress);

    IERC20 public stakingToken;
    uint40 public time_period = 41472000;
    uint40 public token_per_bnb = 208300;
    uint256 public min_tokens = 20870;
    uint256 public distribute_percent = 30;
    uint256 public deduction_before_time = 50;
    uint256 public reward_percent = 16;
    uint256 private plan_diveder = 100;
    uint40 public event_start_time;
    uint40 public event_end_time;
    bool public isEventOn;
    uint256 public event_income;
    bool public isEventTokenDistrubute;
    uint256 public noOfTokenEventDistribute;
    
    address[] public event_complete;
    mapping(address => User) public users;
    uint256 public total_users = 1; 

    struct eventIncome {
        uint256 income;        
        uint40 added_time;        
    }

    mapping(address => eventIncome) public eventIncomes;
    mapping(address => uint256) public userEventIncome;

    constructor(IERC20 _stakingtoken) {      
        stakingToken = _stakingtoken;
        users[msg.sender].id = total_users; 
        users[msg.sender].myaddress = msg.sender; 
        users[msg.sender].deposit_time = uint40(block.timestamp); 
        isEventOn = false; 
    }    
    
    function buy(address sponsoradr) public payable returns(bool) {
        //msg.value = amnt;
        require(msg.value>0,"Amount Should be greater then 0");  
        payable(owner).transfer(msg.value);
        stake(sponsoradr, ((token_per_bnb * msg.value)/(10**18)));
        emit Buy(msg.value, sponsoradr, msg.sender);
        return true;
    }

    function stake(address _upline, uint256 _tokens) internal returns (bool){      
        require(_upline != msg.sender, "Address : Invalid address!");        
        require(_upline != address(0), "Address : Invalid address!");        
        require(_tokens >= min_tokens, "Token : Invalid token amount!");        
        require(users[_upline].deposit_time  > 0 , "Error :Given Address Not active!");      
        require(users[msg.sender].deposit_time  == 0 , "Error :You can stak once from one account!");      
        
        _stake(_upline, _tokens); 
        return true;
    }

    address private upline;
    function _stake(address _upline, uint256 _tokens) internal {        
        
        uint256 cashback = (_tokens * (10 ** 18)) * distribute_percent / 100;
        stakingToken.transfer(msg.sender, cashback);

        total_users++;

        users[msg.sender].id = total_users;
        users[msg.sender].myaddress = msg.sender;
        users[msg.sender].sponsor = _upline;
        
        users[msg.sender].cashback = cashback;
        users[msg.sender].upto = uint40(block.timestamp) + time_period;
        users[msg.sender].deposit_amount = (_tokens * (10 ** 18))- cashback;
        
        users[msg.sender].deposit_time = uint40(block.timestamp);            
        
        users[_upline].directs++;

        upline =  msg.sender;
        
        for (uint i = 0; i < 10; i++) {
            upline = users[upline].sponsor;
            if(upline != address(0)){
                if(users[upline].directs>i){
                    if(users[upline].deposit_time>0){
                       uint256 tcom = (users[msg.sender].deposit_amount * level_commision[i]/100)/plan_diveder;
                        users[upline].total_commision +=  tcom;                
                        if(i == 0){
                            users[upline].direct_commision += tcom;                   
                        
                            if(isEventOn == true && (event_start_time <= block.timestamp && event_end_time >= block.timestamp)){
                                
                                if(eventIncomes[upline].added_time <= event_start_time){
                                    eventIncomes[upline].added_time = uint40(block.timestamp);
                                    eventIncomes[upline].income =  tcom;
                                }else{
                                    eventIncomes[upline].income += tcom;
                                }
                                if(eventIncomes[upline].income >= event_income){
                                    event_complete.push(upline);
                                    if(isEventTokenDistrubute == true){
                                        //stakingToken.transfer(upline, noOfTokenEventDistribute);
                                        userEventIncome[upline] += noOfTokenEventDistribute;
                                        eventIncomes[upline].income = 0;
                                    }
                                }
                            }
                        }
                    }
                }
                users[upline].team++;
            }            
        }
    }
     
    
    function unstake() public returns(bool){
        uint256 addition = 0;
        uint256 deduction = 0;
        if(users[msg.sender].upto <= block.timestamp){
           addition = (users[msg.sender].deposit_amount * reward_percent / 100) ;
        }
        if(users[msg.sender].upto <= block.timestamp){
           deduction = (users[msg.sender].deposit_amount * deduction_before_time / 100) ;
        }

        stakingToken.transfer(msg.sender, (users[msg.sender].deposit_amount+addition-deduction));
        users[msg.sender].deposit_amount = 0;
        users[msg.sender].deposit_time = 0;
        return true;
    }

    function claimCommision(uint256 _claim_amount) public returns(bool){
        require (users[msg.sender].total_commision >= _claim_amount, "Insufficient Balance.");
        stakingToken.transfer(msg.sender, _claim_amount);
        users[msg.sender].total_commision -= _claim_amount;
        users[msg.sender].claimed_income += _claim_amount;
        return true;
    }

    function claimEvent(uint256 _claim_amount) public returns(bool){
        require (userEventIncome[msg.sender] >= _claim_amount, "Insufficient Balance.");
        stakingToken.transfer(msg.sender, _claim_amount);
        userEventIncome[msg.sender] -= _claim_amount;
        users[msg.sender].claimed_income += _claim_amount;
        return true;
    }
    
    function setTokenPerBnb(uint40 tknn) public onlyOwner returns (bool){
        token_per_bnb = tknn;
        return true;
    }
    function setdeduction_before_time(uint256 _percentage) public onlyOwner returns (bool){
        deduction_before_time = _percentage;
        return true;
    }
    function setMinPurchase(uint256 _minPurchase) public onlyOwner returns (bool){
        min_tokens = _minPurchase;
        return true;
    }
    function setcashback_percent(uint256 _percentage) public onlyOwner returns (bool){
        distribute_percent = _percentage;
        return true;
    }
    
    function withdraw(IERC20 staketkn, uint256 _amount) public onlyOwner returns (bool){
        staketkn.transfer(msg.sender, _amount);
        return true;
    }

    function setEvent(uint40 _start_time, uint40 _end_time,uint256 _income, bool _isOn, uint256 _noOfTokens, bool _isTokenDistribute)  public onlyOwner returns(bool){
        event_start_time = _start_time;
        event_end_time = _end_time;
        isEventOn = _isOn;
        event_income = _income;
        isEventTokenDistrubute = _isTokenDistribute;
        noOfTokenEventDistribute = _noOfTokens;
        return true;
    }

    function clearEvent () public onlyOwner returns(bool){
        for(uint i =0;i<event_complete.length;i++){
            delete event_complete[i];
        }
        return true;
    }
    receive() payable external{ }
}