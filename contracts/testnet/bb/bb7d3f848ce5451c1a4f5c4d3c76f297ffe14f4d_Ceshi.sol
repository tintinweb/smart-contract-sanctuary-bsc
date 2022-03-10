/**
 *Submitted for verification at BscScan.com on 2022-03-10
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
    function transfer(address recipient, uint amount) external;
    function balanceOf(address account) external view returns (uint);
    function transferFrom(address sender, address recipient, uint amount) external ;
    function decimals() external view returns (uint8);
}


contract Ceshi {
    using SafeMath for uint;

    uint constant public GRAND_FUND_PROJECT_FEE = 2;
    uint constant public DEVELOPMENT_FUND_PROJECT_FEE = 2;
    uint constant public TEAM_FUND_PROJECT_FEE = 1;
    uint constant public PERCENTS_DIVIDER = 100; //百分比
    uint[6] public miner_manager_level = [1, 2, 3, 4, 5, 6];
    uint[6] public investment_quantity = [300, 600, 900, 1800, 2700, 5400];
    uint[6] public mine_reserves = [1500, 3000, 4500, 9000, 13500, 27000];
    string[6] public miner_manager_name = ['Blue-collar Miner','White-collar Miner','Middle-class Miner','Little-rich Miner','Jet-setting Miner','Super-rich Miner'];
    uint[30] public referrer_bonuses_ = [50, 5, 5, 5, 5, 5, 5, 5, 5, 5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3];

    address payable public admin;
    address public grand_fund;
    address public development_fund;
    address public team_fund;

    struct User {
        uint amount;
        uint miner_manager_level;//矿主等级
        address referrer;//推荐人
        uint mine_reserves;//矿场储量
        uint total_referrer_number; //推荐人数
    }

    mapping (address => User) public users;

    IERC20 usdt;
    constructor(address payable _admin, address payable _grand_fund, address payable _development_fund, address payable _team_fund, IERC20 _usdt) public {
        require(!isContract(_admin));
        admin = _admin;
        grand_fund = _grand_fund;
        development_fund = _development_fund;
        team_fund = _team_fund;
        usdt = _usdt;
    }

    function  transferIn(uint amount) external {
        usdt.transferFrom(msg.sender, address(this), amount);
        User storage user = users[msg.sender];
        user.amount = amount;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}