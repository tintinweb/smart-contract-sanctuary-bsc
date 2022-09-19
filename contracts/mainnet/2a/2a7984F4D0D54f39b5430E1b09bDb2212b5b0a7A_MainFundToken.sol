/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

/*
    Copyright 2022 Translucent.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    SPDX-License-Identifier: Apache-2.0
*/

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

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

pragma solidity ^0.8.0;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

pragma solidity ^0.8.0;

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
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
     * @dev See {IERC20-allowance}.
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
     * @dev See {IERC20-approve}.
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
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
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
     * problems described in {IERC20-approve}.
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
     * problems described in {IERC20-approve}.
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
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
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
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

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
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
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
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

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
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

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
                "ERC20: insufficient allowance"
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

pragma solidity ^0.8.12;

/**
 * @title Decimals
 * @author Translucent
 *
 * Library to supoprt a struct that represents decimal numbers.
 */
library Decimals {
    struct Number {
        uint256 value;
        uint8 decimals;
    }

    /**
     * Scale the current value up or down based on the difference
     * between the current decimals and target decimals.
     *
     * @param self - The current number struct.
     * @param targetDecimals - The decimals to scale the current value to.
     * @return - The scaled number struct.
     */
    function scaleDecimals(Number memory self, uint8 targetDecimals)
        internal
        pure
        returns (Number memory)
    {
        Number memory output = Number({
            value: self.value,
            decimals: targetDecimals
        });

        if (self.decimals > targetDecimals) {
            // Scale down
            output.value = self.value / 10**(self.decimals - targetDecimals);
        } else {
            // Scale up
            output.value = self.value * 10**(targetDecimals - self.decimals);
        }

        return output;
    }

    /**
     * Adds two numbers and preserves the first number's decimals.
     *
     * @param self - The current number struct.
     * @param other - The other number struct.
     * @return - The computed number struct.
     */
    function add(Number memory self, Number memory other)
        internal
        pure
        returns (Number memory)
    {
        return
            Number({
                value: self.value + scaleDecimals(other, self.decimals).value,
                decimals: self.decimals
            });
    }

    /**
     * Subtracts two numbers and preserves the first number's decimals.
     *
     * @param self - The current number struct.
     * @param other - The other number struct.
     * @return - The computed number struct.
     */
    function sub(Number memory self, Number memory other)
        internal
        pure
        returns (Number memory)
    {
        return
            Number({
                value: self.value - scaleDecimals(other, self.decimals).value,
                decimals: self.decimals
            });
    }

    /**
     * Multiplies two numbers and preserves the first number's decimals.
     *
     * @param self - The current number struct.
     * @param other - The other number struct.
     * @return - The computed number struct.
     */
    function mul(Number memory self, Number memory other)
        internal
        pure
        returns (Number memory)
    {
        return
            Number({
                value: (self.value * other.value) / 10**other.decimals,
                decimals: self.decimals
            });
    }

    /**
     * Divides two numbers and preserves the first number's decimals.
     *
     * @param self - The current number struct.
     * @param other - The other number struct.
     * @return - The computed number struct.
     */
    function div(Number memory self, Number memory other)
        internal
        pure
        returns (Number memory)
    {
        return
            Number({
                value: (self.value * 10**other.decimals) / other.value,
                decimals: self.decimals
            });
    }

    /**
     * Compares if first number is greater than or equal to the second.
     *
     * @param self - The current number struct.
     * @param self - The other number struct.
     * @return - The computed number struct.
     */
    function gte(Number memory self, Number memory other)
        internal
        pure
        returns (bool)
    {
        // Compare at the higher decimal precision
        if (self.decimals >= other.decimals)
            return self.value >= scaleDecimals(other, self.decimals).value;
        else return scaleDecimals(self, other.decimals).value >= other.value;
    }

    /**
     * Compares if first number is greater than the second.
     *
     * @param self - The current number struct.
     * @param self - The other number struct.
     * @return - The computed number struct.
     */
    function gt(Number memory self, Number memory other)
        internal
        pure
        returns (bool)
    {
        // Compare at the higher decimal precision
        if (self.decimals >= other.decimals)
            return self.value > scaleDecimals(other, self.decimals).value;
        else return scaleDecimals(self, other.decimals).value > other.value;
    }

    /**
     * Compares if first number is less than or equal to the second.
     *
     * @param self - The current number struct.
     * @param self - The other number struct.
     * @return - The computed number struct.
     */
    function lte(Number memory self, Number memory other)
        internal
        pure
        returns (bool)
    {
        // Compare at the higher decimal precision
        if (self.decimals >= other.decimals)
            return self.value <= scaleDecimals(other, self.decimals).value;
        else return scaleDecimals(self, other.decimals).value <= other.value;
    }
}

