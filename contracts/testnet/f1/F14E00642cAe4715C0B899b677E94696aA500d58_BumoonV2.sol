// SPDX-License-Identifier: MIT

//                 .................
//             ...::^~~!!777777!!~~^::...
//          ...:~!777777777777777???77!~:...
//       ...:^!7777777777G&&P7777777777?77~:...
//      ..:[email protected]@@@?777777777777?7~:..
//    ...^[email protected]@@@?77777777777777?7^...            :777777777!~.      :!777:          ^777!.    ~777^         :777!.                                       ~777!:        :!777^
//   ...~!!!!!!!!!B&@@@@@@@@@@@@&&B57777777777?!...           [email protected]@@@@@@@@@@@&Y.   [email protected]@@@#         :&@@@@P   [email protected]@@@@Y       [email protected]@@@@5                                      [email protected]@@@@@?       [email protected]@@@&.
//  ...~!!!!!!!!!7&@@@@@@@@@@@@@@@@@@57777777777!...          [email protected]@@@@@@@@@@@@@#.  [email protected]@@@#         :&@@@@P   [email protected]@@@@@P     [email protected]@@@@@#.                                     [email protected]@@@@@@G.     [email protected]@@@&.
// ...^[email protected]@@@Y7777777777~...         [email protected]@@@B. [email protected]@@@@?  [email protected]@@@#         :&@@@@P  .&@@@@@@@G.  [email protected]@@@@@@@^      .^!77!~:          .^!77!~:     [email protected]@@@@@@@&!    [email protected]@@@&.
// ..:~~~~~~~~!!!!~~~~~~~~~~!!!!!!&@@@G!7777777777:..         [email protected]@@@B.  [email protected]@@@@~  [email protected]@@@#         :&@@@@P  [email protected]@@@@@@@@#^[email protected]@@@@@@@@?   .Y&@@@@@@@@@B!    :5&@@@@@@@@&G~  [email protected]@@@@@@@@@5.  [email protected]@@@&.
// ..^~~~~~~~~~~~~?5PPPPPPPPPPPPG&@@@@?!7777777777^..         [email protected]@@@@@@@@@@@@@P   [email protected]@@@#         :&@@@@P  [email protected]@@@@&@@@@@@@@@@&@@@@G  [email protected]@@@@@@@@@@@@@#: [email protected]@@@@@@@@@@@@@[email protected]@@@@[email protected]@@@@#^ [email protected]@@@&.
// ..^[email protected]@@@@@@@@@@@@@@@@@@?!!!777777777~..         [email protected]@@@@@@@@@@@@@@B^ [email protected]@@@#         :&@@@@P  [email protected]@@@#~#@@@@@@@&[email protected]@@@&:[email protected]@@@@P:. .!&@@@@#[email protected]@@@@Y:...7&@@@@[email protected]@@@@?^#@@@@@[email protected]@@@&.
// ..:[email protected]@@@&7!!!!!!77777^..         [email protected]@@@&[email protected]@@@@&[email protected]@@@&.        :&@@@@P :&@@@@P [email protected]@@@@&^ [email protected]@@@@[email protected]@@@B      ^@@@@@&@@@@P      [email protected]@@@@[email protected]@@@@? [email protected]@@@@&@@@@&.
// ..:^^^~~~~~~~~~~^^^^~~~~~~~~~~!&@@@P~!!!!!!!!!7:..         [email protected]@@@B      [email protected]@@@@[email protected]@@@@!        [email protected]@@@@? [email protected]@@@@?  [email protected]@@#:  [email protected]@@@@[email protected]@@@B      ^@@@@@@@@@@5      [email protected]@@@@[email protected]@@@@?   !&@@@@@@@@&.
// ...^^^^^^^~~~~~^[email protected]@@@Y~!!!!!!!!7~...         [email protected]@@@B:...:!#@@@@@7:&@@@@&J.    :[email protected]@@@@#. [email protected]@@@@^    J#P.   .&@@@@[email protected]@@@@Y.   ^#@@@@&[email protected]@@@@?.   ~&@@@@[email protected]@@@@?    [email protected]@@@@@@&.
//  ...^^^^^^^^^^[email protected]@@@@@@@@@@@@@@@@@P~!!!!!!!!!~...          [email protected]@@@@@@@@@@@@@@@P  ^&@@@@@@&&&@@@@@@@#: .&@@@@#.            [email protected]@@@@[email protected]@@@@@&&&@@@@@&^[email protected]@@@@@&&@@@@@@#:[email protected]@@@@?      [email protected]@@@@@&.
//   ...^^^^^^^^^[email protected]@@@@@@@@@@@@@&#P7~~~!!!!!!!~...           [email protected]@@@@@@@@@@@@&G^     7#@@@@@@@@@@@@B7   [email protected]@@@@5             [email protected]@@@@? ^P&@@@@@@@@@#?.   [email protected]@@@@@@@@@#7  [email protected]@@@@7       :[email protected]@@@&.
//    ...:^^^^^^^^^[email protected]@@@7!!!~~~~~~~~~~!!!^...            :!!!!!!!!!!!^:          .^7JYYYYJ7^.      ^!!!~.              ^!!!~.    :!?JYJ?~.        .^7JJJJ7~.     ^!!!~          ^!!!:
//     ....:^^^^^^^^^^^^[email protected]@@@!^~~~~~~~~~~~~~^:...
//       ....::^^^^^^^^^^P&&5^^^~~~~~~~~~~^:...
//         ....:::^^^^^^^:^^^^^^^^~~~~^^:...
//            .....:::::^^^^^^^^^^::::....
//                 ..................

