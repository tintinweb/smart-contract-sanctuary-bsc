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
    uint256 public staking_amount = 0;

    uint8 public _apy = 66;
    uint16 public _apy_m = 1000;



    mapping (address => uint256) public user_profit;
    mapping (address => uint256) public user_time;


    event staking(address _user, uint256 _time, uint256 _amount, uint256 _pre_amount);
    event redeem(address _user, uint256 _s_time, uint256 _e_time, uint256 _amount, uint256 _total_amount);
    event redeembyOwner(address _user, uint256 _s_time, uint256 _e_time, uint256 _amount, uint256 _total_amount);
    
    constructor ()  public {
        contract_owner = msg.sender; 
        _set_GBT_TOKEN(0x4dF24862a18A9CB329Bcd6d1c42d7c0E5f405997);
    }
    
    modifier onlyOwner() {
        require(msg.sender == contract_owner);
        _;
    }
    
    function _set_GBT_TOKEN(address _tokenAddr) internal onlyOwner{
        require(_tokenAddr != address(0));
        GBT_token = ERC20(_tokenAddr);
    }
    
    function Staking_Token(uint256 _amount) public returns (bool) {
        uint256 GBT_B = GBT_token.balanceOf(msg.sender);
        uint256 allowance = GBT_token.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Check the GBT allowance.");
        require(GBT_B >= _amount,"Check your GBT balance.");

        uint256 now_time = block.timestamp;
        if(user_time[msg.sender] !=0)
        {
            GBT_token.transferFrom(msg.sender, address(this), _amount);

            uint256 pre_amount = cal_amount(user_profit[msg.sender], user_time[msg.sender], now_time);
            user_profit[msg.sender] = user_profit[msg.sender].add(pre_amount);
            user_profit[msg.sender] = user_profit[msg.sender].add(_amount);
            user_time[msg.sender] = now_time;

            staking_amount = staking_amount.add(pre_amount);
            staking_amount = staking_amount.add(_amount);

            emit staking(msg.sender, now_time, _amount, pre_amount);
        }
        else
        {
            GBT_token.transferFrom(msg.sender, address(this), _amount);

            user_profit[msg.sender] = _amount;
            user_time[msg.sender] = now_time;

            staking_amount = staking_amount.add(_amount);

            emit staking(msg.sender, now_time, _amount, 0);
        }

        return true;
    }

    function cal_amount(uint256 _amount, uint256 _stime, uint256 _etime)internal view returns (uint256){
        require(_etime >= _stime);
        uint256 _time = _etime.sub(_stime);
        uint256 oneDay = 86400;

        uint256 _days = _time.div(oneDay);
        uint256 amount = (((_amount*_apy)/_apy_m)/365)*_days;

        return amount;

    }

    function Redeem_Token() public returns (bool){
        uint256 now_time = block.timestamp;
        uint256 pre_amount = cal_amount(user_profit[msg.sender], user_time[msg.sender], now_time);
        require(pre_amount > 0);
        require(GBT_token.balanceOf(address(this)) >= pre_amount);

        uint256 _time = now_time.sub(user_time[msg.sender]);
        uint256 oneDay = 86400;
        uint256 _days = _time.div(oneDay);
        if(_days < 30)
        {
            uint256 new_profit = (pre_amount*98)/100;
            GBT_token.transfer(msg.sender, new_profit); 
            emit redeem(msg.sender, user_time[msg.sender], now_time, pre_amount, new_profit);
        }
        else
        {
            GBT_token.transfer(msg.sender, pre_amount); 
            emit redeem(msg.sender, user_time[msg.sender], now_time, pre_amount, pre_amount);
        }

        

        user_time[msg.sender] = now_time;
        return true;
    }
    
    function Redeem_All() public returns (bool){
        uint256 now_time = block.timestamp;
        uint256 pre_amount = cal_amount(user_profit[msg.sender], user_time[msg.sender], now_time);
        user_profit[msg.sender] = user_profit[msg.sender].add(pre_amount);

        require(user_profit[msg.sender] > 0);
        require(GBT_token.balanceOf(address(this)) >= user_profit[msg.sender]);


        uint256 _time = now_time.sub(user_time[msg.sender]);
        uint256 oneDay = 86400;
        uint256 _days = _time.div(oneDay);
        if(_days < 30)
        {
            uint256 new_profit = (user_profit[msg.sender]*98)/100;
            GBT_token.transfer(msg.sender, new_profit); 
            emit redeem(msg.sender, user_time[msg.sender], now_time, pre_amount, new_profit);
        }
        else
        {
            GBT_token.transfer(msg.sender, user_profit[msg.sender]); 
            emit redeem(msg.sender, user_time[msg.sender], now_time, pre_amount, user_profit[msg.sender]);
        }

        uint256 new_amount = user_profit[msg.sender].sub(pre_amount);
        staking_amount = staking_amount.sub(new_amount);

        user_profit[msg.sender] = 0;
        user_time[msg.sender] = 0;

        return true;
    }

    function Redeem_Token_byOwner(address _user) public onlyOwner{
        uint256 now_time = block.timestamp;
        uint256 pre_amount = cal_amount(user_profit[_user], user_time[_user], now_time);
        user_profit[_user] = user_profit[_user].add(pre_amount);

        require(user_profit[_user] > 0);
        require(GBT_token.balanceOf(address(this)) >= user_profit[_user]);

        uint256 _time = now_time.sub(user_time[_user]);
        uint256 oneDay = 86400;
        uint256 _days = _time.div(oneDay);
        if(_days < 30)
        {
            uint256 new_profit = (user_profit[_user]*98)/100;
            GBT_token.transfer(_user, new_profit); 
            emit redeembyOwner(_user, user_time[_user], now_time, pre_amount, new_profit);
        }
        else
        {
            GBT_token.transfer(_user, user_profit[_user]); 
            emit redeembyOwner(_user, user_time[_user], now_time, pre_amount, user_profit[_user]);
        }

        uint256 new_amount = user_profit[_user].sub(pre_amount);
        staking_amount = staking_amount.sub(user_profit[_user]);

        user_profit[_user] = 0;
        user_time[_user] = 0;

    }

    function estimate(address _user)public view returns (uint256){
        uint256 now_time = block.timestamp;
        uint256 pre_amount = cal_amount(user_profit[_user], user_time[_user], now_time);

        return pre_amount;
    }


    function withdraw() public onlyOwner{
        address contract_addr = address(this);
        uint256 contract_balance = GBT_token.balanceOf(contract_addr);
        GBT_token.transfer(msg.sender, contract_balance);
        
        staking_amount = 0;
    }

    function set_apy(uint8 new_apy, uint16 new_apy_m) public onlyOwner {
        require(new_apy > 0 && new_apy_m > 0);
        _apy = new_apy;
        _apy_m = new_apy_m;
    }

}