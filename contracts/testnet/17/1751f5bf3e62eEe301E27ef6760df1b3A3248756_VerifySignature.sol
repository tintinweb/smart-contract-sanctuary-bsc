/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: KheeloCoinContract.sol

contract VerifySignature is Ownable
{
    address Auth=0x06573d15e3367D7b4a0Cb0668aEef3E2Dc074003;
    
    function getMessageHashUser(string memory _message) private pure returns (bytes32) 
    {
        return keccak256(abi.encodePacked(_message));
    }
    function getMessageHashAuth(string memory _messageAuth) onlyOwner public view returns(bytes32) 
    {
        require(msg.sender==Auth, "not a valid user");
        getMessageHashUser(_messageAuth); 
        return keccak256(abi.encodePacked(_messageAuth));
    }
    function getEthSignedMessageHash(bytes32 _messageHash)public pure returns (bytes32)
    {    
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }
    function verify(address _signer,string memory _message,bytes memory signature) public pure returns (bool) 
    {
        bytes32 messageHash = getMessageHashUser( _message);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, signature) == _signer;
       
    }
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }
    function splitSignature(bytes memory sig) public pure returns (bytes32 r,bytes32 s,uint8 v)
    {
        require(sig.length == 65, "invalid signature length");

        assembly 
        {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
    }
    // Check Cost 
    modifier costs() 
    {
        require(msg.value >= 50000000000000000," NOT ENOUGH BNB PROVIDED! ");
        _;
    }
    // Transfer BNB to Contract Address From User's Wallet
    receive() external payable costs()
    {
        //Everything Works Fine   
    }
    // Check available BNB in contract
    function CheckTokenBalances() public view returns(uint256)
    {
      return address(this).balance;
    }
    // Transfer BNB to players
    function transferBNBToPlayer(address _signer,string memory _message,bytes memory signature) public 
    {
        bool _sign = verify(_signer,_message,signature);
        require(_sign==true,"error");
        payable(msg.sender).transfer(75000000000000000);
    }
    // Transfer BNB to Owner
    function transferBNBToOwner(uint256 amount) onlyOwner public
    {
        payable(0x06573d15e3367D7b4a0Cb0668aEef3E2Dc074003).transfer(amount);
    }
}