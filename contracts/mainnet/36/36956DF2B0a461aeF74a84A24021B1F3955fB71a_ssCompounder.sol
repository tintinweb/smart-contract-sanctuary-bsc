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
    
    string  public name       = "ss-Compounder v0.0.1";
    uint256 public dev_fee    = 6;
    uint256 public lpPid      = 108;
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
    //event
    mapping(address => uint256) public lpPurchased;
    mapping(address => uint256) public lpToken0Purchased; 
    mapping(address => uint256) public lpToken1Purchased;
    mapping(address => uint256) public lpToken0Staked; 
    mapping(address => uint256) public lpToken1Staked;

    mapping(address => uint256) public userHarvestTimer;
    //track total of LP tokens, token0 and token1 for rewards
    uint256 public totalLp = 0;
    uint256 public totalLpToken0 = 0;
    uint256 public totalLpToken1 = 0;
    //
    event BuyAndStakeAndFarm();
    event NormalHarvest(address, uint256);
    event CompoundedHarvest(address, uint256);
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
        stakeInfo[1].tokenAddress  = 0xa865197A84E780957422237B5D152772654341F3;
        stakeInfo[1].tokenName     = "OLE";
        tokenInstance1             = IERC20(stakeInfo[1].tokenAddress);
        //router
        pancakeRouterAddress       = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        pancakeRouter              = IUniswapV2Router02(pancakeRouterAddress);
        //MasterChef
        pancakeMasterChefAddress   = 0xa5f8C5Dbd5F286960b9d90548680aE5ebFf07652;
        pancakeMasterChef          = IMasterChef(pancakeMasterChefAddress);
        //pair address 
        pancakePairAddress         = 0xe9F369298565B60a0DC19A6fA93cEE934Fd1A58c;
        pancakePair                = IPancakePair(pancakePairAddress); 
    }

    function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,dev_fee),100);
    }

    function balanceTokens0()public view returns(uint256){ 
        return tokenInstance0.balanceOf(address(this));
    }

    function balanceTokens1()public view returns(uint256){ 
        return tokenInstance1.balanceOf(address(this));
    }

    function getFeesPaid() public view returns(uint256) {
        return dev_marketing.balance;
    }

    function pendingUserRewards(address account) public view returns(uint256) {
        //add pending reward to current balance
        uint256 reward = pancakeMasterChef.pendingCake(lpPid,address(this)) + cakeTokenInstance.balanceOf(address(this));
        reward = reward / totalLp * lpPurchased[account];
        return reward;
    }

    //Buy in with BNB
    function BuyStakeFarm() public payable{
        BuyLpTokens();
        Stake();
        Farm();
        userHarvestTimer[msg.sender] = block.timestamp + 12 hours;
        emit BuyAndStakeAndFarm();
    }
    // swap bnb for equal amounts of the 2 LP's
    function BuyLpTokens() public payable{
        require(msg.value >= 0.001 ether, "Minimum is 0.001 bnb");
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
        //tracks users deposits
        totalLpToken0 += amountOut[1];
        lpToken0Purchased[msg.sender] += amountOut[1];
        //second lp
        path[1] = stakeInfo[1].tokenAddress;
        amountOutMin = pancakeRouter.getAmountsOut(amountInSwap,path);
        amountOut = pancakeRouter.swapExactETHForTokens{value: amountInSwap}(amountOutMin[1], path, address(this), deadline);
        //
        totalLpToken1 += amountOut[1];
        lpToken1Purchased[msg.sender] += amountOut[1];
        (bool success,) = dev_marketing.call{value : fee}("");
        require(success, "failed to send bnb");
        fees_collected += fee;
    }

    // staked the senders amount of each token in the liquidity pool
    function Stake() public {
        uint256 token0amount = lpToken0Purchased[msg.sender];
        uint256 token1amount = lpToken1Purchased[msg.sender];
        // approve tokens to be transfered by router
        tokenInstance0.approve(pancakeRouterAddress, token0amount);
        tokenInstance1.approve(pancakeRouterAddress, token1amount);
        uint deadline = block.timestamp + 10 minutes;
        (uint256 amountA, uint256 amountB, uint256 liquidity) = pancakeRouter.addLiquidity(stakeInfo[0].tokenAddress,stakeInfo[1].tokenAddress, token0amount, token1amount, 1, 1, address(this), deadline);
        //ownership of LP 
        lpToken0Staked[msg.sender] += amountA;
        lpToken1Staked[msg.sender] += amountB;
        //
        lpPurchased[msg.sender] += liquidity;
        totalLp += liquidity;
    }

    function Farm() public {
        //approve LP to be transfered by the Farm
        pancakePair.approve(pancakeMasterChefAddress,lpPurchased[msg.sender]);
        pancakeMasterChef.deposit(lpPid,lpPurchased[msg.sender]);
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////
    function compoundHarvest() public {
        require(pendingUserRewards(msg.sender) > 0, "No rewards ATM");
        require(block.timestamp > userHarvestTimer[msg.sender], "Wait to harvest");
        //check if its time for rewards. 
        if (block.timestamp > AutoCompoundTimer ){
            pancakeMasterChef.deposit(lpPid,0);
            AutoCompoundTimer = AutoCompoundTimer + 12 hours;
        }
        require(cakeTokenInstance.balanceOf(address(this)) > pendingUserRewards(msg.sender), "Contract insuffcient funds");
        cakeTokenInstance.approve(address(this),pendingUserRewards(msg.sender));
        uint deadline = block.timestamp + 10 minutes;
        uint256 amountToSwap = pendingUserRewards(msg.sender);
        uint256 amountInSwap = SafeMath.div(amountToSwap,2); 
        //token route
        address[] memory path;
        path = new address[](2);
        path[0] = cakeTokenAddress;
        path[1] = stakeInfo[0].tokenAddress;
        uint256 [] memory amountOutMin = pancakeRouter.getAmountsOut(amountInSwap,path);
        uint256 [] memory amountOut = pancakeRouter.swapExactTokensForETH(amountInSwap,amountOutMin[1], path, address(this), deadline);
        totalLpToken0 += amountOut[1];
        lpToken0Purchased[msg.sender] += amountOut[1];
        //second lp
        path[1] = stakeInfo[1].tokenAddress;
        amountOutMin = pancakeRouter.getAmountsOut(amountInSwap,path);
        amountOut = pancakeRouter.swapExactTokensForETH(amountInSwap,amountOutMin[1], path, address(this), deadline);
        totalLpToken1 += amountOut[1];
        lpToken1Purchased[msg.sender] += amountOut[1];
        //LP's are here -> call stake and farm next
        Stake();
        Farm();
        //
        userHarvestTimer[msg.sender] = block.timestamp + 12 hours;
        emit CompoundedHarvest(msg.sender, lpPurchased[msg.sender]);
    }
    
    //harvest can be done every 12 hours
    function HarvestBasic() public {
        require(pendingUserRewards(msg.sender) > 0, "No rewards ATM");
        require(block.timestamp > userHarvestTimer[msg.sender], "Wait to harvest");
        require(cakeTokenInstance.balanceOf(address(this)) > pendingUserRewards(msg.sender), "Contract insuffcient funds");
        userHarvestTimer[msg.sender] = block.timestamp + 12 hours;
        //
        cakeTokenInstance.transfer(msg.sender,pendingUserRewards(msg.sender));
        emit NormalHarvest(msg.sender, pendingUserRewards(msg.sender));
    }

    function HarvestComplex() public {
        require(pendingUserRewards(msg.sender) > 0, "No rewards ATM");
        require(block.timestamp > userHarvestTimer[msg.sender], "Wait to harvest");
        userHarvestTimer[msg.sender] = block.timestamp + 12 hours;
        //check if its time for rewards. first user to compound will auto run it for all
        if (block.timestamp > AutoCompoundTimer ){
            pancakeMasterChef.deposit(lpPid,0);
            AutoCompoundTimer = AutoCompoundTimer + 12 hours;
        }
        require(cakeTokenInstance.balanceOf(address(this)) > pendingUserRewards(msg.sender), "Contract insuffcient funds");
        cakeTokenInstance.transfer(msg.sender,pendingUserRewards(msg.sender));
        //
        emit NormalHarvest(msg.sender, pendingUserRewards(msg.sender));
    }

    //////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////

    /*
    Exit contract functions
    Sell back for tokens
    */
    function withdrawLps() public {
        withdrawLpFromFarm();
        withdrawfromLp();
        //
        uint256 fee0 = devFee(lpToken0Staked[msg.sender]);
        uint256 fee1 = devFee(lpToken1Staked[msg.sender]);
        //fee
        tokenInstance0.transfer(dev_marketing, fee0);
        tokenInstance1.transfer(dev_marketing, fee1);
        //send the rest of the tokens
        tokenInstance0.transfer(msg.sender, SafeMath.sub(lpToken0Staked[msg.sender], fee0));
        tokenInstance1.transfer(msg.sender, SafeMath.sub(lpToken1Staked[msg.sender], fee0));
        //ownership deleted
        lpToken0Staked[msg.sender] = 0;
        lpToken1Staked[msg.sender] = 0;
        lpToken0Purchased[msg.sender] = 0;
        lpToken1Purchased[msg.sender] = 0;
    }
    
    //v1 ready exit farm
    function withdrawLpFromFarm() public {
        require(lpPurchased[msg.sender] > 0, "You have not provided LPT's");
        pancakeMasterChef.withdraw(lpPid,lpPurchased[msg.sender]);
    }

    //v1 ready exit lp
    function withdrawfromLp() public {
        require(lpPurchased[msg.sender] > 0, "You have not provided LPT's");
        uint deadline = block.timestamp + 10 minutes;
        //approve lp to be burned by router
        pancakePair.approve(pancakeRouterAddress,lpPurchased[msg.sender]);
        (uint amountA, uint amountB) = pancakeRouter.removeLiquidity(stakeInfo[0].tokenAddress,stakeInfo[1].tokenAddress, lpPurchased[msg.sender],1,1, address(this), deadline);
        lpPurchased[msg.sender] = 0;
        lpToken0Staked[msg.sender] = amountA;
        lpToken1Staked[msg.sender] = amountB;
    }
    //we are working to run a server to automate this function. for now harvestcomplex fixes this
    function AutoHarvest() public {
        require(msg.sender == dev_marketing, "Only admin can autoharvest");
        pancakeMasterChef.deposit(lpPid,0);
        AutoCompoundTimer = AutoCompoundTimer + 12 hours;
    }

    //Only for if funds get locked, bnb shouldnt remain in the contract anyways it should always be swapped for lps
    function RemoveBnb(uint256 amount) public {
        require(msg.sender == dev_marketing, "Admin only");
        (bool success,) = dev_marketing.call{value : amount}("");
        require(success, "failed to send bnb");
    }

}