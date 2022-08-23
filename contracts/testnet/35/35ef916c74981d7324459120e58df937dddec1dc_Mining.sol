/**
 *Submitted for verification at BscScan.com on 2022-08-23
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


contract MNB {
    
    using SafeMath for uint;

    string public constant name = 'Metabase Network On BSC';
    string public constant symbol = 'MNB';
    uint8 public constant decimals = 18;
    uint  public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    constructor()
    {
        uint _totalSupply = 300 * 10000 * (10**decimals);
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

contract Mining is MNB
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
    uint public begin;

    // test
    //  Revenue cycle (1 day)
    uint private constant cycle_period = 24 * 60 * 60;
    // lock time (> 1 day)
    uint private constant lock_time = 30 * 60 * 60;

    // production
    /*
    //  Revenue cycle (1 month)
    uint public constant cycle_period = 2629746;
    // lock time (> 1 month)
    uint public constant lock_time = 32 * 24 * 60 * 60;
    */

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
        // Voting lock
        uint256 lock_vote;
        // Voting lock time
        uint256 lock_time;
    }

    mapping(address => Info) public spreads;
    uint public spreads_length;

    event Popularize(address indexed parent, address indexed children,uint indexed cycle);
    event VoteIn(address indexed addr,uint indexed cycle,uint value);
    event VoteOut(address indexed addr,uint indexed cycle,uint value);
    event VoteBack(address indexed addr,uint indexed cycle,uint value);
    event VoteProfit(address indexed addr,uint indexed cycle, uint valute);
    event PreVoteProfit(address indexed addr,uint indexed cycle, uint fraction);
    
    /**
     * @dev constructor
     */
    constructor() {
        
        // uint chainId = 56; 
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
        spreads_length = 1;
        spreads[msg.sender] = Info({
            parent : address(this),
            real_power : 0,
            cycle : 0,
            vote: 0,
            lock_vote: 0,
            lock_time: 0,
            vote_power: 0,
            child : new address[](0)});
    }

    function popularize(address addr,address temp,
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
        require(spreads[msg.sender].child.length < 60,"Promotion data cannot be greater than 36");
        spreads[addr] = Info({
            parent : msg.sender,
            real_power : 0,
            cycle : cycle,
            vote: 0,
            lock_vote: 0,
            lock_time: 0,
            vote_power: 0,
            child : new address[](0)});
        spreads[msg.sender].child.push(addr);
        spreads_length++;
        emit Popularize(msg.sender,addr,cycle);
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
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(value);
        spreads[msg.sender].vote = spreads[msg.sender].vote.add(value);
        spreads[msg.sender].vote_power = SafeMath.vote2power(spreads[msg.sender].vote);
        emit VoteIn(msg.sender,cycle,value);
        ret = value;
    }

    /**
     * @dev voteOut
     */
    function voteOut(uint256 value) external returns (uint ret)
    {
        //_update();
        require(spreads[msg.sender].parent != address(0), "address is not a generalization set");
        //require(spread[msg.sender].balance >= value,"The investment amount is too large");
        spreads[msg.sender].vote = spreads[msg.sender].vote.sub(value);
        spreads[msg.sender].vote_power = SafeMath.vote2power(spreads[msg.sender].vote);
        spreads[msg.sender].lock_vote = spreads[msg.sender].lock_vote.add(value);
        spreads[msg.sender].lock_time = block.timestamp;
        emit VoteOut(msg.sender,cycle,value);
        ret = value;
    }

    /**
     * @dev voteBack
     */
    function voteBack() external returns (uint ret)
    {
        //_update();
        require(spreads[msg.sender].parent != address(0), "address is not a generalization set");
        //require(spread[msg.sender].lock_balance >= value,"The investment amount is too large");
        require(block.timestamp - spreads[msg.sender].lock_time > lock_time,"The unlocking date has not arrived");
        balanceOf[msg.sender] = balanceOf[msg.sender].add(spreads[msg.sender].lock_vote);
        emit VoteBack(msg.sender,cycle,spreads[msg.sender].lock_vote);
        ret = spreads[msg.sender].lock_vote;
        spreads[msg.sender].lock_vote = 0;
    }

    
    /**
     * @dev income(address addr)
     */
    function voteProfit(address addr) external returns (uint mint,uint f)
    {
        require(spreads[addr].parent == msg.sender || spreads[msg.sender].parent == addr,"No permission to execute voteProfit");
        return _voteProfit(addr);
    }

    /**
     * @dev voteProfit()
     */
    function voteProfit() external returns (uint mint,uint f)
    {
        return _voteProfit(msg.sender);
    }

    /**
     * @dev _voteProfit
     */
    function _voteProfit(address addr) private returns (uint mint,uint f)
    {
        require(spreads[addr].parent != address(0), "address is not a generalization set");
        _update();
        //require(spreads[msg.sender].cycle != cycle,"The operation cannot be repeated within one cycle");
        if (spreads[addr].cycle < cycle) {
            uint old_cycle = spreads[addr].cycle;
            uint old_profit = power_profit_whole[old_cycle].profit;
            uint old_power = power_profit_whole[old_cycle].power;
            uint v = old_profit.mul(spreads[addr].real_power) / old_power;
            _mint(addr,v);
            emit VoteProfit(addr,old_cycle,v);
            mint = v;
            spreads[addr].real_power = 0;
            spreads[addr].cycle = cycle;
        }
        uint old_s = spreads[addr].real_power;
        uint s = spreadFraction(addr);
        if (s > old_s) {
            whole_power += (s - old_s);
            spreads[addr].real_power = s;
            emit PreVoteProfit(addr,cycle,s);
            f = s;
        } else {
            f = 0;
        }
    }

    function _update() private returns (bool) {
        if (block.timestamp > (begin + cycle * cycle_period)) {
            uint profit = 15 * 10000 * (10**decimals);
            if (cycle > 120) {
                // 10 years 6%
                profit = totalSupply * 4 / 1000;
            }
            power_profit_whole[cycle] = power_profit({power:whole_power,profit:profit});
            whole_power = 0;
            cycle += 1;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev children
     */
    function spreadChild(address addr) public view returns (Info[] memory infos) {
        uint n = spreads[addr].child.length;
        infos = new Info[](n);
        for (uint i = 0; i < n; i++) {
            infos[i] = spreads[spreads[addr].child[i]];
        }
    }
    
    /**
     * @dev fraction
     */
    function spreadFraction(address addr) public view returns (uint power_)
    {
        uint v = spreads[addr].vote_power;
        uint sum = v * 4;
        sum += SafeMath.min(v,spreads[spreads[addr].parent].vote_power) * 2;

        uint n = spreads[addr].child.length;
        for (uint i = 0; i < n; i++) {
            sum =  SafeMath.min(v,spreads[spreads[addr].child[i]].vote_power);
        }
        power_ = sum;
    }
}