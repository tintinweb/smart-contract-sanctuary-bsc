/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.6.0 <0.8.0;

interface IERC20{

    function name() external view returns(string memory);

    function symbol() external view returns(string memory);

    function totalSupply() external view returns (uint );

    function decimals() external view returns(uint);

    function balanceOf(address account) external view returns(uint);

    function approve(address sender , uint value)external returns(bool);

    function allowance(address sender, address spender) external view returns (uint256);

    function transfer(address recepient , uint value) external returns(bool);

    function transferFrom(address sender,address recepient, uint value) external returns(bool);

    event Transfer(address indexed from , address indexed to , uint value);

    event Approval(address indexed sender , address indexed  spender , uint value);
}


contract Staking{
    IERC20 public token;

    address public Owner;

    struct userStuct{
        bool isExist;
        uint id;
        address userAddress;
        uint currentplan;
        uint amountDeposited;
        uint Duration;
        uint percentage;
        mapping(address => uint) returnid;
    }

    uint public curruserID;
    uint public minTokenAmount = 100000000000000000000;
    mapping(uint => uint) public PERCENTAGE;

    mapping(address => uint[]) checkID;
    mapping(address => mapping(uint => userStuct))public UserList;
    mapping(uint => uint) public STAKING_PERIOD;

    event Staked(uint indexed plan , uint indexed ToeknAmount);
    event unStaked(uint indexed id);
    event UpdatePercentage(uint indexed plan , uint indexed percentage);
    event updateStakingperiod(uint indexed plan , uint indexed stakePeriod);
    event updateMintoken(uint indexed updatemintokens);


    constructor(address _token){
       token = IERC20(_token);
       Owner = msg.sender;

       STAKING_PERIOD[1] = 30 days;
       STAKING_PERIOD[2] = 90 days;
       STAKING_PERIOD[3] = 180 days;
       STAKING_PERIOD[4] = 270 days;
       STAKING_PERIOD[5] = 365 days;

       PERCENTAGE[1] = 5;
       PERCENTAGE[2] = 17;
       PERCENTAGE[3] = 35;
       PERCENTAGE[4] = 50;
       PERCENTAGE[5] = 72;

    }

    modifier OnlyOwner(){
        require(Owner == msg.sender,"caller is not the Owner");
        _;
    }

    function Stake(uint plan , uint tokenAmount) public{
        require(tokenAmount >= minTokenAmount,"Minimum 100 token are eligible for staking");
        require(plan > 0 && plan <=5,"must be required plan");
        require(tokenAmount > 0,"invalid token amount");
        curruserID++;
        checkID[msg.sender].push(curruserID);
        token.transferFrom(msg.sender,address(this),tokenAmount);
        UserList[msg.sender][curruserID].isExist = true;
        UserList[msg.sender][curruserID].id = curruserID;
        UserList[msg.sender][curruserID].userAddress = msg.sender;
        UserList[msg.sender][curruserID].currentplan = plan;
        UserList[msg.sender][curruserID].amountDeposited = tokenAmount;
        UserList[msg.sender][curruserID].Duration = block.timestamp + STAKING_PERIOD[plan];
        UserList[msg.sender][curruserID].percentage =  PERCENTAGE[plan];
        emit Staked(plan , tokenAmount);
    }

    function Unstake(uint id) public {
        //require(UserList[msg.sender][id].id == id && UserList[msg.sender][id].id != 0,"user does not exist");
        require(UserList[msg.sender][id].userAddress == msg.sender ,"user does not exist or ID invalid");
        require(UserList[msg.sender][id].Duration < block.timestamp,"can't unstake before the period expiry");
        uint balance = UserList[msg.sender][id].amountDeposited;
        uint stakereward = (UserList[msg.sender][id].amountDeposited * UserList[msg.sender][id].percentage) / 100;
        uint finalamount = balance + stakereward;
        if(finalamount > 0) {
            token.transfer(msg.sender,finalamount);
            UserList[msg.sender][id].amountDeposited = 0;
        }
        emit unStaked(id);
    }

    function checkuserID(address user) public view returns(uint[] memory){
       return checkID[user];
    }

    function updatePercentage(uint plan , uint percentage) public OnlyOwner{
        require(percentage > 0 ,"percentage cant updated");
        PERCENTAGE[plan] = percentage;
        emit UpdatePercentage(plan , percentage);
    }

    function updateStaking_period(uint plan , uint stakeperiod) public OnlyOwner {
        require(stakeperiod > 0,"minimum staking period must be 30 days");
        STAKING_PERIOD[plan] = stakeperiod;
        emit updateStakingperiod(plan , stakeperiod);
    }   

    function updateMinToken(uint updateminTokens) public OnlyOwner{
        require(updateminTokens >= 100,"minimum tokens must be 100");
        minTokenAmount = updateminTokens;
        emit updateMintoken(updateminTokens); 
    }
}