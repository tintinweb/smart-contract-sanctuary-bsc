/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event Stake(address indexed from, uint256 amount);
    event Unstake(address indexed from, uint256 amount);
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}

contract ZKX is IERC20 {

    string constant _name = "ZAKAX Token";
    string constant _symbol = "ZKX";
    uint256 constant _decimals = 18;
    uint256 constant _totalSupply = 2_016_998_977e18;

    uint256 _circulatingSupply = 0;
    uint256 _stakers = 0;
    uint256 _staked = 0;

    mapping(address => uint256) balances;
    mapping(address => uint256) stakes;
    mapping(address => mapping (address => uint256)) allowed;

    address admin;

    using SafeMath for uint256;

    constructor() {
        admin = msg.sender;
    }
    
    function name() public pure returns (string memory) {
        return _name;
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    
    function decimals() public pure returns (uint256) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function circulatingSupply() public view returns (uint256) {
        return _circulatingSupply;
    }

    function balanceOf(address owner) public view override returns (uint256) {
        return balances[owner];
    }
    
    function allowance(address owner, address delegate) public view override returns (uint256) {
        return allowed[owner][delegate];
    }

    function stakeOf(address owner) public view returns (uint256) {
        return stakes[owner];
    }

    function stakers() public view returns(uint256) {
        return _stakers;
    }

    function staked() public view returns(uint256) {
        return _staked;
    }

    function transfer(address receiver, uint256 amount) public override returns (bool) {
        require(amount <= balances[msg.sender], "Balance less than amount transferred");
        
        balances[msg.sender] = balances[msg.sender].sub(amount);
        balances[receiver] = balances[receiver].add(amount);
        
        emit Transfer(msg.sender, receiver, amount);
        
        return true;
    }

    function stake(uint256 amount) public returns (bool) {
        require(amount <= balances[msg.sender], "Balance less than amount staked");
        
        balances[msg.sender] = balances[msg.sender].sub(amount);
        stakes[msg.sender] = stakes[msg.sender].add(amount);

        _stakers = _stakers.add(1);
        _staked = _staked.add(amount);
        
        emit Stake(msg.sender, amount);
        
        return true;
    }

    function unStake(uint256 amount) public returns (bool) {
        require(amount <= stakes[msg.sender], "Stake less than amount unstaked");
        
        stakes[msg.sender] = stakes[msg.sender].sub(amount);
        balances[msg.sender] = balances[msg.sender].add(amount);

        _stakers = _stakers.sub(1);
        _staked = _staked.sub(amount);
        
        emit Unstake(msg.sender, amount);
        
        return true;
    }

    function approve(address delegate, uint256 amount) public override returns (bool) {
        allowed[msg.sender][delegate] = amount;
        
        emit Approval(msg.sender, delegate, amount);
        
        return true;
    }

    function transferFrom(address owner, address receiver, uint256 amount) public override returns (bool) {
        require(amount <= balances[owner], "Balance less than amount transferred");
        require(amount <= allowed[owner][msg.sender], "Allowed less than amount transferred");

        balances[owner] = balances[owner].sub(amount);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(amount);
        balances[receiver] = balances[receiver].add(amount);
        
        emit Transfer(owner, receiver, amount);
        
        return true;
    }
    
    function mint(address receiver, uint256 amount) public returns (bool) {
        require(msg.sender == admin, "Not admin");
        
        balances[receiver] = balances[receiver].add(amount);
        _circulatingSupply = _circulatingSupply.add(amount);
        
        emit Mint(receiver, amount);
        
        return true;
    }

    function multimint(address rone, uint256 aone, address rtwo, uint256 atwo, address rthree, uint256 athree, address rfour, uint256 afour) public returns (bool) {
        require(msg.sender == admin, "Not admin");
        
        balances[rone] = balances[rone].add(aone);
        _circulatingSupply = _circulatingSupply.add(aone);

        balances[rtwo] = balances[rtwo].add(atwo);
        _circulatingSupply = _circulatingSupply.add(atwo);

        balances[rthree] = balances[rthree].add(athree);
        _circulatingSupply = _circulatingSupply.add(athree);

        balances[rfour] = balances[rfour].add(afour);
        _circulatingSupply = _circulatingSupply.add(afour);
        
        emit Mint(rone, aone);
        emit Mint(rtwo, atwo);
        emit Mint(rthree, athree);
        emit Mint(rfour, afour);
        
        return true;
    }
    
    function burn(address owner, uint256 amount) public returns (bool) {
        require(msg.sender == admin, "Not admin");
        require(amount <= balances[owner], "Balance less than amount to be burnt");
        
        balances[owner] = balances[owner].sub(amount);
        _circulatingSupply = _circulatingSupply.sub(amount);
        
        emit Burn(owner, amount);
        
        return true;
    }

    function changeAdmin(address newAdmin) external {
        require(msg.sender == admin, "Not admin");

        admin = newAdmin;
    }
    
}