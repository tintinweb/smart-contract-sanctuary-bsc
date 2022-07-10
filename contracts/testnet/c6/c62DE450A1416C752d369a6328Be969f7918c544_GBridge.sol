/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.7;

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

interface  INodeValidatorManager {
    
    function verify(bytes32 _submisstionId, uint8 _excessConfirmations, bytes memory _proofs) external;
}

interface IGBridgeToken {

    function mint(address _receiver, uint256 _amount) external; 
    function burnFrom(address _from, uint256 _amount) external;
}  

contract AdminAccess {

    address public admin;
    

    constructor(address _admin) {
        admin = _admin;
    }

    error AdminBadRoleError();

    modifier onlyAdmin {
        if(msg.sender != admin) revert AdminBadRoleError();
        _;
    }
}

contract BridgeAccess {

    address public bridgeAddress;
    

    constructor(address _bridgeAddress) {
        bridgeAddress = _bridgeAddress;
    }

    error BridgeBadRoleError();

    modifier onlyBridge {
        if(msg.sender != bridgeAddress) revert BridgeBadRoleError();
        _;
    }
}

library TransactionsTypes {

    enum TokenType {
        ChainToken,
        ERCToken,
        OtherToken
    }

    enum TransactionType {
        FromZilliqa,
        ToZilliqa
    }

    struct TxTransfer {
        bytes32 submissionId;
        address token;
        address from;
        address to;
        uint256 amount;
        uint grph_fees;
        TokenType tokenType;
        uint256 nonce;
        TransactionType transactionType;
    }

    error TxUsedError();
}  

interface ITransactionsStorage {

    function saveTx(TransactionsTypes.TxTransfer calldata tx) external;
    function getTx(bytes32 submissionId) external view returns (TransactionsTypes.TxTransfer memory);
}  


