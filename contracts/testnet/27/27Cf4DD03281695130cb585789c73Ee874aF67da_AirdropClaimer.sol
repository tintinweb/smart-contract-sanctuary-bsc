pragma solidity ^0.8.7;

import "./Ownable.sol";

contract AirdropClaimer is Ownable {

    struct Airdrop {

        string _name;
        mapping( address => uint256 ) _claimableValue;
    }

    //Airdrop[] private airdrops;
    uint airdropCount;
    mapping( uint => Airdrop ) public _airdrops;

    event _addAirdrop( string name, address[] addresses, uint256[] claimableValues );

    //TODO Check dell'unicità del nome (funzione)
    function addAirdrop( string memory name, address[] memory addresses, uint256[] memory claimableValues ) external onlyOwner{

        Airdrop storage newAirdrop = _airdrops[airdropCount];
        airdropCount++;
        newAirdrop._name = name;

        for(uint i = 0; i < addresses.length; i++){
            newAirdrop._claimableValue[addresses[i]] = claimableValues[i];
        }

        emit _addAirdrop(name, addresses, claimableValues);
    }

    function getlistAirdrop() public view {
        for(uint i = 0; i < airdropCount; i++){
            getAirdrop(i);
        }
    }

    function getAirdrop( uint _index ) public view returns ( string memory _name ){
        return (_airdrops[_index]._name);
    }

    function removeAirdrop( string memory name ) external onlyOwner {

        for(uint i = 0; i < airdropCount; i++){

            if (keccak256(abi.encodePacked(_airdrops[i]._name)) == keccak256(abi.encodePacked(name))) {
                delete _airdrops[i];
            }
        }

    }
}

pragma solidity ^0.8.7;

import { Context } from "./Context.sol";

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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
    * @dev Leaves the contract without owner. It will not be possible to call
    * `onlyOwner` functions anymore. Can only be called by the current owner.
    *
    * NOTE: Renouncing ownership will leave the contract without an owner,
    * thereby removing any functionality that is only available to the owner.
    */
    function renounceOwnership() external onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
    * @dev Transfers ownership of the contract to a new account (`newOwner`).
    * Can only be called by the current owner.
    */
    function transferOwnership(address newOwner) external onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
    * @dev Transfers ownership of the contract to a new account (`newOwner`).
    */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.8.7;


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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () { }

    function _msgSender() internal view virtual returns(address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns(bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}