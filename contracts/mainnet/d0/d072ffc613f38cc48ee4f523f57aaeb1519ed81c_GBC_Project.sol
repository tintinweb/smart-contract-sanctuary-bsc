/**
 *Submitted for verification at BscScan.com on 2022-10-18
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
    
}

interface ERC20 {
  function transfer(address _to, uint256 _value) external returns (bool);
  function balanceOf(address _owner) external view returns (uint256 balance);
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
  function totalSupply() external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
}

contract GBC_Project{
    using SafeMath for uint256;
    ERC20 public USDT;

    address public contract_owner;
    address public project_owner;
    address public web_addr = 0x70eA85D15EE12cb5D7e40fc664308691983353d4;
    uint256 public decimals = 18;

    struct ProjectConfig {
        uint256 startTime;
        uint256 endTime;
        uint256 total;
        uint256 standard;
        uint256 sponsors;
        uint8 fee;
        uint256 _amount;
    }

    ProjectConfig public P_Config;

    mapping (address => uint256) public user_invest;
    mapping (uint256 => address) public sponsors_list;

    constructor ()  public {
        contract_owner = msg.sender; 
        USDT = ERC20(0x55d398326f99059fF775485246999027B3197955); 

        P_Config.startTime = 1663516800;
        P_Config.endTime = 1664553600;
        P_Config.total = 12*1*10**decimals;
        P_Config.standard = 5*1*10**decimals;
        P_Config.sponsors = 0;
        P_Config.fee = 0;
        P_Config._amount = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == contract_owner);
        _;
    }

    event invest_detail(address _user, uint256 usdt_num, uint256 _time);
    event withdraw_detail(address _project_addr, address _web_addr, uint256 p_usdt, uint256 w_usdt, uint256 _time);
    event return_detail(address _user, uint256 usdt_num, uint256 _time);

    function invest(uint256 usdt_num) public returns (bool) {
        uint256 USDT_B = USDT.balanceOf(msg.sender);
        uint256 allowance = USDT.allowance(msg.sender, address(this));
        require(allowance >= usdt_num, "Check the USDT allowance.");
        require(USDT_B >= usdt_num,"Check your USDT balance.");

        require(P_Config.startTime <= block.timestamp && block.timestamp <= P_Config.endTime,"Out of time.");
        require(usdt_num > 0);
        require(P_Config._amount.add(usdt_num) <= P_Config.total);

        USDT.transferFrom(msg.sender, address(this), usdt_num);
        user_invest[msg.sender] = user_invest[msg.sender].add(usdt_num);
        sponsors_list[P_Config.sponsors] = msg.sender;
        P_Config._amount = P_Config._amount.add(usdt_num);
        P_Config.sponsors = P_Config.sponsors.add(1);


        emit invest_detail(msg.sender, usdt_num, block.timestamp);

        return true;
    }


    function withdraw() public onlyOwner{
        require(block.timestamp > P_Config.endTime,"Out of time.");
        require(project_owner!=address(0),"Address Error.");
        address contract_addr = address(this);
        uint256 contract_balance = USDT.balanceOf(contract_addr);

        if(P_Config._amount >= P_Config.standard)
        {
            if(P_Config.fee >0 )
            {
                uint256 new_fee = (contract_balance*P_Config.fee)/100;
                uint256 new_b = contract_balance.sub(new_fee); 

                USDT.transfer(project_owner, new_b);
                USDT.transfer(web_addr, new_fee);
                P_Config._amount = 0; 


                emit withdraw_detail(project_owner, web_addr, new_b, new_fee, block.timestamp);
            }
            else
            {
                USDT.transfer(project_owner, contract_balance);
                P_Config._amount = 0; 


                emit withdraw_detail(project_owner, web_addr, contract_balance, 0, block.timestamp);
            }
        }
        else
        {

            for(uint i = 0; i < P_Config.sponsors; i++) 
            {
                address _user = sponsors_list[i];
                uint256 invest_amount = user_invest[_user];

                if(invest_amount >0)
                {
                    USDT.transfer(_user, invest_amount);
                    user_invest[_user] = 0; 

                    emit return_detail(_user, invest_amount, block.timestamp);

                    P_Config._amount = P_Config._amount.sub(invest_amount); 
                }
            }
        }
    }


    function withdraw_one(uint256 _num) public onlyOwner{
        require(block.timestamp > P_Config.endTime,"Out of time.");
        require(project_owner!=address(0),"Address Error.");
        address contract_addr = address(this);
        uint256 contract_balance = USDT.balanceOf(contract_addr);

        if(P_Config._amount < P_Config.standard)
        {
            address _user = sponsors_list[_num];
            uint256 invest_amount = user_invest[_user];

            if(invest_amount >0)
            {
                USDT.transfer(_user, invest_amount);
                user_invest[_user] = 0; 

                emit return_detail(_user, invest_amount, block.timestamp);

                P_Config._amount = P_Config._amount.sub(invest_amount); 
            }
        }

    }

    function set_time(uint256 _s, uint256 _e) public onlyOwner {
        require(_e > _s);
        P_Config.startTime = _s;
        P_Config.endTime = _e;
    }

    function set_total(uint256 _total) public onlyOwner {
        P_Config.total = _total;
    }

    function set_standard(uint256 _standard) public onlyOwner {
        P_Config.standard = _standard;
    }

    function set_fee(uint8 _fee) public onlyOwner {
        P_Config.fee = _fee;
    }

    function set_project_owner(address _addr) public onlyOwner {
        require(_addr != address(0));
        project_owner = _addr;
    }

    function set_all(uint256 _s, uint256 _e, uint256 _total, uint256 _standard, uint8 _fee, address _addr)public onlyOwner {
        require(_e > _s);
        require(_addr != address(0));
        P_Config.startTime = _s;
        P_Config.endTime = _e;
        P_Config.total = _total;
        P_Config.standard = _standard;
        P_Config.fee = _fee;
        project_owner = _addr;
    }


}