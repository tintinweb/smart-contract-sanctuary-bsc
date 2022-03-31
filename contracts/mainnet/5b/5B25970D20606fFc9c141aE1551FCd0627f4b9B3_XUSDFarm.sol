//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./SafeMath.sol";
import "./IERC20.sol";
import "./IUniswapV2Router02.sol";
import "./Ownable.sol";

interface IFarmManager {
    function distribute() external;
}

interface IXUSD {
    function sell(uint256 tokenAmount) external returns (address,uint);
    function mintWithNative(address recipient, uint256 minOut) external payable;
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

/**
 *
 * xUSD-BNB Farm Contract
 * Developed by DeFi Mark
 *
 */
contract XUSDFarm is ReentrancyGuard, IERC20, Ownable {

    using SafeMath for uint256;
    
    // xUSD
    address constant xUSD = 0x324E8E649A6A3dF817F97CdDBED2b746b62553dD;
    
    // Farm
    IFarmManager public FarmManager;
    
    // precision factor
    uint256 constant precision = 10**18;
    
    // Total Dividends Per Farm
    uint256 dividendsPerToken;
    
    // Total Rewards Given
    uint256 _totalRewards;
    
    // Liquidity Pool Address for xUSD + BNB
    address immutable public pair;
    
    // Router
    IUniswapV2Router02 constant router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    // Contract To Buy And Burn XUSD With LP Tokens Received
    address public liquidityBuyAndBurner = 0x19a9621c051AE81131E60B9AD704723355e48573;
    
    // if withdrawal occurs before lock period
    uint256 public earlyFee = 95;
    
    // 3 days
    uint256 public lockTime = 86400;
    
    // Locker Structure 
    struct Locker {
        uint256 tokensLocked;
        uint256 timeLocked;
        uint256 lastClaim;
        uint256 totalExcluded;
        address DEX;
        address rewardToken;
    }
    
    // Users -> Lockers
    mapping ( address => Locker ) public lockers;
    
    // total reward claims
    mapping ( address => uint256 ) totalClaims;
    
    // total locked across all lockers
    uint256 totalLocked;
    
    constructor(address farmManager) {
        FarmManager = IFarmManager(farmManager);
        pair = IUniswapV2Factory(router.factory()).getPair(xUSD, router.WETH());        
    }
    
    function rewardTokenForHolder(address holder) external view returns (address) {
        return lockers[holder].rewardToken == address(0) ? router.WETH() : lockers[holder].rewardToken;
    }
    function totalSupply() external view override returns (uint256) { return totalLocked; }
    function balanceOf(address account) public view override returns (uint256) { return lockers[account].tokensLocked; }
    function allowance(address holder, address spender) external view override returns (uint256) { return holder == spender ? balanceOf(holder) : 0; }
    function name() public pure override returns (string memory) {
        return "FARM: BNB-XUSD";
    }
    function symbol() public pure override returns (string memory) {
        return "BNB-xUSD";
    }
    function decimals() public pure override returns (uint8) {
        return 18;
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        // ensure claim requirements
        if (recipient == address(this)) {
            _reinvestEarnings(msg.sender);
        } else {
            _makeClaim(msg.sender);
        }
        amount;
        emit Transfer(msg.sender, recipient, 0);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (recipient == address(this)) {
            _reinvestEarnings(msg.sender);
        } else {
            _makeClaim(msg.sender);
        }
        amount;
        emit Transfer(sender, recipient, 0);
        return true;
    }
    
    
    ///////////////////////////////////
    //////    OWNER FUNCTIONS   ///////
    ///////////////////////////////////
    

    function setFarmManager(address newManager) external onlyOwner {
        FarmManager = IFarmManager(newManager);
    }
    
    function setLockTime(uint256 newTime) external onlyOwner {
        lockTime = newTime;
    }

    function setEarlyFee(uint newFee) external onlyOwner {
        require(newFee >= 90);
        earlyFee = newFee;
    }
    
    function setLiquidityBuyAndBurner(address newBurner) external onlyOwner {
        liquidityBuyAndBurner = newBurner;
    }

    function withdraw(uint amount) external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: amount}("");
        require(s, 'Failure BNB Withdrawal');
    }
    
    function withdraw(address token) external onlyOwner {
        require(token != pair, 'Cannot Withdraw LP Tokens');
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }
    
    ///////////////////////////////////
    //////   PUBLIC FUNCTIONS   ///////
    ///////////////////////////////////
    
    function claimReward() external {
        _makeClaim(msg.sender);      
    }
    
    function unlock(uint256 amount) external nonReentrant {
        _unlock(msg.sender, msg.sender, amount, false, false);
    }
    
    function unlockAll() external nonReentrant {
        _unlock(msg.sender, msg.sender, lockers[msg.sender].tokensLocked, false, false);
    }
    
    function emergencyWithdraw() external nonReentrant {
        _unlock(msg.sender, msg.sender, lockers[msg.sender].tokensLocked, false, true);
    }
    
    function unstake(uint256 amount) external nonReentrant {
        _unlock(msg.sender, msg.sender, amount, true, false);
    }
    
    function unstakeAll() external nonReentrant {
        _unlock(msg.sender, msg.sender, lockers[msg.sender].tokensLocked, true, false);
    }
    
    function unstakeFor(uint256 amount, address recipient) external nonReentrant {
        _unlock(msg.sender, recipient, amount, true, false);
    }
    
    function deposit(uint256 amount) external nonReentrant {
        
        uint256 balBefore = IERC20(pair).balanceOf(address(this));
        
        bool s = IERC20(pair).transferFrom(msg.sender, address(this), amount);
        require(s, 'Failure on TransferFrom');
        
        uint256 received = IERC20(pair).balanceOf(address(this)).sub(balBefore);
        require(received <= amount && received > 0, 'Failure On Transfer');
        
        _lock(msg.sender, received);
    }
    
    function reinvestEarnings() external {
        require(lockers[msg.sender].tokensLocked > 0, 'Zero Tokens Locked');
        _reinvestEarnings(msg.sender);
    }

    function setRewardToken(address token, address _DEX) external {
        lockers[msg.sender].rewardToken = token;
        lockers[msg.sender].DEX = _DEX;
    }
    
    ///////////////////////////////////
    //////  INTERNAL FUNCTIONS  ///////
    ///////////////////////////////////
    
    function _makeClaim(address user) internal nonReentrant {
        // ensure claim requirements
        require(lockers[user].tokensLocked > 0, 'Zero Tokens Locked');
        require(lockers[user].lastClaim < block.number, 'Same Block Entry');
        
        uint256 amount = pendingRewards(user);
        require(amount > 0,'Zero Rewards');
        _claimReward(user);
    }
    
    function _claimReward(address user) internal {
        
        // claim dividends
        FarmManager.distribute();
        
        if (lockers[user].tokensLocked == 0) return;
        
        uint256 amount = pendingRewards(user);
        if (amount > 0) {
            // update claim stats 
            lockers[user].lastClaim = block.number;
            totalClaims[user] += amount;
            lockers[user].totalExcluded = currentDividends(lockers[user].tokensLocked);
            // send reward
            _sendReward(user, amount);
        }
        
    }

    function _sendReward(address user, uint amount) internal {

        if (lockers[user].rewardToken == xUSD) {
            IXUSD(xUSD).mintWithNative{value: amount}(user, 0);
            return;
        }

        if (lockers[user].rewardToken == address(0) || lockers[user].DEX == address(0)) {
            (bool s,) = payable(user).call{value: amount}("");
            require(s);
        } else {
            IUniswapV2Router02 _router = IUniswapV2Router02(lockers[user].DEX);

            address[] memory path = new address[](2);
            path[0] = _router.WETH();
            path[1] = lockers[user].rewardToken;

            _router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
                0,
                path,
                user,
                block.timestamp + 300
            );
        }

    }
    
    
    function _transferIn(address token, uint256 amount) internal returns (uint256) {
        uint256 before = IERC20(token).balanceOf(address(this));
        
        bool s = IERC20(token).transferFrom(msg.sender, address(this), amount);
        
        uint256 difference = IERC20(token).balanceOf(address(this)).sub(before);
        require(s && difference <= amount && difference > 0, 'Err Transfer In');
        return difference;
    }
    
    function _pairAndLock(address forUser, uint256 xUSDAmount, uint256 bnbAmount) internal {
        
        // balance of LP Tokens Before
        uint256 lpBalanceBefore = IERC20(pair).balanceOf(address(this));
        
        // approve router to move tokens
        IERC20(xUSD).approve(address(router), xUSDAmount);
        
        // check slippage
        (uint256 minAmountXUSD, uint256 minBNB) = (xUSDAmount.mul(75).div(100), bnbAmount.mul(75).div(100));
        
        // Calculated Expected Amounts After LP Pairing
        uint256 expectedXUSD = IERC20(xUSD).balanceOf(address(this)).sub(xUSDAmount, 'ERR XUSD Amount');
        uint256 expectedBNB = address(this).balance.sub(bnbAmount, 'ERR BNB Amount');
        
        // add liquidity
        router.addLiquidityETH{value: bnbAmount}(
            xUSD,
            xUSDAmount,
            minAmountXUSD,
            minBNB,
            address(this),
            block.timestamp.add(30)
        );
        
        // Track Balances After Liquidity Pairing 
        uint256 xusdAfter = IERC20(xUSD).balanceOf(address(this));
        uint256 bnbAfter = address(this).balance;

        // Note LP Tokens Received
        uint256 lpReceived = IERC20(pair).balanceOf(address(this)).sub(lpBalanceBefore);
        require(lpReceived > 0, 'Zero LP Received');
        
        // Lock LP Tokens Received
        _lock(forUser, lpReceived);
        
        if (xusdAfter > expectedXUSD) {
            uint256 diff = xusdAfter.sub(expectedXUSD);
            IERC20(xUSD).transfer(forUser, diff);
        }
        
        if (bnbAfter > expectedBNB) {
            uint256 diff = bnbAfter.sub(expectedBNB);
            (bool s,) = payable(forUser).call{value: diff}("");
            require(s, 'ERR BNB Transfer');
        }
    }
    
    function _buyAndFarm(uint value) internal {
        
        // balance of xUSD before purchase
        uint256 before = IERC20(xUSD).balanceOf(address(this));
        
        // divvy up BNB
        uint256 xUSDValue = value.mul(5075).div(10000);
        uint256 stakeValue = value.sub(xUSDValue);
        
        // purchase xUSD with half the BNB
        (bool s,) = payable(xUSD).call{value: xUSDValue}("");
        require(s, 'Failure on xUSD Purchase');
        
        // xUSD Received from purchase
        uint256 received = IERC20(xUSD).balanceOf(address(this)).sub(before);
        require(received > 0, 'Too Few Surge Received');

        // burn portion of XUSD Received
        uint burnAmount = (received * 75 ) / 10**4;
        IERC20(xUSD).transfer(xUSD, burnAmount);
        
        // Pair + Lock Liquidity For Token Pair
        uint256 pairAmount = received.sub(burnAmount);
        _pairAndLock(msg.sender, pairAmount, stakeValue);
    }
    
    function stakeInXUSD(uint256 amountXUSD) external payable {
        
        // xUSD received from purchase
        uint256 received = _transferIn(xUSD, amountXUSD);
        require(received > 0, 'Too Few Surge Received');
        
        // Pair + Lock Liquidity For Token Pair
        _pairAndLock(msg.sender, received, msg.value);
    }

    
    function _lock(address user, uint256 lpReceived) private {
        
        if (lockers[user].tokensLocked > 0) {
            _claimReward(user);
        }
        
        // add locker data
        lockers[user].tokensLocked += lpReceived;
        lockers[user].timeLocked = block.number;
        lockers[user].totalExcluded = currentDividends(lockers[user].tokensLocked);
        
        // increment total locked
        totalLocked += lpReceived;
        
        emit Locked(user, lpReceived, block.number + lockTime);
        emit Transfer(address(0), user, lpReceived);
    }

    function _unlock(address user, address lpRecipient, uint256 nTokens, bool removeLiquidity, bool emergency) internal {
        
        // Ensure Lock Requirements
        require(lockers[user].tokensLocked > 0, 'Zero Tokens Locked');
        require(lockers[user].tokensLocked >= nTokens, 'Insufficient Tokens');
        
        bool takeLeaveEarlyFee = (lockers[user].timeLocked + lockTime) > block.number;
        
        if (lockers[user].tokensLocked > 0 && !emergency) {
            _claimReward(user);
        }
        
        // update storage
        if (lockers[user].tokensLocked == nTokens) {
            delete lockers[user]; // Free Storage
        } else {
            lockers[user].tokensLocked = lockers[user].tokensLocked.sub(nTokens); // decrement amount locked
            lockers[user].totalExcluded = currentDividends(lockers[user].tokensLocked);
        }
        
        // Update Total Locked
        totalLocked = totalLocked.sub(nTokens);
        
        uint256 sendTokens = takeLeaveEarlyFee ? nTokens.mul(earlyFee).div(100) : nTokens;
        require(sendTokens > 0, 'Zero Send Amount');
        
        if (removeLiquidity) {
            // Remove LP Send To User
            _removeLiquidity(sendTokens, lpRecipient);
        } else {
            // Transfer LP Tokens To User
            bool s = IERC20(pair).transfer(lpRecipient, sendTokens);
            require(s, 'Failure on LP Token Transfer');
        }
        
        if (takeLeaveEarlyFee) {
            uint256 dif = nTokens.sub(sendTokens);
            if (dif > 0) {
                IERC20(pair).transfer(liquidityBuyAndBurner, dif);
            }
        }

        // tell Blockchain
        emit Unlocked(user, nTokens);
        emit Transfer(user, address(0), nTokens);
    }
    
    function _removeLiquidity(uint256 nLiquidity, address recipient) private {
        
        IERC20(pair).approve(address(router), 2*nLiquidity);
        
        router.removeLiquidityETHSupportingFeeOnTransferTokens(
            xUSD,
            nLiquidity,
            0,
            0,
            recipient,
            block.timestamp.add(30)
        );
        
    }
    
    /** Reinvests XUSD Rewards Back Into The Farm */
    function _reinvestEarnings(address user) internal nonReentrant {
        
        // claim dividends
        FarmManager.distribute();

        uint256 amount = pendingRewards(user);
        require(amount > 0, 'Zero Rewards Pending');
            
        // optimistically set storage
        lockers[user].lastClaim = block.number;
        totalClaims[user] += amount;
        lockers[user].totalExcluded = currentDividends(lockers[user].tokensLocked);
            
        // split Amount in half
        uint256 half = amount / 2;
        uint256 pairHalf = amount.sub(half);

        uint before = IERC20(xUSD).balanceOf(address(this));
        // mint XUSD
        IXUSD(xUSD).mintWithNative{value: half}(address(this), 0);
        uint received = IERC20(xUSD).balanceOf(address(this)) - before;
                
        // Pair BNB Received with other half of XUSD
        _pairAndLock(user, received, pairHalf);
    }
    
    ///////////////////////////////////
    //////    READ FUNCTIONS    ///////
    ///////////////////////////////////
    
    function getTotalQuantitiesInLP() public view returns (uint256, uint256) {
        return (IERC20(xUSD).balanceOf(pair), IERC20(router.WETH()).balanceOf(pair));
    }
    
    function getRedeemableValue(address user) external view returns (uint256, uint256) {
        (uint256 usd, uint256 bnb) = getTotalQuantitiesInLP();
        uint256 share = getLPShareForHolder(user);
        
        return (share.mul(usd).div(precision),share.mul(bnb).div(precision));
    }
    
    function getLPShareForHolder(address user) public view returns (uint256) {
        return lockers[user].tokensLocked.mul(precision).div(IERC20(pair).totalSupply());
    }
    
    function getTimeUntilUnlock(address user) external view returns (uint256) {
        uint256 endTime = lockers[user].timeLocked + lockTime;
        return endTime > block.number ? endTime.sub(block.number) : 0;
    }
    
    function currentDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerToken).div(precision);
    }
    
    function pendingRewards(address user) public view returns (uint256) {
        uint256 amount = lockers[user].tokensLocked;
        if(amount == 0){ return 0; }

        uint256 shareholderTotalDividends = currentDividends(amount);
        uint256 shareholderTotalExcluded = lockers[user].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }
    
    function totalRewardsClaimedForUser(address user) external view returns (uint256) {
        return totalClaims[user];
    }
    
    function totalRewards() external view returns (uint256) {
        return _totalRewards;
    }
    
    function calculateUserLPBalance(address user) external view returns (uint256) {
        return IERC20(pair).balanceOf(user);
    }

    function farmWithBNB() external payable {
        require(msg.value > 0);
        _buyAndFarm(msg.value);
    }

    receive() external payable {
        require(msg.value > 0);
        dividendsPerToken += msg.value.mul(precision).div(totalLocked);
        _totalRewards += msg.value;
    }
    
    event Locked(address staker, uint256 numTokens, uint256 blockUnlocked);
    event Unlocked(address staker, uint256 tokensRedeemed);
    event RewardClaimed(address user, uint256 amountClaimed);

}