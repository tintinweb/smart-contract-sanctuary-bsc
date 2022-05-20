/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

pragma solidity ^0.8.0;

//SPDX-License-Identifier: Unlicense

interface IERC20 {
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint8);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

//UniswapV1 Factory
interface UniswapFactoryInterface {
    // Public Variables
    //address public exchangeTemplate; <= commented because it errors the code
    //uint256 public tokenCount; <= commented because it errors the code
    // Create Exchange
    function createExchange(address token) external returns (address exchange);
    // Get Exchange and Token Info
    function getExchange(address token) external view returns (address exchange);
    function getToken(address exchange) external view returns (address token);
    function getTokenWithId(uint256 tokenId) external view returns (address token);
    // Never use
    function initializeFactory(address template) external;
}

interface IUniswapV3Factory {
    //not full interface
    function getPool(address tokenA,address tokenB,uint24 fee) external view returns (address pool);
}

interface IUniswapV3Pool{
    //not full interface
    function slot0() external view returns (
        uint160 sqrtPriceX96, 
        int24 tick, 
        uint16 observationIndex, 
        uint16 observationCardinality, 
        uint16 observationCardinalityNext, 
        uint8 feeProtocol, 
        bool unlocked);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function fee() external view returns (uint24);
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

contract Price {
    address owner;
    
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //TESTNET 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
    address public BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //TESTNET 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    address public USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    //address public UST = 0x23396cF899Ca06c4472205fC903bDB4de249D6fC;


    uint24[] public feesV3 = [500,3000,10000];

    bool public shouldCheckV1 = false;
    bool public shouldCheckV2 = true;
    bool public shouldCheckV3 = false;

    address[] public commonDEXesV1;
    mapping(address => uint256) public indexOfCommonDEXesV1;

    address[] public commonDEXesV3;
    mapping(address => uint256) public indexOfCommonDEXesV3;

    address[] public commonTokens;
    mapping(address => uint256) public indexOfCommonTokens;

    address[] public commonDEXes;
    mapping(address => uint256) public indexOfCommonDEXes;


    IUniswapV2Pair BNBPair =
        IUniswapV2Pair(0xe0e92035077c39594793e61802a350347c320cf2);

    constructor() {
        owner = msg.sender;
        commonTokens.push(WBNB);
        commonTokens.push(BUSD);
        commonTokens.push(USDT);
        commonTokens.push(USDC);
        commonDEXes.push(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
    }

    function changeShouldCheck(uint8 position, bool newStatus) external {
        require(owner == msg.sender, "Only the DAO can add a token.");

        if(position == 1){
            shouldCheckV1 = newStatus;
        }
        else if(position == 2){
            shouldCheckV2 = newStatus;
        }
        else if(position == 3){
            shouldCheckV3 = newStatus;
        }
    }

    function addCommonToken(address tokenAddress) external {
        require(owner == msg.sender, "Only the DAO can add a token.");
        indexOfCommonTokens[tokenAddress] = commonTokens.length;
        commonTokens.push(tokenAddress);
    }

    function removeCommonTokens(address tokenAddress) external {
        require(owner == msg.sender, "Only the DAO can add a DEX.");
        commonTokens[indexOfCommonTokens[tokenAddress]] = commonTokens[
            commonTokens.length - 1
        ];
        indexOfCommonTokens[
            commonTokens[commonTokens.length - 1]
        ] = indexOfCommonTokens[tokenAddress];
        commonTokens.pop();
    }

    function addCommonDEXes(address dexAddress, uint8 factoryVersion) external {
        require(owner == msg.sender, "Only the DAO can add a DEX.");
        if(factoryVersion == 1){

            indexOfCommonDEXesV1[dexAddress] = commonDEXesV1.length;
            commonDEXesV1.push(dexAddress);

        }
        else if(factoryVersion == 2){

            indexOfCommonDEXes[dexAddress] = commonDEXes.length;
            commonDEXes.push(dexAddress);

        }
        else if(factoryVersion == 3){

            indexOfCommonDEXesV3[dexAddress] = commonDEXesV3.length;
            commonDEXesV3.push(dexAddress);

        }
        
    }

    function removeCommonDEXes(address dexAddress,uint8 factoryVersion) external {
        require(owner == msg.sender, "Only the DAO can add a DEX.");
        if(factoryVersion == 1){

            commonDEXesV1[indexOfCommonDEXesV1[dexAddress]] = commonDEXesV1[
            commonDEXesV1.length - 1
            ];
            indexOfCommonDEXesV1[
            commonDEXesV1[commonDEXesV1.length - 1]
            ] = indexOfCommonDEXesV1[dexAddress];
            commonDEXesV1.pop();

        }
        else if(factoryVersion == 2){

            commonDEXes[indexOfCommonDEXes[dexAddress]] = commonDEXes[
            commonDEXes.length - 1
            ];
            indexOfCommonDEXes[
            commonDEXes[commonDEXes.length - 1]
            ] = indexOfCommonDEXes[dexAddress];
            commonDEXes.pop();

        }
        else if(factoryVersion == 3){

            commonDEXesV3[indexOfCommonDEXesV3[dexAddress]] = commonDEXesV3[
            commonDEXesV3.length - 1
            ];
            indexOfCommonDEXesV3[
            commonDEXesV3[commonDEXesV3.length - 1]
            ] = indexOfCommonDEXesV3[dexAddress];
            commonDEXesV3.pop();

        }
    }

    function getUSDPriceFromSpecificDEXV1(address tokenAddress, address factoryAddress) public view returns (uint256, uint256){
        uint256 averagePrice;
        uint256 totalLiquidity;

        UniswapFactoryInterface factory = UniswapFactoryInterface(factoryAddress);

        address exchangeAddress = factory.getExchange(tokenAddress);

        if(exchangeAddress != address(0) && IERC20(tokenAddress).balanceOf(exchangeAddress) != 0 && address(exchangeAddress).balance != 0){
            uint256 reserve0 = IERC20(tokenAddress).balanceOf(exchangeAddress);
            uint256 reserve1 = address(exchangeAddress).balance;
            uint256 pairPrice;
            uint256 pairLiquidity;

            uint256 BNBUSDPrice = getBasicPrice(WBNB);
            pairPrice = (BNBUSDPrice * reserve1) / reserve0;
            pairLiquidity = (BNBUSDPrice * reserve1) / 10**18;
            totalLiquidity += pairLiquidity;
        }
        if (totalLiquidity != 0) {
            return (averagePrice / totalLiquidity, totalLiquidity);
        }
        else {
            return (0, 0);
        }
    }

    function isStable(address tokenAddr) public view returns (bool) {
        bool stable = false;

        for (uint8 i = 1; i < commonTokens.length && !stable; i++){
            stable = tokenAddr == commonTokens[i] ? true : false;
        }
        return stable;
    }

    function returnLPPiceFromV3(address poolAddr,uint256 priceToken0USD, uint256 priceToken1USD) public view returns (uint256,uint256){
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddr);
        uint256 LP0BalanceToUSD;
        uint256 LP1BalanceToUSD;

        LP0BalanceToUSD = IERC20(pool.token0()).balanceOf(address(pool)) * priceToken0USD / 10 ** 18;
        LP1BalanceToUSD = IERC20(pool.token1()).balanceOf(address(pool)) * priceToken1USD / 10 ** 18;
        return (LP0BalanceToUSD,LP1BalanceToUSD);
    }

    function overflowHandler(address poolAddr) public view returns (uint256,uint256){
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddr);
        (uint256 Q6496,,,,,,) = pool.slot0();
        uint8 token0Decimals = IERC20(pool.token0()).decimals();
        uint8 token1Decimals = IERC20(pool.token1()).decimals();
        uint256 priceToken0;
        uint256 priceToken1;
        uint256 k0;
        uint256 k1 = 10 ** 18;

        if(token0Decimals > token1Decimals){
            k0 = 10 ** (token0Decimals - token1Decimals);
        }
        else if(token1Decimals > token0Decimals){
            k0 = 10 ** (token1Decimals - token0Decimals);
        }
        else{
            k0 = 1;
        }
        if(Q6496 > 10 ** 38){
            priceToken0 = 0;
            priceToken0 = 1;
        }
        else if(Q6496 > 10 ** 33){
        priceToken0 = Q6496 ** 2 / 2 ** 192 * 10 ** 18 / k0;
        priceToken1 = 2 ** 192 * k1 / Q6496 ** 2 * k0;
        }
        else if(Q6496 > 10 ** 27){
        priceToken0 = Q6496 ** 2 * 10 ** 9 / 2 ** 192 * 10 ** 9 / k0;
        priceToken1 = 2 ** 192 * k1 / Q6496 **2 * k0;

        }
        else{
        priceToken0 = Q6496 ** 2 * k1 / 2 ** 192 * k0;
        priceToken1 = 2 ** 192 * k1 / k0 /  Q6496 ** 2;

        }

        if(Q6496 < 10 ** 14){
            priceToken0 = 0;
            priceToken1 = 0;
        }

        return(priceToken0,priceToken1);

    }

