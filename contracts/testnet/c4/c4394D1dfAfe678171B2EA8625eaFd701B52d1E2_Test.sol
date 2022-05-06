// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LockableToken.sol";
import "./ERC20.sol";
import "./ERC20Pausable.sol";
import "./Context.sol";

contract Test is Context, ERC20Pausable, LockableToken {
   
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // Time of the contract creation
    uint256 public creationTime = block.timestamp;
    /// ALOCATIONS
    // To calculate vesting periods we assume that 1 month is always equal to 30 days

    /*** Tokens reserved for sale ***/

    // 180.000.000 tokens will be eventually available for private sale
    //  45.000.000 tokens will be available instantly without vesting

    address public constant SALE_ALLOCATION =
        address(0x1111111111111111111111111111111111111111);
    uint256 public constant SALE_TOTAL = 180000000e18;
    uint256 public constant SALE_PERIOD_AMOUNT = 45000000e18;
    uint256 public constant SALE_UNVESTED = 45000000e18;
    uint256 public constant SALE_PERIOD_LENGTH = 6 * 30 days;
    uint8 public constant SALE_PERIODS_NUMBER = 3;
    uint256 public saleUnlockedAccumulated = 0;

    /*** Tokens reserved for Treasury ***/

    // 90,000,000  tokens will be eventually available for advisers
    // 18,000,000 tokens will be available instantly without vesting

    address public constant TREASURY_ALLOCATION =
        address(0x6666666666666666666666666666666666666666);
    uint256 public constant TREASURY_TOTAL = 90000000e18;
    uint256 public constant TREASURY_PERIOD_AMOUNT = 18000000e18;
    uint256 public constant TREASURY_UNVESTED = 18000000e18;
    uint256 public constant TREASURY_PERIOD_LENGTH = 6 * 30 days;
    uint8 public constant TREASURY_PERIODS_NUMBER = 4;
    uint256 public treasuryUnlockedAccumulated = 0;

    /*** Tokens reserved for Community Building and Airdrop Campaigns ***/

    // 450,000,000 tokens will be eventually available for the community
    //  50,000,000 tokens will be available instantly without vesting

    address public constant COMMUNITY_ALLOCATION =
        address(0x7777777777777777777777777777777777777777);
    uint256 public constant COMMUNITY_TOTAL = 450000000e18;
    uint256 public constant COMMUNITY_PERIOD_AMOUNT = 50000000e18;
    uint256 public constant COMMUNITY_UNVESTED = 50000000e18;
    uint256 public constant COMMUNITY_PERIOD_LENGTH = 6 * 30 days;
    uint8 public constant COMMUNITY_PERIODS_NUMBER = 8;
    uint256 public communityUnlockedAccumulated = 0;

    /*** Tokens reserved for Founders and Team ***/

    // 180.000.000 tokens will be eventually available for the team
    //  36,000,000 tokens will be available instantly without vesting

    address public constant TEAM_ALLOCATION =
        address(0x4444444444444444444444444444444444444444);
    uint256 public constant TEAM_TOTAL = 180000000e18;
    uint256 public constant TEAM_PERIOD_AMOUNT = 36000000e18;
    uint256 public constant TEAM_UNVESTED = 36000000e18;
    uint256 public constant TEAM_PERIOD_LENGTH = 12 * 30 days;
    uint8 public constant TEAM_PERIODS_NUMBER = 4;
    uint256 public teamUnlockedAccumulated = 0;
    
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