pragma solidity ^0.8.12;

/**
 * @title IHumanResources
 * @author Translucent
 *
 * @notice Interface for the CAO's human resources.
 */
interface IHumanResources {
    /********************************************/
    /** Structs to track the employee's details */
    /********************************************/
    struct EmployeeDetails {
        uint256 remunerationPerBlock;
        uint256 remunerationAccrued;
        uint256 lastAccruedBlock;
    }

    /*********************************/
    /** Functions to read the states */
    /*********************************/
    function getEmployeeCount() external view returns (uint256);

    function getEmployeeByIndex(uint256 employeeIndex)
        external
        view
        returns (address, EmployeeDetails memory);

    function getEmployeeByAddress(address employeeAddress)
        external
        view
        returns (EmployeeDetails memory);

    function getEmployeeCurrentRemuneration(address employeeAddress)
        external
        view
        returns (Decimals.Number memory);

    function getUnredeemedExEmployees()
        external
        view
        returns (address[] memory, EmployeeDetails[] memory);

    /***********************************/
    /** Functions to modify the states */
    /***********************************/
    function addEmployee(address employeeAddress, uint256 remunerationPerBlock)
        external;

    function updateEmployee(
        address employeeAddress,
        uint256 remunerationPerBlock
    ) external;

    function removeEmployee(address employeeAddress) external;

    function clearEmployeeRemuneration(address employeeAddress) external;
}

pragma solidity ^0.8.12;

/**
 * @title ICAOGovernor
 * @author Translucent
 *
 * @notice Interface for the centralized autonomous organization's governance.
 */
interface ICAOGovernor {
    /*******************************************************/
    /** Functions to get details and references of the CAO */
    /*******************************************************/
    function getName() external view returns (string memory);

    function getCAOTokenAddress() external view returns (address);

    /**********************************/
    /** Functions to act as modifiers */
    /**********************************/
    function requireCAOGovernance(address caller) external view;

    function requireCAOTokenHolder(address caller) external view;

    /**************************************************/
    /** Functions to manage CAO governance parameters */
    /**************************************************/
    function setAdvanceExecutionThreshold(uint256 newThreshold) external;

    /************************************************/
    /** Structs to facilitate governance and voting */
    /************************************************/
    enum Direction {
        FOR,
        AGAINST
    }
    enum Status {
        PENDING,
        REJECTED,
        APPROVED_AND_EXECUTED,
        APPROVED_BUT_FAILED
    }
    struct Proposal {
        address proposer;
        string description;
        uint256 startBlock;
        uint256 endBlock;
        address[] callAddresses;
        bytes[] callDatas;
        uint256[] callValues;
        uint256 votesFor;
        uint256 votesAgainst;
        Status status;
        uint256 blockExecuted;
        bytes[] returnDatas;
    }

    /**************************************************/
    /** Functions to facilitate governance and voting */
    /**************************************************/
    function createProposal(
        string memory description,
        uint256 blockDelay,
        uint256 blocksDuration,
        address[] calldata callAddresses,
        bytes[] calldata callDatas,
        uint256[] calldata callValues
    ) external returns (uint256);

    function vote(
        uint256 proposalId,
        Direction direction,
        string memory reason
    ) external;

    function executeProposal(uint256 proposalId) external returns (Status);

    /********************************************/
    /** Functions to read the governance states */
    /********************************************/
    function getNumProposals() external view returns (uint256);

    function getActiveProposalsIds() external view returns (uint256[] memory);

    function getProposal(uint256 proposalId)
        external
        view
        returns (Proposal memory);

    function getIsProposalExecutable(uint256 proposalId)
        external
        view
        returns (bool);
}

pragma solidity ^0.8.12;

