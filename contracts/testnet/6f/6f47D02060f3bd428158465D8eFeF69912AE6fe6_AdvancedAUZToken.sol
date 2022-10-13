// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title AUZToken
 * @author Idealogic
 * @notice Contract for the AUZToken
 * @dev All function calls are currently implemented without side effects
 */
contract AUZToken is Ownable, ERC20 {
    // attach library functions
    using SafeERC20 for IERC20;
    using Address for address;

    //event
    event CommissionUpdate(uint256 _percent, string _data);
    event TransferPreSigned(
        address _from,
        address _to,
        uint256 _value,
        uint256 _networkFee
    );

    uint256 public mintingProofsCounter;
    uint256 public burningProofsCounter;
    uint8 private decimal = 8;
    bool private migrated;
    bool private paused;

    // These variable help to calculate the commissions on each token transfer transcation
    uint256 public MINT_FEE_PERCENT = 0; // commission percentage on minting 0.000%
    uint256 public TRANSFER_FEE_PERCENT = 1; // commission percentage on transfer 0.001%
    uint256 public PERCENT_COEFICIENT = 100000; // denominator for percentage calculation. 100000 = 100%, minimum value is 0.001%.

    // Minter address
    address public minter;

    // Address at which fees transferred
    address public feeWallet;

    // Tokens minted in this wallet
    address public sellingWallet;

    //Proofs for gold mints
    mapping(uint256 => string) public mintingProofs;

    //Proofs for gold burns
    mapping(uint256 => string) public burningProofs;

    //Mapping of addresses of contracts that are allowed to transfer tokens
    mapping(address => bool) public allowedContracts;

    //Mapping of addresses of contracts that are free of transfer fee
    mapping(address => bool) public freeOfTransferFeeContracts;

    constructor(
        address _sellingWallet,
        address _minter,
        address _feeWallet
    ) onlyNonZeroAddress(_sellingWallet) ERC20("AUZToken", "AUZ") {
        sellingWallet = _sellingWallet;
        minter = _minter;
        feeWallet = _feeWallet;
        migrated = false;
        paused = false;
    }

    ////////////////////////////////////////////////////////////////
    //                 modifiers
    ////////////////////////////////////////////////////////////////

    modifier onlyNonZeroAddress(address _user) {
        require(_user != address(0), "Zero address not allowed");
        _;
    }

    modifier isContractAddress(address _addressContract) {
        require(_addressContract.isContract(), "Only contract is allowed");
        _;
    }

    modifier onlyMinter() {
        require(msg.sender == minter, "Only Minter is allowed");
        _;
    }

    modifier isNotOPaused() {
        require(paused == false, "Operations paused");
        _;
    }

    modifier onlyAllowedContracts() {
        require(
            (address(msg.sender).isContract() &&
                allowedContracts[msg.sender]) ||
                !address(msg.sender).isContract(),
            "Address: should be allowed"
        );
        _;
    }

    ////////////////////////////////////////////////////////////////
    //                  Only Owner functions
    ////////////////////////////////////////////////////////////////

    /**
     * @notice transfer tokens from contract
     * @dev Only owner can call, tokens will be transferred and equivalent amount of ZToken will be burnt.
     * @param _amount the amount of tokens to be transferred
     * @param _hashes The array of IPFS hashes of the gold burn proofs
     */
    function burnGold(uint256 _amount, string[] memory _hashes)
        external
        onlyMinter
        isNotOPaused
    {
        for (uint256 i = 0; i < _hashes.length; i++) {
            burningProofs[burningProofsCounter] = _hashes[i];
            burningProofsCounter++;
        }
        _burn(msg.sender, _amount);
    }

    /**
     * @notice Minting of AUZtokens backed by gold tokens
     * @param _value The amount transferred
     * @param _hashes The array of IPFS hashes of the gold mint proofs
     */
    function mintGold(uint256 _value, string[] memory _hashes)
        public
        onlyMinter
        isNotOPaused
    {
        uint256 fee = calculateCommissionMint(_value);
        if (fee > 0) _mint(feeWallet, fee);
        for (uint256 i = 0; i < _hashes.length; i++) {
            mintingProofs[mintingProofsCounter] = _hashes[i];
            mintingProofsCounter++;
        }
        _mint(sellingWallet, _value - fee);
    }

    ////////////////////////////////////////////////////////////////
    //                  overriden functions
    ////////////////////////////////////////////////////////////////
    function decimals() public view virtual override returns (uint8) {
        return decimal;
    }

    /**
     * @notice Standard transfer function to Transfer token
     * @dev overriden Function of the openzeppelin ERC20 contract
     * @param recipient receiver's address
     * @param amount The amount to be transferred
     */
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        isNotOPaused
        onlyAllowedContracts
        returns (bool)
    {
        privateTransfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @notice Standard transferFrom. Send tokens on behalf of spender
     * @dev overriden Function of the openzeppelin ERC20 contract
     * @param recipient receiver's address
     * @param sender transfer token from account
     * @param amount The amount to be transferred
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override isNotOPaused onlyAllowedContracts returns (bool) {
        uint256 currentAllowance = allowance(sender, _msgSender());
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(sender, _msgSender(), currentAllowance - amount);
        privateTransfer(sender, recipient, amount);
        return true;
    }

    /**
     * @notice Private method to pause or unpause token operations
     * @param _value Bool variable that indicates the contract state
     */
    function pauseTransfers(bool _value) public onlyOwner returns (bool) {
        paused = _value;
        return true;
    }

    /**
     * @notice Internal method to handle transfer logic
     * @dev Notifies recipient, if recipient is a trusted contract
     * @param _from Sender address
     * @param _recipient Recipient address
     * @param _amount amount of tokens to be transferred
     * @return bool
     */
    function privateTransfer(
        address _from,
        address _recipient,
        uint256 _amount
    ) internal onlyNonZeroAddress(_recipient) returns (bool) {
        uint256 fee = calculateCommissionTransfer(_amount);
        if (fee > 0 && !freeOfTransferFeeContracts[_from]) _transfer(_from, feeWallet, fee);
        _transfer(_from, _recipient, _amount - fee);
        return true;
    }

    /**
     * @notice check Minting fee
     * @dev Does not checks if sender/recipient is whitelisted
     * @param _amount The intended amount of transfer
     * @return uint256 Calculated commission
     */
    function calculateCommissionMint(uint256 _amount)
        public
        view
        returns (uint256)
    {
        return (_amount * MINT_FEE_PERCENT) / PERCENT_COEFICIENT;
    }

    /**
     * @notice check Transfer fee
     * @dev Does not checks if sender/recipient is whitelisted
     * @param _amount The intended amount of transfer
     * @return uint256 Calculated commission
     */
    function calculateCommissionTransfer(uint256 _amount)
        public
        view
        returns (uint256)
    {
        return (_amount * TRANSFER_FEE_PERCENT) / PERCENT_COEFICIENT;
    }

    /**
     * @notice Update commission to be charged on token minting
     * @dev Only owner can call
     * @param _mintFeePercent The comission percent
     */
    function updateCommissionMint(uint256 _mintFeePercent) public onlyOwner {
        require(
            _mintFeePercent <= PERCENT_COEFICIENT,
            "Commission cannot be more than 100%"
        );
        MINT_FEE_PERCENT = _mintFeePercent;
        emit CommissionUpdate(MINT_FEE_PERCENT, "Minting commision");
    }

    /**
     * @notice Update commission to be charged on token transfer
     * @dev Only owner can call
     * @param _transferFeePercent The comission percent
     */
    function updateCommissionTransfer(uint256 _transferFeePercent)
        public
        onlyOwner
    {
        require(
            _transferFeePercent <= PERCENT_COEFICIENT,
            "Commission cannot be more than 100%"
        );
        TRANSFER_FEE_PERCENT = _transferFeePercent;
        emit CommissionUpdate(TRANSFER_FEE_PERCENT, "Transfer commision");
    }

    /**
     * @notice Update address at which fees transferred
     * @dev Only owner can call
     * @param _feeWallet The fee address
     */
    function updateFeeWallet(address _feeWallet) public onlyOwner {
        require(_feeWallet != address(0), "Zero address is not allowed");
        feeWallet = _feeWallet;
    }

    /**
     * @notice Update address at which tokens are sold
     * @dev Only owner can call
     * @param _sellingWallet The selling address
     */
    function updateSellingWallet(address _sellingWallet) public onlyOwner {
        require(_sellingWallet != address(0), "Zero address is not allowed");
        sellingWallet = _sellingWallet;
    }

    /**
        * @notice Update addresses of contracts that are allowed to transfer tokens
        * @dev Only owner can call
        * @param _contractAddress The address of the contract
        * @param _isAllowed Bool variable that indicates is contract allowed to transfer tokens
        */
    function updateAllowedContracts(address _contractAddress, bool _isAllowed) external onlyOwner {
        allowedContracts[_contractAddress] = _isAllowed;
    }

    /** 
        * @notice  Update addresses of contracts that are free of transfer fee
        * @dev Only owner can call
        * @param _contractAddress The address of the contract
        * @param _isFree Bool variable that indicates is contract free of transfer fee
        */
    function updateFreeContracts(address _contractAddress, bool _isFree) external onlyOwner {
        freeOfTransferFeeContracts[_contractAddress] = _isFree;
    }



    /**
     * @notice Prevents contract from accepting ETHs
     * @dev Contracts can still be sent ETH with self destruct. If anyone deliberately does that, the ETHs will be lost
     */
    receive() external payable {
        revert("Contract does not accept ethers");
    }
}

/**
 * @title AdvancedOToken
 * @author Phoenix
 */
contract AdvancedAUZToken is AUZToken {
    mapping(address => mapping(bytes32 => bool)) public tokenUsed; // mapping to track token is used or not

     bytes4 public methodWord_sell =
        bytes4(keccak256("sell(uint256)"));
    bytes4 public methodWord_transfer =
        bytes4(keccak256("transfer(address,uint256)"));
    bytes4 public methodWord_approve =
        bytes4(keccak256("approve(address,uint256)"));
    bytes4 public methodWord_increaseApproval =
        bytes4(keccak256("increaseAllowance(address,uint256)"));
    bytes4 public methodWord_decreaseApproval =
        bytes4(keccak256("decreaseAllowance(address,uint256)"));

    constructor(
        address _sellingWallet,
        address _minter,
        address _feeWallet
    ) AUZToken(_sellingWallet, _minter, _feeWallet) {}

    /**
     * @dev ID of the executing chain
     * @return uint value
     */
    function getChainID() public view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    /**
     * @notice Validates the message and signature
     * @param proof The message that was expected to be signed by user
     * @param message The message that user signed
     * @param r Signature component
     * @param s Signature component
     * @param v Signature component
     * @param token The unique token for each delegated function
     * @return address Signer of message
     */
    function preAuthValidations(
        bytes32 proof,
        bytes32 message,
        bytes32 token,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) private returns (address) {
        address signer = getSigner(message, r, s, v);
        require(signer != address(0), "Zero address not allowed");
        require(!tokenUsed[signer][token], "Token already used");
        require(proof == message, "Invalid proof");
        tokenUsed[signer][token] = true;
        return signer;
    }

    /**
     * @notice Find signer
     * @param message The message that user signed
     * @param r Signature component
     * @param s Signature component
     * @param v Signature component
     * @return address Signer of message
     */
    function getSigner(
        bytes32 message,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public pure returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, message));
        address signer = ecrecover(prefixedHash, v, r, s);
        return signer;
    }

    /**
     * @notice Delegated transfer. Gas fee will be paid by relayer
     * @param message The message that user signed
     * @param r Signature component
     * @param s Signature component
     * @param v Signature component
     * @param token The unique token for each delegated function
     * @param networkFee The fee that will be paid to relayer for gas fee he spends
     * @param to The array of recipients
     * @param amount The array of amounts to be transferred
     */
    function preAuthorizedTransfer(
        bytes32 message,
        bytes32 r,
        bytes32 s,
        uint8 v,
        bytes32 token,
        uint256 networkFee,
        address to,
        uint256 amount
    ) public {
        bytes32 proof = getProofTransfer(
            methodWord_transfer,
            token,
            networkFee,
            msg.sender,
            to,
            amount
        );
        address signer = preAuthValidations(proof, message, token, r, s, v);

        // Deduct network fee if broadcaster charges network fee
        if (networkFee > 0) {
            privateTransfer(signer, msg.sender, networkFee);
        }
        privateTransfer(signer, to, amount);
        emit TransferPreSigned(signer, to, amount, networkFee);
    }

    /**
     * @notice Delegated approval. Gas fee will be paid by relayer
     * @dev Only approve, increaseApproval and decreaseApproval can be delegated
     * @param message The message that user signed
     * @param r Signature component
     * @param s Signature component
     * @param v Signature component
     * @param token The unique token for each delegated function
     * @param networkFee The fee that will be paid to relayer for gas fee he spends
     * @param to The spender address
     * @param amount The amount to be allowed
     * @return Bool value
     */
    function preAuthorizedApproval(
        bytes4 methodHash,
        bytes32 message,
        bytes32 r,
        bytes32 s,
        uint8 v,
        bytes32 token,
        uint256 networkFee,
        address to,
        uint256 amount
    ) public returns (bool) {
        bytes32 proof = getProofApproval(
            methodHash,
            token,
            networkFee,
            msg.sender,
            to,
            amount
        );
        address signer = preAuthValidations(proof, message, token, r, s, v);
        uint256 currentAllowance = allowance(signer, _msgSender());
        // Perform approval
        if (methodHash == methodWord_approve) _approve(signer, to, amount);
        else if (methodHash == methodWord_increaseApproval)
            _approve(signer, to, currentAllowance + amount);
        else if (methodHash == methodWord_decreaseApproval)
            _approve(signer, to, currentAllowance - amount);
        return true;
    }

    function preAuthorizedSell(
        bytes32 message,
        bytes32 r,
        bytes32 s,
        uint8 v,
        bytes32 token,
        uint256 networkFee,
        uint256 amount
    ) public {
        bytes32 proof = getProofTransfer(
            methodWord_transfer,
            token,
            networkFee,
            msg.sender,
            sellingWallet,
            amount
        );
        address signer = preAuthValidations(proof, message, token, r, s, v);

        // Deduct network fee if broadcaster charges network fee
        if (networkFee > 0) {
            privateTransfer(signer, msg.sender, networkFee);
        }
        privateTransfer(signer, sellingWallet, amount);
        emit TransferPreSigned(signer, sellingWallet, amount, networkFee);
    }

    /**
     * @notice Get the message to be signed in case of delegated transfer/approvals
     * @param methodHash The method hash for which delegate action in to be performed
     * @param token The unique token for each delegated function
     * @param networkFee The fee that will be paid to relayer for gas fee he spends
     * @param to The recipient or spender
     * @param amount The amount to be transferred
     * @return Bool value
     */
    function getProofTransfer(
        bytes4 methodHash,
        bytes32 token,
        uint256 networkFee,
        address broadcaster,
        address to,
        uint256 amount
    ) public view returns (bytes32) {
        require(methodHash == methodWord_transfer, "Method not supported");
        bytes32 proof = keccak256(
            abi.encodePacked(
                getChainID(),
                bytes4(methodHash),
                address(this),
                token,
                networkFee,
                broadcaster,
                to,
                amount
            )
        );
        return proof;
    }

    /**
     * @notice Get the message to be signed in case of delegated transfer/approvals
     * @param methodHash The method hash for which delegate action in to be performed
     * @param token The unique token for each delegated function
     * @param networkFee The fee that will be paid to relayer for gas fee he spends
     * @param to The recipient or spender
     * @param amount The amount to be approved
     * @return Bool value
     */
    function getProofApproval(
        bytes4 methodHash,
        bytes32 token,
        uint256 networkFee,
        address broadcaster,
        address to,
        uint256 amount
    ) public view returns (bytes32) {
        require(
            methodHash == methodWord_approve ||
                methodHash == methodWord_increaseApproval ||
                methodHash == methodWord_decreaseApproval,
            "Method not supported"
        );
        bytes32 proof = keccak256(
            abi.encodePacked(
                getChainID(),
                bytes4(methodHash),
                address(this),
                token,
                networkFee,
                broadcaster,
                to,
                amount
            )
        );
        return proof;
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}