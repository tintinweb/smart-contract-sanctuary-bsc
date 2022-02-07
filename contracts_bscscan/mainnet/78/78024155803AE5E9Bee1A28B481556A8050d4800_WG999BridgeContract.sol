// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./Interfaces/WG999BridgeInterface.sol";
import "./Interfaces/WG999Interface.sol";

contract WG999BridgeContract is Ownable, WG999BridgeInterface {

    WG999Interface private _baseTokenInstance;
    IERC20 private _ERC20BaseToken;
    
    address private _moderatorAddress;

    constructor (address tokenAddress) {
        _baseTokenInstance = WG999Interface(tokenAddress);
        _ERC20BaseToken = IERC20(tokenAddress);
    }

    ////////////////
    ///  PUBLIC  ///
    ////////////////
    function migrateOut(string memory to, uint amount) public override returns (bool) {

        _ERC20BaseToken.transferFrom(msg.sender, address(this), amount);
        _baseTokenInstance.Burn(amount);
        emit MigrationOut(msg.sender, to, amount);
        return true;
    }
        
    //////////////////
    ///  MODERATOR ///
    //////////////////
    function migrateIn(string memory from, address to, uint amount) public override returns(bool) {
        require (msg.sender == _moderatorAddress, "This can only be executed through moderator address!");
        
        _baseTokenInstance.Mint(address(this), amount);
        _ERC20BaseToken.transfer(to, amount);
        emit MigrationIn(from, to, amount);
        return true;
    }

    ///////////////
    ///  OWNER  ///
    ///////////////
    
    function setBaseToken(address tokenAddress) onlyOwner public override returns (bool) {
        _baseTokenInstance = WG999Interface(tokenAddress);
        _ERC20BaseToken = IERC20(tokenAddress);
        return true;
    }
    
    function setModerator(address moderatorAddress) onlyOwner public override returns (bool) {
        _moderatorAddress = moderatorAddress;
        return true;
    }

    function salvageTokensFromContract(address tokenAddress, address to, uint amount) onlyOwner public override returns (bool){
        IERC20(tokenAddress).transfer(to, amount);
        return true;
    }
    function killContract() onlyOwner override public {
        selfdestruct(payable(msg.sender));
    }

    ////////////////
    ///  PUBLIC  ///
    ////////////////
    function getBaseTokenAddress() public view override returns(address) {
        return address(_baseTokenInstance);
    }
    function getModeratorAddress() public view override returns(address) {
        return address(_moderatorAddress);
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface WG999BridgeInterface {

    ////////////////
    ///  PUBLIC  ///
    ////////////////
    function migrateOut(string memory to, uint amount) external returns (bool);

    //////////////////
    ///  MODERATOR ///
    //////////////////
    function migrateIn(string memory from, address to, uint amount) external returns(bool);

    ///////////////
    ///  OWNER  ///
    ///////////////
    function setBaseToken(address tokenAddress) external returns (bool);
    function setModerator(address moderatorAddress) external returns (bool);
    function salvageTokensFromContract(address tokenAddress, address to, uint amount) external returns (bool);
    function killContract() external;

    ////////////////
    ///  PUBLIC  ///
    ////////////////
    function getBaseTokenAddress() external view returns(address);
    function getModeratorAddress() external view returns(address);
    
    ////////////////
    ///  EVENTS  ///
    ////////////////
    event MigrationOut(address indexed from, string to, uint amount);
    event MigrationIn(string from, address indexed to,  uint amount);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface WG999Interface {

    //
    // Public
    //
    function doBurn(uint amount) external returns(bool);
    function Mint(address to, uint amount) external returns (bool);
    function Burn(uint amount) external returns (bool);
    
    //
    // Owner
    //
    function setBurningContractAddress(address burningContractAddress) external returns(bool);
    function setupMinter(address minterAddress, bool activity) external returns(bool);
    function setupBurner(address burnerAddress, bool activity) external returns(bool);
    function pause() external returns(bool);
    function unpause() external returns(bool);

    //
    // Public
    //
    function isBurner(address burnerAddress) external view returns(bool);
    function isMinter(address mintingAddress) external view returns(bool);
    function getBurningContractAddress() external view returns (address);
    function getSupplyCap() external view returns (uint);
}

// SPDX-License-Identifier: MIT
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