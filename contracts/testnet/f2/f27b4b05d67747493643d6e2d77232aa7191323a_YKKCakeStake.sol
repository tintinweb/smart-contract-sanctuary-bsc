pragma solidity ^0.8.0;

import "./CakeStakeUpgradeable.sol";
contract YKKCakeStake is CakeStakeUpgradeable{


    function initialize (address uniV2Router02_, address USDT_, address rewardToken_, address cakePool_, address ykkPool_, uint256 startBlock_,  address fundAddress_) public initializer {
        __CakeStake_init(uniV2Router02_, USDT_, rewardToken_, cakePool_, ykkPool_, startBlock_, fundAddress_);
    }

    function diffDecimals() override pure public returns(uint256) {
        return 1;
    }

    function currRewardTokenPerRewardCake(uint256 blockNumber_) override view public returns(uint256) {
        if(blockNumber_ < startBlock){
            return 0;
        }
        uint256 diffMonth = (blockNumber_ - startBlock) / 864000;
        if(diffMonth >= 9){
            return 200;
        }
        return 1000 - diffMonth * 100;
    }

}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

pragma solidity >0.5.6;

interface IUniswapV2Pair {
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IYKKToken is IERC20 {

    function inviter(address) view external returns(address);

    function burn(uint256) external;

    function burnFrom(address account, uint256 amount) external;
}

pragma solidity ^0.8.0;

interface IYKKPool {
    function transferToken(address erc20_, address to, uint256 value) external;
}

pragma solidity ^0.8.0;

interface ICakePool {
    struct UserInfo {
        uint256 shares; // number of shares for a user.
        uint256 lastDepositedTime; // keep track of deposited time for potential penalty.
        uint256 cakeAtLastUserAction; // keep track of cake deposited at the last user action.
        uint256 lastUserActionTime; // keep track of the last user action time.
        uint256 lockStartTime; // lock start time.
        uint256 lockEndTime; // lock end time.
        uint256 userBoostedShare; // boost share, in order to give the user higher reward. The user only enjoys the reward, so the principal needs to be recorded as a debt.
        bool locked; //lock status.
        uint256 lockedAmount; // amount deposited during lock period.
    }

    function userInfo(address _user) view external returns(UserInfo memory);

    function token() view external returns(address);
    function getPricePerFullShare() view external returns(uint256);

    function withdrawByAmount(uint256 _amount) external;

    function deposit(uint256 _amount, uint256 _lockDuration) external;

