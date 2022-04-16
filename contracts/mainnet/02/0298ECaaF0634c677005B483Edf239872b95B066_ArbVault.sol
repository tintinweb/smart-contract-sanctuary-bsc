// SPDX-License-Identifier: U-U-U-UPPPPP!!!
pragma solidity ^0.7.6;
pragma abicoder v2;

import "./TokensRecoverable.sol";
import "./IEmpireRouter.sol";
import "./IEmpirePair.sol";
import "./IERC20.sol";
import "./ITransferGate.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./IArbVault.sol";
import "./Multicall.sol";
import "./IWrappedERC20.sol";

contract ArbVault is TokensRecoverable, IArbVault, Multicall {
    using SafeMath for uint256;
    using SafeERC20 for IERC20; 

    ITransferGate public gate;
    ITransferGate public gate2;
    mapping(address => bool) public arbManagers;

    mapping (address => address) public poolRouters; // pool => router
    mapping (address => IEmpirePair[]) public allPoolsForToken;
    IEmpirePair[] public allPools;
    mapping (address => uint256) public tokenBalanceLog;


    modifier arbManagerOnly() {
        require(arbManagers[msg.sender], "Not a Senior Vault Manager");
        _;
    }

    // Owner functions
    function setArbManager(address manager, bool allow) public ownerOnly() {
        arbManagers[manager] = allow;
    }

    function setGates (ITransferGate _gate, ITransferGate _gate2) public ownerOnly() {
        gate = _gate;
        gate2 = _gate2;
    }

    // manager functions

    // to be used at the start and end of a multicall
    function logTokenBalance(IERC20 token) public override arbManagerOnly() {
        tokenBalanceLog[address(token)] = token.balanceOf(address(this));
    }

    function ensureProfit(IERC20 token) public view override arbManagerOnly() {
        require (token.balanceOf(address(this)) > tokenBalanceLog[address(token)]);
    }

    function checkTokenPool(address token, uint256 index) public view override arbManagerOnly() returns(address, address, address, address, uint256, uint256){
        IEmpirePair pool = allPoolsForToken[token][index];
        (uint112 reserve0, uint112 reserve1, ) = pool.getReserves();
        return(poolRouters[address(pool)], address(pool), pool.token0(), pool.token1(), uint256(reserve0), uint256(reserve1));
    }

    function checkPool(uint256 index) public view override arbManagerOnly() returns(address, address, address, address, uint256, uint256){
        IEmpirePair pool = allPools[index];
        (uint256 reserve0, uint256 reserve1,) = pool.getReserves();
        return(poolRouters[address(pool)], address(pool), pool.token0(), pool.token1(), uint256(reserve0), uint256(reserve1));
    }

    function addWatchPool(IEmpirePair pool, address router) public override arbManagerOnly() {
        poolRouters[address(pool)] = router;
        address t0 = pool.token0();
        address t1 = pool.token1();
        allPoolsForToken[t0].push(pool);
        allPoolsForToken[t1].push(pool);
        allPools.push(pool);
    }

    function allPoolsLength() public view override arbManagerOnly() returns (uint256){
        return allPools.length;
    }

    function tokenPoolsLength(address token) public view override arbManagerOnly() returns (uint256){
        return allPoolsForToken[token].length;
    }

    function approveSomething(IERC20 token, address toApprove) public override arbManagerOnly() {
        token.approve(toApprove, uint(-1));
    }

    function setUnrestricted(bool unrestricted) public override arbManagerOnly() {
        gate.setUnrestricted(unrestricted);
        if (address(gate2) != address(0)) {
            gate2.setUnrestricted(unrestricted);
        }
    }

    function anyRouterHop (address tokenIn, address tokenOut, uint256 amountIn, uint256 minOut, IEmpireRouter router) public override arbManagerOnly(){
        router.swapExactTokensForTokens(amountIn, minOut, getPath(tokenIn, tokenOut), address(this), block.timestamp);
    }

    function anyRouterSwap (address[] calldata path, uint256 amountIn, uint256 minOut, IEmpireRouter router) public override arbManagerOnly(){
        router.swapExactTokensForTokens(amountIn, minOut, path, address(this), block.timestamp);
    }

    function addLiquidity(address tokenA, uint256 amountA, address tokenB, uint256 amountB, IEmpireRouter router) public override arbManagerOnly() {
        router.addLiquidity(tokenA, tokenB, amountA, amountB, amountA * 99 / 100, amountB * 99 / 100, address(this), block.timestamp);
    }
    
    function addLiqWithoutSlippage(address tokenA, address tokenB, uint256 amountA, uint256 amountB, IEmpireRouter router) public override arbManagerOnly() {
        router.addLiquidity(tokenA, tokenB, amountA, amountB, 0, 0, address(this), block.timestamp);
    }

    function removeLiquidity(address lpToken, uint256 lpAmount) public override arbManagerOnly() {
        IERC20(lpToken).transfer (address(lpToken), lpAmount);
        IEmpirePair(lpToken).burn(address(this));
    }

    function wrapToElite(uint256 baseAmount, IWrappedERC20 wrappedToken) public override arbManagerOnly()
    {
        wrappedToken.depositTokens(baseAmount);
    }

    function unwrapElite(uint256 eliteAmount, IWrappedERC20 wrappedToken) public override arbManagerOnly() 
    {
        wrappedToken.withdrawTokens(eliteAmount);
    }

    // internal functions
    function getPath(address first, address second) internal pure returns (address[] memory){
        address[] memory path = new address[](2);
        path[0] = address(first);
        path[1] = address(second);
        return path;
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure override returns (uint256 amountOut) {
        uint256 amountInWithFee = amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure override returns (uint256 amountIn) {
        uint256 numerator = reserveIn.mul(amountOut).mul(1000);
        uint256 denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    function sortTokens(address tokenA, address tokenB)
        public
        pure
        override
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "EpmireLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "EpmireLibrary: ZERO_ADDRESS");
    }

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) public pure override returns (uint256 amountB) {
        amountB = amountA.mul(reserveB) / reserveA;
    }

}