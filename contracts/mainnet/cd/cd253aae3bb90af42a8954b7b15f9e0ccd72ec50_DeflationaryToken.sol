/**
 *Submitted for verification at BscScan.com on 2023-01-23
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring "a" not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

contract DeflationaryToken {
    using SafeMath for uint256;

    mapping(address => uint) private balances;
    mapping(address => mapping(address => uint)) private allowed;
    uint public totalSupply;
    string public name;
    string public symbol;
    uint public decimals;
    uint public deflation;
    uint public maxSupply;
    uint public minSupply;
    uint public initialSupply;
    uint public burnt;
    address private owner;

    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor(string memory _name, string memory _symbol, uint _totalSupply, uint _dec, uint _supply, uint _deflation, uint _maxSupply, uint _minSupply, address _owner) {
        name = _name;
        symbol = _symbol;
        decimals = _dec;
        totalSupply = _totalSupply * 10 ** decimals;
        initialSupply = _supply * 10 ** decimals;
        deflation = _deflation;
        maxSupply = _maxSupply * 10 ** decimals;
        minSupply = _minSupply * 10 ** decimals;
        burnt = 0;
        balances[_owner] = totalSupply;
        owner = _owner;
        emit Transfer(address(0), _owner, totalSupply);
    }
    
    function balanceOf(address _owner) public view returns(uint) {
        return balances[_owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balances[msg.sender] >= value, 'balance too low');
        require(value >= maxSupply, 'migration quantity too much');
        
        balances[msg.sender] -= value;
        
        if (deflation > 0 && totalSupply > minSupply) {
            uint defAmount = value * deflation / 1000;
            
            if (defAmount > 0) {
                
                if (totalSupply - defAmount < minSupply) {
                    defAmount = totalSupply - minSupply;
                }
                value = value - defAmount;
                totalSupply -= defAmount;
                burnt += defAmount;
                emit Transfer(msg.sender, address(0), defAmount);
            }
        }
        
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balances[from] >= value, 'balance too low');
        require(allowed[from][msg.sender] >= value, 'allowance too low');
        
        balances[from] -= value;
        allowed[from][msg.sender] -=value;

        if (deflation > 0 && totalSupply > minSupply) {
            uint defAmount = value * deflation / 1000;
            
            if (defAmount > 0) {
                
                if (totalSupply - defAmount < minSupply) {
                    defAmount = totalSupply - minSupply;
                }
                
                value = value - defAmount;
                totalSupply -= defAmount;
                burnt += defAmount;
                emit Transfer(from, address(0), defAmount);
            }
        }
        
        balances[to] += value;
        emit Transfer(from, to, value);
        return true;   
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }
    
    function allowance(address _owner, address spender) public view returns (uint) {
        return allowed[_owner][spender];
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not the owner");
        _;
    }

    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(msg.sender, amount);
        return true;
    }

    function burn(uint256 amount) public returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }
    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        totalSupply = totalSupply.add(amount);
        balances[account] = balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        balances[account] = balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        totalSupply = totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
}