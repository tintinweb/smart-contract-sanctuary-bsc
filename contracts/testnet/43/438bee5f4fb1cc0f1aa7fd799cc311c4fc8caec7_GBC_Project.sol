/**
 *Submitted for verification at BscScan.com on 2022-09-20
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
    address public web_addr = 0xF966b84a37F9b64Ea588547C40dE23cb62eFa943;// 平台地址
    uint256 public decimals = 18;

    struct ProjectConfig {
        uint256 startTime;
        uint256 endTime;
        uint256 total;//目標金額(單位wei)
        uint256 standard;//達標金額(單位wei)
        uint256 sponsors;//贊助人數
        uint8 fee;//手續費(%)
        uint256 _amount;//已募資的金額(單位wei)
    }

    ProjectConfig public P_Config;

    mapping (address => uint256) public user_invest;//投資金額
    mapping (uint256 => address) public sponsors_list;//投資人清單

    constructor (address _addr)  public {
        contract_owner = msg.sender; 
        project_owner = _addr;//提案人 
        USDT = ERC20(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684); // 測試鏈USDT

        P_Config.startTime = 1663516800;//2022-09-19 00:00
        P_Config.endTime = 1664553600;//2022-10-01 00:00
        P_Config.total = 150*1*10**decimals;// 150 USDT
        P_Config.standard = 20*1*10**decimals;// 20 USDT
        P_Config.sponsors = 0;
        P_Config.fee = 0;
        P_Config._amount = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == contract_owner);
        _;
    }

    function invest(uint256 usdt_num) public returns (bool) {
        uint256 USDT_B = USDT.balanceOf(msg.sender);
        uint256 allowance = USDT.allowance(msg.sender, address(this));
        require(allowance >= usdt_num, "Check the USDT allowance.");
        require(USDT_B >= usdt_num,"Check your USDT balance.");

        require(P_Config.startTime <= block.timestamp && block.timestamp <= P_Config.endTime,"Out of time.");
        require(usdt_num > 0);

        USDT.transferFrom(msg.sender, address(this), usdt_num*1*10**decimals);// USDT 扣款
        user_invest[msg.sender] = user_invest[msg.sender].add(usdt_num*1*10**decimals);
        sponsors_list[P_Config.sponsors] = msg.sender;// 投資人清單
        P_Config._amount = P_Config._amount.add(usdt_num*1*10**decimals);// 募資金額++
        P_Config.sponsors = P_Config.sponsors.add(1);// 投資人數+1

        return true;
    }

    // 提取USDT (合約擁有者)
    function withdraw() public onlyOwner{
        require(block.timestamp > P_Config.endTime,"Out of time.");
        require(project_owner!=address(0),"Address Error.");
        address contract_addr = address(this);
        uint256 contract_balance = USDT.balanceOf(contract_addr);

        if(P_Config._amount >= P_Config.standard)//已達低標
        {
            if(P_Config.fee >0 )
            {
                uint256 new_b = (contract_balance*P_Config.fee)/100;// 給專案發起人
                uint256 new_fee = contract_balance.sub(new_b); // 給平台

                USDT.transfer(project_owner, new_b);
                USDT.transfer(web_addr, new_fee);
            }
            else
            {
                USDT.transfer(project_owner, contract_balance);
            }
        }
        else
        {
            // 未達標 , 將募資金額退回
            for(uint i = 0; i < P_Config.sponsors; i++) 
            {
                address _user = sponsors_list[i];
                uint256 invest_amount = user_invest[_user];//取得投資金額

                if(invest_amount >0)
                {
                    USDT.transfer(_user, invest_amount);// 退回投資金額
                    user_invest[_user] = 0; //投資金額歸零
                }
            }
        }
    }

    // 提取USDT (合約擁有者) - 未達低標 , 單筆退回
    function withdraw_one(uint256 _num) public onlyOwner{
        require(block.timestamp > P_Config.endTime,"Out of time.");
        require(project_owner!=address(0),"Address Error.");
        address contract_addr = address(this);
        uint256 contract_balance = USDT.balanceOf(contract_addr);

        if(P_Config._amount < P_Config.standard)//未達低標
        {
            address _user = sponsors_list[_num];
            uint256 invest_amount = user_invest[_user];//取得投資金額

            if(invest_amount >0)
            {
                USDT.transfer(_user, invest_amount);// 退回投資金額
                user_invest[_user] = 0; //投資金額歸零
            }
        }

    }
    // 募資時間
    function set_time(uint256 _s, uint256 _e) public onlyOwner {
        require(_e > _s);
        P_Config.startTime = _s;
        P_Config.endTime = _e;
    }
    // 目標金額(單位wei)
    function set_total(uint256 _total) public onlyOwner {
        P_Config.total = _total;
    }
    // 募資低標(單位wei)
    function set_standard(uint256 _standard) public onlyOwner {
        P_Config.standard = _standard;
    }
    // 手續費(%)
    function set_fee(uint8 _fee) public onlyOwner {
        P_Config.fee = _fee;
    }


}