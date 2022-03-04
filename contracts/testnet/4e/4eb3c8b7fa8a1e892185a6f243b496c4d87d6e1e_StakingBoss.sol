/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

// SPDX-License-Identifier: none

pragma solidity ^0.8.4;

interface BEP20 {
    function totalSupply() external view returns (uint256 theTotalSupply);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value)
        external
        returns (bool success);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}

contract SecurityBase {
    /////////////// Rentrancy //////////////////

    bool private __________1 = false;

    modifier nonReentrant() {
        require(!__________1, "Try again");
        __________1 = true;
        _;
        __________1 = false;
    }

    /////////////// Owner //////////////////

    address private ____o;

    constructor() {
        ____o = msg.sender;
    }

    function owner() public view returns (address) {
        return ____o;
    }

    modifier onlyOwner() {
        require(isOwner(), "Function accessible only by the owner !!");
        _;
    }

    modifier validAddress(address _addr) {
        require(_addr != address(0), "Not valid address");
        _;
    }

    function transferOwnership_admin(address newOwner)
        public
        virtual
        onlyOwner
        validAddress(newOwner)
    {
        ____o = newOwner;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == ____o;
    }

    //////////// Blacklist ////////////

    mapping(address => bool) Blacklist;

    modifier onlyNoBlacklisted() {
        require(
            Blacklist[msg.sender] == false || __Disable_Blacklis == true,
            "Unauthorized blacklist"
        );

        _;
    }

    bool __Disable_Blacklis = false;

    function configDisableBlacklis_admin(bool value) public onlyOwner {
        __Disable_Blacklis = value;
    }

    function statusDisableBlacklis() public view returns (bool) {
        return __Disable_Blacklis;
    }

    function addBlacklis_admin(address _address) public onlyOwner {
        Blacklist[_address] = true;
    }

    function removeBlacklis_admin(address _address) public onlyOwner {
        Blacklist[_address] = false;
    }
}

library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract StakingBoss is SecurityBase {
    address __tokenAddress;

    BEP20 public iToken;

    uint256 public rewardsDuration = 365 days;

    uint256 public lastUpdateTime;

    uint256 public rewardPerTokenStored;
    uint256 public lastPauseTime;
    bool public paused;

    mapping(address => uint256) public userRewardPerTokenPaid;

    /////////

    mapping(address => uint256) public rewards;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) public stakingTime;

    mapping(address => uint256) public startStakingTime;

    mapping(uint256 => address) private adrsHolders;

    /////////

    uint256 public WITHDRAWAL_FEE = 200; //  0.2% fee

    function get_withdraw_Fee_admin()
        external
        view
        onlyOwner
        returns (uint256)
    {
        return WITHDRAWAL_FEE;
    }

    function set_withdraw_Fee_admin(uint256 feePercent_IN_Finney_)
        public
        onlyOwner
    {
        require(feePercent_IN_Finney_ <= 10000, "invalid percent in finney");

        WITHDRAWAL_FEE = feePercent_IN_Finney_;
    }

    modifier updateReward(address _account) {
        up2date(_account);

        _;
    }

    /// @notice checks if the contract is paused because of bugs
    modifier notPaused() {
        require(!paused, "Paused");
        _;
    }

    // Set Token Address Claim
    function setTokenAddressClaim_admin(address adrs) public onlyOwner {
        __tokenAddress = adrs;

        iToken = BEP20(adrs);
    }

    function up2date(address _account) private {
        lastUpdateTime = block.timestamp;

        if (_account != address(0)) {
            get_Rewards_user(_account);
        }
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOfStaking_user(address _account)
        external
        view
        returns (uint256)
    {
        return _balances[_account];
    }

    uint256 count_address = 0;

    function stake_user(uint256 _amount)
        external
        notPaused
        nonReentrant
        updateReward(msg.sender)
    {
        require(_amount != 0, "invalid _amount");

        require(
            BEP20(__tokenAddress).transferFrom(
                msg.sender,
                address(this),
                _amount
            ),
            "invalid pay"
        );

        // reInvestRewards();

        if (startStakingTime[msg.sender] == 0) {
            adrsHolders[count_address] = msg.sender;

            count_address += 1;

            startStakingTime[msg.sender] = block.timestamp;
        }

        _totalSupply += _amount;
        _balances[msg.sender] += _amount;

        stakingTime[msg.sender] = block.timestamp;

        // iToken.transferFrom(msg.sender, address(this), _amount);
    }

    function update_Rewards_admin() public onlyOwner {
        lastUpdateTime = block.timestamp;

        for (uint256 i = 0; i < count_address; i++) {
            get_Rewards_user(adrsHolders[i]);
        }
    }

    uint256 rewardRateX = 500;

    function rewardPerToken() public view returns (uint256) {
        return ((1 * (10**18)) * rewardRateX) / 100;
    }

    function update_new_rewardRateX_admin(uint256 percent) public onlyOwner {
        require(percent > 100, "invalid percent");

        update_Rewards_admin();

        rewardRateX = percent;
    }

    uint256 sumFee = 0;

    function totalFee_admin() external view onlyOwner returns (uint256) {
        return sumFee;
    }

    function withdrawBalance_user(uint256 _amount)
        public
        nonReentrant
        updateReward(msg.sender)
    {
        require(_amount > 0, "Cannot withdraw 0");

        require(
            _amount <= _balances[msg.sender],
            "Cannot withdraw more than staked"
        );

        if (WITHDRAWAL_FEE > 0) {
            uint256 fee = (_amount * WITHDRAWAL_FEE) / 1e4;

            sumFee += fee;

            _amount -= fee;
        }

        _totalSupply -= _amount;
        _balances[msg.sender] -= _amount;

        iToken.transfer(msg.sender, _amount); // amount
    }

    function withdrawReward_user()
        public
        updateReward(msg.sender)
        returns (uint256)
    {
        uint256 reward = rewards[msg.sender];

        if (reward > 0) {
            iToken.transfer(msg.sender, reward); // reward

            rewards[msg.sender] = 0;
        }

        return reward;
    }

    /// @notice help to exit your position with unstake and claiming the rewards in one txn
    function exit_Staking_user() external {
        withdrawBalance_user(_balances[msg.sender]);
        withdrawReward_user();
    }

    // ############ onlyOwner Functions ##############

    function setPaused(bool _paused) external onlyOwner {
        require(_paused != paused, "Paused state already set");

        paused = _paused;

        if (_paused) lastPauseTime = block.timestamp;
    }

    // ##########################################

    function get_Rewards_user(address _account) public returns (uint256) {
        uint256 time_s = lastUpdateTime - stakingTime[_account];

        rewards[_account] =
            rewards[_account] +
            ((_balances[_account] * rewardPerToken() * time_s) /
                rewardsDuration);

        stakingTime[_account] = lastUpdateTime;

        return rewards[_account];
    }

    function withdrawToken_admin(address to, uint256 amount)
        public
        onlyOwner
        returns (bool)
    {
        BEP20 token = BEP20(__tokenAddress);

        token.transfer(to, amount);

        return true;
    }

    function withdrawToken_admin(
        address tokenAddress,
        address to,
        uint256 amount
    ) public onlyOwner returns (bool) {
        BEP20 token = BEP20(tokenAddress);

        token.transfer(to, amount);

        return true;
    }

    // Owner BNB Withdraw
    function withdrawBNB_admin(address payable to, uint256 amount)
        public
        onlyOwner
        returns (bool)
    {
        to.transfer(amount);
        return true;
    }
}