/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt3(uint y) internal pure returns (uint z) {
        z = sqrt(y);
        z = sqrt(z);
        z = sqrt(z);
    }

    // decimals = 18;
    // (10**decimals) ** 0.125
    function vote2power(uint y) internal pure returns (uint z) {
        if (y >= 1679616 * 10**18) {
            z = z * 6 / 100;
        } else {
            z = (y * sqrt3(y)) * 10000 / 177827941;
        }
    }
}

interface IUniswap {
    
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
}

contract MNT {
    using SafeMath for uint;

    string public constant name = 'Metabase Network Token';
    string public constant symbol = 'MNT';
    uint8 public constant decimals = 18;
    uint  public totalSupply;

    mapping(address => uint) public balances;
    mapping(address => uint) public balanceVote;

    function balanceOf(address owner) external view returns(uint) {
        return balances[owner].add(balanceVote[owner]);
    }

    mapping(address => mapping(address => uint)) public allowance;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function pairFor(address factory,bytes memory code_hash) private view returns (address addr) {
        (address token0, address token1) = address(this) < USDT ? (address(this),USDT) : (USDT,address(this));
        addr = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                code_hash
            )))));
    }

    constructor() {
        // local test
        //pair = pairFor(0xdCCc660F92826649754E357b11bd41C31C0609B9,hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f');
        
        // bsc test
        pair = pairFor(0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc,hex'ecba335299a6693cb2ebc4782e74669b84290b6378ea3a3873c7231a8d7d1074');
        
        // bsc main
        //pair = pairFor(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73,hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5');
        
        uint _totalSupply = 1000_000 ether;
        _mint(msg.sender, _totalSupply);
        begin = block.timestamp;
        spreads_length = 1;
        spreads[msg.sender] = Info({
            parent : address(this),
            cycle : 1,
            vote : 0,
            vote_power : 0,
            real_power : 0,
            lock_time: 0,
            child : new address[](0)});
    }

    function _mint(address to, uint value) internal {
        totalSupply = totalSupply.add(value);
        balances[to] = balances[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        balances[from] = balances[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {
        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
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

    function transferVote(address to, uint value) external returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(value);
        //balanceOf[to] = balanceOf[to].add(value);
        //balanceOf[to] = balanceOf[to].sub(value);
        balanceVote[to] = balanceVote[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
    }


    function transferFrom(address from, address to, uint value) external returns (bool) {
        if (allowance[from][msg.sender] < (2**256 - 1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    struct LP {
        uint lp;
        uint quantity;
        uint weight;
    }

    // 
    uint public whole_weight = 0;
    // 
    uint public whole_quantity = 0;
    //
    mapping(address => LP) public lps;

    uint public begin;
    // 
    uint public height = 0;
    
    uint private constant height_period = 60;
    uint private constant height_profit = 2 ether;
    
    // local test
    //address public constant USDT = 0x6f2fa37EBfaf089C4Fd7e6124C1028306943D11d;
    // bsc test 
    address public constant USDT = 0x89EB90e7E9480Ff2F39Dd60AA2c4FD6FD80472A3;
    // bsc main
    //address public constant USDT = 0x55d398326f99059fF775485246999027B3197955;

    address public pair;

    function addLiquidity(uint amount) external returns (uint usdt_amount, uint liquidity) { 
        require(spreads[msg.sender].parent != address(0), "Parent address is not a generalization set");
        (uint reserveA, uint reserveB,) = IUniswap(pair).getReserves();
        usdt_amount = address(this) < USDT ? amount.mul(reserveB) / reserveA : amount.mul(reserveA) / reserveB;
        _transfer(msg.sender, pair, amount);
        IUniswap(USDT).transferFrom(msg.sender, pair, usdt_amount);
        liquidity = IUniswap(pair).mint(msg.sender);
        updateLP();
        lps[msg.sender].lp = lps[msg.sender].lp.add(liquidity);
        Add(msg.sender,amount);
    }

    function removeLiquidity(uint liquidity) external returns (uint amountMNB, uint amountUSDT) {
        require(spreads[msg.sender].parent != address(0), "Parent address is not a generalization set");
        IUniswap(pair).transferFrom(msg.sender, pair, liquidity);
        (uint amount0, uint amount1) = IUniswap(pair).burn(msg.sender);
        (amountMNB, amountUSDT) = address(this) < USDT ? (amount0, amount1) : (amount1, amount0);
    
        updateLP();
        uint lp = lps[msg.sender].lp;
        assert(liquidity <= lp);
        lps[msg.sender].lp = lp.sub(liquidity);
        Del(msg.sender,lps[msg.sender].quantity.mul(liquidity) / lp);
    }

    function impeach(address addr) external {
        require(spreads[msg.sender].parent != address(0), "Parent address is not a generalization set");
        updateLP();
        uint lp = lps[addr].lp;
        uint pair_lp = IUniswap(pair).balanceOf(addr);
        
        if (lp > pair_lp) {
            uint liquidity = lp.sub(pair_lp);
            lps[addr].lp = lp.sub(liquidity);
            Del(addr,lps[addr].quantity.mul(liquidity) / lp);
        } else {
            revert();
        }
    }

    function updateLP() private {
        if (whole_weight > 0) {
            uint add_height = (block.timestamp.sub(begin) / height_period).sub(height);
            if (add_height > 0) {
                height = height.add(add_height);
                whole_quantity = whole_quantity.add(add_height.mul(height_profit));
            }
        }
    }

    function Add(address addr,uint q) private {
        if (whole_quantity > 0) {
            uint x = whole_weight.mul(q) / whole_quantity;
            whole_quantity = whole_quantity.add(q);
            whole_weight = whole_weight.add(x);
            lps[addr].quantity = lps[addr].quantity.add(q);
            lps[addr].weight = lps[addr].weight.add(x);
        } else {
            whole_quantity = q;
            whole_weight = q;
            lps[addr].weight = q;
            lps[addr].quantity = q;
        }
    }

    function Del(address addr,uint q) private {
        uint quantity = lps[addr].quantity;
        if (quantity > 0) {
            if (q > quantity) {
                q = quantity;
            }
            uint weight = lps[addr].weight;
            uint new_weight = weight.mul(q) / quantity;
            uint out_quantity = whole_quantity.mul(new_weight) / whole_weight;
            _mint(msg.sender,out_quantity.sub(q));
            
            lps[addr].weight = weight.sub(new_weight);
            lps[addr].quantity = quantity.sub(q);
            whole_weight  = whole_weight.sub(new_weight);
            whole_quantity = whole_quantity.sub(out_quantity);
        }
    }

    struct Info {
        address parent;
        address[] child;
        //       
        uint256 cycle;
        // Voting
        uint256 vote;
        // Voting power
        uint256 vote_power;
        // Real computing power
        uint256 real_power;
        // Voting lock time
        uint256 lock_time;
    }

    mapping(address => Info) public spreads;
    uint public spreads_length;
}

contract Mining is MNT
{
    using SafeMath for uint;
    bytes32 private DOMAIN_SEPARATOR;
    //keccak256("popularize(address addr)");
    bytes32 private constant PERMIT_TYPEHASH = 0x21cf163f92d861d4d1aca6cf2580b603353711f20e52675c104cd16e528edf30;

    struct power_profit {
        uint power;
        uint profit;
    }
    
    uint public whole_power = 0;
    mapping(uint => power_profit) public power_profit_whole;
    uint public cycle = 1;

    // test
    //  Revenue cycle (1 day)
    uint private constant cycle_period = 24 * 60 * 60;
    // 
    uint private constant cycle_profit = 24 * 60 * (2 ether);

    // production
    /*
    uint private constant cycle_period = 30 * 24 * 60 * 60;
    // 
    uint private constant cycle_profit = 30 * 24 * 60 * (2 ether);
    */
  
    event Popularize(address indexed parent, address indexed children,uint indexed cycle,uint timestamp);
    event VoteIn(address indexed addr,uint indexed cycle,uint timestamp,uint value);
    event VoteOut(address indexed addr,uint indexed cycle,uint timestamp,uint value);
    event VoteProfit(address indexed addr,uint indexed cycle,uint timestamp, uint value);
    event PreVoteProfit(address indexed addr,uint indexed cycle,uint timestamp, uint fraction);
    
    /**
     * @dev constructor
     */
    constructor() {
        // uint chainId = 56; 
        uint chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(name)),
                keccak256(bytes('1')),
                chainId,
                address(this)
            )
        );
    }

    function popularizeFast(address addr,address temp,
        uint8 addr_v, bytes32 addr_r, bytes32 addr_s,
        uint8 temp_v, bytes32 temp_r, bytes32 temp_s)
        external returns (bool ret)
    {
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, temp))
            )
        );
        require(addr == ecrecover(digest, addr_v, addr_r, addr_s),"signature data1 error");
        require(temp == ecrecover(keccak256(abi.encodePacked(msg.sender)),temp_v, temp_r, temp_s),"signature data2 error");
        return popularize(addr);
    }

    function popularize(address addr,uint8 v, bytes32 r, bytes32 s) external returns (bool ret)
    {
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, msg.sender))
            )
        );
        require(addr == ecrecover(digest, v, r, s),"signature data error");
        return popularize(addr);
    }

    /**
     * @dev popularize
     */
    function popularize(address addr) private returns (bool ret)
    {
        require(spreads[msg.sender].parent != address(0), "Parent address is not a generalization set");
        require(spreads[addr].parent == address(0), "Address has been promoted");
        require(spreads[msg.sender].child.length < 36,"Promotion data cannot be greater than 36");
        spreads[addr] = Info({
            parent : msg.sender,
            cycle : cycle,
            vote: 0,
            vote_power: 0,
            real_power : 0,
            lock_time: 0,
            child : new address[](0)});
        spreads[msg.sender].child.push(addr);
        spreads_length++;
        emit Popularize(msg.sender,addr,cycle,block.timestamp);
        ret = true;
    }

    /**
     * @dev voteIn
     */
    function voteIn(uint256 value) external returns (uint ret)
    {
        //_update();
        require(spreads[msg.sender].parent != address(0), "address is not a generalization set");
        //require(balanceOf[msg.sender] >= value,"The investment amount is too large");
        
        balances[msg.sender] = balances[msg.sender].sub(value);
        spreads[msg.sender].vote = spreads[msg.sender].vote.add(value.add(balanceVote[msg.sender]));
        balanceVote[msg.sender] = 0;
        spreads[msg.sender].lock_time = block.timestamp;
        
        spreads[msg.sender].vote_power = SafeMath.vote2power(spreads[msg.sender].vote);
        emit VoteIn(msg.sender,cycle,block.timestamp,value);
        ret = value;
    }

    /**
     * @dev voteOut
     */
    function voteOut(uint256 value) external returns (uint ret)
    {
        //_update();
        require(spreads[msg.sender].parent != address(0), "address is not a generalization set");
        require(block.timestamp.sub(spreads[msg.sender].lock_time) > cycle_period.mul(2), "Non redeemable during the lock up period");
        spreads[msg.sender].vote = spreads[msg.sender].vote.sub(value);
        spreads[msg.sender].vote_power = SafeMath.vote2power(spreads[msg.sender].vote);
        balances[msg.sender] = balances[msg.sender].add(value);
        emit VoteOut(msg.sender,cycle,block.timestamp,value);
        ret = value;
    }

    /**
     * @dev voteMining()
     */
    function voteMining() external returns (uint mint,uint f)
    {
        return _voteMining(msg.sender);
    }

    /**
     * @dev spreadParent(address addr)
     */
    function spreadParent(address addr) public view returns(
        address[] memory addrs,
        uint[] memory powers,
        uint power_sum) 
    {
        power_sum = 0;
        uint l = 0;
        address addr_temp = addr;
        while (spreads[addr_temp].parent != address(this)) {
            addr_temp = spreads[addr_temp].parent;
            l++;
        }
        powers = new uint[](l);
        addrs = new address[](l);
        addr_temp = addr;
        for (uint i = 0; i < l; i++) {
            addr_temp = spreads[addr_temp].parent;
            addrs[i] = addr_temp;
            uint pow = spreads[addr_temp].vote_power;
            powers[i] = pow;
            power_sum = power_sum.add(pow);
        }
    }

    /**
     * @dev _voteMining
     */
    function _voteMining(address addr) private returns (uint mint,uint f)
    {
        require(spreads[addr].parent != address(0), "address is not a generalization set");
        _update();
        //require(spreads[msg.sender].cycle != cycle,"The operation cannot be repeated within one cycle");
        if (spreads[addr].cycle < cycle) {
            uint old_cycle = spreads[addr].cycle;
            uint old_profit = power_profit_whole[old_cycle].profit;
            uint old_power = power_profit_whole[old_cycle].power;
            if (old_power > 0) {
                uint v = old_profit.mul(spreads[addr].real_power) / old_power;
                (address[] memory addrs, uint[] memory powers,uint power_sum) = spreadParent(addr);
                uint p = v.mul(2) / 10;
                uint min_p = p / 1000;
                if (power_sum > 0) {
                    for (uint i = 0; i < addrs.length; i++) {
                        uint ret = p.mul(powers[i]) / power_sum;
                        if (ret > min_p) {
                            _mint(addrs[i], ret);
                        }
                    }
                }
                _mint(addr,v.sub(p));
                emit VoteProfit(addr,old_cycle,block.timestamp,v);
                mint = v;
            }
            spreads[addr].real_power = 0;
            spreads[addr].cycle = cycle;
        }
        uint old_s = spreads[addr].real_power;
        uint s = spreadPower(addr);
        if (s > old_s) {
            whole_power = whole_power.add(s.sub(old_s));
            spreads[addr].real_power = s;
            spreads[addr].lock_time = block.timestamp;
            emit PreVoteProfit(addr,cycle,block.timestamp,s);
            f = s;
        } else {
            f = 0;
        }
    }

    function _update() private returns (bool) {
        if (block.timestamp > (begin.add(cycle.mul(cycle_period)))) {
            power_profit_whole[cycle] = power_profit({power:whole_power,profit:cycle_profit});
            whole_power = 0;
            cycle += 1;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev spreadChild
     */
    function spreadChild(address addr) public view returns (
        address[] memory addrs,
        uint[] memory votes,
        uint[] memory powers) 
    {
        addrs = spreads[addr].child;
        uint n = spreads[addr].child.length;
        votes = new uint[](n);
        powers = new uint[](n);
        for (uint i = 0; i < n; i++) {
            votes[i] = spreads[addrs[i]].vote;
            powers[i] = spreads[addrs[i]].vote_power;
        }
    }
    
    /**
     * @dev spreadPower
     */
    function spreadPower(address addr) public view returns (uint power_)
    {
        uint v = spreads[addr].vote_power;
        uint sum = v.mul(4);
        sum = sum.add(SafeMath.min(v,spreads[spreads[addr].parent].vote_power).mul(2));

        uint n = spreads[addr].child.length;
        for (uint i = 0; i < n; i++) {
            sum = sum.add(SafeMath.min(v,spreads[spreads[addr].child[i]].vote_power));
        }
        power_ = sum;
    }
}