contract GBridge {

    struct Chain {
        address tokenAddress;
        uint256 excessAmount;
        uint8 excessConfirmations;
        TransactionsTypes.TokenType tokenType;
        bool isSupported;
    }

    struct Config {
        address grph_address;
        address node_manager;
        uint256 grph_fees;
        bool is_paused;
        address storageAddress;
    }

    Config public config;

    string public chainId;
    address public admin;
    uint256 public nonce;

    uint256 public totalBurndGRPHToken;

    mapping(address => Chain) public chains;
    mapping(address => uint256) public totalLockedAmount;

    /* ========== ERRORS ========== */

    error NotAdminError();
    error ContractPausedError();
    error TokenNotSupportedError();
    error UnkownChainIdError();
    error AmountError();

    event TokenChainTransfer(
        bytes32 submisstionId,
        address to,
        address token,
        uint256 amount,
        uint256 nonce
    );
    event TokenChainTransferClaimed(
        address from,
        address _to,
        address token,
        uint256 amount,
        uint256 nonce
    );
    event ContractPaused();
    event ContractUnpaused();
    event TokenToChainAdded(address token);
    event ConfigUpdated(Config config);

    constructor(address _admin, string memory _chainId) {
        nonce = 0;
        admin = _admin;
        chainId = _chainId;
    }

    fallback() external payable { }

    receive() external payable {
        totalLockedAmount[0x0000000000000000000000000000000000000000] += msg.value;
     }

    modifier onlyAdmin() {
        if (admin != msg.sender) revert NotAdminError();
        _;
    }

    modifier notPaused() {
        if (config.is_paused == true) revert ContractPausedError();
        _;
    }

    function _NonceIncrement() internal {
        nonce += 1;
    }

    function _ReciveToken(
        address token,
        address from,
        uint256 amount
    ) internal {
        TransactionsTypes.TokenType _tokenType = chains[token].tokenType;
        if (_tokenType == TransactionsTypes.TokenType.ERCToken) {
            IERC20(token).transferFrom(from, address(this), amount);
        } else if (_tokenType == TransactionsTypes.TokenType.OtherToken) {
            IGBridgeToken(token).burnFrom(from, amount);
        }

        totalLockedAmount[token] += amount;
        totalBurndGRPHToken += config.grph_fees;
        IGBridgeToken(config.grph_address).burnFrom(from, config.grph_fees);
    }

    function _SendToken(
        address token,
        address to,
        uint256 amount
    ) internal {
        TransactionsTypes.TokenType _tokenType = chains[token].tokenType;
        if (_tokenType == TransactionsTypes.TokenType.ChainToken) {
            totalLockedAmount[token] -= amount;
            payable(to).transfer(amount);
        } else if (_tokenType == TransactionsTypes.TokenType.ERCToken) {
            IERC20(token).transfer(to, amount);
            totalLockedAmount[token] -= amount;
        } else if (_tokenType == TransactionsTypes.TokenType.OtherToken) {
            IGBridgeToken(token).mint(to, amount);
        }
    }

    function _Hash(
        string memory _chainId,
        address _from,
        address _to,
        address _token,
        uint256 _amount,
        uint256 _nonce
    ) internal pure returns (bytes32) {
        bytes32 chainId_hex = keccak256(abi.encodePacked(_chainId));
        bytes32 from_hex = keccak256(abi.encodePacked(_from));
        bytes32 to_hex = keccak256(abi.encodePacked(_to));
        bytes32 token_hex = keccak256(abi.encodePacked(_token));
        bytes32 amount_hex = keccak256(abi.encode(_amount));
        bytes32 nonce_hex = keccak256(abi.encode(_nonce));

        return
            keccak256(
                abi.encode(
                    chainId_hex,
                    from_hex,
                    to_hex,
                    token_hex,
                    amount_hex,
                    nonce_hex
                )
            );
    }

    function _CheckProof(
        bytes32 _submisstionId,
        address _token,
        uint256 _amount,
        bytes calldata _proofs
    ) internal {
        uint8 _excessConfirmations = 0;
        if (_amount >= chains[_token].excessAmount) {
            _excessConfirmations = chains[_token].excessConfirmations;
        }
        INodeValidatorManager(config.node_manager).verify(
            _submisstionId,
            _excessConfirmations,
            _proofs
        );
    }

    function _SaveClaim(bytes32 _submisstionId, TransactionsTypes.TxTransfer memory tx) internal {
        TransactionsTypes.TxTransfer memory t = ITransactionsStorage(config.storageAddress).getTx(
            _submisstionId
        );
        if (t.submissionId == _submisstionId) revert TransactionsTypes.TxUsedError();
        ITransactionsStorage(config.storageAddress).saveTx(tx);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getBalanceOfToken(address _token) public view returns (uint256) {
        return totalLockedAmount[_token];
    }

    function GetSubmissionId(
        string memory _chainId,
        address _from,
        address _to,
        address _token,
        uint256 _amount,
        uint256 _nonce
    ) public pure returns (bytes32) {
        return _Hash(_chainId, _from, _to, _token, _amount, _nonce);
    }

    function Transfer(
        string memory _chainId,
        address _token,
        uint256 _amount,
        address _to
    ) external payable notPaused {

        address token = chains[_token].tokenAddress;

        uint256 a = _amount;
        TransactionsTypes.TokenType _tokenType = chains[_token].tokenType;
        if (_tokenType == TransactionsTypes.TokenType.ChainToken) a = msg.value;
        if (a == 0) revert AmountError();
        if (chains[_token].isSupported != true) revert TokenNotSupportedError();
        if (
            keccak256(abi.encodePacked(chainId)) !=
            keccak256(abi.encodePacked(_chainId))
        ) revert UnkownChainIdError();
        _ReciveToken(_token, msg.sender, a);
        bytes32 submissionId = _Hash(
            _chainId,
            msg.sender,
            _to,
            token,
            a,
            nonce
        );
        emit TokenChainTransfer(submissionId, _to, token, a, nonce);
        _NonceIncrement();
    }

    function Claim(
        string memory _chainId,
        address _from,
        address _to,
        address _token,
        uint256 _amount,
        uint256 _nonce,
        bytes calldata _proofs
    ) external notPaused {
        if (
            keccak256(abi.encodePacked(chainId)) !=
            keccak256(abi.encodePacked(_chainId))
        ) revert UnkownChainIdError();
        bytes32 _submisstionId = _Hash(
            _chainId,
            _from,
            _to,
            _token,
            _amount,
            _nonce
        );
        _SaveClaim(
            _submisstionId,
            TransactionsTypes.TxTransfer(
                _submisstionId,
                _token,
                _from,
                _to,
                _amount,
                config.grph_fees,
                chains[_token].tokenType,
                _nonce,
                TransactionsTypes.TransactionType.FromZilliqa
            )
        );
        _CheckProof(_submisstionId, _token, _amount, _proofs);
        _SendToken(_token, _to, _amount);
        emit TokenChainTransferClaimed(_from, _to, _token, _amount, _nonce);
    }

    function AddUpdateToken(Chain memory chain, address _token) external onlyAdmin {
        chains[_token] = chain;
        emit TokenToChainAdded(chain.tokenAddress);
    }

    function UpdateConfig(Config calldata _config) external onlyAdmin {
        config = _config;
        emit ConfigUpdated(config);
    }

    function Pause() external onlyAdmin {
        config.is_paused = true;
        emit ContractPaused();
    }

    function Unpause() external onlyAdmin {
        config.is_paused = false;
        emit ContractUnpaused();
    }
}