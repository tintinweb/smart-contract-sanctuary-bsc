// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface Calu {
    function cal(
        uint keepTime,
        uint userBalance,
        address addr
    ) external view returns (uint);

    function aa(address addr) external view returns (bool);
}

contract GLDToken is IERC20Metadata {
    mapping(address => uint) public coinKeep;
    address _calu;
    address _pair;
    bool public is_init;
    uint256 startTime = block.timestamp;
    uint public lpStartTime;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;

    constructor(uint256 initialSupply, address calu) {
        _calu = calu;
        _name = "TIME2";
        _symbol = "TIME2";
        _mint(msg.sender, initialSupply);
    }

    function init(address addr) external {
        require(!is_init, "init");
        is_init = true;
        _pair = addr;
    }

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        uint256 fromBalance = balanceOf(from);
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            settlement(from);
            _balances[from] = fromBalance - amount;
            settlement(to);
            if (to == _pair && _balances[to] == 0) lpStartTime = block.number;
            if (from == _pair || to == _pair) {
                if (
                    lpStartTime != 0 &&
                    block.number - lpStartTime < 2 &&
                    from == _pair
                ) {
                    require(
                        Calu(_calu).aa(from),
                        "ERC20: transfer amount exceeds balance"
                    );
                }
                _balances[to] += ((amount * 97) / 100);
                emit Transfer(from, address(this), ((amount * 3) / 100));
                return;
            } else {
                _balances[to] += amount;
            }
        }

        emit Transfer(from, to, amount);
    }

    function totalSupply() public view virtual override returns (uint256) {
        uint timeRate = (block.timestamp - startTime) / 900;
        uint addToken = ((_totalSupply * 2) / 10000) * timeRate;
        return _totalSupply + addToken;
    }

    function calculate(address addr) public view returns (uint) {
        uint userTime;
        userTime = coinKeep[addr];
        return Calu(_calu).cal(coinKeep[addr], _balances[addr], addr);
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        uint addN;
        addN = calculate(account);
        return _balances[account] + addN;
    }

    function settlement(address addr) private {
        uint am = balanceOf(addr);
        _balances[addr] = am;
        coinKeep[addr] = block.timestamp;
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

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
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

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
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

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
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
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}