/**
 * @title ICAO
 * @author Translucent
 *
 * @notice Interface for the centralized autonomous organization.
 */
interface ICAO is ICAOGovernor {
    /***************************************/
    /** Functions to set the CAO's helpers */
    /***************************************/
    function setCAOParameters(address parametersAddress) external;

    function setCAOHelpers(address humanResourcesAddress) external;

    /***************************************/
    /** Functions to get the CAO's helpers */
    /***************************************/
    function getHumanResources() external view returns (IHumanResources);

    /**********************************/
    /** Functions to act as modifiers */
    /**********************************/
    function requireCAO(address caller) external view;

    function requireCAOTaskRunner(address caller) external view;

    /****************************************/
    /** Functions for employees interaction */
    /****************************************/
    function computeTokenRedeemAmount(address tokenAddress)
        external
        view
        returns (uint256);

    function redeemRemuneration(address tokenAddress) external;
}

pragma solidity ^0.8.12;

/**
 * @title IAccounting
 * @author Translucent
 *
 * @notice Interface for the main fund's accounting department.
 */
interface IAccounting {
    /********************************************/
    /** Functions to manage the fund parameters */
    /********************************************/
    /** Read */
    function getManagementFee() external view returns (uint256);

    function getEvaluationPeriodBlocks() external view returns (uint32);

    /** Write */
    function setMangementFee(uint256 newManagementFee) external;

    function setEvaluationPeriodBlocks(uint32 newEvaluationPeriodBlocks)
        external;

    /********************************************/
    /** Functions to read the accounting states */
    /********************************************/
    struct AccountingState {
        uint256 aumValue;
        uint256 periodBeginningBlock;
        uint256 periodBeginningAum;
        uint256 periodBeginningSupply;
        uint256 theoreticalSupply;
    }

    function getAumValue() external view returns (Decimals.Number memory);

    function getFundTokenPrice() external view returns (Decimals.Number memory);

    function getState() external view returns (AccountingState memory);

    /*******************************************************/
    /** Functions to manage the accounting process (tasks) */
    /*******************************************************/
    function recordDeposits(uint256 depositValue, uint256 amountMinted)
        external; // frontOffice task

    function recordWithdrawals(uint256 withdrawalValue, uint256 amountBurned)
        external; // frontOffice task

    function recordAumValue(uint256 newAumValue) external; // accounting task
}

pragma solidity ^0.8.12;

/**
 * @title FrontOfficeHelpers
 * @author Translucent
 *
 * FrontOffice helper for providing the request and queue structs
 * to replicate a queue of deposits and withdrawal requests.
 */
