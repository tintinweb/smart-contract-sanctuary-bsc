/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

}


interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender)external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value)external returns (bool);
  function transferFrom(address from, address to, uint256 value)external returns (bool);
  function burn(uint256 value)external returns (bool);
  event Transfer(address indexed from,address indexed to,uint256 value);
  event Approval(address indexed owner,address indexed spender,uint256 value);
}
contract Staking{
using SafeMath for uint256;
address public owner;

constructor(address ownerAddress) public 
    {
        owner = ownerAddress;  
    }

struct Deposit {
    Details[] _detail;  
    Details_borrow[] _detailborrow;
    uint256 amount;
    uint256 borrowamount;
    uint256 incomeamount;
    uint256 roi;
    uint256 borrowroi;
    uint256 profit;
    uint256 profit_persec;
    uint256 interest;
    uint256 interest_persec;
    uint256 start;
    uint256 borrowstart;
    uint256 end;
    uint256 borrowend;
    uint256 new_start;
    uint256 borrow_new_start;
    uint256 total_lend;
    uint256 total_borrow;
    bool status;
    bool borrowstatus;
    }

struct Details {
    uint256 amount;
    uint256 reward;
    uint256 roi;
    uint256 start;
    uint256 end;
    uint256 closetime;
}


struct Details_borrow {
    uint256 amount;
    uint256 interest;
    uint256 roi;
    uint256 start;
    uint256 end;
    uint256 closetime;
}

      struct User{
         mapping(IBEP20 => Deposit) Deposits;
             }

     struct Data{
        string time;
        uint8 lending_percent;
        uint8 borrow_percent;
        uint256 total_lend;
        uint256 total_borrow;
     }

       struct planinfo {
        uint256 id;
        //Data[] _data;
        uint256 time;
        uint256 lending_percent;
        uint256 borrow_percent;
        uint256 total_lend;
        uint256 total_borrow;
    }
    
 

  modifier onlyAdmin() {
    require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

      mapping (address => User) internal users;
        mapping (IBEP20 => planinfo) internal INFO;

     event NewDeposit(address indexed user, uint256 amount, IBEP20, uint256 rate);
     event Stop(address indexed user, uint256 amount, IBEP20, uint256 start, uint256 end, uint256 profit, uint256 time);
     event Withdraw(address indexed user,uint256 amount, IBEP20,uint256 time);
     event Lending(address indexed user,uint256 amount,uint256 receiveamount, IBEP20,IBEP20,uint256 rate);

    function invest(uint256 amount ,IBEP20 _token) external {
        require(INFO[_token].id!=0,"Invalid Token");
        require(_token.balanceOf(msg.sender)>=amount,"Low Balance");
        require(_token.allowance(msg.sender,address(this))>=amount,"Invalid allowance amount");
       
        //bool lend_status=deposit.status;
         Deposit memory deposit = users[msg.sender].Deposits[_token];
        if(deposit.status==true){
            if(deposit.end>block.timestamp){
         _token.transferFrom(msg.sender,address(this),(amount.mul(1e18)));
        uint256 roi = INFO[_token].lending_percent;
        uint256 new_amount=amount.add(users[msg.sender].Deposits[_token].amount);
        users[msg.sender].Deposits[_token].amount=new_amount;
        uint256 time_start=deposit.start;
        uint256 tim_spend=block.timestamp.sub(time_start);
        users[msg.sender].Deposits[_token].profit=deposit.profit.add(deposit.profit_persec.mul(tim_spend));
        uint256 cal_amt = roi.mul(new_amount.mul(1e18));
        uint256 annual_return=cal_amt.div(100);
        uint256 per_sec_return=annual_return.div(INFO[_token].time);
        users[msg.sender].Deposits[_token].profit_persec=per_sec_return;
        users[msg.sender].Deposits[_token].new_start=block.timestamp;
        INFO[_token].total_lend+=amount;
        users[msg.sender].Deposits[_token].total_lend+=amount;
        } else {
        users[msg.sender].Deposits[_token].status=false;
        uint256 tim_spend=deposit.end.sub(deposit.new_start);
        uint256 reward_cal=deposit.profit_persec.mul(tim_spend);
        users[msg.sender].Deposits[_token].incomeamount+=(deposit.amount.mul(1e18)).add(reward_cal.add(deposit.profit));
        users[msg.sender].Deposits[_token].amount=0;
        users[msg.sender].Deposits[_token].profit=0;
        users[msg.sender].Deposits[_token].profit_persec=0;
        users[msg.sender].Deposits[_token].start=0;
        users[msg.sender].Deposits[_token].new_start=0;
        users[msg.sender].Deposits[_token].end=0;
        users[msg.sender].Deposits[_token]._detail.push(Details(deposit.amount,reward_cal.add(deposit.profit),deposit.roi,deposit.start,deposit.end,block.timestamp));
        }
        } else {
        _token.transferFrom(msg.sender,address(this),(amount.mul(1e18)));
        //Deposit memory deposit = users[msg.sender].Deposits[_token];
        uint256 roi = INFO[_token].lending_percent;
        uint256 cal_amt = roi.mul(amount.mul(1e18));
        uint256 annual_return=cal_amt.div(100);
        uint256 per_sec_return=annual_return.div(INFO[_token].time);
        users[msg.sender].Deposits[_token].amount=amount;
        users[msg.sender].Deposits[_token].profit_persec=per_sec_return;
        users[msg.sender].Deposits[_token].roi=roi;
        users[msg.sender].Deposits[_token].start=block.timestamp;
        users[msg.sender].Deposits[_token].new_start=block.timestamp;
        users[msg.sender].Deposits[_token].end=block.timestamp.add(INFO[_token].time);  
        users[msg.sender].Deposits[_token].status=true; 
        INFO[_token].total_lend+=amount;
        users[msg.sender].Deposits[_token].total_lend+=amount;
        }
        emit NewDeposit(msg.sender,amount, _token, INFO[_token].lending_percent);
    }

     function Borrow(uint256 amount ,IBEP20 _mort_token,IBEP20 _borrow_token) external {
        require(INFO[_mort_token].id!=0,"Invalid Mortgage Token");
        require(INFO[_borrow_token].id!=0,"Invalid Borrow Token");
        require(_mort_token.balanceOf(msg.sender)>=amount,"Low Token Balance");
        require(_mort_token.allowance(msg.sender,address(this))>=amount,"Invalid allowance amount");
         Deposit memory deposit = users[msg.sender].Deposits[_borrow_token];
          _mort_token.transferFrom(msg.sender,address(this),(amount.mul(1e18)));
        uint256 maxamt = amount.mul(1e18).mul(80);
        _borrow_token.transfer(msg.sender,(maxamt.div(100)));
        if(deposit.borrowstatus==true){
        uint256 roi = INFO[_borrow_token].borrow_percent;
        uint256 new_amount=amount.add(users[msg.sender].Deposits[_borrow_token].borrowamount);
        users[msg.sender].Deposits[_borrow_token].borrowamount=new_amount;
        uint256 time_start=deposit.borrowstart;
        uint256 tim_spend=block.timestamp.sub(time_start);
        users[msg.sender].Deposits[_borrow_token].interest=deposit.interest.add(deposit.interest_persec.mul(tim_spend));
        uint256 cal_amt = roi.mul(new_amount.mul(1e18));
        uint256 annual_interest=cal_amt.div(100);
        uint256 per_sec_interest=annual_interest.div(INFO[_borrow_token].time);
        users[msg.sender].Deposits[_borrow_token].interest_persec=per_sec_interest;
        users[msg.sender].Deposits[_borrow_token].borrow_new_start=block.timestamp;
        INFO[_borrow_token].total_borrow+=amount;
        users[msg.sender].Deposits[_borrow_token].total_borrow+=amount;
        } else {
        uint256 roi = INFO[_borrow_token].borrow_percent;
        uint256 cal_amt = roi.mul(amount.mul(1e18));
        uint256 annual_interest=cal_amt.div(100);
        uint256 per_sec_interest=annual_interest.div(INFO[_borrow_token].time);
        users[msg.sender].Deposits[_borrow_token].borrowamount=amount;
        users[msg.sender].Deposits[_borrow_token].interest_persec=per_sec_interest;
        users[msg.sender].Deposits[_borrow_token].borrowroi=roi;
        users[msg.sender].Deposits[_borrow_token].borrowstart=block.timestamp;
        users[msg.sender].Deposits[_borrow_token].borrow_new_start=block.timestamp;
        users[msg.sender].Deposits[_borrow_token].borrowend=block.timestamp.add(INFO[_borrow_token].time);  
        users[msg.sender].Deposits[_borrow_token].borrowstatus=true; 
        INFO[_borrow_token].total_borrow+=amount;
        users[msg.sender].Deposits[_borrow_token].total_borrow+=amount;
        }
        emit Lending(msg.sender,amount,(maxamt.div(100)), _borrow_token,_mort_token, INFO[_borrow_token].lending_percent);
     }

    function withdraw(IBEP20 _token) external {
        require(INFO[_token].id!=0,"Invalid Token");
        //bool lend_status=deposit.status;
         Deposit memory deposit = users[msg.sender].Deposits[_token];
        if(deposit.status==true){
        users[msg.sender].Deposits[_token].status=false;
        uint256 reward_cal=0;
        if(deposit.end>block.timestamp){
            reward_cal=deposit.profit_persec.mul(block.timestamp.sub(deposit.new_start));
        } else {
            reward_cal=deposit.profit_persec.mul(deposit.end.sub(deposit.new_start));
        }
        users[msg.sender].Deposits[_token].incomeamount+=(deposit.amount.mul(1e18)).add(reward_cal.add(deposit.profit));
        users[msg.sender].Deposits[_token].amount=0;
        users[msg.sender].Deposits[_token].profit=0;
        users[msg.sender].Deposits[_token].profit_persec=0;
        users[msg.sender].Deposits[_token].start=0;
        users[msg.sender].Deposits[_token].new_start=0;
        users[msg.sender].Deposits[_token].end=0;
        users[msg.sender].Deposits[_token].profit=reward_cal.add(deposit.profit);
        users[msg.sender].Deposits[_token]._detail.push(Details(deposit.amount,reward_cal.add(deposit.profit),deposit.roi,deposit.start,deposit.end,block.timestamp));
        emit Stop(msg.sender,deposit.amount,_token,deposit.start, deposit.end,users[msg.sender].Deposits[_token].profit, block.timestamp);
        }
    }

    function WithdrawToken(uint256 amount,IBEP20 _token) external {
         Deposit memory deposit = users[msg.sender].Deposits[_token];
         require(deposit.incomeamount>=amount,"Insufficient wallet Balance");
         require(_token.balanceOf(address(this))>=(amount.mul(1e18)),"Low Balance");
         users[msg.sender].Deposits[_token].incomeamount=deposit.incomeamount.sub(amount.mul(1e18));
         _token.transfer(msg.sender,(amount.mul(1e18)));
         emit Withdraw(msg.sender,amount,_token, block.timestamp);
    }

   function totalstake(address user,IBEP20 _TKN) public view returns (uint256) {
      //  return (users[user].Details[_TKN].amount);
   }

   function LendingHistory(address user,IBEP20 _TKN) public view returns (Details[] memory) {
        return users[user].Deposits[_TKN]._detail;
   }

   function tokenDetail(IBEP20 _TKN) public view returns (planinfo memory) {
        return INFO[_TKN];
   }

 function CurrentLendingSummary(address user,IBEP20 _TKN) public view returns (Deposit memory) {
        return users[user].Deposits[_TKN];
   }

   function addToken(IBEP20 _token , uint8 apy_lending, uint8 apy_borrow, uint256 time) external onlyAdmin {
       require(INFO[_token].id==0,"Token Already Added");
       INFO[_token].id++;
       INFO[_token].lending_percent=apy_lending;
       INFO[_token].borrow_percent=apy_borrow;
       INFO[_token].time=time;
       INFO[_token].total_lend=0;
       INFO[_token].total_borrow=0;
       //INFO[_token]._data.push(Data(time,apy_lending,apy_borrow,total_lend,total_borrow));
    }

  function withdrawToken(IBEP20 _token , uint256 amount) external onlyAdmin {
        _token.transfer(owner,amount);
    }
    
    function tokenExist(IBEP20 _token) public view returns (bool) {
        return (INFO[_token].id != 0);
    }
}