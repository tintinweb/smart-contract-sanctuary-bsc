/**
 *Submitted for verification at BscScan.com on 2022-09-01
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


// import * as anchor from "@project-serum/anchor";
// import { Program } from "@project-serum/anchor";
// import { Mocktoken } from "../target/types/mocktoken";
// import {
//   getAccount,
//   getMint,
//   createMint, 
//   TOKEN_PROGRAM_ID, 
//   ASSOCIATED_TOKEN_PROGRAM_ID,
//   mintTo,
//   getOrCreateAssociatedTokenAccount,
//   getAssociatedTokenAddress 
// } from "@solana/spl-token";
// import { PublicKey,Keypair, Connection } from '@solana/web3.js';

// describe("mocktoken", () => {

//   const provider = anchor.AnchorProvider.env();
//   // Configure the client to use the local cluster.
//   anchor.setProvider(provider);
//   const program = anchor.workspace.Mocktoken as Program<Mocktoken>;

//   //let token: PublicKey;
//   let mintAuthority: Keypair;
//   let freezeAuthority: Keypair;
//   let user_one: Keypair;
//   let user_two: Keypair;
//   let user_three: Keypair;
//   let user_four: Keypair;

//   it("Set-Up!", async () => {
//     mintAuthority = await anchor.web3.Keypair.generate();
//     freezeAuthority = await anchor.web3.Keypair.generate();
//     user_one = await anchor.web3.Keypair.generate();
//     user_two = await anchor.web3.Keypair.generate();
//     user_three = await anchor.web3.Keypair.generate();
//     user_four = await anchor.web3.Keypair.generate();
//     await multiAirDrop([mintAuthority,freezeAuthority,user_one,user_two,user_three,user_four],100e6);

//     let token = await createToken(
//             mintAuthority,
//             mintAuthority.publicKey,
//             freezeAuthority.publicKey
//           );
//     console.log("token", token.toBase58());

//     let res = await getTokenInfo(token);
//     console.log("Token Info", res.owner.toBase58());

//     // let getInfo = await getMintInfo(token);

//     // console.log("getInfo", getInfo);

//     // console.log("mintAuthority Info", await getTokenInfo(mintAuthority.publicKey));

//   });

//   // it("Mint!", async () => {
//   //   token = await createToken(mintAuthority);
//   //   console.log("token", token.toBase58());
//   // });








//   async function createToken(wallet: Keypair,authority: PublicKey,fauthority: PublicKey) {
//     const mint = await createMint(
//       provider.connection,
//       wallet,                 // payer
//       authority,       // mintAuthority
//       fauthority,       // freezeAuthority  
//       9                       // decimals
//     );
//     return mint;
//   }


//   // async function mint(userWallet,userAssociateWallet,supply) {
//   //   let signature = await mintTo(
//   //     provider.connection,
//   //     userWallet,
//   //     tokenAddress,             //changes(mint)
//   //     userAssociateWallet,
//   //     userWallet.publicKey,
//   //     new anchor.BN(supply)
//   // );
//   // //console.log('mint tx:', signature);
//   // }


//   async function getTokenInfo(account:PublicKey) {
//       return provider.connection.getAccountInfo(account);
//   }

//   async function getMintInfo(account:PublicKey) {
//     return await getMint(provider.connection,account);
//   }


//   async function airDrop(account,amount) {
//     await provider.connection.confirmTransaction(
//         await provider.connection.requestAirdrop(account,amount),
//         "confirmed"
//     );
//   } 

//   async function multiAirDrop(account: Keypair[],amount: number) {
//     for(let i=0; i<account.length;i++) {
//       await provider.connection.confirmTransaction(
//         await provider.connection.requestAirdrop(account[i].publicKey,amount),
//         "confirmed"
//       );
//       //console.log("user balance", i+1, Number(await getBalance(account[i].publicKey)/1e9));
//     }
//   }


// });