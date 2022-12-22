/**
 *Submitted for verification at BscScan.com on 2022-12-22
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
    uint256 amount;
    uint256 roi;
    uint256 profit;
    uint256 profit_persec;
    uint256 start;
    uint256 end;
    uint256 new_start;
    uint256 timelending;
    uint256 total_stake;
    bool status;
    }

struct Details {
    uint256 amount;
    uint256 reward;
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
        uint8 lending_percent;
        uint8 borrow_percent;
        uint256 total_lend;
        uint256 total_borrow;
    }
    
 

  modifier onlyAdmin() {
    require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

      mapping (address => User) internal users;
        mapping (IBEP20 => planinfo) internal INFO;

     event NewDeposit(address indexed user, uint256 amount);
    

    function invest(uint256 amount ,IBEP20 _token, uint256 timelending) external {
        require(INFO[_token].id!=0,"Invalid Token");
        require(_token.balanceOf(msg.sender)>=amount,"Low Balance");
        require(_token.allowance(msg.sender,address(this))>=amount,"Invalid allowance amount");
        _token.transferFrom(msg.sender,address(this),amount);
        bool lend_status=users[msg.sender].Deposits[_token].status;
        if(!lend_status && amount>0){
            if(users[msg.sender].Deposits[_token].end<block.timestamp){
        uint256 roi = INFO[_token].lending_percent;
        roi = roi.div(10);
        uint256 new_amount=amount.add(users[msg.sender].Deposits[_token].amount);
        users[msg.sender].Deposits[_token].amount=new_amount;
        uint256 time_start=users[msg.sender].Deposits[_token].start;
        uint256 secondtocal=users[msg.sender].Deposits[_token].timelending;
        uint256 tim_spend=block.timestamp.sub(time_start);
        uint256 profit_per=users[msg.sender].Deposits[_token].profit_persec;
        uint256 reward_cal=profit_per.mul(tim_spend);
        uint256 profit=users[msg.sender].Deposits[_token].profit;
        users[msg.sender].Deposits[_token].profit=profit.add(reward_cal);
        uint256 annual_return = roi.div(100).mul(new_amount);
        uint256 per_sec_return=annual_return.div(secondtocal);
        users[msg.sender].Deposits[_token].profit_persec=per_sec_return;
        users[msg.sender].Deposits[_token].new_start=block.timestamp;
        } else {
        users[msg.sender].Deposits[_token].status=false;
        uint256 per_sec_prof=users[msg.sender].Deposits[_token].profit_persec;
        uint256 lasttime=users[msg.sender].Deposits[_token].new_start;
        uint256 tim_spend=block.timestamp.sub(lasttime);
        uint256 reward_cal=per_sec_prof.mul(tim_spend);
        uint256 reward=users[msg.sender].Deposits[_token].profit;
        users[msg.sender].Deposits[_token].profit=reward_cal.add(reward);
        users[msg.sender].Deposits[_token]._detail.push(Details(users[msg.sender].Deposits[_token].amount,reward_cal.add(reward),users[msg.sender].Deposits[_token].roi,users[msg.sender].Deposits[_token].start,users[msg.sender].Deposits[_token].end,block.timestamp));
        }
        } else {
        uint256 roi = INFO[_token].lending_percent;
        roi = roi.div(10);
        uint256 annual_return = roi.div(100).mul(amount);
        uint256 per_sec_return=annual_return.div(timelending);
        users[msg.sender].Deposits[_token].amount=amount;
        users[msg.sender].Deposits[_token].profit_persec=per_sec_return;
        users[msg.sender].Deposits[_token].roi=roi;
        users[msg.sender].Deposits[_token].start=block.timestamp;
        users[msg.sender].Deposits[_token].new_start=block.timestamp;
        users[msg.sender].Deposits[_token].timelending=timelending;
        users[msg.sender].Deposits[_token].end=block.timestamp.add(INFO[_token].time);   
        }
        emit NewDeposit(msg.sender,amount);
    }

   function totalstake(address user,IBEP20 _TKN) public view returns (uint256) {
      //  return (users[user].Details[_TKN].amount);
   }

   function seeDetailsLending(address user,IBEP20 _TKN) public view returns (Details[] memory) {
        return users[user].Deposits[_TKN]._detail;
   }

   function seeLending(address user,IBEP20 _TKN) public view returns (Deposit memory) {
        return users[user].Deposits[_TKN];
   }
   function addToken(IBEP20 _token , uint8 apy_lending, uint8 apy_borrow, uint256 time) external onlyAdmin {
     
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