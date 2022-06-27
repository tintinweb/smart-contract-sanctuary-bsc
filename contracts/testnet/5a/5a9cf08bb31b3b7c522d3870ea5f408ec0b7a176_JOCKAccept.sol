/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

pragma solidity ^0.4.0;

// abstract contract Context {
//     function _msgSender() internal view virtual returns (address payable) {
//         return msg.sender;
//     }

//     function _msgData() internal view virtual returns (bytes memory) {
//         this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
//         return msg.data;
//     }
// }

// contract Ownable is Context {
//     address private _owner;
//     address private _previousOwner;
//     uint256 private _lockTime;

//     event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

//     /**
//      * @dev Initializes the contract setting the deployer as the initial owner.
//      */
//     constructor () internal {
//         address msgSender = _msgSender();
//         _owner = msgSender;
//         emit OwnershipTransferred(address(0), msgSender);
//     }

//     /**
//      * @dev Returns the address of the current owner.
//      */
//     function owner() public view returns (address) {
//         return _owner;
//     }

//     /**
//      * @dev Throws if called by any account other than the owner.
//      */
//     modifier onlyOwner() {
//         require(_owner == _msgSender(), "Ownable: caller is not the owner");
//         _;
//     }

//     /**
//     * @dev Leaves the contract without owner. It will not be possible to call
//     * `onlyOwner` functions anymore. Can only be called by the current owner.
//     *
//     * NOTE: Renouncing ownership will leave the contract without an owner,
//     * thereby removing any functionality that is only available to the owner.
//     */
//     function renounceOwnership() public virtual onlyOwner {
//         emit OwnershipTransferred(_owner, address(0));
//         _owner = address(0);
//     }

//     /**
//      * @dev Transfers ownership of the contract to a new account (`newOwner`).
//      * Can only be called by the current owner.
//      */
//     function transferOwnership(address newOwner) public virtual onlyOwner {
//         require(newOwner != address(0), "Ownable: new owner is the zero address");
//         emit OwnershipTransferred(_owner, newOwner);
//         _owner = newOwner;
//     }

//     function geUnlockTime() public view returns (uint256) {
//         return _lockTime;
//     }

//     //Locks the contract for owner for the amount of time provided
//     function lock(uint256 time) public virtual onlyOwner {
//         _previousOwner = _owner;
//         _owner = address(0);
//         _lockTime = now + time;
//         emit OwnershipTransferred(_owner, address(0));
//     }

//     //Unlocks the contract for owner when _lockTime is exceeds
//     function unlock() public virtual {
//         require(_previousOwner == msg.sender, "You don't have permission to unlock");
//         require(now > _lockTime , "Contract is locked until 7 days");
//         emit OwnershipTransferred(_owner, _previousOwner);
//         _owner = _previousOwner;
//     }
// }

// interface ITransferOwner {
//     function acceptOwner() external;
// }

// contract JOCKAccept is  Ownable {
contract JOCKAccept  {
    // address  public jockAdd;

    // constructor (address _jockAdd) public {
    //     jockAdd = _jockAdd;
    // }
    
    // function setAddress(address _add) external onlyOwner() {
    //     jockAdd = _add;
    // }
    
    function acceptOwner1(address _jockAdd) public {
         _jockAdd.call(bytes4(keccak256("acceptOwner()")));
    }
    function acceptOwner2(address _jockAdd) public {
        _jockAdd.callcode(bytes4(keccak256("acceptOwner()")));
    }
    
    // receive() external payable {}/* can accept ether */
}