/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: Unlicensed 
// This contract is not open source and can not be used/forked without permission

/*

    -------------------------------
    AIRDROP TOOL BY TOKENSBYGEN.COM
    -------------------------------

    ****** IMPORTANT WARNING ******

    Before you begin, follow the step-by-step guide at https://tokensbygen.com/airdrop.html

    Even if you have done airdrops before, this contract may not work the way that you expect.
    We can accept no responsibility for loses due to the incorrect use of this contract.

    Created by GenTokens. Supporting GEN, The flagship token of the GenTokens Community.


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

    address payable private _owner;
    address payable public Wallet_Affiliate;
    bool public Access__Unlimited;
    uint256 public Access__Until = 0;

    // Affiliate Tracking
    IERC20 GEN = IERC20(0x7d7a7f452e04C2a5df792645e8bfaF529aDcCEcf); // GEN - For tracking affiliate level
    IERC20 AFT = IERC20(0x98A70E83A53544368D72940467b8bB05267632f4); // Wallet_Affiliate Tracker Token
    uint256 private constant Tier_2 =  500000 * 10**9; 
    uint256 private constant Tier_3 = 1000000 * 10**9; 


    constructor (address payable _Owner,
                 address payable _Code
                ) {

                 _owner = _Owner;
                 Wallet_Affiliate = _Code;
                 Access__Unlimited = false;

                 // Emit ownership transfer of contract
                 emit OwnershipTransferred(address(0), _owner);

    }


    // Restrict function to contract owner only 
    modifier onlyOwner {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }



    // Set fee collector address
    address public Wallet_Fee_Collector = payable(0xde491C65E507d281B6a3688d11e8fC222eee0975);



    function owner() public view returns (address) {
        return _owner;
    }



    // Pay for one day access 0.2 BNB - Enter 0.2 into the function
    function Access_1_Day() public payable onlyOwner {

        uint256 OneDayAccessFee = 2e17;
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

        // Set unlimited access fee to 2BNB - enter 2 into the function
        uint256 Unlimited_Access_Fee = 2e18; 
        require (msg.value == Unlimited_Access_Fee, "Need to pay 2 BNB for full access.");

        // Check for affiliate and distribute commission payments 
        if (msg.value == Unlimited_Access_Fee){

                // Check affiliate is genuine and payment tier
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
                            
                            // Transfer fees
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






    // Update reflections (Airdrop lowest amount of token possible to each wallet)
    function AirDrop_Dust(address Token_CA, address[] calldata Wallets) external onlyOwner {

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






    // Airdrop exact tokens (value includes decimals!)
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





    // Redeploying contract - Airdrop existing holders new tokens. Old and new token must have same decimals!
    function AirDrop_Match(address Old_Token_CA, address New_Token_CA, address[] calldata Wallets) external onlyOwner {

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
                if(Token_Amount > 0){
                    IERC20(New_Token_CA).transfer(Wallets[i], Token_Amount);
                }
            }
    }





    // Airdrop whole tokens (rounded value + decimals)
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






    // Get Token Total for List of Holders - Remember to factor in decimals to final total
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




    // Remove tokens from contract
    function Remove_Tokens(address Token_CA, uint256 Percent) public onlyOwner returns(bool _sent){
        uint256 totalRandom = IERC20(Token_CA).balanceOf(address(this));
        uint256 removeRandom = totalRandom * Percent / 100;
        _sent = IERC20(Token_CA).transfer(msg.sender, removeRandom);
    }




    // Remove BNB from contract 
    function Remove_BNB() public onlyOwner {
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