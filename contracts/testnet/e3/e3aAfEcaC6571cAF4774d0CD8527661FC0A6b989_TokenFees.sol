// SPDX-License-Identifier: UNLICENSED
// Digichain Company all rights on this code. You may NOT copy these contracts.

/*
 * DigichainCoin 
 * App:             https://digichaincoin.com
 * Medium:          https://digichaincoin.medium.com
 * Twitter:         https://twitter.com/digichaincoin
 * Telegram:        https://t.me/prodigitalchain
 * Announcements:   https://t.me/digichaincoin_news
 * GitHub:          https://github.com/digichaincoin
 * Dev              Tommy Chain Dev
 */

pragma solidity ^0.8.0;

import "./Ownable.sol";

interface ITokenFees {
    function getFlatFee() view external returns(uint256);
    function setFlatFee(uint _tokenFee) external;

    function getTotalSupplyFee() view external returns(uint256);
    function setTotalSupplyFee(uint _tokenFee) external;
    
    function getTokenFeeAddress() view external returns(address);
    function setTokenFeeAddress(address payable _tokenFeeAddress) external;
}

contract TokenFees is Ownable{
    
    struct Settings {
        uint256 FLAT_FEE;
        uint256 TS_FEE; // totalSupply fee
        address payable TOKEN_FEE_ADDRESS;
    }
    
    Settings public SETTINGS;
    
    constructor() {
        SETTINGS.FLAT_FEE = 1e18;
        SETTINGS.TS_FEE = 2;
        SETTINGS.TOKEN_FEE_ADDRESS = payable(0x14f1d0b47ABB50FB9D5c49B3cE5b2c318d14c621);
    }
    
    function getFlatFee() view external returns(uint256) {
        return SETTINGS.FLAT_FEE;
    }
    
    function setFlatFee(uint _flatFee) external onlyOwner {
        SETTINGS.FLAT_FEE = _flatFee;
    }

    function getTotalSupplyFee() view external returns(uint256) {
        return SETTINGS.TS_FEE;
    }
    
    function setTotalSupplyFee(uint _tsFee) external onlyOwner {
        SETTINGS.TS_FEE = _tsFee;
    }
    
    function getTokenFeeAddress() view external returns(address) {
        return SETTINGS.TOKEN_FEE_ADDRESS;
    }
    
    function setTokenFeeAddress(address payable _tokenFeeAddress) external onlyOwner {
        SETTINGS.TOKEN_FEE_ADDRESS = _tokenFeeAddress;
    }
}

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/access/[email protected]

pragma solidity ^0.8.0;

import "./Context.sol";
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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/utils/[email protected]

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}