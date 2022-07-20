/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: contracts/TFTC/TFTCContact.sol

//SPDX-License-Identifier:MIT
pragma solidity 0.8.4;

interface IBEP20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool success);

    function approve(
        address spender,
        uint256 amount
    ) external returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract TFTCToken is IBEP20, Ownable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimal_,
        uint256 totalSupply_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimal_;
        _totalSupply = (totalSupply_ * (10**18));
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    //Returns the token owner.
    function getOwner() external view virtual override returns (address) {
        return owner();
    }

    // Returns the token decimals.
    function decimals() external view virtual override returns (uint8) {
        return _decimals;
    }

    //Returns the token symbol.
    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }

    // Returns the token name.
    function name() external view virtual override returns (string memory) {
        return _name;
    }

    //Returns BEP20-totalSupply
    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }

    //Returns BEP20-balanceOf
    function balanceOf(address account)
        external
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    //this function returns remaining number of tokens that spender spend
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function transfer(address to, uint256 amount)
        external
        virtual
        override
        onlyOwner
        returns (bool)
    {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    //caller approves `spender` to spend amount of tokens
    function approve(
        address spender,
        uint256 amount
    ) external virtual override returns (bool) {
       _approve(_msgSender(), spender, amount);
        return true;
    }

    //Send amount of tokens from address sender to address recipient
    //The transferFrom method is used for a withdraw workflow,
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual override onlyOwner returns (bool) {
        require(
            _allowances[sender][_msgSender()] >= amount,
            "BEP20: insufficient allowance"
        );
        unchecked {
            _approve(
                sender,
                _msgSender(),
                _allowances[sender][_msgSender()] - amount
            );
        }
        _transfer(sender, recipient, amount);
        return true;
    }

    //Atomically increases the allowance granted to `spender` by the caller.
    //Emits an {Approval} event indicating the updated allowance.
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        onlyOwner
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            allowance(_msgSender(), spender) + addedValue
        );
        return true;
    }

    // Atomically decreases the allowance granted to `spender` by the caller.
    // Emits an {Approval} event indicating the updated allowance.
    function decreaseAllowance(address spender, uint256 decreasedValue)
        public
        virtual
        onlyOwner
        returns (bool)
    {
        uint256 currentAllowance = allowance(_msgSender(), spender);
        require(
            currentAllowance >= decreasedValue,
            "BEP20: decreased allowance below current allowance"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - decreasedValue);
        }

        return true;
    }

    //Creates `amount` tokens and assigns them to `msg.sender`, increasing the total supply
    //Caller must be the token owner
    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

    //Internal function moves tokens `amount` from `sender` to `recipient`.
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(
            _balances[from] >= amount,
            "BEP20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = _balances[from] - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    //Creates `amount` tokens and assigns them to `account`, increasing
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    //Destroys `amount` tokens from `account`, reducing the
    //total supply.
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        require(
            _balances[account] >= amount,
            "BEP20: burn amount exceeds balance"
        );
        unchecked {
            _balances[account] = _balances[account] - amount;
            _totalSupply = _totalSupply - amount;
        }

        emit Transfer(account, address(0), amount);
    }

    //Internal function sets `amount` as the allowance of `spender` over the `owner`s tokens.
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    //Destroys `amount` tokens from `account`.`amount` is then deducted
    function _burnFrom(address account, uint256 amount) internal {
        require(
            _allowances[account][_msgSender()] >= amount,
            "BEP20: burn amount exceeds allowance"
        );

        _burn(account, amount);

        unchecked {
            _approve(
                account,
                _msgSender(),
                _allowances[account][_msgSender()] - amount
            );
        }
    }
}