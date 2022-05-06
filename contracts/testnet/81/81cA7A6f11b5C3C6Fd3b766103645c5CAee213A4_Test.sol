// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LockableToken.sol";
import "./ERC20.sol";
import "./ERC20Pausable.sol";
import "./Context.sol";

contract Test is Context, ERC20Pausable, LockableToken {
   
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
      
    }

    
    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual {
        
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual {
      
        _unpause();
    }

    /// DISTRIBUTION


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);
    }


    function lock(
        address _of,
        bytes32 _reason,
        uint256 _amount,
        uint256 _time
    ) public override returns (bool) {
      
        return true;
    }

    function increaseLockAmount(
        address _of,
        bytes32 _reason,
        uint256 _amount
    ) public override returns (bool) {
       
        return true;
    }

    function unlock(address _of)
        public
        override
        returns (uint256 unlockableTokens)
    {
       
    }

    event _logMintUnvestingToken(address addr, uint256 total);
    event _logMintUnlockableToken(address addr, uint256 total);
    event _logWithdrawTokens(
        address _from,
        address _to,
        uint256 _amountWithDecimals
    );
    event _logTransferByAdmin(
        address _from,
        address _to,
        uint256 _amountWithDecimals
    );
}