    function calculatePerformanceFee(address _user) external view returns (uint256);
    function MIN_DEPOSIT_AMOUNT() external view returns (uint256);
    function MIN_WITHDRAW_AMOUNT() external view returns (uint256);

}

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "./cake/ICakePool.sol";
import "./interface/IYKKToken.sol";
import "./interface/IYKKPool.sol";
import "./lib/IUniswapV2Router02.sol";
import "./lib/IUniswapV2Pair.sol";
import "./lib/IUniswapV2Factory.sol";

contract CakeStakeUpgradeable is OwnableUpgradeable,PausableUpgradeable {

    using SafeERC20Upgradeable for IERC20Upgradeable;

    IUniswapV2Router02 public uniV2Router02;
    IUniswapV2Pair public uniV2Pair;
    address public USDT;
    address public rewardToken;
    address public stakeToken;
    ICakePool public cakePool;
    uint256 public minStake;
    uint256 public inviterRewardMinStake;
    address public fundAddress;
    uint256 constant public fundFee = 50;
    uint256 constant public LPFee = 50;
    uint256[10] public inviterFee;
    uint256 constant public firstLockTime = 72 hours;
    uint256 public startBlock;
    uint256 public lastRewardBlock;
    uint256 public accRewardPerShare;
    // uint256 public reawardPerBlock;
    mapping(address => UserInfo) public userInfos;
    mapping(address => uint256) userTotalStake;
    uint256 public currUserTotalStakeCake;
    uint256 public totalCliamCake;
    IYKKPool public ykkPool;
    uint256 public lastBurnTime;
    bool public resendPool;
    uint256 constant minBalanceResendPool = 2139688 * 1e18;
    bool public isSwap;
    uint256 public unBurnAmount;
    uint256 public unLPRewardAmount;


    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 unlockTime; 
        uint256 claimAmount; 
    }
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 reward);

    function __CakeStake_init(address uniV2Router02_, address USDT_, address rewardToken_, address cakePool_, address ykkPool_, uint256 startBlock_,  address fundAddress_) internal initializer {
        __Ownable_init_unchained();
        __Pausable_init_unchained();
        __CakeStake_init_unchained(uniV2Router02_, USDT_, rewardToken_, cakePool_, ykkPool_, startBlock_, fundAddress_);
    }

    function __CakeStake_init_unchained(address uniV2Router02_, address USDT_, address rewardToken_, address cakePool_, address ykkPool_, uint256 startBlock_, address fundAddress_) internal initializer {
        minStake = 10 * 1e18;
        inviterRewardMinStake = 10 * 1e18;
        inviterFee = [30, 20, 10, 10, 5, 5, 5, 5, 5, 5];
        fundAddress = fundAddress_;

        uniV2Router02 = IUniswapV2Router02(uniV2Router02_);
        uniV2Pair = IUniswapV2Pair(IUniswapV2Factory(IUniswapV2Router02(uniV2Router02_).factory()).getPair(USDT_, rewardToken_));

        USDT = USDT_;
        rewardToken = rewardToken_;
        cakePool = ICakePool(cakePool_);
        stakeToken = cakePool.token();
        startBlock = block.number > startBlock_ ? block.number : startBlock_;
        ykkPool = IYKKPool(ykkPool_);
        IERC20Upgradeable(stakeToken).approve(cakePool_, type(uint256).max);
        IERC20Upgradeable(stakeToken).approve(uniV2Router02_, type(uint256).max);
    }

    modifier startMining() {
        require(block.number >= startBlock, "Stake: have not started");
        _;
    }

    function ykkPoolBalance() view public returns(uint256){
        return IERC20(rewardToken).balanceOf(address(ykkPool));
    }

    function balanceCake() view public returns(uint256) {
        return IERC20Upgradeable(stakeToken).balanceOf(address(this));
    }

    function getStakeTargetAmount() public view returns (uint256) {
        return currUserTotalStakeCake;
    }

    function getStakeTargetPending() public view returns (uint256) {
        ICakePool.UserInfo memory _userInfo = cakePool.userInfo(address(this));
        uint256 _cakePoolCake = _userInfo.shares * cakePool.getPricePerFullShare() / 1e18;
        return  _cakePoolCake <= getStakeTargetAmount() ? 0 : _cakePoolCake - getStakeTargetAmount();
    }

    function cakeCalculatePerformanceFee() public view returns (uint256){
        return cakePool.calculatePerformanceFee(address(this));
    }

    // Stake CAKE tokens to MasterChef
    function cakeStaking(uint256 _amount) internal {
        cakePool.deposit(_amount, 0);
    }

    // Withdraw CAKE tokens from STAKING.
    function cakewithdrawByAmount(uint256 _amount) internal {
        cakePool.withdrawByAmount(_amount);
    }

    function claimCake() private {
        uint256 _reward = getStakeTargetPending();
        if(_reward > cakePool.MIN_WITHDRAW_AMOUNT()){
            cakewithdrawByAmount(_reward);
        }
    }

    function update() public whenNotPaused {
        uint256 nowBlock = block.number;
        if (nowBlock <= lastRewardBlock) {
            return;
        }
        uint256 _stakeAmount  = getStakeTargetAmount();
        if (_stakeAmount == 0) {
            lastRewardBlock = nowBlock;
            return;
        }
        uint256 cakeBalanceBefore = balanceCake();
        claimCake();
        uint256 cakeReward = balanceCake() - cakeBalanceBefore;
        totalCliamCake += cakeReward;
        processCakeReward(cakeReward);
        uint256 _reward = currRewardTokenPerRewardCake(nowBlock) * cakeReward * 1e18 / diffDecimals() / 100;
        accRewardPerShare += _reward / _stakeAmount;
        lastRewardBlock = nowBlock;
    }

    // Deposit LP
    function deposit(uint256 _amount) public startMining {
        require(_amount > cakePool.MIN_DEPOSIT_AMOUNT() && _amount > cakePool.MIN_WITHDRAW_AMOUNT(), "Stake: amount is too small");

        address _sender = msg.sender;
        UserInfo storage user = userInfos[_sender];
        update();
        if (user.amount > 0) {
            uint256 pendingReward = user.amount * accRewardPerShare / 1e18 - user.rewardDebt;
            transferReward(_sender, pendingReward, true);
            user.claimAmount += pendingReward;
        }
        user.amount = user.amount + _amount;
        user.rewardDebt = user.amount * accRewardPerShare / 1e18;
        if(userTotalStake[_sender] == 0){
            require(_amount >= minStake, "Stake: first investment amount is too small");
            user.unlockTime = block.timestamp + firstLockTime;
        }
        userTotalStake[_sender] += _amount;
        IERC20Upgradeable(stakeToken).safeTransferFrom(address(_sender), address(this), _amount);
        cakeStaking(_amount);
        currUserTotalStakeCake += _amount;
        emit Deposit(_sender, _amount);
    }

    // View function to see pending rewardToken on frontend.
    function pending(address _user) external view returns (uint256) {
        UserInfo storage user = userInfos[_user];
        uint256 _accRewardPerShare = accRewardPerShare;
        uint256 _stakeAmount  = getStakeTargetAmount();
        if (block.number > lastRewardBlock && _stakeAmount != 0) {
            uint256 _prndingCakeReawad = getStakeTargetPending() - cakeCalculatePerformanceFee();
            uint256 _reward = currRewardTokenPerRewardCake() * _prndingCakeReawad * 1e18 / diffDecimals() / 100;
            _accRewardPerShare += _reward / _stakeAmount;
        }
        return user.amount * _accRewardPerShare / 1e18 - user.rewardDebt;
    }

    // Withdraw LP to
    function withdraw(uint256 _amount) external {
        require(_amount > cakePool.MIN_WITHDRAW_AMOUNT(), "Stake: amount is too small");
        address _sender = msg.sender;
        UserInfo storage user = userInfos[_sender];
        require(user.amount >= _amount, "Stake: not good");
        require(user.unlockTime <= block.timestamp, "Stake: withdraw locked");
        update();
        uint256 pendingReward = user.amount * accRewardPerShare / 1e18 - user.rewardDebt;
        transferReward(_sender, pendingReward, false);
        user.claimAmount += pendingReward;
        user.amount = user.amount - _amount;
        user.rewardDebt = user.amount * accRewardPerShare / 1e18;
        currUserTotalStakeCake -= _amount;
        uint256 beforeCake = balanceCake();
        cakewithdrawByAmount(_amount);
        uint256 receiveCke = balanceCake() - beforeCake;
        IERC20Upgradeable(stakeToken).safeTransfer(address(_sender), receiveCke);
        emit Withdraw(_sender, _amount);
    }

    function emergencyWithdraw() external whenNotPaused {
        UserInfo storage user = userInfos[msg.sender];
        require(user.unlockTime <= block.timestamp, "Stake: withdraw locked");
        uint256 _outAmount = user.amount;
        require(_outAmount > cakePool.MIN_WITHDRAW_AMOUNT(), "Stake: amount is too small");
        user.amount = 0;
        user.rewardDebt = 0;
        currUserTotalStakeCake -= _outAmount;
        uint256 beforeCake = balanceCake();
        cakewithdrawByAmount(_outAmount);
        uint256 receiveCke = balanceCake() - beforeCake;
        IERC20Upgradeable(stakeToken).safeTransfer(address(msg.sender), receiveCke);
        emit EmergencyWithdraw(msg.sender, _outAmount);

    }

    function claim() external {
        address _sender = msg.sender;
        UserInfo storage user = userInfos[_sender];
        require(user.amount > 0, "Stake: no stake");
        update();
        uint256 pendingReward = user.amount * accRewardPerShare / 1e18 - user.rewardDebt;
        transferReward(_sender, pendingReward, true);
        user.claimAmount += pendingReward;
        user.rewardDebt = user.amount * accRewardPerShare / 1e18;
        emit Claim(_sender, pendingReward);
    }

    function adminTransferOutERC20(address contract_, address recipient_) external onlyOwner {
        require(contract_ != rewardToken, "Stake: It can't be reward token");
        IERC20Upgradeable erc20Contract = IERC20Upgradeable(contract_);
        uint256 _value = erc20Contract.balanceOf(address(this));
        require(_value > 0, "Stake: no money");
        erc20Contract.safeTransfer(recipient_, _value);
    }

    function updateMinStake(uint256 minStake_) external onlyOwner {
        minStake = minStake_;
    }

    function updateInviterRewardMinStake(uint256 inviterRewardMinStake_) external onlyOwner {
        inviterRewardMinStake = inviterRewardMinStake_;
    }

    function updateFundAddress(address fundAddress_) external onlyOwner {
        require(fundAddress_ != address(0), "Stake: fundAddress error");
        fundAddress = fundAddress_;
    }

    function updateIsSwap(bool isSwap_) external onlyOwner {
        require(isSwap != isSwap_, "Stake: isSwap error");
        isSwap = isSwap_;
    }

    function pause() external whenNotPaused onlyOwner {
        _pause();
    }

    function unpause() external whenPaused onlyOwner {
        _unpause();
    }


    function transferReward(address _to, uint256 _amount, bool _must) internal {
        if(_amount <= 0){
            return;
        }
        IYKKToken _ykk = IYKKToken(rewardToken);
        // IERC20Upgradeable tokenIns = IERC20Upgradeable(rewardToken);
        uint256 poolBal = ykkPoolBalance();
        require(!_must || poolBal >= _amount, "Stake: insufficient fund");
        uint256 outAmount = _amount <= poolBal ? _amount : poolBal;
        uint256 afterOutAmount = outAmount;
        uint256 _burnAmount;
        address _parent = _to;
        for(uint256 i=0; i<inviterFee.length; i++){
            uint256 _inviterFeeAmount = outAmount * inviterFee[i] / 1000;
            afterOutAmount-=_inviterFeeAmount;
            if(_parent != address(0)){
                _parent = _ykk.inviter(_parent);
            }
            if(_parent == address(0) || userInfos[_parent].amount < inviterRewardMinStake){
                _burnAmount+=_inviterFeeAmount;
                continue;
            }
            ykkPool.transferToken(rewardToken, _parent, _inviterFeeAmount);
        }
        if(_burnAmount > 0){
            ykkPool.transferToken(rewardToken, address(this), _burnAmount);
            _ykk.burn(_burnAmount);
        }
        ykkPool.transferToken(rewardToken, _to, afterOutAmount);
    }


    function updateResendPool() private {
        if(resendPool){
            return;
        }
        if(ykkPoolBalance() <= minBalanceResendPool){
            resendPool = true;
        }
    }


    function processCakeReward(uint256 currRewardCakeAmount_) private {
        updateResendPool();

        if(currRewardCakeAmount_ == 0){
            return;
        }

        IERC20Upgradeable cakeIns = IERC20Upgradeable(stakeToken);
        IYKKToken ykkIns = IYKKToken(rewardToken);
        uint256 _fundAmount = currRewardCakeAmount_ * fundFee / 1000;
        uint256 _LPAmount = currRewardCakeAmount_ * LPFee / 1000;
        uint256 _burnAmount = currRewardCakeAmount_ - _fundAmount - _LPAmount;
        cakeIns.safeTransfer(fundAddress, _fundAmount);
        unLPRewardAmount += _LPAmount;
        unBurnAmount += _burnAmount;
        if(uniV2Pair.totalSupply() > 0){
            if(unLPRewardAmount > 0){
                uint256 _beforeYkk = ykkIns.balanceOf(address(this));
                swapTokensCakeToYKK(unLPRewardAmount);
                uint256 _LPRewardAmount = ykkIns.balanceOf(address(this)) - _beforeYkk;
                ykkIns.transfer(address(uniV2Pair), _LPRewardAmount);
                uniV2Pair.sync();
                unLPRewardAmount = 0;
            }
            

            
            if(block.timestamp > lastBurnTime + 1 hours){
                if(unBurnAmount > 0){
                    uint256 _beforeYkk = ykkIns.balanceOf(address(this));
                    swapTokensCakeToYKK(unBurnAmount);
                    uint256 _burnYkkAmount = ykkIns.balanceOf(address(this)) - _beforeYkk;
                    if(resendPool){
                        ykkIns.transfer(address(ykkPool), _burnYkkAmount);
                    }else {
                        ykkIns.burn(_burnYkkAmount);
                    }
                    unBurnAmount = 0;
                    lastBurnTime = block.timestamp;
                }
                
            }            

        }
        
    }

    function swapTokensCakeToYKK(uint256 cakeAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](3);
        path[0] = stakeToken;
        path[1] = USDT;
        path[2] = rewardToken;

        // make the swap
        uniV2Router02.swapExactTokensForTokens(
            cakeAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }


    function diffDecimals() virtual pure public returns(uint256) {
        return 1;
    }

    function currRewardTokenPerRewardCake() view public returns(uint256) {
        return currRewardTokenPerRewardCake(block.number);
    }

    function currRewardTokenPerRewardCake(uint256 blockNumber_) virtual view public returns(uint256) {
        return 0;
    }


     /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}