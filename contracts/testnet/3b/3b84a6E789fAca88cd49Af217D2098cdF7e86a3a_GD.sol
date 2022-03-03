/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract GD  is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _tTotal = 91000000 * 10**9;
    string private _name = "GD";
    string private _symbol = "GD";
    uint8 private _decimals = 9;
    mapping(address=>bool) public isPair;
    uint256 public _sellLpFee = 1;
    uint256 private _previousSellLpFee = _sellLpFee;
    uint256 public _gNodeFee = 4;
    uint256 private _previousGNodeFee = _gNodeFee;
    uint256 public _teamFee = 1;
    uint256 private _previousTeamFee = _teamFee;
    address public LpAddress = address(0x97311A7C827c07f1Cb2890834920664249B7e921);
    address public gNodeAddress = address(0x6cD8b8F12Da961E36898a7601ec7ab1A1D21bdbe );
    address public teamAddress = address(0xA57CCAAB5f233Cea91Fc77dc0d675b11683945fa);
    constructor() public {
         _balances[msg.sender] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
  
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }
  
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address from, address to, uint amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            removeAllFee();
        }
        uint256 toAmount = amount;
        if(isPair[from]){
            
            uint256 LpAmount = amount.mul(_sellLpFee).div(100);
            _takeLp(from,LpAmount);
            if(LpAmount>0){
                toAmount = toAmount.sub(LpAmount);
            }
            
            uint256 gNodeAmount = amount.mul(_gNodeFee).div(100);
            _takeOther(from,gNodeAmount,gNodeAddress);
            if(gNodeAmount>0){
                toAmount = toAmount.sub(gNodeAmount);
            }

            uint256 teamAmount = amount.mul(_teamFee).div(100);
            _takeOther(from,teamAmount,teamAddress);
            if(teamAmount>0){
                toAmount = toAmount.sub(teamAmount);
            }
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(toAmount);
        
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            restoreAllFee();
        }
        emit Transfer(from, to, toAmount);
    }
    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }
   
    function _takeLp(address sender,uint256 LpAmount) private {      
        _balances[LpAddress] = _balances[LpAddress].add(LpAmount);
        emit Transfer(sender, LpAddress, LpAmount);
    }

    function _takeOther(address sender,uint256 amount,address otaddress) private {
        _balances[otaddress] = _balances[otaddress].add(amount);
        emit Transfer(sender, otaddress, amount);
    }
    function removeAllFee() private {
        if (_sellLpFee==0 &&_gNodeFee==0 && _teamFee==0) return;
        _previousSellLpFee  = _sellLpFee;
        _previousGNodeFee  = _gNodeFee;
        _previousTeamFee  = _teamFee;

        _sellLpFee = 0;
        _gNodeFee = 0;
        _teamFee = 0;
    }
    function restoreAllFee() private {
        _sellLpFee = _previousSellLpFee;
        _gNodeFee = _previousGNodeFee;
        _teamFee = _previousTeamFee;
    }
    function setPair(address pairAddress) public onlyOwner{
        isPair[pairAddress] = true;
    }

}