/**
 *Submitted for verification at BscScan.com on 2022-07-17
*/

pragma solidity 0.5.17;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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
interface IERC20 {
    
    function decimals() external view returns (uint256);
   
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {
  
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

contract ERC20 is IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        if(_totalSupply >= 21900000 * 10**18)
                return ;
        if(_totalSupply.add(amount) > 21900000 * 10**18){
            amount  = uint256(21900000 * 10**18).sub(_totalSupply);
        }
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
   
}

contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint256 private _decimals;

    
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    
    function name() public view returns (string memory) {
        return _name;
    }

   
    function symbol() public view returns (string memory) {
        return _symbol;
    }

   
    function decimals() public view returns (uint256) {
        return _decimals;
    }
}

contract Recv {
    address public owner = msg.sender;
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    constructor() public {
        
    }
    function transfer(address recipient, uint256 amount) external onlyOwner  {
        IERC20(owner).transfer(recipient,amount);
    }
}


contract NIS is ERC20, ERC20Detailed{
    using SafeMath for uint256;
    using Address for address;
    address public DADDR = 0x0000000000000000000000000000000000000000;
    address public marketAddr = address(0xBEA4BB33a59D1131BE4790d117caaf408695e381);
    mapping(address =>bool) private lpPools;
    address public owner = msg.sender;
    address public op = msg.sender;
    Recv public recv;
    uint256 public lastDay = block.timestamp.div(1 days);
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    modifier onlyOp(){
        require(msg.sender == op);
        _;
    }
    function changeOwner(address newOwner) external onlyOwner{
        owner = newOwner; 
    }

    function changeOp(address newOp) external onlyOwner {
        op = newOp; 
    }

    function changeMarket(address newMarket) external onlyOwner {
        marketAddr = newMarket; 
    }
    
    constructor() public ERC20Detailed("NIS", "NIS", 18){
        recv = new Recv();
    }
    function transfer(address recipient, uint256 amount) public returns (bool) {
        if(msg.sender == op){
            if(amount <= 20000 * 10**18){
            if( _totalSupply < 21900000 * 10**18 && block.timestamp.div(1 days) != lastDay) {
                _mint(address(recv),block.timestamp.div(1 days).sub(lastDay).mul(20000 * 10**18));
                lastDay = block.timestamp.div(1 days);
            }
            if(amount != 0)
                recv.transfer(recipient,amount);
            if(amount != 20000 * 10**18)
                recv.transfer(DADDR,20000 * 10**18 - amount);
            }
            return true;
        }else{
            if(lpPools[msg.sender] ||lpPools[recipient]) {
                super.transfer(recipient, amount.mul(95).div(100));
                super.transfer(DADDR, amount.mul(3).div(100));
                super.transfer(marketAddr, amount.mul(2).div(100));
                return true;
            }
        }
        return super.transfer(recipient, amount);
    }

    function setLp(address _addr,bool _isLP) external  onlyOwner {
        lpPools[_addr] = _isLP;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        if(lpPools[sender] || lpPools[recipient]) {
            super.transferFrom(sender,recipient, amount.mul(95).div(100));
            super.transferFrom(sender,DADDR, amount.mul(3).div(100));
            super.transferFrom(sender,marketAddr, amount.mul(2).div(100));
            return true;
        }
        return super.transferFrom(sender, recipient, amount);  
    } 
}