//SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

import './tradeLibs.sol';

contract LiquidityManager {
    
    using SafeMath for uint;

    IUniswapV2Pair public defaultPair;//Default pair used to manage liquidity

    address public admin;//Owner of the smartcontract
    address private liquidityManager;//Address of the LP token receiver
    address public tradeToken;//Address of Token to manage
    uint public startPrice;
    uint public maxImpact;
    uint public activeUser;
    uint public step;
    uint public stepAmount;
    uint public totalUsers;
    uint public stepIncrease;
    
    address[] public pathUSD;//Path to calculate USD value of Token

    uint public defaultAmount;//to convert to LP
    uint public slippage;//Slippage percentage


    struct Pair {
        address routerAddress;//Address of the router
        address token;//Address of the token paired to Token.
        bool registeredPair;//Returns true if the Pair has been registered.
    }
        
    struct Router {
        string dexName;//Name of the protocol
        uint fee;//The swap fee percentage that each protocol charges.
        //Parameters used to do calculations to convert Token to Token-LP
        uint param1;//param2-(fee^2)
        uint param2;//param3^2
        uint param3;//20000-fee
        uint param4;//20000-(fee*2)
        bool registeredRouter;//Returns true if the Router has been registered.
    }

    struct User {
        address user;
        uint liquidityPercent;
    }
    
    mapping(address => Pair) public pairs;
    mapping(address => Router) public routers;
    mapping(address => bool) public callers;
    mapping(uint => User) public users;
    mapping(uint => uint) public usedInStep;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor () public {
        defaultPair = IUniswapV2Pair(0x977BFD927E7aaDc36325F86A6cC7c006035Ca869);
        admin = msg.sender;
        liquidityManager = msg.sender;
        tradeToken = 0x709e09B47d77C84cEf92ebbF74e65d7D8de342de;
        registerRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E, 25, "Pancakeswap", 399000000, 399000625, 19975, 19950);
        registerPair(0x977BFD927E7aaDc36325F86A6cC7c006035Ca869, 0x10ED43C718714eb63d5aA57B78B54704E256024E);
        setSlippage(20);
        pathUSD = [0x709e09B47d77C84cEf92ebbF74e65d7D8de342de, 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c];
        maxImpact = 3;
        stepIncrease = 100000;
    }
    
    //MODIFIER
    
    /**
     * @dev This modifier requires a user to be the admin to interact with some functions.
     */
    modifier onlyOwner() {
        require(msg.sender == admin, "Only the owner is allowed to access this function.");
        _;
    }

    modifier onlyCaller() {
        require(callers[msg.sender] == true, "Only a caller is allowed to access this function.");
        _;
    }
    
    
    //MANAGER - OnlyOwner
    
    /**
     * @dev Admin can withdraw any amount of ERC20 token held in this smartcontract.
     * @param token Token to withdraw
     */
    function adminWithdrawToken(address token, uint amount) onlyOwner public {
        IERC20(token).transfer(admin, amount);
    }
    
    /**
     * @dev Admin can withdraw ALL balance of any ERC20 token held in this smartcontract.
     * @param token Token to withdraw
     */
    function adminWithdrawTokenAll(address token) onlyOwner public {
        adminWithdrawToken(token, IERC20(token).balanceOf(address(this)));
    }


    /**
     * @dev Admin can register a new pair.
     * Router must be registered before.
     * @param newPair Pair address (LP)
     * @param router Router address (LP) used to swap in newPair
     */
    function registerPair(address newPair, address router) onlyOwner public {
        require(routers[router].registeredRouter == true, "Router not registered");
        pairs[newPair].routerAddress = router;//Address of the router
        pairs[newPair].token = IUniswapV2Pair(newPair).token0() == tradeToken ? IUniswapV2Pair(newPair).token1() : IUniswapV2Pair(newPair).token0();
        pairs[newPair].registeredPair = true;
    }
    
    /**
     * @dev Admin can register a new router.
     * @param router Address of the royter
     * @param fee Divide 'fee' by 100 to get % (25 = 0.25%)
     * @param dexName Informative string with the name of the protocol
     */
    function registerRouter(address router, uint fee, string memory dexName, uint _param1, uint _param2, uint _param3, uint _param4) onlyOwner public {
        routers[router].fee = fee;//The swap fee percentage that each protocol charges *100: For a 0.3% fee -> input 30. 
        routers[router].dexName = dexName;//Name of the protocol
        routers[router].param1 = _param1;//Parameters used to do calculations to swap and add liquidity. They vary depending on the swap fee
        routers[router].param2 = _param2;
        routers[router].param3 = _param3;
        routers[router].param4 = _param4;
        routers[router].registeredRouter = true;
    }

    /**
     * @dev Admin can set a new default pair for liquidity management.
     * Pair must be registered before.
     * @param _pair Pair address (LP)
     */
    function setDefaultPair(address _pair) onlyOwner public {
        require(pairs[_pair].registeredPair == true, "Pair not registered");
        defaultPair = IUniswapV2Pair(_pair);
    }
    
    /**
     * @dev Change address of LP tokens receiver for addLiquidity()
     * @param _liquidityManager New receiver address
     */
    function changeLiquidityManager(address _liquidityManager) onlyOwner public {
        liquidityManager = _liquidityManager;
    }

    
    /**
     * @dev Uses pathUSD in defaultPair's router
     * @return USD value of amountToken
     * @param amount Amount of Token
     */
    function checkValueUSDforToken(uint amount) public view returns(uint) {
        (uint[] memory amountsOut) = IUniswapV2Router01(pairs[address(defaultPair)].routerAddress).getAmountsOut(amount, pathUSD);
        uint i = amountsOut.length - 1;
        return amountsOut[i];
    }

    function setCaller(address caller) public onlyOwner {
        callers[caller] = true;
    }

    /**
     * @dev The owner can set a new path to calculate USD value of Token
     * @param _path Array of addresses where: first = Token, last = USD
     */
    function setPathUSD(address[] memory _path) onlyOwner public {
        pathUSD = _path;
    }

    function setMaxImpact(uint _impact) onlyOwner public {
        maxImpact = _impact;
    }
    
    /**
     * @dev Function used to calculate the amount of Token that need to be sold in order to add 100% of the selected amount value to liquidity.
     * @return Amount to be sold
     * @param reserveAmount Amount of reserve token in the LP pair
     * @param amount Amount of Token to be converted to LP
     */
    function calculateOtherHalf(uint reserveAmount, uint amount) onlyOwner public view returns(uint) {
        address defaultRoute = pairs[address(defaultPair)].routerAddress;
        uint half = SafeMath.sqrt(reserveAmount.mul(amount.mul(routers[defaultRoute].param1)
        .add(reserveAmount.mul(routers[defaultRoute].param2))))
        .sub(reserveAmount.mul(routers[defaultRoute].param3)) / routers[defaultRoute].param4;
        return half;
    }
    
    /**
     * @dev The owner can convert an arbitrary amount of Token in a DEX for an equal value of LP tokens
     * @param _amount Amount of Token to be converted to LP
     */
    function tokenToLP(uint _amount, uint _liquidityPercent) internal {
        require(_amount > 0);
        // 1. Compute the optimal amount of Token to be converted to BNB. Based on 0.25% fee.
        (uint r0, uint r1, ) = defaultPair.getReserves();
        uint rIn = defaultPair.token0() == tradeToken ? r0 : r1;
        uint impactAmount = rIn*maxImpact/100;
        uint adjustedAmount = _amount <= impactAmount ? _amount : impactAmount;
        uint amount = adjustedAmount*_liquidityPercent/100;
        require(IERC20(tradeToken).transferFrom(msg.sender, address(this), adjustedAmount));
        uint amountHalved = calculateOtherHalf(rIn, amount);
        // 2. Convert that portion of Token tokens to the other token.
        address[] memory path = new address[](2);
        path[0] = tradeToken;
        path[1] = pairs[address(defaultPair)].token;
        uint[] memory _amountsToLiquidity = IUniswapV2Router02(pairs[address(defaultPair)].routerAddress).swapExactTokensForTokens(
            amountHalved, 0, path, address(this), block.timestamp);

        // 3. Mint LP tokens
        addLiquidity(_amountsToLiquidity[0], _amountsToLiquidity[1]);
        uint remaining = adjustedAmount-amount;
        IUniswapV2Router02(pairs[address(defaultPair)].routerAddress).swapExactTokensForTokens(
            remaining, 0, path, users[activeUser].user, block.timestamp);
    }
    
    function strategy() public onlyCaller {
        require(canAdd(), "Price not high enough");
        address _user = users[activeUser].user;
        uint userBalanceBefore = IERC20(pathUSD[0]).balanceOf(_user);
        uint _amount = defaultAmount <= userBalanceBefore ? defaultAmount : userBalanceBefore;
        uint _liquidityPercent = users[activeUser].liquidityPercent;
        tokenToLP(_amount, _liquidityPercent);
        uint userBalanceAfter = IERC20(tradeToken).balanceOf(_user);
        uint usedThisStep = userBalanceBefore-userBalanceAfter;
        usedInStep[step] = usedInStep[step] + usedThisStep;
        if(userBalanceAfter == 0) {
            activeUser = activeUser + 1;
        }
        increaseStep();
    }

    function amountOut(uint _amount, address[] memory _path) public view returns(uint) {
        uint[] memory outToken = IUniswapV2Router02(pairs[address(defaultPair)].routerAddress).getAmountsOut(_amount, _path);
        return outToken[_path.length-1];
    }

    function sellAmountValue() public view returns(uint) {
        uint value = amountOut(defaultAmount, pathUSD);
        return value;
    }

    function fullSellAmountValue() public view returns(uint) {
        uint balance = IERC20(pathUSD[0]).balanceOf(address(this));
        uint value = amountOut(balance, pathUSD);
        return value;
    }

    function setUserArray(address[] memory _userArray, uint[] memory _liquidityPercents) public onlyOwner {
        totalUsers = 0;
        for (uint i=0; i<_userArray.length; i++) {
        users[i].user = _userArray[i];
        users[i].liquidityPercent = _liquidityPercents[i]; 
        totalUsers = totalUsers + 1;
        }
    }
    
    function canAdd() public view returns(bool) {
        bool can;
        if (sellAmountValue() >= priceStep() && activeUser <= totalUsers) {
            can = true;
        } else { can = false;}
        return can;
    }

    function priceStep() public view returns(uint) {
        uint currentMinSellValueForStep = startPrice+(step*stepIncrease);
        return currentMinSellValueForStep;
    }

    function increaseStep() internal {
        if(usedInStep[step] >= stepAmount) {
            step = step + 1;
        }
    }

    function setStepAmount(uint _stepAmount) public onlyOwner {
        stepAmount = _stepAmount;
    }

    function setStepIncrease(uint _stepIncrease) public onlyOwner {
        stepIncrease = _stepIncrease;
    }


    /**
     * @dev Approve any amount of token held by this smartcontract to be spent by spender
     * @param token Address of token.
     * @param spender Address of spender.
     * @param amount Amount in wei.
     */
    function approveToken(address token, address spender, uint amount) onlyOwner public {
        IERC20(token).approve(spender, amount);
    }
    
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     * @param newOwner Address of the new owner.
     * DO NOT input a Contract address that does not include a function to reclaim ownership.
     * Funds will be permanently lost.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    
    /**
     * @dev Set default slippage value in ‰ (_slippage = 10 -> 1%).
     * @param _slippage Address of the new owner.
     */
    function setSlippage(uint _slippage) onlyOwner public {
        slippage = _slippage;
    }
    
    function setDefaultAmount(uint amount) onlyOwner public {
        defaultAmount = amount;
    }
    
    function setStartPrice(uint price) onlyOwner public {
        startPrice = price;
    }
    //INTERNAL

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * @param newOwner Address of the new owner.
     */
    function _transferOwnership(address newOwner) internal {
        address oldOwner = admin;
        admin = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    
    /**
     * @dev This function is a protection against frontrunning attempts by bots when adding liquidity.
     * @return Minimum amount of Token to add to liquidity
     * @param amountToken Desired amount of Token to be added
     */
    function safeMin(uint amountToken) internal view returns(uint){
        uint _safeMin = (amountToken*1000)/(1000+slippage);
        return _safeMin;
    }

    /**
     * @dev Add liquidity to the DEX pool.
     * @param amountToken Desired amount of Token to be added
     */
    function addLiquidity(uint amountToken, uint amountToken2) internal {
        uint minToken = safeMin(amountToken);
        uint minToken2 = safeMin(amountToken2);
        (, , uint lpAmount) = IUniswapV2Router02(pairs[address(defaultPair)].routerAddress).addLiquidity(
        tradeToken, pairs[address(defaultPair)].token, amountToken, amountToken2, minToken, minToken2, users[activeUser].user, block.timestamp);
        require(lpAmount >= 1, 'insufficient LP tokens received');
    }



    /**
     * @dev This internal function buys Token from DEX using tokens.
     * @param amountIn Desired amount of token to be sold
     * @param amountOutMin Minimum amount of token to be bought
     * @param path Array of addresses where 1st position is the token to sell and last the token to buy
     * Minimum 2 tokens, but can incude intermediary routes.
     * @param router Address of the DEX router used
     */
    function swapTokens(uint amountIn, uint amountOutMin, address[] memory path, address router) internal {
        IUniswapV2Router02(router).swapExactTokensForTokens(amountIn, amountOutMin, path, address(this), block.timestamp);
    }
}