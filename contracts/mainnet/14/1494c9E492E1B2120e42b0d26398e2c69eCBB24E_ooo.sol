/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

// SPDX-License-Identifier: None

pragma solidity 0.8.17;

interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address addr_recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender_addr, address addr_recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
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
    
}


abstract contract Context {
    function _msgsender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}





interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}


   

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface IUniswapV2Router02 is IUniswapV2Router01  {
      function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed prevOwner, address indexed newOwner);
    constructor () {
         _owner = 0xFF0bb4ef552f4773082917616619F098592065dd;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
 
    function renounceOwnership() public virtual  {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}





contract ooo is Context, IERC20, Ownable { 

    using SafeMath for uint256;

    
    string private constant _name = unicode"oo"; 
    string private constant _symbol = "oo"; 

    uint8 private constant _decimals = 8;
    uint256 public _tTotal =  10**7 * 10**_decimals;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _isExcludedFromFee; 
    mapping (address => uint256) private _tBalance;


    uint256 public _maxWalletToken = 500 * _tTotal.div(1000);
    uint256 public _maxTxAmount = _maxWalletToken; 
                          
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
   
    
    constructor () {
       
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        //
        //0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this),_uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        //_isExcludedFromFee[address(0)] = true;
        //_isExcludedFromFee[address(0x000000000000000000000000000000000000dEaD)] = true;
         _tBalance[owner()] = _tTotal;
        emit Transfer(address(0), address(this), _tTotal);

    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tBalance[account];
    }

    function transfer(address addr_recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgsender(), addr_recipient, amount);
        return true;
    }

   function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgsender(), spender, amount);
        return true;
    }

    function transferFrom(address sender_addr, address addr_recipient, uint256 amount) public override returns (bool) {
        _transfer(sender_addr, addr_recipient, amount);
        _approve(sender_addr, _msgsender(), _allowances[sender_addr][_msgsender()].sub(amount, " amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgsender(), spender, _allowances[_msgsender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgsender(), spender, _allowances[_msgsender()][spender].sub(subtractedValue, " allowance below zero"));
        return true;
    }

    receive() external payable {}

    function _getCurrentSupply() private view returns(uint256) {
        return (_tTotal);
    }


 function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), " ERR: approve from the zero address");
        require(spender != address(0), " ERR: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(        address from,        address to,        uint256 amount    ) private {
        
        require(amount > 0, "Token amount must be higher than 0.");    
      
        _tokenTransfer(from, to, amount);
    }
    
     function _tokenTransfer(address sender_addr, address addr_recipient, uint256 tokenAmount) private {        

        _tBalance[sender_addr] = _tBalance[sender_addr]-tokenAmount;
        _tBalance[addr_recipient] = _tBalance[addr_recipient]+tokenAmount;
        emit Transfer(sender_addr, addr_recipient, tokenAmount);

     }

  

}