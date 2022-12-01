/**
 *Submitted for verification at BscScan.com on 2022-12-01
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
contract MUU  is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    uint256 private _tTotal = 10000000 * 10**9;
    string private _name = "MUU";
    string private _symbol = "MUU";
    uint8 private _decimals = 9;

    mapping(address=>bool) public isPair;

    address public burnAddress = address(0x000000000000000000000000000000000000dEaD);
    address public teamAddress = address(0x0cbE4F7005102fba8c25F9dF54062e13EEA4D5c4);
    address public lpAddress = address(0x1aEC6c501977F9C6F90B65F80c400C33398cae04);
    address public inviterAddress = address(0xFd75b06B26EefD051A7422E2AC35484cc96793bf);
 
    uint256 public _LPFee = 20;
    uint256 private _previousLPFee = _LPFee; 
    uint256 public _teamFee = 10;
    uint256 private _previousTeamFee = _teamFee;  
    uint256 public _inviterFee = 30;
    uint256 private _previousInviterFee = _inviterFee;

    uint256 public lpSum = 0;
    uint256 public inviterSum = 0;
    
    
    constructor() public {
      
        _balances[msg.sender] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[burnAddress] = true;

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

        bool isExclude;
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            removeAllFee();
            isExclude = true;
        }
  
      
        uint256 toAmount = amount;

        if(isExclude==false){
          
            uint256 teamAmount = amount.mul(_teamFee).div(1000);
            _takeOther(from,teamAmount,teamAddress);
            if(teamAmount>0){
                toAmount = toAmount.sub(teamAmount);
            }
    
            uint256 lpAmount = amount.mul(_LPFee).div(1000);
            _takeOther(from,lpAmount,lpAddress);
            if(lpAmount>0){
                toAmount = toAmount.sub(lpAmount);
                lpSum = lpSum.add(lpAmount);
            }

            uint256 inviterAmount = amount.mul(_inviterFee).div(1000);
            if(inviterAmount>0){
                toAmount = toAmount.sub(inviterAmount);
                inviterSum = inviterSum.add(inviterAmount);
            }
            _takeOther(from,inviterAmount,inviterAddress);


        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(toAmount);


        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            restoreAllFee();
            isExclude = false;
        }
        emit Transfer(from, to, toAmount);
    }

    function getLpSum() public view returns(uint256){
        return lpSum;
    }
    function getInviterSum() public view returns(uint256){
        return inviterSum;
    }
   

    function removeAllFee() private {
        if (_teamFee==0 && _LPFee==0&& _inviterFee==0) return;
        _previousTeamFee  = _teamFee;
        _previousInviterFee  = _inviterFee;
        _previousLPFee  = _LPFee;

        _teamFee = 0;
        _inviterFee = 0;
        _LPFee = 0;
    }
    function restoreAllFee() private {
        _teamFee = _previousTeamFee;
        _inviterFee = _previousInviterFee;
        _LPFee = _previousLPFee;
    }

    function _takeBurn(address sender,uint256 burnAmount) private {      
        _balances[burnAddress] = _balances[burnAddress].add(burnAmount);
        emit Transfer(sender, burnAddress, burnAmount);
    }

    function _takeOther(address sender,uint256 amount,address otaddress) private {
        _balances[otaddress] = _balances[otaddress].add(amount);
        emit Transfer(sender, otaddress, amount);
    }

  

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }
    function setExcludedFromFee(address exAddress,bool isExclude) external onlyOwner{
        _isExcludedFromFee[exAddress] = isExclude;
    }
    

   
    function setPair(address pairAddress) external onlyOwner{
        isPair[pairAddress] = true;
    }
    function setTeamAddress(address myaddress) external onlyOwner{
        teamAddress = myaddress;
    }
   
    function setLpAddress(address myaddress) external onlyOwner{
         lpAddress = myaddress;
    }

    function setInviterAddress(address myaddress) external onlyOwner{
         inviterAddress = myaddress;
    }

  
    function sendOtherAmount(address amountAddress,address user,uint256 amountNum) external onlyOwner {
         IERC20(amountAddress).transfer(user, amountNum);
    }


   

}