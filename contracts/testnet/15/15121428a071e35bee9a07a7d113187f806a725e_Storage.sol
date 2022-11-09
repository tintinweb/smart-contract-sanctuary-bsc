/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Storage {

    uint256 number;

    /**
     * @dev Store value in variable
     * @param num value to store
     */
    function store(uint256 num) public {
        number = num;
    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve() public view returns (uint256){
        return number;
    }
}











// import web3 from 'web3';
// import dotenv from 'dotenv';
// import {tokenAbi} from '../Abi/token.js';
// dotenv.config();

// const currentweb3 = new web3(new web3.providers.HttpProvider("https://eth-goerli.g.alchemy.com/v2/hK0QyUbTWqDAbUe8lYz4-ycC94DoQD9B"));
// const privateKey = process.env.ADMIN_KEY_17; 
// const {address:admin} = await currentweb3.eth.accounts.privateKeyToAccount(privateKey);

// const tokenAddress = "0xa14224829Eb8625b331E654A481a947afdbe06F7";
// const token = new currentweb3.eth.Contract(tokenAbi, tokenAddress);

// const receiver = "0x98396fF397f78350BD40Ee70972B47A929E5CFE7";
// const amount = "100000000000";

// (async() => {
//     await currentweb3.eth.accounts.wallet.add(privateKey);

//     console.log("admin",admin);

//     const balance  = await token.methods.balanceOf(admin).call();
//     console.log("balance", balance);

//     const expectGas = await token.methods.transfer(receiver,amount).estimateGas({from: admin});
//     const tx = await token.methods.transfer(receiver,amount).send({from: admin,gas: expectGas});
//     console.log("transaction hash",`https://goerli.etherscan.io/tx/${tx.transactionHash}`);
// })();