/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

/***
 *    ██████╗  ██████╗ ██╗    ██╗███████╗██████╗ ███╗   ███╗ █████╗ ██████╗ ███████╗
 *    ██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔══██╗████╗ ████║██╔══██╗██╔══██╗██╔════╝
 *    ██████╔╝██║   ██║██║ █╗ ██║█████╗  ██████╔╝██╔████╔██║███████║██║  ██║█████╗  
 *    ██╔═══╝ ██║   ██║██║███╗██║██╔══╝  ██╔══██╗██║╚██╔╝██║██╔══██║██║  ██║██╔══╝  
 *    ██║     ╚██████╔╝╚███╔███╔╝███████╗██║  ██║██║ ╚═╝ ██║██║  ██║██████╔╝███████╗
 *    ╚═╝      ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝
 *    ███████╗ ██████╗ ██████╗ ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
 *    ██╔════╝██╔════╝██╔═══██╗██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║
 *    █████╗  ██║     ██║   ██║███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
 *    ██╔══╝  ██║     ██║   ██║╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║
 *    ███████╗╚██████╗╚██████╔╝███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║
 *    ╚══════╝ ╚═════╝ ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝
 *                                                                                  
 */                                                                                                   
// SPDX-License-Identifier: MIT

pragma solidity 0.5.17;


// Interface of a token BEP20 - ERC20 - TRC20 - .... All functions of the standard interface are declared, even if not used
interface TOKEN20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// Interface to access Powermade contract data
interface Powermade {
    // userInfos getter function (automatically generated because userInfos mapping is public). The getter can only contain standard types, not arrays or other mappings.
    function userInfos(address userAddr) external view returns (uint id, uint referrerID, uint virtualID, uint32 round_robin_next_index, bool banned, uint totalEarned);
    // get the owner 
    function ownerWallet() external view returns (address owner);
    // userIDaddress getter function
    function userIDaddress(uint userID) external view returns (address userAddr);
    // token_addr getter function
    function token_addr() external view returns (address token_address);
    //headWallet getter function
    function headWallet() external view returns (address headWalletAddress);
    // projectWallet getter function
    function projectWallet() external view returns (address projectWalletAddress);
    // lastIDcount getter function
    function lastIDCount() external view returns (uint lastID);
    // businessEnabled getter function
    function businessEnabled() external view returns (bool enabled);
    // Get package info
    function getPackageInfo(uint16 packageID, uint userID) external view returns (uint price, uint duration, bool enabled, bool rebuy_enabled, bool rebuy_before_exp, uint16[] memory prerequisites, uint16[] memory percentages, bool prereq_not_exp, uint totalEarnedPack, uint purchasesCount, uint last_pid);
    // Function used to buy packages (or register users) from external allowed contracts 
    function BuyPackageExt(address userAddr, uint sponsorID, uint16 packageID, bool pay_commissions) external;
}



contract PowermadePackageGifter {

    uint constant private MAX_UINT = 2**256 - 1;

    address public powermadeAddress;
    address public token_address;
    mapping (address => bool) public enabled_gifting_wallets;

    event GiftPackageEv(address indexed payer, uint indexed userID, uint16 packageID);

    // Modifier to be used with functions that can be called only by The Owner of the Powermade Main contract
    modifier onlyPowermadeOwner()
    {
        require(msg.sender == Powermade(powermadeAddress).ownerWallet(), "Denied");
        _;
    }


    // Constructor called when deploying
    constructor(address _powermadeAddress) public {
        powermadeAddress = _powermadeAddress;
        token_address = Powermade(powermadeAddress).token_addr();
        // Approve (infinite) for the Powermade main contract
        bool outcome = TOKEN20(token_address).approve(powermadeAddress, MAX_UINT);
        require(outcome, "Something went wrong");
    }

    // Function used to buy a package as a gift for another user. This function can be called from registered users, owner (projectWallet) and ID1 (headWallet) to airdrop (make a gift) to another already registered user buying him a package (with given packageID).
    function BuyPackageAsGift(uint userID, uint16 packageID) public {
        require(msg.sender == tx.origin, "Sender is not the Tx origin");
        // The business must be enabled
        require(Powermade(powermadeAddress).businessEnabled(), "Business not enabled");
        // The sender must be a registered user or the headWallet or the projectWallet or other enabled gifting wallets
        uint userIDsender;
        (userIDsender, , , , , ) = Powermade(powermadeAddress).userInfos(msg.sender);
        require(userIDsender > 1 || msg.sender == Powermade(powermadeAddress).headWallet() || msg.sender == Powermade(powermadeAddress).projectWallet() || enabled_gifting_wallets[msg.sender], "Sender not Allowed");
        // UserID must be a registered player but not the Head. Note: registered players already bought package 1
        uint lastID = Powermade(powermadeAddress).lastIDCount();
        require(userID > 1 && userID <= lastID, "userID not valid");
        // Deposit funds to the contract, all the funds will be used to buy the package and are exactly the target package amount.
        uint package_price;
        (package_price, , , , , , , , , , ) = Powermade(powermadeAddress).getPackageInfo(packageID, 0);
        depositTokenContract(package_price);
        // Call the internal buy function
        emit GiftPackageEv(msg.sender, userID, packageID);
        address userAddr = Powermade(powermadeAddress).userIDaddress(userID); 
        Powermade(powermadeAddress).BuyPackageExt(userAddr, 0, packageID, true);
    }

    // Utility function to send a token to the smart contract balance
    // The transaction must be approved externally (in JS frontend) with 
    // token_addr.approve(smart_contract, amount)
    function depositTokenContract(uint amount) private {
        require(amount > 0, "You are not sending anything!");
        bool success = TOKEN20(token_address).transferFrom(msg.sender, address(this), amount);
        require(success, "Token transfer to contract failed. Check allowance!");
    }


    // The Powermade owner must call this function if the token used in the Powermade contract has been changed
    function reApproveToken() external onlyPowermadeOwner {
        token_address = Powermade(powermadeAddress).token_addr();
        // Approve (infinite) for the Powermade main contract
        bool outcome = TOKEN20(token_address).approve(powermadeAddress, MAX_UINT);
        require(outcome, "Something went wrong");
    }


    // Extract tokens from the contract (sent to the contract for mistake. There should not be tokens stored into this contract!). Callable only by the Powermade owner
    function retriveTokensContract(address token, uint amount, address destination) external onlyPowermadeOwner {
        bool success = TOKEN20(token).transfer(destination, amount);      // Do the token transfer. The source is the contract itself
        require(success, "Error executing the transaction");
    }

    // Add an extra enabled gifting wallet
    function enableDisableGiftingWallet(address _wallet, bool status) external onlyPowermadeOwner {
        enabled_gifting_wallets[_wallet] = status;
    }


}