    function returnV3Prices(address poolAddr) public view returns (uint256,uint256,uint256,uint256,uint256,uint256){
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddr);
        uint256 priceToken0;
        uint256 priceToken1;
        uint256 priceToken0USD;
        uint256 priceToken1USD;
        uint256 LP0BalanceToUSD;
        uint256 LP1BalanceToUSD;

        (priceToken0,priceToken1) = overflowHandler(poolAddr);

        if(IERC20(pool.token1()).decimals() != 18){
            priceToken0USD = priceToken0 * getBasicPrice(pool.token1()) /10 ** 18;
            LP0BalanceToUSD = IERC20(pool.token0()).balanceOf(address(pool)) * priceToken0USD / 10 ** IERC20(pool.token0()).decimals();
        }
        else{
            priceToken0USD = priceToken0 * getBasicPrice(pool.token1()) / 10 ** (IERC20(commonTokens[1]).decimals());
            LP0BalanceToUSD = IERC20(pool.token0()).balanceOf(address(pool)) * priceToken0USD * 10 **(18 - IERC20(pool.token0()).decimals()) / 10 ** 18;
        }

        if(IERC20(pool.token0()).decimals() != 18){
            priceToken1USD = priceToken1 * getBasicPrice(pool.token0()) /10 ** 18;
            LP1BalanceToUSD = IERC20(pool.token1()).balanceOf(address(pool)) * priceToken1USD / 10 ** IERC20(pool.token1()).decimals();
        }
        else{
            priceToken1USD = priceToken1 * getBasicPrice(pool.token0()) /10 ** (IERC20(commonTokens[1]).decimals());
            LP1BalanceToUSD = IERC20(pool.token1()).balanceOf(address(pool)) * priceToken1USD * 10 **(18 - IERC20(pool.token1()).decimals()) / 10 ** 18;
        }

