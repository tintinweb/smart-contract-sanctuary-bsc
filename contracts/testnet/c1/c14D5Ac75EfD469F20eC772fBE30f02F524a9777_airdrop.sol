/**
 *Submitted for verification at BscScan.com on 2022-10-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
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
        // Solidity only automatically asserts when dividing by 0
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

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
   
       _owner = newOwner;
    }
}

contract redcoin is Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public totalSupply;
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 Initial_supply;
    uint256 Max_Fixed_supply = 1000000000000000000000000000000000000000;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(uint256 InitialSupply)    //mint tokens
    {
        name = "RED coin";
        symbol = "RC";
        decimals = 18;
         Initial_supply=InitialSupply;
        totalSupply = Initial_supply ;
        balances[msg.sender] = totalSupply;
    }

    function mint(uint256 amount) public onlyOwner returns (bool) {
        amount = amount ;
        Max_Fixed_supply = Max_Fixed_supply;
        require(
            totalSupply + amount <= Max_Fixed_supply,
            " you can not mint more than 1 trillion"
        );
        _mint(_msgSender(), amount);
        return true;
    }

    // chk balance from token
    function balanceOf(address owner) public view returns (uint256) {
        return balances[owner];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf(msg.sender) >= value, "balance too low");
       // value = value * (10**decimals);
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        require(balanceOf(from) >= value, "balance too low");
        require(allowance[from][msg.sender] <= value, "allowance too low");
       // value = value * (10**decimals);
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");
        totalSupply = totalSupply.add(amount);
        balances[account] = balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        balances[account] = balances[account].sub(
            amount,
            "BEP20: burn amount exceeds balance"
        );
        totalSupply = totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
}
contract airdrop {
     redcoin Token;
    uint256 public airdropToken;
    uint256 public per_user = 10000000000000000000;  
    address payable public owner;
    bool airdrop_active = false;    
    mapping(address => bool) public result;
   
    modifier owneronly() {
        require(msg.sender == owner);
        _;
    }     
    constructor(redcoin token_)
     {
        require(address(token_) != address(0), "address must be available"); //airdrop tokeN address not = to 0
        owner = payable(msg.sender);
        Token = token_;
    }
    function initializeAirDrop(uint256 _airdropToken) public owneronly{
        require(owner == msg.sender);
        require(_airdropToken != 0);
        airdropToken = _airdropToken;
        airdrop_active = true; 
       // require(Token.balanceOf(msg.sender) >= _airdropToken, "balance too low"); //no need of this bcz use in transfer function alreasdy       
        Token.transferFrom(msg.sender, address(this),_airdropToken );
    }
    //  address[]  registered;
    //  uint256 public count;
     
    //  function register() external {
    //     count++;
    //     registered.push(msg.sender);
    //  }

    function claimToken() external
    {

        require(payable(msg.sender) != owner, "owner can not claim tokens");
        require(airdrop_active == true, " airdrop should be active");            
       require(Token.balanceOf(address(this)) >= per_user,"balance must be greater than require amount"  );
       Token.transferFrom(address(this),msg.sender,per_user);
       result[msg.sender] = true;                       
    }
    function cancel() external
     {
        require(payable(msg.sender) == owner);
        airdrop_active = false;
    }
    function changeTokenAdres(redcoin newTokenAdres) public owneronly {
        Token = newTokenAdres;
    }    
    function update_tokensPerUser(uint256 newPerUser) public owneronly {
        per_user = newPerUser;
    } 
}