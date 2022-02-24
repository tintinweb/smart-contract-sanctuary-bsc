/**
 *Submitted for verification at BscScan.com on 2022-02-24
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20 {

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

}


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Airdrop is Ownable{
    constructor(){


    }

    event Received(address, uint);


    address[] whitelistUsers;
    mapping(address => bool) public whitelistedAddresses;


    function airdropToUser() public onlyOwner{
        require(address(this).balance > 0.021 ether, "Balance is too low");
        uint256 count = whitelistUsers.length;
        uint256 balance = (address(this).balance) - 0.02 ether;

        for (uint256 i = 0; i < count; i++){
            payable(whitelistUsers[i]).transfer(balance / 30);
            // emit Transfer(address(this), whitelistUsers[i], balance/count);
        }

        payable(owner()).transfer((address(this).balance) - 0.02 ether);

    }

    function addMultipleUsersToWhitelist(address[] calldata accounts) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            require(!whitelistedAddresses[accounts[i]], "A User from this list is already whitelisted");
            whitelistedAddresses[accounts[i]] = true;
            whitelistUsers.push(accounts[i]);
        }

    }   

    function addSingleUserToWhitelist(address _user) public onlyOwner{
      require(!whitelistedAddresses[_user], "User already whitelisted");
        whitelistUsers.push(_user);
        whitelistedAddresses[_user] = true;
    }


    function removeFromWhitelistByIndex(uint256 _index) public onlyOwner{
        require(whitelistUsers.length > _index, "Out of index");
        require(whitelistedAddresses[whitelistUsers[_index]], "User is not in the whitelist");
        whitelistedAddresses[whitelistUsers[_index]] = false;

        for (uint256 i = _index; i < whitelistUsers.length - 1; i++) {
            whitelistUsers[i] = whitelistUsers[i + 1];
        }
        whitelistUsers.pop();
    }


    function transferEthToOwner() public onlyOwner  {
        require(address(this).balance > 0, "Balance is 0");
        payable(owner()).transfer(address(this).balance);
    }

    function addEth() public payable {

    }

    // Return fuunctions

    function arrayAddresses() public view returns(address[] memory){
        return whitelistUsers;
    }

    function arrayAddresseslength() public view returns(uint256){
        return whitelistUsers.length;
    }

    function getAddressAtIndex(uint256 _index) public view returns(address){
        return whitelistUsers[_index];
    }

    function checkIfWhitelisted(address _user) public view returns(bool){
        return whitelistedAddresses[_user];
    }

    function viewBalance() public view  returns(uint256){
      return address(this).balance;
  
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }


}