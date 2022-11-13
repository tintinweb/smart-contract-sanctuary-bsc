// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface iIncentiveFactory {
    function saleMasterAddress() external returns(address);
}

interface iSaleMaster {
    function adminAddress() external returns(address);
}

contract Incentive is ReentrancyGuard {
    using Strings for uint256;

    iIncentiveFactory immutable _incentiveFactory;
    iSaleMaster internal _saleMaster;

    struct IncentiveDetails {
        uint256 min_entry;
        uint256 mult_ballots;
        uint256 incentive_type;
        uint256 incentive_rate;
        uint256 incentive_amount;
        uint256 incentive_date;
        uint256 incentive_winner;
    }

    struct EntrantDetails {
        uint256 amount_entered;
        uint256 ballots;
    }

    mapping(uint256 => IncentiveDetails) internal _incentiveDetails;
    mapping(uint256 => mapping(address => EntrantDetails)) internal _entrantDetails;

    mapping(uint256 => uint256) internal ballotNumber;
    mapping(uint256 => mapping(uint256 => address)) internal ballotList;

    mapping(uint256 => uint256) public prizeAmount;

    address immutable token;
    address public owner;
    address immutable incentiveFactoryAddress;
    address public saleMasterAddress;
    address public saleContract;
    address internal adminAddress;

    event IncentiveCreated(address _Owner, address _Incentive);
    event OwnerChanged(address _Previous_Owner, address _Owner);
    event SaleContractSet(address _Setter, address _Sale_Contract);
    event EntrantDetailsUpdated(uint256 _Round, address _Entrant, uint256 _Amount, uint256 _Initial_Ballots, uint256 _Added_Ballots);
    event WinnerToken(uint256 _Round, uint256 _Winner_Ballot, address _Winner_Address);
    event WinnerBase(uint256 _Round, uint256 _Winner_Ballot, address _Winner_Address);
    event DateChanged(uint256 _Round, uint256 _Previous_Date, uint256 _Date);
    event DataSynced();

    modifier onlyOwner() {
        require(owner == msg.sender, "Not sale owner.");
        _;
    }

    constructor(
        address owner_,
        address _token,
        uint256[6] memory _seed_details,
        uint256[6] memory _presale_details,
        uint256[6] memory _community_details
    ) {
        owner = msg.sender;

        token = _token;
        incentiveFactoryAddress = msg.sender;
        _incentiveFactory = iIncentiveFactory(msg.sender);

        saleMasterAddress = _incentiveFactory.saleMasterAddress();
        _saleMaster = iSaleMaster(saleMasterAddress);

        adminAddress = _saleMaster.adminAddress();

        initIncentive(_seed_details,_presale_details,_community_details);

        owner = owner_;

        emit IncentiveCreated(owner, address(this));
    }

    function setOwner(address _newOwner) public onlyOwner {
        address prev_owner = owner;

        owner = _newOwner;

        emit OwnerChanged(prev_owner, owner);
    }

    function setSaleContract(address _sale_contract) public {
        require(msg.sender == saleMasterAddress, "Not authorized");

        saleContract = _sale_contract;

        emit SaleContractSet(msg.sender, saleContract);
    }

    function initIncentive(uint256[6] memory _seed_details,uint256[6] memory _presale_details,uint256[6] memory _community_details) internal {
        if(_seed_details[0] > 0) {
            setIncentiveDetails(1, _seed_details);
        }

        if(_presale_details[0] > 0) {
            setIncentiveDetails(2, _presale_details);
        }

        if(_community_details[0] > 0) {
            setIncentiveDetails(3, _community_details);
        }
    }

    function setIncentiveDetails(uint256 _round, uint256[6] memory _round_details) internal {
        IncentiveDetails storage incentiveDetails = _incentiveDetails[_round];

        incentiveDetails.min_entry = _round_details[0];
        incentiveDetails.mult_ballots = _round_details[1];
        incentiveDetails.incentive_type = _round_details[2];
        incentiveDetails.incentive_rate = _round_details[3];
        incentiveDetails.incentive_amount = _round_details[4];
        incentiveDetails.incentive_date = _round_details[5];
    }

    function setEntrantDetails(uint256 _round, address _entrant, uint256 _amount) public {
        require(msg.sender == saleContract, "Not authorized");

        EntrantDetails storage entrantDetails = _entrantDetails[_round][_entrant];

        uint256 initBallots = entrantDetails.ballots;
        uint256 diffBallots = 0;

        entrantDetails.amount_entered = entrantDetails.amount_entered + _amount;

        if(_incentiveDetails[_round].mult_ballots == 0 && entrantDetails.amount_entered >= _incentiveDetails[_round].min_entry) {
            entrantDetails.ballots = 1;
        } else if(_incentiveDetails[_round].mult_ballots == 1 && entrantDetails.amount_entered >= _incentiveDetails[_round].min_entry) {
            entrantDetails.ballots =  entrantDetails.amount_entered / _incentiveDetails[_round].min_entry;
        }

        if(entrantDetails.ballots > initBallots) {
            diffBallots = entrantDetails.ballots - initBallots;

            for(uint256 i = 1; i <= diffBallots; i++) {
                ballotList[_round][ballotNumber[_round]] = _entrant;
                ballotNumber[_round]++;
            }
        }

        emit EntrantDetailsUpdated(_round, _entrant, _amount, initBallots, diffBallots);
    }

    function findWinnerToken(uint256 _round, uint256[3] memory _randoms) public nonReentrant {
        require(msg.sender == saleContract, "Not authorized");
        require(block.timestamp >= _incentiveDetails[_round].incentive_date, "Not ended");
        require(prizeAmount[_round] > 0, "No prize set");
        require(_incentiveDetails[_round].incentive_type == 1, "Not allowed");

        uint256 winnerBallot = getRandom(ballotNumber[_round],_randoms);
        address winnerAddress = ballotList[_round][winnerBallot];

        ERC20(token).transfer(address(winnerAddress), prizeAmount[_round]);

        emit WinnerToken(_round, winnerBallot, winnerAddress);
    }

    function findWinnerBase(uint256 _round, uint256[3] memory _randoms) public nonReentrant payable {
        require(msg.sender == saleContract, "Not authorized");
        require(block.timestamp >= _incentiveDetails[_round].incentive_date, "Not ended");
        require(prizeAmount[_round] > 0, "No prize set");
        require(msg.value == prizeAmount[_round], "Prize doesn't match");
        require(_incentiveDetails[_round].incentive_type == 2, "Not allowed");

        uint256 winnerBallot = getRandom(ballotNumber[_round], _randoms);
        address winnerAddress = ballotList[_round][winnerBallot];

        payable(address(winnerAddress)).transfer(prizeAmount[_round]);

        emit WinnerBase(_round, winnerBallot, winnerAddress);
    }

    function getRandom(uint256 _number, uint256[3] memory _randoms) internal view returns(uint256 _random) {

        uint256 round1 = random("one", (_number * _randoms[0]).toString(), string(abi.encodePacked("one", _randoms[0], _randoms[1], _randoms[2]))) % _number;
        uint256 round2 = random("two", (_number * _randoms[1]).toString(), string(abi.encodePacked("two", _randoms[1], _randoms[2], _randoms[0]))) % _number;
        uint256 round3 = random("three", (_number * _randoms[2]).toString(), string(abi.encodePacked("three", _randoms[2], _randoms[0], _randoms[1]))) % _number;

        _random = random("selection",(round1 + round2 + round3).toString(),string(abi.encodePacked("selection", round1, _randoms[0], round2, _randoms[1], round3, _randoms[2]))) % _number;

        return(_random);
    }

    function random(string memory _round, string memory _quantity, string memory _id) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty,block.timestamp,msg.sender,_round,_quantity, _id)));
    }

    function calcPrize(uint256 _round, uint256 _amount_in) public {
        require(msg.sender == saleContract, "Not authorized");
        require(_incentiveDetails[_round].incentive_type > 0, "No incentive set");

        if(_incentiveDetails[_round].incentive_rate == 0) {
            prizeAmount[_round] = _incentiveDetails[_round].incentive_amount;
        } else {
            prizeAmount[_round] = _amount_in * _incentiveDetails[_round].incentive_amount / 100;
        }
    }

    function getType(uint256 _round) public view returns(uint256){
        return(_incentiveDetails[_round].incentive_type);
    }

    function getPrizeAmount(uint256 _round) public view returns(uint256){
        return(prizeAmount[_round]);
    }

    function getEntrantDetails(uint256 _round, address _entrant) public view returns(uint256, uint256) {
        EntrantDetails memory entrantDetails = _entrantDetails[_round][_entrant];

        return (entrantDetails.amount_entered, entrantDetails.ballots);
    }

    function getIncentiveDetails(uint256 _round) public view returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        IncentiveDetails memory incentiveDetails = _incentiveDetails[_round];

        return(incentiveDetails.min_entry, incentiveDetails.mult_ballots, incentiveDetails.incentive_type, incentiveDetails.incentive_rate,
        incentiveDetails.incentive_amount, incentiveDetails.incentive_date, incentiveDetails.incentive_winner);
    }

    function getNumberOfBallots(uint256 _round) public view returns(uint256) {
        return(ballotNumber[_round]);
    }

    function getBallotList(uint256 _round) public view returns(address[] memory) {

        address[] memory entrant = new address[](ballotNumber[_round]);

        for(uint256 i = 0; i < ballotNumber[_round]; i++) {
            entrant[i] = ballotList[_round][i];
        }

        return(entrant);
    }

    function getBallotAddress(uint256 _round, uint256 _number) public view returns(address entrant) {
        return(ballotList[_round][_number]);
    }

    function updateDate(uint256 _round, uint256 _newDate) public {
        require(msg.sender == saleContract, "Not authorized");

        uint256 prev_date = _incentiveDetails[_round].incentive_date;

        _incentiveDetails[_round].incentive_date = _newDate;

        emit DateChanged(_round, prev_date, _newDate);
    }

    function syncData() public {
        require(msg.sender == owner || msg.sender == adminAddress, "Not authorized");
        saleMasterAddress = _incentiveFactory.saleMasterAddress();
        _saleMaster = iSaleMaster(saleMasterAddress);
        adminAddress = _saleMaster.adminAddress();

        emit DataSynced();
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
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