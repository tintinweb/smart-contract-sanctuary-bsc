/**
 *Submitted for verification at BscScan.com on 2022-09-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/// @notice the spender isn't authorized to spend this amount
error ERC20AllowanceInsufficient(address account, address spender, uint256 amount);
/// @notice the amount trying being from the account is greater than the account's balance
error ERC20BalanceInsufficient(address account, uint256 amount);

error ERC20TransfersDisabled();

/// @title Using ERC20 an implementation of EIP-20
/// @dev this is purely the implementation and doesn't contain storage it can be used with existing upgradable contracts just map the existing storage.
abstract contract UsingERC20  {

    /// @notice the event emitted after the a transfer
    event Transfer(address indexed from, address indexed to, uint256 value);
    /// @notice the event emitted upon receiving approval
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice transfer tokens from sender to account
    /// @param target_ the address to transfer to
    /// @param amount_ the amount to transfer
    function transfer(address target_, uint256 amount_) external virtual returns (bool) {
        _assertSufficientBalance(msg.sender, amount_);
        return _transfer(msg.sender, target_, amount_);
    }

    /// @notice checks to see if the spender is approved to spend the given amount and transfer
    /// @param source_ the account to transfer from
    /// @param target_ the account to transfer to
    /// @param amount_ the amount to transfer
    function transferFrom(address source_, address target_, uint256 amount_) external virtual returns (bool) {
        _assertSufficientAllowance(source_, msg.sender, amount_);
        _assertSufficientBalance(source_, amount_);
        return _transferFrom(msg.sender, source_, target_, amount_);
    }

    /// @notice the allowance the spender is allowed to spend for an account
    /// @param account_ the account to check
    /// @param spender_ the trusted spender
    /// @return uint256 amount of the account that the spender_ can transfer
    function allowance(address account_, address spender_) external view virtual returns (uint256) {
        return _allowance(account_, spender_);
    }

    /// @notice returns the total supply of tokens
    function totalSupply() public view virtual returns (uint256) {
        return _getTotalSupplyStorage();
    }

    /// @notice check the balance of the given account
    /// @param account_ the account to check
    /// @return uint256 the balance of the account
    function balanceOf(address account_) external view virtual returns (uint256) {
        return _getBalancesStorage()[account_];
    }

    /// @notice the symbol of the token
    function symbol() public view virtual returns (string memory) {
        return _getSymbolStorage();
    }

    /// @notice the decimals of the token
    function decimals() public view virtual returns (uint8) {
        return _getDecimalStorage();
    }

    /// @notice the name of the token
    function name() public view virtual returns (string memory) {
        return _getNameStorage();
    }

    /// @notice approve the spender to spend the given amount for an account
    /// @param spender_ the account to approve
    /// @param amount_ the amount to approve
    function approve(address spender_, uint256 amount_) public virtual returns (bool) {
        _approve(msg.sender, spender_, amount_);
        return true;
    }

    function _allowance(address account_, address spender_) internal view virtual returns (uint256) {
        return _getAllowanceStorage()[account_][spender_];
    }

    /// @notice initialize the token
    /// @dev used internally if you use this in a public function be sure to use the initializer
    function _initializeERC20(address target_, uint totalSupply_) internal virtual {
        _mint(target_, totalSupply_);
    }

    /// @notice approve the spender to spend the given amount for an account
    /// @param spender_ the account to approve
    /// @param amount_ the amount to approve
    function _approve(address source_, address spender_, uint256 amount_) internal virtual {
        _getAllowanceStorage()[source_][spender_] = amount_;
        emit Approval(source_, spender_, amount_);
    }

    /// @notice used internally to get the balance of the account
    function _balanceOf(address account_) internal view virtual returns (uint256) {
        return _getBalancesStorage()[account_];
    }

    /// @notice checks to see if the spender is approved to spend the given amount and transfer
    /// @param source_ the account to transfer from
    /// @param target_ the account to transfer to
    /// @param amount_ the amount to transfer
    function _transferFrom(address spender_, address source_, address target_, uint256 amount_) internal virtual returns (bool) {
        unchecked {
            _getAllowanceStorage()[source_][spender_] -= amount_;
        }
        return _transfer(source_, target_, amount_);
    }

    function _assertSufficientBalance(address account_, uint256 amount_) internal view virtual {
        if (amount_ > _balanceOf(account_)) {
            revert ERC20BalanceInsufficient(account_, amount_);
        }
    }

    function _assertSufficientAllowance(address source_, address spender_, uint256 amount_) internal view virtual {
        if (_allowance(source_, spender_) < amount_ ) {
            revert ERC20AllowanceInsufficient(source_, spender_, amount_);
        }
    }

    /// @notice transfer tokens to one account from another
    /// @param source_ the account to transfer from
    /// @param target_ the account to transfer to
    /// @param amount_ the amount to transfer
    /// @dev inherit from this function to implement custom taxation or other logic warning this function does zero checking for underflows and overflows
    function _transfer(address source_, address target_, uint256 amount_) internal virtual returns (bool) {
        unchecked {
            _getBalancesStorage()[source_] -= amount_;
            _getBalancesStorage()[target_] += amount_;
        }
        emit Transfer(source_, target_, amount_);
        return true;
    }

    /// @notice mint tokens and adjust the supply
    /// @param target_ the account to mint to
    /// @param amount_ the amount to mint
    function _mint(address target_, uint256 amount_) internal virtual {
        unchecked {
            _setTotalSupplyStorage(_getTotalSupplyStorage() + amount_);
            _getBalancesStorage()[target_] += amount_;
        }
        emit Transfer(address(0), target_, amount_);
    }

    /// @notice burn tokens and adjust the supply
    /// @param source_ the account to burn from
    /// @param amount_ the amount to burn
    function _burn(address source_, uint amount_) internal virtual {
        _assertSufficientBalance(source_, amount_);
        unchecked {
            _setTotalSupplyStorage(_getTotalSupplyStorage() - amount_);
            _getBalancesStorage()[source_] -= amount_;
        }
        emit Transfer(source_, address(0), amount_);
    }

    /// @notice get the storage for allowance
    /// @return mapping(address => mapping(address => uint256)) allowance storage
    function _getAllowanceStorage() internal view virtual returns (mapping(address => mapping(address => uint256)) storage);
    /// @notice get the storage for balances
    function _getNameStorage() internal view virtual returns (string memory);
    /// @return mapping(address => uint256) balances storage
    function _getBalancesStorage() internal view virtual returns (mapping(address => uint256) storage);
    function _getTotalSupplyStorage() internal view virtual returns (uint256);
    function _setTotalSupplyStorage(uint256 value) internal virtual;
    function _getSymbolStorage() internal view virtual returns (string memory);
    function _getDecimalStorage() internal view virtual returns (uint8);
}

/// @notice The signer of the permit doesn't match
    error PermitSignatureInvalid(address recovered, address expected, uint256 amount);
/// @notice the block.timestamp has passed the deadline
    error PermitExpired(address owner, address spender, uint256 amount, uint256 deadline);
    error PermitInvalidSignatureSValue();
    error PermitInvalidSignatureVValue();

/// @title Using EIP-2612 Permits
/// @author originally written by soliditylabs with modifications made by [email protected]
/// @dev reference implementation can be found here https://github.com/soliditylabs/ERC20-Permit/blob/main/contracts/ERC20Permit.sol.
///      This contract contains the implementation and lacks storage. Use this with existing upgradeable contracts.
abstract contract UsingPermit  {

    /// @notice initialize the permit function internally
    function _initializePermits() internal {
        _updateDomainSeparator(block.chainid);
    }

    /// @notice get the nonce for the given account
    /// @param account_ the account to get the nonce for
    /// @return the nonce
    function nonces(address account_) public view returns (uint256) {
        return _getNoncesStorage()[account_];
    }

    /// @notice the domain separator for a chain
    /// @param chainId_ the chain id to get the domain separator for
    function domainSeparators(uint256 chainId_) public view returns (bytes32) {
        return _getDomainSeparatorsStorage()[chainId_];
    }

    /// @notice check if the permit is valid
    function _permit(uint chainId_, address owner_, address spender_, uint256 amount_, uint256 deadline_, uint8 v_, bytes32 r_, bytes32 s_) internal virtual {
        if(block.timestamp > deadline_) revert PermitExpired(owner_, spender_, amount_, deadline_);
        bytes32 hashStruct;
        uint256 nonce = _getNoncesStorage()[owner_]++;
        assembly {
            let memPtr := mload(64)
            mstore(memPtr, 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9)
            mstore(add(memPtr, 32), owner_)
            mstore(add(memPtr, 64), spender_)
            mstore(add(memPtr, 96), amount_)
            mstore(add(memPtr, 128),nonce)
            mstore(add(memPtr, 160), deadline_)
            hashStruct := keccak256(memPtr, 192)
        }
        bytes32 eip712DomainHash = _domainSeparator(chainId_);
        bytes32 hash;
        assembly {
            let memPtr := mload(64)

            mstore(memPtr, 0x1901000000000000000000000000000000000000000000000000000000000000)
            mstore(add(memPtr, 2), eip712DomainHash)
            mstore(add(memPtr, 34), hashStruct)

            hash := keccak256(memPtr, 66)
        }
        address signer = _recover(hash, v_, r_, s_);
        if (signer != owner_) revert PermitSignatureInvalid(signer, owner_, amount_);
    }

    /// @notice add a new domain separator to the mapping
    /// @return the domain separator hash
    function _updateDomainSeparator(uint chainId_) internal virtual returns (bytes32) {
        bytes32 newDomainSeparator = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(_getNameStorage())), // ERC-20 Name
                keccak256(bytes("1")),    // Version
                chainId_,
                address(this)
            )
        );
        _getDomainSeparatorsStorage()[chainId_] = newDomainSeparator;
        return newDomainSeparator;
    }

    /// @notice get the domain separator and add it to the mapping if it doesn't exist
    /// @return the new or cached domain separator
    function _domainSeparator(uint chainId_) internal virtual returns (bytes32) {
        bytes32 domainSeparator = _getDomainSeparatorsStorage()[chainId_];

        if (domainSeparator != 0x00) {
            return domainSeparator;
        }

        return _updateDomainSeparator(chainId_);
    }

    /// @notice recover the signer address from the signature
    function _recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (
            uint256(s) >
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
        ) {
            revert PermitInvalidSignatureSValue();
        }

        if (v != 27 && v != 28) {
            revert PermitInvalidSignatureVValue();
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) revert PermitSignatureInvalid(signer, address(0), 0);
        return signer;
    }

    /// @notice the name used to compute the domain separator
    function _getNameStorage() internal view virtual returns (string memory);
    /// @notice get the nonce storage
    function _getNoncesStorage() internal view virtual returns (mapping(address => uint256) storage);
    /// @notice get the domain separator storage
    function _getDomainSeparatorsStorage() internal view virtual returns (mapping(uint256 => bytes32) storage);

}

abstract contract UsingPermitWithStorage is UsingPermit {
    /// @notice nonces per account to prevent re-use of permit
    mapping(address => uint256) internal _nonces;
    /// @notice the predefined type hash
    bytes32 public constant TYPE_HASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    /// @notice a mapping of chainId and domain separators
    mapping(uint256 => bytes32) internal _domainSeparators;

    function _getNoncesStorage() internal view override returns (mapping(address => uint256) storage) {
        return _nonces;
    }

    function _getDomainSeparatorsStorage() internal view override returns (mapping(uint256 => bytes32) storage) {
        return _domainSeparators;
    }

}

/// @title bit library
/// @notice old school bit bits
library bits {

    /// @notice check if only a specific bit is set
    /// @param slot the bit storage slot
    /// @param bit the bit to be checked
    /// @return return true if the bit is set
    function only(uint slot, uint bit) internal pure returns (bool) {
        return slot == bit;
    }

    /// @notice checks if all bits ares set and cleared
    function all(uint slot, uint set_, uint cleared_) internal pure returns (bool) {
        return all(slot, set_) && !all(slot, cleared_);
    }

    /// @notice checks if any of the bits_ are set
    /// @param slot the bit storage to slot
    /// @param bits_ the or list of bits_ to slot
    /// @return true of any of the bits_ are set otherwise false
    function any(uint slot, uint bits_) internal pure returns(bool) {
        return (slot & bits_) != 0;
    }

    /// @notice checks if any of the bits are set and all of the bits are cleared
    function check(uint slot, uint set_, uint cleared_) internal pure returns(bool) {
        return slot != 0 ?  ((set_ == 0 || any(slot, set_)) && (cleared_ == 0 || !any(slot, cleared_))) : (set_ == 0 || any(slot, set_));
    }

    /// @notice checks if all of the bits_ are set
    /// @param slot the bit storage
    /// @param bits_ the list of bits_ required
    /// @return true if all of the bits_ are set in the sloted variable
    function all(uint slot, uint bits_) internal pure returns(bool) {
        return (slot & bits_) == bits_;
    }

    /// @notice set bits_ in this storage slot
    /// @param slot the storage slot to set
    /// @param bits_ the list of bits_ to be set
    /// @return a new uint with bits_ set
    /// @dev bits_ that are already set are not cleared
    function set(uint slot, uint bits_) internal pure returns(uint) {
        return slot | bits_;
    }

    function toggle(uint slot, uint bits_) internal pure returns (uint) {
        return slot ^ bits_;
    }

    function isClear(uint slot, uint bits_) internal pure returns(bool) {
        return !all(slot, bits_);
    }

    /// @notice clear bits_ in the storage slot
    /// @param slot the bit storage variable
    /// @param bits_ the list of bits_ to clear
    /// @return a new uint with bits_ cleared
    function clear(uint slot, uint bits_) internal pure returns(uint) {
        return slot & ~(bits_);
    }

    /// @notice clear & set bits_ in the storage slot
    /// @param slot the bit storage variable
    /// @param bits_ the list of bits_ to clear
    /// @return a new uint with bits_ cleared and set
    function reset(uint slot, uint bits_) internal pure returns(uint) {
        slot = clear(slot, type(uint).max);
        return set(slot, bits_);
    }

}

/// @notice Emitted when a check for
error FlagsInvalid(address account, uint256 set, uint256 cleared);

/// @title UsingFlags contract
/// @notice Use this contract to implement unique permissions or attributes
/// @dev you have up to 255 flags you can use. Be careful not to use the same flag more than once. Generally a preferred approach is using
///      pure virtual functions to implement the flags in the derived contract.
abstract contract UsingFlags {
    /// @notice a helper library to check if a flag is set
    using bits for uint256;
    event FlagsChanged(address indexed account, uint256 from, uint256 to);

    /// @notice checks of the required flags are set or cleared
    /// @param account_ the account to check
    /// @param set_ the flags that must be set
    /// @param cleared_ the flags that must be cleared
    modifier requires(address account_, uint256 set_, uint256 cleared_) {
        if (!(_getFlags(account_).check(set_, cleared_))) revert FlagsInvalid(account_, set_, cleared_);
        _;
    }

    /// @notice getFlags returns the currently set flags
    /// @param account_ the account to check
    function getFlags(address account_) public virtual view returns (uint256) {
        return _getFlags(account_);
    }

    function _getFlags(address account_) internal virtual view returns (uint256) {
        return _getFlagStorage()[account_];
    }

    /// @notice set and clear flags for the given account
    /// @param account_ the account to modify flags for
    /// @param set_ the flags to set
    /// @param clear_ the flags to clear
    function _setFlags(address account_, uint256 set_, uint256 clear_) internal virtual {
        uint256 before = _getFlags(account_);
        _getFlagStorage()[account_] = _getFlags(account_).set(set_).clear(clear_);
        emit FlagsChanged(account_, before, _getFlags(account_));
    }

    function _checkFlags(address account_, uint set_, uint cleared_) internal view returns (bool) {
        return _checkFlags(_getFlags(account_), set_, cleared_);
    }

    function _checkFlags(uint flags_, uint set_, uint cleared_) internal view returns (bool) {
        return flags_.check(set_, cleared_);
    }

    function _assertFlags(uint flags_, uint set_, uint cleared_) internal view {
        if (!_checkFlags(flags_, set_, cleared_)) revert FlagsInvalid(address(0), set_, cleared_);
    }

    function _assertFlags(address account_, uint set_, uint cleared_) internal view {
        if (!_checkFlags(_getFlags(account_), set_, cleared_)) revert FlagsInvalid(account_, set_, cleared_);

    }

    /// @notice get the storage for flags
    function _getFlagStorage() internal view virtual returns (mapping(address => uint256) storage);
}

/// @title UsingFlagsWithStorage contract
/// @dev use this when creating a new contract
abstract contract UsingFlagsWithStorage is UsingFlags {
    using bits for uint256;

    /// @notice the mapping to store the flags
    mapping(address => uint256) internal _flags;

    function _getFlagStorage() internal view override returns (mapping(address => uint256) storage) {
        return _flags;
    }
}

/// @title UsingERC20WithStorage ERC20 contract with storage
/// @dev This should be used with new token contracts or upgradeable contracts with incompatible storage.
abstract contract UsingERC20WithStorage is UsingERC20 {
    /// @notice the total supply of tokens
    uint256 internal _totalSupply;
    /// @notice the mapping of allowances
    mapping(address => mapping(address => uint256)) internal _allowances;
    /// @notice the mapping of account balances
    mapping(address => uint256) internal _balances;

    /// @notice get the storage for balances
    /// @return mapping(address => uint256) the storage for balances
    function _getBalancesStorage() internal view virtual override returns (mapping(address => uint256) storage){
        return _balances;
    }

    /// @notice get the storage for allowances
    /// @return mapping(address => mapping(address => uint256)) the storage for allowances
    function _getAllowanceStorage() internal view virtual override returns (mapping(address => mapping(address => uint256)) storage){
        return _allowances;
    }

    /// @notice get the storage for total supply
    /// @return uint256 the storage for total supply
    function _getTotalSupplyStorage() internal view virtual override returns (uint256){
        return _totalSupply;
    }

    /// @notice set the storage for total supply
    function _setTotalSupplyStorage(uint256 _value) internal virtual override {
        _totalSupply = _value;
    }

}

error BatchLengthMismatch();

/// @title UsingBatchTransfer
/// @notice Use this contract to implement batch transfers in ERC20 tokens
abstract contract UsingBatchTransfer {

    /// @notice transfer tokens in batches
    /// @param accounts_ the accounts to transfer to
    /// @param amounts_ the amounts to transfer to each account
    function batchTransfer(address[] calldata accounts_, uint256[] calldata amounts_) external virtual {
        if (accounts_.length != amounts_.length) revert BatchLengthMismatch();
        for (uint i = 0; i < accounts_.length; i++) {
            _assertSufficientBalance(msg.sender, amounts_[i]);
            _transfer(msg.sender, accounts_[i], amounts_[i]);
        }
    }

    function _assertSufficientBalance(address source_, uint256 amount_) internal view virtual;
    /// @notice the required transfer method to be implemented
    function _transfer(address source_, address target_, uint256 amount_) internal virtual returns (bool);
}

error AdminRequired();
error Initialized();

abstract contract JetsetFlags is UsingFlagsWithStorage {

    uint constant TRANSFERS_ENABLED = 1; // 1
    uint constant PERMITS_ENABLED =  TRANSFERS_ENABLED << 1; // 2
    uint constant INITIALIZED = PERMITS_ENABLED << 1; // 3
    uint constant ADMIN = INITIALIZED << 1; // 4
    uint constant LIQUIDITY_PAIR = ADMIN << 1; // 6
    uint constant FEE_EXEMPT = LIQUIDITY_PAIR << 1; // 10
    uint constant BLOCKED = FEE_EXEMPT << 1; // 11
    uint constant DEVELOPER = BLOCKED << 1; // 12

    struct Flags {
        uint256 transfersEnabled;
        uint256 permitsEnabled;
        uint256 initialized;
        uint256 admin;
        uint256 liquidityPair;
        uint256 feeExempt;
        uint256 blocked;
        uint256 developer;
    }

    // states
    // transfer 88334

    uint constant THIS_OFFSET = 223;
    uint constant SENDER_OFFSET = THIS_OFFSET - 32;
    uint constant SOURCE_OFFSET = SENDER_OFFSET - 32;
    uint constant TARGET_OFFSET = SOURCE_OFFSET - 32;

    uint constant THIS_TRANSFERS_ENABLED = TRANSFERS_ENABLED << THIS_OFFSET;
    uint constant THIS_PERMITS_ENABLED = PERMITS_ENABLED << THIS_OFFSET;
    uint constant THIS_INITIALIZED = INITIALIZED << THIS_OFFSET;
    uint constant THIS_FLAGS_MASK = ((1 << 32) - 1) << 224;

    uint constant SENDER_IS_ADMIN = ADMIN << SENDER_OFFSET;
    uint constant SENDER_FLAGS_MASK = ((1 << 32) - 1) << 192;

    uint constant SOURCE_IS_LIQUIDITY_PAIR = LIQUIDITY_PAIR << SOURCE_OFFSET;
    uint constant SOURCE_IS_FEE_EXEMPT = FEE_EXEMPT << SOURCE_OFFSET;
    uint constant SOURCE_IS_BLOCKED = BLOCKED << SOURCE_OFFSET;
    uint constant SOURCE_IS_THIS = INITIALIZED << SOURCE_OFFSET;

    uint constant TARGET_IS_LIQUIDITY_PAIR = LIQUIDITY_PAIR << TARGET_OFFSET;
    uint constant TARGET_IS_FEE_EXEMPT = FEE_EXEMPT << TARGET_OFFSET;
    uint constant TARGET_IS_BLOCKED = BLOCKED << TARGET_OFFSET;
    uint constant TARGET_IS_THIS = INITIALIZED << TARGET_OFFSET;

    uint constant PRECISION = 10 ** 5;

    modifier requiresAdmin() {
        if (!_checkFlags(msg.sender, ADMIN, 0)) revert AdminRequired();
        _;
    }

    modifier initializer() {
        if (_checkFlags(address(this), INITIALIZED, 0)) revert Initialized();
        _setFlags(address(this), INITIALIZED, 0);
        _;
    }

    /// @notice set and clear any arbitrary flag
    /// @dev only use this if you know what you are doing
    function setFlags(address account_, uint256 set_, uint256 clear_) external requiresAdmin {
        _setFlags(account_, set_, clear_);
    }

    /// @notice the current available flags
    /// @return the flags structure with each flag value
    function flags() external view returns (Flags memory) {
        return Flags(
            TRANSFERS_ENABLED,
            PERMITS_ENABLED,
            INITIALIZED,
            ADMIN,
            LIQUIDITY_PAIR,
            FEE_EXEMPT,
            BLOCKED,
            DEVELOPER
        );
    }

}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract UsingERC1967UpgradeUpgradeable {
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

/// @title UsingUUPS upgradeable proxy contract
/// @notice this is just a renamed from OpenZeppelin (UUPSUpgradeable)
abstract contract UsingUUPS is IERC1822ProxiableUpgradeable, UsingERC1967UpgradeUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

library AddressSet {
    using AddressSet for Set;
    
    error KeyExists();
    error KeyError();

    struct Set {
        address[] items;
        mapping(address => uint) indices;
    }

    function add(Set storage set_, address item_) internal {
        if (set_.contains(item_)) revert KeyExists();
        set_.items.push(item_);
        set_.indices[item_] = set_.items.length;
    }

    function replace(Set storage set_, address oldItem_, address newItem_) internal {
        if (set_.indices[oldItem_] == 0) {
            revert KeyError();
        }
        set_.items[set_.indices[oldItem_] - 1] = newItem_;
        set_.indices[newItem_] = set_.indices[oldItem_];
        set_.indices[oldItem_] = 0;
    }

    function pop(Set storage set_) internal returns (address) {
        address last = set_.items[set_.length() - 1];
        delete set_.indices[last];
        return last;
    }

    function get(Set storage set_, uint index_) internal view returns (address) {
        return set_.items[index_];
    }

    function length(Set storage set_) internal view returns (uint) {
        return set_.items.length;
    }

    function remove(Set storage set_, address item_) internal  {
        if (set_.indices[item_] == 0) {
            revert KeyError();
        }
        uint index = set_.indices[item_];
        if (index != set_.length()) {
            set_.items[index - 1] = set_.items[set_.length() - 1];
            set_.indices[set_.items[index - 1]] = index;
        }
        set_.items.pop();
        set_.indices[item_] = 0;
    }

    function clear(Set storage set_) internal {
        for (uint i=0; i < set_.length(); i++) {
            address key = set_.items[i];
            set_.indices[key] = 0;
        }
        delete set_.items;
    }

    function contains(Set storage set_, address item_) internal view returns (bool) {
        return set_.indices[item_] > 0;
    }

    function indexOf(Set storage set_, address item_) internal view returns (uint) {
        return set_.indices[item_] - 1;
    }
    
}

error ArrayLengthMismatch();
error WithdrawFailed();
error PaymentFailed();

/// @title Jetset Token Contract
contract Jetset is JetsetFlags, UsingBatchTransfer, UsingERC20WithStorage, UsingPermitWithStorage, UsingUUPS {
    using AddressSet for AddressSet.Set;

    /// @notice event emitted when a fees are changed
    event FeesChanged(address indexed sender, Fees oldFees, Fees newFees);
    /// @notice event emitted with the allocation of fees is changed
    event FeeAllocationsChanged(address indexed sender, FeeAllocations oldFeeAllocations, FeeAllocations newFeeAllocations);
    /// @notice event emitted when the marketing wallet address is changed
    event MarketingAddressChanged(address indexed sender, address oldMarketingAddress, address newMarketingAddress);

    /// @notice a structure for fees and allocations that fits in one storage slot
    struct FeesAndAllocations {
        uint32 transferFee;
        uint32 buyFee;
        uint32 sellFee;
        uint32 liquidityAllocation;
        uint32 burnAllocation;
        uint32 marketingAllocation;
        uint64 _unused;
    }

    /// @notice a structure for viewing fees externally
    struct Fees {
        uint32 transferFee;
        uint32 buyFee;
        uint32 sellFee;
    }

    /// @notice a structure for viewing allocations externally
    struct FeeAllocations {
        uint32 liquidityAllocation;
        uint32 burnAllocation;
        uint32 marketingAllocation;
    }

    /// @notice the router used for adding and removing liquidity
    IUniswapV2Router02 _router;
    /// @notice a structure for fees and allocations
    FeesAndAllocations _feesAndAllocations;
    /// @notice the address of the marketing wallet
    address _marketingAddress;
    /// @notice an internal balance of marketing tokens vs liquidity tokens
    uint _marketingBalance;
    /// @notice the path used for swapping tokens to WETH
    address[] _path;
    /// @notice used for tracking account flags over time;
    mapping(uint => AddressSet.Set) _flaggedAccounts;

    receive() external payable {}

    /// @notice initialize the contract
    /// @param totalSupply_ the total supply of the token
    /// @param routerAddress_ the address of the default router
    /// @param marketingAddress_ the address of the marketing wallet to send marketing fees too
    /// @param fees_ the fees and fee ratios to be used
    /// @dev this can only be called once and is called during the upgrades deployment
    function initialize(uint totalSupply_, address routerAddress_, address marketingAddress_, FeesAndAllocations memory fees_) external initializer {
        _initializeERC20(msg.sender, totalSupply_);
        _initializePermits();
        _setFlags(msg.sender, ADMIN | FEE_EXEMPT, 0);
        _setFlags(address(this), FEE_EXEMPT, 0);
        _router = IUniswapV2Router02(routerAddress_);
        _marketingAddress = marketingAddress_;
        _feesAndAllocations = fees_;
        _path = new address[](2);
        (_path[0], _path[1]) = (address(this), _router.WETH());
        _approve(address(this), routerAddress_, type(uint256).max);
    }

    /// @notice set the fees
    /// @param transferFee_ the fee to applied for non dex transfers
    /// @param buyFee_ the fee to be applied during swaps to this token
    /// @param sellFee_ the fee to be applied during swaps from this
    /// @dev this can only be called by the admin
    function setFees(uint32 transferFee_, uint32 buyFee_, uint32 sellFee_) external requiresAdmin {
        Fees memory oldFees = fees();
        (_feesAndAllocations.transferFee, _feesAndAllocations.buyFee, _feesAndAllocations.sellFee) = (transferFee_, buyFee_, sellFee_);
        emit FeesChanged(msg.sender, oldFees, fees());
    }

    /// @notice the transfer fees
    /// @return the current buy, sell and transfer fees
    function fees() public view returns (Fees memory) {
        return Fees(_feesAndAllocations.transferFee, _feesAndAllocations.buyFee, _feesAndAllocations.sellFee);
    }

    /// @notice get the current allocation of fees
    /// @return the current allocation of fees
    function feeAllocations() public view returns (FeeAllocations memory) {
        return FeeAllocations(_feesAndAllocations.liquidityAllocation, _feesAndAllocations.burnAllocation, _feesAndAllocations.marketingAllocation);
    }

    /// @notice set the ratio of the fee for the given type
    /// @param liquidityAllocation_ the ratio of the sell fee to be used for liquidity injection
    /// @param burnAllocation_ the ratio of the buy fee to be used for burning
    /// @param marketingAllocation_ the ratio of the buy and sell fee to be used for marketing
    /// @dev this can only be called by the admin
    function setFeeAllocations(uint32 liquidityAllocation_, uint32 burnAllocation_, uint32 marketingAllocation_) external requiresAdmin {
        FeeAllocations memory oldFeeAllocations = feeAllocations();
        (_feesAndAllocations.liquidityAllocation, _feesAndAllocations.burnAllocation, _feesAndAllocations.marketingAllocation) = (liquidityAllocation_, burnAllocation_, marketingAllocation_);
        emit FeeAllocationsChanged(msg.sender, oldFeeAllocations, feeAllocations());
    }

    /// @notice set the marketing receiver address
    /// @param marketingAddress_ the address to send marketing fees too
    /// @dev this can only be called by the admin
    function setMarketingAddress(address marketingAddress_) external requiresAdmin {
        address oldMarketingAddress = _marketingAddress;
        _marketingAddress = marketingAddress_;
        emit MarketingAddressChanged(msg.sender, oldMarketingAddress, _marketingAddress);
    }

    /// @notice the current marketing address that will receiv marketing fees
    /// @return the address of the marketing wallet
    function marketingAddress() external view returns (address) {
        return _marketingAddress;
    }

    /// @notice is the contract initialized
    function initialized() public view returns (bool) {
        return _checkFlags(address(this), INITIALIZED, 0);
    }

    /// @notice add an admin to this contract
    /// @param admin_ the address to add as an admin
    function addAdmin(address admin_) external requiresAdmin {
        _flaggedAccounts[ADMIN].add(admin_);
        _setFlags(admin_, ADMIN, 0);
    }

    /// @notice remove an admin from this contract
    /// @param admin_ the admin to remove
    /// @dev requires existing admin privileges
    function removeAdmin(address admin_) external requiresAdmin {
        _flaggedAccounts[ADMIN].remove(admin_);
        _setFlags(admin_, 0, ADMIN);
    }

    /// @notice exempt account from fees
    /// @param account_ the account to exempt from fees
    /// @dev will revert if sender isn't admin or if the account is already exempted
    function exemptAccountFromFees(address account_) external requiresAdmin {
        _flaggedAccounts[FEE_EXEMPT].add(account_);
        _setFlags(account_, FEE_EXEMPT, 0);
    }

    /// @notice remove fee exemption from account
    /// @param account_ the address of the account to remove the exemption
    /// @dev will revert if sender isn't admin or if the account doesn't have exemption
    function unexemptAccountFromFees(address account_) external requiresAdmin {
        _flaggedAccounts[FEE_EXEMPT].remove(account_);
        _setFlags(account_, 0, FEE_EXEMPT);
    }

    /// @notice block an account from transferring
    /// @param account_ the account to block
    /// @dev requires existing admin privileges
    function blockAccount(address account_) external requiresAdmin {
        _flaggedAccounts[BLOCKED].add(account_);
        _setFlags(account_, BLOCKED, 0);
    }

    /// @notice unblock an account from transferring
    /// @param account_ the account to unblock
    /// @dev requires existing admin privileges
    function unblockAccount(address account_) external requiresAdmin {
        _flaggedAccounts[BLOCKED].remove(account_);
        _setFlags(account_, 0, BLOCKED);
    }

    /// @notice add a liquidity pair for applying buy and sell tax
    /// @param pair_ the address of the pair to add
    /// @dev the contract currently only adds to the initial liquidity pool and will need an upgrade to add to additional pools
    function addPair(address pair_) external requiresAdmin {
        _flaggedAccounts[LIQUIDITY_PAIR].add(pair_);
        _setFlags(pair_, LIQUIDITY_PAIR, 0);
    }

    /// @notice remove a liquidity pair for applying buy and sell tax
    /// @param pair_ the address of the pair to remove
    /// @dev requires existing admin privileges
    function removePair(address pair_) external requiresAdmin {
        _flaggedAccounts[LIQUIDITY_PAIR].remove(pair_);
        _setFlags(pair_, 0, LIQUIDITY_PAIR);
    }

    /// @notice pause the contract from all transfers
    /// @dev requires existing admin privileges
    function pause() external requiresAdmin {
        _setFlags(address(this), 0, TRANSFERS_ENABLED);
    }

    /// @notice unpause the contract and allow transferring
    function unpause() external requiresAdmin {
        _setFlags(address(this), TRANSFERS_ENABLED, 0);
    }

    /// @notice check if the contract is paused
    /// @return true if the contract is paused
    function paused() external view returns (bool) {
        return _checkFlags(_getFlags(address(this)), 0, TRANSFERS_ENABLED);
    }

    /// @notice withdraw BNB that was sent to the contract by mistake
    /// @param to_ the address to send the BNB to
    /// @param amount_ the amount of BNB to send
    /// @dev requires existing admin privileges
    function withdrawBNB(address to_, uint256 amount_) external requiresAdmin {
        (bool success,) = payable(to_).call{value: amount_}("");
        if (!success) revert WithdrawFailed();
    }

    /// @notice withdraw tokens that were sent to the contract by mistake
    /// @param token_ the address of the token to withdraw
    /// @param to_ the address to send the tokens to
    /// @param amount_ the amount of tokens to send
    /// @dev requires existing admin privileges
    function withdrawTokens(address token_, address to_,  uint256 amount_) external requiresAdmin {
        IERC20(token_).transfer(to_, amount_);
    }

    /// @notice the current version of the contract
    function version() external pure returns (string memory) {
        return "2.0";
    }

    function _transfer(address source_, address target_, uint256 amount_) internal override(UsingERC20, UsingBatchTransfer) returns (bool) {
        uint flags = _getTransferFlags(msg.sender, source_, target_);
        // check to ensure that transfers are enabled and that the sender and recipient are not blocked
        _assertFlags(flags, THIS_TRANSFERS_ENABLED | SENDER_IS_ADMIN, SOURCE_IS_BLOCKED | TARGET_IS_BLOCKED);
        uint fee;
        if (!_checkFlags(flags, SOURCE_IS_FEE_EXEMPT | TARGET_IS_FEE_EXEMPT, 0)) {
            fee = _processTransfer(source_, amount_, flags);
        }
        return super._transfer(source_, target_, amount_ - fee);
    }

    function _processTransfer(address source_, uint amount_, uint flags_) internal returns (uint) {
        if (_checkFlags(flags_, SOURCE_IS_LIQUIDITY_PAIR, 0)) {
            // if the source is a liquidity pair, then the transfer is a sell
            amount_ = _calculatePercentage(amount_, _feesAndAllocations.buyFee);
            _burn(source_, _calculatePercentage(amount_, _feesAndAllocations.burnAllocation));
            uint marketingTokens = _calculatePercentage(amount_, _feesAndAllocations.marketingAllocation);
            super._transfer(source_, address(this), marketingTokens);
            _marketingBalance += marketingTokens;
        } else {
            amount_ = _calculatePercentage(amount_, _checkFlags(flags_, TARGET_IS_LIQUIDITY_PAIR, 0) ? _feesAndAllocations.sellFee : _feesAndAllocations.transferFee);
            if (!_executeLiquidityInjection()) {
                _executeSwap();
            }
            if (amount_ > 0) {
                super._transfer(source_, address(this), amount_);
                _marketingBalance += _calculatePercentage(amount_, _feesAndAllocations.marketingAllocation);
            }
        }
        return amount_;
    }

    function _calculatePercentage(uint amount_, uint32 percentage_) internal pure returns (uint) {
        return amount_ * percentage_ / PRECISION;
    }

    function _executeSwap() internal returns (bool) {
        uint totalTokenBalance = _balanceOf(address(this));
        uint currentBalance = address(this).balance;
        try _router.swapExactTokensForETHSupportingFeeOnTransferTokens(totalTokenBalance, 0, _path, address(this), block.timestamp) {
            uint marketingRatio = _marketingBalance * 10 ** 18 / totalTokenBalance;
            (bool success,) = payable(_marketingAddress).call{value: (address(this).balance - currentBalance) * marketingRatio / 10 ** 18}("");
            if (!success) revert PaymentFailed();
            _marketingBalance = 0;
        } catch {}
        return false;
    }

    function _executeLiquidityInjection() internal returns (bool) {
        uint liquidityTokenBalance = _balanceOf(address(this));
        if (liquidityTokenBalance > 0) {
            uint balance = address(this).balance;
            if (balance > 0) {
                uint thisTokenBalance = _balanceOf(address(this)) - _marketingBalance;
                try _router.addLiquidityETH{value: balance}(address(this), liquidityTokenBalance, 0, 0, address(this), block.timestamp + 1) {
                    return true;
                } catch {}
            }
        }
        return false;
    }

    function _assertSufficientBalance(address source_, uint amount_) internal view override(UsingERC20, UsingBatchTransfer) {
        return UsingERC20._assertSufficientBalance(source_, amount_);
    }

    function _getTransferFlags(address sender_, address source_, address target_) internal view returns (uint) {
        return _getFlags(address(this)) << 223 |  _getFlags(sender_) << 191 |  _getFlags(source_) << 159 | _getFlags(target_) << 127;
    }

    function _getDecimalStorage() internal pure override returns (uint8) {
        return 18;
    }

    function _getNameStorage() internal pure override(UsingERC20, UsingPermit) returns (string memory) {
        return "Jetset";
    }

    function _getSymbolStorage() internal pure override returns (string memory) {
        return "JET";
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override requires(msg.sender, ADMIN | DEVELOPER, 0) {}

}