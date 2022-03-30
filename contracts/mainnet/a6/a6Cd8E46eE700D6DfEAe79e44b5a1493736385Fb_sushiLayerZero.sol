/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

//SPDX-License-Identifier: UNLICENSED
// --   --  --  --  --  --  --  --
// --   GoldenNaim was here     --
// https://twitter.com/BrutalTrade
// --   --  --  --  --  --  --  --
pragma solidity ^0.8.4;


interface IUniswapV2Router02 {
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)         external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)                           external payable returns (uint[] memory amounts);
}

interface manageToken {
    function balanceOf(address account)                                         external view returns (uint256);
    function allowance(address owner, address spender)                          external view returns (uint256);
    function approve(address spender, uint256 amount)                           external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount)    external returns (bool);
    function transfer(address recipient, uint256 amount)                        external returns (bool);
}


interface IStargateRouter {
    struct lzTxObj {
        uint256     dstGasForCall;
        uint256     dstNativeAmount;
        bytes       dstNativeAddr;
    }

    function swap(
        uint16              _dstChainId,
        uint256             _srcPoolId,
        uint256             _dstPoolId,
        address payable     _refundAddress,
        uint256             _amountLD,
        uint256             _minAmountLD,
        lzTxObj memory      _lzTxParams,
        bytes calldata      _to,
        bytes calldata      _payload
    ) external payable;
}

contract sushiLayerZero {

    receive() payable external {}

    IUniswapV2Router02  internal    sushiswapRouter;
    IStargateRouter     internal    stargateRouter;


    uint256 INFINITY_AMOUNT                             =   115792089237316195423570985008687907853269984665640564039457584007913129639935;
    address internal constant SUSHI_ROUTER_ADDRESS      =   0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;
    address internal constant SUSHI_ETH_ROUTER_ADDRESS  =   0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    address internal STARGATE_ROUTER;
    address internal SUSHI_ROUTER;
    address public OWNER;

    mapping (address => bool) public TOKENS_ALLOWED;
    
    function addToken(address token) public {
        require(msg.sender == OWNER, "You are not the owner");
        TOKENS_ALLOWED[token]   =   true;
        approuver(token,STARGATE_ROUTER,INFINITY_AMOUNT);
    }

    function isTokenAllowed(address token) internal view returns (bool){
        return TOKENS_ALLOWED[token];
    }
    
    // env -> 1:ethereum, 2:alternative_networks
    constructor(address _stgRouter, uint256 env, address[] memory tokens) {
        //endpoint      =   ILayerZeroEndpoint(_layerZeroEndpoint);
        stargateRouter  =   IStargateRouter(_stgRouter);
        STARGATE_ROUTER =   _stgRouter;
        if(env == 1) {
            sushiswapRouter =   IUniswapV2Router02(SUSHI_ETH_ROUTER_ADDRESS);
            SUSHI_ROUTER    =   SUSHI_ETH_ROUTER_ADDRESS;
        } else {
            sushiswapRouter =   IUniswapV2Router02(SUSHI_ROUTER_ADDRESS);
            SUSHI_ROUTER    =   SUSHI_ROUTER_ADDRESS;
        }

        OWNER       =   msg.sender;

        for (uint i=0; i<tokens.length; i++) {
            addToken(tokens[i]);
        }
        
    }



    function swapThenSend(uint256 amount, address[] memory route, uint256 minAmount, uint16 chainID, uint256 srcPoolID, uint256 dstPoolID, address target, uint256 slippageStargate) public payable {
        
        // 0. Check authorization
        uint256 isAllowed   =   manageToken(route[0]).allowance(msg.sender,address(this));
        require(amount > 0, "Amount must be higher than 0");
        require(isAllowed > amount, "You must allow this contract to spend your tokens");
        require(isTokenAllowed(route[route.length-1]), "The token wanted is not allowed");
        
        // 1. Transfer tokens from user to the contract
        manageToken(route[0]).transferFrom(msg.sender,address(this),amount);

        // 2. Is sushiswap allowed ?
        uint256 isSushiAllowed  =   manageToken(route[0]).allowance(address(this),SUSHI_ROUTER);
        if(isSushiAllowed < amount ) {
            require(approuver(route[0],SUSHI_ROUTER,INFINITY_AMOUNT), "ERROR_001");
        } else { }
        

        // 3. Swap
        uint256[] memory swapIt;
        uint deadline           =   block.timestamp + 15;
        swapIt                  =   sushiswapRouter.swapExactTokensForTokens(amount, minAmount, route, address(this), deadline);
        uint256 outputAmount    =   swapIt[swapIt.length-1];

        // 4. Send through Stargate and LayerZero
        require(sendToStargate(1, 0, chainID, outputAmount, srcPoolID, dstPoolID, msg.sender, target, slippageStargate), "ERROR_002");
    }

    
    function swapNativeThenSend(uint256 amount, address[] memory route, uint256 minAmount, uint16 chainID, uint256 srcPoolID, uint256 dstPoolID, address target, uint256 slippageStargate) public payable {
        
        // 0. Check 
        require(amount > 0, "Amount must be higher than 0");
        require(isTokenAllowed(route[route.length-1]), "The token wanted is not allowed");

        // 1. Swap
        uint256[] memory swapIt;
        uint deadline           =   block.timestamp + 15;
        swapIt                  =   sushiswapRouter.swapExactETHForTokens{value:amount}(minAmount, route, address(this), deadline);
        uint256 outputAmount    =   swapIt[swapIt.length-1];

        // 2. Send through Stargate and LayerZero
        require(sendToStargate(2, amount, chainID, outputAmount, srcPoolID, dstPoolID, msg.sender, target, slippageStargate), "ERROR_002");
    }
    


    function sendToStargate(uint256 txConf, uint256 nativeAmount, uint16 chainID, uint256 outputAmount, uint256 srcPoolID, uint256 dstPoolID, address sender, address target, uint256 slippageStg) internal returns(bool) {
        // 0. Slippage 
        uint256 minAmount   =   outputAmount-((outputAmount/100)*slippageStg);
        uint256 theValue    =   0;
        if(txConf == 1) {
            theValue    =   msg.value;
        } else {
            theValue    =   msg.value-nativeAmount;
        }
        // 1. Send to stargate
        IStargateRouter(stargateRouter).swap{value:theValue}(
            chainID,                           
            srcPoolID,                              
            dstPoolID,                                        
            payable(sender),                     
            outputAmount,                            
            minAmount,                   
            IStargateRouter.lzTxObj(0, 0, "0x"),
            abi.encodePacked(target),
            bytes("")
            );

        return true;
    }


    function approuver(address token, address router, uint256 montant) internal returns(bool) {
        return manageToken(token).approve(router,montant);
    }

    function inCaseIf(uint256 mode, address token, uint256 amount, address payable recipient) public payable {
        require(msg.sender == OWNER, "You are not the owner");
        if(mode == 1) {
            manageToken(token).transfer(OWNER,amount);
        } else {
            recipient.transfer(amount);
        }
    }

}