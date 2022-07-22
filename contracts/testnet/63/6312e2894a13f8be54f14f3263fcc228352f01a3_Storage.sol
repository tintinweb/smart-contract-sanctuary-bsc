/**
 *Submitted for verification at BscScan.com on 2022-07-21
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

    bytes32 public constant SIGNATURE_PERMIT_TYPEHASH = keccak256("Permit(address user,uint256 value,uint256 nonce,uint256 deadline)");

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
    function retrieve() public pure returns (uint256){
        return type(uint256).max;
    }
}


// lib 

// use anchor_lang::prelude::*;
// use anchor_spl::token::{self, Burn, CloseAccount, MintTo, Transfer};
// use anchor_spl::token::transfer;
// use crate:: { error:: ErrorCode};
// use context::*;
// use account::{SaleInfo};

// mod error;
// mod account;
// mod context;

// declare_id!("2BFtKHsXGCmeBWcHJPP2etoMTaXkzGW2MKxPQQPMN6bX");

// #[program]
// pub mod presale {
//     use super::*;

//     pub fn create_sale(
//         ctx: Context<CreateSale>, 
//         owner: Pubkey,
//         content: String, 
//         sale_quantity: u64,  
//         start_time: u64,
//         end_time: u64,
//         sale_price: u64,
//         minimum_deposit_sol: u64,
//         maximum_deposit_sol: u64,
//     ) -> Result<()> {
//         let deposit_info = &mut ctx.accounts.deposit_info;

//         require!(owner == ctx.accounts.caller.key(), ErrorCode::OnlyOwner);
//         deposit_info.owner = ctx.accounts.caller.key();
//         deposit_info.content = content;
//         deposit_info.is_sale = true;
//         deposit_info.sale_quantity = sale_quantity;
//         deposit_info.start_time = start_time;
//         deposit_info.end_time = end_time;
//         deposit_info.sale_price = sale_price;
//         deposit_info.minimum_deposit_sol = minimum_deposit_sol;
//         deposit_info.maximum_deposit_sol = maximum_deposit_sol;
//         deposit_info.bump = *ctx.bumps.get("deposit_info").unwrap();
//         Ok(())
//     }

//     pub fn token_deposit(
//         ctx: Context<DepositToken>,
//         deposit_amount: u64
//     ) -> Result<()> {

//         let cpi_accounts = Transfer {
//             from: ctx.accounts.buyer_token_account.to_account_info(),
//             to: ctx.accounts.pda_token_account.to_account_info(),
//             authority: ctx.accounts.owner.to_account_info(),
//         };
//         let cpi_program = ctx.accounts.token_program.to_account_info();
//         let cpi_ctx = CpiContext::new(cpi_program, cpi_accounts);
//         let result = transfer(cpi_ctx, deposit_amount);
//         // if let Err(_) = result {
//         //     return Err(error!(MarketError::TokenTransferFailed));
//         // }
//         Ok(())
//     }

//     pub fn buy(
//         ctx: Context<BuyCTX>,
//         deposit_amount: u64
//     ) -> Result<()> {
//         let deposit_info = &mut ctx.accounts.deposit_info;
//         let buyer = &mut ctx.accounts.buyer;

//         // Sol Transfer
//         anchor_lang::solana_program::program::invoke(
//             &anchor_lang::solana_program::system_instruction::transfer(
//                 &buyer.to_account_info().key(),
//                 &deposit_info.owner.key(), 
//                 deposit_amount), 
//             &[
//                 buyer.to_account_info(), 
//                 ctx.accounts.owner.to_account_info(), 
//                 ctx.accounts.system_program.to_account_info()
//             ]
//         )?;

//         // Token Transfer
//         let amount_out = deposit_amount.checked_mul(1e9 as u64).unwrap().checked_div(deposit_info.sale_price).unwrap();
//         let seeds = &[
//             deposit_info.owner.as_ref(),
//             b"deposit_info",
//             &[deposit_info.bump],
//         ];
//         let signer = &[&seeds[..]];
//         // Mint Watermelon to user
//         let cpi_accounts = Transfer {
//             from: ctx.accounts.pda_token_account.to_account_info(),
//             to: ctx.accounts.buyer_token_account.to_account_info(),
//             authority: deposit_info.to_account_info(),
//         };
//         let cpi_program = ctx.accounts.token_program.to_account_info();
//         let cpi_ctx = CpiContext::new_with_signer(cpi_program, cpi_accounts, signer);
//         token::transfer(cpi_ctx, amount_out)?;

//         Ok(())
//     }

//     pub fn deposit(
//         ctx: Context<DepositSale>,
//         deposit_amount: u64
//     ) -> Result<()> {
//         let deposit_info = &mut ctx.accounts.deposit_info;
//         let sender = &mut ctx.accounts.caller;
//         let receiver = &mut ctx.accounts.receiver;

//         anchor_lang::solana_program::program::invoke(
//             &anchor_lang::solana_program::system_instruction::transfer(
//                 &sender.to_account_info().key(),
//                 &receiver.to_account_info().key(), 
//                 deposit_amount), 
//             &[
//                 sender.to_account_info(), 
//                 receiver.to_account_info(), 
//                 ctx.accounts.system_program.to_account_info()
//             ]
//         )?;


//         deposit_info.current_balance = deposit_info.current_balance + deposit_amount;

//         Ok(())
//     }


//     pub fn withdraw(
//         ctx: Context<WithdrawSale>,
//         amount_of_lamports: u64
//     ) -> Result<()> {
//         let from = ctx.accounts.deposit_info.to_account_info();
//         let to = ctx.accounts.receiver.to_account_info();

//         // Debit from_account and credit to_account
//         **from.try_borrow_mut_lamports()? -= amount_of_lamports;
//         **to.try_borrow_mut_lamports()? += amount_of_lamports;

//         Ok(())
//     }

// }







// context

// use crate:: { account::*, error:: ErrorCode};
// use anchor_lang::prelude::*;
// use anchor_spl::token::{Mint, Token, TokenAccount};
// use anchor_spl::associated_token::AssociatedToken;

// #[derive(Accounts)]
// #[instruction(owner: Pubkey, content: String)]
// pub struct CreateSale<'info> {
//     #[account(
//         init, 
//         payer = caller,
//         space = SaleInfo::space(&content),
//         seeds = [owner.as_ref(), b"deposit_info"],
//         bump
//     )]
//     pub deposit_info: Account<'info, SaleInfo>,
//     #[account(mut)]
//     pub caller: Signer<'info>,
//     pub system_program: Program<'info, System>
// }

// #[derive(Accounts)]
// pub struct BuyCTX<'info> {
//     #[account(
//         mut, 
//         seeds = [deposit_info.owner.as_ref(), b"deposit_info"],
//         bump
//     )]
//     pub deposit_info: Account<'info, SaleInfo>,

//     /// CHECK: receiver wallet
//     #[account(mut)]
//     pub owner: AccountInfo<'info>,

//     #[account(mut)]
//     pub buyer: Signer<'info>,

//     #[account(
//         mut,
//         constraint= buyer_token_account.owner == buyer.key(),        
//         constraint= buyer_token_account.mint == mint_key.key(),
//     )]
//     pub buyer_token_account: Account<'info, TokenAccount>,
    
//     #[account(        
//         mut,
//         associated_token::mint = mint_key,
//         associated_token::authority = deposit_info
//     )]
//     pub pda_token_account: Account<'info, TokenAccount>,

//     pub mint_key: Account<'info, Mint>,

//     pub token_program: Program<'info, Token>,
//     pub associated_token_program: Program<'info, AssociatedToken>,
//     pub system_program: Program<'info, System>,
//     pub rent: Sysvar<'info, Rent>
// }


// #[derive(Accounts)]
// pub struct DepositToken<'info> {
//     #[account(
//         mut, 
//         seeds = [deposit_info.owner.as_ref(), b"deposit_info"],
//         bump
//     )]
//     pub deposit_info: Account<'info, SaleInfo>,

//     #[account(mut)]
//     pub owner: Signer<'info>,

//     #[account(
//         mut,
//         constraint= buyer_token_account.owner == owner.key(),        
//         constraint= buyer_token_account.mint == mint_key.key(),
//     )]
//     pub buyer_token_account: Account<'info, TokenAccount>,
    
//     #[account(        
//         init,
//         payer = owner,
//         associated_token::mint = mint_key,
//         associated_token::authority = deposit_info
//     )]
//     pub pda_token_account: Account<'info, TokenAccount>,

//     pub mint_key: Account<'info, Mint>,

//     pub token_program: Program<'info, Token>,
//     pub associated_token_program: Program<'info, AssociatedToken>,
//     pub system_program: Program<'info, System>,
//     pub rent: Sysvar<'info, Rent>
// }



// #[derive(Accounts)]
// pub struct DepositSale<'info> {
//     #[account(
//         mut, 
//         seeds = [deposit_info.owner.as_ref(), b"deposit_info"],
//         bump
//     )]
//     pub deposit_info: Account<'info, SaleInfo>,
//     #[account(mut)]
//     pub caller: Signer<'info>,
//     /// CHECK: receiver wallet
//     #[account(mut)]
//     pub receiver: AccountInfo<'info>,
//     pub system_program: Program<'info, System>
// }


// #[derive(Accounts)]
// pub struct WithdrawSale<'info> {
//     #[account(
//         mut, 
//         seeds = [deposit_info.owner.as_ref(), b"deposit_info"],
//         bump,
//         has_one = owner
//     )]
//     pub deposit_info: Account<'info, SaleInfo>,
//     #[account(mut)]
//     pub owner: Signer<'info>,
//     /// CHECK: pda wallet
//     #[account(mut)]
//     pub pda_wallet: AccountInfo<'info>,
//     /// CHECK: receiver wallet
//     #[account(mut)]
//     pub receiver: AccountInfo<'info>,
//     pub system_program: Program<'info, System>
// }



// lib

// use anchor_lang::prelude::*;

// #[account]
// pub struct SaleInfo {
//     pub owner: Pubkey,
//     pub content: String, 
//     pub bump: u8,
//     pub sale_quantity: u64,
//     pub current_balance: u64,   
//     pub start_time: u64,
//     pub end_time: u64,
//     pub sale_price: u64,
//     pub minimum_deposit_sol: u64,
//     pub maximum_deposit_sol: u64,
//     pub is_sale: bool
// }


// impl SaleInfo {
//     pub fn space(content: &str) -> usize {
//         8 + 1 + 32 + 8 + 8 + 8 + 8 + 8 + 8 + 8 + 1 +  4 + content.len()
//     }
// }






























// test

// const anchor = require("@project-serum/anchor");
// const {
//   createMint, 
//   TOKEN_PROGRAM_ID, 
//   ASSOCIATED_TOKEN_PROGRAM_ID,
//   mintTo,
//   getOrCreateAssociatedTokenAccount,
//   getAssociatedTokenAddress 
// } = require("@solana/spl-token");
// const spl = require("@solana/spl-token");

// const web3 = require("@solana/web3.js");
// const { expect } = require("chai");

// describe("presale", () => {
//   const provider = anchor.AnchorProvider.env();
//   anchor.setProvider(provider);
//   const program = anchor.workspace.Presale;

//   const contractAddress = String(program.programId);
//   let presale;
//   let tokenAddress;
//   let userAccounts = [];
//   let userAssociateAccounts = [];

//   async function setProgram(account) {
//     let wallet = new anchor.Wallet(account);
//     let currentProvider = new anchor.AnchorProvider(
//       provider.connection, wallet, provider.opts);

//     presale = new anchor.Program(program.idl,program.programId,currentProvider);
//   }

  
//   it("Account Create & Airdrop", async () => {
//     for(let i=0; i<10; i++) {
//       userAccounts.push(anchor.web3.Keypair.generate());
      
//       if(i== 0 || i == 1) console.log("user account", i + 1, String(userAccounts[i].publicKey));
//     }
//     await airDrop(userAccounts[0].publicKey, 2000000000);
//     await multiAirDrop(userAccounts,3000000000);
//     tokenAddress = await createToken(userAccounts[0]);
//     let associateWalletOne = await createAssociatedAccount(userAccounts[0]);
//     await mint(userAccounts[0],associateWalletOne,100000e9);
//     expect(await getTokenBalance(associateWalletOne)).equal("100000");

//     let wallet = new anchor.Wallet(userAccounts[0]);
//     let currentProvider = new anchor.AnchorProvider(
//       provider.connection, wallet, provider.opts);

//     presale = new anchor.Program(program.idl,program.programId,currentProvider);
//   });
  

//   it("CreateSale!", async () => {
//     await setProgram(userAccounts[0]);
//     const [pda,bump] = await anchor.web3.PublicKey.findProgramAddress(
//         [userAccounts[0].publicKey.toBytes(),
//         Buffer.from("deposit_info")],
//         program.programId
//     );

//     let currentTime = Math.floor(new Date().getTime()/1000.0);

//     // console.log("pda & bump", (pda).toString(), bump);

//     const tx = await presale.rpc.createSale(
//         userAccounts[0].publicKey,
//         "first deposit hello",
//         new anchor.BN(10000e9),
//         new anchor.BN(currentTime),
//         new anchor.BN(currentTime + (86400 * 5)),
//         new anchor.BN(0.1e9),
//         new anchor.BN(0.01e9),
//         new anchor.BN(100e9),
//         {
//             accounts: {
//               depositInfo: pda,
//               caller: userAccounts[0].publicKey,
//               systemProgram: anchor.web3.SystemProgram.programId
//             }
//         }
//     );

//     let response = await presale.account.saleInfo.fetch(pda);

//     console.log("Response", {
//       owner : response.owner.toString(),
//       content: response.content.toString(),
//       bump : response.bump.toString(),
//       isSale : response.isSale,
//       saleQuantity: response.saleQuantity.toString(),
//       currentBalance : response.currentBalance.toString(),
//       startTime : response.startTime.toString(),
//       endTime : response.endTime.toString(),
//       salePrice : response.salePrice.toString(),
//       minimumDepositSol : response.minimumDepositSol.toString(),
//       maximumDepositSol : response.maximumDepositSol.toString()
//     });
//     expect(response.owner.toString()).equal(userAccounts[0].publicKey.toString());

//     let userOneATA = await createAssociatedAccount(userAccounts[0]);
//     let userTwoATA = await createAssociatedAccount(userAccounts[1]);
//     let pdaATA = await getAssociatedTokenAddress(tokenAddress,pda,true);
//     await transfer(userAccounts[0],userOneATA,userTwoATA);
//     expect(await getTokenBalance(userOneATA)).equal("90000");
//     expect(await getTokenBalance(userTwoATA)).equal("10000");
//     // await transfer(userAccounts[0],userOneATA,pdaATA);    
//   });

//   it("Owner Token Load", async () => {
//     // Add your test here.
//     const [pda,bump] = await anchor.web3.PublicKey.findProgramAddress(
//         [userAccounts[0].publicKey.toBytes(),
//         Buffer.from("deposit_info")],
//         program.programId
//     );

//     let userATA = await getAssociatedTokenAddress(tokenAddress,userAccounts[0].publicKey);
//     let pdaATA = await getAssociatedTokenAddress(tokenAddress,pda,true);
//     await presale.rpc.tokenDeposit(
//       new anchor.BN(10000e9),
//       {
//           accounts: {
//             depositInfo: pda,
//             owner: userAccounts[0].publicKey,
//             buyerTokenAccount: userATA,
//             pdaTokenAccount: pdaATA,
//             mintKey: tokenAddress,
//             tokenProgram: TOKEN_PROGRAM_ID,
//             associatedTokenProgram: ASSOCIATED_TOKEN_PROGRAM_ID,
//             systemProgram: anchor.web3.SystemProgram.programId,
//             rent: anchor.web3.SYSVAR_RENT_PUBKEY,
//           }
//       }
//     );

//     expect(await getTokenBalance(userATA)).equal("80000");
//     expect(await getTokenBalance(pdaATA)).equal("10000");
//   });



//   it("First Buy", async () => {
//     const owner = userAccounts[0];
//     const user = userAccounts[2];
//     const [pda,bump] = await anchor.web3.PublicKey.findProgramAddress(
//         [userAccounts[0].publicKey.toBytes(),
//         Buffer.from("deposit_info")],
//         program.programId
//     );

//     await setProgram(user);
//     let userTwoATA = await createAssociatedAccount(user);
//     let userATA = await getAssociatedTokenAddress(tokenAddress,user.publicKey);
//     let pdaATA = await getAssociatedTokenAddress(tokenAddress,pda,true);

//     console.log("Test",userATA);


//     await presale.rpc.buy(
//       new anchor.BN(1e9),
//       {
//           accounts: {
//             depositInfo: pda,
//             owner: owner.publicKey,
//             buyer: user.publicKey,
//             buyerTokenAccount: userATA,
//             pdaTokenAccount: pdaATA,
//             mintKey: tokenAddress,
//             tokenProgram: TOKEN_PROGRAM_ID,
//             associatedTokenProgram: ASSOCIATED_TOKEN_PROGRAM_ID,
//             systemProgram: anchor.web3.SystemProgram.programId,
//             rent: anchor.web3.SYSVAR_RENT_PUBKEY,
//           }
//       }
//     );

//     console.log("Bal", await getTokenBalance(userATA), await getTokenBalance(pdaATA))

//     // expect(await getTokenBalance(userATA)).equal("80000");
//     // expect(await getTokenBalance(pdaATA)).equal("10000");  
//   });




//   // it("withdraw", async () => {
//   //     // Add your test here.
//   //     const [pda,bump] = await anchor.web3.PublicKey.findProgramAddress(
//   //       [userAccounts[0].publicKey.toBytes(),
//   //       Buffer.from("deposit_info")],
//   //       program.programId
//   //     );


//   //     await getAccountOwner(pda, "PDA");

//   //     // console.log("pda & bump", (pda).toString(), bump);

//   //     let senderBeforeBalance = await getBalance(userAccounts[1].publicKey);
//   //     let receiverBeforeBalance = await getBalance(pda);

//   //     console.log("Before Balance", (senderBeforeBalance).toString() , (receiverBeforeBalance).toString());

//   //     console.log("contract address", contractAddress.toString());
//   //   //  await getAccountOwner(contractAddress.toString(), "Contract");

//   //     const tx = await presale.rpc.withdraw(
//   //         new anchor.BN(1000000000),
//   //             {
//   //                 accounts: {
//   //                   depositInfo: pda,
//   //                   owner: userAccounts[0].publicKey,
//   //                   pdaWallet: pda,
//   //                   receiver: userAccounts[1].publicKey,
//   //                   systemProgram: anchor.web3.SystemProgram.programId,
//   //                 }
//   //             }
//   //     );

//   //     console.log("Your transaction signature", tx);

//   //     let senderAfterBalance = await getBalance(userAccounts[1].publicKey);
//   //     let receiverAfterBalance = await getBalance(pda);

//   //     console.log("After Balance", (senderAfterBalance).toString() , (receiverAfterBalance).toString());

//   //     let response = await presale.account.depositInfo.fetch(pda);

//   //     console.log("Response", {
//   //     owner : response.owner.toString(),
//   //     minimumDepositAmount : response.minimumDepositAmount.toString(),
//   //     currentBalance : response.currentBalance.toString(),
//   //     content : response.content.toString(),
//   //     bump : response.bump.toString()
//   //     });
//   //     expect(response.owner.toString()).equal(userAccounts[0].publicKey.toString());

//   // })

//   // it("Deposit one!", async () => {
//   //   // Add your test here.
//   //   const [pda,bump] = await anchor.web3.PublicKey.findProgramAddress(
//   //       [userAccounts[0].publicKey.toBytes(),
//   //       Buffer.from("deposit_info")],
//   //       program.programId
//   //   );

//   //  // console.log("pda & bump", (pda).toString(), bump);

//   //   let senderBeforeBalance = await getBalance(userAccounts[0].publicKey);
//   //   let receiverBeforeBalance = await getBalance(pda);

//   //   console.log("Before Balance", (senderBeforeBalance).toString() , (receiverBeforeBalance).toString());

//   //   const tx = await presale.rpc.deposit(
//   //     new anchor.BN(1000000000),
//   //     {
//   //         accounts: {
//   //           depositInfo: pda,
//   //           owner: userAccounts[0].publicKey,
//   //           receiver: pda,
//   //           systemProgram: anchor.web3.SystemProgram.programId,
//   //         }
//   //     }
//   //   );

//   //  // console.log("Your transaction signature", tx);

//   //  let senderAfterBalance = await getBalance(userAccounts[0].publicKey);
//   //  let receiverAfterBalance = await getBalance(pda);

//   //  console.log("After Balance", (senderAfterBalance).toString() , (receiverAfterBalance).toString());

//   //   let response = await presale.account.depositInfo.fetch(pda);

//   //   console.log("Response", {
//   //     owner : response.owner.toString(),
//   //     minimumDepositAmount : response.minimumDepositAmount.toString(),
//   //     currentBalance : response.currentBalance.toString(),
//   //     content : response.content.toString(),
//   //     bump : response.bump.toString()
//   //   });
//   //   expect(response.owner.toString()).equal(userAccounts[0].publicKey.toString());
  
//   // });

//   // it("withdraw", async () => {
//   //     // Add your test here.
//   //     const [pda,bump] = await anchor.web3.PublicKey.findProgramAddress(
//   //       [userAccounts[0].publicKey.toBytes(),
//   //       Buffer.from("deposit_info")],
//   //       program.programId
//   //     );


//   //     await getAccountOwner(pda, "PDA");

//   //     // console.log("pda & bump", (pda).toString(), bump);

//   //     let senderBeforeBalance = await getBalance(userAccounts[1].publicKey);
//   //     let receiverBeforeBalance = await getBalance(pda);

//   //     console.log("Before Balance", (senderBeforeBalance).toString() , (receiverBeforeBalance).toString());

//   //     console.log("contract address", contractAddress.toString());
//   //   //  await getAccountOwner(contractAddress.toString(), "Contract");

//   //     const tx = await presale.rpc.withdraw(
//   //         new anchor.BN(1000000000),
//   //             {
//   //                 accounts: {
//   //                   depositInfo: pda,
//   //                   owner: userAccounts[0].publicKey,
//   //                   pdaWallet: pda,
//   //                   receiver: userAccounts[1].publicKey,
//   //                   systemProgram: anchor.web3.SystemProgram.programId,
//   //                 }
//   //             }
//   //     );

//   //     console.log("Your transaction signature", tx);

//   //     let senderAfterBalance = await getBalance(userAccounts[1].publicKey);
//   //     let receiverAfterBalance = await getBalance(pda);

//   //     console.log("After Balance", (senderAfterBalance).toString() , (receiverAfterBalance).toString());

//   //     let response = await presale.account.depositInfo.fetch(pda);

//   //     console.log("Response", {
//   //     owner : response.owner.toString(),
//   //     minimumDepositAmount : response.minimumDepositAmount.toString(),
//   //     currentBalance : response.currentBalance.toString(),
//   //     content : response.content.toString(),
//   //     bump : response.bump.toString()
//   //     });
//   //     expect(response.owner.toString()).equal(userAccounts[0].publicKey.toString());

//   // })






//   async function transfer(fromWallet,fromTokenAccount,toTokenAccount) {
//       let signature = await spl.transfer(
//           provider.connection,
//           fromWallet,
//           fromTokenAccount,
//           toTokenAccount,
//           fromWallet.publicKey,
//           10000e9
//       );

//     console.log("signature", signature);
//   }

//   async function mint(userWallet,userAssociateWallet,supply) {
//     let signature = await mintTo(
//       provider.connection,
//       userWallet,
//       tokenAddress,             //changes(mint)
//       userAssociateWallet,
//       userWallet.publicKey,
//       new anchor.BN(supply)
//   );
//   console.log('mint tx:', signature);
//   }

//   async function createToken(wallet) {
//     const mint = await createMint(
//       provider.connection,
//       wallet,
//       wallet.publicKey,
//       wallet.publicKey,
//       9
//     );
//     console.log("mint", mint.toBase58());
//     return mint;
//   }

//   async function createAssociatedAccount(wallet) {
//       //const tokenInstance = new Token(provider.connection,tokenAddress,TOKEN_PROGRAM_ID,userAccounts[0]);

//       let tokenAssociateWallet = await getOrCreateAssociatedTokenAccount(
//         provider.connection,
//         wallet,
//         tokenAddress,
//         wallet.publicKey
//       );
//       console.log("tokenAssociateWallet", tokenAssociateWallet.address.toBase58());
//       return tokenAssociateWallet.address;

//       //let A_wallet = await tokenInstance.createAccount(userAccounts[0].publicKey);
//   }

//   async function getAccountOwner(account,context) {
//     let accountInfo = await provider.connection.getAccountInfo(account);
//     await space();
//     console.log(context, "Account Info",{
//         wallet : account.toString(),
//         owner : accountInfo.owner.toString()
//     }) 
//     await space();
//   }

//   async function getTokenBalance(account) {
//     let currBal = await provider.connection.getTokenAccountBalance(account);
//     return (currBal.value.uiAmountString);
//   }

//   async function getBalance(account) {
//     return (await provider.connection.getBalance(account));
//   } 

//   async function airDrop(account,amount) {
//     await provider.connection.confirmTransaction(
//         await provider.connection.requestAirdrop(account,amount),
//         "confirmed"
//     );
//   } 

//   async function multiAirDrop(account,amount) {
//     for(let i=0; i<account.length;i++) {
//       await provider.connection.confirmTransaction(
//         await provider.connection.requestAirdrop(account[i].publicKey,amount),
//         "confirmed"
//       );
//       //console.log("user balance", i+1, Number(await getBalance(account[i].publicKey)/1e9));
//     }
//   } 

//   async function space() {
//     console.log("");
//     console.log("");
//     // console.log("");
//     // console.log("");
//     // console.log("");
//   }


// });