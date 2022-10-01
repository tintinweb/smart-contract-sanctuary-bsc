/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: Unlicensed

/*

TEST

*/

pragma solidity 0.8.15;

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


contract Test is Ownable  {



    ///// can make pivate and just use the Token Info function for this!
    mapping (address => uint256) public _LOCK_TIME;
    mapping (address => string) public _Website;
    mapping (address => string) public _Telegram;




    // Gets token contract address from the LP pair /// set to external for checks - should be internal?
    function get_CA_from_LP (address LP_Address) public view returns (address Token_CA){

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



    // Gets token contract address from the LP pair /// set to external for checks - should be internal?
    function get_Owner_from_LP (address LP_Address) public view returns (address){

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
    function Token_Information(address LP_Address) public view returns(string memory Token_Name,
                                                       string memory Token_Symbol,
                                                       address Owner_Wallet,
                                                       string memory Website,
                                                       string memory Telegram,
                                                       uint256 Unlock_Time) {

        address TheTokenCA = get_CA_from_LP(LP_Address);


        // Return Token Data /// Needs to get the details of the token not the LP token! 
        return (BEP20(TheTokenCA).name(),
                BEP20(TheTokenCA).symbol(),
                BEP20(TheTokenCA).owner(),
                _Website[LP_Address],
                _Telegram[LP_Address],
                _LOCK_TIME[LP_Address]);

    }

    // Add website and Telegram links for the token
    function Update_Links(address LP_Address, string memory Website_URL, string memory Telegram_URL) public {

        // Check the msg.sender is the owner of the token
        require(msg.sender == get_Owner_from_LP(LP_Address),"You need to be the owner of the token you are updating.");

        // update links
        _Website[LP_Address] = Website_URL;
        _Telegram[LP_Address] = Telegram_URL;



    }
    








    // Get the owner wallet from the CA
    function get_Owner (address Token_CA) public view returns (address){
        return BEP20(Token_CA).owner();
    }
    // Get the token name from the CA
    function get_Name (address Token_CA) public view returns (string memory){
        return BEP20(Token_CA).name();
    }
    // Get the token name from the CA
    function get_Symbol (address Token_CA) public view returns (string memory){
        return BEP20(Token_CA).symbol();
    }



    // Increase timer
    function Add_Days_To_Lock(address LP_Token_Address, uint256 Number_of_Days) external {

        // Check that a lock exists for this LP token - Check that this contract is holding more than 0 of this token!

        // Check msg.sender is owner of the token

        // Get the CA for this LP Token

        // Get the owner for the returned CA

        // The owner must be the message caller

        // 
    }



    // Get the balance of the tokens on the contract
    function remove_Tokens(

        address LP_Token,
        uint256 Percent_to_Remove

        ) payable public {

        // have to pay 0.1 BNB to remove tokens from the locker

        // One of the tokens from the pair MUST be BNB - The other must be owned by the caller

        // Get the CA for this LP Token

        // Get the owner for the returned CA

        // The owner must be the message caller

        // The lock timer must be expired!

        // Sanity Check 
        if(Percent_to_Remove > 100){Percent_to_Remove = 100;}

        // Balance check 
        uint256 total_LP = BEP20(LP_Token).balanceOf(address(this));

        // Amount to remove       
        uint256 remove_LP = total_LP * Percent_to_Remove / 100;

        // Emit the transfer!

        // Transfer to owner
        BEP20(LP_Token).transfer(msg.sender, remove_LP);

    }


    receive() external payable {}

}