/**
 *Submitted for verification at BscScan.com on 2022-10-01
*/

// SPDX-License-Identifier: Unlicensed
// This contract is not open source and can not be used/forked without permission

/*

    Free LP Token Locker Provided by https://gentokens.com/
    Visit our website to check out our other utilities

    Current GenTokens Utilities

        * Liquidity Token Locker
        * Token Generator
        * Airdrop Tool

    Our utilities are designed to provide secure solutions for developers and investors.


        ████████████████████████████████████████████
        █                                          █
        █  - Earn BNB by Promoting Our Services! - █ 
        █   - Check Our Website For Details -      █
        █                                          █
        █          https://gentokens.com           █
        █                                          █
        ████████████████████████████████████████████


    Website: https://gentokens.com/
    YouTube: https://youtube.com/c/gentokens
    Telegram: https://t.me/GenTokens

    Profits from our utilities support GEN, the flagship token of the GenTokens Community

    GEN Website: https://gen.gentokens.com/
    GEN Telegram: https://t.me/gen_gentokens
    GEN Contract Address: 0x7d7a7f452e04c2a5df792645e8bfaf529adccecf

    --> We are fully doxxed! <--

    KYC/DOXX Certificates:
    https://coinsniper.net/coin/25309/kyc
    https://auditrate.tech/certificate/certificate_GEN.html


    -------------------------------------------------------------------------------------

    Terms of Use

    IMPORTANT: We only support tokens with a BNB liquidity pair!
    Do not send NON-BNB LP Tokens to this contract!

    To access the lock, you must be the current token owner. 
    If you transfer ownership, the new owner will be the only wallet that can access the lock.
    If you renounce ownership, your LP tokens will become trapped and are not recoverable.

    To see a full demonstration of how to use your lock visit our website at https://gentokens.com/



    -------------------------------------------------------------------------------------


*/


pragma solidity 0.8.17;


interface BEP20 {

    function token0() external view returns (address); 
    function token1() external view returns (address); 
    function owner() external view returns (address); 
    function name() external view returns (string calldata); 
    function symbol() external view returns (string calldata);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}



// address constant BNBADD = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // MAIN NET 
address constant BNBADD = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // TEST NET 


