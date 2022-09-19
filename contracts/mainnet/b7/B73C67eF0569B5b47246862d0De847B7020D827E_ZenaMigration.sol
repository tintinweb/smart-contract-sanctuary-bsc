// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./libs/IUniRouter02.sol";
import "./libs/IWETH.sol";

// BrewlabsFarm is the master of brews. He can make brews and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once brews is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract BrewlabsFarm is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;         // How many LP tokens the user has provided.
        uint256 rewardDebt;     // Reward debt. See explanation below.
        uint256 reflectionDebt;     // Reflection debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of brewss
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accTokenPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accTokenPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. brewss to distribute per block.
        uint256 duration;
        uint256 startBlock;
        uint256 bonusEndBlock;
        uint256 lastRewardBlock;  // Last block number that brewss distribution occurs.
        uint256 accTokenPerShare;   // Accumulated brewss per share, times 1e12. See below.
        uint256 accReflectionPerShare;   // Accumulated brewss per share, times 1e12. See below.
        uint256 lastReflectionPerPoint;
        uint16 depositFee;      // Deposit fee in basis points
        uint16 withdrawFee;      // Deposit fee in basis points
    }

    struct SwapSetting {
        IERC20 lpToken;
        address swapRouter;
        address[] earnedToToken0;
        address[] earnedToToken1;
        address[] reflectionToToken0;
        address[] reflectionToToken1;
        bool enabled;
    }

    // The brews TOKEN!
    IERC20 public brews;
    // Reflection Token
    address public reflectionToken;
    uint256 public accReflectionPerPoint;
    bool public hasDividend;

    // brews tokens created per block.
    uint256 public rewardPerBlock;
    // Bonus muliplier for early brews makers.
    uint256 public constant BONUS_MULTIPLIER = 1;
    // Deposit Fee address
    address public feeAddress;
    address public buyBackWallet = 0x408c4aDa67aE1244dfeC7D609dea3c232843189A;
    uint256 public performanceFee = 0.0035 ether;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    SwapSetting[] public swapSettings;
    uint256[] public totalStaked;

    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when brews mining starts.
    uint256 public startBlock;

    uint256 private totalEarned;
    uint256 private totalRewardStaked;
    uint256 private totalReflectionStaked;
    uint256 private totalReflections;
    uint256 private reflectionDebt;

    uint256 private paidRewards;
    uint256 private shouldTotalPaid;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event SetFeeAddress(address indexed user, address indexed newAddress);
    event SetBuyBackWallet(address indexed user, address newAddress);
    event SetPerformanceFee(uint256 fee);
    event UpdateEmissionRate(address indexed user, uint256 rewardPerBlock);

    constructor(IERC20 _brews, address _reflectionToken, uint256 _rewardPerBlock, bool _hasDividend) {
        brews = _brews;
        reflectionToken = _reflectionToken;
        rewardPerBlock = _rewardPerBlock;
        hasDividend = _hasDividend;

        feeAddress = msg.sender;
        startBlock = block.number.add(30 * 28800); // after 30 days
    }

    mapping(IERC20 => bool) public poolExistence;
    modifier nonDuplicated(IERC20 _lpToken) {
        require(poolExistence[_lpToken] == false, "nonDuplicated: duplicated");
        _;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    function add(uint256 _allocPoint, IERC20 _lpToken, uint16 _depositFee, uint16 _withdrawFee, uint256 _duration, bool _withUpdate) external onlyOwner nonDuplicated(_lpToken) {
        require(_depositFee <= 10000, "add: invalid deposit fee basis points");
        require(_withdrawFee <= 10000, "add: invalid withdraw fee basis points");

        if (_withUpdate) {
            massUpdatePools();
        }
        
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolExistence[_lpToken] = true;
        poolInfo.push(PoolInfo({
            lpToken : _lpToken,
            allocPoint : _allocPoint,
            duration: _duration,
            startBlock: lastRewardBlock,
            bonusEndBlock: lastRewardBlock.add(_duration.mul(28800)),
            lastRewardBlock : lastRewardBlock,
            accTokenPerShare : 0,
            accReflectionPerShare : 0,
            lastReflectionPerPoint: 0,
            depositFee : _depositFee,
            withdrawFee: _withdrawFee
        }));

        swapSettings.push();
        swapSettings[swapSettings.length - 1].lpToken = _lpToken;

        totalStaked.push(0);
    }

    // Update the given pool's brews allocation point and deposit fee. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, uint16 _depositFee, uint16 _withdrawFee, uint256 _duration, bool _withUpdate) external onlyOwner {
        require(_depositFee <= 10000, "set: invalid deposit fee basis points");
        require(_withdrawFee <= 10000, "set: invalid deposit fee basis points");
        if(poolInfo[_pid].bonusEndBlock > block.number) {
            require(poolInfo[_pid].startBlock.add(_duration.mul(28800)) > block.number, "set: invalid duration");
        }

        if (_withUpdate) {
            massUpdatePools();
        }
        
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);

        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFee = _depositFee;
        poolInfo[_pid].withdrawFee = _withdrawFee;
        poolInfo[_pid].duration = _duration;

        if(poolInfo[_pid].bonusEndBlock < block.number) {
            if (!_withUpdate) updatePool(_pid);
            
            poolInfo[_pid].startBlock = block.number;
            poolInfo[_pid].bonusEndBlock = block.number.add(_duration.mul(28800));
        } else {
            poolInfo[_pid].bonusEndBlock = poolInfo[_pid].startBlock.add(_duration.mul(28800));
        }
    }

    // Update the given pool's compound parameters. Can only be called by the owner.
    function setSwapSetting(
        uint256 _pid, 
        address _uniRouter, 
        address[] memory _earnedToToken0, 
        address[] memory _earnedToToken1, 
        address[] memory _reflectionToToken0, 
        address[] memory _reflectionToToken1, 
        bool _enabled
    ) external onlyOwner {
        SwapSetting storage swapSetting = swapSettings[_pid];

        swapSetting.enabled = _enabled;
        swapSetting.swapRouter = _uniRouter;
        swapSetting.earnedToToken0 = _earnedToToken0;
        swapSetting.earnedToToken1 = _earnedToToken1;
        swapSetting.reflectionToToken0 = _reflectionToToken0;
        swapSetting.reflectionToToken1 = _reflectionToToken1;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to, uint256 _endBlock) public pure returns (uint256) {
        if(_from > _endBlock) return 0;
        if(_to > _endBlock) {
            return _endBlock.sub(_from).mul(BONUS_MULTIPLIER);    
        }

        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    // View function to see pending brews on frontend.
    function pendingRewards(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        uint256 accTokenPerShare = pool.accTokenPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0 && totalAllocPoint > 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number, pool.bonusEndBlock);
            uint256 brewsReward = multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accTokenPerShare = accTokenPerShare.add(brewsReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accTokenPerShare).div(1e12).sub(user.rewardDebt);
    }

    function pendingReflections(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        uint256 accReflectionPerShare = pool.accReflectionPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if(reflectionToken == address(pool.lpToken)) lpSupply = totalReflectionStaked;
        if (block.number > pool.lastRewardBlock && lpSupply != 0 && hasDividend && totalAllocPoint > 0) {
            uint256 reflectionAmt = availableDividendTokens();
            if(reflectionAmt > totalReflections) {
                reflectionAmt = reflectionAmt.sub(totalReflections);
            } else reflectionAmt = 0;
            
            uint256 _accReflectionPerPoint = accReflectionPerPoint.add(reflectionAmt.mul(1e12).div(totalAllocPoint));
            
            accReflectionPerShare = pool.accReflectionPerShare.add(
                pool.allocPoint.mul(_accReflectionPerPoint.sub(pool.lastReflectionPerPoint)).div(lpSupply)
            );
        }
        return user.amount.mul(accReflectionPerShare).div(1e12).sub(user.reflectionDebt);
    } 

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; pid++) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if(address(pool.lpToken) == address(brews)) lpSupply = totalRewardStaked;
        if(address(pool.lpToken) == reflectionToken) lpSupply = totalReflectionStaked;
        if (lpSupply == 0 || pool.allocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number, pool.bonusEndBlock);
        uint256 brewsReward = multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accTokenPerShare = pool.accTokenPerShare.add(brewsReward.mul(1e12).div(lpSupply));

        if(hasDividend) {
            uint256 reflectionAmt = availableDividendTokens();
            if(reflectionAmt > totalReflections) {
                reflectionAmt = reflectionAmt.sub(totalReflections);
            } else reflectionAmt = 0;

            accReflectionPerPoint = accReflectionPerPoint.add(reflectionAmt.mul(1e12).div(totalAllocPoint));
            pool.accReflectionPerShare = pool.accReflectionPerShare.add(
                pool.allocPoint.mul(accReflectionPerPoint.sub(pool.lastReflectionPerPoint)).div(lpSupply)
            );
            pool.lastReflectionPerPoint = accReflectionPerPoint;

            totalReflections = totalReflections.add(reflectionAmt);
        }

        pool.lastRewardBlock = block.number;
        shouldTotalPaid = shouldTotalPaid + brewsReward;
    }

    // Deposit LP tokens to BrewlabsFarm for brews allocation.
    function deposit(uint256 _pid, uint256 _amount) external payable nonReentrant {
        _transferPerformanceFee();

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        if(pool.bonusEndBlock < block.number) {
            massUpdatePools();

            totalAllocPoint = totalAllocPoint.sub(pool.allocPoint);
            pool.allocPoint = 0;
        } else {
            updatePool(_pid);
        }

        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                require(availableRewardTokens() >= pending, "Insufficient reward tokens");
                safeTokenTransfer(msg.sender, pending);

                if(totalEarned > pending) {
                    totalEarned = totalEarned.sub(pending);
                } else {
                    totalEarned = 0;
                }
                paidRewards = paidRewards + pending;
            }

            uint256 pendingReflection = user.amount.mul(pool.accReflectionPerShare).div(1e12).sub(user.reflectionDebt);
            pendingReflection = _estimateDividendAmount(pendingReflection);
            if (pendingReflection > 0 && hasDividend) {
                if(address(reflectionToken) == address(0x0)) {
                    payable(msg.sender).transfer(pendingReflection);
                } else {
                    IERC20(reflectionToken).safeTransfer(msg.sender, pendingReflection);
                }
                totalReflections = totalReflections.sub(pendingReflection);
            }
        }
        if (_amount > 0) {
            uint256 beforeAmt = pool.lpToken.balanceOf(address(this));
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            uint256 afterAmt = pool.lpToken.balanceOf(address(this));
            uint256 amount = afterAmt.sub(beforeAmt);

            if (pool.depositFee > 0) {
                uint256 depositFee = amount.mul(pool.depositFee).div(10000);
                pool.lpToken.safeTransfer(feeAddress, depositFee);
                user.amount = user.amount.add(amount).sub(depositFee);
            } else {
                user.amount = user.amount.add(amount);
            }

            _calculateTotalStaked(_pid, pool.lpToken, amount, true);
        }

        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        user.reflectionDebt = user.amount.mul(pool.accReflectionPerShare).div(1e12);

        emit Deposit(msg.sender, _pid, _amount);
    }
    
    // Withdraw LP tokens from BrewlabsFarm.
    function withdraw(uint256 _pid, uint256 _amount) external payable nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        require(_amount > 0, "Amount should be greator than 0");

        _transferPerformanceFee();

        if(pool.bonusEndBlock < block.number) {
            massUpdatePools();
            
            totalAllocPoint = totalAllocPoint.sub(pool.allocPoint);
            pool.allocPoint = 0;
        } else {
            updatePool(_pid);
        }

        uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            safeTokenTransfer(msg.sender, pending);

            if(totalEarned > pending) {
                totalEarned = totalEarned.sub(pending);
            } else {
                totalEarned = 0;
            }
            paidRewards = paidRewards + pending;
        }
        
        uint256 pendingReflection = user.amount.mul(pool.accReflectionPerShare).div(1e12).sub(user.reflectionDebt);
        pendingReflection = _estimateDividendAmount(pendingReflection);
        if (pendingReflection > 0 && hasDividend) {
            if(address(reflectionToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingReflection);
            } else {
                IERC20(reflectionToken).safeTransfer(msg.sender, pendingReflection);
            }
            totalReflections = totalReflections.sub(pendingReflection);
        }

        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            if (pool.withdrawFee > 0) {
                uint256 withdrawFee = _amount.mul(pool.withdrawFee).div(10000);
                pool.lpToken.safeTransfer(feeAddress, withdrawFee);
                pool.lpToken.safeTransfer(address(msg.sender), _amount.sub(withdrawFee));
            } else {
                pool.lpToken.safeTransfer(address(msg.sender), _amount);
            }

            _calculateTotalStaked(_pid, pool.lpToken, _amount, false);
        }
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        user.reflectionDebt = user.amount.mul(pool.accReflectionPerShare).div(1e12);

        emit Withdraw(msg.sender, _pid, _amount);
    }

    function claimReward(uint256 _pid) external payable nonReentrant {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if(user.amount < 0) return;

        updatePool(_pid);
        _transferPerformanceFee();

        uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            safeTokenTransfer(msg.sender, pending);

            if(totalEarned > pending) {
                totalEarned = totalEarned.sub(pending);
            } else {
                totalEarned = 0;
            }
            paidRewards = paidRewards + pending;
        }
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
    }

    function compoundReward(uint256 _pid) external payable nonReentrant {
        PoolInfo memory pool = poolInfo[_pid];
        SwapSetting memory swapSetting = swapSettings[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if(user.amount < 0) return;
        if(!swapSetting.enabled) return;

        updatePool(_pid);
        _transferPerformanceFee();

        uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            if(totalEarned > pending) {
                totalEarned = totalEarned.sub(pending);
            } else {
                totalEarned = 0;
            }
            paidRewards = paidRewards + pending;
        }

        if(address(brews) != address(pool.lpToken)) {
            uint256 tokenAmt = pending / 2;
            uint256 tokenAmt0 = tokenAmt;
            address token0 = address(brews);
            if(swapSetting.earnedToToken0.length > 0) {
                token0 = swapSetting.earnedToToken0[swapSetting.earnedToToken0.length - 1];
                tokenAmt0 = _safeSwap(swapSetting.swapRouter, tokenAmt, swapSetting.earnedToToken0, address(this));
            }
            uint256 tokenAmt1 = tokenAmt;
            address token1 = address(brews);
            if(swapSetting.earnedToToken1.length > 0) {
                token1 = swapSetting.earnedToToken1[swapSetting.earnedToToken1.length - 1];
                tokenAmt1 = _safeSwap(swapSetting.swapRouter, tokenAmt, swapSetting.earnedToToken1, address(this));
            }

            uint256 beforeAmt = pool.lpToken.balanceOf(address(this));
            _addLiquidity(swapSetting.swapRouter, token0, token1, tokenAmt0, tokenAmt1, address(this));
            uint256 afterAmt = pool.lpToken.balanceOf(address(this));

            pending = afterAmt - beforeAmt;
        }

        user.amount = user.amount + pending;
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        user.reflectionDebt = user.reflectionDebt + pending * pool.accReflectionPerShare / 1e12;
        
        _calculateTotalStaked(_pid, pool.lpToken, pending, true);
        emit Deposit(msg.sender, _pid, pending);
    }

    function claimDividend(uint256 _pid) external payable nonReentrant {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if(user.amount < 0) return;
        if(!hasDividend) return;
        
        updatePool(_pid);
        _transferPerformanceFee();

        uint256 pendingReflection = user.amount.mul(pool.accReflectionPerShare).div(1e12).sub(user.reflectionDebt);
        pendingReflection = _estimateDividendAmount(pendingReflection);
        if (pendingReflection > 0) {
            if(address(reflectionToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingReflection);
            } else {
                IERC20(reflectionToken).safeTransfer(msg.sender, pendingReflection);
            }
            totalReflections = totalReflections.sub(pendingReflection);
        }

        user.reflectionDebt = user.amount.mul(pool.accReflectionPerShare).div(1e12);
    }

    function compoundDividend(uint256 _pid) external payable nonReentrant {
        PoolInfo memory pool = poolInfo[_pid];
        SwapSetting memory swapSetting = swapSettings[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if(user.amount < 0) return;
        if(!hasDividend) return;
        
        updatePool(_pid);
        _transferPerformanceFee();

        uint256 pending = user.amount.mul(pool.accReflectionPerShare).div(1e12).sub(user.reflectionDebt);
        pending = _estimateDividendAmount(pending);
        if (pending > 0) {
            totalReflections = totalReflections.sub(pending);
        }

        if(reflectionToken != address(pool.lpToken)) {
            if(reflectionToken == address(0x0)) {
                address wethAddress = IUniRouter02(swapSetting.swapRouter).WETH();
                IWETH(wethAddress).deposit{ value: pending }();
            }

            uint256 tokenAmt = pending / 2;
            uint256 tokenAmt0 = tokenAmt;
            address token0 = reflectionToken;
            if(swapSetting.reflectionToToken0.length > 0) {
                token0 = swapSetting.reflectionToToken0[swapSetting.reflectionToToken0.length - 1];
                tokenAmt0 = _safeSwap(swapSetting.swapRouter, tokenAmt, swapSetting.reflectionToToken0, address(this));
            }
            uint256 tokenAmt1 = tokenAmt;
            address token1 = reflectionToken;
            if(swapSetting.reflectionToToken1.length > 0) {
                token0 = swapSetting.reflectionToToken1[swapSetting.reflectionToToken1.length - 1];
                tokenAmt1 = _safeSwap(swapSetting.swapRouter, tokenAmt, swapSetting.reflectionToToken1, address(this));
            }

            uint256 beforeAmt = pool.lpToken.balanceOf(address(this));
            _addLiquidity(swapSetting.swapRouter, token0, token1, tokenAmt0, tokenAmt1, address(this));
            uint256 afterAmt = pool.lpToken.balanceOf(address(this));

            pending = afterAmt - beforeAmt;
        }

        user.amount = user.amount + pending;
        user.rewardDebt = user.rewardDebt + pending.mul(pool.accTokenPerShare).div(1e12);
        user.reflectionDebt = user.amount.mul(pool.accReflectionPerShare).div(1e12);

        _calculateTotalStaked(_pid, pool.lpToken, pending, true);        
        emit Deposit(msg.sender, _pid, pending);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) external nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpToken.safeTransfer(address(msg.sender), amount);

        _calculateTotalStaked(_pid, pool.lpToken, amount, false);
        
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    function _transferPerformanceFee() internal {
        require(msg.value >= performanceFee, 'should pay small gas');

        payable(buyBackWallet).transfer(performanceFee);
        if(msg.value > performanceFee) {
            payable(msg.sender).transfer(msg.value - performanceFee);
        }
    }

    function _calculateTotalStaked(uint256 _pid, IERC20 _lpToken, uint256 _amount, bool _deposit) internal {
        if(_deposit) {
            totalStaked[_pid] = totalStaked[_pid].add(_amount);
            if(address(_lpToken) == address(brews)) {
                totalRewardStaked = totalRewardStaked + _amount;
            }
            if(address(_lpToken) == reflectionToken) {
                totalReflectionStaked = totalReflectionStaked + _amount;
            }
        } else {
            totalStaked[_pid] = totalStaked[_pid] - _amount;
            if(address(_lpToken) == address(brews)) {
                if(totalRewardStaked < _amount) totalRewardStaked = _amount;
                totalRewardStaked = totalRewardStaked - _amount;
            }
            if(address(_lpToken) == reflectionToken) {
                if(totalReflectionStaked < _amount) totalReflectionStaked = _amount;
                totalReflectionStaked = totalReflectionStaked - _amount;
            }
        }        
    }

    function _estimateDividendAmount(uint256 amount) internal view returns(uint256) {
        uint256 dTokenBal = availableDividendTokens();
        if(amount > totalReflections) amount = totalReflections;
        if(amount > dTokenBal) amount = dTokenBal;
        return amount;
    }

    /**
     * @notice Available amount of reward token
     */
    function availableRewardTokens() public view returns (uint256) {
        if(address(brews) == reflectionToken) return totalEarned;

        uint256 _amount = brews.balanceOf(address(this));
        return _amount - totalRewardStaked;
    }

    /**
     * @notice Available amount of reflection token
     */
    function availableDividendTokens() public view returns (uint256) {
        if(hasDividend == false) return 0;
        if(address(reflectionToken) == address(0x0)) {
            return address(this).balance;
        }

        uint256 _amount = IERC20(reflectionToken).balanceOf(address(this));        
        if(address(reflectionToken) == address(brews)) {
            if(_amount < totalEarned) return 0;
            _amount = _amount - totalEarned;
        }
        return _amount - totalReflectionStaked;
    }
    
    function insufficientRewards() external view returns (uint256) {
        uint256 adjustedShouldTotalPaid = shouldTotalPaid;
        uint256 remainRewards = availableRewardTokens() + paidRewards;

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; pid++) {
            PoolInfo memory pool = poolInfo[pid];
            if(startBlock == 0) {
                adjustedShouldTotalPaid = adjustedShouldTotalPaid + rewardPerBlock * pool.allocPoint * pool.duration * 28800 / totalAllocPoint;
            } else {
                uint256 multiplier = getMultiplier(pool.lastRewardBlock, pool.bonusEndBlock, pool.bonusEndBlock);
                adjustedShouldTotalPaid = adjustedShouldTotalPaid + multiplier * rewardPerBlock * pool.allocPoint / totalAllocPoint;
            }
        }

        if(remainRewards >= adjustedShouldTotalPaid) return 0;

        return adjustedShouldTotalPaid - remainRewards;
    }


    // Safe brews transfer function, just in case if rounding error causes pool to not have enough brewss.
    function safeTokenTransfer(address _to, uint256 _amount) internal {
        uint256 brewsBal = brews.balanceOf(address(this));
        bool transferSuccess = false;
        if (_amount > brewsBal) {
            transferSuccess = brews.transfer(_to, brewsBal);
        } else {
            transferSuccess = brews.transfer(_to, _amount);
        }
        require(transferSuccess, "safeTokenTransfer: transfer failed");
    }

    function setFeeAddress(address _feeAddress) external onlyOwner {
        feeAddress = _feeAddress;
        emit SetFeeAddress(msg.sender, _feeAddress);
    }

    function setPerformanceFee(uint256 _fee) external {
        require(msg.sender == buyBackWallet, "setPerformanceFee: FORBIDDEN");

        performanceFee = _fee;
        emit SetPerformanceFee(_fee);
    }
    
    function setBuyBackWallet(address _addr) external {
        require(msg.sender == buyBackWallet, "setBuyBackWallet: FORBIDDEN");
        buyBackWallet = _addr;
        emit SetBuyBackWallet(msg.sender, _addr);
    }

    //Brews has to add hidden dummy pools inorder to alter the emission, here we make it simple and transparent to all.
    function updateEmissionRate(uint256 _rewardPerBlock) external onlyOwner {
        massUpdatePools();
        rewardPerBlock = _rewardPerBlock;
        emit UpdateEmissionRate(msg.sender, _rewardPerBlock);
    }

    function updateStartBlock(uint256 _startBlock) external onlyOwner {
        require(startBlock > block.number, "farm is running now");
        require(_startBlock > block.number, "should be greater than current block");

        startBlock = _startBlock;
        for(uint pid = 0; pid < poolInfo.length; pid++) {
            poolInfo[pid].startBlock = startBlock;
            poolInfo[pid].lastRewardBlock = startBlock;
            poolInfo[pid].bonusEndBlock = startBlock.add(poolInfo[pid].duration.mul(28800));
        }
    }

    /*
     * @notice Deposit reward token
     * @dev Only call by owner. Needs to be for deposit of reward token when reflection token is same with reward token.
     */
    function depositRewards(uint _amount) external nonReentrant {
        require(_amount > 0);

        uint256 beforeAmt = brews.balanceOf(address(this));
        brews.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = brews.balanceOf(address(this));

        totalEarned = totalEarned.add(afterAmt).sub(beforeAmt);
    }

    function increaseEmissionRate(uint256 _amount) external onlyOwner {
        require(startBlock > 0, "pool is not started");
        require(_amount > 0, "invalid amount");

        uint256 bonusEndBlock = 0;
        for(uint i  = 0; i < poolInfo.length; i++) {
            if(bonusEndBlock < poolInfo[i].bonusEndBlock) {
                bonusEndBlock = poolInfo[i].bonusEndBlock;
            }
        }
        require(bonusEndBlock > block.number, "pool was already finished");
        
        massUpdatePools();

        uint256 beforeAmt = brews.balanceOf(address(this));
        brews.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = brews.balanceOf(address(this));

        totalEarned = totalEarned + afterAmt - beforeAmt;

        uint256 remainRewards = availableRewardTokens() + paidRewards;
        if(remainRewards > shouldTotalPaid) {
            remainRewards = remainRewards - shouldTotalPaid;

            uint256 remainBlocks = bonusEndBlock - block.number;
            rewardPerBlock = remainRewards / remainBlocks;
            emit UpdateEmissionRate(msg.sender, rewardPerBlock);
        }
    }

    function emergencyWithdrawRewards(uint256 _amount) external onlyOwner {
        if(_amount == 0) {
            uint256 amount = brews.balanceOf(address(this));
            safeTokenTransfer(msg.sender, amount);
        } else {
            safeTokenTransfer(msg.sender, _amount);
        }
    }

    function emergencyWithdrawReflections() external onlyOwner {
        if(address(reflectionToken) == address(0x0)) {
            uint256 amount = address(this).balance;
            payable(address(this)).transfer(amount);
        } else {
            uint256 amount = IERC20(reflectionToken).balanceOf(address(this));
            IERC20(reflectionToken).transfer(msg.sender, amount);
        }
    }

    function recoverWrongToken(address _token) external onlyOwner {
        require(_token != address(brews) && _token != reflectionToken, "cannot recover reward token or reflection token");
        require(poolExistence[IERC20(_token)] == false, "token is using on pool");

        if(_token == address(0x0)) {
            uint256 amount = address(this).balance;
            payable(address(this)).transfer(amount);
        } else {
            uint256 amount = IERC20(_token).balanceOf(address(this));
            if(amount > 0) {
                IERC20(_token).transfer(msg.sender, amount);
            }
        }
    }

    function _safeSwap(
        address _uniRouter,
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal returns (uint256) {
        uint256 beforeAmt = IERC20(_path[_path.length - 1]).balanceOf(address(this));
        IERC20(_path[0]).safeApprove(_uniRouter, _amountIn);
        IUniRouter02(_uniRouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amountIn,
            0,
            _path,
            _to,
            block.timestamp + 600
        );
        uint256 afterAmt = IERC20(_path[_path.length - 1]).balanceOf(address(this));
        return afterAmt - beforeAmt;
    }

    function _addLiquidity(
        address _uniRouter,
        address _token0,
        address _token1,
        uint256 _tokenAmt0,
        uint256 _tokenAmt1,
        address _to
    ) internal returns(uint256 amountA, uint256 amountB, uint256 liquidity) {
        IERC20(_token0).safeIncreaseAllowance(_uniRouter, _tokenAmt0);
        IERC20(_token1).safeIncreaseAllowance(_uniRouter, _tokenAmt1);

        (amountA, amountB, liquidity) = IUniRouter02(_uniRouter).addLiquidity(
            _token0,
            _token1,
            _tokenAmt0,
            _tokenAmt1,
            0,
            0,
            _to,
            block.timestamp + 600
        );

        IERC20(_token0).safeApprove(_uniRouter, uint256(0));
        IERC20(_token1).safeApprove(_uniRouter, uint256(0));
    }
    receive() external payable {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IUniRouter01.sol";

interface IUniRouter02 is IUniRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IUniRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This treasury contract has been developed by brewlabs.info
 */
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import "../libs/IUniFactory.sol";
import "../libs/IUniRouter02.sol";
import "../libs/IWETH.sol";

interface IStaking {
    function performanceFee() external view returns(uint256);
    function setServiceInfo(address _addr, uint256 _fee) external;
}

interface IFarm {
    function setBuyBackWallet(address _addr) external;
}

contract VulkaniaTreasury is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Whether it is initialized
    bool private isInitialized;
    uint256 private TIME_UNIT = 1 days;

    IERC20  public token;
    address public dividendToken;
    address public pair;

    uint256 public period = 30;                         // 30 days
    uint256 public withdrawalLimit = 500;               // 5% of total supply
    uint256 public liquidityWithdrawalLimit = 2000;     // 20% of LP supply
    uint256 public buybackRate = 9500;                  // 95%
    uint256 public addLiquidityRate = 9400;             // 94%

    uint256 private startTime;
    uint256 private sumWithdrawals = 0;
    uint256 private sumLiquidityWithdrawals = 0;

    uint256 public performanceFee = 100;     // 1%
    uint256 public performanceLpFee = 200;   // 2%
    address public feeWallet = 0x408c4aDa67aE1244dfeC7D609dea3c232843189A;

    // swap router and path, slipPage
    address public uniRouterAddress;
    address[] public bnbToTokenPath;
    uint256 public slippageFactor = 830;    // 17%
    uint256 public constant slippageFactorUL = 995;

    event TokenBuyBack(uint256 amountETH, uint256 amountToken);
    event LiquidityAdded(uint256 amountETH, uint256 amountToken, uint256 liquidity);
    event SetSwapConfig(address router, uint256 slipPage, address[] path);
    event TransferBuyBackWallet(address staking, address wallet);
    event LiquidityWithdrawn(uint256 amount);
    event Withdrawn(uint256 amount);

    event AddLiquidityRateUpdated(uint256 percent);
    event BuybackRateUpdated(uint256 percent);
    event PeriodUpdated(uint256 duration);
    event LiquidityWithdrawLimitUpdated(uint256 percent);
    event WithdrawLimitUpdated(uint256 percent);
    event ServiceInfoUpdated(address wallet, uint256 performanceFee, uint256 liquidityFee);

    constructor() {}
   
    /**
     * @notice Initialize the contract
     * @param _token: token address
     * @param _dividendToken: reflection token address
     * @param _uniRouter: uniswap router address for swap tokens
     * @param _bnbToTokenPath: swap path to buy Token
     */
    function initialize(
        IERC20 _token,
        address _dividendToken,
        address _uniRouter,
        address[] memory _bnbToTokenPath
    ) external onlyOwner {
        require(!isInitialized, "Already initialized");

        // Make this contract initialized
        isInitialized = true;

        token = _token;
        dividendToken = _dividendToken;
        pair = IUniV2Factory(IUniRouter02(_uniRouter).factory()).getPair(_bnbToTokenPath[0], address(token));

        uniRouterAddress = _uniRouter;
        bnbToTokenPath = _bnbToTokenPath;
    }

    /**
     * @notice Buy token from BNB
     */
    function buyBack() external onlyOwner nonReentrant {
        uint256 ethAmt = address(this).balance;
        uint256 _fee = ethAmt * performanceFee / 10000;
        if(_fee > 0) {
            payable(feeWallet).transfer(_fee);
            ethAmt = ethAmt - _fee;
        }
        ethAmt = ethAmt * buybackRate / 10000;

        if(ethAmt > 0) {
            uint256[] memory amounts = _safeSwapEth(ethAmt, bnbToTokenPath, address(this));
            emit TokenBuyBack(amounts[0], amounts[amounts.length - 1]);
        }
    }

    
    /**
     * @notice Add liquidity
     */
    function addLiquidity() external onlyOwner nonReentrant {
        uint256 ethAmt = address(this).balance;
        uint256 _fee = ethAmt * performanceLpFee / 10000;
        if(_fee > 0) {
            payable(feeWallet).transfer(_fee);
            ethAmt = ethAmt - _fee;
        }
        ethAmt = ethAmt * addLiquidityRate / 10000 / 2;

        if(ethAmt > 0) {
            uint256[] memory amounts = _safeSwapEth(ethAmt, bnbToTokenPath, address(this));
            uint256 _tokenAmt = amounts[amounts.length - 1];
            emit TokenBuyBack(amounts[0], _tokenAmt);
            
            (uint256 amountToken, uint256 amountETH, uint256 liquidity) = _addLiquidityEth(address(token), ethAmt, _tokenAmt, address(this));
            emit LiquidityAdded(amountETH, amountToken, liquidity);
        }
    }


    /**
     * @notice Withdraw token as much as maximum 5% of total supply
     * @param _amount: amount to withdraw
     */
    function withdraw(uint256 _amount) external onlyOwner {
        uint256 tokenAmt = token.balanceOf(address(this));
        require(_amount > 0 && _amount <= tokenAmt, "Invalid Amount");

        if(block.timestamp - startTime > period * TIME_UNIT) {
            startTime = block.timestamp;
            sumWithdrawals = 0;
        }

        uint256 limit = withdrawalLimit * (token.totalSupply()) / 10000;
        require(sumWithdrawals + _amount <= limit, "exceed maximum withdrawal limit for 30 days");

        token.safeTransfer(msg.sender, _amount);
        emit Withdrawn(_amount);
    }

    /**
     * @notice Withdraw token as much as maximum 20% of lp supply
     * @param _amount: liquidity amount to withdraw
     */
    function withdrawLiquidity(uint256 _amount) external onlyOwner {
        uint256 tokenAmt = IERC20(pair).balanceOf(address(this));
        require(_amount > 0 && _amount <= tokenAmt, "Invalid Amount");

        if(block.timestamp - startTime > period * TIME_UNIT) {
            startTime = block.timestamp;
            sumLiquidityWithdrawals = 0;
        }

        uint256 limit = liquidityWithdrawalLimit * (IERC20(pair).totalSupply()) / 10000;
        require(sumLiquidityWithdrawals + _amount <= limit, "exceed maximum LP withdrawal limit for 30 days");

        IERC20(pair).safeTransfer(msg.sender, _amount);
        emit LiquidityWithdrawn(_amount);
    }
    
    /**
     * @notice Withdraw tokens
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external onlyOwner {
        uint256 tokenAmt = token.balanceOf(address(this));
        if(tokenAmt > 0) {
            token.transfer(msg.sender, tokenAmt);
        }

        tokenAmt = IERC20(pair).balanceOf(address(this));
        if(tokenAmt > 0) {
            IERC20(pair).transfer(msg.sender, tokenAmt);
        }

        uint256 ethAmt = address(this).balance;
        if(ethAmt > 0) {
            payable(msg.sender).transfer(ethAmt);
        }
    }

    /**
     * @notice Harvest reflection for token
     */
    function harvest() external onlyOwner {
        if(dividendToken == address(0x0)) {
            uint256 ethAmt = address(this).balance;
            if(ethAmt > 0) {
                payable(msg.sender).transfer(ethAmt);
            }
        } else {
            uint256 tokenAmt = IERC20(dividendToken).balanceOf(address(this));
            if(tokenAmt > 0) {
                IERC20(dividendToken).transfer(msg.sender, tokenAmt);
            }
        }
    }

    /**
     * @notice Set duration for withdraw limit
     * @param _period: duration
     */
    function setWithdrawalLimitPeriod(uint256 _period) external onlyOwner {
        require(_period >= 10, "small period");
        period = _period;
        emit PeriodUpdated(_period);
    }

    /**
     * @notice Set liquidity withdraw limit
     * @param _percent: percentage of LP supply in point
     */
    function setLiquidityWithdrawalLimit(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");
        
        liquidityWithdrawalLimit = _percent;
        emit LiquidityWithdrawLimitUpdated(_percent);
    }

    /**
     * @notice Set withdraw limit
     * @param _percent: percentage of total supply in point
     */
    function setWithdrawalLimit(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");
        
        withdrawalLimit = _percent;
        emit WithdrawLimitUpdated(_percent);
    }
    
    /**
     * @notice Set buyback rate
     * @param _percent: percentage in point
     */
    function setBuybackRate(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");

        buybackRate = _percent;
        emit BuybackRateUpdated(_percent);
    }

    /**
     * @notice Set addliquidy rate
     * @param _percent: percentage in point
     */
    function setAddLiquidityRate(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");

        addLiquidityRate = _percent;
        emit AddLiquidityRateUpdated(_percent);
    }

    function setServiceInfo(address _wallet, uint256 _fee) external {
        require(msg.sender == feeWallet, "Invalid setter");
        require(_wallet != feeWallet && _wallet != address(0x0), "Invalid new wallet");
        require(_fee < 500, "invalid performance fee");
       
        feeWallet = _wallet;
        performanceFee = _fee;
        performanceLpFee = _fee * 2;

        emit ServiceInfoUpdated(_wallet, performanceFee, performanceLpFee);
    }
    
    /**
     * @notice Set buyback wallet of farm contract
     * @param _uniRouter: dex router address
     * @param _slipPage: slip page for swap
     * @param _path: bnb-token swap path
     */
    function setSwapSettings(address _uniRouter, uint256 _slipPage, address[] memory _path) external onlyOwner {
        require(_slipPage < 1000, "Invalid percentage");

        uniRouterAddress = _uniRouter;
        slippageFactor = _slipPage;
        bnbToTokenPath = _path;

        emit SetSwapConfig(_uniRouter, _slipPage, _path);
    }

    /**
     * @notice set buyback wallet of farm contract
     * @param _farm: farm contract address
     * @param _addr: buyback wallet address
     */
    function setFarmServiceInfo(address _farm, address _addr) external onlyOwner {
        require(_farm != address(0x0) && _addr != address(0x0), "Invalid Address");
        IFarm(_farm).setBuyBackWallet(_addr);

        emit TransferBuyBackWallet(_farm, _addr);
    }

    /**
     * @notice set buyback wallet of staking contract 
     * @param _staking: staking contract address
     * @param _addr: buyback wallet address
     */
    function setStakingServiceInfo(address _staking, address _addr) external onlyOwner {
        require(_staking != address(0x0) && _addr != address(0x0), "Invalid Address");
        uint256 _fee = IStaking(_staking).performanceFee();
        IStaking(_staking).setServiceInfo(_addr, _fee);

        emit TransferBuyBackWallet(_staking, _addr);
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _token: the address of the token to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _token) external onlyOwner {
        require(_token != address(token) && _token != dividendToken && _token != pair, "Cannot be token & dividend token, pair");

        if(_token == address(0x0)) {
            uint256 _tokenAmount = address(this).balance;
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            uint256 _tokenAmount = IERC20(_token).balanceOf(address(this));
            IERC20(_token).safeTransfer(msg.sender, _tokenAmount);
        }
    }


    /************************
    ** Internal Methods
    *************************/
    /*
     * @notice get token from ETH via swap.
     */
    function _safeSwapEth(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal returns (uint256[] memory amounts) {
        amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length - 1];

        IUniRouter02(uniRouterAddress).swapExactETHForTokensSupportingFeeOnTransferTokens{value: _amountIn}(
            amountOut * slippageFactor / 1000,
            _path,
            _to,
            block.timestamp + 600
        );
    }

    /*
     * @notice Add liquidity for Token-BNB pair.
     */
    function _addLiquidityEth(
        address _token,
        uint256 _ethAmt,
        uint256 _tokenAmt,
        address _to
    ) internal returns(uint256 amountToken, uint256 amountETH, uint256 liquidity) {
        IERC20(_token).safeIncreaseAllowance(uniRouterAddress, _tokenAmt);

        (amountToken, amountETH, liquidity) = IUniRouter02(uniRouterAddress).addLiquidityETH{value: _ethAmt}(
            address(_token),
            _tokenAmt,
            0,
            0,
            _to,
            block.timestamp + 600
        );

        IERC20(_token).safeApprove(uniRouterAddress, uint256(0));
    }


    receive() external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IUniV2Factory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author token
 * This treasury contract has been developed by brewlabs.info
 */
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import "../libs/IUniFactory.sol";
import "../libs/IUniRouter02.sol";
import "../libs/IWETH.sol";

interface IStaking {
    function performanceFee() external view returns(uint256);
    function setServiceInfo(address _addr, uint256 _fee) external;
}

interface IFarm {
    function setBuyBackWallet(address _addr) external;
}

contract RentEezTreasury is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Whether it is initialized
    bool private isInitialized;
    uint256 private TIME_UNIT = 1 days;

    IERC20  public token;
    address public dividendToken;
    address public pair;

    uint256 public period = 30;                         // 30 days
    uint256 public withdrawalLimit = 500;               // 5% of total supply
    uint256 public liquidityWithdrawalLimit = 2000;     // 20% of LP supply
    uint256 public buybackRate = 9500;                  // 95%
    uint256 public addLiquidityRate = 9400;             // 94%

    uint256 private startTime;
    uint256 private sumWithdrawals = 0;
    uint256 private sumLiquidityWithdrawals = 0;

    uint256 public performanceFee = 100;     // 1%
    uint256 public performanceLpFee = 200;   // 2%
    address public feeWallet = 0x408c4aDa67aE1244dfeC7D609dea3c232843189A;

    // swap router and path, slipPage
    address public uniRouterAddress;
    address[] public bnbToTokenPath;
    uint256 public slippageFactor = 830;    // 17%
    uint256 public constant slippageFactorUL = 995;

    event TokenBuyBack(uint256 amountETH, uint256 amountToken);
    event LiquidityAdded(uint256 amountETH, uint256 amountToken, uint256 liquidity);
    event SetSwapConfig(address router, uint256 slipPage, address[] path);
    event TransferBuyBackWallet(address staking, address wallet);
    event LiquidityWithdrawn(uint256 amount);
    event Withdrawn(uint256 amount);

    event AddLiquidityRateUpdated(uint256 percent);
    event BuybackRateUpdated(uint256 percent);
    event PeriodUpdated(uint256 duration);
    event LiquidityWithdrawLimitUpdated(uint256 percent);
    event WithdrawLimitUpdated(uint256 percent);
    event ServiceInfoUpdated(address wallet, uint256 performanceFee, uint256 liquidityFee);

    constructor() {}
   
    /**
     * @notice Initialize the contract
     * @param _token: token address
     * @param _dividendToken: reflection token address
     * @param _uniRouter: uniswap router address for swap tokens
     * @param _bnbToTokenPath: swap path to buy token
     */
    function initialize(
        IERC20 _token,
        address _dividendToken,
        address _uniRouter,
        address[] memory _bnbToTokenPath
    ) external onlyOwner {
        require(!isInitialized, "Already initialized");

        // Make this contract initialized
        isInitialized = true;

        token = _token;
        dividendToken = _dividendToken;
        pair = IUniV2Factory(IUniRouter02(_uniRouter).factory()).getPair(_bnbToTokenPath[0], address(token));

        uniRouterAddress = _uniRouter;
        bnbToTokenPath = _bnbToTokenPath;
    }

    /**
     * @notice Buy token from BNB
     */
    function buyBack() external onlyOwner nonReentrant{
        uint256 ethAmt = address(this).balance;
        uint256 _fee = ethAmt.mul(performanceFee).div(10000);
        if(_fee > 0) {
            payable(feeWallet).transfer(_fee);
            ethAmt = ethAmt.sub(_fee);
        }

        ethAmt = ethAmt.mul(buybackRate).div(10000);
        if(ethAmt > 0) {
            uint256[] memory amounts = _safeSwapEth(ethAmt, bnbToTokenPath, address(this));
            emit TokenBuyBack(amounts[0], amounts[amounts.length - 1]);
        }
    }

    /**
     * @notice Add liquidity
     */
    function addLiquidity() external onlyOwner nonReentrant{
        uint256 ethAmt = address(this).balance;
        uint256 _fee = ethAmt.mul(performanceLpFee).div(10000);
        if(_fee > 0) {
            payable(feeWallet).transfer(_fee);
            ethAmt = ethAmt.sub(_fee);
        }

        ethAmt = ethAmt.mul(addLiquidityRate).div(10000).div(2);
        if(ethAmt > 0) {
            uint256[] memory amounts = _safeSwapEth(ethAmt, bnbToTokenPath, address(this));
            uint256 _tokenAmt = amounts[amounts.length - 1];
            emit TokenBuyBack(amounts[0], _tokenAmt);
            
            (uint256 amountToken, uint256 amountETH, uint256 liquidity) = _addLiquidityEth(address(token), ethAmt, _tokenAmt, address(this));
            emit LiquidityAdded(amountETH, amountToken, liquidity);
        }
    }

    /**
     * @notice Withdraw brews as much as maximum 5% of total supply
     * @param _amount: amount to withdraw
     */
    function withdraw(uint256 _amount) external onlyOwner {
        uint256 tokenAmt = token.balanceOf(address(this));
        require(_amount > 0 && _amount <= tokenAmt, "Invalid Amount");

        if(block.timestamp.sub(startTime) > period.mul(TIME_UNIT)) {
            startTime = block.timestamp;
            sumWithdrawals = 0;
        }

        uint256 limit = withdrawalLimit.mul(token.totalSupply()).div(10000);
        require(sumWithdrawals.add(_amount) <= limit, "exceed maximum withdrawal limit for 30 days");

        token.safeTransfer(msg.sender, _amount);
        emit Withdrawn(_amount);
    }

    /**
     * @notice Withdraw brews as much as maximum 20% of lp supply
     * @param _amount: liquidity amount to withdraw
     */
    function withdrawLiquidity(uint256 _amount) external onlyOwner {
        uint256 tokenAmt = IERC20(pair).balanceOf(address(this));
        require(_amount > 0 && _amount <= tokenAmt, "Invalid Amount");

        if(block.timestamp.sub(startTime) > period.mul(TIME_UNIT)) {
            startTime = block.timestamp;
            sumLiquidityWithdrawals = 0;
        }

        uint256 limit = liquidityWithdrawalLimit.mul(IERC20(pair).totalSupply()).div(10000);
        require(sumLiquidityWithdrawals.add(_amount) <= limit, "exceed maximum LP withdrawal limit for 30 days");

        IERC20(pair).safeTransfer(msg.sender, _amount);
        emit LiquidityWithdrawn(_amount);
    }

    
    /**
     * @notice Withdraw tokens
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external onlyOwner {
        uint256 tokenAmt = token.balanceOf(address(this));
        if(tokenAmt > 0) {
            token.transfer(msg.sender, tokenAmt);
        }

        tokenAmt = IERC20(pair).balanceOf(address(this));
        if(tokenAmt > 0) {
            IERC20(pair).transfer(msg.sender, tokenAmt);
        }

        uint256 ethAmt = address(this).balance;
        if(ethAmt > 0) {
            payable(msg.sender).transfer(ethAmt);
        }
    }

    /**
     * @notice Harvest reflection for token
     */
    function harvest() external onlyOwner {
        if(dividendToken == address(0x0)) {
            uint256 ethAmt = address(this).balance;
            if(ethAmt > 0) {
                payable(msg.sender).transfer(ethAmt);
            }
        } else {
            uint256 tokenAmt = IERC20(dividendToken).balanceOf(address(this));
            if(tokenAmt > 0) {
                IERC20(dividendToken).transfer(msg.sender, tokenAmt);
            }
        }
    }

    /**
     * @notice Set duration for withdraw limit
     * @param _period: duration
     */
    function setWithdrawalLimitPeriod(uint256 _period) external onlyOwner {
        require(_period >= 10, "small period");
        period = _period;
        emit PeriodUpdated(_period);
    }

    /**
     * @notice Set liquidity withdraw limit
     * @param _percent: percentage of LP supply in point
     */
    function setLiquidityWithdrawalLimit(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");
        
        liquidityWithdrawalLimit = _percent;
        emit LiquidityWithdrawLimitUpdated(_percent);
    }

    /**
     * @notice Set withdraw limit
     * @param _percent: percentage of total supply in point
     */
    function setWithdrawalLimit(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");
        
        withdrawalLimit = _percent;
        emit WithdrawLimitUpdated(_percent);
    }
    
    /**
     * @notice Set buyback amount
     * @param _percent: percentage in point
     */
    function setBuybackRate(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");

        buybackRate = _percent;
        emit BuybackRateUpdated(_percent);
    }

    /**
     * @notice Set addliquidy amount
     * @param _percent: percentage in point
     */
    function setAddLiquidityRate(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");

        addLiquidityRate = _percent;
        emit AddLiquidityRateUpdated(_percent);
    }

    function setServiceInfo(address _wallet, uint256 _fee) external {
        require(msg.sender == feeWallet, "Invalid setter");
        require(_wallet != feeWallet && _wallet != address(0x0), "Invalid new wallet");
        require(_fee < 500, "invalid performance fee");
       
        feeWallet = _wallet;
        performanceFee = _fee;
        performanceLpFee = _fee.mul(2);

        emit ServiceInfoUpdated(_wallet, performanceFee, performanceLpFee);
    }
    
    /**
     * @notice Set buyback wallet of farm contract
     * @param _uniRouter: dex router address
     * @param _slipPage: slip page for swap
     * @param _path: bnb-brews path
     */
    function setSwapSettings(address _uniRouter, uint256 _slipPage, address[] memory _path) external onlyOwner {
        require(_slipPage < 1000, "Invalid percentage");

        uniRouterAddress = _uniRouter;
        slippageFactor = _slipPage;
        bnbToTokenPath = _path;

        emit SetSwapConfig(_uniRouter, _slipPage, _path);
    }

    /**
     * @notice set buyback wallet of farm contract
     * @param _farm: farm contract address
     * @param _addr: buyback wallet address
     */
    function setFarmServiceInfo(address _farm, address _addr) external onlyOwner {
        require(_farm != address(0x0) && _addr != address(0x0), "Invalid Address");
        IFarm(_farm).setBuyBackWallet(_addr);

        emit TransferBuyBackWallet(_farm, _addr);
    }

    /**
     * @notice set buyback wallet of staking contract 
     * @param _staking: staking contract address
     * @param _addr: buyback wallet address
     */
    function setStakingServiceInfo(address _staking, address _addr) external onlyOwner {
        require(_staking != address(0x0) && _addr != address(0x0), "Invalid Address");
        uint256 _fee = IStaking(_staking).performanceFee();
        IStaking(_staking).setServiceInfo(_addr, _fee);

        emit TransferBuyBackWallet(_staking, _addr);
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _token: the address of the token to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _token) external onlyOwner {
        require(_token != address(token) && _token != dividendToken && _token != pair, "Cannot be token & dividend token, pair");

        if(_token == address(0x0)) {
            uint256 _tokenAmount = address(this).balance;
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            uint256 _tokenAmount = IERC20(_token).balanceOf(address(this));
            IERC20(_token).safeTransfer(msg.sender, _tokenAmount);
        }
    }


    /************************
    ** Internal Methods
    *************************/
    /*
     * @notice  get token from ETH via swap.
     */
    function _safeSwapEth(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal returns (uint256[] memory amounts) {
        amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length.sub(1)];

        IUniRouter02(uniRouterAddress).swapExactETHForTokensSupportingFeeOnTransferTokens{value: _amountIn}(
            amountOut.mul(slippageFactor).div(1000),
            _path,
            _to,
            block.timestamp.add(600)
        );
    }

    /*
     * @notice Add liquidity for token-BNB pair.
     */
    function _addLiquidityEth(
        address _token,
        uint256 _ethAmt,
        uint256 _tokenAmt,
        address _to
    ) internal returns(uint256 amountToken, uint256 amountETH, uint256 liquidity) {
        IERC20(_token).safeIncreaseAllowance(uniRouterAddress, _tokenAmt);

        (amountToken, amountETH, liquidity) = IUniRouter02(uniRouterAddress).addLiquidityETH{value: _ethAmt}(
            address(_token),
            _tokenAmt,
            0,
            0,
            _to,
            block.timestamp.add(600)
        );

        IERC20(_token).safeApprove(uniRouterAddress, uint256(0));
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This treasury contract has been developed by brewlabs.info
 */
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import "../libs/IUniFactory.sol";
import "../libs/IUniRouter02.sol";
import "../libs/IWETH.sol";

interface IStaking {
    function performanceFee() external view returns(uint256);
    function setServiceInfo(address _addr, uint256 _fee) external;
}

interface IFarm {
    function setBuyBackWallet(address _addr) external;
}

contract OgemTreasury is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Whether it is initialized
    bool private isInitialized;
    uint256 private TIME_UNIT = 1 days;

    IERC20  public token;
    address public dividendToken;
    address public pair;

    uint256 public period = 30;                         // 30 days
    uint256 public withdrawalLimit = 500;               // 5% of total supply
    uint256 public liquidityWithdrawalLimit = 2000;     // 20% of LP supply
    uint256 public buybackRate = 9500;                  // 95%
    uint256 public addLiquidityRate = 9400;             // 94%

    uint256 private startTime;
    uint256 private sumWithdrawals = 0;
    uint256 private sumLiquidityWithdrawals = 0;

    uint256 public performanceFee = 100;     // 1%
    uint256 public performanceLpFee = 200;   // 2%
    address public feeWallet = 0x408c4aDa67aE1244dfeC7D609dea3c232843189A;

    // swap router and path, slipPage
    address public uniRouterAddress;
    address[] public bnbToTokenPath;
    uint256 public slippageFactor = 830;    // 17%
    uint256 public constant slippageFactorUL = 995;

    event TokenBuyBack(uint256 amountETH, uint256 amountToken);
    event LiquidityAdded(uint256 amountETH, uint256 amountToken, uint256 liquidity);
    event SetSwapConfig(address router, uint256 slipPage, address[] path);
    event TransferBuyBackWallet(address staking, address wallet);
    event LiquidityWithdrawn(uint256 amount);
    event Withdrawn(uint256 amount);

    event AddLiquidityRateUpdated(uint256 percent);
    event BuybackRateUpdated(uint256 percent);
    event PeriodUpdated(uint256 duration);
    event LiquidityWithdrawLimitUpdated(uint256 percent);
    event WithdrawLimitUpdated(uint256 percent);
    event ServiceInfoUpdated(address wallet, uint256 performanceFee, uint256 liquidityFee);

    constructor() {}
   
    /**
     * @notice Initialize the contract
     * @param _token: token address
     * @param _dividendToken: reflection token address
     * @param _uniRouter: uniswap router address for swap tokens
     * @param _bnbToTokenPath: swap path to buy Token
     */
    function initialize(
        IERC20 _token,
        address _dividendToken,
        address _uniRouter,
        address[] memory _bnbToTokenPath
    ) external onlyOwner {
        require(!isInitialized, "Already initialized");

        // Make this contract initialized
        isInitialized = true;

        token = _token;
        dividendToken = _dividendToken;
        pair = IUniV2Factory(IUniRouter02(_uniRouter).factory()).getPair(_bnbToTokenPath[0], address(token));

        uniRouterAddress = _uniRouter;
        bnbToTokenPath = _bnbToTokenPath;
    }

    /**
     * @notice Buy token from BNB
     */
    function buyBack() external onlyOwner nonReentrant {
        uint256 ethAmt = address(this).balance;
        uint256 _fee = ethAmt * performanceFee / 10000;
        if(_fee > 0) {
            payable(feeWallet).transfer(_fee);
            ethAmt = ethAmt - _fee;
        }
        ethAmt = ethAmt * buybackRate / 10000;

        if(ethAmt > 0) {
            uint256[] memory amounts = _safeSwapEth(ethAmt, bnbToTokenPath, address(this));
            emit TokenBuyBack(amounts[0], amounts[amounts.length - 1]);
        }
    }

    
    /**
     * @notice Add liquidity
     */
    function addLiquidity() external onlyOwner nonReentrant {
        uint256 ethAmt = address(this).balance;
        uint256 _fee = ethAmt * performanceLpFee / 10000;
        if(_fee > 0) {
            payable(feeWallet).transfer(_fee);
            ethAmt = ethAmt - _fee;
        }
        ethAmt = ethAmt * addLiquidityRate / 10000 / 2;

        if(ethAmt > 0) {
            uint256[] memory amounts = _safeSwapEth(ethAmt, bnbToTokenPath, address(this));
            uint256 _tokenAmt = amounts[amounts.length - 1];
            emit TokenBuyBack(amounts[0], _tokenAmt);
            
            (uint256 amountToken, uint256 amountETH, uint256 liquidity) = _addLiquidityEth(address(token), ethAmt, _tokenAmt, address(this));
            emit LiquidityAdded(amountETH, amountToken, liquidity);
        }
    }


    /**
     * @notice Withdraw token as much as maximum 5% of total supply
     * @param _amount: amount to withdraw
     */
    function withdraw(uint256 _amount) external onlyOwner {
        uint256 tokenAmt = token.balanceOf(address(this));
        require(_amount > 0 && _amount <= tokenAmt, "Invalid Amount");

        if(block.timestamp - startTime > period * TIME_UNIT) {
            startTime = block.timestamp;
            sumWithdrawals = 0;
        }

        uint256 limit = withdrawalLimit * (token.totalSupply()) / 10000;
        require(sumWithdrawals + _amount <= limit, "exceed maximum withdrawal limit for 30 days");

        token.safeTransfer(msg.sender, _amount);
        emit Withdrawn(_amount);
    }

    /**
     * @notice Withdraw token as much as maximum 20% of lp supply
     * @param _amount: liquidity amount to withdraw
     */
    function withdrawLiquidity(uint256 _amount) external onlyOwner {
        uint256 tokenAmt = IERC20(pair).balanceOf(address(this));
        require(_amount > 0 && _amount <= tokenAmt, "Invalid Amount");

        if(block.timestamp - startTime > period * TIME_UNIT) {
            startTime = block.timestamp;
            sumLiquidityWithdrawals = 0;
        }

        uint256 limit = liquidityWithdrawalLimit * (IERC20(pair).totalSupply()) / 10000;
        require(sumLiquidityWithdrawals + _amount <= limit, "exceed maximum LP withdrawal limit for 30 days");

        IERC20(pair).safeTransfer(msg.sender, _amount);
        emit LiquidityWithdrawn(_amount);
    }
    
    /**
     * @notice Withdraw tokens
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external onlyOwner {
        uint256 tokenAmt = token.balanceOf(address(this));
        if(tokenAmt > 0) {
            token.transfer(msg.sender, tokenAmt);
        }

        tokenAmt = IERC20(pair).balanceOf(address(this));
        if(tokenAmt > 0) {
            IERC20(pair).transfer(msg.sender, tokenAmt);
        }

        uint256 ethAmt = address(this).balance;
        if(ethAmt > 0) {
            payable(msg.sender).transfer(ethAmt);
        }
    }

    /**
     * @notice Harvest reflection for token
     */
    function harvest() external onlyOwner {
        if(dividendToken == address(0x0)) {
            uint256 ethAmt = address(this).balance;
            if(ethAmt > 0) {
                payable(msg.sender).transfer(ethAmt);
            }
        } else {
            uint256 tokenAmt = IERC20(dividendToken).balanceOf(address(this));
            if(tokenAmt > 0) {
                IERC20(dividendToken).transfer(msg.sender, tokenAmt);
            }
        }
    }

    /**
     * @notice Set duration for withdraw limit
     * @param _period: duration
     */
    function setWithdrawalLimitPeriod(uint256 _period) external onlyOwner {
        require(_period >= 10, "small period");
        period = _period;
        emit PeriodUpdated(_period);
    }

    /**
     * @notice Set liquidity withdraw limit
     * @param _percent: percentage of LP supply in point
     */
    function setLiquidityWithdrawalLimit(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");
        
        liquidityWithdrawalLimit = _percent;
        emit LiquidityWithdrawLimitUpdated(_percent);
    }

    /**
     * @notice Set withdraw limit
     * @param _percent: percentage of total supply in point
     */
    function setWithdrawalLimit(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");
        
        withdrawalLimit = _percent;
        emit WithdrawLimitUpdated(_percent);
    }
    
    /**
     * @notice Set buyback rate
     * @param _percent: percentage in point
     */
    function setBuybackRate(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");

        buybackRate = _percent;
        emit BuybackRateUpdated(_percent);
    }

    /**
     * @notice Set addliquidy rate
     * @param _percent: percentage in point
     */
    function setAddLiquidityRate(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");

        addLiquidityRate = _percent;
        emit AddLiquidityRateUpdated(_percent);
    }

    function setServiceInfo(address _wallet, uint256 _fee) external {
        require(msg.sender == feeWallet, "Invalid setter");
        require(_wallet != feeWallet && _wallet != address(0x0), "Invalid new wallet");
        require(_fee < 500, "invalid performance fee");
       
        feeWallet = _wallet;
        performanceFee = _fee;
        performanceLpFee = _fee * 2;

        emit ServiceInfoUpdated(_wallet, performanceFee, performanceLpFee);
    }
    
    /**
     * @notice Set buyback wallet of farm contract
     * @param _uniRouter: dex router address
     * @param _slipPage: slip page for swap
     * @param _path: bnb-token swap path
     */
    function setSwapSettings(address _uniRouter, uint256 _slipPage, address[] memory _path) external onlyOwner {
        require(_slipPage < 1000, "Invalid percentage");

        uniRouterAddress = _uniRouter;
        slippageFactor = _slipPage;
        bnbToTokenPath = _path;

        emit SetSwapConfig(_uniRouter, _slipPage, _path);
    }

    /**
     * @notice set buyback wallet of farm contract
     * @param _farm: farm contract address
     * @param _addr: buyback wallet address
     */
    function setFarmServiceInfo(address _farm, address _addr) external onlyOwner {
        require(_farm != address(0x0) && _addr != address(0x0), "Invalid Address");
        IFarm(_farm).setBuyBackWallet(_addr);

        emit TransferBuyBackWallet(_farm, _addr);
    }

    /**
     * @notice set buyback wallet of staking contract 
     * @param _staking: staking contract address
     * @param _addr: buyback wallet address
     */
    function setStakingServiceInfo(address _staking, address _addr) external onlyOwner {
        require(_staking != address(0x0) && _addr != address(0x0), "Invalid Address");
        uint256 _fee = IStaking(_staking).performanceFee();
        IStaking(_staking).setServiceInfo(_addr, _fee);

        emit TransferBuyBackWallet(_staking, _addr);
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _token: the address of the token to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _token) external onlyOwner {
        require(_token != address(token) && _token != dividendToken && _token != pair, "Cannot be token & dividend token, pair");

        if(_token == address(0x0)) {
            uint256 _tokenAmount = address(this).balance;
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            uint256 _tokenAmount = IERC20(_token).balanceOf(address(this));
            IERC20(_token).safeTransfer(msg.sender, _tokenAmount);
        }
    }


    /************************
    ** Internal Methods
    *************************/
    /*
     * @notice get token from ETH via swap.
     */
    function _safeSwapEth(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal returns (uint256[] memory amounts) {
        amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length - 1];

        IUniRouter02(uniRouterAddress).swapExactETHForTokensSupportingFeeOnTransferTokens{value: _amountIn}(
            amountOut * slippageFactor / 1000,
            _path,
            _to,
            block.timestamp + 600
        );
    }

    /*
     * @notice Add liquidity for Token-BNB pair.
     */
    function _addLiquidityEth(
        address _token,
        uint256 _ethAmt,
        uint256 _tokenAmt,
        address _to
    ) internal returns(uint256 amountToken, uint256 amountETH, uint256 liquidity) {
        IERC20(_token).safeIncreaseAllowance(uniRouterAddress, _tokenAmt);

        (amountToken, amountETH, liquidity) = IUniRouter02(uniRouterAddress).addLiquidityETH{value: _ethAmt}(
            address(_token),
            _tokenAmt,
            0,
            0,
            _to,
            block.timestamp + 600
        );

        IERC20(_token).safeApprove(uniRouterAddress, uint256(0));
    }


    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This contract has been developed by brewlabs.info
 */
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

contract WanchorTeamLocker is Ownable{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool public isActive = false;
    bool private initialized = false;

    IERC20 public token;
    address public reflectionToken;
    uint256 public totalLocked;

    uint256 public lockDuration = 180; // 180 days
    uint256 private accReflectionPerShare;
    uint256 private allocatedReflections;
    uint256 private processingLimit = 30;

    uint256 private PRECISION_FACTOR = 1 ether;
    uint256 constant MAX_STAKES = 256;

    struct Lock {
        uint256 amount;              // locked amount
        uint256 duration;            // team member can claim after duration in days
        uint256 releaseTime;
    }

    struct UserInfo {
        uint256 amount;         // total locked amount
        uint256 firstIndex;     // first index for unlocked elements
        uint256 reflectionDebt; // Reflection debt
    }
   
    mapping(address => Lock[]) public locks;
    mapping(address => UserInfo) public userInfo;
    address[] public members;
    mapping(address => bool) private isMember;

    event Deposited(address member, uint256 amount, uint256 duration);
    event Released(address member, uint256 amount);
    event LockDurationUpdated(uint256 duration);
        
    modifier onlyActive() {
        require(isActive == true, "not active");
        _;
    }

    constructor () {}

    function initialize(IERC20 _token, address _reflectionToken) external onlyOwner {
        require(initialized == false, "already initialized");
        initialized = true;

        token = _token;
        reflectionToken = _reflectionToken;
    }

    function deposit(uint256 amount) external onlyActive {
        require(amount > 0, "Invalid amount");

        _updatePool();

        UserInfo storage user = userInfo[msg.sender];        
        uint256 pending = user.amount.mul(accReflectionPerShare).div(PRECISION_FACTOR).sub(user.reflectionDebt);
        if (pending > 0) {
            if(reflectionToken == address(0x0)) {
                payable(msg.sender).transfer(pending);
            } else {
                IERC20(reflectionToken).safeTransfer(address(msg.sender), pending);
            }
            allocatedReflections = allocatedReflections.sub(pending);
        }
        
        uint256 beforeAmount = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), amount);
        uint256 afterAmount = token.balanceOf(address(this));
        uint256 realAmount = afterAmount.sub(beforeAmount);
        
        _addLock(msg.sender, realAmount, user.firstIndex);
        
        if(isMember[msg.sender] == false) {
            members.push(msg.sender);
            isMember[msg.sender] = true;
        }

        user.amount = user.amount.add(realAmount);
        user.reflectionDebt = user.amount.mul(accReflectionPerShare).div(PRECISION_FACTOR);

        totalLocked = totalLocked.add(realAmount);

        emit Deposited(msg.sender, amount, lockDuration);
    }

    function _addLock(address _account, uint256 _amount, uint256 firstIndex) internal {
        Lock[] storage _locks = locks[_account];

        uint256 releaseTime = block.timestamp.add(lockDuration.mul(1 days));
        uint256 i = _locks.length;

        require(i < MAX_STAKES, "Max Locks");

        _locks.push(); // grow the array
        // find the spot where we can insert the current stake
        // this should make an increasing list sorted by end
        while (i != 0 && _locks[i - 1].releaseTime > releaseTime && i >= firstIndex) {
            // shift it back one
            _locks[i] = _locks[i - 1];
            i -= 1;
        }
        
        // insert the stake
        Lock storage _lock = _locks[i];
        _lock.amount = _amount;
        _lock.duration = lockDuration;
        _lock.releaseTime = releaseTime;
    }


    function harvest() external onlyActive {
        _updatePool();

        UserInfo storage user = userInfo[msg.sender];        
        uint256 pending = user.amount.mul(accReflectionPerShare).div(PRECISION_FACTOR).sub(user.reflectionDebt);
        if (pending > 0) {
            if(reflectionToken == address(0x0)) {
                payable(msg.sender).transfer(pending);
            } else {
                IERC20(reflectionToken).safeTransfer(address(msg.sender), pending);
            }
            allocatedReflections = allocatedReflections.sub(pending);
        }
        
        user.reflectionDebt = user.amount.mul(accReflectionPerShare).div(PRECISION_FACTOR);
    }

    function release() public onlyActive {
        _updatePool();

        UserInfo storage user = userInfo[msg.sender];
        Lock[] storage _locks = locks[msg.sender];
        
        bool bUpdatable = true;
        uint256 firstIndex = user.firstIndex;
        
        uint256 claimAmt = 0;
        for(uint256 i = user.firstIndex; i < _locks.length; i++) {
            Lock storage _lock = _locks[i];

            if(bUpdatable && _lock.amount == 0) firstIndex = i;
            if(_lock.amount == 0) continue;
            if(_lock.releaseTime > block.timestamp) {
                bUpdatable = false;
                continue;
            }

            if(i - user.firstIndex > processingLimit) break;

            claimAmt = claimAmt.add(_lock.amount);
            _lock.amount = 0;

            firstIndex = i;
        }

        if(claimAmt > 0) {
            token.safeTransfer(msg.sender, claimAmt);
            emit Released(msg.sender, claimAmt);
        }
        
        uint256 reflectionAmt = user.amount.mul(accReflectionPerShare).div(PRECISION_FACTOR).sub(user.reflectionDebt);
        if(reflectionAmt > 0) {
            if(reflectionToken == address(0x0)) {
                payable(msg.sender).transfer(reflectionAmt);
            } else {
                IERC20(reflectionToken).safeTransfer(msg.sender, reflectionAmt);
            }
            allocatedReflections = allocatedReflections.sub(reflectionAmt);
        }

        user.amount = user.amount.sub(claimAmt);
        user.reflectionDebt = user.amount.mul(accReflectionPerShare).div(PRECISION_FACTOR);

        totalLocked = totalLocked.sub(claimAmt);
    }

    function pendingReflection(address _user) external view returns (uint256) {
        if(totalLocked == 0) return 0;

        uint256 reflectionAmt = availableRelectionTokens();
        reflectionAmt = reflectionAmt.sub(allocatedReflections);
        uint256 _accReflectionPerShare = accReflectionPerShare.add(reflectionAmt.mul(PRECISION_FACTOR).div(totalLocked));

        UserInfo memory user = userInfo[_user];
        uint256 pending = user.amount.mul(_accReflectionPerShare).div(PRECISION_FACTOR).sub(user.reflectionDebt);
        return pending;
    }

    function pendingTokens(address _user) public view returns (uint256) {
        Lock[] memory _locks = locks[_user];
        UserInfo memory user = userInfo[_user];

        uint256 claimAmt = 0;
        for(uint256 i = user.firstIndex; i < _locks.length; i++) {
            Lock memory _lock = _locks[i];
            if(_lock.amount == 0) continue;
            if(_lock.releaseTime > block.timestamp) continue;

            claimAmt = claimAmt.add(_lock.amount);
        }

        return claimAmt;
    }

    function totalLockedforUser(address _user) public view returns (uint256) {
        UserInfo memory user = userInfo[_user];
        return user.amount;
    }

    function setStatus(bool _isActive) external onlyOwner {
        isActive = _isActive;
    }

    function updateLockDuration(uint256 _duration) external onlyOwner {
        lockDuration = _duration;
        emit LockDurationUpdated(_duration);
    }

    function setProcessingLimit(uint256 _limit) external onlyOwner {
        require(_limit > 0, "Invalid limit");
        processingLimit = _limit;
    }

    function emergencyWithdraw() external onlyOwner {
        uint256 tokenAmt = token.balanceOf(address(this));
        if(tokenAmt > 0) {
            token.transfer(msg.sender, tokenAmt);
        }

        if(address(token) == reflectionToken) return;

        uint256 reflectionAmt = address(this).balance;
        if(reflectionToken != address(0x0)) {
            reflectionAmt = IERC20(reflectionToken).balanceOf(address(this));
        }

        if(reflectionAmt > 0) {
            if(reflectionToken == address(0x0)) {
                payable(msg.sender).transfer(reflectionAmt);
            } else {
                IERC20(reflectionToken).transfer(msg.sender, reflectionAmt);
            }
        }
    }

    function recoverWrongToken(address _tokenAddress) external onlyOwner {
        require(_tokenAddress != address(token), "Cannot recover locked token");
        require(_tokenAddress != reflectionToken, "Cannot recover reflection token");

        if(_tokenAddress == address(0x0)) {
            uint256 amount = address(this).balance;
            payable(msg.sender).transfer(amount);
        } else {
            uint256 amount = IERC20(_tokenAddress).balanceOf(address(this));
            IERC20(_tokenAddress).safeTransfer(address(msg.sender), amount);
        }
    }

    function availableRelectionTokens() internal view returns (uint256) {
        uint256 _amount = address(this).balance;
        if(reflectionToken != address(0x0)) {
            _amount = IERC20(reflectionToken).balanceOf(address(this));

            if (address(token) == reflectionToken) {
                if (_amount < totalLocked) return 0;            
                return _amount.sub(totalLocked);
            }
        }

        return _amount;
    }

    function _updatePool() internal {
        if(totalLocked == 0) return;

        uint256 reflectionAmt = availableRelectionTokens();
        reflectionAmt = reflectionAmt.sub(allocatedReflections);

        accReflectionPerShare = accReflectionPerShare.add(reflectionAmt.mul(PRECISION_FACTOR).div(totalLocked));
        allocatedReflections = allocatedReflections.add(reflectionAmt);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @author Brewlabs
 * This contract has been developed by brewlabs.info
 */
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract ZenaMigration is Ownable, ReentrancyGuard {
  using SafeERC20 for IERC20;

  IERC20 public oldToken;
  IERC20 public newToken;

  bytes32 private merkleRoot;
  bytes32 private claimMerkleRoot;
  uint256 private totalStaked;

  bool public claimable = false;

  struct UserInfo {
    uint256 amount;
    uint256 paidAmount;
  }
  mapping(address => UserInfo) public userInfo;

  event Deposit(address user, uint256 amount);
  event Claim(address user, uint256 amount);

  event claimEnabled();
  event HarvestOldToken(uint256 amount);
  event SetMigrationToken(address token);
  event SetSnapShot(bytes32 merkleRoot, bytes32 claimMerkleRoot);

  modifier canClaim() {
    require(claimable, "cannot claim");
    _;
  }

  /**
   * @notice Initialize the contract
   * @param _oldToken: token address
   * @param _newToken: reflection token address
   */
  constructor(address _oldToken, address _newToken) {
    oldToken = IERC20(_oldToken);
    newToken = IERC20(_newToken);
  }

  function deposit(uint256 _amount, bytes32[] memory _merkleProof) external nonReentrant {
    require(merkleRoot != "", "Migration not enabled");
    require(userInfo[msg.sender].amount == 0, "already migrated");

    // Verify the merkle proof.
    bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _amount));
    require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "Invalid merkle proof.");

    oldToken.safeTransferFrom(msg.sender, address(this), _amount);

    UserInfo storage user = userInfo[msg.sender];
    user.amount = _amount;
    totalStaked += _amount;

    emit Deposit(msg.sender, _amount);
  }

  function claim(uint256 _amount, bytes32[] memory _merkleProof) external nonReentrant {
    UserInfo storage user = userInfo[msg.sender];
    require(claimable, "claim not enabled");
    require(user.amount > 0, "not migrate yet");
    require(user.paidAmount == 0, "already claimed");

    // Verify the merkle proof.
    bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _amount));
    require(MerkleProof.verify(_merkleProof, claimMerkleRoot, leaf), "Invalid merkle proof.");

    user.paidAmount = _amount;
    newToken.safeTransfer(msg.sender, _amount);

    emit Claim(msg.sender, _amount);
  }

  function setMigrationToken(address _newToken) external onlyOwner {
    require(!claimable, "claim was enabled");
    require(_newToken != address(0x0) && _newToken != address(newToken), "invalid new token");
    require(_newToken != address(oldToken), "cannot set old token address");

    newToken = IERC20(_newToken);
    emit SetMigrationToken(_newToken);
  }

  function setMerkleRoot(bytes32 _merkleRoot, bytes32 _claimMerkleRoot) external onlyOwner {
    merkleRoot = _merkleRoot;
    claimMerkleRoot = _claimMerkleRoot;
    emit SetSnapShot(_merkleRoot, _claimMerkleRoot);
  }

  function enableClaim() external onlyOwner {
    require(!claimable, "already enabled");
    claimable = true;
    emit claimEnabled();
  }

  function harvestOldToken() external onlyOwner {
    uint256 amount = oldToken.balanceOf(address(this));
    oldToken.safeTransfer(msg.sender, amount);
    emit HarvestOldToken(amount);
  }

  /**
   * @notice It allows the admin to recover wrong tokens sent to the contract
   * @param _token: the address of the token to withdraw
   * @param _amount: the amount to withdraw, if amount is zero, all tokens will be withdrawn
   * @dev This function is only callable by admin.
   */
  function rescueTokens(address _token, uint256 _amount) external onlyOwner {
    if (_token == address(0x0)) {
      if (_amount > 0) {
        payable(msg.sender).transfer(_amount);
      } else {
        uint256 _tokenAmount = address(this).balance;
        payable(msg.sender).transfer(_tokenAmount);
      }
    } else {
      if (_amount > 0) {
        IERC20(_token).safeTransfer(msg.sender, _amount);
      } else {
        uint256 _tokenAmount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, _tokenAmount);
      }
    }
  }

  receive() external payable {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merklee tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @author Brewlabs
 * This contract has been developed by brewlabs.info
 */
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkelRootTest is Ownable {
  bytes32 private merkleRoot;

  function check(
    address _addr,
    uint256 _max,
    bytes32[] memory _merkleProof
  ) external view returns (bool) {
    require(merkleRoot != "", "Migration not enabled");

    // Verify the merkle proof.
    bytes32 leaf = keccak256(abi.encodePacked(_addr, _max));
    return MerkleProof.verify(_merkleProof, merkleRoot, leaf);
  }

  function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
    merkleRoot = _merkleRoot;
  }
  receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/Pausable.sol';

contract Whitelist is Ownable, Pausable {
    
  mapping (address => bool) private whitelistedMap;

  event Whitelisted(address indexed account, bool isWhitelisted);

  function whitelisted(address _address) external view returns (bool) {
    if (paused()) {
      return false;
    }

    return whitelistedMap[_address];
  }

  function addAddress(address _address) external onlyOwner {
    require(whitelistedMap[_address] != true);
    whitelistedMap[_address] = true;
    emit Whitelisted(_address, true);
  }

  function addAddresses(address[] memory _addresses) external onlyOwner {
    for(uint i = 0; i < _addresses.length; i++) {
        whitelistedMap[_addresses[i]] = true;
        emit Whitelisted(_addresses[i], true);
    }
  }

  function removeAddress(address _address) external onlyOwner {
    require(whitelistedMap[_address] != false);
    whitelistedMap[_address] = false;
    emit Whitelisted(_address, false);
  }

  function pause() external onlyOwner {
    _pause();
  }

  function unpause() external onlyOwner {
    _unpause();
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../utils/Context.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This contract has been developed by brewlabs.info
 */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract BlocVestX is ERC20Burnable, Ownable {
    mapping(address => bool) isMinter;

    event AddMinter(address minter);
    event RemoveMinter(address minter);

    modifier onlyMinter() {
        require(isMinter[msg.sender], "not minter");
        _;
    }
    constructor() ERC20("BlocVestX", "BVSTX") {}

    function mint(address _to, uint256 _amount) external onlyMinter {
        _mint(_to, _amount);
    }

    function addMinter(address _minter) external onlyOwner {
        isMinter[_minter] = true;
        emit AddMinter(_minter);
    }

    function removeMinter(address _minter) external onlyOwner {
        isMinter[_minter] = false;
        emit RemoveMinter(_minter);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This contract has been developed by brewlabs.info
 */
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

contract MetaMerceLocker is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool private initialized = false;

    IERC20 public token;
    address public reflectionToken;
    uint256 public lockDuration = 90;

    uint256 private accReflectionPerShare;
    uint256 private allocatedReflections;
    uint256 private totalAllocated;
    uint256 public totalDistributed;

    uint256 private constant PRECISION_FACTOR = 1 ether;

    struct Distribution {
        address distributor;        // distributor address
        uint256 alloc;              // allocation token amount
        uint256 unlockBlock;         // block number to unlock
        bool claimed;
    }
   
    mapping(address => Distribution) public distributions;
    mapping(address => bool) isDistributor;
    address[] public distributors;

    event AddDistribution(address indexed distributor, uint256 allocation, uint256 duration, uint256 unlockBlock);
    event UpdateDistribution(address indexed distributor, uint256 allocation, uint256 duration, uint256 unlockBlock);
    event WithdrawDistribution(address indexed distributor, uint256 amount, uint256 reflection);
    event RemoveDistribution(address indexed distributor);
    event UpdateLockDuration(uint256 Days);

    constructor () {}

    function initialize(IERC20 _token, address _reflectionToken) external onlyOwner {
        require(!initialized, "already initialized");
        initialized = true;

        token = _token;
        reflectionToken = _reflectionToken;
    }

    function addDistribution(address distributor, uint256 allocation) external onlyOwner {
        require(!isDistributor[distributor], "already set");

        isDistributor[distributor] = true;
        distributors.push(distributor);

        uint256 allocationAmt = allocation.mul(10**IERC20Metadata(address(token)).decimals());
        
        Distribution storage _distribution = distributions[distributor];
        _distribution.distributor = distributor;
        _distribution.alloc = allocationAmt;
        _distribution.unlockBlock = block.number.add(lockDuration.mul(28800));

        totalDistributed += allocationAmt;

        emit AddDistribution(distributor, allocationAmt, lockDuration, _distribution.unlockBlock);
    }

    function removeDistribution(address distributor) external onlyOwner {
        require(isDistributor[distributor], "Not found");
        require(!distributions[distributor].claimed, "Already claimed");

        isDistributor[distributor] = false;
        totalDistributed -= distributions[distributor].alloc;

        Distribution storage _distribution = distributions[distributor];
        _distribution.distributor = address(0x0);
        _distribution.alloc = 0;
        _distribution.unlockBlock = 0;

        emit RemoveDistribution(distributor);
    }

    function updateDistribution(address distributor, uint256 allocation) external onlyOwner {
        require(isDistributor[distributor] == true, "Not found");

        Distribution storage _distribution = distributions[distributor];
        require(!_distribution.claimed, "already withdrawn");
        require(_distribution.unlockBlock > block.number, "cannot update");
        
        uint256 allocationAmt = allocation.mul(10**IERC20Metadata(address(token)).decimals());
        totalDistributed += allocationAmt - _distribution.alloc;

        _distribution.distributor = distributor;
        _distribution.alloc = allocationAmt;
        _distribution.unlockBlock = block.number.add(lockDuration.mul(28800));

        emit UpdateDistribution(distributor, allocationAmt, lockDuration, _distribution.unlockBlock);
    }

    function withdrawDistribution(address _user) external onlyOwner {
        require(claimable(_user) == true, "not claimable");
        
        _updatePool();

        Distribution storage _distribution = distributions[_user];
        uint256 pending = _distribution.alloc.mul(accReflectionPerShare).div(PRECISION_FACTOR);
        if(pending > 0) {
            IERC20(reflectionToken).safeTransfer(_user, pending);
            allocatedReflections = allocatedReflections.sub(pending);
        }

        totalDistributed -= _distribution.alloc;
        _distribution.claimed = true;
        if(totalAllocated > _distribution.alloc) {
            totalAllocated = totalAllocated - _distribution.alloc;
        } else {
            totalAllocated = 0;
        }

        token.safeTransfer(_distribution.distributor, _distribution.alloc);

        emit WithdrawDistribution(_distribution.distributor, _distribution.alloc, pending);
    }

    function pendingReflection(address _user) external view returns (uint256) {
        if(isDistributor[_user] == false) return 0;
        if(totalDistributed == 0) return 0;

        uint256 reflectionAmt = availableDividendTokens();
        if(reflectionAmt < allocatedReflections) return 0;

        reflectionAmt = reflectionAmt.sub(allocatedReflections);
        uint256 _accReflectionPerShare = accReflectionPerShare.add(reflectionAmt.mul(PRECISION_FACTOR).div(totalDistributed));
        
        Distribution storage _distribution = distributions[_user];
        if(_distribution.claimed) return 0;
        return _distribution.alloc.mul(_accReflectionPerShare).div(PRECISION_FACTOR);
    }

    function claimable(address _user) public view returns (bool) {
        if(!isDistributor[_user]) return false;
        if(distributions[_user].claimed) return false;
        if(distributions[_user].unlockBlock < block.number) return true;

        return false;
    }

    function availableAllocatedTokens() public view returns (uint256) {
        if(address(token) == reflectionToken) return totalAllocated;
        return token.balanceOf(address(this));
    }

    function availableDividendTokens() public view returns (uint256) {
        if(reflectionToken == address(0x0)) {
            return address(this).balance;
        }

        uint256 _amount = IERC20(reflectionToken).balanceOf(address(this));        
        if(reflectionToken == address(token)) {
            if(_amount < totalAllocated) return 0;
            _amount = _amount - totalAllocated;
        }

        return _amount;
    }

    function setLockDuration(uint256 _days) external onlyOwner {
        require(_days > 0, "Invalid duration");

        lockDuration = _days;
        emit UpdateLockDuration(_days);
    }

    function depositToken(uint256 _amount) external onlyOwner {
        require(_amount > 0, "invalid amount");

        uint256 beforeAmt = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = token.balanceOf(address(this));

        totalAllocated = totalAllocated + afterAmt - beforeAmt;
    }

    function emergencyWithdraw() external onlyOwner {
        uint256 tokenAmt = token.balanceOf(address(this));
        if(tokenAmt > 0) {
            token.transfer(msg.sender, tokenAmt);
        }

        uint256 reflectionAmt = IERC20(reflectionToken).balanceOf(address(this));
        if(reflectionAmt > 0) {
            IERC20(reflectionToken).transfer(msg.sender, reflectionAmt);
        }
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _token: the address of the token to withdraw
     * @dev This function is only callable by admin.
     */
    function rescueTokens(address _token) external onlyOwner {
        require(_token != address(token) && _token != address(reflectionToken), "Cannot be token & dividend token");

        if(_token == address(0x0)) {
            uint256 _tokenAmount = address(this).balance;
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            uint256 _tokenAmount = IERC20(_token).balanceOf(address(this));
            IERC20(_token).safeTransfer(msg.sender, _tokenAmount);
        }
    }

    function _updatePool() internal {
        if(totalDistributed == 0) return;

        uint256 reflectionAmt = availableDividendTokens();
        if(reflectionAmt < allocatedReflections) return;
        reflectionAmt = reflectionAmt - allocatedReflections;

        accReflectionPerShare = accReflectionPerShare.add(reflectionAmt.mul(PRECISION_FACTOR).div(totalDistributed));
        allocatedReflections = allocatedReflections.add(reflectionAmt);
    }
    
    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
pragma abicoder v2;

/**
 * @author Brewlabs
 * This treasury contract has been developed by brewlabs.info
 */
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

interface IJigsawToken {
    function getNumberOfTokenHolders() external view returns(uint256);
    function getTokenHolderAtIndex(uint256 accountIndex) external view returns(address);
    function balanceOf(address account) external view returns (uint256);
}
interface IPegSwap{
    function swap(uint256 amount, address source, address target) external;
    function getSwappableAmount(address source, address target) external view returns(uint);
}

contract JigsawDistributor is ReentrancyGuard, VRFConsumerBaseV2, Ownable {
    using SafeERC20 for IERC20;

    VRFCoordinatorV2Interface COORDINATOR;
    LinkTokenInterface LINKTOKEN;

    bool public initialized = false;
    IJigsawToken public jigsawToken;

    uint64 public s_subscriptionId;

    bytes32 keyHash;
    uint32 callbackGasLimit = 150000;
    uint16 requestConfirmations = 3;
    uint32 numWords =  3;

    uint256 public s_requestId;
    uint256 public r_requestId;
    uint256[] public s_randomWords;

    struct TheOfferingResult {
        address[3] winner;
        uint256[3] amount;
    }
    uint256 public theOfferingID;
    uint256 public theOfferingRate = 2500;
    uint256[3] public theOfferingHolderRates = [6000, 2500, 1000];
    mapping(uint256 => TheOfferingResult) private theOfferingResults;
    uint256 public winnerBalanceLimit = 20000 * 1 ether;

    mapping(address => bool) private isWinner;
    address[] private winnerList;
    uint256 public oneTimeResetCount = 1000;

    address[3] public wallets;
    uint256[3] public rates = [2500, 2000, 2500];
    
    // BSC Mainnet ERC20_LINK_ADDRESS
    address public constant ERC20_LINK_ADDRESS = 0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39;
    address public constant PEGSWAP_ADDRESS = 0xF8A0BF9cF54Bb92F17374d9e9A321E6a111a51bD;

    event SetDistributors(address walletA, address walletB, address walletC);
    event SetDistributorRates(uint256 rateA, uint256 rateB, uint256 rateC);
    event SetTheOfferingRate(uint256 rate);
    event SetTheOfferingHolderRates(uint256 rateA, uint256 rateB, uint256 rateC);
    event SetWinnerBalanceLimit(uint256 amount);
    event Distributed(uint256 amountA, uint256 amountB, uint256 amountC);
    event HolderDistributed(uint256 triadID, address[3] winners, uint256[3] amounts);
    event SetOneTimeResetCount(uint256 num);
    event ResetWinnerList();

    /**
     * @notice Constructor
     * @dev RandomNumberGenerator must be deployed prior to this contract
     */
    constructor(address _vrfCoordinator, address _link, bytes32 _keyHash) VRFConsumerBaseV2(_vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        s_subscriptionId = COORDINATOR.createSubscription();
        keyHash = _keyHash;

        COORDINATOR.addConsumer(s_subscriptionId, address(this));
        LINKTOKEN = LinkTokenInterface(_link);
    }

    /**
     * @notice Initialize the contract
     * @dev This function must be called by the owner of the contract.
     */
    function initialize(address _token, address[3] memory _wallets) external onlyOwner {
        require(!initialized, "Contract already initialized");
        initialized = true;

        jigsawToken = IJigsawToken(_token);
        wallets = _wallets;
    }

    /**
     * @notice Distribute the ETH to the three distributors
     * @dev This function must be called by the owner of the contract.
     */
    function callDistributor() external onlyOwner {
        require(initialized, "Contract not initialized");

        uint256 amount = address(this).balance;
        require(amount > 3, "Not enough ETH to distribute");

        uint256 amountA = amount * rates[0] / 10000;
        uint256 amountB = amount * rates[1] / 10000;
        uint256 amountC = amount * rates[2] / 10000;
        payable(wallets[0]).transfer(amountA);
        payable(wallets[1]).transfer(amountB);
        payable(wallets[2]).transfer(amountC);

        emit Distributed(amountA, amountB, amountC);
    }

    /**
     * @notice Distribute the prizes to the three winners
     * @dev This function must be called by the owner of the contract.
     */
    function callTheOffering() external onlyOwner {
        require(initialized, "Contract not initialized");
        require(s_requestId == r_requestId, "Request IDs do not match");
        require(s_randomWords.length == numWords, "Number of words does not match");

        uint256 numHolders = jigsawToken.getNumberOfTokenHolders();
        require(numHolders > 3, "Not enough token holders");

        s_requestId = 0;
        
        uint256[3] memory idx;
        uint256[3] memory sortedIdx;
        for(uint i = 0; i < 3; i++) {
            idx[i] = s_randomWords[i] % (numHolders - i);
            for(uint j = 0; j < i; j++) {
                if (idx[i] >= sortedIdx[j]) {
                    idx[i] = idx[i] + 1;
                } else {
                    break;
                }
            }

            idx[i] = idx[i] % numHolders;
            sortedIdx[i] = idx[i];
            if(i > 0 && sortedIdx[i] < sortedIdx[i - 1]) {
                uint256 t = sortedIdx[i];
                sortedIdx[i] = sortedIdx[i - 1];
                sortedIdx[i - 1] = t;
            }
        }

        theOfferingID = theOfferingID + 1;        
        TheOfferingResult storage triadResult = theOfferingResults[theOfferingID];

        uint256 amount = address(this).balance;
        amount = amount * theOfferingRate / 10000;
        for(uint i = 0; i < 3; i++) {
            address winnerA = jigsawToken.getTokenHolderAtIndex(idx[i]);
            triadResult.winner[i] = winnerA;

            if(isWinner[winnerA]) continue;
            isWinner[winnerA] = true;
            winnerList.push(winnerA);

            if(isContract(winnerA)) continue;
            if(jigsawToken.balanceOf(winnerA) < winnerBalanceLimit) continue;

            uint256 amountA = amount * theOfferingHolderRates[i] / 10000;
            triadResult.amount[i] = amountA;
            payable(winnerA).transfer(amountA);
        }

        emit HolderDistributed(theOfferingID, triadResult.winner, triadResult.amount);
    }

    function offeringResult(uint256 _id) external view returns(address[3] memory, uint256[3] memory) {
        return (theOfferingResults[_id].winner, theOfferingResults[_id].amount);
    }

    function totalWinners() external view returns(uint256) {
        return winnerList.length;
    }

    function resetWinnerList() external onlyOwner {
        uint count = winnerList.length;
        for(uint i = 0; i < count; i++) {
            if(i >= oneTimeResetCount) break;
            
            address winner = winnerList[winnerList.length - 1];
            isWinner[winner] = false;
            winnerList.pop();
        }

        emit ResetWinnerList();
    }

    function setOneTimeResetCount(uint256 num) external onlyOwner {
        oneTimeResetCount = num;
        emit SetOneTimeResetCount(num);
    }

    /**
     * @notice Set the distribution rates for the three wallets
     * @dev This function must be called by the owner of the contract.
     */
    function setDistributorRates(uint256 _rateA, uint256 _rateB, uint256 _rateC) external onlyOwner {        
        require(_rateA > 0, "Rate A must be greater than 0");
        require(_rateB > 0, "Rate B must be greater than 0");
        require(_rateC > 0, "Rate C must be greater than 0");
        require(_rateA + _rateB + _rateC < 10000, "Total rate must be less than 10000");

        rates = [_rateA, _rateB, _rateC];
        emit SetDistributorRates(_rateA, _rateB, _rateC);
    }

    /**
     * @notice Set the three wallets for the distribution
     * @dev This function must be called by the owner of the contract.
     */
    function setWallets(address[3] memory _wallets) external onlyOwner {
        require(initialized, "Contract not initialized");

        require(_wallets[0] != address(0), "Wallet A must be set");
        require(_wallets[1] != address(0), "Wallet B must be set");
        require(_wallets[2] != address(0), "Wallet C must be set");
        require(_wallets[0] != _wallets[1], "Wallet A and B must be different");
        require(_wallets[0] != _wallets[2], "Wallet A and C must be different");
        require(_wallets[1] != _wallets[2], "Wallet B and C must be different");

        wallets = _wallets;
        emit SetDistributors(wallets[0], wallets[1], wallets[2]);
    }

    /**
     * @notice Set the distribution rate for the three wallets
     * @dev This function must be called by the owner of the contract.
     */
    function setTheOfferingRate(uint256 _rate) external onlyOwner {
        require(_rate > 0, "Rate must be greater than 0");
        theOfferingRate = _rate;
        emit SetTheOfferingRate(_rate);
    }
    
    /**
     * @notice Set the minimum balance to receive ETH from call offering
     * @dev This function must be called by the owner of the contract.
     */
    function setWinnerBalanceLimit(uint256 _min) external onlyOwner {
        winnerBalanceLimit = _min * 1 ether;
        emit SetWinnerBalanceLimit(winnerBalanceLimit);
    }

    /**
     * @notice Set the distribution rates for three winners
     * @dev This function must be called by the owner of the contract.
     */
    function setTheOfferingHolderRates(uint256 _rateA, uint256 _rateB, uint256 _rateC) external onlyOwner {
        require(_rateA > 0, "Rate A must be greater than 0");
        require(_rateB > 0, "Rate B must be greater than 0");
        require(_rateC > 0, "Rate C must be greater than 0");
        require(_rateA + _rateB + _rateC < 10000, "Total rate must be less than 10000");

        theOfferingHolderRates = [_rateA, _rateB, _rateC];
        emit SetTheOfferingHolderRates(_rateA, _rateB, _rateC);
    }

    function setCoordiatorConfig(bytes32 _keyHash, uint32 _gasLimit, uint32 _numWords ) external onlyOwner {
        keyHash = _keyHash;
        callbackGasLimit = _gasLimit;
        numWords = _numWords;
    }

    /**
     * @notice fetch subscription information from the VRF coordinator
     */
    function getSubscriptionInfo() external view returns (uint96 balance, uint64 reqCount, address owner, address[] memory consumers) {
        return COORDINATOR.getSubscription(s_subscriptionId);
    }

    /**
     * @notice cancle subscription from the VRF coordinator
     * @dev This function must be called by the owner of the contract.
     */
    function cancelSubscription() external onlyOwner {
        COORDINATOR.cancelSubscription(s_subscriptionId, msg.sender);
        s_subscriptionId = 0;
    }

    /**
     * @notice subscribe to the VRF coordinator
     * @dev This function must be called by the owner of the contract.
     */
    function startSubscription(address _vrfCoordinator) external onlyOwner {
        require(s_subscriptionId == 0, "Subscription already started");

        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        s_subscriptionId = COORDINATOR.createSubscription();
        COORDINATOR.addConsumer(s_subscriptionId, address(this));
    }

    /**
     * @notice Fund link token from the VRF coordinator for subscription
     * @dev This function must be called by the owner of the contract.
     */
    function fundToCoordiator(uint96 _amount) external onlyOwner {
        LINKTOKEN.transferFrom(msg.sender, address(this), _amount);
        LINKTOKEN.transferAndCall(
            address(COORDINATOR),
            _amount,
            abi.encode(s_subscriptionId)
        );
    }

    /**
     * @notice Fund link token from the VRF coordinator for subscription
     * @dev This function must be called by the owner of the contract.
     */
    function fundPeggedLinkToCoordiator(uint256 _amount) external onlyOwner {
        IERC20(ERC20_LINK_ADDRESS).transferFrom(msg.sender, address(this), _amount);
        IERC20(ERC20_LINK_ADDRESS).approve(PEGSWAP_ADDRESS, _amount);
        IPegSwap(PEGSWAP_ADDRESS).swap(_amount, ERC20_LINK_ADDRESS, address(LINKTOKEN));
        
        uint256 tokenBal = LINKTOKEN.balanceOf(address(this));
        LINKTOKEN.transferAndCall(
            address(COORDINATOR),
            tokenBal,
            abi.encode(s_subscriptionId)
        );
    }

    /**
     * @notice Request random words from the VRF coordinator
     * @dev This function must be called by the owner of the contract.
     */
    function requestRandomWords() external onlyOwner {
        r_requestId = 0;
        // Will revert if subscription is not set and funded.
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        r_requestId = requestId;
        s_randomWords = randomWords;
    }

    
    function emergencyWithdrawETH() external onlyOwner {
        uint256 _tokenAmount = address(this).balance;
        payable(msg.sender).transfer(_tokenAmount);
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _token: the address of the token to withdraw
     * @dev This function is only callable by admin.
     */
    function emergencyWithdrawToken(address _token) external onlyOwner {
        uint256 _tokenAmount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, _tokenAmount);
    }

    function isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(_addr) }
        return size > 0;
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This contract has been developed by brewlabs.info
 */
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TokenVesting is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Whether it is initialized
    bool public isInitialized;
    uint256 public duration = 99 * 365; // 99 years

    // The block number when claim starts.
    uint256 public startBlock;
    // The block number when claim ends.
    uint256 public claimEndBlock;
    // tokens created per block.
    uint256 public claimPerBlock;
    // The block number of the last update
    uint256 public lastClaimBlock;

    // The vested token
    IERC20 public vestedToken;
    // The dividend token of vested token
    address public dividendToken;


    event Claimed(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event AdminTokenRecovered(address tokenRecovered, uint256 amount);

    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);
    event ClaimEndBlockUpdated(uint256 endBlock);
    event NewclaimPerBlock(uint256 claimPerBlock);
    event DurationUpdated(uint256 _duration);

    constructor() {}

    /*
     * @notice Initialize the contract
     * @param _vestedToken: vested token address
     * @param _dividendToken: reflection token address
     * @param _claimPerBlock: claim amount per block (in vestedToken)
     */
    function initialize(
        IERC20 _vestedToken,
        address _dividendToken,
        uint256 _claimPerBlock
    ) external onlyOwner {
        require(!isInitialized, "Already initialized");

        // Make this contract initialized
        isInitialized = true;

        vestedToken = _vestedToken;
        dividendToken = _dividendToken;

        claimPerBlock = _claimPerBlock;
    }

    function claim() external nonReentrant onlyOwner {
        if(startBlock == 0) return;

        uint256 multiplier = _getMultiplier(lastClaimBlock, block.number);
        uint256 amount = multiplier.mul(claimPerBlock);
        if(amount > 0) {
            vestedToken.safeTransfer(msg.sender, amount);
            emit Claimed(msg.sender, amount);
        }

        lastClaimBlock = block.number;
    }

    function harvest() external onlyOwner {      
        uint256 amount = 0;
        if(address(dividendToken) == address(0x0)) {
            amount = address(this).balance;
            if(amount > 0) {
                payable(msg.sender).transfer(amount);
            }
        } else {
            amount = IERC20(dividendToken).balanceOf(address(this));
            if(amount > 0) {
                IERC20(dividendToken).safeTransfer(msg.sender, amount);
            }
        }
    }

    function emergencyWithdraw() external nonReentrant onlyOwner{
        uint256 amount = vestedToken.balanceOf(address(this));
        if(amount > 0) {
            vestedToken.safeTransfer(msg.sender, amount);
        }

        emit EmergencyWithdraw(msg.sender, amount);
    }

    function pendingClaim() external view returns (uint256) {
        if(startBlock == 0) return 0;
        uint256 multiplier = _getMultiplier(lastClaimBlock, block.number);
        uint256 amount = multiplier.mul(claimPerBlock);
        
        return amount;
    }

    function pendingDividends() external view returns (uint256) {
        uint256 amount = 0;
        if(address(dividendToken) == address(0x0)) {
            amount = address(this).balance;
        } else {
            amount = IERC20(dividendToken).balanceOf(address(this));
        }
        
        return amount;
    }


    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of tokens to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(
            _tokenAddress != address(vestedToken) && _tokenAddress != address(dividendToken),
            "Cannot be vested or dividend token address"
        );

        if(_tokenAddress == address(0x0)) {
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
        }

        emit AdminTokenRecovered(_tokenAddress, _tokenAmount);
    }

    function startClaim() external onlyOwner {
        require(startBlock == 0, "Pool was already started");

        startBlock = block.number.add(100);
        claimEndBlock = startBlock.add(duration * 28800);
        lastClaimBlock = startBlock;
        
        emit NewStartAndEndBlocks(startBlock, claimEndBlock);
    }

    function stopClaim() external onlyOwner {
        claimEndBlock = block.number;
    }

    function updateEndBlock(uint256 _endBlock) external onlyOwner {
        require(startBlock > 0, "startBlock is not set");
        require(_endBlock > block.number && _endBlock > startBlock, "Invalid end block");

        claimEndBlock = _endBlock;
        emit ClaimEndBlockUpdated(_endBlock);
    }

    function updateClaimPerBlock(uint256 _claimPerBlock) external onlyOwner {
        // require(block.number < startBlock, "Claim was already started");

        if(startBlock > 0) {
            uint256 multiplier = _getMultiplier(lastClaimBlock, block.number);
            uint256 amount = multiplier.mul(claimPerBlock);
            if(amount > 0) {
                vestedToken.safeTransfer(msg.sender, amount);
                emit Claimed(msg.sender, amount);
            }

            lastClaimBlock = block.number;
        }

        claimPerBlock = _claimPerBlock;
        emit NewclaimPerBlock(_claimPerBlock);
    }

    function setDuration(uint256 _duration) external onlyOwner {
        require(startBlock == 0, "Pool was already started");
        require(_duration >= 30, "lower limit reached");

        duration = _duration;
        emit DurationUpdated(_duration);
    }

    /*
     * @notice Return multiplier over the given _from to _to block.
     * @param _from: block to start
     * @param _to: block to finish
     */
    function _getMultiplier(uint256 _from, uint256 _to) internal view returns (uint256) {
        if (_to <= claimEndBlock) {
            return _to.sub(_from);
        } else if (_from >= claimEndBlock) {
            return 0;
        } else {
            return claimEndBlock.sub(_from);
        }
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @author Brewlabs
 * This contract has been developed by brewlabs.info
 */
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract ImpactXPMigration is Ownable, ReentrancyGuard {
  using SafeERC20 for IERC20;

  uint256 public constant MIGRATION_PRECISION = 10**20;
  uint256 public constant PERCENT_PRECISION = 10000;

  IERC20 public oldToken;
  IERC20 public newToken;
  uint256 public migrationRate;
  uint256 public taxOfOldToken = 1100;
  uint256 public bonusRate = 1000;

  bytes32 private merkleRoot;
  uint256 private totalStaked;
  uint256 private totalClaimed;

  bool public claimable = false;

  struct UserInfo {
    uint256 amount;
    uint256 claimed;
    uint256 paidAmount;
  }
  mapping(address => UserInfo) public userInfo;

  event Deposit(address user, uint256 amount);
  event Claim(address user, uint256 amount);

  event claimEnabled();
  event HarvestOldToken(uint256 amount);
  event SetMigrationToken(address token);
  event SetBonusRate(uint256 rate);
  event SetSnapShot(bytes32 merkleRoot);

  modifier canClaim() {
    require(claimable, "cannot claim");
    _;
  }

  /**
   * @notice Initialize the contract
   * @param _oldToken: token address
   * @param _newToken: reflection token address
   */
  constructor(address _oldToken, address _newToken) {
    oldToken = IERC20(_oldToken);
    newToken = IERC20(_newToken);

    migrationRate = (newToken.totalSupply() * MIGRATION_PRECISION) / oldToken.totalSupply();
  }

  function deposit(
    uint256 _amount,
    uint256 _max,
    bytes32[] memory _merkleProof
  ) external nonReentrant {
    require(merkleRoot != "", "Migration not enabled");

    // check if total deposits exceed snapshot
    uint256 prevAmt = (userInfo[msg.sender].amount * PERCENT_PRECISION) /
      (PERCENT_PRECISION - taxOfOldToken);
    require(_amount + prevAmt <= _max, "migration amount cannot exceed max");

    // Verify the merkle proof.
    bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _max));
    require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "Invalid merkle proof.");

    uint256 beforeAmt = oldToken.balanceOf(address(this));
    oldToken.safeTransferFrom(msg.sender, address(this), _amount);
    uint256 afterAmt = oldToken.balanceOf(address(this));
    uint256 realAmt = afterAmt - beforeAmt;
    if(realAmt > _amount) realAmt = _amount;

    UserInfo storage user = userInfo[msg.sender];
    user.amount += realAmt;
    totalStaked += realAmt;

    emit Deposit(msg.sender, realAmt);
  }

  function claim() external nonReentrant {
    UserInfo storage user = userInfo[msg.sender];
    require(claimable, "claim not enabled");
    require(user.amount - user.claimed > 0, "not available to claim");

    uint256 pending = pendingClaim(msg.sender);
    if (pending > 0) {
      newToken.safeTransfer(msg.sender, pending);
    }

    user.claimed = user.amount;
    user.paidAmount += pending;
    totalClaimed += pending;
    emit Claim(msg.sender, pending);
  }

  function pendingClaim(address _user) public view returns (uint256) {
    UserInfo memory user = userInfo[_user];
    uint256 amount = user.amount - user.claimed;
    uint256 expectedAmt = (amount * (10000 + bonusRate)) / (10000 - taxOfOldToken);

    return (expectedAmt * migrationRate) / MIGRATION_PRECISION;
  }

  function insufficientClaims() external view returns (uint256) {
    uint256 tokenBal = newToken.balanceOf(address(this));
    uint256 expectedAmt = (totalStaked * (10000 + bonusRate)) / (10000 - taxOfOldToken);
    expectedAmt = (expectedAmt * migrationRate) / MIGRATION_PRECISION - totalClaimed;

    if (tokenBal > expectedAmt) return 0;
    return expectedAmt - tokenBal;
  }

  function setMigrationToken(address _newToken) external onlyOwner {
    require(!claimable, "claim was enabled");
    require(_newToken != address(0x0) && _newToken != address(newToken), "invalid new token");
    require(_newToken != address(oldToken), "cannot set old token address");

    newToken = IERC20(_newToken);
    migrationRate = (newToken.totalSupply() * MIGRATION_PRECISION) / oldToken.totalSupply();
    emit SetMigrationToken(_newToken);
  }

  function setBonusRate(uint256 _bonus) external onlyOwner {
    require(!claimable, "claim was enabled");
    require(_bonus < PERCENT_PRECISION, "invalid percent");
    bonusRate = _bonus;
    emit SetBonusRate(_bonus);
  }

  function setSnapShotMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
    merkleRoot = _merkleRoot;
    emit SetSnapShot(_merkleRoot);
  }

  function enableClaim() external onlyOwner {
    require(!claimable, "already enabled");
    claimable = true;
    emit claimEnabled();
  }

  function harvestOldToken() external onlyOwner {
    uint256 amount = oldToken.balanceOf(address(this));
    oldToken.safeTransfer(msg.sender, amount);
    emit HarvestOldToken(amount);
  }

  /**
   * @notice It allows the admin to recover wrong tokens sent to the contract
   * @param _token: the address of the token to withdraw
   * @param _amount: the amount to withdraw, if amount is zero, all tokens will be withdrawn
   * @dev This function is only callable by admin.
   */
  function rescueTokens(address _token, uint256 _amount) external onlyOwner {
    if (_token == address(0x0)) {
      if (_amount > 0) {
        payable(msg.sender).transfer(_amount);
      } else {
        uint256 _tokenAmount = address(this).balance;
        payable(msg.sender).transfer(_tokenAmount);
      }
    } else {
      if (_amount > 0) {
        IERC20(_token).safeTransfer(msg.sender, _amount);
      } else {
        uint256 _tokenAmount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, _tokenAmount);
      }
    }
  }

  receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This contract has been developed by brewlabs.info
 */

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../libs/IUniRouter02.sol";

interface IBlocVestNft is IERC721 {
  function rarities(uint256 tokenId) external view returns (uint256);
}

contract BlocVestTrickleVault is Ownable, IERC721Receiver, ReentrancyGuard {
  using SafeERC20 for IERC20;
  bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

  // IERC20 public bvst = IERC20(0xC7b29e78BcE023757928eD3839Ff92F94391842E);
  // IERC20 public bvstLP = IERC20(0xaA187EDdD4b37B8864bd5015acF07d65B79E9101);
  IERC20 public bvst = IERC20(0x8428b19C97acCD93fA10f19cbbdfF4FB71C4D175);
  IERC20 public bvstLP = IERC20(0xB37d9c39d6A3873Dca3CBfA01D795a03f41b7298);

  uint256 public claimLimit = 365;
  uint256 public userLimit = 25000 ether;
  uint256 public compoundLimit = 1000;

  address public bvstNft;
  uint256 public defaultApr = 50;
  uint256[4] public cardAprs = [25, 50, 100, 150];

  struct HarvestFee {
    uint256 feeInBNB;
    uint256 feeInToken;
    uint256 fee;
  }
  HarvestFee[3] public harvestFees; // 0 - default, 1 - weekly tax, 2 - whale tax
  uint256 public depositFee = 1000;
  uint256 public whaleLimit = 85;

  struct UserInfo {
    uint256 apr;
    uint256 cardType;
    uint256 rewards;
    uint256 totalStaked;
    uint256 totalRewards;
    uint256 lastRewardBlock;
    uint256 totalClaims;
  }
  mapping(address => UserInfo) public userInfo;
  uint256 public totalStaked;

  address public uniRouterAddress;
  address[] public tokenToBnbPath;

  uint256 public autoCompoundFeeInDay = 0.007 ether;
  mapping(address => uint256) public autoCompounds;
  address[] public autoCompounders;

  address public treasury = 0x6219B6b621E6E66a6c5a86136145E6E5bc6e4672;
  // address public treasury = 0x0b7EaCB3EB29B13C31d934bdfe62057BB9763Bb7;
  uint256 public performanceFee = 0.0035 ether;

  event Deposit(address indexed user, uint256 amount);
  event Claim(address indexed user, uint256 amount);
  event AutoCompound(address user, uint256 amount);
  event RequestAutoCompound(address user, uint256 times);

  event NftStaked(address indexed user, address nft, uint256 tokenId);

  event SetDepositFee(uint256 percent);
  event SetAutoCompoundFee(uint256 fee);
  event SetUserDepositLimit(uint256 limit);
  event SetClaimLimit(uint256 count);
  event SetDefaultApr(uint256 apr);
  event SetCardAprs(uint256[4] aprs);
  event SetHarvestFees(
    uint8 feeType,
    uint256 inBNBToTreasury,
    uint256 inTokenToTreasury,
    uint256 toContract
  );
  event SetWhaleLimit(uint256 percent);

  event AdminTokenRecovered(address tokenRecovered, uint256 amount);
  event ServiceInfoUpadted(address addr, uint256 fee);
  event SetSettings(address uniRouter, address[] tokenToBnbPath);

  constructor(
    address _nft,
    address _uniRouter,
    address[] memory _path
  ) {
    bvstNft = _nft;
    uniRouterAddress = _uniRouter;
    tokenToBnbPath = _path;

    harvestFees[0] = HarvestFee(0, 0, 1000);
    harvestFees[1] = HarvestFee(0, 0, 5000);
    harvestFees[2] = HarvestFee(1500, 1500, 2000);
  }

  function deposit(uint256 _amount) external payable nonReentrant {
    UserInfo storage user = userInfo[msg.sender];
    require(_amount > 0, "invalid amount");
    require(_amount + user.totalStaked <= userLimit, "cannot exceed maximum limit");

    _transferPerformanceFee();

    uint256 beforeAmount = bvst.balanceOf(address(this));
    bvst.safeTransferFrom(address(msg.sender), address(this), _amount);
    uint256 afterAmount = bvst.balanceOf(address(this));
    uint256 realAmount = afterAmount - beforeAmount;
    realAmount = (realAmount * (10000 - depositFee)) / 10000;

    uint256 _pending = pendingRewards(msg.sender);
    user.rewards += _pending;
    user.lastRewardBlock = block.number;
    user.totalRewards = user.totalRewards + _pending;
    user.totalStaked = user.totalStaked + realAmount;
    totalStaked = totalStaked + realAmount;

    emit Deposit(msg.sender, realAmount);
  }

  function stakeNft(uint256 _tokenId) external payable nonReentrant {
    _transferPerformanceFee();

    uint256 _pending = _claim(msg.sender);
    if (_pending > 0) {
      bvst.safeTransfer(msg.sender, _pending);
    }

    IERC721(bvstNft).safeTransferFrom(msg.sender, address(this), _tokenId);

    UserInfo storage user = userInfo[msg.sender];
    uint256 rarity = IBlocVestNft(bvstNft).rarities(_tokenId);
    require(user.cardType < rarity + 1, "cannot stake lower level card");

    user.cardType = rarity + 1;
    user.apr = cardAprs[rarity] + defaultApr;

    emit NftStaked(msg.sender, bvstNft, _tokenId);
  }

  function harvest() external payable nonReentrant {
    require(userInfo[msg.sender].totalClaims <= claimLimit, "exceed claim limit");

    _transferPerformanceFee();

    uint256 _pending = _claim(msg.sender);
    if (_pending > 0) {
      bvst.safeTransfer(msg.sender, _pending);
    }

    UserInfo storage user = userInfo[msg.sender];
    user.totalClaims = user.totalClaims + 1;
  }

  function compound() external payable nonReentrant {
    _transferPerformanceFee();

    uint256 _pending = _claim(msg.sender);
    UserInfo storage user = userInfo[msg.sender];

    if (_pending > 0) {
      uint256 tSupply = (bvst.totalSupply() * compoundLimit) / 10000;
      if (_pending > tSupply) _pending = tSupply;

      user.totalStaked = user.totalStaked + _pending;
      totalStaked = totalStaked + _pending;

      emit Deposit(msg.sender, _pending);
    }
  }

  function requestAutoCompound(uint256 _times) external payable nonReentrant {
    require(msg.value >= _times * autoCompoundFeeInDay, "insufficient compound fee");

    if (autoCompounds[msg.sender] == 0) {
      autoCompounders.push(msg.sender);
    }
    autoCompounds[msg.sender] = autoCompounds[msg.sender] + _times;
    payable(treasury).transfer(msg.value);

    emit RequestAutoCompound(msg.sender, _times);
  }

  function autoCompound(uint256 _index) external nonReentrant {
    if (_index >= autoCompounders.length) return;

    address _user = autoCompounders[_index];
    if (autoCompounds[_user] == 0) {
      autoCompounders[_index] = autoCompounders[autoCompounders.length - 1];
      autoCompounders.pop();
      return;
    }

    uint256 _pending = _claim(_user);
    UserInfo storage user = userInfo[_user];

    if (_pending > 0) {
      autoCompounds[_user] = autoCompounds[_user] - 1;
      if (autoCompounds[_user] == 0) {
        autoCompounders[_index] = autoCompounders[autoCompounders.length - 1];
        autoCompounders.pop();
      }

      uint256 tSupply = (bvst.totalSupply() * compoundLimit) / 10000;
      if (_pending > tSupply) _pending = tSupply;

      user.totalStaked = user.totalStaked + _pending;
      totalStaked = totalStaked + _pending;

      emit Deposit(_user, _pending);
      emit AutoCompound(_user, _pending);
    }
  }

  function autoCompounderCount() external view returns (uint256) {
    return autoCompounders.length;
  }

  function autoCompounderInfo(uint256 _index) external view returns (UserInfo memory) {
    if (_index >= autoCompounders.length) return userInfo[address(0x0)];

    address _user = autoCompounders[_index];
    return userInfo[_user];
  }

  function pendingRewards(address _user) public view returns (uint256) {
    UserInfo memory user = userInfo[_user];

    uint256 expiryBlock = user.lastRewardBlock + 28800;
    if (user.lastRewardBlock == 0 || expiryBlock < user.lastRewardBlock) {
      return 0;
    }

    uint256 multiplier = (expiryBlock > block.number ? block.number : expiryBlock) -
      user.lastRewardBlock;

    return user.rewards + (multiplier * user.totalStaked * user.apr) / 10000 / 28800;
  }

  function appliedTax(address _user) internal view returns (HarvestFee memory) {
    UserInfo memory user = userInfo[_user];
    if (user.lastRewardBlock == 0) return harvestFees[0];

    uint256 tokenInLp = bvst.balanceOf(address(bvstLP));
    if (user.totalStaked >= (tokenInLp * whaleLimit) / 10000) {
      return harvestFees[2];
    }

    uint256 passedBlocks = block.number - user.lastRewardBlock;
    if (passedBlocks <= 7 * 28800) return harvestFees[1];
    return harvestFees[0];
  }

  function _claim(address _user) internal returns (uint256) {
    UserInfo storage user = userInfo[_user];

    uint256 _pending = pendingRewards(_user);
    user.apr = user.cardType == 0 ? 0 : cardAprs[user.cardType - 1];
    user.apr += defaultApr;
    if (_pending == 0) return 0;

    user.rewards = 0;
    user.totalRewards = user.totalRewards + _pending;
    user.lastRewardBlock = block.number;

    HarvestFee memory tax = appliedTax(_user);
    uint256 feeInBNB = (_pending * tax.feeInBNB) / 10000;
    if (feeInBNB > 0) {
      _safeSwap(feeInBNB, tokenToBnbPath, treasury);
    }
    uint256 feeInToken = (_pending * tax.feeInToken) / 10000;
    uint256 fee = (_pending * tax.fee) / 10000;

    bvst.safeTransfer(treasury, feeInToken);
    emit Claim(_user, _pending);

    return _pending - feeInBNB - feeInToken - fee;
  }

  function _transferPerformanceFee() internal {
    require(msg.value >= performanceFee, "should pay small gas to compound or harvest");

    payable(treasury).transfer(performanceFee);
    if (msg.value > performanceFee) {
      payable(msg.sender).transfer(msg.value - performanceFee);
    }
  }

  function setDepositFee(uint256 _percent) external onlyOwner {
    require(_percent < 10000, "invalid limit");
    depositFee = _percent;
    emit SetDepositFee(_percent);
  }

  function setAutoCompoundFee(uint256 _fee) external onlyOwner {
    autoCompoundFeeInDay = _fee;
    emit SetAutoCompoundFee(_fee);
  }

  function setDepositUserLimit(uint256 _limit) external onlyOwner {
    userLimit = _limit;
    emit SetUserDepositLimit(_limit);
  }

  function setClaimLimit(uint256 _count) external onlyOwner {
    claimLimit = _count;
    emit SetClaimLimit(_count);
  }

  function setDefaultApr(uint256 _apr) external onlyOwner {
    require(_apr < 10000, "invalid apr");
    defaultApr = _apr;
    emit SetDefaultApr(_apr);
  }

  function setCardAprs(uint256[4] memory _aprs) external onlyOwner {
    require(totalStaked > 0, "is staking");
    uint256 totalAlloc = 0;
    for (uint256 i = 0; i <= 4; i++) {
      totalAlloc = totalAlloc + _aprs[i];
      require(_aprs[i] > 0, "Invalid apr");
    }

    cardAprs = _aprs;
    emit SetCardAprs(_aprs);
  }

  function setHarvestFees(
    uint8 _feeType,
    uint256 _inBNBToTreasury,
    uint256 _inTokenToTreasury,
    uint256 _toContract
  ) external onlyOwner {
    require(_feeType <= 3, "invalid type");
    require(_inBNBToTreasury + _inTokenToTreasury + _toContract < 10000, "invalid base apr");

    HarvestFee storage _fee = harvestFees[_feeType];
    _fee.feeInBNB = _inBNBToTreasury;
    _fee.feeInToken = _inTokenToTreasury;
    _fee.fee = _toContract;

    emit SetHarvestFees(_feeType, _inBNBToTreasury, _inTokenToTreasury, _toContract);
  }

  function setWhaleLimit(uint256 _percent) external onlyOwner {
    require(_percent < 10000, "invalid limit");
    whaleLimit = _percent;
    emit SetWhaleLimit(_percent);
  }

  function setServiceInfo(address _treasury, uint256 _fee) external {
    require(msg.sender == treasury, "setServiceInfo: FORBIDDEN");
    require(_treasury != address(0x0), "Invalid address");

    treasury = _treasury;
    performanceFee = _fee;

    emit ServiceInfoUpadted(_treasury, _fee);
  }

  function setSettings(address _uniRouter, address[] memory _tokenToBnbPath) external onlyOwner {
    uniRouterAddress = _uniRouter;
    tokenToBnbPath = _tokenToBnbPath;
    emit SetSettings(_uniRouter, _tokenToBnbPath);
  }

  function _safeSwap(
    uint256 _amountIn,
    address[] memory _path,
    address _to
  ) internal {
    bvst.safeApprove(uniRouterAddress, _amountIn);
    IUniRouter02(uniRouterAddress).swapExactTokensForETHSupportingFeeOnTransferTokens(
      _amountIn,
      0,
      _path,
      _to,
      block.timestamp + 600
    );
  }

  /**
   * @notice It allows the admin to recover wrong tokens sent to the contract
   * @param _token: the address of the token to withdraw
   * @param _amount: the number of tokens to withdraw
   * @dev This function is only callable by admin.
   */
  function rescueTokens(address _token, uint256 _amount) external onlyOwner {
    if (_token == address(0x0)) {
      payable(msg.sender).transfer(_amount);
    } else {
      IERC20(_token).safeTransfer(address(msg.sender), _amount);
    }

    emit AdminTokenRecovered(_token, _amount);
  }

  /**
   * onERC721Received(address operator, address from, uint256 tokenId, bytes data) → bytes4
   * It must return its Solidity selector to confirm the token transfer.
   * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
   */
  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata
  ) external view override returns (bytes4) {
    require(msg.sender == bvstNft, "not enabled NFT");
    return _ERC721_RECEIVED;
  }

  receive() external payable {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This contract has been developed by brewlabs.info
 */
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract BlocVestNft is ERC721Enumerable, Ownable {
  using SafeERC20 for IERC20;
  using Strings for uint256;

  uint256 private totalMinted;
  string private _tokenBaseURI = "";
  string[4] public categoryNames = ["Bronze", "Silver", "Gold", "Platinum"];

  bool public mintAllowed = false;
  uint256 public onetimeMintingLimit = 40;
  address public payingToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
  uint256[4] public prices = [500 ether, 1000 ether, 2500 ether, 5000 ether];

  address public treasury;
  uint256 public performanceFee = 0.0015 ether;

  mapping(uint256 => string) private _tokenURIs;
  mapping(uint256 => uint256) public rarities;
  mapping(address => bool) private whitelist;
  mapping(address => mapping(uint256 => bool)) private feeExcluded;

  event BaseURIUpdated(string uri);
  event MintEnabled();
  event MintDisabled();
  event SetPayingToken(address token);
  event SetSalePrices(uint256[4] prices);
  event SetOneTimeLimit(uint256 limit);
  event ServiceInfoUpadted(address treasury, uint256 fee);
  event WhiteListUpdated(address addr, bool enabled);
  event FeeExcluded(address addr, uint256 category);
  event FeeIncluded(address addr, uint256 category);

  constructor() ERC721("BlocVest NFT Card", "Bvest") {
    treasury = msg.sender;
  }

  function _transfer(
    address from,
    address to,
    uint256 tokenId
  ) internal override {
    require(
      !checkHoldCategory(to, rarities[tokenId]) || whitelist[to],
      "Non-tranferable more to non whitelisted address"
    );
    super._transfer(from, to, tokenId);
  }

  function mint(uint256 _category) external payable {
    require(mintAllowed, "mint was disabled");
    require(_category < 4, "invalid category");
    require(!checkHoldCategory(msg.sender, _category), "already hold this card");

    _transferPerformanceFee();

    if (!feeExcluded[msg.sender][_category]) {
      uint256 amount = prices[_category];
      IERC20(payingToken).safeTransferFrom(msg.sender, address(this), amount);
    }

    uint256 tokenId = totalMinted + 1;
    _safeMint(msg.sender, tokenId);
    _setTokenURI(tokenId, tokenId.toString());

    rarities[tokenId] = _category;
    totalMinted = totalMinted + 1;
  }

  function setWhitelist(address _addr, bool _enabled) external onlyOwner {
    whitelist[_addr] = _enabled;
    emit WhiteListUpdated(_addr, _enabled);
  }

  function excludeFromFee(address _addr, uint256 _category) external onlyOwner {
    feeExcluded[_addr][_category] = true;
    emit FeeExcluded(_addr, _category);
  }

  function includeInFee(address _addr, uint256 _category) external onlyOwner {
    feeExcluded[_addr][_category] = false;
    emit FeeIncluded(_addr, _category);
  }

  function enabledMint() external onlyOwner {
    require(!mintAllowed, "already enabled");
    mintAllowed = true;
    emit MintEnabled();
  }

  function disableMint() external onlyOwner {
    require(mintAllowed, "already disabled");
    mintAllowed = false;
    emit MintDisabled();
  }

  function setPayingToken(address _token) external onlyOwner {
    require(!mintAllowed, "mint was enabled");
    require(_token != payingToken, "same token");
    require(_token != address(0x0), "invalid token");

    payingToken = _token;
    emit SetPayingToken(_token);
  }

  function setSalePrices(uint256[4] memory _prices) external onlyOwner {
    require(!mintAllowed, "mint was enabled");
    prices = _prices;
    emit SetSalePrices(_prices);
  }

  function setOneTimeMintingLimit(uint256 _limit) external onlyOwner {
    onetimeMintingLimit = _limit;
    emit SetOneTimeLimit(_limit);
  }

  function setServiceInfo(address _addr, uint256 _fee) external {
    require(msg.sender == treasury, "setServiceInfo: FORBIDDEN");
    require(_addr != address(0x0), "Invalid address");

    treasury = _addr;
    performanceFee = _fee;

    emit ServiceInfoUpadted(_addr, _fee);
  }

  function setTokenBaseURI(string memory _uri) external onlyOwner {
    _tokenBaseURI = _uri;
    emit BaseURIUpdated(_uri);
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(_exists(tokenId), "BlocVest: URI query for nonexistent token");

    string memory base = _baseURI();

    // If both are set, concatenate the baseURI (via abi.encodePacked).
    string memory metadata = string(
      abi.encodePacked(
        '{"name": "BlocVest NFT Card", "description": "BlocVest NFT Card #',
        tokenId.toString(),
        ': BlocVest NFT Cards are generated as a result of each individual.", "image": "',
        string(
          abi.encodePacked(base, categoryNames[rarities[tokenId]], ".mp4")
        ),
        '", "attributes":[{"trait_type":"category", "value":"',
        categoryNames[rarities[tokenId]],
        '"}, {"trait_type":"number", "value":"',
        tokenId.toString(),
        '"}]}'
      )
    );

    return
      string(
        abi.encodePacked(
          "data:application/json;base64,",
          _base64(bytes(metadata))
        )
      );
  }

  function categoryOf(uint256 tokenId) external view returns (string memory) {
    return categoryNames[rarities[tokenId]];
  }

  function checkHoldCategory(address _user, uint256 _category)
    internal
    view
    returns (bool)
  {
    uint256 balance = balanceOf(_user);
    if (balance == 0) return false;

    for (uint256 i = 0; i < balance; i++) {
      uint256 tokenId = tokenOfOwnerByIndex(_user, i);
      if (rarities[tokenId] == _category) return true;
    }
    return false;
  }

  function _transferPerformanceFee() internal {
    require(msg.value >= performanceFee, "should pay small gas to mint");

    payable(treasury).transfer(performanceFee);
    if (msg.value > performanceFee) {
      payable(msg.sender).transfer(msg.value - performanceFee);
    }
  }

  function _baseURI() internal view override returns (string memory) {
    return _tokenBaseURI;
  }

  function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
    require(_exists(tokenId), "BlocVest: URI set of nonexistent token");
    _tokenURIs[tokenId] = _tokenURI;
  }

  function _base64(bytes memory data) internal pure returns (string memory) {
    if (data.length == 0) return "";

    // load the table into memory
    string
      memory table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    // multiply by 4/3 rounded up
    uint256 encodedLen = 4 * ((data.length + 2) / 3);

    // add some extra buffer at the end required for the writing
    string memory result = new string(encodedLen + 32);

    assembly {
      // set the actual output length
      mstore(result, encodedLen)

      // prepare the lookup table
      let tablePtr := add(table, 1)

      // input ptr
      let dataPtr := data
      let endPtr := add(dataPtr, mload(data))

      // result ptr, jump over length
      let resultPtr := add(result, 32)

      // run over the input, 3 bytes at a time
      for {

      } lt(dataPtr, endPtr) {

      } {
        dataPtr := add(dataPtr, 3)

        // read 3 bytes
        let input := mload(dataPtr)

        // write 4 characters
        mstore(
          resultPtr,
          shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F))))
        )
        resultPtr := add(resultPtr, 1)
        mstore(
          resultPtr,
          shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F))))
        )
        resultPtr := add(resultPtr, 1)
        mstore(
          resultPtr,
          shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F))))
        )
        resultPtr := add(resultPtr, 1)
        mstore(resultPtr, shl(248, mload(add(tablePtr, and(input, 0x3F)))))
        resultPtr := add(resultPtr, 1)
      }

      // padding with '='
      switch mod(mload(data), 3)
      case 1 {
        mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
      }
      case 2 {
        mstore(sub(resultPtr, 1), shl(248, 0x3d))
      }
    }

    return result;
  }

  function rescueTokens(address _token) external onlyOwner {
    if (_token == address(0x0)) {
      uint256 _ethAmount = address(this).balance;
      payable(msg.sender).transfer(_ethAmount);
    } else {
      uint256 _tokenAmount = IERC20(_token).balanceOf(address(this));
      IERC20(_token).safeTransfer(msg.sender, _tokenAmount);
    }
  }

  receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This contract has been developed by brewlabs.info
 */
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import "../libs/IUniFactory.sol";
import "../libs/IUniRouter02.sol";
import "../libs/IWETH.sol";

interface IStaking {
    function performanceFee() external view returns(uint256);
    function setServiceInfo(address _addr, uint256 _fee) external;
}

interface IFarm {
    function setBuyBackWallet(address _addr) external;
}

contract BlocVestTreasury is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Whether it is initialized
    bool private isInitialized;
    uint256 private TIME_UNIT = 1 days;

    IERC20  public token;
    address public dividendToken;
    address public pair;

    uint256 public period = 30;                         // 30 days
    uint256 public withdrawalLimit = 500;               // 5% of total supply
    uint256 public liquidityWithdrawalLimit = 2000;     // 20% of LP supply
    uint256 public buybackRate = 9500;                  // 95%
    uint256 public addLiquidityRate = 9400;             // 94%

    uint256 private startTime;
    uint256 private sumWithdrawals = 0;
    uint256 private sumLiquidityWithdrawals = 0;

    uint256 public performanceFee = 100;     // 1%
    uint256 public performanceLpFee = 200;   // 2%
    address public feeWallet = 0x408c4aDa67aE1244dfeC7D609dea3c232843189A;

    // swap router and path, slipPage
    address public uniRouterAddress;
    address[] public bnbToTokenPath;
    uint256 public slippageFactor = 830;    // 17%
    uint256 public constant slippageFactorUL = 995;

    event TokenBuyBack(uint256 amountETH, uint256 amountToken);
    event LiquidityAdded(uint256 amountETH, uint256 amountToken, uint256 liquidity);
    event SetSwapConfig(address router, uint256 slipPage, address[] path);
    event TransferBuyBackWallet(address staking, address wallet);
    event LiquidityWithdrawn(uint256 amount);
    event Withdrawn(uint256 amount);

    event AddLiquidityRateUpdated(uint256 percent);
    event BuybackRateUpdated(uint256 percent);
    event PeriodUpdated(uint256 duration);
    event LiquidityWithdrawLimitUpdated(uint256 percent);
    event WithdrawLimitUpdated(uint256 percent);
    event ServiceInfoUpdated(address wallet, uint256 performanceFee, uint256 liquidityFee);

    constructor() {}
   
    /**
     * @notice Initialize the contract
     * @param _token: token address
     * @param _dividendToken: reflection token address
     * @param _uniRouter: uniswap router address for swap tokens
     * @param _bnbToTokenPath: swap path to buy Token
     */
    function initialize(
        IERC20 _token,
        address _dividendToken,
        address _uniRouter,
        address[] memory _bnbToTokenPath
    ) external onlyOwner {
        require(!isInitialized, "Already initialized");

        // Make this contract initialized
        isInitialized = true;

        token = _token;
        dividendToken = _dividendToken;
        pair = IUniV2Factory(IUniRouter02(_uniRouter).factory()).getPair(_bnbToTokenPath[0], address(token));

        uniRouterAddress = _uniRouter;
        bnbToTokenPath = _bnbToTokenPath;
    }

    /**
     * @notice Buy token from BNB
     */
    function buyBack() external onlyOwner nonReentrant {
        uint256 ethAmt = address(this).balance;
        uint256 _fee = ethAmt * performanceFee / 10000;
        if(_fee > 0) {
            payable(feeWallet).transfer(_fee);
            ethAmt = ethAmt - _fee;
        }
        ethAmt = ethAmt * buybackRate / 10000;

        if(ethAmt > 0) {
            uint256[] memory amounts = _safeSwapEth(ethAmt, bnbToTokenPath, address(this));
            emit TokenBuyBack(amounts[0], amounts[amounts.length - 1]);
        }
    }

    
    /**
     * @notice Add liquidity
     */
    function addLiquidity() external onlyOwner nonReentrant {
        uint256 ethAmt = address(this).balance;
        uint256 _fee = ethAmt * performanceLpFee / 10000;
        if(_fee > 0) {
            payable(feeWallet).transfer(_fee);
            ethAmt = ethAmt - _fee;
        }
        ethAmt = ethAmt * addLiquidityRate / 10000 / 2;

        if(ethAmt > 0) {
            uint256[] memory amounts = _safeSwapEth(ethAmt, bnbToTokenPath, address(this));
            uint256 _tokenAmt = amounts[amounts.length - 1];
            emit TokenBuyBack(amounts[0], _tokenAmt);
            
            (uint256 amountToken, uint256 amountETH, uint256 liquidity) = _addLiquidityEth(address(token), ethAmt, _tokenAmt, address(this));
            emit LiquidityAdded(amountETH, amountToken, liquidity);
        }
    }


    /**
     * @notice Withdraw token as much as maximum 5% of total supply
     * @param _amount: amount to withdraw
     */
    function withdraw(uint256 _amount) external onlyOwner {
        uint256 tokenAmt = token.balanceOf(address(this));
        require(_amount > 0 && _amount <= tokenAmt, "Invalid Amount");

        if(block.timestamp - startTime > period * TIME_UNIT) {
            startTime = block.timestamp;
            sumWithdrawals = 0;
        }

        uint256 limit = withdrawalLimit * (token.totalSupply()) / 10000;
        require(sumWithdrawals + _amount <= limit, "exceed maximum withdrawal limit for 30 days");

        token.safeTransfer(msg.sender, _amount);
        emit Withdrawn(_amount);
    }

    /**
     * @notice Withdraw token as much as maximum 20% of lp supply
     * @param _amount: liquidity amount to withdraw
     */
    function withdrawLiquidity(uint256 _amount) external onlyOwner {
        uint256 tokenAmt = IERC20(pair).balanceOf(address(this));
        require(_amount > 0 && _amount <= tokenAmt, "Invalid Amount");

        if(block.timestamp - startTime > period * TIME_UNIT) {
            startTime = block.timestamp;
            sumLiquidityWithdrawals = 0;
        }

        uint256 limit = liquidityWithdrawalLimit * (IERC20(pair).totalSupply()) / 10000;
        require(sumLiquidityWithdrawals + _amount <= limit, "exceed maximum LP withdrawal limit for 30 days");

        IERC20(pair).safeTransfer(msg.sender, _amount);
        emit LiquidityWithdrawn(_amount);
    }
    
    /**
     * @notice Withdraw tokens
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external onlyOwner {
        uint256 tokenAmt = token.balanceOf(address(this));
        if(tokenAmt > 0) {
            token.transfer(msg.sender, tokenAmt);
        }

        tokenAmt = IERC20(pair).balanceOf(address(this));
        if(tokenAmt > 0) {
            IERC20(pair).transfer(msg.sender, tokenAmt);
        }

        uint256 ethAmt = address(this).balance;
        if(ethAmt > 0) {
            payable(msg.sender).transfer(ethAmt);
        }
    }

    /**
     * @notice Harvest reflection for token
     */
    function harvest() external onlyOwner {
        if(dividendToken == address(0x0)) {
            uint256 ethAmt = address(this).balance;
            if(ethAmt > 0) {
                payable(msg.sender).transfer(ethAmt);
            }
        } else {
            uint256 tokenAmt = IERC20(dividendToken).balanceOf(address(this));
            if(tokenAmt > 0) {
                IERC20(dividendToken).transfer(msg.sender, tokenAmt);
            }
        }
    }

    /**
     * @notice Set duration for withdraw limit
     * @param _period: duration
     */
    function setWithdrawalLimitPeriod(uint256 _period) external onlyOwner {
        require(_period >= 10, "small period");
        period = _period;
        emit PeriodUpdated(_period);
    }

    /**
     * @notice Set liquidity withdraw limit
     * @param _percent: percentage of LP supply in point
     */
    function setLiquidityWithdrawalLimit(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");
        
        liquidityWithdrawalLimit = _percent;
        emit LiquidityWithdrawLimitUpdated(_percent);
    }

    /**
     * @notice Set withdraw limit
     * @param _percent: percentage of total supply in point
     */
    function setWithdrawalLimit(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");
        
        withdrawalLimit = _percent;
        emit WithdrawLimitUpdated(_percent);
    }
    
    /**
     * @notice Set buyback rate
     * @param _percent: percentage in point
     */
    function setBuybackRate(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");

        buybackRate = _percent;
        emit BuybackRateUpdated(_percent);
    }

    /**
     * @notice Set addliquidy rate
     * @param _percent: percentage in point
     */
    function setAddLiquidityRate(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");

        addLiquidityRate = _percent;
        emit AddLiquidityRateUpdated(_percent);
    }

    function setServiceInfo(address _wallet, uint256 _fee) external {
        require(msg.sender == feeWallet, "Invalid setter");
        require(_wallet != feeWallet && _wallet != address(0x0), "Invalid new wallet");
        require(_fee < 500, "invalid performance fee");
       
        feeWallet = _wallet;
        performanceFee = _fee;
        performanceLpFee = _fee * 2;

        emit ServiceInfoUpdated(_wallet, performanceFee, performanceLpFee);
    }
    
    /**
     * @notice Set buyback wallet of farm contract
     * @param _uniRouter: dex router address
     * @param _slipPage: slip page for swap
     * @param _path: bnb-token swap path
     */
    function setSwapSettings(address _uniRouter, uint256 _slipPage, address[] memory _path) external onlyOwner {
        require(_slipPage < 1000, "Invalid percentage");

        uniRouterAddress = _uniRouter;
        slippageFactor = _slipPage;
        bnbToTokenPath = _path;

        emit SetSwapConfig(_uniRouter, _slipPage, _path);
    }

    /**
     * @notice set buyback wallet of farm contract
     * @param _farm: farm contract address
     * @param _addr: buyback wallet address
     */
    function setFarmServiceInfo(address _farm, address _addr) external onlyOwner {
        require(_farm != address(0x0) && _addr != address(0x0), "Invalid Address");
        IFarm(_farm).setBuyBackWallet(_addr);

        emit TransferBuyBackWallet(_farm, _addr);
    }

    /**
     * @notice set buyback wallet of staking contract 
     * @param _staking: staking contract address
     * @param _addr: buyback wallet address
     */
    function setStakingServiceInfo(address _staking, address _addr) external onlyOwner {
        require(_staking != address(0x0) && _addr != address(0x0), "Invalid Address");
        uint256 _fee = IStaking(_staking).performanceFee();
        IStaking(_staking).setServiceInfo(_addr, _fee);

        emit TransferBuyBackWallet(_staking, _addr);
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _token: the address of the token to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _token) external onlyOwner {
        require(_token != address(token) && _token != dividendToken && _token != pair, "Cannot be token & dividend token, pair");

        if(_token == address(0x0)) {
            uint256 _tokenAmount = address(this).balance;
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            uint256 _tokenAmount = IERC20(_token).balanceOf(address(this));
            IERC20(_token).safeTransfer(msg.sender, _tokenAmount);
        }
    }


    /************************
    ** Internal Methods
    *************************/
    /*
     * @notice get token from ETH via swap.
     */
    function _safeSwapEth(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal returns (uint256[] memory amounts) {
        amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length - 1];

        IUniRouter02(uniRouterAddress).swapExactETHForTokensSupportingFeeOnTransferTokens{value: _amountIn}(
            amountOut * slippageFactor / 1000,
            _path,
            _to,
            block.timestamp + 600
        );
    }

    /*
     * @notice Add liquidity for Token-BNB pair.
     */
    function _addLiquidityEth(
        address _token,
        uint256 _ethAmt,
        uint256 _tokenAmt,
        address _to
    ) internal returns(uint256 amountToken, uint256 amountETH, uint256 liquidity) {
        IERC20(_token).safeIncreaseAllowance(uniRouterAddress, _tokenAmt);

        (amountToken, amountETH, liquidity) = IUniRouter02(uniRouterAddress).addLiquidityETH{value: _ethAmt}(
            address(_token),
            _tokenAmt,
            0,
            0,
            _to,
            block.timestamp + 600
        );

        IERC20(_token).safeApprove(uniRouterAddress, uint256(0));
    }


    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This contract has been developed by brewlabs.info
 */
 
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../libs/IPriceOracle.sol";
import "../libs/IUniRouter02.sol";
import "../libs/IWETH.sol";

interface IToken {
     /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);
}

contract BlocVestShareholderVault is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Whether it is initialized
    bool public isInitialized;
    bool public isActive = false;
    IPriceOracle private oracle;

    uint256 public lockDuration = 3 * 30; // 3 months
    uint256 public harvestCycle = 30; // 30 days

    // swap router and path, slipPage
    address public uniRouterAddress;
    address[] public earnedToStakedPath;
    uint256 public slippageFactor = 800; // 20% default slippage tolerance
    uint256 public constant slippageFactorUL = 995;

    address public treasury = 0x0b7EaCB3EB29B13C31d934bdfe62057BB9763Bb7;
    uint256 public performanceFee = 0.0035 ether;
    bool public activeEmergencyWithdraw = false;

    // The staked token
    IERC20 public stakingToken;
    // The earned token
    IERC20 public earnedToken;

    // The precision factor
    uint256 public PRECISION_FACTOR;

    uint256 public totalStaked;
    uint256 public prevPeriodAccToken;

    // Accrued token per share
    uint256 public accTokenPerShare;
    uint256 private totalEarned;
    uint256 private totalPaid;

    struct UserInfo {
        uint256 amount; // How many staked tokens the user has provided
        uint256 usdAmount;
        uint256 lastDepositTime;
        uint256 lastClaimTime;
        uint256 totalEarned;
        uint256 rewardDebt; // Reward debt
    }
    // Info of each user that stakes tokens (stakingToken)
    mapping(address => UserInfo) public userInfo;

    // uint256 constant TIME_UNITS = 1 days;
    uint256 constant TIME_UNITS = 2 minutes;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event AdminTokenRecovered(address tokenRecovered, uint256 amount);
    event SetEmergencyWithdrawStatus(bool status);

    event ActiveUpdated(bool isActive);
    event LockDurationUpdated(uint256 _duration);
    event HarvestCycleUpdated(uint256 _duration);
    event ServiceInfoUpadted(address addr, uint256 fee);

    event SetSettings(
        uint256 _slippageFactor,
        address _uniRouter,
        address[] _path0
    );

    modifier onlyActive () {
        require(isActive, "not enabled");
        _;
    }

    constructor() {}

    /*
     * @notice Initialize the contract
     * @param _stakingToken: staked token address
     * @param _earnedToken: earned token address
     * @param _uniRouter: uniswap router address for swap tokens
     * @param _earnedToStakedPath: swap path to compound (earned -> staking path)
     * @param _oracle: price oracle
     */
    function initialize(
        IERC20 _stakingToken,
        IERC20 _earnedToken,
        address _uniRouter,
        address[] memory _earnedToStakedPath,
        address _oracle
    ) external onlyOwner {
        require(!isInitialized, "Already initialized");

        // Make this contract initialized
        isInitialized = true;

        stakingToken = _stakingToken;
        earnedToken = _earnedToken;
        oracle = IPriceOracle(_oracle);


        uint256 decimalsRewardToken = uint256(IToken(address(earnedToken)).decimals());
        require(decimalsRewardToken < 30, "Must be inferior to 30");
        PRECISION_FACTOR = uint256(10**(40 - decimalsRewardToken));

        uniRouterAddress = _uniRouter;
        earnedToStakedPath = _earnedToStakedPath;
    }

    function deposit(uint256 _amount) external payable onlyActive nonReentrant {
        require(_amount > 0, "Amount should be greator than 0");

        UserInfo storage user = userInfo[msg.sender];

        _transferPerformanceFee();
        _updatePool();

        uint256 beforeAmount = 0;
        uint256 afterAmount = 0;
        uint256 pending = 0;
        if (user.amount > 0) {
            pending = user.amount * accTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
            pending = estimateRewardAmount(pending);
            if (pending > 0) {
                require(availableRewardTokens() >= pending, "Insufficient reward tokens");

                totalPaid = totalPaid + pending;
                totalEarned = totalEarned - pending;
                
                if(address(stakingToken) != address(earnedToken)) {
                    beforeAmount = stakingToken.balanceOf(address(this));
                    _safeSwap(pending, earnedToStakedPath, address(this));
                    afterAmount = stakingToken.balanceOf(address(this));
                    pending = afterAmount - beforeAmount;
                }
            }
        }
        
        beforeAmount = stakingToken.balanceOf(address(this));
        stakingToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        afterAmount = stakingToken.balanceOf(address(this));
        
        uint256 realAmount = afterAmount - beforeAmount + pending;
        uint256 tokenPrice = oracle.getTokenPrice(address(stakingToken));
        
        user.amount = user.amount + realAmount;
        user.usdAmount = user.usdAmount + realAmount * tokenPrice / 1e18;
        user.totalEarned = user.totalEarned + pending;
        user.lastDepositTime = block.timestamp;
        user.lastClaimTime = block.timestamp;
        user.rewardDebt = user.amount * accTokenPerShare / PRECISION_FACTOR;

        totalStaked = totalStaked + realAmount;
        
        emit Deposit(msg.sender, realAmount);
    }

    /*
     * @notice Withdraw staked tokens and collect reward tokens
     * @param _amount: amount to withdraw (in earnedToken)
     */
    function withdraw(uint256 _amount) external payable onlyActive nonReentrant {
        require(_amount > 0, "Amount should be greator than 0");

        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "Amount to withdraw too high");
        require(user.lastDepositTime + (lockDuration * TIME_UNITS) < block.timestamp, "cannot withdraw");

        _transferPerformanceFee();
        _updatePool();

        uint256 pending = user.amount * accTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
        pending = estimateRewardAmount(pending);
        if (pending > 0 && user.lastClaimTime + (harvestCycle * TIME_UNITS) < block.timestamp) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            earnedToken.safeTransfer(address(msg.sender), pending);
            
            totalPaid = totalPaid + pending;
            totalEarned = totalEarned - pending;
        } else {
            pending = 0;
        }
        
        uint256 realAmount = _amount;
        uint256 tokenPrice = oracle.getTokenPrice(address(stakingToken));
        if(realAmount * tokenPrice / 1e18 > user.usdAmount) {
            realAmount = user.usdAmount * 1e18 / tokenPrice;
            totalStaked = totalStaked - user.amount;
            
            user.amount = 0;
            user.usdAmount = 0;
        } else {
            totalStaked = totalStaked - _amount;

            user.amount = user.amount - _amount;
            user.usdAmount = user.usdAmount - _amount * tokenPrice / 1e18;
        }
        
        stakingToken.safeTransfer(address(msg.sender), realAmount);
        user.totalEarned = user.totalEarned + pending;
        user.rewardDebt = user.amount * accTokenPerShare / PRECISION_FACTOR;

        emit Withdraw(msg.sender, realAmount);
    }

    function harvest() external payable onlyActive nonReentrant {
        UserInfo storage user = userInfo[msg.sender];

        _transferPerformanceFee();
        _updatePool();

        if (user.amount == 0) return;
        require(user.lastClaimTime + (harvestCycle * TIME_UNITS) < block.timestamp, "cannot harvest");

        uint256 pending = user.amount * accTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
        pending = estimateRewardAmount(pending);
        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            earnedToken.safeTransfer(address(msg.sender), pending);
            
            totalPaid = totalPaid + pending;
            totalEarned = totalEarned - pending;
        }
        
        user.totalEarned = user.totalEarned + pending;
        user.rewardDebt = user.amount * accTokenPerShare / PRECISION_FACTOR;
        user.lastClaimTime = block.timestamp;
    }

    function _transferPerformanceFee() internal {
        require(msg.value >= performanceFee, 'should pay small gas to compound or harvest');

        payable(treasury).transfer(performanceFee);
        if(msg.value > performanceFee) {
            payable(msg.sender).transfer(msg.value - performanceFee);
        }
    }

    /*
     * @notice Withdraw staked tokens without caring about rewards
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external nonReentrant {
        require(activeEmergencyWithdraw, "Emergnecy withdraw not enabled");

        UserInfo storage user = userInfo[msg.sender];
        uint256 amountToTransfer = user.amount;
        if(amountToTransfer < 0) return;

        uint256 pending = user.amount * accTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
        pending = estimateRewardAmount(pending);
        totalEarned = totalEarned - pending;
        totalStaked = totalStaked - amountToTransfer;
        
        uint256 tokenPrice = oracle.getTokenPrice(address(stakingToken));
        if(amountToTransfer * tokenPrice / 1e18 > user.usdAmount) {
            amountToTransfer = user.usdAmount * 1e18 / tokenPrice;
        }
        stakingToken.safeTransfer(address(msg.sender), amountToTransfer);

        user.amount = 0;
        user.usdAmount = 0;
        user.rewardDebt = 0;

        emit EmergencyWithdraw(msg.sender, user.amount);
    }

    function allTimeRewards() external view returns (uint256) {
        return totalPaid + availableRewardTokens();
    }

    /**
     * @notice Available amount of reward token
     */
    function availableRewardTokens() public view returns (uint256) {
        uint256 _amount = earnedToken.balanceOf(address(this));
        if (address(earnedToken) == address(stakingToken)) {
            if (_amount < totalStaked) return 0;
            return _amount - totalStaked;
        }

        return _amount;
    }

    /*
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @return Pending reward for a given user
     */
    function pendingRewards(address _user) external view returns (uint256) {
        if(totalStaked == 0) return 0;

        UserInfo memory user = userInfo[_user];
        
        uint256 rewardAmount = availableRewardTokens();
        if(rewardAmount < totalEarned) {
            rewardAmount = totalEarned;
        }

        uint256 adjustedTokenPerShare = accTokenPerShare + (
                (rewardAmount - totalEarned) * PRECISION_FACTOR / totalStaked
            );
        
        uint256 pending = user.amount * adjustedTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
        
        return pending;
    }

    /*
     * @notice Withdraw reward token
     * @dev Only callable by owner. Needs to be for emergency.
     */
    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
        require(isActive == true, "Pool is running");
        require(availableRewardTokens() >= _amount, "Insufficient reward tokens");

        if(_amount == 0) _amount = availableRewardTokens();
        earnedToken.safeTransfer(address(msg.sender), _amount);
        
        if (totalEarned > 0) {
            if (_amount > totalEarned) {
                totalEarned = 0;
            } else {
                totalEarned = totalEarned - _amount;
            }
        }
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of tokens to withdraw
     * @dev This function is only callable by admin.
     */
    function rescueTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(
            _tokenAddress != address(earnedToken),
            "Cannot be reward token"
        );

        if(_tokenAddress == address(stakingToken)) {
            uint256 tokenBal = stakingToken.balanceOf(address(this));
            require(_tokenAmount <= tokenBal - totalStaked, "Insufficient balance");
        }

        if(_tokenAddress == address(0x0)) {
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
        }

        emit AdminTokenRecovered(_tokenAddress, _tokenAmount);
    }

    function finishThisPeriod() external onlyOwner {
        prevPeriodAccToken = totalPaid + availableRewardTokens();
    }

    function setServiceInfo(address _treasury, uint256 _fee) external {
        require(msg.sender == treasury, "setServiceInfo: FORBIDDEN");
        require(_treasury != address(0x0), "Invalid address");

        treasury = _treasury;
        performanceFee = _fee;

        emit ServiceInfoUpadted(_treasury, _fee);
    }

    function setActive(bool _isActive) external onlyOwner {
        isActive = _isActive;
        emit ActiveUpdated(_isActive);
    }

    function setLockDuration(uint256 _duration) external onlyOwner {
        require(_duration >= 0, "invalid duration");

        lockDuration = _duration;
        emit LockDurationUpdated(_duration);
    }

    function setHarvestCycle(uint256 _days) external onlyOwner {
        require(_days >= 0, "invalid duration");

        harvestCycle = _days;
        emit HarvestCycleUpdated(_days);
    }

    function setEmergencyWithdraw(bool _status) external onlyOwner {
        activeEmergencyWithdraw = _status;
        emit SetEmergencyWithdrawStatus(_status);
    }

    function setSettings(
        uint256 _slippageFactor,
        address _uniRouter,
        address[] memory _earnedToStakedPath
    ) external onlyOwner {
        require(_slippageFactor <= slippageFactorUL, "_slippageFactor too high");

        slippageFactor = _slippageFactor;
        uniRouterAddress = _uniRouter;
        earnedToStakedPath = _earnedToStakedPath;

        emit SetSettings(_slippageFactor, _uniRouter, _earnedToStakedPath);
    }

    /************************
    ** Internal Methods
    *************************/
    /*
     * @notice Update reward variables of the given pool to be up-to-date.
     */
    function _updatePool() internal {
        if(totalStaked == 0) return;

        uint256 rewardAmount = availableRewardTokens();
        if(rewardAmount < totalEarned) {
            rewardAmount = totalEarned;
        }

        accTokenPerShare = accTokenPerShare + (
                (rewardAmount - totalEarned) * PRECISION_FACTOR / totalStaked
            );

        totalEarned = rewardAmount;
    }

    function estimateRewardAmount(uint256 amount) internal view returns(uint256) {
        uint256 dTokenBal = availableRewardTokens();
        if(amount > totalEarned) amount = totalEarned;
        if(amount > dTokenBal) amount = dTokenBal;
        return amount;
    }

    function _safeSwap(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal {
        uint256[] memory amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length - 1];

        IERC20(_path[0]).safeApprove(uniRouterAddress, _amountIn);
        IUniRouter02(uniRouterAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amountIn,
            amountOut * slippageFactor / 1000,
            _path,
            _to,
            block.timestamp + 600
        );
    }

    receive() external payable {}
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IPriceOracle {
    /**
      * @notice Get the price of a token
      * @param token The token to get the price of
      * @return The asset price mantissa (scaled by 1e18).
      *  Zero means the price is unavailable.
      */
    function getTokenPrice(address token) external view returns (uint);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This contract has been developed by brewlabs.info
 */
 
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../libs/IPriceOracle.sol";

contract BlocVestAccumulatorVault is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // The staked token
    IERC20 public stakingToken;
    IPriceOracle private oracle;

    uint256[] public nominated = [7, 14, 30];
    uint256 public bonusRate = 2000;
    uint256 public depositLimit = 500 ether;

    struct UserInfo {
        uint256 amount;
        uint256 usdAmount;
        uint256 initialAmount;
        uint256 nominatedCycle;
        uint256 lastDepositTime;
        uint256 lastClaimTime;
        uint256 deposited;
        uint256 depositedUsd;
        uint256 reward;
        uint256 totalStaked;
        uint256 totalReward;
        bool isNominated;
    }
    mapping(address => UserInfo) public userInfo;
    uint256 public userCount;
    uint256 public totalStaked;

    address public treasury = 0x6219B6b621E6E66a6c5a86136145E6E5bc6e4672;
    // address public treasury = 0x0b7EaCB3EB29B13C31d934bdfe62057BB9763Bb7;
    uint256 public performanceFee = 0.0035 ether;
    // uint256 constant TIME_UNITS = 1 days;
    uint256 constant TIME_UNITS = 15 minutes;

    event Deposit(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount);
    event CycleNominated(address indexed user, uint256 cycle);
    event AdminTokenRecovered(address tokenRecovered, uint256 amount);
    event ServiceInfoUpadted(address addr, uint256 fee);
    event SetBonusRate(uint256 rate);
    event SetDepositLimit(uint256 limit);

    constructor(IERC20 _token, address _oracle) {
        stakingToken = _token;
        oracle = IPriceOracle(_oracle);
    }

    function deposit(uint256 _amount) external payable nonReentrant {
        UserInfo storage user = userInfo[msg.sender];

        require(_amount > 0, "Amount should be greator than 0");
        require(user.nominatedCycle > 0, "not nominate days");
        require(user.lastDepositTime + user.nominatedCycle * TIME_UNITS < block.timestamp, "cannot deposit before pass nominated days");

        _transferPerformanceFee();

        uint256 beforeAmount = stakingToken.balanceOf(address(this));
        stakingToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        uint256 afterAmount = stakingToken.balanceOf(address(this));        
        uint256 realAmount = afterAmount - beforeAmount;

        uint256 tokenPrice = oracle.getTokenPrice(address(stakingToken));
        uint256 usdAmount = realAmount * tokenPrice / 1 ether;
        require(usdAmount <= depositLimit, "cannot exceed max deposit limit");

        if(user.amount > 0) {
            if(user.lastClaimTime == user.lastDepositTime) {
                user.deposited += user.amount;
                user.depositedUsd += user.usdAmount;
            }

            uint256 claimable = 0;
            uint256 expireTime = user.lastDepositTime + user.nominatedCycle * TIME_UNITS + TIME_UNITS;
            if(block.timestamp < expireTime && user.usdAmount >= user.initialAmount && usdAmount >= user.initialAmount) {
                claimable = user.usdAmount * bonusRate / 10000;
            }

            user.reward += claimable;
        }

        if(user.initialAmount == 0) {
            user.initialAmount = usdAmount;
            user.isNominated = true;
            userCount = userCount + 1;
        }

        user.amount = realAmount;
        user.usdAmount = usdAmount;
        user.totalStaked += realAmount;
        user.lastDepositTime = block.timestamp;
        user.lastClaimTime = block.timestamp;
        
        totalStaked += realAmount;

        emit Deposit(msg.sender, realAmount);
    }

    function nominatedDays(uint256 _type) external {
        require(_type < nominated.length, "invalid type");
        require(userInfo[msg.sender].isNominated == false, "already nominated");

        UserInfo storage user = userInfo[msg.sender];
        user.nominatedCycle = nominated[_type];

        emit CycleNominated(msg.sender, nominated[_type]);
    }

    function claim() external payable nonReentrant {
        UserInfo storage user = userInfo[msg.sender];

        _transferPerformanceFee();

        uint256 expireTime = user.lastDepositTime + user.nominatedCycle * TIME_UNITS;
        if(block.timestamp > expireTime && user.lastClaimTime == user.lastDepositTime) {
            user.deposited += user.amount;
            user.depositedUsd += user.usdAmount;
        }

        uint256 tokenPrice = oracle.getTokenPrice(address(stakingToken));        
        uint256 claimable = user.reward * 1e18 / tokenPrice;
        user.totalReward += claimable + user.depositedUsd;

        uint256 depositedTokens = user.depositedUsd * 1e18 / tokenPrice;
        if(depositedTokens > user.deposited) {
            depositedTokens = user.deposited;
        }
        claimable += depositedTokens;

        stakingToken.safeTransfer(msg.sender, claimable);

        user.deposited = 0;
        user.depositedUsd = 0;
        user.reward = 0;
        user.lastClaimTime = block.timestamp;
        emit Claim(msg.sender, claimable);
    }

    function pendingRewards(address _user) external view returns (uint256) {
        UserInfo memory user = userInfo[_user];
        
        uint256 tokenPrice = oracle.getTokenPrice(address(stakingToken));
        uint256 claimable = user.reward * 1e18 / tokenPrice;
        
        uint256 expireTime = user.lastDepositTime + user.nominatedCycle * TIME_UNITS;
        if(block.timestamp > expireTime && user.lastClaimTime == user.lastDepositTime) {
            user.deposited += user.amount;
            user.depositedUsd += user.usdAmount;
        }

        uint256 depositedTokens = user.depositedUsd * 1e18 / tokenPrice;
        if(depositedTokens > user.deposited) {
            depositedTokens = user.deposited;
        }
        claimable += depositedTokens;

        return claimable;
    }


    function _transferPerformanceFee() internal {
        require(msg.value >= performanceFee, 'should pay small gas to compound or harvest');

        payable(treasury).transfer(performanceFee);
        if(msg.value > performanceFee) {
            payable(msg.sender).transfer(msg.value - performanceFee);
        }
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _token: the address of the token to withdraw
     * @param _amount: the number of tokens to withdraw
     * @dev This function is only callable by admin.
     */
    function rescueTokens(address _token, uint256 _amount) external onlyOwner {
        if(_token == address(0x0)) {
            payable(msg.sender).transfer(_amount);
        } else {
            IERC20(_token).safeTransfer(address(msg.sender), _amount);
        }

        emit AdminTokenRecovered(_token, _amount);
    }

    function setServiceInfo(address _treasury, uint256 _fee) external {
        require(msg.sender == treasury, "setServiceInfo: FORBIDDEN");
        require(_treasury != address(0x0), "Invalid address");

        treasury = _treasury;
        performanceFee = _fee;

        emit ServiceInfoUpadted(_treasury, _fee);
    }

    function setDepositLimit(uint256 _limit) external onlyOwner {
        depositLimit = _limit;
        emit SetDepositLimit(_limit);
    }

    function updateBonusRate(uint256 _rate) external onlyOwner {
        require(_rate <= 10000, "Invalid rate");
        bonusRate = _rate;
        emit SetBonusRate(_rate);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This contract has been developed by brewlabs.info
 */
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./libs/IPriceOracle.sol";
import "./libs/IUniRouter02.sol";
import "./libs/IWETH.sol";
interface IToken {
     /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);
}

contract BrewlabsLockupFixed is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Whether it is initialized
    bool public isInitialized;
    uint256 public duration = 365; // 365 days

    // Whether a limit is set for users
    bool public hasUserLimit;
    // The pool limit (0 if none)
    uint256 public poolLimitPerUser;


    // The block number when staking starts.
    uint256 public startBlock;
    // The block number when staking ends.
    uint256 public bonusEndBlock;
    uint256 public bonusEndTime;


    // swap router and path, slipPage
    uint256 public slippageFactor = 800; // 20% default slippage tolerance
    uint256 public constant slippageFactorUL = 995;

    address public uniRouterAddress;
    address[] public reflectionToStakedPath;
    address[] public earnedToStakedPath;

    IPriceOracle private oracle;

    address public walletA;
    address public buyBackWallet = 0x408c4aDa67aE1244dfeC7D609dea3c232843189A;
    uint256 public performanceFee = 0.0035 ether;

    // The precision factor
    uint256 public PRECISION_FACTOR;
    uint256 public PRECISION_FACTOR_BUSD;
    uint256 public PRECISION_FACTOR_REFLECTION;

    // The staked token
    IERC20 public stakingToken;
    // The earned token
    IERC20 public earnedToken;
    // The dividend token of staking token
    address public dividendToken;

    // Accrued token per share
    uint256 public accDividendPerShare;
    uint256 public rewardRate = 250;
    uint256 public rewardCycle = 7; // 7 days

    uint256 public totalStaked;

    uint256 private totalEarned;
    uint256 private totalReflections;
    uint256 private reflections;

    struct Lockup {
        uint256 duration;
        uint256 depositFee;
        uint256 withdrawFee;
        uint256 rate;
        uint256 accTokenPerShare;
        uint256 lastRewardBlock;
        uint256 totalStaked;
    }

    struct UserInfo {
        uint256 amount;         // total staked amount
        uint256 firstIndex;     // first index for unlocked elements
        uint256 reflectionDebt; // Reflection debt
    }

    struct Stake {
        uint256 amount;     // amount to stake
        uint256 amountInUsd; // amount in USD
        uint256 duration;   // the lockup duration of the stake
        uint256 end;        // when does the staking period end
        uint256 lockTime;
        uint256 rewardDebt; // Reward debt
    }
    uint256 constant MAX_STAKES = 256;
    uint256 private processingLimit = 30;

    Lockup public lockupInfo;
    mapping(address => Stake[]) public userStakes;
    mapping(address => UserInfo) public userStaked;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event AdminTokenRecovered(address tokenRecovered, uint256 amount);

    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);
    event LockupUpdated(uint256 _duration, uint256 _fee0, uint256 _fee1, uint256 _rate);
    event RewardsStop(uint256 blockNumber);
    event EndBlockUpdated(uint256 blockNumber);
    event UpdatePoolLimit(uint256 poolLimitPerUser, bool hasLimit);

    event ServiceInfoUpadted(address _addr, uint256 _fee);
    event WalletAUpdated(address _addr);
    event DurationUpdated(uint256 _duration);

    event SetSettings(
        uint256 _slippageFactor,
        address _uniRouter,
        address[] _path0,
        address[] _path1
    );

    constructor() {}

    /*
     * @notice Initialize the contract
     * @param _stakingToken: staked token address
     * @param _earnedToken: earned token address
     * @param _dividendToken: reflection token address
     * @param _uniRouter: uniswap router address for swap tokens
     * @param _earnedToStakedPath: swap path to compound (earned -> staking path)
     * @param _reflectionToStakedPath: swap path to compound (reflection -> staking path)
     */
    function initialize(
        IERC20 _stakingToken,
        IERC20 _earnedToken,
        address _dividendToken,
        uint256 _rewardPerBlock,
        uint256 _depositFee,
        uint256 _withdrawFee,
        uint256 _lockDuration,
        address _uniRouter,
        address _oracle,
        address[] memory _earnedToStakedPath,
        address[] memory _reflectionToStakedPath
    ) external onlyOwner {
        require(!isInitialized, "Already initialized");

        // Make this contract initialized
        isInitialized = true;

        stakingToken = _stakingToken;
        earnedToken = _earnedToken;
        dividendToken = _dividendToken;

        walletA = msg.sender;
        oracle = IPriceOracle(_oracle);

        uint256 decimalsRewardToken = uint256(IToken(address(earnedToken)).decimals());
        require(decimalsRewardToken < 30, "Must be inferior to 30");
        PRECISION_FACTOR = uint256(10**(40 - decimalsRewardToken));
        PRECISION_FACTOR_BUSD = uint256(10**(IToken(address(stakingToken)).decimals()));

        uint256 decimalsdividendToken = 18;
        if(address(dividendToken) != address(0x0)) {
            decimalsdividendToken = uint256(IToken(address(dividendToken)).decimals());
            require(decimalsdividendToken < 30, "Must be inferior to 30");
        }
        PRECISION_FACTOR_REFLECTION = uint256(10**(40 - decimalsdividendToken));

        uniRouterAddress = _uniRouter;
        earnedToStakedPath = _earnedToStakedPath;
        reflectionToStakedPath = _reflectionToStakedPath;

        lockupInfo.duration = _lockDuration;
        lockupInfo.depositFee = _depositFee;
        lockupInfo.withdrawFee = _withdrawFee;
        lockupInfo.rate = _rewardPerBlock;
        lockupInfo.accTokenPerShare = 0;
        lockupInfo.lastRewardBlock = 0;
        lockupInfo.totalStaked = 0;
    }

    /*
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @param _amount: amount to withdraw (in earnedToken)
     */
    function deposit(uint256 _amount) external payable nonReentrant {
        require(startBlock > 0 && startBlock < block.number, "Staking hasn't started yet");
        require(_amount > 0, "Amount should be greator than 0");

        _transferPerformanceFee();
        _updatePool();

        UserInfo storage user = userStaked[msg.sender];
        uint256 pendingReflection = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - user.reflectionDebt;
        pendingReflection = estimateDividendAmount(pendingReflection);
        if (pendingReflection > 0) {
            if(address(dividendToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingReflection);
            } else {
                IERC20(dividendToken).safeTransfer(address(msg.sender), pendingReflection);
            }
            totalReflections = totalReflections - pendingReflection;
        }

        uint256 beforeAmount = stakingToken.balanceOf(address(this));
        stakingToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        uint256 afterAmount = stakingToken.balanceOf(address(this));        
        uint256 realAmount = afterAmount - beforeAmount;

        if (hasUserLimit) {
            require(
                realAmount + user.amount <= poolLimitPerUser,
                "User amount above limit"
            );
        }
        if (lockupInfo.depositFee > 0) {
            uint256 fee = realAmount * lockupInfo.depositFee / 10000;
            if (fee > 0) {
                stakingToken.safeTransfer(walletA, fee);
                realAmount = realAmount - fee;
            }
        }
        
        _addStake(msg.sender, lockupInfo.duration, realAmount, user.firstIndex);

        user.amount = user.amount + realAmount;
        user.reflectionDebt = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;

        lockupInfo.totalStaked = lockupInfo.totalStaked + realAmount;
        totalStaked = totalStaked + realAmount;

        emit Deposit(msg.sender, realAmount);
    }

    function _addStake(address _account, uint256 _duration, uint256 _amount, uint256 firstIndex) internal {
        Stake[] storage stakes = userStakes[_account];

        uint256 end = block.timestamp + _duration * 1 days;
        uint256 i = stakes.length;
        require(i < MAX_STAKES, "Max stakes");

        stakes.push(); // grow the array
        // find the spot where we can insert the current stake
        // this should make an increasing list sorted by end
        while (i != 0 && stakes[i - 1].end > end && i >= firstIndex) {
            // shift it back one
            stakes[i] = stakes[i - 1];
            i -= 1;
        }
        
        uint256 tokenPrice = oracle.getTokenPrice(address(stakingToken));

        // insert the stake
        Stake storage newStake = stakes[i];
        newStake.duration = _duration;
        newStake.end = end;
        newStake.amount = _amount;
        newStake.amountInUsd = _amount * tokenPrice / PRECISION_FACTOR_BUSD;
        newStake.lockTime = block.timestamp;
        newStake.rewardDebt = 0;
    }

    /*
     * @notice Withdraw staked tokens and collect reward tokens
     * @param _amount: amount to withdraw (in earnedToken)
     */
    function withdraw(uint256 _amount) external payable nonReentrant {
        require(_amount > 0, "Amount should be greator than 0");

        _transferPerformanceFee();
        _updatePool();

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        
        bool bUpdatable = true;
        uint256 firstIndex = user.firstIndex;
        uint256 tokenPrice = oracle.getTokenPrice(address(stakingToken));

        uint256 pending = 0;
        uint256 remained = _amount;
        for(uint256 j = user.firstIndex; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(bUpdatable && stake.amount == 0) firstIndex = j;
            if(stake.amount == 0) continue;
            if(remained == 0) break;

            if(j - user.firstIndex > processingLimit) break;

            uint256 _pending = _calcReward(stake.amountInUsd, stake.lockTime, stake.rewardDebt);
            pending = pending + _pending;
            if(stake.end < block.timestamp) {
                if(stake.amount > remained) {
                    stake.amount = stake.amount - remained;
                    remained = 0;
                } else {
                    remained = remained - stake.amount;
                    stake.amount = 0;

                    if(bUpdatable) firstIndex = j;
                }
            }

            stake.amountInUsd = stake.amount * tokenPrice / PRECISION_FACTOR_BUSD;
            stake.rewardDebt = _calcReward(stake.amountInUsd, stake.lockTime, 0);
            if(stake.amount > 0) bUpdatable = false;
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            uint256 fee = pending * lockupInfo.withdrawFee / 10000;
            earnedToken.safeTransfer(walletA, fee);
            earnedToken.safeTransfer(address(msg.sender), pending - fee);
            
            if(totalEarned > pending) {
                totalEarned = totalEarned - pending;
            } else {
                totalEarned = 0;
            }
        }
        
        uint256 pendingReflection = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - user.reflectionDebt;
        pendingReflection = estimateDividendAmount(pendingReflection);
        if (pendingReflection > 0) {
            if(address(dividendToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingReflection);
            } else {
                IERC20(dividendToken).safeTransfer(address(msg.sender), pendingReflection);
            }
            totalReflections = totalReflections - pendingReflection;
        }

        uint256 realAmount = _amount - remained;
        user.firstIndex = firstIndex;
        user.amount = user.amount - realAmount;
        user.reflectionDebt = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;

        lockupInfo.totalStaked = lockupInfo.totalStaked - realAmount;
        totalStaked = totalStaked - realAmount;

        stakingToken.safeTransfer(address(msg.sender), realAmount);

        emit Withdraw(msg.sender, realAmount);
    }

    function claimReward() external payable nonReentrant {
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool();

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];

        uint256 pending = 0;
        for(uint256 j = user.firstIndex; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.amount == 0) continue;
            if(j - user.firstIndex > processingLimit) break;

            uint256 _pending = _calcReward(stake.amountInUsd, stake.lockTime, stake.rewardDebt);

            pending = pending + _pending;
            stake.rewardDebt = stake.rewardDebt + _pending;
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            earnedToken.safeTransfer(address(msg.sender), pending);
            
            if(totalEarned > pending) {
                totalEarned = totalEarned - pending;
            } else {
                totalEarned = 0;
            }
        }
    }

    function claimDividend() external payable nonReentrant {
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool();

        UserInfo storage user = userStaked[msg.sender];
        if (user.amount == 0) return;

        uint256 pendingReflection = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - user.reflectionDebt;
        pendingReflection = estimateDividendAmount(pendingReflection);
        if (pendingReflection > 0) {
            if(address(dividendToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingReflection);
            } else {
                IERC20(dividendToken).safeTransfer(address(msg.sender), pendingReflection);
            }
            totalReflections = totalReflections - pendingReflection;
        }
        user.reflectionDebt = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
    }

    function compoundReward() external payable nonReentrant {
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool();

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];

        uint256 tokenPrice = oracle.getTokenPrice(address(stakingToken));

        uint256 pending = 0;
        uint256 compounded = 0;
        for(uint256 j = user.firstIndex; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.amount == 0) continue;
            if(j - user.firstIndex > processingLimit) break;

            uint256 _pending = _calcReward(stake.amountInUsd, stake.lockTime, stake.rewardDebt);
            pending = pending + _pending;

            if(address(stakingToken) != address(earnedToken) && _pending > 0) {
                uint256 _beforeAmount = stakingToken.balanceOf(address(this));
                _safeSwap(_pending, earnedToStakedPath, address(this));
                uint256 _afterAmount = stakingToken.balanceOf(address(this));
                _pending = _afterAmount - _beforeAmount;
            }
            compounded = compounded + _pending;

            stake.amount = stake.amount + _pending;
            stake.amountInUsd = stake.amount * tokenPrice / PRECISION_FACTOR_BUSD;
            stake.rewardDebt = _calcReward(stake.amountInUsd, stake.lockTime, 0);
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            
            if(totalEarned > pending) {
                totalEarned = totalEarned - pending;
            } else {
                totalEarned = 0;
            }

            user.amount = user.amount + compounded;
            user.reflectionDebt = user.reflectionDebt + compounded * accDividendPerShare / PRECISION_FACTOR_REFLECTION;

            lockupInfo.totalStaked = lockupInfo.totalStaked + compounded;
            totalStaked = totalStaked + compounded;

            emit Deposit(msg.sender, compounded);
        }
    }

    function compoundDividend() external payable nonReentrant {
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool();

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];

        uint256 tokenPrice = oracle.getTokenPrice(address(stakingToken));

        uint256 pending = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - user.reflectionDebt;
        pending = estimateDividendAmount(pending);
        totalReflections = totalReflections - pending;
        if(address(stakingToken) != address(dividendToken) && pending > 0) {
            if(address(dividendToken) == address(0x0)) {
                address wethAddress = IUniRouter02(uniRouterAddress).WETH();
                IWETH(wethAddress).deposit{ value: pending }();
            }

            uint256 _beforeAmount = stakingToken.balanceOf(address(this));
            _safeSwap(pending, reflectionToStakedPath, address(this));
            uint256 _afterAmount = stakingToken.balanceOf(address(this));
            pending = _afterAmount - _beforeAmount;
        }

        if(pending > 0) {            
            Stake storage stake = stakes[user.firstIndex];

            uint256 _pendingReward = _calcReward(stake.amountInUsd, stake.lockTime, stake.rewardDebt);

            stake.amount = stake.amount + pending;
            stake.amountInUsd = stake.amount * tokenPrice / PRECISION_FACTOR_BUSD;
            
            uint256 rewardDebt = _calcReward(stake.amountInUsd, stake.lockTime, 0);
            if(rewardDebt > _pendingReward) {
                stake.rewardDebt = _calcReward(stake.amountInUsd, stake.lockTime, 0) - _pendingReward;
            } else {
                stake.rewardDebt = 0;
            }
        
            user.amount = user.amount + pending;
            user.reflectionDebt = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;

            lockupInfo.totalStaked = lockupInfo.totalStaked + pending;
            totalStaked = totalStaked + pending;

            emit Deposit(msg.sender, pending);
        }
    }

    function _transferPerformanceFee() internal {
        require(msg.value >= performanceFee, 'should pay small gas to compound or harvest');

        payable(buyBackWallet).transfer(performanceFee);
        if(msg.value > performanceFee) {
            payable(msg.sender).transfer(msg.value - performanceFee);
        }
    }

    /*
     * @notice Withdraw staked tokens without caring about rewards
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external nonReentrant {
        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];

        uint256 firstIndex = user.firstIndex;
        uint256 amountToTransfer = 0;
        for(uint256 j = user.firstIndex; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.amount == 0) {
                firstIndex = j;
                continue;
            }
            if(j - user.firstIndex > processingLimit) break;

            amountToTransfer = amountToTransfer + stake.amount;

            stake.amount = 0;
            stake.rewardDebt = 0;
            
            firstIndex = j;
        }

        if (amountToTransfer > 0) {
            stakingToken.safeTransfer(address(msg.sender), amountToTransfer);

            user.firstIndex = firstIndex;
            user.amount = user.amount - amountToTransfer;
            user.reflectionDebt = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;

            lockupInfo.totalStaked = lockupInfo.totalStaked - amountToTransfer;
            totalStaked = totalStaked - amountToTransfer;
        }

        emit EmergencyWithdraw(msg.sender, amountToTransfer);
    }

    function rewardPerBlock() external view returns (uint256) {
        return lockupInfo.rate;
    }

    /**
     * @notice Available amount of reward token
     */
    function availableRewardTokens() public view returns (uint256) {
        if(address(earnedToken) == address(dividendToken)) return totalEarned;

        uint256 _amount = earnedToken.balanceOf(address(this));
        if (address(earnedToken) == address(stakingToken)) {
            if (_amount < totalStaked) return 0;
            return _amount - totalStaked;
        }

        return _amount;
    }

    /**
     * @notice Available amount of reflection token
     */
    function availableDividendTokens() public view returns (uint256) {
        if(address(dividendToken) == address(0x0)) {
            return address(this).balance;
        }

        uint256 _amount = IERC20(dividendToken).balanceOf(address(this));
        
        if(address(dividendToken) == address(earnedToken)) {
            if(_amount < totalEarned) return 0;
            _amount = _amount - totalEarned;
        }

        if(address(dividendToken) == address(stakingToken)) {
            if(_amount < totalStaked) return 0;
            _amount = _amount - totalStaked;
        }

        return _amount;
    }

    function userInfo(address _account) external view returns (uint256 amount, uint256 available, uint256 locked) {
        UserInfo memory user = userStaked[msg.sender];
        Stake[] memory stakes = userStakes[_account];
        
        for(uint256 i = user.firstIndex; i < stakes.length; i++) {
            Stake memory stake = stakes[i];
            if(stake.amount == 0) continue;
            
            amount = amount + stake.amount;
            if(block.timestamp > stake.end) {
                available = available + stake.amount;
            } else {
                locked = locked + stake.amount;
            }
        }
    }

    /*
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @return Pending reward for a given user
     */
    function pendingReward(address _account) external view returns (uint256) {
        if(startBlock == 0) return 0;

        UserInfo memory user = userStaked[_account];
        Stake[] memory stakes = userStakes[_account];

        if(lockupInfo.totalStaked == 0 || user.amount == 0) return 0;

        uint256 pending = 0;
        for(uint256 i = user.firstIndex; i < stakes.length; i++) {
            Stake memory stake = stakes[i];
            if(stake.amount == 0) continue;

            pending = pending + (
                _calcReward(stake.amountInUsd, stake.lockTime, stake.rewardDebt)
            );
        }
        return pending;
    }

    function pendingDividends(address _account) external view returns (uint256) {
        if(startBlock == 0 || totalStaked == 0) return 0;
        
        UserInfo memory user = userStaked[_account];
        if(user.amount == 0) return 0;

        uint256 reflectionAmount = availableDividendTokens();
        if(reflectionAmount < totalReflections) {
            reflectionAmount = totalReflections;
        }

        uint256 sTokenBal = totalStaked;
        uint256 eTokenBal = availableRewardTokens();
        if(address(stakingToken) == address(earnedToken)) {
            sTokenBal = sTokenBal + eTokenBal;
        }

        uint256 adjustedReflectionPerShare = accDividendPerShare + (
                (reflectionAmount - totalReflections) * PRECISION_FACTOR_REFLECTION / sTokenBal
            );
        
        uint256 pendingReflection = user.amount * adjustedReflectionPerShare / PRECISION_FACTOR_REFLECTION - user.reflectionDebt;
        return pendingReflection;
    }

    /************************
    ** Admin Methods
    *************************/
    function harvest() external onlyOwner {
        _updatePool();

        reflections = estimateDividendAmount(reflections);
        if(reflections > 0) {            
            if(address(dividendToken) == address(0x0)) {
                payable(walletA).transfer(reflections);
            } else {
                IERC20(dividendToken).safeTransfer(walletA, reflections);
            }

            totalReflections = totalReflections - reflections;
            reflections = 0;
        }
    }

    /*
     * @notice Deposit reward token
     * @dev Only call by owner. Needs to be for deposit of reward token when reflection token is same with reward token.
     */
    function depositRewards(uint _amount) external onlyOwner nonReentrant {
        require(_amount > 0, "invalid amount");

        uint256 beforeAmt = earnedToken.balanceOf(address(this));
        earnedToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = earnedToken.balanceOf(address(this));

        totalEarned = totalEarned + afterAmt - beforeAmt;
    }

    /*
     * @notice Withdraw reward token
     * @dev Only callable by owner. Needs to be for emergency.
     */
    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
        require( block.number > bonusEndBlock, "Pool is running");
        require(availableRewardTokens() >= _amount, "Insufficient reward tokens");

        earnedToken.safeTransfer(address(msg.sender), _amount);
        
        if (totalEarned > 0) {
            if (_amount > totalEarned) {
                totalEarned = 0;
            } else {
                totalEarned = totalEarned - _amount;
            }
        }
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of tokens to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(
            _tokenAddress != address(earnedToken),
            "Cannot be reward token"
        );

        if(_tokenAddress == address(stakingToken)) {
            uint256 tokenBal = stakingToken.balanceOf(address(this));
            require(_tokenAmount <= tokenBal - totalStaked, "Insufficient balance");
        }

        if(_tokenAddress == address(0x0)) {
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
        }

        emit AdminTokenRecovered(_tokenAddress, _tokenAmount);
    }

    function startReward() external onlyOwner {
        require(startBlock == 0, "Pool was already started");

        startBlock = block.number + 100;
        bonusEndBlock = startBlock + duration * 28800;
        bonusEndTime = block.timestamp + duration * 1 days + 300;
        lockupInfo.lastRewardBlock = startBlock;
        
        emit NewStartAndEndBlocks(startBlock, bonusEndBlock);
    }

    function stopReward() external onlyOwner {
        bonusEndBlock = block.number;
        bonusEndTime = block.timestamp;
        emit RewardsStop(bonusEndBlock);
    }

    function updateEndBlock(uint256 _endBlock) external onlyOwner {
        require(startBlock > 0, "Pool is not started");
        require(bonusEndBlock > block.number, "Pool was already finished");
        require(_endBlock > block.number && _endBlock > startBlock, "Invalid end block");
        bonusEndBlock = _endBlock;
        bonusEndTime = block.timestamp + (_endBlock - block.number) * 3;

        emit EndBlockUpdated(_endBlock);
    }

    /*
     * @notice Update pool limit per user
     * @dev Only callable by owner.
     * @param _hasUserLimit: whether the limit remains forced
     * @param _poolLimitPerUser: new pool limit per user
     */
    function updatePoolLimitPerUser( bool _hasUserLimit, uint256 _poolLimitPerUser) external onlyOwner {
        if (_hasUserLimit) {
            require(
                _poolLimitPerUser > poolLimitPerUser,
                "New limit must be higher"
            );
            poolLimitPerUser = _poolLimitPerUser;
        } else {
            poolLimitPerUser = 0;
        }
        hasUserLimit = _hasUserLimit;

        emit UpdatePoolLimit(poolLimitPerUser, hasUserLimit);
    }

    function updateLockup(uint256 _duration, uint256 _depositFee, uint256 _withdrawFee, uint256 _rate) external onlyOwner {
        // require(block.number < startBlock, "Pool was already started");
        require(_depositFee < 2000, "Invalid deposit fee");
        require(_withdrawFee < 2000, "Invalid withdraw fee");

        _updatePool();

        lockupInfo.duration = _duration;
        lockupInfo.depositFee = _depositFee;
        lockupInfo.withdrawFee = _withdrawFee;
        lockupInfo.rate = _rate;
        
        emit LockupUpdated(_duration, _depositFee, _withdrawFee, _rate);
    }

    function setServiceInfo(address _addr, uint256 _fee) external {
        require(msg.sender == buyBackWallet, "setServiceInfo: FORBIDDEN");
        require(_addr != address(0x0), "Invalid address");

        buyBackWallet = _addr;
        performanceFee = _fee;

        emit ServiceInfoUpadted(_addr, _fee);
    }
    
    function setDuration(uint256 _duration) external onlyOwner {
        require(startBlock == 0, "Pool was already started");

        duration = _duration;
        emit DurationUpdated(_duration);
    }
    
    function setProcessingLimit(uint256 _limit) external onlyOwner {
        require(_limit > 0, "Invalid limit");
        processingLimit = _limit;
    }

    function setSettings(
        uint256 _slippageFactor, 
        address _uniRouter, 
        address[] memory _earnedToStakedPath, 
        address[] memory _reflectionToStakedPath
    ) external onlyOwner {
        require(_slippageFactor <= slippageFactorUL, "_slippageFactor too high");

        slippageFactor = _slippageFactor;
        uniRouterAddress = _uniRouter;
        reflectionToStakedPath = _reflectionToStakedPath;
        earnedToStakedPath = _earnedToStakedPath;

        emit SetSettings(_slippageFactor, _uniRouter, _earnedToStakedPath, _reflectionToStakedPath);
    }
    
    function updateWalletA(address _walletA) external onlyOwner {
        require(_walletA != address(0x0) || _walletA != walletA, "Invalid address");

        walletA = _walletA;
        emit WalletAUpdated(_walletA);
    }

    /************************
    ** Internal Methods
    *************************/
    /*
     * @notice Update reward variables of the given pool to be up-to-date.
     */
    function _updatePool() internal {
        // calc reflection rate
        if(totalStaked > 0) {
            uint256 reflectionAmount = availableDividendTokens();
            if(reflectionAmount < totalReflections) {
                reflectionAmount = totalReflections;
            }

            uint256 sTokenBal = totalStaked;
            uint256 eTokenBal = availableRewardTokens();
            if(address(stakingToken) == address(earnedToken)) {
                sTokenBal = sTokenBal + eTokenBal;
            }

            accDividendPerShare = accDividendPerShare + (
                    (reflectionAmount - totalReflections) * PRECISION_FACTOR_REFLECTION / sTokenBal
                );

            if(address(stakingToken) == address(earnedToken)) {
                reflections = reflections + (reflectionAmount - totalReflections) * eTokenBal / sTokenBal;
            }
            totalReflections = reflectionAmount;
        }

        if (block.number <= lockupInfo.lastRewardBlock || lockupInfo.lastRewardBlock == 0) return;
        lockupInfo.lastRewardBlock = block.number;
    }
    
    function _calcReward(uint256 _amountInUsd, uint256 _lockTime, uint256 _debt) public view returns (uint256) {
        if(block.timestamp < _lockTime || bonusEndTime < _lockTime) return 0;
        
        uint256 _rate = (block.timestamp - _lockTime) / (rewardCycle  * 1 days);
        if(block.timestamp > bonusEndTime) {
            _rate = (bonusEndTime - _lockTime) / (rewardCycle  * 1 days);
        }
        _rate = _rate * rewardRate;

        uint256 reward = _amountInUsd * _rate / 10000;
        if(reward < _debt) return 0;
        return reward - _debt;
    }

    function estimateDividendAmount(uint256 amount) internal view returns(uint256) {
        uint256 dTokenBal = availableDividendTokens();
        if(amount > totalReflections) amount = totalReflections;
        if(amount > dTokenBal) amount = dTokenBal;
        return amount;
    }

    function _safeSwap(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal {
        uint256[] memory amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length - 1];
        
        IERC20(_path[0]).safeApprove(uniRouterAddress, _amountIn);
        IUniRouter02(uniRouterAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amountIn,
            amountOut * slippageFactor / 1000,
            _path,
            _to,
            block.timestamp + 600
        );
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This contract has been developed by brewlabs.info
 */
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract BlocVaultVesting is Ownable, ReentrancyGuard{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool public     isActive = false;
    bool private    initialized = false;

    IERC20  public  vestingToken;
    address public  reflectionToken;
    uint256 private accReflectionPerShare;
    uint256 private allocatedReflections;
    uint256 private reflectionDebt;

    uint256[4] public duration = [90, 180, 240, 360];
    uint256 public rewardCycle = 30;    // 30 days
    uint256 public rewardRate = 1000;   // 10% per 30 days

    uint256 public harvestCycle = 7; // 7 days

    uint256 private PRECISION_FACTOR = 1 ether;
    uint256 private TIME_UNIT = 1 days;

    struct UserInfo {
        uint256 counts;          // number of vesting
        uint256 totalVested;     // vested total amount in wei
    }

    struct VestingInfo {
        uint256 amount;             // vested amount
        uint256 duration;           // lock duration in day
        uint256 lockedTime;         // timestamp that user locked tokens
        uint256 releaseTime;        // timestamp that user can unlock tokens
        uint256 lastHarvestTime;    // last timestamp that user harvested reflections of vested tokens
        uint256 tokenDebt;          // amount that user havested reward
        uint256 reflectionDebt;
        uint8   status;
    }
   
    uint256 public totalVested = 0;
    uint256 private totalEarned;
    mapping(address => UserInfo) public userInfo;
    mapping(address => mapping(uint256 => VestingInfo))  public vestingInfos;

    event Vested(address user, uint256 id, uint256 amount, uint256 duration);
    event Released(address user, uint256 id, uint256 amount);
    event Revoked(address user, uint256 id, uint256 amount);
    event RewardClaimed(address user, uint256 amount);
    event DividendClaimed(address user, uint256 amount);
    event EmergencyWithdrawn(address indexed user, uint256 amount);
    event DurationUpdated(uint256 idx, uint256 duration);
    event RateUpdated(uint256 rate);
        
    modifier onlyActive() {
        require(isActive == true, "not active");
        _;
    }

    constructor () {}

    function initialize(IERC20 _token, address _reflectionToken) external onlyOwner {
        require(initialized == false, "already initialized");
        initialized = true;

        vestingToken = _token;
        reflectionToken = _reflectionToken;
    }

    function vest(uint256 _amount, uint256 _type) external onlyActive nonReentrant {
        require(_amount > 0, "Invalid amount");
        require(_type < 4, "Invalid vesting type");

        _updatePool();
        
        uint256 beforeAmount = vestingToken.balanceOf(address(this));
        vestingToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmount = vestingToken.balanceOf(address(this));
        uint256 realAmount = afterAmount.sub(beforeAmount);
        
        UserInfo storage _userInfo = userInfo[msg.sender];
        
        uint256 lastIndex = _userInfo.counts;
        vestingInfos[msg.sender][lastIndex] = VestingInfo(
            realAmount,
            duration[_type],
            block.timestamp,
            block.timestamp.add(duration[_type].mul(TIME_UNIT)),
            block.timestamp,
            0,
            realAmount.mul(accReflectionPerShare).div(PRECISION_FACTOR),
            0
        );
        
        _userInfo.counts = lastIndex.add(1);
        _userInfo.totalVested = _userInfo.totalVested.add(realAmount);

        totalVested = totalVested.add(realAmount);

        emit Vested(msg.sender, lastIndex, _amount, duration[_type]);
    }

    function revoke(uint256 _vestId) external onlyActive nonReentrant {
        VestingInfo storage _vest = vestingInfos[msg.sender][_vestId];
        require(_vest.amount > 0 && _vest.status == 0, "Not available");

        vestingToken.safeTransfer(msg.sender, _vest.amount);

        _vest.status = 2;

        UserInfo storage _userInfo = userInfo[msg.sender];
        _userInfo.totalVested = _userInfo.totalVested.sub(_vest.amount);
        totalVested = totalVested.sub(_vest.amount);

        emit Revoked(msg.sender, _vestId, _vest.amount);
    }

    function release(uint256 _vestId) external onlyActive nonReentrant {
        VestingInfo storage _vest = vestingInfos[msg.sender][_vestId];

        require(_vest.amount > 0 && _vest.status == 0, "Not available");
        require(_vest.releaseTime < block.timestamp, "Not Releasable");

        _updatePool();

        uint pending = calcReward(_vest.amount, _vest.lockedTime, _vest.releaseTime, _vest.tokenDebt);
        require(pending <= availableRewardTokens(), "Insufficient reward");

        uint256 claimAmt = _vest.amount.add(pending);
        if(claimAmt > 0) {
            vestingToken.safeTransfer(msg.sender, claimAmt);
            emit RewardClaimed(msg.sender, pending);
        }

        if(totalEarned > pending) {
            totalEarned = totalEarned.sub(pending);
        } else {
            totalEarned = 0;
        }

        uint256 reflectionAmt = _vest.amount.mul(accReflectionPerShare).div(PRECISION_FACTOR).sub(_vest.reflectionDebt);
        if(reflectionAmt > 0) {
            if(reflectionToken == address(0x0)) {
                payable(msg.sender).transfer(reflectionAmt);
            } else {
                IERC20(reflectionToken).safeTransfer(msg.sender, reflectionAmt);
            }
            allocatedReflections = allocatedReflections.sub(reflectionAmt);
            emit DividendClaimed(msg.sender, reflectionAmt);
        }

        _vest.tokenDebt = _vest.tokenDebt.add(pending);
        _vest.reflectionDebt = _vest.amount.mul(accReflectionPerShare).div(PRECISION_FACTOR);
        _vest.status = 1;

        UserInfo storage _userInfo = userInfo[msg.sender];
        _userInfo.totalVested = _userInfo.totalVested.sub(_vest.amount);
        totalVested = totalVested.sub(_vest.amount);

        emit Released(msg.sender, _vestId, _vest.amount);
    }

    function claimDividend(uint256 _vestId) external onlyActive nonReentrant {
        VestingInfo storage _vest = vestingInfos[msg.sender][_vestId];
        require(_vest.amount > 0 && _vest.status == 0, "Not available");
        require(block.timestamp.sub(_vest.lastHarvestTime) > harvestCycle.mul(TIME_UNIT), "Cannot harvest in 7 days after last harvest");

        _updatePool();

        uint256 reflectionAmt = _vest.amount.mul(accReflectionPerShare).div(PRECISION_FACTOR).sub(_vest.reflectionDebt);
        if(reflectionAmt > 0) {
            if(reflectionToken == address(0x0)) {
                payable(msg.sender).transfer(reflectionAmt);
            } else {
                IERC20(reflectionToken).safeTransfer(msg.sender, reflectionAmt);
            }

            allocatedReflections = allocatedReflections.sub(reflectionAmt);
            emit DividendClaimed(msg.sender, reflectionAmt);
        }

        _vest.lastHarvestTime = block.timestamp;
        _vest.reflectionDebt = _vest.amount.mul(accReflectionPerShare).div(PRECISION_FACTOR);
    }

    function claimReward(uint256 _vestId) external onlyActive nonReentrant {
        VestingInfo storage _vest = vestingInfos[msg.sender][_vestId];
        require(_vest.amount > 0 && _vest.status == 0, "Not available");
        require(block.timestamp.sub(_vest.lastHarvestTime) > harvestCycle.mul(TIME_UNIT), "Cannot harvest in 7 days after last harvest");

        uint pending = calcReward(_vest.amount, _vest.lockedTime, _vest.releaseTime, _vest.tokenDebt);
        require(pending <= availableRewardTokens(), "Insufficient reward");

        if(pending > 0) {
            vestingToken.safeTransfer(msg.sender, pending);
            emit RewardClaimed(msg.sender, pending);

            if(totalEarned > pending) {
                totalEarned = totalEarned.sub(pending);
            } else {
                totalEarned = 0;
            }
        }        

        _vest.lastHarvestTime = block.timestamp;
        _vest.tokenDebt = _vest.tokenDebt.add(pending);
    }

    function calcReward(uint256 _amount, uint256 _lockedTime, uint256 _releaseTime, uint256 _rewardDebt) internal view returns(uint256 reward) {
        if(_lockedTime > block.timestamp) return 0;

        uint256 passTime = block.timestamp.sub(_lockedTime);
        if(_releaseTime < block.timestamp) {
            passTime = _releaseTime.sub(_lockedTime);
        }

        reward = _amount.mul(rewardRate).div(10000)
                        .mul(passTime).div(rewardCycle.mul(TIME_UNIT))
                        .sub(_rewardDebt);
    }

    function pendingClaim(address _user, uint256 _vestId) external view returns (uint256 pending) {
        VestingInfo storage _vest = vestingInfos[_user][_vestId];
        if(_vest.status > 0 || _vest.amount == 0) return 0;

        pending = calcReward(_vest.amount, _vest.lockedTime, _vest.releaseTime, _vest.tokenDebt);
    }

    function pendingDividend(address _user, uint256 _vestId) external view returns (uint256 pending) {
        VestingInfo storage _vest = vestingInfos[_user][_vestId];
        if(_vest.status > 0 || _vest.amount == 0) return 0;

        uint256 tokenAmt = vestingToken.balanceOf(address(this));
        if(tokenAmt == 0) return 0;

        uint256 reflectionAmt = availableDividendTokens();
        reflectionAmt = reflectionAmt.sub(allocatedReflections);
        uint256 _accReflectionPerShare = accReflectionPerShare.add(reflectionAmt.mul(PRECISION_FACTOR).div(tokenAmt));

        pending = _vest.amount.mul(_accReflectionPerShare).div(PRECISION_FACTOR).sub(_vest.reflectionDebt);
    }

    /**
     * @notice Available amount of reflection token
     */
    function availableDividendTokens() public view returns (uint256) {
        if(address(reflectionToken) == address(0x0)) {
            return address(this).balance;
        }

        if(address(reflectionToken) == address(vestingToken)) {
            uint256 _amount = IERC20(reflectionToken).balanceOf(address(this));
            if(_amount < totalEarned.add(totalVested)) return 0;
            return _amount.sub(totalEarned).sub(totalVested);
        } else {
            uint256 _amount = address(this).balance;
            if(reflectionToken != address(0x0)) {
                _amount = IERC20(reflectionToken).balanceOf(address(this));
            }
            return _amount;
        }
    }
    
    /**
     * @notice Available amount of reward token
     */
    function availableRewardTokens() public view returns (uint256) {
        if(address(vestingToken) == address(reflectionToken)) return totalEarned;

        uint256 _amount = vestingToken.balanceOf(address(this));
        if (_amount < totalVested) return 0;
        return _amount.sub(totalVested);
    }

     /*
     * @notice Deposit reward token
     * @dev Only call by owner. Needs to be for deposit of reward token when reflection token is same with reward token.
     */
    function depositRewards(uint _amount) external nonReentrant {
        require(_amount > 0);

        uint256 beforeAmt = vestingToken.balanceOf(address(this));
        vestingToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = vestingToken.balanceOf(address(this));

        totalEarned = totalEarned.add(afterAmt).sub(beforeAmt);
    }

    function harvest() external onlyOwner {
        _updatePool();

        uint256 tokenAmt = availableRewardTokens();
        uint256 reflectionAmt = (tokenAmt).mul(accReflectionPerShare).div(PRECISION_FACTOR).sub(reflectionDebt);
        if(reflectionAmt > 0) {
            payable(msg.sender).transfer(reflectionAmt);
        } else {
            IERC20(reflectionToken).safeTransfer(msg.sender, reflectionAmt);
        }

        reflectionDebt = (tokenAmt.sub(totalVested)).mul(accReflectionPerShare).div(PRECISION_FACTOR);
    }

    function emergencyWithdraw() external onlyOwner {
        uint256 tokenAmt = vestingToken.balanceOf(address(this));
        if(tokenAmt > 0) {
            vestingToken.transfer(msg.sender, tokenAmt.sub(totalVested));
        }

        if(address(reflectionToken) != address(vestingToken)) {
            uint256 reflectionAmt = address(this).balance;
            if(reflectionToken != address(0x0)) {
                reflectionAmt = IERC20(reflectionToken).balanceOf(address(this));
            }

            if(reflectionAmt > 0) {
                if(reflectionToken == address(0x0)) {
                    payable(msg.sender).transfer(reflectionAmt);
                } else {
                    IERC20(reflectionToken).transfer(msg.sender, reflectionAmt);
                }
            }
        }

        totalEarned = 0;

        allocatedReflections = 0;
        accReflectionPerShare = 0;
        reflectionDebt = 0;
    }

    function recoverWrongToken(address _token) external onlyOwner {
        require(_token != address(vestingToken), "Cannot recover locked token");
        require(_token != reflectionToken, "Cannot recover reflection token");

        if(_token == address(0x0)) {
            uint256 amount = address(this).balance;
            payable(msg.sender).transfer(amount);
        } else {
            uint256 amount = IERC20(_token).balanceOf(address(this));
            IERC20(_token).safeTransfer(address(msg.sender), amount);
        }
    }

    function setDuration(uint256 _type, uint256 _duration) external onlyOwner {
        require(isActive == false, "Vesting was started");

        duration[_type] = _duration;
        emit DurationUpdated(_type, _duration);
    }

    function setRewardRate(uint256 _rate) external onlyOwner {
        require(isActive == false, "Vesting was started");

        rewardRate = _rate;
        emit RateUpdated(_rate);
    }

    function setStatus(bool _isActive) external onlyOwner {
        isActive = _isActive;
    }

    function _updatePool() internal {
        uint256 tokenAmt = availableRewardTokens();
        tokenAmt = tokenAmt.add(totalVested);
        if(tokenAmt == 0) return;

        uint256 reflectionAmt = availableDividendTokens();
        reflectionAmt = reflectionAmt.sub(allocatedReflections);

        accReflectionPerShare = accReflectionPerShare.add(reflectionAmt.mul(PRECISION_FACTOR).div(tokenAmt));
        allocatedReflections = allocatedReflections.add(reflectionAmt);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This treasury contract has been developed by brewlabs.info
 */
 
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import "../libs/IUniFactory.sol";
import "../libs/IUniRouter02.sol";
import "../libs/IWETH.sol";

interface IStaking {
    function performanceFee() external view returns(uint256);
    function setServiceInfo(address _addr, uint256 _fee) external;
}

interface IFarm {
    function setBuyBackWallet(address _addr) external;
}

contract BGLTreasury is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Whether it is initialized
    bool private isInitialized;
    uint256 private TIME_UNIT = 1 days;

    IERC20  public token;
    address public dividendToken;
    address public pair;

    uint256 public period = 30;                         // 30 days
    uint256 public withdrawalLimit = 500;               // 5% of total supply
    uint256 public liquidityWithdrawalLimit = 2000;     // 20% of LP supply
    uint256 public buybackRate = 9500;                  // 95%
    uint256 public addLiquidityRate = 9400;             // 94%

    uint256 private startTime;
    uint256 private sumWithdrawals = 0;
    uint256 private sumLiquidityWithdrawals = 0;

    uint256 public performanceFee = 100;     // 1%
    uint256 public performanceLpFee = 200;   // 2%
    address public feeWallet = 0x408c4aDa67aE1244dfeC7D609dea3c232843189A;

    // swap router and path, slipPage
    address public uniRouterAddress;
    address[] public bnbToTokenPath;
    uint256 public slippageFactor = 830;    // 17%
    uint256 public constant slippageFactorUL = 995;

    event TokenBuyBack(uint256 amountETH, uint256 amountToken);
    event LiquidityAdded(uint256 amountETH, uint256 amountToken, uint256 liquidity);
    event SetSwapConfig(address router, uint256 slipPage, address[] path);
    event TransferBuyBackWallet(address staking, address wallet);
    event LiquidityWithdrawn(uint256 amount);
    event Withdrawn(uint256 amount);

    event AddLiquidityRateUpdated(uint256 percent);
    event BuybackRateUpdated(uint256 percent);
    event PeriodUpdated(uint256 duration);
    event LiquidityWithdrawLimitUpdated(uint256 percent);
    event WithdrawLimitUpdated(uint256 percent);
    event ServiceInfoUpdated(address wallet, uint256 performanceFee, uint256 liquidityFee);

    constructor() {}
   
    /**
     * @notice Initialize the contract
     * @param _token: token address
     * @param _dividendToken: reflection token address
     * @param _uniRouter: uniswap router address for swap tokens
     * @param _bnbToTokenPath: swap path to buy Token
     */
    function initialize(
        IERC20 _token,
        address _dividendToken,
        address _uniRouter,
        address[] memory _bnbToTokenPath
    ) external onlyOwner {
        require(!isInitialized, "Already initialized");

        // Make this contract initialized
        isInitialized = true;

        token = _token;
        dividendToken = _dividendToken;
        pair = IUniV2Factory(IUniRouter02(_uniRouter).factory()).getPair(_bnbToTokenPath[0], address(token));

        uniRouterAddress = _uniRouter;
        bnbToTokenPath = _bnbToTokenPath;
    }

    /**
     * @notice Buy token from BNB
     */
    function buyBack() external onlyOwner nonReentrant {
        uint256 ethAmt = address(this).balance;
        uint256 _fee = ethAmt * performanceFee / 10000;
        if(_fee > 0) {
            payable(feeWallet).transfer(_fee);
            ethAmt = ethAmt - _fee;
        }
        ethAmt = ethAmt * buybackRate / 10000;

        if(ethAmt > 0) {
            uint256[] memory amounts = _safeSwapEth(ethAmt, bnbToTokenPath, address(this));
            emit TokenBuyBack(amounts[0], amounts[amounts.length - 1]);
        }
    }

    
    /**
     * @notice Add liquidity
     */
    function addLiquidity() external onlyOwner nonReentrant {
        uint256 ethAmt = address(this).balance;
        uint256 _fee = ethAmt * performanceLpFee / 10000;
        if(_fee > 0) {
            payable(feeWallet).transfer(_fee);
            ethAmt = ethAmt - _fee;
        }
        ethAmt = ethAmt * addLiquidityRate / 10000 / 2;

        if(ethAmt > 0) {
            uint256[] memory amounts = _safeSwapEth(ethAmt, bnbToTokenPath, address(this));
            uint256 _tokenAmt = amounts[amounts.length - 1];
            emit TokenBuyBack(amounts[0], _tokenAmt);
            
            (uint256 amountToken, uint256 amountETH, uint256 liquidity) = _addLiquidityEth(address(token), ethAmt, _tokenAmt, address(this));
            emit LiquidityAdded(amountETH, amountToken, liquidity);
        }
    }


    /**
     * @notice Withdraw token as much as maximum 5% of total supply
     * @param _amount: amount to withdraw
     */
    function withdraw(uint256 _amount) external onlyOwner {
        uint256 tokenAmt = token.balanceOf(address(this));
        require(_amount > 0 && _amount <= tokenAmt, "Invalid Amount");

        if(block.timestamp - startTime > period * TIME_UNIT) {
            startTime = block.timestamp;
            sumWithdrawals = 0;
        }

        uint256 limit = withdrawalLimit * (token.totalSupply()) / 10000;
        require(sumWithdrawals + _amount <= limit, "exceed maximum withdrawal limit for 30 days");

        token.safeTransfer(msg.sender, _amount);
        emit Withdrawn(_amount);
    }

    /**
     * @notice Withdraw token as much as maximum 20% of lp supply
     * @param _amount: liquidity amount to withdraw
     */
    function withdrawLiquidity(uint256 _amount) external onlyOwner {
        uint256 tokenAmt = IERC20(pair).balanceOf(address(this));
        require(_amount > 0 && _amount <= tokenAmt, "Invalid Amount");

        if(block.timestamp - startTime > period * TIME_UNIT) {
            startTime = block.timestamp;
            sumLiquidityWithdrawals = 0;
        }

        uint256 limit = liquidityWithdrawalLimit * (IERC20(pair).totalSupply()) / 10000;
        require(sumLiquidityWithdrawals + _amount <= limit, "exceed maximum LP withdrawal limit for 30 days");

        IERC20(pair).safeTransfer(msg.sender, _amount);
        emit LiquidityWithdrawn(_amount);
    }
    
    /**
     * @notice Withdraw tokens
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external onlyOwner {
        uint256 tokenAmt = token.balanceOf(address(this));
        if(tokenAmt > 0) {
            token.transfer(msg.sender, tokenAmt);
        }

        tokenAmt = IERC20(pair).balanceOf(address(this));
        if(tokenAmt > 0) {
            IERC20(pair).transfer(msg.sender, tokenAmt);
        }

        uint256 ethAmt = address(this).balance;
        if(ethAmt > 0) {
            payable(msg.sender).transfer(ethAmt);
        }
    }

    /**
     * @notice Harvest reflection for token
     */
    function harvest() external onlyOwner {
        if(dividendToken == address(0x0)) {
            uint256 ethAmt = address(this).balance;
            if(ethAmt > 0) {
                payable(msg.sender).transfer(ethAmt);
            }
        } else {
            uint256 tokenAmt = IERC20(dividendToken).balanceOf(address(this));
            if(tokenAmt > 0) {
                IERC20(dividendToken).transfer(msg.sender, tokenAmt);
            }
        }
    }

    /**
     * @notice Set duration for withdraw limit
     * @param _period: duration
     */
    function setWithdrawalLimitPeriod(uint256 _period) external onlyOwner {
        require(_period >= 10, "small period");
        period = _period;
        emit PeriodUpdated(_period);
    }

    /**
     * @notice Set liquidity withdraw limit
     * @param _percent: percentage of LP supply in point
     */
    function setLiquidityWithdrawalLimit(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");
        
        liquidityWithdrawalLimit = _percent;
        emit LiquidityWithdrawLimitUpdated(_percent);
    }

    /**
     * @notice Set withdraw limit
     * @param _percent: percentage of total supply in point
     */
    function setWithdrawalLimit(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");
        
        withdrawalLimit = _percent;
        emit WithdrawLimitUpdated(_percent);
    }
    
    /**
     * @notice Set buyback rate
     * @param _percent: percentage in point
     */
    function setBuybackRate(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");

        buybackRate = _percent;
        emit BuybackRateUpdated(_percent);
    }

    /**
     * @notice Set addliquidy rate
     * @param _percent: percentage in point
     */
    function setAddLiquidityRate(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");

        addLiquidityRate = _percent;
        emit AddLiquidityRateUpdated(_percent);
    }

    function setServiceInfo(address _wallet, uint256 _fee) external {
        require(msg.sender == feeWallet, "Invalid setter");
        require(_wallet != feeWallet && _wallet != address(0x0), "Invalid new wallet");
        require(_fee < 500, "invalid performance fee");
       
        feeWallet = _wallet;
        performanceFee = _fee;
        performanceLpFee = _fee * 2;

        emit ServiceInfoUpdated(_wallet, performanceFee, performanceLpFee);
    }
    
    /**
     * @notice Set buyback wallet of farm contract
     * @param _uniRouter: dex router address
     * @param _slipPage: slip page for swap
     * @param _path: bnb-token swap path
     */
    function setSwapSettings(address _uniRouter, uint256 _slipPage, address[] memory _path) external onlyOwner {
        require(_slipPage < 1000, "Invalid percentage");

        uniRouterAddress = _uniRouter;
        slippageFactor = _slipPage;
        bnbToTokenPath = _path;

        emit SetSwapConfig(_uniRouter, _slipPage, _path);
    }

    /**
     * @notice set buyback wallet of farm contract
     * @param _farm: farm contract address
     * @param _addr: buyback wallet address
     */
    function setFarmServiceInfo(address _farm, address _addr) external onlyOwner {
        require(_farm != address(0x0) && _addr != address(0x0), "Invalid Address");
        IFarm(_farm).setBuyBackWallet(_addr);

        emit TransferBuyBackWallet(_farm, _addr);
    }

    /**
     * @notice set buyback wallet of staking contract 
     * @param _staking: staking contract address
     * @param _addr: buyback wallet address
     */
    function setStakingServiceInfo(address _staking, address _addr) external onlyOwner {
        require(_staking != address(0x0) && _addr != address(0x0), "Invalid Address");
        uint256 _fee = IStaking(_staking).performanceFee();
        IStaking(_staking).setServiceInfo(_addr, _fee);

        emit TransferBuyBackWallet(_staking, _addr);
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _token: the address of the token to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _token) external onlyOwner {
        require(_token != address(token) && _token != dividendToken && _token != pair, "Cannot be token & dividend token, pair");

        if(_token == address(0x0)) {
            uint256 _tokenAmount = address(this).balance;
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            uint256 _tokenAmount = IERC20(_token).balanceOf(address(this));
            IERC20(_token).safeTransfer(msg.sender, _tokenAmount);
        }
    }


    /************************
    ** Internal Methods
    *************************/
    /*
     * @notice get token from ETH via swap.
     */
    function _safeSwapEth(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal returns (uint256[] memory amounts) {
        amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length - 1];

        IUniRouter02(uniRouterAddress).swapExactETHForTokensSupportingFeeOnTransferTokens{value: _amountIn}(
            amountOut * slippageFactor / 1000,
            _path,
            _to,
            block.timestamp + 600
        );
    }

    /*
     * @notice Add liquidity for Token-BNB pair.
     */
    function _addLiquidityEth(
        address _token,
        uint256 _ethAmt,
        uint256 _tokenAmt,
        address _to
    ) internal returns(uint256 amountToken, uint256 amountETH, uint256 liquidity) {
        IERC20(_token).safeIncreaseAllowance(uniRouterAddress, _tokenAmt);

        (amountToken, amountETH, liquidity) = IUniRouter02(uniRouterAddress).addLiquidityETH{value: _ethAmt}(
            address(_token),
            _tokenAmt,
            0,
            0,
            _to,
            block.timestamp + 600
        );

        IERC20(_token).safeApprove(uniRouterAddress, uint256(0));
    }


    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This treasury contract has been developed by brewlabs.info
 */
 
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import "../libs/IUniFactory.sol";
import "../libs/IUniRouter02.sol";
import "../libs/IWETH.sol";

interface IStaking {
    function performanceFee() external view returns(uint256);
    function setServiceInfo(address _addr, uint256 _fee) external;
}

interface IFarm {
    function setBuyBackWallet(address _addr) external;
}

contract BaltoTreasury is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Whether it is initialized
    bool private isInitialized;
    uint256 private TIME_UNIT = 1 days;

    IERC20  public token;
    address public dividendToken;
    address public pair;

    uint256 public period = 30;                         // 30 days
    uint256 public withdrawalLimit = 500;               // 5% of total supply
    uint256 public liquidityWithdrawalLimit = 2000;     // 20% of LP supply
    uint256 public buybackRate = 9500;                  // 95%
    uint256 public addLiquidityRate = 9400;             // 94%

    uint256 private startTime;
    uint256 private sumWithdrawals = 0;
    uint256 private sumLiquidityWithdrawals = 0;

    uint256 public performanceFee = 100;     // 1%
    uint256 public performanceLpFee = 200;   // 2%
    address public feeWallet = 0x408c4aDa67aE1244dfeC7D609dea3c232843189A;

    // swap router and path, slipPage
    address public uniRouterAddress;
    address[] public bnbToTokenPath;
    uint256 public slippageFactor = 830;    // 17%
    uint256 public constant slippageFactorUL = 995;

    event TokenBuyBack(uint256 amountETH, uint256 amountToken);
    event LiquidityAdded(uint256 amountETH, uint256 amountToken, uint256 liquidity);
    event SetSwapConfig(address router, uint256 slipPage, address[] path);
    event TransferBuyBackWallet(address staking, address wallet);
    event LiquidityWithdrawn(uint256 amount);
    event Withdrawn(uint256 amount);

    event AddLiquidityRateUpdated(uint256 percent);
    event BuybackRateUpdated(uint256 percent);
    event PeriodUpdated(uint256 duration);
    event LiquidityWithdrawLimitUpdated(uint256 percent);
    event WithdrawLimitUpdated(uint256 percent);
    event ServiceInfoUpdated(address wallet, uint256 performanceFee, uint256 liquidityFee);

    constructor() {}
   
    /**
     * @notice Initialize the contract
     * @param _token: token address
     * @param _dividendToken: reflection token address
     * @param _uniRouter: uniswap router address for swap tokens
     * @param _bnbToTokenPath: swap path to buy Token
     */
    function initialize(
        IERC20 _token,
        address _dividendToken,
        address _uniRouter,
        address[] memory _bnbToTokenPath
    ) external onlyOwner {
        require(!isInitialized, "Already initialized");

        // Make this contract initialized
        isInitialized = true;

        token = _token;
        dividendToken = _dividendToken;
        pair = IUniV2Factory(IUniRouter02(_uniRouter).factory()).getPair(_bnbToTokenPath[0], address(token));

        uniRouterAddress = _uniRouter;
        bnbToTokenPath = _bnbToTokenPath;
    }

    /**
     * @notice Buy token from BNB
     */
    function buyBack() external onlyOwner nonReentrant {
        uint256 ethAmt = address(this).balance;
        uint256 _fee = ethAmt * performanceFee / 10000;
        if(_fee > 0) {
            payable(feeWallet).transfer(_fee);
            ethAmt = ethAmt - _fee;
        }
        ethAmt = ethAmt * buybackRate / 10000;

        if(ethAmt > 0) {
            uint256[] memory amounts = _safeSwapEth(ethAmt, bnbToTokenPath, address(this));
            emit TokenBuyBack(amounts[0], amounts[amounts.length - 1]);
        }
    }

    
    /**
     * @notice Add liquidity
     */
    function addLiquidity() external onlyOwner nonReentrant {
        uint256 ethAmt = address(this).balance;
        uint256 _fee = ethAmt * performanceLpFee / 10000;
        if(_fee > 0) {
            payable(feeWallet).transfer(_fee);
            ethAmt = ethAmt - _fee;
        }
        ethAmt = ethAmt * addLiquidityRate / 10000 / 2;

        if(ethAmt > 0) {
            uint256[] memory amounts = _safeSwapEth(ethAmt, bnbToTokenPath, address(this));
            uint256 _tokenAmt = amounts[amounts.length - 1];
            emit TokenBuyBack(amounts[0], _tokenAmt);
            
            (uint256 amountToken, uint256 amountETH, uint256 liquidity) = _addLiquidityEth(address(token), ethAmt, _tokenAmt, address(this));
            emit LiquidityAdded(amountETH, amountToken, liquidity);
        }
    }


    /**
     * @notice Withdraw token as much as maximum 5% of total supply
     * @param _amount: amount to withdraw
     */
    function withdraw(uint256 _amount) external onlyOwner {
        uint256 tokenAmt = token.balanceOf(address(this));
        require(_amount > 0 && _amount <= tokenAmt, "Invalid Amount");

        if(block.timestamp - startTime > period * TIME_UNIT) {
            startTime = block.timestamp;
            sumWithdrawals = 0;
        }

        uint256 limit = withdrawalLimit * (token.totalSupply()) / 10000;
        require(sumWithdrawals + _amount <= limit, "exceed maximum withdrawal limit for 30 days");

        token.safeTransfer(msg.sender, _amount);
        emit Withdrawn(_amount);
    }

    /**
     * @notice Withdraw token as much as maximum 20% of lp supply
     * @param _amount: liquidity amount to withdraw
     */
    function withdrawLiquidity(uint256 _amount) external onlyOwner {
        uint256 tokenAmt = IERC20(pair).balanceOf(address(this));
        require(_amount > 0 && _amount <= tokenAmt, "Invalid Amount");

        if(block.timestamp - startTime > period * TIME_UNIT) {
            startTime = block.timestamp;
            sumLiquidityWithdrawals = 0;
        }

        uint256 limit = liquidityWithdrawalLimit * (IERC20(pair).totalSupply()) / 10000;
        require(sumLiquidityWithdrawals + _amount <= limit, "exceed maximum LP withdrawal limit for 30 days");

        IERC20(pair).safeTransfer(msg.sender, _amount);
        emit LiquidityWithdrawn(_amount);
    }
    
    /**
     * @notice Withdraw tokens
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external onlyOwner {
        uint256 tokenAmt = token.balanceOf(address(this));
        if(tokenAmt > 0) {
            token.transfer(msg.sender, tokenAmt);
        }

        tokenAmt = IERC20(pair).balanceOf(address(this));
        if(tokenAmt > 0) {
            IERC20(pair).transfer(msg.sender, tokenAmt);
        }

        uint256 ethAmt = address(this).balance;
        if(ethAmt > 0) {
            payable(msg.sender).transfer(ethAmt);
        }
    }

    /**
     * @notice Harvest reflection for token
     */
    function harvest() external onlyOwner {
        if(dividendToken == address(0x0)) {
            uint256 ethAmt = address(this).balance;
            if(ethAmt > 0) {
                payable(msg.sender).transfer(ethAmt);
            }
        } else {
            uint256 tokenAmt = IERC20(dividendToken).balanceOf(address(this));
            if(tokenAmt > 0) {
                IERC20(dividendToken).transfer(msg.sender, tokenAmt);
            }
        }
    }

    /**
     * @notice Set duration for withdraw limit
     * @param _period: duration
     */
    function setWithdrawalLimitPeriod(uint256 _period) external onlyOwner {
        require(_period >= 10, "small period");
        period = _period;
        emit PeriodUpdated(_period);
    }

    /**
     * @notice Set liquidity withdraw limit
     * @param _percent: percentage of LP supply in point
     */
    function setLiquidityWithdrawalLimit(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");
        
        liquidityWithdrawalLimit = _percent;
        emit LiquidityWithdrawLimitUpdated(_percent);
    }

    /**
     * @notice Set withdraw limit
     * @param _percent: percentage of total supply in point
     */
    function setWithdrawalLimit(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");
        
        withdrawalLimit = _percent;
        emit WithdrawLimitUpdated(_percent);
    }
    
    /**
     * @notice Set buyback rate
     * @param _percent: percentage in point
     */
    function setBuybackRate(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");

        buybackRate = _percent;
        emit BuybackRateUpdated(_percent);
    }

    /**
     * @notice Set addliquidy rate
     * @param _percent: percentage in point
     */
    function setAddLiquidityRate(uint256 _percent) external onlyOwner {
        require(_percent < 10000, "Invalid percentage");

        addLiquidityRate = _percent;
        emit AddLiquidityRateUpdated(_percent);
    }

    function setServiceInfo(address _wallet, uint256 _fee) external {
        require(msg.sender == feeWallet, "Invalid setter");
        require(_wallet != feeWallet && _wallet != address(0x0), "Invalid new wallet");
        require(_fee < 500, "invalid performance fee");
       
        feeWallet = _wallet;
        performanceFee = _fee;
        performanceLpFee = _fee * 2;

        emit ServiceInfoUpdated(_wallet, performanceFee, performanceLpFee);
    }
    
    /**
     * @notice Set buyback wallet of farm contract
     * @param _uniRouter: dex router address
     * @param _slipPage: slip page for swap
     * @param _path: bnb-token swap path
     */
    function setSwapSettings(address _uniRouter, uint256 _slipPage, address[] memory _path) external onlyOwner {
        require(_slipPage < 1000, "Invalid percentage");

        uniRouterAddress = _uniRouter;
        slippageFactor = _slipPage;
        bnbToTokenPath = _path;

        emit SetSwapConfig(_uniRouter, _slipPage, _path);
    }

    /**
     * @notice set buyback wallet of farm contract
     * @param _farm: farm contract address
     * @param _addr: buyback wallet address
     */
    function setFarmServiceInfo(address _farm, address _addr) external onlyOwner {
        require(_farm != address(0x0) && _addr != address(0x0), "Invalid Address");
        IFarm(_farm).setBuyBackWallet(_addr);

        emit TransferBuyBackWallet(_farm, _addr);
    }

    /**
     * @notice set buyback wallet of staking contract 
     * @param _staking: staking contract address
     * @param _addr: buyback wallet address
     */
    function setStakingServiceInfo(address _staking, address _addr) external onlyOwner {
        require(_staking != address(0x0) && _addr != address(0x0), "Invalid Address");
        uint256 _fee = IStaking(_staking).performanceFee();
        IStaking(_staking).setServiceInfo(_addr, _fee);

        emit TransferBuyBackWallet(_staking, _addr);
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _token: the address of the token to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _token) external onlyOwner {
        require(_token != address(token) && _token != dividendToken && _token != pair, "Cannot be token & dividend token, pair");

        if(_token == address(0x0)) {
            uint256 _tokenAmount = address(this).balance;
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            uint256 _tokenAmount = IERC20(_token).balanceOf(address(this));
            IERC20(_token).safeTransfer(msg.sender, _tokenAmount);
        }
    }


    /************************
    ** Internal Methods
    *************************/
    /*
     * @notice get token from ETH via swap.
     */
    function _safeSwapEth(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal returns (uint256[] memory amounts) {
        amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length - 1];

        IUniRouter02(uniRouterAddress).swapExactETHForTokensSupportingFeeOnTransferTokens{value: _amountIn}(
            amountOut * slippageFactor / 1000,
            _path,
            _to,
            block.timestamp + 600
        );
    }

    /*
     * @notice Add liquidity for Token-BNB pair.
     */
    function _addLiquidityEth(
        address _token,
        uint256 _ethAmt,
        uint256 _tokenAmt,
        address _to
    ) internal returns(uint256 amountToken, uint256 amountETH, uint256 liquidity) {
        IERC20(_token).safeIncreaseAllowance(uniRouterAddress, _tokenAmt);

        (amountToken, amountETH, liquidity) = IUniRouter02(uniRouterAddress).addLiquidityETH{value: _ethAmt}(
            address(_token),
            _tokenAmt,
            0,
            0,
            _to,
            block.timestamp + 600
        );

        IERC20(_token).safeApprove(uniRouterAddress, uint256(0));
    }


    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract BrewlabsTokenLocker is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool private initialized = false;

    IERC20  public token;
    address public reflectionToken;

    uint256 public defrostFee;
    uint256 public editFee;
    uint256 public performanceFee = 0.0035 ether;

    uint256 public NONCE = 0;
    uint256 public totalLocked;
    address public treasury;

    uint256 private accReflectionPerShare;
    uint256 private totalReflections;
    address private devWallet;
    uint256 private devRate;
    
    struct TokenLock {
        uint256 lockID; // lockID nonce per token
        uint256 lockDate; // the date the token was locked
        uint256 amount; // the amount of tokens still locked
        uint256 unlockTime; // the date the token can be withdrawn
        uint256 unlockRate; // 0 - not vesting, else - vesting 
        address operator;
        uint256 tokenDebt;
        uint256 reflectionDebt;
        bool isDefrost;
    }
    mapping(uint256 => TokenLock) public locks;

    event NewLock(uint256 lockID, address operator, address token, uint256 amount, uint256 unlockTime, uint256 unlockRate);
    event SplitLock(uint256 lockID, uint256 newLockID, address operator, uint256 amount, uint256 unlockTime);
    event AddLock(uint256 lockID, uint256 amount);
    event TransferLock(uint256 lockID, address operator);
    event Relock(uint256 lockID, uint256 amount, uint256 unlockTime);
    event DefrostActivated(uint256 lockID);
    event Defrosted(uint256 lockID);
    event Claimed(uint256 lockID, uint256 amount);

    event UpdateUnlockRate(uint256 rate);
    event UpdateTreasury(address addr);

    constructor() {}

    function initialize(address _token, address _reflectionToken, address _treasury, uint256 _editFee, uint256 _defrostFee, address _devWallet, uint256 _devRate, address _owner) external {
        require(initialized == false, "already initialized");
        require(owner() == address(0x0) || msg.sender == owner(), "not allowed");

        initialized = true;
            
        token = IERC20(_token);
        reflectionToken = _reflectionToken;

        treasury = _treasury;
        editFee = _editFee;
        defrostFee = _defrostFee;

        devWallet = _devWallet;
        devRate = _devRate;

        _transferOwnership(_owner);
    }

    function newLock(address _operator, uint256 _amount, uint256 _unlockTime, uint256 _unlockRate) external onlyOwner {
        require(_operator != address(0x0), "Invalid address");
        require(_unlockTime > block.timestamp, "Invalid unlock time");
        require(_amount > 0, "Invalid amount");

        _updatePool();

        uint256 beforeAmt = token.balanceOf(address(this));
        token.transferFrom(msg.sender, address(this), _amount);
        uint256 amountIn = token.balanceOf(address(this)).sub(beforeAmt);

        NONCE = NONCE.add(1);

        TokenLock storage lock = locks[NONCE];
        lock.lockID = NONCE;
        lock.lockDate = block.timestamp;
        lock.amount = amountIn;
        lock.unlockTime = _unlockTime;
        lock.unlockRate = _unlockRate;
        lock.operator = _operator;
        lock.tokenDebt = 0;
        lock.reflectionDebt = amountIn.mul(accReflectionPerShare).div(1e18);
        lock.isDefrost = false;

        totalLocked = totalLocked.add(amountIn);
        emit NewLock(lock.lockID, _operator, address(token), amountIn, _unlockTime, _unlockRate);
    }

    function addLock(uint256 _lockID, uint256 _amount) external payable nonReentrant {
        require(_amount > 0, "Invalid amount");
        
        TokenLock storage lock = locks[_lockID];
        require(lock.operator == msg.sender, "not operator");
        require(lock.unlockTime > block.timestamp, "already unlocked");
        require(lock.amount > lock.tokenDebt, "not enough locked amount");

        _updatePool();
        _transferFee(editFee);

        uint256 beforeAmt = token.balanceOf(address(this));
        token.transferFrom(msg.sender, address(this), _amount);
        uint256 amountIn = token.balanceOf(address(this)).sub(beforeAmt);

        lock.amount = lock.amount.add(amountIn);
        lock.reflectionDebt = lock.reflectionDebt.add(amountIn.mul(accReflectionPerShare).div(1e18));
        
        totalLocked = totalLocked.add(amountIn);
        emit AddLock(_lockID, amountIn);
    }

    function splitLock(uint256 _lockID, address _operator, uint256 _amount, uint256 _unlockTime) external payable {
        require(_operator != address(0x0), "Invalid address");
        require(_amount > 0, "Invalid amount");

        TokenLock storage lock = locks[_lockID];
        require(lock.operator == msg.sender, "not operator");
        require(lock.amount > lock.tokenDebt, "not enough locked amount");
        require(lock.unlockTime > block.timestamp, "already unlocked");
        require(lock.amount.sub(lock.tokenDebt) > _amount, "amount exceed original locked amount");
        require(_unlockTime >= lock.unlockTime, "unlock time should be longer than original");

        _updatePool();
        _transferFee(editFee);

        uint256 pending = lock.amount.sub(lock.tokenDebt).mul(accReflectionPerShare).div(1e18).sub(lock.reflectionDebt);
        if(pending > 0) {
            if(reflectionToken == address(0x0)) {
                payable(lock.operator).transfer(pending);
            } else {
                IERC20(reflectionToken).safeTransfer(lock.operator, pending);
            }
            totalReflections = totalReflections.sub(pending);
        }

        lock.amount = lock.amount.sub(lock.tokenDebt).sub(_amount);
        lock.tokenDebt = 0;
        lock.reflectionDebt = lock.amount.mul(accReflectionPerShare).div(1e18);

        NONCE = NONCE.add(1);

        lock = locks[NONCE];
        lock.lockID = NONCE;
        lock.lockDate = block.timestamp;
        lock.amount = _amount;
        lock.tokenDebt = 0;
        lock.reflectionDebt = _amount.mul(accReflectionPerShare).div(1e18);
        lock.unlockTime = _unlockTime;
        lock.operator = _operator;
        lock.isDefrost = false;

        emit SplitLock(_lockID, lock.lockID, _operator, _amount, _unlockTime);
    }

    function reLock(uint256 _lockID, uint256 _unlockTime) external payable nonReentrant {
        require(_unlockTime > block.timestamp, "Invalid unlock time");
        require(_unlockTime > locks[_lockID].unlockTime, "Relock time should be longer than original");

        TokenLock storage lock = locks[_lockID];
        require(lock.operator == msg.sender, "not operator");
        require(lock.amount > lock.tokenDebt, "not enough locked amount");

        _updatePool();
        _transferFee(editFee);

        uint256 pending = lock.amount.sub(lock.tokenDebt).mul(accReflectionPerShare).div(1e18).sub(lock.reflectionDebt);
        if(pending > 0) {
            if(reflectionToken == address(0x0)) {
                payable(lock.operator).transfer(pending);
            } else {
                IERC20(reflectionToken).safeTransfer(lock.operator, pending);
            }
            totalReflections = totalReflections.sub(pending);
        }

        lock.lockDate = block.timestamp;
        lock.unlockTime = _unlockTime;
        lock.amount = lock.amount.sub(lock.tokenDebt);
        lock.tokenDebt = 0;
        lock.reflectionDebt = lock.amount.mul(accReflectionPerShare).div(1e18);

        emit Relock(_lockID, lock.amount, lock.unlockTime);
    }

    function transferLock(uint256 _lockID, address _operator) external payable {
        TokenLock storage lock = locks[_lockID];
        require(lock.operator == msg.sender, "not operator");
        require(lock.amount > lock.tokenDebt, "not enough locked amount");
        require(lock.unlockTime > block.timestamp, "already unlocked");

        require(_operator != address(0x0) && _operator != lock.operator, "invalid new operator");

        _transferFee(editFee);

        lock.operator = _operator;
        emit TransferLock(_lockID, _operator);
    }

    function claim(uint256 _lockID) external nonReentrant {
        TokenLock storage lock = locks[_lockID];
        require(lock.operator == msg.sender, "not operator");
        require(lock.amount > lock.tokenDebt, "not enough locked amount");
        require(lock.unlockTime < block.timestamp, "being locked yet");

        _updatePool();

        uint256 pending = lock.amount.sub(lock.tokenDebt).mul(accReflectionPerShare).div(1e18).sub(lock.reflectionDebt);
        if(pending > 0) {
            if(reflectionToken == address(0x0)) {
                payable(lock.operator).transfer(pending);
            } else {
                IERC20(reflectionToken).safeTransfer(lock.operator, pending);
            }
            totalReflections = totalReflections.sub(pending);
        }

        uint256 claimAmt = pendingClaims(_lockID);
        if(claimAmt > 0) {
            token.safeTransfer(lock.operator, claimAmt);

            lock.tokenDebt = lock.tokenDebt.add(claimAmt);
            lock.reflectionDebt = lock.amount.sub(lock.tokenDebt).mul(accReflectionPerShare).div(1e18);

            totalLocked = totalLocked.sub(claimAmt);
            emit Claimed(_lockID, claimAmt);
        }
    }

    function harvest(uint256 _lockID) external payable nonReentrant {
        TokenLock storage lock = locks[_lockID];
        require(lock.operator == msg.sender, "not operator");

        _transferPerformanceFee();
        _updatePool();

        uint256 pending = lock.amount.sub(lock.tokenDebt).mul(accReflectionPerShare).div(1e18).sub(lock.reflectionDebt);
        if(pending > 0) {
            if(reflectionToken == address(0x0)) {
                payable(lock.operator).transfer(pending);
            } else {
                IERC20(reflectionToken).safeTransfer(lock.operator, pending);
            }
            totalReflections = totalReflections.sub(pending);
        }

        lock.reflectionDebt = lock.amount.sub(lock.tokenDebt).mul(accReflectionPerShare).div(1e18);
    }

    function allowDefrost(uint256 _lockID) external payable nonReentrant {
        TokenLock storage lock = locks[_lockID];
        require(lock.operator == msg.sender, "not operator");
        require(lock.amount > lock.tokenDebt, "not enough locked amount");
        require(lock.unlockTime > block.timestamp, "already unlocked");
        
        _transferFee(defrostFee);
        lock.isDefrost = true;

        emit DefrostActivated(_lockID);
    }

    function pendingReflections(uint256 _lockID) external view returns (uint256 pending) {
        TokenLock storage lock = locks[_lockID];
        if(lock.amount <= lock.tokenDebt) return 0;

        uint256 reflectionAmt = availableDividendTokens();
        uint256 _accReflectionPerShare = accReflectionPerShare.add(
                reflectionAmt.sub(totalReflections).mul(1e18).div(totalLocked)
            );

        pending = lock.amount.sub(lock.tokenDebt).mul(_accReflectionPerShare).div(1e18).sub(lock.reflectionDebt);
    }

    function pendingClaims(uint256 _lockID) public view returns (uint256) {
        TokenLock storage lock = locks[_lockID];
        if(lock.unlockTime > block.timestamp) return 0;
        if(lock.amount <= lock.tokenDebt) return 0;
        if(lock.unlockRate == 0) return lock.amount.sub(lock.tokenDebt);

        uint256 multiplier = block.timestamp.sub(lock.unlockTime);
        uint256 amount = lock.unlockRate.mul(multiplier);
        if(amount > lock.amount) amount = lock.amount;

        return amount.sub(lock.tokenDebt);
    }

    function availableDividendTokens() public view returns (uint256) {
        if(address(reflectionToken) == address(0x0)) {
            return address(this).balance;
        }

        uint256 _amount = IERC20(reflectionToken).balanceOf(address(this));        
        if(reflectionToken == address(token)) {
            if(_amount < totalLocked) return 0;
            _amount = _amount.sub(totalLocked);
        }

        return _amount;
    }

    function defrost(uint256 _lockID) external nonReentrant {
        TokenLock storage lock = locks[_lockID];
        require(msg.sender == owner() || msg.sender == lock.operator, "forbidden: only owner or operator");
        require(lock.isDefrost == true, "defrost is not activated");
        require(lock.amount > lock.tokenDebt, "not enough locked amount");
        require(lock.unlockTime > block.timestamp, "already unlocked");

        _updatePool();

        uint256 pending = lock.amount.sub(lock.tokenDebt).mul(accReflectionPerShare).div(1e18).sub(lock.reflectionDebt);
        if(pending > 0) {
            if(reflectionToken == address(0x0)) {
                payable(treasury).transfer(pending);
            } else {
                IERC20(reflectionToken).safeTransfer(treasury, pending);
            }
            totalReflections = totalReflections.sub(pending);
        }

        uint256 claimAmt = lock.amount.sub(lock.tokenDebt);
        token.transfer(lock.operator, claimAmt);

        lock.tokenDebt = lock.amount;
        lock.reflectionDebt = 0;
        totalLocked = totalLocked.sub(claimAmt);

        emit Defrosted(_lockID);
    }

    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0x0), "invalid treasury");
        
        treasury = _treasury;
        emit UpdateTreasury(_treasury);
    }


    function _updatePool() internal {
        if(totalLocked > 0) {
            uint256 reflectionAmt = availableDividendTokens();

            accReflectionPerShare = accReflectionPerShare.add(
                    reflectionAmt.sub(totalReflections).mul(1e18).div(totalLocked)
                );

            totalReflections = reflectionAmt;
        }
    }

    function _transferPerformanceFee() internal {
        require(msg.value >= performanceFee, "should pay small gas to compound or harvest");

        payable(treasury).transfer(performanceFee);
        if(msg.value > performanceFee) {
            payable(msg.sender).transfer(msg.value.sub(performanceFee));
        }
    }

    function _transferFee(uint256 fee) internal {
        require(msg.value >= fee, "not enough processing fee");
        if(msg.value > fee) {
            payable(msg.sender).transfer(msg.value.sub(fee));
        }

        uint256 _devFee = fee.mul(devRate).div(10000);
        if(_devFee > 0) {
            payable(devWallet).transfer(_devFee);
        }

        payable(treasury).transfer(fee.sub(_devFee));
    }

    receive() external payable {}
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract BrewlabsTokenConstructor is Ownable {
    address public feeAddress = 0x408c4aDa67aE1244dfeC7D609dea3c232843189A;
    uint256 public feeAmount = 0.0035 ether;

    constructor() {}

    function _balanceOf(address _token) public view returns (uint256) {
        IERC20 token = IERC20(_token);
        return token.balanceOf(address(this));
    }

    function setFeeAddress(address payable _feeAddress) public onlyOwner {
        feeAddress = _feeAddress;
    }

    function setFeeAmount(uint256 _feeAmount) public onlyOwner {
        feeAmount = _feeAmount;
    }

    function constructorTransfer(
        address _token,
        uint256 _amount,
        address _to
    ) external payable {
        require(msg.value >= feeAmount, 'Constructor: fee is not enough');
        payable(feeAddress).transfer(feeAmount);
        IERC20 token = IERC20(_token);
        token.transferFrom(msg.sender, address(this), _amount);
        token.transfer(_to, this._balanceOf(_token));
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _token: the address of the token to withdraw
     * @dev This function is only callable by admin.
     */
    function rescueToken(address _token) external onlyOwner {
        if(_token == address(0x0)) {
            uint256 _tokenAmount = address(this).balance;
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            uint256 _tokenAmount = IERC20(_token).balanceOf(address(this));
            IERC20(_token).transfer(msg.sender, _tokenAmount);
        }
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./libs/IUniRouter02.sol";
import "./libs/IWETH.sol";
interface IToken {
     /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    function claim() external;
}

contract BrewlabsStakingMulti is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // The address of the smart chef factory
    address public POOL_FACTORY;

    // Whether it is initialized
    bool public isInitialized;
    uint256 public duration = 60; // 60 days

    // Whether a limit is set for users
    bool public hasUserLimit;
    // The pool limit (0 if none)
    uint256 public poolLimitPerUser;


    // The block number when staking starts.
    uint256 public startBlock;
    // The block number when staking ends.
    uint256 public bonusEndBlock;
    // tokens created per block.
    uint256 public rewardPerBlock;
    // The block number of the last pool update
    uint256 public lastRewardBlock;


    // swap router and path, slipPage
    uint256 public slippageFactor = 800; // 20% default slippage tolerance
    uint256 public constant slippageFactorUL = 995;

    address public uniRouterAddress;
    address[] public earnedToStakedPath;


    // The deposit & withdraw fee
    uint256 public constant MAX_FEE = 2000;
    uint256 public depositFee;
    uint256 public withdrawFee;

    address public walletA;
    address public buyBackWallet = 0x408c4aDa67aE1244dfeC7D609dea3c232843189A;
    uint256 public performanceFee = 0.0035 ether;

    // The precision factor
    uint256 public PRECISION_FACTOR;
    uint256[] public PRECISION_FACTOR_REFLECTION;

    // The staked token
    IERC20 public stakingToken;
    // The earned token
    IERC20 public earnedToken;
    // The dividend token of staking token
    address[] public dividendTokens;

    // Accrued token per share
    uint256 public accTokenPerShare;
    uint256[] public accDividendPerShare;

    uint256 public totalStaked;

    uint256 private totalEarned;
    uint256[] private totalReflections;
    uint256[] private reflections;

    uint256 private paidRewards;
    uint256 private shouldTotalPaid;

    // Info of each user that stakes tokens (stakingToken)
    mapping(address => UserInfo) public userInfo;

    struct UserInfo {
        uint256 amount; // How many staked tokens the user has provided
        uint256 rewardDebt; // Reward debt
        uint256[] reflectionDebt; // Reflection debt
    }

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event AdminTokenRecovered(address tokenRecovered, uint256 amount);

    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);
    event NewRewardPerBlock(uint256 rewardPerBlock);
    event RewardsStop(uint256 blockNumber);
    event EndBlockUpdated(uint256 blockNumber);
    event UpdatePoolLimit(uint256 poolLimitPerUser, bool hasLimit);

    event ServiceInfoUpadted(address _addr, uint256 _fee);
    event WalletAUpdated(address _addr);
    event DurationUpdated(uint256 _duration);

    event SetSettings(
        uint256 _depositFee,
        uint256 _withdrawFee,
        uint256 _slippageFactor,
        address _uniRouter,
        address[] _path0
    );

    constructor() {
        POOL_FACTORY = msg.sender;
    }

    /*
     * @notice Initialize the contract
     * @param _stakingToken: staked token address
     * @param _earnedToken: earned token address
     * @param _dividendTokens: reflection token list
     * @param _rewardPerBlock: reward per block (in earnedToken)
     * @param _depositFee: deposit fee
     * @param _withdrawFee: withdraw fee
     * @param _uniRouter: uniswap router address for swap tokens
     * @param _earnedToStakedPath: swap path to compound (earned -> staking path)
     */
    function initialize(
        IERC20 _stakingToken,
        IERC20 _earnedToken,
        address[] memory _dividendTokens,
        uint256 _rewardPerBlock,
        uint256 _depositFee,
        uint256 _withdrawFee,
        address _uniRouter,
        address[] memory _earnedToStakedPath
    ) external {
        require(!isInitialized, "Already initialized");
        require(msg.sender == POOL_FACTORY, "Not factory");

        // Make this contract initialized
        isInitialized = true;

        stakingToken = _stakingToken;
        earnedToken = _earnedToken;

        uint256 decimalsRewardToken = uint256(IToken(address(earnedToken)).decimals());
        require(decimalsRewardToken < 30, "Must be inferior to 30");
        PRECISION_FACTOR = uint256(10**(40 - decimalsRewardToken));

        for(uint i = 0; i < _dividendTokens.length; i++) {
            dividendTokens.push(_dividendTokens[i]);
            totalReflections.push(0);
            accDividendPerShare.push(0);
            reflections.push(0);

            uint256 decimalsdividendToken = 18;
            if(address(dividendTokens[i]) != address(0x0)) {
                decimalsdividendToken = uint256(IToken(address(dividendTokens[i])).decimals());
                require(decimalsdividendToken < 30, "Must be inferior to 30");
            }
            PRECISION_FACTOR_REFLECTION.push(uint256(10**(40 - decimalsdividendToken)));
        }

        rewardPerBlock = _rewardPerBlock;

        require(_depositFee < MAX_FEE, "Invalid deposit fee");
        require(_withdrawFee < MAX_FEE, "Invalid withdraw fee");

        depositFee = _depositFee;
        withdrawFee = _withdrawFee;
        
        walletA = msg.sender;

        uniRouterAddress = _uniRouter;
        earnedToStakedPath = _earnedToStakedPath;
    }

    /*
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @param _amount: amount to withdraw (in earnedToken)
     */
    function deposit(uint256 _amount) external payable nonReentrant {
        require(startBlock > 0 && startBlock < block.number, "Staking hasn't started yet");
        require(_amount > 0, "Amount should be greator than 0");

        UserInfo storage user = userInfo[msg.sender];

        if (hasUserLimit) {
            require(
                _amount + user.amount <= poolLimitPerUser,
                "User amount above limit"
            );
        }

        _transferPerformanceFee();
        _updatePool();

        if (user.amount > 0) {
            uint256 pending = user.amount * accTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
            if (pending > 0) {
                require(availableRewardTokens() >= pending, "Insufficient reward tokens");
                earnedToken.safeTransfer(address(msg.sender), pending);
                
                if(totalEarned > pending) {
                    totalEarned = totalEarned - pending;
                } else {
                    totalEarned = 0;
                }
                paidRewards = paidRewards + pending;
            }

            for(uint256 i = 0; i < dividendTokens.length; i++) {
                uint256 pendingReflection = user.amount * accDividendPerShare[i] / PRECISION_FACTOR_REFLECTION[i] - user.reflectionDebt[i];
                pendingReflection = estimateDividendAmount(i, pendingReflection);
                if (pendingReflection > 0) {
                    if(address(dividendTokens[i]) == address(0x0)) {
                        payable(msg.sender).transfer(pendingReflection);
                    } else {
                        IERC20(dividendTokens[i]).safeTransfer(address(msg.sender), pendingReflection);
                    }
                    totalReflections[i] = totalReflections[i] - pendingReflection;
                }
            }
        }

        uint256 beforeAmount = stakingToken.balanceOf(address(this));
        stakingToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        uint256 afterAmount = stakingToken.balanceOf(address(this));
        
        uint256 realAmount = afterAmount - beforeAmount;
        if (depositFee > 0) {
            uint256 fee = realAmount * depositFee / 10000;
            if (fee > 0) {
                stakingToken.safeTransfer(walletA, fee);
                realAmount = realAmount - fee;
            }
        }
        
        user.amount = user.amount + realAmount;
        totalStaked = totalStaked + realAmount;        

        user.rewardDebt = user.amount * accTokenPerShare / PRECISION_FACTOR;
        if(user.reflectionDebt.length == 0) {
            for(uint i = 0; i < dividendTokens.length; i++) {
                user.reflectionDebt.push(0);
            }
        }
        for(uint i = 0; i < dividendTokens.length; i++) {
            user.reflectionDebt[i] = user.amount * accDividendPerShare[i] / PRECISION_FACTOR_REFLECTION[i];
        }

        emit Deposit(msg.sender, realAmount);
    }

    /*
     * @notice Withdraw staked tokens and collect reward tokens
     * @param _amount: amount to withdraw (in earnedToken)
     */
    function withdraw(uint256 _amount) external payable nonReentrant {
        require(_amount > 0, "Amount should be greator than 0");

        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "Amount to withdraw too high");

        _transferPerformanceFee();
        _updatePool();

        if(user.amount > 0) {
            uint256 pending = user.amount * accTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
            if (pending > 0) {
                require(availableRewardTokens() >= pending, "Insufficient reward tokens");
                earnedToken.safeTransfer(address(msg.sender), pending);
                
                if(totalEarned > pending) {
                    totalEarned = totalEarned - pending;
                } else {
                    totalEarned = 0;
                }
                paidRewards = paidRewards + pending;
            }

            for(uint i = 0; i < dividendTokens.length; i++) {
                uint256 pendingReflection =  user.amount * accDividendPerShare[i] / PRECISION_FACTOR_REFLECTION[i] - user.reflectionDebt[i];
                pendingReflection = estimateDividendAmount(i, pendingReflection);
                if (pendingReflection > 0) {
                    if(address(dividendTokens[i]) == address(0x0)) {
                        payable(msg.sender).transfer(pendingReflection);
                    } else {
                        IERC20(dividendTokens[i]).safeTransfer(address(msg.sender), pendingReflection);
                    }
                    totalReflections[i] = totalReflections[i] - pendingReflection;
                }
            }
        }


        uint256 realAmount = _amount;
        if (user.amount < _amount) {
            realAmount = user.amount;
        }

        user.amount = user.amount - realAmount;
        totalStaked = totalStaked - realAmount;

        if (withdrawFee > 0) {
            uint256 fee = realAmount * withdrawFee / 10000;
            if (fee > 0) {
                stakingToken.safeTransfer(walletA, fee);
                realAmount = realAmount - fee;
            }
        }

        stakingToken.safeTransfer(address(msg.sender), realAmount);

        user.rewardDebt = user.amount * accTokenPerShare / PRECISION_FACTOR;
        for(uint i = 0; i < dividendTokens.length; i++) {
            user.reflectionDebt[i] = user.amount * accDividendPerShare[i] / PRECISION_FACTOR_REFLECTION[i];
        }

        emit Withdraw(msg.sender, _amount);
    }

    function claimReward() external payable nonReentrant {
        UserInfo storage user = userInfo[msg.sender];

        _transferPerformanceFee();
        _updatePool();

        if (user.amount == 0) return;

        uint256 pending = user.amount * accTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            earnedToken.safeTransfer(address(msg.sender), pending);
            
            if(totalEarned > pending) {
                totalEarned = totalEarned - pending;
            } else {
                totalEarned = 0;
            }
            paidRewards = paidRewards + pending;
        }
        
        user.rewardDebt = user.amount * accTokenPerShare / PRECISION_FACTOR;
    }

    function claimDividend() external payable nonReentrant {
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool();

        UserInfo storage user = userInfo[msg.sender];
        if (user.amount == 0) return;

        for(uint i = 0; i < dividendTokens.length; i++) {
            uint256 pendingReflection = user.amount * accDividendPerShare[i] / PRECISION_FACTOR_REFLECTION[i] - user.reflectionDebt[i];
            pendingReflection = estimateDividendAmount(i, pendingReflection);
            if (pendingReflection > 0) {
                if(address(dividendTokens[i]) == address(0x0)) {
                    payable(msg.sender).transfer(pendingReflection);
                } else {
                    IERC20(dividendTokens[i]).safeTransfer(address(msg.sender), pendingReflection);
                }
                totalReflections[i] = totalReflections[i] - pendingReflection;
            }
            
            user.reflectionDebt[i] = user.amount * accDividendPerShare[i] / PRECISION_FACTOR_REFLECTION[i];
        }
    }

    function compoundReward() external payable nonReentrant {
        UserInfo storage user = userInfo[msg.sender];

        _transferPerformanceFee();
        _updatePool();

        if (user.amount == 0) return;

        uint256 pending = user.amount * accTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            if(totalEarned > pending) {
                totalEarned = totalEarned - pending;
            } else {
                totalEarned = 0;
            }
            paidRewards = paidRewards + pending;
            
            if(address(stakingToken) != address(earnedToken)) {
                uint256 beforeAmount = stakingToken.balanceOf(address(this));
                _safeSwap(pending, earnedToStakedPath, address(this));
                uint256 afterAmount = stakingToken.balanceOf(address(this));
                pending = afterAmount - beforeAmount;
            }

            if (hasUserLimit) {
                require(
                    pending + user.amount <= poolLimitPerUser,
                    "User amount above limit"
                );
            }

            totalStaked = totalStaked + pending;
            user.amount = user.amount + pending;
            for(uint i = 0; i < dividendTokens.length; i++) {
                user.reflectionDebt[i] = user.reflectionDebt[i] + pending * accDividendPerShare[i] / PRECISION_FACTOR_REFLECTION[i];
            }

            emit Deposit(msg.sender, pending);
        }
        
        user.rewardDebt = user.amount * accTokenPerShare / PRECISION_FACTOR;
    }

    function compoundDividend() external nonReentrant {
    }

    function _transferPerformanceFee() internal {
        require(msg.value >= performanceFee, 'should pay small gas to compound or harvest');

        payable(buyBackWallet).transfer(performanceFee);
        if(msg.value > performanceFee) {
            payable(msg.sender).transfer(msg.value - performanceFee);
        }
    }
    /*
     * @notice Withdraw staked tokens without caring about rewards
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        uint256 amountToTransfer = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        for(uint i = 0; i < dividendTokens.length; i++) {
            user.reflectionDebt[i] = 0;
        }

        if (amountToTransfer > 0) {
            stakingToken.safeTransfer(address(msg.sender), amountToTransfer);
            totalStaked = totalStaked - amountToTransfer;
        }

        emit EmergencyWithdraw(msg.sender, user.amount);
    }

    /**
     * @notice Available amount of reward token
     */
    function availableRewardTokens() public view returns (uint256) {
        uint256 _amount = earnedToken.balanceOf(address(this));
        if (address(earnedToken) == address(stakingToken)) {
            if (_amount < totalStaked) return 0;
            return _amount - totalStaked;
        }

        return _amount;
    }

    /**
     * @notice Available amount of reflection token
     */
    function availableDividendTokens(uint index) public view returns (uint256) {
        if(address(dividendTokens[index]) == address(0x0)) {
            return address(this).balance;
        }

        uint256 _amount = IERC20(dividendTokens[index]).balanceOf(address(this));
        
        if(address(dividendTokens[index]) == address(earnedToken)) {
            if(_amount < totalEarned) return 0;
            _amount = _amount - totalEarned;
        }

        if(address(dividendTokens[index]) == address(stakingToken)) {
            if(_amount < totalStaked) return 0;
            _amount = _amount - totalStaked;
        }

        return _amount;
    }

    function insufficientRewards() external view returns (uint256) {
        uint256 adjustedShouldTotalPaid = shouldTotalPaid;
        uint256 remainRewards = availableRewardTokens() + paidRewards;

        if(startBlock == 0) {
            adjustedShouldTotalPaid = adjustedShouldTotalPaid + rewardPerBlock * duration * 28800;
        } else {
            uint256 remainBlocks = _getMultiplier(lastRewardBlock, bonusEndBlock);
            adjustedShouldTotalPaid = adjustedShouldTotalPaid + rewardPerBlock * remainBlocks;
        }

        if(remainRewards >= adjustedShouldTotalPaid) return 0;

        return adjustedShouldTotalPaid - remainRewards;
    }

    /*
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @return Pending reward for a given user
     */
    function pendingReward(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];

        uint256 adjustedTokenPerShare = accTokenPerShare;
        if (block.number > lastRewardBlock && totalStaked != 0 && lastRewardBlock > 0) {
            uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
            uint256 rewards = multiplier * rewardPerBlock;
            
            adjustedTokenPerShare = accTokenPerShare + (
                    rewards * PRECISION_FACTOR / totalStaked
                );
        }
        return user.amount * adjustedTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
    }

    function pendingDividends(address _user) external view returns (uint256[] memory data) {
        data = new uint256[](dividendTokens.length);
        if(totalStaked == 0) return data;
        
        UserInfo storage user = userInfo[_user];
        if(user.amount == 0) return data;

        for(uint i = 0; i < dividendTokens.length; i++) {
            uint256 reflectionAmount = availableDividendTokens(i);
            if(reflectionAmount < totalReflections[i]) {
                reflectionAmount = totalReflections[i];
            }

            uint256 sTokenBal = totalStaked;
            uint256 eTokenBal = availableRewardTokens();
            if(address(stakingToken) == address(earnedToken)) {
                sTokenBal = sTokenBal + eTokenBal;
            }

            uint256 adjustedReflectionPerShare = accDividendPerShare[i] + (
                    (reflectionAmount - totalReflections[i]) * PRECISION_FACTOR_REFLECTION[i] / sTokenBal
                );
            
            uint256 pendingReflection = user.amount * adjustedReflectionPerShare / PRECISION_FACTOR_REFLECTION[i] - user.reflectionDebt[i];            
            data[i] = pendingReflection;
        }

        return data;
    }

    /************************
    ** Admin Methods
    *************************/
    function harvest() external onlyOwner {        
        _updatePool();

        for(uint i = 0; i < dividendTokens.length; i++) {
            reflections[i] = estimateDividendAmount(i, reflections[i]);
            if(reflections[i] > 0) {
                if(address(dividendTokens[i]) == address(0x0)) {
                    payable(walletA).transfer(reflections[i]);
                } else {
                    IERC20(dividendTokens[i]).safeTransfer(walletA, reflections[i]);
                }

                totalReflections[i] = totalReflections[i] - reflections[i];
                reflections[i] = 0;
            }
        }
    }

    /*
     * @notice Deposit reward token
     * @dev Only call by owner. Needs to be for deposit of reward token when reflection token is same with reward token.
     */
    function depositRewards(uint _amount) external onlyOwner nonReentrant {
        require(_amount > 0, "invalid amount");

        uint256 beforeAmt = earnedToken.balanceOf(address(this));
        earnedToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = earnedToken.balanceOf(address(this));

        totalEarned = totalEarned + afterAmt - beforeAmt;
    }

    function increaseEmissionRate(uint256 _amount) external onlyOwner {
        require(startBlock > 0, "pool is not started");
        require(bonusEndBlock > block.number, "pool was already finished");
        require(_amount > 0, "invalid amount");
        
        _updatePool();

        uint256 beforeAmt = earnedToken.balanceOf(address(this));
        earnedToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = earnedToken.balanceOf(address(this));

        totalEarned = totalEarned + afterAmt - beforeAmt;

        uint256 remainRewards = availableRewardTokens() + paidRewards;
        if(remainRewards > shouldTotalPaid) {
            remainRewards = remainRewards - shouldTotalPaid;

            uint256 remainBlocks = bonusEndBlock - block.number;
            rewardPerBlock = remainRewards / remainBlocks;
            emit NewRewardPerBlock(rewardPerBlock);
        }
    }

    /*
     * @notice Withdraw reward token
     * @dev Only callable by owner. Needs to be for emergency.
     */
    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
        require( block.number > bonusEndBlock, "Pool is running");
        require(availableRewardTokens() >= _amount, "Insufficient reward tokens");

        earnedToken.safeTransfer(address(msg.sender), _amount);
        
        if (totalEarned > 0) {
            if (_amount > totalEarned) {
                totalEarned = 0;
            } else {
                totalEarned = totalEarned - _amount;
            }
        }
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of tokens to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount)
        external
        onlyOwner
    {
        require(
            _tokenAddress != address(earnedToken),
            "Cannot be reward token"
        );

        if(_tokenAddress == address(stakingToken)) {
            uint256 tokenBal = stakingToken.balanceOf(address(this));
            require(_tokenAmount <= tokenBal - totalStaked, "Insufficient balance");
        }

        if(_tokenAddress == address(0x0)) {
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
        }

        emit AdminTokenRecovered(_tokenAddress, _tokenAmount);
    }

    function startReward() external onlyOwner {
        require(startBlock == 0, "Pool was already started");

        startBlock = block.number + 100;
        bonusEndBlock = startBlock + duration * 28800;
        lastRewardBlock = startBlock;
        
        emit NewStartAndEndBlocks(startBlock, bonusEndBlock);
    }

    function stopReward() external onlyOwner {
        _updatePool();

        uint256 remainRewards = availableRewardTokens() + paidRewards;
        if(remainRewards > shouldTotalPaid) {
            remainRewards = remainRewards - shouldTotalPaid;
            earnedToken.transfer(msg.sender, remainRewards);

            if(totalEarned > remainRewards) {
                totalEarned = totalEarned - remainRewards;
            } else {
                totalEarned = 0;
            }
        }

        bonusEndBlock = block.number;
        emit RewardsStop(bonusEndBlock);
    }

    function updateEndBlock(uint256 _endBlock) external onlyOwner {
        require(startBlock > 0, "Pool is not started");
        require(bonusEndBlock > block.number, "Pool was already finished");
        require(_endBlock > block.number && _endBlock > startBlock, "Invalid end block");
        bonusEndBlock = _endBlock;
        emit EndBlockUpdated(_endBlock);
    }

    /*
     * @notice Update pool limit per user
     * @dev Only callable by owner.
     * @param _hasUserLimit: whether the limit remains forced
     * @param _poolLimitPerUser: new pool limit per user
     */
    function updatePoolLimitPerUser( bool _hasUserLimit, uint256 _poolLimitPerUser) external onlyOwner {
        if (_hasUserLimit) {
            require(
                _poolLimitPerUser > poolLimitPerUser,
                "New limit must be higher"
            );
            poolLimitPerUser = _poolLimitPerUser;
        } else {
            poolLimitPerUser = 0;
        }
        hasUserLimit = _hasUserLimit;

        emit UpdatePoolLimit(poolLimitPerUser, hasUserLimit);
    }

    /*
     * @notice Update reward per block
     * @dev Only callable by owner.
     * @param _rewardPerBlock: the reward per block
     */
    function updateRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner {
        // require(block.number < startBlock, "Pool was already started");

        rewardPerBlock = _rewardPerBlock;
        emit NewRewardPerBlock(_rewardPerBlock);
    }

    function setServiceInfo(address _buyBackWallet, uint256 _fee) external {
        require(msg.sender == buyBackWallet, "setServiceInfo: FORBIDDEN");
        require(_buyBackWallet != address(0x0), "Invalid address");

        buyBackWallet = _buyBackWallet;
        performanceFee = _fee;

        emit ServiceInfoUpadted(_buyBackWallet, _fee);
    }

    function updateWalletA(address _walletA) external onlyOwner {
        require(_walletA != address(0x0) || _walletA != walletA, "Invalid address");

        walletA = _walletA;
        emit WalletAUpdated(_walletA);
    }

    function setDuration(uint256 _duration) external onlyOwner {
        require(startBlock == 0, "Pool was already started");
        require(_duration >= 30, "lower limit reached");

        duration = _duration;
        emit DurationUpdated(_duration);
    }

    function setSettings(
        uint256 _depositFee,
        uint256 _withdrawFee,
        uint256 _slippageFactor,
        address _uniRouter,
        address[] memory _earnedToStakedPath
    ) external onlyOwner {
        require(_depositFee < MAX_FEE, "Invalid deposit fee");
        require(_withdrawFee < MAX_FEE, "Invalid withdraw fee");
        require(_slippageFactor <= slippageFactorUL, "_slippageFactor too high");

        depositFee = _depositFee;
        withdrawFee = _withdrawFee;

        slippageFactor = _slippageFactor;
        uniRouterAddress = _uniRouter;
        earnedToStakedPath = _earnedToStakedPath;

        emit SetSettings(_depositFee, _withdrawFee, _slippageFactor, _uniRouter, _earnedToStakedPath);
    }


    /************************
    ** Internal Methods
    *************************/
    /*
     * @notice Update reward variables of the given pool to be up-to-date.
     */
    function _updatePool() internal {
        // calc reflection rate
        if(totalStaked > 0) {
            uint256 sTokenBal = totalStaked;
            uint256 eTokenBal = availableRewardTokens();
            if(address(stakingToken) == address(earnedToken)) {
                sTokenBal = sTokenBal + eTokenBal;
            }

            for(uint i  = 0; i < dividendTokens.length; i++) {
                uint256 reflectionAmount = availableDividendTokens(i);
                if(reflectionAmount < totalReflections[i]) {
                    reflectionAmount = totalReflections[i];
                }

                accDividendPerShare[i] = accDividendPerShare[i] + (
                        (reflectionAmount - totalReflections[i]) * PRECISION_FACTOR_REFLECTION[i] / sTokenBal
                    );

                if(address(stakingToken) == address(earnedToken)) {
                    reflections[i] = reflections[i] + (reflectionAmount - totalReflections[i]) * eTokenBal / sTokenBal;
                }
                totalReflections[i] = reflectionAmount;
            }
        }

        if (block.number <= lastRewardBlock || lastRewardBlock == 0) {
            return;
        }

        if (totalStaked == 0) {
            lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
        uint256 _reward = multiplier * rewardPerBlock;
        accTokenPerShare = accTokenPerShare + (
            _reward * PRECISION_FACTOR / totalStaked
        );
        lastRewardBlock = block.number;
        shouldTotalPaid = shouldTotalPaid + _reward;
    }

    function estimateDividendAmount(uint256 index, uint256 amount) internal view returns(uint256) {
        uint256 dTokenBal = availableDividendTokens(index);
        if(amount > totalReflections[index]) amount = totalReflections[index];
        if(amount > dTokenBal) amount = dTokenBal;
        return amount;
    }

    /*
     * @notice Return reward multiplier over the given _from to _to block.
     * @param _from: block to start
     * @param _to: block to finish
     */
    function _getMultiplier(uint256 _from, uint256 _to)
        internal
        view
        returns (uint256)
    {
        if (_to <= bonusEndBlock) {
            return _to - _from;
        } else if (_from >= bonusEndBlock) {
            return 0;
        } else {
            return bonusEndBlock - _from;
        }
    }

    function _safeSwap(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal {
        uint256[] memory amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length - 1];

        IERC20(_path[0]).safeApprove(uniRouterAddress, _amountIn);
        IUniRouter02(uniRouterAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amountIn,
            amountOut * slippageFactor / 1000,
            _path,
            _to,
            block.timestamp + 600
        );
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./libs/IUniRouter02.sol";
import "./libs/IWETH.sol";

interface IToken {
     /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    function claim() external;
}

contract BrewlabsStakingClaim is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // The address of the smart chef factory
    address public POOL_FACTORY;

    // Whether it is initialized
    bool public isInitialized;
    uint256 public duration = 60; // 60 days

    // Whether a limit is set for users
    bool public hasUserLimit;
    // The pool limit (0 if none)
    uint256 public poolLimitPerUser;


    // The block number when staking starts.
    uint256 public startBlock;
    // The block number when staking ends.
    uint256 public bonusEndBlock;
    // tokens created per block.
    uint256 public rewardPerBlock;
    // The block number of the last pool update
    uint256 public lastRewardBlock;


    // swap router and path, slipPage
    uint256 public slippageFactor = 800; // 20% default slippage tolerance
    uint256 public constant slippageFactorUL = 995;

    address public uniRouterAddress;
    address[] public reflectionToStakedPath;
    address[] public earnedToStakedPath;


    // The deposit & withdraw fee
    uint256 public constant MAX_FEE = 2000;
    uint256 public depositFee;
    uint256 public withdrawFee;

    address public walletA;
    address public buyBackWallet = 0x408c4aDa67aE1244dfeC7D609dea3c232843189A;
    uint256 public performanceFee = 0.0035 ether;

    // The precision factor
    uint256 public PRECISION_FACTOR;
    uint256 public PRECISION_FACTOR_REFLECTION;

    // The staked token
    IERC20 public stakingToken;
    // The earned token
    IERC20 public earnedToken;
    // The dividend token of staking token
    address public dividendToken;

    // Accrued token per share
    uint256 public accTokenPerShare;
    uint256 public accDividendPerShare;

    uint256 public totalStaked;

    uint256 private totalEarned;
    uint256 private totalReflections;
    uint256 private reflections;

    uint256 private paidRewards;
    uint256 private shouldTotalPaid;

    // Info of each user that stakes tokens (stakingToken)
    mapping(address => UserInfo) public userInfo;

    struct UserInfo {
        uint256 amount; // How many staked tokens the user has provided
        uint256 rewardDebt; // Reward debt
        uint256 reflectionDebt; // Reflection debt
    }

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event AdminTokenRecovered(address tokenRecovered, uint256 amount);

    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);
    event NewRewardPerBlock(uint256 rewardPerBlock);
    event RewardsStop(uint256 blockNumber);
    event EndBlockUpdated(uint256 blockNumber);
    event UpdatePoolLimit(uint256 poolLimitPerUser, bool hasLimit);

    event ServiceInfoUpadted(address _addr, uint256 _fee);
    event WalletAUpdated(address _addr);
    event DurationUpdated(uint256 _duration);

    event SetSettings(
        uint256 _depositFee,
        uint256 _withdrawFee,
        uint256 _slippageFactor,
        address _uniRouter,
        address[] _path0,
        address[] _path1
    );

    constructor() {
        POOL_FACTORY = msg.sender;
    }

    /*
     * @notice Initialize the contract
     * @param _stakingToken: staked token address
     * @param _earnedToken: earned token address
     * @param _dividendToken: reflection token address
     * @param _rewardPerBlock: reward per block (in earnedToken)
     * @param _depositFee: deposit fee
     * @param _withdrawFee: withdraw fee
     * @param _uniRouter: uniswap router address for swap tokens
     * @param _earnedToStakedPath: swap path to compound (earned -> staking path)
     * @param _reflectionToStakedPath: swap path to compound (reflection -> staking path)
     */
    function initialize(
        IERC20 _stakingToken,
        IERC20 _earnedToken,
        address _dividendToken,
        uint256 _rewardPerBlock,
        uint256 _depositFee,
        uint256 _withdrawFee,
        address _uniRouter,
        address[] memory _earnedToStakedPath,
        address[] memory _reflectionToStakedPath
    ) external {
        require(!isInitialized, "Already initialized");
        require(msg.sender == POOL_FACTORY, "Not factory");

        // Make this contract initialized
        isInitialized = true;

        stakingToken = _stakingToken;
        earnedToken = _earnedToken;
        dividendToken = _dividendToken;

        rewardPerBlock = _rewardPerBlock;

        require(_depositFee < MAX_FEE, "Invalid deposit fee");
        require(_withdrawFee < MAX_FEE, "Invalid withdraw fee");

        depositFee = _depositFee;
        withdrawFee = _withdrawFee;
        
        walletA = msg.sender;

        uint256 decimalsRewardToken = uint256(IToken(address(earnedToken)).decimals());
        require(decimalsRewardToken < 30, "Must be inferior to 30");
        PRECISION_FACTOR = uint256(10**(40 - decimalsRewardToken));

        uint256 decimalsdividendToken = 18;
        if(dividendToken != address(0x0)) {
            decimalsdividendToken = uint256(IToken(dividendToken).decimals());
            require(decimalsdividendToken < 30, "Must be inferior to 30");
        }
        PRECISION_FACTOR_REFLECTION = uint256(10**(40 - decimalsdividendToken));

        uniRouterAddress = _uniRouter;
        earnedToStakedPath = _earnedToStakedPath;
        reflectionToStakedPath = _reflectionToStakedPath;
    }

    /*
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @param _amount: amount to withdraw (in earnedToken)
     */
    function deposit(uint256 _amount) external payable nonReentrant {
        require(startBlock > 0 && startBlock < block.number, "Staking hasn't started yet");
        require(_amount > 0, "Amount should be greator than 0");

        UserInfo storage user = userInfo[msg.sender];

        if (hasUserLimit) {
            require(
                _amount + user.amount <= poolLimitPerUser,
                "User amount above limit"
            );
        }

        _transferPerformanceFee();
        _updatePool();

        if (user.amount > 0) {
            uint256 pending = user.amount * accTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
            if (pending > 0) {
                require(availableRewardTokens() >= pending, "Insufficient reward tokens");
                earnedToken.safeTransfer(address(msg.sender), pending);
                
                if(totalEarned > pending) {
                    totalEarned = totalEarned - pending;
                } else {
                    totalEarned = 0;
                }
                paidRewards = paidRewards + pending;
            }

            uint256 pendingReflection = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - user.reflectionDebt;
            pendingReflection = estimateDividendAmount(pendingReflection);
            if (pendingReflection > 0) {
                if(dividendToken == address(0x0)) {
                    payable(msg.sender).transfer(pendingReflection);
                } else {
                    IERC20(dividendToken).safeTransfer(address(msg.sender), pendingReflection);
                }
                totalReflections = totalReflections - pendingReflection;
            }
        }

        uint256 beforeAmount = stakingToken.balanceOf(address(this));
        stakingToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        uint256 afterAmount = stakingToken.balanceOf(address(this));
        
        uint256 realAmount = afterAmount - beforeAmount;
        if (depositFee > 0) {
            uint256 fee = realAmount * depositFee / 10000;
            if (fee > 0) {
                stakingToken.safeTransfer(walletA, fee);
                realAmount = realAmount - fee;
            }
        }
        
        user.amount = user.amount + realAmount;
        user.rewardDebt = user.amount * accTokenPerShare / PRECISION_FACTOR;
        user.reflectionDebt = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;

        totalStaked = totalStaked + realAmount;
        
        emit Deposit(msg.sender, realAmount);
    }

    /*
     * @notice Withdraw staked tokens and collect reward tokens
     * @param _amount: amount to withdraw (in earnedToken)
     */
    function withdraw(uint256 _amount) external payable nonReentrant {
        require(_amount > 0, "Amount should be greator than 0");

        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "Amount to withdraw too high");

        _transferPerformanceFee();
        _updatePool();

        if(user.amount > 0) {
            uint256 pending = user.amount * accTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
            if (pending > 0) {
                require(availableRewardTokens() >= pending, "Insufficient reward tokens");
                earnedToken.safeTransfer(address(msg.sender), pending);
                
                if(totalEarned > pending) {
                    totalEarned = totalEarned - pending;
                } else {
                    totalEarned = 0;
                }
                paidRewards = paidRewards + pending;
            }

            uint256 pendingReflection = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - user.reflectionDebt;
            pendingReflection = estimateDividendAmount(pendingReflection);
            if (pendingReflection > 0) {
                if(dividendToken == address(0x0)) {
                    payable(msg.sender).transfer(pendingReflection);
                } else {
                    IERC20(dividendToken).safeTransfer(address(msg.sender), pendingReflection);
                }
                totalReflections = totalReflections - pendingReflection;
            }
        }

        uint256 realAmount = _amount;

        if (user.amount < _amount) {
            realAmount = user.amount;
        }

        user.amount = user.amount - realAmount;
        totalStaked = totalStaked - realAmount;

        if (withdrawFee > 0) {
            uint256 fee = realAmount * withdrawFee / 10000;
            if (fee > 0) {
                stakingToken.safeTransfer(walletA, fee);
                realAmount = realAmount - fee;
            }
        }

        stakingToken.safeTransfer(address(msg.sender), realAmount);

        user.rewardDebt = user.amount * accTokenPerShare / PRECISION_FACTOR;
        user.reflectionDebt = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;

        emit Withdraw(msg.sender, _amount);
    }

    function claimReward() external payable nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        
        _transferPerformanceFee();
        _updatePool();

        if (user.amount == 0) return;

        uint256 pending = user.amount * accTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            earnedToken.safeTransfer(address(msg.sender), pending);
            
            if(totalEarned > pending) {
                totalEarned = totalEarned - pending;
            } else {
                totalEarned = 0;
            }
            paidRewards = paidRewards + pending;
        }
        
        user.rewardDebt = user.amount * accTokenPerShare / PRECISION_FACTOR;
    }

    function claimDividend() external payable nonReentrant {
        UserInfo storage user = userInfo[msg.sender];

        _transferPerformanceFee();
        _updatePool();

        if (user.amount == 0) return;

        uint256 pendingReflection = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - user.reflectionDebt;
        pendingReflection = estimateDividendAmount(pendingReflection);
        if (pendingReflection > 0) {
            if(dividendToken == address(0x0)) {
                payable(msg.sender).transfer(pendingReflection);
            } else {
                IERC20(dividendToken).safeTransfer(address(msg.sender), pendingReflection);
            }
            totalReflections = totalReflections - pendingReflection;
        }
        
        user.reflectionDebt = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
    }

    function compoundReward() external payable nonReentrant {
        UserInfo storage user = userInfo[msg.sender];

        _transferPerformanceFee();
        _updatePool();

        if (user.amount == 0) return;

        uint256 pending = user.amount * accTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            if(totalEarned > pending) {
                totalEarned = totalEarned - pending;
            } else {
                totalEarned = 0;
            }
            paidRewards = paidRewards + pending;
            
            if(address(stakingToken) != address(earnedToken)) {
                uint256 beforeAmount = stakingToken.balanceOf(address(this));
                _safeSwap(pending, earnedToStakedPath, address(this));
                uint256 afterAmount = stakingToken.balanceOf(address(this));
                pending = afterAmount - beforeAmount;
            }

            if (hasUserLimit) {
                require(
                    pending + user.amount <= poolLimitPerUser,
                    "User amount above limit"
                );
            }

            totalStaked = totalStaked + pending;
            user.amount = user.amount + pending;
            user.reflectionDebt = user.reflectionDebt + pending * accDividendPerShare / PRECISION_FACTOR_REFLECTION;

            emit Deposit(msg.sender, pending);
        }
        
        user.rewardDebt = user.amount * accTokenPerShare / PRECISION_FACTOR;
    }

    function compoundDividend() external payable nonReentrant {
        UserInfo storage user = userInfo[msg.sender];

        _transferPerformanceFee();
        _updatePool();

        if (user.amount == 0) return;

        uint256 pending = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - user.reflectionDebt;
        pending = estimateDividendAmount(pending);
        if (pending > 0) {
            totalReflections = totalReflections - pending;

            if(address(stakingToken) != address(dividendToken)) {
                if(address(dividendToken) == address(0x0)) {
                    address wethAddress = IUniRouter02(uniRouterAddress).WETH();
                    IWETH(wethAddress).deposit{ value: pending }();
                }

                uint256 beforeAmount = stakingToken.balanceOf(address(this));
                _safeSwap(pending, reflectionToStakedPath, address(this));
                uint256 afterAmount = stakingToken.balanceOf(address(this));

                pending = afterAmount - beforeAmount;
            }

            if (hasUserLimit) {
                require(
                    pending + user.amount <= poolLimitPerUser,
                    "User amount above limit"
                );
            }

            totalStaked = totalStaked + pending;
            user.amount = user.amount + pending;
            user.rewardDebt = user.rewardDebt + pending * accTokenPerShare / PRECISION_FACTOR;

            emit Deposit(msg.sender, pending);
        }
        
        user.reflectionDebt = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
    }
    
    function _transferPerformanceFee() internal {
        require(msg.value >= performanceFee, 'should pay small gas to compound or harvest');

        payable(buyBackWallet).transfer(performanceFee);
        if(msg.value > performanceFee) {
            payable(msg.sender).transfer(msg.value - performanceFee);
        }
    }

    /*
     * @notice Withdraw staked tokens without caring about rewards
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        uint256 amountToTransfer = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        user.reflectionDebt = 0;

        if (amountToTransfer > 0) {
            stakingToken.safeTransfer(address(msg.sender), amountToTransfer);
            totalStaked = totalStaked - amountToTransfer;
        }

        emit EmergencyWithdraw(msg.sender, user.amount);
    }

    /**
     * @notice Available amount of reward token
     */
    function availableRewardTokens() public view returns (uint256) {
        if(address(earnedToken) == address(dividendToken)) return totalEarned;

        uint256 _amount = earnedToken.balanceOf(address(this));
        if (address(earnedToken) == address(stakingToken)) {
            if (_amount < totalStaked) return 0;
            return _amount - totalStaked;
        }

        return _amount;
    }

    /**
     * @notice Available amount of reflection token
     */
    function availableDividendTokens() public view returns (uint256) {
        if(dividendToken == address(0x0)) {
            return address(this).balance;
        }

        uint256 _amount = IERC20(dividendToken).balanceOf(address(this));
        
        if(dividendToken == address(earnedToken)) {
            if(_amount < totalEarned) return 0;
            _amount = _amount - totalEarned;
        }

        if(dividendToken == address(stakingToken)) {
            if(_amount < totalStaked) return 0;
            _amount = _amount - totalStaked;
        }

        return _amount;
    }
 
    function insufficientRewards() external view returns (uint256) {
        uint256 adjustedShouldTotalPaid = shouldTotalPaid;
        uint256 remainRewards = availableRewardTokens() + paidRewards;

        if(startBlock == 0) {
            adjustedShouldTotalPaid = adjustedShouldTotalPaid + rewardPerBlock * duration * 28800;
        } else {
            uint256 remainBlocks = _getMultiplier(lastRewardBlock, bonusEndBlock);
            adjustedShouldTotalPaid = adjustedShouldTotalPaid + rewardPerBlock * remainBlocks;
        }

        if(remainRewards >= adjustedShouldTotalPaid) return 0;

        return adjustedShouldTotalPaid - remainRewards;
    }

    /*
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @return Pending reward for a given user
     */
    function pendingReward(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];

        uint256 adjustedTokenPerShare = accTokenPerShare;
        if (block.number > lastRewardBlock && totalStaked != 0 && lastRewardBlock > 0) {
            uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
            uint256 rewards = multiplier * rewardPerBlock;

            adjustedTokenPerShare = accTokenPerShare + (
                    rewards * PRECISION_FACTOR / totalStaked
                );
        }

        return user.amount * adjustedTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
    }

    function pendingDividends(address _user) external view returns (uint256) {
        if(totalStaked == 0) return 0;

        UserInfo storage user = userInfo[_user];
        
        uint256 reflectionAmount = availableDividendTokens();
        if(reflectionAmount < totalReflections) {
            reflectionAmount = totalReflections;
        }

        uint256 sTokenBal = totalStaked;
        uint256 eTokenBal = availableRewardTokens();
        if(address(stakingToken) == address(earnedToken)) {
            sTokenBal = sTokenBal + eTokenBal;
        }

        uint256 adjustedReflectionPerShare = accDividendPerShare + (
                (reflectionAmount - totalReflections) * PRECISION_FACTOR_REFLECTION / sTokenBal
            );
        
        uint256 pendingReflection = user.amount * adjustedReflectionPerShare / PRECISION_FACTOR_REFLECTION - user.reflectionDebt;        
        return pendingReflection;
    }

    /************************
    ** Admin Methods
    *************************/
    function harvest() external onlyOwner {    
        IToken(address(stakingToken)).claim();
        
        _updatePool();

        reflections = estimateDividendAmount(reflections);
        if(reflections > 0) {
            if(address(dividendToken) == address(0x0)) {
                payable(walletA).transfer(reflections);
            } else {
                IERC20(dividendToken).safeTransfer(walletA, reflections);
            }

            totalReflections = totalReflections - reflections;
            reflections = 0;
        }
    }

    /*
     * @notice Deposit reward token
     * @dev Only call by owner. Needs to be for deposit of reward token when reflection token is same with reward token.
     */
    function depositRewards(uint _amount) external onlyOwner nonReentrant {
        require(_amount > 0, "invalid amount");

        uint256 beforeAmt = earnedToken.balanceOf(address(this));
        earnedToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = earnedToken.balanceOf(address(this));

        totalEarned = totalEarned + afterAmt - beforeAmt;
    }
 
    function increaseEmissionRate(uint256 _amount) external onlyOwner {
        require(startBlock > 0, "pool is not started");
        require(bonusEndBlock > block.number, "pool was already finished");
        require(_amount > 0, "invalid amount");
        
        _updatePool();

        uint256 beforeAmt = earnedToken.balanceOf(address(this));
        earnedToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = earnedToken.balanceOf(address(this));

        totalEarned = totalEarned + afterAmt - beforeAmt;

        uint256 remainRewards = availableRewardTokens() + paidRewards;
        if(remainRewards > shouldTotalPaid) {
            remainRewards = remainRewards - shouldTotalPaid;

            uint256 remainBlocks = bonusEndBlock - block.number;
            rewardPerBlock = remainRewards / remainBlocks;
            emit NewRewardPerBlock(rewardPerBlock);
        }
    }

    /*
     * @notice Withdraw reward token
     * @dev Only callable by owner. Needs to be for emergency.
     */
    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
        require( block.number > bonusEndBlock, "Pool is running");
        require(availableRewardTokens() >= _amount, "Insufficient reward tokens");

        earnedToken.safeTransfer(address(msg.sender), _amount);
        
        if (totalEarned > 0) {
            if (_amount > totalEarned) {
                totalEarned = 0;
            } else {
                totalEarned = totalEarned - _amount;
            }
        }
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of tokens to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount)
        external
        onlyOwner
    {
        require(
            _tokenAddress != address(earnedToken),
            "Cannot be reward token"
        );

        if(_tokenAddress == address(stakingToken)) {
            uint256 tokenBal = stakingToken.balanceOf(address(this));
            require(_tokenAmount <= tokenBal - totalStaked, "Insufficient balance");
        }

        if(_tokenAddress == address(0x0)) {
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
        }

        emit AdminTokenRecovered(_tokenAddress, _tokenAmount);
    }

    function startReward() external onlyOwner {
        require(startBlock == 0, "Pool was already started");

        startBlock = block.number + 100;
        bonusEndBlock = startBlock + duration * 28800;
        lastRewardBlock = startBlock;
        
        emit NewStartAndEndBlocks(startBlock, bonusEndBlock);
    }

    function stopReward() external onlyOwner {
        _updatePool();

        uint256 remainRewards = availableRewardTokens() + paidRewards;
        if(remainRewards > shouldTotalPaid) {
            remainRewards = remainRewards - shouldTotalPaid;
            earnedToken.transfer(msg.sender, remainRewards);

            if(totalEarned > remainRewards) {
                totalEarned = totalEarned - remainRewards;
            } else {
                totalEarned = 0;
            }
        }

        bonusEndBlock = block.number;
        emit RewardsStop(bonusEndBlock);
    }

    function updateEndBlock(uint256 _endBlock) external onlyOwner {
        require(startBlock > 0, "Pool is not started");
        require(bonusEndBlock > block.number, "Pool was already finished");
        require(_endBlock > block.number && _endBlock > startBlock, "Invalid end block");
        bonusEndBlock = _endBlock;
        emit EndBlockUpdated(_endBlock);
    }

    /*
     * @notice Update pool limit per user
     * @dev Only callable by owner.
     * @param _hasUserLimit: whether the limit remains forced
     * @param _poolLimitPerUser: new pool limit per user
     */
    function updatePoolLimitPerUser( bool _hasUserLimit, uint256 _poolLimitPerUser) external onlyOwner {
        if (_hasUserLimit) {
            require(
                _poolLimitPerUser > poolLimitPerUser,
                "New limit must be higher"
            );
            poolLimitPerUser = _poolLimitPerUser;
        } else {
            poolLimitPerUser = 0;
        }
        hasUserLimit = _hasUserLimit;

        emit UpdatePoolLimit(poolLimitPerUser, hasUserLimit);
    }

    /*
     * @notice Update reward per block
     * @dev Only callable by owner.
     * @param _rewardPerBlock: the reward per block
     */
    function updateRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner {
        // require(block.number < startBlock, "Pool was already started");

        rewardPerBlock = _rewardPerBlock;
        emit NewRewardPerBlock(_rewardPerBlock);
    }

    function setServiceInfo(address _buyBackWallet, uint256 _fee) external {
        require(msg.sender == buyBackWallet, "setServiceInfo: FORBIDDEN");
        require(_buyBackWallet != address(0x0), "Invalid address");

        buyBackWallet = _buyBackWallet;
        performanceFee = _fee;

        emit ServiceInfoUpadted(_buyBackWallet, _fee);
    }

    function updateWalletA(address _walletA) external onlyOwner {
        require(_walletA != address(0x0) || _walletA != walletA, "Invalid address");

        walletA = _walletA;
        emit WalletAUpdated(_walletA);
    }

    function setDuration(uint256 _duration) external onlyOwner {
        require(startBlock == 0, "Pool was already started");
        require(_duration >= 30, "lower limit reached");

        duration = _duration;
        emit DurationUpdated(_duration);
    }

    function setSettings(
        uint256 _depositFee,
        uint256 _withdrawFee,
        uint256 _slippageFactor,
        address _uniRouter,
        address[] memory _earnedToStakedPath,
        address[] memory _reflectionToStakedPath
    ) external onlyOwner {
        require(_depositFee < MAX_FEE, "Invalid deposit fee");
        require(_withdrawFee < MAX_FEE, "Invalid withdraw fee");
        require(_slippageFactor <= slippageFactorUL, "_slippageFactor too high");

        depositFee = _depositFee;
        withdrawFee = _withdrawFee;

        slippageFactor = _slippageFactor;
        uniRouterAddress = _uniRouter;
        reflectionToStakedPath = _reflectionToStakedPath;
        earnedToStakedPath = _earnedToStakedPath;

        emit SetSettings(_depositFee, _withdrawFee, _slippageFactor, _uniRouter, _earnedToStakedPath, _reflectionToStakedPath);
    }


    /************************
    ** Internal Methods
    *************************/
    /*
     * @notice Update reward variables of the given pool to be up-to-date.
     */
    function _updatePool() internal {
        // calc reflection rate
        if(totalStaked > 0) {
            uint256 reflectionAmount = availableDividendTokens();
            if(reflectionAmount < totalReflections) {
                reflectionAmount = totalReflections;
            }

            uint256 sTokenBal = totalStaked;
            uint256 eTokenBal = availableRewardTokens();
            if(address(stakingToken) == address(earnedToken)) {
                sTokenBal = sTokenBal + eTokenBal;
            }

            accDividendPerShare = accDividendPerShare + (
                    (reflectionAmount - totalReflections) * PRECISION_FACTOR_REFLECTION / sTokenBal
                );

            if(address(stakingToken) == address(earnedToken)) {
                reflections = reflections + (reflectionAmount - totalReflections) * eTokenBal / sTokenBal;
            }
            totalReflections = reflectionAmount;
        }

        if (block.number <= lastRewardBlock || lastRewardBlock == 0) {
            return;
        }

        if (totalStaked == 0) {
            lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
        uint256 _reward = multiplier * rewardPerBlock;
        accTokenPerShare = accTokenPerShare + (
            _reward * PRECISION_FACTOR / totalStaked
        );
        lastRewardBlock = block.number;
        shouldTotalPaid = shouldTotalPaid + _reward;
    }

    function estimateDividendAmount(uint256 amount) internal view returns(uint256) {
        uint256 dTokenBal = availableDividendTokens();
        if(amount > totalReflections) amount = totalReflections;
        if(amount > dTokenBal) amount = dTokenBal;
        return amount;
    }

    /*
     * @notice Return reward multiplier over the given _from to _to block.
     * @param _from: block to start
     * @param _to: block to finish
     */
    function _getMultiplier(uint256 _from, uint256 _to)
        internal
        view
        returns (uint256)
    {
        if (_to <= bonusEndBlock) {
            return _to - _from;
        } else if (_from >= bonusEndBlock) {
            return 0;
        } else {
            return bonusEndBlock - _from;
        }
    }

    function _safeSwap(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal {
        uint256[] memory amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length - 1];

        IERC20(_path[0]).safeApprove(uniRouterAddress, _amountIn);
        IUniRouter02(uniRouterAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amountIn,
            amountOut * slippageFactor / 1000,
            _path,
            _to,
            block.timestamp + 600
        );
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./libs/IUniRouter02.sol";
import "./libs/IWETH.sol";
interface IToken {
     /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);
}

contract BrewlabsStaking is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Whether it is initialized
    bool public isInitialized;
    uint256 public duration = 365; // 365 days

    // Whether a limit is set for users
    bool public hasUserLimit;
    // The pool limit (0 if none)
    uint256 public poolLimitPerUser;


    // The block number when staking starts.
    uint256 public startBlock;
    // The block number when staking ends.
    uint256 public bonusEndBlock;
    // tokens created per block.
    uint256 public rewardPerBlock;
    // The block number of the last pool update
    uint256 public lastRewardBlock;


    // swap router and path, slipPage
    uint256 public slippageFactor = 800; // 20% default slippage tolerance
    uint256 public constant slippageFactorUL = 995;

    address public uniRouterAddress;
    address[] public reflectionToStakedPath;
    address[] public earnedToStakedPath;


    // The deposit & withdraw fee
    uint256 public constant MAX_FEE = 2000;
    uint256 public depositFee;

    uint256 public withdrawFee;

    address public walletA;
    address public buyBackWallet = 0x408c4aDa67aE1244dfeC7D609dea3c232843189A;
    uint256 public performanceFee = 0.0035 ether;

    // The precision factor
    uint256 public PRECISION_FACTOR;
    uint256 public PRECISION_FACTOR_REFLECTION;

    // The staked token
    IERC20 public stakingToken;
    // The earned token
    IERC20 public earnedToken;
    // The dividend token of staking token
    address public dividendToken;
    bool public hasDividend;

    // Accrued token per share
    uint256 public accTokenPerShare;
    uint256 public accDividendPerShare;

    uint256 public totalStaked;

    uint256 private totalEarned;
    uint256 private totalReflections;
    uint256 private reflections;

    uint256 private paidRewards;
    uint256 private shouldTotalPaid;

    // Info of each user that stakes tokens (stakingToken)
    mapping(address => UserInfo) public userInfo;

    struct UserInfo {
        uint256 amount; // How many staked tokens the user has provided
        uint256 rewardDebt; // Reward debt
        uint256 reflectionDebt; // Reflection debt
    }

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event AdminTokenRecovered(address tokenRecovered, uint256 amount);

    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);
    event NewRewardPerBlock(uint256 rewardPerBlock);
    event RewardsStop(uint256 blockNumber);
    event EndBlockUpdated(uint256 blockNumber);
    event UpdatePoolLimit(uint256 poolLimitPerUser, bool hasLimit);

    event ServiceInfoUpadted(address _addr, uint256 _fee);
    event WalletAUpdated(address _addr);
    event DurationUpdated(uint256 _duration);

    event SetSettings(
        uint256 _depositFee,
        uint256 _withdrawFee,
        uint256 _slippageFactor,
        address _uniRouter,
        address[] _path0,
        address[] _path1
    );

    constructor() {}

    /*
     * @notice Initialize the contract
     * @param _stakingToken: staked token address
     * @param _earnedToken: earned token address
     * @param _dividendToken: reflection token address
     * @param _rewardPerBlock: reward per block (in earnedToken)
     * @param _depositFee: deposit fee
     * @param _withdrawFee: withdraw fee
     * @param _uniRouter: uniswap router address for swap tokens
     * @param _earnedToStakedPath: swap path to compound (earned -> staking path)
     * @param _reflectionToStakedPath: swap path to compound (reflection -> staking path)
     */
    function initialize(
        IERC20 _stakingToken,
        IERC20 _earnedToken,
        address _dividendToken,
        uint256 _rewardPerBlock,
        uint256 _depositFee,
        uint256 _withdrawFee,
        address _uniRouter,
        address[] memory _earnedToStakedPath,
        address[] memory _reflectionToStakedPath,
        bool _hasDividend
    ) external onlyOwner {
        require(!isInitialized, "Already initialized");

        // Make this contract initialized
        isInitialized = true;

        stakingToken = _stakingToken;
        earnedToken = _earnedToken;
        dividendToken = _dividendToken;
        hasDividend = _hasDividend;

        rewardPerBlock = _rewardPerBlock;

        require(_depositFee < MAX_FEE, "Invalid deposit fee");
        require(_withdrawFee < MAX_FEE, "Invalid withdraw fee");

        depositFee = _depositFee;
        withdrawFee = _withdrawFee;
        
        walletA = msg.sender;

        uint256 decimalsRewardToken = uint256(IToken(address(earnedToken)).decimals());
        require(decimalsRewardToken < 30, "Must be inferior to 30");
        PRECISION_FACTOR = uint256(10**(40 - decimalsRewardToken));

        uint256 decimalsdividendToken = 18;
        if(address(dividendToken) != address(0x0)) {
            decimalsdividendToken = uint256(IToken(address(dividendToken)).decimals());
            require(decimalsdividendToken < 30, "Must be inferior to 30");
        }
        PRECISION_FACTOR_REFLECTION = uint256(10**(40 - decimalsdividendToken));

        uniRouterAddress = _uniRouter;
        earnedToStakedPath = _earnedToStakedPath;
        reflectionToStakedPath = _reflectionToStakedPath;
    }

    /*
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @param _amount: amount to withdraw (in earnedToken)
     */
    function deposit(uint256 _amount) external payable nonReentrant {
        require(startBlock > 0 && startBlock < block.number, "Staking hasn't started yet");
        require(_amount > 0, "Amount should be greator than 0");

        UserInfo storage user = userInfo[msg.sender];

        if (hasUserLimit) {
            require(
                _amount + user.amount <= poolLimitPerUser,
                "User amount above limit"
            );
        }

        _transferPerformanceFee();
        _updatePool();

        if (user.amount > 0) {
            uint256 pending = user.amount * accTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
            if (pending > 0) {
                require(availableRewardTokens() >= pending, "Insufficient reward tokens");
                earnedToken.safeTransfer(address(msg.sender), pending);
                
                if(totalEarned > pending) {
                    totalEarned = totalEarned - pending;
                } else {
                    totalEarned = 0;
                }
                paidRewards = paidRewards + pending;
            }

            uint256 pendingReflection = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - user.reflectionDebt;
            pendingReflection = estimateDividendAmount(pendingReflection);
            if (pendingReflection > 0 && hasDividend) {
                if(address(dividendToken) == address(0x0)) {
                    payable(msg.sender).transfer(pendingReflection);
                } else {
                    IERC20(dividendToken).safeTransfer(address(msg.sender), pendingReflection);
                }
                totalReflections = totalReflections - pendingReflection;
            }
        }
        
        uint256 beforeAmount = stakingToken.balanceOf(address(this));
        stakingToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        uint256 afterAmount = stakingToken.balanceOf(address(this));        
        uint256 realAmount = afterAmount - beforeAmount;
        if(realAmount > _amount) realAmount = _amount;

        if (depositFee > 0) {
            uint256 fee = realAmount * depositFee / 10000;
            stakingToken.safeTransfer(walletA, fee);
            realAmount = realAmount - fee;
        }
        
        user.amount = user.amount + realAmount;
        user.rewardDebt = user.amount * accTokenPerShare / PRECISION_FACTOR;
        user.reflectionDebt = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;

        totalStaked = totalStaked + realAmount;
        
        emit Deposit(msg.sender, realAmount);
    }

    /*
     * @notice Withdraw staked tokens and collect reward tokens
     * @param _amount: amount to withdraw (in earnedToken)
     */
    function withdraw(uint256 _amount) external payable nonReentrant {
        require(_amount > 0, "Amount should be greator than 0");

        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "Amount to withdraw too high");

        _transferPerformanceFee();
        _updatePool();

        if(user.amount > 0) {
            uint256 pending = user.amount * accTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
            if (pending > 0) {
                require(availableRewardTokens() >= pending, "Insufficient reward tokens");
                earnedToken.safeTransfer(address(msg.sender), pending);
                
                if(totalEarned > pending) {
                    totalEarned = totalEarned - pending;
                } else {
                    totalEarned = 0;
                }
                paidRewards = paidRewards + pending;
            }

            uint256 pendingReflection = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - user.reflectionDebt;
            pendingReflection = estimateDividendAmount(pendingReflection);
            if (pendingReflection > 0 && hasDividend) {
                if(address(dividendToken) == address(0x0)) {
                    payable(msg.sender).transfer(pendingReflection);
                } else {
                    IERC20(dividendToken).safeTransfer(address(msg.sender), pendingReflection);
                }
                totalReflections = totalReflections - pendingReflection;
            }
        }

        uint256 realAmount = _amount;
        if (user.amount < _amount) {
            realAmount = user.amount;
        }

        user.amount = user.amount - realAmount;
        totalStaked = totalStaked - realAmount;

        if (withdrawFee > 0) {
            uint256 fee = realAmount * withdrawFee / 10000;
            stakingToken.safeTransfer(walletA, fee);
            realAmount = realAmount - fee;
        }

        stakingToken.safeTransfer(address(msg.sender), realAmount);

        user.rewardDebt = user.amount * accTokenPerShare / PRECISION_FACTOR;
        user.reflectionDebt = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;

        emit Withdraw(msg.sender, _amount);
    }

    function claimReward() external payable nonReentrant {
        UserInfo storage user = userInfo[msg.sender];

        _transferPerformanceFee();
        _updatePool();

        if (user.amount == 0) return;

        uint256 pending = user.amount * accTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            earnedToken.safeTransfer(address(msg.sender), pending);
            
            if(totalEarned > pending) {
                totalEarned = totalEarned - pending;
            } else {
                totalEarned = 0;
            }
            paidRewards = paidRewards + pending;
        }
        
        user.rewardDebt = user.amount * accTokenPerShare / PRECISION_FACTOR;
    }

    function claimDividend() external payable nonReentrant {
        require(hasDividend == true, "No reflections");
        UserInfo storage user = userInfo[msg.sender];

        _transferPerformanceFee();
        _updatePool();

        if (user.amount == 0) return;

        uint256 pendingReflection = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - user.reflectionDebt;
        pendingReflection = estimateDividendAmount(pendingReflection);
        if (pendingReflection > 0) {
            if(address(dividendToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingReflection);
            } else {
                IERC20(dividendToken).safeTransfer(address(msg.sender), pendingReflection);
            }
            totalReflections = totalReflections - pendingReflection;
        }
        
        user.reflectionDebt = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
    }

    function compoundReward() external payable nonReentrant {
        UserInfo storage user = userInfo[msg.sender];

        _transferPerformanceFee();
        _updatePool();

        if (user.amount == 0) return;

        uint256 pending = user.amount * accTokenPerShare / PRECISION_FACTOR - user.rewardDebt;
        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            if(totalEarned > pending) {
                totalEarned = totalEarned - pending;
            } else {
                totalEarned = 0;
            }
            paidRewards = paidRewards + pending;
            
            if(address(stakingToken) != address(earnedToken)) {
                uint256 beforeAmount = stakingToken.balanceOf(address(this));
                _safeSwap(pending, earnedToStakedPath, address(this));
                uint256 afterAmount = stakingToken.balanceOf(address(this));
                pending = afterAmount - beforeAmount;
            }

            if (hasUserLimit) {
                require(
                    pending + user.amount <= poolLimitPerUser,
                    "User amount above limit"
                );
            }

            totalStaked = totalStaked + pending;
            user.amount = user.amount + pending;
            user.reflectionDebt = user.reflectionDebt + pending * accDividendPerShare / PRECISION_FACTOR_REFLECTION;

            emit Deposit(msg.sender, pending);
        }
        
        user.rewardDebt = user.amount * accTokenPerShare / PRECISION_FACTOR;
    }

    function compoundDividend() external payable nonReentrant {
        require(hasDividend == true, "No reflections");
        UserInfo storage user = userInfo[msg.sender];

        _transferPerformanceFee();
        _updatePool();

        if (user.amount == 0) return;

        uint256 pending = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - user.reflectionDebt;
        pending = estimateDividendAmount(pending);
        if (pending > 0) {
            totalReflections = totalReflections - pending;

            if(address(stakingToken) != address(dividendToken)) {
                if(address(dividendToken) == address(0x0)) {
                    address wethAddress = IUniRouter02(uniRouterAddress).WETH();
                    IWETH(wethAddress).deposit{ value: pending }();
                }

                uint256 beforeAmount = stakingToken.balanceOf(address(this));
                _safeSwap(pending, reflectionToStakedPath, address(this));
                uint256 afterAmount = stakingToken.balanceOf(address(this));

                pending = afterAmount - beforeAmount;
            }

            if (hasUserLimit) {
                require(
                    pending + user.amount <= poolLimitPerUser,
                    "User amount above limit"
                );
            }

            totalStaked = totalStaked + pending;
            user.amount = user.amount + pending;
            user.rewardDebt = user.rewardDebt + pending * accTokenPerShare / PRECISION_FACTOR;

            emit Deposit(msg.sender, pending);
        }
        
        user.reflectionDebt = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
    }

    function _transferPerformanceFee() internal {
        require(msg.value >= performanceFee, 'should pay small gas to compound or harvest');

        payable(buyBackWallet).transfer(performanceFee);
        if(msg.value > performanceFee) {
            payable(msg.sender).transfer(msg.value - performanceFee);
        }
    }

    /*
     * @notice Withdraw staked tokens without caring about rewards
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        uint256 amountToTransfer = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        user.reflectionDebt = 0;

        if (amountToTransfer > 0) {
            stakingToken.safeTransfer(address(msg.sender), amountToTransfer);
            totalStaked = totalStaked - amountToTransfer;
        }

        emit EmergencyWithdraw(msg.sender, user.amount);
    }

    /**
     * @notice Available amount of reward token
     */
    function availableRewardTokens() public view returns (uint256) {
        if(address(earnedToken) == address(dividendToken)) return totalEarned;

        uint256 _amount = earnedToken.balanceOf(address(this));
        if (address(earnedToken) == address(stakingToken)) {
            if (_amount < totalStaked) return 0;
            return _amount - totalStaked;
        }

        return _amount;
    }

    /**
     * @notice Available amount of reflection token
     */
    function availableDividendTokens() public view returns (uint256) {
        if(address(dividendToken) == address(0x0)) {
            return address(this).balance;
        }

        uint256 _amount = IERC20(dividendToken).balanceOf(address(this));
        
        if(address(dividendToken) == address(earnedToken)) {
            if(_amount < totalEarned) return 0;
            _amount = _amount - totalEarned;
        }

        if(address(dividendToken) == address(stakingToken)) {
            if(_amount < totalStaked) return 0;
            _amount = _amount - totalStaked;
        }

        return _amount;
    }

    function insufficientRewards() external view returns (uint256) {
        uint256 adjustedShouldTotalPaid = shouldTotalPaid;
        uint256 remainRewards = availableRewardTokens() + paidRewards;

        if(startBlock == 0) {
            adjustedShouldTotalPaid = adjustedShouldTotalPaid + rewardPerBlock * duration * 28800;
        } else {
            uint256 remainBlocks = _getMultiplier(lastRewardBlock, bonusEndBlock);
            adjustedShouldTotalPaid = adjustedShouldTotalPaid + rewardPerBlock * remainBlocks;
        }

        if(remainRewards >= adjustedShouldTotalPaid) return 0;

        return adjustedShouldTotalPaid - remainRewards;
    }

    /*
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @return Pending reward for a given user
     */
    function pendingReward(address _user) external view returns (uint256) {
        UserInfo memory user = userInfo[_user];

        uint256 adjustedTokenPerShare = accTokenPerShare;
        if (block.number > lastRewardBlock && totalStaked != 0 && lastRewardBlock > 0) {
            uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
            uint256 rewards = multiplier * rewardPerBlock;

            adjustedTokenPerShare = accTokenPerShare + (
                    rewards * PRECISION_FACTOR / totalStaked
                );
        }

        return user.amount * adjustedTokenPerShare / PRECISION_FACTOR -  user.rewardDebt;
    }

    function pendingDividends(address _user) external view returns (uint256) {
        if(totalStaked == 0) return 0;

        UserInfo memory user = userInfo[_user];
        
        uint256 reflectionAmount = availableDividendTokens();
        if(reflectionAmount < totalReflections) {
            reflectionAmount = totalReflections;
        }

        uint256 sTokenBal = totalStaked;
        uint256 eTokenBal = availableRewardTokens();
        if(address(stakingToken) == address(earnedToken)) {
            sTokenBal = sTokenBal + eTokenBal;
        }

        uint256 adjustedReflectionPerShare = accDividendPerShare + (
                (reflectionAmount - totalReflections) * PRECISION_FACTOR_REFLECTION / sTokenBal
            );
        
        uint256 pendingReflection = 
                user.amount * adjustedReflectionPerShare / PRECISION_FACTOR_REFLECTION - user.reflectionDebt;
        
        return pendingReflection;
    }

    /************************
    ** Admin Methods
    *************************/
    function harvest() external onlyOwner {        
        _updatePool();

        reflections = estimateDividendAmount(reflections);
        if(reflections > 0) {
            if(address(dividendToken) == address(0x0)) {
                payable(walletA).transfer(reflections);
            } else {
                IERC20(dividendToken).safeTransfer(walletA, reflections);
            }

            totalReflections = totalReflections - reflections;
            reflections = 0;
        }
    }

    /*
     * @notice Deposit reward token
     * @dev Only call by owner. Needs to be for deposit of reward token when reflection token is same with reward token.
     */
    function depositRewards(uint _amount) external onlyOwner nonReentrant {
        require(_amount > 0, "invalid amount");

        uint256 beforeAmt = earnedToken.balanceOf(address(this));
        earnedToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = earnedToken.balanceOf(address(this));

        totalEarned = totalEarned + afterAmt - beforeAmt;
    }

    function increaseEmissionRate(uint256 _amount) external onlyOwner {
        require(startBlock > 0, "pool is not started");
        require(bonusEndBlock > block.number, "pool was already finished");
        require(_amount > 0, "invalid amount");
        
        _updatePool();

        uint256 beforeAmt = earnedToken.balanceOf(address(this));
        earnedToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = earnedToken.balanceOf(address(this));

        totalEarned = totalEarned + afterAmt - beforeAmt;

        uint256 remainRewards = availableRewardTokens() + paidRewards;
        if(remainRewards > shouldTotalPaid) {
            remainRewards = remainRewards - shouldTotalPaid;

            uint256 remainBlocks = bonusEndBlock - block.number;
            rewardPerBlock = remainRewards / remainBlocks;
            emit NewRewardPerBlock(rewardPerBlock);
        }
    }

    /*
     * @notice Withdraw reward token
     * @dev Only callable by owner. Needs to be for emergency.
     */
    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
        require( block.number > bonusEndBlock, "Pool is running");
        require(availableRewardTokens() >= _amount, "Insufficient reward tokens");

        if(_amount == 0) _amount = availableRewardTokens();
        earnedToken.safeTransfer(address(msg.sender), _amount);
        
        if (totalEarned > 0) {
            if (_amount > totalEarned) {
                totalEarned = 0;
            } else {
                totalEarned = totalEarned - _amount;
            }
        }
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of tokens to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(
            _tokenAddress != address(earnedToken),
            "Cannot be reward token"
        );

        if(_tokenAddress == address(stakingToken)) {
            uint256 tokenBal = stakingToken.balanceOf(address(this));
            require(_tokenAmount <= tokenBal - totalStaked, "Insufficient balance");
        }

        if(_tokenAddress == address(0x0)) {
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
        }

        emit AdminTokenRecovered(_tokenAddress, _tokenAmount);
    }

    function startReward() external onlyOwner {
        require(startBlock == 0, "Pool was already started");

        startBlock = block.number + 100;
        bonusEndBlock = startBlock + duration * 28800;
        lastRewardBlock = startBlock;
        
        emit NewStartAndEndBlocks(startBlock, bonusEndBlock);
    }

    function stopReward() external onlyOwner {
        _updatePool();

        uint256 remainRewards = availableRewardTokens() + paidRewards;
        if(remainRewards > shouldTotalPaid) {
            remainRewards = remainRewards - shouldTotalPaid;
            earnedToken.transfer(msg.sender, remainRewards);

            if(totalEarned > remainRewards) {
                totalEarned = totalEarned - remainRewards;
            } else {
                totalEarned = 0;
            }
        }

        bonusEndBlock = block.number;
        emit RewardsStop(bonusEndBlock);
    }

    function updateEndBlock(uint256 _endBlock) external onlyOwner {
        require(startBlock > 0, "Pool is not started");
        require(bonusEndBlock > block.number, "Pool was already finished");
        require(_endBlock > block.number && _endBlock > startBlock, "Invalid end block");
        bonusEndBlock = _endBlock;
        emit EndBlockUpdated(_endBlock);
    }

    /*
     * @notice Update pool limit per user
     * @dev Only callable by owner.
     * @param _hasUserLimit: whether the limit remains forced
     * @param _poolLimitPerUser: new pool limit per user
     */
    function updatePoolLimitPerUser( bool _hasUserLimit, uint256 _poolLimitPerUser) external onlyOwner {
        if (_hasUserLimit) {
            require(
                _poolLimitPerUser > poolLimitPerUser,
                "New limit must be higher"
            );
            poolLimitPerUser = _poolLimitPerUser;
        } else {
            poolLimitPerUser = 0;
        }
        hasUserLimit = _hasUserLimit;

        emit UpdatePoolLimit(poolLimitPerUser, hasUserLimit);
    }

    /*
     * @notice Update reward per block
     * @dev Only callable by owner.
     * @param _rewardPerBlock: the reward per block
     */
    function updateRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner {
        // require(block.number < startBlock, "Pool was already started");

        rewardPerBlock = _rewardPerBlock;
        emit NewRewardPerBlock(_rewardPerBlock);
    }

    function setServiceInfo(address _buyBackWallet, uint256 _fee) external {
        require(msg.sender == buyBackWallet, "setServiceInfo: FORBIDDEN");
        require(_buyBackWallet != address(0x0), "Invalid address");

        buyBackWallet = _buyBackWallet;
        performanceFee = _fee;

        emit ServiceInfoUpadted(_buyBackWallet, _fee);
    }

    function updateWalletA(address _walletA) external onlyOwner {
        require(_walletA != address(0x0) || _walletA != walletA, "Invalid address");

        walletA = _walletA;
        emit WalletAUpdated(_walletA);
    }

    function setDuration(uint256 _duration) external onlyOwner {
        require(_duration >= 30, "lower limit reached");

        duration = _duration;
        if(startBlock > 0) {
            bonusEndBlock = startBlock + duration * 28800;
            require(bonusEndBlock > block.number, "invalid duration");
        }
        emit DurationUpdated(_duration);
    }

    function setSettings(
        uint256 _depositFee,
        uint256 _withdrawFee,
        uint256 _slippageFactor,
        address _uniRouter,
        address[] memory _earnedToStakedPath,
        address[] memory _reflectionToStakedPath
    ) external onlyOwner {
        require(_depositFee < MAX_FEE, "Invalid deposit fee");
        require(_withdrawFee < MAX_FEE, "Invalid withdraw fee");
        require(_slippageFactor <= slippageFactorUL, "_slippageFactor too high");

        depositFee = _depositFee;
        withdrawFee = _withdrawFee;

        slippageFactor = _slippageFactor;
        uniRouterAddress = _uniRouter;
        reflectionToStakedPath = _reflectionToStakedPath;
        earnedToStakedPath = _earnedToStakedPath;

        emit SetSettings(_depositFee, _withdrawFee, _slippageFactor, _uniRouter, _earnedToStakedPath, _reflectionToStakedPath);
    }

    /************************
    ** Internal Methods
    *************************/
    /*
     * @notice Update reward variables of the given pool to be up-to-date.
     */
    function _updatePool() internal {
        // calc reflection rate
        if(totalStaked > 0 && hasDividend) {
            uint256 reflectionAmount = availableDividendTokens();
            if(reflectionAmount < totalReflections) {
                reflectionAmount = totalReflections;
            }

            uint256 sTokenBal = totalStaked;
            uint256 eTokenBal = availableRewardTokens();
            if(address(stakingToken) == address(earnedToken)) {
                sTokenBal = sTokenBal + eTokenBal;
            }

            accDividendPerShare = accDividendPerShare + (
                    (reflectionAmount - totalReflections) * PRECISION_FACTOR_REFLECTION / sTokenBal
                );

            if(address(stakingToken) == address(earnedToken)) {
                reflections = reflections + (reflectionAmount - totalReflections) * eTokenBal / sTokenBal;
            }
            totalReflections = reflectionAmount;
        }

        if (block.number <= lastRewardBlock || lastRewardBlock == 0) {
            return;
        }

        if (totalStaked == 0) {
            lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
        uint256 _reward = multiplier * rewardPerBlock;
        accTokenPerShare = accTokenPerShare + (
            _reward * PRECISION_FACTOR / totalStaked
        );
        lastRewardBlock = block.number;
        shouldTotalPaid = shouldTotalPaid + _reward;
    }

    function estimateDividendAmount(uint256 amount) internal view returns(uint256) {
        uint256 dTokenBal = availableDividendTokens();
        if(amount > totalReflections) amount = totalReflections;
        if(amount > dTokenBal) amount = dTokenBal;
        return amount;
    }

    /*
     * @notice Return reward multiplier over the given _from to _to block.
     * @param _from: block to start
     * @param _to: block to finish
     */
    function _getMultiplier(uint256 _from, uint256 _to)
        internal
        view
        returns (uint256)
    {
        if (_to <= bonusEndBlock) {
            return _to - _from;
        } else if (_from >= bonusEndBlock) {
            return 0;
        } else {
            return bonusEndBlock - _from;
        }
    }

    function _safeSwap(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal {
        uint256[] memory amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length - 1];

        IERC20(_path[0]).safeApprove(uniRouterAddress, _amountIn);
        IUniRouter02(uniRouterAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amountIn,
            amountOut * slippageFactor / 1000,
            _path,
            _to,
            block.timestamp + 600
        );
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract BrewlabsPairLocker is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool private initialized = false;

    IERC20  public lpToken;
    uint256 public editFee;
    uint256 public defrostFee;
    uint256 public NONCE = 0;
    
    address public treasury;
    address private devWallet;
    uint256 private devRate;

    struct PairLock {
        uint256 lockID; // lockID nonce per uni pair
        uint256 lockDate; // the date the token was locked
        uint256 amount; // the amount of tokens still locked
        uint256 unlockTime; // the date the token can be withdrawn
        address operator;
        uint256 tokenDebt;
        bool isDefrost;
    }
    mapping(uint256 => PairLock) public locks;
    uint256 public totalLocked;

    event NewLock(uint256 lockID, address operator, address token, uint256 amount, uint256 unlockTime);
    event Splitlock(uint256 lockID, uint256 newLockID, address operator, uint256 amount, uint256 unlockTime);
    event AddLock(uint256 lockID, uint256 amount);
    event TransferLock(uint256 lockID, address operator);
    event Relock(uint256 lockID, uint256 unlockTime);
    event DefrostActivated(uint256 lockID);
    event Defrosted(uint256 lockID);
    event Unlocked(uint256 lockID);
    event UpdateTreasury(address addr);

    constructor() {}

    function initialize(address _lpToken, address _treasury, uint256 _editFee, uint256 _defrostFee, address _devWallet, uint256 _devRate, address _owner) external {
        require(!initialized, "already initialized");
        require(owner() == address(0x0) || msg.sender == owner(), "not allowed");

        initialized = true;

        lpToken = IERC20(_lpToken);
        treasury = _treasury;
        editFee = _editFee;
        defrostFee = _defrostFee;

        devWallet = _devWallet;
        devRate = _devRate;

        _transferOwnership(_owner);
    }

    function newLock(address _operator, uint256 _amount, uint256 _unlockTime) external onlyOwner {
        require(_amount > 0, "Invalid amount");
        require(_unlockTime > block.timestamp, "Invalid unlock time");

        uint256 beforeAmt = lpToken.balanceOf(address(this));
        lpToken.transferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = lpToken.balanceOf(address(this));

        NONCE = NONCE.add(1);
        PairLock storage lock = locks[NONCE];
        lock.lockID = NONCE;
        lock.lockDate = block.timestamp;
        lock.amount = afterAmt.sub(beforeAmt);
        lock.tokenDebt = 0;
        lock.unlockTime = _unlockTime;
        lock.operator = _operator;
        lock.isDefrost = false;

        totalLocked = totalLocked.add(lock.amount);

        emit NewLock(lock.lockID,  _operator, address(lpToken), lock.amount, _unlockTime);
    }

    function addLock(uint256 _lockID, uint256 _amount) external payable nonReentrant {
        require(_amount > 0, "Invalid amount");
        
        PairLock storage lock = locks[_lockID];
        require(lock.operator == msg.sender, "not operator");
        require(lock.amount > lock.tokenDebt, "already unlocked");
        require(lock.unlockTime > block.timestamp, "passed unlock time");

        _transferFee(editFee);

        uint256 beforeAmt = lpToken.balanceOf(address(this));
        lpToken.transferFrom(msg.sender, address(this), _amount);
        uint256 amountIn = lpToken.balanceOf(address(this)).sub(beforeAmt);

        lock.amount = lock.amount.add(amountIn);
        totalLocked = totalLocked.add(amountIn);

        emit AddLock(lock.lockID, amountIn);
    }

    function splitLock(uint256 _lockID, address _operator, uint256 _amount, uint256 _unlockTime) external payable nonReentrant {
        require(_amount > 0, "Invalid amount");
        require(_operator != address(0x0), "Invalid address");
        
        PairLock storage lock = locks[_lockID];
        require(lock.operator == msg.sender, "not operator");
        require(lock.amount > lock.tokenDebt, "already unlocked");
        require(lock.unlockTime > block.timestamp, "passed unlock time");
        require(lock.amount.sub(lock.tokenDebt) > _amount, "amount exceed original locked amount");
        require(lock.unlockTime <= _unlockTime, "unlock time should be greater than original");

        _transferFee(editFee);

        lock.amount = lock.amount.sub(_amount);        

        NONCE = NONCE.add(1);

        lock = locks[NONCE];
        lock.lockID = NONCE;
        lock.lockDate = block.timestamp;
        lock.amount = _amount;
        lock.tokenDebt = 0;
        lock.unlockTime = _unlockTime;
        lock.operator = _operator;
        lock.isDefrost = false;

        emit Splitlock(_lockID, lock.lockID, _operator, _amount, _unlockTime);
    }

    function reLock(uint256 _lockID, uint256 _unlockTime) external payable nonReentrant {
        require(_unlockTime > block.timestamp, "Invalid unlock time");
        require(_unlockTime > locks[_lockID].unlockTime, "Relock time should be longer than original");

        PairLock storage lock = locks[_lockID];
        require(lock.operator == msg.sender, "not operator");
        require(lock.amount > lock.tokenDebt, "not enough locked amount");

        _transferFee(editFee);

        lock.lockDate = block.timestamp;
        lock.unlockTime = _unlockTime;
        lock.amount = lock.amount.sub(lock.tokenDebt);
        lock.tokenDebt = 0;
        emit Relock(_lockID, _unlockTime);
    }

    function transferLock(uint256 _lockID, address _operator) external payable {
        PairLock storage lock = locks[_lockID];
        require(lock.operator == msg.sender, "not operator");
        require(lock.amount > lock.tokenDebt, "not enough locked amount");
        require(lock.unlockTime > block.timestamp, "already unlocked");

        require(_operator != address(0x0) && _operator != lock.operator, "Invalid new operator");

        _transferFee(editFee);

        lock.operator = _operator;
        emit TransferLock(_lockID, _operator);
    }

    function claim(uint256 _lockID) external nonReentrant {
        PairLock storage lock = locks[_lockID];
        require(lock.operator == msg.sender, "not operator");
        require(lock.amount > lock.tokenDebt, "already unlocked");
        require(lock.unlockTime < block.timestamp, "cannot unlock");

        lpToken.transfer(lock.operator, lock.amount);

        lock.tokenDebt = lock.amount;
        totalLocked = totalLocked.sub(lock.amount);
        emit Unlocked(_lockID);
    }

    function allowDefrost(uint256 _lockID) external payable {
        PairLock storage lock = locks[_lockID];
        require(lock.operator == msg.sender, "not operator");
        require(lock.amount > lock.tokenDebt, "not enough locked amount");
        require(lock.unlockTime > block.timestamp, "already unlocked");

        _transferFee(defrostFee);

        lock.isDefrost = true;
        emit DefrostActivated(_lockID);
    }

    function defrost(uint256 _lockID) external nonReentrant {
        PairLock storage lock = locks[_lockID];
        require(msg.sender == owner() || msg.sender == lock.operator, "forbidden: only owner or operator");
        require(lock.isDefrost == true, "defrost is not activated");
        require(lock.amount > lock.tokenDebt, "not enough locked amount");
        require(lock.unlockTime > block.timestamp, "already unlocked");

        lpToken.transfer(lock.operator, lock.amount);

        lock.tokenDebt = lock.amount;
        totalLocked = totalLocked.sub(lock.amount);
        emit Defrosted(_lockID);
    }

    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0x0), "invalid treasury");
        
        treasury = _treasury;
        emit UpdateTreasury(_treasury);
    }

    function _transferFee(uint256 fee) internal {
        require(msg.value >= fee, "not enough processing fee");
        if(msg.value > fee) {
            payable(msg.sender).transfer(msg.value.sub(fee));
        }

        uint256 _devFee = fee.mul(devRate).div(10000);
        if(_devFee > 0) {
            payable(devWallet).transfer(_devFee);
        }

        payable(treasury).transfer(fee.sub(_devFee));
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./libs/IUniRouter02.sol";
import "./libs/IWETH.sol";

interface IToken {
     /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);
}

contract BrewlabsLockupV2 is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Whether it is initialized
    bool public isInitialized;
    uint256 public duration = 365; // 365 days

    // Whether a limit is set for users
    bool public hasUserLimit;
    // The pool limit (0 if none)
    uint256 public poolLimitPerUser;


    // The block number when staking starts.
    uint256 public startBlock;
    // The block number when staking ends.
    uint256 public bonusEndBlock;


    // swap router and path, slipPage
    uint256 public slippageFactor = 800; // 20% default slippage tolerance
    uint256 public constant slippageFactorUL = 995;

    address public uniRouterAddress;
    address[] public reflectionToStakedPath;
    address[] public earnedToStakedPath;

    address public walletA;
    address public buyBackWallet = 0x408c4aDa67aE1244dfeC7D609dea3c232843189A;
    uint256 public performanceFee = 0.0035 ether;

    // The precision factor
    uint256 public PRECISION_FACTOR;
    uint256 public PRECISION_FACTOR_REFLECTION;

    // The staked token
    IERC20 public stakingToken;
    // The earned token
    IERC20 public earnedToken;
    // The dividend token of staking token
    address public dividendToken;

    // Accrued token per share
    uint256 public accDividendPerShare;

    uint256 public totalStaked;

    uint256 private totalEarned;
    uint256 private totalReflections;
    uint256 private reflections;

    uint256 private paidRewards;
    uint256 private shouldTotalPaid;

    struct Lockup {
        uint256 duration;
        uint256 depositFee;
        uint256 withdrawFee;
        uint256 rate;
        uint256 accTokenPerShare;
        uint256 lastRewardBlock;
        uint256 totalStaked;
    }

    struct UserInfo {
        uint256 amount;         // total staked amount
        uint256 firstIndex;     // first index for unlocked elements
        uint256 reflectionDebt; // Reflection debt
    }

    struct Stake {
        uint256 amount;     // amount to stake
        uint256 duration;   // the lockup duration of the stake
        uint256 end;        // when does the staking period end
        uint256 rewardDebt; // Reward debt
    }
    uint256 constant MAX_STAKES = 256;
    uint256 private processingLimit = 30;

    Lockup public lockupInfo;
    mapping(address => Stake[]) public userStakes;
    mapping(address => UserInfo) public userStaked;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event AdminTokenRecovered(address tokenRecovered, uint256 amount);

    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);
    event LockupUpdated(uint256 _duration, uint256 _fee0, uint256 _fee1, uint256 _rate);
    event RewardsStop(uint256 blockNumber);
    event EndBlockUpdated(uint256 blockNumber);
    event UpdatePoolLimit(uint256 poolLimitPerUser, bool hasLimit);

    event ServiceInfoUpadted(address _addr, uint256 _fee);
    event WalletAUpdated(address _addr);
    event DurationUpdated(uint256 _duration);

    event SetSettings(
        uint256 _slippageFactor,
        address _uniRouter,
        address[] _path0,
        address[] _path1
    );

    constructor() {}

    /*
     * @notice Initialize the contract
     * @param _stakingToken: staked token address
     * @param _earnedToken: earned token address
     * @param _dividendToken: reflection token address
     * @param _uniRouter: uniswap router address for swap tokens
     * @param _earnedToStakedPath: swap path to compound (earned -> staking path)
     * @param _reflectionToStakedPath: swap path to compound (reflection -> staking path)
     */
    function initialize(
        IERC20 _stakingToken,
        IERC20 _earnedToken,
        address _dividendToken,
        uint256 _rewardPerBlock,
        uint256 _depositFee,
        uint256 _withdrawFee,
        uint256 _lockDuration,
        address _uniRouter,
        address[] memory _earnedToStakedPath,
        address[] memory _reflectionToStakedPath
    ) external onlyOwner {
        require(!isInitialized, "Already initialized");

        // Make this contract initialized
        isInitialized = true;

        stakingToken = _stakingToken;
        earnedToken = _earnedToken;
        dividendToken = _dividendToken;

        walletA = msg.sender;

        uint256 decimalsRewardToken = uint256(IToken(address(earnedToken)).decimals());
        require(decimalsRewardToken < 30, "Must be inferior to 30");
        PRECISION_FACTOR = uint256(10**(40 - decimalsRewardToken));

        uint256 decimalsdividendToken = 18;
        if(address(dividendToken) != address(0x0)) {
            decimalsdividendToken = uint256(IToken(address(dividendToken)).decimals());
            require(decimalsdividendToken < 30, "Must be inferior to 30");
        }
        PRECISION_FACTOR_REFLECTION = uint256(10**(40 - decimalsdividendToken));

        uniRouterAddress = _uniRouter;
        earnedToStakedPath = _earnedToStakedPath;
        reflectionToStakedPath = _reflectionToStakedPath;

        lockupInfo.duration = _lockDuration;
        lockupInfo.depositFee = _depositFee;
        lockupInfo.withdrawFee = _withdrawFee;
        lockupInfo.rate = _rewardPerBlock;
        lockupInfo.accTokenPerShare = 0;
        lockupInfo.lastRewardBlock = 0;
        lockupInfo.totalStaked = 0;
    }

    /*
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @param _amount: amount to withdraw (in earnedToken)
     */
    function deposit(uint256 _amount) external payable nonReentrant {
        require(startBlock > 0 && startBlock < block.number, "Staking hasn't started yet");
        require(_amount > 0, "Amount should be greator than 0");

        _transferPerformanceFee();
        _updatePool();

        UserInfo storage user = userStaked[msg.sender];        
        uint256 pendingReflection = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - user.reflectionDebt;
        pendingReflection = estimateDividendAmount(pendingReflection);
        if (pendingReflection > 0) {
            if(address(dividendToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingReflection);
            } else {
                IERC20(dividendToken).safeTransfer(address(msg.sender), pendingReflection);
            }
            totalReflections = totalReflections - pendingReflection;
        }

        uint256 beforeAmount = stakingToken.balanceOf(address(this));
        stakingToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        uint256 afterAmount = stakingToken.balanceOf(address(this));        
        uint256 realAmount = afterAmount - beforeAmount;

        if (hasUserLimit) {
            require(
                realAmount + user.amount <= poolLimitPerUser,
                "User amount above limit"
            );
        }
        if (lockupInfo.depositFee > 0) {
            uint256 fee = realAmount * lockupInfo.depositFee / 10000;
            if (fee > 0) {
                stakingToken.safeTransfer(walletA, fee);
                realAmount = realAmount - fee;
            }
        }
        
        _addStake(msg.sender, lockupInfo.duration, realAmount, user.firstIndex);

        user.amount = user.amount + realAmount;
        user.reflectionDebt = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;

        lockupInfo.totalStaked = lockupInfo.totalStaked + realAmount;
        totalStaked = totalStaked + realAmount;

        emit Deposit(msg.sender, realAmount);
    }

    function _addStake(address _account, uint256 _duration, uint256 _amount, uint256 firstIndex) internal {
        Stake[] storage stakes = userStakes[_account];

        uint256 end = block.timestamp + _duration * 1 days;
        uint256 i = stakes.length;
        require(i < MAX_STAKES, "Max stakes");

        stakes.push(); // grow the array
        // find the spot where we can insert the current stake
        // this should make an increasing list sorted by end
        while (i != 0 && stakes[i - 1].end > end && i >= firstIndex) {
            // shift it back one
            stakes[i] = stakes[i - 1];
            i -= 1;
        }
        
        // insert the stake
        Stake storage newStake = stakes[i];
        newStake.duration = _duration;
        newStake.end = end;
        newStake.amount = _amount;
        newStake.rewardDebt = newStake.amount * lockupInfo.accTokenPerShare / PRECISION_FACTOR;
    }

    /*
     * @notice Withdraw staked tokens and collect reward tokens
     * @param _amount: amount to withdraw (in earnedToken)
     */
    function withdraw(uint256 _amount) external payable nonReentrant {
        require(_amount > 0, "Amount should be greator than 0");

        _transferPerformanceFee();
        _updatePool();

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        
        bool bUpdatable = true;
        uint256 firstIndex = user.firstIndex;

        uint256 pending = 0;
        uint256 pendingCompound = 0;
        uint256 compounded = 0;
        uint256 remained = _amount;
        for(uint256 j = user.firstIndex; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(bUpdatable && stake.amount == 0) firstIndex = j;
            if(stake.amount == 0) continue;
            if(remained == 0) break;

            if(j - user.firstIndex > processingLimit) break;

            uint256 _pending = stake.amount * lockupInfo.accTokenPerShare / PRECISION_FACTOR - stake.rewardDebt;
            if(stake.end > block.timestamp) {
                pendingCompound = pendingCompound + _pending;

                if(address(stakingToken) != address(earnedToken) && _pending > 0) {
                    uint256 _beforeAmount = stakingToken.balanceOf(address(this));
                    _safeSwap(_pending, earnedToStakedPath, address(this));
                    uint256 _afterAmount = stakingToken.balanceOf(address(this));
                    _pending = _afterAmount - _beforeAmount;
                }
                compounded = compounded + _pending;
                stake.amount = stake.amount + _pending;
            } else {
                pending = pending + _pending;
                if(stake.amount > remained) {
                    stake.amount = stake.amount - remained;
                    remained = 0;
                } else {
                    remained = remained - stake.amount;
                    stake.amount = 0;

                    if(bUpdatable) firstIndex = j;
                }
            }
            stake.rewardDebt = stake.amount * lockupInfo.accTokenPerShare / PRECISION_FACTOR;

            if(stake.amount > 0) bUpdatable = false;
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            earnedToken.safeTransfer(address(msg.sender), pending);
            
            if(totalEarned > pending) {
                totalEarned = totalEarned - pending;
            } else {
                totalEarned = 0;
            }
            paidRewards = paidRewards + pending;
        }

        if (pendingCompound > 0) {
            require(availableRewardTokens() >= pendingCompound, "Insufficient reward tokens");
            
            if(totalEarned > pendingCompound) {
                totalEarned = totalEarned - pendingCompound;
            } else {
                totalEarned = 0;
            }
            
            emit Deposit(msg.sender, compounded);
        }
        
        uint256 pendingReflection = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - user.reflectionDebt;
        pendingReflection = estimateDividendAmount(pendingReflection);
        if (pendingReflection > 0) {
            if(address(dividendToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingReflection);
            } else {
                IERC20(dividendToken).safeTransfer(address(msg.sender), pendingReflection);
            }
            totalReflections = totalReflections - pendingReflection;
        }

        uint256 realAmount = _amount - remained;
        user.firstIndex = firstIndex;
        user.amount = user.amount - realAmount + compounded;
        user.reflectionDebt = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;

        lockupInfo.totalStaked = lockupInfo.totalStaked - realAmount + compounded;
        totalStaked = totalStaked - realAmount + compounded;

        if(realAmount > 0) {
            if (lockupInfo.withdrawFee > 0) {
                uint256 fee = realAmount * lockupInfo.withdrawFee / 10000;
                stakingToken.safeTransfer(walletA, fee);
                realAmount = realAmount - fee;
            }

            stakingToken.safeTransfer(address(msg.sender), realAmount);
        }

        emit Withdraw(msg.sender, realAmount);
    }

    function claimReward() external payable nonReentrant {
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool();

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];

        uint256 pending = 0;
        uint256 pendingCompound = 0;
        uint256 compounded = 0;
        for(uint256 j = user.firstIndex; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.amount == 0) continue;
            if(j - user.firstIndex > processingLimit) break;

            uint256 _pending = stake.amount * lockupInfo.accTokenPerShare / PRECISION_FACTOR - stake.rewardDebt;

            if(stake.end > block.timestamp) {
                pendingCompound = pendingCompound + _pending;

                if(address(stakingToken) != address(earnedToken) && _pending > 0) {
                    uint256 _beforeAmount = stakingToken.balanceOf(address(this));
                    _safeSwap(_pending, earnedToStakedPath, address(this));
                    uint256 _afterAmount = stakingToken.balanceOf(address(this));
                    _pending = _afterAmount - _beforeAmount;
                }
                compounded = compounded + _pending;
                stake.amount = stake.amount + _pending;
            } else {
                pending = pending + _pending;
            }
            stake.rewardDebt = stake.amount * lockupInfo.accTokenPerShare / PRECISION_FACTOR;
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            earnedToken.safeTransfer(address(msg.sender), pending);
            
            if(totalEarned > pending) {
                totalEarned = totalEarned - pending;
            } else {
                totalEarned = 0;
            }
            paidRewards = paidRewards + pending;
        }

        if (pendingCompound > 0) {
            require(availableRewardTokens() >= pendingCompound, "Insufficient reward tokens");
            
            if(totalEarned > pendingCompound) {
                totalEarned = totalEarned - pendingCompound;
            } else {
                totalEarned = 0;
            }

            user.amount = user.amount + compounded;
            user.reflectionDebt = user.reflectionDebt + compounded * accDividendPerShare / PRECISION_FACTOR_REFLECTION;

            lockupInfo.totalStaked = lockupInfo.totalStaked + compounded;
            totalStaked = totalStaked + compounded;

            emit Deposit(msg.sender, compounded);
        }
    }

    function claimDividend() external payable nonReentrant {
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool();

        UserInfo storage user = userStaked[msg.sender];
        if (user.amount == 0) return;

        uint256 pendingReflection = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - user.reflectionDebt;
        pendingReflection = estimateDividendAmount(pendingReflection);
        if (pendingReflection > 0) {
            if(address(dividendToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingReflection);
            } else {
                IERC20(dividendToken).safeTransfer(address(msg.sender), pendingReflection);
            }
            totalReflections = totalReflections - pendingReflection;
        }
        user.reflectionDebt = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
    }

    function compoundReward() external payable nonReentrant {
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool();

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];

        uint256 pending = 0;
        uint256 compounded = 0;
        for(uint256 j = user.firstIndex; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.amount == 0) continue;
            if(j - user.firstIndex > processingLimit) break;

            uint256 _pending = stake.amount * lockupInfo.accTokenPerShare / PRECISION_FACTOR - stake.rewardDebt;
            pending = pending + _pending;

            if(address(stakingToken) != address(earnedToken) && _pending > 0) {
                uint256 _beforeAmount = stakingToken.balanceOf(address(this));
                _safeSwap(_pending, earnedToStakedPath, address(this));
                uint256 _afterAmount = stakingToken.balanceOf(address(this));
                _pending = _afterAmount - _beforeAmount;
            }
            compounded = compounded + _pending;

            stake.amount = stake.amount + _pending;
            stake.rewardDebt = stake.amount * lockupInfo.accTokenPerShare / PRECISION_FACTOR;
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            
            if(totalEarned > pending) {
                totalEarned = totalEarned - pending;
            } else {
                totalEarned = 0;
            }
            paidRewards = paidRewards + pending;

            user.amount = user.amount + compounded;
            user.reflectionDebt = user.reflectionDebt + compounded * accDividendPerShare / PRECISION_FACTOR_REFLECTION;

            lockupInfo.totalStaked = lockupInfo.totalStaked + compounded;
            totalStaked = totalStaked + compounded;

            emit Deposit(msg.sender, compounded);
        }
    }

    function compoundDividend() external payable nonReentrant {
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool();

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];

        uint256 pending = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - user.reflectionDebt;
        pending = estimateDividendAmount(pending);
        totalReflections = totalReflections - pending;
        if(address(stakingToken) != address(dividendToken) && pending > 0) {
            if(address(dividendToken) == address(0x0)) {
                address wethAddress = IUniRouter02(uniRouterAddress).WETH();
                IWETH(wethAddress).deposit{ value: pending }();
            }

            uint256 _beforeAmount = stakingToken.balanceOf(address(this));
            _safeSwap(pending, reflectionToStakedPath, address(this));
            uint256 _afterAmount = stakingToken.balanceOf(address(this));
            pending = _afterAmount - _beforeAmount;
        }

        if(pending > 0) {            
            Stake storage stake = stakes[user.firstIndex];
            stake.amount = stake.amount + pending;
            stake.rewardDebt = stake.rewardDebt + pending * lockupInfo.accTokenPerShare / PRECISION_FACTOR;
        
            user.amount = user.amount + pending;
            user.reflectionDebt = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;

            lockupInfo.totalStaked = lockupInfo.totalStaked + pending;
            totalStaked = totalStaked + pending;

            emit Deposit(msg.sender, pending);
        }
    }

    function _transferPerformanceFee() internal {
        require(msg.value >= performanceFee, 'should pay small gas to compound or harvest');

        payable(buyBackWallet).transfer(performanceFee);
        if(msg.value > performanceFee) {
            payable(msg.sender).transfer(msg.value - performanceFee);
        }
    }

    /*
     * @notice Withdraw staked tokens without caring about rewards
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external nonReentrant {
        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];

        uint256 firstIndex = user.firstIndex;
        uint256 amountToTransfer = 0;
        for(uint256 j = user.firstIndex; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.amount == 0) {
                firstIndex = j;
                continue;
            }
            if(j - user.firstIndex > processingLimit) break;

            amountToTransfer = amountToTransfer + stake.amount;

            stake.amount = 0;
            stake.rewardDebt = 0;
            
            firstIndex = j;
        }

        if (amountToTransfer > 0) {
            stakingToken.safeTransfer(address(msg.sender), amountToTransfer);

            user.firstIndex = firstIndex;
            user.amount = user.amount - amountToTransfer;
            user.reflectionDebt = user.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;

            lockupInfo.totalStaked = lockupInfo.totalStaked - amountToTransfer;
            totalStaked = totalStaked - amountToTransfer;
        }

        emit EmergencyWithdraw(msg.sender, amountToTransfer);
    }

    function rewardPerBlock() external view returns (uint256) {
        return lockupInfo.rate;
    }

    /**
     * @notice Available amount of reward token
     */
    function availableRewardTokens() public view returns (uint256) {
        if(address(earnedToken) == address(dividendToken)) return totalEarned;

        uint256 _amount = earnedToken.balanceOf(address(this));
        if (address(earnedToken) == address(stakingToken)) {
            if (_amount < totalStaked) return 0;
            return _amount - totalStaked;
        }

        return _amount;
    }

    /**
     * @notice Available amount of reflection token
     */
    function availableDividendTokens() public view returns (uint256) {
        if(address(dividendToken) == address(0x0)) {
            return address(this).balance;
        }

        uint256 _amount = IERC20(dividendToken).balanceOf(address(this));
        
        if(address(dividendToken) == address(earnedToken)) {
            if(_amount < totalEarned) return 0;
            _amount = _amount - totalEarned;
        }

        if(address(dividendToken) == address(stakingToken)) {
            if(_amount < totalStaked) return 0;
            _amount = _amount - totalStaked;
        }

        return _amount;
    }

    function insufficientRewards() external view returns (uint256) {
        uint256 adjustedShouldTotalPaid = shouldTotalPaid;
        uint256 remainRewards = availableRewardTokens() + paidRewards;

        if(startBlock == 0) {
            adjustedShouldTotalPaid = adjustedShouldTotalPaid + lockupInfo.rate * duration * 28800;
        } else {
            uint256 remainBlocks = _getMultiplier(lockupInfo.lastRewardBlock, bonusEndBlock);
            adjustedShouldTotalPaid = adjustedShouldTotalPaid + lockupInfo.rate * remainBlocks;
        }

        if(remainRewards >= adjustedShouldTotalPaid) return 0;

        return adjustedShouldTotalPaid - remainRewards;
    }

    function userInfo(address _account) external view returns (uint256 amount, uint256 available, uint256 locked) {
        UserInfo memory user = userStaked[msg.sender];
        Stake[] memory stakes = userStakes[_account];
        
        for(uint256 i = user.firstIndex; i < stakes.length; i++) {
            Stake memory stake = stakes[i];
            if(stake.amount == 0) continue;
            
            amount = amount + stake.amount;
            if(block.timestamp > stake.end) {
                available = available + stake.amount;
            } else {
                locked = locked + stake.amount;
            }
        }
    }

    /*
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @return Pending reward for a given user
     */
    function pendingReward(address _account) external view returns (uint256) {
        if(startBlock == 0) return 0;

        UserInfo memory user = userStaked[_account];
        Stake[] memory stakes = userStakes[_account];

        if(lockupInfo.totalStaked == 0) return 0;
        
        uint256 adjustedTokenPerShare = lockupInfo.accTokenPerShare;
        if (block.number > lockupInfo.lastRewardBlock && lockupInfo.totalStaked != 0 && lockupInfo.lastRewardBlock > 0) {
            uint256 multiplier = _getMultiplier(lockupInfo.lastRewardBlock, block.number);
            uint256 reward = multiplier * lockupInfo.rate;
            adjustedTokenPerShare =
                lockupInfo.accTokenPerShare + (
                    reward * PRECISION_FACTOR / lockupInfo.totalStaked
                );
        }

        uint256 pending = 0;
        for(uint256 i = user.firstIndex; i < stakes.length; i++) {
            Stake memory stake = stakes[i];
            if(stake.amount == 0) continue;

            pending = pending + (
                stake.amount * adjustedTokenPerShare / PRECISION_FACTOR - stake.rewardDebt
            );
        }
        return pending;
    }

    function pendingDividends(address _account) external view returns (uint256) {
        if(startBlock == 0 || totalStaked == 0) return 0;
        
        UserInfo memory user = userStaked[_account];
        if(user.amount == 0) return 0;

        uint256 reflectionAmount = availableDividendTokens();
        if(reflectionAmount < totalReflections) {
            reflectionAmount = totalReflections;
        }

        uint256 sTokenBal = totalStaked;
        uint256 eTokenBal = availableRewardTokens();
        if(address(stakingToken) == address(earnedToken)) {
            sTokenBal = sTokenBal + eTokenBal;
        }

        uint256 adjustedReflectionPerShare = accDividendPerShare + (
                (reflectionAmount - totalReflections) * PRECISION_FACTOR_REFLECTION / sTokenBal
            );
        
        uint256 pendingReflection = user.amount * adjustedReflectionPerShare / PRECISION_FACTOR_REFLECTION - user.reflectionDebt;
        return pendingReflection;
    }

    /************************
    ** Admin Methods
    *************************/
    function harvest() external onlyOwner {
        _updatePool();

        reflections = estimateDividendAmount(reflections);
        if(reflections > 0) {            
            if(address(dividendToken) == address(0x0)) {
                payable(walletA).transfer(reflections);
            } else {
                IERC20(dividendToken).safeTransfer(walletA, reflections);
            }

            totalReflections = totalReflections - reflections;
            reflections = 0;
        }
    }

    /*
     * @notice Deposit reward token
     * @dev Only call by owner. Needs to be for deposit of reward token when reflection token is same with reward token.
     */
    function depositRewards(uint _amount) external onlyOwner nonReentrant {
        require(_amount > 0, "invalid amount");

        uint256 beforeAmt = earnedToken.balanceOf(address(this));
        earnedToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = earnedToken.balanceOf(address(this));

        totalEarned = totalEarned + afterAmt - beforeAmt;
    }

    function increaseEmissionRate(uint256 _amount) external onlyOwner {
        require(startBlock > 0, "pool is not started");
        require(bonusEndBlock > block.number, "pool was already finished");
        require(_amount > 0, "invalid amount");
        
        _updatePool();

        uint256 beforeAmt = earnedToken.balanceOf(address(this));
        earnedToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = earnedToken.balanceOf(address(this));

        totalEarned = totalEarned + afterAmt - beforeAmt;

        uint256 remainRewards = availableRewardTokens() + paidRewards;
        if(remainRewards > shouldTotalPaid) {
            remainRewards = remainRewards - shouldTotalPaid;

            uint256 remainBlocks = bonusEndBlock - block.number;
            lockupInfo.rate = remainRewards / remainBlocks;
            emit LockupUpdated(lockupInfo.duration, lockupInfo.depositFee, lockupInfo.withdrawFee, lockupInfo.rate);
        }
    }

    /*
     * @notice Withdraw reward token
     * @dev Only callable by owner. Needs to be for emergency.
     */
    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
        require( block.number > bonusEndBlock, "Pool is running");
        require(availableRewardTokens() >= _amount, "Insufficient reward tokens");

        earnedToken.safeTransfer(address(msg.sender), _amount);
        
        if (totalEarned > 0) {
            if (_amount > totalEarned) {
                totalEarned = 0;
            } else {
                totalEarned = totalEarned - _amount;
            }
        }
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of tokens to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(
            _tokenAddress != address(earnedToken),
            "Cannot be reward token"
        );

        if(_tokenAddress == address(stakingToken)) {
            uint256 tokenBal = stakingToken.balanceOf(address(this));
            require(_tokenAmount <= tokenBal - totalStaked, "Insufficient balance");
        }

        if(_tokenAddress == address(0x0)) {
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
        }

        emit AdminTokenRecovered(_tokenAddress, _tokenAmount);
    }

    function startReward() external onlyOwner {
        require(startBlock == 0, "Pool was already started");

        startBlock = block.number + 100;
        bonusEndBlock = startBlock + duration * 28800;
        lockupInfo.lastRewardBlock = startBlock;
        
        emit NewStartAndEndBlocks(startBlock, bonusEndBlock);
    }

    function stopReward() external onlyOwner {
        _updatePool();

        uint256 remainRewards = availableRewardTokens() + paidRewards;
        if(remainRewards > shouldTotalPaid) {
            remainRewards = remainRewards - shouldTotalPaid;
            earnedToken.transfer(msg.sender, remainRewards);

            if(totalEarned > remainRewards) {
                totalEarned = totalEarned - remainRewards;
            } else {
                totalEarned = 0;
            }
        }

        bonusEndBlock = block.number;
        emit RewardsStop(bonusEndBlock);
    }

    function updateEndBlock(uint256 _endBlock) external onlyOwner {
        require(startBlock > 0, "Pool is not started");
        require(bonusEndBlock > block.number, "Pool was already finished");
        require(_endBlock > block.number && _endBlock > startBlock, "Invalid end block");
        bonusEndBlock = _endBlock;
        emit EndBlockUpdated(_endBlock);
    }

    /*
     * @notice Update pool limit per user
     * @dev Only callable by owner.
     * @param _hasUserLimit: whether the limit remains forced
     * @param _poolLimitPerUser: new pool limit per user
     */
    function updatePoolLimitPerUser( bool _hasUserLimit, uint256 _poolLimitPerUser) external onlyOwner {
        if (_hasUserLimit) {
            require(
                _poolLimitPerUser > poolLimitPerUser,
                "New limit must be higher"
            );
            poolLimitPerUser = _poolLimitPerUser;
        } else {
            poolLimitPerUser = 0;
        }
        hasUserLimit = _hasUserLimit;

        emit UpdatePoolLimit(poolLimitPerUser, hasUserLimit);
    }

    function updateLockup(uint256 _duration, uint256 _depositFee, uint256 _withdrawFee, uint256 _rate) external onlyOwner {
        // require(block.number < startBlock, "Pool was already started");
        require(_depositFee < 2000, "Invalid deposit fee");
        require(_withdrawFee < 2000, "Invalid withdraw fee");

        _updatePool();

        lockupInfo.duration = _duration;
        lockupInfo.depositFee = _depositFee;
        lockupInfo.withdrawFee = _withdrawFee;
        lockupInfo.rate = _rate;
        
        emit LockupUpdated(_duration, _depositFee, _withdrawFee, _rate);
    }

    function setServiceInfo(address _addr, uint256 _fee) external {
        require(msg.sender == buyBackWallet, "setServiceInfo: FORBIDDEN");
        require(_addr != address(0x0), "Invalid address");

        buyBackWallet = _addr;
        performanceFee = _fee;

        emit ServiceInfoUpadted(_addr, _fee);
    }
    
    function setDuration(uint256 _duration) external onlyOwner {
        require(startBlock == 0, "Pool was already started");

        duration = _duration;
        emit DurationUpdated(_duration);
    }
    
    function setProcessingLimit(uint256 _limit) external onlyOwner {
        require(_limit > 0, "Invalid limit");
        processingLimit = _limit;
    }

    function setSettings(
        uint256 _slippageFactor, 
        address _uniRouter, 
        address[] memory _earnedToStakedPath, 
        address[] memory _reflectionToStakedPath
    ) external onlyOwner {
        require(_slippageFactor <= slippageFactorUL, "_slippageFactor too high");

        slippageFactor = _slippageFactor;
        uniRouterAddress = _uniRouter;
        reflectionToStakedPath = _reflectionToStakedPath;
        earnedToStakedPath = _earnedToStakedPath;

        emit SetSettings(_slippageFactor, _uniRouter, _earnedToStakedPath, _reflectionToStakedPath);
    }
    
    function updateWalletA(address _walletA) external onlyOwner {
        require(_walletA != address(0x0) || _walletA != walletA, "Invalid address");

        walletA = _walletA;
        emit WalletAUpdated(_walletA);
    }

    /************************
    ** Internal Methods
    *************************/
    /*
     * @notice Update reward variables of the given pool to be up-to-date.
     */
    function _updatePool() internal {
        // calc reflection rate
        if(totalStaked > 0) {
            uint256 reflectionAmount = availableDividendTokens();
            if(reflectionAmount < totalReflections) {
                reflectionAmount = totalReflections;
            }

            uint256 sTokenBal = totalStaked;
            uint256 eTokenBal = availableRewardTokens();
            if(address(stakingToken) == address(earnedToken)) {
                sTokenBal = sTokenBal + eTokenBal;
            }

            accDividendPerShare = accDividendPerShare + (
                    (reflectionAmount - totalReflections) * PRECISION_FACTOR_REFLECTION / sTokenBal
                );

            if(address(stakingToken) == address(earnedToken)) {
                reflections = reflections + (reflectionAmount - totalReflections) * eTokenBal / sTokenBal;
            }
            totalReflections = reflectionAmount;
        }

        if (block.number <= lockupInfo.lastRewardBlock || lockupInfo.lastRewardBlock == 0) return;

        if (lockupInfo.totalStaked == 0) {
            lockupInfo.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = _getMultiplier(lockupInfo.lastRewardBlock, block.number);
        uint256 _reward = multiplier * lockupInfo.rate;
        lockupInfo.accTokenPerShare = lockupInfo.accTokenPerShare + (
            _reward * PRECISION_FACTOR / lockupInfo.totalStaked
        );
        lockupInfo.lastRewardBlock = block.number;
        shouldTotalPaid = shouldTotalPaid + _reward;
    }

    function estimateDividendAmount(uint256 amount) internal view returns(uint256) {
        uint256 dTokenBal = availableDividendTokens();
        if(amount > totalReflections) amount = totalReflections;
        if(amount > dTokenBal) amount = dTokenBal;
        return amount;
    }

    /*
     * @notice Return reward multiplier over the given _from to _to block.
     * @param _from: block to start
     * @param _to: block to finish
     */
    function _getMultiplier(uint256 _from, uint256 _to)
        internal
        view
        returns (uint256)
    {
        if (_to <= bonusEndBlock) {
            return _to - _from;
        } else if (_from >= bonusEndBlock) {
            return 0;
        } else {
            return bonusEndBlock - _from;
        }
    }

    function _safeSwap(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal {
        uint256[] memory amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length - 1];
        
        IERC20(_path[0]).safeApprove(uniRouterAddress, _amountIn);
        IUniRouter02(uniRouterAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amountIn,
            amountOut * slippageFactor / 1000,
            _path,
            _to,
            block.timestamp + 600
        );
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./libs/IUniRouter02.sol";
import "./libs/IWETH.sol";
interface IToken {
    function decimals() external view returns (uint8);
}

contract BrewlabsLockupMulti is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Whether it is initialized
    bool public isInitialized;
    uint256 public duration = 365; // 365 days

    // Whether a limit is set for users
    bool public hasUserLimit;
    // The pool limit (0 if none)
    uint256 public poolLimitPerUser;


    // The block number when staking starts.
    uint256 public startBlock;
    // The block number when staking ends.
    uint256 public bonusEndBlock;


    // swap router and path, slipPage
    uint256 public slippageFactor = 800; // 20% default slippage tolerance
    uint256 public constant slippageFactorUL = 995;

    address public uniRouterAddress;
    address[] public reflectionToStakedPath;
    address[] public earnedToStakedPath;

    address public walletA;
    address public buyBackWallet = 0x408c4aDa67aE1244dfeC7D609dea3c232843189A;
    uint256 public performanceFee = 0.0035 ether;

    // The precision factor
    uint256 public PRECISION_FACTOR;
    uint256[] public PRECISION_FACTOR_REFLECTION;

    // The staked token
    IERC20 public stakingToken;
    // The earned token
    IERC20 public earnedToken;
    // The dividend token of staking token
    address[] public dividendTokens;

    // Accrued token per share
    uint256[] public accDividendPerShare;

    uint256 public totalStaked;

    uint256 private totalEarned;
    uint256[] private totalReflections;
    uint256[] private reflections;

    struct Lockup {
        uint256 duration;
        uint256 depositFee;
        uint256 withdrawFee;
        uint256 rate;
        uint256 accTokenPerShare;
        uint256 lastRewardBlock;
        uint256 totalStaked;
    }

    struct UserInfo {
        uint256 amount;             // total locked amount
        uint256 firstIndex;         // first index for unlocked elements
        uint256[] reflectionDebt;   // Reflection debt
    }

    struct Stake {
        uint256 amount;     // amount to stake
        uint256 duration;   // the lockup duration of the stake
        uint256 end;        // when does the staking period end
        uint256 rewardDebt; // Reward debt
    }
    uint256 constant MAX_STAKES = 256;
    uint256 private processingLimit = 30;

    Lockup public lockupInfo;
    mapping(address => Stake[]) public userStakes;
    mapping(address => UserInfo) public userStaked;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event AdminTokenRecovered(address tokenRecovered, uint256 amount);

    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);
    event LockupUpdated(uint256 _duration, uint256 _fee0, uint256 _fee1, uint256 _rate);
    event RewardsStop(uint256 blockNumber);
    event EndBlockUpdated(uint256 blockNumber);
    event UpdatePoolLimit(uint256 poolLimitPerUser, bool hasLimit);

    event ServiceInfoUpadted(address _addr, uint256 _fee);
    event WalletAUpdated(address _addr);
    event DurationUpdated(uint256 _duration);

    event SetSettings(
        uint256 _slippageFactor,
        address _uniRouter,
        address[] _path0
    );

    constructor() {}

    /*
     * @notice Initialize the contract
     * @param _stakingToken: staked token address
     * @param _earnedToken: earned token address
     * @param _dividendToken: reflection token address
     * @param _uniRouter: uniswap router address for swap tokens
     * @param _earnedToStakedPath: swap path to compound (earned -> staking path)
     */
    function initialize(
        IERC20 _stakingToken,
        IERC20 _earnedToken,
        address[] memory _dividendTokens,
        uint256 _rewardPerBlock,
        uint256 _depositFee,
        uint256 _withdrawFee,
        uint256 _duration,
        address _uniRouter,
        address[] memory _earnedToStakedPath
    ) external onlyOwner {
        require(!isInitialized, "Already initialized");

        // Make this contract initialized
        isInitialized = true;

        stakingToken = _stakingToken;
        earnedToken = _earnedToken;

        walletA = msg.sender;

        uint256 decimalsRewardToken = uint256(IToken(address(earnedToken)).decimals());
        require(decimalsRewardToken < 30, "Must be inferior to 30");
        PRECISION_FACTOR = uint256(10**(40 - decimalsRewardToken));

        for(uint i = 0; i < _dividendTokens.length; i++) {
            dividendTokens.push(_dividendTokens[i]);
            totalReflections.push(0);
            accDividendPerShare.push(0);
            reflections.push(0);

            uint256 decimalsdividendToken = 18;
            if(address(dividendTokens[i]) != address(0x0)) {
                decimalsdividendToken = uint256(IToken(address(dividendTokens[i])).decimals());
                require(decimalsdividendToken < 30, "Must be inferior to 30");
            }
            PRECISION_FACTOR_REFLECTION.push(uint256(10**(40 - decimalsdividendToken)));
        }


        uniRouterAddress = _uniRouter;
        earnedToStakedPath = _earnedToStakedPath;

        lockupInfo.duration = _duration;
        lockupInfo.depositFee = _depositFee;
        lockupInfo.withdrawFee = _withdrawFee;
        lockupInfo.rate = _rewardPerBlock;
        lockupInfo.accTokenPerShare = 0;
        lockupInfo.lastRewardBlock = 0;
        lockupInfo.totalStaked = 0;
    }

    /*
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @param _amount: amount to withdraw (in earnedToken)
     */
    function deposit(uint256 _amount) external payable nonReentrant {
        require(startBlock > 0 && startBlock < block.number, "Staking hasn't started yet");
        require(_amount > 0, "Amount should be greator than 0");

        _transferPerformanceFee();
        _updatePool();

        UserInfo storage user = userStaked[msg.sender];
        if(user.amount > 0) {
            for(uint256 i = 0; i < dividendTokens.length; i++) {
                uint256 pendingReflection = 
                    user.amount * accDividendPerShare[i] / PRECISION_FACTOR_REFLECTION[i] - user.reflectionDebt[i];
                
                pendingReflection = estimateDividendAmount(i, pendingReflection);
                if (pendingReflection > 0) {
                    if(address(dividendTokens[i]) == address(0x0)) {
                        payable(msg.sender).transfer(pendingReflection);
                    } else {
                        IERC20(dividendTokens[i]).safeTransfer(address(msg.sender), pendingReflection);
                    }
                    totalReflections[i] = totalReflections[i] - pendingReflection;
                }
            }
        }

        uint256 beforeAmount = stakingToken.balanceOf(address(this));
        stakingToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        uint256 afterAmount = stakingToken.balanceOf(address(this));
        uint256 realAmount = afterAmount - beforeAmount;

        if (hasUserLimit) {
            require(
                realAmount + user.amount <= poolLimitPerUser,
                "User amount above limit"
            );
        }
        if (lockupInfo.depositFee > 0) {
            uint256 fee = realAmount * lockupInfo.depositFee / 10000;
            if (fee > 0) {
                stakingToken.safeTransfer(walletA, fee);
                realAmount = realAmount - fee;
            }
        }
        
        _addStake(msg.sender, lockupInfo.duration, realAmount, user.firstIndex);

        user.amount = user.amount + realAmount;
        if(user.reflectionDebt.length == 0) {
            for(uint i = 0; i < dividendTokens.length; i++) {
                user.reflectionDebt.push(user.amount * accDividendPerShare[i] / PRECISION_FACTOR_REFLECTION[i]);
            }
        } else {
            for(uint i = 0; i < dividendTokens.length; i++) {
                user.reflectionDebt[i] = user.amount * accDividendPerShare[i] / PRECISION_FACTOR_REFLECTION[i];
            }
        }

        lockupInfo.totalStaked = lockupInfo.totalStaked + realAmount;
        totalStaked = totalStaked + realAmount;

        emit Deposit(msg.sender, realAmount);
    }

    function _addStake(address _account, uint256 _duration, uint256 _amount, uint256 firstIndex) internal {
        Stake[] storage stakes = userStakes[_account];

        uint256 end = block.timestamp + _duration * 1 days;
        uint256 i = stakes.length;
        require(i < MAX_STAKES, "Max stakes");

        stakes.push(); // grow the array
        // find the spot where we can insert the current stake
        // this should make an increasing list sorted by end
        while (i != 0 && stakes[i - 1].end > end && i >= firstIndex) {
            // shift it back one
            stakes[i] = stakes[i - 1];
            i -= 1;
        }
        
        // insert the stake
        Stake storage newStake = stakes[i];
        newStake.duration = _duration;
        newStake.end = end;
        newStake.amount = _amount;
        newStake.rewardDebt = newStake.amount * lockupInfo.accTokenPerShare * PRECISION_FACTOR;
    }

    /*
     * @notice Withdraw staked tokens and collect reward tokens
     * @param _amount: amount to withdraw (in earnedToken)
     */
    function withdraw(uint256 _amount) external payable nonReentrant {
        require(_amount > 0, "Amount should be greator than 0");

        _transferPerformanceFee();
        _updatePool();

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        
        bool bUpdatable = true;
        uint256 firstIndex = user.firstIndex;

        uint256 pending = 0;
        uint256 pendingCompound = 0;
        uint256 compounded = 0;
        uint256 remained = _amount;
        for(uint256 j = user.firstIndex; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(bUpdatable && stake.amount == 0) firstIndex = j;
            if(stake.amount == 0) continue;
            if(remained == 0) break;

            if(j - user.firstIndex > processingLimit) break;

            uint256 _pending = stake.amount * lockupInfo.accTokenPerShare / PRECISION_FACTOR - stake.rewardDebt;
            if(stake.end > block.timestamp) {
                pendingCompound = pendingCompound + _pending;

                if(address(stakingToken) != address(earnedToken) && _pending > 0) {
                    uint256 _beforeAmount = stakingToken.balanceOf(address(this));
                    _safeSwap(_pending, earnedToStakedPath, address(this));
                    uint256 _afterAmount = stakingToken.balanceOf(address(this));
                    _pending = _afterAmount - _beforeAmount;
                }
                compounded = compounded + _pending;
                stake.amount = stake.amount + _pending;
            } else {
                pending = pending + _pending;
                if(stake.amount > remained) {
                    stake.amount = stake.amount - remained;
                    remained = 0;
                } else {
                    remained = remained - stake.amount;
                    stake.amount = 0;

                    if(bUpdatable) firstIndex = j;
                }
            }
            stake.rewardDebt = stake.amount * lockupInfo.accTokenPerShare / PRECISION_FACTOR;

            if(stake.amount > 0) bUpdatable = false;
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            earnedToken.safeTransfer(address(msg.sender), pending);
            
            if(totalEarned > pending) {
                totalEarned = totalEarned - pending;
            } else {
                totalEarned = 0;
            }
        }

        if (pendingCompound > 0) {
            require(availableRewardTokens() >= pendingCompound, "Insufficient reward tokens");
            
            if(totalEarned > pendingCompound) {
                totalEarned = totalEarned - pendingCompound;
            } else {
                totalEarned = 0;
            }
            
            emit Deposit(msg.sender, compounded);
        }

        for(uint256 i = 0; i < dividendTokens.length; i++) {
            uint256 pendingReflection = 
                user.amount * accDividendPerShare[i] / PRECISION_FACTOR_REFLECTION[i] - user.reflectionDebt[i];

            pendingReflection = estimateDividendAmount(i, pendingReflection);
            if (pendingReflection > 0) {
                if(address(dividendTokens[i]) == address(0x0)) {
                    payable(msg.sender).transfer(pendingReflection);
                } else {
                    IERC20(dividendTokens[i]).safeTransfer(address(msg.sender), pendingReflection);
                }
                totalReflections[i] = totalReflections[i] - pendingReflection;
            }
        }

        uint256 realAmount = _amount - remained;

        user.firstIndex = firstIndex;
        user.amount = user.amount - realAmount + compounded;
        lockupInfo.totalStaked = lockupInfo.totalStaked - realAmount + compounded;
        totalStaked = totalStaked - realAmount + compounded;

        if(realAmount > 0) {
            if (lockupInfo.withdrawFee > 0) {
                uint256 fee = realAmount * lockupInfo.withdrawFee / 10000;
                stakingToken.safeTransfer(walletA, fee);
                realAmount = realAmount - fee;
            }

            stakingToken.safeTransfer(address(msg.sender), realAmount);
        }

        for(uint i = 0; i < dividendTokens.length; i++) {
            user.reflectionDebt[i] = user.amount * accDividendPerShare[i] / PRECISION_FACTOR_REFLECTION[i];
        }

        emit Withdraw(msg.sender, realAmount);
    }

    function claimReward() external payable nonReentrant {
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool();

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];

        uint256 pending = 0;
        uint256 pendingCompound = 0;
        uint256 compounded = 0;
        for(uint256 j = user.firstIndex; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.amount == 0) continue;
            if(j - user.firstIndex > processingLimit) break;

            uint256 _pending = stake.amount * lockupInfo.accTokenPerShare / PRECISION_FACTOR - stake.rewardDebt;

            if(stake.end > block.timestamp) {
                pendingCompound = pendingCompound + _pending;

                if(address(stakingToken) != address(earnedToken) && _pending > 0) {
                    uint256 _beforeAmount = stakingToken.balanceOf(address(this));
                    _safeSwap(_pending, earnedToStakedPath, address(this));
                    uint256 _afterAmount = stakingToken.balanceOf(address(this));
                    _pending = _afterAmount - _beforeAmount;
                }
                compounded = compounded + _pending;
                stake.amount = stake.amount + _pending;
            } else {
                pending = pending + _pending;
            }
            stake.rewardDebt = stake.amount * lockupInfo.accTokenPerShare / PRECISION_FACTOR;
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            earnedToken.safeTransfer(address(msg.sender), pending);
            
            if(totalEarned > pending) {
                totalEarned = totalEarned - pending;
            } else {
                totalEarned = 0;
            }
        }

        if (pendingCompound > 0) {
            require(availableRewardTokens() >= pendingCompound, "Insufficient reward tokens");
            
            if(totalEarned > pendingCompound) {
                totalEarned = totalEarned - pendingCompound;
            } else {
                totalEarned = 0;
            }

            user.amount = user.amount + compounded;
            lockupInfo.totalStaked = lockupInfo.totalStaked + compounded;
            totalStaked = totalStaked + compounded;

            for(uint i = 0; i < dividendTokens.length; i++) {
                user.reflectionDebt[i] = user.reflectionDebt[i] + compounded * accDividendPerShare[i] / PRECISION_FACTOR_REFLECTION[i];
            }

            emit Deposit(msg.sender, compounded);
        }
    }

    function claimDividend() external payable nonReentrant {
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool();

        UserInfo storage user = userStaked[msg.sender];
        if (user.amount == 0) return;        

        for(uint i = 0; i < dividendTokens.length; i++) {
            uint256 pendingReflection = 
                user.amount * accDividendPerShare[i] / PRECISION_FACTOR_REFLECTION[i] - user.reflectionDebt[i];

            pendingReflection = estimateDividendAmount(i, pendingReflection);
            if (pendingReflection > 0) {
                if(address(dividendTokens[i]) == address(0x0)) {
                    payable(msg.sender).transfer(pendingReflection);
                } else {
                    IERC20(dividendTokens[i]).safeTransfer(address(msg.sender), pendingReflection);
                }
                totalReflections[i] = totalReflections[i] - pendingReflection;
            }
            
            user.reflectionDebt[i] = user.amount * accDividendPerShare[i] / PRECISION_FACTOR_REFLECTION[i];
        }
    }

    function compoundReward() external payable nonReentrant {
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool();

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];

        uint256 pending = 0;
        uint256 compounded = 0;
        for(uint256 j = user.firstIndex; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.amount == 0) continue;
            if(j - user.firstIndex > processingLimit) break;

            uint256 _pending = stake.amount * lockupInfo.accTokenPerShare / PRECISION_FACTOR - stake.rewardDebt;
            pending = pending + _pending;

            if(address(stakingToken) != address(earnedToken) && _pending > 0) {
                uint256 _beforeAmount = stakingToken.balanceOf(address(this));
                _safeSwap(_pending, earnedToStakedPath, address(this));
                uint256 _afterAmount = stakingToken.balanceOf(address(this));
                _pending = _afterAmount - _beforeAmount;
            }
            compounded = compounded + _pending;

            stake.amount = stake.amount + _pending;
            stake.rewardDebt = stake.amount * lockupInfo.accTokenPerShare / PRECISION_FACTOR;
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            
            if(totalEarned > pending) {
                totalEarned = totalEarned - pending;
            } else {
                totalEarned = 0;
            }

            user.amount = user.amount + compounded;
            lockupInfo.totalStaked = lockupInfo.totalStaked + compounded;
            totalStaked = totalStaked + compounded;

            for(uint i = 0; i < dividendTokens.length; i++) {
                user.reflectionDebt[i] = user.reflectionDebt[i] + compounded * accDividendPerShare[i] / PRECISION_FACTOR_REFLECTION[i];
            }

            emit Deposit(msg.sender, compounded);
        }
    }

    function compoundDividend() external pure {}

    function _transferPerformanceFee() internal {
        require(msg.value >= performanceFee, 'should pay small gas to compound or harvest');

        payable(buyBackWallet).transfer(performanceFee);
        if(msg.value > performanceFee) {
            payable(msg.sender).transfer(msg.value - performanceFee);
        }
    }

    /*
     * @notice Withdraw staked tokens without caring about rewards
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw() external nonReentrant {
        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];

        uint256 firstIndex = user.firstIndex;
        uint256 amountToTransfer = 0;
        for(uint256 j = user.firstIndex; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.amount == 0) {
                firstIndex = j;
                continue;
            }
            if(j - user.firstIndex > processingLimit) break;

            amountToTransfer = amountToTransfer + stake.amount;

            stake.amount = 0;
            stake.rewardDebt = 0;

            firstIndex = j;
        }

        if (amountToTransfer > 0) {
            stakingToken.safeTransfer(address(msg.sender), amountToTransfer);

            user.firstIndex = firstIndex;
            user.amount = user.amount - amountToTransfer;
            for(uint i = 0; i < dividendTokens.length; i++) {
                user.reflectionDebt[i] = user.amount * accDividendPerShare[i] / PRECISION_FACTOR_REFLECTION[i];
            }

            lockupInfo.totalStaked = lockupInfo.totalStaked - amountToTransfer;
            totalStaked = totalStaked - amountToTransfer;
        }

        emit EmergencyWithdraw(msg.sender, amountToTransfer);
    }

    function rewardPerBlock() external view returns (uint256) {
        return lockupInfo.rate;
    }

    /**
     * @notice Available amount of reward token
     */
    function availableRewardTokens() public view returns (uint256) {
        uint256 _amount = earnedToken.balanceOf(address(this));
        if (address(earnedToken) == address(stakingToken)) {
            if (_amount < totalStaked) return 0;
            return _amount - totalStaked;
        }

        return _amount;
    }

    /**
     * @notice Available amount of reflection token
     */
    function availableDividendTokens(uint index) public view returns (uint256) {
        if(address(dividendTokens[index]) == address(0x0)) {
            return address(this).balance;
        }

        uint256 _amount = IERC20(dividendTokens[index]).balanceOf(address(this));
        
        if(address(dividendTokens[index]) == address(earnedToken)) {
            if(_amount < totalEarned) return 0;
            _amount = _amount - totalEarned;
        }

        if(address(dividendTokens[index]) == address(stakingToken)) {
            if(_amount < totalStaked) return 0;
            _amount = _amount - totalStaked;
        }

        return _amount;
    }

    function userInfo(address _account) external view returns (uint256 amount, uint256 available, uint256 locked) {
        UserInfo memory user = userStaked[_account];
        Stake[] memory stakes = userStakes[_account];
        
        for(uint256 i = user.firstIndex; i < stakes.length; i++) {
            Stake memory stake = stakes[i];
            if(stake.amount == 0) continue;
            
            amount = amount + stake.amount;
            if(block.timestamp > stake.end) {
                available = available + stake.amount;
            } else {
                locked = locked + stake.amount;
            }
        }
    }

    /*
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @return Pending reward for a given user
     */
    function pendingReward(address _account) external view returns (uint256) {
        if(startBlock == 0) return 0;
        if(lockupInfo.totalStaked == 0) return 0;

        UserInfo memory user = userStaked[_account];
        Stake[] memory stakes = userStakes[_account];        

        if(user.amount == 0) return 0;
        
        uint256 adjustedTokenPerShare = lockupInfo.accTokenPerShare;
        if (block.number > lockupInfo.lastRewardBlock && lockupInfo.totalStaked != 0 && lockupInfo.lastRewardBlock > 0) {
            uint256 multiplier = _getMultiplier(lockupInfo.lastRewardBlock, block.number);
            uint256 reward = multiplier * lockupInfo.rate;
            adjustedTokenPerShare = lockupInfo.accTokenPerShare + reward * PRECISION_FACTOR / lockupInfo.totalStaked;
        }

        uint256 pending = 0;
        for(uint256 i = user.firstIndex; i < stakes.length; i++) {
            Stake memory stake = stakes[i];
            if(stake.amount == 0) continue;

            pending = pending + (
                stake.amount * adjustedTokenPerShare / PRECISION_FACTOR - stake.rewardDebt
            );
        }
        return pending;
    }

    function pendingDividends(address _account) external view returns (uint256[] memory data) {
        data = new uint256[](dividendTokens.length);
        if(startBlock == 0 || totalStaked == 0) return data;

        UserInfo memory user = userStaked[_account];
        if(user.amount == 0) return data;
        
        for(uint i = 0; i < dividendTokens.length; i++) {
            uint256 reflectionAmount = availableDividendTokens(i);
            if(reflectionAmount < totalReflections[i]) {
                reflectionAmount = totalReflections[i];
            }

            uint256 sTokenBal = totalStaked;
            uint256 eTokenBal = availableRewardTokens();
            if(address(stakingToken) == address(earnedToken)) {
                sTokenBal = sTokenBal + eTokenBal;
            }

            uint256 adjustedReflectionPerShare = accDividendPerShare[i] + (
                    (reflectionAmount - totalReflections[i]) * PRECISION_FACTOR_REFLECTION[i] / sTokenBal
                );
            
            uint256 pendingReflection = 
                    user.amount * adjustedReflectionPerShare / PRECISION_FACTOR_REFLECTION[i] - user.reflectionDebt[i];
            
            data[i] = pendingReflection;
        }

        return data;
    }

    /************************
    ** Admin Methods
    *************************/
    function harvest() external onlyOwner {        
        _updatePool();

        for(uint i = 0; i < dividendTokens.length; i++) {
            reflections[i] = estimateDividendAmount(i, reflections[i]);
            if(reflections[i] > 0) {
                if(address(dividendTokens[i]) == address(0x0)) {
                    payable(walletA).transfer(reflections[i]);
                } else {
                    IERC20(dividendTokens[i]).safeTransfer(walletA, reflections[i]);
                }

                totalReflections[i] = totalReflections[i] - reflections[i];
                reflections[i] = 0;
            }
        }
    }

    /*
     * @notice Deposit reward token
     * @dev Only call by owner. Needs to be for deposit of reward token when reflection token is same with reward token.
     */
    function depositRewards(uint _amount) external onlyOwner nonReentrant {
        require(_amount > 0, "invalid amount");

        uint256 beforeAmt = earnedToken.balanceOf(address(this));
        earnedToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = earnedToken.balanceOf(address(this));

        totalEarned = totalEarned + afterAmt - beforeAmt;
    }

    /*
     * @notice Withdraw reward token
     * @dev Only callable by owner. Needs to be for emergency.
     */
    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
        require( block.number > bonusEndBlock, "Pool is running");
        require(availableRewardTokens() >= _amount, "Insufficient reward tokens");

        earnedToken.safeTransfer(address(msg.sender), _amount);
        
        if (totalEarned > 0) {
            if (_amount > totalEarned) {
                totalEarned = 0;
            } else {
                totalEarned = totalEarned - _amount;
            }
        }
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of tokens to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(
            _tokenAddress != address(earnedToken),
            "Cannot be reward token"
        );

        if(_tokenAddress == address(stakingToken)) {
            uint256 tokenBal = stakingToken.balanceOf(address(this));
            require(_tokenAmount <= tokenBal - totalStaked, "Insufficient balance");
        }

        if(_tokenAddress == address(0x0)) {
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
        }

        emit AdminTokenRecovered(_tokenAddress, _tokenAmount);
    }

    function startReward() external onlyOwner {
        require(startBlock == 0, "Pool was already started");

        startBlock = block.number + 100;
        bonusEndBlock = startBlock + duration * 28800;
        lockupInfo.lastRewardBlock = startBlock;
        
        emit NewStartAndEndBlocks(startBlock, bonusEndBlock);
    }

    function stopReward() external onlyOwner {
        bonusEndBlock = block.number;
        emit RewardsStop(bonusEndBlock);
    }

    function updateEndBlock(uint256 _endBlock) external onlyOwner {
        require(startBlock > 0, "Pool is not started");
        require(bonusEndBlock > block.number, "Pool was already finished");
        require(_endBlock > block.number && _endBlock > startBlock, "Invalid end block");
        bonusEndBlock = _endBlock;
        emit EndBlockUpdated(_endBlock);
    }

    /*
     * @notice Update pool limit per user
     * @dev Only callable by owner.
     * @param _hasUserLimit: whether the limit remains forced
     * @param _poolLimitPerUser: new pool limit per user
     */
    function updatePoolLimitPerUser( bool _hasUserLimit, uint256 _poolLimitPerUser) external onlyOwner {
        if (_hasUserLimit) {
            require(
                _poolLimitPerUser > poolLimitPerUser,
                "New limit must be higher"
            );
            poolLimitPerUser = _poolLimitPerUser;
        } else {
            poolLimitPerUser = 0;
        }
        hasUserLimit = _hasUserLimit;

        emit UpdatePoolLimit(poolLimitPerUser, hasUserLimit);
    }

    function updateLockup(uint256 _duration, uint256 _depositFee, uint256 _withdrawFee, uint256 _rate) external onlyOwner {
        // require(block.number < startBlock, "Pool was already started");
        require(_depositFee < 2000 && _withdrawFee < 2000, "Invalid fee");

        _updatePool();

        lockupInfo.duration = _duration;
        lockupInfo.depositFee = _depositFee;
        lockupInfo.withdrawFee = _withdrawFee;
        lockupInfo.rate = _rate;
        
        emit LockupUpdated(_duration, _depositFee, _withdrawFee, _rate);
    }

    function setServiceInfo(address _addr, uint256 _fee) external {
        require(msg.sender == buyBackWallet, "setServiceInfo: FORBIDDEN");
        require(_addr != address(0x0), "Invalid address");

        buyBackWallet = _addr;
        performanceFee = _fee;

        emit ServiceInfoUpadted(_addr, _fee);
    }
    
    function setDuration(uint256 _duration) external onlyOwner {
        require(startBlock == 0, "Pool was already started");

        duration = _duration;
        emit DurationUpdated(_duration);
    }

    function setProcessingLimit(uint256 _limit) external onlyOwner {
        require(_limit > 0, "Invalid limit");
        processingLimit = _limit;
    }

    function setSettings(
        uint256 _slippageFactor, 
        address _uniRouter, 
        address[] memory _earnedToStakedPath
    ) external onlyOwner {
        require(_slippageFactor <= slippageFactorUL, "_slippageFactor too high");

        slippageFactor = _slippageFactor;
        uniRouterAddress = _uniRouter;
        earnedToStakedPath = _earnedToStakedPath;

        emit SetSettings(_slippageFactor, _uniRouter, _earnedToStakedPath);
    }

    function updateWalletA(address _walletA) external onlyOwner {
        require(_walletA != address(0x0) || _walletA != walletA, "Invalid address");

        walletA = _walletA;
        emit WalletAUpdated(_walletA);
    }


    /************************
    ** Internal Methods
    *************************/
    /*
     * @notice Update reward variables of the given pool to be up-to-date.
     */
    function _updatePool() internal {
        // calc reflection rate
        if(totalStaked > 0) {
            uint256 sTokenBal = totalStaked;
            uint256 eTokenBal = availableRewardTokens();
            if(address(stakingToken) == address(earnedToken)) {
                sTokenBal = sTokenBal + eTokenBal;
            }

            for(uint i  = 0; i < dividendTokens.length; i++) {
                uint256 reflectionAmount = availableDividendTokens(i);
                if(reflectionAmount < totalReflections[i]) {
                    reflectionAmount = totalReflections[i];
                }

                accDividendPerShare[i] = accDividendPerShare[i] + (
                        (reflectionAmount - totalReflections[i]) * PRECISION_FACTOR_REFLECTION[i] / sTokenBal
                    );

                if(address(stakingToken) == address(earnedToken)) {
                    reflections[i] = reflections[i] + (reflectionAmount - totalReflections[i]) * eTokenBal / sTokenBal;
                }
                totalReflections[i] = reflectionAmount;
            }
        }

        if (block.number <= lockupInfo.lastRewardBlock || lockupInfo.lastRewardBlock == 0) return;

        if (lockupInfo.totalStaked == 0) {
            lockupInfo.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = _getMultiplier(lockupInfo.lastRewardBlock, block.number);
        uint256 _reward = multiplier * lockupInfo.rate;
        lockupInfo.accTokenPerShare = lockupInfo.accTokenPerShare + (
            _reward * PRECISION_FACTOR / lockupInfo.totalStaked
        );
        lockupInfo.lastRewardBlock = block.number;
    }

    
    function estimateDividendAmount(uint256 index, uint256 amount) internal view returns(uint256) {
        uint256 dTokenBal = availableDividendTokens(index);
        if(amount > totalReflections[index]) amount = totalReflections[index];
        if(amount > dTokenBal) amount = dTokenBal;
        return amount;
    }

    /*
     * @notice Return reward multiplier over the given _from to _to block.
     * @param _from: block to start
     * @param _to: block to finish
     */
    function _getMultiplier(uint256 _from, uint256 _to)
        internal
        view
        returns (uint256)
    {
        if (_to <= bonusEndBlock) {
            return _to - _from;
        } else if (_from >= bonusEndBlock) {
            return 0;
        } else {
            return bonusEndBlock - _from;
        }
    }

    function _safeSwap(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal {
        uint256[] memory amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length - 1];

        IERC20(_path[0]).safeApprove(uniRouterAddress, _amountIn);
        IUniRouter02(uniRouterAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amountIn,
            amountOut * slippageFactor / 1000,
            _path,
            _to,
            block.timestamp + 600
        );
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./libs/IUniRouter02.sol";
import "./libs/IWETH.sol";
interface IToken {
     /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);
}

contract BrewlabsLockupFee is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Whether it is initialized
    bool public isInitialized;
    uint256 public duration = 7; // 7 days

    // Whether a limit is set for users
    bool public hasUserLimit;
    // The pool limit (0 if none)
    uint256 public poolLimitPerUser;


    // The block number when staking starts.
    uint256 public startBlock;
    // The block number when staking ends.
    uint256 public bonusEndBlock;


    // swap router and path, slipPage
    uint256 public slippageFactor = 800; // 20% default slippage tolerance
    uint256 public constant slippageFactorUL = 995;

    address public uniRouterAddress;
    address[] public reflectionToStakedPath;
    address[] public earnedToStakedPath;

    address public walletA;
    address public buyBackWallet = 0x408c4aDa67aE1244dfeC7D609dea3c232843189A;
    uint256 public performanceFee = 0.0035 ether;

    // The precision factor
    uint256 public PRECISION_FACTOR;
    uint256 public PRECISION_FACTOR_REFLECTION;

    // The staked token
    IERC20 public stakingToken;
    // The earned token
    IERC20 public earnedToken;
    // The dividend token of staking token
    address public dividendToken;

    // Accrued token per share
    uint256 public accDividendPerShare;
    uint256 public totalStaked;

    uint256 private totalEarned;
    uint256 private totalReflections;
    uint256 private reflections;

    struct Lockup {
        uint8 stakeType;
        uint256 duration;
        uint256 depositFee;
        uint256 withdrawFee;
        uint256 rate;
        uint256 accTokenPerShare;
        uint256 lastRewardBlock;
        uint256 totalStaked;
    }

    struct UserInfo {
        uint256 amount; // How many staked tokens the user has provided
        uint256 locked;
        uint256 available;
    }

    struct Stake {
        uint8   stakeType;
        uint256 amount;     // amount to stake
        uint256 duration;   // the lockup duration of the stake
        uint256 end;        // when does the staking period end
        uint256 rewardDebt; // Reward debt
        uint256 reflectionDebt; // Reflection debt
    }
    uint256 constant MAX_STAKES = 256;

    Lockup[] public lockups;
    mapping(address => Stake[]) public userStakes;
    mapping(address => UserInfo) public userStaked;

    event Deposit(address indexed user, uint256 stakeType, uint256 amount);
    event Withdraw(address indexed user, uint256 stakeType, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event AdminTokenRecovered(address tokenRecovered, uint256 amount);

    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);
    event LockupUpdated(uint8 _type, uint256 _duration, uint256 _fee0, uint256 _fee1, uint256 _rate);
    event RewardsStop(uint256 blockNumber);
    event EndBlockUpdated(uint256 blockNumber);
    event UpdatePoolLimit(uint256 poolLimitPerUser, bool hasLimit);

    event ServiceInfoUpadted(address _addr, uint256 _fee);
    event DurationUpdated(uint256 _duration);

    event SetSettings(
        uint256 _slippageFactor,
        address _uniRouter,
        address[] _path0,
        address[] _path1,
        address _walletA
    );

    constructor() {}

    /*
     * @notice Initialize the contract
     * @param _stakingToken: staked token address
     * @param _earnedToken: earned token address
     * @param _dividendToken: reflection token address
     * @param _uniRouter: uniswap router address for swap tokens
     * @param _earnedToStakedPath: swap path to compound (earned -> staking path)
     * @param _reflectionToStakedPath: swap path to compound (reflection -> staking path)
     */
    function initialize(
        IERC20 _stakingToken,
        IERC20 _earnedToken,
        address _dividendToken,
        address _uniRouter,
        address[] memory _earnedToStakedPath,
        address[] memory _reflectionToStakedPath
    ) external onlyOwner {
        require(!isInitialized, "Already initialized");

        // Make this contract initialized
        isInitialized = true;

        stakingToken = _stakingToken;
        earnedToken = _earnedToken;
        dividendToken = _dividendToken;

        walletA = msg.sender;

        uint256 decimalsRewardToken = uint256(IToken(address(earnedToken)).decimals());
        require(decimalsRewardToken < 30, "Must be inferior to 30");
        PRECISION_FACTOR = uint256(10**(40 - decimalsRewardToken));

        uint256 decimalsdividendToken = 18;
        if(address(dividendToken) != address(0x0)) {
            decimalsdividendToken = uint256(IToken(address(dividendToken)).decimals());
            require(decimalsdividendToken < 30, "Must be inferior to 30");
        }
        PRECISION_FACTOR_REFLECTION = uint256(10**(40 - decimalsRewardToken));

        uniRouterAddress = _uniRouter;
        earnedToStakedPath = _earnedToStakedPath;
        reflectionToStakedPath = _reflectionToStakedPath;
    }

    /*
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @param _amount: amount to withdraw (in earnedToken)
     */
    function deposit(uint256 _amount, uint8 _stakeType) external payable nonReentrant {
        require(startBlock > 0 && startBlock < block.number, "Staking hasn't started yet");
        require(_amount > 0, "Amount should be greator than 0");
        require(_stakeType < lockups.length, "Invalid stake type");

        _transferPerformanceFee();
        _updatePool(_stakeType);

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];

        uint256 pending = 0;
        uint256 pendingCompound = 0;
        uint256 pendingReflection = 0;
        uint256 compounded = 0;
        for(uint256 j = 0; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            pendingReflection = pendingReflection + (
                stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - stake.reflectionDebt
            );

            uint256 _pending = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR - stake.rewardDebt;
            if(stake.end > block.timestamp) {
                pendingCompound = pendingCompound + _pending;

                if(address(stakingToken) != address(earnedToken) && _pending > 0) {
                    earnedToken.safeTransfer(walletA, _pending * lockup.withdrawFee / 10000);
                    _pending = _pending * (10000 - lockup.withdrawFee) / 10000;

                    _pending = _safeSwap(_pending, earnedToStakedPath, address(this));
                }
                compounded = compounded + _pending;
                stake.amount = stake.amount + _pending;
            } else {
                pending = pending + _pending;
            }
            stake.rewardDebt = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR;
            stake.reflectionDebt = stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            uint256 fee = pending * lockup.withdrawFee / 10000;
            earnedToken.safeTransfer(walletA, fee);
            earnedToken.safeTransfer(address(msg.sender), pending - fee);
            
            if(totalEarned > pending) {
                totalEarned = totalEarned - pending;
            } else {
                totalEarned = 0;
            }
        }

        if (pendingCompound > 0) {
            require(availableRewardTokens() >= pendingCompound, "Insufficient reward tokens");
            
            if(totalEarned > pendingCompound) {
                totalEarned = totalEarned - pendingCompound;
            } else {
                totalEarned = 0;
            }
        }

        pendingReflection = estimateDividendAmount(pendingReflection);
        if (pendingReflection > 0) {
            if(address(dividendToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingReflection);
            } else {
                IERC20(dividendToken).safeTransfer(address(msg.sender), pendingReflection);
            }
            totalReflections = totalReflections - pendingReflection;
        }

        uint256 beforeAmount = stakingToken.balanceOf(address(this));
        stakingToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        uint256 afterAmount = stakingToken.balanceOf(address(this));        
        uint256 realAmount = afterAmount - beforeAmount;

        if (hasUserLimit) {
            require(
                realAmount + user.amount <= poolLimitPerUser,
                "User amount above limit"
            );
        }
        if (lockup.depositFee > 0) {
            uint256 fee = realAmount * lockup.depositFee / 10000;
            if (fee > 0) {
                stakingToken.safeTransfer(walletA, fee);
                realAmount = realAmount - fee;
            }
        }
        
        _addStake(_stakeType, msg.sender, lockup.duration, realAmount);

        user.amount = user.amount + realAmount + compounded;
        lockup.totalStaked = lockup.totalStaked + realAmount + compounded;
        totalStaked = totalStaked + realAmount + compounded;

        emit Deposit(msg.sender, _stakeType, realAmount + compounded);
    }

    function _addStake(uint8 _stakeType, address _account, uint256 _duration, uint256 _amount) internal {
        Stake[] storage stakes = userStakes[_account];

        uint256 end = block.timestamp + _duration * 1 days;
        uint256 i = stakes.length;
        require(i < MAX_STAKES, "Max stakes");

        stakes.push(); // grow the array
        // find the spot where we can insert the current stake
        // this should make an increasing list sorted by end
        while (i != 0 && stakes[i - 1].end > end) {
            // shift it back one
            stakes[i] = stakes[i - 1];
            i -= 1;
        }
        
        Lockup storage lockup = lockups[_stakeType];

        // insert the stake
        Stake storage newStake = stakes[i];
        newStake.stakeType = _stakeType;
        newStake.duration = _duration;
        newStake.end = end;
        newStake.amount = _amount;
        newStake.rewardDebt = newStake.amount * lockup.accTokenPerShare / PRECISION_FACTOR;
        newStake.reflectionDebt = newStake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
    }

    /*
     * @notice Withdraw staked tokens and collect reward tokens
     * @param _amount: amount to withdraw (in earnedToken)
     */
    function withdraw(uint256 _amount, uint8 _stakeType) external payable nonReentrant {
        require(_amount > 0, "Amount should be greator than 0");
        require(_stakeType < lockups.length, "Invalid stake type");

        _transferPerformanceFee();
        _updatePool(_stakeType);

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];
        
        uint256 pending = 0;
        uint256 pendingCompound = 0;
        uint256 pendingReflection = 0;
        uint256 compounded = 0;
        uint256 remained = _amount;
        for(uint256 j = 0; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;
            if(remained == 0) break;

            uint256 _pending = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR - stake.rewardDebt;
            pendingReflection = pendingReflection + (
                stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - stake.reflectionDebt
            );

            if(stake.end > block.timestamp) {
                pendingCompound = pendingCompound + _pending;

                if(address(stakingToken) != address(earnedToken) && _pending > 0) {
                    earnedToken.safeTransfer(walletA, _pending * lockup.withdrawFee / 10000);
                    _pending = _pending * (10000 - lockup.withdrawFee) / 10000;

                    _pending = _safeSwap(_pending, earnedToStakedPath, address(this));
                }
                compounded = compounded + _pending;
                stake.amount = stake.amount + _pending;
            } else {
                pending = pending + _pending;
                if(stake.amount > remained) {
                    stake.amount = stake.amount - remained;
                    remained = 0;
                } else {
                    remained = remained - stake.amount;
                    stake.amount = 0;
                }
            }
            stake.rewardDebt = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR;
            stake.reflectionDebt = stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            uint256 fee = pending * lockup.withdrawFee / 10000;
            earnedToken.safeTransfer(walletA, fee);
            earnedToken.safeTransfer(address(msg.sender), pending - fee);
            
            if(totalEarned > pending) {
                totalEarned = totalEarned - pending;
            } else {
                totalEarned = 0;
            }
        }

        if (pendingCompound > 0) {
            require(availableRewardTokens() >= pendingCompound, "Insufficient reward tokens");
            
            if(totalEarned > pendingCompound) {
                totalEarned = totalEarned - pendingCompound;
            } else {
                totalEarned = 0;
            }
            
            emit Deposit(msg.sender, _stakeType, compounded);
        }

        if (pendingReflection > 0) {
            pendingReflection = estimateDividendAmount(pendingReflection);
            if(address(dividendToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingReflection);
            } else {
                IERC20(dividendToken).safeTransfer(address(msg.sender), pendingReflection);
            }
            totalReflections = totalReflections - pendingReflection;
        }

        uint256 realAmount = _amount - remained;
        user.amount = user.amount - realAmount + compounded;
        lockup.totalStaked = lockup.totalStaked - realAmount + compounded;
        totalStaked = totalStaked - realAmount + compounded;

        stakingToken.safeTransfer(address(msg.sender), realAmount);
       
        emit Withdraw(msg.sender, _stakeType, realAmount);
    }

    function claimReward(uint8 _stakeType) external payable nonReentrant {
        if(_stakeType >= lockups.length) return;
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool(_stakeType);

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];

        uint256 pending = 0;
        uint256 pendingCompound = 0;
        uint256 compounded = 0;
        for(uint256 j = 0; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            uint256 _pending = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR - stake.rewardDebt;

            if(stake.end > block.timestamp) {
                pendingCompound = pendingCompound + _pending;

                if(address(stakingToken) != address(earnedToken) && _pending > 0) {
                    earnedToken.safeTransfer(walletA, _pending * lockup.withdrawFee / 10000);
                    _pending = _pending * (10000 - lockup.withdrawFee) / 10000;

                    _pending = _safeSwap(_pending, earnedToStakedPath, address(this));
                }
                compounded = compounded + _pending;
                stake.amount = stake.amount + _pending;
                stake.reflectionDebt = stake.reflectionDebt + _pending * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
            } else {
                pending = pending + _pending;
            }
            stake.rewardDebt = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR;
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            uint256 fee = pending * lockup.withdrawFee / 10000;
            earnedToken.safeTransfer(walletA, fee);
            earnedToken.safeTransfer(address(msg.sender), pending - fee);
            
            if(totalEarned > pending) {
                totalEarned = totalEarned - pending;
            } else {
                totalEarned = 0;
            }
        }

        if (pendingCompound > 0) {
            require(availableRewardTokens() >= pendingCompound, "Insufficient reward tokens");
            
            if(totalEarned > pendingCompound) {
                totalEarned = totalEarned - pendingCompound;
            } else {
                totalEarned = 0;
            }

            user.amount = user.amount + compounded;
            lockup.totalStaked = lockup.totalStaked + compounded;
            totalStaked = totalStaked + compounded;

            emit Deposit(msg.sender, _stakeType, compounded);
        }
    }

    function claimDividend(uint8 _stakeType) external payable nonReentrant {
        if(_stakeType >= lockups.length) return;
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool(_stakeType);

        Stake[] storage stakes = userStakes[msg.sender];

        uint256 pendingReflection = 0;
        for(uint256 j = 0; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            pendingReflection = pendingReflection + (
                stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - stake.reflectionDebt
            );

            stake.reflectionDebt = stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
        }

        pendingReflection = estimateDividendAmount(pendingReflection);
        if (pendingReflection > 0) {
            if(address(dividendToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingReflection);
            } else {
                IERC20(dividendToken).safeTransfer(address(msg.sender), pendingReflection);
            }
            totalReflections = totalReflections - pendingReflection;
        }
    }

    function compoundReward(uint8 _stakeType) external payable nonReentrant {
        if(_stakeType >= lockups.length) return;
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool(_stakeType);

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];

        uint256 pending = 0;
        uint256 compounded = 0;
        for(uint256 j = 0; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            uint256 _pending = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR - stake.rewardDebt;
            pending = pending + _pending;

            if(address(stakingToken) != address(earnedToken) && _pending > 0) {
                earnedToken.safeTransfer(walletA, _pending * lockup.withdrawFee / 10000);
                _pending = _pending * (10000 - lockup.withdrawFee) / 10000;
                
                _pending = _safeSwap(_pending, earnedToStakedPath, address(this));
            }
            compounded = compounded + _pending;

            stake.amount = stake.amount + _pending;
            stake.rewardDebt = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR;
            stake.reflectionDebt = stake.reflectionDebt + _pending * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            
            if(totalEarned > pending) {
                totalEarned = totalEarned - pending;
            } else {
                totalEarned = 0;
            }

            user.amount = user.amount + compounded;
            lockup.totalStaked = lockup.totalStaked + compounded;
            totalStaked = totalStaked + compounded;

            emit Deposit(msg.sender, _stakeType, compounded);
        }
    }

    function compoundDividend(uint8 _stakeType) external payable nonReentrant {
        if(_stakeType >= lockups.length) return;
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool(_stakeType);

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];

        uint256 compounded = 0;
        for(uint256 j = 0; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            uint256 _pending = stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - stake.reflectionDebt;
            _pending = estimateDividendAmount(_pending);

            totalReflections = totalReflections - _pending;
            if(address(stakingToken) != address(dividendToken) && _pending > 0) {
                if(address(dividendToken) == address(0x0)) {
                    address wethAddress = IUniRouter02(uniRouterAddress).WETH();
                    IWETH(wethAddress).deposit{ value: _pending }();
                }

                _pending = _safeSwap(_pending, reflectionToStakedPath, address(this));
            }
            
            compounded = compounded + _pending;
            stake.amount = stake.amount + _pending;
            stake.rewardDebt = stake.rewardDebt + _pending * lockup.accTokenPerShare / PRECISION_FACTOR;
            stake.reflectionDebt = stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
        }

        if (compounded > 0) {
            user.amount = user.amount + compounded;
            lockup.totalStaked = lockup.totalStaked + compounded;
            totalStaked = totalStaked + compounded;

            emit Deposit(msg.sender, _stakeType, compounded);
        }
    }

    function _transferPerformanceFee() internal {
        require(msg.value >= performanceFee, 'should pay small gas to compound or harvest');

        payable(buyBackWallet).transfer(performanceFee);
        if(msg.value > performanceFee) {
            payable(msg.sender).transfer(msg.value - performanceFee);
        }
    }

    /*
     * @notice Withdraw staked tokens without caring about rewards
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw(uint8 _stakeType) external nonReentrant {
        if(_stakeType >= lockups.length) return;

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];

        uint256 amountToTransfer = 0;
        for(uint256 j = 0; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            amountToTransfer = amountToTransfer + stake.amount;

            stake.amount = 0;
            stake.rewardDebt = 0;
            stake.reflectionDebt = 0;
        }

        if (amountToTransfer > 0) {
            stakingToken.safeTransfer(address(msg.sender), amountToTransfer);

            user.amount = user.amount - amountToTransfer;
            lockup.totalStaked = lockup.totalStaked - amountToTransfer;
            totalStaked = totalStaked - amountToTransfer;
        }

        emit EmergencyWithdraw(msg.sender, amountToTransfer);
    }

    function rewardPerBlock(uint8 _stakeType) external view returns (uint256) {
        if(_stakeType >= lockups.length) return 0;

        return lockups[_stakeType].rate;
    }

    /**
     * @notice Available amount of reward token
     */
    function availableRewardTokens() public view returns (uint256) {
        if(address(earnedToken) == address(dividendToken)) return totalEarned;

        uint256 _amount = earnedToken.balanceOf(address(this));
        if (address(earnedToken) == address(stakingToken)) {
            if (_amount < totalStaked) return 0;
            return _amount - totalStaked;
        }

        return _amount;
    }

    /**
     * @notice Available amount of reflection token
     */
    function availableDividendTokens() public view returns (uint256) {
        if(address(dividendToken) == address(0x0)) {
            return address(this).balance;
        }

        uint256 _amount = IERC20(dividendToken).balanceOf(address(this));
        
        if(address(dividendToken) == address(earnedToken)) {
            if(_amount < totalEarned) return 0;
            _amount = _amount - totalEarned;
        }

        if(address(dividendToken) == address(stakingToken)) {
            if(_amount < totalStaked) return 0;
            _amount = _amount - totalStaked;
        }

        return _amount;
    }

    function userInfo(uint8 _stakeType, address _account) external view returns (uint256 amount, uint256 available, uint256 locked) {
        Stake[] memory stakes = userStakes[_account];
        
        for(uint256 i = 0; i < stakes.length; i++) {
            Stake memory stake = stakes[i];

            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;
            
            amount = amount + stake.amount;
            if(block.timestamp > stake.end) {
                available = available + stake.amount;
            } else {
                locked = locked + stake.amount;
            }
        }
    }

    /*
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @return Pending reward for a given user
     */
    function pendingReward(address _account, uint8 _stakeType) external view returns (uint256) {
        if(_stakeType >= lockups.length || startBlock == 0) return 0;

        Stake[] memory stakes = userStakes[_account];
        Lockup memory lockup = lockups[_stakeType];

        if(lockup.totalStaked == 0) return 0;
        
        uint256 adjustedTokenPerShare = lockup.accTokenPerShare;
        if (block.number > lockup.lastRewardBlock && lockup.totalStaked != 0 && lockup.lastRewardBlock > 0) {
            uint256 multiplier = _getMultiplier(lockup.lastRewardBlock, block.number);
            uint256 reward = multiplier * lockup.rate;

            adjustedTokenPerShare = lockup.accTokenPerShare + reward * PRECISION_FACTOR / lockup.totalStaked;
        }

        uint256 pending = 0;
        for(uint256 i = 0; i < stakes.length; i++) {
            Stake memory stake = stakes[i];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            pending = pending + (
                    stake.amount * adjustedTokenPerShare / PRECISION_FACTOR - stake.rewardDebt
                );
        }
        return pending;
    }

    function pendingDividends(address _account, uint8 _stakeType) external view returns (uint256) {
        if(_stakeType >= lockups.length) return 0;
        if(startBlock == 0 || totalStaked == 0) return 0;

        Stake[] memory stakes = userStakes[_account];
        
        uint256 reflectionAmount = availableDividendTokens();
        if(reflectionAmount < totalReflections) {
            reflectionAmount = totalReflections;
        }

        uint256 sTokenBal = totalStaked;
        uint256 eTokenBal = availableRewardTokens();
        if(address(stakingToken) == address(earnedToken)) {
            sTokenBal = sTokenBal + eTokenBal;
        }

        uint256 adjustedReflectionPerShare = accDividendPerShare + ( 
            (reflectionAmount - totalReflections) * PRECISION_FACTOR_REFLECTION / sTokenBal
        );
        
        uint256 pendingReflection = 0;
        for(uint256 i = 0; i < stakes.length; i++) {
            Stake memory stake = stakes[i];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            pendingReflection = pendingReflection + (
                stake.amount * adjustedReflectionPerShare / PRECISION_FACTOR_REFLECTION - stake.reflectionDebt
            );
        }
        return pendingReflection;
    }

    /************************
    ** Admin Methods
    *************************/
    function harvest() external onlyOwner {
        _updatePool(0);

        reflections = estimateDividendAmount(reflections);
        if(reflections > 0) {
            if(address(dividendToken) == address(0x0)) {
                payable(walletA).transfer(reflections);
            } else {
                IERC20(dividendToken).safeTransfer(walletA, reflections);
            }

            totalReflections = totalReflections - reflections;
            reflections = 0;
        }
    }

    /*
     * @notice Deposit reward token
     * @dev Only call by owner. Needs to be for deposit of reward token when reflection token is same with reward token.
     */
    function depositRewards(uint _amount) external onlyOwner nonReentrant {
        require(_amount > 0, "invalid amount");

        uint256 beforeAmt = earnedToken.balanceOf(address(this));
        earnedToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = earnedToken.balanceOf(address(this));

        totalEarned = totalEarned + afterAmt - beforeAmt;
    }

    /*
     * @notice Withdraw reward token
     * @dev Only callable by owner. Needs to be for emergency.
     */
    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
        require( block.number > bonusEndBlock, "Pool is running");
        require(availableRewardTokens() >= _amount, "Insufficient reward tokens");

        earnedToken.safeTransfer(address(msg.sender), _amount);        
        if (totalEarned > 0) {
            if (_amount > totalEarned) {
                totalEarned = 0;
            } else {
                totalEarned = totalEarned - _amount;
            }
        }
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of tokens to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(
            _tokenAddress != address(earnedToken),
            "Cannot be reward token"
        );

        if(_tokenAddress == address(stakingToken)) {
            uint256 tokenBal = stakingToken.balanceOf(address(this));
            require(_tokenAmount <= tokenBal - totalStaked, "Insufficient balance");
        }

        if(_tokenAddress == address(0x0)) {
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
        }

        emit AdminTokenRecovered(_tokenAddress, _tokenAmount);
    }

    function startReward() external onlyOwner {
        require(startBlock == 0, "Pool was already started");

        startBlock = block.number + 100;
        bonusEndBlock = startBlock + duration * 28800;
        for(uint256 i = 0; i < lockups.length; i++) {
            lockups[i].lastRewardBlock = startBlock;
        }
        
        emit NewStartAndEndBlocks(startBlock, bonusEndBlock);
    }

    function stopReward() external onlyOwner {
        bonusEndBlock = block.number;
        emit RewardsStop(bonusEndBlock);
    }

    function updateEndBlock(uint256 _endBlock) external onlyOwner {
        require(startBlock > 0, "Pool is not started");
        require(bonusEndBlock > block.number, "Pool was already finished");
        require(_endBlock > block.number && _endBlock > startBlock, "Invalid end block");
        bonusEndBlock = _endBlock;
        emit EndBlockUpdated(_endBlock);
    }

    /*
     * @notice Update pool limit per user
     * @dev Only callable by owner.
     * @param _hasUserLimit: whether the limit remains forced
     * @param _poolLimitPerUser: new pool limit per user
     */
    function updatePoolLimitPerUser( bool _hasUserLimit, uint256 _poolLimitPerUser) external onlyOwner {
        if (_hasUserLimit) {
            require(
                _poolLimitPerUser > poolLimitPerUser,
                "New limit must be higher"
            );
            poolLimitPerUser = _poolLimitPerUser;
        } else {
            poolLimitPerUser = 0;
        }
        hasUserLimit = _hasUserLimit;

        emit UpdatePoolLimit(poolLimitPerUser, _hasUserLimit);
    }

    function updateLockup(uint8 _stakeType, uint256 _duration, uint256 _depositFee, uint256 _withdrawFee, uint256 _rate) external onlyOwner {
        // require(block.number < startBlock, "Pool was already started");
        require(_stakeType < lockups.length, "Lockup Not found");
        require(_depositFee < 2000, "Invalid deposit fee");
        require(_withdrawFee < 2000, "Invalid withdraw fee");

        _updatePool(_stakeType);

        Lockup storage _lockup = lockups[_stakeType];
        _lockup.duration = _duration;
        _lockup.depositFee = _depositFee;
        _lockup.withdrawFee = _withdrawFee;
        _lockup.rate = _rate;
        
        emit LockupUpdated(_stakeType, _duration, _depositFee, _withdrawFee, _rate);
    }

    function addLockup(uint256 _duration, uint256 _depositFee, uint256 _withdrawFee, uint256 _rate) external onlyOwner {
        require(_depositFee < 2000, "Invalid deposit fee");
        require(_withdrawFee < 2000, "Invalid withdraw fee");
        
        lockups.push();
        
        Lockup storage _lockup = lockups[lockups.length - 1];
        _lockup.duration = _duration;
        _lockup.depositFee = _depositFee;
        _lockup.withdrawFee = _withdrawFee;
        _lockup.rate = _rate;
        _lockup.lastRewardBlock = block.number;

        emit LockupUpdated(uint8(lockups.length - 1), _duration, _depositFee, _withdrawFee, _rate);
    }

    function setServiceInfo(address _addr, uint256 _fee) external {
        require(msg.sender == buyBackWallet, "setServiceInfo: FORBIDDEN");
        require(_addr != address(0x0), "Invalid address");

        buyBackWallet = _addr;
        performanceFee = _fee;

        emit ServiceInfoUpadted(_addr, _fee);
    }
    
    function setDuration(uint256 _duration) external onlyOwner {
        require(startBlock == 0, "Pool was already started");
        require(_duration >= 30, "lower limit reached");

        duration = _duration;
        emit DurationUpdated(_duration);
    }

    function setSettings(
        uint256 _slippageFactor, 
        address _uniRouter, 
        address[] memory _earnedToStakedPath, 
        address[] memory _reflectionToStakedPath,
        address _feeAddr
    ) external onlyOwner {
        require(_slippageFactor <= slippageFactorUL, "_slippageFactor too high");
        require(_feeAddr != address(0x0), "Invalid Address");

        slippageFactor = _slippageFactor;
        uniRouterAddress = _uniRouter;
        reflectionToStakedPath = _reflectionToStakedPath;
        earnedToStakedPath = _earnedToStakedPath;
        walletA = _feeAddr;

        emit SetSettings(_slippageFactor, _uniRouter, _earnedToStakedPath, _reflectionToStakedPath, _feeAddr);
    }


    /************************
    ** Internal Methods
    *************************/
    /*
     * @notice Update reward variables of the given pool to be up-to-date.
     */
    function _updatePool(uint8 _stakeType) internal {
        // calc reflection rate
        if(totalStaked > 0) {
            uint256 reflectionAmount = availableDividendTokens();
            if(reflectionAmount < totalReflections) {
                reflectionAmount = totalReflections;
            }

            uint256 sTokenBal = totalStaked;
            uint256 eTokenBal = availableRewardTokens();
            if(address(stakingToken) == address(earnedToken)) {
                sTokenBal = sTokenBal + eTokenBal;
            }

            accDividendPerShare = accDividendPerShare + (
                (reflectionAmount - totalReflections) * PRECISION_FACTOR_REFLECTION / sTokenBal
            );

            if(address(stakingToken) == address(earnedToken)) {
                reflections = reflections + (reflectionAmount - totalReflections) * eTokenBal / sTokenBal;
            }
            totalReflections = reflectionAmount;
        }

        Lockup storage lockup = lockups[_stakeType];
        if (block.number <= lockup.lastRewardBlock || lockup.lastRewardBlock == 0) return;

        if (lockup.totalStaked == 0) {
            lockup.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = _getMultiplier(lockup.lastRewardBlock, block.number);
        uint256 _reward = multiplier * lockup.rate;
        lockup.accTokenPerShare = lockup.accTokenPerShare + (
            _reward * PRECISION_FACTOR / lockup.totalStaked
        );
        lockup.lastRewardBlock = block.number;
    }

    function estimateDividendAmount(uint256 amount) internal view returns(uint256) {
        uint256 dTokenBal = availableDividendTokens();
        if(amount > totalReflections) amount = totalReflections;
        if(amount > dTokenBal) amount = dTokenBal;
        return amount;
    }

    /*
     * @notice Return reward multiplier over the given _from to _to block.
     * @param _from: block to start
     * @param _to: block to finish
     */
    function _getMultiplier(uint256 _from, uint256 _to)
        internal
        view
        returns (uint256)
    {
        if (_to <= bonusEndBlock) {
            return _to - _from;
        } else if (_from >= bonusEndBlock) {
            return 0;
        } else {
            return bonusEndBlock - _from;
        }
    }

    function _safeSwap(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal returns(uint256){
        uint256[] memory amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length - 1];        
        uint256 _beforeAmount = stakingToken.balanceOf(address(this));
        
        IERC20(_path[0]).safeApprove(uniRouterAddress, _amountIn);
        IUniRouter02(uniRouterAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amountIn,
            amountOut * slippageFactor / 1000,
            _path,
            _to,
            block.timestamp + 600
        );

        uint256 _afterAmount = stakingToken.balanceOf(address(this));
        return _afterAmount - _beforeAmount;
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./libs/IUniRouter02.sol";
import "./libs/IWETH.sol";

interface IToken {
     /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);
}

interface WhiteList {
    function whitelisted(address _address) external view returns (bool);
}

contract BrewlabsLockup is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 private constant PERCENT_PRECISION = 10000;

    // Whether it is initialized
    bool public isInitialized;
    uint256 public duration = 365; // 365 days

    // Whether a limit is set for users
    bool public hasUserLimit;
    // The pool limit (0 if none)
    uint256 public poolLimitPerUser;
    address public whiteList;

    // The block number when staking starts.
    uint256 public startBlock;
    // The block number when staking ends.
    uint256 public bonusEndBlock;

    bool public activeEmergencyWithdraw = false;

    // swap router and path, slipPage
    uint256 public slippageFactor = 8000; // 20% default slippage tolerance
    uint256 public constant slippageFactorUL = 9950;

    address public uniRouterAddress;
    address[] public reflectionToStakedPath;
    address[] public earnedToStakedPath;

    address public walletA;
    address public buyBackWallet = 0x408c4aDa67aE1244dfeC7D609dea3c232843189A;
    uint256 public performanceFee = 0.0035 ether;

    // The precision factor
    uint256 public PRECISION_FACTOR;
    uint256 public PRECISION_FACTOR_REFLECTION;

    // The staked token
    IERC20 public stakingToken;
    // The earned token
    IERC20 public earnedToken;
    // The dividend token of staking token
    address public dividendToken;

    // Accrued token per share
    uint256 public accDividendPerShare;
    uint256 public totalStaked;

    uint256 private totalEarned;
    uint256 private totalReflections;
    uint256 private reflections;

    uint256 private paidRewards;
    uint256 private shouldTotalPaid;

    struct Lockup {
        uint8 stakeType;
        uint256 duration;
        uint256 depositFee;
        uint256 withdrawFee;
        uint256 rate;
        uint256 accTokenPerShare;
        uint256 lastRewardBlock;
        uint256 totalStaked;
        uint256 totalStakedLimit;
    }

    struct UserInfo {
        uint256 amount; // How many staked tokens the user has provided
        uint256 locked;
        uint256 available;
    }

    struct Stake {
        uint8   stakeType;
        uint256 amount;     // amount to stake
        uint256 duration;   // the lockup duration of the stake
        uint256 end;        // when does the staking period end
        uint256 rewardDebt; // Reward debt
        uint256 reflectionDebt; // Reflection debt
    }
    uint256 constant MAX_STAKES = 256;

    Lockup[] public lockups;
    mapping(address => Stake[]) public userStakes;
    mapping(address => UserInfo) public userStaked;

    event Deposit(address indexed user, uint256 stakeType, uint256 amount);
    event Withdraw(address indexed user, uint256 stakeType, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event AdminTokenRecovered(address tokenRecovered, uint256 amount);
    event SetEmergencyWithdrawStatus(bool status);

    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);
    event LockupUpdated(uint8 _type, uint256 _duration, uint256 _fee0, uint256 _fee1, uint256 _rate);
    event RewardsStop(uint256 blockNumber);
    event EndBlockUpdated(uint256 blockNumber);
    event UpdatePoolLimit(uint256 poolLimitPerUser, bool hasLimit);

    event ServiceInfoUpadted(address _addr, uint256 _fee);
    event DurationUpdated(uint256 _duration);
    event SetWhiteList(address _whitelist);

    event SetSettings(
        uint256 _slippageFactor,
        address _uniRouter,
        address[] _path0,
        address[] _path1,
        address _walletA
    );

    constructor() {}

    /*
     * @notice Initialize the contract
     * @param _stakingToken: staked token address
     * @param _earnedToken: earned token address
     * @param _dividendToken: reflection token address
     * @param _uniRouter: uniswap router address for swap tokens
     * @param _earnedToStakedPath: swap path to compound (earned -> staking path)
     * @param _reflectionToStakedPath: swap path to compound (reflection -> staking path)
     */
    function initialize(
        IERC20 _stakingToken,
        IERC20 _earnedToken,
        address _dividendToken,
        address _uniRouter,
        address[] memory _earnedToStakedPath,
        address[] memory _reflectionToStakedPath,
        address _whiteList
    ) external onlyOwner {
        require(!isInitialized, "Already initialized");

        // Make this contract initialized
        isInitialized = true;

        stakingToken = _stakingToken;
        earnedToken = _earnedToken;
        dividendToken = _dividendToken;

        walletA = msg.sender;

        uint256 decimalsRewardToken = uint256(IToken(address(earnedToken)).decimals());
        require(decimalsRewardToken < 30, "Must be inferior to 30");
        PRECISION_FACTOR = uint256(10**(40 - decimalsRewardToken));

        uint256 decimalsdividendToken = 18;
        if(address(dividendToken) != address(0x0)) {
            decimalsdividendToken = uint256(IToken(address(dividendToken)).decimals());
            require(decimalsdividendToken < 30, "Must be inferior to 30");
        }
        PRECISION_FACTOR_REFLECTION = uint256(10**(40 - decimalsRewardToken));

        uniRouterAddress = _uniRouter;
        earnedToStakedPath = _earnedToStakedPath;
        reflectionToStakedPath = _reflectionToStakedPath;
        whiteList = _whiteList;
    }

    /*
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @param _amount: amount to withdraw (in earnedToken)
     */
    function deposit(uint256 _amount, uint8 _stakeType) external payable nonReentrant {
        require(startBlock > 0 && startBlock < block.number, "Staking hasn't started yet");
        require(_amount > 0, "Amount should be greator than 0");
        require(_stakeType < lockups.length, "Invalid stake type");
        if(whiteList != address(0x0)) {
            require(WhiteList(whiteList).whitelisted(msg.sender), "not whitelisted");
        }

        _transferPerformanceFee();
        _updatePool(_stakeType);

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];

        if(lockup.totalStakedLimit > 0) {
            require(lockup.totalStaked < lockup.totalStakedLimit, "Total staked limit exceeded");

            if(lockup.totalStaked + _amount > lockup.totalStakedLimit) {
                _amount = lockup.totalStakedLimit - lockup.totalStaked;
            }
        }

        uint256 pending = 0;
        uint256 pendingReflection = 0;
        for(uint256 j = 0; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            pendingReflection = pendingReflection + (
                stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - stake.reflectionDebt
            );

            uint256 _pending = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR - stake.rewardDebt;
            pending = pending + _pending;

            stake.rewardDebt = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR;
            stake.reflectionDebt = stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            earnedToken.safeTransfer(address(msg.sender), pending);
            _updateEarned(pending);
            paidRewards = paidRewards + pending;
        }

        pendingReflection = estimateDividendAmount(pendingReflection);
        if (pendingReflection > 0) {
            _transferToken(dividendToken, msg.sender, pendingReflection);
            totalReflections = totalReflections - pendingReflection;
        }

        uint256 beforeAmount = stakingToken.balanceOf(address(this));
        stakingToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        uint256 afterAmount = stakingToken.balanceOf(address(this));        
        uint256 realAmount = afterAmount - beforeAmount;
        if(realAmount > _amount) realAmount = _amount;

        if (hasUserLimit) {
            require(
                realAmount + user.amount <= poolLimitPerUser,
                "User amount above limit"
            );
        }
        if (lockup.depositFee > 0) {
            uint256 fee = realAmount * lockup.depositFee / PERCENT_PRECISION;
            if (fee > 0) {
                stakingToken.safeTransfer(walletA, fee);
                realAmount = realAmount - fee;
            }
        }
        
        _addStake(_stakeType, msg.sender, lockup.duration, realAmount);

        user.amount = user.amount + realAmount;
        lockup.totalStaked = lockup.totalStaked + realAmount;
        totalStaked = totalStaked + realAmount;

        emit Deposit(msg.sender, _stakeType, realAmount);
    }

    function _addStake(uint8 _stakeType, address _account, uint256 _duration, uint256 _amount) internal {
        Stake[] storage stakes = userStakes[_account];

        uint256 end = block.timestamp + _duration * 1 days;
        uint256 i = stakes.length;
        require(i < MAX_STAKES, "Max stakes");

        stakes.push(); // grow the array
        // find the spot where we can insert the current stake
        // this should make an increasing list sorted by end
        while (i != 0 && stakes[i - 1].end > end) {
            // shift it back one
            stakes[i] = stakes[i - 1];
            i -= 1;
        }
        
        Lockup storage lockup = lockups[_stakeType];

        // insert the stake
        Stake storage newStake = stakes[i];
        newStake.stakeType = _stakeType;
        newStake.duration = _duration;
        newStake.end = end;
        newStake.amount = _amount;
        newStake.rewardDebt = newStake.amount * lockup.accTokenPerShare / PRECISION_FACTOR;
        newStake.reflectionDebt = newStake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
    }

    /*
     * @notice Withdraw staked tokens and collect reward tokens
     * @param _amount: amount to withdraw (in earnedToken)
     */
    function withdraw(uint256 _amount, uint8 _stakeType) external payable nonReentrant {
        require(_amount > 0, "Amount should be greator than 0");
        require(_stakeType < lockups.length, "Invalid stake type");

        _transferPerformanceFee();
        _updatePool(_stakeType);

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];
        
        uint256 pending = 0;
        uint256 pendingReflection = 0;
        uint256 remained = _amount;
        for(uint256 j = 0; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;
            if(remained == 0) break;

            uint256 _pending = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR - stake.rewardDebt;
            pendingReflection = pendingReflection + (
                stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - stake.reflectionDebt
            );

            pending = pending + _pending;
            if(stake.end < block.timestamp || bonusEndBlock < block.number) {
                if(stake.amount > remained) {
                    stake.amount = stake.amount - remained;
                    remained = 0;
                } else {
                    remained = remained - stake.amount;
                    stake.amount = 0;
                }
            }

            stake.rewardDebt = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR;
            stake.reflectionDebt = stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            earnedToken.safeTransfer(address(msg.sender), pending);
            _updateEarned(pending);
            paidRewards = paidRewards + pending;
        }

        if (pendingReflection > 0) {
            pendingReflection = estimateDividendAmount(pendingReflection);
            _transferToken(dividendToken, msg.sender, pendingReflection);
            totalReflections = totalReflections - pendingReflection;
        }

        uint256 realAmount = _amount - remained;
        user.amount = user.amount - realAmount;
        lockup.totalStaked = lockup.totalStaked - realAmount;
        totalStaked = totalStaked - realAmount;

        if(realAmount > 0) {
            if (lockup.withdrawFee > 0) {
                uint256 fee = realAmount * lockup.withdrawFee / PERCENT_PRECISION;
                stakingToken.safeTransfer(walletA, fee);
                realAmount = realAmount - fee;
            }

            stakingToken.safeTransfer(address(msg.sender), realAmount);
        }

        emit Withdraw(msg.sender, _stakeType, realAmount);
    }

    function claimReward(uint8 _stakeType) external payable nonReentrant {
        if(_stakeType >= lockups.length) return;
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool(_stakeType);

        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];

        uint256 pending = 0;
        for(uint256 j = 0; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            uint256 _pending = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR - stake.rewardDebt;
            pending = pending + _pending;

            stake.rewardDebt = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR;
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            earnedToken.safeTransfer(address(msg.sender), pending);
            _updateEarned(pending);
            paidRewards = paidRewards + pending;
        }
    }

    function claimDividend(uint8 _stakeType) external payable nonReentrant {
        if(_stakeType >= lockups.length) return;
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool(_stakeType);

        Stake[] storage stakes = userStakes[msg.sender];

        uint256 pendingReflection = 0;
        for(uint256 j = 0; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            pendingReflection = pendingReflection + (
                stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - stake.reflectionDebt
            );

            stake.reflectionDebt = stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
        }

        pendingReflection = estimateDividendAmount(pendingReflection);
        if (pendingReflection > 0) {
            _transferToken(dividendToken, msg.sender, pendingReflection);
            totalReflections = totalReflections - pendingReflection;
        }
    }

    function compoundReward(uint8 _stakeType) external payable nonReentrant {
        if(_stakeType >= lockups.length) return;
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool(_stakeType);

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];

        uint256 pending = 0;
        uint256 compounded = 0;
        for(uint256 j = 0; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            uint256 _pending = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR - stake.rewardDebt;
            pending = pending + _pending;

            if(address(stakingToken) != address(earnedToken) && _pending > 0) {
                uint256 _beforeAmount = stakingToken.balanceOf(address(this));
                _safeSwap(_pending, earnedToStakedPath, address(this));
                uint256 _afterAmount = stakingToken.balanceOf(address(this));
                _pending = _afterAmount - _beforeAmount;
            }
            compounded = compounded + _pending;

            stake.amount = stake.amount + _pending;
            stake.rewardDebt = stake.amount * lockup.accTokenPerShare / PRECISION_FACTOR;
            stake.reflectionDebt = stake.reflectionDebt + _pending * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
        }

        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            _updateEarned(pending);
            paidRewards = paidRewards + pending;

            user.amount = user.amount + compounded;
            lockup.totalStaked = lockup.totalStaked + compounded;
            totalStaked = totalStaked + compounded;

            emit Deposit(msg.sender, _stakeType, compounded);
        }
    }

    function compoundDividend(uint8 _stakeType) external payable nonReentrant {
        if(_stakeType >= lockups.length) return;
        if(startBlock == 0) return;

        _transferPerformanceFee();
        _updatePool(_stakeType);

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];

        uint256 compounded = 0;
        for(uint256 j = 0; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            uint256 _pending = stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION - stake.reflectionDebt;
            _pending = estimateDividendAmount(_pending);

            totalReflections = totalReflections - _pending;
            if(address(stakingToken) != address(dividendToken) && _pending > 0) {
                if(address(dividendToken) == address(0x0)) {
                    address wethAddress = IUniRouter02(uniRouterAddress).WETH();
                    IWETH(wethAddress).deposit{ value: _pending }();
                }

                uint256 _beforeAmount = stakingToken.balanceOf(address(this));
                _safeSwap(_pending, reflectionToStakedPath, address(this));
                uint256 _afterAmount = stakingToken.balanceOf(address(this));

                _pending = _afterAmount - _beforeAmount;
            }
            
            compounded = compounded + _pending;
            stake.amount = stake.amount + _pending;
            stake.rewardDebt = stake.rewardDebt + _pending * lockup.accTokenPerShare / PRECISION_FACTOR;
            stake.reflectionDebt = stake.amount * accDividendPerShare / PRECISION_FACTOR_REFLECTION;
        }

        if (compounded > 0) {
            user.amount = user.amount + compounded;
            lockup.totalStaked = lockup.totalStaked + compounded;
            totalStaked = totalStaked + compounded;

            emit Deposit(msg.sender, _stakeType, compounded);
        }
    }

    function _transferPerformanceFee() internal {
        require(msg.value >= performanceFee, 'should pay small gas to compound or harvest');

        payable(buyBackWallet).transfer(performanceFee);
        if(msg.value > performanceFee) {
            payable(msg.sender).transfer(msg.value - performanceFee);
        }
    }

    /*
     * @notice Withdraw staked tokens without caring about rewards
     * @dev Needs to be for emergency.
     */
    function emergencyWithdraw(uint8 _stakeType) external nonReentrant {
        require(activeEmergencyWithdraw, "Emergnecy withdraw not enabled");
        if(_stakeType >= lockups.length) return;

        UserInfo storage user = userStaked[msg.sender];
        Stake[] storage stakes = userStakes[msg.sender];
        Lockup storage lockup = lockups[_stakeType];

        uint256 amountToTransfer = 0;
        for(uint256 j = 0; j < stakes.length; j++) {
            Stake storage stake = stakes[j];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            amountToTransfer = amountToTransfer + stake.amount;

            stake.amount = 0;
            stake.rewardDebt = 0;
            stake.reflectionDebt = 0;
        }

        if (amountToTransfer > 0) {
            stakingToken.safeTransfer(address(msg.sender), amountToTransfer);

            user.amount = user.amount - amountToTransfer;
            lockup.totalStaked = lockup.totalStaked - amountToTransfer;
            totalStaked = totalStaked - amountToTransfer;
        }

        emit EmergencyWithdraw(msg.sender, amountToTransfer);
    }

    function rewardPerBlock(uint8 _stakeType) external view returns (uint256) {
        if(_stakeType >= lockups.length) return 0;

        return lockups[_stakeType].rate;
    }

    /**
     * @notice Available amount of reward token
     */
    function availableRewardTokens() public view returns (uint256) {
        if(address(earnedToken) == address(dividendToken)) return totalEarned;

        uint256 _amount = earnedToken.balanceOf(address(this));
        if (address(earnedToken) == address(stakingToken)) {
            if (_amount < totalStaked) return 0;
            return _amount - totalStaked;
        }

        return _amount;
    }

    /**
     * @notice Available amount of reflection token
     */
    function availableDividendTokens() public view returns (uint256) {
        if(address(dividendToken) == address(0x0)) {
            return address(this).balance;
        }

        uint256 _amount = IERC20(dividendToken).balanceOf(address(this));
        
        if(address(dividendToken) == address(earnedToken)) {
            if(_amount < totalEarned) return 0;
            _amount = _amount - totalEarned;
        }

        if(address(dividendToken) == address(stakingToken)) {
            if(_amount < totalStaked) return 0;
            _amount = _amount - totalStaked;
        }

        return _amount;
    }

    function insufficientRewards() external view returns (uint256) {
        uint256 adjustedShouldTotalPaid = shouldTotalPaid;
        uint256 remainRewards = availableRewardTokens() + paidRewards;

        for(uint i = 0; i < lockups.length; i++) {
            if(startBlock == 0) {
                adjustedShouldTotalPaid = adjustedShouldTotalPaid + lockups[i].rate * duration * 28800;
            } else {
                uint256 remainBlocks = _getMultiplier(lockups[i].lastRewardBlock, bonusEndBlock);
                adjustedShouldTotalPaid = adjustedShouldTotalPaid + lockups[i].rate * remainBlocks;
            }
        }

        if(remainRewards >= adjustedShouldTotalPaid) return 0;

        return adjustedShouldTotalPaid - remainRewards;
    }

    function userInfo(uint8 _stakeType, address _account) external view returns (uint256 amount, uint256 available, uint256 locked) {
        Stake[] memory stakes = userStakes[_account];
        
        for(uint256 i = 0; i < stakes.length; i++) {
            Stake memory stake = stakes[i];

            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;
            
            amount = amount + stake.amount;
            if(block.timestamp > stake.end || bonusEndBlock < block.number) {
                available = available + stake.amount;
            } else {
                locked = locked + stake.amount;
            }
        }
    }

    /*
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @return Pending reward for a given user
     */
    function pendingReward(address _account, uint8 _stakeType) external view returns (uint256) {
        if(_stakeType >= lockups.length || startBlock == 0) return 0;

        Stake[] memory stakes = userStakes[_account];
        Lockup memory lockup = lockups[_stakeType];

        if(lockup.totalStaked == 0) return 0;
        
        uint256 adjustedTokenPerShare = lockup.accTokenPerShare;
        if (block.number > lockup.lastRewardBlock && lockup.totalStaked != 0 && lockup.lastRewardBlock > 0) {
            uint256 multiplier = _getMultiplier(lockup.lastRewardBlock, block.number);
            uint256 reward = multiplier * lockup.rate;

            adjustedTokenPerShare = lockup.accTokenPerShare + reward * PRECISION_FACTOR / lockup.totalStaked;
        }

        uint256 pending = 0;
        for(uint256 i = 0; i < stakes.length; i++) {
            Stake memory stake = stakes[i];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            pending = pending + (
                    stake.amount * adjustedTokenPerShare / PRECISION_FACTOR - stake.rewardDebt
                );
        }
        return pending;
    }

    function pendingDividends(address _account, uint8 _stakeType) external view returns (uint256) {
        if(_stakeType >= lockups.length) return 0;
        if(startBlock == 0 || totalStaked == 0) return 0;

        Stake[] memory stakes = userStakes[_account];
        
        uint256 reflectionAmount = availableDividendTokens();
        if(reflectionAmount < totalReflections) {
            reflectionAmount = totalReflections;
        }

        uint256 sTokenBal = totalStaked;
        uint256 eTokenBal = availableRewardTokens();
        if(address(stakingToken) == address(earnedToken)) {
            sTokenBal = sTokenBal + eTokenBal;
        }

        uint256 adjustedReflectionPerShare = accDividendPerShare + ( 
            (reflectionAmount - totalReflections) * PRECISION_FACTOR_REFLECTION / sTokenBal
        );
        
        uint256 pendingReflection = 0;
        for(uint256 i = 0; i < stakes.length; i++) {
            Stake memory stake = stakes[i];
            if(stake.stakeType != _stakeType) continue;
            if(stake.amount == 0) continue;

            pendingReflection = pendingReflection + (
                stake.amount * adjustedReflectionPerShare / PRECISION_FACTOR_REFLECTION - stake.reflectionDebt
            );
        }
        return pendingReflection;
    }

    /************************
    ** Admin Methods
    *************************/
    function harvest() external onlyOwner {
        _updatePool(0);

        reflections = estimateDividendAmount(reflections);
        if(reflections > 0) {
            _transferToken(dividendToken, walletA, reflections);
            totalReflections = totalReflections - reflections;
            reflections = 0;
        }
    }

    /*
     * @notice Deposit reward token
     * @dev Only call by owner. Needs to be for deposit of reward token when reflection token is same with reward token.
     */
    function depositRewards(uint _amount) external onlyOwner nonReentrant {
        require(_amount > 0, "invalid amount");

        uint256 beforeAmt = earnedToken.balanceOf(address(this));
        earnedToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = earnedToken.balanceOf(address(this));

        totalEarned = totalEarned + afterAmt - beforeAmt;
    }

    function increaseEmissionRate(uint8 _stakeType, uint256 _amount) external onlyOwner {
        require(startBlock > 0, "pool is not started");
        require(bonusEndBlock > block.number, "pool was already finished");
        require(_amount > 0, "invalid amount");
        
        _updatePool(_stakeType);

        uint256 beforeAmt = earnedToken.balanceOf(address(this));
        earnedToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = earnedToken.balanceOf(address(this));

        totalEarned = totalEarned + afterAmt - beforeAmt;

        uint256 remainRewards = availableRewardTokens() + paidRewards;
        uint256 adjustedShouldTotalPaid = shouldTotalPaid;
        for(uint i = 0; i < lockups.length; i++) {
            if(i == _stakeType) continue;

            if(startBlock == 0) {
                adjustedShouldTotalPaid = adjustedShouldTotalPaid + lockups[i].rate * duration * 28800;
            } else {
                uint256 remainBlocks = _getMultiplier(lockups[i].lastRewardBlock, bonusEndBlock);
                adjustedShouldTotalPaid = adjustedShouldTotalPaid + lockups[i].rate * remainBlocks;
            }
        }

        if(remainRewards > shouldTotalPaid) {
            remainRewards = remainRewards - adjustedShouldTotalPaid;

            uint256 remainBlocks = bonusEndBlock - block.number;
            lockups[_stakeType].rate = remainRewards / remainBlocks;
            emit LockupUpdated(_stakeType, lockups[_stakeType].duration, lockups[_stakeType].depositFee, lockups[_stakeType].withdrawFee, lockups[_stakeType].rate);
        }
    }

    /*
     * @notice Withdraw reward token
     * @dev Only callable by owner. Needs to be for emergency.
     */
    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
        require( block.number > bonusEndBlock, "Pool is running");
        require(availableRewardTokens() >= _amount, "Insufficient reward tokens");

        earnedToken.safeTransfer(address(msg.sender), _amount);        
        if (totalEarned > 0) {
            if (_amount > totalEarned) {
                totalEarned = 0;
            } else {
                totalEarned = totalEarned - _amount;
            }
        }
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of tokens to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(
            _tokenAddress != address(earnedToken),
            "Cannot be reward token"
        );

        if(_tokenAddress == address(stakingToken)) {
            uint256 tokenBal = stakingToken.balanceOf(address(this));
            require(_tokenAmount <= tokenBal - totalStaked, "Insufficient balance");
        }

        if(_tokenAddress == address(0x0)) {
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
        }

        emit AdminTokenRecovered(_tokenAddress, _tokenAmount);
    }

    function startReward() external onlyOwner {
        require(startBlock == 0, "Pool was already started");

        startBlock = block.number + 100;
        bonusEndBlock = startBlock + duration * 28800;
        for(uint256 i = 0; i < lockups.length; i++) {
            lockups[i].lastRewardBlock = startBlock;
        }
        
        emit NewStartAndEndBlocks(startBlock, bonusEndBlock);
    }

    function stopReward() external onlyOwner {
        for(uint8 i = 0; i < lockups.length; i++) {
            _updatePool(i);
        }

        uint256 remainRewards = availableRewardTokens() + paidRewards;
        if(remainRewards > shouldTotalPaid) {
            remainRewards = remainRewards - shouldTotalPaid;
            earnedToken.transfer(msg.sender, remainRewards);
            _updateEarned(remainRewards);
        }

        bonusEndBlock = block.number;
        emit RewardsStop(bonusEndBlock);
    }

    function updateEndBlock(uint256 _endBlock) external onlyOwner {
        require(startBlock > 0, "Pool is not started");
        require(bonusEndBlock > block.number, "Pool was already finished");
        require(_endBlock > block.number && _endBlock > startBlock, "Invalid end block");
        bonusEndBlock = _endBlock;
        emit EndBlockUpdated(_endBlock);
    }

    /*
     * @notice Update pool limit per user
     * @dev Only callable by owner.
     * @param _hasUserLimit: whether the limit remains forced
     * @param _poolLimitPerUser: new pool limit per user
     */
    function updatePoolLimitPerUser( bool _hasUserLimit, uint256 _poolLimitPerUser) external onlyOwner {
        if (_hasUserLimit) {
            require(
                _poolLimitPerUser > poolLimitPerUser,
                "New limit must be higher"
            );
            poolLimitPerUser = _poolLimitPerUser;
        } else {
            poolLimitPerUser = 0;
        }
        hasUserLimit = _hasUserLimit;

        emit UpdatePoolLimit(poolLimitPerUser, _hasUserLimit);
    }

    function updateLockup(uint8 _stakeType, uint256 _duration, uint256 _depositFee, uint256 _withdrawFee, uint256 _rate, uint256 _totalStakedLimit) external onlyOwner {
        // require(block.number < startBlock, "Pool was already started");
        require(_stakeType < lockups.length, "Lockup Not found");
        require(_depositFee < 2000, "Invalid deposit fee");
        require(_withdrawFee < 2000, "Invalid withdraw fee");

        _updatePool(_stakeType);

        Lockup storage _lockup = lockups[_stakeType];
        _lockup.duration = _duration;
        _lockup.depositFee = _depositFee;
        _lockup.withdrawFee = _withdrawFee;
        _lockup.rate = _rate;
        _lockup.totalStakedLimit = _totalStakedLimit;
        
        emit LockupUpdated(_stakeType, _duration, _depositFee, _withdrawFee, _rate);
    }

    function addLockup(uint256 _duration, uint256 _depositFee, uint256 _withdrawFee, uint256 _rate, uint256 _totalStakedLimit) external onlyOwner {
        require(_depositFee < 2000, "Invalid deposit fee");
        require(_withdrawFee < 2000, "Invalid withdraw fee");
        
        lockups.push();
        
        Lockup storage _lockup = lockups[lockups.length - 1];
        _lockup.stakeType = uint8(lockups.length - 1);
        _lockup.duration = _duration;
        _lockup.depositFee = _depositFee;
        _lockup.withdrawFee = _withdrawFee;
        _lockup.rate = _rate;
        _lockup.lastRewardBlock = block.number;
        _lockup.totalStakedLimit = _totalStakedLimit;

        emit LockupUpdated(uint8(lockups.length - 1), _duration, _depositFee, _withdrawFee, _rate);
    }

    function setServiceInfo(address _addr, uint256 _fee) external {
        require(msg.sender == buyBackWallet, "setServiceInfo: FORBIDDEN");
        require(_addr != address(0x0), "Invalid address");

        buyBackWallet = _addr;
        performanceFee = _fee;

        emit ServiceInfoUpadted(_addr, _fee);
    }

    function setEmergencyWithdraw(bool _status) external {
        require(msg.sender == buyBackWallet || msg.sender == owner(), "setEmergencyWithdraw: FORBIDDEN");

        activeEmergencyWithdraw = _status;
        emit SetEmergencyWithdrawStatus(_status);
    }
    
    function setDuration(uint256 _duration) external onlyOwner {
        require(startBlock == 0, "Pool was already started");
        require(_duration >= 30, "lower limit reached");

        duration = _duration;
        emit DurationUpdated(_duration);
    }

    function setSettings(
        uint256 _slippageFactor, 
        address _uniRouter, 
        address[] memory _earnedToStakedPath, 
        address[] memory _reflectionToStakedPath,
        address _feeAddr
    ) external onlyOwner {
        require(_slippageFactor <= slippageFactorUL, "_slippageFactor too high");
        require(_feeAddr != address(0x0), "Invalid Address");

        slippageFactor = _slippageFactor;
        uniRouterAddress = _uniRouter;
        reflectionToStakedPath = _reflectionToStakedPath;
        earnedToStakedPath = _earnedToStakedPath;
        walletA = _feeAddr;

        emit SetSettings(_slippageFactor, _uniRouter, _earnedToStakedPath, _reflectionToStakedPath, _feeAddr);
    }

    function setWhitelist(address _whitelist) external onlyOwner {
        whiteList = _whitelist;
        emit SetWhiteList(_whitelist);
    }


    /************************
    ** Internal Methods
    *************************/
    /*
     * @notice Update reward variables of the given pool to be up-to-date.
     */
    function _updatePool(uint8 _stakeType) internal {
        // calc reflection rate
        if(totalStaked > 0) {
            uint256 reflectionAmount = availableDividendTokens();
            if(reflectionAmount < totalReflections) {
                reflectionAmount = totalReflections;
            }

            uint256 sTokenBal = totalStaked;
            uint256 eTokenBal = availableRewardTokens();
            if(address(stakingToken) == address(earnedToken)) {
                sTokenBal = sTokenBal + eTokenBal;
            }

            accDividendPerShare = accDividendPerShare + (
                (reflectionAmount - totalReflections) * PRECISION_FACTOR_REFLECTION / sTokenBal
            );

            if(address(stakingToken) == address(earnedToken)) {
                reflections = reflections + (reflectionAmount - totalReflections) * eTokenBal / sTokenBal;
            }
            totalReflections = reflectionAmount;
        }

        Lockup storage lockup = lockups[_stakeType];
        if (block.number <= lockup.lastRewardBlock || lockup.lastRewardBlock == 0) return;

        if (lockup.totalStaked == 0) {
            lockup.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = _getMultiplier(lockup.lastRewardBlock, block.number);
        uint256 _reward = multiplier * lockup.rate;
        lockup.accTokenPerShare = lockup.accTokenPerShare + (
            _reward * PRECISION_FACTOR / lockup.totalStaked
        );
        lockup.lastRewardBlock = block.number;
        shouldTotalPaid = shouldTotalPaid + _reward;
    }

    function estimateDividendAmount(uint256 amount) internal view returns(uint256) {
        uint256 dTokenBal = availableDividendTokens();
        if(amount > totalReflections) amount = totalReflections;
        if(amount > dTokenBal) amount = dTokenBal;
        return amount;
    }

    /*
     * @notice Return reward multiplier over the given _from to _to block.
     * @param _from: block to start
     * @param _to: block to finish
     */
    function _getMultiplier(uint256 _from, uint256 _to)
        internal
        view
        returns (uint256)
    {
        if (_to <= bonusEndBlock) {
            return _to - _from;
        } else if (_from >= bonusEndBlock) {
            return 0;
        } else {
            return bonusEndBlock - _from;
        }
    }

    function _transferToken(address _token, address _to, uint256 _amount) internal {
        if(_token == address(0x0)) {
            payable(_to).transfer(_amount);
        } else {
            IERC20(_token).transfer(_to, _amount);
        }
    }

    function _updateEarned(uint256 _amount) internal {
        if(totalEarned > _amount) {
            totalEarned = totalEarned - _amount;
        } else {
            totalEarned = 0;
        }
    }

    function _safeSwap(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal {
        uint256[] memory amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length - 1];

        IERC20(_path[0]).safeApprove(uniRouterAddress, _amountIn);
        IUniRouter02(uniRouterAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _amountIn,
            amountOut * slippageFactor / PERCENT_PRECISION,
            _path,
            _to,
            block.timestamp + 600
        );
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./libs/IUniFactory.sol";
import "./libs/IUniRouter02.sol";
import "./libs/IWETH.sol";

contract BrewlabsLiquidityManager is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public uniRouterAddress;

    uint256 public fee = 100; // 1%
    address public treasury = 0x408c4aDa67aE1244dfeC7D609dea3c232843189A;
    address public walletA = 0xE1f1dd010BBC2860F81c8F90Ea4E38dB949BB16F;

    address public wethAddress;
    address[] public wethToBrewsPath;
    uint256 public slippageFactor = 9500; // 5% default slippage tolerance
    uint256 public constant slippageFactorUL = 8000;
    
    bool public buyBackBurn = false;
    uint256 public buyBackLimit = 1 ether;
    address public constant buyBackAddress = 0x000000000000000000000000000000000000dEaD;
    
    event WalletAUpdated(address _addr);
    event FeeUpdated(uint256 _fee);
    event BuyBackStatusChanged(bool _status);
    event BuyBackLimitUpdated(uint256 _limit);
    event AdminTokenRecovered(address tokenRecovered, uint256 amount);

    constructor() {}

    function initialize(
        address _uniRouterAddress,
        address[] memory _wethToBrewsPath
    ) external onlyOwner {
        require(_uniRouterAddress != address(0x0), "Invalid address");
        
        uniRouterAddress = _uniRouterAddress;
        wethToBrewsPath = _wethToBrewsPath;

        wethAddress = IUniRouter02(uniRouterAddress).WETH();
    }

    function addLiquidity(address token0, address token1, uint256 _amount0, uint256 _amount1, uint256 _slipPage) external payable nonReentrant returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
        require(_amount0 > 0 && _amount1 > 0, "amount is zero");
        require(_slipPage < 10000, "slippage cannot exceed 100%");
        require(token0 != token1, "cannot use same token for pair");

        uint256 beforeAmt = IERC20(token0).balanceOf(address(this));
        IERC20(token0).transferFrom(msg.sender, address(this), _amount0);
        uint256 token0Amt = IERC20(token0).balanceOf(address(this)).sub(beforeAmt);
        token0Amt = token0Amt.mul(10000 - fee).div(10000);

        beforeAmt = IERC20(token1).balanceOf(address(this));
        IERC20(token1).transferFrom(msg.sender, address(this), _amount1);
        uint256 token1Amt = IERC20(token1).balanceOf(address(this)).sub(beforeAmt);
        token1Amt = token1Amt.mul(10000 - fee).div(10000);
        
        (amountA, amountB, liquidity) = _addLiquidity( token0, token1, token0Amt, token1Amt, _slipPage);

        token0Amt = IERC20(token0).balanceOf(address(this));
        token1Amt = IERC20(token1).balanceOf(address(this));
        IERC20(token0).transfer(walletA, token0Amt);
        IERC20(token1).transfer(walletA, token1Amt);
    }

    function _addLiquidity(address token0, address token1, uint256 _amount0, uint256 _amount1, uint256 _slipPage) internal returns (uint256, uint256, uint256) {
        IERC20(token0).safeIncreaseAllowance(uniRouterAddress, _amount0);
        IERC20(token1).safeIncreaseAllowance(uniRouterAddress, _amount1);

        return IUniRouter02(uniRouterAddress).addLiquidity(
                token0,
                token1,
                _amount0,
                _amount1,
                _amount0.mul(10000 - _slipPage).div(10000),
                _amount1.mul(10000 - _slipPage).div(10000),
                msg.sender,
                block.timestamp.add(600)
            );
    }

    function addLiquidityETH(address token, uint256 _amount, uint256 _slipPage) external payable nonReentrant returns (uint256 amountToken, uint256 amountETH, uint256 liquidity) {
        require(_amount > 0, "amount is zero");
        require(_slipPage < 10000, "slippage cannot exceed 100%");
        require(msg.value > 0, "amount is zero");

        uint256 beforeAmt = IERC20(token).balanceOf(address(this));
        IERC20(token).transferFrom(msg.sender, address(this), _amount);
        uint256 tokenAmt = IERC20(token).balanceOf(address(this)).sub(beforeAmt);
        tokenAmt = tokenAmt.mul(10000 - fee).div(10000);

        uint256 ethAmt = msg.value;
        ethAmt = ethAmt.mul(10000 - fee).div(10000);
    
        IERC20(token).safeIncreaseAllowance(uniRouterAddress, tokenAmt);        
        (amountToken, amountETH, liquidity) = _addLiquidityETH(token, tokenAmt, ethAmt, _slipPage);

        tokenAmt = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(walletA, tokenAmt);

        if(buyBackBurn) {
            buyBack();
        } else {
            ethAmt = address(this).balance;
            payable(treasury).transfer(ethAmt);
        }
    }

    function _addLiquidityETH(address token, uint256 _amount, uint256 _ethAmt, uint256 _slipPage) internal returns (uint256, uint256, uint256) {
        IERC20(token).safeIncreaseAllowance(uniRouterAddress, _amount);        
        
        return IUniRouter02(uniRouterAddress).addLiquidityETH{value: _ethAmt}(
            token,
            _amount,
            _amount.mul(10000 - _slipPage).div(10000),
            _ethAmt.mul(10000 - _slipPage).div(10000),
            msg.sender,
            block.timestamp.add(600)
        );
    }

    function removeLiquidity(address token0, address token1, uint256 _amount) external nonReentrant returns (uint256 amountA, uint256 amountB){
        require(_amount > 0, "amount is zero");
        
        address pair = getPair(token0, token1);
        IERC20(pair).transferFrom(msg.sender, address(this), _amount);
        IERC20(pair).safeIncreaseAllowance(uniRouterAddress, _amount);

        uint256 beforeAmt0 = IERC20(token0).balanceOf(address(this));
        uint256 beforeAmt1 = IERC20(token1).balanceOf(address(this));                
        IUniRouter02(uniRouterAddress).removeLiquidity(
            token0,
            token1,
            _amount,
            0,
            0,
            address(this),
            block.timestamp.add(600)
        );
        uint256 afterAmt0 = IERC20(token0).balanceOf(address(this));
        uint256 afterAmt1 = IERC20(token1).balanceOf(address(this));

        amountA = afterAmt0.sub(beforeAmt0);
        amountB = afterAmt1.sub(beforeAmt1);
        IERC20(token0).safeTransfer(msg.sender, amountA.mul(10000 - fee).div(10000));
        IERC20(token1).safeTransfer(msg.sender, amountB.mul(10000 - fee).div(10000));

        IERC20(token0).transfer(walletA, amountA.mul(fee).div(10000));
        IERC20(token1).transfer(walletA, amountB.mul(fee).div(10000));

        amountA = amountA.mul(10000 - fee).div(10000);
        amountB = amountB.mul(10000 - fee).div(10000);
    }

    function removeLiquidityETH(address token, uint256 _amount) external nonReentrant returns (uint256 amountToken, uint256 amountETH){
        require(_amount > 0, "amount is zero");
        
        address pair = getPair(token, wethAddress);
        IERC20(pair).transferFrom(msg.sender, address(this), _amount);
        IERC20(pair).safeIncreaseAllowance(uniRouterAddress, _amount);
        
        uint256 beforeAmt0 = IERC20(token).balanceOf(address(this));
        uint256 beforeAmt1 = address(this).balance;        
        IUniRouter02(uniRouterAddress).removeLiquidityETH(
            token,
            _amount,
            0,
            0,
            address(this),                
            block.timestamp.add(600)
        );
        uint256 afterAmt0 = IERC20(token).balanceOf(address(this));
        uint256 afterAmt1 = address(this).balance;
        
        amountToken = afterAmt0.sub(beforeAmt0);
        amountETH = afterAmt1.sub(beforeAmt1);
        IERC20(token).safeTransfer(msg.sender, amountToken.mul(10000 - fee).div(10000));
        payable(msg.sender).transfer(amountETH.mul(10000 - fee).div(10000));

        IERC20(token).transfer(walletA, amountToken.mul(fee).div(10000));
        payable(treasury).transfer(amountETH.mul(fee).div(10000));

        amountToken = amountToken.mul(10000 - fee).div(10000);
        amountETH = amountETH.mul(10000 - fee).div(10000);
    }

    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint256 _amount) external nonReentrant returns (uint256 amountETH){
        require(_amount > 0, "amount is zero");
        
        address pair = getPair(token, wethAddress);
        IERC20(pair).transferFrom(msg.sender, address(this), _amount);
        IERC20(pair).safeIncreaseAllowance(uniRouterAddress, _amount);

        uint256 beforeAmt0 = IERC20(token).balanceOf(address(this));
        uint256 beforeAmt1 = address(this).balance;
        IUniRouter02(uniRouterAddress).removeLiquidityETHSupportingFeeOnTransferTokens(
            token,
            _amount,
            0,
            0,
            address(this),
            block.timestamp.add(600)
        );
        uint256 afterAmt0 = IERC20(token).balanceOf(address(this));
        uint256 afterAmt1 = address(this).balance;
        
        uint256 amountToken = afterAmt0.sub(beforeAmt0);
        amountETH = afterAmt1.sub(beforeAmt1);
        IERC20(token).safeTransfer(msg.sender, amountToken.mul(10000 - fee).div(10000));
        payable(msg.sender).transfer(amountETH.mul(10000 - fee).div(10000));

        IERC20(token).transfer(walletA, amountToken.mul(fee).div(10000));
        payable(treasury).transfer(amountETH.mul(fee).div(10000));

        amountToken = amountToken.mul(10000 - fee).div(10000);
        amountETH = amountETH.mul(10000 - fee).div(10000);
    }
   
    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of tokens to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        if(_tokenAddress == address(0x0)) {
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);
        }

        emit AdminTokenRecovered(_tokenAddress, _tokenAmount);
    }

    function updateWalletA(address _walletA) external onlyOwner {
        require(_walletA != address(0x0) || _walletA != walletA, "Invalid address");

        walletA = _walletA;
        emit WalletAUpdated(_walletA);
    }

    function updateFee(uint256 _fee) external onlyOwner {
        require(_fee < 2000, "fee cannot exceed 20%");

        fee = _fee;
        emit FeeUpdated(_fee);
    }

    function setBuyBackStatus(bool _status) external onlyOwner {
        buyBackBurn = _status;

        uint256 ethAmt = address(this).balance;
        if(ethAmt > 0 && _status == false) {
            payable(walletA).transfer(ethAmt);
        }

        emit BuyBackStatusChanged(_status);
    }

    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0x0), "Invalid address");
        treasury = _treasury;
    }

    function updateBuyBackLimit(uint256 _limit) external onlyOwner {
        require(_limit > 0, "Invalid amount");

        buyBackLimit = _limit;
        emit BuyBackLimitUpdated(_limit);
    }

    function buyBack() internal {
        uint256 wethAmt = address(this).balance;

        if(wethAmt > buyBackLimit) {
             _safeSwapWeth(
                wethAmt,
                wethToBrewsPath,
                buyBackAddress
            );
        }
    }

    function _safeSwapWeth(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal {
        uint256[] memory amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length.sub(1)];

        IUniRouter02(uniRouterAddress).swapExactETHForTokens{value: _amountIn}(
            amountOut.mul(slippageFactor).div(10000),
            _path,
            _to,
            block.timestamp.add(600)
        );
    }

    function getPair(address token0, address token1) public view returns (address) {
        address factory = IUniRouter02(uniRouterAddress).factory();
        return IUniV2Factory(factory).getPair(token0, token1);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockErc20 is ERC20 {
  constructor() ERC20("Test", "TEST") {}

  function mintTo(address _to, uint256 _amount) external {
    _mint(_to, _amount);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This contract has been developed by brewlabs.info
 */
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

interface IToken {
    function claim() external;
    function decimals() external view returns (uint256);
}

contract TeamLocker is Ownable{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool public isActive = false;
    bool private initialized = false;

    IERC20 public token;

    address public  reflectionToken;
    uint256 private accReflectionPerShare;
    uint256 private allocatedReflections;

    uint256 public vestingDuration = 365;

    uint256 private PRECISION_FACTOR = 1 ether;

    struct Distribution {
        address distributor;        // distributor address
        uint256 alloc;              // allocation token amount
        uint256 duration;           // distributor can unlock after duration in day 
        uint256 unlockRate;         // distributor can unlock amount as much as unlockRate(in wei) per block after duration
        uint256 lastClaimBlock;     // last claimed block number
        uint256 tokenDebt;          // claimed token amount
        uint256 reflectionDebt;     
    }
   
    mapping(address => Distribution) public distributions;
    mapping(address => bool) isDistributor;
    address[] public distributors;

    event AddDistribution(address distributor, uint256 allocation, uint256 duration, uint256 unlockRate);
    event UpdateDistribution(address distributor, uint256 allocation, uint256 duration, uint256 unlockRate);
    event RemoveDistribution(address distributor);
    event UpdateVestingDuration(uint256 Days);
    event Claim(address distributor, uint256 amount);
        
    modifier onlyActive() {
        require(isActive == true, "not active");
        _;
    }

    constructor () {}

    function initialize(IERC20 _token, address _reflectionToken) external onlyOwner {
        require(initialized == false, "already initialized");
        initialized = true;

        token = _token;
        reflectionToken = _reflectionToken;
    }


    function addDistribution(address distributor, uint256 allocation, uint256 duration) external onlyOwner {
        require(isDistributor[distributor] == false, "already set");

        isDistributor[distributor] = true;
        distributors.push(distributor);

        uint256 allocationAmt = allocation.mul(10**IToken(address(token)).decimals());
        
        Distribution storage _distribution = distributions[distributor];        
        _distribution.distributor = distributor;
        _distribution.alloc = allocationAmt;
        _distribution.duration = duration;
        _distribution.unlockRate = allocationAmt.div(vestingDuration).div(28800);
        _distribution.tokenDebt = 0;

        uint256 firstUnlockBlock = block.number.add(duration.mul(28800));
        _distribution.lastClaimBlock = firstUnlockBlock;

        _distribution.reflectionDebt = allocationAmt.mul(accReflectionPerShare).div(PRECISION_FACTOR);

        emit AddDistribution(distributor, allocationAmt, duration, _distribution.unlockRate);
    }

    function removeDistribution(address distributor) external onlyOwner {
        require(isDistributor[distributor] == true, "Not found");

        isDistributor[distributor] = false;
        
        Distribution storage _distribution = distributions[distributor];
        _distribution.distributor = address(0x0);
        _distribution.alloc = 0;
        _distribution.duration = 0;
        _distribution.unlockRate = 0;
        _distribution.lastClaimBlock = 0;
        _distribution.tokenDebt = 0;
        _distribution.reflectionDebt = 0;

        emit RemoveDistribution(distributor);
    }

    function updateDistribution(address distributor, uint256 allocation, uint256 duration) external onlyOwner {
        require(isDistributor[distributor] == true, "Not found");

        uint256 allocationAmt = allocation.mul(10**IToken(address(token)).decimals());
        Distribution storage _distribution = distributions[distributor];

        require(_distribution.lastClaimBlock > block.number, "cannot update");
        require(_distribution.tokenDebt < allocationAmt, "Allocation should be greater than claimed amount");
        
        _distribution.alloc = allocationAmt;
        _distribution.duration = duration;
        _distribution.unlockRate = allocationAmt.div(vestingDuration).div(28800);

        uint256 firstUnlockBlock = block.number.add(duration.mul(28800));
        _distribution.lastClaimBlock = firstUnlockBlock;

        _distribution.reflectionDebt = allocationAmt.mul(accReflectionPerShare).div(PRECISION_FACTOR);

        emit UpdateDistribution(distributor, allocationAmt, duration, _distribution.unlockRate);
    }

    function claim() external onlyActive {
        require(claimable(msg.sender) == true, "not claimable");
        
        harvest();

        Distribution storage _distribution = distributions[msg.sender];
        
        uint256 amount = _distribution.alloc.sub(_distribution.tokenDebt);
        uint256 claimAmt = _distribution.unlockRate.mul(block.number.sub(_distribution.lastClaimBlock));
        if(claimAmt > amount) claimAmt = amount;

        _distribution.tokenDebt = _distribution.tokenDebt.add(claimAmt);
        _distribution.reflectionDebt = (amount.sub(claimAmt)).mul(accReflectionPerShare).div(PRECISION_FACTOR);
        _distribution.lastClaimBlock = block.number;
        
        token.safeTransfer(_distribution.distributor, claimAmt);

        emit Claim(_distribution.distributor, claimAmt);
    }

    function harvest() public onlyActive {
        if(isDistributor[msg.sender] == false) return;

        _updatePool();

        Distribution storage _distribution = distributions[msg.sender];
        uint256 amount = _distribution.alloc.sub(_distribution.tokenDebt);
        uint256 pending = amount.mul(accReflectionPerShare).div(PRECISION_FACTOR).sub(_distribution.reflectionDebt);

        _distribution.reflectionDebt = amount.mul(accReflectionPerShare).div(PRECISION_FACTOR);

        if(pending > 0) {
            IERC20(reflectionToken).safeTransfer(msg.sender, pending);
            allocatedReflections = allocatedReflections.sub(pending);
        }
    }

    function pendingClaim(address _user) external view returns (uint256) {
        if(isDistributor[_user] == false) return 0;        

        Distribution storage _distribution = distributions[_user];
        if(_distribution.lastClaimBlock >= block.number) return 0;
        
        uint256 amount = _distribution.alloc.sub(_distribution.tokenDebt);
        uint256 claimAmt = _distribution.unlockRate.mul(block.number.sub(_distribution.lastClaimBlock));
        if(claimAmt > amount) claimAmt = amount;

        return amount;
    }

    function pendingReflection(address _user) external view returns (uint256) {
        if(isDistributor[_user] == false) return 0;

        uint256 tokenAmt = token.balanceOf(address(this));
        if(tokenAmt == 0) return 0;

        Distribution storage _distribution = distributions[_user];

        uint256 reflectionAmt = IERC20(reflectionToken).balanceOf(address(this));
        reflectionAmt = reflectionAmt.sub(allocatedReflections);
        uint256 _accReflectionPerShare = accReflectionPerShare.add(reflectionAmt.mul(PRECISION_FACTOR).div(tokenAmt));
        
        uint256 amount = _distribution.alloc.sub(_distribution.tokenDebt);
        uint256 pending = amount.mul(_accReflectionPerShare).div(PRECISION_FACTOR).sub(_distribution.reflectionDebt);

        return pending;
    }

    function claimable(address _user) public view returns (bool) {
        if(isDistributor[_user] == false) return false;
        if(distributions[_user].lastClaimBlock >= block.number) return false;

        Distribution memory _distribution = distributions[_user];
        uint256 amount = _distribution.alloc.sub(_distribution.tokenDebt);
        if(amount > 0) return true;

        return false;
    }

    function setStatus(bool _isActive) external onlyOwner {
        isActive = _isActive;
    }

    function setVestingDuration(uint256 _days) external onlyOwner {
        require(_days > 0, "Invalid duration");

        vestingDuration = _days;
        emit UpdateVestingDuration(_days);
    }

    function emergencyWithdraw() external onlyOwner {
        uint256 tokenAmt = token.balanceOf(address(this));
        if(tokenAmt > 0) {
            token.transfer(msg.sender, tokenAmt);
        }

        uint256 reflectionAmt = IERC20(reflectionToken).balanceOf(address(this));
        if(reflectionAmt > 0) {
            IERC20(reflectionToken).transfer(msg.sender, reflectionAmt);
        }
    }

    function claimDividendFromToken() external {
        IToken(address(token)).claim();
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _token: the address of the token to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _token) external onlyOwner {
        require(_token != address(token) && _token != address(reflectionToken), "Cannot be token & dividend token");

        if(_token == address(0x0)) {
            uint256 _tokenAmount = address(this).balance;
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            uint256 _tokenAmount = IERC20(_token).balanceOf(address(this));
            IERC20(_token).safeTransfer(msg.sender, _tokenAmount);
        }
    }

    function _updatePool() internal {
        uint256 tokenAmt = token.balanceOf(address(this));
        if(tokenAmt == 0) return;

        uint256 reflectionAmt = 0;
        reflectionAmt = IERC20(reflectionToken).balanceOf(address(this));
        reflectionAmt = reflectionAmt.sub(allocatedReflections);

        accReflectionPerShare = accReflectionPerShare.add(reflectionAmt.mul(PRECISION_FACTOR).div(tokenAmt));
        allocatedReflections = allocatedReflections.add(reflectionAmt);
    }
    
    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This contract has been developed by brewlabs.info
 */
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

contract ShitfaceInuTeamLocker is Ownable{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool public isActive = false;
    bool private initialized = false;

    IERC20 public token;
    address public reflectionToken;
    uint256 public totalLocked;

    uint256 public lockDuration = 180; // 180 days
    uint256 private accReflectionPerShare;
    uint256 private allocatedReflections;
    uint256 private processingLimit = 30;

    uint256 private PRECISION_FACTOR = 1 ether;
    uint256 constant MAX_STAKES = 256;

    struct Lock {
        uint256 amount;              // locked amount
        uint256 duration;            // team member can claim after duration in days
        uint256 releaseTime;
    }

    struct UserInfo {
        uint256 amount;         // total locked amount
        uint256 firstIndex;     // first index for unlocked elements
        uint256 reflectionDebt; // Reflection debt
    }
   
    mapping(address => Lock[]) public locks;
    mapping(address => UserInfo) public userInfo;
    address[] public members;
    mapping(address => bool) private isMember;

    event Deposited(address member, uint256 amount, uint256 duration);
    event Released(address member, uint256 amount);
    event LockDurationUpdated(uint256 duration);
        
    modifier onlyActive() {
        require(isActive == true, "not active");
        _;
    }

    constructor () {}

    function initialize(IERC20 _token, address _reflectionToken) external onlyOwner {
        require(initialized == false, "already initialized");
        initialized = true;

        token = _token;
        reflectionToken = _reflectionToken;
    }

    function deposit(uint256 amount) external onlyActive {
        require(amount > 0, "Invalid amount");

        _updatePool();

        UserInfo storage user = userInfo[msg.sender];        
        uint256 pending = user.amount.mul(accReflectionPerShare).div(PRECISION_FACTOR).sub(user.reflectionDebt);
        if (pending > 0) {
            if(reflectionToken == address(0x0)) {
                payable(msg.sender).transfer(pending);
            } else {
                IERC20(reflectionToken).safeTransfer(address(msg.sender), pending);
            }
            allocatedReflections = allocatedReflections.sub(pending);
        }
        
        uint256 beforeAmount = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), amount);
        uint256 afterAmount = token.balanceOf(address(this));
        uint256 realAmount = afterAmount.sub(beforeAmount);
        
        _addLock(msg.sender, realAmount, user.firstIndex);
        
        if(isMember[msg.sender] == false) {
            members.push(msg.sender);
            isMember[msg.sender] = true;
        }

        user.amount = user.amount.add(realAmount);
        user.reflectionDebt = user.amount.mul(accReflectionPerShare).div(PRECISION_FACTOR);

        totalLocked = totalLocked.add(realAmount);

        emit Deposited(msg.sender, amount, lockDuration);
    }

    function _addLock(address _account, uint256 _amount, uint256 firstIndex) internal {
        Lock[] storage _locks = locks[_account];

        uint256 releaseTime = block.timestamp.add(lockDuration.mul(1 days));
        uint256 i = _locks.length;

        require(i < MAX_STAKES, "Max Locks");

        _locks.push(); // grow the array
        // find the spot where we can insert the current stake
        // this should make an increasing list sorted by end
        while (i != 0 && _locks[i - 1].releaseTime > releaseTime && i >= firstIndex) {
            // shift it back one
            _locks[i] = _locks[i - 1];
            i -= 1;
        }
        
        // insert the stake
        Lock storage _lock = _locks[i];
        _lock.amount = _amount;
        _lock.duration = lockDuration;
        _lock.releaseTime = releaseTime;
    }


    function harvest() external onlyActive {
        _updatePool();

        UserInfo storage user = userInfo[msg.sender];        
        uint256 pending = user.amount.mul(accReflectionPerShare).div(PRECISION_FACTOR).sub(user.reflectionDebt);
        if (pending > 0) {
            if(reflectionToken == address(0x0)) {
                payable(msg.sender).transfer(pending);
            } else {
                IERC20(reflectionToken).safeTransfer(address(msg.sender), pending);
            }
            allocatedReflections = allocatedReflections.sub(pending);
        }
        
        user.reflectionDebt = user.amount.mul(accReflectionPerShare).div(PRECISION_FACTOR);
    }

    function release() public onlyActive {
        _updatePool();

        UserInfo storage user = userInfo[msg.sender];
        Lock[] storage _locks = locks[msg.sender];
        
        bool bUpdatable = true;
        uint256 firstIndex = user.firstIndex;
        
        uint256 claimAmt = 0;
        for(uint256 i = user.firstIndex; i < _locks.length; i++) {
            Lock storage _lock = _locks[i];

            if(bUpdatable && _lock.amount == 0) firstIndex = i;
            if(_lock.amount == 0) continue;
            if(_lock.releaseTime > block.timestamp) {
                bUpdatable = false;
                continue;
            }

            if(i - user.firstIndex > processingLimit) break;

            claimAmt = claimAmt.add(_lock.amount);
            _lock.amount = 0;

            firstIndex = i;
        }

        if(claimAmt > 0) {
            token.safeTransfer(msg.sender, claimAmt);
            emit Released(msg.sender, claimAmt);
        }
        
        uint256 reflectionAmt = user.amount.mul(accReflectionPerShare).div(PRECISION_FACTOR).sub(user.reflectionDebt);
        if(reflectionAmt > 0) {
            if(reflectionToken == address(0x0)) {
                payable(msg.sender).transfer(reflectionAmt);
            } else {
                IERC20(reflectionToken).safeTransfer(msg.sender, reflectionAmt);
            }
            allocatedReflections = allocatedReflections.sub(reflectionAmt);
        }

        user.amount = user.amount.sub(claimAmt);
        user.reflectionDebt = user.amount.mul(accReflectionPerShare).div(PRECISION_FACTOR);

        totalLocked = totalLocked.sub(claimAmt);
    }

    function pendingReflection(address _user) external view returns (uint256) {
        if(totalLocked == 0) return 0;

        uint256 reflectionAmt = availableRelectionTokens();
        reflectionAmt = reflectionAmt.sub(allocatedReflections);
        uint256 _accReflectionPerShare = accReflectionPerShare.add(reflectionAmt.mul(PRECISION_FACTOR).div(totalLocked));

        UserInfo memory user = userInfo[_user];
        uint256 pending = user.amount.mul(_accReflectionPerShare).div(PRECISION_FACTOR).sub(user.reflectionDebt);
        return pending;
    }

    function pendingTokens(address _user) public view returns (uint256) {
        Lock[] memory _locks = locks[_user];
        UserInfo memory user = userInfo[_user];

        uint256 claimAmt = 0;
        for(uint256 i = user.firstIndex; i < _locks.length; i++) {
            Lock memory _lock = _locks[i];
            if(_lock.amount == 0) continue;
            if(_lock.releaseTime > block.timestamp) continue;

            claimAmt = claimAmt.add(_lock.amount);
        }

        return claimAmt;
    }

    function totalLockedforUser(address _user) public view returns (uint256) {
        UserInfo memory user = userInfo[_user];
        return user.amount;
    }

    function setStatus(bool _isActive) external onlyOwner {
        isActive = _isActive;
    }

    function updateLockDuration(uint256 _duration) external onlyOwner {
        lockDuration = _duration;
        emit LockDurationUpdated(_duration);
    }

    function setProcessingLimit(uint256 _limit) external onlyOwner {
        require(_limit > 0, "Invalid limit");
        processingLimit = _limit;
    }

    function emergencyWithdraw() external onlyOwner {
        uint256 tokenAmt = token.balanceOf(address(this));
        if(tokenAmt > 0) {
            token.transfer(msg.sender, tokenAmt);
        }

        if(address(token) == reflectionToken) return;

        uint256 reflectionAmt = address(this).balance;
        if(reflectionToken != address(0x0)) {
            reflectionAmt = IERC20(reflectionToken).balanceOf(address(this));
        }

        if(reflectionAmt > 0) {
            if(reflectionToken == address(0x0)) {
                payable(msg.sender).transfer(reflectionAmt);
            } else {
                IERC20(reflectionToken).transfer(msg.sender, reflectionAmt);
            }
        }
    }

    function recoverWrongToken(address _tokenAddress) external onlyOwner {
        require(_tokenAddress != address(token), "Cannot recover locked token");
        require(_tokenAddress != reflectionToken, "Cannot recover reflection token");

        if(_tokenAddress == address(0x0)) {
            uint256 amount = address(this).balance;
            payable(msg.sender).transfer(amount);
        } else {
            uint256 amount = IERC20(_tokenAddress).balanceOf(address(this));
            IERC20(_tokenAddress).safeTransfer(address(msg.sender), amount);
        }
    }

    function availableRelectionTokens() internal view returns (uint256) {
        uint256 _amount = address(this).balance;
        if(reflectionToken != address(0x0)) {
            _amount = IERC20(reflectionToken).balanceOf(address(this));

            if (address(token) == reflectionToken) {
                if (_amount < totalLocked) return 0;            
                return _amount.sub(totalLocked);
            }
        }

        return _amount;
    }

    function _updatePool() internal {
        if(totalLocked == 0) return;

        uint256 reflectionAmt = availableRelectionTokens();
        reflectionAmt = reflectionAmt.sub(allocatedReflections);

        accReflectionPerShare = accReflectionPerShare.add(reflectionAmt.mul(PRECISION_FACTOR).div(totalLocked));
        allocatedReflections = allocatedReflections.add(reflectionAmt);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This contract has been developed by brewlabs.info
 */
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

interface IDividendToken {
    function claim() external;
    function decimals() external view returns (uint8);
}

contract DiversFiTeamLocker is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool public isActive = false;
    bool private initialized = false;

    IERC20 public token;
    address[] public reflectionTokens;

    uint256[] private accReflectionPerShare;
    uint256[] private allocatedReflections;

    uint256[] private PRECISION_FACTOR;

    struct Distribution {
        address distributor;        // distributor address
        uint256 alloc;              // allocation token amount
        uint256 duration;           // distributor can unlock after duration in minutes 
        uint256 unlockRate;         // distributor can unlock amount as much as unlockRate(in wei) per block after duration
        uint256 lastClaimBlock;     // last claimed block number
        uint256 tokenDebt;          // claimed token amount
        uint256[] reflectionDebt;
    }
   
    mapping(address => Distribution) public distributions;
    mapping(address => bool) isDistributor;
    address[] public distributors;

    event AddDistribution(address distributor, uint256 allocation, uint256 duration, uint256 unlockRate);
    event UpdateDistribution(address distributor, uint256 allocation, uint256 duration, uint256 unlockRate);
    event RemoveDistribution(address distributor);
    event Claim(address distributor, uint256 amount);
        
    modifier onlyActive() {
        require(isActive == true, "not active");
        _;
    }

    constructor () {}

    function initialize(IERC20 _token, address[] memory _reflectionTokens) external onlyOwner {
        require(initialized == false, "already initialized");
        initialized = true;

        token = _token;
        for(uint i = 0; i < _reflectionTokens.length; i++) {
            reflectionTokens.push(_reflectionTokens[i]);
            allocatedReflections.push(0);
            accReflectionPerShare.push(0);

            uint256 decimalsdividendToken = 18;
            if(address(_reflectionTokens[i]) != address(0x0)) {
                decimalsdividendToken = uint256(IDividendToken(_reflectionTokens[i]).decimals());
                require(decimalsdividendToken < 30, "Must be inferior to 30");
            }
            PRECISION_FACTOR.push(uint256(10**(uint256(40).sub(decimalsdividendToken))));
        }
    }


    function addDistribution(address distributor, uint256 allocation, uint256 duration, uint256 unlockRate) external onlyOwner {
        require(isDistributor[distributor] == false, "already set");

        isDistributor[distributor] = true;
        distributors.push(distributor);
        
        Distribution storage _distribution = distributions[distributor];        
        _distribution.distributor = distributor;
        _distribution.alloc = allocation;
        _distribution.duration = duration;
        _distribution.unlockRate = unlockRate;
        _distribution.tokenDebt = 0;

        uint256 firstUnlockBlock = block.number.add(duration.mul(20));
        _distribution.lastClaimBlock = firstUnlockBlock;
        
        for(uint i = 0; i < reflectionTokens.length; i++) {
            _distribution.reflectionDebt.push(allocation.mul(accReflectionPerShare[i]).div(PRECISION_FACTOR[i]));
        }

        emit AddDistribution(distributor, allocation, duration, unlockRate);
    }

    function removeDistribution(address distributor) external onlyOwner {
        require(isDistributor[distributor] == true, "Not found");

        isDistributor[distributor] = false;
        
        Distribution storage _distribution = distributions[distributor];
        _distribution.distributor = address(0x0);
        _distribution.alloc = 0;
        _distribution.duration = 0;
        _distribution.unlockRate = 0;
        _distribution.lastClaimBlock = 0;
        _distribution.tokenDebt = 0;

        for(uint i = 0; i < reflectionTokens.length; i++) {
            _distribution.reflectionDebt[i] = 0;
        }

        emit RemoveDistribution(distributor);
    }

    function updateDistribution(address distributor, uint256 allocation, uint256 duration, uint256 unlockRate) external onlyOwner {
        require(isDistributor[distributor] == true, "Not found");

        Distribution storage _distribution = distributions[distributor];

        require(_distribution.lastClaimBlock > block.number, "cannot update");

        _distribution.alloc = allocation;
        _distribution.duration = duration;
        _distribution.unlockRate = unlockRate;

        uint256 firstUnlockBlock = block.number.add(duration.mul(20));
        _distribution.lastClaimBlock = firstUnlockBlock;
        
        for(uint i = 0; i < reflectionTokens.length; i++) {
            _distribution.reflectionDebt[i] = allocation.mul(accReflectionPerShare[i]).div(PRECISION_FACTOR[i]);
        }

        emit UpdateDistribution(distributor, allocation, duration, unlockRate);
    }

    function claim() external onlyActive {
        require(claimable(msg.sender) == true, "not claimable");
        
        harvest();

        Distribution storage _distribution = distributions[msg.sender];
        
        uint256 amount = _distribution.alloc.sub(_distribution.tokenDebt);
        uint256 claimAmt = _distribution.unlockRate.mul(block.number.sub(_distribution.lastClaimBlock));
        if(claimAmt > amount) claimAmt = amount;

        _distribution.tokenDebt = _distribution.tokenDebt.add(claimAmt);
        _distribution.lastClaimBlock = block.number;
        for(uint i = 0; i < reflectionTokens.length; i++) {
            _distribution.reflectionDebt[i] = (amount.sub(claimAmt)).mul(accReflectionPerShare[i]).div(PRECISION_FACTOR[i]);
        }
        
        token.safeTransfer(_distribution.distributor, claimAmt);

        emit Claim(_distribution.distributor, claimAmt);
    }

    function harvest() public onlyActive {
        if(isDistributor[msg.sender] == false) return;

        _updatePool();

        Distribution storage _distribution = distributions[msg.sender];
        uint256 amount = _distribution.alloc.sub(_distribution.tokenDebt);
        for(uint i = 0; i < reflectionTokens.length; i++) {
            uint256 pending = amount.mul(accReflectionPerShare[i]).div(PRECISION_FACTOR[i]).sub(_distribution.reflectionDebt[i]);
            if(pending > 0) {
                IERC20(reflectionTokens[i]).safeTransfer(msg.sender, pending);
                allocatedReflections[i] = allocatedReflections[i].sub(pending);
            }

            _distribution.reflectionDebt[i] = amount.mul(accReflectionPerShare[i]).div(PRECISION_FACTOR[i]);
        }
    }

    function pendingClaim(address _user) external view returns (uint256) {
        if(isDistributor[_user] == false) return 0;        

        Distribution storage _distribution = distributions[_user];
        if(_distribution.lastClaimBlock >= block.number) return 0;
        
        uint256 amount = _distribution.alloc.sub(_distribution.tokenDebt);
        uint256 claimAmt = _distribution.unlockRate.mul(block.number.sub(_distribution.lastClaimBlock));
        if(claimAmt > amount) claimAmt = amount;

        return amount;
    }

    function pendingReflection(address _user) external view returns (uint256[] memory data) {
        data = new uint256[](reflectionTokens.length);
        if(isDistributor[_user] == false) return data;

        uint256 tokenAmt = token.balanceOf(address(this));
        if(tokenAmt == 0) return data;

        Distribution storage _distribution = distributions[_user];
        for(uint i = 0; i < reflectionTokens.length; i++) {
            uint256 reflectionAmt = availableReflectionTokens(i);
            reflectionAmt = reflectionAmt.sub(allocatedReflections[i]);
            uint256 _accReflectionPerShare = accReflectionPerShare[i].add(reflectionAmt.mul(PRECISION_FACTOR[i]).div(tokenAmt));
            
            uint256 amount = _distribution.alloc.sub(_distribution.tokenDebt);
            uint256 pending = amount.mul(_accReflectionPerShare).div(PRECISION_FACTOR[i]).sub(_distribution.reflectionDebt[i]);
            data[i] = pending;
        }

        return data;
    }

    function claimable(address _user) public view returns (bool) {
        if(isDistributor[_user] == false) return false;
        if(distributions[_user].lastClaimBlock >= block.number) return false;

        Distribution memory _distribution = distributions[_user];
        uint256 amount = _distribution.alloc.sub(_distribution.tokenDebt);
        if(amount > 0) return true;

        return false;
    }

    function setStatus(bool _isActive) external onlyOwner {
        isActive = _isActive;
    }

    function emergencyWithdraw() external onlyOwner {
        uint256 tokenAmt = token.balanceOf(address(this));
        if(tokenAmt > 0) {
            token.transfer(msg.sender, tokenAmt);
        }
        
        for(uint i = 0; i < reflectionTokens.length; i++) {
            uint256 reflectionAmt = IERC20(reflectionTokens[i]).balanceOf(address(this));
            if(reflectionAmt > 0) {
                IERC20(reflectionTokens[i]).transfer(msg.sender, reflectionAmt);
            }

            allocatedReflections[i] = 0;
            accReflectionPerShare[i] = 0;
        }
    }

    function claimDividendFromToken() external onlyOwner {
        IDividendToken(address(token)).claim();
    }

    function availableReflectionTokens(uint index) internal view returns (uint256) {
        uint256 _amount = address(this).balance;
        if(reflectionTokens[index] != address(0x0)) {
            _amount = IERC20(reflectionTokens[index]).balanceOf(address(this));
        }

        return _amount;
    }

    function _updatePool() internal {
        uint256 tokenAmt = token.balanceOf(address(this));
        if(tokenAmt == 0) return;

        for(uint i  = 0; i < reflectionTokens.length; i++) {
            uint256 reflectionAmt = availableReflectionTokens(i);
            reflectionAmt = reflectionAmt.sub(allocatedReflections[i]);

            accReflectionPerShare[i] = accReflectionPerShare[i].add(reflectionAmt.mul(PRECISION_FACTOR[i]).div(tokenAmt));
            allocatedReflections[i] = allocatedReflections[i].add(reflectionAmt);
        }
    }
    
    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This contract has been developed by brewlabs.info
 */
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

contract BUSDBuffetTeamLocker is Ownable{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool public isActive = false;
    bool private initialized = false;

    IERC20 public token;

    uint256 public lockDuration = 365; // 365 days
    address public  reflectionToken;
    uint256 private accReflectionPerShare;
    uint256 private allocatedReflections;

    uint256 private PRECISION_FACTOR = 1 ether;
    uint256 constant MAX_STAKES = 256;

    struct Lock {
        uint256 amount;              // allocation point of token supply
        uint256 duration;            // team member can claim after duration in days
        uint256 reflectionDebt;
        uint256 releaseTime;
    }
   
    mapping(address => Lock[]) public locks;
    address[] public members;

    event Deposited(address member, uint256 amount, uint256 duration);
    event Released(address member, uint256 amount);
    event LockDurationUpdated(uint256 duration);
        
    modifier onlyActive() {
        require(isActive == true, "not active");
        _;
    }

    constructor () {}

    function initialize(IERC20 _token, address _reflectionToken) external onlyOwner {
        require(initialized == false, "already initialized");
        initialized = true;

        token = _token;
        reflectionToken = _reflectionToken;
    }

    function deposit(uint256 amount) external onlyActive {
        require(amount > 0, "Invalid amount");

        _updatePool();
        
        uint256 beforeAmount = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), amount);
        uint256 afterAmount = token.balanceOf(address(this));
        uint256 realAmount = afterAmount.sub(beforeAmount);
        
        _addLock(msg.sender, realAmount);
        
        members.push(msg.sender);

        emit Deposited(msg.sender, amount, lockDuration);
    }

    function _addLock(address _account, uint256 _amount) internal {
        Lock[] storage _locks = locks[_account];

        uint256 releaseTime = block.timestamp.add(lockDuration.mul(1 days));
        uint256 i = _locks.length;

        require(i < MAX_STAKES, "Max Locks");

        _locks.push(); // grow the array
        // find the spot where we can insert the current stake
        // this should make an increasing list sorted by end
        while (i != 0 && _locks[i - 1].releaseTime > releaseTime) {
            // shift it back one
            _locks[i] = _locks[i - 1];
            i -= 1;
        }
        
        // insert the stake
        Lock storage _lock = _locks[i];
        _lock.amount = _amount;
        _lock.duration = lockDuration;
        _lock.reflectionDebt = _amount.mul(accReflectionPerShare).div(PRECISION_FACTOR);
        _lock.releaseTime = releaseTime;
    }


    function harvest() external onlyActive {
        _updatePool();

        Lock[] storage _locks = locks[msg.sender];

        uint256 reflectionAmt = 0;
        for(uint256 i = 0; i < _locks.length; i++) {
            Lock storage _lock = _locks[i];
            if(_lock.amount == 0) continue;

            reflectionAmt = reflectionAmt.add(
                _lock.amount.mul(accReflectionPerShare).div(PRECISION_FACTOR).sub(_lock.reflectionDebt)
            );

            _lock.reflectionDebt = _lock.amount.mul(accReflectionPerShare).div(PRECISION_FACTOR);
        }

        if(reflectionAmt > 0) {
            if(reflectionToken == address(0x0)) {
                payable(msg.sender).transfer(reflectionAmt);
            } else {
                IERC20(reflectionToken).safeTransfer(msg.sender, reflectionAmt);
            }

            allocatedReflections = allocatedReflections.sub(reflectionAmt);
        }
    }
    

    function release() public onlyActive {
        _updatePool();

        Lock[] storage _locks = locks[msg.sender];

        uint256 claimAmt = 0;
        uint256 reflectionAmt = 0;
        for(uint256 i = 0; i < _locks.length; i++) {
            Lock storage _lock = _locks[i];
            if(_lock.amount == 0) continue;
            if(_lock.releaseTime > block.timestamp) continue;

            claimAmt = claimAmt.add(_lock.amount);
            reflectionAmt = reflectionAmt.add(
                _lock.amount.mul(accReflectionPerShare).div(PRECISION_FACTOR).sub(_lock.reflectionDebt)
            );

            _lock.amount = 0;
            _lock.reflectionDebt = 0;
        }

        if(claimAmt > 0) {
            token.safeTransfer(msg.sender, claimAmt);
        }

        if(reflectionAmt > 0) {
            if(reflectionToken == address(0x0)) {
                payable(msg.sender).transfer(reflectionAmt);
            } else {
                IERC20(reflectionToken).safeTransfer(msg.sender, reflectionAmt);
            }
            allocatedReflections = allocatedReflections.sub(reflectionAmt);
        }
    }

    function pendingReflection(address _user) external view returns (uint256) {
        uint256 tokenAmt = token.balanceOf(address(this));
        if(tokenAmt == 0) return 0;

        uint256 reflectionAmt = address(this).balance;
        if(reflectionToken != address(0x0)) {
            reflectionAmt = IERC20(reflectionToken).balanceOf(address(this));
        }
        reflectionAmt = reflectionAmt.sub(allocatedReflections);
        uint256 _accReflectionPerShare = accReflectionPerShare.add(reflectionAmt.mul(PRECISION_FACTOR).div(tokenAmt));

        Lock[] storage _locks = locks[_user];

        uint256 pending = 0;
        for(uint256 i = 0; i < _locks.length; i++) {
            Lock storage _lock = _locks[i];
            if(_lock.amount == 0) continue;

            pending = pending.add(
                _lock.amount.mul(_accReflectionPerShare).div(PRECISION_FACTOR).sub(_lock.reflectionDebt)
            );
        }
        
        return pending;
    }

    function pendingTokens(address _user) public view returns (uint256) {
        Lock[] storage _locks = locks[_user];

        uint256 claimAmt = 0;
        for(uint256 i = 0; i < _locks.length; i++) {
            Lock storage _lock = _locks[i];
            if(_lock.amount == 0) continue;
            if(_lock.releaseTime > block.timestamp) continue;

            claimAmt = claimAmt.add(_lock.amount);
        }

        return claimAmt;
    }

    function totalLocked(address _user) public view returns (uint256) {
        Lock[] storage _locks = locks[_user];

        uint256 amount = 0;
        for(uint256 i = 0; i < _locks.length; i++) {
            Lock storage _lock = _locks[i];
            if(_lock.amount == 0) continue;

            amount = amount.add(_lock.amount);
        }

        return amount;
    }

    function setStatus(bool _isActive) external onlyOwner {
        isActive = _isActive;
    }

    function updateLockDuration(uint256 _duration) external onlyOwner {
        lockDuration = _duration;
        emit LockDurationUpdated(_duration);
    }

    function emergencyWithdraw() external onlyOwner {
        uint256 tokenAmt = token.balanceOf(address(this));
        if(tokenAmt > 0) {
            token.transfer(msg.sender, tokenAmt);
        }

        uint256 reflectionAmt = address(this).balance;
        if(reflectionToken != address(0x0)) {
            reflectionAmt = IERC20(reflectionToken).balanceOf(address(this));
        }

        if(reflectionAmt > 0) {
            if(reflectionToken == address(0x0)) {
                payable(msg.sender).transfer(reflectionAmt);
            } else {
                IERC20(reflectionToken).transfer(msg.sender, reflectionAmt);
            }
        }
    }

    function recoverWrongToken(address _tokenAddress) external onlyOwner {
        require(_tokenAddress != address(token), "Cannot recover locked token");
        require(_tokenAddress != reflectionToken, "Cannot recover reflection token");

        if(_tokenAddress == address(0x0)) {
            uint256 amount = address(this).balance;
            payable(msg.sender).transfer(amount);
        } else {
            uint256 amount = IERC20(_tokenAddress).balanceOf(address(this));
            IERC20(_tokenAddress).safeTransfer(address(msg.sender), amount);
        }
    }

    function _updatePool() internal {
        uint256 tokenAmt = token.balanceOf(address(this));
        if(tokenAmt == 0) return;

        uint256 reflectionAmt = address(this).balance;
        if(reflectionToken != address(0x0)) {
            reflectionAmt = IERC20(reflectionToken).balanceOf(address(this));
        }
        reflectionAmt = reflectionAmt.sub(allocatedReflections);

        accReflectionPerShare = accReflectionPerShare.add(reflectionAmt.mul(PRECISION_FACTOR).div(tokenAmt));
        allocatedReflections = allocatedReflections.add(reflectionAmt);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This contract has been developed by brewlabs.info
 */

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';


contract BaltoTeamLocker is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool public isActive = false;
    bool private initialized = false;

    IERC20 public token;
    address public reflectionToken;

    uint256 public dividendPercent = 9800;
    uint256 private PRECISION_FACTOR = 1 ether;
   
    mapping(address => bool) isUsed;
    mapping(address => bool) public isDistributor;
    address[] public distributors;
    uint256 public totalDistributors;

    event AddDistribution(address distributor);
    event RemoveDistribution(address distributor);
    event UpdateDividendPercent(uint256 percent);

    event Harvested(uint256 amount);
    event EmergencyWithdrawn();
    event EmergencyDividendWithdrawn();
        
    modifier onlyActive() {
        require(isActive == true, "not active");
        _;
    }

    constructor () {}

    function initialize(IERC20 _token, address _reflectionToken) external onlyOwner {
        require(initialized == false, "already initialized");
        initialized = true;

        token = _token;
        reflectionToken = _reflectionToken;
    }


    function addDistribution(address distributor) external onlyOwner {
        require(isDistributor[distributor] == false, "already set");

        isDistributor[distributor] = true;
        if(!isUsed[distributor]) {
            distributors.push(distributor);
            isUsed[distributor] = true;
        }
        totalDistributors = totalDistributors.add(1);

        emit AddDistribution(distributor);
    }

    function removeDistribution(address distributor) external onlyOwner {
        require(isDistributor[distributor] == true, "Not found");

        isDistributor[distributor] = false;
        totalDistributors = totalDistributors.sub(1);
        
        emit RemoveDistribution(distributor);
    }

    function harvest() public onlyActive {
        require(isDistributor[msg.sender] == true || msg.sender == owner(), "only distributor");

        uint256 reflectionTokens = 0;
        if(reflectionToken == address(0x0)) {
            reflectionTokens = address(this).balance;
        } else {
            reflectionTokens = IERC20(reflectionToken).balanceOf(address(this));
        }

        uint256 dAmt = reflectionTokens.mul(dividendPercent).div(10000).div(totalDistributors);
        if(dAmt == 0) return;

        for(uint i = 0; i < distributors.length; i++) {
            address distributor = distributors[i];
            if(!isDistributor[distributor]) continue;

            if(reflectionToken == address(0x0)) {
                payable(distributor).transfer(dAmt);
            } else {
                IERC20(reflectionToken).safeTransfer(distributor, dAmt);
            }
        }

        emit Harvested(dAmt);
    }

    function pendingReflection(address _user) external view returns (uint256) {
        if(isDistributor[_user] == false) return 0;

        uint256 reflectionTokens = 0;
        if(reflectionToken == address(0x0)) {
            reflectionTokens = address(this).balance;
        } else {
            reflectionTokens = IERC20(reflectionToken).balanceOf(address(this));
        }

        return reflectionTokens.mul(dividendPercent).div(10000).div(totalDistributors);
    }

    function setStatus(bool _isActive) external onlyOwner {
        isActive = _isActive;
    }

    function setDividendPercent(uint256 _percent) external onlyOwner {
        require(_percent <= 10000, "Invalid percentage");
        dividendPercent = _percent;
        emit UpdateDividendPercent(_percent);
    }

    function emergencyWithdraw() external onlyOwner {
        uint256 tokenAmt = token.balanceOf(address(this));
        if(tokenAmt > 0) {
            token.transfer(msg.sender, tokenAmt);
        }
        emit EmergencyWithdrawn();
    }

    function emergencyDividendWithdraw() external onlyOwner {
        if(reflectionToken == address(0x0)) {
            uint256 reflectionTokens = address(this).balance;
            payable(msg.sender).transfer(reflectionTokens);
        } else {
            uint256 reflectionTokens = IERC20(reflectionToken).balanceOf(address(this));
            IERC20(reflectionToken).transfer(msg.sender, reflectionTokens);
        }

        emit EmergencyDividendWithdrawn();
    }
    
    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _token: the address of the token to withdraw
     * @dev This function is only callable by admin.
     */
    function rescueToken(address _token) external onlyOwner {
        if(_token == address(0x0)) {
            uint256 _tokenAmount = address(this).balance;
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            uint256 _tokenAmount = IERC20(_token).balanceOf(address(this));
            IERC20(_token).safeTransfer(msg.sender, _tokenAmount);
        }
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';

contract Epoch is Ownable {
    uint256 private period;
    uint256 private startTime;
    uint256 private lastEpochTime;
    uint256 private epoch;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        uint256 _period,
        uint256 _startTime,
        uint256 _startEpoch
    ) {
        period = _period;
        startTime = _startTime;
        epoch = _startEpoch;
        lastEpochTime = startTime - period;
    }

    /* ========== Modifier ========== */

    modifier checkStartTime {
        require(block.timestamp >= startTime, 'Epoch: not started yet');

        _;
    }

    modifier checkEpoch {
        uint256 _nextEpochPoint = nextEpochPoint();
        if (block.timestamp < _nextEpochPoint) {
            require(msg.sender == owner(), 'Epoch: only operator allowed for pre-epoch');
            _;
        } else {
            _;

            for (;;) {
                lastEpochTime = _nextEpochPoint;
                ++epoch;
                _nextEpochPoint = nextEpochPoint();
                if (block.timestamp < _nextEpochPoint) break;
            }
        }
    }

    /* ========== VIEW FUNCTIONS ========== */

    function getCurrentEpoch() public view returns (uint256) {
        return epoch;
    }

    function getPeriod() public view returns (uint256) {
        return period;
    }

    function getStartTime() public view returns (uint256) {
        return startTime;
    }

    function getLastEpochTime() public view returns (uint256) {
        return lastEpochTime;
    }

    function nextEpochPoint() public view returns (uint256) {
        return lastEpochTime + period;
    }

    /* ========== GOVERNANCE ========== */

    function setPeriod(uint256 _period) external onlyOwner {
        require(_period >= 1 hours && _period <= 48 hours, '_period: out of range');
        period = _period;
    }

    function setEpoch(uint256 _epoch) external onlyOwner {
        epoch = _epoch;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./libs/Babylonian.sol";
import "./libs/FixedPoint.sol";
import "./libs/UniswapV2OracleLibrary.sol";
import "./libs/IUniPair.sol";
import "./libs/Epoch.sol";


// fixed window oracle that recomputes the average price for the entire period once every period
// note that the price average is only guaranteed to be over at least 1 period, but may be over a longer period
contract BrewlabsTwapOracle is Epoch {
    using FixedPoint for *;

    /* ========== STATE VARIABLES ========== */

    // uniswap
    address public token0;
    address public token1;
    IUniswapV2Pair public pair;

    // oracle
    uint32 public blockTimestampLast;
    uint256 public price0CumulativeLast;
    uint256 public price1CumulativeLast;
    FixedPoint.uq112x112 public price0Average;
    FixedPoint.uq112x112 public price1Average;

    event Updated(uint256 price0CumulativeLast, uint256 price1CumulativeLast);

    /* ========== CONSTRUCTOR ========== */
    constructor(
        IUniswapV2Pair _pair,
        uint256 _period,
        uint256 _startTime
    ) Epoch(_period, _startTime, 0) {
        pair = _pair;
        token0 = pair.token0();
        token1 = pair.token1();
        price0CumulativeLast = pair.price0CumulativeLast(); // fetch the current accumulated price value (1 / 0)
        price1CumulativeLast = pair.price1CumulativeLast(); // fetch the current accumulated price value (0 / 1)
        uint112 reserve0;
        uint112 reserve1;
        (reserve0, reserve1, blockTimestampLast) = pair.getReserves();
        require(reserve0 != 0 && reserve1 != 0, "BrewlabsTwapOracle: NO_RESERVES"); // ensure that there's liquidity in the pair
    }

    /* ========== MUTABLE FUNCTIONS ========== */

    /** @dev Updates 1-day EMA price from Uniswap.  */
    function update() external checkEpoch {
        (uint256 price0Cumulative, uint256 price1Cumulative, uint32 blockTimestamp) = UniswapV2OracleLibrary.currentCumulativePrices(address(pair));
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired

        if (timeElapsed == 0) {
            // prevent divided by zero
            return;
        }

        // overflow is desired, casting never truncates
        // cumulative price is in (uq112x112 price * seconds) units so we simply wrap it after division by time elapsed
        price0Average = FixedPoint.uq112x112(uint224((price0Cumulative - price0CumulativeLast) / timeElapsed));
        price1Average = FixedPoint.uq112x112(uint224((price1Cumulative - price1CumulativeLast) / timeElapsed));

        price0CumulativeLast = price0Cumulative;
        price1CumulativeLast = price1Cumulative;
        blockTimestampLast = blockTimestamp;

        emit Updated(price0Cumulative, price1Cumulative);
    }

    // note this will always return 0 before update has been called successfully for the first time.
    function consult(address _token, uint256 _amountIn) external view returns (uint144 amountOut) {
        if (_token == token0) {
            amountOut = price0Average.mul(_amountIn).decode144();
        } else {
            require(_token == token1, "BrewlabsTwapOracle: INVALID_TOKEN");
            amountOut = price1Average.mul(_amountIn).decode144();
        }
    }

    function twap(address _token, uint256 _amountIn) external view returns (uint144 _amountOut) {
        (uint256 price0Cumulative, uint256 price1Cumulative, uint32 blockTimestamp) = UniswapV2OracleLibrary.currentCumulativePrices(address(pair));
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if (_token == token0) {
            if(timeElapsed == 0) {
                _amountOut = price0Average.mul(_amountIn).decode144();
            } else {
                _amountOut = FixedPoint.uq112x112(uint224((price0Cumulative - price0CumulativeLast) / timeElapsed)).mul(_amountIn).decode144();
            }
        } else if (_token == token1) {
            if(timeElapsed == 0) {
                _amountOut = price1Average.mul(_amountIn).decode144();
            } else {
                _amountOut = FixedPoint.uq112x112(uint224((price1Cumulative - price1CumulativeLast) / timeElapsed)).mul(_amountIn).decode144();
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Babylonian {
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
        // else z = 0
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Babylonian.sol";

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))
library FixedPoint {
    // range: [0, 2**112 - 1]
    // resolution: 1 / 2**112
    struct uq112x112 {
        uint224 _x;
    }

    // range: [0, 2**144 - 1]
    // resolution: 1 / 2**112
    struct uq144x112 {
        uint256 _x;
    }

    uint8 private constant RESOLUTION = 112;
    uint256 private constant Q112 = uint256(1) << RESOLUTION;
    uint256 private constant Q224 = Q112 << RESOLUTION;

    // encode a uint112 as a UQ112x112
    function encode(uint112 x) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(x) << RESOLUTION);
    }

    // encodes a uint144 as a UQ144x112
    function encode144(uint144 x) internal pure returns (uq144x112 memory) {
        return uq144x112(uint256(x) << RESOLUTION);
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {
        require(x != 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112(self._x / uint224(x));
    }

    // multiply a UQ112x112 by a uint, returning a UQ144x112
    // reverts on overflow
    function mul(uq112x112 memory self, uint256 y) internal pure returns (uq144x112 memory) {
        uint256 z;
        require(y == 0 || (z = uint256(self._x) * y) / y == uint256(self._x), "FixedPoint: MULTIPLICATION_OVERFLOW");
        return uq144x112(z);
    }

    // returns a UQ112x112 which represents the ratio of the numerator to the denominator
    // equivalent to encode(numerator).div(denominator)
    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    // decode a UQ112x112 into a uint112 by truncating after the radix point
    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    // decode a UQ144x112 into a uint144 by truncating after the radix point
    function decode144(uq144x112 memory self) internal pure returns (uint144) {
        return uint144(self._x >> RESOLUTION);
    }

    // take the reciprocal of a UQ112x112
    function reciprocal(uq112x112 memory self) internal pure returns (uq112x112 memory) {
        require(self._x != 0, "FixedPoint: ZERO_RECIPROCAL");
        return uq112x112(uint224(Q224 / self._x));
    }

    // square root of a UQ112x112
    function sqrt(uq112x112 memory self) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(Babylonian.sqrt(uint256(self._x)) << 56));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FixedPoint.sol";
import "./IUniswapV2Pair.sol";

// library with helper methods for oracles that are concerned with computing average prices
library UniswapV2OracleLibrary {
    using FixedPoint for *;

    // helper function that returns the current block timestamp within the range of uint32, i.e. [0, 2**32 - 1]
    function currentBlockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2**32);
    }

    // produces the cumulative price using counterfactuals to save gas and avoid a call to sync.
    function currentCumulativePrices(address pair)
        internal
        view
        returns (
            uint256 price0Cumulative,
            uint256 price1Cumulative,
            uint32 blockTimestamp
        )
    {
        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IUniswapV2Pair(pair).price0CumulativeLast();
        price1Cumulative = IUniswapV2Pair(pair).price1CumulativeLast();

        // if time has elapsed since the last update on the pair, mock the accumulated price values
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            // subtraction overflow is desired
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            // addition overflow is desired
            // counterfactual
            price0Cumulative += uint256(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            // counterfactual
            price1Cumulative += uint256(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IUniPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    
    function getReserves()
        external
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        );
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IUniswapV2Pair {
  function token0() external view returns (address);

  function token1() external view returns (address);

  function getReserves()
    external
    view
    returns (
      uint112 _reserve0,
      uint112 _reserve1,
      uint32 _blockTimestampLast
    );

  function price0CumulativeLast() external view returns (uint256);
  function price1CumulativeLast() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/proxy/Clones.sol";
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import './libs/IBrewlabsTokenLocker.sol';
import './libs/IUniFactory.sol';
import './libs/IUniPair.sol';

contract BrewlabsTokenFreezer is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct FeeStruct {
        uint256 mintFee;
        uint256 editFee;
        uint256 defrostFee;
    }
    FeeStruct public gFees;

    address public implementation;
    mapping (address => address) public tokenLockers;

    address public treasury = 0x408c4aDa67aE1244dfeC7D609dea3c232843189A;
    address private devAddr;
    uint256 private devRate = 0;
    uint256 private TIME_UNIT = 1 days;

    event TokenLockerCreated(address locker, address token, address reflectionToken);
    event FeeUpdated(uint256 mintFee, uint256 editFee, uint256 defrostFee);
    event UpdateImplementation(address impl);

    constructor (address _implementation) {
        implementation = _implementation;

        devAddr = msg.sender;

        gFees.mintFee = 1 ether;
        gFees.editFee = 0.3 ether;
        gFees.defrostFee = 5 ether;
    }

    function createTokenLocker(address _op, address _token, address _reflectionToken, uint256 _amount, uint256 _cycle, uint256 _cAmount, uint256 _unlockTime) external payable returns (address locker) {
        require(msg.value >= gFees.mintFee, "not enough fee");

        _transferFee(gFees.mintFee);

        uint256 beforeAmt = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = IERC20(_token).balanceOf(address(this));

        uint256 amountIn = afterAmt.sub(beforeAmt);

        locker = tokenLockers[_token];
        if(locker == address(0x0)) {
            bytes32 salt = keccak256(abi.encodePacked(_op, _token, block.timestamp));
            locker = Clones.cloneDeterministic(implementation, salt);
            IBrewlabsTokenLocker(locker).initialize(_token, _reflectionToken, treasury, gFees.editFee, gFees.defrostFee, devAddr, devRate, address(this));

            tokenLockers[_token] = locker;
            emit TokenLockerCreated(locker, _token, _reflectionToken);
        }

        uint256 unlockRate = 0;
        if(_cycle > 0) {
            unlockRate = _cAmount.div(_cycle.mul(TIME_UNIT));
        }

        IERC20(_token).approve(locker, amountIn);
        IBrewlabsTokenLocker(locker).newLock(_op, amountIn, _unlockTime, unlockRate);
    }

    function setImplementation(address _implementation) external onlyOwner {
        require(_implementation != address(0x0), "invalid address");

        implementation = _implementation;
        emit UpdateImplementation(_implementation);
    }

    function forceUnlockToken(address payable _locker, uint256 _lockID) external onlyOwner {
        IBrewlabsTokenLocker(_locker).defrost(_lockID);
    }

    function updateTreasuryOfLocker(address _locker, address _treasury) external onlyOwner {
        require(_locker != address(0x0), "invalid locker");
        IBrewlabsTokenLocker(_locker).setTreasury(_treasury);
    }

    function transferOwnershipOfLocker( address payable _locker, address _newOwner) external onlyOwner {
        IBrewlabsTokenLocker(_locker).transferOwnership(_newOwner);
    }

    function setFees(uint256 _mintFee, uint256 _editFee, uint256 _defrostFee) external onlyOwner {
        gFees.mintFee = _mintFee;
        gFees.editFee = _editFee;
        gFees.defrostFee = _defrostFee;

        emit FeeUpdated(_mintFee, _editFee, _defrostFee);
    }

    function setTreasury(address _treasury) external onlyOwner {
        treasury = _treasury;
    }

    function setDevRate(uint256 _rate) external {
        require(msg.sender == owner() || msg.sender == devAddr, "only owner & dev");
        require(_rate < 10000, "Invalid rate");
        devRate = _rate;
    }

    function setDevAddress(address _dev) external {
        require(msg.sender == devAddr, "not dev");
        devAddr = _dev;
    }

    function _transferFee(uint256 _fee) internal {
        if(msg.value > _fee) {
            payable(msg.sender).transfer(msg.value.sub(_fee));
        }

        uint256 _devFee = _fee.mul(devRate).div(10000);
        if(_devFee > 0) {
            payable(devAddr).transfer(_devFee);
        }

        payable(treasury).transfer(_fee.sub(_devFee));
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBrewlabsTokenLocker {
    function NONCE() external view returns(uint256);
    
    function editFee() external view returns(uint256);
    function defrostFee() external view returns(uint256);
    function token() external view returns(address);
    function reflectionToken() external view returns(address);
    function totalLocked() external view returns(uint256);
    function treasury() external view returns(address);

    struct TokenLock {
        uint256 lockID; // lockID nonce per token
        uint256 lockDate; // the date the token was locked
        uint256 amount; // the amount of tokens still locked
        uint256 unlockTime; // the date the token can be withdrawn
        uint256 unlockRate; // 0 - not vesting, else - vesting 
        address operator;
        uint256 tokenDebt;
        uint256 reflectionDebt;
        bool isDefrost;
    }
    function locks(uint256 index) external view returns(TokenLock memory);
    function pendingReflections(address _user) external view returns (uint256 pending);
    function pendingClaims(uint256 _lockID) external view returns (uint256);

    // owner method
    function initialize(address _token, address _reflectionToken, address _treasury, uint256 _editFee, uint256 _defrostFee, address _devWallet, uint256 _devRate, address _owner) external;
    function defrost(uint256 _lockID) external;
    function newLock(address _operator, uint256 _amount, uint256 _unlockTime, uint256 _unlockRate) external;
    function setTreasury(address _treasury) external;
    function transferOwnership(address newOwner) external;
    
    // operator method
    function addLock(uint256 _lockID, uint256 _amount) external payable;
    function allowDefrost(uint256 _lockID) external payable;
    function claim(uint256 _lockID) external;
    function harvest(uint256 _lockID) external payable;
    function reLock(uint256 _lockID, uint256 _unlockTime) external payable;
    function splitLock(uint256 _lockID, address _operator, uint256 _amount, uint256 _unlockTime) external payable;
    function transferLock(uint256 _lockID, address _operator) external payable;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/proxy/Clones.sol";
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import './libs/IBrewlabsPairLocker.sol';
import './libs/IUniFactory.sol';
import './libs/IUniPair.sol';

contract BrewlabsPairFreezer is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct FeeStruct {
        uint256 mintFee;
        uint256 editFee;
        uint256 defrostFee;
    }
    FeeStruct public gFees;

    address public implementation;
    mapping (address => address) public liquidityLockers;

    address public treasury = 0x408c4aDa67aE1244dfeC7D609dea3c232843189A;
    address private devAddr;
    uint256 private devRate = 0;

    event LiquidityLockerCreated(address locker, address factory, address token);
    event FeeUpdated(uint256 mintFee, uint256 editFee, uint256 defrostFee);
    event UpdateImplementation(address impl);

    constructor (address _implementation) {
        implementation = _implementation;

        devAddr = msg.sender;

        gFees.mintFee = 0.5 ether;
        gFees.editFee = 0.3 ether;
        gFees.defrostFee = 5 ether;
    }

    function createLiquidityLocker(address _op, address _uniFactory, address _pair, uint256 _amount, uint256 _unlockTime) external payable returns (address locker) {
        require(msg.value >= gFees.mintFee, "not enough fee");
        
        _checkPair(_uniFactory, _pair);
        _transferFee(gFees.mintFee);

        uint256 beforeAmt = IERC20(_pair).balanceOf(address(this));
        IERC20(_pair).transferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = IERC20(_pair).balanceOf(address(this));

        uint256 amountIn = afterAmt.sub(beforeAmt);

        locker = liquidityLockers[_pair];
        if(locker == address(0x0)) {
            bytes32 salt = keccak256(abi.encodePacked(_op, _pair, amountIn, _unlockTime, block.timestamp));
            locker = Clones.cloneDeterministic(implementation, salt);
            IBrewlabsPairLocker(locker).initialize(_pair, treasury, gFees.editFee, gFees.defrostFee, devAddr, devRate, address(this));

            liquidityLockers[_pair] = locker;
            emit LiquidityLockerCreated(locker, _uniFactory, _pair);
        }

        IERC20(_pair).approve(locker, amountIn);
        IBrewlabsPairLocker(locker).newLock(_op, amountIn, _unlockTime);
    }

    function setImplementation(address _implementation) external onlyOwner {
        require(_implementation != address(0x0), "invalid address");

        implementation = _implementation;
        emit UpdateImplementation(_implementation);
    }

    function forceUnlockLP(address _locker, uint256 _lockID) external onlyOwner {
        IBrewlabsPairLocker(_locker).defrost(_lockID);
    }

    function updateTreasuryOfLocker(address _locker, address _treasury) external onlyOwner {
        require(_locker != address(0x0), "invalid locker");
        IBrewlabsPairLocker(_locker).setTreasury(_treasury);
    }

    function transferOwnershipOfLocker( address payable _locker, address _newOwner) external onlyOwner {
        IBrewlabsPairLocker(_locker).transferOwnership(_newOwner);
    }
    function setFees(uint256 _mintFee, uint256 _editFee, uint256 _defrostFee) external onlyOwner {
        gFees.mintFee = _mintFee;
        gFees.editFee = _editFee;
        gFees.defrostFee = _defrostFee;

        emit FeeUpdated(_mintFee, _editFee, _defrostFee);
    }

    function setTreasury(address _treasury) external onlyOwner {
        treasury = _treasury;
    }

    function setDevRate(uint256 _rate) external {
        require(msg.sender == owner() || msg.sender == devAddr, "only owner & dev");
        require(_rate < 10000, "Invalid rate");
        devRate = _rate;
    }

    function setDevAddress(address _devAddr) external {
        require(msg.sender == devAddr, "not dev");
        devAddr = _devAddr;
    }

    function _checkPair(address _uniFactory, address _lpToken) internal view {
        // ensure this pair is a univ2 pair by querying the factory
        IUniPair lpair = IUniPair(_lpToken);
        address factoryPairAddress = IUniV2Factory(_uniFactory).getPair(lpair.token0(), lpair.token1());
        require(factoryPairAddress == _lpToken, 'invalid pair');
    }

    function _transferFee(uint256 _fee) internal {
        if(msg.value > _fee) {
            payable(msg.sender).transfer(msg.value.sub(_fee));
        }

        uint256 _devFee = _fee.mul(devRate).div(10000);
        if(_devFee > 0) {
            payable(devAddr).transfer(_devFee);
        }

        payable(treasury).transfer(_fee.sub(_devFee));
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBrewlabsPairLocker {
    function NONCE() external view returns(uint256);

    function defrostFee() external view returns(uint256);
    function editFee() external view returns(uint256);
    function lpToken() external view returns(address);
    function totalLocked() external view returns(uint256);
    function treasury() external view returns(address);

    struct PairLock {
        uint256 lockID; // lockID nonce per uni pair
        uint256 lockDate; // the date the token was locked
        uint256 amount; // the amount of tokens still locked
        uint256 unlockTime; // the date the token can be withdrawn
        address operator;
        uint256 tokenDebt;
        bool isDefrost;
    }
    function locks(uint256 index) external view returns(PairLock memory);

    // owner method
    function initialize(address _lpToken, address _treasury, uint256 _editFee, uint256 _defrostFee, address _devWallet, uint256 _devPercent, address _owner) external;
    function defrost(uint256 _lockID) external;
    function newLock(address _operator, uint256 _amount, uint256 _unlockTime) external;
    function setTreasury(address _treasury) external;
    function transferOwnership(address newOwner) external;
    
    // operator method
    function addLock(uint256 _lockID,uint256 _amount) external payable;
    function allowDefrost(uint256 _lockID) external payable;
    function claim(uint256 _lockID) external;
    function reLock(uint256 _lockID,uint256 _unlockTime) external payable;
    function splitLock(uint256 _lockID, address _operator, uint256 _amount, uint256 _unlockTime) external payable;
    function transferLock(uint256 _lockID,address _operator) external payable;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This treasury contract has been developed by brewlabs.info
 */
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./libs/IUniFactory.sol";
import "./libs/IUniRouter02.sol";

interface IStaking {
  function performanceFee() external view returns (uint256);

  function setServiceInfo(address _addr, uint256 _fee) external;
}

interface IFarm {
  function setBuyBackWallet(address _addr) external;
}

contract BrewlabsTreasury is Ownable {
  using SafeERC20 for IERC20;

  bool private isInitialized;
  uint256 private constant TIME_UNIT = 1 days;
  uint256 private constant PERCENT_PRECISION = 10000;

  IERC20 public token;
  address public dividendToken;
  address public pair;
  address private constant USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
  address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

  uint256 public period = 30; // 30 days
  uint256 public withdrawalLimit = 500; // 5% of total supply
  uint256 public liquidityWithdrawalLimit = 2000; // 20% of LP supply
  uint256 public buybackRate = 9500; // 95%
  uint256 public addLiquidityRate = 9400; // 94%

  uint256 private startTime;
  uint256 private sumWithdrawals = 0;
  uint256 private sumLiquidityWithdrawals = 0;

  address public uniRouterAddress;
  address[] public bnbToTokenPath;
  address[] public bnbToDividendPath;
  address[] public dividendToTokenPath;
  uint256 public slippageFactor = 8300; // 17%
  uint256 public constant slippageFactorUL = 9950;

  event Initialized(
    address token,
    address dividendToken,
    address router,
    address[] bnbToTokenPath,
    address[] bnbToDividendPath,
    address[] dividendToTokenPath
  );

  event TokenBuyBack(uint256 amountETH, uint256 amountToken);
  event TokenBuyBackFromDividend(uint256 amount, uint256 amountToken);
  event LiquidityAdded(
    uint256 amountETH,
    uint256 amountToken,
    uint256 liquidity
  );
  event LiquidityWithdrawn(uint256 amount);
  event Withdrawn(uint256 amount);
  event Harvested(address account, uint256 amount);
  event Swapped(address token, uint256 amountETH, uint256 amountToken);

  event BnbHarvested(address to, uint256 amount);
  event EmergencyWithdrawn();
  event AdminTokenRecovered(address tokenRecovered, uint256 amount);
  event BusdHarvested(address to, uint256[] amounts);
  event UsdcHarvested(address to, uint256[] amounts);

  event SetSwapConfig(
    address router,
    uint256 slipPage,
    address[] bnbToTokenPath,
    address[] bnbToDividendPath,
    address[] dividendToTokenPath
  );
  event TransferBuyBackWallet(address staking, address wallet);
  event AddLiquidityRateUpdated(uint256 percent);
  event BuybackRateUpdated(uint256 percent);
  event PeriodUpdated(uint256 duration);
  event LiquidityWithdrawLimitUpdated(uint256 percent);
  event WithdrawLimitUpdated(uint256 percent);

  constructor() {}

  /**
   * @notice Initialize the contract
   * @param _token: token address
   * @param _dividendToken: reflection token address
   * @param _uniRouter: uniswap router address for swap tokens
   * @param _bnbToTokenPath: swap path to buy Token
   * @param _bnbToDividendPath: swap path to buy dividend token
   * @param _dividendToTokenPath: swap path to buy Token with dividend token
   */
  function initialize(
    IERC20 _token,
    address _dividendToken,
    address _uniRouter,
    address[] memory _bnbToTokenPath,
    address[] memory _bnbToDividendPath,
    address[] memory _dividendToTokenPath
  ) external onlyOwner {
    require(!isInitialized, "Already initialized");
    require(_uniRouter != address(0x0), "invalid address");
    require(address(_token) != address(0x0), "invalid token address");

    // Make this contract initialized
    isInitialized = true;

    token = _token;
    dividendToken = _dividendToken;
    pair = IUniV2Factory(IUniRouter02(_uniRouter).factory()).getPair(
      _bnbToTokenPath[0],
      address(token)
    );

    uniRouterAddress = _uniRouter;
    bnbToTokenPath = _bnbToTokenPath;
    bnbToDividendPath = _bnbToDividendPath;
    dividendToTokenPath = _dividendToTokenPath;

    emit Initialized(
      address(_token),
      _dividendToken,
      _uniRouter,
      _bnbToTokenPath,
      _bnbToDividendPath,
      _dividendToTokenPath
    );
  }

  /**
   * @notice Buy token from BNB
   */
  function buyBack() external onlyOwner {
    uint256 ethAmt = address(this).balance;
    ethAmt = (ethAmt * buybackRate) / PERCENT_PRECISION;

    if (ethAmt > 0) {
      uint256 _tokenAmt = _safeSwapEth(ethAmt, bnbToTokenPath, address(this));
      emit TokenBuyBack(ethAmt, _tokenAmt);
    }
  }

  /**
   * @notice Buy token from reflections
   */
  function buyBackFromDividend() external onlyOwner {
    if (dividendToken == address(0x0)) return;

    uint256 reflections = IERC20(dividendToken).balanceOf(address(this));
    if (reflections > 0) {
      uint256 _tokenAmt = _safeSwap(
        reflections,
        dividendToTokenPath,
        address(this)
      );
      emit TokenBuyBackFromDividend(reflections, _tokenAmt);
    }
  }

  /**
   * @notice Add liquidity
   */
  function addLiquidity() external onlyOwner {
    uint256 ethAmt = address(this).balance;
    ethAmt = (ethAmt * addLiquidityRate) / PERCENT_PRECISION / 2;

    if (ethAmt > 0) {
      uint256 _tokenAmt = _safeSwapEth(ethAmt, bnbToTokenPath, address(this));
      emit TokenBuyBack(ethAmt, _tokenAmt);

      (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
      ) = _addLiquidityEth(address(token), ethAmt, _tokenAmt, address(this));
      emit LiquidityAdded(amountETH, amountToken, liquidity);
    }
  }

  /**
   * @notice Swap and harvest reflection for token
   * @param _to: receiver address
   */
  function harvest(address _to) external onlyOwner {
    uint256 ethAmt = address(this).balance;
    ethAmt = (ethAmt * buybackRate) / PERCENT_PRECISION;

    if (dividendToken == address(0x0)) {
      if (ethAmt > 0) {
        payable(_to).transfer(ethAmt);
        emit Harvested(_to, ethAmt);
      }
    } else {
      if (ethAmt > 0) {
        uint256 _tokenAmt = _safeSwapEth(
          ethAmt,
          bnbToDividendPath,
          address(this)
        );
        emit Swapped(dividendToken, ethAmt, _tokenAmt);
      }

      uint256 tokenAmt = IERC20(dividendToken).balanceOf(address(this));
      if (tokenAmt > 0) {
        IERC20(dividendToken).transfer(_to, tokenAmt);
        emit Harvested(_to, tokenAmt);
      }
    }
  }

  function harvestBNB(address _to) external onlyOwner {
    require(_to != address(0x0), "invalid address");
    uint256 ethAmt = address(this).balance;
    payable(_to).transfer(ethAmt);
    emit BnbHarvested(_to, ethAmt);
  }

  function harvestBUSD(address _to) external onlyOwner {
    require(_to != address(0x0), "invalid address");
    uint256 ethAmt = address(this).balance;
    ethAmt = (ethAmt * buybackRate) / PERCENT_PRECISION;

    if (ethAmt == 0) return;

    address[] memory path = new address[](2);
    path[0] = IUniRouter02(uniRouterAddress).WETH();
    path[1] = BUSD;

    uint256[] memory amounts = IUniRouter02(uniRouterAddress)
      .swapExactETHForTokens{ value: ethAmt }(
      0,
      path,
      _to,
      block.timestamp + 600
    );

    emit BusdHarvested(_to, amounts);
  }

  function harvestUSDC(address _to) external onlyOwner {
    require(_to != address(0x0), "invalid address");
    uint256 ethAmt = address(this).balance;
    ethAmt = (ethAmt * buybackRate) / PERCENT_PRECISION;

    if (ethAmt == 0) return;

    address[] memory path = new address[](2);
    path[0] = IUniRouter02(uniRouterAddress).WETH();
    path[1] = USDC;

    uint256[] memory amounts = IUniRouter02(uniRouterAddress)
      .swapExactETHForTokens{ value: ethAmt }(
      0,
      path,
      _to,
      block.timestamp + 600
    );
    emit UsdcHarvested(_to, amounts);
  }

  /**
   * @notice Withdraw token as much as maximum 5% of total supply
   * @param _amount: amount to withdraw
   */
  function withdraw(uint256 _amount) external onlyOwner {
    uint256 tokenAmt = token.balanceOf(address(this));
    require(_amount > 0 && _amount <= tokenAmt, "Invalid Amount");

    if (block.timestamp - startTime > period * TIME_UNIT) {
      startTime = block.timestamp;
      sumWithdrawals = 0;
    }

    uint256 limit = (withdrawalLimit * (token.totalSupply())) /
      PERCENT_PRECISION;
    require(
      sumWithdrawals + _amount <= limit,
      "exceed maximum withdrawal limit for 30 days"
    );

    token.safeTransfer(msg.sender, _amount);
    emit Withdrawn(_amount);
  }

  /**
   * @notice Withdraw liquidity
   * @param _amount: amount to withdraw
   */
  function withdrawLiquidity(uint256 _amount) external onlyOwner {
    uint256 tokenAmt = IERC20(pair).balanceOf(address(this));
    require(_amount > 0 && _amount <= tokenAmt, "Invalid Amount");

    if (block.timestamp - startTime > period * TIME_UNIT) {
      startTime = block.timestamp;
      sumLiquidityWithdrawals = 0;
    }

    uint256 limit = (liquidityWithdrawalLimit * (IERC20(pair).totalSupply())) /
      PERCENT_PRECISION;
    require(
      sumLiquidityWithdrawals + _amount <= limit,
      "exceed maximum LP withdrawal limit for 30 days"
    );

    IERC20(pair).safeTransfer(msg.sender, _amount);
    emit LiquidityWithdrawn(_amount);
  }

  /**
   * @notice Withdraw tokens
   * @dev Needs to be for emergency.
   */
  function emergencyWithdraw() external onlyOwner {
    uint256 tokenAmt = token.balanceOf(address(this));
    if (tokenAmt > 0) {
      token.transfer(msg.sender, tokenAmt);
    }

    tokenAmt = IERC20(pair).balanceOf(address(this));
    if (tokenAmt > 0) {
      IERC20(pair).transfer(msg.sender, tokenAmt);
    }

    uint256 ethAmt = address(this).balance;
    if (ethAmt > 0) {
      payable(msg.sender).transfer(ethAmt);
    }
    emit EmergencyWithdrawn();
  }

  /**
   * @notice Set duration for withdraw limit
   * @param _period: duration
   */
  function setWithdrawalLimitPeriod(uint256 _period) external onlyOwner {
    require(_period >= 10, "small period");
    period = _period;
    emit PeriodUpdated(_period);
  }

  /**
   * @notice Set liquidity withdraw limit
   * @param _percent: percentage of LP supply in point
   */
  function setLiquidityWithdrawalLimit(uint256 _percent) external onlyOwner {
    require(_percent < PERCENT_PRECISION, "Invalid percentage");

    liquidityWithdrawalLimit = _percent;
    emit LiquidityWithdrawLimitUpdated(_percent);
  }

  /**
   * @notice Set withdraw limit
   * @param _percent: percentage of total supply in point
   */
  function setWithdrawalLimit(uint256 _percent) external onlyOwner {
    require(_percent < PERCENT_PRECISION, "Invalid percentage");

    withdrawalLimit = _percent;
    emit WithdrawLimitUpdated(_percent);
  }

  /**
   * @notice Set buyback rate
   * @param _percent: percentage in point
   */
  function setBuybackRate(uint256 _percent) external onlyOwner {
    require(_percent < PERCENT_PRECISION, "Invalid percentage");

    buybackRate = _percent;
    emit BuybackRateUpdated(_percent);
  }

  /**
   * @notice Set addliquidy rate
   * @param _percent: percentage in point
   */
  function setAddLiquidityRate(uint256 _percent) external onlyOwner {
    require(_percent < PERCENT_PRECISION, "Invalid percentage");

    addLiquidityRate = _percent;
    emit AddLiquidityRateUpdated(_percent);
  }

  /**
   * @notice Set buyback wallet of farm contract
   * @param _uniRouter: dex router address
   * @param _slipPage: slip page for swap
   * @param _bnbToTokenPath: bnb-token swap path
   * @param _bnbToDividendPath: bnb-token swap path
   * @param _dividendToTokenPath: bnb-token swap path
   */
  function setSwapSettings(
    address _uniRouter,
    uint256 _slipPage,
    address[] memory _bnbToTokenPath,
    address[] memory _bnbToDividendPath,
    address[] memory _dividendToTokenPath
  ) external onlyOwner {
    require(_uniRouter != address(0x0), "invalid address");
    require(_slipPage <= slippageFactorUL, "_slippage too high");

    uniRouterAddress = _uniRouter;
    slippageFactor = _slipPage;
    bnbToTokenPath = _bnbToTokenPath;
    bnbToDividendPath = _bnbToDividendPath;
    dividendToTokenPath = _dividendToTokenPath;

    emit SetSwapConfig(
      _uniRouter,
      _slipPage,
      _bnbToTokenPath,
      _bnbToDividendPath,
      _dividendToTokenPath
    );
  }

  /**
   * @notice set buyback wallet of farm contract
   * @param _farm: farm contract address
   * @param _addr: buyback wallet address
   */
  function setFarmServiceInfo(address _farm, address _addr) external onlyOwner {
    require(_farm != address(0x0) && _addr != address(0x0), "Invalid Address");
    IFarm(_farm).setBuyBackWallet(_addr);

    emit TransferBuyBackWallet(_farm, _addr);
  }

  /**
   * @notice set buyback wallet of staking contract
   * @param _staking: staking contract address
   * @param _addr: buyback wallet address
   */
  function setStakingServiceInfo(address _staking, address _addr)
    external
    onlyOwner
  {
    require(
      _staking != address(0x0) && _addr != address(0x0),
      "Invalid Address"
    );
    uint256 _fee = IStaking(_staking).performanceFee();
    IStaking(_staking).setServiceInfo(_addr, _fee);

    emit TransferBuyBackWallet(_staking, _addr);
  }

  /**
   * @notice It allows the admin to recover wrong tokens sent to the contract
   * @param _token: the address of the token to withdraw
   * @dev This function is only callable by admin.
   */
  function rescueTokens(address _token) external onlyOwner {
    require(
      _token != address(token) && _token != dividendToken && _token != pair,
      "Cannot be token & dividend token, pair"
    );

    uint256 _tokenAmount;
    if (_token == address(0x0)) {
      _tokenAmount = address(this).balance;
      payable(msg.sender).transfer(_tokenAmount);
    } else {
      _tokenAmount = IERC20(_token).balanceOf(address(this));
      IERC20(_token).safeTransfer(msg.sender, _tokenAmount);
    }
    emit AdminTokenRecovered(_token, _tokenAmount);
  }

  /************************
   ** Internal Methods
   *************************/

  /**
   * @notice get token from ETH via swap.
   * @param _amountIn: eth amount to swap
   * @param _path: swap path
   * @param _to: receiver address
   */
  function _safeSwapEth(
    uint256 _amountIn,
    address[] memory _path,
    address _to
  ) internal returns (uint256) {
    uint256[] memory amounts = IUniRouter02(uniRouterAddress).getAmountsOut(
      _amountIn,
      _path
    );
    uint256 amountOut = amounts[amounts.length - 1];

    address _token = _path[_path.length - 1];
    uint256 beforeAmt = IERC20(_token).balanceOf(address(this));
    IUniRouter02(uniRouterAddress)
      .swapExactETHForTokensSupportingFeeOnTransferTokens{ value: _amountIn }(
      (amountOut * slippageFactor) / PERCENT_PRECISION,
      _path,
      _to,
      block.timestamp + 600
    );
    uint256 afterAmt = IERC20(_token).balanceOf(address(this));

    return afterAmt - beforeAmt;
  }

  /**
   * @notice swap token based on path.
   * @param _amountIn: token amount to swap
   * @param _path: swap path
   * @param _to: receiver address
   */
  function _safeSwap(
    uint256 _amountIn,
    address[] memory _path,
    address _to
  ) internal returns (uint256) {
    uint256[] memory amounts = IUniRouter02(uniRouterAddress).getAmountsOut(
      _amountIn,
      _path
    );
    uint256 amountOut = amounts[amounts.length - 1];

    IERC20(_path[0]).safeApprove(uniRouterAddress, _amountIn);

    address _token = _path[_path.length - 1];
    uint256 beforeAmt = IERC20(_token).balanceOf(address(this));
    IUniRouter02(uniRouterAddress)
      .swapExactTokensForTokensSupportingFeeOnTransferTokens(
        _amountIn,
        (amountOut * slippageFactor) / PERCENT_PRECISION,
        _path,
        _to,
        block.timestamp + 600
      );
    uint256 afterAmt = IERC20(_token).balanceOf(address(this));

    return afterAmt - beforeAmt;
  }

  /**
   * @notice add token-BNB liquidity.
   * @param _token: token address
   * @param _ethAmt: eth amount to add liquidity
   * @param _tokenAmt: token amount to add liquidity
   * @param _to: receiver address
   */
  function _addLiquidityEth(
    address _token,
    uint256 _ethAmt,
    uint256 _tokenAmt,
    address _to
  )
    internal
    returns (
      uint256 amountToken,
      uint256 amountETH,
      uint256 liquidity
    )
  {
    IERC20(_token).safeIncreaseAllowance(uniRouterAddress, _tokenAmt);

    (amountToken, amountETH, liquidity) = IUniRouter02(uniRouterAddress)
      .addLiquidityETH{ value: _ethAmt }(
      address(_token),
      _tokenAmt,
      0,
      0,
      _to,
      block.timestamp + 600
    );

    IERC20(_token).safeApprove(uniRouterAddress, uint256(0));
  }

  receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This treasury contract has been developed by brewlabs.info
 */
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import "./libs/IUniRouter02.sol";

contract BrewlabsRevenue is Ownable {
    using SafeERC20 for IERC20;

    // Whether it is initialized
    bool private isInitialized;


    address public walletA;
    address public walletB;

    uint256 public walletARate = 3000;
    uint256 public saleRate = 10000; // 100%

    // swap router and path, slipPage
    address public uniRouterAddress;
    address[] public swapPath;
    
    event TokenBuyBack(uint256 amountToken);
    event DividendRateUpdated(uint256 rate1, uint256 rate2);
    event SaleRateUpdated(uint256 rate);
    event SetSwapConfig(address router, address[] path);

    constructor() {}
   
    /**
     * @notice Initialize the contract
     * @param _walletA: contract A
     * @param _walletB: contract B
     * @param _uniRouter: uniswap router address for swap tokens
     * @param _swapPath: swap path to buy Token
     */
    function initialize(
        address _walletA,
        address _walletB,
        address _uniRouter,
        address[] memory _swapPath
    ) external onlyOwner {
        require(!isInitialized, "Already initialized");
        require(IUniRouter01(_uniRouter).WETH() == _swapPath[0], "invalid router");

        // Make this contract initialized
        isInitialized = true;

        walletA = _walletA;
        walletB = _walletB;
        uniRouterAddress = _uniRouter;
        swapPath = _swapPath;
    }

    /**
     * @notice Buy token from BNB
     */
    function buyBack() external onlyOwner {
        if(swapPath.length < 2) return;

        address tokenB = swapPath[swapPath.length - 1];

        uint256 swapAmt = address(this).balance;
        swapAmt = swapAmt * saleRate / 10000;

        if(swapAmt > 0) {
            _safeSwapEth(swapAmt, swapPath, address(this));

            uint256 tokenBal = IERC20(tokenB).balanceOf(address(this));
            uint256 tokenAmt = tokenBal * walletARate / 10000;
            
            IERC20(tokenB).transfer(walletA, tokenAmt);
            IERC20(tokenB).transfer(walletB, tokenBal - tokenAmt);
        }
    }

    /**
     * @notice Set sale rate
     * @param _rate: percentage in point
     */
    function setSaleRate(uint256 _rate) external onlyOwner {
        require(_rate < 10000, "Invalid percentage");

        saleRate = _rate;
        emit SaleRateUpdated(_rate);
    }

    /**
     * @notice Set dividend rate
     * @param _aRate: percentage in point
     */
    function setDividendRate(uint256 _aRate) external onlyOwner {
        require(_aRate <= 10000, "Invalid percentage");

        walletARate = _aRate;
        emit DividendRateUpdated(walletARate, 10000 - _aRate);
    }

    function setWalletA(address _walletA) external onlyOwner {
        require(_walletA != address(0x0), "invalid address");
        walletA = _walletA;
    }

    function setWalletB(address _walletB) external onlyOwner {
        require(_walletB != address(0x0), "invalid address");
        walletB = _walletB;
    }
    
    /**
     * @notice Set buyback wallet of farm contract
     * @param _uniRouter: dex router address
     * @param _path: bnb-token swap path
     */
    function setSwapSettings(address _uniRouter, address[] memory _path) external onlyOwner {
        require(IUniRouter01(_uniRouter).WETH() == _path[0], "invalid router");
        uniRouterAddress = _uniRouter;
        swapPath = _path;

        emit SetSwapConfig(_uniRouter, _path);
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _token: the address of the token to withdraw
     * @dev This function is only callable by admin.
     */
    function rescueToken(address _token) external onlyOwner {
        if(_token == address(0x0)) {
            uint256 _tokenAmount = address(this).balance;
            payable(msg.sender).transfer(_tokenAmount);
        } else {
            uint256 _tokenAmount = IERC20(_token).balanceOf(address(this));
            IERC20(_token).safeTransfer(msg.sender, _tokenAmount);
        }
    }


    /************************
    ** Internal Methods
    *************************/
    /*
     * @notice get token from ETH via swap.
     */
    function _safeSwapEth(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal {
        IUniRouter02(uniRouterAddress).swapExactETHForTokensSupportingFeeOnTransferTokens{value: _amountIn}(
            0,
            _path,
            _to,
            block.timestamp + 600
        );
    }
    
    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

interface IDividendToken {
    function claim() external;
}

contract BrewlabsLocker is Ownable{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool public isActive = false;
    bool private initialized = false;

    IERC20 public brews;

    address public  reflectionToken;
    uint256 private accReflectionPerShare;
    uint256 private allocatedReflections;

    uint256 private PRECISION_FACTOR = 1 ether;

    struct Distribution {
        address distributor;        // distributor address
        uint256 alloc;              // allocation token amount
        uint256 duration;           // distributor can unlock after duration in minutes 
        uint256 unlockRate;         // distributor can unlock amount as much as unlockRate(in wei) per block after duration
        uint256 lastClaimBlock;     // last claimed block number
        uint256 tokenDebt;          // claimed token amount
        uint256 reflectionDebt;     
    }
   
    mapping(address => Distribution) public distributions;
    mapping(address => bool) isDistributor;
    address[] public distributors;

    event AddDistribution(address distributor, uint256 allocation, uint256 duration, uint256 unlockRate);
    event UpdateDistribution(address distributor, uint256 allocation, uint256 duration, uint256 unlockRate);
    event RemoveDistribution(address distributor);
    event Claim(address distributor, uint256 amount);
        
    modifier onlyActive() {
        require(isActive == true, "not active");
        _;
    }

    constructor () {}

    function initialize(IERC20 _token, address _reflectionToken) external onlyOwner {
        require(initialized == false, "already initialized");
        initialized = true;

        brews = _token;
        reflectionToken = _reflectionToken;
    }


    function addDistribution(address distributor, uint256 allocation, uint256 duration, uint256 unlockRate) external onlyOwner {
        require(isDistributor[distributor] == false, "already set");

        isDistributor[distributor] = true;
        distributors.push(distributor);
        
        Distribution storage _distribution = distributions[distributor];        
        _distribution.distributor = distributor;
        _distribution.alloc = allocation;
        _distribution.duration = duration;
        _distribution.unlockRate = unlockRate;
        _distribution.tokenDebt = 0;

        uint256 firstUnlockBlock = block.number.add(duration.mul(20));
        _distribution.lastClaimBlock = firstUnlockBlock;

        _distribution.reflectionDebt = allocation.mul(accReflectionPerShare).div(PRECISION_FACTOR);

        emit AddDistribution(distributor, allocation, duration, unlockRate);
    }

    function removeDistribution(address distributor) external onlyOwner {
        require(isDistributor[distributor] == true, "Not found");

        isDistributor[distributor] = false;
        
        Distribution storage _distribution = distributions[distributor];
        _distribution.distributor = address(0x0);
        _distribution.alloc = 0;
        _distribution.duration = 0;
        _distribution.unlockRate = 0;
        _distribution.lastClaimBlock = 0;
        _distribution.tokenDebt = 0;
        _distribution.reflectionDebt = 0;

        emit RemoveDistribution(distributor);
    }

    function updateDistribution(address distributor, uint256 allocation, uint256 duration, uint256 unlockRate) external onlyOwner {
        require(isDistributor[distributor] == true, "Not found");

        Distribution storage _distribution = distributions[distributor];

        require(_distribution.lastClaimBlock > block.number, "cannot update");

        _distribution.alloc = allocation;
        _distribution.duration = duration;
        _distribution.unlockRate = unlockRate;

        uint256 firstUnlockBlock = block.number.add(duration.mul(20));
        _distribution.lastClaimBlock = firstUnlockBlock;

        _distribution.reflectionDebt = allocation.mul(accReflectionPerShare).div(PRECISION_FACTOR);

        emit UpdateDistribution(distributor, allocation, duration, unlockRate);
    }

    function claim() external onlyActive {
        require(claimable(msg.sender) == true, "not claimable");
        
        harvest();

        Distribution storage _distribution = distributions[msg.sender];
        
        uint256 amount = _distribution.alloc.sub(_distribution.tokenDebt);
        uint256 claimAmt = _distribution.unlockRate.mul(block.number.sub(_distribution.lastClaimBlock));
        if(claimAmt > amount) claimAmt = amount;

        _distribution.tokenDebt = _distribution.tokenDebt.add(claimAmt);
        _distribution.reflectionDebt = (amount.sub(claimAmt)).mul(accReflectionPerShare).div(PRECISION_FACTOR);
        _distribution.lastClaimBlock = block.number;
        
        brews.safeTransfer(_distribution.distributor, claimAmt);

        emit Claim(_distribution.distributor, claimAmt);
    }

    function harvest() public onlyActive {
        if(isDistributor[msg.sender] == false) return;

        _updatePool();

        Distribution storage _distribution = distributions[msg.sender];
        uint256 amount = _distribution.alloc.sub(_distribution.tokenDebt);
        uint256 pending = amount.mul(accReflectionPerShare).div(PRECISION_FACTOR).sub(_distribution.reflectionDebt);

        _distribution.reflectionDebt = amount.mul(accReflectionPerShare).div(PRECISION_FACTOR);

        if(pending > 0) {
            IERC20(reflectionToken).safeTransfer(msg.sender, pending);
            allocatedReflections = allocatedReflections.sub(pending);
        }
    }

    function pendingClaim(address _user) external view returns (uint256) {
        if(isDistributor[_user] == false) return 0;        

        Distribution storage _distribution = distributions[_user];
        if(_distribution.lastClaimBlock >= block.number) return 0;
        
        uint256 amount = _distribution.alloc.sub(_distribution.tokenDebt);
        uint256 claimAmt = _distribution.unlockRate.mul(block.number.sub(_distribution.lastClaimBlock));
        if(claimAmt > amount) claimAmt = amount;

        return amount;
    }

    function pendingReflection(address _user) external view returns (uint256) {
        if(isDistributor[_user] == false) return 0;

        uint256 tokenAmt = brews.balanceOf(address(this));
        if(tokenAmt == 0) return 0;

        Distribution storage _distribution = distributions[_user];

        uint256 reflectionAmt = IERC20(reflectionToken).balanceOf(address(this));
        reflectionAmt = reflectionAmt.sub(allocatedReflections);
        uint256 _accReflectionPerShare = accReflectionPerShare.add(reflectionAmt.mul(PRECISION_FACTOR).div(tokenAmt));
        
        uint256 amount = _distribution.alloc.sub(_distribution.tokenDebt);
        uint256 pending = amount.mul(_accReflectionPerShare).div(PRECISION_FACTOR).sub(_distribution.reflectionDebt);

        return pending;
    }

    function claimable(address _user) public view returns (bool) {
        if(isDistributor[_user] == false) return false;
        if(distributions[_user].lastClaimBlock >= block.number) return false;

        Distribution memory _distribution = distributions[_user];
        uint256 amount = _distribution.alloc.sub(_distribution.tokenDebt);
        if(amount > 0) return true;

        return false;
    }

    function setStatus(bool _isActive) external onlyOwner {
        isActive = _isActive;
    }

    function emergencyWithdraw() external onlyOwner {
        uint256 tokenAmt = brews.balanceOf(address(this));
        if(tokenAmt > 0) {
            brews.transfer(msg.sender, tokenAmt);
        }

        uint256 reflectionAmt = IERC20(reflectionToken).balanceOf(address(this));
        if(reflectionAmt > 0) {
            IERC20(reflectionToken).transfer(msg.sender, reflectionAmt);
        }
    }

    function claimDividendFromToken() external onlyOwner {
        IDividendToken(address(brews)).claim();
    }

    function _updatePool() internal {
        uint256 tokenAmt = brews.balanceOf(address(this));
        if(tokenAmt == 0) return;

        uint256 reflectionAmt = 0;
        reflectionAmt = IERC20(reflectionToken).balanceOf(address(this));
        reflectionAmt = reflectionAmt.sub(allocatedReflections);

        accReflectionPerShare = accReflectionPerShare.add(reflectionAmt.mul(PRECISION_FACTOR).div(tokenAmt));
        allocatedReflections = allocatedReflections.add(reflectionAmt);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./libs/PriceOracle.sol";
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId) external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );

    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

interface IERC20Extended is IERC20 {
    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);
}

interface ITwapOracle {
    function twap(address _token, uint256 _amountIn) external view returns (uint144 _amountOut);
}

contract BrewlabsPriceOracle is PriceOracle {
    using SafeMath for uint256;
    using SafeERC20 for IERC20Extended;

    address public admin;
    address public wrapped;

    /// @notice Chainlink Aggregators
    mapping(address => AggregatorV3Interface) public aggregators;    

    struct PriceInfo {
        address token;              // Address of token contract, TOKEN
        address baseToken;          // Address of base token contract, BASETOKEN
        address lpToken;            // Address of TOKEN-BASETOKEN pair contract
        bool active;                // Active status of price record 0 
    }

    struct TwapPriceInfo {
        address token;              // Address of token contract, TOKEN
        address baseToken;          // Address of base token contract, BASETOKEN
        address twapOracle;         // Address of twap oracle contract
        bool active;                // Active status of price record 0 
    }

    mapping(address => PriceInfo) public priceRecords;
    mapping(address => TwapPriceInfo) public priceTwapRecords;
    mapping(address => uint256) public assetPrices;
    
    event NewAdmin(address oldAdmin, address newAdmin);
    event PriceRecordUpdated(address token, address baseToken, address lpToken, bool _active);
    event TwapPriceRecordUpdated(address token, address baseToken, address twapOracle, bool _active);
    event DirectPriceUpdated(address token, uint256 oldPrice, uint256 newPrice);
    event AggregatorUpdated(address tokenAddress, address source);

    constructor(address _wrapped) {
        wrapped = _wrapped;
        admin = msg.sender;
    }

    function getTokenPrice(address _tokenAddress) external view override returns (uint256) {
        address tokenAddress = _tokenAddress;
        if (_tokenAddress == address(0)) {
            tokenAddress = wrapped;
        }
        uint256 tokenPrice = assetPrices[tokenAddress];
        if (tokenPrice == 0) {
            tokenPrice = getPriceFromOracle(tokenAddress);
        }
        if (tokenPrice == 0) {
            tokenPrice = getPriceFromTwap(tokenAddress);
        }
        if (tokenPrice == 0) {
            tokenPrice = getPriceFromDex(tokenAddress);
        } 
        return tokenPrice;
    }

    function getPriceFromDex(address _tokenAddress) public view returns (uint256) {
        PriceInfo storage priceInfo = priceRecords[_tokenAddress];
        if (priceInfo.active) {
            uint256 rawTokenAmount = IERC20Extended(priceInfo.token).balanceOf(priceInfo.lpToken);
            uint256 tokenDecimalDelta = 18 - uint256(IERC20Extended(priceInfo.token).decimals());
            uint256 tokenAmount = rawTokenAmount.mul(10**tokenDecimalDelta);
            uint256 rawBaseTokenAmount = IERC20Extended(priceInfo.baseToken).balanceOf(priceInfo.lpToken);
            uint256 baseTokenDecimalDelta = 18 - uint256(IERC20Extended(priceInfo.baseToken).decimals());
            uint256 baseTokenAmount = rawBaseTokenAmount.mul(10**baseTokenDecimalDelta);
            uint256 baseTokenPrice = getPriceFromOracle(priceInfo.baseToken);
            uint256 tokenPrice = baseTokenPrice.mul(baseTokenAmount).div(tokenAmount);

            return tokenPrice;
        } else {
            return 0;
        }
    }

    function getPriceFromTwap(address _tokenAddress) public view returns (uint256) {
        TwapPriceInfo storage priceInfo = priceTwapRecords[_tokenAddress];
        if (priceInfo.active) {
            uint144 twapPrice = ITwapOracle(priceInfo.twapOracle).twap(priceInfo.token, 10**(uint256(IERC20Extended(priceInfo.token).decimals())));
            uint256 baseTokenPrice = getPriceFromOracle(priceInfo.baseToken);
            uint256 tokenPrice = baseTokenPrice.mul(twapPrice).div(10**(uint256(IERC20Extended(priceInfo.token).decimals())));
            return tokenPrice;
        } else {
            return 0;
        }
    }

    function getPriceFromOracle(address _tokenAddress) public view returns (uint256) {
        uint256 chainLinkPrice = getPriceFromChainlink(_tokenAddress);
        return chainLinkPrice;
    }

    function getPriceFromChainlink(address _tokenAddress) public view returns (uint256) {
        AggregatorV3Interface aggregator = aggregators[_tokenAddress];
        if (address(aggregator) != address(0)) {
            ( , int answer, , , ) = aggregator.latestRoundData();

            // It's fine for price to be 0. We have two price feeds.
            if (answer == 0) {
                return 0;
            }

            // Extend the decimals to 1e18.
            uint retVal = uint(answer);
            uint price = retVal.mul(10**(18 - uint(aggregator.decimals())));

            return price;            
        }
        return 0;        
    }

    function setDexPriceInfo(address _token, address _baseToken, address _lpToken, bool _active) external {
        require(msg.sender == admin, "only admin can set DEX price");
        PriceInfo storage priceInfo = priceRecords[_token];
        uint256 baseTokenPrice = getPriceFromOracle(_baseToken);
        require(baseTokenPrice > 0, "invalid base token");
        priceInfo.token = _token;
        priceInfo.baseToken = _baseToken;
        priceInfo.lpToken = _lpToken;
        priceInfo.active = _active;
        emit PriceRecordUpdated(_token, _baseToken, _lpToken, _active);
    }

    function setTwapPriceInfo(address _token, address _baseToken, address _twapOracle, bool _active) external {
        require(msg.sender == admin, "only admin can set DEX price");
        TwapPriceInfo storage priceInfo = priceTwapRecords[_token];
        uint256 baseTokenPrice = getPriceFromOracle(_baseToken);
        require(baseTokenPrice > 0, "invalid base token");
        priceInfo.token = _token;
        priceInfo.baseToken = _baseToken;
        priceInfo.twapOracle = _twapOracle;
        priceInfo.active = _active;
        emit TwapPriceRecordUpdated(_token, _baseToken, _twapOracle, _active);
    }

    function setDirectPrice(address _token, uint256 _price) external {
        require(msg.sender == admin, "only admin can set direct price");
        emit DirectPriceUpdated(_token, assetPrices[_token], _price);
        assetPrices[_token] = _price;
    }

    function setAdmin(address newAdmin) external {
        require(msg.sender == admin, "only admin can set new admin");
        address oldAdmin = admin;
        admin = newAdmin;

        emit NewAdmin(oldAdmin, newAdmin);
    }

    function setAggregators(address[] calldata tokenAddresses, address[] calldata sources) external {
        require(msg.sender == admin, "only the admin may set the aggregators");
        for (uint i = 0; i < tokenAddresses.length; i++) {
            aggregators[tokenAddresses[i]] = AggregatorV3Interface(sources[i]);
            emit AggregatorUpdated(tokenAddresses[i], sources[i]);
        }
    } 

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

abstract contract PriceOracle {
    /// @notice Indicator that this is a PriceOracle contract (for inspection)
    bool public constant isPriceOracle = true;

    /**
      * @notice Get the price of a token
      * @param token The token to get the price of
      * @return The asset price mantissa (scaled by 1e18).
      *  Zero means the price is unavailable.
      */
    function getTokenPrice(address token) external virtual view returns (uint);
}