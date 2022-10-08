//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

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
    address  public  Admin;
    address  public  treasury_wallet;
    IBEP20 public  token;
    

    // uint256 public constant Percent_Divider = 100_000; //divider for percentage

    // uint256 public MAX_LEVEL = 12; //maximam number of levels
    // uint256 public MAX_Profit_Bonus = 300_000; //percentage of profit
    // uint256 public MAX_Profit_Regular = 200_000; //percentage of profit
    // uint256 public min_duration = 30 days; //minimum duration to Claim
    // uint256 public max_duration = 360 days; //maximum duration to Claim
    // uint256 public fee_percent = 40_000; //percentage of fee
    // uint256 public cashback_percent = 20_000; //percentage of cashback
    // uint256 public level_percent = 80_000; //percentage of level
    // uint256 public personal_refral_percent = 10_000; //percentage of personal refral
    


    uint256 public nonce = 1; //nonce for Users ids;for each tire requirement
    uint256 public registration_fee = 10 ether; //registration fee
    // uint256 [10] public uni_level_requirements = [0,0,1,1,2,2,3,3,4,4]; //minimum requirements for each level

    // enum Tire {
    //     Bronze,
    //     Silver,
    //     Gold,
    //     Ruby,
    //     Emarald,
    //     Diamond
    // }

    // struct level_data{
    //     uint256 price;
    //     uint256 after_price;
    //     uint256 regular_profit;
    //     uint256 bonus_profit;
    //     uint256 token_per_duration_regular;
    //     uint256 token_per_duration_bonus;
    // }


    struct accountinfo {
        bool registerd;
        uint256 id;
        address owner;
    }

    mapping(address => accountinfo) public accounts;

    constructor() {
        Admin = msg.sender;
        token = IBEP20(0xfCacB1e616F0Aa55378a68fb3A815444CFF9f9fc);
        accounts[Admin].registerd = true;
        accounts[Admin].id = nonce;
        accounts[Admin].owner = Admin;
        nonce++;
    }

    function register()public returns(bool){
        require(accounts[msg.sender].registerd == false, "Already registerd");
        // token.transferFrom(msg.sender, address(this), registration_fee);
        accounts[msg.sender].registerd = true;
        accounts[msg.sender].id = nonce;
        accounts[msg.sender].owner = msg.sender;
        nonce++;
        return true;
    }

    // function buy_level(address ref,uint256 level) public  {
    //     require(level <= MAX_LEVEL,"Level is greater than maximum level");
    //     require(level > 0,"Level is less than 1");
    //     require(ref != address(0) && ref != msg.sender,"Invalid address");
    //     require(msg.value >= level_details[level].price,"Insufficient amount");
    //     treasury_wallet.transfer(level_details[level].price - level_details[level].after_price);

    //     if(user_details[msg.sender].sponser[level] == address(0)) {
    //         user_details[msg.sender].sponser[level] = ref;
    //     }

    // }
    // function distribute_amount(uint256 amount)internal{
    //     require(amount > 0,"Amount is less than 1");

    // }
    // function update_medal(address user) internal {
    //     require(user != address(0),"User is not valid");
    // }
    // function update_withdraw_trigger(address user) internal {
    //     require(user != address(0),"User is not valid");
    // }
    // function update_tree_indexing(address user) internal {
    //     require(user != address(0),"User is not valid");
    // }
    // function withdraw_rewards(uint256 level) public {
    //     require(level > 0 && level <= MAX_LEVEL,"invalid level");
    //     require(user_details[msg.sender].active_cycle[level],"Cycle is not active");
    //     require(!user_details[msg.sender].completed_cycle[level],"Cycle is already completed");
    //     require(user_details[msg.sender].claimable_reward[level] > 0,"No rewards to claim");
    //     require(user_details[msg.sender].last_claim_time[level] + min_duration < block.timestamp ,"Minimum duration not met");

    // }

}