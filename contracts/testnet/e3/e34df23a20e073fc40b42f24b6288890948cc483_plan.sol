pragma solidity >=0.4.0 <0.8.0;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./owned.sol";


contract plan is owned {
    IERC20 public stakingToken;
    uint40 public time_period = 15552000;
    uint256 public min_tokens = 10000;
    uint256 public distribute_persent = 6;
    uint256 public level_distribute_persent = 15;
    uint256 private plan_diveder = 100;
    uint40 public event_start_time;
    uint40 public event_end_time;
    bool public isEventOn;

    mapping(address => User) public users;
    uint256 public total_users = 1; 

    struct eventIncome {
        uint256 income;        
    }

    mapping(address => eventIncome) public eventIncomes;

    constructor(IERC20 _stakingtoken) public {      
        stakingToken = _stakingtoken;
        users[msg.sender].id = total_users; 
        users[msg.sender].myaddress = msg.sender; 
        isEventOn = false; 
    }

    function stak(address _upline, uint256 _tokens) public returns (bool){      

        _stak(_upline, _tokens); 
        return true;
    }

    address private upline;
    function _stak(address _upline, uint256 _tokens) internal {
        
        stakingToken.transferFrom(msg.sender, address(this), _tokens * (10 ** 18));
        uint256 cashback = (_tokens * (10 ** 18)) * distribute_persent / 100;
        stakingToken.transfer(msg.sender, cashback);

        total_users++;

        users[msg.sender].id = total_users;
        users[msg.sender].myaddress = msg.sender;
        users[msg.sender].sponsor = _upline;
        users[msg.sender].cashback = distribute_persent;
        users[msg.sender].upto = uint40(block.timestamp) + time_period;
        users[msg.sender].deposit_amount = _tokens * (10 ** 18);
             
        users[msg.sender].deposit_time = uint40(block.timestamp);            
        
        users[_upline].directs++;

        upline =  msg.sender;
        for (uint i = 0; i < 10; i++) {
            upline = users[upline].sponsor;
            if(upline != address(0) && users[upline].deposit_time != 0){
                users[upline].total_commision +=  (_tokens * (10 ** 18)) * (level_commision[i]/plan_diveder)/100;
                if(isEventOn == true){
                    eventIncomes[upline].income = eventIncomes[upline].income + ((_tokens * (10 ** 18)) * (level_commision[i]/plan_diveder)/100);
                }
            }
        }
    }

    function unstake() public returns(bool){
        uint256 deduction = 0;
        if(users[msg.sender].upto >= block.timestamp){
           deduction = (users[msg.sender].deposit_amount * users[msg.sender].cashback / 100) + (users[msg.sender].deposit_amount * level_distribute_persent / 100);
        }

        stakingToken.transfer(msg.sender, (users[msg.sender].deposit_amount-deduction));
        users[msg.sender].deposit_amount = 0;
        users[msg.sender].deposit_time = 0;
        return true;
    }

    function claimCommision(uint256 _claim_amount) public returns(bool){
        require (users[msg.sender].total_commision >= _claim_amount, "Insufficient Balance.");
        stakingToken.transfer(msg.sender, _claim_amount);
        users[msg.sender].total_commision -= _claim_amount;
        return true;
    }

    function setPercentage(uint _lvl, uint256 income) public onlyOwner returns (bool){
        level_commision[_lvl] = income;
        return true;
    }

    function withdraw(uint256 _amount) public onlyOwner returns (bool){
        stakingToken.transfer(msg.sender, _amount);
        return true;
    }

    function setEvent(uint40 _start_time, uint40 _end_time, bool _isOn)  public onlyOwner returns(bool){
        event_start_time = _start_time;
        event_end_time = _end_time;
        isEventOn = _isOn;
        return true;
    }

    //function clearEvent() public onlyOwner returns(bool){
        //eventIncomes = ;
    //    return true;
    //}

}