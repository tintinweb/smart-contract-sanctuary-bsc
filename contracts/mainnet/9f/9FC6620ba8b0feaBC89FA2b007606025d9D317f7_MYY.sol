/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

pragma solidity =0.6.6;


interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// erc20
interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint256);
    function totalSupply() external view returns (uint256);

    function balanceOf(address _address) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// safe math
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Math error");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >= b, "Math error");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "Math error");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a / b;
        return c;
    }
}


// owner
contract Ownable {
    address public owner;

    constructor(address _owner) internal {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'owner error');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


// strategy
contract Strategy is Ownable {

    address public factory;
    address public wbnb;
    address public marketing;
    address public pool;
    uint256 constant internal poolFee = 1;       // 1%
    uint256 constant internal holderFee = 2;     // 2%
    uint256 constant internal marketingFee = 1;  // 1%
    // uint256 constant private totalFee = 4;   // 4%
    uint256 public pointer;      // holder dividend index
    uint256 public amount = 30;  // number of people
    mapping(address => bool) public isHolder;   // is holder
    mapping(address => uint256) public indexOf; // holder in index, 0 start
    address[] public holders;                   // all holder, contract not can is holder, 0 start


    constructor(
        address _factory,
        address _wbnb,
        address _owner,
        address _marketing
    ) internal Ownable(_owner) {
        factory = _factory;
        wbnb = _wbnb;
        marketing = _marketing;

        pool = IUniswapV2Factory(_factory).createPair(address(this), _wbnb);
    }

    function setMarketing(address _marketing) public onlyOwner returns(bool) {
        marketing = _marketing;
        return true;
    }

    function setAmount(uint256 _amount) public onlyOwner returns(bool) {
        amount = _amount;
        return true;
    }

    // true is contract
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }


}


// MYY
contract MYY is IERC20, Strategy {
    using SafeMath for uint256;

    string constant private _name = "MYY";
    string constant private _symbol = "MYY";
    uint8 constant private _decimals = 18;
    uint256 constant private _totalSupply = 100000 * 10**uint256(_decimals);
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;

    constructor(
        address _factory,
        address _wbnb,
        address _owner,
        address _marketing
    ) public Strategy(_factory, _wbnb, _owner, _marketing) {
        _balances[_owner] = _totalSupply;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _address) public view override returns (uint256) {
        return _balances[_address];
    }

    function _approve(address _owner, address _spender, uint256 _value) private {
        _allowed[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
    }

    function approve(address _spender, uint256 _value) public override returns (bool) {
        _approve(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view override returns (uint256) {
        return _allowed[_owner][_spender];
    }

    function _transfer(address _from, address _to, uint256 _value) private {
        _balances[_from] = SafeMath.sub(_balances[_from], _value);
        _balances[_to] = SafeMath.add(_balances[_to], _value);
        emit Transfer(_from, _to, _value);
    }

    function _transferFull(address _from, address _to, uint256 _value) private {
        uint256 poolAmount = _value.mul(poolFee).div(100);
        uint256 holderAmount = _value.mul(holderFee).div(100);
        uint256 marketingAmount = _value.mul(marketingFee).div(100);
        uint256 toAmount = _value.sub(poolAmount).sub(holderAmount).sub(marketingAmount);

        _transfer(_from, address(this), poolAmount);
        _transfer(_from, address(this), holderAmount);
        _transfer(_from, marketing, marketingAmount);
        _transfer(_from, _to, toAmount);

        _holdersDividend(holderAmount);
        addOrRemoveHolders(_from, _to);
        if(!isContract(_from) && !isContract(_to)) {
            backflowPool();
        }
    }

    function transfer(address _to, uint256 _value) public override returns (bool) {
        require(_balances[msg.sender] >= _value, 'balance error');
        _transferFull(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
        require(_balances[_from] >= _value, 'balance error');
        _allowed[_from][msg.sender] = SafeMath.sub(_allowed[_from][msg.sender], _value);
        _transferFull(_from, _to, _value);
        return true;
    }

    
    event add(address indexed holder);
    event remove(address indexed holder);

    // backflow pool
    // contract all balances of backflow
    function backflowPool() public returns(bool) {
        require(_balances[address(this)] > 0, 'balance is zero');
        // contract all balances give pool
        if(_balances[pool] > 0) {
            _transfer(address(this), pool, _balances[address(this)]);
            // force reserves to match balances
            IUniswapV2Pair(pool).sync();
        }
        return true;
    }

    // add or remove holders
    function addOrRemoveHolders(address _from, address _to) public {
        // remove
        if(!isContract(_from) && _balances[_from] == 0 && isHolder[_from]) {
            // from address
            uint256 _fromIndex = indexOf[_from];
            
            // last address
            uint256 _lastIndex = holders.length - 1;
            address _lastAddress = holders[_lastIndex];
            holders[_fromIndex] = _lastAddress;
            indexOf[_lastAddress] = _fromIndex;

            holders.pop();
            isHolder[_from] = false;
            delete indexOf[_from]; 

            if(pointer >= holders.length) {
                pointer = 0;
            }
            
            emit remove(_from);
        }
        // add
        if(!isContract(_to) && _balances[_to] > 0 && !isHolder[_to]) {
            isHolder[_to] = true;
            indexOf[_to] = holders.length;
            holders.push(_to);

            emit add(_to);
        }
    }

    function getHolders() public view returns (address[] memory x) {
        uint256 len = holders.length;
        x = new address[](len);
        for(uint256 i = 0; i < len; i++) {
            x[i] = holders[i];
        }
    }

    function getHoldersLength() public view returns (uint256) {
        return holders.length;
    }

    // holders dividend
    function _holdersDividend(uint256 _dividendValue) private {
        if (holders.length == 0) {
            return;
        }
        address[] memory _addrs;
        uint256 balanceTotal;
        _addrs = holders.length <= amount ? new address[](holders.length) : new address[](amount);

        if (holders.length <= amount) {
            for(uint256 i = 0; i < holders.length; i++) {
                _addrs[i] = holders[i];
                balanceTotal += _balances[_addrs[i]];
            }
            pointer = 0;
        }else if (holders.length - pointer >= amount) {
            for(uint256 i = 0; i < amount; i++) {
                _addrs[i] = holders[pointer+i];
                balanceTotal += _balances[_addrs[i]];
            }
            pointer = pointer + amount;
            pointer = pointer >= holders.length ? 0 : pointer;
        }else {
            uint256 _end = holders.length > pointer ? holders.length - pointer : 0;
            uint256 _start = amount - _end;
            for(uint256 i = 0; i < _end; i++) {
                _addrs[i] = holders[pointer+i];
                balanceTotal += _balances[_addrs[i]];
            }
            for(uint256 i = 0; i < _start; i++) {
                _addrs[_end+i] = holders[i];
                balanceTotal += _balances[holders[i]];
            }
            pointer = _start;
        }
        // gain success _addrs and total balances。

        // dividend
        for(uint256 i = 0; i < _addrs.length; i++) {
            uint256 _fee = _balances[_addrs[i]].mul(_dividendValue).div(balanceTotal);
            if (_fee > 0) {
                _transfer(address(this), _addrs[i], _fee);
            }
        }
    }



}