library FrontOfficeHelpers {
    /*******************/
    /** Request struct */
    /*******************/
    // NOTE: status NULL = 0 as default uninitialized status (do not change)
    //       this is so we can differentitate uninitialized from pending statuses.
    enum RequestStatus {
        NULL,
        PENDING,
        CANCELLED,
        SUCCESSFUL,
        AMOUNT_TOO_LARGE,
        EXPIRED,
        INSUFFICIENT_OUTPUT,
        INCENTIVE_NOT_FOUND,
        INCENTIVE_NOT_QUALIFIED,
        UNHANDLED
    }
    struct Request {
        address user;
        uint256 amountIn;
        uint256 minAmountOut;
        uint256 blockDeadline;
        address incentive; // used only for deposits (ignored for withdrawals)
        RequestStatus status;
        uint256 blockUpdated;
        uint256 computedAmountOut;
        bool isReclaimed;
    }

    /**
     * Helper function to check if a request is in the pending status.
     *
     * @param request - The request struct.
     * @return - Whether the request is pending or not.
     */
    function isPending(Request memory request) internal pure returns (bool) {
        return request.status == RequestStatus.PENDING;
    }

    /**
     * Helper function to check if a request is in the pending status.
     *
     * @param request - The request struct.
     * @return - Whether the request is pending or not.
     */
    function _isPending(Request storage request) internal view returns (bool) {
        return request.status == RequestStatus.PENDING;
    }

    /**
     * Helper function to check if a request is in a failed status.
     *
     * @param request - The request struct.
     * @return - Whether the request is pending or not.
     */
    function isFailed(Request storage request) internal view returns (bool) {
        RequestStatus status = request.status;
        return
            status == RequestStatus.EXPIRED ||
            status == RequestStatus.INSUFFICIENT_OUTPUT ||
            status == RequestStatus.INCENTIVE_NOT_FOUND ||
            status == RequestStatus.INCENTIVE_NOT_QUALIFIED ||
            status == RequestStatus.UNHANDLED;
    }

    /**
     * Sets the status of a request to failed.
     *
     * @param request - The request struct.
     */
    function setCancelled(Request storage request) internal {
        require(
            _isPending(request),
            "FrontOfficeLib: cannot set a non-pending request to cancelled"
        );
        request.status = RequestStatus.CANCELLED;
        request.blockUpdated = block.number;
    }

    /**
     * Sets the status of a request to amount too large.
     *
     * @param request - The request struct.
     */
    function setAmountTooLarge(Request storage request) internal {
        require(
            _isPending(request),
            "FrontOfficeLib: cannot set a non-pending request to failed"
        );
        request.status = RequestStatus.AMOUNT_TOO_LARGE;
        request.blockUpdated = block.number;
    }

    /**
     * Sets the status of a request to expired.
     *
     * @param request - The request struct.
     */
    function setExpired(Request storage request) internal {
        require(
            _isPending(request),
            "FrontOfficeLib: cannot set a non-pending request to failed"
        );
        request.status = RequestStatus.EXPIRED;
        request.blockUpdated = block.number;
    }

    /**
     * Sets the status of a request to insufficient output.
     *
     * @param request - The request struct.
     */
    function setInsufficientOutput(
        Request storage request,
        uint256 computedAmountOut
    ) internal {
        require(
            _isPending(request),
            "FrontOfficeLib: cannot set a non-pending request to failed"
        );
        request.status = RequestStatus.INSUFFICIENT_OUTPUT;
        request.blockUpdated = block.number;
        request.computedAmountOut = computedAmountOut;
    }

    /**
     * Sets the status of a request to incentive not found.
     *
     * @param request - The request struct.
     */
    function setIncentiveNotFound(
        Request storage request,
        uint256 computedAmountOut
    ) internal {
        require(
            _isPending(request),
            "FrontOfficeLib: cannot set a non-pending request to failed"
        );
        request.status = RequestStatus.INCENTIVE_NOT_FOUND;
        request.blockUpdated = block.number;
        request.computedAmountOut = computedAmountOut;
    }

    /**
     * Sets the status of a request to incentive not qualified.
     *
     * @param request - The request struct.
     */
    function setIncentiveNotQualified(
        Request storage request,
        uint256 computedAmountOut
    ) internal {
        require(
            _isPending(request),
            "FrontOfficeLib: cannot set a non-pending request to failed"
        );
        request.status = RequestStatus.INCENTIVE_NOT_QUALIFIED;
        request.blockUpdated = block.number;
        request.computedAmountOut = computedAmountOut;
    }

    /**
     * Sets the status of a request to unhandled.
     *
     * @param request - The request struct.
     */
    function setUnhandled(Request storage request) internal {
        require(
            _isPending(request),
            "FrontOfficeLib: cannot set a non-pending request to unhandled"
        );
        request.status = RequestStatus.UNHANDLED;
        request.blockUpdated = block.number;
    }

    /**
     * Sets the status of a request to success.
     *
     * @param request - The request struct.
     */
    function setSuccessful(Request storage request, uint256 computedAmountOut)
        internal
    {
        require(
            _isPending(request),
            "FrontOfficeLib: cannot set a non-pending request to successful"
        );
        request.status = RequestStatus.SUCCESSFUL;
        request.blockUpdated = block.number;
        request.computedAmountOut = computedAmountOut;
    }

    /*****************/
    /** Queue struct */
    /*****************/
    struct Queue {
        mapping(uint256 => Request) requests;
        uint256 readIdx;
        uint256 writeIdx;
    }

    /**
     * Gets the length of the queue.
     *
     * @param queue - The queue struct.
     * @return - The `length` based on the difference between the indexes.
     */
    function length(Queue storage queue) internal view returns (uint256) {
        return queue.writeIdx - queue.readIdx;
    }

    /**
     * Pushes a request into the queue.
     *
     * @param queue - The queue struct.
     * @param userAddress - The address of the user.
     * @param amountIn - The input amount.
     * @param minAmountOut - The min output amount for the request to succeed.
     * @param blockDeadline - The latest block that the request can be executed
     * @return - The queue number (index) of the request.
     */
    function push(
        Queue storage queue,
        address userAddress,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 blockDeadline,
        address incentive
    ) internal returns (uint256) {
        // Pull the current writeIdx into memory
        uint256 currentWriteIdx = queue.writeIdx;

        // Write into the queue at the current writeIdx
        queue.requests[currentWriteIdx] = Request({
            user: userAddress,
            amountIn: amountIn,
            minAmountOut: minAmountOut,
            blockDeadline: blockDeadline,
            incentive: incentive,
            status: RequestStatus.PENDING,
            blockUpdated: 0,
            computedAmountOut: 0,
            isReclaimed: false
        });

        // Increment the writeIdx
        queue.writeIdx++;

        // Return the current writeIdx
        return currentWriteIdx;
    }

    /**
     * Reads the first request in the queue.
     *
     * @param queue - The queue struct.
     * @return - The reference to the request.
     */
    function front(Queue storage queue)
        internal
        view
        returns (Request storage)
    {
        return queue.requests[queue.readIdx];
    }

    /**
     * Pops a request from the queue.
     *
     * @dev This replicates the interface of a queue's pop op
     *      although we never actually `pop` the request from the map,
     *      merely incrementing the readIdx.
     *
     * @dev We also do not perform checks on the index since it is guaranteed
     *      that we will not pop beyond the write index internally.
     *
     * @param queue - The queue struct.
     */
    function pop(Queue storage queue) internal {
        // Increment the readIdx
        queue.readIdx++;
    }
}

