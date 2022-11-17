/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/************************************************************
 *                                                          *
 *       github: https://github.com/metabasenet/fruit       *
 *                                                          *
 ************************************************************
 *                                                          *
 *          H5 app: https://fruit.metabasenet.site          *
 *                                                          *
 ************************************************************/
 
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

    function sqrt3(uint y) internal pure returns (uint z) {
        z = sqrt(y * 10**12);
        z = sqrt(z * 10**6);
        z = sqrt(z * 10**6);
    }

    // decimals = 18;
    // (10**decimals) ** 0.125
    function vote2power(uint y) internal pure returns (uint z) {
        if (y >= 6**8 * 1 ether) {
            z = z * 6 / 100;
        } else {
            z = y * sqrt3(y) / 17782794100;
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
        return balances[owner].add(balanceVote[owner]).add(spreads[owner].vote);
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
        
        // bsc test
        pair = pairFor(0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc,hex'ecba335299a6693cb2ebc4782e74669b84290b6378ea3a3873c7231a8d7d1074');
        
        uint _totalSupply = 1000_000 ether;
        _mint(msg.sender, _totalSupply);
        
        begin = block.number;
        spreads_length = 1;
        spreads[msg.sender] = Info({
            parent : address(this),
            cycle : 1,
            vote : 0,
            vote_power : 0,
            real_power : 0,
            lock_number : 0,
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

    // Oct-31-2022 07:31:20 PM +UTC
    uint public begin;
    // 
    uint public height = 0;
    //
    uint public constant height_profit = 0.1 ether;
    
    // bsc test 
    address public constant USDT = 0x89EB90e7E9480Ff2F39Dd60AA2c4FD6FD80472A3;

    uint public constant cycle_period = 60 * 20;
    uint public constant cycle_profit = 60 * 20 * (0.1 ether);
    
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
            uint add_height = block.number.sub(begin.add(height));
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
        // Voting lock number
        uint256 lock_number;
    }

    mapping(address => Info) public spreads;
    uint public spreads_length;
}