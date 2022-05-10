/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

// SPDX-License-Identifier: UNLISCENSED

pragma solidity ^0.8.4;

interface IERC20 {
    
     /**
     * @dev returns the tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

     /**
     * @dev returns the decimal places of a token
     */
    function decimals() external view returns (uint8);

    /**
     * @dev transfers the `amount` of tokens from caller's account
     * to the `recipient` account.
     *
     * returns boolean value indicating the operation status.
     *
     * Emits a {Transfer} event
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
 
}
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

        modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // Change the owner of the contract_can only be called by owner //
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}
contract Whitelist {
    mapping(address => bool) whitelist;
    event AddedToWhitelist(address indexed account);
    event RemovedFromWhitelist(address indexed account);
    
    // Used to determine msg.sender eligibility //
    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender));
        _;
    }

    // JoinClub only needs to be paid once //
    function JoinClub_1BNB(address _address) public payable {
        require(msg.value == 1 wei);
        whitelist[_address] = true;
        emit AddedToWhitelist(_address);
    }

    // Checks to see if an address is whitelisted //
    function isWhitelisted(address _address) public view returns(bool) {
        return whitelist[_address];
    }
}
contract SMTFaucet is Whitelist, Ownable {
    
    // The token transfered to msg.sender //
    IERC20 token;

    // The token msg.sender must hold //
    IERC20 token2;

     // For rate limiting //
    mapping(address=>uint256) nextRequestAt;
    
    // No.of tokens to send when requested
    uint256 BNB_Share_Amount = 100000000000;
    
    // Sets the addresses of the Owner and the underlying tokens //
    constructor (address _smtAddress, address _smtAddress2, address _ownerAddress) {
        token = IERC20(_smtAddress);
        token2 = IERC20(_smtAddress2);
        owner = _ownerAddress;
    }   
    
    // Sends the BNB_Share_amount to the caller //
    function ClaimYourShare() external {
        require(token.balanceOf(address(this)) > 1,"FaucetError: Empty");
        require(token2.balanceOf(msg.sender) >= 1 );
        require(nextRequestAt[msg.sender] < block.timestamp, "FaucetError: Try again later");
        require(isWhitelisted(msg.sender), "FaucetError: Not Whitelisted");
        // Next request from the address can be made only after 5 minutes and 23 seconds        
        nextRequestAt[msg.sender] = block.timestamp + (5 minutes) + (23 seconds); 
        
        token.transfer(msg.sender,BNB_Share_Amount * 3**token.decimals());
    }  
    
  
}