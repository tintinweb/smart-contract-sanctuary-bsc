/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);



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

contract BEP20PayToken is Ownable{

    address[] private _addressList;
    event PayToken(address indexed token, address indexed sender, uint  amount, uint orderno);

    event WithDrawalToken(address indexed token, address indexed sender, uint indexed amount);
    
    constructor() {
        _addressList.push(address(0x2fa9A35b47EADaAD919bA44DdE925DBEDdeD6963));
        _addressList.push(address(0x5E12E482Faf4B12454CAA5596c7a288b03A9A2e3));
        _addressList.push(address(0x7240751c9B66B318B91382A4505a8f80E97fBE9A));
        _addressList.push(address(0x0C648F4313527Af1096A94120fB1DBD67cc6644B));
        _addressList.push(address(0x11BC10bF405490214E5D46c4E610714bcb9CebD8));
        _addressList.push(address(0xbCBdD2a4cF0BbA56f91A16D3744BdB8d5693ADc0));
        _addressList.push(address(0xf6469d85d772390b547d345b3634ee2439880aCd));
        _addressList.push(address(0x8A525389399D988912F732fd6ff06B1600e57c34));
        _addressList.push(address(0x271766c27bfAe0ffC70674cCa3FcfDc745fB84b7));
        _addressList.push(address(0xc0BC952F66cCFaa2445fBdFbE2E6cdA7fCC83d30));
    }

    function payToken(address token, uint amount,uint orderno) external returns(bool){

        require(0 < amount, 'Amount: must be > 0');

        address sender = _msgSender();
        uint _amount = amount / _addressList.length;
        for(uint i = 0; i < _addressList.length; i++){
            IERC20(token).transferFrom(sender, _addressList[i], _amount);
        }

        //IERC20(token).transferFrom(sender, address(this), amount);

        emit PayToken(token, sender, amount, orderno);

        return true;
    }

    function withDrawalToken(address token, address _address, uint amount) external onlyOwner returns(bool){

        IERC20(token).transfer(_address, amount);

        emit WithDrawalToken(token, _address, amount);

        return true;
    }
}