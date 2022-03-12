/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

pragma solidity ^0.5.10;

library SafeMath {

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }

    function mul(uint a, uint b) internal pure returns (uint) {

        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }

    function mod(uint a, uint b) internal pure returns (uint) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    //查询授权数量
    function allowance(address tokenOwner, address spender)  external returns (uint remaining);
    //转账
    function transfer(address to, uint amount) external  returns (bool success);
    //授权
    function approve(address spender, uint256 tokens) external returns (bool success);
    //授权转账
    function transferFrom(address from, address to, uint amount) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed tokenOwner, address indexed spender, uint amount);
}


contract Ceshi {
    using SafeMath for uint;
    using SafeMath for uint256;

    address payable public corporation_admin; //管理员 公司
    address payable public fund_admin; //基金
    uint256 public max_boss_num; //最大boss数量
    uint256 public max_captain_num; //最大队长数量
    uint256 public max_driver_num; //最大队员数量
    uint256 public total_boss_num; //总boss数量
    uint256 public total_captain_num; //总队长数量
    uint256 public total_driver_num; //总队员数量
    uint256 accuracy = 1e6; //精度
    uint256[3] public allowable_amount = [1000 * accuracy, 3000 * accuracy, 5000 * accuracy];
    string[3] public level_name = ['driver', 'captain', 'boss'];

    struct User {
        uint256 amount; //金额
        uint256 level; //等级
        address referrer; //推荐人
        uint256 checkpoint; //上次入金时间
        uint256 referrer_bonus; //推荐奖金
        uint256 total_referrer_number; //推荐人数
        uint256 relationship_level;
        address relationship_address;
    }

    mapping (address => User) public users;

    IERC20 USDT;

    constructor(address payable _corporation_admin, address payable _fund_admin, IERC20 _USDT,uint _max_boss_num, uint _max_captain_num, uint _max_driver_num) public {
        require(!isContract(_corporation_admin));
        corporation_admin = _corporation_admin;
        fund_admin = _fund_admin;
        USDT = _USDT;
        max_boss_num = _max_boss_num;
        max_captain_num = _max_captain_num;
        max_driver_num = _max_driver_num;
        total_boss_num = 0;
        total_captain_num = 0;
        total_driver_num = 0;
    }

    function  joinIn(uint amount, address referrer) external {
        require( amount == allowable_amount[0] || amount == allowable_amount[1] || amount == allowable_amount[2], "amount error" ); //数量错误
        User storage user = users[msg.sender];
        require(user.amount == 0, "joinIn repeat");
        if (amount == allowable_amount[0]) {
            require(total_driver_num < max_driver_num, "driver full");
            max_driver_num = max_driver_num.add(1);
            user.level = 1;
        }
        if (amount == allowable_amount[1]) {
            require(total_captain_num < max_captain_num, "captain full");
            total_captain_num = total_captain_num.add(1);
            user.level = 2;
        }
        if (amount == allowable_amount[2]) {
            require(total_boss_num < max_boss_num, "boss full");
            total_boss_num = total_boss_num.add(1);
            user.level = 3;
        }
        if(user.referrer == address(0) && (users[referrer].amount > 0 || referrer == corporation_admin) && referrer != msg.sender){
            USDT.transferFrom(msg.sender, address(this), amount);
            user.referrer = referrer;
            user.amount = amount;
            if(user.level == users[referrer].level && users[referrer].relationship_level != 0){
                user.relationship_level = users[referrer].relationship_level;
                user.relationship_address = users[referrer].relationship_address;
            }else if(user.level < users[referrer].level){
                user.relationship_level = users[referrer].level;
                user.relationship_address = referrer;
            }
            uint ratio = level_ratio(users[referrer].level);
            USDT.transfer(referrer, amount.mul(ratio).div(100));
            if(users[referrer].level != 3 && users[referrer].relationship_level != 0){
                share_bonus(referrer,amount,ratio);
            }
            USDT.transfer(corporation_admin, amount.mul(30).div(100));
            USDT.transfer(fund_admin, amount.mul(20).div(100));
        }
    }

    function share_bonus(address _referrer, uint _amount, uint _issued) internal {
        uint ratio = level_ratio(users[_referrer].relationship_level);
        if(ratio > _issued){
            uint usable_ratio = ratio.sub(_issued);
            USDT.transfer(users[_referrer].relationship_address, _amount.mul(usable_ratio).div(100));
            uint issued = _issued.add(usable_ratio);
            if(issued < 50 && users[users[_referrer].relationship_address].level != 0){
                share_bonus(users[_referrer].relationship_address,_amount,issued);
            }
        }
    }

    function level_ratio(uint _level) public pure returns (uint) {
        uint ratio = 0;
        if(_level == 1){
            ratio = 20;
        }else if(_level == 2){
            ratio = 30;
        }else if(_level == 3){
            ratio = 50;
        }
        return ratio;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function add_boss_num(uint256 _add_quantity) external{
        require(corporation_admin==msg.sender, 'Admin what?');
        max_boss_num = max_boss_num.add(_add_quantity);
    }

    function add_captain_num(uint256 _add_quantity) external{
        require(corporation_admin==msg.sender, 'Admin what?');
        max_captain_num = max_captain_num.add(_add_quantity);
    }

    function add_driver_num(uint256 _add_quantity) external{
        require(corporation_admin==msg.sender, 'Admin what?');
        max_driver_num = max_driver_num.add(_add_quantity);
    }
   
}