// SPDX-License-Identifier: MIT
    pragma solidity ^0.8.7;

    import "./BEP20.sol";
    import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

    /**
    * @title TokenVesting.
    */
    contract TokenVesting is Ownable, ReentrancyGuard {
        using SafeMath for uint256;

        // start time of the vesting period.
        uint256 private immutable vestingStart;
        // cliff period in seconds.
        uint256 private immutable vestingCliff;
        // duration of the vesting period in seconds.
        uint256 private immutable vestingDuration;
        // duration of a slice period for the vesting in seconds.
        uint256 private immutable vestingSlicePeriod;

        struct VestingStructure {
            bool initialized;
            // beneficiary of tokens after they're released.
            address beneficiary;
            // whether or not the vesting is revocable.
            bool revocable;
            // total amount of tokens to be released at the end of the vesting.
            uint256 amountTotal;
            // amount of tokens released.
            uint256 released;
            // whether or not the vesting has been revoked.
            bool revoked;
        }

        // Address of the BEP20 token.
        BEP20 private immutable token;

        mapping(bytes32 => VestingStructure) private vestingIdToVestingStructure;

        uint256 private VestingTotalAmount;

        event Released(bytes32 vestingId, uint256 totalTokenAmountReleased);
        event Revoked(
            bytes32 vestingId,
            uint256 totalTokenAmountReleased,
            bool revoked
        );
        event NewVestingSchedule(
            bytes32 vestingId,
            address beneficiary,
            bool revocable,
            uint256 amountTotal,
            uint256 released,
            bool revoked
        );

        /**
        * @dev Reverts if the vesting schedule does not exist or has been revoked.
        */
        modifier onlyIfVestingNotRevoked(bytes32 vestingId) {
            require(
                vestingIdToVestingStructure[vestingId].initialized,
                "TokenVesting: vesting schedule's not initialized"
            );
            require(
                !vestingIdToVestingStructure[vestingId].revoked,
                "TokenVesting: vesting schedule's revoked"
            );
            _;
        }

        /**
        * @dev Reverts if the address provided is of zero type.
        */
        modifier zeroAddressCheck(address account) {
            require(
                account != address(0),
                "TokenVesting: zero address not permitted!"
            );
            _;
        }

        /**
        * @dev Creates a vesting contract.
        * @param token_ address of the BEP20 token contract
        */
        constructor(
            BEP20 token_,
            uint256 _vestingStart,
            uint256 _vestingCliff,
            uint256 _vestingDuration,
            uint256 _vestingSlicePeriod
        ) zeroAddressCheck(address(token_)) {
            require(
                _vestingDuration > 0,
                "TokenVesting: vesting duration must be greater than 0."
            );
            require(
                _vestingSlicePeriod >= 1,
                "TokenVesting: vesting slicePeriodSeconds must be greater than or equal to 1."
            );

            token = token_;
            vestingStart = _vestingStart;
            vestingCliff = _vestingStart.add(_vestingCliff);
            vestingDuration = _vestingDuration;
            vestingSlicePeriod = _vestingSlicePeriod;
        }

        /**
        * @notice Returns the vesting information for a given holder.
        * @return the vesting structure information.
        */
        function getVestingScheduleByAddress(address holder)
            external
            view
            zeroAddressCheck(holder)
            returns (VestingStructure memory)
        {
            return getVestingSchedule(computeVestingIdForAddress(holder));
        }

        /**
        * @notice Computes the vesting identifier for an address.
        * @return the vesting schedule identifier in bytes.
        */
        function computeVestingIdForAddress(address holder)
            internal
            pure
            zeroAddressCheck(holder)
            returns (bytes32)
        {
            return keccak256(abi.encodePacked(holder));
        }

        /**
        * @notice Returns the vesting schedule information for a given identifier.
        * @return the vesting schedule structure information.
        */
        function getVestingSchedule(bytes32 vestingId)
            internal
            view
            returns (VestingStructure memory)
        {
            return vestingIdToVestingStructure[vestingId];
        }

        /**
        * @notice Returns the total amount of vesting schedules.
        * @return the total amount of vesting schedules.
        */
        function getVestingTotalAmount() external view returns (uint256) {
            return VestingTotalAmount;
        }

        /**
        * @notice Returns the address of the BEP20 token managed by the vesting contract.
        * @return the address of the BEP20 token.
        */
        function getTokenAddress() external view returns (address) {
            return address(token);
        }

        /**
        * @notice Creates a new vesting schedule for a beneficiary.
        * @param _beneficiary address of the beneficiary to whom vested tokens are transferred.
        * @param _amount total amount of tokens to be released at the end of the vesting.
        */
        function vestingAllocation(address _beneficiary, uint256 _amount)
            external
            onlyOwner
            zeroAddressCheck(_beneficiary)
        {
            require(
                getCurrentTime() < vestingStart,
                "TokenVesting: cannot create schedules since vesting period has begun."
            );
            require(_amount > 0, "TokenVesting: amount must be greater than 0.");
            require(
                getNonAllocatedTokenAmount() >= _amount,
                "TokenVesting: cannot create vesting schedule because of insufficient tokens."
            );

            bytes32 vestingId = computeVestingIdForAddress(_beneficiary);

            if (vestingIdToVestingStructure[vestingId].amountTotal > 0) {
                vestingIdToVestingStructure[vestingId].amountTotal =
                    vestingIdToVestingStructure[vestingId].amountTotal +
                    _amount;

                VestingTotalAmount = VestingTotalAmount.add(_amount);
            } else {
                vestingIdToVestingStructure[vestingId] = VestingStructure(
                    true,
                    _beneficiary,
                    true,
                    _amount,
                    0,
                    false
                );

                emit NewVestingSchedule(
                    vestingId,
                    _beneficiary,
                    true,
                    _amount,
                    0,
                    false
                );

                VestingTotalAmount = VestingTotalAmount.add(_amount);
            }
        }

        /**
        * @notice Revokes the vesting schedule for given identifier.
        * @param beneficiary the vesting token holder.
        */
        function revoke(address beneficiary)
            external
            onlyOwner
            zeroAddressCheck(beneficiary)
            onlyIfVestingNotRevoked(computeVestingIdForAddress(beneficiary))
        {
            bytes32 vestingId = computeVestingIdForAddress(beneficiary);

            require(
                vestingIdToVestingStructure[vestingId].revocable,
                "TokenVesting: vesting schedule is not revocable"
            );

            VestingStructure storage vestingStructure = vestingIdToVestingStructure[
                vestingId
            ];

            release(beneficiary);
            vestingStructure.revoked = true;

            uint256 unreleased = vestingStructure.amountTotal.sub(
                vestingStructure.released
            );

            VestingTotalAmount = VestingTotalAmount.sub(unreleased);

            emit Revoked(vestingId, vestingStructure.released, true);
        }

        /**
        * @notice Withdraw all available funds.
        */
        function withdrawAvailableFunds() external nonReentrant onlyOwner {
            require(
                getNonAllocatedTokenAmount() > 0,
                "TokenVesting: cannot withdraw because of insufficient tokens"
            );

            token.transfer(owner(), getNonAllocatedTokenAmount());
        }

        /**
        * @notice Release vested amount of tokens.
        * @param beneficiary the vesting token holder.
        */
        function release(address beneficiary)
            public
            nonReentrant
            zeroAddressCheck(beneficiary)
            onlyIfVestingNotRevoked(computeVestingIdForAddress(beneficiary))
        {
            bytes32 vestingId = computeVestingIdForAddress(beneficiary);

            VestingStructure storage vestingStructure = vestingIdToVestingStructure[
                vestingId
            ];

            bool isBeneficiary = msg.sender == vestingStructure.beneficiary;
            bool isOwner = msg.sender == owner();

            require(
                isBeneficiary || isOwner,
                "TokenVesting: only beneficiary and owner can release vested tokens."
            );

            uint256 vestedAmount = _computeReleasableAmount(vestingStructure);

            require(
                vestedAmount > 0,
                "TokenVesting: cannot release tokens, not enough vested tokens."
            );

            vestingStructure.released = vestingStructure.released.add(vestedAmount);

            VestingTotalAmount = VestingTotalAmount.sub(vestedAmount);

            token.transfer(vestingStructure.beneficiary, vestedAmount);
            emit Released(vestingId, vestingStructure.released);
        }

        /**
        * @notice Computes the vested amount of tokens for a given holder.
        * @param beneficiary the vesting token holder.
        * @return the vested amount.
        */
        function computeReleasableAmount(address beneficiary)
            public
            view
            zeroAddressCheck(beneficiary)
            onlyIfVestingNotRevoked(computeVestingIdForAddress(beneficiary))
            returns (uint256)
        {
            bytes32 vestingId = computeVestingIdForAddress(beneficiary);

            VestingStructure storage vestingStructure = vestingIdToVestingStructure[
                vestingId
            ];

            return _computeReleasableAmount(vestingStructure);
        }

        /**
        * @dev Returns the amount of tokens that can be withdrawn by the owner.
        * @return the amount of tokens.
        */
        function getNonAllocatedTokenAmount() internal view returns (uint256) {
            return token.balanceOf(address(this)).sub(VestingTotalAmount);
        }

        /**
        * @dev Computes the releasable amount of tokens for a vesting schedule.
        * @param vestingStructure vesting information of a specific beneficiary.
        * @return the amount of releasable tokens.
        */
        function _computeReleasableAmount(VestingStructure memory vestingStructure)
            internal
            view
            returns (uint256)
        {
            require(
                getCurrentTime() > vestingCliff,
                "TokenVesting: cliff period isn't over!"
            );
            require(
                !vestingStructure.revoked,
                "TokenVesting: vesting schedule has already been revoked!"
            );

            if (getCurrentTime() >= vestingStart.add(vestingDuration)) {
                return vestingStructure.amountTotal.sub(vestingStructure.released);
            } else {
                uint256 timeFromStart = getCurrentTime().sub(vestingStart);
                uint256 secondsPerSlice = vestingSlicePeriod;
                uint256 vestedSlicePeriods = timeFromStart.div(secondsPerSlice);
                uint256 vestedSeconds = vestedSlicePeriods.mul(secondsPerSlice);
                return
                    vestingStructure
                        .amountTotal
                        .mul(vestedSeconds)
                        .div(vestingDuration)
                        .sub(vestingStructure.released);
            }
        }

        function getCurrentTime() internal view virtual returns (uint256) {
            return block.timestamp;
        }
    }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IBEP20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BEP20 is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _symbol;
    string private _name;

    modifier zeroAddressCheck(address account) {
        require(
            account != address(0),
            "BEP20: transfer from/to the zero address"
        );
        _;
    }

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view override returns (address) {
        return owner();
    }

    /**
     * @dev Returns the BEP20 token decimals.
     */
    function decimals() public pure override returns (uint8) {
        return 18;
    }

    /**
     * @dev Returns the BEP20 token symbol.
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the BEP20 token name.
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IBEP20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IBEP20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IBEP20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IBEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "BEP20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual zeroAddressCheck(from) zeroAddressCheck(to) {
        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "BEP20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount)
        internal
        virtual
        zeroAddressCheck(account)
    {
        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount)
        internal
        virtual
        zeroAddressCheck(account)
    {
        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual zeroAddressCheck(owner) zeroAddressCheck(spender) {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "BEP20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}