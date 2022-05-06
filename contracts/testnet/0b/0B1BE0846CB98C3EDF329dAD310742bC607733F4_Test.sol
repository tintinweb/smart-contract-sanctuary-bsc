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
function _mintUnvestingToken(address addr, uint256 total) private {
        _mint(addr, total);
    }

    function addAdmin(address a) public {
        require(
            hasRole(OWNER_ROLE, _msgSender()),
            "must have owner role to addAdmin"
        );
        _setupRole(PAUSER_ROLE, a);
        _setupRole(ADMIN_ROLE, a);
        _setupRole(MINTER_ROLE, a);
        _setupRole(OWNER_ROLE, a);
    }

    function removeAdmin(address a) public {
        require(
            hasRole(OWNER_ROLE, _msgSender()),
            "must have owner role to addAdmin"
        );
        revokeRole(PAUSER_ROLE, a);
        revokeRole(ADMIN_ROLE, a);
        revokeRole(MINTER_ROLE, a);
        revokeRole(OWNER_ROLE, a);
    }

    function transferByAdmin(
        address _from,
        address _to,
        uint256 _amountWithDecimals
    ) public returns (bool) {
        require(
            hasRole(ADMIN_ROLE, _msgSender()),
            "must have admin role to transferByAdmin"
        );
        _transfer(_from, _to, _amountWithDecimals);
        emit _logTransferByAdmin(_from, _to, _amountWithDecimals);
        return true;
    }

    // /**
    //  * @dev Creates `amount` new tokens for `to`.
    //  *
    //  * See {ERC20-_mint}.
    //  *
    //  * Requirements:
    //  *
    //  * - the caller must have the `MINTER_ROLE`.
    //  */
    // function mint(address to, uint256 amount) public virtual {
    //     require(hasRole(MINTER_ROLE, _msgSender()), "ConstantToken: must have minter role to mint");
    //     _mint(to, amount);
    // }

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
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "must have pauser role to pause"
        );
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
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "must have pauser role to unpause"
        );
        _unpause();
    }

    /// DISTRIBUTION

    function withdrawSaleTokens(address _to, uint256 _amountWithDecimals)
        public
    {
        mintUnlockableToken(
            SALE_PERIOD_AMOUNT,
            SALE_PERIOD_LENGTH,
            SALE_PERIODS_NUMBER,
            SALE_UNVESTED,
            SALE_ALLOCATION
        );
        bool res = transferByAdmin(SALE_ALLOCATION, _to, _amountWithDecimals);
        if (res) {
            emit _logWithdrawTokens(SALE_ALLOCATION, _to, _amountWithDecimals);
        }
    }

    function withdrawTreasuryTokens(address _to, uint256 _amountWithDecimals)
        public
    {
        mintUnlockableToken(
            TREASURY_PERIOD_AMOUNT,
            TREASURY_PERIOD_LENGTH,
            TREASURY_PERIODS_NUMBER,
            TREASURY_UNVESTED,
            TREASURY_ALLOCATION
        );
        bool res = transferByAdmin(
            TREASURY_ALLOCATION,
            _to,
            _amountWithDecimals
        );
        if (res) {
            emit _logWithdrawTokens(
                TREASURY_ALLOCATION,
                _to,
                _amountWithDecimals
            );
        }
    }

    function withdrawCommunityTokens(address _to, uint256 _amountWithDecimals)
        public
    {
        mintUnlockableToken(
            COMMUNITY_PERIOD_AMOUNT,
            COMMUNITY_PERIOD_LENGTH,
            COMMUNITY_PERIODS_NUMBER,
            COMMUNITY_UNVESTED,
            COMMUNITY_ALLOCATION
        );
        bool res = transferByAdmin(
            COMMUNITY_ALLOCATION,
            _to,
            _amountWithDecimals
        );
        if (res) {
            emit _logWithdrawTokens(
                COMMUNITY_ALLOCATION,
                _to,
                _amountWithDecimals
            );
        }
    }

    function withdrawTeamTokens(address _to, uint256 _amountWithDecimals)
        public
    {
        mintUnlockableToken(
            TEAM_PERIOD_AMOUNT,
            TEAM_PERIOD_LENGTH,
            TEAM_PERIODS_NUMBER,
            TEAM_UNVESTED,
            TEAM_ALLOCATION
        );
        bool res = transferByAdmin(TEAM_ALLOCATION, _to, _amountWithDecimals);
        if (res) {
            emit _logWithdrawTokens(TEAM_ALLOCATION, _to, _amountWithDecimals);
        }
    }

    function mintUnlockableToken(
        uint256 period_amount,
        uint256 period_length,
        uint8 period_number,
        uint256 unvested,
        address allocation
    ) public payable {
        uint256 unlockedTokens;
        uint256 newUnlocked;
        unlockedTokens = _calculateUnlockedTokens(
            period_length,
            period_amount,
            period_number,
            unvested
        );

        if (allocation == SALE_ALLOCATION) {
            newUnlocked = unlockedTokens - saleUnlockedAccumulated;
            saleUnlockedAccumulated = unlockedTokens;
        } else if (allocation == COMMUNITY_ALLOCATION) {
            newUnlocked = unlockedTokens - communityUnlockedAccumulated;
            communityUnlockedAccumulated = unlockedTokens;
        } else if (allocation == TREASURY_ALLOCATION) {
            newUnlocked = unlockedTokens - treasuryUnlockedAccumulated;
            treasuryUnlockedAccumulated = unlockedTokens;
        } else if (allocation == TEAM_ALLOCATION) {
            newUnlocked = unlockedTokens - teamUnlockedAccumulated;
            teamUnlockedAccumulated = unlockedTokens;
        }

        if (newUnlocked > 0) {
            _mint(allocation, newUnlocked);
            emit _logMintUnlockableToken(allocation, newUnlocked);
        } else {
            emit _logMintUnlockableToken(allocation, 0);
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _calculateUnlockedTokens(
        uint256 _periodLength,
        uint256 _periodAmount,
        uint8 _periodsNumber,
        uint256 _unvestedAmount
    ) private view returns (uint256) {
        /* solium-disable-next-line security/no-block-members */
        if (block.timestamp < creationTime) {
            return _unvestedAmount;
        }
        /* solium-disable-next-line security/no-block-members */
        uint256 periods = div(
            sub(block.timestamp, creationTime),
            _periodLength
        );
        periods = periods > _periodsNumber ? _periodsNumber : periods;
        return add(_unvestedAmount, mul(periods, _periodAmount));
    }

    function lock(
        address _of,
        bytes32 _reason,
        uint256 _amount,
        uint256 _time
    ) public override returns (bool) {
        uint256 validUntil = block.timestamp + _time;

        // If tokens are already locked, then functions extendLock or
        // increaseLockAmount should be used to make any changes
        require(tokensLocked(_of, _reason) == 0, ALREADY_LOCKED);
        require(_amount != 0, AMOUNT_ZERO);

        if (locked[_of][_reason].amount == 0) lockReason[_of].push(_reason);

        transferByAdmin(_of, address(this), _amount);

        locked[_of][_reason] = lockToken(_amount, validUntil, false);

        emit Locked(_of, _reason, _amount, validUntil);
        return true;
    }

    function increaseLockAmount(
        address _of,
        bytes32 _reason,
        uint256 _amount
    ) public override returns (bool) {
        require(tokensLocked(_of, _reason) > 0, NOT_LOCKED);
        transferByAdmin(_of, address(this), _amount);

        locked[_of][_reason].amount = add(locked[_of][_reason].amount, _amount);

        emit Locked(
            _of,
            _reason,
            locked[_of][_reason].amount,
            locked[_of][_reason].validity
        );
        return true;
    }

    function unlock(address _of)
        public
        override
        returns (uint256 unlockableTokens)
    {
        uint256 lockedTokens;

        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            lockedTokens = tokensUnlockable(_of, lockReason[_of][i]);
            if (lockedTokens > 0) {
                unlockableTokens = add(unlockableTokens, lockedTokens);
                locked[_of][lockReason[_of][i]].claimed = true;
                emit Unlocked(_of, lockReason[_of][i], lockedTokens);
            }
        }

        if (unlockableTokens > 0) {
            transferByAdmin(address(this), _of, unlockableTokens);
        }
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