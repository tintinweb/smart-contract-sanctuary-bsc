// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Address.sol";
import "./Math.sol";
import "./SafeMath.sol";

contract BuddySystem {
    using Address for address;
    using SafeMath for uint256;

    /////////////////////////////////
    // CONFIGURABLES AND VARIABLES //
    /////////////////////////////////

    uint256 public players;

    //////////////////
    // DATA MAPPING //
    //////////////////

    mapping(address => address) private _uplineOf;
    mapping(address => uint256) private _downlinesOf;

    /////////////////////
    // CONTRACT EVENTS //
    /////////////////////

    event onSetUpline(address indexed player, address indexed buddy);

    //////////////////////////////
    // CONSTRUCTOR AND FALLBACK //
    //////////////////////////////

    constructor () {
        _uplineOf[address(0)] = address(0);
        _downlinesOf[address(0)] = 0;
    }

    receive() payable external {
        revert();
    }

    ////////////////////
    // VIEW FUNCTIONS //
    ////////////////////

    // Return the upline of the sender
    function myUpline() public view returns (address){
        return uplineOf(msg.sender);
    }

    // Return the downline count of the sender
    function myDownlines() public view returns (uint256){
        return downlinesOf(msg.sender);
    }

    // Return the upline of a player
    function uplineOf(address player) public view returns (address) {
        return _uplineOf[player];
    }

    // Return the downline count of a player
    function downlinesOf(address player) public view returns (uint256) {
        return _downlinesOf[player];
    }

    /////////////////////
    // WRITE FUNCTIONS //
    /////////////////////

    // Updated the upline of the sender
    function setUpline(address _newUpline) public returns (uint256) {

        // Grab the current upline address        
        address _oldUpline = _uplineOf[msg.sender];

        // Set the new upline address
        _uplineOf[msg.sender] = _newUpline;

        // Update the downline counters for old and new
        _downlinesOf[_newUpline] += 1;
        
        if (_downlinesOf[_oldUpline] > 1) {
            _downlinesOf[_oldUpline] -= 1;
        }

        // Fire Event
        emit onSetUpline(msg.sender, _newUpline);
        return (downlinesOf(msg.sender));
    }
}