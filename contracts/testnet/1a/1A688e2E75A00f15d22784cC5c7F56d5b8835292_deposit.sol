// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./Ownable.sol";

interface IERC20 {
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
}

contract deposit is Ownable{
    uint[5] public slab;
    uint[5] public slabTotal;
    struct userDeposit{
        uint balance;
        uint level;
    }
    mapping(address => userDeposit) public depositAmount;
    address public ERC20;
    event depositBYuser(address indexed depositor, uint indexed _amount);
    constructor(address _erc20){
        ERC20 = _erc20;
    }

    function setLevel(uint[5] calldata _amount) public onlyOwner{
        slab[0] = _amount[0];
        slabTotal[0] += _amount[0];
        for(uint i=1;i<5;i++){
            slab[i] = _amount[i];
            slabTotal[i] =slabTotal[i-1] + _amount[i];
        }
    }
//slab[0] = 500; slab[1] = 400; slab[2] = 300 ....
//slabTotal[0] = 500 ; slabTotal[1] = 900
    function depositByUser(uint _amount) public returns(bool){
        userDeposit memory user = depositAmount[msg.sender];
        uint bal = user.balance;
        uint userSlab = user.level;
        uint total;
        uint space;
        user.balance += _amount;
        IERC20(ERC20).transferFrom(msg.sender,address(this),_amount);
        if(bal + _amount >= slabTotal[4]){            
            depositAmount[msg.sender] = user;
            emit depositBYuser(msg.sender,_amount);
            return true;
        }
        else{        
            total = slabTotal[userSlab];
            space = total - bal;
            if(_amount > space){
                _amount -= space;
                while(_amount != 0){
                    uint y = slab[userSlab+1];
                    if(_amount > y){
                        _amount = _amount - y;
                        userSlab +=1;
                    }
                    else{
                        user.level = userSlab+1;
                        depositAmount[msg.sender] = user;
                        emit depositBYuser(msg.sender,_amount);
                        return true;
                    }
                }
            }
            else{
                depositAmount[msg.sender] = user;
                emit depositBYuser(msg.sender,_amount);
                return true;
            }
        }
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

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

pragma solidity ^0.8.7;

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