/**
 *Submitted for verification at BscScan.com on 2022-02-08
*/

pragma solidity ^0.5.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}

contract ERC20Interface {
    function totalSupply() public view returns (uint256);

    function balanceOf(address tokenOwner)
        public
        view
        returns (uint256 balance);

    function allowance(address tokenOwner, address spender)
        public
        view
        returns (uint256 remaining);

    function transfer(address to, uint256 value) public returns (bool success);

    function approve(address spender, uint256 value)
        public
        returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 value
    );
}

contract VirtualPlanet3D is ERC20Interface {
    using SafeMath for uint256;
    string public symbol;
    string public name;
    uint8 public decimals;
    uint256 _totalSupply;
    address public owner;
    bool public activeStatus = true;

    uint256 public minPurchase = 500;
    uint256 public maxPurchase = 357500;

    uint256 constant tokenPrice = 0.00027 ether;
    uint256 _saledTokens = 0 * 10**uint256(decimals);
    event Active(address msgSender);
    event Reset(address msgSender);
    event Burn(address indexed from, uint256 value);
    event Freeze(address indexed from, uint256 value);
    event Unfreeze(address indexed from, uint256 value);

    mapping(address => uint256) public balances;
    mapping(address => uint256) public freezeOf;
    mapping(address => mapping(address => uint256)) public allowed;

    constructor() public {
        symbol = "VP3D";
        name = "VirtualPlanet3D";
        decimals = 18;
        _totalSupply = 500000000 * 10**uint256(decimals);
        owner = msg.sender;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0);
        0x55B2627E8300281E8D8B786C6409Fc21B87D517b.transfer(balance);
    }

    function buyToken(address account, uint256 tokenAmount) public payable {
        require(msg.sender == account, "No permission");
        require(msg.value >= tokenAmount * tokenPrice, "Not enough bnb sent");
        require(tokenAmount >= minPurchase, "A minimum of 500 can be purchased.");
        require(tokenAmount <= maxPurchase, "A maximum of 357500 can be purchased.");
        require(_saledTokens + tokenAmount <= 100000000, "Maximum sales value reached.");
        uint256 aToken = tokenAmount * 10**uint256(decimals);
        balances[msg.sender] = balanceOf(msg.sender) + aToken;
        _saledTokens = _saledTokens + tokenAmount;
        emit Transfer(address(0), msg.sender, aToken);
    }

    function isOwner(address add) public view returns (bool) {
        if (add == owner) {
            return true;
        } else return false;
    }

    modifier onlyOwner() {
        if (!isOwner(msg.sender)) {
            revert();
        }
        _;
    }

    modifier onlyActive() {
        if (!activeStatus) {
            revert();
        }
        _;
    }

    function activeMode() public onlyOwner {
        activeStatus = true;
        emit Active(msg.sender);
    }

    function resetMode() public onlyOwner {
        activeStatus = false;
        emit Reset(msg.sender);
    }

    function saledTokens() public view returns (uint256) {
        return _saledTokens;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner)
        public
        view
        returns (uint256 balance)
    {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender)
        public
        view
        returns (uint256 remaining)
    {
        return allowed[tokenOwner][spender];
    }

    function transfer(address to, uint256 value)
        public
        onlyActive
        returns (bool success)
    {
        if (to == address(0)) {
            revert();
        }
        if (value <= 0) {
            revert();
        }
        if (balances[msg.sender] < value) {
            revert();
        }
        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value)
        public
        onlyActive
        returns (bool success)
    {
        if (value <= 0) {
            revert();
        }
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public onlyActive returns (bool success) {
        if (to == address(0)) {
            revert();
        }
        if (value <= 0) {
            revert();
        }
        if (balances[from] < value) {
            revert();
        }
        if (value > allowed[from][msg.sender]) {
            revert();
        }
        balances[from] = balances[from].sub(value);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        emit Transfer(from, to, value);
        return true;
    }

    function burn(uint256 value) public onlyActive returns (bool success) {
        if (balances[msg.sender] < value) {
            revert();
        }
        if (value <= 0) {
            revert();
        }
        balances[msg.sender] = balances[msg.sender].sub(value);
        _totalSupply = _totalSupply.sub(value);
        emit Burn(msg.sender, value);
        return true;
    }

    function freeze(uint256 value) public onlyActive returns (bool success) {
        if (balances[msg.sender] < value) {
            revert();
        }
        if (value <= 0) {
            revert();
        }
        balances[msg.sender] = balances[msg.sender].sub(value);
        freezeOf[msg.sender] = freezeOf[msg.sender].add(value);
        emit Freeze(msg.sender, value);
        return true;
    }

    function unfreeze(uint256 value) public onlyActive returns (bool success) {
        if (freezeOf[msg.sender] < value) {
            revert();
        }
        if (value <= 0) {
            revert();
        }
        freezeOf[msg.sender] = freezeOf[msg.sender].sub(value);
        balances[msg.sender] = balances[msg.sender].add(value);
        emit Unfreeze(msg.sender, value);
        return true;
    }

}