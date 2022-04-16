// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './SafeERC20.sol';
import './SafeMath.sol';
import './Ownable.sol';
import "./ReentrancyGuard.sol";
import "./IUniRouter02.sol";
import "./IWETH.sol";

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

contract PawthStaking is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // The address of the smart chef factory
    address public POOL_FACTORY;

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
    uint256 public slippageFactor = 950; // 5% default slippage tolerance
    uint256 public constant slippageFactorUL = 995;

    address public uniRouterAddress;
    address[] public reflectionToStakedPath;
    address[] public earnedToStakedPath;


    // The deposit & withdraw fee
    uint256 public constant MAX_FEE = 2000;
    uint256 public depositFee;

    uint256 public withdrawFee;
    uint256 public buyBackRate = 7500; // 75%
    uint256 public walletARate = 2500;   // 25%

    address public walletA;
    address public buyBackAddress = 0x000000000000000000000000000000000000dEaD;
    address public buyBackWallet = 0x9036464e4ecD2d40d21EE38a0398AEdD6805a09B;
    uint256 public performanceFee = 0.0005 ether;

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
    uint256 private reflectionDebt;

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
    event NewPoolLimit(uint256 poolLimitPerUser);
    event RewardsStop(uint256 blockNumber);

    event ServiceInfoUpadted(address _addr, uint256 _fee);
    event WalletAUpdated(address _addr);
    event BuybackAddressUpadted(address _addr);
    event DurationUpdated(uint256 _duration);

    event SetSettings(
        uint256 _depositFee,
        uint256 _withdrawFee,
        uint256 _walletARate,
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
        address[] memory _reflectionToStakedPath,
        bool _hasDividend
    ) external {
        require(!isInitialized, "Already initialized");
        require(msg.sender == POOL_FACTORY, "Not factory");

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
        PRECISION_FACTOR = uint256(10**(uint256(40).sub(decimalsRewardToken)));

        uint256 decimalsdividendToken = 18;
        if(address(dividendToken) != address(0x0)) {
            decimalsdividendToken = uint256(IToken(address(dividendToken)).decimals());
            require(decimalsdividendToken < 30, "Must be inferior to 30");
        }
        PRECISION_FACTOR_REFLECTION = uint256(10**(uint256(40).sub(decimalsdividendToken)));

        uniRouterAddress = _uniRouter;
        earnedToStakedPath = _earnedToStakedPath;
        reflectionToStakedPath = _reflectionToStakedPath;

        _resetAllowances();
    }

    /*
     * @notice Deposit staked tokens and collect reward tokens (if any)
     * @param _amount: amount to withdraw (in earnedToken)
     */
    function deposit(uint256 _amount) external nonReentrant {
        require(_amount > 0, "Amount should be greator than 0");

        UserInfo storage user = userInfo[msg.sender];

        if (hasUserLimit) {
            require(
                _amount.add(user.amount) <= poolLimitPerUser,
                "User amount above limit"
            );
        }

        _updatePool();

        if (user.amount > 0) {
            uint256 pending =
                user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR).sub(
                    user.rewardDebt
                );
            if (pending > 0) {
                require(availableRewardTokens() >= pending, "Insufficient reward tokens");
                earnedToken.safeTransfer(address(msg.sender), pending);
                
                if(totalEarned > pending) {
                    totalEarned = totalEarned.sub(pending);
                } else {
                    totalEarned = 0;
                }
            }

            uint256 pendingReflection = 
                user.amount.mul(accDividendPerShare).div(PRECISION_FACTOR_REFLECTION).sub(
                    user.reflectionDebt
                );
            if (pendingReflection > 0 && hasDividend) {
                if(address(dividendToken) == address(0x0)) {
                    payable(msg.sender).transfer(pendingReflection);
                } else {
                    IERC20(dividendToken).safeTransfer(address(msg.sender), pendingReflection);
                }
                totalReflections = totalReflections.sub(pendingReflection);
            }
        }

        
        uint256 beforeAmount = stakingToken.balanceOf(address(this));
        stakingToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        uint256 afterAmount = stakingToken.balanceOf(address(this));
        
        uint256 realAmount = afterAmount.sub(beforeAmount);
        if (depositFee > 0) {
            uint256 fee = realAmount.mul(depositFee).div(10000);
            if (fee > 0) {
                stakingToken.safeTransfer(walletA, fee);
                realAmount = realAmount.sub(fee);
            }
        }
        
        user.amount = user.amount.add(realAmount);
        user.rewardDebt = user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR);
        user.reflectionDebt = user.amount.mul(accDividendPerShare).div(PRECISION_FACTOR_REFLECTION);

        totalStaked = totalStaked.add(realAmount);
        
        emit Deposit(msg.sender, realAmount);
    }

    /*
     * @notice Withdraw staked tokens and collect reward tokens
     * @param _amount: amount to withdraw (in earnedToken)
     */
    function withdraw(uint256 _amount) external nonReentrant {
        require(_amount > 0, "Amount should be greator than 0");

        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "Amount to withdraw too high");

        _updatePool();

        if(user.amount > 0) {
            uint256 pending =
                user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR).sub(
                    user.rewardDebt
                );
            if (pending > 0) {
                require(availableRewardTokens() >= pending, "Insufficient reward tokens");
                earnedToken.safeTransfer(address(msg.sender), pending);
                
                if(totalEarned > pending) {
                    totalEarned = totalEarned.sub(pending);
                } else {
                    totalEarned = 0;
                }
            }

            uint256 pendingReflection = 
                user.amount.mul(accDividendPerShare).div(PRECISION_FACTOR_REFLECTION).sub(
                    user.reflectionDebt
                );
            if (pendingReflection > 0 && hasDividend) {
                if(address(dividendToken) == address(0x0)) {
                    payable(msg.sender).transfer(pendingReflection);
                } else {
                    IERC20(dividendToken).safeTransfer(address(msg.sender), pendingReflection);
                }
                totalReflections = totalReflections.sub(pendingReflection);
            }
        }

        uint256 realAmount = _amount;

        if (user.amount < _amount) {
            realAmount = user.amount;
        }

        user.amount = user.amount.sub(realAmount);
        totalStaked = totalStaked.sub(realAmount);

        if (withdrawFee > 0) {
            uint256 fee = realAmount.mul(withdrawFee).div(10000);

            uint256 _walletAAmt = fee.mul(walletARate).div(10000);
            if (_walletAAmt > 0) {
                stakingToken.safeTransfer(walletA, _walletAAmt);
                realAmount = realAmount.sub(_walletAAmt);
            }
            uint256 _buybackAmt = fee.mul(buyBackRate).div(10000);
            if (_buybackAmt > 0) {
                stakingToken.safeTransfer(buyBackAddress, _buybackAmt);
                realAmount = realAmount.sub(_buybackAmt);
            }
        }

        stakingToken.safeTransfer(address(msg.sender), realAmount);

        user.rewardDebt = user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR);
        user.reflectionDebt = user.amount.mul(accDividendPerShare).div(PRECISION_FACTOR_REFLECTION);

        emit Withdraw(msg.sender, _amount);
    }

    function claimReward() external payable nonReentrant {
        UserInfo storage user = userInfo[msg.sender];

        _transferPerformanceFee();
        _updatePool();

        if (user.amount == 0) return;

        uint256 pending =
            user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR).sub(
                user.rewardDebt
            );
        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            earnedToken.safeTransfer(address(msg.sender), pending);
            
            if(totalEarned > pending) {
                totalEarned = totalEarned.sub(pending);
            } else {
                totalEarned = 0;
            }
        }
        
        user.rewardDebt = user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR);
    }

    function claimDividend() external payable nonReentrant {
        require(hasDividend == true, "No reflections");
        UserInfo storage user = userInfo[msg.sender];

        _transferPerformanceFee();
        _updatePool();

        if (user.amount == 0) return;

        uint256 pendingReflection = 
            user.amount.mul(accDividendPerShare).div(PRECISION_FACTOR_REFLECTION).sub(
                user.reflectionDebt
            );
        if (pendingReflection > 0) {
            if(address(dividendToken) == address(0x0)) {
                payable(msg.sender).transfer(pendingReflection);
            } else {
                IERC20(dividendToken).safeTransfer(address(msg.sender), pendingReflection);
            }
            totalReflections = totalReflections.sub(pendingReflection);
        }
        
        user.reflectionDebt = user.amount.mul(accDividendPerShare).div(PRECISION_FACTOR_REFLECTION);
    }

    function compoundReward() external payable nonReentrant {
        UserInfo storage user = userInfo[msg.sender];

        _transferPerformanceFee();
        _updatePool();

        if (user.amount == 0) return;

        uint256 pending =
            user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR).sub(
                user.rewardDebt
            );
        if (pending > 0) {
            require(availableRewardTokens() >= pending, "Insufficient reward tokens");
            if(totalEarned > pending) {
                totalEarned = totalEarned.sub(pending);
            } else {
                totalEarned = 0;
            }
            
            if(address(stakingToken) != address(earnedToken)) {
                uint256 beforeAmount = stakingToken.balanceOf(address(this));
                _safeSwap(pending, earnedToStakedPath, address(this));
                uint256 afterAmount = stakingToken.balanceOf(address(this));
                pending = afterAmount.sub(beforeAmount);
            }

            if (hasUserLimit) {
                require(
                    pending.add(user.amount) <= poolLimitPerUser,
                    "User amount above limit"
                );
            }

            totalStaked = totalStaked.add(pending);
            user.amount = user.amount.add(pending);
            user.reflectionDebt = user.amount.mul(accDividendPerShare).div(PRECISION_FACTOR_REFLECTION).sub(
                (user.amount.sub(pending)).mul(accDividendPerShare).div(PRECISION_FACTOR_REFLECTION).sub(user.reflectionDebt)
            );

            emit Deposit(msg.sender, pending);
        }
        
        user.rewardDebt = user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR);
    }

    function compoundDividend() external payable nonReentrant {
        require(hasDividend == true, "No reflections");
        UserInfo storage user = userInfo[msg.sender];

        _transferPerformanceFee();
        _updatePool();

        if (user.amount == 0) return;

        uint256 pending = 
            user.amount.mul(accDividendPerShare).div(PRECISION_FACTOR_REFLECTION).sub(
                user.reflectionDebt
            );
        if (pending > 0) {
            totalReflections = totalReflections.sub(pending);

            if(address(stakingToken) != address(dividendToken)) {
                if(address(dividendToken) == address(0x0)) {
                    address wethAddress = IUniRouter02(uniRouterAddress).WETH();
                    IWETH(wethAddress).deposit{ value: pending }();
                }

                uint256 beforeAmount = stakingToken.balanceOf(address(this));
                _safeSwap(pending, reflectionToStakedPath, address(this));
                uint256 afterAmount = stakingToken.balanceOf(address(this));

                pending = afterAmount.sub(beforeAmount);
            }

            if (hasUserLimit) {
                require(
                    pending.add(user.amount) <= poolLimitPerUser,
                    "User amount above limit"
                );
            }

            totalStaked = totalStaked.add(pending);
            user.amount = user.amount.add(pending);
            user.rewardDebt = user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR).sub(
                (user.amount.sub(pending)).mul(accTokenPerShare).div(PRECISION_FACTOR).sub(user.rewardDebt)
            );

            emit Deposit(msg.sender, pending);
        }
        
        user.reflectionDebt = user.amount.mul(accDividendPerShare).div(PRECISION_FACTOR_REFLECTION);
    }

    function _transferPerformanceFee() internal {
        require(msg.value >= performanceFee, 'should pay small gas to compound or harvest');

        payable(buyBackWallet).transfer(performanceFee);
        if(msg.value > performanceFee) {
            payable(msg.sender).transfer(msg.value.sub(performanceFee));
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
            totalStaked = totalStaked.sub(amountToTransfer);
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
            return _amount.sub(totalStaked);
        }

        return _amount;
    }

    /**
     * @notice Available amount of reflection token
     */
    function availabledividendTokens() public view returns (uint256) {
        if(address(dividendToken) == address(0x0)) {
            return address(this).balance;
        }

        uint256 _amount = IERC20(dividendToken).balanceOf(address(this));
        
        if(address(dividendToken) == address(earnedToken)) {
            if(_amount < totalEarned) return 0;
            _amount = _amount.sub(totalEarned);
        }

        if(address(dividendToken) == address(stakingToken)) {
            if(_amount < totalStaked) return 0;
            _amount = _amount.sub(totalStaked);
        }

        return _amount;
    }

    /*
     * @notice View function to see pending reward on frontend.
     * @param _user: user address
     * @return Pending reward for a given user
     */
    function pendingReward(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        
        if (block.number > lastRewardBlock && totalStaked != 0 && lastRewardBlock > 0) {
            uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
            uint256 cakeReward = multiplier.mul(rewardPerBlock);
            uint256 adjustedTokenPerShare =
                accTokenPerShare.add(
                    cakeReward.mul(PRECISION_FACTOR).div(totalStaked)
                );
            return
                user
                    .amount
                    .mul(adjustedTokenPerShare)
                    .div(PRECISION_FACTOR)
                    .sub(user.rewardDebt);
        } else {
            return
                user.amount.mul(accTokenPerShare).div(PRECISION_FACTOR).sub(
                    user.rewardDebt
                );
        }
    }

    function pendingDividends(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];

        if(totalStaked == 0) return 0;
        
        uint256 reflectionAmount = availabledividendTokens();
        uint256 sTokenBal = stakingToken.balanceOf(address(this));

        uint256 adjustedReflectionPerShare = accDividendPerShare.add(
                reflectionAmount.sub(totalReflections).mul(PRECISION_FACTOR_REFLECTION).div(sTokenBal)
            );
        
        uint256 pendingReflection = 
                user.amount.mul(adjustedReflectionPerShare).div(PRECISION_FACTOR_REFLECTION).sub(
                    user.reflectionDebt
                );
        
        return pendingReflection;
    }

    /************************
    ** Admin Methods
    *************************/
    function harvest() external onlyOwner {        
        _updatePool();

        uint256 _amount = stakingToken.balanceOf(address(this));
        _amount = _amount.sub(totalStaked);

        uint256 pendingReflection = _amount.mul(accDividendPerShare).div(PRECISION_FACTOR_REFLECTION).sub(reflectionDebt);
        if(pendingReflection > 0) {
            if(address(dividendToken) == address(0x0)) {
                payable(walletA).transfer(pendingReflection);
            } else {
                IERC20(dividendToken).safeTransfer( walletA, pendingReflection);
            }
            totalReflections = totalReflections.sub(pendingReflection);
        }
        
        reflectionDebt = _amount.mul(accDividendPerShare).div(PRECISION_FACTOR_REFLECTION);
    }

    /*
     * @notice Deposit reward token
     * @dev Only call by owner. Needs to be for deposit of reward token when reflection token is same with reward token.
     */
    function depositRewards(uint _amount) external nonReentrant {
        require(_amount > 0);

        uint256 beforeAmt = earnedToken.balanceOf(address(this));
        earnedToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = earnedToken.balanceOf(address(this));

        totalEarned = totalEarned.add(afterAmt).sub(beforeAmt);
    }

    /*
     * @notice Withdraw reward token
     * @dev Only callable by owner. Needs to be for emergency.
     */
    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
        require( block.number > bonusEndBlock, "Pool is running");
        if(address(earnedToken) != address(dividendToken)) {
            require(availableRewardTokens() >= _amount, "Insufficient reward tokens");
        }

        if(_amount == 0) _amount = availableRewardTokens();
        earnedToken.safeTransfer(address(msg.sender), _amount);
        
        if (totalEarned > 0) {
            if (_amount > totalEarned) {
                totalEarned = 0;
            } else {
                totalEarned = totalEarned.sub(_amount);
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
            require(_tokenAmount <= tokenBal.sub(totalStaked), "Insufficient balance");
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

        startBlock = block.number.add(100);
        bonusEndBlock = startBlock.add(duration * 28800);
        lastRewardBlock = startBlock;
        
        emit NewStartAndEndBlocks(startBlock, bonusEndBlock);
    }

    function stopReward() external onlyOwner {
        bonusEndBlock = block.number;
    }

    /*
     * @notice Update pool limit per user
     * @dev Only callable by owner.
     * @param _hasUserLimit: whether the limit remains forced
     * @param _poolLimitPerUser: new pool limit per user
     */
    function updatePoolLimitPerUser( bool _hasUserLimit, uint256 _poolLimitPerUser) external onlyOwner {
        require(hasUserLimit, "Must be set");
        if (_hasUserLimit) {
            require(
                _poolLimitPerUser > poolLimitPerUser,
                "New limit must be higher"
            );
            poolLimitPerUser = _poolLimitPerUser;
        } else {
            hasUserLimit = _hasUserLimit;
            poolLimitPerUser = 0;
        }
        emit NewPoolLimit(poolLimitPerUser);
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
        require(_buyBackWallet != address(0x0) || _buyBackWallet != buyBackWallet, "Invalid address");

        buyBackWallet = _buyBackWallet;
        performanceFee = _fee;

        emit ServiceInfoUpadted(_buyBackWallet, _fee);
    }

    function updateWalletA(address _walletA) external onlyOwner {
        require(_walletA != address(0x0) || _walletA != walletA, "Invalid address");

        walletA = _walletA;
        emit WalletAUpdated(_walletA);
    }

    function updateBuybackAddr(address _addr) external onlyOwner {
        require(_addr != address(0x0) || _addr != buyBackAddress, "Invalid address");

        buyBackAddress = _addr;
        emit BuybackAddressUpadted(_addr);
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
        uint256 _walletARate,
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
        walletARate = _walletARate;
        buyBackRate = uint256(10000).sub(walletARate);

        slippageFactor = _slippageFactor;
        uniRouterAddress = _uniRouter;
        reflectionToStakedPath = _reflectionToStakedPath;
        earnedToStakedPath = _earnedToStakedPath;

        emit SetSettings(_depositFee, _withdrawFee, _walletARate, _slippageFactor, _uniRouter, _earnedToStakedPath, _reflectionToStakedPath);
    }

    function resetAllowances() external onlyOwner {
        _resetAllowances();
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
            uint256 reflectionAmount = availabledividendTokens();
            uint256 sTokenBal = stakingToken.balanceOf(address(this));

            accDividendPerShare = accDividendPerShare.add(
                    reflectionAmount.sub(totalReflections).mul(PRECISION_FACTOR_REFLECTION).div(sTokenBal)
                );

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
        uint256 _reward = multiplier.mul(rewardPerBlock);
        accTokenPerShare = accTokenPerShare.add(
            _reward.mul(PRECISION_FACTOR).div(totalStaked)
        );
        lastRewardBlock = block.number;
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
            return _to.sub(_from);
        } else if (_from >= bonusEndBlock) {
            return 0;
        } else {
            return bonusEndBlock.sub(_from);
        }
    }

    function _safeSwap(
        uint256 _amountIn,
        address[] memory _path,
        address _to
    ) internal {
        uint256[] memory amounts = IUniRouter02(uniRouterAddress).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length.sub(1)];

        IUniRouter02(uniRouterAddress).swapExactTokensForTokens(
            _amountIn,
            amountOut.mul(slippageFactor).div(1000),
            _path,
            _to,
            block.timestamp.add(600)
        );
    }

    function _resetAllowances() internal {
        earnedToken.safeApprove(uniRouterAddress, uint256(0));
        earnedToken.safeIncreaseAllowance(
            uniRouterAddress,
            type(uint256).max
        );

        if(address(dividendToken) == address(0x0)) {
            address wethAddress = IUniRouter02(uniRouterAddress).WETH();
            IERC20(wethAddress).safeApprove(uniRouterAddress, uint256(0));
            IERC20(wethAddress).safeIncreaseAllowance(
                uniRouterAddress,
                type(uint256).max
            );
        } else {
            IERC20(dividendToken).safeApprove(uniRouterAddress, uint256(0));
            IERC20(dividendToken).safeIncreaseAllowance(
                uniRouterAddress,
                type(uint256).max
            );
        }        
    }

    receive() external payable {}
}