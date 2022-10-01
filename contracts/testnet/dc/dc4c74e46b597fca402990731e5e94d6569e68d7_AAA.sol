/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: Unlicensed

/*

TEST

*/

pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = 0xD05895EDF847e1712721Cc9e0427Aa26289A6Bc5;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
}


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



// WBNB
//// address constant BNBADD = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // MAIN NET 
address constant BNBADD = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; // TEST NET 


contract AAA is Ownable  {



    ///// can make pivate and just use the Token Info function for this!
    mapping (address => uint256) private _LOCK_TIME;
    mapping (address => string) private _Website;




    // Gets token contract address from the LP pair /// set to external for checks - should be internal?
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



    // Gets token contract address from the LP pair
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







    // Token information 

    ///// also need = tokens in locker, total tokens, percent in this locker 
    function Token_Information(address LP_Address) public view returns(
                                                       string memory Token_Name,
                                                       string memory Token_Symbol,
                                                       string memory Website,
                                                       uint256 Unlock_Time_Stamp,
                                                       uint256 Days_until_Unlock,
                                                       uint256 Percent_of_LP_Locked) {

        address TheTokenCA = get_CA_from_LP(LP_Address);
        uint256 LP_Percent_Locked = 100 * (BEP20(LP_Address).balanceOf(address(this))) / (BEP20(LP_Address).totalSupply());


        // Convert timestamp to days
        uint256 DaysRemaining = 12; ///////////


/*
             if ((_LOCK_TIME[LP_Address] - block.timestamp) < 86400) {

                DaysRemaining = 0;

             } else {

                DaysRemaining = (_LOCK_TIME[LP_Address] - block.timestamp) / 86400;
             }

*/
        // Return Token Data /// Needs to get the details of the token not the LP token! 
        return (BEP20(TheTokenCA).name(),
                BEP20(TheTokenCA).symbol(),
                _Website[LP_Address],
                _LOCK_TIME[LP_Address],
                DaysRemaining,
                LP_Percent_Locked
                );

    }

    // Add website and Telegram links for the token
    function Update_Website(address LP_Address, string memory Website_URL) public {

        // Check the msg.sender is the owner of the token
        require(msg.sender == get_Owner_from_LP(LP_Address),"You need to be the owner of the token you are updating.");

        // update links
        _Website[LP_Address] = Website_URL;

    }
    









    // Increase timer
    function Update_Lock_Length(address LP_Token_Address, uint256 Unlock_in_X_Days) external {

        // Check the msg.sender is the owner of the token
        require(msg.sender == get_Owner_from_LP(LP_Token_Address),"You need to be the owner of the token you are updating.");

        // Current lock time
        uint256 current_Unlock = _LOCK_TIME[LP_Token_Address];

        // New unlock time
        uint256 new_Unlock = block.timestamp + (Unlock_in_X_Days * 86400);

        // New unlock time must be after current unlock time
        require(new_Unlock >= current_Unlock, "Your new unlock date must be after the current unlock date.");

        // Update the locker time
        _LOCK_TIME[LP_Token_Address] = new_Unlock;

    }


    // Remove LP Tokens from Lock
    function Remove_LP_Tokens(

        address LP_Token_Address,
        uint256 Percent_to_Remove

        ) payable public {

        // NEED TO PAY TO UNLOCK!

        // Check the msg.sender is the owner of the token
        require(msg.sender == get_Owner_from_LP(LP_Token_Address),"You need to be the owner of the token you are updating.");

        // The lock timer must be expired!
        require(block.timestamp >= _LOCK_TIME[LP_Token_Address],"That token is still locked!");

        // Sanity Check 
        if(Percent_to_Remove > 100){Percent_to_Remove = 100;}

        // Balance check 
        uint256 LP_Locked = BEP20(LP_Token_Address).balanceOf(address(this));

        // Amount to remove       
        uint256 remove_LP = LP_Locked * Percent_to_Remove / 100;

        ////// Emit the transfer!

        // Transfer to owner
        BEP20(LP_Token_Address).transfer(msg.sender, remove_LP);

    }


    receive() external payable {}

}