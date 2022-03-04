/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

//SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.12;

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
    uint256 public constant GRAND_FUND_PROJECT_FEE = 2;
    uint256 public constant DEVELOPMENT_FUND_PROJECT_FEE = 2;
    uint256 public constant TEAM_FUND_PROJECT_FEE = 1;
    uint256 public constant PERCENTS_DIVIDER = 100; //百分比
    uint256[3] public miner_manager_level = [1, 2, 3];
    uint256[3] public investment_quantity = [1000, 3000, 5000];
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
    ) {
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
            (users[referrer].amount > 0 || referrer == corporation_admin) &&
            referrer != msg.sender
        ) {
            user.referrer = referrer; //设置上级
            user.amount = amount;
            USDT.transfer(corporation_admin, amount*30/100);
            USDT.transfer(fund_admin, amount*20/100);
        }
    }

    //给上级支付奖励
    function ref_award(address _ref_addr, uint256 _amount, uint256 _paid) internal {
        if(users[_ref_addr].amount > 0){
            uint256 paid = 0;
            uint256 level = users[_ref_addr].level;
            if (level == 1) {
                paid == 20;
            }
            if (level == 2) {
                paid == 30;
            }
            if (level == 3) {
                paid == 50;
            }
            uint256 can_paid = paid - _paid;
            if (can_paid > 0) {
                uint256 bonus = _amount*can_paid/100;
                users[_ref_addr].referrer_bonus = users[_ref_addr].referrer_bonus + bonus;
                if (paid != 50) {
                    ref_award(users[_ref_addr].referrer, _amount, paid);
                }
            }
        }
    }
}