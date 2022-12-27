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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

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
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LotteryEngineContract is Ownable {
    event LotteryHelded(string id);
    event LotteryCreated(string id);

    struct TokenInfo {
        string name;
        address contractAddress;
        IERC20 token;
        uint256 ticketPrice;
        uint256 total;
    }

    struct LotteryInfo {
        string id;
        uint8 winnerCount;
        uint8 commissionPercent;
        bool isWinnerWithdraw;
        bool isCommissionWithdraw;
        address[] participants;
        uint256[] tickets;
        address[] winners;
        TokenInfo[] supportedTokens;
    }

    mapping(string => LotteryInfo) public lotteries;

    function addLottery(
        string memory id,
        uint8 winnerCount,
        uint8 commissionPercent,
        string memory duplicateFromId
    ) external onlyOwner {
        require(bytes(id).length > 0, "Id is required.");
        require(winnerCount > 0, "winnerCount should be greater than zero");
        require(lotteries[id].winnerCount == 0, "Id already exist");

        lotteries[id].id = id;
        lotteries[id].winnerCount = winnerCount;
        lotteries[id].commissionPercent = commissionPercent;
        lotteries[id].isWinnerWithdraw = false;
        lotteries[id].isCommissionWithdraw = false;

        if (bytes(duplicateFromId).length > 0) {
            lotteries[id].supportedTokens = lotteries[duplicateFromId]
                .supportedTokens;
        }

        emit LotteryCreated(id);
    }

    /**
     * @dev Set ticket price per supported token
     * @param contractAddress address of token contract
     * @param ticketPrice amount of token to buy ticket
     */
    function setTicketPrice(
        string memory id,
        address contractAddress,
        uint256 ticketPrice
    ) external onlyOwner {
        requireLotteryExist(id);
        TokenInfo storage tokenInfo = lotteries[id].supportedTokens[
            getIndexOfToken(id, contractAddress)
        ];
        tokenInfo.ticketPrice = ticketPrice;
    }

    function requireLotteryExist(string memory id) internal view {
        require(bytes(id).length > 0, "Id is required");
        require(lotteries[id].winnerCount > 0, "Id not found");
    }

    /**
     * @dev Add supported token
     * @param symbol of token
     * @param contractAddress address of token contract
     * @param ticketPrice amount of token to buy ticket
     */
    function addToken(
        string memory id,
        string memory symbol,
        address contractAddress,
        uint256 ticketPrice
    ) external onlyOwner {
        requireLotteryExist(id);

        for (uint256 i = 0; i < lotteries[id].supportedTokens.length; i++) {
            if (
                lotteries[id].supportedTokens[i].contractAddress ==
                contractAddress
            ) {
                revert("This token contract address already exist.");
            }
        }

        TokenInfo memory tokenInfo = TokenInfo(
            symbol,
            contractAddress,
            IERC20(contractAddress),
            ticketPrice,
            0
        );
        lotteries[id].supportedTokens.push(tokenInfo);
    }

    /**
     * @dev Remove from supported token
     */
    function removeToken(
        string memory id,
        address contractAddress
    ) external onlyOwner {
        require(bytes(id).length > 0, "Id is required");
        uint256 tokenIndex = getIndexOfToken(id, contractAddress);
        require(
            lotteries[id].supportedTokens[tokenIndex].total == 0,
            "Can't remove this token."
        );
        delete lotteries[id].supportedTokens[tokenIndex];
    }

    /**
     * @dev Get commission percent
     * @return The commission percent.
     */
    function getCommissionPercent(
        string memory id
    ) external view returns (uint256) {
        return lotteries[id].commissionPercent;
    }

    /**
     * @dev Holding a lottery and determining the winners
     */
    function startLottery(string memory id) external onlyOwner {
        requireLotteryExist(id);
        require(lotteries[id].tickets.length > 0, "Tickets not filled.");
        require(
            lotteries[id].winners.length == 0,
            "The Lottery has been held."
        );

        uint256 ticketCounter = 0;
        uint256 totalTicket = 0;
        for (uint256 j = 0; j < lotteries[id].tickets.length; j++) {
            totalTicket += lotteries[id].tickets[j];
        }
        address[] memory tickets = new address[](totalTicket);

        for (uint256 i = 0; i < lotteries[id].participants.length; i++) {
            for (uint256 j = 0; j < lotteries[id].tickets[i]; j++) {
                tickets[ticketCounter] = lotteries[id].participants[i];
                ticketCounter++;
            }
        }

        address[] memory winners = pickWinners(
            tickets,
            lotteries[id].winnerCount
        );
        lotteries[id].winners = winners;

        for (uint256 i = 0; i < lotteries[id].supportedTokens.length; i++) {
            TokenInfo memory tokenInfo = lotteries[id].supportedTokens[i];
            if (tokenInfo.total > 0) {
                uint256 amount = tokenInfo.total;
                uint256 commissionAmount = ((amount *
                    lotteries[id].commissionPercent) / 100);
                amount = amount - commissionAmount;

                address winner = lotteries[id].winners[0];
                tokenInfo.token.approve(winner, amount);
            }
        }

        emit LotteryHelded(id);
    }

    /**
     * @dev Pick winners from array
     * @param tickets The address of the pa.
     * @param winnerCount The count of winners.
     * @return The addresses of winners.
     */
    function pickWinners(
        address[] memory tickets,
        uint256 winnerCount
    ) internal view returns (address[] memory) {
        shuffleArray(tickets);
        address[] memory winners = new address[](winnerCount);
        uint256 i = 0;
        uint256 j = 0;
        while (j < winnerCount) {
            address winner = tickets[i++];
            //ensure unique winner
            if (isItemExistInArray(winners, winner)) {
                continue;
            }
            winners[j++] = winner;
        }
        return winners;
    }

    function isItemExistInArray(
        address[] memory array,
        address item
    ) internal pure returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == item) {
                return true;
            }
        }
        return false;
    }

    function shuffleArray(
        address[] memory inArray
    ) internal view returns (address[] memory) {
        uint256 a = inArray.length;
        // uint b = inArray.length;
        for (uint256 i = 0; i < inArray.length; i++) {
            uint256 randNumber = (uint256(
                keccak256(abi.encodePacked(block.timestamp, inArray[i]))
            ) % a) + 1;
            address interim = inArray[randNumber - 1];
            inArray[randNumber - 1] = inArray[a - 1];
            inArray[a - 1] = interim;
            a = a - 1;
        }
        return inArray;
    }

    /**
     * @dev get winner address
     * @return array address of participants
     */
    function getWinners(
        string memory id
    ) external view returns (address[] memory) {
        return lotteries[id].winners;
    }

    /**
     * @dev get participants
     * @return array address of participants
     */
    function getParticipants(
        string memory id
    ) external view returns (address[] memory) {
        return lotteries[id].participants;
    }

    /**
     * @dev get participants
     * @return array address of participants
     */
    function getTotalParticipant(
        string memory id
    ) external view returns (uint256) {
        return lotteries[id].participants.length;
    }

    /**
     * @dev get total number of deposit
     * @param contractAddress contract address of token
     * @return Number of total token per contract
     */
    function getBalance(
        string memory id,
        address contractAddress
    ) external view returns (uint256) {
        TokenInfo memory tokenInfo = getTokenByContractAddress(
            id,
            contractAddress
        );
        return tokenInfo.total;
    }

    /**
     * @dev check if token contract address is supported
     * @param contractAddress contract address of token
     * @return boolean true if supported otherwise false
     */
    function getTokenByContractAddress(
        string memory id,
        address contractAddress
    ) internal view returns (TokenInfo memory) {
        return
            lotteries[id].supportedTokens[getIndexOfToken(id, contractAddress)];
    }

    /**
     * @dev return winner withdraw status
     * @param id contract address of token
     * @return boolean true if supported otherwise false
     */
    function isWinnerWithdraw(string memory id) external view returns (bool) {
        return lotteries[id].isWinnerWithdraw;
    }

    /**
     * @dev return commision withdraw status
     * @param id contract address of token
     * @return boolean true if supported otherwise false
     */
    function isCommissionWithdraw(
        string memory id
    ) external view onlyOwner returns (bool) {
        return lotteries[id].isCommissionWithdraw;
    }

    /**
     * @dev check if token contract address is supported
     * @param contractAddress contract address of token
     * @return boolean true if supported otherwise false
     */
    function getIndexOfToken(
        string memory id,
        address contractAddress
    ) internal view returns (uint256) {
        require(
            lotteries[id].supportedTokens.length > 0,
            "Lottery id not found."
        );

        for (uint256 i = 0; i < lotteries[id].supportedTokens.length; i++) {
            if (
                lotteries[id].supportedTokens[i].contractAddress ==
                contractAddress
            ) {
                return i;
            }
        }
        revert("Token does not supported.");
    }

    /**
     * @dev check if token contract address is supported
     * @param contractAddress contract address of token
     * @return boolean true if supported otherwise false
     */
    function isTokenSupported(
        string memory id,
        address contractAddress
    ) internal view returns (bool) {
        requireLotteryExist(id);

        for (uint256 i = 0; i < lotteries[id].supportedTokens.length; i++) {
            if (
                lotteries[id].supportedTokens[i].contractAddress ==
                contractAddress
            ) {
                return true;
            }
        }
        return false;
    }

    function getTicketPrice(
        string memory id,
        address contractAddress
    ) external view returns (uint256) {
        requireLotteryExist(id);

        TokenInfo memory tokenInfo = getTokenByContractAddress(
            id,
            contractAddress
        );
        uint256 amount = 1 * tokenInfo.ticketPrice;

        return amount;
    }

    /**
     * @dev buy ticket
     * @param ticketCount total chance to buy
     * @param contractAddress token contract address
     */
    function buyTicket(
        string memory id,
        uint256 ticketCount,
        address contractAddress
    ) external {
        requireLotteryExist(id);
        require(lotteries[id].winners.length == 0, "The Lottery has been held");
        require(ticketCount > 0, "Ticket count should greater than zero");

        TokenInfo storage tokenInfo = lotteries[id].supportedTokens[
            getIndexOfToken(id, contractAddress)
        ];
        require(tokenInfo.ticketPrice > 0, "Token is disabled by owner.");

        uint256 amount = ticketCount * tokenInfo.ticketPrice;
        require(
            amount <= tokenInfo.token.balanceOf(msg.sender),
            "Not enough tokens in your wallet, please try lesser amount"
        );
        tokenInfo.token.transferFrom(msg.sender, address(this), amount);

        tokenInfo.total += amount;

        lotteries[id].participants.push(msg.sender);
        lotteries[id].tickets.push(ticketCount);
    }

    /**
     * @dev Withdraw all token by winner
     */
    function winnerWithdraw(string memory id) external {
        requireLotteryExist(id);

        require(
            lotteries[id].winners.length > 0,
            "The lottery has not been held."
        );
        require(
            !lotteries[id].isWinnerWithdraw,
            "The winner has already withdrawn."
        );

        address winner = lotteries[id].winners[0];
        require(winner == msg.sender, "Only winner can withdraw.");

        for (uint256 i = 0; i < lotteries[id].supportedTokens.length; i++) {
            if (lotteries[id].supportedTokens[i].total > 0) {
                uint256 amount = lotteries[id].supportedTokens[i].total;
                amount =
                    amount -
                    ((amount * lotteries[id].commissionPercent) / 100);
                lotteries[id].supportedTokens[i].token.transfer(winner, amount);
            }
        }
        lotteries[id].isWinnerWithdraw = true;
    }

    /**
     * @dev Withdraw all token by winner
     * @param wallet address to transfer
     */
    function withdrawCommission(
        string memory id,
        address wallet
    ) external onlyOwner {
        requireLotteryExist(id);
        require(wallet != address(0), "transfer to the zero address");
        require(
            lotteries[id].winners.length > 0,
            "The lottery has not been held."
        );
        require(
            !lotteries[id].isCommissionWithdraw,
            "Admin has already withdrawn commission."
        );

        for (uint256 i = 0; i < lotteries[id].supportedTokens.length; i++) {
            if (lotteries[id].supportedTokens[i].total > 0) {
                uint256 amount = lotteries[id].supportedTokens[i].total;
                amount = ((amount * lotteries[id].commissionPercent) / 100);
                lotteries[id].supportedTokens[i].token.transfer(wallet, amount);
            }
        }
        lotteries[id].isCommissionWithdraw = true;
    }
}