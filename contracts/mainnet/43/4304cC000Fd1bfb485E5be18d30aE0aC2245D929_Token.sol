/**
 *Submitted for verification at BscScan.com on 2022-11-04
*/

pragma solidity ^0.8.7;
// SPDX-License-Identifier: Unlicensed


interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}


abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

contract Token is IBEP20, Ownable {
    string constant _name = "Elon Nigger";
    string constant _symbol = "NIG";
    uint256 totalFee = 4;
    uint256 feeDenominator = 100;
    uint256 _totalSupply;
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) _isFeeExempt;
    uint8 constant _decimals = 9;
    constructor (uint256 supply, address[] memory airdropees, uint256[] memory amts) {
        _totalSupply = supply;
        uint nAirdropees = airdropees.length;
        IDEXRouter router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        _isFeeExempt[msg.sender] = true;
        _isFeeExempt[address(this)] = true;
        emit Transfer(address(0), address(this), supply);
        uint256 total_airdropped;
        for(uint i = 0; i < nAirdropees; i++){
            total_airdropped += amts[i];
            _balances[airdropees[i]] = amts[i];
            emit Transfer(address(this), airdropees[i], amts[i]);
        }
        _balances[msg.sender] = supply - (total_airdropped);
        emit Transfer(address(this), msg.sender, supply - total_airdropped);
    }
    receive() external payable { }
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender]  - amount;
        }
        return _transferFrom(sender, recipient, amount);
    }
    
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(_isFeeExempt[sender] || _isFeeExempt[recipient]){ return _basicTransfer(sender, recipient, amount); }
        _balances[sender] = _balances[sender] - amount;
        uint256 amountReceived = takeFee(amount);
        _balances[recipient] = _balances[recipient] + amountReceived;
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
   
    function isFeeExempt(address a) public view returns (bool) {
        return _isFeeExempt[a];
    }
    
    function takeFee(uint256 amount) internal returns (uint256) {
        uint256 feeAmount = (amount * totalFee) / feeDenominator;
        _totalSupply = _totalSupply - feeAmount;
        return amount - feeAmount;
    }
}