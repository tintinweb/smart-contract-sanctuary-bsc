/**
 *Submitted for verification at BscScan.com on 2022-07-15
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
        // changes to the state and to Ether balances are reverted.
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


// use anchor_lang::prelude::*;
// use crate:: {
//     error:: ErrorCode
// };

// mod error;

// declare_id!("ASoshQHNVML7Z2pEnGpC5S1vxdtRm2diA1PnvxMhhCkr");

// #[program]
// pub mod redeem {
//     use super::*;

//     pub fn create_sale(
//         ctx: Context<CreateSale>, 
//         owner: Pubkey,
//         content: String,
//         minimum_deposit_amount: u128
//     ) -> Result<()> {
//         let deposit_info = &mut ctx.accounts.deposit_info;


//         require!(owner == ctx.accounts.caller.key(), ErrorCode::OnlyOwner);
//         deposit_info.owner = ctx.accounts.caller.key();
//         deposit_info.minimum_deposit_amount = minimum_deposit_amount;
//         deposit_info.content = content;
//         deposit_info.bump = *ctx.bumps.get("deposit_info").unwrap();
//         Ok(())
//     }


//     pub fn deposit(
//         ctx: Context<DepositSale>,
//         deposit_amount: u64
//     ) -> Result<()> {
//         let deposit_info = &mut ctx.accounts.deposit_info;
//         let sender = &mut ctx.accounts.owner;
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

//     pub fn transfer_native_sol(
//         ctx: Context<Transfer>,
//         amount_of_lamports: u64
//     ) -> Result<()> {
//         let from = ctx.accounts.from.to_account_info();
//         let to = ctx.accounts.to.to_account_info();

//         // Debit from_account and credit to_account
//         **from.try_borrow_mut_lamports()? -= amount_of_lamports;
//         **to.try_borrow_mut_lamports()? += amount_of_lamports;

//         Ok(())
//     }

// }

// #[derive(Accounts)]
// #[instruction(owner: Pubkey, content: String)]
// pub struct CreateSale<'info> {
//     #[account(
//         init, 
//         payer = caller,
//         space = DepositInfo::space(&content),
//         seeds = [owner.as_ref(), b"deposit_info"],
//         bump
//     )]
//     pub deposit_info: Account<'info, DepositInfo>,
//     #[account(mut)]
//     pub caller: Signer<'info>,
//     pub system_program: Program<'info, System>
// }


// #[derive(Accounts)]
// pub struct DepositSale<'info> {
//     #[account(
//         mut, 
//         seeds = [deposit_info.owner.as_ref(), b"deposit_info"],
//         bump,
//         has_one = owner
//     )]
//     pub deposit_info: Account<'info, DepositInfo>,
//     #[account(mut)]
//     pub owner: Signer<'info>,
//     /// CHECK: receiver wallet
//     #[account(mut)]
//     pub receiver: AccountInfo<'info>,
//     pub system_program: Program<'info, System>
// }

// #[derive(Accounts)]
// pub struct Transfer<'info> {
//     #[account(mut)]
//     /// CHECK: This is not dangerous because its just a stackoverflow sample o.O
//     pub from: AccountInfo<'info>,
//     #[account(mut)]
//     /// CHECK: This is not dangerous because we just pay to this account
//     pub to: AccountInfo<'info>,
//     #[account(mut)]
//     pub user: Signer<'info>,
//     pub system_program: Program<'info, System>,
// }


// #[account]
// pub struct DepositInfo {
//     pub owner: Pubkey,
//     pub minimum_deposit_amount: u128,
//     pub current_balance: u64,
//     pub content: String,
//     pub bump: u8
// }

// impl DepositInfo {
//     pub fn space(content: &str) -> usize {
//         1 + 8 + 32 + 16 + 16 + 4 + content.len()
//     }
// }







// use anchor_lang::prelude::*;

// #[error_code]
// pub enum ErrorCode {
//     #[msg("Caller is not the owner")]
//     OnlyOwner
// }



































// const anchor = require("@project-serum/anchor");
// const { Keypair } = require("@solana/web3.js");
// const { expect } = require("chai");

// describe("redeem", () => {
//   // Configure the client to use the local cluster.
//   const provider = anchor.AnchorProvider.env();
//   anchor.setProvider(provider);

//   const program = anchor.workspace.Redeem;
//   const contractAddress = String(program.programId);
//   let redeem;


//   let userAccounts = [];


//   it("Account Create & Airdrop", async () => {
//     for(let i=0; i<10; i++) {
//       userAccounts.push(anchor.web3.Keypair.generate());
//       // console.log("user account", i + 1, String(userAccounts[i].publicKey));
//     }
//     await airDrop(userAccounts[0].publicKey, 2000000000);
//     await multiAirDrop(userAccounts,3000000000);

//     let wallet = new anchor.Wallet(userAccounts[0]);
//     let currentProvider = new anchor.AnchorProvider(
//       provider.connection, wallet, provider.opts);

//     redeem = new anchor.Program(program.idl,program.programId,currentProvider);

//     //console.log("user 1 balance", Number((await provider.connection.getBalance(userAccounts[0].publicKey))));

//   });
  

//   it("CreateSale!", async () => {
//     // Add your test here.

//     const [pda,bump] = await anchor.web3.PublicKey.findProgramAddress(
//         [userAccounts[0].publicKey.toBytes(),
//         Buffer.from("deposit_info")],
//         program.programId
//     );

//   //  console.log("pda & bump", (pda).toString(), bump);

//     const tx = await redeem.rpc.createSale(
//       userAccounts[0].publicKey,
//       "first deposit hello",
//       new anchor.BN(10000000),
//       {
//           accounts: {
//             depositInfo: pda,
//             caller: userAccounts[0].publicKey,
//             systemProgram: anchor.web3.SystemProgram.programId,
//           }
//       }
//     );
//    // console.log("Your transaction signature", tx);

//     let response = await redeem.account.depositInfo.fetch(pda);

//     console.log("Response", {
//       owner : response.owner.toString(),
//       minimumDepositAmount : response.minimumDepositAmount.toString(),
//       currentBalance : response.currentBalance.toString(),
//       content : response.content.toString(),
//       bump : response.bump.toString()
//     });
//     expect(response.owner.toString()).equal(userAccounts[0].publicKey.toString());
//   });

//   // it("Deposit!", async () => {
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

//   //   const tx = await redeem.rpc.deposit(
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

//   //  console.log("Before Balance", (senderAfterBalance).toString() , (receiverAfterBalance).toString());

//   //   let response = await redeem.account.depositInfo.fetch(pda);

//   //   console.log("Response", {
//   //     owner : response.owner.toString(),
//   //     minimumDepositAmount : response.minimumDepositAmount.toString(),
//   //     currentBalance : response.currentBalance.toString(),
//   //     content : response.content.toString(),
//   //     bump : response.bump.toString()
//   //   });
//   //   expect(response.owner.toString()).equal(userAccounts[0].publicKey.toString());
  
//   // });

//   it("Deposit Two", async () => {
//     // Add your test here.
//     const [pda,bump] = await anchor.web3.PublicKey.findProgramAddress(
//         [userAccounts[0].publicKey.toBytes(),
//         Buffer.from("deposit_info")],
//         program.programId
//     );

//    // console.log("pda & bump", (pda).toString(), bump);

//     let senderBeforeBalance = await getBalance(userAccounts[0].publicKey);
//     let receiverBeforeBalance = await getBalance(userAccounts[1].publicKey);

//     console.log("Before Balance", (senderBeforeBalance).toString() , (receiverBeforeBalance).toString());

//     const tx = await redeem.rpc.transferNativeSol(
//       new anchor.BN(1000000),
//       {
//           accounts: {
//             from: userAccounts[0].publicKey,
//             to: userAccounts[1].publicKey,
//             user: userAccounts[0].publicKey,
//             systemProgram: anchor.web3.SystemProgram.programId,
//           }
//       }
//     );

//    // console.log("Your transaction signature", tx);

//    let senderAfterBalance = await getBalance(userAccounts[0].publicKey);
//    let receiverAfterBalance = await getBalance(userAccounts[1].publicKey);

//    console.log("Before Balance", (senderAfterBalance).toString() , (receiverAfterBalance).toString());

//     let response = await redeem.account.depositInfo.fetch(pda);

//     console.log("Response", {
//       owner : response.owner.toString(),
//       minimumDepositAmount : response.minimumDepositAmount.toString(),
//       currentBalance : response.currentBalance.toString(),
//       content : response.content.toString(),
//       bump : response.bump.toString()
//     });
//     expect(response.owner.toString()).equal(userAccounts[0].publicKey.toString());
  
//   });


















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

// });