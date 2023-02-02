//0x5D8A836B359880d04328459Ba29Bf44ae105b1DE
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @author Brewlabs
 * This contract has been developed by brewlabs.info
 */
import './SafeERC20.sol';
import './Ownable.sol';
import "./ReentrancyGuard.sol";

import "./IPriceOracle.sol";
import "./IUniRouter02.sol";
import "./IWETH.sol";

contract EgoStakingV2 is Ownable, ReentrancyGuard {
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

    // swap router and path, slipPage
    uint256 public slippageFactor = 800; // 20% default slippage tolerance
    uint256 public constant slippageFactorUL = 995;

    address public uniRouterAddress;
    address[] public reflectionToStakedPath;
    address[] public earnedToStakedPath;

    IPriceOracle private oracle;

    // The precision factor
    uint256 public PRECISION_FACTOR;
    uint256 public PRECISION_FACTOR_BUSD = 1000000000;
    
    // The staked token
    IERC20 public stakingToken;
    // The earned token
    IERC20 public earnedToken;

    uint256 public totalStaked;

    struct cycleInfo
        {
        uint256 cycleStart;
        uint256 cycleEnd;
        uint256 cycleTotalProduct;
        uint256 botRewards;
        }
    struct stakeInfo
        {
        uint256 stakeStartCycle;
        uint256 stakeStartTime;
        uint256 amount;
        uint256 amountInUsd;
        }
    struct userInCycleInfo
        {
        uint256 Product;
        uint256 Staked;
        uint256 opStake;
        uint256 opUnstake;
        uint256 SubRoutineStart;
        uint256 SubRoutineEnd;
        bool    midCycleOps;
        }

    mapping(address => mapping(uint256 => userInCycleInfo)) public userProductInSpecdCycle;
    mapping(uint256 => cycleInfo) public CycleInfoForSpecdCycle;
    mapping(address => stakeInfo) public stakePerUser; 
    mapping(address => uint256)   public userTotalStaked;
    mapping(address => uint256)   public userClaimedRewards;
    mapping(address => uint256)   public userCompoundedRewards;

    uint256 public cCycle;
    uint256 public currentTime;
    uint256        subRoutineStart;
    uint256        subRoutineEnd;

    uint256 constant MAX_STAKES = 256;
    uint256 private processingLimit = 30;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event AdminTokenRecovered(address tokenRecovered, uint256 amount);

    event UpdatePoolLimit(uint256 poolLimitPerUser, bool hasLimit);

    event ServiceInfoUpadted(address _addr, uint256 _fee);
    event WalletAUpdated(address _addr);

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
     * @param _uniRouter: uniswap router address for swap tokens
     * @param _earnedToStakedPath: swap path to compound (earned -> staking path)
     */

     //0x5425890298aed601595a70AB815c96711a31Bc65, 0x5425890298aed601595a70AB815c96711a31Bc65,0,0,0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee,0xA2Ee1a41d407631BE33E6fe4BB51EF5484b68699,0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee
    function initialize(
        IERC20 _stakingToken,
        IERC20 _earnedToken

     ) external onlyOwner {
        require(!isInitialized, "Already initialized");

        // Make this contract initialized
        isInitialized = true;

        startBlock = block.number;

        stakingToken = _stakingToken;
        earnedToken = _earnedToken;
        
        //oracle = IPriceOracle(_oracle);

        //uniRouterAddress = _uniRouter;
        //earnedToStakedPath = _earnedToStakedPath;
     
        currentTime = block.timestamp;
        cCycle = 0;
        subRoutineStart = currentTime;
        CycleInfoForSpecdCycle[cCycle].cycleStart = currentTime;
    }

    /*
     * @notice Deposit staked tokens
     * @param _amount: amount to deposit (in stakedToken)
     */

    function deposit(uint256 _amount) 
        external 
        payable 
        nonReentrant 
            {
            require(startBlock > 0 && startBlock < block.number, "Staking hasn't started yet");
            require(_amount > 0, "Amount should be greater than 0");         
            
            stakeInfo storage user = stakePerUser[msg.sender];

            uint256 beforeAmount = stakingToken.balanceOf(address(this));

            stakingToken.safeTransferFrom
                (
                address(msg.sender),
                address(this),
                _amount
                );
            uint256 afterAmount = stakingToken.balanceOf(address(this));        
            uint256 realAmount = afterAmount - beforeAmount;

            if (hasUserLimit) 
                {
                require(
                    realAmount + user.amount <= poolLimitPerUser,
                    "User amount above limit"
                );
                }

            currentTime = block.timestamp;
            user.stakeStartTime = currentTime;
            if (user.stakeStartTime == 0) user.stakeStartCycle = cCycle;
            // user.amount = user.amount + _amount;           

            subRoutineEnd = currentTime;
            uint256 subRoutineLength = subRoutineEnd - subRoutineStart;
            CycleInfoForSpecdCycle[cCycle].cycleTotalProduct = CycleInfoForSpecdCycle[cCycle].cycleTotalProduct + totalStaked * subRoutineLength;
                    
            subRoutineStart = subRoutineEnd;
            totalStaked = totalStaked + realAmount;
                    
            userInCycleInfo storage userInCurrentCycle = userProductInSpecdCycle[msg.sender][cCycle];
            userInCurrentCycle.midCycleOps = true;
            userInCurrentCycle.SubRoutineEnd = currentTime;
            if(userInCurrentCycle.SubRoutineStart == 0) userInCurrentCycle.SubRoutineStart = CycleInfoForSpecdCycle[cCycle].cycleStart;
                
            uint256 userSubRoutineLength = userInCurrentCycle.SubRoutineEnd - userInCurrentCycle.SubRoutineStart;
            // userInCurrentCycle.Staked = userTotalStaked[msg.sender];
            userInCurrentCycle.Product = userInCurrentCycle.Product + user.amount * userSubRoutineLength;
            userInCurrentCycle.SubRoutineStart = userInCurrentCycle.SubRoutineEnd;
            userInCurrentCycle.opStake = userInCurrentCycle.opStake + realAmount;
            user.amount = user.amount + realAmount;
            

            emit Deposit(msg.sender, realAmount);
            }


    /*
     * @notice Withdraw staked tokens
     * @param _amount: amount to withdraw (in stakedToken)
     */
    function withdraw(uint256 _amount) 
        external 
        payable 
        nonReentrant 
            {
            require(_amount > 0, "Amount should be greater than 0");
            require(_amount <= stakePerUser[msg.sender].amount , "You cannot withdraw more than you have");
            
            
            stakingToken.safeTransfer(address(msg.sender), _amount);

            subRoutineEnd = block.timestamp;
            uint256 subRoutineLength = subRoutineEnd - subRoutineStart;
            CycleInfoForSpecdCycle[cCycle].cycleTotalProduct = CycleInfoForSpecdCycle[cCycle].cycleTotalProduct + totalStaked * subRoutineLength;

            subRoutineStart = subRoutineEnd;
            totalStaked = totalStaked - _amount;

            userInCycleInfo storage userInCurrentCycle = userProductInSpecdCycle[msg.sender][cCycle];
            userInCurrentCycle.midCycleOps = true;
            userInCurrentCycle.SubRoutineEnd = subRoutineEnd;
            if(userInCurrentCycle.SubRoutineStart == 0) userInCurrentCycle.SubRoutineStart = CycleInfoForSpecdCycle[cCycle].cycleStart;
            uint256 userSubRoutineLength = userInCurrentCycle.SubRoutineEnd - userInCurrentCycle.SubRoutineStart;
            userInCurrentCycle.Product = userInCurrentCycle.Product + stakePerUser[msg.sender].amount * userSubRoutineLength;
            userInCurrentCycle.SubRoutineStart = userInCurrentCycle.SubRoutineEnd;
            stakePerUser[msg.sender].amount = stakePerUser[msg.sender].amount - _amount;
            userInCurrentCycle.opUnstake = userInCurrentCycle.opUnstake + _amount;
            
            emit Withdraw(msg.sender, _amount);
            }

    function claimReward(uint256 _amountRewards) 
        external 
        payable 
        nonReentrant 
            {
            if(startBlock == 0) return;
            require(_amountRewards <= accruedRewardsPerUser() - userClaimedRewards[msg.sender], "You don't have enough accrued rewards");
                   
            userClaimedRewards[msg.sender] = userClaimedRewards[msg.sender] + _amountRewards;
            
            earnedToken.safeTransfer(address(msg.sender), _amountRewards);       
            }

    function compoundReward() 
        external 
        payable 
        nonReentrant 
            {
            if(startBlock == 0) return;
           
            stakeInfo storage user = stakePerUser[msg.sender];


            uint256 tokenPrice = oracle.getTokenPrice(address(stakingToken));
            uint256 _compounded;
            uint256 _pending = userLeftToClaim();
            

            if(address(stakingToken) != address(earnedToken) && _pending > 0) 
                {
                uint256 _beforeAmount = stakingToken.balanceOf(address(this));
                _safeSwap(_pending, earnedToStakedPath, address(this));
                uint256 _afterAmount = stakingToken.balanceOf(address(this));
                _compounded = _afterAmount - _beforeAmount;
                
                userCompoundedRewards[msg.sender] = userCompoundedRewards[msg.sender] + _pending;   
                }
                            
            currentTime = block.timestamp;
            user.stakeStartTime = currentTime;
            if (user.stakeStartTime == 0) user.stakeStartCycle = cCycle;
                   
            subRoutineEnd = currentTime;
            uint256 subRoutineLength = subRoutineEnd - subRoutineStart;
            CycleInfoForSpecdCycle[cCycle].cycleTotalProduct = CycleInfoForSpecdCycle[cCycle].cycleTotalProduct + totalStaked * subRoutineLength;
                    
            subRoutineStart = subRoutineEnd;
            totalStaked = totalStaked + _compounded;
                    
            userInCycleInfo storage userInCurrentCycle = userProductInSpecdCycle[msg.sender][cCycle];
            userInCurrentCycle.midCycleOps = true;
            userInCurrentCycle.SubRoutineEnd = currentTime;
            if(userInCurrentCycle.SubRoutineStart == 0) userInCurrentCycle.SubRoutineStart = CycleInfoForSpecdCycle[cCycle].cycleStart;
                
            uint256 userSubRoutineLength = userInCurrentCycle.SubRoutineEnd - userInCurrentCycle.SubRoutineStart;
            userInCurrentCycle.Product = userInCurrentCycle.Product + userTotalStaked[msg.sender] * userSubRoutineLength;
            userInCurrentCycle.SubRoutineStart = userInCurrentCycle.SubRoutineEnd;
            userInCurrentCycle.Staked = userInCurrentCycle.Staked + _compounded;
            userInCurrentCycle.opStake = userInCurrentCycle.opStake + _compounded;
            user.amount = user.amount + _compounded;
            
            emit Deposit(msg.sender, _compounded);
            
            }
        

    /*
     * @notice Withdraw staked tokens without caring about rewards
     * @dev Needs to be for emergency.
     */
    // function emergencyWithdraw() 
    //     external 
    //     nonReentrant 
    //         {
    //         stakeInfo storage user = stakePerUser[msg.sender];
    
    //         if (user.amount > 0) 
    //             {
    //             stakingToken.safeTransfer(address(msg.sender), user.amount);

    //             user.amount = 0;
    //                         lockupInfo.totalStaked = lockupInfo.totalStaked - amountToTransfer;
    //             totalStaked = totalStaked - amountToTransfer;
    //             }

    //         emit EmergencyWithdraw(msg.sender, amountToTransfer);
    //         }


    /************************
    ** View Functions
    *************************/
    /*
     * @notice View function to see accrued rewards
     * @return Accrued reward for a given user
     */
    function accruedRewardsPerUser()
        public
        view
        returns(uint256)
            {
            uint256 i = stakePerUser[msg.sender].stakeStartCycle;
            uint256 accrued;
            uint256 ASB;
            for(i; i<cCycle; i++)
                {
                userInCycleInfo memory user = userProductInSpecdCycle[msg.sender][i];
                ASB = ASB + user.opStake - user.opUnstake;
                uint256 whichMethod;
                if(user.midCycleOps == false && ASB == 0) whichMethod = 0;
                if(user.midCycleOps == true) whichMethod = 1;
                if(user.midCycleOps == false && ASB > 0) whichMethod = 2;


                uint256 userProduct = calculateUserProductInSpecdCycle(i,whichMethod, ASB);
                uint256 userRatio = calculateUserRatioInSpecdCycle(i, userProduct);
                accrued = accrued + rewards(userRatio, CycleInfoForSpecdCycle[i].botRewards);    
                // accrued = accrued + rewards(calculateUserRatioInSpecdCycle(i, calculateUserProductInSpecdCycle(i,whichMethod)) ,CycleInfoForSpecdCycle[i].botRewards);                 

                }
            return accrued;     
            }        

    /*
     * @notice View function to calculate the user's product in a given cycle
     * @return User's product in a given cycle
     */
    function calculateUserProductInSpecdCycle(uint256 _cycle, uint256 _whichMethod, uint256 _ASB)
        public
        view
        returns(uint256)
            {
            uint256 userProduct;
            userInCycleInfo memory userInCurrentCycle = userProductInSpecdCycle[msg.sender][_cycle];
                
            if (_whichMethod == 0)
                {
                userProduct = 0;
                }
                else if (_whichMethod == 1)
                    {
                    uint256 cycleLength = CycleInfoForSpecdCycle[_cycle].cycleEnd - userInCurrentCycle.SubRoutineStart;
                    userProduct = userInCurrentCycle.Product + _ASB * cycleLength;
                    }
                    else if (_whichMethod == 2)
                        {
                        uint256 cycleLength = CycleInfoForSpecdCycle[_cycle].cycleEnd - CycleInfoForSpecdCycle[_cycle].cycleStart;
                        userProduct = _ASB * cycleLength;
                        }
                        
            return userProduct;
            }
        
    function calculateUserRatioInSpecdCycle(uint256 _cycle, uint256 _product)
        public
        view
        returns(uint256)
            {
            if(_product != 0 && CycleInfoForSpecdCycle[_cycle].cycleTotalProduct !=0)
                {
                return _product * PRECISION_FACTOR_BUSD / CycleInfoForSpecdCycle[_cycle].cycleTotalProduct;
                }
                else return 0;
            }     

    function rewards(uint256 _ratio, uint256 _botRewards)
        public
        view
        returns(uint256)
            {
            if (_ratio != 0) return _ratio * _botRewards / PRECISION_FACTOR_BUSD;
            else return 0;
            }

    function userLeftToClaim()
        public
        view
        returns(uint256)
            {
            return accruedRewardsPerUser() - userClaimedRewards[msg.sender] - userCompoundedRewards[msg.sender];
            }

    /************************
    ** Admin Functions
    *************************/

    /*
     * @notice Deposit reward token
     * @dev Only call by owner. Needs to be for deposit of reward token when reflection token is same with reward token.
     */
    function newCycle(uint _amount) external onlyOwner nonReentrant {
        require(_amount > 0, "invalid amount");

        uint256 beforeAmt = earnedToken.balanceOf(address(this));
        earnedToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterAmt = earnedToken.balanceOf(address(this));

        cycleInfo storage cycle = CycleInfoForSpecdCycle[cCycle];
        cycle.cycleEnd = block.timestamp;
        cycle.botRewards = afterAmt - beforeAmt;

                            
        subRoutineEnd = cycle.cycleEnd;
        uint256 subRoutineLength = subRoutineEnd - subRoutineStart;
        cycle.cycleTotalProduct = cycle.cycleTotalProduct + totalStaked * subRoutineLength; 

        subRoutineStart = subRoutineEnd;

        cCycle +=1;
        addCycle(subRoutineStart);


        
    }

    /*
     * @notice Withdraw reward token
     * @dev Only callable by owner. Needs to be for emergency.
     */
    // function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
    //     require( block.number > bonusEndBlock, "Pool is running");
    //     require(availableRewardTokens() >= _amount, "Insufficient reward tokens");

    //     earnedToken.safeTransfer(address(msg.sender), _amount);
        
    //     if (totalEarned > 0) {
    //         if (_amount > totalEarned) {
    //             totalEarned = 0;
    //         } else {
    //             totalEarned = totalEarned - _amount;
    //         }
    //     }
    // }

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

    // function setServiceInfo(address _addr, uint256 _fee) external {
    //     require(msg.sender == buyBackWallet, "setServiceInfo: FORBIDDEN");
    //     require(_addr != address(0x0), "Invalid address");
    //     require(_fee < 0.05 ether, "fee cannot exceed 0.05 ether");

    //     buyBackWallet = _addr;
    //     performanceFee = _fee;

    //     emit ServiceInfoUpadted(_addr, _fee);
    // }
     
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
    
    /************************
    ** Internal Methods
    *************************/
    
    function addCycle(uint256 _addTime)
        internal
            {
            CycleInfoForSpecdCycle[cCycle].cycleStart = _addTime;
            currentTime = _addTime;
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