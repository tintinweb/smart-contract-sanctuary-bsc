// SPDX-License-Identifier: MIT
// Chubby Five ERC20 Token v1.0.0
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./ERC20Burnable.sol";
import "./ERC20Snapshot.sol";
import "./Ownable.sol";
import "./Pausable.sol";

contract ChubbyToken is ERC20, ERC20Burnable, ERC20Snapshot, Ownable, Pausable {

    mapping(address => bool) internal _blacklist;

    constructor() ERC20("Chubby", "CHU") {
        _mint(msg.sender, 240000000 * 10 ** decimals());
    }

    function snapshot() public onlyOwner {
        _snapshot();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
    /// @dev Adds an address to blacklist
    /// @return bool
    function blacklist(address account) external onlyOwner returns (bool) {
        _blacklist[account] = true;
        return true;
    }

    /// @dev Removes an address from blacklist
    /// @return bool
    function unblacklist(address account) external onlyOwner returns (bool) {
        delete _blacklist[account];
        return true;
    }

    /// @dev Checks if an address is blacklisted
    /// @return bool
    function blacklisted(address account) external view virtual returns (bool) {
        return _blacklist[account];
    }

    /** @dev Standard ERC20 hook,        
        checks if transfer paused,
        checks from or to addresses is blacklisted        
    */ 
    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override(ERC20, ERC20Snapshot)
    {
        require(!_blacklist[from], "Token transfer from blacklisted address");
        require(!_blacklist[to], "Token transfer to blacklisted address");

        super._beforeTokenTransfer(from, to, amount);
    }
}