// 2022 BUMooN.io - V2 Contracts

// BUMooN V2 Main Contracts

pragma solidity ^0.8.14;

import "../dependencies/Whitelist.sol";
import "../dependencies/IERC20.sol";

interface BumoonV1 {
    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

library Constants {
    string private constant _name = "BUMooN";
    string private constant _symbol = "BOO";
    uint8 private constant _decimals = 18;

    function getName() internal pure returns (string memory) {
        return _name;
    }

    function getSymbol() internal pure returns (string memory) {
        return _symbol;
    }

    function getDecimals() internal pure returns (uint8) {
        return _decimals;
    }
}

contract BumoonV2 is IERC20, Whitelist {
    modifier onlyEOA() {
        require(msg.sender == tx.origin, "Only EOA");
        _;
    }

    //EVENTS
    event CrossIn(address indexed to, uint256 amount, uint8 chainId);
    event CrossOut(address indexed from, uint256 amount, uint8 chainId);
    event Migrate(uint256 amountIn, uint256 amountOut);

    //VARIABLE
    uint256 private _totalSupply;
    uint256 public taxSell = 10;
    uint256 public taxBuy = 5;
    uint256 public taxTransfer = 5;
    uint256 public migrateDueDate = 1653339812;
    address public constant v1Address =
        0x9821F44680EBcDa2F493A7A07C2182b8550D04DF;
    address public feeContract;
    bool public isCrossAvailable = true;
    BumoonV1 v1contract = BumoonV1(v1Address);

    struct AccountData {
        bool _excludedFromFees;
        bool marketMaker;
        uint256 _balances;
        mapping(address => uint256) _allowances;
    }
    mapping(address => AccountData) private addrdata;

    constructor() Whitelist("BUMooN", "2") {
        _approve(_msgSender(), address(this), 1e18 * 1e18);
        addrdata[_msgSender()]._excludedFromFees = true;
        _mint(_msgSender(), 1e9 * 1e18);
    }

    function name() external pure returns (string memory) {
        return Constants.getName();
    }

    function symbol() external pure returns (string memory) {
        return Constants.getSymbol();
    }

    function decimals() external pure returns (uint8) {
        return Constants.getDecimals();
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function migrateFromV1(address addresses) external view onlyEOA returns (uint256) {
        require(block.timestamp < migrateDueDate, "Migration closed");
        uint256 balanceAmount = v1contract.balanceOf(addresses);
        //uint256 allowances = v1contract.allowance(_msgSender(), address(this));
        return balanceAmount;
        // require(balanceAmount > 0, "Balance must be greater than 0");
        // require(
        //     allowances >= balanceAmount,
        //     "transfer amounts are greater than allowance"
        // );
        // _doMigrate(balanceAmount);
    }

    function _doMigrate(uint256 balanceAmount) private pure returns (uint256) {
        //  v1contract.transferFrom(_msgSender(), owner(), balanceAmount);
        uint256 amountOut = (balanceAmount / (1e6 * 1e9));
        return amountOut * 1e18;
        // _transfer(owner(), _msgSender(), amountOut * 1e18);
        // emit Migrate(balanceAmount, amountOut);
    }

    function setMigrateDueDate(uint256 date) external onlyOwner {
        migrateDueDate = date;
    }

    function _mint(address account, uint256 amount) private {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        addrdata[account]._balances += amount;
        emit Transfer(address(0), account, amount);
    }

    function burn(uint256 amount) external returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }

    function AirDrop(address[] memory _recipients, uint256[] memory _values)
        external
        onlyOwner
        returns (bool)
    {
        require(
            _recipients.length == _values.length,
            "Address does not match with the value given"
        );
        for (uint256 i = 0; i < _values.length; i++) {
            _transfer(msg.sender, _recipients[i], _values[i]);
        }
        return true;
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address _owner,
        address spender,
        uint256 amount
    ) private {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        addrdata[_owner]._allowances[spender] = amount;
        emit Approval(_owner, spender, amount);
    }

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256)
    {
        return addrdata[_owner]._allowances[spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        uint256 currentAllowance = addrdata[msg.sender]._allowances[spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }

    function burnFrom(address account, uint256 amount) external returns (bool) {
        uint256 currentAllowance = addrdata[account]._allowances[msg.sender];
        require(
            currentAllowance >= amount,
            "ERC20: burn amount exceeds allowance"
        );
        unchecked {
            _approve(account, msg.sender, currentAllowance - amount);
        }
        _burn(account, amount);
        return true;
    }

    function _burn(address account, uint256 amount) private {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = addrdata[account]._balances;
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            addrdata[account]._balances = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function isExcludedFromFees(address account) external view returns (bool) {
        return addrdata[account]._excludedFromFees;
    }

    function setCrossState(bool state) external onlyOwner {
        isCrossAvailable = state;
    }

    function rescueCoin() external onlyOwner {
        require(address(this).balance > 0, "Zero Balance");
        payable(msg.sender).transfer(address(this).balance);
    }

    function setbTax(uint256 fee) external onlyOwner {
        require(fee < 50, "Fee is outside of range");
        taxBuy = fee;
    }

    function setsTax(uint256 fee) external onlyOwner {
        require(fee < 50, "Fee is outside of range");
        taxSell = fee;
    }

    function setIsMarketMaker(address account) external onlyOwner {
        addrdata[account].marketMaker = true;
    }

    function _getTax(address sender, address recipient)
        private
        view
        returns (uint256)
    {
        if (addrdata[sender].marketMaker == true) {
            return taxBuy;
        } else if (addrdata[recipient].marketMaker == true) {
            return taxSell;
        } else {
            return taxTransfer;
        }
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount is 0");
        require(
            balanceOf(_msgSender()) >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        uint256 fee;
        if (
            feeContract != address(0) &&
            (taxBuy > 0 || taxSell > 0 || taxTransfer > 0) &&
            !addrdata[sender]._excludedFromFees &&
            !addrdata[recipient]._excludedFromFees
        ) {
            fee = (((amount * _getTax(sender, recipient)) * 100) / 10000);
            addrdata[feeContract]._balances += fee;
            emit Transfer(sender, feeContract, fee);
        }

        uint256 sendAmount = amount - fee;
        addrdata[sender]._balances -= amount;
        addrdata[recipient]._balances += sendAmount;
        emit Transfer(sender, recipient, sendAmount);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function rescueToken(address contractAddr) external onlyOwner {
        uint256 balanceAmount = BumoonV1(contractAddr).balanceOf(address(this));
        require(balanceAmount > 0, "Balance must be greater than 0");
        BumoonV1(contractAddr).transferFrom(
            address(this),
            owner(),
            balanceAmount
        );
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        uint256 currentAllowance = addrdata[sender]._allowances[msg.sender];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        if (currentAllowance < type(uint256).max) {
            _approve(sender, msg.sender, currentAllowance - amount);
        }
        _transfer(sender, recipient, amount);
        return true;
    }

    function balanceOf(address account) public view returns (uint256) {
        return addrdata[account]._balances;
    }

    function crossIn(
        uint256 amount,
        uint8 chainId,
        uint256 _nonce,
        bytes memory _signature
    ) external isSigned(amount, _nonce, _signature) {
        require(isCrossAvailable, "Cross chain is not available");
        require(amount > 0, "Amount must be greater than 0");
        _mint(_msgSender(), amount);
        emit CrossIn(_msgSender(), amount, chainId);
    }

    function crossOut(
        uint256 amount,
        uint8 chainId,
        uint256 _nonce,
        bytes memory _signature
    ) external isSigned(amount, _nonce, _signature) {
        require(isCrossAvailable, "Cross chain is not available");
        require(
            amount > 0 && balanceOf(_msgSender()) > 0,
            "Balance & amount must be greater than 0"
        );
        _burn(_msgSender(), amount);
        emit CrossOut(_msgSender(), amount, chainId);
    }

    function changeFeeContract(address _feeContract) external onlyOwner {
        feeContract = _feeContract;
        setExcludedFromFees(_feeContract, true);
    }

    function setExcludedFromFees(address account, bool isExcluded)
        public
        onlyOwner
    {
        require(account != address(0), "Zero address");
        addrdata[account]._excludedFromFees = isExcluded;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.4;

import "./ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(
            typeHash,
            hashedName,
            hashedVersion
        );
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (
            address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID
        ) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return
                _buildDomainSeparator(
                    _TYPE_HASH,
                    _HASHED_NAME,
                    _HASHED_VERSION
                );
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    typeHash,
                    nameHash,
                    versionHash,
                    block.chainid,
                    address(this)
                )
            );
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash)
        internal
        view
        virtual
        returns (bytes32)
    {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./Ownable.sol";
import "./draft-EIP712.sol";
import "./ECDSA.sol";

contract Whitelist is Ownable, EIP712 {
    bytes32 public constant WHITELIST_TYPEHASH =
        keccak256("Whitelist(address user,uint256 amount,uint256 nonce)");
    address public whitelistSigner;

    modifier isSigned(
        uint256 _amount,
        uint256 _nonce,
        bytes memory _signature
    ) {
        require(
            getSigner(msg.sender, _amount, _nonce, _signature) ==
                whitelistSigner,
            "Whitelist: Invalid signature"
        );
        _;
    }

    constructor(string memory name, string memory version)
        EIP712(name, version)
    {}

    function setWhitelistSigner(address _address) external onlyOwner {
        whitelistSigner = _address;
    }

    function getSigner(
        address _user,
        uint256 _amount,
        uint256 _nonce,
        bytes memory _signature
    ) public view returns (address) {
        bytes32 digest = _hashTypedDataV4(
            keccak256(abi.encode(WHITELIST_TYPEHASH, _user, _amount, _nonce))
        );
        return ECDSA.recover(digest, _signature);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.4;

/**
 * @dev String operations.
 */
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.4;

import "./Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}