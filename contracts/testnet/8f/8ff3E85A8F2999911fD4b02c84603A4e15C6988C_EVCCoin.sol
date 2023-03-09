// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;



/**----------------------------

 /$$$$$$$$ /$$    /$$  /$$$$$$ 
| $$_____/| $$   | $$ /$$__  $$
| $$      | $$   | $$| $$  \__/
| $$$$$   |  $$ / $$/| $$      
| $$__/    \  $$ $$/ | $$      
| $$        \  $$$/  | $$    $$
| $$$$$$$$   \  $/   |  $$$$$$/
|________/    \_/     \______/ 

----------------------------**/



import "./ERC20.sol";
import "./ERC20Burnable.sol";
import "./ReentrancyGuard.sol";


// EVCCoin.
contract EVCCoin is Ownable, ERC20, ERC20Burnable, ReentrancyGuard {

    uint256 public rewardsPerHour = 136; // 0.00136%/h or 12% APR
    uint256 public minStake = 1 * 10 ** decimals();
    uint256 public compoundFreq = 14400; //4 hours
    uint256 public claimLock = 7 days;

    struct Staker {
        uint256 deposited;
        uint256 timeOfLastUpdate;
        uint256 unclaimedRewards;

        uint256 depositAt;
        uint256 claimable;

    }

    mapping(address => Staker) internal stakers;

    constructor() ERC20("EVCCoin", "EVC") {
        _mint(msg.sender, 1000000000 * 10 ** decimals());
    }

    function mint(address _to, uint256 _amount) public onlyOwner() {
        _mint(_to, _amount);
    }

    function compoundRewardsTimer(address _user) public view returns(uint256 _timer) {
        if (stakers[_user].timeOfLastUpdate + compoundFreq <= block.timestamp) {
            return 0;
        } else {
            return (stakers[_user].timeOfLastUpdate + compoundFreq) -
                block.timestamp;
        }
    }

    function calculateRewards(address _staker) internal view returns(uint256 rewards) {
        return (((((block.timestamp - stakers[_staker].timeOfLastUpdate) *
            stakers[_staker].deposited) * rewardsPerHour) / 3600) / 10000000);
    }

    function setRewards(uint256 _rewardsPerHour) public onlyOwner {
        rewardsPerHour = _rewardsPerHour;
    }

    function setMinStake(uint256 _minStake) public onlyOwner {
        minStake = _minStake;
    }

    function setCompFreq(uint256 _compoundFreq) public onlyOwner {
        compoundFreq = _compoundFreq;
    }


    function stake(uint256 _amount) external nonReentrant {
        require(_amount >= minStake, "Amount smaller than minimimum deposit");
        require(balanceOf(msg.sender) >= _amount, "Can't stake more than you own");
        if (stakers[msg.sender].deposited == 0) {
            stakers[msg.sender].deposited = _amount;
            stakers[msg.sender].timeOfLastUpdate = block.timestamp;
            stakers[msg.sender].depositAt = block.timestamp;
            stakers[msg.sender].unclaimedRewards = 0;
        } else {
            uint256 rewards = calculateRewards(msg.sender);
            stakers[msg.sender].unclaimedRewards += rewards;
            stakers[msg.sender].deposited += _amount;
            stakers[msg.sender].timeOfLastUpdate = block.timestamp;
            stakers[msg.sender].depositAt = block.timestamp;
        }
        _burn(msg.sender, _amount);
    }

    function claimReward() external nonReentrant {
        uint256 rewards = stakers[msg.sender].claimable;
        require(block.timestamp > stakers[msg.sender].depositAt + claimLock, "time remain to claim");
        require(rewards > 0, "You have no rewards");
        stakers[msg.sender].unclaimedRewards = 0;
        stakers[msg.sender].timeOfLastUpdate = block.timestamp;
        _transfer(owner(), msg.sender, rewards);
        stakers[msg.sender].claimable = 0;
    }

    function unStake() external nonReentrant {
        require(stakers[msg.sender].deposited > 0, "You have no deposit");
        uint256 _rewards = calculateRewards(msg.sender) + stakers[msg.sender].unclaimedRewards;
        uint256 _deposit = stakers[msg.sender].deposited;
        stakers[msg.sender].deposited = 0;
        stakers[msg.sender].timeOfLastUpdate = 0;
        stakers[msg.sender].claimable = _rewards;
        uint256 _amount = _deposit;
        _mint(msg.sender, _amount);
    }

    function setclaimLock(uint256 _claimLock) public onlyOwner {
        claimLock = _claimLock;
    }

    function getDepositAt() public view returns(uint256) {
        return stakers[msg.sender].depositAt;
    }

    function getClaimTimer() public view returns(uint256) {
        uint256 depositAt = stakers[msg.sender].depositAt;
        return (depositAt + claimLock) - block.timestamp;
    }

    function getDepositInfo(address _user) public view returns(uint256 _stake, uint256 _rewards) {
        _stake = stakers[_user].deposited;
        _rewards = calculateRewards(_user) + stakers[msg.sender].claimable;
        return (_stake, _rewards);
    }

}