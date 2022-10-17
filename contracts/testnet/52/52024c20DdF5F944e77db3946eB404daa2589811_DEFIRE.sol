//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract DEFIRE {
    address public Admin;
    address public treasury_wallet;
    IBEP20 public token;

    uint256 public constant Percent_Divider = 100_000; //divider for percentage

    uint256 public MAX_LEVEL = 12; //maximam number of levels
    uint256 public MAX_Profit_Bonus = 300_000; //percentage of profit
    uint256 public MAX_Profit_Regular = 200_000; //percentage of profit
    uint256 public min_duration = 30 days; //minimum duration to Claim
    uint256 public max_duration = 360 days; //maximum duration to Claim
    uint256 public fee_percent = 40_000; //percentage of fee
    uint256 public cashback_percent = 20_000; //percentage of cashback
    uint256 public level_percent = 80_000; //percentage of level
    uint256 public personal_refral_percent = 10_000; //percentage of personal refral
    uint256 public total_invested; //total invested
    uint256 public total_withdrawn; //total withdrawn
    uint256 public total_referral_bonus; //total referral bonus

    uint256 public nonce = 1; //nonce for Users ids;for each tire requirement
    uint256 public registration_fee = 10 ether; //registration fee
    uint256[10] public uni_level_requirements = [0, 0, 1, 1, 2, 2, 3, 3, 4, 4]; //minimum requirements for each level
    uint256[10] public uni_level_bonus = [
        10,
        10,
        10,
        10,
        10,
        10,
        10,
        10,
        10,
        10
    ]; //percentage of bonus for each level
    uint256[7] public rank_requirements = [
        0,
        25_000 ether,
        50_000 ether,
        100_000 ether,
        200_000 ether,
        300_000 ether,
        500_000 ether
    ]; //minimum requirements for each rank

    uint256 public price = 100 ether; //price of level
    // uint256 regular_profit;
    // uint256 bonus_profit;
    // uint256 token_per_duration_regular;
    // uint256 token_per_duration_bonus;

    struct deposit {
        uint256 amount;
        uint256 withdrawn;
        uint256 max_withdraw;
        bool complete;
    }
    struct accountinfo {
        deposit[] depositdata;
        address[] directs;
        bool registerd;
        uint256 id;
        address owner;
        uint256 total_invested;
        uint256 total_withdrawn;
        uint256 total_referral_bonus;
        rank current_rank;
    }
    enum rank {
        None,
        Bronze,
        Silver,
        Gold,
        Ruby,
        Emerald,
        Diamond
    }
    mapping(address => accountinfo) public accounts;
    mapping(uint256 => address) public id_to_address;

    constructor() {
        Admin = msg.sender;
        token = IBEP20(0xfCacB1e616F0Aa55378a68fb3A815444CFF9f9fc);
        accounts[Admin].registerd = true;
        accounts[Admin].id = nonce;
        accounts[Admin].owner = Admin;
        nonce++;
    }

    function register(address ref) public returns (bool) {
        require(accounts[ref].registerd == true, "Invalid Referral");
        require(accounts[msg.sender].registerd == false, "Already registerd");
        accounts[msg.sender].registerd = true;
        accounts[msg.sender].id = nonce;
        accounts[msg.sender].owner = msg.sender;
        accounts[ref].directs.push(msg.sender);
        nonce++;
        return true;
    }

    function buy_level(address[] memory upline) public {
        require(upline.length <= 10);
        require(accounts[msg.sender].registerd == true, "Not registerd");
        token.transferFrom(msg.sender, address(this), price);
        for (uint256 i = 0; i < upline.length; i++) {
            if (
                accounts[upline[i]].directs.length >=
                uni_level_requirements[i] ||
                upline[i] == Admin
            ) {
                if (
                    accounts[upline[i]].depositdata.length > 0 ||
                    upline[i] == Admin
                ) {
                    if (
                        accounts[upline[i]]
                            .depositdata[
                                accounts[upline[i]].depositdata.length - 1
                            ]
                            .complete == false
                    ) {
                        uint256 withdrawable = (price * uni_level_bonus[i]) /
                            Percent_Divider;
                        uint256 remaining = accounts[upline[i]]
                            .depositdata[
                                accounts[upline[i]].depositdata.length - 1
                            ]
                            .max_withdraw -
                            accounts[upline[i]]
                                .depositdata[
                                    accounts[upline[i]].depositdata.length - 1
                                ]
                                .withdrawn;
                        if (withdrawable >= remaining) {
                            withdrawable = remaining;
                            accounts[upline[i]]
                                .depositdata[
                                    accounts[upline[i]].depositdata.length - 1
                                ]
                                .complete = true;
                        }
                        accounts[upline[i]]
                            .depositdata[
                                accounts[upline[i]].depositdata.length - 1
                            ]
                            .withdrawn += withdrawable;
                        token.transfer(upline[i], withdrawable);
                        total_withdrawn += withdrawable;
                        accounts[upline[i]].total_withdrawn += withdrawable;
                        total_referral_bonus += withdrawable;
                        accounts[upline[i]]
                            .total_referral_bonus += withdrawable;
                    }
                }
            }
        }
        if (accounts[msg.sender].depositdata.length > 0) {
            require(
                accounts[msg.sender]
                    .depositdata[accounts[msg.sender].depositdata.length - 1]
                    .complete == true,
                "Previous deposit not complete"
            );
        }
        accounts[msg.sender].depositdata.push(
            deposit(
                price,
                0,
                (price * MAX_Profit_Bonus) / Percent_Divider,
                false
            )
        );
        total_invested += price;
        accounts[msg.sender].total_invested += price;

        for (uint256 i = 0; i < rank_requirements.length; i++) {
            if (accounts[msg.sender].total_invested >= rank_requirements[i]) {
                accounts[msg.sender].current_rank = rank(i);
            }
        }
    }
}