pragma solidity ^0.8.12;

/**
 * @title IFrontOffice
 * @author Translucent
 *
 * @notice Interface for the main fund's front office department.
 */
interface IFrontOffice {
    /****************************************************/
    /** Function to get the parameters contract address */
    /****************************************************/
    function getParametersAddress() external view returns (address);

    /******************************************/
    /** Functions to facilitate user requests */
    /******************************************/
    /** Structs */
    /**
     * Lookup struct to invert the mapping to facilitate searching of
     * a user's latest request by tracking the accessors.
     */
    struct RequestAccessor {
        bool isDeposit;
        address token;
        uint256 queueNumber;
    }

    /** Read */
    function getUserRequestCount(address userAddress)
        external
        view
        returns (uint256);

    function getUserRequestByIndex(address userAddress, uint256 index)
        external
        view
        returns (RequestAccessor memory, FrontOfficeHelpers.Request memory);

    function getDepositsQueueLength(address tokenAddress)
        external
        view
        returns (uint256);

    function getWithdrawalsQueueLength(address tokenAddress)
        external
        view
        returns (uint256);

    /** Write */
    function requestDeposit(
        address tokenAddress,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 blockDeadline,
        address incentive
    ) external;

    function requestWithdrawal(
        address tokenAddress,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 blockDeadline
    ) external;

    function cancelLatestRequest() external;

    function reclaimFromFailedRequest(uint256 index) external;

    /***************************************************************/
    /** Functions to facilitate the processing of requests (tasks) */
    /***************************************************************/
    function processDeposits(
        address tokenAddress,
        uint256 maxRequestsToProcess // Limits txn size and allows batching
    ) external;

    function processWithdrawals(
        address tokenAddress,
        uint256 maxRequestsToProcess // Limits txn size and allows batching
    ) external;
}

pragma solidity ^0.8.12;

/**
 * @title IIncentivesManager
 * @author Translucent
 *
 * @notice Interface for the main fund's incentives manager.
 */
interface IIncentivesManager {
    /************************************************/
    /** Functions to read and modify the parameters */
    /************************************************/
    function getIncentives() external view returns (address[] memory);

    function addIncentive(address incentiveAddress) external;

    function removeIncentive(address incentiveAddress) external;

    /*********************************************************/
    /** Functions to aggregate the incentives for accounting */
    /*********************************************************/
    function getDilutionDetails(
        Decimals.Number memory periodBeginningSupply,
        Decimals.Number memory returnsFactor
    )
        external
        returns (
            Decimals.Number memory,
            address[] memory,
            Decimals.Number[] memory
        );

