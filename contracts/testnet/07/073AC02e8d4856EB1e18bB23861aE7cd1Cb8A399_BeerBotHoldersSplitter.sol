/**
 *Submitted for verification at BscScan.com on 2022-12-27
*/

// SPDX-License-Identifier: MIT

// Sources flattened with hardhat v2.12.1 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/access/[email protected]


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


// File @openzeppelin/contracts/security/[email protected]


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


// File contracts/BeerBotHoldersSplitter.sol


pragma solidity ^0.8.9;
/**
* @dev iterfaces of IERC20 that would be used
*/
interface IERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);
    function balanceOf(address _account) external returns (uint256);
}

contract BeerBotHoldersSplitter is Ownable{

    mapping (bytes32 => address) public whiteListedTokens;  

    constructor(){
        
    }

    /**
     * @dev whith this function the owner can add or edit token addresses
     */
    function whitelistToken(bytes32 _symbol, address tokenAddress)
        external
        onlyOwner
        {
            whiteListedTokens[_symbol] = tokenAddress;
        }

    function whiteListedTokenAddress(bytes32 _symbol)
        external
        view
        returns (address)
        { 
            require(whiteListedTokens[_symbol] != 0x0000000000000000000000000000000000000000, "splitToHolders: not whitelited token");
            return whiteListedTokens[_symbol];
        }
    

    /**
     * @dev this returns the token especified balance of this contract
     */
    function symbolContractBalance(bytes32 _symbol) 
        public   
        returns (uint256)
        {
            return IERC20(whiteListedTokens[_symbol]).balanceOf(address(this));
        }

    /**
     * @dev this transfers USDT that belong to your contract to the specified address
     */
    function sendSymbolTo(bytes32 _symbol, address _to, uint256 _amount) 
        internal 
        onlyOwner
        {         
            IERC20 token = IERC20(whiteListedTokens[_symbol]);        
            token.transfer(_to, _amount);
        }

    /**
     * @dev this recives an array of address and array of percentages in basis points, so...
     * 0.01% =	  1 bps
     * 0.1%	 =   10 bps
     * 0.5%	 =   50 bps
     * 1%	 =  100 bps
     * 10%	 =  1000 bps
     * 100%	 = 10000 bps
     */
    function splitToHolders(bytes32 _symbol, address[] memory payees, uint16[] memory shares_) 
        external
        payable 
        onlyOwner        
        {
            require(payees.length > 0, "splitToHolders: no payees");
            require(payees.length == shares_.length, "splitToHolders: payees and shares length mismatch");
            require(whiteListedTokens[_symbol] != 0x0000000000000000000000000000000000000000, "splitToHolders: not whitelited token");
            require(symbolContractBalance(_symbol) > 0, "splitToHolders: no funds of token");

            uint256 payment = 0;
            uint256 tokenBaseValue = IERC20(whiteListedTokens[_symbol]).balanceOf(address(this));
            
            for(uint16 i = 0; i < payees.length; i++) {
                payment =  tokenBaseValue * shares_[i] / 10000;                                
                sendSymbolTo(_symbol, payees[i], payment);
            }
        }

}