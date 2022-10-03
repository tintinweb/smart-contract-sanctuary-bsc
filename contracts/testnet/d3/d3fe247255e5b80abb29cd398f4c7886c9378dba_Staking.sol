/**
 *Submitted for verification at BscScan.com on 2022-10-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
    
}

library Counters {
    using SafeMath for uint256;

    struct Counter {

        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

interface ERC20 {
  function transfer(address _to, uint256 _value) external returns (bool);
  function balanceOf(address _owner) external view returns (uint256 balance);
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
  function totalSupply() external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
}


contract Staking{
    using SafeMath for uint256;

    ERC20 public GBT_token;

    address public contract_owner;
    uint256 public decimals = 18;

    uint8 public _apy = 4;//年化報酬 4%


    mapping (address => uint256) public user_profit;//總收益(投入+利息) //internal
    mapping (address => uint256) public user_time;//利息計算的起始時間  //internal


    event staking(address _user, address _nft_addr, uint _nft_id, uint256 _time, uint256 _order_id, uint256 withdraw_time);
    event redeem(address _user, uint256 _end_time, uint256 _order_id, uint256 _amount);
    event cal(uint256 _order_id, uint256 _nft_amount, uint256 _apy, uint256 _start_time, uint256 _end_time, uint256 _days);
    event cancel(address _user, address _nft_addr, uint _nft_id,  uint256 _order_id, uint256 return_time);
    event referrer_amount(address _referrer,uint256 _order_id, uint256 _amount, uint256 r_amount, uint256 referrer_num);
    
    constructor ()  public {
        contract_owner = msg.sender; 
        _set_GBT_TOKEN(0xB536CeAFFf55Dea1673d769c2d4F6b03B8d4079E);
    }
    
    modifier onlyOwner() {
        require(msg.sender == contract_owner);
        _;
    }
    
    //pay token
    function _set_GBT_TOKEN(address _tokenAddr) internal onlyOwner{
        require(_tokenAddr != address(0));
        GBT_token = ERC20(_tokenAddr);
    }
    
    // 質押
    function Staking_Token(uint256 _amount) public returns (bool) {
        uint256 GBT_B = GBT_token.balanceOf(msg.sender);
        uint256 allowance = GBT_token.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Check the GBT allowance.");
        require(GBT_B >= _amount,"Check your GBT balance.");

        uint256 now_time = block.timestamp;
        if(user_time[msg.sender] !=0)// 表示有上一筆
        {
            //先結算上一筆的利息
            uint256 pre_amount = cal_amount(user_profit[msg.sender], user_time[msg.sender], now_time);
            user_profit[msg.sender] = user_profit[msg.sender].add(pre_amount);//結算的利息加入質押的餘額
            user_time[msg.sender] = now_time;
        }
        else
        {
            // 第一次質押
            user_profit[msg.sender] = _amount;//質押的餘額
            user_time[msg.sender] = now_time;
        }

        return true;
    }

    // 計算利息
    function cal_amount(uint256 _amount, uint256 _stime, uint256 _etime)internal returns (uint256){
        require(_etime >= _stime);
        uint256 _time = _etime.sub(_stime);// _etime - _stime
        uint256 oneDay = 60;// 86400 = 1天 (測試用1分鐘)

        uint256 _days = _time.div(oneDay);// _time/oneDay
        uint256 amount = (((_amount*_apy)/100)/365)*_days;

        return amount;

    }
    
    // 領取本金+利息
    function Redeem_Token() public returns (bool){
        uint256 now_time = block.timestamp;
        uint256 pre_amount = cal_amount(user_profit[msg.sender], user_time[msg.sender], now_time);
        user_profit[msg.sender] = user_profit[msg.sender].add(pre_amount);//結算的利息加入質押的餘額

        require(user_profit[msg.sender] > 0);
        GBT_token.transfer(msg.sender, user_profit[msg.sender]); 
        user_profit[msg.sender] = 0;// 質押金額=0
        user_time[msg.sender] = 0;// 質押時間=0

        return true;
    }


    //堤幣(GBT-token)
    function withdraw() public onlyOwner{
        address contract_addr = address(this);
        uint256 contract_balance = GBT_token.balanceOf(contract_addr);
        GBT_token.transfer(msg.sender, contract_balance);
        
    }

}