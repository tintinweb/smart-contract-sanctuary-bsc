pragma solidity ^0.8.9;

// SPDX-License-Identifier: MIT
//  _______  __    __  ______  _______         ______    __              __                         
// |       \|  \  |  \/      \|       \       /      \  |  \            |  \                        
// | $$$$$$$| $$  | $|  $$$$$$| $$$$$$$\     |  $$$$$$\_| $$_    ______ | $$   __  ______   ______  
// | $$__/ $| $$  | $| $$___\$| $$  | $$_____| $$___\$|   $$ \  |      \| $$  /  \/      \ /      \ 
// | $$    $| $$  | $$\$$    \| $$  | $|      \$$    \ \$$$$$$   \$$$$$$| $$_/  $|  $$$$$$|  $$$$$$\
// | $$$$$$$| $$  | $$_\$$$$$$| $$  | $$\$$$$$_\$$$$$$\ | $$ __ /      $| $$   $$| $$    $| $$   \$$
// | $$__/ $| $$__/ $|  \__| $| $$__/ $$     |  \__| $$ | $$|  |  $$$$$$| $$$$$$\| $$$$$$$| $$      
// | $$    $$\$$    $$\$$    $| $$    $$      \$$    $$  \$$  $$\$$    $| $$  \$$\\$$     | $$      
//  \$$$$$$$  \$$$$$$  \$$$$$$ \$$$$$$$        \$$$$$$    \$$$$  \$$$$$$$\$$   \$$ \$$$$$$$\$$      
                                                                                                 
                                                                                                 
                                                                                                 
