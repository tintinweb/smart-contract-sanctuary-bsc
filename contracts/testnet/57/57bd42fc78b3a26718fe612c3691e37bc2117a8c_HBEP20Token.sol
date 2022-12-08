/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

pragma solidity =0.8.7;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)
library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

interface IBEP20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

abstract contract HBEP20 is IBEP20 {
    using SafeMath for uint256;

    uint  private _totalSupply;
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowance;

    event Mint(address indexed sender, uint amount);
    event Burn(address indexed sender, uint amount, address indexed to);

    string public override name;
    string public override symbol;
    uint8 public override decimals;

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function _mint(address to, uint value) internal {
        _totalSupply = _totalSupply.add(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        _balances[from] = _balances[from].sub(value);
        _totalSupply = _totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) private {
        _allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external override returns (bool) {
        if (_allowance[from][msg.sender] != uint256(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) {
            _allowance[from][msg.sender] = _allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    function balanceOf(address _owner) public view override returns (uint256) {
        return _balances[_owner];
    }

    function allowance(address _owner, address _spender) public view override returns (uint256) {
        return _allowance[_owner][_spender];
    }
}

contract HBEP20Token is HBEP20 {
    address public factory;
    address private _owner;

    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    constructor() {
        factory = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "HBEP20Token: caller is not the owner");
        _;
    }
    
    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'HBEP20Factory: TRANSFER_FAILED');
    }

    // called once by the factory at time of deployment
    function initialize(address creator, string memory _name, string memory _symbol, uint8 _decimals) external {
        require(msg.sender == factory, 'HBEP20Token: FORBIDDEN'); // sufficient check
        _owner = creator;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to, uint256 amount) external onlyOwner returns (uint256) {
        _mint(to, amount);
        emit Mint(msg.sender, amount);
        return amount;
    }

    // this low-level function should be called from a contract which performs important safety checks
    function burn(uint256 amount) external onlyOwner returns (uint256) {
        require(amount > 0, 'HBEP20Factory: INSUFFICIENT_AMOUNT');
        _burn(address(this), amount);
        emit Burn(msg.sender, amount, address(0));
        return amount;
    }
}