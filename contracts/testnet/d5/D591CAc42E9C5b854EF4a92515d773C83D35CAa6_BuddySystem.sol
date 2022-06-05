// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Address.sol";
import "./Math.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";

import "./IERC20.sol";

import "./Ownable.sol";

contract BuddySystem is Ownable {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /////////////////////////////////
    // CONFIGURABLES AND VARIABLES //
    /////////////////////////////////

    struct PlayerData {
        address upline;
        uint256 downlines;
    }

    uint256 public players;

    //////////////////
    // DATA MAPPING //
    //////////////////

    mapping(address => PlayerData) private _playerData;

    /////////////////////
    // CONTRACT EVENTS //
    /////////////////////

    event onSetUpline(address indexed player, address indexed buddy);

    //////////////////////////////
    // CONSTRUCTOR AND FALLBACK //
    //////////////////////////////

    constructor () {
        _playerData[address(0)].upline = address(0);
        _playerData[address(0)].downlines = 0;
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
        return _playerData[player].upline;
    }

    // Return the downline count of a player
    function downlinesOf(address player) public view returns (uint256) {
        return _playerData[player].downlines;
    }

    /////////////////////
    // WRITE FUNCTIONS //
    /////////////////////

    // Updated the upline of the sender
    function setUpline(address _newUpline) public returns (uint256) {

        // Grab the current upline address        
        address _oldUpline = _playerData[msg.sender].upline;

        // Set the new upline address
        _playerData[msg.sender].upline = _newUpline;

        // Update the downline counters for old and new
        _playerData[_newUpline].downlines += 1;
        
        if (_playerData[_oldUpline].downlines > 1) {
            _playerData[_oldUpline].downlines -= 1;
        }

        // Fire Event
        emit onSetUpline(msg.sender, _newUpline);
        return (downlinesOf(msg.sender));
    }
}