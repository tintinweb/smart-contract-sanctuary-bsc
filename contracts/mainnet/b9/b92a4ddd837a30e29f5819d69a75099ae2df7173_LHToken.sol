// SPDX-License-Identifier: MIT
// Liquid Holdings Contracts 
// by AlexNa

pragma solidity ^0.8.13;

import "ERC20.sol";
import "Pausable.sol";
import "Ownable.sol";

contract Blacklistable is Ownable {
    mapping(address => bool) internal blacklisted;

    event Blacklisted(address indexed _account);
    event UnBlacklisted(address indexed _account);

    modifier notBlacklisted(address _account) {
        require(
            !blacklisted[_account],
            "Blacklistable: account is blacklisted"
        );
        _;
    }

    function isBlacklisted(address _account) external view returns (bool) {
        return blacklisted[_account];
    }

    function blacklist(address _account) external onlyOwner {
        blacklisted[_account] = true;
        emit Blacklisted(_account);
    }

    function unBlacklist(address _account) external onlyOwner {
        blacklisted[_account] = false;
        emit UnBlacklisted(_account);
    }
}


contract LHToken is ERC20, Blacklistable, Pausable {

    uint8 private _decimals; 

    constructor(string memory name_, string memory symbol_, uint8 decimals_)
        ERC20( name_, symbol_ ) 
    {
       _decimals = decimals_;
    }   

    function pause() whenNotPaused onlyOwner public {
        _pause();
    }

    function unpause() whenPaused onlyOwner public {
        _unpause();
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function mint( uint256 amount) onlyOwner public {
        _mint( owner(), amount );
    }

    function burn( uint256 amount) onlyOwner public {
        _burn( owner(), amount );    
    }    

    function destroyBlackFunds (address blackListedUser_) public onlyOwner {
        require(
            blacklisted[blackListedUser_], 
            "not blacklisted"
        );
        
        uint dirtyFunds = balanceOf(blackListedUser_);
        _burn( blackListedUser_, dirtyFunds );    
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "token transfer while paused");
        require(!blacklisted[from], "account is blacklisted");
    }

}