contract BUSDSTAKER {
    //constant
    uint256 public constant percent_divider = 100_000;

    //address
    token public BUSD = token(0x1933CAFbc5a1840355DBd9967a3e97FF36f14370);
    address payable public admin;
    address payable public project_fee_address;
    address payable public dev_fee_address;

    //uint256
    uint256 public stake_percent = 180_000;
    uint256 public stake_period = 30 minutes;
    uint256 public max_stake = 200_000_000 * (10**BUSD.decimals());
    uint256 public min_stake = 10 * (10**BUSD.decimals());
    uint256 public total_staked;
    uint256 public time_step = 1 seconds;
    uint256 public total_level = 3;
    uint256 public tax = 10_000;
    uint256 [3] public  refral_percentage = [7_000, 3_000, 2_000];
    uint256 public project_fee_percentage = 10_000;
    uint256 public dev_fee_percentage = 5_000;
    uint256 public total_fee_percentage = 26_000;

    //struct
    struct Staker {
        uint256 amount;
        uint256 claimed;
        uint256 claimable;
        uint256 max_claimable;
        uint256 token_per_time_step;
        uint256 last_claim_time;
        uint256 unstake_time;
        uint256 stake_time;
        

    }

    //map
    mapping(address => Staker) public plan;
    mapping(address => mapping(address  => mapping(uint256 => bool)))  referral_exists;

    mapping(address => address) private reffral;
    mapping(address => uint256) public reffral_rewards;
    mapping(address => mapping(uint256 => uint256))public levelrewards;
    mapping(address => mapping(uint256 => uint256))public levelstakers;
    mapping(address => mapping(uint256 => uint256))public levelusers;


    //modifier
    modifier onlyadmin() {
        require(msg.sender == admin, "Stake: Not an admin");
        _;
    }

    //constructor
    constructor() {
        admin = payable(msg.sender);
        dev_fee_address = payable(msg.sender);
        project_fee_address = payable(msg.sender);

    }

    function deposit(address ref, uint256 _amount)
        public
    {
        require(
            plan[msg.sender].amount + _amount <= max_stake,
            "max_stake limit reached"
        );
        require(_amount >= min_stake, "Deposit more than minimum limit");
        BUSD.transferFrom(msg.sender, address(this), _amount);
        BUSD.transfer(project_fee_address, _amount*project_fee_percentage/percent_divider);
        BUSD.transfer(dev_fee_address, _amount*dev_fee_percentage/percent_divider);

        total_staked = total_staked + (_amount);
        
        uint256  totaltax = (_amount *total_fee_percentage/percent_divider);
        uint256 stakeamount = _amount - totaltax;

        if(ref != address(0) && ref!= msg.sender) {
            setref(msg.sender, ref);
        }else{
            setref(msg.sender, admin);
        }

        setrefralrewards(msg.sender,stakeamount);
        
        updaterecord(msg.sender, stakeamount);

        plan[msg.sender].last_claim_time = block.timestamp;

        plan[msg.sender].stake_time = block.timestamp;
        plan[msg.sender].unstake_time = block.timestamp + (stake_period);
        plan[msg.sender].claimed = 0;
    }

    function updaterecord(address user, uint256 _amount) internal {
        plan[user].claimable = calculaterewards(user);
        plan[user].amount = plan[user].amount + (_amount);
        uint256 _stake_percent = getpercent();
        plan[user].max_claimable =
            ((plan[user].amount * (_stake_percent)) / (percent_divider)) +
            plan[user].claimable;

        plan[user].token_per_time_step = (
            calculatepertimesetp(
                plan[user].max_claimable - plan[user].claimable,
                stake_period
            )
        );
    }


    function setrefralrewards(address user, uint256 _amount)internal{
        for(uint256 i = 0; i < total_level; i++) {
            if(getrefral(user) != address(0) && user != address(0)) {
                if(!referral_exists[user][getrefral(user)][i]){
                    referral_exists[user][getrefral(user)][i] = true;
                    levelusers[getrefral(user)][i+1]++;
                    }
                user = getrefral(user);
                reffral_rewards[user] = reffral_rewards[user] + (_amount * refral_percentage[i]/percent_divider);
                levelrewards[user][i+1] = levelrewards[user][i+1] + (_amount * refral_percentage[i]/percent_divider);
                levelstakers[user][i+1] = levelstakers[user][i+1] + (_amount);
            }else{
                break;
            }
        }
    }
    function setref(address user, address ref)internal{
        reffral[user] = ref;
    }

    function renivest() public  {
        if (calculaterewards(msg.sender) > 0) {
            require(
                plan[msg.sender].amount + (calculaterewards(msg.sender)) <=
                    max_stake,
                "max_stake limit reached"
            );
        }

        total_staked = total_staked + (calculaterewards(msg.sender)) + reffral_rewards[msg.sender];

        if (calculaterewards(msg.sender) > 0) {
            BUSD.transfer(
                dev_fee_address,
                (((calculaterewards(msg.sender)+reffral_rewards[msg.sender]) * dev_fee_percentage) / percent_divider)
            );
        }
        require(plan[msg.sender].amount > 0, "not staked");

        plan[msg.sender].amount =
            plan[msg.sender].amount +
            ((calculaterewards(msg.sender)+reffral_rewards[msg.sender]) -
                (((calculaterewards(msg.sender)+reffral_rewards[msg.sender]) * tax) / percent_divider));
        uint256 _stake_percent = getpercent();
        plan[msg.sender].token_per_time_step = (
            calculatepertimesetp(
                ((plan[msg.sender].amount * (_stake_percent)) /
                    (percent_divider)),
                stake_period
            )
        );
        plan[msg.sender].max_claimable = ((plan[msg.sender].amount *
            (_stake_percent)) / (percent_divider));

        plan[msg.sender].last_claim_time = block.timestamp;

        plan[msg.sender].stake_time = block.timestamp;
        plan[msg.sender].unstake_time = block.timestamp + (stake_period);
        plan[msg.sender].claimable = 0;
        plan[msg.sender].claimed = 0;
        reffral_rewards[msg.sender] = 0;
    }

    function _withdraw(address _user, address reward) internal {
        require(
            plan[_user].claimed <= plan[_user].max_claimable,
            "no claimable amount available"
        );
        require(
            block.timestamp > plan[_user].last_claim_time,
            "time not reached"
        );

        if (calculaterewards(_user) > 0) {
            BUSD.transfer(
                reward,
                calculaterewards(_user) -
                    ((calculaterewards(_user) * dev_fee_percentage) / percent_divider)
            );
            BUSD.transfer(
                dev_fee_address,
                ((calculaterewards(_user) * dev_fee_percentage) / percent_divider)
            );
        }
        plan[_user].claimed = plan[_user].claimed + (calculaterewards(_user));
        plan[_user].last_claim_time = block.timestamp;
        plan[_user].claimable = 0;
    }

    function withdraw() external {
        require(plan[msg.sender].amount > 0, "not staked");
        _withdraw(msg.sender, msg.sender);
        withdrawrefrewards(msg.sender);
        if(plan[msg.sender].max_claimable == plan[msg.sender].claimed){
        delete plan[msg.sender];
        }
    }
    function withdrawrefrewards(address user) internal  {
        BUSD.transfer(user, reffral_rewards[user]);
        reffral_rewards[user] = 0;
    }

    function calculaterewards(address _sender)
        public
        view
        returns (uint256 amount)
    {
        uint256 claimable = plan[_sender].token_per_time_step *
            ((block.timestamp - (plan[_sender].last_claim_time)) / (time_step));
        claimable = claimable + plan[_sender].claimable;
        if (claimable > plan[_sender].max_claimable - (plan[_sender].claimed)) {
            claimable = plan[_sender].max_claimable - (plan[_sender].claimed);
        }
        return (claimable);
    }

    // transfer adminship
    function transferownership(address payable _newadmin) external onlyadmin {
        admin = _newadmin;
    }

    function changetax(uint256 _tax) external onlyadmin {
        require(_tax < percent_divider / 4, "Tax must be less than 25%");
        tax = _tax;
    }


    function withdrawlosttoken(address _token, uint256 _amount)
        external
        onlyadmin
    {
        token(_token).transfer(msg.sender, _amount);
    }

    function changetokenaddress(address _newAddress) external onlyadmin {
        BUSD = token(_newAddress);
    }

    function getcontracttokenbalance() public view returns (uint256) {
        return BUSD.balanceOf(address(this));
    }

    function calculatepertimesetp(uint256 amount, uint256 _VestingPeriod)
        internal
        view
        returns (uint256)
    {
        return (amount * (time_step)) / (_VestingPeriod);
    }

    function getpercent() internal view returns (uint256) {
        return (stake_percent);
    }

    function setplanpercentage(uint256 _percent) external onlyadmin {
        stake_percent = _percent;
    }

    function setminmax(uint256 _minamount, uint256 _maxamount)
        external
        onlyadmin
    {
        max_stake = _minamount;
        min_stake = _maxamount;
    }

    function updateplanvestingperiod(uint256 _VestingPeriod)
        external
        onlyadmin
    {
        stake_period = _VestingPeriod;
    }

    function getrefral(address _address) public view returns (address) {
        return reffral[_address];
    }
}

interface token {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
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