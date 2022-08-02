// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6;
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Ownable.sol";
import "./Initializable.sol";

contract SmartDisPatchInitializable is Ownable, Initializable {
    
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public constant MAX_SUPPLY_TOKEN = 500;
    // The address of the smart chef factory
    address public SMART_DISPATCH_FACTORY;
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => PoolInfo) private poolInfos;
    address[] public rewardTokens;

    struct PoolInfo {
        bool enable;
        IERC20 rewardToken;
        uint256 reserve;
        uint256 rewardLastStored;
        mapping(address => uint256) userRewardStored;
        mapping(address => uint256) newReward;
        mapping(address => uint256) claimedReward;
    }
    event AddPool(address indexed token);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(
        address indexed user,
        address indexed token,
        uint256 reward
    );
    
    constructor(){
        SMART_DISPATCH_FACTORY = msg.sender;
    }
    fallback() external payable {}
    receive() external payable {      
    }
    //function initialize(address[] memory rewardTokens_, address admin_)
    function initialize()
        external
        initializer
    {
        require(msg.sender == SMART_DISPATCH_FACTORY, "Not factory");
        //rewardTokens = rewardTokens_;
        //for (uint256 i = 0; i != rewardTokens_.length; i++) {
            //poolInfos[rewardTokens_[i]].rewardToken = IERC20(rewardTokens_[i]);
           // poolInfos[rewardTokens_[i]].enable = true;
           poolInfos[deadAddress].enable = true;
       // }

        //transferOwnership(admin_);
    }

    modifier updateDispatch(address account) {
       // for (uint256 i = 0; i != rewardTokens.length; i++) {
           // address token = rewardTokens[i];
            PoolInfo storage pool = poolInfos[deadAddress];
            if (pool.enable) {
                pool.rewardLastStored = rewardPer(pool);
                if (pool.rewardLastStored > 0) {
                    //uint256 balance = pool.rewardToken.balanceOf(address(this));
                    uint256 balance = address(this).balance;
                    pool.reserve = balance;
                    if (account != address(0)) {
                        pool.newReward[account] = available(deadAddress, account);
                        pool.userRewardStored[account] = pool.rewardLastStored;
                    }
                }
            }
        //}
        _;
    }

    function getAllSupplyTokens() public view returns (address[] memory) {
        return rewardTokens;
    }

    function claimedReward(address account)
        public
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfos[deadAddress];
        return pool.claimedReward[account];
    }

    function lastReward(PoolInfo storage pool) private view returns (uint256) {
        if (_totalSupply == 0) {
            return 0;
        }
        uint256 balance = address(this).balance;
        return balance.sub(pool.reserve);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function rewardPer(PoolInfo storage pool) private view returns (uint256) {
        if (totalSupply() == 0) {
            return pool.rewardLastStored;
        }
        return
            pool.rewardLastStored.add(
                lastReward(pool).mul(1e18).div(totalSupply())
            );
    }

    function stake(address account, uint256 amount)
        external
        updateDispatch(account)
    {
        require(msg.sender == SMART_DISPATCH_FACTORY, "Not factory");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Staked(account, amount);
    }

    function withdraw(address account, uint256 amount)
        external
        updateDispatch(account)
    {
        require(msg.sender == SMART_DISPATCH_FACTORY, "Not factory");
        if (_balances[account] < amount) {
            amount = _balances[account];
        }
        if (amount == 0) {
            return;
        }
        _totalSupply = _totalSupply.sub(amount);
        _balances[account] = _balances[account].sub(amount);
        emit Withdrawn(account, amount);
    }

    function available(address token, address account)
        public
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfos[token];
        return
            balanceOf(account)
                .mul(rewardPer(pool).sub(pool.userRewardStored[account]))
                .div(1e18)
                .add(pool.newReward[account]);
    }

    function claim() external updateDispatch(msg.sender) {
        PoolInfo storage pool = poolInfos[deadAddress];
        uint256 reward = available(deadAddress, msg.sender);
        if (reward <= 0) {
            return;
        }
        pool.reserve = pool.reserve.sub(reward);
        pool.newReward[msg.sender] = 0;

        pool.claimedReward[msg.sender] = pool.claimedReward[msg.sender].add(
            reward
        );

        pool.rewardToken.safeTransfer(msg.sender, reward);
        emit RewardPaid(msg.sender, deadAddress, reward);
    }
}