/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
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
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
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
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
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
}

abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(
            currentAllowance >= amount,
            "ERC20: burn amount exceeds allowance"
        );
        _approve(account, _msgSender(), currentAllowance - amount);
        _burn(account, amount);
    }
}

contract Metanetint is ERC20, ERC20Burnable {
    address payable public creator;
    using Strings for uint256;

    uint public Max_supply = 9999999 ether;
    uint public burn_amount = 0;
    uint public mint_for_airdrop = 0;

    uint public proposalId = 1;

    struct Vote {
        address wallet;
        uint amount;
        uint proposalId;
        bool isYes;
    }

    struct Proposal {
        uint id;
        uint256 reqAmount;
        address depositWallet;
        address creator;
        uint256 expiryDate;
        uint256 voteYesCount;
        uint256 voteNoCount;
        bool isActive;
        bool feeWithdraw;
    }

    mapping(uint => Proposal) public allProposal;
    mapping(address => mapping(uint => Vote)) public allVote;

    constructor(
        string memory _name,
        string memory _symbol,
        address payable _creator
    ) ERC20(_name, _symbol) {
        creator = _creator;
    }

    function mint(address wallet, uint256 amount) public OnlyCreator {
        require(totalSupply() <= Max_supply, "Sale has already ended.");
        require(
            totalSupply() + amount <= Max_supply,
            "Exceeds maximum supply !"
        );
        require(
            (mint_for_airdrop + amount) <= 499980 ether,
            "mint for airdrop end  "
        );

        mint_for_airdrop = mint_for_airdrop + amount;

        _mint(wallet, amount);
    }

    function burnToken(uint256 amount) public virtual OnlyCreator {
        require(
            totalSupply() + amount <= Max_supply,
            "Exceeds maximum supply !"
        );
        require(
            (mint_for_airdrop + amount) <= 499980 ether,
            "mint for airdrop end  "
        );

        burn_amount += amount;
        Max_supply -= amount;

        mint_for_airdrop = mint_for_airdrop + amount;

        _mint(_msgSender(), amount);
        _burn(_msgSender(), amount);
    }

    function burn(uint256 amount) public virtual override {
        Max_supply -= amount;
        burn_amount += amount;

        _burn(_msgSender(), amount);
    }

    function getSingleProposal(uint _proposalId)
        public
        view
        returns (Proposal memory)
    {
        require(allProposal[_proposalId].id > 0, "proposal not valid");
        return allProposal[_proposalId];
    }

    function createNewProposal(uint256 _reqAmount, address _depositWallet)
        public
    {

        require(_reqAmount <= ((totalSupply() * 50) / 100) , 'amount not valid ');
        uint exp = 2 weeks + block.timestamp;

        Proposal memory proposal = Proposal({
            id: proposalId,
            reqAmount: _reqAmount,
            depositWallet: _depositWallet,
            creator: msg.sender,
            expiryDate: exp,
            voteYesCount: 0,
            voteNoCount: 0,
            isActive: false,
            feeWithdraw: false
        });
        allProposal[proposalId] = proposal;

        proposalId++;
    }

    function setVote(
        uint tokenAmountStack,
        uint _proposalId,
        bool isYes
    ) public {
        require(tokenAmountStack > 0, "amount not valid ");

        require(allProposal[_proposalId].id > 0, "proposal not valid");

        require(
            allVote[msg.sender][_proposalId].amount < 1,
            "You have registered your vote"
        );

        require(balanceOf(msg.sender) >= tokenAmountStack, "Inventory is low");

        require(
            allProposal[_proposalId].expiryDate > block.timestamp,
            "proposal expiry date"
        );

        allVote[msg.sender][_proposalId] = Vote({
            wallet: msg.sender,
            amount: tokenAmountStack,
            proposalId: _proposalId,
            isYes: isYes
        });

        if (isYes) {
            allProposal[_proposalId].voteYesCount =
                allProposal[_proposalId].voteYesCount +
                tokenAmountStack;
        } else {
            allProposal[_proposalId].voteNoCount =
                allProposal[_proposalId].voteNoCount +
                tokenAmountStack;
        }

        super.transfer(address(this), tokenAmountStack);

        _calcValidProposal(_proposalId);
    }

    function withdrawUserVote(uint _proposalId) public {
        require(allProposal[_proposalId].id > 0, "proposal not valid");

        require(
            allVote[msg.sender][_proposalId].amount > 1,
            "You not registered your vote"
        );

        Vote memory userVote = allVote[msg.sender][_proposalId];

        if (allProposal[_proposalId].expiryDate > block.timestamp) {
            if (userVote.isYes) {
                allProposal[_proposalId].voteYesCount =
                    allProposal[_proposalId].voteYesCount -
                    userVote.amount;
            } else {
                allProposal[_proposalId].voteNoCount =
                    allProposal[_proposalId].voteNoCount -
                    userVote.amount;
            }
        }
        uint256 amount = userVote.amount;

        super._transfer(address(this), address(userVote.wallet), amount);

        allVote[msg.sender][_proposalId].amount = 0;

        _calcValidProposal(_proposalId);
    }

    function withdrawCreatorVote(uint _proposalId) public {
        require(allProposal[_proposalId].id > 0, "proposal not valid");
        require(
            allProposal[_proposalId].creator == msg.sender,
            " you not creator proposal "
        );
        require(allProposal[_proposalId].isActive, " proposal not active ");
        require(!allProposal[_proposalId].feeWithdraw, " feeWithdraw  ");

        require(
            allProposal[_proposalId].expiryDate <= block.timestamp,
            "proposal expiry date not end"
        );

        require(
            totalSupply() + allProposal[_proposalId].reqAmount <= Max_supply,
            "Exceeds maximum supply !"
        );

        allProposal[_proposalId].feeWithdraw = true;
        _mint(
            address(allProposal[_proposalId].depositWallet),
            allProposal[_proposalId].reqAmount
        );
    }

    function _calcValidProposal(uint _proposalId) private {
        require(allProposal[_proposalId].id > 0, "proposal not valid");

        if (allProposal[_proposalId].expiryDate > block.timestamp) {
            uint yesCount = allProposal[_proposalId].voteYesCount;
            uint noCount = allProposal[_proposalId].voteNoCount;
            uint t = (totalSupply() * 51) / 100;
            if (yesCount + noCount > t && yesCount > noCount) {
                allProposal[_proposalId].isActive = true;
            } else {
                allProposal[_proposalId].isActive = false;
            }
        }
    }

    modifier OnlyCreator() {
        require(msg.sender == creator, "only creator");
        _;
    }
}