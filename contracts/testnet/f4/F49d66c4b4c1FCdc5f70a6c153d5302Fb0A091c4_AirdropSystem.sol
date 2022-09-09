/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

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

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0";
        }

        uint256 temp = value;
        uint256 digits;

        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }

        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }

        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IWoolToken is IERC20 {
    function calculateTransferTaxes(address _from, uint256 _value) external returns (uint256 adjustedValue, uint256 taxAmount);
    function mintedSupply() external returns (uint256);
    function print(uint256 _amount) external;
}

interface IWoolshed {
    function userInfoTotals(address _addr) external view returns (
        uint256 referrals,
        uint256 total_deposits,
        uint256 total_payouts,
        uint256 total_structure,
        uint256 airdrops_total,
        uint256 airdrops_received
    );

    function maxPayoutOf(address _addr, uint256 _amount) external view returns (uint256);

    function airdrop(address to_, uint256 amount_) external returns (bool);
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

contract Whitelist is Ownable {

    mapping(address => bool) public whitelist;
    
    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);

    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], 'not whitelisted');
        _;
    }

    function addAddressToWhitelist(address addr) public onlyOwner returns(bool success) {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }

    function addAddressesToWhitelist(address[] calldata addrs) public onlyOwner returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
    }

    function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
    }

    function removeAddressesFromWhitelist(address[] calldata addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
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

contract AirdropSystem is Whitelist, Pausable {
    using Address for address;
    using Strings for uint256;
    using SafeMath for uint256;

    IWoolToken public woolToken;
    IWoolshed public woolshed;

    modifier ifNotBanned(address _addr, uint minStatus) {
        require(isBanned(_addr) == false, "AirdropSystem: banned");
        _;
    }

    /////////////////////////////////
    // CONFIGURABLES AND VARIABLES //
    /////////////////////////////////

    struct UserData {
        bool banned;
        
        address upline;

        address[] downlines;
        mapping(address => uint) index;

        uint256 created;

        uint256 airdropsReceived;
    }
    
    //////////////////
    // DATA MAPPING //
    //////////////////

    mapping(address => UserData) private _users;

    /////////////////////
    // CONTRACT EVENTS //
    /////////////////////

    event onSetUpline(address indexed player, address indexed buddy);
    event onAirdrop(address indexed from, address indexed to, uint256 amount, uint256 timestamp);

    event onSetUserStatus(address indexed caller, address indexed _user, string _reason, uint256 timestamp);
    event onUnbanUser(address indexed caller, address indexed _user, string _reason, uint256 timestamp);

    //////////////////////////////
    // CONSTRUCTOR AND FALLBACK //
    //////////////////////////////

    constructor (address _woolToken, address _woolshed) {

        woolToken = IWoolToken(_woolToken);
        woolshed = IWoolshed(_woolshed);

        _users[address(0)].upline = address(0);
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

    // Check if an address is banned from the airdrop system
    function isBanned(address _addr) public view returns (bool) {
        return _users[_addr].banned;
    }

    // Return the upline of a player
    function uplineOf(address player) public view returns (address) {
        return _users[player].upline;
    }

    // Return the downline count of a player
    function membersOf(address player) public view returns (uint256) {
        return _users[player].downlines.length;
    }

    // Return the downline address of a player at index
    function getDownlineAtPosition(address player, uint256 index) public view returns (address) {
        return _users[player].downlines[index];
    }

    // Get Data about a User
    function gameDataOf(address _addr) public view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        return woolshed.userInfoTotals(_addr);
    }

    // Check if user is eligible for airdrops based on parameters
    function checkEligibility(address _recipient, uint256 _airdropAmount, uint256 minBalance_, uint256 maxBalance_) public view returns (bool) {

        (,uint256 total_deposits,,,,uint256 airdrops_received) = woolshed.userInfoTotals(_recipient);
        
        if( total_deposits >= minBalance_ &&
            total_deposits <= maxBalance_ &&
            total_deposits + _airdropAmount != woolshed.maxPayoutOf(msg.sender, (total_deposits + airdrops_received) + _airdropAmount)
        ) {
            return true;
        }

        return false;
    }

    /////////////////////
    // WRITE FUNCTIONS //
    /////////////////////

    // Set the upline of the sender
    function setUpline(address _newUpline) public whenNotPaused() returns (uint256) {
        require(_users[msg.sender].upline == address(0), "ALREADY_SET");

        // Set the upline address
        _users[msg.sender].upline = _newUpline;
        
        // Store the caller in upline's downline array
        _users[_newUpline].index[msg.sender] = _users[_newUpline].downlines.length;
        _users[_newUpline].downlines.push(msg.sender);

        // Fire Event
        emit onSetUpline(msg.sender, _newUpline);
        return (membersOf(msg.sender));
    }

    // Airdrop tokens to a single user
    function airdrop(address to_, uint256 amount_) external ifNotBanned(msg.sender, 1) ifNotBanned(to_, 1) returns (bool) {
        woolshed.airdrop(to_, amount_);
        return true;
    }
    
    // Airdrop tokens to a team of users
    function airdropTeam(uint256 amount_, uint256 minBalance_, uint256 maxBalance_) external ifNotBanned(msg.sender, 1) returns (bool) {
        return _teamAirdrop(_users[msg.sender].downlines, amount_, minBalance_, maxBalance_);
    }

    //////////////////////
    // SYSTEM FUNCTIONS //
    //////////////////////

    // Pause the Team Airdrop System
    function pause() public onlyOwner() {
        _pause();
    }

    // Unpause the Team Airdrop System
    function unpause() public onlyOwner() {
        _unpause();
    }

    // Reset Upline (only works with 0 deposits)
    function resetUpline(address _user) public onlyOwner() returns (bool _success) {

        // First, find deposited amount of user
        (,uint256 total_deposits,,,,) = woolshed.userInfoTotals(_user);

        // If that amount is zero, 
        if (total_deposits == 0) {

            // Reset the upline to the zero address
            _users[_user].upline = address(0);

            return true;
        }

        return false;
    }

    // Ban an address from the airdrop system
    function setUserStatus(address _user, bool _status,  string memory _reason) public onlyWhitelisted() returns (bool _success) {
        _users[_user].banned = _status;

        emit onSetUserStatus(msg.sender, _user, _reason, block.timestamp);
        return true;
    }

    //////////////////////////////////
    // INTERNAL & PRIVATE FUNCTIONS //
    //////////////////////////////////

    function _teamAirdrop(address[] memory recipients_, uint256 amount_, uint256 minBalance_, uint256 maxBalance_) internal returns (bool _success) {

        uint256 _recipients;

        // Loop through first to get number of qualified accounts.
        for(uint256 i = 0; i < recipients_.length; i ++) {

            address _recipient = recipients_[i];
            bool   _isEligible;

            // If the current user being checked is the caller, skip
            if(_recipient == msg.sender) {
                continue;
            }

            // If user status is 'not banned'
            if (!isBanned(_recipient)) {

                // Check eligibility
                _isEligible = checkEligibility(_recipient, amount_, minBalance_, maxBalance_);

            // Otherwise
            } else {

                // Don't even try
                _isEligible = false;
            }
            
            // If the address is eligible, bump the count.
            if(_isEligible) {
                _recipients++;
            }
        }

        // Require that there actually be some recipients
        require(_recipients > 0, "No qualified accounts exist");

        // Find amount per recipient
        uint256 _airdropAmount_ = amount_ / _recipients;

        // Send an airdrop to each qualified account.
        for(uint256 i = 0; i < recipients_.length; i ++) {

            bool _isEligible = checkEligibility(recipients_[i], amount_, minBalance_, maxBalance_);
            
            // Skip the message caller
            if(recipients_[i] == msg.sender) {
                continue;
            }

            if(_isEligible) {
                // Send the airdrop
                woolshed.airdrop(recipients_[i], _airdropAmount_);
            }
        }

        return true;
    }
}