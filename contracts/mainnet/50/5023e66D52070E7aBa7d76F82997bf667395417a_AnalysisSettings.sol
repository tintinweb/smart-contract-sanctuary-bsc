/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/**
 * @title AnalysisSettings
 * @dev This contract is used to store the privacy settings for the analysis contract
 */
contract AnalysisSettings {
  mapping (address => bool) optedOut;

  event OptOut(address indexed _address);
  event OptIn(address indexed _address);

  /**
   * @dev Opt out of analysis participation, address must be the same as the sender
   * @param _addr The address of the user who is opting out
   */
  function optOut(address _addr) public {
    require(msg.sender == _addr, "ADDRESS_MISMATCH");

    optedOut[msg.sender] = true;

    emit OptOut(msg.sender);
  }

  /**
   * The opposite of optOut, resets the user's opt out status to false
   * @dev Opt in to analysis participation, address must be the same as the sender
   * @param _addr The address of the user who is opting in
   */
  function optIn(address _addr) public {
    require(msg.sender == _addr, "ADDRESS_MISMATCH");

    optedOut[msg.sender] = false;
    emit OptIn(msg.sender);
  }

  /**
   * @dev Check if a user has opted out of analysis participation
   * @param _address The address of the user to check
   * @return bool True if the user has not explicitly opted out, false if they have
   */
  function userOptedIn(address _address) public view returns (bool) {
    // user has not denied analysis participation or has 
    return !optedOut[_address];
  }
}