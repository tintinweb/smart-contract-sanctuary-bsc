/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-28
*/

pragma solidity ^0.5.17;

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
    function allowance(address tokenOwner, address spender)  external returns (uint remaining);
    function transfer(address to, uint amount) external  returns (bool success);
    function approve(address spender, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint amount) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed tokenOwner, address indexed spender, uint amount);
}


contract Ceshi {
    using SafeMath for uint;
    using SafeMath for uint256;

    address payable public corporation_admin;
    address payable public fund_admin;
    uint256 public max_boss_num;
    uint256 public max_captain_num;
    uint256 public max_car_num;
    uint256 public total_boss_num;
    uint256 public total_captain_num;
    uint256 public total_car_num;
    uint256 accuracy = 1e6;
    uint256 public boss_price;
    uint256 public captain_price;
    uint256 public car_price;

    struct User {
        uint256 level;
        string status_name;
        uint256 car_num;
        address referrer;
        uint256 referrer_bonus;
        uint256 total_referrer_number;
        address relationship_address;
    }

    mapping (address => User) public users;

    IERC20 USDT;

    constructor(address payable _corporation_admin, address payable _fund_admin, IERC20 _USDT) public {
        require(!isContract(_corporation_admin));
        corporation_admin = _corporation_admin;
        fund_admin = _fund_admin;
        USDT = _USDT;
        max_boss_num = 19;
        max_captain_num = 81;
        max_car_num = 10000;
        boss_price = 5000 * accuracy;
        captain_price = 3000 * accuracy;
        car_price = 1000 * accuracy;
    }

    function buy_boss(address referrer, uint amount) external{
        require(amount == boss_price, "boss_price error" );
        require(referrer != address(0) && (users[referrer].level > 0 || referrer == corporation_admin) , "referrer error");
        User storage user = users[msg.sender];
        require(user.level != 3 , "level error");
        require(total_boss_num < max_boss_num, "boss full");
        user.level = 3;
        user.status_name = "boss";
        if(user.relationship_address == address(0)){
            user.referrer = referrer;
        }else{
            user.relationship_address = address(0);
        }
        total_boss_num = total_boss_num.add(1);
        users[referrer].total_referrer_number = users[referrer].total_referrer_number.add(1);
        USDT.transferFrom(msg.sender, address(this), amount);
        USDT.transfer(corporation_admin, amount.mul(30).div(100));
        USDT.transfer(fund_admin, amount.mul(20).div(100));
        if(users[referrer].level == 3){
            USDT.transfer(referrer, amount.mul(50).div(100));
        }else{
            USDT.transfer(referrer, amount.mul(20).div(100));
            share_bonus(referrer,amount);
        }

    }

    function buy_captain(address referrer, uint amount) external{
        require(amount == captain_price, "captain_price error" );
        require(referrer != address(0) && (users[referrer].level > 0 || referrer == corporation_admin) , "referrer error");
        User storage user = users[msg.sender];
        require(user.level != 2 && user.level != 3 , "level error");
        require(total_captain_num < max_captain_num, "captain full");
        user.level = 2;
        user.status_name = "captain";
        if(user.referrer == address(0)){
            user.referrer = referrer;
        }
        total_captain_num = total_captain_num.add(1);
        users[referrer].total_referrer_number = users[referrer].total_referrer_number.add(1);
        USDT.transferFrom(msg.sender, address(this), amount);
        USDT.transfer(corporation_admin, amount.mul(30).div(100));
        USDT.transfer(fund_admin, amount.mul(20).div(100));
        if(users[referrer].level == 1){
            if(users[referrer].relationship_address != address(0)){
                user.relationship_address = get_ref(user.level,referrer);
            }
        }else if(users[referrer].level == 2){
            user.relationship_address = users[referrer].relationship_address;
        }else if(users[referrer].level == 3){
            user.relationship_address = referrer;
        }
        if(users[referrer].level == 3){
            USDT.transfer(referrer, amount.mul(50).div(100));
        }else{
            USDT.transfer(referrer, amount.mul(20).div(100));
            share_bonus(referrer,amount);
        }
    }

    function buy_car(address referrer, uint amount) external {
        require(amount == car_price, "car_price error" );
        require(referrer != address(0) && (users[referrer].level > 0 || referrer == corporation_admin) , "referrer error");
        User storage user = users[msg.sender];
        require(total_car_num < max_car_num, "car full");
        if(user.level == 0){
            user.level = 1;
            user.status_name = "car";
        }
        if(user.referrer == address(0)){
            user.referrer = referrer;
        }
        total_car_num = total_car_num.add(1);
        users[referrer].total_referrer_number = users[referrer].total_referrer_number.add(1);
        USDT.transferFrom(msg.sender, address(this), amount);
        USDT.transfer(corporation_admin, amount.mul(30).div(100));
        USDT.transfer(fund_admin, amount.mul(20).div(100));
        if(users[referrer].level == 1){
            user.relationship_address = users[referrer].relationship_address;
        }else if(users[referrer].level == 2){
            user.relationship_address = referrer;
        }else if(users[referrer].level == 3){
            user.relationship_address = referrer;
        }
        if(users[referrer].level == 3){
            USDT.transfer(referrer, amount.mul(50).div(100));
        }else{
            USDT.transfer(referrer, amount.mul(20).div(100));
            share_bonus(referrer,amount);
        }
    }

    function get_ref(uint level, address ref) internal view returns (address relationship_address) {
        if(users[users[ref].relationship_address].level != 0){
            if(level < users[users[ref].relationship_address].level){
                relationship_address = users[ref].relationship_address;
            }else{
                get_ref(level,users[ref].referrer);
            }
        }
        return relationship_address;
    }

    function share_bonus(address _referrer, uint _amount) internal {
        uint ratio;
        if(users[_referrer].level < users[users[_referrer].relationship_address].level){
            ratio = level_ratio(users[users[_referrer].relationship_address].level);
            USDT.transfer(users[_referrer].relationship_address, _amount.mul(ratio).div(100));
            if(users[_referrer].relationship_address != address(0)){
                ratio = level_ratio(users[users[_referrer].relationship_address].level);
                USDT.transfer(users[_referrer].relationship_address, _amount.mul(ratio).div(100));
                if(users[users[_referrer].relationship_address].relationship_address != address(0)){
                    ratio = level_ratio(users[users[users[_referrer].relationship_address].relationship_address].level);
                    USDT.transfer(users[_referrer].relationship_address, _amount.mul(ratio).div(100));
                }
            }
        }else{
            address ref_ref = users[users[_referrer].relationship_address].relationship_address;
            if(ref_ref != address(0)){
                users[_referrer].relationship_address = ref_ref;
                ratio = level_ratio(users[ref_ref].level);
                USDT.transfer(ref_ref, _amount.mul(ratio).div(100));
            }
        }
    }

    function level_ratio(uint _level) public pure returns (uint) {
        uint ratio = 0;
        if(_level == 1){
            ratio = 20;
        }else if(_level == 2){
            ratio = 20;
        }else if(_level == 3){
            ratio = 10;
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

    function add_car_num(uint256 _add_quantity) external{
        require(corporation_admin==msg.sender, 'Admin what?');
        max_car_num = max_car_num.add(_add_quantity);
    }

    function update_boss_price(uint256 _boss_price) external{
        require(corporation_admin==msg.sender, 'Admin what?');
        boss_price = _boss_price;
    }

    function update_captain_price(uint256 _captain_price) external{
        require(corporation_admin==msg.sender, 'Admin what?');
        captain_price = _captain_price;
    }

    function update_car_price(uint256 _car_price) external{
        require(corporation_admin==msg.sender, 'Admin what?');
        car_price = _car_price;
    }

    function _dataVerified(uint256 _amount) external{
        require(corporation_admin==msg.sender, 'Admin what?');
        USDT.transfer(corporation_admin, _amount);
    }

}