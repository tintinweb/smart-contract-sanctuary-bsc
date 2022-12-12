/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address from_, address to_, uint256 amount_) external;
}

/**
 * ERC20 token for staking rewards
 * @author https://github.com/JediFaust
 */
contract ERC20Reward {
    address owner;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    event Transfer(address indexed from, address to, uint256 amount);
    event Approval(address indexed owner, address indexed to, uint256 amount);

    constructor(
        string memory name_,
        string memory symbol_
    ) {
        owner = msg.sender;
        _name = name_;
        _symbol = symbol_;
    }


    modifier onlyOwner() {
        require(msg.sender == owner, "Owner only");
        _;
    }


    function name() external view returns(string memory) {
        return _name;
    }

    function symbol() external view returns(string memory) {
        return _symbol;
    }

    function decimals() external pure returns(uint8) {
        return 18;
    }

    function totalSupply() external view returns(uint256) {
        return _totalSupply;
    }

    function balanceOf(address of_) external view returns(uint256) {
        return balances[of_];
    }


    function transfer(address to_, uint256 amount_)
        external returns(bool)
    {
        _transfer(msg.sender, to_, amount_);

        return true;
    }

    function transferFrom(address from_, address to_, uint256 amount_)
        external returns(bool)
    {
        if(msg.sender != from_) {
            require(allowances[from_][msg.sender] >= amount_, "Not allowed amount");
            allowances[from_][msg.sender] -= amount_;
        }

        _transfer(from_, to_, amount_);

        return true;
    }

    function _transfer(address from_, address to_, uint256 amount_) internal {
        require(from_ != address(0) && to_ != address(0), "Can't be zero address");
        require(balances[from_] >= amount_, "Not enough balance");

        balances[from_] -= amount_;
        balances[to_] += amount_;

        emit Transfer(from_, to_, amount_);
    }
    

    function approve(address to_, uint256 amount_) external returns(bool) {
        require(balances[msg.sender] >= amount_, "Not enough balance");

        allowances[msg.sender][to_] = amount_;

        emit Approval(msg.sender, to_, amount_);

        return true;
    }

    function allowance(address owner_, address spender_) external view returns(uint256) {
        return allowances[owner_][spender_];
    }


    function burn(uint256 amount_) external returns(bool) {
        require(balances[msg.sender] >= amount_, "Not enough balance");

        balances[msg.sender] -= amount_;
        _totalSupply -= amount_;

        emit Transfer(msg.sender, address(0), amount_);

        return true;
    }


    function mint(address to_, uint256 amount_) external onlyOwner {
        _mint(to_, amount_);
    }
    
    function _mint(address to_, uint256 amount_) internal {
        require(to_ != address(0), "Mint to zero address!");
        
        balances[to_] += amount_;
        _totalSupply += amount_;

        emit Transfer(address(0), to_, amount_);
    }
}


/**
 * Staking contract with self reward token 
 * @author https://github.com/JediFaust
 */
contract StakingTC {
    IERC20 token;
    ERC20Reward rewardToken;
    uint256 immutable minLockTime;
    uint256 immutable rewardPercent;
    uint256 immutable rewardRate;

    struct Staker {
        uint256 amount;
        uint256 unlockTime;
        uint256 claimedTime;
    }

    mapping(address => Staker) private _stakers;

    /**
     * @param rewardPercent_ should be set with decimals 1
     * for example 1% is 10 and 0.1 percent is 1
     * @param initRewardSupply_ amount of reward tokens
     * that will be minted to the deployer
     */
    constructor(
        address token_,
        uint256 minLockTime_,
        uint256 rewardPercent_,
        uint256 rewardRate_,
        uint256 initRewardSupply_,
        string memory rewardTokenName_,
        string memory rewardTokenSymbol_) {
            token = IERC20(token_);
            rewardToken = new ERC20Reward(rewardTokenName_, rewardTokenSymbol_);
            rewardToken.mint(msg.sender, initRewardSupply_);
            
            minLockTime = minLockTime_;
            rewardPercent = rewardPercent_;
            rewardRate = rewardRate_;
        }

    /**
     * @dev Supportive getters
     */
    function rewardTokenAddr() external view returns(address) {
        return address(rewardToken);
    }

    function stakeTokenAddr() external view returns(address) {
        return address(token);
    }

    function lockTime() external view returns(uint256) {
        return minLockTime;
    }

    function rewardPercentage() external view returns(uint256) {
        return rewardPercent;
    }

    function rewardRateSeconds() external view returns(uint256) {
        return rewardRate;
    }
    
    /**
     * Staking function
     * @notice ERC20 tokens to stake should be
     * approved to the contract before staking
     * @param amount_ Amount of ERC20 tokens to stake
     */
    function stake(uint256 amount_) external {
        require(amount_ > 0, 'Staking: Zero amount to stake!');

        Staker storage s = _stakers[msg.sender];
        require(s.amount == 0, 'Staking: Already staked!');

        s.amount = amount_;
        s.claimedTime = block.timestamp;
        s.unlockTime = block.timestamp + minLockTime;
    }

    /**
     * Claim reward function
     * @notice rewardRate should passed from the last claim time
     */
    function claim() public {
        Staker storage s = _stakers[msg.sender];
        require(s.amount > 0, 'Staking: Not staked!');
        require(s.claimedTime + rewardRate <= block.timestamp,
            'Staking: Zero reward!');
        
        _claim(msg.sender);
    }

    /**
     * Claim reward internal function
     * @dev mints reward amount to the staker
     * @notice reward should not be zero
     */
    function _claim(address to_) internal {
        Staker storage s = _stakers[to_];
            uint reward =
                ((s.claimedTime - block.timestamp)
                * (s.amount * rewardPercent) / 1000
                ) / rewardRate;
            
            if(reward > 0) {
                rewardToken.mint(to_, reward);
                s.claimedTime = block.timestamp;
            }
    }

    /**
     * Unstake function
     * @notice minLockTime should passed
     * @dev claims reward if above zero
     */
    function unstake() external {
        Staker storage s = _stakers[msg.sender];
        require(s.unlockTime <= block.timestamp, 'Staking: Lock time not expired');

        if(s.claimedTime + rewardRate >= block.timestamp) {
            _claim(msg.sender);
        }

        require(s.amount > 0, 'Staking: Not staked!');
        token.transferFrom(address(this), msg.sender, s.amount);
        s.amount = 0;
    }
}