// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "@openzeppelin/contracts-newone/utils/math/Math.sol";
import "@openzeppelin/contracts-newone/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-newone/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-newone/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts-newone/utils/Counters.sol";
import "@openzeppelin/contracts-newone/access/Ownable.sol";

/**
 * @dev Interface of policy contract for permission for claim.
 */
interface IVestingPolicy {
    /**
     * @dev Returns number of tokens, which are permitted to claim
     * for this address.
     *
     */
    function permittedForClaim(address) external view returns (uint256);


     /**
     * @dev Decrease permitted amount of tokens to claim
     * for this address.
     *
     */
    function decreaseAnountToClaim(address, uint256) external returns (bool);
}

contract EywaVesting is ERC20, ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    // Relative timestamp to use transfer/transferFrom without permission
    uint256 public permissionlessTimeStamp; 

    // Absolute timestamp of vesting period start 
    uint256 public started;

    // Token which is vested on this contract
    IERC20 public immutable eywaToken;

    struct cliffData{
        // Relative timestamp first cliff duration    
        uint256 cliffDuration1; 

        // Claimable number of tokens after first cliff period
        uint256 cliffAmount1; 

        // Relative timestamp second cliff duration    
        uint256 cliffDuration2; 

        // Claimable number of tokens after second cliff period
        uint256 cliffAmount2; 

        // Relative timestamp third cliff duration    
        uint256 cliffDuration3; 

        // Claimable number of tokens after third cliff period
        uint256 cliffAmount3; 
    }

    cliffData public cliffs;

    // Duration of one linear or discrete step
    uint256 public stepDuration; 

    // Number linear or discrete steps
    uint256 public numOfSteps; 

    // Relative timestamp to claim without permission
    uint256 claimWithAllowanceTimeStamp;

    // Contract which gives permission to claim before claimWithAllowanceTimeStamp
    IVestingPolicy public claimAllowanceContract;
    
    /**
     * The number of claimed tokens in ``address``'s account.
     * Note: it doesn't necessary represent how much ``address`` claimed
     * because after transfer/transfer from, it also changes this number proportionately.
     * Note: it is used for math calculation of available to claim tokens.
     */
    mapping(address => uint256) public claimed; // how much already claimed

    // Initial amount of eywa vested on this contract
    uint256 public vEywaInitialSupply;

    /**
     * The number of tokens in ``address``'s account as if there were no burning tokens
     * Note: it is used for math calculation of available to claim tokens
     */
    mapping(address => uint256) public unburnBalanceOf;

    /**
     * The number of tokens allowed for transfer/transferFrom 
     * from ``address``'s account to another ``address``'s account.
     * Note: It uses address(0) for permission for staking to staking contract
     * or to unstake from it.
     */
    mapping(address => mapping(address => uint256)) public transferPermission;

    /**
     * @dev Emitted when address`from` claimed amount `amount` tokens.
     */
    event ReleasedAfterClaim(address indexed from, uint256 indexed amount);


    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` of the token
     * and also sets eywa token's address.
     */
    constructor(IERC20 _eywaToken) ERC20("Vested Eywa", "vEYWA") {
        eywaToken = _eywaToken;
    }

    /**
     * @dev Initializes main parameters for vesting period 
     * @param _claimAllowanceContract - address of contract which gives permission to claim before claimWithAllowanceTimeStamp
     * @param _claimWithAllowanceTimeStamp - relative timestamp to claim without permission
     * @param _started - absolute timestamp of vesting period start 
     * @param _cliffs - data of three cliffs
     * @param _stepDuration - duration of one linear or discrete step
     * @param _allStepsDuration - duration of all linear or discrete steps
     * @param _permissionlessTimeStamp - relative timestamp to use transfer/transferFrom without permission
     * @param _initialAddresses - intitial token owners list
     * @param _initialSupplyAddresses - intitial token owners balances list
     *
     * Requirements:
     * - can be used only once
     * - _started should not be equal to 0
     * - _started should not be equal or bigger than current timestamp
     * - can be used only by owner
     *
     */
    function initialize(
        IVestingPolicy _claimAllowanceContract,
        uint256 _claimWithAllowanceTimeStamp,
        uint256 _started,
        cliffData memory _cliffs,
        uint256 _stepDuration,
        uint256 _allStepsDuration,
        uint256 _permissionlessTimeStamp,
        address[] calldata _initialAddresses,
        uint256[] calldata _initialSupplyAddresses
    ) external onlyOwner {
        require(started == 0, "Contract is already initialized");
        require(_started != 0, "_started can't be equal zero value");
        require(_started >= block.timestamp, "_started is less then current block.timestamp");

        claimWithAllowanceTimeStamp = _claimWithAllowanceTimeStamp;
        claimAllowanceContract = _claimAllowanceContract;
        started = _started;
        cliffs.cliffDuration1 = _cliffs.cliffDuration1;
        cliffs.cliffAmount1 = _cliffs.cliffAmount1;
        cliffs.cliffDuration2 = _cliffs.cliffDuration2;
        cliffs.cliffAmount2 = _cliffs.cliffAmount2;
        cliffs.cliffDuration3 = _cliffs.cliffDuration3;
        cliffs.cliffAmount3 = _cliffs.cliffAmount3;
        stepDuration = _stepDuration;
        permissionlessTimeStamp = _permissionlessTimeStamp;

        for (uint256 i = 0; i < _initialAddresses.length; i++) {
            _mint(_initialAddresses[i], _initialSupplyAddresses[i]);
            vEywaInitialSupply = vEywaInitialSupply + _initialSupplyAddresses[i];
            unburnBalanceOf[_initialAddresses[i]] = _initialSupplyAddresses[i];
        }
        numOfSteps = _allStepsDuration / _stepDuration;
        IERC20(eywaToken).safeTransferFrom(msg.sender, address(this), vEywaInitialSupply);
    }

    /**
     * @dev Change vesting policy contract
     * @param newContract - set new contract for vesting policy
     *
     * Requirements:
     * - can be used only by owner
     *
     */
    function renounceClaimAllowanceContract(IVestingPolicy newContract) external onlyOwner {
        claimAllowanceContract = newContract;
    }

    /**
     * @dev Returns permitted by vesting policy contract amount to claim 
     * @param tokenOwner - token owner
     *
     */
    function permittedAmountToClaim(address tokenOwner) public view returns (uint256) {
        return IVestingPolicy(claimAllowanceContract).permittedForClaim(tokenOwner);
    }

    /**
     * @dev Returns permitted amount to transfer 
     * @param from - sender address
     * @param to - recepient address
     *
     */
    function getCurrentTransferPermission(address from, address to) external view returns (uint256) {
        return transferPermission[from][to];
    }

    /**
     * @dev Increase permission to send tokens for this pair addresses
     * @param from - sender address
     * @param to - recepient address
     * @param amount - number of increase amount
     *
     * Requirements:
     * - can be used only by owner
     *
     */
    function increaseTransferPermission(
        address from,
        address to,
        uint256 amount
    ) external onlyOwner {
        transferPermission[from][to] = transferPermission[from][to] + amount;
    }

    /**
     * @dev Decrease permission to send tokens for this pair addresses
     * @param from - sender address
     * @param to - recepient address
     * @param amount - number of decrease amount
     *
     * Requirements:
     * - can be used only by owner
     *
     */
    function decreaseTransferPermission(
        address from,
        address to,
        uint256 amount
    ) external onlyOwner {
        transferPermission[from][to] = transferPermission[from][to] - amount;
    }

    /**
     * @dev Returns number of token available to claim for tokenOwner in the time.
     * @param time - timestamp
     * @param tokenOwner - address of token owner
     *
     */
    function available(uint256 time, address tokenOwner) public view returns (uint256) {
        if (claimable(time) >= vEywaInitialSupply) {
            return balanceOf(tokenOwner);
        }
        if (claimable(time) * unburnBalanceOf[tokenOwner] / vEywaInitialSupply >= claimed[tokenOwner]) {
            return (claimable(time) * unburnBalanceOf[tokenOwner] / vEywaInitialSupply) - claimed[tokenOwner];
        } else {
            return 0;
        }
    }

    /**
     * @dev Returns number of token available to claim after first cliff for address who owns
     * 'ownedTokens' tokens number.
     * @param ownedTokens - number of tokens
     *
     */
    function availableAfterFirstCliff(uint256 ownedTokens) public view returns (uint256) {
        if (ownedTokens == 0) {
            return 0;
        }
        return (claimable(started + cliffs.cliffDuration1) * ownedTokens / vEywaInitialSupply);
    }


    /**
     * @dev Updates claimed and unburnBalanceOf mappings for math calculation next available amount of tokens
     * after transfer/transferFrom functions
     * @param sender - sender address
     * @param recipient - recepient address
     * @param amount - number of transfer amount
     *
     */
    function updateUnburnBalanceAndClaimed(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        uint256 claimedNumberTransfer = claimed[sender] * amount / unburnBalanceOf[sender];
        uint256 remainderIncrease;
        if ((claimed[sender] * amount) % unburnBalanceOf[sender] > 0) {
            remainderIncrease = 1;
        }
        claimed[sender] = claimed[sender] - claimedNumberTransfer;
        claimed[recipient] = claimed[recipient] + claimedNumberTransfer + remainderIncrease;
        unburnBalanceOf[sender] = unburnBalanceOf[sender] - amount;
        unburnBalanceOf[recipient] = unburnBalanceOf[recipient] + amount;
    }

    /**
     * @dev Returns total amount is claimable for the time
     * @param time - timestamp
     *
     * Note: it doesn't include burn amount in calculation.
     *
     */
    function claimable(uint256 time) public view returns (uint256) {
        if (time == 0) {
            return 0;
        }
        uint256 cliffSum;
        if (time < started + cliffs.cliffDuration1) {
            return 0;
        } 
        if (time >= started + cliffs.cliffDuration1){
            cliffSum = cliffSum + cliffs.cliffAmount1;
            if (time >= started + cliffs.cliffDuration1 + cliffs.cliffDuration2){
                cliffSum = cliffSum + cliffs.cliffAmount2;
                if (time >= started + cliffs.cliffDuration1 + cliffs.cliffDuration2 + cliffs.cliffDuration3){
                    cliffSum = cliffSum + cliffs.cliffAmount3;
                    uint256 passedSinceCliff = time - (started + cliffs.cliffDuration1 + cliffs.cliffDuration2 + cliffs.cliffDuration3);
                    uint256 stepsPassed = Math.min(numOfSteps, passedSinceCliff / stepDuration);
                    if (stepsPassed >= numOfSteps) {
                        return vEywaInitialSupply;
                    }
                    return cliffSum + ((vEywaInitialSupply - cliffs.cliffAmount1 - cliffs.cliffAmount2 - cliffs.cliffAmount3) * stepsPassed / numOfSteps);
                }
            }
        }
        return cliffSum;
    }

    /**
     * @dev Claim to release certain amount of vested tokens
     * @param claimedAmount - number of tokens to release
     *
     * Requirements:
     * - claimedAmount should be less or equal to available amount
     * - if there is not claimWithAllowanceTimeStampm you should have permission for it
     *
     * Emits an {ReleasedAfterClaim} event.
     *
     */
    function claim(uint256 claimedAmount) external nonReentrant {
        uint256 availableAmount = available(block.timestamp, msg.sender);
        if (started + claimWithAllowanceTimeStamp > block.timestamp) {
            uint256 amountWithPermission = permittedAmountToClaim(msg.sender);
            require(amountWithPermission >= claimedAmount, "Don't have permission for this amount for early claim");
            bool isDecreased = IVestingPolicy(claimAllowanceContract).decreaseAnountToClaim(msg.sender, claimedAmount);
            require(isDecreased == true, "Can't spend permission for this claim");
        }
        require(claimedAmount > 0, "Claimed amount is 0");
        require(availableAmount >= claimedAmount, "the amount is not available");
        claimed[msg.sender] = claimed[msg.sender] + claimedAmount;
        _burn(msg.sender, claimedAmount);
        IERC20(eywaToken).safeTransfer(msg.sender, claimedAmount);
        emit ReleasedAfterClaim(msg.sender, claimedAmount);
    }

    function transfer(address recipient, uint256 amount) public override nonReentrant returns (bool) {
        require(started <= block.timestamp, "It is not started time yet");
        bool result;
        if (block.timestamp < started + permissionlessTimeStamp) {
            uint256 maxStakinPermission = Math.max(transferPermission[msg.sender][address(0)], transferPermission[address(0)][recipient]);
            uint256 permissionAmount = Math.max(transferPermission[msg.sender][recipient], maxStakinPermission);
            require(amount <= permissionAmount, "This early transfer doesn't have permission");
            if (transferPermission[msg.sender][recipient] > maxStakinPermission){
                transferPermission[msg.sender][recipient] = transferPermission[msg.sender][recipient] - amount;
            }
            updateUnburnBalanceAndClaimed(msg.sender, recipient, amount);
            result = super.transfer(recipient, amount);
            return result;
        } else {
            updateUnburnBalanceAndClaimed(msg.sender, recipient, amount);
            result = super.transfer(recipient, amount);
            return result;
        }
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override nonReentrant returns (bool) {
        require(started <= block.timestamp, "It is not started time yet");
        bool result;
        if (block.timestamp < started + permissionlessTimeStamp) {
            uint256 maxStakinPermission = Math.max(transferPermission[sender][address(0)], transferPermission[address(0)][recipient]);
            uint256 permissionAmount = Math.max(transferPermission[sender][recipient], maxStakinPermission);
            require(amount <= permissionAmount, "This early transfer doesn't have permission");
            if (transferPermission[sender][recipient] > maxStakinPermission){
                transferPermission[sender][recipient] = transferPermission[sender][recipient] - amount;
            }
            updateUnburnBalanceAndClaimed(sender, recipient, amount);
            result = super.transferFrom(sender, recipient, amount);
            return result;
        } else {
            updateUnburnBalanceAndClaimed(sender, recipient, amount);
            result = super.transferFrom(sender, recipient, amount);
            return result;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

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
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
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
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
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
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
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
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

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

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }
}

// SPDX-License-Identifier: MIT

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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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