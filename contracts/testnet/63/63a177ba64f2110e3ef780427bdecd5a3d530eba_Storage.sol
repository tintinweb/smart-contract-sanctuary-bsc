/**
 *Submitted for verification at BscScan.com on 2022-09-02
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
//   approve,
//   setAuthority,
//   createMint, 
//   transfer,
//   createAccount,
//   AuthorityType,
//   TOKEN_PROGRAM_ID, 
//   ASSOCIATED_TOKEN_PROGRAM_ID,
//   mintTo,
//   getOrCreateAssociatedTokenAccount,
//   getAssociatedTokenAddress,
//   createMintToInstruction,
//   closeAccount,
//   thawAccount,
//   burn,
//   revoke,
//   freezeAccount
// } from "@solana/spl-token";
// import { PublicKey,Keypair, Connection } from '@solana/web3.js';
// import {AccountStore} from '../config/wallet';
// import { expect } from "chai";
// import  assert from "assert";

// describe("mocktoken", () => {
//   const provider = anchor.AnchorProvider.env();
//   anchor.setProvider(provider);
//   const program = anchor.workspace.Mocktoken as Program<Mocktoken>;

//   let mintKey: PublicKey;
//   let mintAuthority: Keypair;
//   let freezeAuthority: Keypair;

//   let accounts: Keypair[] = new Array(10);

//   it("Create Token!", async () => {
//     accounts = await AccountStore();
//     await multiAirDrop(accounts,100e6);
//     mintAuthority = accounts[5];
//     freezeAuthority = accounts[1];

//     mintKey = await createToken(
//                   mintAuthority,
//                   mintAuthority.publicKey,
//                   freezeAuthority.publicKey
//               );
//     const mint_info = await getMint(provider.connection,mintKey);
//     expect(mint_info.mintAuthority.toBase58()).equal(mintAuthority.publicKey.toBase58());
//     expect(mint_info.freezeAuthority.toBase58()).equal(freezeAuthority.publicKey.toBase58());
//     expect(mint_info.decimals).equal(9);
//     expect(Number(mint_info.supply)).equal(0);
//     expect(mint_info.isInitialized).equal(true);
//   });

//   it("Mint-1.0", async () => {
//     let user = accounts[3];
//     let tokenQuantity = 10e9;

//     let getUserAssociatedAccount = await getOrCreateAssociatedTokenAccount(provider.connection,user,mintKey,user.publicKey);

//     expect(getUserAssociatedAccount.mint.toBase58()).equal(mintKey.toBase58());
//     expect(getUserAssociatedAccount.owner.toBase58()).equal(user.publicKey.toBase58());
//     expect(Number(getUserAssociatedAccount.amount)).equal(0);

//     await mintTo(
//         provider.connection,
//         mintAuthority,
//         mintKey,            
//         getUserAssociatedAccount.address,
//         mintAuthority.publicKey,
//         tokenQuantity
//     );

//     const userTokenBalance = await provider.connection.getTokenAccountBalance(getUserAssociatedAccount.address);
//     const tokenSupply = await provider.connection.getTokenSupply(mintKey);
//     expect(Number(userTokenBalance.value.amount)).equal(10e9);
//     expect(Number(tokenSupply.value.amount)).equal(10e9);
//   });

//   it("Mint-2.0", async () => {
//     let user = accounts[4];
//     let tokenQuantity = 10e9;

//     let getUserAssociatedAccount = await getOrCreateAssociatedTokenAccount(provider.connection,user,mintKey,user.publicKey);

//     expect(getUserAssociatedAccount.mint.toBase58()).equal(mintKey.toBase58());
//     expect(getUserAssociatedAccount.owner.toBase58()).equal(user.publicKey.toBase58());
//     expect(Number(getUserAssociatedAccount.amount)).equal(0);

//     await mintTo(
//         provider.connection,
//         mintAuthority,
//         mintKey,            
//         getUserAssociatedAccount.address,
//         mintAuthority.publicKey,
//         tokenQuantity
//     );

//     const userTokenBalance = await provider.connection.getTokenAccountBalance(getUserAssociatedAccount.address);
//     const tokenSupply = await provider.connection.getTokenSupply(mintKey);
//     expect(Number(userTokenBalance.value.amount)).equal(10e9);
//     expect(Number(tokenSupply.value.amount)).equal(20e9);
//   });

//   it("Mint-Authority Revert", async () => {
//     let user = accounts[4];
//     let minter = accounts[1];
//     let tokenQuantity = 10e9;

//     let getUserAssociatedAccount = await getOrCreateAssociatedTokenAccount(provider.connection,user,mintKey,user.publicKey);

//     try {
//       await mintTo(
//         provider.connection,
//         minter,
//         mintKey,            
//         getUserAssociatedAccount.address,
//         minter.publicKey,
//         tokenQuantity
//       );
//       assert.fail();
//     } catch (err) {}
//   });

//   it("Set-Mint-Authority", async () => {
//     let currentMinter = mintAuthority;
//     let newMinter = accounts[0];

//     const before_minter = (await getMint(provider.connection,mintKey)).mintAuthority;
//     expect(before_minter.toBase58()).equal(mintAuthority.publicKey.toBase58());

//     await setAuthority(
//         provider.connection,
//         currentMinter,  // signer
//         mintKey,
//         currentMinter.publicKey,
//         AuthorityType.MintTokens,
//         newMinter.publicKey
//     );

//     const after_minter = (await getMint(provider.connection,mintKey)).mintAuthority;
//     expect(after_minter.toBase58()).equal(newMinter.publicKey.toBase58());
//   });

//   it("Mint-3.0", async () => {
//     let user = accounts[4];
//     let tokenQuantity = 10e9;
//     let newMinter = accounts[0];

//     let getUserAssociatedAccount = await getOrCreateAssociatedTokenAccount(provider.connection,user,mintKey,user.publicKey);

//     expect(getUserAssociatedAccount.mint.toBase58()).equal(mintKey.toBase58());
//     expect(getUserAssociatedAccount.owner.toBase58()).equal(user.publicKey.toBase58());

//     await mintTo(
//         provider.connection,
//         newMinter,
//         mintKey,            
//         getUserAssociatedAccount.address,
//         newMinter.publicKey,
//         tokenQuantity
//     );

//     const userTokenBalance = await provider.connection.getTokenAccountBalance(getUserAssociatedAccount.address);
//     const tokenSupply = await provider.connection.getTokenSupply(mintKey);
//     expect(Number(userTokenBalance.value.amount)).equal(20e9);
//     expect(Number(tokenSupply.value.amount)).equal(30e9);

//     mintAuthority = newMinter;
//   });


//   it("Approve-Test-1.0", async () => {
//     let user = accounts[3];
//     let receiver = accounts[5];
//     let tokenQuantity = 5e9;

//     let getUserAssociatedAccount = await getOrCreateAssociatedTokenAccount(provider.connection,user,mintKey,user.publicKey);
//     let getReceiverAssociatedAccount = await getOrCreateAssociatedTokenAccount(provider.connection,receiver,mintKey,receiver.publicKey);
//     let beforeTokenInfo = await getAccount(provider.connection,getUserAssociatedAccount.address);

//     expect(beforeTokenInfo.delegate).equal(null);
//     expect(Number(beforeTokenInfo.delegatedAmount)).equal(0);

//     await approve(
//         provider.connection,
//         user,
//         getUserAssociatedAccount.address,            
//         receiver.publicKey,
//         user.publicKey,
//         tokenQuantity
//     );

//     let afterTokenInfo = await getAccount(provider.connection,getUserAssociatedAccount.address);
//     expect(afterTokenInfo.delegate.toBase58()).equal(receiver.publicKey.toBase58());
//     expect(Number(afterTokenInfo.delegatedAmount)).equal(tokenQuantity);
//   });

//   it("Delegate-Transfer-1.0", async () => {
//     let user = accounts[3];
//     let delegate = accounts[5];
//     let tokenQuantity = 5e9;

//     let getUserAssociatedAccount = await getAssociatedTokenAddress(mintKey,user.publicKey);
//     let getDelegateAssociatedAccount = await getAssociatedTokenAddress(mintKey,delegate.publicKey); 
//     let beforeUserTokenInfo = await getAccount(provider.connection,getUserAssociatedAccount);
//     let beforeDelegateTokenInfo = await getAccount(provider.connection,getDelegateAssociatedAccount);

//     expect(beforeUserTokenInfo.delegate.toBase58()).equal(delegate.publicKey.toBase58());
//     expect(Number(beforeUserTokenInfo.delegatedAmount)).equal(tokenQuantity);
//     expect(Number(beforeUserTokenInfo.amount)).equal(10e9);
//     expect(Number(beforeDelegateTokenInfo.amount)).equal(0);
    
//     try{
//       await transfer(
//           provider.connection,
//           delegate,
//           getUserAssociatedAccount,
//           getDelegateAssociatedAccount,
//           delegate.publicKey,
//           tokenQuantity
//       );
//     } catch (err) { console.log("err", err) }

//     let afterUserTokenInfo = await getAccount(provider.connection,getUserAssociatedAccount);
//     let afterDelegateTokenInfo = await getAccount(provider.connection,getDelegateAssociatedAccount);

//     expect(Number(afterUserTokenInfo.amount)).equal(5e9);
//     expect(Number(afterDelegateTokenInfo.amount)).equal(5e9);
//     expect(Number(afterDelegateTokenInfo.delegatedAmount)).equal(0);
//     expect(afterDelegateTokenInfo.delegate).equal(null);
//   });

//   it("Transfer-1.0", async () => {
//     let sender = accounts[4];
//     let receiver = accounts[6];
//     let tokenQuantity = 5e9;

//     let getSenderAssociatedAccount = await getAssociatedTokenAddress(mintKey,sender.publicKey);
//     let getReceiverAssociatedAccount = (await getOrCreateAssociatedTokenAccount(provider.connection,receiver,mintKey,receiver.publicKey)).address;
//     let beforeSenderTokenInfo = await getAccount(provider.connection,getSenderAssociatedAccount);
//     let beforeReceiverTokenInfo = await getAccount(provider.connection,getReceiverAssociatedAccount);

//     expect(Number(beforeSenderTokenInfo.amount)).equal(20e9);
//     expect(Number(beforeReceiverTokenInfo.amount)).equal(0);

//     await transfer(
//         provider.connection,
//         sender,
//         getSenderAssociatedAccount,
//         getReceiverAssociatedAccount,
//         sender.publicKey,
//         tokenQuantity
//     );

//     let afterSenderTokenInfo = await getAccount(provider.connection,getSenderAssociatedAccount);
//     let afterReceiverTokenInfo = await getAccount(provider.connection,getReceiverAssociatedAccount);

//     expect(Number(afterSenderTokenInfo.amount)).equal(15e9);
//     expect(Number(afterReceiverTokenInfo.amount)).equal(5e9);
//   });


//   it("Burn", async () => {
//     let user = accounts[4];
//     let tokenQuantity = 5e9;

//     let getSenderAssociatedAccount = await getAssociatedTokenAddress(mintKey,user.publicKey);
//     let beforeSenderTokenInfo = await getAccount(provider.connection,getSenderAssociatedAccount);    
//     expect(Number(beforeSenderTokenInfo.amount)).equal(15e9);

//     await burn(
//         provider.connection,
//         user,
//         getSenderAssociatedAccount,
//         mintKey,
//         user.publicKey,
//         tokenQuantity
//     );

//     let afterSenderTokenInfo = await getAccount(provider.connection,getSenderAssociatedAccount);
//     expect(Number(afterSenderTokenInfo.amount)).equal(10e9);
//   });

//   it("Approve & Revoke - Test", async () => {
//     const user = accounts[3];
//     const delegete = accounts[5];
//     const tokenQuantity = 500e9;

//     const getUserAssociatedAccount = await getOrCreateAssociatedTokenAccount(provider.connection,user,mintKey,user.publicKey);
//     const getDelegeteAssociatedAccount = await getOrCreateAssociatedTokenAccount(provider.connection,delegete,mintKey,delegete.publicKey);
//     const beforeTokenInfo = await getAccount(provider.connection,getUserAssociatedAccount.address);

//     expect(beforeTokenInfo.delegate).equal(null);
//     expect(Number(beforeTokenInfo.delegatedAmount)).equal(0);

//     await approve(
//         provider.connection,
//         user,
//         getUserAssociatedAccount.address,            
//         delegete.publicKey,
//         user.publicKey,
//         tokenQuantity
//     );

//     const afterTokenInfo = await getAccount(provider.connection,getUserAssociatedAccount.address);
//     expect(afterTokenInfo.delegate.toBase58()).equal(delegete.publicKey.toBase58());
//     expect(Number(afterTokenInfo.delegatedAmount)).equal(tokenQuantity);


//     await revoke(
//       provider.connection,
//       user,
//       getUserAssociatedAccount.address,    
//       user.publicKey
//     )

//     const afterRevokeTokenInfo = await getAccount(provider.connection,getUserAssociatedAccount.address);
//     expect(Number(afterRevokeTokenInfo.delegatedAmount)).equal(0);
//     expect(afterRevokeTokenInfo.delegate).equal(null);
//   });

//   it("Set-Freeze-Authority", async () => {
//     let currentAuthority = freezeAuthority;
//     let newFreezeAuthority = accounts[0];

//     const before_freezer = (await getMint(provider.connection,mintKey)).freezeAuthority;
//     expect(before_freezer.toBase58()).equal(freezeAuthority.publicKey.toBase58());  

//     await setAuthority(
//         provider.connection,
//         currentAuthority,  // signer
//         mintKey,
//         currentAuthority.publicKey,
//         AuthorityType.FreezeAccount,
//         newFreezeAuthority.publicKey
//     );

//     const after_freezer = (await getMint(provider.connection,mintKey)).freezeAuthority;
//     expect(after_freezer.toBase58()).equal(newFreezeAuthority.publicKey.toBase58());    
//   });


//   it("Transfer-Before-Freeze", async () => {
//     let sender = accounts[4];
//     let receiver = accounts[6];
//     let tokenQuantity = 5e9;

//     let getSenderAssociatedAccount = await getAssociatedTokenAddress(mintKey,sender.publicKey);
//     let getReceiverAssociatedAccount = (await getOrCreateAssociatedTokenAccount(provider.connection,receiver,mintKey,receiver.publicKey)).address;
//     let beforeSenderTokenInfo = await getAccount(provider.connection,getSenderAssociatedAccount);
//     let beforeReceiverTokenInfo = await getAccount(provider.connection,getReceiverAssociatedAccount);

//     expect(Number(beforeSenderTokenInfo.amount)).equal(10e9);
//     expect(Number(beforeReceiverTokenInfo.amount)).equal(5e9);

//     await transfer(
//         provider.connection,
//         sender,
//         getSenderAssociatedAccount,
//         getReceiverAssociatedAccount,
//         sender.publicKey,
//         tokenQuantity
//     );

//     let afterSenderTokenInfo = await getAccount(provider.connection,getSenderAssociatedAccount);
//     let afterReceiverTokenInfo = await getAccount(provider.connection,getReceiverAssociatedAccount);

//     expect(Number(afterSenderTokenInfo.amount)).equal(5e9);
//     expect(Number(afterReceiverTokenInfo.amount)).equal(10e9);
//   });

//   it("Freeze", async () => {
//     let user = accounts[6];
//     let tokenQuantity = 5e9;
//     let newFreezeAuthority = accounts[0];

//     let getSenderAssociatedAccount = await getAssociatedTokenAddress(mintKey,user.publicKey);
//     let beforeSenderTokenInfo = await getAccount(provider.connection,getSenderAssociatedAccount); 
//     expect(beforeSenderTokenInfo.isFrozen).equal(false);

//     await freezeAccount(
//         provider.connection,
//         newFreezeAuthority,
//         getSenderAssociatedAccount,
//         mintKey,
//         newFreezeAuthority.publicKey,
//     );

//     let afterSenderTokenInfo = await getAccount(provider.connection,getSenderAssociatedAccount); 
//     expect(afterSenderTokenInfo.isFrozen).equal(true);
//     freezeAuthority = newFreezeAuthority;
//   });

//   it("Transfer-After-Freeze", async () => {
//     let sender = accounts[6];
//     let receiver = accounts[4];
//     let tokenQuantity = 5e9;

//     let getSenderAssociatedAccount = await getAssociatedTokenAddress(mintKey,sender.publicKey);
//     let getReceiverAssociatedAccount = (await getOrCreateAssociatedTokenAccount(provider.connection,receiver,mintKey,receiver.publicKey)).address;
//     let beforeSenderTokenInfo = await getAccount(provider.connection,getSenderAssociatedAccount);
//     let beforeReceiverTokenInfo = await getAccount(provider.connection,getReceiverAssociatedAccount); 

//     expect(Number(beforeSenderTokenInfo.amount)).equal(10e9);
//     expect(Number(beforeReceiverTokenInfo.amount)).equal(5e9);

//     try {
//       await transfer(
//           provider.connection,
//           sender,
//           getSenderAssociatedAccount,
//           getReceiverAssociatedAccount,
//           sender.publicKey,
//           tokenQuantity
//       );
//     } catch (err) { 
//       // console.log("err", err);
//     }

//     let afterSenderTokenInfo = await getAccount(provider.connection,getSenderAssociatedAccount);
//     let afterReceiverTokenInfo = await getAccount(provider.connection,getReceiverAssociatedAccount);

//     expect(Number(afterSenderTokenInfo.amount)).equal(10e9);
//     expect(Number(afterReceiverTokenInfo.amount)).equal(5e9);
//   });

//   it("ThawAccount", async () => {
//     let user = accounts[6];
//     let tokenQuantity = 5e9;

//     let getSenderAssociatedAccount = await getAssociatedTokenAddress(mintKey,user.publicKey);
//     let beforeSenderTokenInfo = await getAccount(provider.connection,getSenderAssociatedAccount);  
//     expect(beforeSenderTokenInfo.isFrozen).equal(true);
    
//     await thawAccount(
//         provider.connection,
//         freezeAuthority,
//         getSenderAssociatedAccount,
//         mintKey,
//         freezeAuthority.publicKey,
//     );

//     let afterSenderTokenInfo = await getAccount(provider.connection,getSenderAssociatedAccount); 
//     expect(afterSenderTokenInfo.isFrozen).equal(false);     
//   });

//   it("Transfer-After-Thaw", async () => {
//     let sender = accounts[6];
//     let receiver = accounts[4];
//     let tokenQuantity = 5e9;

//     let getSenderAssociatedAccount = await getAssociatedTokenAddress(mintKey,sender.publicKey);
//     let getReceiverAssociatedAccount = (await getOrCreateAssociatedTokenAccount(provider.connection,receiver,mintKey,receiver.publicKey)).address;
//     let beforeSenderTokenInfo = await getAccount(provider.connection,getSenderAssociatedAccount);
//     let beforeReceiverTokenInfo = await getAccount(provider.connection,getReceiverAssociatedAccount);

//     expect(Number(beforeSenderTokenInfo.amount)).equal(10e9);
//     expect(Number(beforeReceiverTokenInfo.amount)).equal(5e9);

//     try {
//       await transfer(
//           provider.connection,
//           sender,
//           getSenderAssociatedAccount,
//           getReceiverAssociatedAccount,
//           sender.publicKey,
//           tokenQuantity
//       );
//     } catch (err) { 
//       // console.log("err", err);
//     }

//     let afterSenderTokenInfo = await getAccount(provider.connection,getSenderAssociatedAccount);
//     let afterReceiverTokenInfo = await getAccount(provider.connection,getReceiverAssociatedAccount);

//     expect(Number(afterSenderTokenInfo.amount)).equal(5e9);
//     expect(Number(afterReceiverTokenInfo.amount)).equal(10e9);
//   });

//   it("Set-CloseAccount-Authority-ForUser", async () => {
//     let user = accounts[3];
//     let closeAccount = accounts[4];

//     let getUserAssociatedAccount = await getAssociatedTokenAddress(mintKey,user.publicKey);
//     let getCloserAssociatedAccount = await getAssociatedTokenAddress(mintKey,closeAccount.publicKey);
//     let beforeUserTokenInfo = await getAccount(provider.connection,getUserAssociatedAccount);
//     let beforeCloserTokenInfo = await getAccount(provider.connection,getCloserAssociatedAccount);

//     expect(Number(beforeUserTokenInfo.amount)).equal(5e9);
//     expect(Number(beforeCloserTokenInfo.amount)).equal(10e9);
//     expect(beforeUserTokenInfo.closeAuthority).equal(null); 

//     try {
//       await setAuthority(
//           provider.connection,
//           user,  // signer
//           getUserAssociatedAccount,
//           user.publicKey,
//           AuthorityType.CloseAccount,
//           closeAccount.publicKey
//       );
//     }catch (err) { console.log("err", err); }

//     let afterUserTokenInfo = await getAccount(provider.connection,getUserAssociatedAccount);
//     let afterCloserTokenInfo = await getAccount(provider.connection,getCloserAssociatedAccount);

//     expect(afterUserTokenInfo.closeAuthority.toBase58()).equal(closeAccount.publicKey.toBase58());
//     console.log("afterUserTokenInfo", afterUserTokenInfo);

//     let info = await provider.connection.getAccountInfo(getUserAssociatedAccount);
//     console.log("info", info.lamports);
    

//     // const after_minter = (await getMint(provider.connection,mintKey)).mintAuthority;
//     // expect(after_minter.toBase58()).equal(newMinter.publicKey.toBase58());
//   });


//   // "case hundred pause chest goat review grunt obey business concert upon whip"











//   async function createToken(wallet: Keypair,authority: PublicKey,fauthority: PublicKey) {
//     const mint = await createMint(
//       provider.connection,
//       wallet,          // payer
//       authority,       // mintAuthority
//       fauthority,      // freezeAuthority  
//       9                // decimals
//     );
//     return mint;
//   }

//   async function tokenAccountInfo(args:PublicKey){
//       return await getAccount(provider.connection,args);
//   }

//   async function getTokenBalance(account) {
//     let currBal = await provider.connection.getTokenAccountBalance(account);
//     return (currBal.value.amount);
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
//     }
//   }

// });