contract AAA {

    mapping (address => uint256) private _LOCK_TIME;
    mapping (address => string) private _Website;

    event LP_Token_Removed(address LP_Token, address Removed_by, uint256 Amount_Removed);
    event LP_Lock_updated(address LP_Token, address Updated_by, uint256 Days_until_Unlock);
    event Token_Rescued(address Token, address Rescued_by, uint256 Amount_Rescued);


    // Get token contract address from the LP pair
    function get_CA_from_LP (address LP_Address) private view returns (address Token_CA){

        address Tok_0 = BEP20(LP_Address).token0();
        address Tok_1 = BEP20(LP_Address).token1();

        // One token must be BNB
        require((Tok_0 == BNBADD || Tok_1 == BNBADD), "Not a valid BNB pair");

        if (Tok_0 != BNBADD){

            return Tok_0;
        
        } else {

            return Tok_1;

        }

    }


    // Get token owner from the LP pair
    function get_Owner_from_LP (address LP_Address) private view returns (address){

        address TokenCA;

        address Tok_0 = BEP20(LP_Address).token0();
        address Tok_1 = BEP20(LP_Address).token1();

        // One token must be BNB
        require((Tok_0 == BNBADD || Tok_1 == BNBADD), "Not a valid BNB pair");

            if (Tok_0 != BNBADD){

                TokenCA = Tok_0;
            
            } else {

                TokenCA = Tok_1;

            }

        // Return the owner for the TokenCA
        return BEP20(TokenCA).owner();

    }


    // Check LP Lock
    function Check_LP_Lock(address LP_Token_Address) public view returns(
                                                       string memory Token_Name,
                                                       address Contract_Address,
                                                       string memory Website,
                                                       uint256 Unlock_Time_Stamp,
                                                       uint256 Days_until_Unlock,
                                                       uint256 Percent_of_LP_Tokens_Locked) {

        // Get token CA
        address TheTokenCA = get_CA_from_LP(LP_Token_Address);

        // Get percent of LP locked
        uint256 LP_Percent_Locked = 100 * (BEP20(LP_Token_Address).balanceOf(address(this))) / (BEP20(LP_Token_Address).totalSupply());


        // Convert timestamp to days
        uint256 DaysRemaining = 0; 


             if (_LOCK_TIME[LP_Token_Address] < (block.timestamp + 86400)) {

                DaysRemaining = 0;

             } else {

                DaysRemaining = (_LOCK_TIME[LP_Token_Address] - block.timestamp) / 86400;
             }


        // Return Token Data
        return (BEP20(TheTokenCA).name(),
                TheTokenCA,
                _Website[LP_Token_Address],
                _LOCK_TIME[LP_Token_Address],
                DaysRemaining,
                LP_Percent_Locked
                );

    }

    // LP Lock Provider URL
    string public Free_LP_Lock_Provider = "http://www.gentokens.com";



    // Remove LP Tokens from Lock
    function Remove_LP_Tokens(

        address LP_Token_Address,
        uint256 Percent_to_Remove

        ) public {

        // Check the msg.sender is the owner of the token
        require(msg.sender == get_Owner_from_LP(LP_Token_Address),"You need to be the owner of the token.");

        // The lock timer must be expired!
        require(block.timestamp >= _LOCK_TIME[LP_Token_Address],"That token is still locked!");

        // Sanity Check
        require(Percent_to_Remove <= 100,"Enter the amount you want to remove as a percent of the total tokens locked.");

        // Balance check 
        uint256 LP_Locked = BEP20(LP_Token_Address).balanceOf(address(this));

        // Amount to remove       
        uint256 remove_LP = LP_Locked * Percent_to_Remove / 100;

        // Transfer to owner
        BEP20(LP_Token_Address).transfer(msg.sender, remove_LP);

        // Emit the LP token removal
        emit LP_Token_Removed(LP_Token_Address, msg.sender, remove_LP);

    }


    // Set unlock time
    function Set_Unlock_Time(address LP_Token_Address, uint256 Unlock_in_X_Days) external {

        // Check the msg.sender is the owner of the token
        require(msg.sender == get_Owner_from_LP(LP_Token_Address),"You need to be the owner of the token you are updating.");

        // Current unlock time
        uint256 current_Unlock = _LOCK_TIME[LP_Token_Address];

        // New unlock time
        uint256 new_Unlock = block.timestamp + (Unlock_in_X_Days * 86400);

        // New unlock time must be after current unlock time
        require(new_Unlock >= current_Unlock, "Your new unlock date must be after the current unlock date.");

        // Update the locker time
        _LOCK_TIME[LP_Token_Address] = new_Unlock;

        // Emit Lock Update
        emit LP_Lock_updated(LP_Token_Address, msg.sender, Unlock_in_X_Days);

    }


    // Add website link for the token
    function Set_Website(address LP_Token_Address, string memory Website_URL) external {

        // Check the msg.sender is the owner of the token
        require(msg.sender == get_Owner_from_LP(LP_Token_Address),"You need to be the owner of the token you are updating.");

        // Update link
        _Website[LP_Token_Address] = Website_URL;

    }





    /*

    TOKEN RESCUE - NON BNB LP TOKENS ONLY!

    The following function can only be accessed by Gen (Address: 0xD05895EDF847e1712721Cc9e0427Aa26289A6Bc5)
    This function permits the rescue of trapped NON-BNB LP tokens only.

    This function can NOT rescue a BNB LP token if you have renounced your contract or transferred ownership!

    It is only possible to rescue NON-BNB LP tokens.

    The sole purpose of this function is to correct mistakes, allowing NON-BNB LP tokens that are sent to the contract 
    to be recovered and returned to their rightful owner.

    Without this safeguard, any NON-BNB LP Tokens would be permanently trapped in the contract.
    To request a trapped token to be rescued contact Gen via Telegram: https://t.me/GenTokens

    Rescued tokens will be returned to the wallet that sent them to the contract. No exceptions.

    */



    // Emergency Rescue of NON BNB LP Tokens
    function Token_Rescue(address Token_To_Rescue, uint256 Percent_to_Rescue) external {

        // Token Rescue Can Only be Done By Gen
        require(msg.sender == 0xD05895EDF847e1712721Cc9e0427Aa26289A6Bc5, "Only Gen can rescue tokens!");

        // Get token symbol
        string memory Token_Symbol = BEP20(Token_To_Rescue).symbol();

        // If Token Symbol it Cake_LP check the pairs for BNB
        if (keccak256(bytes(Token_Symbol)) == keccak256(bytes("Cake_LP"))){

            // Token could be a BNB LP Pair - Check it!
            address Tok_0 = BEP20(Token_To_Rescue).token0();
            address Tok_1 = BEP20(Token_To_Rescue).token1();

            // If either pair is BNB then do not permit removal
            require((Tok_0 != BNBADD), "Can not rescue a BNB LP Token! Owner must remove!");
            require((Tok_1 != BNBADD), "Can not rescue a BNB LP Token! Owner must remove!");

            // Check balance trapped on contract 
            uint256 Trapped_Tokens = BEP20(Token_To_Rescue).balanceOf(address(this));

            // Percent to rescue (Required if total trapped exceeds the transaction limit of the trapped token)       
            uint256 Rescue_Amount = Trapped_Tokens * Percent_to_Rescue / 100;

            // Transfer to Gen
            BEP20(Token_To_Rescue).transfer(msg.sender, Rescue_Amount);

            // Emit the rescue
            emit Token_Rescued(Token_To_Rescue, msg.sender, Rescue_Amount);

        } else {

            // Token is not a BNB LP Pair 

            // Check balance trapped on contract 
            uint256 Trapped_Tokens = BEP20(Token_To_Rescue).balanceOf(address(this));

            // Percent to rescue (Required if total trapped exceeds the transaction limit of the trapped token)       
            uint256 Rescue_Amount = Trapped_Tokens * Percent_to_Rescue / 100;

            // Transfer to Gen
            BEP20(Token_To_Rescue).transfer(msg.sender, Rescue_Amount);

            // Emit the rescue
            emit Token_Rescued(Token_To_Rescue, msg.sender, Rescue_Amount);
        }







    }

}