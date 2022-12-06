/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: UNLICENSED

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

// File openzeppelin-solidity/contracts/token/ERC20/extensions/[email protected]

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

// File openzeppelin-solidity/contracts/utils/[email protected]

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

// File openzeppelin-solidity/contracts/token/ERC20/[email protected]

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

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

// File contracts/Myntist.sol

pragma solidity 0.8.7;

library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash < proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(
                    abi.encodePacked(computedHash, proofElement)
                );
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(
                    abi.encodePacked(proofElement, computedHash)
                );
            }
        }

        // Check if the computed hash (root) is equal to the provided root
        return computedHash == root;
    }
}

contract GlobalsAndUtility is ERC20 {
    /*  XfLobbyEnter      (auto-generated event)

        uint40            timestamp       -->  data0 [ 39:  0]
        address  indexed  memberAddr
        uint256  indexed  entryId
        uint96            rawAmount       -->  data0 [135: 40]
        address  indexed  referrerAddr
    */
    event XfLobbyEnter(
        uint256 data0,
        address indexed memberAddr,
        uint256 indexed entryId,
        address indexed referrerAddr
    );

    /*  XfLobbyExit       (auto-generated event)

        uint40            timestamp       -->  data0 [ 39:  0]
        address  indexed  memberAddr
        uint256  indexed  entryId
        uint72            xfAmount        -->  data0 [111: 40]
        address  indexed  referrerAddr
    */
    event XfLobbyExit(
        uint256 data0,
        address indexed memberAddr,
        uint256 indexed entryId,
        address indexed referrerAddr,
        uint256 referrerAddrBonus
    );

    /*  DailyDataUpdate   (auto-generated event)

        uint40            timestamp       -->  data0 [ 39:  0]
        uint16            beginDay        -->  data0 [ 55: 40]
        uint16            endDay          -->  data0 [ 71: 56]
        bool              isAutoUpdate    -->  data0 [ 79: 72]
        address  indexed  updaterAddr
    */
    event DailyDataUpdate(uint256 data0, address indexed updaterAddr);

    /*  Claim             (auto-generated event)

        uint40            timestamp       -->  data0 [ 39:  0]
        bytes20  indexed  btcAddr
        uint56            rawSatoshis     -->  data0 [ 95: 40]
        uint56            adjSatoshis     -->  data0 [151: 96]
        address  indexed  claimToAddr
        uint8             claimFlags      -->  data0 [159:152]
        uint72            claimedFranks   -->  data0 [231:160]
        address  indexed  referrerAddr
        address           senderAddr      -->  data1 [159:  0]
    */
    event Claim(
        uint256 data0,
        uint256 data1,
        bytes20 indexed btcAddr,
        address indexed claimToAddr,
        address indexed referrerAddr,
        uint256 referrerBonus,
        uint256 claimedMynt,
        uint256 adjBtc,
        uint256 rawBtc
    );

    /*  ClaimAssist       (auto-generated event)

        uint40            timestamp       -->  data0 [ 39:  0]
        bytes20           btcAddr         -->  data0 [199: 40]
        uint56            rawSatoshis     -->  data0 [255:200]
        uint56            adjSatoshis     -->  data1 [ 55:  0]
        address           claimToAddr     -->  data1 [215: 56]
        uint8             claimFlags      -->  data1 [223:216]
        uint72            claimedFranks   -->  data2 [ 71:  0]
        address           referrerAddr    -->  data2 [231: 72]
        address  indexed  senderAddr
    */
    event ClaimAssist(
        uint256 data0,
        uint256 data1,
        uint256 data2,
        address indexed senderAddr
    );

    /*  StakeStart        (auto-generated event)

        uint40            timestamp       -->  data0 [ 39:  0]
        address  indexed  stakerAddr
        uint40   indexed  stakeId
        uint72            stakedFranks    -->  data0 [111: 40]
        uint72            stakeShares     -->  data0 [183:112]
        uint16            stakedDays      -->  data0 [199:184]
        bool              isAutoStake     -->  data0 [207:200]
    */
    event StakeStart(
        uint256 data0,
        address indexed stakerAddr,
        uint40 indexed stakeId
    );

    /*  StakeGoodAccounting(auto-generated event)

        uint40            timestamp       -->  data0 [ 39:  0]
        address  indexed  stakerAddr
        uint40   indexed  stakeId
        uint72            stakedFranks    -->  data0 [111: 40]
        uint72            stakeShares     -->  data0 [183:112]
        uint72            payout          -->  data0 [255:184]
        uint72            penalty         -->  data1 [ 71:  0]
        address  indexed  senderAddr
    */
    event StakeGoodAccounting(
        uint256 data0,
        uint256 data1,
        address indexed stakerAddr,
        uint40 indexed stakeId,
        address indexed senderAddr
    );

    /*  StakeEnd          (auto-generated event)

        uint40            timestamp       -->  data0 [ 39:  0]
        address  indexed  stakerAddr
        uint40   indexed  stakeId
        uint72            stakedFranks    -->  data0 [111: 40]
        uint72            stakeShares     -->  data0 [183:112]
        uint72            payout          -->  data0 [255:184]
        uint72            penalty         -->  data1 [ 71:  0]
        uint16            servedDays      -->  data1 [ 87: 72]
        bool              prevUnlocked    -->  data1 [ 95: 88]
    */
    event StakeEnd(
        uint256 data0,
        uint256 data1,
        address indexed stakerAddr,
        uint40 indexed stakeId,
        uint256 stakeReturn
    );

    /*  ShareRateChange   (auto-generated event)

        uint40            timestamp       -->  data0 [ 39:  0]
        uint40            shareRate       -->  data0 [ 79: 40]
        uint40   indexed  stakeId
    */
    event ShareRateChange(
        uint256 data0,
        uint40 indexed stakeId,
        uint256 shareRate
    );

    /* Origin address */
    address internal constant ORIGIN_ADDR =
        0x0297209262AA172478b4B5A54b46A7d1cC77a80B;

    /* Flush address */
    address internal constant FLUSH_ADDR =
        0x0297209262AA172478b4B5A54b46A7d1cC77a80B;

    /* ERC20 constants */
    function decimals() public view virtual override returns (uint8) {
        return 8;
    }

    constructor() ERC20("MYNTIST", "MYNT") {
        owner = msg.sender;
    }

    // uint8 public constant decimal = 8;

    /* Franks per Satoshi = 10,000 * 1e8 / 1e8 = 1e4 */
    uint256 private constant FRANKS_PER_MYNT = 10**uint256(8); // 1e8
    uint256 private constant MYNT_PER_BTC = 1e4;
    uint256 private constant SATOSHIS_PER_BTC = 1e8;
    uint256 internal constant FRANKS_PER_SATOSHI =
        (FRANKS_PER_MYNT / SATOSHIS_PER_BTC) * MYNT_PER_BTC;

    /* Time of contract launch (2019-12-03T00:00:00Z) */
    uint256 internal constant LAUNCH_TIME = 1670243400;

    /* Size of a Franks or Shares uint */
    uint256 internal constant FRANK_UINT_SIZE = 72;

    /* Size of a transform lobby entry index uint */
    uint256 internal constant XF_LOBBY_ENTRY_INDEX_SIZE = 40;
    uint256 internal constant XF_LOBBY_ENTRY_INDEX_MASK =
        (1 << XF_LOBBY_ENTRY_INDEX_SIZE) - 1;

    /* Seed for WAAS Lobby */
    uint256 internal constant WAAS_LOBBY_SEED_MYNT = 1e9;
    uint256 internal constant WAAS_LOBBY_SEED_FRANKS =
        WAAS_LOBBY_SEED_MYNT * FRANKS_PER_MYNT;

    /* Start of claim phase */
    uint256 internal constant PRE_CLAIM_DAYS = 1;
    uint256 internal constant CLAIM_PHASE_START_DAY = PRE_CLAIM_DAYS;

    /* Length of claim phase */
    uint256 private constant CLAIM_PHASE_WEEKS = 50;
    uint256 internal constant CLAIM_PHASE_DAYS = CLAIM_PHASE_WEEKS * 7;

    /* End of claim phase */
    uint256 internal constant CLAIM_PHASE_END_DAY =
        CLAIM_PHASE_START_DAY + CLAIM_PHASE_DAYS;

    /* Number of words to hold 1 bit for each transform lobby day */
    uint256 internal constant XF_LOBBY_DAY_WORDS =
        (CLAIM_PHASE_END_DAY + 255) >> 8;

    /* BigPayDay */
    uint256 internal constant BIG_PAY_DAY = CLAIM_PHASE_END_DAY + 1;

    /* Root hash of the UTXO Merkle tree */
    bytes32 internal constant MERKLE_TREE_ROOT =
        0x356e9927cd8116111dde8864f0d5c1bc3a7805656ca9f2d3d4a1403721846e30;

    /* Size of a Satoshi claim uint in a Merkle leaf */
    uint256 internal constant MERKLE_LEAF_SATOSHI_SIZE = 45;

    /* Zero-fill between BTC address and Satoshis in a Merkle leaf */
    // uint256 internal constant MERKLE_LEAF_FILL_SIZE =
    //     256 - 160 - MERKLE_LEAF_SATOSHI_SIZE;
    // uint256 internal constant MERKLE_LEAF_FILL_BASE =
    //     (1 << MERKLE_LEAF_FILL_SIZE) - 1;
    // uint256 internal constant MERKLE_LEAF_FILL_MASK =
    //     MERKLE_LEAF_FILL_BASE << MERKLE_LEAF_SATOSHI_SIZE;

    /* Size of a Satoshi total uint */
    uint256 internal constant SATOSHI_UINT_SIZE = 51;
    uint256 internal constant SATOSHI_UINT_MASK = (1 << SATOSHI_UINT_SIZE) - 1;

    /* Total Satoshis from all BTC addresses in UTXO snapshot */
    uint256 internal constant FULL_SATOSHIS_TOTAL = 1900000000000000;

    /* Total Satoshis from supported BTC addresses in UTXO snapshot after applying Silly Whale */
    uint256 internal constant CLAIMABLE_SATOSHIS_TOTAL = 910087996911001;

    /* Number of claimable BTC addresses in UTXO snapshot */
    uint256 internal constant CLAIMABLE_BTC_ADDR_COUNT = 27997742;

    /* Largest BTC address Satoshis balance in UTXO snapshot (sanity check) */
    uint256 internal constant MAX_BTC_ADDR_BALANCE_SATOSHIS = 25550214098481;

    /* Percentage of total claimed Franks that will be auto-staked from a claim */
    uint256 internal constant AUTO_STAKE_CLAIM_PERCENT = 90;

    /* Stake timing parameters */
    uint256 internal constant MIN_STAKE_DAYS = 1;
    uint256 internal constant MIN_AUTO_STAKE_DAYS = 350;

    uint256 internal constant MAX_STAKE_DAYS = 5555; // Approx 15 years

    uint256 internal constant EARLY_PENALTY_MIN_DAYS = 90;

    uint256 private constant LATE_PENALTY_GRACE_WEEKS = 2;
    uint256 internal constant LATE_PENALTY_GRACE_DAYS =
        LATE_PENALTY_GRACE_WEEKS * 7;

    uint256 private constant LATE_PENALTY_SCALE_WEEKS = 100;
    uint256 internal constant LATE_PENALTY_SCALE_DAYS =
        LATE_PENALTY_SCALE_WEEKS * 7;

    /* Stake shares Longer Pays Better bonus constants used by _stakeStartBonusFranks() */
    uint256 private constant LPB_BONUS_PERCENT = 20;
    uint256 private constant LPB_BONUS_MAX_PERCENT = 200;
    uint256 internal constant LPB = (364 * 100) / LPB_BONUS_PERCENT;
    uint256 internal constant LPB_MAX_DAYS =
        (LPB * LPB_BONUS_MAX_PERCENT) / 100;

    /* Stake shares Bigger Pays Better bonus constants used by _stakeStartBonusFranks() */
    uint256 private constant BPB_BONUS_PERCENT = 10;
    uint256 private constant BPB_MAX_MYNT = 150 * 1e6;
    uint256 internal constant BPB_MAX_FRANKS = BPB_MAX_MYNT * FRANKS_PER_MYNT;
    uint256 internal constant BPB = (BPB_MAX_FRANKS * 100) / BPB_BONUS_PERCENT;

    /* Share rate is scaled to increase precision */
    uint256 internal constant SHARE_RATE_SCALE = 1e5;

    /* Share rate max (after scaling) */
    uint256 internal constant SHARE_RATE_UINT_SIZE = 40;
    uint256 internal constant SHARE_RATE_MAX = (1 << SHARE_RATE_UINT_SIZE) - 1;

    /* Constants for preparing the claim message text */
    // uint8 internal constant ETH_ADDRESS_BYTE_LEN = 20;
    // uint8 internal constant ETH_ADDRESS_MYNT_LEN = ETH_ADDRESS_BYTE_LEN * 2;

    // uint8 internal constant CLAIM_PARAM_HASH_BYTE_LEN = 12;
    // uint8 internal constant CLAIM_PARAM_HASH_MYNT_LEN =
    //     CLAIM_PARAM_HASH_BYTE_LEN * 2;

    // uint8 internal constant BITCOIN_SIG_PREFIX_LEN = 24;
    // bytes24 internal constant BITCOIN_SIG_PREFIX_STR =
    //     "Bitcoin Signed Message:\n";

    // bytes internal constant STD_CLAIM_PREFIX_STR = "Claim_MYNT_to_0x";
    // bytes internal constant OLD_CLAIM_PREFIX_STR = "Claim_BitcoinMYNT_to_0x";

    // bytes16 internal constant MYNT_DIGITS = "0123456789abcdef";

    /* Claim flags passed to btcAddressClaim()  */
    uint8 internal constant CLAIM_FLAG_MSG_PREFIX_OLD = 1 << 0;
    uint8 internal constant CLAIM_FLAG_BTC_ADDR_COMPRESSED = 1 << 1;
    uint8 internal constant CLAIM_FLAG_BTC_ADDR_P2WPKH_IN_P2SH = 1 << 2;
    uint8 internal constant CLAIM_FLAG_BTC_ADDR_BECH32 = 1 << 3;
    uint8 internal constant CLAIM_FLAG_ETH_ADDR_LOWERCASE = 1 << 4;

    //For NFT AA CONTRACT
    address internal nftAAMinter;
    address internal owner;
    address internal rewardMinter;

    // Signature struct
    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    mapping(bytes32 => bool) public executed;

    /* Globals expanded for memory (except _latestStakeId) and compact for storage */
    struct GlobalsCache {
        // 1
        //Stake Franks Total
        uint256 _lockedFranksTotal;
        //Stake Shares Created on current day
        uint256 _nextStakeSharesTotal;
        // Share Rate of Share
        uint256 _shareRate;
        //Total Penalties Late + Early
        uint256 _stakePenaltyTotal;
        // 2
        //Just Like Last Updated Day
        uint256 _dailyDataCount;
        //Total Shares Staked
        uint256 _stakeSharesTotal;
        //Latest Stake Id
        uint40 _latestStakeId;
        //Unclaimed Btc Total
        uint256 _unclaimedSatoshisTotal;
        //Claimed Btc Total
        uint256 _claimedSatoshisTotal;
        //Claim BTC Address Count
        uint256 _claimedBtcAddrCount;
        //
        uint256 _currentDay;
    }

    struct GlobalsStore {
        // 1
        uint72 lockedFranksTotal;
        uint72 nextStakeSharesTotal;
        uint40 shareRate;
        uint72 stakePenaltyTotal;
        // 2
        uint16 dailyDataCount;
        uint72 stakeSharesTotal;
        uint40 latestStakeId;
        uint128 claimStats;
    }

    GlobalsStore public globals;

    /* Claimed BTC addresses */
    mapping(bytes20 => bool) public btcAddressClaims;

    /* Daily data */
    struct DailyDataStore {
        uint72 dayPayoutTotal;
        uint72 dayStakeSharesTotal;
        uint56 dayUnclaimedSatoshisTotal;
    }

    mapping(uint256 => DailyDataStore) public dailyData;

    /* Stake expanded for memory (except _stakeId) and compact for storage */
    struct StakeCache {
        uint40 _stakeId;
        uint256 _stakedFranks;
        uint256 _stakeShares;
        uint256 _lockedDay;
        uint256 _stakedDays;
        uint256 _unlockedDay;
        bool _isAutoStake;
    }

    struct StakeStore {
        uint40 stakeId;
        uint72 stakedFranks;
        uint72 stakeShares;
        uint16 lockedDay;
        uint16 stakedDays;
        uint16 unlockedDay;
        bool isAutoStake;
        string newStakeName;
    }

    mapping(address => StakeStore[]) public stakeLists;

    /* Temporary state for calculating daily rounds */
    struct DailyRoundState {
        uint256 _allocSupplyCached;
        uint256 _mintOriginBatch;
        uint256 _payoutTotal;
    }

    struct XfLobbyEntryStore {
        uint96 rawAmount;
        address referrerAddr;
    }

    struct XfLobbyQueueStore {
        uint40 headIndex;
        uint40 tailIndex;
        mapping(uint256 => XfLobbyEntryStore) entries;
    }

    mapping(uint256 => uint256) public xfLobby;
    mapping(uint256 => mapping(address => XfLobbyQueueStore))
        public xfLobbyMembers;

    modifier onlyNFTMinter() {
        require(msg.sender == nftAAMinter, "Invalid Caller");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyMiniAAMinter() {
        require(msg.sender == rewardMinter, "Invalid Caller");
        _;
    }

    function setAddressesForContractSupplies(
        address nftAAContractAddress,
        address miniAAContractAddress
    ) external onlyOwner {
        nftAAMinter = nftAAContractAddress;
        rewardMinter = miniAAContractAddress;
    }

    // function setMiniAAMinter(address _minter) public onlyOwner {
    //     rewardMinter = _minter;
    // }

    function mintAmountForNftAA(address _to, uint256 _amount)
        public
        onlyNFTMinter
    {
        require(_to != address(0), "invalid address");
        require(_amount > 0, "Amount must be more than Zero");
        _mint(_to, _amount);
    }

    function mintAmount(address _to, uint256 _amount) public onlyMiniAAMinter {
        require(_to != address(0), "invalid address");
        require(_amount > 0, "Amount must be more than Zero");
        _mint(_to, _amount);
    }

    /**
     * @dev PUBLIC FACING: Optionally update daily data for a smaller
     * range to reduce gas cost for a subsequent operation
     * @param beforeDay Only update days before this day number (optional; 0 for current day)
     */
    function dailyDataUpdate(uint256 beforeDay) external {
        GlobalsCache memory g;
        GlobalsCache memory gSnapshot;
        _globalsLoad(g, gSnapshot);

        /* Skip pre-claim period */
        require(g._currentDay > CLAIM_PHASE_START_DAY, "Too early");

        if (beforeDay != 0) {
            require(beforeDay <= g._currentDay, "invalid beforeDay");

            _dailyDataUpdate(g, beforeDay, false);
        } else {
            /* Default to updating before current day */
            _dailyDataUpdate(g, g._currentDay, false);
        }

        _globalsSync(g, gSnapshot);
    }

    /**
     * @dev PUBLIC FACING: External helper to return multiple values of daily data with
     * a single call. Ugly implementation due to limitations of the standard ABI encoder.
     * @param beginDay First day of data range
     * @param endDay Last day (non-inclusive) of data range
     * Fixed array of packed values
     */
    function dailyDataRange(uint256 beginDay, uint256 endDay)
        external
        view
        returns (uint256[] memory list)
    {
        require(
            beginDay < endDay && endDay <= globals.dailyDataCount,
            "range invalid"
        );

        list = new uint256[](endDay - beginDay);

        uint256 src = beginDay;
        uint256 dst = 0;
        uint256 v;
        do {
            v =
                uint256(dailyData[src].dayUnclaimedSatoshisTotal) <<
                (FRANK_UINT_SIZE * 2);
            v |= uint256(dailyData[src].dayStakeSharesTotal) << FRANK_UINT_SIZE;
            v |= uint256(dailyData[src].dayPayoutTotal);

            list[dst++] = v;
        } while (++src < endDay);

        return list;
    }

    /**
     * @dev PUBLIC FACING: External helper to return most global info with a single call.
     * Ugly implementation due to limitations of the standard ABI encoder.
     * @return Fixed array of values
     */
    function globalInfo() external view returns (uint256[13] memory) {
        uint256 _claimedBtcAddrCount;
        uint256 _claimedSatoshisTotal;
        uint256 _unclaimedSatoshisTotal;

        (
            _claimedBtcAddrCount,
            _claimedSatoshisTotal,
            _unclaimedSatoshisTotal
        ) = _claimStatsDecode(globals.claimStats);

        return [
            // 1
            globals.lockedFranksTotal,
            globals.nextStakeSharesTotal,
            globals.shareRate,
            globals.stakePenaltyTotal,
            // 2
            globals.dailyDataCount,
            globals.stakeSharesTotal,
            globals.latestStakeId,
            _unclaimedSatoshisTotal,
            _claimedSatoshisTotal,
            _claimedBtcAddrCount,
            //
            block.timestamp,
            totalSupply(),
            xfLobby[_currentDay()]
        ];
    }

    /**
     * @dev PUBLIC FACING: ERC20 totalSupply() is the circulating supply and does not include any
     * staked Franks. allocatedSupply() includes both.
     * @return Allocated Supply in Franks
     */
    function allocatedSupply() external view returns (uint256) {
        return totalSupply() + globals.lockedFranksTotal;
    }

    /**
     * @dev PUBLIC FACING: External helper for the current day number since launch time
     * @return Current day number (zero-based)
     */
    function currentDay() external view returns (uint256) {
        return _currentDay();
    }

    function _currentDay() internal view returns (uint256) {
        return (block.timestamp - LAUNCH_TIME) / 300;
    }

    function _dailyDataUpdateAuto(GlobalsCache memory g) internal {
        _dailyDataUpdate(g, g._currentDay, true);
    }

    function _globalsLoad(GlobalsCache memory g, GlobalsCache memory gSnapshot)
        internal
        view
    {
        // 1
        g._lockedFranksTotal = globals.lockedFranksTotal;
        g._nextStakeSharesTotal = globals.nextStakeSharesTotal;
        g._shareRate = globals.shareRate;
        g._stakePenaltyTotal = globals.stakePenaltyTotal;
        // 2
        g._dailyDataCount = globals.dailyDataCount;
        g._stakeSharesTotal = globals.stakeSharesTotal;
        g._latestStakeId = globals.latestStakeId;
        (
            g._claimedBtcAddrCount,
            g._claimedSatoshisTotal,
            g._unclaimedSatoshisTotal
        ) = _claimStatsDecode(globals.claimStats);
        //
        g._currentDay = _currentDay();

        _globalsCacheSnapshot(g, gSnapshot);
    }

    function _globalsCacheSnapshot(
        GlobalsCache memory g,
        GlobalsCache memory gSnapshot
    ) internal pure {
        // 1
        gSnapshot._lockedFranksTotal = g._lockedFranksTotal;
        gSnapshot._nextStakeSharesTotal = g._nextStakeSharesTotal;
        gSnapshot._shareRate = g._shareRate;
        gSnapshot._stakePenaltyTotal = g._stakePenaltyTotal;
        // 2
        gSnapshot._dailyDataCount = g._dailyDataCount;
        gSnapshot._stakeSharesTotal = g._stakeSharesTotal;
        gSnapshot._latestStakeId = g._latestStakeId;
        gSnapshot._unclaimedSatoshisTotal = g._unclaimedSatoshisTotal;
        gSnapshot._claimedSatoshisTotal = g._claimedSatoshisTotal;
        gSnapshot._claimedBtcAddrCount = g._claimedBtcAddrCount;
    }

    function _globalsSync(GlobalsCache memory g, GlobalsCache memory gSnapshot)
        internal
    {
        if (
            g._lockedFranksTotal != gSnapshot._lockedFranksTotal ||
            g._nextStakeSharesTotal != gSnapshot._nextStakeSharesTotal ||
            g._shareRate != gSnapshot._shareRate ||
            g._stakePenaltyTotal != gSnapshot._stakePenaltyTotal
        ) {
            // 1
            globals.lockedFranksTotal = uint72(g._lockedFranksTotal);
            globals.nextStakeSharesTotal = uint72(g._nextStakeSharesTotal);
            globals.shareRate = uint40(g._shareRate);
            globals.stakePenaltyTotal = uint72(g._stakePenaltyTotal);
        }
        if (
            g._dailyDataCount != gSnapshot._dailyDataCount ||
            g._stakeSharesTotal != gSnapshot._stakeSharesTotal ||
            g._latestStakeId != gSnapshot._latestStakeId ||
            g._unclaimedSatoshisTotal != gSnapshot._unclaimedSatoshisTotal ||
            g._claimedSatoshisTotal != gSnapshot._claimedSatoshisTotal ||
            g._claimedBtcAddrCount != gSnapshot._claimedBtcAddrCount
        ) {
            // 2
            globals.dailyDataCount = uint16(g._dailyDataCount);
            globals.stakeSharesTotal = uint72(g._stakeSharesTotal);
            globals.latestStakeId = g._latestStakeId;
            globals.claimStats = _claimStatsEncode(
                g._claimedBtcAddrCount,
                g._claimedSatoshisTotal,
                g._unclaimedSatoshisTotal
            );
        }
    }

    function _stakeLoad(
        StakeStore storage stRef,
        uint40 stakeIdParam,
        StakeCache memory st
    ) internal view {
        /* Ensure caller's stakeIndex is still current */
        require(stakeIdParam == stRef.stakeId, "not found");

        st._stakeId = stRef.stakeId;
        st._stakedFranks = stRef.stakedFranks;
        st._stakeShares = stRef.stakeShares;
        st._lockedDay = stRef.lockedDay;
        st._stakedDays = stRef.stakedDays;
        st._unlockedDay = stRef.unlockedDay;
        st._isAutoStake = stRef.isAutoStake;
    }

    function _stakeUpdate(StakeStore storage stRef, StakeCache memory st)
        internal
    {
        stRef.stakeId = st._stakeId;
        stRef.stakedFranks = uint72(st._stakedFranks);
        stRef.stakeShares = uint72(st._stakeShares);
        stRef.lockedDay = uint16(st._lockedDay);
        stRef.stakedDays = uint16(st._stakedDays);
        stRef.unlockedDay = uint16(st._unlockedDay);
        stRef.isAutoStake = st._isAutoStake;
    }

    function _stakeAdd(
        StakeStore[] storage stakeListRef,
        uint40 newStakeId,
        uint256 newStakedFranks,
        uint256 newStakeShares,
        uint256 newLockedDay,
        uint256 newStakedDays,
        bool newAutoStake,
        string memory newStakeName
    ) internal {
        stakeListRef.push(
            StakeStore(
                newStakeId,
                uint72(newStakedFranks),
                uint72(newStakeShares),
                uint16(newLockedDay),
                uint16(newStakedDays),
                uint16(0), // unlockedDay
                newAutoStake,
                newStakeName
            )
        );
    }

    /**
     * @dev Efficiently delete from an unordered array by moving the last element
     * to the "hole" and reducing the array length. Can change the order of the list
     * and invalidate previously held indexes.
     * @notice stakeListRef length and stakeIndex are already ensured valid in stakeEnd()
     * @param stakeListRef Reference to stakeLists[stakerAddr] array in storage
     * @param stakeIndex Index of the element to delete
     */
    function _stakeRemove(StakeStore[] storage stakeListRef, uint256 stakeIndex)
        internal
    {
        uint256 lastIndex = stakeListRef.length - 1;

        /* Skip the copy if element to be removed is already the last element */
        if (stakeIndex != lastIndex) {
            /* Copy last element to the requested element's "hole" */
            stakeListRef[stakeIndex] = stakeListRef[lastIndex];
        }

        /*
            Reduce the array length now that the array is contiguous.
            Surprisingly, 'pop()' uses less gas than 'stakeListRef.length = lastIndex'
        */
        stakeListRef.pop();
    }

    function _claimStatsEncode(
        uint256 _claimedBtcAddrCount,
        uint256 _claimedSatoshisTotal,
        uint256 _unclaimedSatoshisTotal
    ) internal pure returns (uint128) {
        uint256 v = _claimedBtcAddrCount << (SATOSHI_UINT_SIZE * 2);
        v |= _claimedSatoshisTotal << SATOSHI_UINT_SIZE;
        v |= _unclaimedSatoshisTotal;

        return uint128(v);
    }

    function _claimStatsDecode(uint128 v)
        internal
        pure
        returns (
            uint256 _claimedBtcAddrCount,
            uint256 _claimedSatoshisTotal,
            uint256 _unclaimedSatoshisTotal
        )
    {
        _claimedBtcAddrCount = v >> (SATOSHI_UINT_SIZE * 2);
        _claimedSatoshisTotal = (v >> SATOSHI_UINT_SIZE) & SATOSHI_UINT_MASK;
        _unclaimedSatoshisTotal = v & SATOSHI_UINT_MASK;

        return (
            _claimedBtcAddrCount,
            _claimedSatoshisTotal,
            _unclaimedSatoshisTotal
        );
    }

    /**
     * @dev Estimate the stake payout for an incomplete day
     * @param g Cache of stored globals
     * @param stakeSharesParam Param from stake to calculate bonuses for
     * @param day Day to calculate bonuses for
     * Payout in Franks
     */
    function _estimatePayoutRewardsDay(
        GlobalsCache memory g,
        uint256 stakeSharesParam,
        uint256 day
    ) internal view returns (uint256 payout) {
        /* Prevent updating state for this estimation */
        GlobalsCache memory gTmp;
        _globalsCacheSnapshot(g, gTmp);

        DailyRoundState memory rs;
        rs._allocSupplyCached = totalSupply() + g._lockedFranksTotal;

        _dailyRoundCalc(gTmp, rs, day);

        /* Stake is no longer locked so it must be added to total as if it were */
        gTmp._stakeSharesTotal += stakeSharesParam;

        payout = (rs._payoutTotal * stakeSharesParam) / gTmp._stakeSharesTotal;

        if (day == BIG_PAY_DAY) {
            uint256 bigPaySlice = (gTmp._unclaimedSatoshisTotal *
                FRANKS_PER_SATOSHI *
                stakeSharesParam) / gTmp._stakeSharesTotal;
            payout += bigPaySlice + _calcAdoptionBonus(gTmp, bigPaySlice);
        }

        return payout;
    }

    function _calcAdoptionBonus(GlobalsCache memory g, uint256 payout)
        internal
        pure
        returns (uint256)
    {
        /*
            VIRAL REWARDS: Add adoption percentage bonus to payout

            viral = payout * (claimedBtcAddrCount / CLAIMABLE_BTC_ADDR_COUNT)
        */
        // uint256 viral = payout * g._claimedBtcAddrCount / CLAIMABLE_BTC_ADDR_COUNT;

        /*
            CRIT MASS REWARDS: Add adoption percentage bonus to payout

            crit  = payout * (claimedSatoshisTotal / CLAIMABLE_SATOSHIS_TOTAL)
        */
        // uint256 crit = payout * g._claimedSatoshisTotal / CLAIMABLE_SATOSHIS_TOTAL;

        return
            ((payout * g._claimedBtcAddrCount) / CLAIMABLE_BTC_ADDR_COUNT) +
            ((payout * g._claimedSatoshisTotal) / CLAIMABLE_SATOSHIS_TOTAL);
    }

    function _dailyRoundCalc(
        GlobalsCache memory g,
        DailyRoundState memory rs,
        uint256 day
    ) private pure {
        /*
            Calculate payout round

            Inflation of 3.69% inflation per 364 days             (approx 1 year)
            dailyInterestRate   = exp(log(1 + 3.69%)  / 364) - 1
                                = exp(log(1 + 0.0369) / 364) - 1
                                = exp(log(1.0369) / 364) - 1
                                = 0.000099553011616349            (approx)

            payout  = allocSupply * dailyInterestRate
                    = allocSupply / (1 / dailyInterestRate)
                    = allocSupply / (1 / 0.000099553011616349)
                    = allocSupply / 10044.899534066692            (approx)
                    = allocSupply * 10000 / 100448995             (* 10000/10000 for int precision)
        */
        rs._payoutTotal = (rs._allocSupplyCached * 10000) / 100448995;

        if (day < CLAIM_PHASE_END_DAY) {
            uint256 bigPaySlice = (g._unclaimedSatoshisTotal *
                FRANKS_PER_SATOSHI) / CLAIM_PHASE_DAYS;

            uint256 originBonus = bigPaySlice +
                _calcAdoptionBonus(g, rs._payoutTotal + bigPaySlice);
            rs._mintOriginBatch += originBonus;
            rs._allocSupplyCached += originBonus;

            rs._payoutTotal += _calcAdoptionBonus(g, rs._payoutTotal);
        }

        if (g._stakePenaltyTotal != 0) {
            rs._payoutTotal += g._stakePenaltyTotal;
            g._stakePenaltyTotal = 0;
        }
    }

    function _dailyRoundCalcAndStore(
        GlobalsCache memory g,
        DailyRoundState memory rs,
        uint256 day
    ) private {
        _dailyRoundCalc(g, rs, day);

        dailyData[day].dayPayoutTotal = uint72(rs._payoutTotal);
        dailyData[day].dayStakeSharesTotal = uint72(g._stakeSharesTotal);
        dailyData[day].dayUnclaimedSatoshisTotal = uint56(
            g._unclaimedSatoshisTotal
        );
    }

    function _dailyDataUpdate(
        GlobalsCache memory g,
        uint256 beforeDay,
        bool isAutoUpdate
    ) private {
        if (g._dailyDataCount >= beforeDay) {
            /* Already up-to-date */
            return;
        }

        DailyRoundState memory rs;
        rs._allocSupplyCached = totalSupply() + g._lockedFranksTotal;

        uint256 day = g._dailyDataCount;

        _dailyRoundCalcAndStore(g, rs, day);

        /* Stakes started during this day are added to the total the next day */
        if (g._nextStakeSharesTotal != 0) {
            g._stakeSharesTotal += g._nextStakeSharesTotal;
            g._nextStakeSharesTotal = 0;
        }

        while (++day < beforeDay) {
            _dailyRoundCalcAndStore(g, rs, day);
        }

        _emitDailyDataUpdate(g._dailyDataCount, day, isAutoUpdate);
        g._dailyDataCount = day;

        if (rs._mintOriginBatch != 0) {
            _mint(ORIGIN_ADDR, rs._mintOriginBatch);
        }
    }

    function _emitDailyDataUpdate(
        uint256 beginDay,
        uint256 endDay,
        bool isAutoUpdate
    ) private {
        emit DailyDataUpdate( // (auto-generated event)
            uint256(uint40(block.timestamp)) |
                (uint256(uint16(beginDay)) << 40) |
                (uint256(uint16(endDay)) << 56) |
                (isAutoUpdate ? (1 << 72) : 0),
            msg.sender
        );
    }
}

contract StakeableToken is GlobalsAndUtility {
    /**
     * @dev PUBLIC FACING: Open a stake.
     * @param newStakedFranks Number of Franks to stake
     * @param newStakedDays Number of days to stake
     */
    function stakeStart(
        uint256 newStakedFranks,
        uint256 newStakedDays,
        string memory newStakeName
    ) external {
        GlobalsCache memory g;
        GlobalsCache memory gSnapshot;
        _globalsLoad(g, gSnapshot);

        /* Enforce the minimum stake time */
        require(newStakedDays >= MIN_STAKE_DAYS, "less than min days");

        /* Check if log data needs to be updated */
        _dailyDataUpdateAuto(g);

        _stakeStart(g, newStakedFranks, newStakedDays, newStakeName, false);

        /* Remove staked Franks from balance of staker */
        _burn(msg.sender, newStakedFranks);

        _globalsSync(g, gSnapshot);
    }

    /**
     * @dev PUBLIC FACING: Unlocks a completed stake, distributing the proceeds of any penalty
     * immediately. The staker must still call stakeEnd() to retrieve their stake return (if any).
     * @param stakerAddr Address of staker
     * @param stakeIndex Index of stake within stake list
     * @param stakeIdParam The stake's id
     */
    function stakeGoodAccounting(
        address stakerAddr,
        uint256 stakeIndex,
        uint40 stakeIdParam
    ) external {
        GlobalsCache memory g;
        GlobalsCache memory gSnapshot;
        _globalsLoad(g, gSnapshot);

        /* require() is more informative than the default assert() */
        require(stakeLists[stakerAddr].length != 0, "No record");
        require(stakeIndex < stakeLists[stakerAddr].length, "invalid index");

        StakeStore storage stRef = stakeLists[stakerAddr][stakeIndex];

        /* Get stake copy */
        StakeCache memory st;
        _stakeLoad(stRef, stakeIdParam, st);

        /* Stake must have served full term */
        require(
            g._currentDay >= st._lockedDay + st._stakedDays,
            "not fully served"
        );

        /* Stake must still be locked */
        require(st._unlockedDay == 0, "already unlocked");

        /* Check if log data needs to be updated */
        _dailyDataUpdateAuto(g);

        /* Unlock the completed stake */
        _stakeUnlock(g, st);

        /* stakeReturn value is unused here */
        (
            ,
            uint256 payout,
            uint256 penalty,
            uint256 cappedPenalty
        ) = _stakePerformance(g, st, st._stakedDays);

        emit StakeGoodAccounting( // (auto-generated event)
            uint256(uint40(block.timestamp)) |
                (uint256(uint72(st._stakedFranks)) << 40) |
                (uint256(uint72(st._stakeShares)) << 112) |
                (uint256(uint72(payout)) << 184),
            uint256(uint72(penalty)),
            stakerAddr,
            stakeIdParam,
            msg.sender
        );

        // _emitStakeGoodAccounting(
        //     stakerAddr,
        //     stakeIdParam,
        //     st._stakedFranks,
        //     st._stakeShares,
        //     payout,
        //     penalty
        // );

        if (cappedPenalty != 0) {
            _splitPenaltyProceeds(g, cappedPenalty);
        }

        /* st._unlockedDay has changed */
        _stakeUpdate(stRef, st);

        _globalsSync(g, gSnapshot);
    }

    /**
     * @dev PUBLIC FACING: Closes a stake. The order of the stake list can change so
     * a stake id is used to reject stale indexes.
     * @param stakeIndex Index of stake within stake list
     * @param stakeIdParam The stake's id
     */
    function stakeEnd(uint256 stakeIndex, uint40 stakeIdParam) external {
        GlobalsCache memory g;
        GlobalsCache memory gSnapshot;
        _globalsLoad(g, gSnapshot);

        StakeStore[] storage stakeListRef = stakeLists[msg.sender];

        /* require() is more informative than the default assert() */
        require(stakeListRef.length != 0, "No record");
        require(stakeIndex < stakeListRef.length, "invalid index");

        /* Get stake copy */
        StakeCache memory st;
        _stakeLoad(stakeListRef[stakeIndex], stakeIdParam, st);

        /* Check if log data needs to be updated */
        _dailyDataUpdateAuto(g);

        uint256 servedDays = 0;

        bool prevUnlocked = (st._unlockedDay != 0);
        uint256 stakeReturn;
        uint256 payout = 0;
        uint256 penalty = 0;
        uint256 cappedPenalty = 0;

        if (g._currentDay >= st._lockedDay) {
            if (prevUnlocked) {
                /* Previously unlocked in stakeGoodAccounting(), so must have served full term */
                servedDays = st._stakedDays;
            } else {
                _stakeUnlock(g, st);

                servedDays = g._currentDay - st._lockedDay;
                if (servedDays > st._stakedDays) {
                    servedDays = st._stakedDays;
                } else {
                    /* Deny early-unstake before an auto-stake minimum has been served */
                    if (servedDays < MIN_AUTO_STAKE_DAYS) {
                        require(!st._isAutoStake, "still locked");
                    }
                }
            }

            (stakeReturn, payout, penalty, cappedPenalty) = _stakePerformance(
                g,
                st,
                servedDays
            );
        } else {
            /* Deny early-unstake before an auto-stake minimum has been served */
            require(!st._isAutoStake, "still locked");

            /* Stake hasn't been added to the total yet, so no penalties or rewards apply */
            g._nextStakeSharesTotal -= st._stakeShares;

            stakeReturn = st._stakedFranks;
        }

        emit StakeEnd( // (auto-generated event)
            uint256(uint40(block.timestamp)) |
                (uint256(uint72(st._stakedFranks)) << 40) |
                (uint256(uint72(st._stakeShares)) << 112) |
                (uint256(uint72(payout)) << 184),
            uint256(uint72(penalty)) |
                (uint256(uint16(servedDays)) << 72) |
                (prevUnlocked ? (1 << 88) : 0),
            msg.sender,
            stakeIdParam,
            stakeReturn
        );

        // _emitStakeEnd(
        //     stakeIdParam,
        //     st._stakedFranks,
        //     st._stakeShares,
        //     payout,
        //     penalty,
        //     servedDays,
        //     prevUnlocked
        // );

        if (cappedPenalty != 0 && !prevUnlocked) {
            /* Split penalty proceeds only if not previously unlocked by stakeGoodAccounting() */
            _splitPenaltyProceeds(g, cappedPenalty);
        }

        /* Pay the stake return, if any, to the staker */
        if (stakeReturn != 0) {
            _mint(msg.sender, stakeReturn);

            /* Update the share rate if necessary */
            _shareRateUpdate(g, st, stakeReturn);
        }
        g._lockedFranksTotal -= st._stakedFranks;

        _stakeRemove(stakeListRef, stakeIndex);

        _globalsSync(g, gSnapshot);
    }

    function stakeTransfer(uint256 stakeIndex, address transferToAddress)
        external
    {
        // GlobalsCache memory g;
        // GlobalsCache memory gSnapshot;
        // _globalsLoad(g, gSnapshot);

        StakeStore[] storage stakeListRef = stakeLists[msg.sender];
        StakeStore storage stRef = stakeLists[msg.sender][stakeIndex];
        /* require() is more informative than the default assert() */
        require(stakeListRef.length != 0, "No Record");
        require(stakeIndex < stakeListRef.length, "invalid index");
        require(stRef.unlockedDay == 0, "Stake Completed");
        /* Check if log data needs to be updated */
        // _dailyDataUpdateAuto(g);
        _stakeAdd(
            stakeLists[transferToAddress],
            stRef.stakeId,
            stRef.stakedFranks,
            stRef.stakeShares,
            stRef.lockedDay,
            stRef.stakedDays,
            // stRef.unlockedDay,
            stRef.isAutoStake,
            stRef.newStakeName
        );
        // stakeLists[transferToAddress].push(
        //     StakeStore(
        //     stRef.stakeId,
        //     stRef.stakedFranks,
        //     stRef.stakeShares ,
        //     stRef.lockedDay ,
        //     stRef.stakedDays,
        //     stRef.unlockedDay,
        //     stRef.isAutoStake,
        //     stRef.newStakeName
        //     )
        // );
        // _globalsSync(g, gSnapshot);
        _stakeRemove(stakeListRef, stakeIndex);
    }

    /**
     * @dev PUBLIC FACING: Return the current stake count for a staker address
     * @param stakerAddr Address of staker
      No Use Currently
     */
    function stakeCount(address stakerAddr) external view returns (uint256) {
        return stakeLists[stakerAddr].length;
    }

    /**
     * @dev Open a stake.
     * @param g Cache of stored globals
     * @param newStakedFranks Number of Franks to stake
     * @param newStakedDays Number of days to stake
     * @param newAutoStake Stake is automatic directly from a new claim
     */
    function _stakeStart(
        GlobalsCache memory g,
        uint256 newStakedFranks,
        uint256 newStakedDays,
        string memory newStakeName,
        bool newAutoStake
    ) internal {
        /* Enforce the maximum stake time */
        require(newStakedDays <= MAX_STAKE_DAYS, "Higher than maximum days");

        // uint256 bonusFranks = _stakeStartBonusFranks(newStakedFranks, newStakedDays);
        uint256 newStakeShares = ((newStakedFranks +
            (_stakeStartBonusFranks(newStakedFranks, newStakedDays))) *
            SHARE_RATE_SCALE) / g._shareRate;

        /* Ensure newStakedFranks is enough for at least one stake share */
        require(newStakeShares != 0, "Not Enough Shares");

        /*
            The stakeStart timestamp will always be part-way through the current
            day, so it needs to be rounded-up to the next day to ensure all
            stakes align with the same fixed calendar days. The current day is
            already rounded-down, so rounded-up is current day + 1.
        */
        uint256 newLockedDay = g._currentDay < CLAIM_PHASE_START_DAY
            ? CLAIM_PHASE_START_DAY + 1
            : g._currentDay + 1;

        /* Create Stake */
        uint40 newStakeId = ++g._latestStakeId;
        _stakeAdd(
            stakeLists[msg.sender],
            newStakeId,
            newStakedFranks,
            newStakeShares,
            newLockedDay,
            newStakedDays,
            newAutoStake,
            newStakeName
        );

        // _emitStakeStart(newStakeId, newStakedFranks, newStakeShares, newStakedDays, newAutoStake);
        emit StakeStart( // (auto-generated event)
            uint256(uint40(block.timestamp)) |
                (uint256(uint72(newStakedFranks)) << 40) |
                (uint256(uint72(newStakeShares)) << 112) |
                (uint256(uint16(newStakedDays)) << 184) |
                (newAutoStake ? (1 << 200) : 0),
            msg.sender,
            newStakeId
        );

        /* Stake is added to total in the next round, not the current round */
        g._nextStakeSharesTotal += newStakeShares;

        /* Track total staked Franks for inflation calculations */
        g._lockedFranksTotal += newStakedFranks;
    }

    /**
     * @dev Calculates total stake payout including rewards for a multi-day range
     * @param g Cache of stored globals
     * @param stakeSharesParam Param from stake to calculate bonuses for
     * @param beginDay First day to calculate bonuses for
     * @param endDay Last day (non-inclusive) of range to calculate bonuses for
     *  Payout in Franks
     */
    function _calcPayoutRewards(
        GlobalsCache memory g,
        uint256 stakeSharesParam,
        uint256 beginDay,
        uint256 endDay
    ) private view returns (uint256 payout) {
        for (uint256 day = beginDay; day < endDay; day++) {
            payout +=
                (dailyData[day].dayPayoutTotal * stakeSharesParam) /
                dailyData[day].dayStakeSharesTotal;
        }

        /* Less expensive to re-read storage than to have the condition inside the loop */
        if (beginDay <= BIG_PAY_DAY && endDay > BIG_PAY_DAY) {
            uint256 bigPaySlice = (g._unclaimedSatoshisTotal *
                FRANKS_PER_SATOSHI *
                stakeSharesParam) / dailyData[BIG_PAY_DAY].dayStakeSharesTotal;

            payout += bigPaySlice + _calcAdoptionBonus(g, bigPaySlice);
        }
        return payout;
    }

    /**
     * @dev Calculate bonus Franks for a new stake, if any
     * @param newStakedFranks Number of Franks to stake
     * @param newStakedDays Number of days to stake
     */
    function _stakeStartBonusFranks(
        uint256 newStakedFranks,
        uint256 newStakedDays
    ) private pure returns (uint256 bonusFranks) {
        /*
            LONGER PAYS BETTER:

            If longer than 1 day stake is committed to, each extra day
            gives bonus shares of approximately 0.0548%, which is approximately 20%
            extra per year of increased stake length committed to, but capped to a
            maximum of 200% extra.

            extraDays       =  stakedDays - 1

            longerBonus%    = (extraDays / 364) * 20%
                            = (extraDays / 364) / 5
                            =  extraDays / 1820
                            =  extraDays / LPB

            extraDays       =  longerBonus% * 1820
            extraDaysMax    =  longerBonusMax% * 1820
                            =  200% * 1820
                            =  3640
                            =  LPB_MAX_DAYS

            BIGGER PAYS BETTER:

            Bonus percentage scaled 0% to 10% for the first 150M MYNT of stake.

            biggerBonus%    = (cappedFranks /  BPB_MAX_FRANKS) * 10%
                            = (cappedFranks /  BPB_MAX_FRANKS) / 10
                            =  cappedFranks / (BPB_MAX_FRANKS * 10)
                            =  cappedFranks /  BPB

            COMBINED:

            combinedBonus%  =            longerBonus%  +  biggerBonus%

                                      cappedExtraDays     cappedFranks
                            =         ---------------  +  ------------
                                            LPB               BPB

                                cappedExtraDays * BPB     cappedFranks * LPB
                            =   ---------------------  +  ------------------
                                      LPB * BPB               LPB * BPB

                                cappedExtraDays * BPB  +  cappedFranks * LPB
                            =   --------------------------------------------
                                                  LPB  *  BPB

            bonusFranks     = franks * combinedBonus%
                            = franks * (cappedExtraDays * BPB  +  cappedFranks * LPB) / (LPB * BPB)
        */
        uint256 cappedExtraDays = 0;

        /* Must be more than 1 day for Longer-Pays-Better */
        if (newStakedDays > 1) {
            cappedExtraDays = newStakedDays <= LPB_MAX_DAYS
                ? newStakedDays - 1
                : LPB_MAX_DAYS;
        }

        uint256 cappedStakedFranks = newStakedFranks <= BPB_MAX_FRANKS
            ? newStakedFranks
            : BPB_MAX_FRANKS;

        bonusFranks = cappedExtraDays * BPB + cappedStakedFranks * LPB;
        bonusFranks = (newStakedFranks * bonusFranks) / (LPB * BPB);

        return bonusFranks;
    }

    function _stakeUnlock(GlobalsCache memory g, StakeCache memory st)
        private
        pure
    {
        g._stakeSharesTotal -= st._stakeShares;
        st._unlockedDay = g._currentDay;
    }

    function _stakePerformance(
        GlobalsCache memory g,
        StakeCache memory st,
        uint256 servedDays
    )
        private
        view
        returns (
            uint256 stakeReturn,
            uint256 payout,
            uint256 penalty,
            uint256 cappedPenalty
        )
    {
        if (servedDays < st._stakedDays) {
            (payout, penalty) = _calcPayoutAndEarlyPenalty(
                g,
                st._lockedDay,
                st._stakedDays,
                servedDays,
                st._stakeShares
            );
            stakeReturn = st._stakedFranks + payout;
        } else {
            // servedDays must == stakedDays here
            payout = _calcPayoutRewards(
                g,
                st._stakeShares,
                st._lockedDay,
                st._lockedDay + servedDays
            );
            stakeReturn = st._stakedFranks + payout;

            penalty = _calcLatePenalty(
                st._lockedDay,
                st._stakedDays,
                st._unlockedDay,
                stakeReturn
            );
        }
        if (penalty != 0) {
            if (penalty > stakeReturn) {
                /* Cannot have a negative stake return */
                cappedPenalty = stakeReturn;
                stakeReturn = 0;
            } else {
                /* Remove penalty from the stake return */
                cappedPenalty = penalty;
                stakeReturn -= cappedPenalty;
            }
        }
        return (stakeReturn, payout, penalty, cappedPenalty);
    }

    function _calcPayoutAndEarlyPenalty(
        GlobalsCache memory g,
        uint256 lockedDayParam,
        uint256 stakedDaysParam,
        uint256 servedDays,
        uint256 stakeSharesParam
    ) private view returns (uint256 payout, uint256 penalty) {
        uint256 servedEndDay = lockedDayParam + servedDays;

        /* 50% of stakedDays (rounded up) with a minimum applied */
        uint256 penaltyDays = (stakedDaysParam + 1) / 2;
        if (penaltyDays < EARLY_PENALTY_MIN_DAYS) {
            penaltyDays = EARLY_PENALTY_MIN_DAYS;
        }

        if (servedDays == 0) {
            /* Fill penalty days with the estimated average payout */
            uint256 expected = _estimatePayoutRewardsDay(
                g,
                stakeSharesParam,
                lockedDayParam
            );
            penalty = expected * penaltyDays;
            return (payout, penalty); // Actual payout was 0
        }

        if (penaltyDays < servedDays) {
            /*
                Simplified explanation of intervals where end-day is non-inclusive:

                penalty:    [lockedDay  ...  penaltyEndDay)
                delta:                      [penaltyEndDay  ...  servedEndDay)
                payout:     [lockedDay  .......................  servedEndDay)
            */
            uint256 penaltyEndDay = lockedDayParam + penaltyDays;
            penalty = _calcPayoutRewards(
                g,
                stakeSharesParam,
                lockedDayParam,
                penaltyEndDay
            );

            uint256 delta = _calcPayoutRewards(
                g,
                stakeSharesParam,
                penaltyEndDay,
                servedEndDay
            );
            payout = penalty + delta;
            return (payout, penalty);
        }

        /* penaltyDays >= servedDays  */
        payout = _calcPayoutRewards(
            g,
            stakeSharesParam,
            lockedDayParam,
            servedEndDay
        );

        if (penaltyDays == servedDays) {
            penalty = payout;
        } else {
            /*
                (penaltyDays > servedDays) means not enough days served, so fill the
                penalty days with the average payout from only the days that were served.
            */
            penalty = (payout * penaltyDays) / servedDays;
        }
        return (payout, penalty);
    }

    function _calcLatePenalty(
        uint256 lockedDayParam,
        uint256 stakedDaysParam,
        uint256 unlockedDayParam,
        uint256 rawStakeReturn
    ) private pure returns (uint256) {
        /* Allow grace time before penalties accrue */
        uint256 maxUnlockedDay = lockedDayParam +
            stakedDaysParam +
            LATE_PENALTY_GRACE_DAYS;
        if (unlockedDayParam <= maxUnlockedDay) {
            return 0;
        }

        /* Calculate penalty as a percentage of stake return based on time */
        return
            (rawStakeReturn * (unlockedDayParam - maxUnlockedDay)) /
            LATE_PENALTY_SCALE_DAYS;
    }

    function _splitPenaltyProceeds(GlobalsCache memory g, uint256 penalty)
        private
    {
        /* Split a penalty 50:50 between Origin and stakePenaltyTotal */
        uint256 splitPenalty = penalty / 2;

        if (splitPenalty != 0) {
            _mint(ORIGIN_ADDR, splitPenalty);
        }

        /* Use the other half of the penalty to account for an odd-numbered penalty */
        splitPenalty = penalty - splitPenalty;
        g._stakePenaltyTotal += splitPenalty;
    }

    function _shareRateUpdate(
        GlobalsCache memory g,
        StakeCache memory st,
        uint256 stakeReturn
    ) private {
        if (stakeReturn > st._stakedFranks) {
            /*
                Calculate the new shareRate that would yield the same number of shares if
                the user re-staked this stakeReturn, factoring in any bonuses they would
                receive in stakeStart().
            */
            // uint256 bonusFranks = _stakeStartBonusFranks(stakeReturn, st._stakedDays);
            uint256 newShareRate = ((stakeReturn +
                (_stakeStartBonusFranks(stakeReturn, st._stakedDays))) *
                SHARE_RATE_SCALE) / st._stakeShares;

            if (newShareRate > SHARE_RATE_MAX) {
                /*
                    Realistically this can't happen, but there are contrived theoretical
                    scenarios that can lead to extreme values of newShareRate, so it is
                    capped to prevent them anyway.
                */
                newShareRate = SHARE_RATE_MAX;
            }

            if (newShareRate > g._shareRate) {
                g._shareRate = newShareRate;

                _emitShareRateChange(newShareRate, st._stakeId);
            }
        }
    }

    // function _emitStakeStart(
    //     uint40 stakeId,
    //     uint256 stakedFranks,
    //     uint256 stakeShares,
    //     uint256 stakedDays,
    //     bool isAutoStake
    // )
    //     private
    // {
    //     emit StakeStart( // (auto-generated event)
    //         uint256(uint40(block.timestamp))
    //             | (uint256(uint72(stakedFranks)) << 40)
    //             | (uint256(uint72(stakeShares)) << 112)
    //             | (uint256(uint16(stakedDays)) << 184)
    //             | (isAutoStake ? (1 << 200) : 0),
    //         msg.sender,
    //         stakeId
    //     );
    // }

    // function _emitStakeGoodAccounting(
    //     address stakerAddr,
    //     uint40 stakeId,
    //     uint256 stakedFranks,
    //     uint256 stakeShares,
    //     uint256 payout,
    //     uint256 penalty
    // )
    //     private
    // {
    //     emit StakeGoodAccounting( // (auto-generated event)
    //         uint256(uint40(block.timestamp))
    //             | (uint256(uint72(stakedFranks)) << 40)
    //             | (uint256(uint72(stakeShares)) << 112)
    //             | (uint256(uint72(payout)) << 184),
    //         uint256(uint72(penalty)),
    //         stakerAddr,
    //         stakeId,
    //         msg.sender
    //     );
    // }

    // function _emitStakeEnd(
    //     uint40 stakeId,
    //     uint256 stakedFranks,
    //     uint256 stakeShares,
    //     uint256 payout,
    //     uint256 penalty,
    //     uint256 servedDays,
    //     bool prevUnlocked
    // )
    //     private
    // {
    //     emit StakeEnd( // (auto-generated event)
    //         uint256(uint40(block.timestamp))
    //             | (uint256(uint72(stakedFranks)) << 40)
    //             | (uint256(uint72(stakeShares)) << 112)
    //             | (uint256(uint72(payout)) << 184),
    //         uint256(uint72(penalty))
    //             | (uint256(uint16(servedDays)) << 72)
    //             | (prevUnlocked ? (1 << 88) : 0),
    //         msg.sender,
    //         stakeId
    //     );
    // }

    function _emitShareRateChange(uint256 shareRate, uint40 stakeId) private {
        emit ShareRateChange( // (auto-generated event)
            uint256(uint40(block.timestamp)) |
                (uint256(uint40(shareRate)) << 40),
            stakeId,
            shareRate
        );
    }
}

contract SignatureVerification is StakeableToken {
    function claimMessageMatchesSignature(
        address _to,
        uint256 _amount,
        Signature memory signature,
        uint256 _nounce
    ) public pure returns (address) {
        string memory header = "\x19Ethereum Signed Message:\n84";

        // Perform the elliptic curve recover operation
        bytes32 messageHash = keccak256(
            abi.encodePacked(header, _to, _amount, _nounce)
        );
        return ecrecover(messageHash, signature.v, signature.r, signature.s);
    }

    function sigAddress(
        bytes32 messageHash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public pure returns (address) {
        require(v >= 27 && v <= 30, "v invalid");
        return ecrecover(messageHash, v, r, s);
    }

    // function pubKeyToEthAddress(bytes32 pubKeyX, bytes32 pubKeyY)
    //     public
    //     pure
    //     returns (address)
    // {
    //     return
    //         address(
    //             uint160(uint256(keccak256(abi.encodePacked(pubKeyX, pubKeyY))))
    //         );
    // }

    function pubKeyToBtcAddress(
        bytes32 pubKeyX,
        bytes32 pubKeyY,
        uint8 claimFlags
    ) public pure returns (bytes20) {
        /*
            Helpful references:
             - https://en.bitcoin.it/wiki/Technical_background_of_version_1_Bitcoin_addresses
             - https://github.com/cryptocoinjs/ecurve/blob/master/lib/point.js
        */
        uint8 startingByte;
        bytes memory pubKey;
        bool compressed = (claimFlags & CLAIM_FLAG_BTC_ADDR_COMPRESSED) != 0;
        bool nested = (claimFlags & CLAIM_FLAG_BTC_ADDR_P2WPKH_IN_P2SH) != 0;
        bool bech32 = (claimFlags & CLAIM_FLAG_BTC_ADDR_BECH32) != 0;

        if (compressed) {
            require(!(nested && bech32), "HEX: claimFlags invalid");

            startingByte = (pubKeyY[31] & 0x01) == 0 ? 0x02 : 0x03;
            // startingByte = 0x03;
            pubKey = abi.encodePacked(startingByte, pubKeyX);
        } else {
            require(!nested && !bech32, "HEX: claimFlags invalid");

            startingByte = 0x04;
            pubKey = abi.encodePacked(startingByte, pubKeyX, pubKeyY);
        }

        bytes20 pubKeyHash = _hash160(pubKey);
        if (nested) {
            return _hash160(abi.encodePacked(hex"0014", pubKeyHash));
        }
        return pubKeyHash;
    }

    /**
     * @dev ripemd160(sha256(data))
     * @param data Data to be hashed
     * @return 20-byte hash
     */
    function _hash160(bytes memory data) private pure returns (bytes20) {
        return ripemd160(abi.encodePacked(sha256(data)));
    }

    /**
     * @dev Verify a BTC address and balance are part of the Merkle tree
     * @param btcAddr Bitcoin address (binary; no base58-check encoding)
     * @param rawSatoshis Raw BTC address balance in Satoshis
     * @param proof Merkle tree proof
     * @return True if valid
     */
    function _btcAddressIsValid(
        bytes20 btcAddr,
        uint256 rawSatoshis,
        bytes32[] memory proof
    ) internal pure returns (bool) {
        // bytes32 merkleLeaf = keccak256(abi.encodePacked(btcAddr, rawSatoshis));

        return
            _merkleProofIsValid(
                keccak256(abi.encodePacked(btcAddr, rawSatoshis)),
                proof
            );
    }

    /**
     * @dev Verify a Merkle proof using the UTXO Merkle tree
     * @param merkleLeaf Leaf asserted to be present in the Merkle tree
     * @param proof Generated Merkle tree proof
     * @return True if valid
     */
    function _merkleProofIsValid(bytes32 merkleLeaf, bytes32[] memory proof)
        private
        pure
        returns (bool)
    {
        return MerkleProof.verify(proof, MERKLE_TREE_ROOT, merkleLeaf);
    }
}

contract UTXORedeemableToken is SignatureVerification {
    /**
     * @dev PUBLIC FACING: Claim a BTC address and its Satoshi balance in Franks
     * crediting the appropriate amount to a specified Eth address. Bitcoin ECDSA
     * signature must be from that BTC address and must match the claim message
     * for the Eth address.
     * @param rawSatoshis Raw BTC address balance in Satoshis
     * @param proof Merkle tree proof
     * @param pubKeyX First  half of uncompressed ECDSA public key for the BTC address
     * @param pubKeyY Second half of uncompressed ECDSA public key for the BTC address
     * @param autoStakeDays Number of days to auto-stake, subject to minimum auto-stake days
     * @param referrerAddr Eth address of referring user (optional; 0x0 for no referrer)
     * @return Total number of Franks credited, if successful
     */
    function btcAddressClaim(
        uint256 rawSatoshis,
        bytes32[] calldata proof,
        bytes32 pubKeyX,
        bytes32 pubKeyY,
        Signature calldata signature,
        uint256 autoStakeDays,
        address referrerAddr,
        uint256 nounce,
        uint8 claimFlags
    ) external returns (uint256) {
        /* Sanity check */
        require(
            rawSatoshis <= MAX_BTC_ADDR_BALANCE_SATOSHIS,
            "CHK: rawSatoshis"
        );

        /* Enforce the minimum stake time for the auto-stake from this claim */
        require(
            autoStakeDays >= MIN_AUTO_STAKE_DAYS,
            "autoStakeDays lower than min"
        );

        /* Ensure signature matches the claim message containing the Eth address and claimParamHash */
        {
            bytes32 sigHash = keccak256(
                abi.encodePacked(nounce, signature.v, signature.r, signature.s)
            );
            require(!executed[sigHash], "Signature expired");
            executed[sigHash] = true;
            bool signaturesChecked = false;

            if (
                claimMessageMatchesSignature(
                    msg.sender,
                    rawSatoshis,
                    signature,
                    nounce
                ) == owner
            ) {
                signaturesChecked = true;
            }
            require(signaturesChecked, "Access restricted");
        }
        /* Derive BTC address from public key */
        bytes20 btcAddr = pubKeyToBtcAddress(pubKeyX, pubKeyY, claimFlags);

        /* Ensure BTC address has not yet been claimed */
        require(!btcAddressClaims[btcAddr], "already claimed");

        // /* Ensure BTC address is part of the Merkle tree */
        require(
            _btcAddressIsValid(btcAddr, rawSatoshis, proof),
            "address or balance unknown"
        );

        /* Mark BTC address as claimed */
        btcAddressClaims[btcAddr] = true;

        return
            _satoshisClaimSync(
                rawSatoshis,
                msg.sender,
                btcAddr,
                autoStakeDays,
                referrerAddr
            );
    }

    function _satoshisClaimSync(
        uint256 rawSatoshis,
        address claimToAddr,
        bytes20 btcAddr,
        uint256 autoStakeDays,
        address referrerAddr
    ) private returns (uint256 totalClaimedFranks) {
        GlobalsCache memory g;
        GlobalsCache memory gSnapshot;
        _globalsLoad(g, gSnapshot);

        totalClaimedFranks = _satoshisClaim(
            g,
            rawSatoshis,
            claimToAddr,
            btcAddr,
            // claimFlags,
            autoStakeDays,
            referrerAddr
        );

        _globalsSync(g, gSnapshot);

        return totalClaimedFranks;
    }

    /**
     * @dev Credit an Eth address with the Franks value of a raw Satoshis balance
     * @param g Cache of stored globals
     * @param rawSatoshis Raw BTC address balance in Satoshis
     * @param claimToAddr Destination Eth address for the claimed Franks to be sent
     * @param btcAddr Bitcoin address (binary; no base58-check encoding)
     * @param autoStakeDays Number of days to auto-stake, subject to minimum auto-stake days
     * @param referrerAddr Eth address of referring user (optional; 0x0 for no referrer)
     *  Total number of Franks credited, if successful
     */
    function _satoshisClaim(
        GlobalsCache memory g,
        uint256 rawSatoshis,
        address claimToAddr,
        bytes20 btcAddr,
        uint256 autoStakeDays,
        address referrerAddr
    ) private returns (uint256 totalClaimedFranks) {
        /* Allowed only during the claim phase */
        require(
            g._currentDay >= CLAIM_PHASE_START_DAY,
            "phase not yet started"
        );
        require(g._currentDay < CLAIM_PHASE_END_DAY, "phase ended");

        /* Check if log data needs to be updated */
        _dailyDataUpdateAuto(g);

        /* Sanity check */
        require(
            g._claimedBtcAddrCount < CLAIMABLE_BTC_ADDR_COUNT,
            "CHK: _claimedBtcAddrCount"
        );

        (
            uint256 adjSatoshis,
            uint256 claimedFranks,
            uint256 claimBonusFranks
        ) = _calcClaimValues(g, rawSatoshis);

        /* Increment claim count to track viral rewards */
        g._claimedBtcAddrCount++;

        totalClaimedFranks = _remitBonuses(
            claimToAddr,
            btcAddr,
            rawSatoshis,
            adjSatoshis,
            claimedFranks,
            claimBonusFranks,
            referrerAddr
        );

        /* Auto-stake a percentage of the successful claim */
        uint256 autoStakeFranks = (totalClaimedFranks *
            AUTO_STAKE_CLAIM_PERCENT) / 100;
        _stakeStart(g, autoStakeFranks, autoStakeDays, "", true);

        /* Mint remaining claimed Franks to claim address */
        _mint(claimToAddr, totalClaimedFranks - autoStakeFranks);

        return totalClaimedFranks;
    }

    function _remitBonuses(
        address claimToAddr,
        bytes20 btcAddr,
        uint256 rawSatoshis,
        uint256 adjSatoshis,
        uint256 claimedFranks,
        uint256 claimBonusFranks,
        address referrerAddr
    ) private returns (uint256 totalClaimedFranks) {
        totalClaimedFranks = claimedFranks + claimBonusFranks;

        uint256 originBonusFranks = claimBonusFranks;

        if (referrerAddr == address(0)) {
            /* No referrer */
            _emitClaim(
                claimToAddr,
                btcAddr,
                rawSatoshis,
                adjSatoshis,
                totalClaimedFranks,
                referrerAddr,
                0
            );
        } else {
            /* Referral bonus of 10% of total claimed Franks to claimer */
            uint256 referralBonusFranks = totalClaimedFranks / 10;

            totalClaimedFranks += referralBonusFranks;

            /* Then a cumulative referrer bonus of 20% to referrer */
            uint256 referrerBonusFranks = totalClaimedFranks / 5;

            originBonusFranks += referralBonusFranks + referrerBonusFranks;

            if (referrerAddr == claimToAddr) {
                /* Self-referred */
                totalClaimedFranks += referrerBonusFranks;
                _emitClaim(
                    claimToAddr,
                    btcAddr,
                    rawSatoshis,
                    adjSatoshis,
                    totalClaimedFranks,
                    referrerAddr,
                    referrerBonusFranks
                );
            } else {
                /* Referred by different address */
                _emitClaim(
                    claimToAddr,
                    btcAddr,
                    rawSatoshis,
                    adjSatoshis,
                    totalClaimedFranks,
                    referrerAddr,
                    referrerBonusFranks
                );
                _mint(referrerAddr, referrerBonusFranks);
            }
        }

        _mint(ORIGIN_ADDR, originBonusFranks);

        return totalClaimedFranks;
    }

    function _emitClaim(
        address claimToAddr,
        bytes20 btcAddr,
        uint256 rawSatoshis,
        uint256 adjSatoshis,
        uint256 claimedFranks,
        address referrerAddr,
        uint256 referrerBonusFranks
    ) private {
        emit Claim( // (auto-generated event)
            uint256(uint40(block.timestamp)) |
                (uint256(uint56(rawSatoshis)) << 40) |
                (uint256(uint56(adjSatoshis)) << 96) |
                (uint256(uint72(claimedFranks)) << 160),
            uint256(uint160(msg.sender)),
            btcAddr,
            claimToAddr,
            referrerAddr,
            referrerBonusFranks,
            claimedFranks,
            adjSatoshis,
            rawSatoshis
        );

        if (claimToAddr == msg.sender) {
            return;
        }

        emit ClaimAssist( // (auto-generated event)
            uint256(uint40(block.timestamp)) |
                (uint256(uint160(btcAddr)) << 40) |
                (uint256(uint56(rawSatoshis)) << 200),
            uint256(uint56(adjSatoshis)) |
                (uint256(uint160(claimToAddr)) << 56),
            uint256(uint72(claimedFranks)) |
                (uint256(uint160(referrerAddr)) << 72),
            msg.sender
        );
    }

    function _calcClaimValues(GlobalsCache memory g, uint256 rawSatoshis)
        private
        pure
        returns (
            uint256 adjSatoshis,
            uint256 claimedFranks,
            uint256 claimBonusFranks
        )
    {
        /* Apply Silly Whale reduction */
        adjSatoshis = _adjustSillyWhale(rawSatoshis);
        require(
            g._claimedSatoshisTotal + adjSatoshis <= CLAIMABLE_SATOSHIS_TOTAL,
            "CHK: _claimedSatoshisTotal"
        );
        g._claimedSatoshisTotal += adjSatoshis;

        uint256 daysRemaining = CLAIM_PHASE_END_DAY - g._currentDay;

        /* Apply late-claim reduction */
        adjSatoshis = _adjustLateClaim(adjSatoshis, daysRemaining);
        g._unclaimedSatoshisTotal -= adjSatoshis;

        /* Convert to Franks and calculate speed bonus */
        claimedFranks = adjSatoshis * FRANKS_PER_SATOSHI;
        claimBonusFranks = _calcSpeedBonus(claimedFranks, daysRemaining);

        return (adjSatoshis, claimedFranks, claimBonusFranks);
    }

    /**
     * @dev Apply Silly Whale adjustment
     * @param rawSatoshis Raw BTC address balance in Satoshis
     * @return Adjusted BTC address balance in Satoshis
     */
    function _adjustSillyWhale(uint256 rawSatoshis)
        private
        pure
        returns (uint256)
    {
        if (rawSatoshis < 1000e8) {
            /* For < 1,000 BTC: no penalty */
            return rawSatoshis;
        }
        if (rawSatoshis >= 10000e8) {
            /* For >= 10,000 BTC: penalty is 75%, leaving 25% */
            return rawSatoshis / 4;
        }
        /*
            For 1,000 <= BTC < 10,000: penalty scales linearly from 50% to 75%

            penaltyPercent  = (btc - 1000) / (10000 - 1000) * (75 - 50) + 50
                            = (btc - 1000) / 9000 * 25 + 50
                            = (btc - 1000) / 360 + 50

            appliedPercent  = 100 - penaltyPercent
                            = 100 - ((btc - 1000) / 360 + 50)
                            = 100 - (btc - 1000) / 360 - 50
                            = 50 - (btc - 1000) / 360
                            = (18000 - (btc - 1000)) / 360
                            = (18000 - btc + 1000) / 360
                            = (19000 - btc) / 360

            adjustedBtc     = btc * appliedPercent / 100
                            = btc * ((19000 - btc) / 360) / 100
                            = btc * (19000 - btc) / 36000

            adjustedSat     = 1e8 * adjustedBtc
                            = 1e8 * (btc * (19000 - btc) / 36000)
                            = 1e8 * ((sat / 1e8) * (19000 - (sat / 1e8)) / 36000)
                            = 1e8 * (sat / 1e8) * (19000 - (sat / 1e8)) / 36000
                            = (sat / 1e8) * 1e8 * (19000 - (sat / 1e8)) / 36000
                            = (sat / 1e8) * (19000e8 - sat) / 36000
                            = sat * (19000e8 - sat) / 36000e8
        */
        return (rawSatoshis * (19000e8 - rawSatoshis)) / 36000e8;
    }

    /**
     * @dev Apply late-claim adjustment to scale claim to zero by end of claim phase
     * @param adjSatoshis Adjusted BTC address balance in Satoshis (after Silly Whale)
     * @param daysRemaining Number of reward days remaining in claim phase
     * @return Adjusted BTC address balance in Satoshis (after Silly Whale and Late-Claim)
     */
    function _adjustLateClaim(uint256 adjSatoshis, uint256 daysRemaining)
        private
        pure
        returns (uint256)
    {
        /*
            Only valid from CLAIM_PHASE_DAYS to 1, and only used during that time.

            adjustedSat = sat * (daysRemaining / CLAIM_PHASE_DAYS) * 100%
                        = sat *  daysRemaining / CLAIM_PHASE_DAYS
        */
        return (adjSatoshis * daysRemaining) / CLAIM_PHASE_DAYS;
    }

    /**
     * @dev Calculates speed bonus for claiming earlier in the claim phase
     * @param claimedFranks Franks claimed from adjusted BTC address balance Satoshis
     * @param daysRemaining Number of claim days remaining in claim phase
     * @return Speed bonus in Franks
     */
    function _calcSpeedBonus(uint256 claimedFranks, uint256 daysRemaining)
        private
        pure
        returns (uint256)
    {
        /*
            Only valid from CLAIM_PHASE_DAYS to 1, and only used during that time.
            Speed bonus is 20% ... 0% inclusive.

            bonusFranks = claimedFranks  * ((daysRemaining - 1)  /  (CLAIM_PHASE_DAYS - 1)) * 20%
                        = claimedFranks  * ((daysRemaining - 1)  /  (CLAIM_PHASE_DAYS - 1)) * 20/100
                        = claimedFranks  * ((daysRemaining - 1)  /  (CLAIM_PHASE_DAYS - 1)) / 5
                        = claimedFranks  *  (daysRemaining - 1)  / ((CLAIM_PHASE_DAYS - 1)  * 5)
        */
        return
            (claimedFranks * (daysRemaining - 1)) /
            ((CLAIM_PHASE_DAYS - 1) * 5);
    }
}

contract TransformableToken is UTXORedeemableToken {
    /**
     * @dev PUBLIC FACING: Enter the tranform lobby for the current round
     * @param referrerAddr Eth address of referring user (optional; 0x0 for no referrer)
     */
    function xfLobbyEnter(address referrerAddr) external payable {
        uint256 enterDay = _currentDay();
        require(enterDay < CLAIM_PHASE_END_DAY, "Lobbies ended");

        uint256 rawAmount = msg.value;
        require(rawAmount != 0, "Amount required");

        XfLobbyQueueStore storage qRef = xfLobbyMembers[enterDay][msg.sender];

        uint256 entryIndex = qRef.tailIndex++;

        qRef.entries[entryIndex] = XfLobbyEntryStore(
            uint96(rawAmount),
            referrerAddr
        );

        xfLobby[enterDay] += rawAmount;

        // _emitXfLobbyEnter(enterDay, entryIndex, rawAmount, referrerAddr);
        emit XfLobbyEnter( // (auto-generated event)
            uint256(uint40(block.timestamp)) |
                (uint256(uint96(rawAmount)) << 40),
            msg.sender,
            (enterDay << XF_LOBBY_ENTRY_INDEX_SIZE) | entryIndex,
            referrerAddr
        );
    }

    /**
     * @dev PUBLIC FACING: Leave the transform lobby after the round is complete
     * @param enterDay Day number when the member entered
     */
    function xfLobbyExit(uint256 enterDay) external {
        require(enterDay < _currentDay(), "Round not complete");

        XfLobbyQueueStore storage qRef = xfLobbyMembers[enterDay][msg.sender];

        uint256 headIndex = qRef.headIndex;
        uint256 endIndex = qRef.tailIndex;

        require(headIndex < endIndex, "count invalid");

        // uint256 waasLobby = _waasLobby(enterDay);
        uint256 _xfLobby = xfLobby[enterDay];
        uint256 totalXfAmount = 0;
        uint256 originBonusFranks = 0;

        do {
            uint256 rawAmount = qRef.entries[headIndex].rawAmount;
            address referrerAddr = qRef.entries[headIndex].referrerAddr;

            delete qRef.entries[headIndex];

            uint256 xfAmount = (_waasLobby(enterDay) * rawAmount) / _xfLobby;

            if (referrerAddr == address(0)) {
                /* No referrer */
                _emitXfLobbyExit(
                    enterDay,
                    headIndex,
                    xfAmount,
                    referrerAddr,
                    0
                );
            } else {
                /* Referral bonus of 10% of xfAmount to member */
                uint256 referralBonusFranks = xfAmount / 10;

                xfAmount += referralBonusFranks;

                /* Then a cumulative referrer bonus of 20% to referrer */
                uint256 referrerBonusFranks = xfAmount / 5;

                if (referrerAddr == msg.sender) {
                    /* Self-referred */
                    xfAmount += referrerBonusFranks;
                    _emitXfLobbyExit(
                        enterDay,
                        headIndex,
                        xfAmount,
                        referrerAddr,
                        referrerBonusFranks
                    );
                } else {
                    /* Referred by different address */
                    _emitXfLobbyExit(
                        enterDay,
                        headIndex,
                        xfAmount,
                        referrerAddr,
                        referrerBonusFranks
                    );
                    _mint(referrerAddr, referrerBonusFranks);
                }
                originBonusFranks += referralBonusFranks + referrerBonusFranks;
            }

            totalXfAmount += xfAmount;
        } while (++headIndex < endIndex);

        qRef.headIndex = uint40(headIndex);

        if (originBonusFranks != 0) {
            _mint(ORIGIN_ADDR, originBonusFranks);
        }
        if (totalXfAmount != 0) {
            _mint(msg.sender, totalXfAmount);
        }
    }

    /**
     * @dev PUBLIC FACING: Release any value that has been sent to the contract
     */
    function xfLobbyFlush() external {
        require(address(this).balance != 0, "No value");

        payable(FLUSH_ADDR).transfer(address(this).balance);
    }

    /**
     * @dev PUBLIC FACING: External helper to return multiple values of xfLobby[] with
     * a single call
     * @param beginDay First day of data range
     * @param endDay Last day (non-inclusive) of data range
     * Fixed array of values
     */
    function xfLobbyRange(uint256 beginDay, uint256 endDay)
        external
        view
        returns (uint256[] memory list)
    {
        require(
            beginDay <= endDay &&
                endDay <= CLAIM_PHASE_END_DAY &&
                endDay <= _currentDay(),
            "invalid range"
        );

        //To Get Last Day data (Reason Array Size)
        list = new uint256[]((endDay + 1) - beginDay);

        uint256 src = beginDay;
        uint256 dst = 0;
        do {
            list[dst++] = uint256(xfLobby[src++]);
        } while (src <= endDay);

        return list;
    }

    /**
     * @dev PUBLIC FACING: Return a current lobby member queue entry.
     * Only needed due to limitations of the standard ABI encoder.
     * @param entriesDay 49 bit compound value. Top 9 bits: enterDay, Bottom 40 bits: entryIndex
     *  1: Raw amount that was entered with; 2: Referring Eth addr (optional; 0x0 for no referrer)
     */
    function xfLobbyEntry(uint256 entriesDay)
        external
        view
        returns (XfLobbyEntryStore[] memory entries)
    {
        XfLobbyQueueStore storage qRef = xfLobbyMembers[entriesDay][msg.sender];
        uint256 _tailIndex = qRef.tailIndex;
        uint256 _headIndex = qRef.headIndex;

        require(_headIndex <= _tailIndex, "invalid index");

        entries = new XfLobbyEntryStore[](_tailIndex - _headIndex);

        do {
            entries[_headIndex] = qRef.entries[_headIndex];
        } while (++_headIndex < _tailIndex);

        return entries;
    }

    /**
     * @dev PUBLIC FACING: Return the lobby days that a user is in with a single call
     * @param memberAddr Eth address of the user
     *  Bit vector of lobby day numbers
     */

    function xfLobbyPendingDays(address memberAddr)
        external
        view
        returns (uint256[] memory words)
    {
        uint256 day = _currentDay() + 1;
        if (day > CLAIM_PHASE_END_DAY) {
            day = CLAIM_PHASE_END_DAY;
        }
        words = new uint256[](day);

        while (day > 0) {
            day--;
            if (
                xfLobbyMembers[day][memberAddr].tailIndex >
                xfLobbyMembers[day][memberAddr].headIndex
            ) {
                words[day] = 1;
            }
        }

        return words;
    }

    function _waasLobby(uint256 enterDay) private returns (uint256 waasLobby) {
        if (enterDay >= CLAIM_PHASE_START_DAY) {
            GlobalsCache memory g;
            GlobalsCache memory gSnapshot;
            _globalsLoad(g, gSnapshot);

            _dailyDataUpdateAuto(g);
            //AA Daily Supply
            uint256 unclaimed = dailyData[enterDay].dayUnclaimedSatoshisTotal;
            waasLobby = (unclaimed * FRANKS_PER_SATOSHI) / CLAIM_PHASE_DAYS;
            _globalsSync(g, gSnapshot);
        } else {
            waasLobby = WAAS_LOBBY_SEED_FRANKS;
        }
        return waasLobby;
    }

    // function _emitXfLobbyEnter(
    //     uint256 enterDay,
    //     uint256 entryIndex,
    //     uint256 rawAmount,
    //     address referrerAddr
    // )
    //     private
    // {
    //     emit XfLobbyEnter( // (auto-generated event)
    //         uint256(uint40(block.timestamp))
    //             | (uint256(uint96(rawAmount)) << 40),
    //         msg.sender,
    //         (enterDay << XF_LOBBY_ENTRY_INDEX_SIZE) | entryIndex,
    //         referrerAddr
    //     );
    // }

    function _emitXfLobbyExit(
        uint256 enterDay,
        uint256 entryIndex,
        uint256 xfAmount,
        address referrerAddr,
        uint256 referrerBonusFranks
    ) private {
        emit XfLobbyExit( // (auto-generated event)
            uint256(uint40(block.timestamp)) |
                (uint256(uint72(xfAmount)) << 40),
            msg.sender,
            (enterDay << XF_LOBBY_ENTRY_INDEX_SIZE) | entryIndex,
            referrerAddr,
            referrerBonusFranks
        );
    }
}

contract MYNTIST is TransformableToken {
    constructor() {
        /* Initialize global shareRate to 1 */
        globals.shareRate = uint40(1 * SHARE_RATE_SCALE);

        /* Initialize dailyDataCount to skip pre-claim period */
        globals.dailyDataCount = uint16(PRE_CLAIM_DAYS);

        /* Add all Satoshis from UTXO snapshot to contract */
        globals.claimStats = _claimStatsEncode(
            0, // _claimedBtcAddrCount
            0, // _claimedSatoshisTotal
            FULL_SATOSHIS_TOTAL // _unclaimedSatoshisTotal
        );
    }

    receive() external payable {}
}