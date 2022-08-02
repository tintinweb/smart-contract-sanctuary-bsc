// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b > a) {
            return 0;
        } else {
            return a - b;
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

abstract contract Pausable is Context {

    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    constructor () {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract BuddySystem is Ownable, Pausable {
    using Address for address;
    using SafeMath for uint256;

    /////////////////////////////////
    // CONFIGURABLES AND VARIABLES //
    /////////////////////////////////

    struct UserData {
        address upline;
        address[] downlines;
        uint256 members;
    }

    uint256 public players;
    
    //////////////////
    // DATA MAPPING //
    //////////////////

    mapping(address => UserData) private _users;

    /////////////////////
    // CONTRACT EVENTS //
    /////////////////////

    event onSetUpline(address indexed player, address indexed buddy);

    //////////////////////////////
    // CONSTRUCTOR AND FALLBACK //
    //////////////////////////////

    constructor () {
        _users[address(0)].upline = address(0);
        _users[address(0)].members = 0;
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
    function myMembers() public view returns (uint256){
        return membersOf(msg.sender);
    }

    // Return the upline of a player
    function uplineOf(address player) public view returns (address) {
        return _users[player].upline;
    }

    // Return the downline count of a player
    function membersOf(address player) public view returns (uint256) {
        return _users[player].members;
    }

    // Return the downline address of a player
    function getDownlineOf(address player, uint256 index) public view returns (address) {
        return _users[player].downlines[index];
    }

    /////////////////////
    // WRITE FUNCTIONS //
    /////////////////////

    // Updated the upline of the sender
    function setUpline(address _newUpline) public whenNotPaused() returns (uint256) {
        require(_users[msg.sender].upline == address(0), "ALREADY_SET");

        // Grab the current upline address        
        address _oldUpline = _users[msg.sender].upline;

        // Set the new upline address
        _users[msg.sender].upline = _newUpline;

        // Update the downline counters for old and new
        _users[_newUpline].members += 1;
        _users[msg.sender].downlines.push(_newUpline);
        
        // If there's a number to change, do so
        if (_users[_oldUpline].members > 1) {
            _users[_oldUpline].members -= 1;
        }

        // Fire Event
        emit onSetUpline(msg.sender, _newUpline);
        return (membersOf(msg.sender));
    }

    //////////////////////
    // SYSTEM FUNCTIONS //
    //////////////////////

    function pause() public onlyOwner() {
        _pause();
    }

    function unpause() public onlyOwner() {
        _unpause();
    }
}