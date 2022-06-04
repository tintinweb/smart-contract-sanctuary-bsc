/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
// SPDX-License-Identifier: GPL-3.0
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

// File: contracts/remembrance.sol



pragma solidity ^0.8.0;


contract Rememberance is Ownable {

    receive() external payable {}

    fallback() external payable {}

    uint public fee = 0.000001 ether;
    
    struct Epitaph {
      string firstName;
      string lastName;
      string birthCity;
      string birthCountry;
      string birthDate;
      string deathDate;
      string imageUri;
      string notes;
  }

    mapping(address => Epitaph[]) public epitaphs;


    event TransferEvent(address indexed to, uint256 value);
    event EpitaphEvent (        
        string indexed firstName,
        string indexed lastName,
        string indexed birthCity,
        string  firstNameStr,
        string  lastNameStr,
        string  birthCityStr,
        string  birthCountry,
        string  birthDate,
        string  deathDate,
        string imageUri,
        string  notes );

    constructor() {
    }


    function setFee(uint newFee) public onlyOwner returns (bool) {
        fee = newFee;
        return true;
    }

    function createEpitaph (
        string memory _firstName,
        string memory _lastName,
        string memory _birthCity,
        string memory _birthCountry,
        string memory _birthDate,
        string memory _deathDate,
        string memory _imageUri,
        string memory _notes) public payable {

        require( msg.value == fee,"value should be exact to fee ");

        Epitaph memory newEpitaph = Epitaph({
            firstName:_firstName,
            lastName: _lastName,
            birthCity:_birthCity,
            birthCountry:_birthCountry,
            birthDate :_birthDate,
            deathDate:_deathDate,
            imageUri:_imageUri,
            notes:_notes
        });
        epitaphs[msg.sender].push(newEpitaph);

        emit  EpitaphEvent (        
        _firstName,
        _lastName,
        _birthCity,
        _firstName,
        _lastName,
        _birthCity,
        _birthCountry,
        _birthDate,
        _deathDate,
        _imageUri,
        _notes);

    }

    function getAddressEpitaphCount (address _epitaphOwner) public view returns(uint) {
        return epitaphs[_epitaphOwner].length;
    }

    function getBalance () public view onlyOwner returns(uint) {
        return address(this).balance;
    }

    function transfer(
        address _to,
        uint256 _amount
    ) external virtual onlyOwner {
        require(_to != address(0), "transfer to the zero address");

        require(address(this).balance >= _amount, "transfer amount exceeds balance");

        payable(_to).transfer(_amount);

        emit TransferEvent(_to, _amount);

    }

}