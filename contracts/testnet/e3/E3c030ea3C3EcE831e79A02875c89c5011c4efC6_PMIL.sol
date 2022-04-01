/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-29
*/

pragma solidity ^0.8.0;

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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
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

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract PMIL is Ownable {
    using SafeMath for uint256;

    uint256 public totalSupply;
    mapping(address => uint256) public balances;
    
    mapping (address => uint256) public IDOBalance;
    uint256 public IDOTotal;

    address mainnetAddress = 0xc362B3ed5039447dB7a06F0a3d0bd9238E74d57c;
    address usdtAddress = 0xc362B3ed5039447dB7a06F0a3d0bd9238E74d57c;
    // address usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
    
    address receiver = 0x03E23B1fEbceAFBFEE0e57cbe38014F3780d082e;
    address[] public participants;
    
    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;
    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);
    event AttendIDO(address addr, uint256 amount, uint256 time);

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        _mint(msg.sender, msg.value.mul(10).div(22));
        IDOTotal = IDOTotal.add(msg.value);
        IDOBalance[msg.sender] = IDOBalance[msg.sender].add(msg.value);
        if (IDOBalance[msg.sender] == 0) {
            participants.push(msg.sender);
        }
        emit AttendIDO(msg.sender, msg.value, block.timestamp);
    }

    function withdraw(uint wad) public {
        require(balanceOf[msg.sender] >= wad, "Not enough balance");
        balanceOf[msg.sender] -= wad;
        transfer(payable(msg.sender), wad);
        emit Withdrawal(msg.sender, wad);
    }

    function balance() public view returns (uint) {
        return address(this).balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        require(balanceOf[src] >= wad);
        if (src != msg.sender && allowance[src][msg.sender] != uint(0)-1) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }
        balanceOf[src] -= wad;
        balanceOf[dst] += wad;
        emit Transfer(src, dst, wad);
        return true;
    }

    function getParticipants() public view  returns (address[] memory) {
        return participants;
    }

    function getIDOBalance(address _addr) public view returns (uint256) {
        return IDOBalance[_addr];
    }

    function withdraw() public onlyOwner {
        IERC20(usdtAddress).transfer(receiver, IERC20(usdtAddress).balanceOf(address(this)));
        withdraw(balance());
    }
    
    function attendIDO( uint256 amount) external returns (bool){
        IERC20(usdtAddress).transferFrom(msg.sender, receiver, amount);
        _mint(msg.sender, amount.mul(10).div(22));
        if (IDOBalance[msg.sender] == 0) {
            participants.push(msg.sender);
        }
        IDOTotal = IDOTotal.add(amount);
        IDOBalance[msg.sender] = IDOBalance[msg.sender].add(amount);
 
        return true;
    }

    function swapForToken(uint256 amount) external {
        _burn(msg.sender, amount);
        IERC20(usdtAddress).transferFrom(msg.sender, address(this), 1e18);
        IERC20(mainnetAddress).transfer(msg.sender, 1e18);
    }
    
    function setUsdtAddress(address _addr) onlyOwner external{
        usdtAddress = _addr;
    }

    function setReceiver(address _addr) onlyOwner external{
        receiver = _addr;
    }
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        totalSupply = totalSupply.add(amount);
        balances[account] = balances[account].add(amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        balances[account] = balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        totalSupply = totalSupply.sub(amount);
    }

}