/**
 *Submitted for verification at BscScan.com on 2022-10-02
*/

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


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: contracts/House_Wallet.sol


pragma solidity ^0.8.7;


contract Multiple_Transaction is Ownable {

    uint256 playerFee;
    uint256 holderFee;
    uint256 ownerFee;
    uint256 liquidityFee;
    uint256 housewalletFee;

    address Fee_Wallet;
    address Liqudity_Address;
    address Housewallet_Address;
    address Owner_Address; 

    address [] shootA;


     constructor(address _Housewallet,address _Fee_Wallet, address _Liqudity_Address, address _Owner_Address) {
        setHousewallet_Address(_Housewallet);
        setFee_Wallet(_Fee_Wallet);
        setLiqudity_Address( _Liqudity_Address);
        setOwner_Address(_Owner_Address);
       
    }

    receive() external payable {}

    function shoot() external payable{
        require (0.32 * 10**18 >= msg.value && 0.006 * 10**18 <= msg.value);
        playerFee = ((msg.value * 35) / 1035);
        housewalletFee=(msg.value - playerFee);
        shootA.push(msg.sender);       
        send();      

    }

    function send() private{        
        housewalletFee=(msg.value - playerFee);
        payable(Fee_Wallet).transfer((housewalletFee * 2) / 100);
        payable(Liqudity_Address).transfer((housewalletFee * 1) / 100);
        payable(Owner_Address).transfer((housewalletFee * 25) / 10000);
        payable(Housewallet_Address).transfer(address(this).balance);          
        
    }

    function setHousewallet_Address(address _Housewallet_Address) public onlyOwner {
        Housewallet_Address = _Housewallet_Address;
    
    }

    function setFee_Wallet(address _Fee_Wallet) public onlyOwner {
        Fee_Wallet = _Fee_Wallet;
        
    }

        function setLiqudity_Address(address _Liqudity_Address) public onlyOwner {
        Liqudity_Address = _Liqudity_Address;
    
    }

    function setOwner_Address(address _Owner_Address) public onlyOwner {
        Owner_Address = _Owner_Address;
        
    }
  
}