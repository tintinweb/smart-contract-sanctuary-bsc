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
    uint256 public claim_period = 1 minutes;
    uint256 public max_stake = 200_000_000 * (10**BUSD.decimals());
    uint256 public min_stake = 10 * (10**BUSD.decimals());
    uint256 public total_staked;
    uint256 public time_step = 1 seconds;

    uint256 public total_level = 3;
    uint256[3] public refral_percentage = [7_000, 3_000, 2_000];
    uint256 public project_fee_percentage = 10_000;
    uint256 public dev_fee_percentage = 5_000;

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
    // mapping(address => mapping(address => mapping(uint256 => bool))) referral_exists;

    mapping(address => address) private reffral;
    mapping(address => uint256) public reffral_rewards;
    mapping(address => mapping(uint256 => uint256)) public levelrewards;
    mapping(address => mapping(uint256 => uint256)) public levelstakers;
    mapping(address => mapping(uint256 => uint256)) public levelusers;
    mapping(address => bool) already_deposited;

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

    function deposit(address ref, uint256 _amount) public {
        require(
            plan[msg.sender].amount + _amount <= max_stake,
            "max_stake limit reached"
        );
        require(_amount >= min_stake, "Deposit more than minimum limit");
        BUSD.transferFrom(msg.sender, address(this), _amount);
        BUSD.transfer(
            project_fee_address,
            (_amount * project_fee_percentage) / percent_divider
        );
        BUSD.transfer(
            dev_fee_address,
            (_amount * dev_fee_percentage) / percent_divider
        );

        total_staked = total_staked + (_amount);

        if(msg.sender == admin){
		    setref(msg.sender,address(0));
		}else if (getrefral(msg.sender) == address(0)) {
		    
			if ((!already_deposited[ref] || ref == msg.sender) && msg.sender != admin) {
				setref(msg.sender, admin);
			}

			setref(msg.sender, ref);

        address upline = getrefral(msg.sender);
			for (uint256 i = 0; i < 3; i++) {
                if (upline != address(0)) {
                    levelusers[upline][i] = levelusers[upline][i] + 1;
                     
					upline = getrefral(upline);
				} else break;
            }
        }

        setrefralrewards(msg.sender, _amount);
        updaterecord(msg.sender, _amount);

        plan[msg.sender].last_claim_time = block.timestamp;

        plan[msg.sender].stake_time = block.timestamp;
        plan[msg.sender].unstake_time = block.timestamp + (stake_period);
        plan[msg.sender].claimed = 0;
        already_deposited[msg.sender] = true;
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

    function setrefralrewards(address user, uint256 _amount) internal {
        address upline = getrefral(user);
        for (uint256 i = 0; i < total_level; i++) {
            if (upline!=address(0)) {
                
                
                reffral_rewards[upline] =
                    reffral_rewards[upline] +
                    ((_amount * refral_percentage[i]) / percent_divider);
                levelrewards[upline][i + 1] =
                    levelrewards[upline][i + 1] +
                    ((_amount * refral_percentage[i]) / percent_divider);
                levelstakers[upline][i + 1] =
                    levelstakers[upline][i + 1] +
                    (_amount);

                upline = getrefral(upline);
            } else {
                break;
            }
        }
    }

    function setref(address user, address ref) internal {
        reffral[user] = ref;
    }

    function renivest() public {
        require(block.timestamp >= plan[msg.sender].last_claim_time + claim_period, "time not reached");
        if (calculaterewards(msg.sender) > 0) {
            require(
                plan[msg.sender].amount + (calculaterewards(msg.sender)) <=
                    max_stake,
                "max_stake limit reached"
            );
        }

        total_staked =
            total_staked +
            (calculaterewards(msg.sender)) +
            reffral_rewards[msg.sender];

        if (calculaterewards(msg.sender) > 0) {
            BUSD.transfer(
                dev_fee_address,
                (((calculaterewards(msg.sender) + reffral_rewards[msg.sender]) *
                    dev_fee_percentage) / percent_divider)
            );
        }
        require(plan[msg.sender].amount > 0, "not staked");

        plan[msg.sender].amount =
            plan[msg.sender].amount +
            ((calculaterewards(msg.sender) + reffral_rewards[msg.sender]));
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

    function _withdraw(address _user) internal {
        require(
            plan[_user].claimed <= plan[_user].max_claimable,
            "no claimable amount available"
        );
        require(
            block.timestamp > plan[_user].last_claim_time + claim_period,
            "time not reached"
        );
        uint256 value = calculaterewards(_user);
        if (value > BUSD.balanceOf(address(this))) {
            value = BUSD.balanceOf(address(this));
            plan[_user].claimable = calculaterewards(_user) - value;
        } else {
            plan[_user].claimed = plan[_user].claimed + (value);
            plan[_user].last_claim_time = block.timestamp;
            plan[_user].claimable = 0;
        }
        if (value > 0) {
            BUSD.transfer(_user, value);
            BUSD.transfer(
                dev_fee_address,
                ((value * dev_fee_percentage) / percent_divider)
            );
        }
    }

    function withdraw() external {
        require(plan[msg.sender].amount > 0, "not staked");
        
        if (plan[msg.sender].max_claimable == plan[msg.sender].claimed) {
            delete plan[msg.sender];
        }else{
            _withdraw(msg.sender);
        }
    }

    function withdrawrefrewards() public {
        uint256 value = reffral_rewards[msg.sender];
        if (value > BUSD.balanceOf(address(this))) {
            value = BUSD.balanceOf(address(this));
        }
        BUSD.transfer(msg.sender, value);
        reffral_rewards[msg.sender] = reffral_rewards[msg.sender] - value;
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

    function withdrawlosttoken(address _token, uint256 _amount)
        external
        onlyadmin
    {
        token(_token).transfer(msg.sender, _amount);
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