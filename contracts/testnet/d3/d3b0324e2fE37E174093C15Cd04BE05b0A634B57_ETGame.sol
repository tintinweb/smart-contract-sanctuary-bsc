/**
 *Submitted for verification at BscScan.com on 2022-07-09
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
    uint256 public PRICE = 2;//88 USDT (IFO)
    uint256 public PRICE_B = 3;//1000 USDT (聯合股東)
    uint256 public REWARD = 4400;//88000 ET 的 5% 給推薦人
    address public ET_addr = address(0);//ET代幣合約地只
    address public ET_pool = address(0);
    bool public isActive = false;


    mapping (address => bool) public A_is_buy;// IFO
    mapping (address => bool) public B_is_buy;// 聯合股東
    mapping (address => bool) public is_chg;//是否領取代幣

    mapping (address => uint256) public ET_balance;// 待領取的 ET 代幣
    mapping (address => uint256) public R_num;// 推薦人數
    mapping (address => address) public my_referrer;// 我的推薦人

    event owner_withdraw(address to_addr, uint256 _value);

    constructor() public {
        contract_owner = msg.sender; 
        BUSD = ERC20(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684); // 測試鏈BUSD
    }

    modifier onlyOwner() {
        require(msg.sender == contract_owner);
        _;
    }

    // IFO
    function buy_A() public returns (bool) {
        uint256 BUSD_B = BUSD.balanceOf(msg.sender);
        uint256 allowance = BUSD.allowance(msg.sender, address(this));
        require(my_referrer[msg.sender] != address(0), "Please Set referrer.");
        require(A_is_buy[msg.sender]==false, "You have purchased.");
        require(BUSD_B >= PRICE*1*10**18,"Check your BUSD balance");
        require(allowance >= PRICE*1*10**18, "Check the BUSD allowance");

        
        BUSD.transferFrom(msg.sender, address(this), PRICE*1*10**18);

        ET_balance[msg.sender] = ET_balance[msg.sender].add(88000*1*10**18);// 88000 個 ET 代幣
        address referrer_addr = my_referrer[msg.sender];
        ET_balance[referrer_addr] = ET_balance[referrer_addr].add(REWARD*1*10**18);// 推薦人可獲得 4400個ET 代幣

        A_is_buy[msg.sender] = true;
        is_chg[msg.sender] = false;
  
        return true;
    }

    // 聯合股東
    function buy_B() public returns (bool) {
        uint256 BUSD_B = BUSD.balanceOf(msg.sender);
        uint256 allowance = BUSD.allowance(msg.sender, address(this));
        require(B_is_buy[msg.sender]==false, "You have purchased.");
        require(BUSD_B >= PRICE_B*1*10**18,"Check your BUSD balance");
        require(allowance >= PRICE_B*1*10**18, "Check the BUSD allowance");

        
        BUSD.transferFrom(msg.sender, address(this), PRICE_B*1*10**18);

        B_is_buy[msg.sender] = true;
        is_chg[msg.sender] = false;
  
        return true;
    }

    // 提取 ET 代幣
    function withdraw_ET() public{
        uint256 reward_balance = ET_balance[msg.sender];
        require(reward_balance > 0 ,"Insufficient balance");
        ET_Token.transfer(msg.sender, reward_balance);

        ET_balance[msg.sender] = ET_balance[msg.sender].sub(reward_balance);

        if(ET_balance[msg.sender]==0)
        {
            is_chg[msg.sender] = true;
        }
    }

    // 合約擁有者提取 USDT
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


    function set_ET_address(address _token) public onlyOwner {
        require(_token!=address(0),"Address Error.");
        ET_addr = _token;

        ET_Token = ERC20(ET_addr);
    }

    function user_chgToken() public returns (bool) {
        require(is_chg[msg.sender]==false,"You have exchanged.");
        is_chg[msg.sender] = true;

        return true;
    }

    // 設定推薦人
    function set_referrer(address _addr) public returns (bool) {
        require(_addr!= address(0),"Address Error.");
        require(_addr!= msg.sender,"Referrer Error.");
        require(my_referrer[msg.sender] != address(0),"Error.");
        my_referrer[msg.sender] = _addr;
        R_num[_addr] = R_num[_addr].add(1);

        return true;
    }

    // 查詢推薦人
    function get_my_referrer(address _addr) public view returns (address) {
        return my_referrer[_addr];
    }

    // 查詢地址推薦人數
    function get_R_num(address _addr) public view returns (uint256) {
        return R_num[_addr];
    }

    // 查詢累積 ET代幣額度
    function get_ET_balance(address _addr) public view returns (uint256) {
        return ET_balance[_addr];
    }

}