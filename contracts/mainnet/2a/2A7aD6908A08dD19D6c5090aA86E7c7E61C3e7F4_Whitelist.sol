// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./IWhitelist.sol";
import "./ManagedSecurity.sol";

/**
 * @title Whitelist 
 * 
 * Contract that keeps whitelist data. On the admin side it allows adding & removing of addresses on 
 * the whitelist. To other contracts, it acts as an oracle to determine whether or not any arbitrary 
 * address is whitelisted. 
 * 
 * @author John R. Kosinski
 */
contract Whitelist is IWhitelist, ManagedSecurity {
    mapping(address => bool) private whitelisted;   //stores the whitelist 
    bool public whitelistOn = true;                 //enables/disables whitelist 
    
    //events 
    event WhitelistOnOffChanged(address indexed caller, bool value); 
    event WhitelistAddedRemoved(address indexed caller, address indexed addr, bool value); 
    
    /**
     * Creates an instance of the Whitelist contract. 
     * 
     * @param _securityManager Contract which will manage secure access for this contract. 
     */
    constructor(ISecurityManager _securityManager) {
        _setSecurityManager(_securityManager); 
    }
    
    /**
     * Indicates whether or not the given address is in the whitelist. 
     * 
     * @param addr The address to query. 
     * @return bool True if the given address is in the whitelist.
     */
    function isWhitelisted(address addr) external view returns (bool) {
        if (whitelistOn) {
            return whitelisted[addr]; 
        }
        return true;
    }
    
    /**
     * Adds or removes an address to/from the whitelist. 
     * 
     * Emits: 
     * - {WhitelistAddedRemoved} event if any change has been made to the whitelist. 
     * 
     * Reverts: 
     * - {UnauthorizedAccess} if caller does not have the appropriate security role
     * - {ZeroAddressArgument} if address passed is 0x0
     * 
     * @param addr The address to add or remove. 
     * @param addRemove If true, adds; otherwise removes the address.
     */
    function addRemoveWhitelist(address addr, bool addRemove) external onlyRole(WHITELIST_MANAGER_ROLE) {  
        if (addr == address(0)) 
            revert ZeroAddressArgument(); 
        
        _addRemoveWhitelist(addr, addRemove); 
    }
    
    /**
     * Adds or removes multiple addresses to/from the whitelist. 
     * @dev Addresses that are equal to 0x0 will not be added, but the function will not revert if one 
     * is included in the array. 0x0 addresses in this function will just be ignored. 
     * 
     * Emits: 
     * - {WhitelistAddedRemoved} event if any change has been made to the whitelist, for each address. 
     * 
     * Reverts: 
     * - {UnauthorizedAccess} if caller does not have the appropriate security role
     * 
     * @param addresses Array of addresses to add or remove. 
     * @param addRemove If true, adds; otherwise removes the address.
     */
    function addRemoveWhitelistBulk(address[] calldata addresses, bool addRemove) external onlyRole(WHITELIST_MANAGER_ROLE)  {
        for (uint n = 0; n < addresses.length; n++) {
            if (addresses[n] != address(0)) {
                _addRemoveWhitelist(addresses[n], addRemove); 
            }
        }
    }
    
    /**
     * Enables or disables whitelisting. 
     * 
     * Emits: 
     * - {WhitelistOnOffChanged} event if any change has been made to {whitelistOn} flag. 
     * 
     * Reverts: 
     * - {UnauthorizedAccess} if caller does not have the appropriate security role
     * 
     * @param onOff If true, enables; otherwise disables whitelisting.
     */
    function setWhitelistOnOff(bool onOff) external onlyRole(WHITELIST_MANAGER_ROLE) { 
        if (whitelistOn != onOff) {
            whitelistOn = onOff;
            emit WhitelistOnOffChanged(_msgSender(), onOff);
        }
    }
    
    /**
     * Adds or removes the given address to/from the whitelist. 
     * 
     * Emits: 
     * - {WhitelistAddedRemoved} if any change has been made to the whitelist (e.g. address
     *      actually added or removed)
     * 
     * @param addr The address to add or remove. 
     * @param addRemove If true, adds; otherwise removes the address.
     */
    function _addRemoveWhitelist(address addr, bool addRemove) internal {
        if (whitelisted[addr] != addRemove) {
            whitelisted[addr] = addRemove;
            emit WhitelistAddedRemoved(_msgSender(), addr, addRemove); 
        }
    }
}