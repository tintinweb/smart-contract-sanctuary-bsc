/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

//SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.12;

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

    constructor(
        address payable _corporation_admin
    ) {
        corporation_admin = _corporation_admin;
    }

    function joinIn(uint256 amount, address referrer) external {
        payable(referrer).transfer(amount*20/100);
        payable(corporation_admin).transfer(amount*30/100);
    }

    
}