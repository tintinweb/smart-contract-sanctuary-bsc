// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../interfaces/IBetSlips.sol";
import "../games/BaseGame.sol";

contract MinesGame is BaseGame {

    struct MinesPlayerChoice {
        uint8 amountOfBombs;
        uint8[] revealedCells;
    }

    uint8 public constant AMOUNT_OF_CELLS = 25;

    mapping(string => MinesPlayerChoice) _playerChoices;

    constructor(address betSlipsAddr, uint256 rtp) {
        _betSlipsAddr = payable(betSlipsAddr);
        _rtp = rtp;
        gameCode = "mines";
    }

    function getOdds(uint8 amountOfBombs, uint256 selectedCounts)
        private
        view
        returns (uint256)
    {
        uint256 proDenominator = 1;
        uint256 proNumerator = 1;
        uint256 denominator = AMOUNT_OF_CELLS;
        uint256 numerator = AMOUNT_OF_CELLS - amountOfBombs;

        for(uint8 i = 0; i < selectedCounts; i++) {
            proNumerator *= numerator;
            proDenominator *= denominator;
            numerator--;
            denominator--;
        }

        uint256 odds = _rtp * proDenominator / proNumerator;
        
        return odds;
    }

    function revealSeed(
        string memory seedHash, 
        string memory seed, 
        uint8[] memory revealedCells
    ) public {
        require(SeedUtility.compareSeed(seedHash, seed) == true, "Invalid seed");
        require((revealedCells.length > 0 && revealedCells.length < 24), "Invalid selected cells");

        string memory bombPositionString;

        IBetSlips.BetSlip memory betSlip = IBetSlips(_betSlipsAddr).getBetSlip(
            seedHash
        );

        _playerChoices[seedHash].revealedCells = revealedCells;

        for(uint8 i = 0; i < revealedCells.length; i++)
        {
            if (i == 0)
                betSlip.playerGameChoice = string(abi.encodePacked("[", SeedUtility.uintToStr(revealedCells[i])));
            else
                betSlip.playerGameChoice = string(abi.encodePacked(betSlip.playerGameChoice, ", ", SeedUtility.uintToStr(revealedCells[i])));
        }
        betSlip.playerGameChoice = string(abi.encodePacked(betSlip.playerGameChoice , "]"));

        betSlip.odds = getOdds(_playerChoices[seedHash].amountOfBombs, revealedCells.length);
        
        uint8[] memory bombPositions = generateBombPositions(_playerChoices[seedHash].amountOfBombs, seed);

        uint256 returnAmount = getReturnAmount(
            seedHash,
            betSlip.wagerAmount,
            betSlip.odds,
            bombPositions
        );

        for(uint8 i = 0; i < bombPositions.length; i++) {
            if (i == 0)
                bombPositionString = string(abi.encodePacked("[ ", SeedUtility.uintToStr(bombPositions[i])));
            else
                bombPositionString = string(abi.encodePacked(bombPositionString, ", ", SeedUtility.uintToStr(bombPositions[i])));
        }
        bombPositionString = string(abi.encodePacked(bombPositionString, " ]"));

        IBetSlips(_betSlipsAddr).completeBet(
            seedHash,
            seed,
            betSlip.playerGameChoice,
            bombPositionString,
            returnAmount,
            betSlip.odds
        );
    }

    function placeBet(
        uint256 wagerAmount,
        uint8 amountOfBombs,
        string memory seedHash,
        address token
    ) public whenNotPaused{
        placeBetSlip(wagerAmount, amountOfBombs, seedHash, token, 0, 0, 0, 0);
    }

    function placeBetWithPermit(
        uint256 wagerAmount,
        uint8 amountOfBombs,
        string memory seedHash,
        address token,
        uint256 deadLine,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public whenNotPaused{
        placeBetSlip(wagerAmount, amountOfBombs, seedHash, token, deadLine, v, r, s);
    }

    function placeBetSlip(
        uint256 wagerAmount,
        uint8 amountOfBombs,
        string memory seedHash,
        address token,
        uint256 deadLine,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private {

        uint256 minAmount = _betLimits[token].minAmount;
        uint256 maxAmount = _betLimits[token].maxAmount;

        require(
            wagerAmount >= minAmount && wagerAmount <= maxAmount,
            "The WagerAmount is invalid"
        );

        require(
            amountOfBombs > 0 && amountOfBombs <= 24,
            "The BombsAmount is invalid"
        );

        string memory playerGameChoice;
        if (amountOfBombs == 1) {
           playerGameChoice = "1 bomb";
        } else {
           playerGameChoice = string(abi.encodePacked(SeedUtility.uintToStr(amountOfBombs), " bombs"));
        }

        _playerChoices[seedHash].amountOfBombs = amountOfBombs;

        IBetSlips(_betSlipsAddr).placeBetSlip(
            msg.sender,
            token,
            wagerAmount,
            gameCode,
            playerGameChoice,
            seedHash,
            0,
            deadLine,
            v,
            r,
            s
        );
    }

    function getReturnAmount(
        string memory seedHash,
        uint256 wagerAmount,
        uint256 odds,
        uint8[] memory bombPositions
    ) private view returns (uint256) {
        MinesPlayerChoice memory playerChoice = _playerChoices[seedHash];

        uint256 returnAmount;
        bool winFlag = true;

        for (uint8 i = 0; i < bombPositions.length; i++) {
            for (uint8 j = 0; j < playerChoice.revealedCells.length; j++) {
                if (bombPositions[i] == playerChoice.revealedCells[j]) {
                    winFlag = false;
                    break;
                }
            }
            if (!winFlag)
                break;
        }

        if (winFlag) {
            returnAmount = (wagerAmount * odds) / 100;
        }
        else { 
            returnAmount = 0;
        }

        return returnAmount;
    }

    function generateBombPositions(uint8 amountOfBombs, string memory seed)
        private
        pure 
        returns (uint8[] memory) 
    {
        uint8[] memory bombSeries = new uint8[](amountOfBombs);
        bool[] memory seeds = new bool[](AMOUNT_OF_CELLS+1);
        string memory currentSeed = seed;
        uint8 count = 0;

        for (uint8 i = 0; i < AMOUNT_OF_CELLS - 1; i++)
            seeds[i] = false;

        while (count < amountOfBombs) {
            uint256 curRndNumber = SeedUtility.getHashNumberUsingAsciiNumber(currentSeed);
            uint256 index = curRndNumber % AMOUNT_OF_CELLS + 1;
            if (!seeds[index]) {
                seeds[index] = true;
                count++;
            }
            currentSeed = SeedUtility.bytes32ToString(sha256(abi.encodePacked(currentSeed)));
        }

        count = 0;

        for (uint8 i = 0; i < AMOUNT_OF_CELLS + 1 ; i++)
            if (seeds[i]){
                bombSeries[count] = i;
                count++;
            }

        return bombSeries;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IBetSlips {
    enum Status {
        PLACED,
        COMPLETED,
        REVOKED
    }

    struct BetSlip {
        uint256 betId;
        address player;
        address token;
        string gameCode;
        string playerGameChoice;
        string gameResult;
        uint256 wagerAmount;
        uint256 returnAmount;
        uint256 odds;
        string seedHash;
        string seed;
        Status status;
        uint256 placedAt;
        uint256 completedAt;
    }

    event betSlipPlaced(
        uint256 betId,
        address player,
        address tokenAddress,
        string gameCode,
        string playerGameChoice,
        uint256 wagerAmount,
        string seedHash,
        uint256 odds,
        Status status
    );

    event betSlipCompleted(
        uint256 betId,
        address player,
        address tokenAddress,
        string gameCode,
        string playerGameChoice,
        uint256 wagerAmount,
        string seedHash,
        string gameResult,
        uint256 returnAmount,
        string seed,
        uint256 odds,
        Status status
    );

    event betSlipRevoked(
        string seedHashes,
        string reason
    );

    function getBetSlip(string memory seedHash)
        external
        returns (BetSlip memory);

    function placeBetSlip(
        address player,
        address token,
        uint256 wagerAmount,
        string memory gameCode,
        string memory playerGameChoice,
        string memory seedHash,
        uint256 odds,
        uint256 deadLine,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function completeBet(
        string memory seedHash,
        string memory seed,
        string memory playerGameChoice,
        string memory gameResult,
        uint256 returnAmount,
        uint256 odds
    ) external;

    function revokeBetSlips(
        string [] memory seedHashes,
        string memory reason
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../libraries/SeedUtility.sol";

contract BaseGame is Ownable, Pausable {
  struct BetLimit {
        uint256 minAmount;
        uint256 maxAmount;
        uint256 defaultAmount;
    }

    mapping(address => BetLimit) _betLimits;

    address payable internal _betSlipsAddr;
    uint256 internal _rtp;
    string gameCode;

    event betLimitChangedEvent(
        string gameCode,
        string tokenSymbol,
        address tokenAddress,
        uint256 minAmount,
        uint256 maxAmount,
        uint256 defaultAmount
    );

    event rtpChangedEvent(
        string gameCode,
        uint256 rtp
    );

    event gameStateChangedEvent(
        string gameCode,
        bool enabled
    );

    function setRtp(uint256 rtp) public onlyOwner {
        _rtp = rtp;
        emit rtpChangedEvent(gameCode, _rtp);
    }

    function getRtp() public view returns (uint256) {
        return _rtp;
    }

    function setBetSlipsAddress(address betSlipsAddr) public onlyOwner {
        _betSlipsAddr = payable(betSlipsAddr);
    }

    function getBetSlipsAddress() public view returns (address) {
        return _betSlipsAddr;
    }

    function setBetLimit(
        address tokenAddress,
        uint256 minAmount,
        uint256 maxAmount,
        uint256 defaultAmount
    ) public onlyOwner {
        BetLimit memory betLimit = BetLimit(minAmount, maxAmount, defaultAmount);
        _betLimits[tokenAddress] = betLimit;
        string memory tokenSymbol = ERC20(tokenAddress).symbol();

        emit betLimitChangedEvent(gameCode, tokenSymbol, tokenAddress, minAmount, maxAmount, defaultAmount);
    }

    function getGameConfig(address token) public view returns (string memory) {
        string memory rtp = string(
            abi.encodePacked('{"rtp":', SeedUtility.uintToStr(_rtp), ",")
        );

        string memory betLimitsStr = string(abi.encodePacked('"betLimits": {'));

        BetLimit memory betLimit = _betLimits[token];

        string memory tokenStr = string(
            abi.encodePacked('"', SeedUtility.addressToStr(token), '": {')
        );

        string memory minStr = string(
            abi.encodePacked(
                '"minAmount": ',
                SeedUtility.uintToStr(betLimit.minAmount),
                ","
            )
        );

        string memory maxStr = string(
            abi.encodePacked(
                '"maxAmount": ',
                SeedUtility.uintToStr(betLimit.maxAmount),
                ","
            )
        );

        string memory defaultStr = string(
            abi.encodePacked(
                '"defaultAmount": ',
                SeedUtility.uintToStr(betLimit.defaultAmount),
                "}"
            )
        );

        betLimitsStr = string(
            abi.encodePacked(
                betLimitsStr,
                tokenStr,
                minStr,
                maxStr,
                defaultStr
            )
        );

        return string(abi.encodePacked(rtp, betLimitsStr, "}}"));
    }

    function pauseGame() public onlyOwner whenNotPaused {
        _pause();
        emit gameStateChangedEvent(gameCode, false);
    }

    function unpauseGame() public onlyOwner whenPaused {
       _unpause();
       emit gameStateChangedEvent(gameCode, true);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

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
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
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
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

library SeedUtility {
    //Fraction is literally the number expressed as a quotient, in which the numerator is divided by the denominator. 
    //Because solidity doesn't support decimal data, fraction is needed for dealing with deciaml data operation.
    //Thus, decimal data is converted into fraction data.
    struct Fraction {
        uint256 numerator;
        uint256 denominator;
    }

    function bytes32ToString(bytes32 _bytes32)
        public
        pure
        returns (string memory)
    {
        bytes memory s = new bytes(64);

        for (uint8 i = 0; i < 32; i++) {
            bytes1 b = bytes1(_bytes32[i]);
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));

            if (hi < 0x0A) {
                s[i * 2] = bytes1(uint8(hi) + 0x30);
            } else {
                s[i * 2] = bytes1(uint8(hi) + 0x57);
            }

            if (lo < 0x0A) {
                s[i * 2 + 1] = bytes1(uint8(lo) + 0x30);
            } else {
                s[i * 2 + 1] = bytes1(uint8(lo) + 0x57);
            }
        }

        return string(s);
    }

    function strToUint(string memory _str) public pure returns (uint256 res) {
        uint64 val = 0;
        uint8 a = uint8(97); // a
        uint8 zero = uint8(48); //0
        uint8 nine = uint8(57); //9
        uint8 A = uint8(65); //A
        uint8 F = uint8(70); //F
        uint8 f = uint8(102); //f

        for (uint256 i = 0; i < bytes(_str).length; i++) {
            uint8 byt = uint8(bytes(_str)[i]);
            if (byt >= zero && byt <= nine) byt = byt - zero;
            else if (byt >= a && byt <= f) byt = byt - a + 10;
            else if (byt >= A && byt <= F) byt = byt - A + 10;
            val = (val << 4) | (byt & 0xF);
        }

        return val;
    }

    function uintToStr(uint256 _i)
        public
        pure
        returns (string memory _uintAsString)
    {
        uint256 number = _i;
        if (number == 0) {
            return "0";
        }
        uint256 j = number;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }

        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (number >= 10) {
            bstr[k--] = bytes1(uint8(48 + (number % 10)));
            number /= 10;
        }
        bstr[k] = bytes1(uint8(48 + (number % 10)));
        return string(bstr);
    }

    function addressToStr(address _address)
        public
        pure
        returns (string memory)
    {
        bytes32 _bytes = bytes32((uint256(uint160(_address))));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _string = new bytes(42);

        _string[0] = "0";
        _string[1] = "x";

        for (uint256 i = 0; i < 20; i++) {
            _string[2 + i * 2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _string[3 + i * 2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }

        return string(_string);
    }

    function compareSeed(string memory seedHash, string memory seed)
        public
        pure
        returns (bool)
    {
        string memory hash = bytes32ToString(sha256(abi.encodePacked(seed)));

        if (
            keccak256(abi.encodePacked(hash)) ==
            keccak256(abi.encodePacked(seedHash))
        ) {
            return true;
        } else {
            return false;
        }
    }

    function getHashNumberUsingAsciiNumber(string memory asciiNumbers)
        public
        pure
        returns (uint256)
    {
        bytes memory b = bytes(asciiNumbers);
        uint256 sum = 0;

        for (uint256 i = 0; i < b.length; i++) {
            bytes1 char = b[i];

            sum += uint256(uint8(char));
        }

        return sum;
    }

    function abs(int256 x) 
        public 
        pure 
        returns (int256) 
    {
       return x >= 0 ? x : -x;
    }

    function getHashNumber(string memory seed)
        public
        pure
        returns (uint256)
    {
        int256 p = 31;
        int256 m = 10 ** 9 + 9;
        int256 powerOfP = 1;
        int256 hashVal = 0;
        bytes memory b = bytes(seed);
        bytes1 ascciNumberOfA = 'a';

        for (uint256 i = 0; i < b.length; i++) {
            bytes1 char = b[i];
            hashVal = (hashVal + int256(int8(uint8(char)) - int8(uint8(ascciNumberOfA)) + 1) * powerOfP) % m;
            powerOfP = (powerOfP * p) % m;
        }

        return uint256(abs(hashVal));
    }

    function getResultByProbabilities(string memory seed, uint256[] memory probabilities, uint256 amountOfDigits)
        public
        pure
        returns (uint256 index)
    {
        uint256 totalProbabilities = 0;
        uint256 amountOfResultItems = probabilities.length;

        // The value generated by getHashNumber is one that has 9 digits integer.
        // hitNumber is integer that amount of digits of aboved integer from the lowest digit.
        uint256 hitNumber = getHashNumber(seed) % (10**amountOfDigits);

        for(index = 0; index < amountOfResultItems; index++)
        {
            totalProbabilities += probabilities[index];
            
            if (totalProbabilities > hitNumber)
            {
                return index;
            }
        }
    }

    function getResultByFractionProbabilities(string memory seed, Fraction[] memory probabilities, uint256 amountOfDigits)
        public
        pure
        returns (uint256 index)
    {
        uint256 amountOfResultItems = probabilities.length;

        Fraction memory totalProbabilities;
        totalProbabilities.numerator = 0;
        totalProbabilities.denominator = 1;

        // The value generated by getHashNumber is one that has 9 digits integer.
        // hitNumber is integer that has amount of digits(amountOfDigits) from the lowest digit.
        uint256 hitNumber = getHashNumber(seed) % (10**amountOfDigits);

        for(index = 0; index < amountOfResultItems; index++)
        {
            totalProbabilities = fractionAddFraction(totalProbabilities, probabilities[index]);
            
            if ((totalProbabilities.numerator / totalProbabilities.denominator) > hitNumber)
            {
                return index;
            }
        }
    }

    function fractionMultInteger(Fraction memory fraction, uint256 integer)
        public
        pure
        returns (Fraction memory result)
    {
        result.numerator = fraction.numerator * integer;
        result.denominator = fraction.denominator;
    }

    function fractionDivInteger(Fraction memory fraction, uint256 integer)
        public
        pure
        returns (Fraction memory result)
    {
        result.numerator = fraction.numerator;
        result.denominator = fraction.denominator * integer;
    }

    function fractionAddFraction(Fraction memory fraction1, Fraction memory fraction2)
        public
        pure
        returns (Fraction memory result)
    {
        result.numerator = fraction1.numerator*fraction2.denominator + fraction2.numerator*fraction1.denominator;
        result.denominator = fraction1.denominator * fraction2.denominator;
    }

    function fractionDivFraction(Fraction memory fraction1, Fraction memory fraction2)
        public
        pure
        returns (Fraction memory result)
    {
        result.numerator = fraction1.numerator*fraction2.denominator;
        result.denominator = fraction1.denominator * fraction2.numerator;
    }

    function toJsonStrArray(string [] memory arr)
        public 
        pure
        returns (string memory)
    {
        string memory jsonStrArray;
        for (uint8 i = 0; i < arr.length; i++) {
            if (i == 0)
                jsonStrArray = string(abi.encodePacked('["', arr[i], '"'));
            else
                jsonStrArray = string(abi.encodePacked(jsonStrArray, ', "', arr[i], '"'));
        }
        jsonStrArray = string(abi.encodePacked(jsonStrArray, ']'));

        return jsonStrArray;
    }

    function toStrArray(string [] memory arr)
        public 
        pure
        returns (string memory)
    {
        string memory strArray;
        for (uint8 i = 0; i < arr.length; i++) {
            if (i == 0)
                strArray = string(abi.encodePacked("[", arr[i]));
            else
                strArray = string(abi.encodePacked(strArray, ", ", arr[i]));
        }
        strArray = string(abi.encodePacked(strArray, "]"));

        return strArray;
    }

    function substring(string memory str, uint startIndex, uint endIndex) 
        public 
        pure 
        returns (string memory ) 
    {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex-startIndex);
        for(uint i = startIndex; i < endIndex; i++) {
            result[i-startIndex] = strBytes[i];
        }
        return string(result);
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