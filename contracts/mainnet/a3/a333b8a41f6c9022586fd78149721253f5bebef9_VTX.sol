/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

// SPDX-License-Identifier: GPL-3.0

// File: contracts/interfaces/IERC20.sol

pragma solidity >=0.8.17;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// File: contracts\utils\Roles.sol

pragma solidity >=0.8.17;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

// File: contracts/interfaces/IVTXERC20.sol

pragma solidity >=0.8.17;

interface IVTXERC20 {

    event PairAdded(address indexed account);
    event MintedFrom(address indexed to, uint indexed value);
    event BurnedFrom(address indexed from, uint indexed value);

    function addPair (address account) external returns (bool);

    function mintFrom(address to, uint value) external returns (bool);
    
    function burnFrom(address from, uint value) external returns (bool);
}

// File: contracts/utils/VTXERC20.sol

pragma solidity >=0.8.17;

contract VTXERC20 is IERC20, IVTXERC20 {
    using Roles for Roles.Role;

    address public constant factory = 0x55E2778508B112e7a7fcFF011F5F67b812478dB9;
    address public pair;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint private _totalSupply;
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;

    bytes32 private _DOMAIN_SEPARATOR;
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 private constant _PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint) private _nonces; //Check functionality of nonces

    Roles.Role private _factory;
    Roles.Role private _pair;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) { 
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _factory.add(factory);
               
        uint chainId;
        assembly {
            chainId := chainid()
        }
        _DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(_name)),
                keccak256(bytes('1')),
                chainId,
                address(this)
            )
        );
    }

    modifier onlyFactory() {
        require(_factory.has(msg.sender), "ACCESS RESTRICTED TO FACTORY");
        _;
    }

    modifier onlyPair() {
        require(_pair.has(msg.sender), "ACCESS RESTRICTED TO PAIR");
        _;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
 
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return _DOMAIN_SEPARATOR;
    }

    function PERMIT_TYPEHASH() public view virtual returns (bytes32) {
        return _PERMIT_TYPEHASH;
    }

    function nonces(address account) public view virtual returns (uint256) {
        return _nonces[account];
    }

    function addPair (address account) external onlyFactory returns (bool) {
            //Only the factory address can call this function during pair creation
            _pair.add(account);
            pair = account;
            emit PairAdded(account);
            return true;
    }

    function _mintFrom(address to, uint256 value) internal {
        _totalSupply = _totalSupply + value;
        _balances[to] = _balances[to] + value;
        emit Transfer(address(0), to, value);
    }

    function _burnFrom(address from, uint256 value) internal {
        _totalSupply = _totalSupply - value;
        _balances[from] = _balances[from] - value;
        emit Transfer (from, address(0), value);
    }

    function mintFrom(address to, uint256 value) external onlyPair returns (bool) {
        //Only the pair address can mint tokens using this function
        _mintFrom(to, value);
        return true;
    }

    function burnFrom(address from, uint256 value) external onlyPair returns (bool) {
        //Only the pair address can burn tokens using this function
        _burnFrom(from, value);
        return true;
    }

    function _mint(address to, uint256 value) internal {
        _totalSupply = _totalSupply + value;
        _balances[to] = _balances[to] + value;
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {
        _balances[from] = _balances[from] - value;
        _totalSupply = _totalSupply - value;
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) private {
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {
        _balances[from] = _balances[from] - value;
        _balances[to] = _balances[to] + value;
        //TxSupplyMapping(address(this)).transferTxSupply(from, to, value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external returns (bool) {
        if (_allowances[from][msg.sender] != type(uint).max) {
            _allowances[from][msg.sender] = _allowances[from][msg.sender] - value;
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(deadline >= block.timestamp, 'EXPIRED');
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                _DOMAIN_SEPARATOR,
                keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, 'INVALID_SIGNATURE');
        _approve(owner, spender, value);
    }
}

// File: Context.sol

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

// File: Ownable.sol

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

// File: contracts/utils/VTX.sol

pragma solidity 0.8.17;

contract VTX is VTXERC20, Ownable {

    constructor(uint _totalSupply) 
        VTXERC20("VTX", "VTX", 18) {
        _mint(msg.sender, _totalSupply);
    }

    receive() external payable {}
    fallback() external payable {}

    function mint(address to, uint value) public onlyOwner {
        _mint(to, value);
    }

    function burn(address from, uint value) public onlyOwner {
        _burn(from, value);
    }
}

// File: contracts/utils/TxSupplyMapping.sol

pragma solidity >=0.8.17;

contract TxSupplyMapping {

    struct TxData {
        uint256 txBalance;
        uint256 txSupplyValue;
    }
    
    mapping(address => TxData[]) public txSupply;

    event Buy (address indexed holder, uint256 indexed TxTokenAmount, uint256 indexed TxPoolSupply);
    event Sell (address indexed holder, uint256 indexed TxTokenAmount);

    // Left shift each array element then remove the last element
    // Effectively the same as deleting the FIRST element in the storage array
    function leftShiftArray(address holder) internal {
        for (uint i; i < txSupply[holder].length -1 && txSupply[holder].length != 0; i++) {
            txSupply[holder][i] = txSupply[holder][i + 1];
            }
            txSupply[holder].pop();
    }

    function getTxSupplyLength(address holder) public virtual view returns (uint256 txSupplyLength) {
        return txSupply[holder].length;
    }

    function getTxBalanceAndSupply(address holder) public virtual view returns (TxData[] memory) {
        return txSupply[holder];
    }

    function getPrevTxBalanceAndSupply(address holder, uint16 step) public virtual view returns (uint256 txBalanceValue, uint256 txSupplyValue) {
        (txBalanceValue, txSupplyValue) = txSupply[holder].length > 0 && step <= txSupply[holder].length -1
                                        ? (txSupply[holder][step].txBalance, txSupply[holder][step].txSupplyValue)
                                        : (0, 0);
    }

    function updateTxBalanceAndSupply(address holder, uint256 txTokenAmount, uint256 newTxSupplyValue) internal virtual returns (bool) {
        txSupply[holder].push(TxData(txTokenAmount, newTxSupplyValue));
        emit Buy(holder, txTokenAmount, newTxSupplyValue);
        return true;
    }

    function updateTxBalanceOnSale(address holder, uint256 txTokenAmount) internal virtual returns (bool) {
        uint256 loggedTxTokenAmount = txTokenAmount; // Store txTokenAmount value before adjustment in function as a local variable
        if (txSupply[holder].length == 0) {
            emit Sell (holder, loggedTxTokenAmount);
            return true;
        }
        while (txSupply[holder].length > 0 && txTokenAmount > txSupply[holder][0].txBalance) {
                txTokenAmount = txTokenAmount - txSupply[holder][0].txBalance;
                leftShiftArray(holder);
                // Implement contingency in extemely unlikely situation whereby the transaction has so many iterations that max gas limit is reached
                if (txSupply[holder].length == 0) {
                    emit Sell (holder, loggedTxTokenAmount);
                    return true;
                } // Checks array length again after left shift + pop() and if it is now 0, emit Sell event and end this instance of function execution
                continue; // Otherwise, begin the next iteration of the "while" loop immediately
        } if (txTokenAmount < txSupply[holder][0].txBalance) {
            txSupply[holder][0].txBalance = txSupply[holder][0].txBalance - txTokenAmount;
            emit Sell (holder, loggedTxTokenAmount);
            return true;
        } else if (txTokenAmount == txSupply[holder][0].txBalance) {
            leftShiftArray(holder);
            emit Sell (holder, loggedTxTokenAmount);
            return true;
        } else {
            revert ("UpdateTxBalanceOnSaleFailed");
        }
    }

    function transferTxSupply(address from, address to, uint256 transferTokenAmount) internal returns (bool) {
        require(transferTokenAmount >= 10000000000000000, "VTX: INSUFFICIENT TRANSFER AMOUNT"); //In Wei (1*10**18)) so value is 0.01 ETH
        while (transferTokenAmount > 0) {
        for (uint16 step; txSupply[from].length != 0; step++) {
            transferTokenAmount;
            (uint256 prevTxBalance, uint256 prevTxSupply) = getPrevTxBalanceAndSupply(from, step);
            if (prevTxBalance == 0) {
                return true;
            }
            if (transferTokenAmount >= prevTxBalance && prevTxBalance > 0) {
                transferTokenAmount = transferTokenAmount - prevTxBalance;
                leftShiftArray(from);
                txSupply[to].push(TxData(prevTxBalance, prevTxSupply));
                continue;
            } else if (transferTokenAmount < prevTxBalance) {
                txSupply[from][step].txBalance = prevTxBalance - transferTokenAmount;
                txSupply[to].push(TxData(transferTokenAmount, prevTxSupply));
                return true;
            }
        }
        } return false;
    }
}