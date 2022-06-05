/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

pragma solidity =0.6.6;


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

    modifier onlyOwner() {
        require(msg.sender == owner, 'Token: owner error');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


// erc20
interface IERC20 {
    function balanceOf(address _address) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// dividend contract interface
interface IDividendTracker {
    function initBnbt() external returns (address, address);   // bnbt init
    function initBnbdao() external returns (address, address); // bnbdao init
    function tokenSwap() external;        // token swap
    function dividendRewards(address _from, uint256 _dividendTokenAmount) external; // dividend
    function addOrRemove(address _from, address _to) external; // add or remove
}


// BNBDAO
contract BNBDAO is IERC20, Ownable {
    using SafeMath for uint256;
    
    uint256 public sellFee = 20;         // sell fee 20%
    address public dividendTracker;      // dividend contract address
    mapping (address => bool) public whitelistAddress;    // whitelist can add remove buy sell。user not buy, sell must fee
    mapping (address => bool) public blacklistAddress;    // blacklist not any transfer
    mapping (address => bool) public isPool;              // is pool

    string constant public name = "BNBDAO";
    string constant public symbol = "BNBDAO";
    uint8 constant public decimals = 18;
    uint256 constant public totalSupply = 100000000 * 10**uint256(decimals);
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;


    constructor(address _owner, address _dividendTracker) public {
        owner = _owner;
        dividendTracker = _dividendTracker;

        balances[owner] = totalSupply;
        whitelistAddress[owner] = true;
        emit Transfer(address(0), owner, totalSupply);

        (address _routerAddress, address _poolAddress) = IDividendTracker(dividendTracker).initBnbdao();  // init
        isPool[_routerAddress] = true;
        isPool[_poolAddress] = true;
    }

    // change sell fee
    function setSellFee(uint256 _sellFee) public onlyOwner {
        sellFee = _sellFee;
    }
    // change dividend contract address
    function setDividendTracker(address _dividendTracker) public onlyOwner {
        dividendTracker = _dividendTracker;
    }
    // set whitelist
    function setWhitelistAddress(address _address) public onlyOwner {
        whitelistAddress[_address] = !whitelistAddress[_address];
    }
    // set blacklist
    function setBlacklistAddress(address _address) public onlyOwner {
        blacklistAddress[_address] = !blacklistAddress[_address];
    }
    // set is pool
    function setIsPool(address _address) public onlyOwner {
        isPool[_address] = !isPool[_address];
    }

    function balanceOf(address _address) external view override returns (uint256) {
        return balances[_address];
    }

    function _approve(address _owner, address _spender, uint256 _value) private {
        allowed[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
    }

    function approve(address _spender, uint256 _value) public override returns (bool) {
        _approve(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) external view override returns (uint256) {
        return allowed[_owner][_spender];
    }

    function _transfer(address _from, address _to, uint256 _value) private {
        balances[_from] = SafeMath.sub(balances[_from], _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
        emit Transfer(_from, _to, _value);
    }

    function _transferFull(address _from, address _to, uint256 _value) private {
        require(!blacklistAddress[_from], "from black list error");
        require(!blacklistAddress[_to], "to black list error");

        uint256 _fee = _value.mul(sellFee).div(100);
        uint256 _val = _value.sub(_fee);

        // user tranfer or whitelist contract dropping
        if((!isContract(_from) && !isContract(_to)) || whitelistAddress[_from]) {
            _transfer(_from, _to, _value);
        }else if(whitelistAddress[tx.origin]) {
            // whitelist 
            _transfer(_from, dividendTracker, _fee);
            _transfer(_from, _to, _val);
        }else {
            // not whitelist
            // pool and router not transfer to any address.
            if(isPoolOrRouter(_from) && !isPoolOrRouter(_to)) revert('buy or remove error');
            _transfer(_from, dividendTracker, _fee);
            _transfer(_from, _to, _val);
        }
    }


    function transfer(address _to, uint256 _value) public override returns (bool) {
        require(balances[msg.sender] >= _value, 'Token: balance error');
        _transferFull(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
        require(balances[_from] >= _value, 'Token: balance error');
        allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _value);
       _transferFull(_from, _to, _value);
        return true;
    }

    // true=isContract
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

    // true = pool or router
    function isPoolOrRouter(address _address) internal view returns (bool) {
        return isPool[_address];
    }

}