// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;


import './IUniswapV2Router02.sol';
import './IUniswapV2Factory.sol';
import './IERC20.sol';
import './IPancakePair.sol';
import './IMasterChef.sol';
import './SafeMath.sol';

contract ssCompounder{
    using SafeMath for uint256;
    
    string  public name       = "SS-Compounder V1";
    uint256 public dev_fee    = 6;
    uint256 public lpPid      = 110; //108;
    bool    public swapinProgress = false;
    address payable dev_marketing;
    uint256 fees_collected = 0;
    uint256 AutoCompoundTimer = 0;
    //rewards are in cake
    address cakeTokenAddress = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
    IERC20 cakeTokenInstance;
    //ERC20 -> LP staking
    struct Staking{
        address tokenAddress;
        string tokenName;
        //IERC20 tokenInstance;
    }

    Staking[2] public stakeInfo;
    //
    address public pancakeRouterAddress;
    IUniswapV2Router02 public pancakeRouter;
    //
    address public pancakeMasterChefAddress;
    IMasterChef public pancakeMasterChef;
    //
    address public pancakePairAddress;
    IPancakePair public pancakePair;
    //
    IERC20 public tokenInstance0;
    IERC20 public tokenInstance1;
    //
    //events
    event Bought_Lps(address, uint256);
    event Staked_Lp(address, uint256, uint256, uint256);
    event Farming_Lp(address, uint256);
    //event compoundReceived(address, uint256);
    mapping(address => uint256) public lpPurchased; 
    uint256 totalLp = 0;
    //
    constructor(){
        AutoCompoundTimer = block.timestamp;
        //switch tokens to high apy pancake tokens
        dev_marketing = payable(msg.sender);
        //
        cakeTokenInstance = IERC20(cakeTokenAddress);
        //
        stakeInfo[0].tokenAddress  = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        stakeInfo[0].tokenName     = "BUSD";
        tokenInstance0             = IERC20(stakeInfo[0].tokenAddress);
        //EX for second token
        stakeInfo[1].tokenAddress  = 0x208cfEc94d2BA8B8537da7A9BB361c6baAD77272; //0xa865197A84E780957422237B5D152772654341F3;
        stakeInfo[1].tokenName     = "SHELL"; //"OLE";
        tokenInstance1             = IERC20(stakeInfo[1].tokenAddress);
        //router
        pancakeRouterAddress       = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        pancakeRouter              = IUniswapV2Router02(pancakeRouterAddress);
        //MasterChef
        pancakeMasterChefAddress   = 0xa5f8C5Dbd5F286960b9d90548680aE5ebFf07652;
        pancakeMasterChef          = IMasterChef(pancakeMasterChefAddress);
        //pair address 
        pancakePairAddress         = 0x02D75D7beebF6D5228A3Fa5f810CedF2BEa5aB1E;
        pancakePair                = IPancakePair(pancakePairAddress); 
    }

    modifier devOnly(){
        require(msg.sender == dev_marketing, "only dev-admin can execute");
        _;
    }

    function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,dev_fee),100);
    }

    function BuyLpTokensToUser() public payable{
        require(swapinProgress == false, "StakeThenFarm: In progress");
        require(msg.value >= 0.001 ether, "Minimum is 0.001 bnb");
        swapinProgress = true;
        uint fee = devFee(msg.value);
        uint deadline = block.timestamp + 10 minutes;
        uint256 amountToSwap = SafeMath.sub(msg.value,fee);
        uint256 amountInSwap = SafeMath.div(amountToSwap,2); 
        //token route
        address[] memory path;
        path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = stakeInfo[0].tokenAddress;
        uint256 [] memory amountOutMin = pancakeRouter.getAmountsOut(amountInSwap,path);
        uint256 [] memory amountOut = pancakeRouter.swapExactETHForTokens{value: amountInSwap}(amountOutMin[1], path, msg.sender, deadline);
        //second lp
        path[1] = stakeInfo[1].tokenAddress;
        amountOutMin = pancakeRouter.getAmountsOut(amountInSwap,path);
        amountOut = pancakeRouter.swapExactETHForTokens{value: amountInSwap}(amountOutMin[1], path, msg.sender, deadline);
        swapinProgress = false;
        (bool success,) = dev_marketing.call{value : fee}("");
        require(success, "failed to send bnb");
        fees_collected += fee;
        emit Bought_Lps(msg.sender, msg.value);
    }

    function BuyLpTokens() public payable{
        require(swapinProgress == false, "StakeThenFarm: In progress");
        require(msg.value >= 0.001 ether, "Minimum is 0.001 bnb");
        swapinProgress = true;
        uint fee = devFee(msg.value);
        uint deadline = block.timestamp + 10 minutes;
        uint256 amountToSwap = SafeMath.sub(msg.value,fee);
        uint256 amountInSwap = SafeMath.div(amountToSwap,2); 
        //token route
        address[] memory path;
        path = new address[](2);
        path[0] = pancakeRouter.WETH();
        path[1] = stakeInfo[0].tokenAddress;
        uint256 [] memory amountOutMin = pancakeRouter.getAmountsOut(amountInSwap,path);
        uint256 [] memory amountOut = pancakeRouter.swapExactETHForTokens{value: amountInSwap}(amountOutMin[1], path, address(this), deadline);
        //second lp
        path[1] = stakeInfo[1].tokenAddress;
        amountOutMin = pancakeRouter.getAmountsOut(amountInSwap,path);
        amountOut = pancakeRouter.swapExactETHForTokens{value: amountInSwap}(amountOutMin[1], path, address(this), deadline);
        swapinProgress = false;
        (bool success,) = dev_marketing.call{value : fee}("");
        require(success, "failed to send bnb");
        fees_collected += fee;
        emit Bought_Lps(msg.sender, msg.value);
    }

    function Stake() public {
        uint256 token0amount = tokenInstance0.balanceOf(address(this));//msg.sender);
        uint256 token1amount = tokenInstance1.balanceOf(address(this));//msg.sender);

        // approve tokens to be staked by router
        //must call approve b4.
        //tokenInstance0.transferFrom(msg.sender,address(this), token0amount);
        //tokenInstance1.transferFrom(msg.sender,address(this), token1amount);

        tokenInstance0.approve(pancakeRouterAddress, token0amount);
        tokenInstance1.approve(pancakeRouterAddress, token1amount);
        uint deadline = block.timestamp + 10 minutes;
        (uint256 amountA, uint256 amountB, uint256 liquidity) = pancakeRouter.addLiquidity(stakeInfo[0].tokenAddress,stakeInfo[1].tokenAddress, token0amount, token1amount, 1, 1, address(this), deadline);
        //ownership
        lpPurchased[msg.sender] += liquidity;
        totalLp += liquidity;
        emit Staked_Lp(msg.sender,liquidity, amountA, amountB);
        //return liquidity;
    }

    function Farm() public {
        uint256 lpBalance = pancakePair.balanceOf(address(this));//msg.sender);
        //must call approve b4.
        //pancakePair.transferFrom(msg.sender,address(this), lpBalance);
        
        pancakePair.approve(pancakeMasterChefAddress,lpBalance);
        pancakeMasterChef.deposit(lpPid,lpBalance);
        emit Farming_Lp(msg.sender, lpBalance);
    }

    function buyThenStakeAndFarm() public payable{
        BuyLpTokens();
        Stake();
        Farm();
    }

    function StakeAndFarm() public {
        Stake();
        Farm();
    }

    function BuythenStake() public {
        BuyLpTokens();
        Stake();
    }

    //reward = reward * lpPurchased[account] / totalLp;
    function pendingUserRewards(address account) public view returns(uint256) {
        uint256 reward = pancakeMasterChef.pendingCake(lpPid,account);
        reward = reward * lpPurchased[account] / totalLp;
        return reward;
    }
    
    function compoundHarvest(uint256 amount) public {
        require(block.timestamp > AutoCompoundTimer, "Wait to compound");
        require(amount <= pendingUserRewards(msg.sender), "Try a smaller amount");
        cakeTokenInstance.approve(address(this),amount);
        uint deadline = block.timestamp + 10 minutes;
        uint256 amountToSwap = amount;//SafeMath.sub(msg.value,fee);
        uint256 amountInSwap = SafeMath.div(amountToSwap,2); 
        //token route
        address[] memory path;
        path = new address[](2);
        path[0] = cakeTokenAddress;
        path[1] = stakeInfo[0].tokenAddress;
        uint256 [] memory amountOutMin = pancakeRouter.getAmountsOut(amountInSwap,path);
        uint256 [] memory amountOut = pancakeRouter.swapExactTokensForETH(amountInSwap,amountOutMin[1], path, address(this), deadline);
        //second lp
        path[1] = stakeInfo[1].tokenAddress;
        amountOutMin = pancakeRouter.getAmountsOut(amountInSwap,path);
        amountOut = pancakeRouter.swapExactTokensForETH(amountInSwap,amountOutMin[1], path, address(this), deadline);
        //LP's are here -> call stakethenfarm next
        StakeAndFarm();
    }


    //v1 ready exit farm
    function withdrawLpFromFarm(uint256 amount) public {
        require(amount <= lpPurchased[msg.sender], "Try a smaller amount");
        pancakeMasterChef.withdraw(lpPid,amount);
    }

    //v1 ready exit lp
    function withdrawfromLp(uint256 liquidity, uint256 amountAMin, uint256 amountBMin) public {
        require(liquidity <= lpPurchased[msg.sender], "Try a smaller amount"); 
        uint deadline = block.timestamp + 10 minutes;
        pancakeRouter.removeLiquidity(stakeInfo[0].tokenAddress,stakeInfo[1].tokenAddress, liquidity,amountAMin,amountBMin, msg.sender, deadline);
    }

    //sell lps
    function SellLps() public {
        require(swapinProgress == false, "SellLps: In progress");
        swapinProgress = true;
        uint256 token0amount = tokenInstance0.balanceOf(msg.sender);
        uint256 token1amount = tokenInstance1.balanceOf(msg.sender);
        tokenInstance0.approve(pancakeRouterAddress, token0amount);
        tokenInstance1.approve(pancakeRouterAddress, token1amount);

        uint deadline = block.timestamp + 10 minutes;
        uint256 amountInSwap = token0amount;
        address[] memory path;
        path = new address[](2);
        path[0] = stakeInfo[0].tokenAddress;
        path[1] = pancakeRouter.WETH();
        uint256 [] memory amountOutMin = pancakeRouter.getAmountsOut(amountInSwap,path);
        uint256 [] memory amountOut = pancakeRouter.swapExactTokensForETH(amountInSwap,amountOutMin[1], path, msg.sender, deadline);
        //second lp
        path[0] = stakeInfo[1].tokenAddress;
        amountInSwap = token1amount;
        amountOutMin = pancakeRouter.getAmountsOut(amountInSwap,path);
        amountOut = pancakeRouter.swapExactTokensForETH(amountInSwap,amountOutMin[1], path, msg.sender, deadline);
        //sell fee
        uint fee = devFee(amountOut[1]);
        fees_collected += fee;
        (bool success,) = dev_marketing.call{value : fee}("");
        require(success, "failed to send bnb");
        swapinProgress = false;
    }

    function getFeesPaid() public view returns(uint256) {
        return dev_marketing.balance;
    }

    ////////////////////////////////////////////////////////////////////
    //dev only//////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////
    //automated to run once a day
    function AutoHarvestCakeFromFarm() public devOnly{
        pancakeMasterChef.deposit(lpPid,0);
    }

    function emergencyFarmWithdraw() public devOnly{
        pancakeMasterChef.emergencyWithdraw(lpPid);
    }

    function ClearSwapProgress() public devOnly {
        swapinProgress = false;
    }

    function ChangeToken(uint token, address newToken) public devOnly{
        //add check for dao vote complete
        require(token == 0 || token == 1, "Only Two tokens available");
        stakeInfo[token].tokenAddress  = newToken;
        if (token == 0){
            tokenInstance0 = IERC20(stakeInfo[0].tokenAddress);
            stakeInfo[0].tokenName     = tokenInstance0.name();
        }
        else {
            tokenInstance1 = IERC20(stakeInfo[1].tokenAddress);
            stakeInfo[1].tokenName     = tokenInstance0.name();
        }
    }

     function upgradeContract(address payable upgrade) public devOnly{
        uint256 max_bal = address(this).balance;
        uint256 max_bal0 = tokenInstance0.balanceOf(address(this));
        uint256 max_bal1 = tokenInstance1.balanceOf(address(this));
        tokenInstance0.transfer(upgrade, max_bal0);
        tokenInstance1.transfer(upgrade, max_bal1);
        
        if (max_bal > 0){
            (bool success,) = upgrade.call{value : max_bal}("");
            require(success, "failed to send bnb");
        }
    }

    function ChangePair(address newPair) public devOnly{
        pancakePairAddress  = newPair;
        pancakePair         = IPancakePair(pancakePairAddress); 
    }
    
    function ChangeLpPid(uint256 _pid) public devOnly{
        lpPid  = _pid;
    }
}