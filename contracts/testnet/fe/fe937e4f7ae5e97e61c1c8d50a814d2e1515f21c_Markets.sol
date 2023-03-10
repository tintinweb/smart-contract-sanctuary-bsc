/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

// Sources flattened with hardhat v2.12.6 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/[email protected]

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    event Approval(address indexed owner, address indexed spender, uint256 value);

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


// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

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


// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/token/ERC20/[email protected]

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;



/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
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
    function balanceOf(address account) public view virtual override returns (uint256) {
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
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
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
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
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
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

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
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
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
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
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


// File contracts/Markets.sol

pragma solidity ^0.8.0;


contract Markets {
    struct Market {
        address generator;
        address tokenId;
        address depositTokenId;
        address validityReporter;
        address resolver;
        address disputer;

        uint validityDeposit;
        uint resolutionDeposit;

        uint32 resolutionTime;
        uint32 answerSubmittedTime;
        uint32 disputedTime;
        uint32 resolvedTime;
        uint8 lenOptions; // (answer == lenOptions) => invalid
        uint8 submittedAnswer;
        uint8 finalAnswer;

        bool validityDepositClaimed;
        bool resolutionDepositClaimed;
        bool serviceCommissionClaimed;
        bool generationCommissionClaimed;

        mapping (uint8 => mapping(address => uint)) bets;
        mapping (uint8 => uint) bets_total;
    }
    address private admin;
    mapping (uint => Market) markets;

    constructor() {
        admin = msg.sender;
    }

    function initialize(uint id, address _tokenId, address _depositTokenId, uint32 _resolutionTime, uint8 _lenOptions) external {
        require(markets[id].generator == address(0), "The ID already exists!");
        Market storage market = markets[id];
        market.generator = msg.sender;
        market.tokenId = _tokenId;
        market.depositTokenId = _depositTokenId;
        market.resolutionTime = _resolutionTime;
        market.lenOptions = _lenOptions;

        uint8 decimal = ERC20(market.depositTokenId).decimals();
        uint zeros = 10 ** decimal;
        bool success = IERC20(market.depositTokenId).transferFrom(msg.sender, address(this), 10 * zeros);
        require(success, "Failed to deposit tokens");
        market.validityDeposit = 5 * zeros;
        market.resolutionDeposit = 5 * zeros;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    modifier onlyGenerator(uint id) {
        require(msg.sender == markets[id].generator, "Only market generator can call this function");
        _;
    }

    modifier noGenerator(uint id) {
        require(msg.sender != markets[id].generator, "Market generator can not call this function");
        _;
    }

    modifier verifyOption(uint id, uint8 _option) {
        require(_option < markets[id].lenOptions, "your option is out of range");
        _;
    }

    modifier verifyAnswer(uint id, uint8 _answer) {
        require(_answer <= markets[id].lenOptions, "your answer is out of option range");
        _;
    }

    function predict(uint id, uint8 option, uint amount) external verifyOption(id, option) {
        Market storage market = markets[id];
        require(block.timestamp < market.resolutionTime - 1 hours, "Market participation ended");
        require( // Need to be approved before user's using Predicto
            amount <= IERC20(market.tokenId).allowance(msg.sender, address(this)),
            "Allowed tokens are not enough"
        );
        bool success = IERC20(market.tokenId).transferFrom(msg.sender, address(this), amount);
        require(success, "Failed to temporarily transfer tokens from user to this contract while processing logic");
        market.bets[option][msg.sender] += amount; // TODO : check if okay when bets[option][msg.sender] == 0
        market.bets_total[option] += amount;
    }

    function predictedAmount(uint id, address addr, uint8 option) external view returns (uint) {
        return markets[id].bets[option][addr];
    }

    function predictedTotalAmount(uint id, uint8 option) external view returns (uint) {
        return markets[id].bets_total[option];
    }

    function totalAmount(uint id) external view returns (uint) {
        Market storage market = markets[id];
        uint sum = 0;
        for (uint8 i = 0; i < market.lenOptions; ++i) {
            sum += market.bets_total[i];
        }
        return sum;
    }

    function reportValidity(uint id) external noGenerator(id) {
        Market storage market = markets[id];
        require(block.timestamp < market.resolutionTime, "Invalidity report is able before resolutionTime");
        bool success = IERC20(market.depositTokenId).transferFrom(msg.sender, address(this), market.validityDeposit);
        require(success, "Failed to deposit tokens");
        market.validityDeposit *= 2;
        market.validityReporter = msg.sender;
    }

    function isReported(uint id) external view returns (bool) {
        return markets[id].validityReporter != address(0);
    }

    function submitAnswer(uint id, uint8 answer) external verifyAnswer(id, answer) {
        Market storage market = markets[id];
        require(market.resolutionTime < block.timestamp, "Submit an answer after the market ends");
        if (block.timestamp < market.resolutionTime + 1 days) {
            require(msg.sender == market.generator, "Only market generator can submit an answer for 1 day after resolutionTime");
        }
        market.submittedAnswer = answer;
        market.resolver = msg.sender;
        market.answerSubmittedTime = uint32(block.timestamp);
    }

    function dispute(uint id) external noGenerator(id) {
        Market storage market = markets[id];
        require(market.resolver != address(0), "An answer is not submitted yet");
        require(market.disputer == address(0), "The market is already disputed");
        require(block.timestamp < market.answerSubmittedTime + 2 days, "disputable time is within 2 days after the answer submission");
        require(msg.sender != market.resolver, "The person who submitted the answer can't dispute");
        bool success = IERC20(market.depositTokenId).transferFrom(msg.sender, address(this), market.resolutionDeposit);
        require(success, "Failed to deposit tokens");
        market.resolutionDeposit *= 2;
        market.disputedTime = uint32(block.timestamp);
        market.disputer = msg.sender;
    }

    function revoke(uint id) external onlyAdmin {
        Market storage market = markets[id];
        market.resolvedTime = uint32(block.timestamp);
        market.finalAnswer = market.lenOptions;
    }

    function resolve(uint id, uint8 answer) external onlyAdmin verifyAnswer(id, answer) {
        Market storage market = markets[id];
        require(market.disputer != address(0), "Cannot resolve without any dispute");
        market.finalAnswer = answer;
        market.resolvedTime = uint32(block.timestamp);
    }

    function _getAnswerWithAssertingMarketFinalization(uint id) internal view returns (uint8) {
        Market storage market = markets[id];
        if (market.resolvedTime != 0) {
            return market.finalAnswer;
        } else if ((market.resolver != address(0)) && (market.answerSubmittedTime + 2 days < block.timestamp) && (market.disputer == address(0))) {
            return market.submittedAnswer;
        }
        revert("The market is not finalized");
    }

    function claim(uint id) external {
        Market storage market = markets[id];
        uint8 answer = _getAnswerWithAssertingMarketFinalization(id);
        uint claimAmount = 0;
        if (answer == market.lenOptions) { // invalid
            for (uint8 option = 0; option < market.lenOptions; ++option) {
                claimAmount += market.bets[option][msg.sender];
                market.bets[option][msg.sender] = 0;
            }
        } else {
            claimAmount = market.bets[answer][msg.sender];
            uint sumOtherOptions = 0;
            for (uint8 option = 0; option < market.lenOptions; ++option) {
                if (option == answer) continue;
                sumOtherOptions += market.bets_total[option];
            }
            claimAmount += sumOtherOptions * market.bets[answer][msg.sender] * 97 / market.bets_total[answer] / 100;
            market.bets[answer][msg.sender] = 0;
        }
        IERC20(market.tokenId).transfer(msg.sender, claimAmount);
    }

    function claimResolutionDeposit(uint id) external {
        Market storage market = markets[id];
        _getAnswerWithAssertingMarketFinalization(id);
        require(!market.resolutionDepositClaimed, "Resolution deposit was already claimed");
        address receiver;
        if (market.disputer == address(0) || market.submittedAnswer == market.finalAnswer) {
            receiver = market.resolver;
        } else if (market.disputer != address(0)) {
            receiver = market.disputer;
        } else {
            receiver = admin;
        }
        bool success = IERC20(market.depositTokenId).transfer(receiver, market.resolutionDeposit);
        require(success, "Failed to claim resolution deposit");
        market.resolutionDepositClaimed = true;
    }

    function claimValidityDeposit(uint id) external {
        Market storage market = markets[id];
        uint8 answer = _getAnswerWithAssertingMarketFinalization(id);
        require(!market.validityDepositClaimed, "Validity deposit was already claimed");
        address receiver;
        if (answer == market.lenOptions) {
            receiver = market.validityReporter != address(0) ? market.validityReporter : admin;
        } else {
            receiver = market.generator;
        }
        bool success = IERC20(market.depositTokenId).transfer(receiver, market.validityDeposit);
        require(success, "Failed to claim validity deposit");
        market.validityDepositClaimed = true;
    }

    function claimServiceCommission(uint id) external onlyAdmin {
        Market storage market = markets[id];
        require(!market.serviceCommissionClaimed, "Already claimed");
        uint8 answer = _getAnswerWithAssertingMarketFinalization(id);
        require(answer != market.lenOptions, "The market ended with invalidity");
        uint commissionPermille = (
            market.resolver == market.generator
            && (market.disputer == address(0) || market.submittedAnswer == market.finalAnswer)
        ) ? 25: 30;
        uint sumOtherOptions = 0;
        for (uint8 option = 0; option < market.lenOptions; ++option) {
            if (option == answer) continue;
            sumOtherOptions += market.bets_total[option];
        }
        uint commissionAmount = sumOtherOptions * commissionPermille / 1000;
        bool success = IERC20(market.tokenId).transfer(admin, commissionAmount);
        require(success, "Failed to claim service commission");
        market.serviceCommissionClaimed = true;
    }

    function claimMarketGenerationCommission(uint id) external onlyGenerator(id) {
        Market storage market = markets[id];
        require(!market.generationCommissionClaimed, "Already claimed");
        uint8 answer = _getAnswerWithAssertingMarketFinalization(id);
        require(answer != market.lenOptions, "The market ended with invalidity");
        require(market.resolver == market.generator, "Generator didn't submit the answer");
        require(market.disputer == address(0) || market.submittedAnswer == market.finalAnswer, "The submitted answer was not correct");
        uint sumOtherOptions = 0;
        for (uint8 option = 0; option < market.lenOptions; ++option) {
            if (option == answer) continue;
            sumOtherOptions += market.bets_total[option];
        }
        uint commissionAmount = sumOtherOptions * 5 / 1000;
        bool success = IERC20(market.tokenId).transfer(market.generator, commissionAmount);
        require(success, "Failed to claim market generation commission");
        market.generationCommissionClaimed = true;
    }
}