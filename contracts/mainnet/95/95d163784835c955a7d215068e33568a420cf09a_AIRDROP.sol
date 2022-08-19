/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

// SPDX-License-Identifier: Unlicensed 
// This contract is not open source and can not be used/forked without permission
// Created by https://TokensByGen.com/
// Contract Code Pre-Verified on BSCScan using 'Similar Match Source Code'

/*

-----------------------------
AIRDROP TOOL BY GENTOKENS.COM
-----------------------------



  **** IMPORTANT WARNING! ****

  It's very easy to lose or trap tokens when using this contract if you do not use it correctly.
  Before you begin, watch the step-by-step video and read the PDF guide thoroughly. 
  Even if you have done airdrops before, this contract may not work the way that you expect.
  This contract is limited by the contract of the tokens you wish to airdrop, so it will not always work in the same way.
  We can accept no responsibility for loses due to the incorrect use of this contract.

  Link to access PDF Guide
  XXXXXXXX////////

  Link to access step-by-step video
  XXXXXXXX////////





- VERY IMPORTNAT - FEES AND LIMITS!

    If you are the owner of a token, then you are probably excluded from fees and limits by default. 
    This means that you can send the entire supply of tokens to the airdrop contract without any issue.
    But... The airdrop contract will encounter problems trying to send tokens to other people!

    You need to exclude the airdrop contract address from fees and limits also. 


- Access Restrictions

    Your airdrop contract is bound to your wallet.
    You are the only person that has access to any of the functions. 
    The contract is limited to one wallet, ownership can not be transferred.


- Access Levels

    * 1 Day Access

        If you do not have unlimited access you can pay 0.2 BNB for 24 hour access.

    * Unlimited Access 

        The cost of unlimited access is 2 BNB


- Transferring Tokens

    In order to use the airdrop functions, you must first send sufficient tokens to the airdrop contract.
    You can do this manually via MetaMask.

    When tokens are transferred, they must comply with the restrictions and limits set in the token contract.
    If a token has a transaction limit or a fee, this will apply during the airdrop. 
    To prevent this, the airdrop contract address must be excluded from fees and limits on the token contract. 
    Some tokens may also need to whitelist the airdrop contract address before it is possible to transfer tokens.


- What causes an airdrop to fail?

    Remember that the transfer of tokens is handling by functions inside the token contract, not the airdrop contract. 
    This means that any limits or restrictions on those functions may cause the airdrop to fail. 

        These are the most common reasons that an airdrop may fail

        * Not enough tokens on the airdrop contract

            If there are not enough tokens on the airdrop contract to complete the full airdrop the entire transaction will fail and revert. 

        * Token contract fees

            If the token contract has fees, you need to exclude the airdrop contract address. Otherwise, when sending tokens to the 
            airdrop contract, fewer tokens will arrive 







*/


pragma solidity 0.8.16;

interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}








