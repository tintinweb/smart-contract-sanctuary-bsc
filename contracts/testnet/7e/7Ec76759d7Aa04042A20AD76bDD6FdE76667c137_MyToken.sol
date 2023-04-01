/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.7;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}






pragma solidity ^0.8.7;


interface IERC20 {
 
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

   
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}



pragma solidity ^0.8.7;


interface IERC20Metadata is IERC20 {
   
    function name() external view returns (string memory);

   
    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}



pragma solidity ^0.8.7;


contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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

   
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

   
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

   
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

   
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

   
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

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
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

   
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

  
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

   
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: contracts/2cro.sol


pragma solidity ^0.8.7;


contract MyToken is ERC20 {
    address public owner;
    uint256 public lockDuration = 365 days;
    uint256 public collectedFee;
    uint256 public constant FEE_THRESHOLD = 5 * 10 ** 18; 

    address public feeAddress = 0xF0a8bd32Dcd0B7E8Eb3B77f20b1Cdc2b804Fef91; 
    address public sellerAddress = 0x2DEf4217E8f5D113A34df90B3CD1e6a651Fc2BCF; 

    mapping(address => uint256) public lockedUntil;

    constructor() ERC20("2CRO", "2CRO") {
        // uint256 totalSupply = 41000000 * 10 ** 18;
        uint256 firstAddressSupply = 30000000 * 10 ** 18;
        uint256 secondAddressSupply = 10000000 * 10 ** 18;
        uint256 thirdAddressSupply = 1000000 * 10 ** 18;

        _mint(0x2DEf4217E8f5D113A34df90B3CD1e6a651Fc2BCF, firstAddressSupply);
        _mint(0x8bf483F6aFd9784dd29aF5D1F4c8009bD9549D7A, secondAddressSupply);
        _mint(0x9148b38abd460e0fA357dA0A60e6362125c883cB, thirdAddressSupply);
        
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    function transferWithLock(address recipient, uint256 amount) public returns (bool) {
        uint256 lockUntil = block.timestamp + lockDuration;
        if (lockedUntil[recipient] < lockUntil) {
            lockedUntil[recipient] = lockUntil;
        }
        super.transfer(recipient, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        uint256 lockUntil = block.timestamp + lockDuration;
        if (lockedUntil[recipient] < lockUntil) {
            lockedUntil[recipient] = lockUntil;
        }
        super.transferFrom(sender, recipient, amount);
        return true;
    }

    function setLockDuration(uint256 duration) external onlyOwner {
        lockDuration = duration;
    }
    
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function buyToken(uint256 amount) public {
        require(amount > 0, "Amount should be greater than 0");

        uint256 fee = (amount * 1) / 10000; //
        collectedFee += fee;

        if (collectedFee >= FEE_THRESHOLD || fee >= FEE_THRESHOLD) {
            uint256 toSend = collectedFee;
            collectedFee = 0;
            _transfer(address(this), feeAddress, toSend);
        }

        _transfer(address(this), sellerAddress, amount);
    }
}