        return (priceToken0,priceToken1,priceToken0USD,priceToken1USD,LP0BalanceToUSD,LP1BalanceToUSD);
    }

    function getUSDPriceFromSpecificDEXV3(address tokenAddress, address factoryAddress) public view returns (uint256, uint256) {

        uint256 averagePrice;
        uint256 totalLiquidity;
        address pairAddress;
        IUniswapV3Factory factory = IUniswapV3Factory(factoryAddress);

        for (uint8 i = 0; i < commonTokens.length; i++) {
            for (uint8 j = 0; j < feesV3.length; j++){

                pairAddress = factory.getPool(tokenAddress,commonTokens[i], feesV3[j]);
            
                if (pairAddress != address(0)) {
                    IUniswapV3Pool pool = IUniswapV3Pool(pairAddress);
                    uint256 pairPrice;
                    address poolAddress = address(pool);
                    uint256 pairLiquidity;

                    if (tokenAddress == pool.token0() && IERC20(pool.token0()).balanceOf(poolAddress) > 15000000) {

                        (,,pairPrice,,,) = returnV3Prices(address(pool));
                        (,,,,,pairLiquidity) = returnV3Prices(address(pool));
                        totalLiquidity += pairLiquidity;

                    } else if (IERC20(pool.token1()).balanceOf(poolAddress) > 15000000) {

                        (,,,pairPrice,,) = returnV3Prices(address(pool));
                        (,,,,pairLiquidity,) = returnV3Prices(address(pool));
                        totalLiquidity += pairLiquidity;
                    }
                    else {

                        pairLiquidity = 0;

                    }

                    averagePrice += pairPrice * pairLiquidity;
                }
            }
        }

        if (totalLiquidity != 0) {
            return (averagePrice / totalLiquidity, totalLiquidity);
        } else {
            return (0, 0);
        }
    }


    function getUSDPriceFromSpecificDEX(
        address tokenAddress,
        address factoryAddress
    ) public view returns (uint256, uint256) {
        uint256 averagePrice;
        uint256 totalLiquidity;

        IUniswapV2Factory factory = IUniswapV2Factory(factoryAddress);

        for (uint8 i = 0; i < commonTokens.length; i++) {
            address pairAddress = factory.getPair(
                tokenAddress,
                commonTokens[i]
            );

            if (pairAddress != address(0)) {
                IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
                (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
                uint256 pairPrice;
                uint256 pairLiquidity;

                if (tokenAddress == pair.token0() && reserve0 != 0) {
                    //If the token is WBNB
                    if (i == 0) {
                        uint256 BNBUSDPrice = getBasicPrice(WBNB);
                        pairPrice = (BNBUSDPrice * reserve1) / reserve0;
                        pairLiquidity = (BNBUSDPrice * reserve1) / 10**18;
                        totalLiquidity += pairLiquidity;
                    } else {
                        uint256 vsTokenDecimals = IERC20(commonTokens[i])
                            .decimals();

                        if (vsTokenDecimals == 18) {
                            pairPrice = (reserve1 * 10**18) / reserve0;
                            pairLiquidity = reserve1;
                            totalLiquidity += pairLiquidity;
                        } else {
                            pairPrice =
                                (reserve1 *
                                    10**(18 - vsTokenDecimals) *
                                    10**18) /
                                reserve0;
                            pairLiquidity =
                                reserve1 *
                                10**(18 - vsTokenDecimals);
                            totalLiquidity += pairLiquidity;
                        }
                    }
                } else if (reserve1 != 0) {
                    //If the token is WBNB
                    if (i == 0) {
                        uint256 BNBUSDPrice = getBasicPrice(WBNB);
                        pairPrice = (BNBUSDPrice * reserve0) / reserve1;
                        pairLiquidity = (BNBUSDPrice * reserve0) / 10**18;
                        totalLiquidity += pairLiquidity;
                    } else {
                        uint256 vsTokenDecimals = IERC20(commonTokens[i])
                            .decimals();

                        if (vsTokenDecimals == 18) {
                            pairPrice = (reserve0 * 10**18) / reserve1;
                            pairLiquidity = reserve0;
                            totalLiquidity += pairLiquidity;
                        } else {
                            pairPrice =
                                (reserve0 *
                                    10**(18 - vsTokenDecimals) *
                                    10**18) /
                                reserve1;
                            pairLiquidity =
                                reserve0 *
                                10**(18 - vsTokenDecimals);
                            totalLiquidity += pairLiquidity;
                        }
                    }
                }

                averagePrice += pairPrice * pairLiquidity;
            }
        }

        if (totalLiquidity != 0) {
            return (averagePrice / totalLiquidity, totalLiquidity);
        } else {
            return (0, 0);
        }
    }

    function getGeneralUSDPrice(address tokenAddress)
        public
        view
        returns (uint256, uint256)
    {
        uint256 averagePrice;
        uint256 totalLiquidity;
        
        if(shouldCheckV1){

            for (uint256 i = 0; i < commonDEXesV1.length; i++) {
                (
                    uint256 dexPrice,
                    uint256 dexLiquidity
                ) = getUSDPriceFromSpecificDEXV1(tokenAddress, commonDEXesV1[i]);
                averagePrice += dexPrice * dexLiquidity;
                totalLiquidity += dexLiquidity;
            }
            
        }
        
        if(shouldCheckV2){

            for (uint256 i = 0; i < commonDEXes.length; i++) {
                (
                    uint256 dexPrice,
                    uint256 dexLiquidity
                ) = getUSDPriceFromSpecificDEX(tokenAddress, commonDEXes[i]);
                averagePrice += dexPrice * dexLiquidity;
                totalLiquidity += dexLiquidity;
                
            }

        }

        if(shouldCheckV3){

            for (uint256 i = 0; i < commonDEXesV3.length; i++) {
                (
                    uint256 dexPrice,
                    uint256 dexLiquidity
                ) = getUSDPriceFromSpecificDEXV3(tokenAddress, commonDEXesV3[i]);
                averagePrice += dexPrice * dexLiquidity;
                totalLiquidity += dexLiquidity;
            }

        }

        

        if (totalLiquidity != 0) {
            return (averagePrice / totalLiquidity, totalLiquidity);
        } else {
            return (0, 0);
        }
    }

    function getBasicPrice(address tokenAddress)
        public
        view
        returns (uint256 price)
    {
        IUniswapV2Factory factory = IUniswapV2Factory(commonDEXes[0]);
        if(tokenAddress == commonTokens[1]){
            tokenAddress = commonTokens[2];
        }
        IUniswapV2Pair pair = IUniswapV2Pair(
            factory.getPair(tokenAddress, commonTokens[1])
        );
        if(address(pair) != address(0)){
            (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();

            if (tokenAddress == pair.token0()) {
                return (reserve1 * 10**18) / reserve0;
            } else {
                return (reserve0 * 10**18) / reserve1;
            }
        }
        else{
            return 0;
        }
    }

    function getUSDPriceFromSpecificDEXUsingStable(
        address tokenAddress,
        address factoryAddress
    ) public view returns (uint256, uint256) {
        uint256 averagePrice;
        uint256 totalLiquidity;

        IUniswapV2Factory factory = IUniswapV2Factory(factoryAddress);

        for (uint8 i = 1; i < commonTokens.length; i++) {
            address pairAddress = factory.getPair(
                tokenAddress,
                commonTokens[i]
            );

            if (pairAddress != address(0)) {
                IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
                (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
                uint256 pairPrice;
                uint256 pairLiquidity;

                if (tokenAddress == pair.token0() && reserve0 != 0) {
                    uint256 vsTokenDecimals = IERC20(commonTokens[i])
                        .decimals();

                    if (vsTokenDecimals == 18) {
                        pairPrice = (reserve1 * 10**18) / reserve0;
                        pairLiquidity = reserve1;
                        totalLiquidity += pairLiquidity;
                    } else {
                        pairPrice =
                            (reserve1 * 10**(18 - vsTokenDecimals) * 10**18) /
                            reserve0;
                        pairLiquidity = reserve1 * 10**(18 - vsTokenDecimals);
                        totalLiquidity += pairLiquidity;
                    }
                } else if (reserve1 != 0) {
                    //If the token is WBNB

                    uint256 vsTokenDecimals = IERC20(commonTokens[i])
                        .decimals();

                    if (vsTokenDecimals == 18) {
                        pairPrice = (reserve0 * 10**18) / reserve1;
                        pairLiquidity = reserve0;
                        totalLiquidity += pairLiquidity;
                    } else {
                        pairPrice =
                            (reserve0 * 10**(18 - vsTokenDecimals) * 10**18) /
                            reserve1;
                        pairLiquidity = reserve0 * 10**(18 - vsTokenDecimals);
                        totalLiquidity += pairLiquidity;
                    }
                }

                averagePrice += pairPrice * pairLiquidity;
            }
        }

        if (totalLiquidity != 0) {
            return (averagePrice / totalLiquidity, totalLiquidity);
        } else {
            return (0, 0);
        }
    }
}