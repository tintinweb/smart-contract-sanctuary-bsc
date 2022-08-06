// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;


import './IUniswapV2Router02.sol';
import './IUniswapV2Factory.sol';
import './IERC20.sol';
import './IPancakePair.sol';
import './IMasterChef.sol';
import './SafeMath.sol';

contract ssCompounder{
    //O.Z. math lib
    using SafeMath for uint256;
    ///////////////////////////////////////////////////////////////////
    ////////////////// Contract data //////////////////////////////////
    ///////////////////////////////////////////////////////////////////
    string  public  name       = "ss-Compounder v.0.1.0";
    uint256 public  dev_fee    = 6;
    address payable dev_marketing;
    uint256         fees_collected    = 0;
    uint256 public  AutoCompoundTimer = 0;
    //Time between compounds
    uint256         AUTO_TIMER = 15 minutes;
    uint256 public  lpPid      = 108;
    //Total Bnb contract has received (never decreases)
    uint256 public totalBnb    = 0;
    //Total LP over time. Decreases when users withdraw their funds
    uint256 public totalLp     = 0;
    //Future change LP & Farm
    bool public freezeBuyin    = false;

    struct Staking{
        address tokenAddress;
        string tokenName;
    }
    Staking[2] public stakeInfo;
    IERC20 public tokenInstance0;
    IERC20 public tokenInstance1;
    //
    address public pancakeRouterAddress;
    IUniswapV2Router02 pancakeRouter;
    //
    address public pancakeMasterChefAddress;
    IMasterChef pancakeMasterChef;
    //
    address public pancakePairAddress;
    IPancakePair pancakePair;
    //rewards are in cake
    address cakeTokenAddress = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
    IERC20 cakeTokenInstance;
    //
    ///////////////////////////////////////////////////////////////////
    ///////////// Ownership data in order of usage ////////////////////
    ///////////////////////////////////////////////////////////////////
    //Token 0 & 1 count on a single deposit, is always reset to 0
    mapping(address => uint256) lpToken0Purchased; 
    mapping(address => uint256) lpToken1Purchased;
    //Total Token 0 & 1 total counter
    mapping(address => uint256) public lpToken0Staked;
    mapping(address => uint256) public lpToken1Staked;
    //Liquidity Pool Token count on a single deposit, is always reset to 0
    mapping(address => uint256) lpPurchased;
    //Liquidity Pool Token total counter.
    mapping(address => uint256) public lpPurchasedInFarm;
    //User time between harvests
    mapping(address => uint256) public userHarvestTimer;
    
    ///////////////////////////////////////////////////////////////////
    //////////////////////// Event data ///////////////////////////////
    ///////////////////////////////////////////////////////////////////
    event BuyAndStakeAndFarm(address);
    event NormalHarvest(address, uint256);
    event CompoundedHarvest(address, uint256);
    event WithdrawAll(address);
    event AutoHarvesting();
    
    ///////////////////////////////////////////////////////////////////
    ///////////// constructor data  ///////////////////////////////////
    ///////////////////////////////////////////////////////////////////
    constructor(){
        //switch tokens to high apy pancake tokens
        dev_marketing = payable(msg.sender);
        
        cakeTokenInstance = IERC20(cakeTokenAddress);
        //Staking token 0
        stakeInfo[0].tokenAddress  = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        stakeInfo[0].tokenName     = "BUSD";
        tokenInstance0             = IERC20(stakeInfo[0].tokenAddress);
        //Staking token 1
        stakeInfo[1].tokenAddress  = 0xa865197A84E780957422237B5D152772654341F3;
        stakeInfo[1].tokenName     = "OLE";
        tokenInstance1             = IERC20(stakeInfo[1].tokenAddress);
        //router for swapping tokens, adding & removing liquidity
        pancakeRouterAddress       = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        pancakeRouter              = IUniswapV2Router02(pancakeRouterAddress);
        //MasterChef for depositing & withdrawing LP's to farm
        pancakeMasterChefAddress   = 0xa5f8C5Dbd5F286960b9d90548680aE5ebFf07652;
        pancakeMasterChef          = IMasterChef(pancakeMasterChefAddress);
        //pair address 
        pancakePairAddress         = 0xe9F369298565B60a0DC19A6fA93cEE934Fd1A58c;
        pancakePair                = IPancakePair(pancakePairAddress); 
    }

    ///////////////////////////////////////////////////////////////////
    ///////////// read functions  /////////////////////////////////////
    ///////////////////////////////////////////////////////////////////
    function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,dev_fee),100);
    }

    function pendingContractRewards() public view returns(uint256) {
        uint256 reward = pancakeMasterChef.pendingCake(lpPid,address(this));
        return reward;
    }

    function contractCakeBalance() public view returns(uint256) {
        uint256 bal = cakeTokenInstance.balanceOf(address(this));
        return bal;
    }
    ///////////////////////////////////////////////////////////////////
    ///////////// Reward Calculators //////////////////////////////////
    ///////////////////////////////////////////////////////////////////
    
    function readyUserRewards(address account) public view returns(uint256) {
        uint256 reward = contractCakeBalance();
        uint256 userReward = SafeMath.div(SafeMath.mul(reward,lpPurchasedInFarm[account]),totalLp);
        return userReward;
    }

   function pendingUserRewards(address account) public view returns(uint256) {
        uint256 reward = pendingContractRewards();
        uint256 userReward = SafeMath.div(SafeMath.mul(reward,lpPurchasedInFarm[account]),totalLp);
        return userReward;
    }
    
    ///////////////////////////////////////////////////////////////////
    ///////////// buy in functions  ///////////////////////////////////
    ///////////////////////////////////////////////////////////////////
    function BuyStakeFarm() public payable{
        userHarvestTimer[msg.sender] = block.timestamp + AUTO_TIMER;
        BuyLpTokens();
        Stake();
        Farm();
        emit BuyAndStakeAndFarm(msg.sender);
    }

    // swap bnb for near equal amounts of the 2 LP's
    function BuyLpTokens() public payable{
        require(freezeBuyin == false, "Buy in Froze. Pls cash out if you have invested.");
        require(msg.value >= 0.001 ether, "Minimum is 0.001 bnb");
        //set contract timer on first buy in.
        if (totalBnb == 0)
            {
            AutoCompoundTimer = block.timestamp + AUTO_TIMER;
            }
        totalBnb += msg.value;
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
        lpToken0Purchased[msg.sender] = amountOut[1];
        //second lp
        path[1] = stakeInfo[1].tokenAddress;
        amountOutMin = pancakeRouter.getAmountsOut(amountInSwap,path);
        amountOut = pancakeRouter.swapExactETHForTokens{value: amountInSwap}(amountOutMin[1], path, address(this), deadline);
        //
        lpToken1Purchased[msg.sender] = amountOut[1];
        (bool success,) = dev_marketing.call{value : fee}("");
        require(success, "failed to send bnb");
        fees_collected += fee;
    }

    // staked the senders amount of each token in the liquidity pool
    function Stake() public {
        uint256 token0amount = lpToken0Purchased[msg.sender];
        uint256 token1amount = lpToken1Purchased[msg.sender];
        lpToken0Purchased[msg.sender] = 0;
        lpToken1Purchased[msg.sender] = 0;
        // approve tokens to be transfered by router
        tokenInstance0.approve(pancakeRouterAddress, token0amount);
        tokenInstance1.approve(pancakeRouterAddress, token1amount);
        uint deadline = block.timestamp + 10 minutes;
        (uint256 amountA, uint256 amountB, uint256 liquidity) = pancakeRouter.addLiquidity(stakeInfo[0].tokenAddress,stakeInfo[1].tokenAddress, token0amount, token1amount, 1, 1, address(this), deadline);
        //ownership of LP 
        totalLp += liquidity;
        lpToken0Staked[msg.sender] += amountA;
        lpToken1Staked[msg.sender] += amountB;
        lpPurchased[msg.sender] = liquidity;
    }

    function Farm() public {
        //approve LP to be transfered by the Farm
        uint256 toFarmAmount = lpPurchased[msg.sender];
        lpPurchased[msg.sender] = 0;
        pancakePair.approve(pancakeMasterChefAddress,toFarmAmount);
        pancakeMasterChef.deposit(lpPid,toFarmAmount);
        //
        lpPurchasedInFarm[msg.sender] += toFarmAmount;
    }
    ///////////////////////////////////////////////////////////////////
    //// Exit contract functions, Send token share to user  ///////////
    ////////////////////////////////////////////////////////////////////
    function withdrawLps() public {
        withdrawLpFromFarm();
        withdrawfromLp();
        //dev/marketing fee
        uint256 fee0 = devFee(lpToken0Staked[msg.sender]);
        uint256 fee1 = devFee(lpToken1Staked[msg.sender]);
        uint256 out0 = SafeMath.sub(lpToken0Staked[msg.sender], fee0);
        uint256 out1 = SafeMath.sub(lpToken1Staked[msg.sender], fee1);
        //ownership deleted
        lpToken0Staked[msg.sender] = 0;
        lpToken1Staked[msg.sender] = 0;
        //fee
        tokenInstance0.transfer(dev_marketing, fee0);
        tokenInstance1.transfer(dev_marketing, fee1);
        //send the rest of the tokens
        tokenInstance0.transfer(msg.sender, out0);
        tokenInstance1.transfer(msg.sender, out1);
        //
        emit WithdrawAll(msg.sender);
    }
    
    //v1 ready exit farm
    function withdrawLpFromFarm() public {
        require(lpPurchasedInFarm[msg.sender] > 0, "You have not provided LPT's");
        pancakeMasterChef.withdraw(lpPid,lpPurchasedInFarm[msg.sender]);
    }

    //v1 ready exit lp
    function withdrawfromLp() public {
        require(lpPurchasedInFarm[msg.sender] > 0, "You have not provided LPT's");
        uint deadline = block.timestamp + 10 minutes;
        uint256 fromLp = lpPurchasedInFarm[msg.sender];
        totalLp -= fromLp;
        lpPurchasedInFarm[msg.sender] = 0;
        //approve lp to be burned by router
        pancakePair.approve(pancakeRouterAddress,fromLp);
        (uint amountA, uint amountB) = pancakeRouter.removeLiquidity(stakeInfo[0].tokenAddress,stakeInfo[1].tokenAddress, fromLp,1,1, address(this), deadline);
        lpToken0Staked[msg.sender] = amountA;
        lpToken1Staked[msg.sender] = amountB;
    }

    ////////////////////////////////////////////////////////////////////////////////
    /////////////////////////Harvest types /////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////
    function compoundHarvest() public {
        require(pendingUserRewards(msg.sender) > 0 || readyUserRewards(msg.sender) > 0, "No rewards ATM");
        require(block.timestamp > userHarvestTimer[msg.sender], "Wait to harvest");
        userHarvestTimer[msg.sender] = block.timestamp + AUTO_TIMER;
        //check if its time for rewards. 
        if (block.timestamp > AutoCompoundTimer ){
            pancakeMasterChef.deposit(lpPid,0);
            AutoCompoundTimer = block.timestamp + AUTO_TIMER;
        }
        require(cakeTokenInstance.balanceOf(address(this)) > readyUserRewards(msg.sender), "Contract insuffcient funds");
        //approve router to swap
        cakeTokenInstance.approve(pancakeRouterAddress,readyUserRewards(msg.sender));
        uint deadline = block.timestamp + 10 minutes;
        uint256 amountToSwap = readyUserRewards(msg.sender);
        uint256 amountInSwap = SafeMath.div(amountToSwap,2); 
        //token route
        address[] memory path;
        path = new address[](2);
        path[0] = cakeTokenAddress;
        path[1] = stakeInfo[0].tokenAddress;
        uint256 [] memory amountOutMin = pancakeRouter.getAmountsOut(amountInSwap,path);
        uint256 [] memory amountOut = pancakeRouter.swapExactTokensForTokens(amountInSwap,amountOutMin[1], path, address(this), deadline);
        lpToken0Purchased[msg.sender] = amountOut[1];
        //second lp
        path[1] = stakeInfo[1].tokenAddress;
        amountOutMin = pancakeRouter.getAmountsOut(amountInSwap,path);
        amountOut = pancakeRouter.swapExactTokensForTokens(amountInSwap,amountOutMin[1], path, address(this), deadline);
        lpToken1Purchased[msg.sender] = amountOut[1];
        //LP's are here -> call stake and farm next
        Stake();
        Farm();
        emit CompoundedHarvest(msg.sender, lpPurchased[msg.sender]);
    }
    
    //harvest can be done every x hours
    function HarvestComplex() public {
        require(pendingUserRewards(msg.sender) > 0 || readyUserRewards(msg.sender) > 0, "No rewards ATM");
        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        require(block.timestamp > userHarvestTimer[msg.sender], "Wait to harvest");
        userHarvestTimer[msg.sender] = block.timestamp + AUTO_TIMER;
        //check if its time for rewards. Only the first user to compound (every 12 hours) will auto run it
        if (block.timestamp > AutoCompoundTimer ){
            AutoCompoundTimer = block.timestamp + AUTO_TIMER;
            pancakeMasterChef.deposit(lpPid,0);
        }
        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        require(cakeTokenInstance.balanceOf(address(this)) > readyUserRewards(msg.sender), "Contract insuffcient funds");
        cakeTokenInstance.transfer(msg.sender,readyUserRewards(msg.sender));
        //
        emit NormalHarvest(msg.sender, readyUserRewards(msg.sender));
    }

    function HarvestBasic() public {
        require(block.timestamp > userHarvestTimer[msg.sender], "Wait to harvest");
        require(readyUserRewards(msg.sender) > 0, "No rewards ATM");
        require(cakeTokenInstance.balanceOf(address(this)) > readyUserRewards(msg.sender), "Contract insuffcient funds");
        userHarvestTimer[msg.sender] = block.timestamp + AUTO_TIMER;
        //
        cakeTokenInstance.transfer(msg.sender,readyUserRewards(msg.sender));
        emit NormalHarvest(msg.sender, readyUserRewards(msg.sender));
    }

    ////////////////////////////////////////////////////////////////////////////////
    //////////////// Hopeful for v1 works with HarvestBasic ////////////////////////
    //////////////////////////////////////////////////////////////////////////////// 
    //we are working to run a server to automate this function, saving users on gas. 
    //For now harvestcomplex takes care of this
    function AutoHarvest() public {
        require(msg.sender == dev_marketing, "Only admin can autoharvest");
        pancakeMasterChef.deposit(lpPid,0);
        AutoCompoundTimer = AutoCompoundTimer + AUTO_TIMER;
        emit AutoHarvesting();
    }

    //Only for if funds get locked, bnb and tokens shouldn;t remain in the contract, as it should always be swapped for lps and farmed.
    //Ex: Pennies worth may remain when addLiquity is called taking equvalent value amounts. 
    //These funds will be redistributed to holders at random.
    function RemoveBnb(uint256 amount) public {
        require(msg.sender == dev_marketing, "Admin only");
        (bool success,) = dev_marketing.call{value : amount}("");
        require(success, "failed to send bnb");
    }
    function RemoveToken0(address account, uint256 amount) public {
        require(msg.sender == dev_marketing, "Admin only");
        tokenInstance0.transfer(account,amount);
    }
    function RemoveToken1(address account, uint256 amount) public {
        require(msg.sender == dev_marketing, "Admin only");
        tokenInstance1.transfer(account,amount);
    }
    function RemovePancake(address account, uint256 amount) public {
        require(msg.sender == dev_marketing, "Admin only");
        cakeTokenInstance.transfer(account,amount);
    }
    ////////////////////////////////////////////////////////////////////////////////
    ////////////////// Future looking functions ////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////// 
    function ChangeHarvestTimer(uint256 timer) public {
        require(msg.sender == dev_marketing, "Admin only");
        AUTO_TIMER = timer;   
    } 
    function FreezeBuyIn() public {
        require(msg.sender == dev_marketing, "Admin only");
        freezeBuyin = true;
    }
    function unFreezeBuyIn() public {
        require(msg.sender == dev_marketing, "Admin only");
        freezeBuyin = false;
    }
    // Ability to change Farm.
    function ChangeLp(address token0, address token1, address pair, uint256 pid) public {
        require(msg.sender == dev_marketing, "Admin only");
        require(freezeBuyin == true, "Buy in must be frozen prior");
        stakeInfo[0].tokenAddress  = token0;
        tokenInstance0             = IERC20(stakeInfo[0].tokenAddress);
        stakeInfo[0].tokenName     = tokenInstance0.name();
        //
        stakeInfo[1].tokenAddress  = token1;
        tokenInstance1             = IERC20(stakeInfo[1].tokenAddress);
        stakeInfo[1].tokenName     = tokenInstance1.name();
        //
        pancakePairAddress         = pair;
        pancakePair                = IPancakePair(pancakePairAddress); 
        //
        lpPid = pid;
    }

}