contract AIRDROP is Context {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address payable public _owner;
    address payable public Wallet_Affiliate;
    bool public Access__Unlimited;
    uint256 public Access__Until = 0;

    // Wallet_Affiliateiliate Tracking
    IERC20 GEN = IERC20(0x7d7a7f452e04C2a5df792645e8bfaF529aDcCEcf); // GEN - For tracking affiliate level
    IERC20 AFT = IERC20(0x98A70E83A53544368D72940467b8bB05267632f4); // Wallet_Affiliateiliate Tracker Token
    uint256 private constant Tier_2 =  500000 * 10**9; 
    uint256 private constant Tier_3 = 1000000 * 10**9; 


    constructor (address payable _Owner,
                 address payable _Code,
                 bool _Access__Unlimited
                ) {

                 _owner = _Owner;
                 Wallet_Affiliate = _Code;
                 Access__Unlimited = _Access__Unlimited;

                 // Emit ownership transfer of contract
                 emit OwnershipTransferred(address(0), _owner);

    }


    // Restrict function to contract owner only 
    modifier onlyOwner {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }



    // Set fee collector address
    address public Wallet_Fee_Collector = payable(0x627C95B6fD9026E00Ab2c373FB08CC47E02629a0); ///// UPDATE TO COLLECTOR CONTRACT 222



    function owner() public view returns (address) {
        return _owner;
    }









    // Pay for one day access - 0.2 BNB
    function Access_1_Day() public payable onlyOwner {


        // Check current access level
        require (!Access__Unlimited, "You do not need to pay, you have unlimited access!");

        uint256 OneDayAccessFee = 1e16; ///change to 2e17 0.2 BNB - test at 0.01 BNB
        require(msg.value == OneDayAccessFee, "Need to pay 0.2 BNB for one day access");


        // Credit affiliate 
        if (msg.value == OneDayAccessFee){


                // Distribute affiliate commission
                if(AFT.balanceOf(Wallet_Affiliate) > 0){

                        uint256 DEV = 0;
                        uint256 AFF = 0;
                        uint256 TBG = 0;

                        if(GEN.balanceOf(Wallet_Affiliate) >= Tier_3){

                            DEV = 10;
                            AFF = 20;
                            TBG = 70;

                        } else if (GEN.balanceOf(Wallet_Affiliate) >= Tier_2){

                            DEV = 10;
                            AFF = 15;
                            TBG = 75;

                        } else {

                            DEV = 10;
                            AFF = 10;
                            TBG = 80;

                        }

                        if (AFF > 0){
                            
                            send_BNB(Wallet_Fee_Collector, msg.value * TBG / 100);
                            send_BNB(_owner, msg.value * DEV / 100);
                            send_BNB(Wallet_Affiliate, msg.value * AFF / 100);

                        }

                } else {

                // Transfer Fee to Collector Wallet
                send_BNB(Wallet_Fee_Collector, msg.value);

                }

            // Allow access for 24 hours
            Access__Until = block.timestamp + 1 days;
        }        

    }






    // Buy full access
    function Access_Unlimited() public payable onlyOwner {

        // Check current access level
        require (!Access__Unlimited, "You already have unlimited access!");

        uint256 Unlimited_Access_Fee = 2e16; ///cahnge to 2e18 for 2 bnb
        require (msg.value == Unlimited_Access_Fee, "Need to pay 2 BNB for full access.");

        // Check for affiliate and distribute commission payments 
        if (msg.value == Unlimited_Access_Fee){

                // Check Wallet_Affiliateiliate is genuine - (Holds the TokensByGEN Wallet_Affiliateiliate Token)
                if(AFT.balanceOf(Wallet_Affiliate) > 0){

                        uint256 DEV = 0;
                        uint256 AFF = 0;
                        uint256 TBG = 0;

                        if(GEN.balanceOf(Wallet_Affiliate) >= Tier_3){

                            DEV = 10;
                            AFF = 20;
                            TBG = 70;

                        } else if (GEN.balanceOf(Wallet_Affiliate) >= Tier_2){

                            DEV = 10;
                            AFF = 15;
                            TBG = 75;

                        } else {

                            DEV = 10;
                            AFF = 10;
                            TBG = 80;

                        }

                        if (AFF > 0){
                            
                            send_BNB(Wallet_Fee_Collector, msg.value * TBG / 100);
                            send_BNB(_owner, msg.value * DEV / 100);
                            send_BNB(Wallet_Affiliate, msg.value * AFF / 100);

                        }

                } else {

                // Transfer Fee to Collector Wallet
                send_BNB(Wallet_Fee_Collector, msg.value);

                }


            // Update access level 
            Access__Unlimited = true;

        }

    }






    // Update reflections (dust drop)
    function Airdrop_Dust(address Token_CA, address[] calldata Wallets) external onlyOwner {

        // Check owner has access
        if (!Access__Unlimited){
            require(block.timestamp <= Access__Until, "You do not have access");
        }
        
        // Limit array length to reduce gas errors
        require(Wallets.length <= 500, "Limit sending to 500 to reduce errors"); 
        for (uint i=0; i < Wallets.length; i++) {
            IERC20(Token_CA).transfer(Wallets[i], 1);
        }
    }



    // Airdrop tokens (rounded value + decimals)
    function AirDrop_Rounded(address Token_CA, uint256 Decimals, address[] calldata Wallets, uint256[] calldata Tokens) external onlyOwner {

        // Check owner has access
        if (!Access__Unlimited){
            require(block.timestamp <= Access__Until, "You do not have access");
        }


        // Limit array length to avoid out of gas error
        require(Wallets.length <= 500, "Limit sending to 500 to reduce errors"); 
        require(Wallets.length == Tokens.length, "Token and Wallet count missmatch!");

        uint256 checkQuantity = 0;

        for(uint i=0; i < Wallets.length; i++){
        checkQuantity = checkQuantity + Tokens[i];
        }

        require(IERC20(Token_CA).balanceOf(address(this)) >= checkQuantity, "Not Enough Tokens!"); 

        for (uint i=0; i < Wallets.length; i++) {
            IERC20(Token_CA).transfer(Wallets[i], Tokens[i]*10**Decimals);
        }
    }












    // Airdrop exact amount of tokens - BE VERY CAREFUL USING THIS FUNCTION! Exported holders may not show correct blacne after the decimal.
    function AirDrop_Exact(address Token_CA, address[] calldata Wallets, uint256[] calldata Tokens) external onlyOwner {

        // Check owner has access
        if (!Access__Unlimited){
            require(block.timestamp <= Access__Until, "You do not have access");
        }

        // Limit array length to avoid out of gas error
        require(Wallets.length <= 500, "Limit sending to 500 to reduce errors"); 
        require(Wallets.length == Tokens.length, "Token and Wallet count missmatch!");

        uint256 checkQuantity = 0;

        for(uint i=0; i < Wallets.length; i++){
        checkQuantity = checkQuantity + Tokens[i];
        }

        require(IERC20(Token_CA).balanceOf(address(this)) >= checkQuantity, "Not Enough Tokens!"); 

        for (uint i=0; i < Wallets.length; i++) {
            IERC20(Token_CA).transfer(Wallets[i], Tokens[i]);
        }
    }





    // Redeploying contract - Airdrop existing holders new tokens!
    // Old and new token must have same decimals!
    function Airdrop_Match(address Old_Token_CA, address New_Token_CA, address[] calldata Wallets) external onlyOwner {

        // Check owner has access
        if (!Access__Unlimited){
            require(block.timestamp <= Access__Until, "You do not have access");
        }


        // Check balance of all holders
        uint256 Tokens_Req = 0;
            for(uint i=0; i < Wallets.length; i++){
                Tokens_Req += IERC20(Old_Token_CA).balanceOf(Wallets[i]);
            }

        require(IERC20(New_Token_CA).balanceOf(address(this)) >= Tokens_Req, "Not Enough Tokens!");

        uint256 Token_Amount = 0;

            // Airdrop tokens based on old tokens held
            for(uint i=0; i < Wallets.length; i++){

                // Get amount
                Token_Amount = IERC20(Old_Token_CA).balanceOf(Wallets[i]);

                // Airdrop Amount
                IERC20(New_Token_CA).transfer(Wallets[i], Token_Amount);
            }
    }







    // Get Token Total for List of Holders
    function Check_Holder_Total(address Token_CA, address[] calldata Wallets) external view returns(uint256 Tokens_Required) {

        // Check owner has access
        if (!Access__Unlimited){
            require(block.timestamp <= Access__Until, "You do not have access");
        }


        // Check balance of all holders
        uint256 Tokens_Req = 0;
            for(uint i=0; i < Wallets.length; i++){
                Tokens_Req += IERC20(Token_CA).balanceOf(Wallets[i]);
            }

        return Tokens_Req;

    }




    // Reclaim tokens
    function Purge_Tokens(address Token_CA, uint256 Percent) public onlyOwner returns(bool _sent){
        uint256 totalRandom = IERC20(Token_CA).balanceOf(address(this));
        uint256 removeRandom = totalRandom * Percent / 100;
        _sent = IERC20(Token_CA).transfer(msg.sender, removeRandom);
    }




    // Purge BNB
    function Purge_BNB() public onlyOwner {
        uint256 BNB = address(this).balance;
        if (BNB > 0) {
        (bool sent, bytes memory data) = msg.sender.call{value: BNB}("");
        }
    }

    receive() external payable {}

    // Send BNB
    function send_BNB(address _to, uint256 _amount) internal returns (bool Sent) {
                                
        (Sent,) = payable(_to).call{value: _amount}("");

    }
    

}