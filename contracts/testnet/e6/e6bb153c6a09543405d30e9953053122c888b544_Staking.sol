/**
 *Submitted for verification at BscScan.com on 2022-10-19
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
    uint256 public staking_amount = 0;//目前質押中的數量

    //年化報酬 = (_apy / _apy_m) => 66/1000 = 6.6%
    uint8 public _apy = 66;
    uint16 public _apy_m = 1000;



    mapping (address => uint256) public user_profit;//總收益(投入+利息) //internal
    mapping (address => uint256) public user_time;//利息計算的起始時間  //internal


    event staking(address _user, uint256 _time, uint256 _amount, uint256 _pre_amount);//地址,質押時間,質押數量,前一筆利息
    event redeem(address _user, uint256 _s_time, uint256 _e_time, uint256 _amount, uint256 _total_amount);//地址,計息開始時間,計息結束時間,利息,總提取
    event redeembyOwner(address _user, uint256 _s_time, uint256 _e_time, uint256 _amount, uint256 _total_amount);//地址,計息開始時間,計息結束時間,利息,總提取
    
    constructor ()  public {
        contract_owner = msg.sender; 
        _set_GBT_TOKEN(0xB536CeAFFf55Dea1673d769c2d4F6b03B8d4079E);// 測試鏈 GBT
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
            GBT_token.transferFrom(msg.sender, address(this), _amount);// 扣款

            //先結算上一筆的利息
            uint256 pre_amount = cal_amount(user_profit[msg.sender], user_time[msg.sender], now_time);
            user_profit[msg.sender] = user_profit[msg.sender].add(pre_amount);//結算的利息加入質押的餘額
            user_profit[msg.sender] = user_profit[msg.sender].add(_amount);//本次投入的數量
            user_time[msg.sender] = now_time;

            staking_amount = staking_amount.add(pre_amount);// 寫入總質押數量(前一次的利息)
            staking_amount = staking_amount.add(_amount);// 寫入總質押數量(本次)

            emit staking(msg.sender, now_time, _amount, pre_amount);
        }
        else
        {
            GBT_token.transferFrom(msg.sender, address(this), _amount);// 扣款

            // 第一次質押
            user_profit[msg.sender] = _amount;//質押的餘額
            user_time[msg.sender] = now_time;

            staking_amount = staking_amount.add(_amount);// 寫入總質押數量

            emit staking(msg.sender, now_time, _amount, 0);
        }

        return true;
    }

    // 計算利息
    function cal_amount(uint256 _amount, uint256 _stime, uint256 _etime)internal view returns (uint256){
        require(_etime >= _stime);
        uint256 _time = _etime.sub(_stime);// _etime - _stime
        uint256 oneDay = 60;// 86400 = 1天 (測試用60秒)

        uint256 _days = _time.div(oneDay);// _time/oneDay
        uint256 amount = (((_amount*_apy)/_apy_m)/365)*_days;

        return amount;

    }
    // 只領取利息
    function Redeem_Token() public returns (bool){
        uint256 now_time = block.timestamp;
        uint256 pre_amount = cal_amount(user_profit[msg.sender], user_time[msg.sender], now_time);
        require(pre_amount > 0);
        require(GBT_token.balanceOf(address(this)) >= pre_amount);//合約裡的餘額必須足夠

        uint256 _time = now_time.sub(user_time[msg.sender]);
        uint256 oneDay = 60;// 86400 = 1天 (測試用60秒)
        uint256 _days = _time.div(oneDay);// _time/oneDay
        if(_days < 30)// 30天內提取 , 需扣2%手續費
        {
            uint256 new_profit = (pre_amount*98)/100;//扣2%手續費
            GBT_token.transfer(msg.sender, new_profit); 
            emit redeem(msg.sender, user_time[msg.sender], now_time, pre_amount, new_profit);
        }
        else
        {
            GBT_token.transfer(msg.sender, pre_amount); 
            emit redeem(msg.sender, user_time[msg.sender], now_time, pre_amount, pre_amount);
        }

        

        user_time[msg.sender] = now_time;// 質押時間 重新開始
        return true;
    }
    
    // 領取本金+利息
    function Redeem_All() public returns (bool){
        uint256 now_time = block.timestamp;
        uint256 pre_amount = cal_amount(user_profit[msg.sender], user_time[msg.sender], now_time);
        user_profit[msg.sender] = user_profit[msg.sender].add(pre_amount);//結算的利息加入質押的餘額

        require(user_profit[msg.sender] > 0);
        require(GBT_token.balanceOf(address(this)) >= user_profit[msg.sender]);//合約裡的餘額必須足夠


        uint256 _time = now_time.sub(user_time[msg.sender]);
        uint256 oneDay = 60;// 86400 = 1天 (測試用60秒)
        uint256 _days = _time.div(oneDay);// _time/oneDay
        if(_days < 30)// 30天內提取 , 需扣2%手續費
        {
            uint256 new_profit = (user_profit[msg.sender]*98)/100;//扣2%手續費
            GBT_token.transfer(msg.sender, new_profit); 
            emit redeem(msg.sender, user_time[msg.sender], now_time, pre_amount, new_profit);
        }
        else
        {
            GBT_token.transfer(msg.sender, user_profit[msg.sender]); 
            emit redeem(msg.sender, user_time[msg.sender], now_time, pre_amount, user_profit[msg.sender]);
        }

        uint256 new_amount = user_profit[msg.sender].sub(pre_amount);// 減去此次產生的利息
        staking_amount = staking_amount.sub(new_amount);// 減去總質押數量

        user_profit[msg.sender] = 0;// 質押金額=0
        user_time[msg.sender] = 0;// 質押時間=0

        return true;
    }

    // 領取本金+利息 by owner
    function Redeem_Token_byOwner(address _user) public onlyOwner{
        uint256 now_time = block.timestamp;
        uint256 pre_amount = cal_amount(user_profit[_user], user_time[_user], now_time);
        user_profit[_user] = user_profit[_user].add(pre_amount);//結算的利息加入質押的餘額

        require(user_profit[_user] > 0);
        require(GBT_token.balanceOf(address(this)) >= user_profit[_user]);//合約裡的餘額必須足夠

        uint256 _time = now_time.sub(user_time[_user]);
        uint256 oneDay = 60;// 86400 = 1天 (測試用60秒)
        uint256 _days = _time.div(oneDay);// _time/oneDay
        if(_days < 30)// 30天內提取 , 需扣2%手續費
        {
            uint256 new_profit = (user_profit[_user]*98)/100;//扣2%手續費
            GBT_token.transfer(_user, new_profit); 
            emit redeembyOwner(_user, user_time[_user], now_time, pre_amount, new_profit);
        }
        else
        {
            GBT_token.transfer(_user, user_profit[_user]); 
            emit redeembyOwner(_user, user_time[_user], now_time, pre_amount, user_profit[_user]);
        }

        uint256 new_amount = user_profit[_user].sub(pre_amount);// 減去此次產生的利息
        staking_amount = staking_amount.sub(user_profit[_user]);// 減去總質押數量

        user_profit[_user] = 0;// 質押金額=0
        user_time[_user] = 0;// 質押時間=0

    }

    // 試算目前產生利息
    function estimate(address _user)public view returns (uint256){
        uint256 now_time = block.timestamp;
        uint256 pre_amount = cal_amount(user_profit[_user], user_time[_user], now_time);

        return pre_amount;
    }


    //堤幣(GBT-token)
    function withdraw() public onlyOwner{
        address contract_addr = address(this);
        uint256 contract_balance = GBT_token.balanceOf(contract_addr);
        GBT_token.transfer(msg.sender, contract_balance);
        
        staking_amount = 0;//質押數量歸0
    }
    // 設定年化報酬(%) 4% = 4/100 ; new_apy=4 , new_apy_m=100
    function set_apy(uint8 new_apy, uint16 new_apy_m) public onlyOwner {
        require(new_apy > 0 && new_apy_m > 0);
        _apy = new_apy;
        _apy_m = new_apy_m;
    }

}