/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-04
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;



abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) { //ritorna il msg.sender sotto forma di payable address
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) { //ritorna l'intera calldata
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 { //interfaccia dei token di tipo ERC20

    function totalSupply() external view returns (uint256); //ritorna il totale dei token in circolazione
    function balanceOf(address account) external view returns (uint256); //dato un address ritorna i token da lui posseduti
    function transfer(address recipient, uint256 amount) external returns (bool); //sposta x token dal msg.sender a un address
    function allowance(address owner, address spender) external view returns (uint256); //permette a qualcuno di spostare x token dal contratto
    function approve(address spender, uint256 amount) external returns (bool); //approva la transazione
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool); //transferisci x token da un sender a un recipient
    event Transfer(address indexed from, address indexed to, uint256 value);//evento di trasferimento
    event Approval(address indexed owner, address indexed spender, uint256 value);//evento di approvazione
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) { //somma due parametri verificando che il risultato sia maggiore di uno dei due
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {//dati due parametri aggiunge una riga di errore in caso il secondo sia maggiore del primo
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) { //verifica che il secondo parametro sia minore o uguale al primo
        require(b <= a, errorMessage);
        uint256 c = a - b; //effettua la sottrazione

        return c; //ritorna il risultato
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) { //moltiplica un numero
        if (a == 0) { //se a è uguale a 0 ritorna 0
            return 0;
        }

        uint256 c = a * b; //effettua la moltiplicazione
        require(c / a == b, "SafeMath: multiplication overflow");//se il risultato diviso il primo parametro non è uguale al secondo parametro da errore

        return c;//ritorna il risultato
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {//richiama un'altra funzione aggiungendo l'errore in caso di divisione per 0
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage); //verifica che b sia maggiore di '
        uint256 c = a / b; //effettua la divisione
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;//ritorna il quoziente
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {//ritorna una funzione verificando che il divisore non sia 0
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);//richiede che b sia diverso da 0
        return a % b;//ritorna il modulo di a e b
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) } //ritorna l'hash dell'address passato come parametro
        return (codehash != accountHash && codehash != 0x0);//verifica che l'accoutn sia stato creato e che contenga del codice
    }

    function sendValue(address payable recipient, uint256 amount) internal { //manda dell'ethereum a un address
        require(address(this).balance >= amount, "Address: insufficient balance"); //richiede che il quantitativo di eth nel contratto sia più alto dell'amount

        //solhint-disadble-next-line avoid-low-level-calls, avoid-call-value
        //chiama una funzione nell'address del recipient, tra le graffe si indica quanto eth mandare (in wei) e un limite di gas (se assente è infinito)
        //nelle tonde bisogna inserire la funzione da chiamare, in questo caso è vuota quindi richiamerà la fallback o la receive
        //ritorna due variabili, una boolean che indica se ha avuto successo la call e una stringa di byte (in caso la funzione ritorni qualcosa)
        (bool success, ) = recipient.call{ value: amount }("");       
        //se ha avuto successo lo conferma altrimenti da errore
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {//richiama una funzione aggiungendo l'error message
      return functionCall(target, data, "Address: low-level call failed"); //ritorna il risultato della funzione chiamata
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {//chiama una funzione aggiungendo la vlaue
        return _functionCallWithValue(target, data, 0, errorMessage); //ritorna il risultato della funzione chiamata
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {//richiama una funzione omonima aggiungendo l'errore message
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");//ritorna il risultato della funzione chiamata
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) { //richiama una funzione privata
        require(address(this).balance >= value, "Address: insufficient balance for call");//verifica che il balance del contratto sia più alto del value da inviare
        return _functionCallWithValue(target, data, value, errorMessage);//ritorna il risultato di una funzione
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract"); //verifica che l'hash dell'address sia di un contratto contenente codice
        // richiama un metodo all'interno dell'address "target", il valore e il nome
        // ritornando la boolean success e la bytes memory contenente il
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data); 
        if (success) {//se ha avuto successo ritorna il valore ritornato dalla funzione
            return returndata;
        } else {
            
            if (returndata.length > 0) {//se returndata contiene qualcosa
                assembly {
                    let returndata_size := mload(returndata) //carica dalla memoria i dati conenuti in returndata
                    revert(add(32, returndata), returndata_size)//da errore con argomento 32+returndata e i dati all'interno di returndata
                }
            } else {//altrimenti da errore
                revert(errorMessage);
            }
        }
    }
}

contract Ownable is Context { //contratto che serve a rendere alcune funzioni limitate da un solo indirizzo, ereditaria da context
    address private _owner; //proprietario del contratto
    address private _previousOwner; //proprietario precedente del contratto

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner); //evento di trasferimento della proprietà

    constructor () { //costruttore che assegna la proprietà al creatore del contratto
        address msgSender = _msgSender(); //address con valore msg.sender, la funzione è contenuta in context
        _owner = msgSender;//l'owner del contratto è il msg.sender durante la creazione
        emit OwnershipTransferred(address(0), msgSender);//evento di trasferimento da address(0) al msg.sender
    }

    function owner() public view returns (address) {//ritorna l'owener
        return _owner;
    }   
    
    modifier onlyOwner() {//modifier da aggiungere alle funzioni per renderle richiamabili solo dall'owner
        require(_owner == _msgSender(), "Ownable: caller is not the owner");//verifica che il msg.sender sia uguale all'owner altrimenti da errore
        _;//tutto ciò che c'è sopra viene eseguito prima del codice della funzione quello sotto dopo
    }
    
    function waiveOwnership() public virtual onlyOwner {//rinuncia alla ownership passandola all'address (0) ATTENZIONE non sarà più possibile usare le funzioni onlyOwner
        emit OwnershipTransferred(_owner, address(0));//evento di trasferimento della ownership
        _owner = address(0);//modifica della state variable
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {//transferisce l'ownership dal vecchio al nuoov owner
        require(newOwner != address(0), "Ownable: new owner is the zero address");//richiede che il nuovo owner sia diverso dall'address(0) altrimenti usare la funzione waiveOwnership
        emit OwnershipTransferred(_owner, newOwner);//evento di trasferimento della owenership
        _owner = newOwner;//modifica della state variable
    }
}

interface IUniswapV2Factory {//interfaccia della factory di UniswapV2
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

interface IUniswapV2Pair { //interfaccia all'uniswapv2pair
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);//ritorna il nome del token
    function symbol() external pure returns (string memory);//ritorna il sombolo del token
    function decimals() external pure returns (uint8);//ritorna il numero di decimali del token
    function totalSupply() external view returns (uint);//ritorna la supply totale del token
    function balanceOf(address owner) external view returns (uint);//ritorna il balance dell'address passato
    function allowance(address owner, address spender) external view returns (uint);//ritorna quanti token può spender trasferire per conto di owner tramite transferfrom
    function approve(address spender, uint value) external returns (bool);//imposta l'allowance a un valore specifico
    function transfer(address to, uint value) external returns (bool);//sposta i tuoi token a un indirizzo
    function transferFrom(address from, address to, uint value) external returns (bool);//sposta i token da un indirizzo a un altro se chi esegue il comando ha abbastanza allowance

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    
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

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

contract MinchiaFRA is Context, IERC20, Ownable {
    //Usare le librerie
    using SafeMath for uint256;
    using Address for address;
    //nome, simbolo e decimali del token ATTENZIONE le variabili devono avere questo nome
    string private _name = "MinchiaFRA";
    string private _symbol = "FRA";
    uint8 private _decimals = 9;

    address payable public marketingWalletAddress = payable(0xEe304ef98877AD69A8D7eB0B1CDe7e675071D0D7); // Marketing Address
    address payable public BuyBackWalletAddress = payable(0xEe304ef98877AD69A8D7eB0B1CDe7e675071D0D7); // BuyBack Address
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD; //Dead Address
    //ATTENZIONE le seguenti 2 variabili devono avere questo nome
    mapping (address => uint256) _balances; //Balance di ogni account
    mapping (address => mapping (address => uint256)) private _allowances;//Address 1 può 
    
    mapping (address => bool) public isExcludedFromFee; //Se l'indirizzo è esente dalle fee
    mapping (address => bool) public isWalletLimitExempt;// è esente dal limite di grandezza dei wallet
    mapping (address => bool) public isTxLimitExempt;//è esente dal limite delle transazioni
    mapping (address => bool) public isMarketPair;//Fa parte delle market pair

    uint256 public _buyLiquidityFee = 2;//tassa sull'acquisto per la liquidita
    uint256 public _buyMarketingFee = 2;//tassa sull'acquisto per il marketing
    uint256 public _buyBuyBackFee = 0;//tassa sull'acquisto per il buyback dei token
    uint256 public _sellLiquidityFee = 2;//tassa sulla vendita per la liquidita
    uint256 public _sellMarketingFee = 2;//tassa sulla vendita per il marketing
    uint256 public _sellBuyBackFee = 0;//tassa sulla vendita per il buyback

    uint256 public _liquidityShare = 2;
    uint256 public _marketingShare = 2;
    uint256 public _BuyBackShare = 0;

    uint256 public _totalTaxIfBuying = 0;//tassa totale se si compra
    uint256 public _totalTaxIfSelling = 0;//tassa totale se si vende
    uint256 public _totalDistributionShares = 0;

    uint256 private _totalSupply = 1000 * 10**6 * 10**9;//Supply totale ATTENZIONEla variabile deve avere questo nome
    uint256 public _maxTxAmount = 10 * 10**6 * 10**9;//grandezza massima della transazione
    uint256 public _walletMax = 10 * 10**6 * 10**9;//grandezza massima del wallet
    uint256 private minimumTokensBeforeSwap = 25000 * 10**9; //Token minimi prima di scambiarli

    IUniswapV2Router02 public uniswapV2Router; //creazione del router
    address public uniswapPair; //creazione dell'address pubblico della pair
    
    bool inSwapAndLiquify; //Variabile che verifica se dentro la funzione Swap and liquify Vedere modifier lockTheSwap
    bool public swapAndLiquifyEnabled = true; //abilità lo swap and liquify
    bool public swapAndLiquifyByLimitOnly = false;//Variabile utilizzata nella sezione transfer e abilitabile dalla funzione setSwapAndLiquifyByLimitOnly
    bool public checkWalletLimit = true;//abilità i limiti di grandezza dei wallet

    event SwapAndLiquifyEnabledUpdated(bool enabled);//evento lanciato in caso di aggiornamento della variabile swapAndLiquifyEnabled
    event SwapAndLiquify(//lanciato alla fine della funzione swap and liquify
        uint256 tokensSwapped,//numero di token scambiati
        uint256 ethReceived,//eth ricevuto
        uint256 tokensIntoLiqudity//numero di token andati in liquidità
    );
    
    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );
    
    modifier lockTheSwap {//blocca gli swap se si sta eseguendo la funzione swap and liquify
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {
        
        //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); //assegna come router PancakeSwap
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); //PancakeSwap Testnet
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()) //usa la funzione factory all'interno del router per trovare l'indirizzo della factory di pancakeswap
            .createPair(address(this), _uniswapV2Router.WETH());//crea una coppia con questo indirizzo e il WETH della rete (in questo caso WBNB)

        uniswapV2Router = _uniswapV2Router; //imposta la state variable  del router come l'indirizzo creato in precedenza
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;//imposta come allowance della coppia tra il contratto e il router l'intera supply

        isExcludedFromFee[owner()] = true;//esclude dalle fee l'owner
        isExcludedFromFee[address(this)] = true;//esclude dalle fee il contratto
        
        _totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee).add(_buyBuyBackFee);//imposta come tassa totale per comprare la somma delle tasse marketing, buyback e liquidita
        _totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee).add(_sellBuyBackFee);//imposta come tassa totale per vendere la somma delle tasse marketing, buyback e liquidita
        _totalDistributionShares = _liquidityShare.add(_marketingShare).add(_BuyBackShare);//imposta come dividendo totale la somma delle tasse marketing, buyback e liquidita

        isWalletLimitExempt[owner()] = true;//esclude dal limite di grandezza del wallet l'owner
        isWalletLimitExempt[address(uniswapPair)] = true;//esclude dal limite di grandezza del wallet la coppia
        isWalletLimitExempt[address(this)] = true;//esclude dal limite di grandezza del wallet il contratto
        
        isTxLimitExempt[owner()] = true;//esclude dal limite di transazione l'owner
        isTxLimitExempt[address(this)] = true;//esclude dal limite della transazione il contratto

        isMarketPair[address(uniswapPair)] = true;//imposta la pair come true nel isMarketPair

        _balances[_msgSender()] = _totalSupply;//il balance del creatore del contratto diventa l'intera supply
        emit Transfer(address(0), _msgSender(), _totalSupply);//evento di trasferimento della supply da null al creatore
    }

    function name() public view returns (string memory) {//funzione che ritorna il nome del token
        return _name;
    }

    function symbol() public view returns (string memory) {//funzione che ritorna il simbolo del token

        return _symbol;
    }

    function decimals() public view returns (uint8) {//funzione che ritorna i decimali del token
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {//funzione che ritorna la supply del token
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {//funzione che ritorna il balance di token di un account
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {//ritorna l'allowance di un owner nei confronti di uno spender
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {//aumenta l'allowance del msg.sender nei confronti dello spender, ritorna un bool
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {//diminuisce l'allowance del msg.sender nei confronti dello spender, ritorna un bool
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {//funzione pubblica che richiama l'approve privata impostando come owner il msg.sender
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {//cambia l'allowance
        require(owner != address(0), "ERC20: approve from the zero address");//verifica che l'owner sia diverso dallo zero address
        require(spender != address(0), "ERC20: approve to the zero address");//verifica che lo spender sia diverso dallo zero address

        _allowances[owner][spender] = amount;//imposta come allowance il numero passato come parametro
        emit Approval(owner, spender, amount);//emette l'evento con i valori 
    }

    function addMarketPair(address account) public onlyOwner {//aggiunge un address come market pair
        isMarketPair[account] = true;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {//imposta se un address ha limiti di transazione
        isTxLimitExempt[holder] = exempt;
    }
    
    function setIsExcludedFromFee(address account, bool newValue) public onlyOwner {//imposta se un account è escluso dalle tasse
        isExcludedFromFee[account] = newValue;
    }

    function setBuyTaxes(uint256 newLiquidityTax, uint256 newMarketingTax, uint256 newBuyBackTax) external onlyOwner() {//cambia i valori delle tasse sugli acquisti
        _buyLiquidityFee = newLiquidityTax;
        _buyMarketingFee = newMarketingTax;
        _buyBuyBackFee = newBuyBackTax;

        _totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee).add(_buyBuyBackFee);
    }

    function setSellTaxes(uint256 newLiquidityTax, uint256 newMarketingTax, uint256 newBuyBackTax) external onlyOwner() {//cambia i valori delle tasse sulla vendita
        _sellLiquidityFee = newLiquidityTax;
        _sellMarketingFee = newMarketingTax;
        _sellBuyBackFee = newBuyBackTax;

        _totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee).add(_sellBuyBackFee);
    }
    
    function setDistributionSettings(uint256 newLiquidityShare, uint256 newMarketingShare, uint256 newBuyBackShare) external onlyOwner() {//cambia i valori dei dividendi
        _liquidityShare = newLiquidityShare;
        _marketingShare = newMarketingShare;
        _BuyBackShare = newBuyBackShare;

        _totalDistributionShares = _liquidityShare.add(_marketingShare).add(_BuyBackShare);
    }
    
    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {//imposta il tetto massimo di transazione verificando che sia minore del 4% della total supply
        require(maxTxAmount <= (40 * 10**6 * 10**9), "Max wallet should be less or equal to 4% totalSupply");
        _maxTxAmount = maxTxAmount;
    }

    function enableDisableWalletLimit(bool newValue) external onlyOwner {//imposta se verificare o meno il wallet limit
       checkWalletLimit = newValue;
    }

    function setIsWalletLimitExempt(address holder, bool exempt) external onlyOwner {//imposta se un address è esente dal wallet limit
        isWalletLimitExempt[holder] = exempt;
    }

    function setWalletLimit(uint256 newLimit) external onlyOwner {//imposta la grandezza massima dei wallet
        _walletMax  = newLimit;
    }

    function setNumTokensBeforeSwap(uint256 newLimit) external onlyOwner() {//cambia il numero massimo di token prima di uno swap
        minimumTokensBeforeSwap = newLimit;
    }

    function setMarketingWalletAddress(address newAddress) external onlyOwner() {//cambia il wallet per le tasse di marketing
        marketingWalletAddress = payable(newAddress);
    }

    function setBuyBackWalletAddress(address newAddress) external onlyOwner() {//cambia il wallet per le tasse buyback
        BuyBackWalletAddress = payable(newAddress);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {//imopsta se lo SwapandLiquify è abilitato
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setSwapAndLiquifyByLimitOnly(bool newValue) public onlyOwner {//imposta se lo SwapAndLiquifyByLimitOnly è abilitato
        swapAndLiquifyByLimitOnly = newValue;
    }
    
    function getCirculatingSupply() public view returns (uint256) {//Ritorna la supply circolante (totale - quella del deadaddress)
        return _totalSupply.sub(balanceOf(deadAddress));
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {//transferisce a un indirizzo dell'ethereum
        recipient.transfer(amount);
    }
    
    function changeRouterVersion(address newRouterAddress) public onlyOwner returns(address newPairAddress) {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(newRouterAddress);//cambia il router address

        newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(address(this), _uniswapV2Router.WETH()); 

        if(newPairAddress == address(0)) //Create If Doesnt exist
        {
            newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory())//dalla factory del nuovo router crea una coppia con questo indirizzo e il loro WETH
                .createPair(address(this), _uniswapV2Router.WETH());
        }

        uniswapPair = newPairAddress; //Set new pair address
        uniswapV2Router = _uniswapV2Router; //Set new router address

        isWalletLimitExempt[address(uniswapPair)] = true;//imposta la nuova pair come esente dal limite del wallet
        isMarketPair[address(uniswapPair)] = true;//imposta la nuova pair come marketpair
    }

     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}
    //richiama la funzione _transfer aggiungendo come parametro sender il msg.sender, ritorna un bool
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    //richiama la funzione _transfer e rimuove l'allowance usata, ritorna un bool
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");//se i lsender è lo zero address da errore
        require(recipient != address(0), "ERC20: transfer to the zero address");//se il recipiente è lo zero address da errore

        if(inSwapAndLiquify)//se è dentro la swapandliquify richiama la funzione di trasferimento base
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {
            if(!isTxLimitExempt[sender] && !isTxLimitExempt[recipient]) {//verifica che entrambi siano esenti dal limite di transazione
                require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");//verificano che il valore della transazione sia sotto il limite
            }            

            uint256 contractTokenBalance = balanceOf(address(this)); //Token Nel contratto
            bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap; //maggiore del minimo
            
            if (overMinimumTokenBalance && !inSwapAndLiquify && !isMarketPair[sender] && swapAndLiquifyEnabled) //Sopra il minimo E NON dentro function swapandliquify E il sender non è parte della market pair E il la swap and liquify è enable
            {
                if(swapAndLiquifyByLimitOnly)//se è attiva la modalita solo limite
                    contractTokenBalance = minimumTokensBeforeSwap;//imposta come balance il minimo di token prima di uno swap
                    swapAndLiquify(contractTokenBalance);//richiama la swap and liquify con il minimo come token balance
            }

            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");//il balance di colui che invia viene sottratto da quanto bisogna inviare, se insuifficiente ritorna un errore

            uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) ? amount : takeFee(sender, recipient, amount);//verifica se uno dei due sia esente dalle tasse, in caso opposto sottrae le tasse

            if(checkWalletLimit && !isWalletLimitExempt[recipient])//se non è esente e non eccede il limite di grandezza del wallet
                require(balanceOf(recipient).add(finalAmount) <= _walletMax);//vedrifica che il suo balance + il nuovo amount sia più basso del limite dei wallet

            _balances[recipient] = _balances[recipient].add(finalAmount);//balance del destinatario + finalamount

            emit Transfer(sender, recipient, finalAmount);//evento di trasferimento dei fondi
            return true;//ritorno esito positivo
        }
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {//richiamata se già dentro SwapAndLiquify
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");//al balance di chi invia viene sottratto l'amount in caso sia insufficiente da errore
        _balances[recipient] = _balances[recipient].add(amount);//al destinatario vengono aggiunti i token
        emit Transfer(sender, recipient, amount);//evento di trasferimento dei fondi
        return true;//ritorno esito positivo
    }

    function swapAndLiquify(uint256 tAmount) private lockTheSwap { //E mo sono dolori
        
        uint256 tokensForLP = tAmount.mul(_liquidityShare).div(_totalDistributionShares).div(2);
        uint256 tokensForSwap = tAmount.sub(tokensForLP);

        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance;

        uint256 totalBNBFee = _totalDistributionShares.sub(_liquidityShare.div(2));
        
        uint256 amountBNBLiquidity = amountReceived.mul(_liquidityShare).div(totalBNBFee).div(2);
        uint256 amountBNBBuyBack = amountReceived.mul(_BuyBackShare).div(totalBNBFee);
        uint256 amountBNBMarketing = amountReceived.sub(amountBNBLiquidity).sub(amountBNBBuyBack);

        if(amountBNBMarketing > 0)
            transferToAddressETH(marketingWalletAddress, amountBNBMarketing);

        if(amountBNBBuyBack > 0)
            transferToAddressETH(BuyBackWalletAddress, amountBNBBuyBack);

        if(amountBNBLiquidity > 0 && tokensForLP > 0)
            addLiquidity(tokensForLP, amountBNBLiquidity);
    }
    
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = 0;
        
        if(isMarketPair[sender]) {
            feeAmount = amount.mul(_totalTaxIfBuying).div(100);
        }
        else if(isMarketPair[recipient]) {
            feeAmount = amount.mul(_totalTaxIfSelling).div(100);
        }
        
        if(feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount);
    }
    
}