/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Owner {

    address private owner;

    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted. [email protected]
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
} 













// import web3 from "web3";
// import dotenv from 'dotenv';
// import { Interface } from '@ethersproject/abi';
// import fs from 'fs';
// import {tokenAbi} from '../Abi/token.js';
// import { factoryAbi } from '../Abi/Dex/factory.js';
// import { routerAbi } from '../Abi/Dex/router.js';
// import {multicallAbi} from '../Abi/Dex/multicall.js';
// dotenv.config();

// var BN = web3.utils.BN;

// const currentWeb3 = new web3(new web3.providers.HttpProvider(process.env.BSC_MAINNET_NODEREAL));

// const multicallAddress = "0xfF6FD90A470Aaa0c1B8A54681746b07AcdFedc9B";

// const wbnb = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";

// const pancakeRouter = "0x10ED43C718714eb63d5aA57B78B54704E256024E";

// const jetswapRouter = "0xBe65b8f75B9F20f4C522e0067a3887FADa714800";

// const apeswapRouter = "0xcF0feBd3f17CEf5b47b0cD257aCf6025c5BFf3b7";

// const babySwapRouter = "0x325E343f1dE602396E256B67eFd1F61C3A6B38Bd";
// const babySwapFactory = "0x86407bEa2078ea5f5EB5A52B2caA963bC1F889Da";

// const cheeseSwapRouter = "0x3047799262d8D2EF41eD2a222205968bC9B0d895";
// const cheeseSwapFactory = "0xdd538E4Fd1b69B7863E1F741213276A6Cf1EfB3B";

// const token_itf = new Interface(tokenAbi);
// const router_itf = new Interface(routerAbi);

// const multicall = new currentWeb3.eth.Contract(multicallAbi,multicallAddress);

// const multicallTrigger = async(calldata) => {
//     const { returnData } = await multicall.methods.aggregate(calldata).call();

//     return returnData;
// }

// const getAmountsOut = (encodeData) => {
//     let {amounts} = router_itf.decodeFunctionResult("getAmountsOut",encodeData);

//     return amounts;
// }


// const getFalshWatch = async(request) => { 
//     let calldataOne = [];

//     calldataOne[0] = { 
//         target: request.token_A, 
//         callData: token_itf.encodeFunctionData("symbol",[]) 
//     };

//     calldataOne[1] = { 
//         target: request.token_B, 
//         callData: token_itf.encodeFunctionData("symbol",[]) 
//     };

//     calldataOne[2] = { 
//         target: request.routerAddress_one, 
//         callData: router_itf.encodeFunctionData("getAmountsOut",[
//             request.amount,[request.token_A,request.token_B]]) 
//     };

//     calldataOne[3] = { 
//         target: request.routerAddress_two, 
//         callData: router_itf.encodeFunctionData("getAmountsOut",[
//             request.amount,[request.token_B,request.token_A]]) 
//     };

//     const returnData = await multicallTrigger(calldataOne);

//     const tokenASymbol = token_itf.decodeFunctionResult("symbol", returnData[0]);
//     const tokenBSymbol = token_itf.decodeFunctionResult("symbol", returnData[1]);
//     const amountOutOne = getAmountsOut(returnData[2]);
//     const amountOutTwo = getAmountsOut(returnData[3]);

//     console.log("amountOutOne", String(amountOutOne));

//     let calldataTwo = [];

//     calldataTwo[0] = { 
//         target: request.routerAddress_one, 
//         callData: router_itf.encodeFunctionData("getAmountsOut",[
//             amountOutOne[1],[request.token_A,request.token_B]]) 
//     };

//     calldataTwo[1] = { 
//         target: request.routerAddress_two, 
//         callData: router_itf.encodeFunctionData("getAmountsOut",[
//             amountOutTwo[1],[request.token_B,request.token_A]]) 
//     };


//     const returnDataTwo = await multicallTrigger(calldataTwo);

//     const amountOutThree = getAmountsOut(returnDataTwo[0]);
//     const amountOutFour = getAmountsOut(returnDataTwo[1]);

//     console.log(request.swap_one, tokenASymbol, tokenBSymbol, JSON.stringify({
//         "In": `${amountOutOne[0] / 1e18 }`,
//         "Out": `${amountOutOne[1] / 1e18 }`,
//     }));

//     console.log(request.swap_two, tokenBSymbol, tokenASymbol, {
//         "In": `${amountOutTwo[0] / 1e18 }`,
//         "Out": `${amountOutTwo[1] / 1e18 }`,
//     });

//     console.log(request.swap_two, tokenASymbol, tokenBSymbol, {
//         "In": `${amountOutThree[0] / 1e18 }`,
//         "Out": `${amountOutThree[1] / 1e18 }`,
//     });

//     console.log(request.swap_one, tokenBSymbol, tokenASymbol, {
//         "In": `${amountOutFour[0] / 1e18 }`,
//         "Out": `${amountOutFour[1] / 1e18 }`,
//     });
// }


// (async() => {  
//     const amountIn = 1e18;

//     const request = {
//         "routerAddress_one": pancakeRouter,
//         "routerAddress_two": jetswapRouter,
//         "token_A": wbnb,
//         "token_B": "0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3",
//         "amount": (new BN(amountIn.toString())).toString(),
//         "swap_one": "pancake-apeswap",
//         "swap_two": "apeswap-pancake"
//     }

//     await getFalshWatch(request);    
// })();