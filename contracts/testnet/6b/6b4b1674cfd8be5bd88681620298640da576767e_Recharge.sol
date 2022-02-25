/**
 *Submitted for verification at BscScan.com on 2022-02-25
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

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




contract Recharge is Ownable{



    IERC20 private usdt;
    IERC20 private hnt;

    address receiveAddess;



    constructor(address _u, address _h, address  _receiveAddress) {

       usdt = IERC20(_u);
       hnt = IERC20(_h);
       receiveAddess = _receiveAddress;

    }




    event RechargeUsdt(address sender, uint value);

    event RechargeHnt(address sender, uint value);






    function rechargeUsdt(uint amount) external returns(bool){
        address sender = _msgSender();
        _recharge(usdt, sender, amount);
        emit RechargeUsdt(sender, amount);
        return true;
    }


    function rechargeHnt(uint amount) external returns(bool){
        address sender = _msgSender();
        _recharge(hnt, sender, amount);
        emit RechargeHnt(sender, amount);
        return true;
    }


    function _recharge(IERC20 erc20, address sender, uint amount) private {
        require(0 < amount, 'Amount can not be less then zero');
        erc20.transferFrom(sender, receiveAddess, amount);
    }



    function resetReceive(address _receiveAddress) external onlyOwner returns(bool){
        receiveAddess = _receiveAddress;
        return true;
    }


    function resetToken(address  _usdt, address  _hnt) external onlyOwner returns(bool){
        if(_usdt != address(usdt)){
            usdt = IERC20(_usdt);
        }
        if(_hnt != address(hnt)){
            hnt = IERC20(_hnt);
        }
        return true;
    }


    function recoverToken(address  _address, address  _receive) external onlyOwner returns(bool){
        IERC20 erc = IERC20(_address);
        erc.transfer(_receive, erc.balanceOf(address(this)));
        return true;
    }


}