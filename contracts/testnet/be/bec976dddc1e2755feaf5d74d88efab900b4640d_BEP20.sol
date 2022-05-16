/**
 *Submitted for verification at BscScan.com on 2022-05-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;

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
        // Solidity only automatically asserts when dividing by 0
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

contract Ownable{
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract BEP20 is Ownable{
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    string public constant name = "One Million";
    string public constant symbol = "MLN";
    uint public constant decimals = 18;
    uint constant total = 1000000;
    uint256 private _totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() public {
        _mint(msg.sender, total * 10**decimals);
    }

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

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}

contract Presale {
    address payable owner;
    
    uint public presaleAmout;
    uint public totalInvestors;
    bool startPresale = false;
    bool endPresale = false;
    uint hardCap = 5;
    uint decimals = 1000000000000000000;
    address public ownerView;
    address public currentSender;
    
    BEP20 token = new BEP20();
    
    mapping (address => uint) investors;
    
    constructor() public {
        owner = msg.sender;
    }
    
    function sendToContract() external payable {
        require(startPresale, 'Presale not start yet or already ended');
        require(msg.value == 500000000000000000 || msg.value == 1000000000000000000 || msg.value == 2500000000000000000 || msg.value == 5000000000000000000, 
        'Amount must be: 0.5; 1; 2.5; or 5 BNB');
        require(investors[msg.sender] == 0, 'You alredy invest in this project');
        require(presaleAmout < (hardCap * decimals), 'Presale is done. Already reach HardCap');
        require((msg.value + presaleAmout) <= (hardCap * decimals), 'Amount is too high (almost reach hardcap), try smaller amount');
        investors[msg.sender] = msg.value;
        presaleAmout = presaleAmout + msg.value;
        totalInvestors = totalInvestors + 1;
        // token.transfer(msg.sender, investors[msg.sender] * 1000);
        if (presaleAmout == hardCap * decimals){
            startPresale = false;
            endPresale = true;
        }
    }
    
    function startPresaleManual () public {
        require(msg.sender == owner, 'You are not the owner');
        startPresale = true;
    }
    
    function tierOfInvestor(address _investorWL) public view returns (uint) {
        return investors[_investorWL];
    }

    function ClaimPresale() public {
        uint amount;
        require(endPresale, 'Presale not finished yet');
        require(investors[msg.sender] > 0, "You are not in presale list");
        require(investors[msg.sender] != 1, 'You already claim your tokens');
        amount = investors[msg.sender] * 1000;
        currentSender = msg.sender;
        token.transfer(msg.sender, amount);
        investors[msg.sender] = 1;
    }
    
    function transferFromPresaleManual(address _investor, uint _amount) public {
        require(msg.sender == owner, 'You are not the owner');
        token.transfer(_investor, _amount);
    }

}