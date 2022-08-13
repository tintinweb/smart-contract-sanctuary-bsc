/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

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

contract MNT {
    using SafeMath for uint;

    string public constant name = 'Metabase Network';
    string public constant symbol = 'MNT';
    uint8 public constant decimals = 18;
    uint  public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    constructor()
    {
        uint _totalSupply = 2100 * 10000 * (10**decimals);
        _mint(msg.sender, _totalSupply);
    }

    function burn(uint256 _value) external returns (bool success) {
        _burn(msg.sender, _value);
        return true;
    }

    function _mint(address to, uint value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {
        //require(balanceOf[from] >= value,"_transfer error");
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external returns (bool) {
        //require(allowance[from][msg.sender] >= value,"transferFrom error");
        allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }
}

contract Mining is MNT
{
    using SafeMath for uint;

    bytes32 public DOMAIN_SEPARATOR;

    //keccak256("popularize(address addr)");
    bytes32 public constant PERMIT_TYPEHASH = 0x21cf163f92d861d4d1aca6cf2580b603353711f20e52675c104cd16e528edf30;

    uint public fraction_sum = 0; 
    uint public fraction_mature = 0;
    uint public cycle = 1;    
    uint public begin;

    // test
    uint public profit = 10000 * (10**decimals);
    //  Revenue cycle (1 hours)
    uint public constant cycle_period = 24 * 60 * 60;
    // lock time (2 hours)
    uint public constant lock_time = 30 * 60 * 60;

    // production
    /*
    uint public profit = 15 * 10000 * (10**decimals);
    //  Revenue cycle (one month)
    uint public constant cycle_period = 2629746;
    // lock time (31 hours)
    uint public constant lock_time = 32 * 24 * 60 * 60;
    */

    struct Info {
        address parent;
        address[] child;
        uint256 fraction;
        uint256 cycle;
        uint256 balance;
        uint256 lock_balance;
        uint256 lock_time;
    }     
    mapping(address => Info) public spreads;

    event Popularize(address indexed parent, address indexed children);
    event Vote(address indexed addr,uint value);
    event Withdrawal(address indexed addr,uint value);
    event Cash(address indexed addr,uint value);
    event Income(address indexed addr,uint indexed cycle, uint valute,uint profit, uint fraction_mature);
    event PreIncome(address indexed addr,uint indexed cycle, uint fraction_sum,uint valute);
    
    /**
     * @dev popularize
     */
    function popularize(address addr,uint8 v, bytes32 r, bytes32 s) external returns (bool)
    {
        require(spreads[msg.sender].parent != address(0), "Parent address is not a generalization set");
        require(spreads[addr].parent == address(0), "Address has been promoted");
        _update();
         bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, msg.sender))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress ==  addr,"Signature data error");
        require(spreads[msg.sender].child.length < 20,"Promotion data cannot be greater than 20");
        spreads[addr] = Info({
            parent : msg.sender,
            fraction : 0,
            cycle : 0,
            balance: 0,
            lock_balance: 0,
            lock_time: 0,
            child : new address[](0)});
        spreads[msg.sender].child.push(addr);
        emit Popularize(msg.sender,addr);
        return true;
    }

    /**
     * @dev vote
     */
    function vote(uint256 value) external returns (bool)
    {
        require(spreads[msg.sender].parent != address(0), "address is not a generalization set");
        //require(balanceOf[msg.sender] >= value,"The investment amount is too large");
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(value);
        spreads[msg.sender].balance = spreads[msg.sender].balance.add(value);
        emit Vote(msg.sender,value);
        return true;
    }

    /**
     * @dev withdrawal
     */
    function withdrawal(uint256 value) external returns (bool)
    {
        require(spreads[msg.sender].parent != address(0), "address is not a generalization set");
        //require(spread[msg.sender].balance >= value,"The investment amount is too large");
        spreads[msg.sender].balance = spreads[msg.sender].balance.sub(value);
        spreads[msg.sender].lock_balance = spreads[msg.sender].lock_balance.add(value);
        spreads[msg.sender].lock_time = block.timestamp;
        emit Withdrawal(msg.sender,value);
        return true;
    }

    /**
     * @dev cash
     */
    function cash(uint256 value) external returns (bool)
    {
        require(spreads[msg.sender].parent != address(0), "address is not a generalization set");
        //require(spread[msg.sender].lock_balance >= value,"The investment amount is too large");
        require(block.timestamp - spreads[msg.sender].lock_time > lock_time,"The unlocking date has not arrived");
        spreads[msg.sender].lock_balance = spreads[msg.sender].lock_balance.sub(value);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(value);
        emit Cash(msg.sender,value);
        return true;
    }

    /**
     * @dev income
     */
    function income() external returns (bool)
    {
        require(spreads[msg.sender].parent != address(0), "address is not a generalization set");
        _update();
        require(spreads[msg.sender].cycle != cycle,"The operation cannot be repeated within one cycle");
        uint v_ = 0;
        if (spreads[msg.sender].cycle == (cycle - 1) && fraction_mature > 0) {
            v_ = profit.mul(spreads[msg.sender].fraction) / (fraction_mature);
            _mint(msg.sender,v_);
            emit Income(msg.sender,cycle,v_,profit,fraction_mature);
        }
        uint s = fraction(msg.sender);
        fraction_sum += s;
        spreads[msg.sender].fraction = s;
        spreads[msg.sender].cycle = cycle;
        emit PreIncome(msg.sender,cycle,fraction_sum,s);
        return true;
    }
    
    /**
     * @dev constructor
     */
    constructor() {
        uint chainId = 97;
        /*
        assembly {
            chainId := chainid()
        }*/
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(name)),
                keccak256(bytes('1')),
                chainId,
                address(this)
            )
        );

        begin = block.timestamp;
        spreads[msg.sender] = Info({
            parent : address(this),
            fraction : 0,
            cycle : 0,
            balance: 0,
            lock_balance: 0,
            lock_time: 0,
            child : new address[](0)});
    }

    function _update() private returns (bool) {
        if (block.timestamp > (begin + cycle * cycle_period)) {
            fraction_mature = fraction_sum;
            fraction_sum = 0;
            cycle += 1;
            if (cycle > 60) {
                profit = totalSupply * 8 / 1000;
            }
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev parent
     */
    function parent(address addr) public view returns (address par,uint balance) {
        par = spreads[addr].parent;
        balance = spreads[spreads[addr].parent].balance;
    }

    /**
     * @dev children
     */
    function child(address addr) public view returns (address[] memory addrs,uint[] memory balances) {
        addrs = spreads[addr].child;
        uint n = spreads[addr].child.length;
        balances = new uint[](n);
        for (uint i = 0; i < n; i++) {
            balances[i] = spreads[spreads[addr].child[i]].balance;
        }
    }

    /**
     * @dev getInfo
     */
    function info(address addr) public view returns (uint balance_,uint fraction_, uint cycle_,uint lock_balance_,uint lock_time_) 
    {
        balance_ = spreads[addr].balance;
        fraction_ = spreads[addr].fraction;
        cycle_ = spreads[addr].cycle;
        lock_balance_ = spreads[addr].lock_balance;
        lock_time_ = spreads[addr].lock_time;
    }
    
    /**
     * @dev fraction
     */
    function fraction(address addr) public view returns (uint fraction_)
    {
        uint v = spreads[addr].balance;
        uint s = spreads[spreads[addr].parent].balance;
        if (v < s) {
            s = v;
        }
        uint n = spreads[addr].child.length;
        for (uint i = 0; i < n; i++) {
            uint v_c = spreads[spreads[addr].child[i]].balance;
            if (v_c < v) {
                s += v_c;
            } else {
                s += v;
            }
        }
        fraction_ = s;
    }
}