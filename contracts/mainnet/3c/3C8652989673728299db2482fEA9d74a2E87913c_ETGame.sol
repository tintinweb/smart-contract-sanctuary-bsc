/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
    
    function sqrt(uint x) internal pure returns(uint) {
        uint z = (x + 1 ) / 2;
        uint y = x;
        while(z < y){
          y = z;
          z = ( x / z + z ) / 2;
        }
        return y;
     }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

interface ERC20 {
  function transfer(address _to, uint256 _value) external returns (bool);
  function balanceOf(address _owner) external view returns (uint256 balance);
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
  function totalSupply() external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
}

contract ETGame {
    using SafeMath for uint256;
    using Address for address;

    ERC20 public BUSD;
    ERC20 public ET_Token;

    address public contract_owner;
    address public AR_addr = 0xA9beA6Cb7a3F1e889BF868B00bd09CD56F601f90;
    address public BR_addr = 0x435d8A440f53E6Dfb2197A9581E3006Dbff1d30c;
    uint256 public PRICE = 88;
    uint256 public PRICE_B = 1000;
    uint256 public REWARD = 4400;
    address public ET_addr = address(0);
    address public ET_pool = address(0);
    bool public isActive = true;


    mapping (address => bool) public A_is_buy;
    mapping (address => bool) public B_is_buy;
    mapping (address => bool) public is_chg;

    mapping (address => uint256) public ET_balance;
    mapping (address => uint256) public R_num;
    mapping (address => address) public my_referrer;

    event owner_withdraw(address to_addr, uint256 _value);
    event user_withdraw(address to_addr, uint256 _value, bool _ischg);

    constructor() public {
        contract_owner = msg.sender; 
        BUSD = ERC20(0x55d398326f99059fF775485246999027B3197955);
    }

    modifier onlyOwner() {
        require(msg.sender == contract_owner);
        _;
    }

    function buy_A() public returns (bool) {
        uint256 BUSD_B = BUSD.balanceOf(msg.sender);
        uint256 allowance = BUSD.allowance(msg.sender, address(this));
        require(isActive, "Not started yet.");
        require(my_referrer[msg.sender] != address(0), "Please Set referrer.");
        require(A_is_buy[msg.sender]==false, "You have purchased.");
        require(BUSD_B >= PRICE*1*10**18,"Check your BUSD balance");
        require(allowance >= PRICE*1*10**18, "Check the BUSD allowance");

        
        BUSD.transferFrom(msg.sender, AR_addr, PRICE*1*10**18);
        ET_balance[msg.sender] = ET_balance[msg.sender].add(88000*1*10**18);
        address referrer_addr = my_referrer[msg.sender];
        ET_balance[referrer_addr] = ET_balance[referrer_addr].add(REWARD*1*10**18);

        A_is_buy[msg.sender] = true;
        is_chg[msg.sender] = false;
  
        return true;
    }

    function buy_B() public returns (bool) {
        uint256 BUSD_B = BUSD.balanceOf(msg.sender);
        uint256 allowance = BUSD.allowance(msg.sender, address(this));
        require(isActive, "Not started yet.");
        require(B_is_buy[msg.sender]==false, "You have purchased.");
        require(BUSD_B >= PRICE_B*1*10**18,"Check your BUSD balance");
        require(allowance >= PRICE_B*1*10**18, "Check the BUSD allowance");

        
        BUSD.transferFrom(msg.sender, BR_addr, PRICE_B*1*10**18);
        ET_balance[msg.sender] = ET_balance[msg.sender].add(100000*1*10**18);

        B_is_buy[msg.sender] = true;
        is_chg[msg.sender] = false;
  
        return true;
    }

    function withdraw_ET() public{
        require(ET_addr != address(0) ,"Not started yet.");
        require(ET_pool  != address(0) ,"Not started yet..");
        uint256 reward_balance = ET_balance[msg.sender];
        require(reward_balance > 0 ,"Insufficient balance");
        uint256 ET_B = ET_Token.balanceOf(ET_pool);
        uint256 ET_allowance = ET_Token.allowance(ET_pool, address(this));
        require(ET_B >= reward_balance,"Check ET-Token balance");
        require(ET_allowance >= reward_balance, "Check ET-Token allowance");

        ET_Token.transferFrom(ET_pool, msg.sender, reward_balance);

        ET_balance[msg.sender] = ET_balance[msg.sender].sub(reward_balance);

        if(ET_balance[msg.sender]==0)
        {
            is_chg[msg.sender] = true;
        }

        emit user_withdraw(msg.sender, reward_balance, is_chg[msg.sender]);
    }

    function withdraw(address w_addr) public onlyOwner{
        require(w_addr!=address(0),"Address Error.");
        address contract_addr = address(this);
        uint256 contract_balance = BUSD.balanceOf(contract_addr);
        BUSD.transfer(w_addr, contract_balance);
        
        emit owner_withdraw(w_addr, contract_balance);
    }


    function set_active() public onlyOwner {
        if(isActive)
        {
            isActive = false;
        }
        else
        {
            isActive = true;
        }
    }

    function set_ET_address(address _token, address _pool) public onlyOwner {
        require(_token!=address(0),"Address Error.");
        require(_pool!=address(0),"Address Error..");
        ET_addr = _token;
        ET_pool = _pool;

        ET_Token = ERC20(ET_addr);
    }

    function user_chgToken() public returns (bool) {
        require(is_chg[msg.sender]==false,"You have exchanged.");
        is_chg[msg.sender] = true;

        return true;
    }

    function set_referrer(address _addr) public returns (bool) {
        require(_addr!= address(0),"Address Error.");
        require(_addr!= msg.sender,"Referrer Error.");
        require(my_referrer[msg.sender] == address(0),"Error.");
        my_referrer[msg.sender] = _addr;
        R_num[_addr] = R_num[_addr].add(1);

        return true;
    }

    function get_my_referrer(address _addr) public view returns (address) {
        return my_referrer[_addr];
    }

    function get_R_num(address _addr) public view returns (uint256) {
        return R_num[_addr];
    }

    function get_ET_balance(address _addr) public view returns (uint256) {
        return ET_balance[_addr];
    }

    function set_AR_addr(address _addr) public onlyOwner {
        require(_addr!=address(0),"Address Error.");
        AR_addr = _addr;
    }

    function set_BR_addr(address _addr) public onlyOwner {
        require(_addr!=address(0),"Address Error.");
        BR_addr = _addr;
    }

    function set_user_is_chg(address _addr,bool _bool) public onlyOwner {
        require(_addr!=address(0),"Address Error.");
        is_chg[_addr] = _bool;
    }

}