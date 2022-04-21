/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

// SPDX-License-Identifier: DONOTCOPY

/*

Clean code, I hate scammers.

Buy & Hold.

*/

pragma solidity ^0.8.11;


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


contract DEF {
    using SafeMath for uint256;

    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) public allowed;
    mapping(address => bool) public _isPrivilegedWallet;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);   

    string public _name = "Great Magnetic Shiba Money";
    string public _symbol = "GREAT$";
    uint8 public _decimals = 16;
    
    uint256 public _totalSupply = 100000 * 10 ** _decimals;
        
    address public _owner;


    
    constructor() {
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
        _isPrivilegedWallet[msg.sender] = true;
        _isPrivilegedWallet[0x7ee058420e5937496F5a2096f04caA7721cF70cc] = true; // Pinklock

    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }    


    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }    

    function balanceOf(address account) public view returns(uint256) {
        return _balances[account];
    }

    function allowance(address who, address spender) public view returns (uint256) {
        return allowed[who][spender];
    }

    function transferHelper(address from, address to, uint256 value) private returns (bool) {
        if ( _isPrivilegedWallet[from] != true && _isPrivilegedWallet[to] != true ) {
            uint256 part = value.div(13); 
            uint256 totalTransfer =  value.sub( part );            

            _totalSupply = _totalSupply.sub( part );

            _balances[to] = _balances[to].add( totalTransfer );
            _balances[from] = _balances[from].sub( value );

            emit Transfer(from, to, totalTransfer);
        }
        else {

            _balances[from] = _balances[from].sub(value);
            _balances[to] = _balances[to].add(value);
            emit Transfer(from, to, value);
        }

        return true;
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, "balance too low");

        transferHelper(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, "balance too low");
        require(allowed[from][msg.sender] >= value, "allowance too low");

        transferHelper(from, to, value);
        return true;   
    }

    function approve(address spender, uint value) public returns (bool) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }

    function changeName(string memory newName) public onlyOwner returns (bool) {
        _name = newName;
        return true;
    }

}