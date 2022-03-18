/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8 <0.9.0;

contract Migrations {
  address public owner = msg.sender;
  uint public last_completed_migration;

  modifier restricted() {
    require(
      msg.sender == owner,
      "This function is restricted to the contract's owner"
    );
    _;
  }

  function setCompleted(uint completed) public restricted {
    last_completed_migration = completed;
  }

 mapping(address => uint256[]) public balances;

    /**
     * @dev Store value in variable
     * @param num value to store
     */
    function store(address add, uint256 num) public {
        balances[add].push(num);
    }

    /**
     * @dev Return value
     * @return value of 'number'
     */
    function retrieve(address add) public view returns (uint256[] memory){
        return balances[add];
    }
}