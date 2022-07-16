/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

// SPDX-License-Identifier: BSD-3-Clause

pragma solidity ^0.8.10;

contract PlanetStorage {
    
    address public gGammaAddress = 0xF701A48e5C751A213b7c540F84B64b5A6109962E;
    address public gammatroller = 0xF54f9e7070A1584532572A6F640F09c606bb9A83;
    address public oracle = 0xC23b8aF5D68222a2FB835CEB07B009b94e36eFF9;
    
    address public admin;
    
    uint256 public level0Discount = 0;
    uint256 public level1Discount = 500;
    uint256 public level2Discount = 2000;
    uint256 public level3Discount = 5000;
   
    uint256 public level1Min = 100;
    uint256 public level2Min = 500;
    uint256 public level3Min = 1000;
    
    
    /**
     * @notice Total amount of underlying discount given
     */
    mapping(address => uint) public totalDiscountGiven;
    
    mapping(address => bool) public deprecatedMarket;
    
    mapping(address => bool) public isMarketListed;
    
    address[] public deprecatedMarketArr;  
    
    /*
     * @notice Official record of each user whether the user is present in discountGetters or not
     */
    mapping(address => mapping(address => BorrowDiscountSnapshot)) public borrowDiscountSnap;
    
    struct ReturnBorrowDiscountLocalVars {
        uint marketTokenSupplied;
    }
    
    mapping(address => address[]) public usersWhoHaveBorrow;

    /**
     * @notice Container for borrow balance information
     * @member principal Total balance (with accrued interest), after applying the most recent balance-changing action
     * @member interestIndex Global borrowIndex as of the most recent balance-changing action
     */
    struct BorrowSnapshot {
        uint principal;
        uint interestIndex;
    }
    
    /**
     * @notice Container for Discount information
     * @member exist (whether user is present in Discount scheme)
     * @member index (user address index in array of usersWhoHaveBorrow)
     * @member lastRepayAmountDiscountGiven(the last repay amount at which discount is given to user)
     * @member accTotalDiscount(total discount accumulated to the user)
     * @member lastUpdated(timestamp at which it is updated last time)
     */
    struct BorrowDiscountSnapshot {
        bool exist;
        uint index;
        uint lastBorrowAmountDiscountGiven;
        uint accTotalDiscount;
        uint lastUpdated;
    }
    
   /**
    * @notice Event emitted when discount is changed for user
    */
    event BorrowDiscountAccrued(address market,address borrower,uint discountGiven,uint lastUpdated);
     
    event gGammaAddressChange(address prevgGammaAddress,address newgGammaAddress);
    
    event gammatrollerChange(address prevGammatroller,address newGammatroller);
    
    event oracleChanged(address prevOracle,address newOracle);
    
}

contract PlanetDelegationStorage {
    /**
     * @notice Implementation address for this contract
     */
    address public implementation;
}

abstract contract PlanetDelegatorInterface is PlanetDelegationStorage {
    /**
     * @notice Emitted when implementation is changed
     */
    event NewImplementation(address oldImplementation, address newImplementation);

    /**
     * @notice Called by the admin to update the implementation of the delegator
     * @param implementation_ The address of the new implementation for delegation
     */
    function _setImplementation(address implementation_) virtual public;
}


contract PlanetDiscountDelegator is PlanetStorage,PlanetDelegatorInterface {
   
    event NewAdmin(address oldAdmin, address newAdmin);
    
    constructor(address implementation_,address admin_) {
        // Creator of the contract is admin during initialization
        admin = msg.sender;
        
        _setImplementation(implementation_);
        // Set the proper admin now that initialization is done
        admin = admin_;
    }

    /**
     * @notice Called by the admin to update the implementation of the delegator
     * @param implementation_ The address of the new implementation for delegation
     */
    function _setImplementation(address implementation_) override public {
        require(msg.sender == admin, "GErc20Delegator::_setImplementation: Caller must be admin");

        address oldImplementation = implementation;
        implementation = implementation_;

        emit NewImplementation(oldImplementation, implementation);
    }

    function _setAdmin(address newAdmin) public  {
        // Check caller = admin
        require(msg.sender == admin,"caller is not admin");

        // Save current value, if any, for inclusion in log
        address oldAdmin = admin;

        // Store admin with value newAdmin
        admin = newAdmin;

        // Emit NewAdmin(oldAdmin, newAdmin)
        emit NewAdmin(oldAdmin, newAdmin);

    }
    
   
    /**
     * @notice Delegates execution to an implementation contract
     * @dev It returns to the external caller whatever the implementation returns or forwards reverts
     */
    fallback () external payable {
        require(msg.value == 0,"GErc20Delegator:fallback: cannot send value to fallback");

        // delegate all other functions to current implementation
        (bool success, ) = implementation.delegatecall(msg.data);

        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize())

            switch success
            case 0 { revert(free_mem_ptr, returndatasize()) }
            default { return(free_mem_ptr, returndatasize()) }
        }
    }
}