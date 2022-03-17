/**
 *Submitted for verification at BscScan.com on 2022-03-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-08
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

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

}

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */

contract EMP_INFORMATION is  Ownable {
  string public company = "ESP Softtech";
  uint256 public empid = 0;
//   string public name = '';
//   string public email = '';
//   uint256 public mobile;

  struct _empDetails{
    uint256 empid;
    string name;
    string email;
    uint256 mobile; 
  }
  mapping(uint256 => _empDetails) public empDetails;

  function setCompany(string memory company_name) onlyOwner public{
      company = company_name; 
  }

  function addEmployee(string memory new_name, string memory new_email, uint256 new_mobile) public{
    //   require(empid != new_empid, "Employee Id already exist!!!");

      empid = empid+1;
      empDetails[empid] = _empDetails(empid, new_name, new_email, new_mobile);
  }
    
function updateDetails(uint256 emp_id, string memory name, string memory email, uint256 mobile) public{
    require(emp_id > 0, "Emp Id required!!");
    empDetails[emp_id] = _empDetails(emp_id, name, email, mobile);
}

function deleteEmp(uint256 emp_id) public{
    delete empDetails[emp_id];
}

}