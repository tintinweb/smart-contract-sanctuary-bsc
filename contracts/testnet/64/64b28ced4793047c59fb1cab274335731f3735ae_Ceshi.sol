/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

//SPDX-License-Identifier: SimPL-2.0
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
    function transfer(address recipient, uint256 amount) external;

    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;

    function decimals() external view returns (uint8);
}

contract Ceshi {
    using SafeMath for uint;
    
    address payable public corporation_admin; //管理员 公司
    address payable public fund_admin; //基金
    uint256 public max_boss_num; //最大boss数量
    uint256 public max_captain_num; //最大队长数量
    uint256 public max_member_num; //最大队员数量
    uint256 public total_boss_num; //总boss数量
    uint256 public total_captain_num; //总队长数量
    uint256 public total_member_num; //总队员数量

    struct User {
        uint256 amount; //金额
        uint256 level; //等级
        address referrer; //推荐人
        uint256 checkpoint; //上次入金时间
        uint256 referrer_bonus; //推荐奖金
        uint256 total_referrer_number; //推荐人数
    }

    mapping(address => User) public users;

    IERC20 USDT;

    constructor(
        address payable _corporation_admin,
        address payable _fund_admin,
        IERC20 _USDT
    ) public {
        corporation_admin = _corporation_admin;
        fund_admin = _fund_admin;
        USDT = _USDT;
        max_boss_num = 19;
        max_captain_num = 81;
        max_member_num = 10000;
        total_boss_num = 0;
        total_captain_num = 0;
        total_member_num = 0;
    }

    function joinIn(uint256 amount, address referrer) external {
        require(
            amount == 1000 || amount == 3000 || amount == 5000,
            "amount error"
        ); //数量错误
        if (amount == 1000) {
            require(total_member_num < max_member_num, "member full");
        }
        if (amount == 3000) {
            require(total_captain_num < max_captain_num, "captain full");
        }
        if (amount == 5000) {
            require(total_boss_num < max_boss_num, "boss full");
        }
        USDT.transferFrom(msg.sender, address(this), amount);
        User storage user = users[msg.sender];
        if (
            user.referrer == address(0) &&
            (users[referrer].amount > 0 || referrer == corporation_admin) &&
            referrer != msg.sender
        ) {
            user.referrer = referrer; //设置上级
            user.amount = amount;
            USDT.transfer(corporation_admin, amount.mul(30).div(100));
            USDT.transfer(fund_admin, amount.mul(20).div(100));
        }

    }

}