    /******************************************/
    /** Functions for use by the front office */
    /******************************************/
    enum ValidityCode {
        VALID,
        NOT_APPLICABLE,
        NOT_FOUND,
        NOT_QUALIFIED
    }

    function checkValidity(address incentiveAddress, address userAddress)
        external
        returns (ValidityCode);
}

pragma solidity ^0.8.12;

/**
 * @title IMainFundToken
 * @author Translucent
 *
 * @notice Interface for the main fund's token.
 */
interface IMainFundToken is IERC20 {
    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;
}

pragma solidity ^0.8.12;

/**
 * @title IMainFund
 * @author Translucent
 *
 * @notice Interface for the centralized autonomous organization's token.
 */
interface IMainFund {
    /****************************************/
    /** Functions to set the fund's helpers */
    /****************************************/
    function setMainFundHelpers(
        address caoAddress,
        address tokenAddress,
        address accountingAddress,
        address frontOfficeAddress,
        address incentivesManagerAddress
    ) external;

    /****************************************/
    /** Functions to get the fund's helpers */
    /****************************************/
    function getCAO() external view returns (ICAO);

    function getFundToken() external view returns (IMainFundToken);

    function getAccounting() external view returns (IAccounting);

    function getFrontOffice() external view returns (IFrontOffice);

    function getIncentivesManager() external view returns (IIncentivesManager);

    /****************************************/
    /** Functions to facilitate withdrawals */
    /****************************************/
    function approveFrontOfficeForWithdrawals(
        address[] calldata tokensAddresses,
        uint256[] calldata amounts
    ) external;
}

pragma solidity ^0.8.12;

/**
 * @title MainFundHelper
 * @author Translucent
 *
 * @notice Base contract for main fund helpers to inherit from,
 *         providing reference to the fund contract.
 */
abstract contract MainFundHelper is Context {
    address private _fundAddress;

    /**
     * Sets the fund
     */
    constructor(address fundAddress) {
        _fundAddress = fundAddress;
    }

    /**
     * @dev Returns the address of the fund.
     */
    function getFundAddress() public view returns (address) {
        return _fundAddress;
    }

    /**
     * @dev Returns the address of the fund.
     */
    function getFund() public view returns (IMainFund) {
        return IMainFund(_fundAddress);
    }

    /**
     * @dev Throws if called by any account other than the fund.
     */
    modifier onlyFund() {
        require(
            _fundAddress == _msgSender(),
            "MainFundHelper: caller is not the fund"
        );
        _;
    }
}

pragma solidity ^0.8.12;

/**
 * @title MainFundToken
 * @author Translucent
 *
 * @notice Contract for the main fund's token.
 */
contract MainFundToken is ERC20, MainFundHelper, IMainFundToken {
    /** Constructor */
    constructor(
        address fundAddress,
        string memory name,
        string memory symbol,
        address initialAccount,
        uint256 initialAmount
    ) ERC20(name, symbol) MainFundHelper(fundAddress) {
        _mint(initialAccount, initialAmount);
    }

    /**
     * Mints the token to a user.
     *
     * @param account - The user to mint to.
     * @param amount - The amount to mint.
     */
    function mint(address account, uint256 amount) external {
        // Only callable by the front office, accounting, or fund contracts
        require(
            _msgSender() == address(getFund().getFrontOffice()) ||
                _msgSender() == address(getFund().getAccounting()) ||
                _msgSender() == getFundAddress(),
            "MainFundToken: caller is not the fund, front office, or accounting contract"
        );
        _mint(account, amount);
    }

    /**
     * Burns the token from a user.
     *
     * @param account - The user to burn from.
     * @param amount - The amount to burn.
     */
    function burn(address account, uint256 amount) external {
        // Only callable by the front office, accounting, or fund contracts
        require(
            _msgSender() == address(getFund().getFrontOffice()) ||
                _msgSender() == address(getFund().getAccounting()) ||
                _msgSender() == getFundAddress(),
            "MainFundToken: caller is not the fund, front office, or accounting contract"
        );
        _burn(account, amount);
    }
}