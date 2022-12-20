// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./ITake.sol";


contract Take is  Ownable,Pausable,ITake{

mapping ( uint256 => Drawcheck) public DrawBase;

    uint256 public Distribution_number;

    //общий процент от введенного числа по ящикам 
    uint256[10] public ProcentChest = [17,15,14,12,11,9,8,6,4,4];//+
    //на сколько ящиков дробить 
    uint256[10] public number_of_chests_=[200,150,100,60,50,40,20,15,10,5];

   struct Drawcheck {
    uint256 allMITI;
    uint256 allUSDT;
    uint256[10] One_chests_MITI;
    uint256[10] One_chests_USDT;
   }

   function NewBalance (uint256 Summa_MITI,uint256 Summa_USDT) public onlyOwner {
    Distribution_number++;
    
    uint256 One_MITI = Summa_MITI/100;
    uint256 One_USDT = Summa_USDT/100;

    Drawcheck memory newDrawcheck;
    newDrawcheck.allMITI = Summa_MITI;
    newDrawcheck.allUSDT = Summa_USDT;

    uint256 B;
    while (B<=9) {
        uint256 MITI__ = One_MITI*ProcentChest[B];
    newDrawcheck.One_chests_MITI[B] =MITI__/number_of_chests_[B];

        uint256 USDT__=One_USDT*ProcentChest[B];
    newDrawcheck.One_chests_USDT[B] =USDT__/number_of_chests_[B];
    B++;
    }
    DrawBase[Distribution_number] = newDrawcheck;
    }


    //Get______________________________________________

   function Get_Distribution_number () public virtual override view returns (uint256) {
    return Distribution_number;
   }

   function Get_One_chest_MITI ( uint256 num_Track, uint256 chest_num) public virtual override view returns (uint256) {
    return DrawBase[num_Track].One_chests_MITI[chest_num-1]; 
   } 

   function Get_One_chest_USDT ( uint256 num_Track, uint256 chest_num) public virtual override view returns (uint256) {
    return DrawBase[num_Track].One_chests_USDT[chest_num-1]; 
   } 

   function Get_Track_all (uint256 num_Track) public virtual override view returns (
    uint256 allMITI_,uint256 allUSDT_  ){
     allMITI_ = DrawBase[num_Track].allMITI;
     allUSDT_ = DrawBase[num_Track].allUSDT;
   }

   function Get_Track_1_2_3_4_5 (uint256 num_Track) public virtual override view returns( 
    uint256 One_chests_MITI_1, uint256 One_chests_USDT_1,
    uint256 One_chests_MITI_2, uint256 One_chests_USDT_2,
    uint256 One_chests_MITI_3, uint256 One_chests_USDT_3,
    uint256 One_chests_MITI_4, uint256 One_chests_USDT_4,
    uint256 One_chests_MITI_5, uint256 One_chests_USDT_5) {
        One_chests_MITI_1 = DrawBase[num_Track].One_chests_MITI[0];
     One_chests_USDT_1 = DrawBase[num_Track].One_chests_USDT[0];

     One_chests_MITI_2 = DrawBase[num_Track].One_chests_MITI[1];
     One_chests_USDT_2 = DrawBase[num_Track].One_chests_USDT[1];

     One_chests_MITI_3 = DrawBase[num_Track].One_chests_MITI[2];
     One_chests_USDT_3 = DrawBase[num_Track].One_chests_USDT[2];

     One_chests_MITI_4 = DrawBase[num_Track].One_chests_MITI[3];
     One_chests_USDT_4 = DrawBase[num_Track].One_chests_USDT[3];

     One_chests_MITI_5 = DrawBase[num_Track].One_chests_MITI[4];
     One_chests_USDT_5 = DrawBase[num_Track].One_chests_USDT[4];
    }

    function Get_Track_6_7_8_9_10 (uint256 num_Track) public virtual override view returns( 
    uint256 One_chests_MITI_6, uint256 One_chests_USDT_6,
    uint256 One_chests_MITI_7, uint256 One_chests_USDT_7,
    uint256 One_chests_MITI_8, uint256 One_chests_USDT_8,
    uint256 One_chests_MITI_9, uint256 One_chests_USDT_9,
     uint256 One_chests_MITI_10, uint256 One_chests_USDT_10) {
        One_chests_MITI_6 = DrawBase[num_Track].One_chests_MITI[5];
     One_chests_USDT_6 = DrawBase[num_Track].One_chests_USDT[5];

     One_chests_MITI_7 = DrawBase[num_Track].One_chests_MITI[6];
     One_chests_USDT_7 = DrawBase[num_Track].One_chests_USDT[6];

     One_chests_MITI_8 = DrawBase[num_Track].One_chests_MITI[7];
     One_chests_USDT_8 = DrawBase[num_Track].One_chests_USDT[7];

     One_chests_MITI_9 = DrawBase[num_Track].One_chests_MITI[8];
     One_chests_USDT_9 = DrawBase[num_Track].One_chests_USDT[8];

     One_chests_MITI_10 = DrawBase[num_Track].One_chests_MITI[9];
     One_chests_USDT_10= DrawBase[num_Track].One_chests_USDT[9];

    }

    //Set _____________

    function set_num_Chest (uint256[] memory _num_ches) public onlyOwner {
        uint256 A;
        while (A<=9) {
            number_of_chests_[A]=_num_ches[A];
        }
    }

    function setProcentChest (uint256[] memory _Procent) public onlyOwner {
        F_(_Procent);
        uint256 B;
        while (B<=9) {
         ProcentChest[B]=_Procent[B];
        B++;
}
}
   function F_ (uint256[] memory chest) internal pure {
   uint256 sum;
   uint256 A;
   while (A<=9) {
     sum=sum+chest[A];
     A++;
   }
    require(sum ==100);
   }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ITake { 
    function Get_Distribution_number () external view returns (uint256);

    function Get_One_chest_MITI ( uint256 num_Track, uint256 chest_num) external view returns (uint256);
    function Get_One_chest_USDT ( uint256 num_Track, uint256 chest_num) external view returns (uint256);

    function Get_Track_all (uint256 num_Track) external view returns (
    uint256 allMITI_,uint256 allUSDT_ );
    
    function Get_Track_1_2_3_4_5 (uint256 num_Track) external view returns( uint256 One_chests_MITI_1, uint256 One_chests_USDT_1,
    uint256 One_chests_MITI_2, uint256 One_chests_USDT_2,
    uint256 One_chests_MITI_3, uint256 One_chests_USDT_3,
    uint256 One_chests_MITI_4, uint256 One_chests_USDT_4,
    uint256 One_chests_MITI_5, uint256 One_chests_USDT_5);

    function Get_Track_6_7_8_9_10 (uint256 num_Track) external view returns( 
    uint256 One_chests_MITI_6, uint256 One_chests_USDT_6,
    uint256 One_chests_MITI_7, uint256 One_chests_USDT_7,
    uint256 One_chests_MITI_8, uint256 One_chests_USDT_8,
    uint256 One_chests_MITI_9, uint256 One_chests_USDT_9,
     uint256 One_chests_MITI_10, uint256 One_chests_USDT_10);



    

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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