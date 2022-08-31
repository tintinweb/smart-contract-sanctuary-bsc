/**
 *Submitted for verification at BscScan.com on 2022-08-31
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
    using SafeMath for uint256;

    IWoolToken public woolToken;
    IWoolshed public woolshed;

    address public taxVault;

    uint256 public players;

    modifier ifNotBanned(address _addr) {
        require(!isBanned(_addr), "AirdropSystem: banned");
        _;
    }

    /////////////////////////////////
    // CONFIGURABLES AND VARIABLES //
    /////////////////////////////////

    struct UserData {
        bool banned;
        bool changePermitted;
        
        address upline;
        address[] downlines;

        uint8 changes;

        uint256 members;

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

    event onBanUser(address indexed caller, address indexed _user, string _reason, uint256 timestamp);
    event onUnbanUser(address indexed caller, address indexed _user, uint256 timestamp);

    event onPermitChangeUpline(address indexed caller, address indexed _user, uint256 timestamp);

    //////////////////////////////
    // CONSTRUCTOR AND FALLBACK //
    //////////////////////////////

    constructor (address _woolToken, address _woolshed, address _taxVault) {

        woolToken = IWoolToken(_woolToken);
        woolshed = IWoolshed(_woolshed);

        taxVault = _taxVault;

        _users[address(0)].upline = address(0);
        _users[address(0)].members = 0;
    }

    receive() payable external {
        revert();
    }

    ////////////////////
    // VIEW FUNCTIONS //
    ////////////////////

    // Check if an address is banned from the airdrop system
    function isBanned(address _addr) public view returns (bool) {
        return _users[_addr].banned;
    }

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

    // Return the downline address of a player at index
    function getDownlineAtPosition(address player, uint256 index) public view returns (address) {
        return _users[player].downlines[index];
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
            _users[_oldUpline].downlines.pop();
        }

        // Fire Event
        emit onSetUpline(msg.sender, _newUpline);
        return (membersOf(msg.sender));
    }

    // Reset the upline of the sender
    function changeOnce(address _newUpline) public whenNotPaused() returns (uint256) {
        require(_users[msg.sender].changePermitted == true && _users[msg.sender].changes == 0, "NOT_PERMITTED");

        // Grab the current upline address        
        address _oldUpline = _users[msg.sender].upline;

        // Set the new upline address
        _users[msg.sender].upline = _newUpline;

        // Update the downline counters for old and new
        _users[_newUpline].members += 1;
        _users[msg.sender].downlines.push(_newUpline);

        // Count the change in name
        _users[msg.sender].changes++;
        
        // If there's a number to change, do so
        if (_users[_oldUpline].members > 1) {
            _users[_oldUpline].members -= 1;
            _users[_oldUpline].downlines.pop();
        }

        // Fire Event
        emit onSetUpline(msg.sender, _newUpline);
        return (membersOf(msg.sender));
    }

    // Airdrop tokens to a single user
    function airdrop(address to_, uint256 amount_) external ifNotBanned(msg.sender) ifNotBanned(to_) returns (bool) {
        require(woolToken.transferFrom(msg.sender, address(taxVault), amount_), "Token transfer failed");

        (uint256 realizedDeposit, uint256 taxedAmount) = woolToken.calculateTransferTaxes(msg.sender, amount_);

        woolToken.transfer(address(taxVault), taxedAmount);

        woolshed.airdrop(to_, realizedDeposit);

        return true;
    }
    
    // Airdrop tokens to a team of users
    function airdropTeam(uint256 amount_, uint256 minBalance_, uint256 maxBalance_) external ifNotBanned(msg.sender) returns (bool) {

        address[] memory recipients_ = _users[msg.sender].downlines;

        require(woolToken.transferFrom(msg.sender, address(taxVault), amount_), "Token transfer failed");

        woolToken.transfer(address(taxVault), amount_);

        return _teamAirdrop(recipients_, amount_, minBalance_, maxBalance_);
    }

    //////////////////////////////////
    // INTERNAL & PRIVATE FUNCTIONS //
    //////////////////////////////////

    function _teamAirdrop(address[] memory recipients_, uint256 amount_, uint256 minBalance_, uint256 maxBalance_) internal returns (bool) {
        
        // address[] memory recipients_ = _referrals[msg.sender];
        uint256 _count_;

        // Loop through first to get number of qualified accounts.
        for(uint256 i = 0; i < recipients_.length; i ++) {

            require(!isBanned(recipients_[i]), "RECIPIENT_BANNED");

            if(recipients_[i] == msg.sender) {
                continue;
            }

            bool _isEligible = checkEligibility(recipients_[i], amount_, minBalance_, maxBalance_);

            // If the current user being checked is the caller, skip
            if(recipients_[i] == msg.sender) {
                continue;
            }
            
            // If the address is eligible, bump the count.
            if(_isEligible) {
                _count_ ++; 
            }
        }

        // Require that there actually be some recipients
        require(_count_ > 0, "No qualified accounts exist");

        // Find amount per recipient
        uint256 _airdropAmount_ = amount_ / _count_;

        // Send an airdrop to each qualified account.
        for(uint256 i = 0; i < recipients_.length; i ++) {
            
            // Skip the message caller
            if(recipients_[i] == msg.sender) {
                continue;
            }
            
            // Send the airdrop
            woolshed.airdrop(recipients_[i], _airdropAmount_);
        }

        return true;
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

    function permitChange(address _user) public onlyWhitelisted() returns (bool _success) {
        require(_users[_user].changes == 0, "ALREADY_CHANGED");

        _users[_user].changePermitted = true;

        emit onPermitChangeUpline(msg.sender, _user, block.timestamp);
        return true;
    }

    function banUser(address _user, string memory _reason) public onlyWhitelisted() returns (bool _success) {
        _users[_user].banned = true;

        emit onBanUser(msg.sender, _user, _reason, block.timestamp);
        return true;
    }

    function unbanUser(address _user) public onlyWhitelisted() returns (bool _success) {
        _users[_user].banned = false;

        emit onUnbanUser(msg.sender, _user, block.timestamp);
        return true;
    }
}