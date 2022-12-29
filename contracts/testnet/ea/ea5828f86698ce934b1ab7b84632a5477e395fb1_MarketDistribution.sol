// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.4;

import "./IMarketDistribution.sol";
import "./IMarketGeneration.sol";
import "./RootedToken.sol";
import "./RootedTransferGate.sol";
import "./TokensRecoverable.sol";
import "./SafeMath.sol";
import "./IERC31337.sol";
import "./IERC20.sol";
import "./ISwapRouter02.sol";
import "./ISwapFactory.sol";
import "./ISwapPair.sol";
import "./SafeERC20.sol";

contract MarketDistribution is TokensRecoverable, IMarketDistribution {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool public override distributionComplete;

    ISwapRouter02 swapRouter;
    ISwapFactory swapFactory;

    IMarketGeneration public marketGeneration;
    RootedToken public rootedToken;
    IERC31337 public eliteToken;
    IERC20 public baseToken;

    address public devAddress;

    address public userClaimContract;
    address public liquidityController;
    address public teamSplitterAddress;
    
    ISwapPair public rootedEliteLP;
    ISwapPair public rootedBaseLP;

    uint256 public constant rootedTokenSupply = 1e24; // 1 million

    uint256 public totalBaseTokenCollected;
    uint256 public totalBoughtForContributors;

    mapping (address => uint256) public claimTime;
    mapping (address => uint256) public totalClaim;
    mapping (address => uint256) public remainingClaim;
    
    uint256 public totalBoughtForReferrals;
    uint256 public recoveryDate = block.timestamp + 2592000; // 1 Month

    uint16 public preBuyForReferralsPercent;
    uint16 public preBuyForContributorsPercent;
    uint16 public preBuyForMarketStabilizationPercent;

    uint256 public override vestingPeriodStartTime;
    uint256 public override vestingPeriodEndTime; 
    
    uint256 public vestingDuration;
    uint256 public rootedBottom;

    constructor(address _devAddress, address _userClaimContract) {
        devAddress = _devAddress;
        userClaimContract = _userClaimContract;
    }

    function init(
        RootedToken _rootedToken, 
        IERC31337 _eliteToken, 
        address _liquidityController,
        ISwapRouter02 _swapRouter, 
        IMarketGeneration _marketGeneration,
        uint256 _vestingDuration, 
        uint16 _preBuyForReferralsPercent, 
        uint16 _preBuyForContributorsPercent, 
        uint16 _preBuyForMarketStabilizationPercent) public ownerOnly() {        
        rootedToken = _rootedToken;
        eliteToken = _eliteToken;
        baseToken = _eliteToken.wrappedToken();
        liquidityController = _liquidityController;
        swapRouter = _swapRouter;
        swapFactory = ISwapFactory(_swapRouter.factory());
        marketGeneration = _marketGeneration;
        vestingDuration = _vestingDuration;
        preBuyForReferralsPercent = _preBuyForReferralsPercent;
        preBuyForContributorsPercent = _preBuyForContributorsPercent;
        preBuyForMarketStabilizationPercent = _preBuyForMarketStabilizationPercent;
    }

    function setupEliteRooted() public {
        rootedEliteLP = ISwapPair(swapFactory.getPair(address(eliteToken), address(rootedToken)));
        if (address(rootedEliteLP) == address(0)) 
        {
            rootedEliteLP = ISwapPair(swapFactory.createPair(address(eliteToken), address(rootedToken)));
            require (address(rootedEliteLP) != address(0));
        }
    }

    function setupBaseRooted() public {
        rootedBaseLP = ISwapPair(swapFactory.getPair(address(baseToken), address(rootedToken)));
        if (address(rootedBaseLP) == address(0)) {
            rootedBaseLP = ISwapPair(swapFactory.createPair(address(baseToken), address(rootedToken)));
            require (address(rootedBaseLP) != address(0));
        }
    }

    function completeSetup() public ownerOnly() {   
        require (address(rootedEliteLP) != address(0), "Rooted Elite pool is not created");
        require (address(rootedBaseLP) != address(0), "Rooted Base pool is not created");   

        eliteToken.approve(address(swapRouter), uint256(-1));
        rootedToken.approve(address(swapRouter), uint256(-1));
        baseToken.safeApprove(address(swapRouter), uint256(-1));
        baseToken.safeApprove(address(eliteToken), uint256(-1));
        rootedBaseLP.approve(address(swapRouter), uint256(-1));
        rootedEliteLP.approve(address(swapRouter), uint256(-1));
    }

    function distribute() public override {
        require (msg.sender == address(marketGeneration), "Unauthorized");
        require (!distributionComplete, "Distribution complete");
   
        vestingPeriodStartTime = block.timestamp;
        vestingPeriodEndTime = block.timestamp + vestingDuration;
        distributionComplete = true;

        totalBaseTokenCollected = baseToken.balanceOf(address(marketGeneration));
        baseToken.safeTransferFrom(msg.sender, address(this), totalBaseTokenCollected);  

        RootedTransferGate gate = RootedTransferGate(address(rootedToken.transferGate()));

        gate.setUnrestricted(true);
        rootedToken.mint(rootedTokenSupply);

        rootedToken.transfer(userClaimContract, 537000000000000000000000);

        createRootedEliteLiquidity();

        eliteToken.sweepFloor(address(this));        
        eliteToken.depositTokens(baseToken.balanceOf(address(this)));
                
        buyTheBottom();
        preBuyForReferrals();
        preBuyForContributors();
        sellTheTop();

        uint256 devShare = totalBaseTokenCollected * 600 / 10000;
        baseToken.transfer(devAddress, devShare);

        baseToken.transfer(liquidityController, baseToken.balanceOf(address(this)));      

        createRootedBaseLiquidity();       

        gate.setUnrestricted(false);
    }   
    
    function createRootedEliteLiquidity() private {
        eliteToken.depositTokens(baseToken.balanceOf(address(this)));
        swapRouter.addLiquidity(address(eliteToken), address(rootedToken), eliteToken.balanceOf(address(this)), rootedToken.totalSupply(), 0, 0, address(this), block.timestamp);
    }

    function buyTheBottom() private {
        uint256 amount = totalBaseTokenCollected * preBuyForMarketStabilizationPercent / 10000;  
        uint256[] memory amounts = swapRouter.swapExactTokensForTokens(amount, 0, eliteRootedPath(), address(this), block.timestamp);        
        rootedBottom = amounts[1];
    }

    function sellTheTop() private {
        uint256[] memory amounts = swapRouter.swapExactTokensForTokens(rootedBottom, 0, rootedElitePath(), address(this), block.timestamp);
        uint256 eliteAmount = amounts[1];
        eliteToken.withdrawTokens(eliteAmount);
    }   
    
    function preBuyForReferrals() private {
        uint256 amount = totalBaseTokenCollected * preBuyForReferralsPercent / 10000;
        uint256[] memory amounts = swapRouter.swapExactTokensForTokens(amount, 0, eliteRootedPath(), address(this), block.timestamp);
        totalBoughtForReferrals = amounts[1];
    }

    function preBuyForContributors() private {
        uint256 preBuyAmount = totalBaseTokenCollected * preBuyForContributorsPercent / 10000;
        uint256 eliteBalance = eliteToken.balanceOf(address(this));
        uint256 amount = preBuyAmount > eliteBalance ? eliteBalance : preBuyAmount;
        uint256[] memory amounts = swapRouter.swapExactTokensForTokens(amount, 0, eliteRootedPath(), address(this), block.timestamp);
        totalBoughtForContributors = amounts[1];
    }

    function createRootedBaseLiquidity() private {
        uint256 elitePerLpToken = eliteToken.balanceOf(address(rootedEliteLP)).mul(1e18).div(rootedEliteLP.totalSupply());
        uint256 lpAmountToRemove = baseToken.balanceOf(address(eliteToken)).mul(1e18).div(elitePerLpToken);
        
        (uint256 eliteAmount, uint256 rootedAmount) = swapRouter.removeLiquidity(address(eliteToken), address(rootedToken), lpAmountToRemove, 0, 0, address(this), block.timestamp);
        
        uint256 baseInElite = baseToken.balanceOf(address(eliteToken));
        uint256 baseAmount = eliteAmount > baseInElite ? baseInElite : eliteAmount;       
        
        eliteToken.withdrawTokens(baseAmount);
        swapRouter.addLiquidity(address(baseToken), address(rootedToken), baseAmount, rootedAmount, 0, 0, liquidityController, block.timestamp);
        rootedEliteLP.transfer(liquidityController, rootedEliteLP.balanceOf(address(this)));
        eliteToken.transfer(liquidityController, eliteToken.balanceOf(address(this)));
    }

    function eliteRootedPath() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = address(eliteToken);
        path[1] = address(rootedToken);
        return path;
    }

    function rootedElitePath() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = address(rootedToken);
        path[1] = address(eliteToken);
        return path;
    }
    
    function getTotalClaim(address account) public view returns (uint256) {
        uint256 contribution = marketGeneration.contribution(account);
        return contribution == 0 ? 0 : contribution.mul(totalBoughtForContributors).div(marketGeneration.totalContribution());
    }

    function getReferralClaim(address account) public view returns (uint256) {
        uint256 referralShare = marketGeneration.referralPoints(account);
        return referralShare == 0 ? 0 : referralShare.mul(totalBoughtForReferrals).div(marketGeneration.totalReferralPoints());
    }

    function claim(address account) public override returns (uint256) {
        require (distributionComplete, "Distribution is not completed");
        require (msg.sender == address(marketGeneration), "Unauthorized");

        if (totalClaim[account] == 0) {
            totalClaim[account] = remainingClaim[account] = getTotalClaim(account);
        }

        uint256 share = totalClaim[account];
        uint256 endTime = vestingPeriodEndTime > block.timestamp ? block.timestamp : vestingPeriodEndTime;

        require (claimTime[account] < endTime, "Already claimed");

        uint256 claimStartTime = claimTime[account] == 0 ? vestingPeriodStartTime : claimTime[account];
        share = (endTime.sub(claimStartTime)).mul(share).div(vestingDuration);
        claimTime[account] = block.timestamp;
        remainingClaim[account] -= share;
        rootedToken.transfer(account, share);

        return share;
    }

    function claimReferralRewards(address account, uint256 referralShare) public override {
        require (distributionComplete, "Distribution is not completed");
        require (msg.sender == address(marketGeneration), "Unauthorized");

        uint256 share = referralShare.mul(totalBoughtForReferrals).div(marketGeneration.totalReferralPoints());
        rootedToken.transfer(account, share);
    }

    function canRecoverTokens(IERC20 token) internal override view returns (bool) { 
        return block.timestamp > recoveryDate || token != rootedToken;
    }
}