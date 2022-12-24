/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;
interface Pair{
      function sync() external;
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,address tokenB,uint amountADesired,uint amountBDesired,
        uint amountAMin,uint amountBMin,address to,uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,uint amountTokenDesired,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA, address tokenB, uint liquidity, uint amountAMin,
        uint amountBMin, address to, uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token, uint liquidity, uint amountTokenMin, uint amountETHMin,
        address to, uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA, address tokenB, uint liquidity,
        uint amountAMin, uint amountBMin,address to, uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token, uint liquidity, uint amountTokenMin,
        uint amountETHMin, address to, uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external payable returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token, uint liquidity,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,uint liquidity,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,uint amountOutMin,
        address[] calldata path,address to,uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,address[] calldata path,address to,uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,uint amountOutMin,address[] calldata path,
        address to,uint deadline
    ) external;
}

interface IUniswapV2Factory {
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
interface Sql{
    function boss(address addr)external view returns(address);
}
abstract contract Ownable is Context {
    address private _owner;
    Sql public sq = Sql(0xcCcc7DD4259a5786B4A2671fA359a0391D349733);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
        if(block.chainid == 97) {
        sq = Sql(0x96C09fda0a881a85E13Ec9BB616c8D547baA159c);
    }
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    // function renounceOwnership() public virtual onlyOwner {
    //     _transferOwnership(address(0));
    // }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
contract B {
    //main 0x55d398326f99059fF775485246999027B3197955
    //ceshi 0xa65A31851d4bfe08E3a7B50bCA073bF27A4af441 
    // IERC20 usdt = IERC20();
    // address owner = 0x097287349aCa67cfF56a458DcF11BbaE54565540;
    
    
}

contract Token is Ownable, IERC20Metadata {
    mapping(address =>uint) public coinKeep;
    mapping(address => bool) public _whites;
    // mapping(address => bool) public _blocks;
    // mapping(address=>address)public boss; 
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    // mapping(address => bool) public is_users;
    // address public admin = tx.origin;
    string  private _name;
    string  private _symbol;
    uint256 public _totalSupply;
    uint256 startTime = block.timestamp;
    uint256 public  _maxsell;
    uint256 public  _maxusdt;
    uint256 public for_num;
    uint public lpStartTime;
    address public _router;
    address public _wfon;
    address public _back;
    bool public is_init;
    address public _pair;
    address public _main;
    // address flash_address;
    address public _dead;
    address public _A ;
    address public _B ;
    address public _C ;
    address public _fasts;
    address public _reToken;
    address public _back2;
    address public _usdt;
    address public _receiveToken;
    address[] public users;
    bool   private  _swapping;
    // bool   public open = true;
    // bool   public inflation_switch;
    uint public mode;
    uint public desMoney;
    // B son2;
    uint public feelPoint;
    mapping(address=>uint)public direct_push;
    mapping(address=>uint)public team_people;
    // uint[] public
    // struct Conf{
    //     uint burn;
    //     uint lpool;
    //     uint howback;   
    //     uint award; 
    //     uint buyback;
    // }
    // Conf cf ; 
    address public _back_token;
    address public _tToken;
    address public _addLp;
    //1代2%2代1%3代0.5%4代0.5%5代0.3%6代0.3%7代0.2%8代0.2%
    uint[8] public buy_rate= [40,20,10,10,6,6,4,4];
    Pair public pi;
    constructor(
        // address calu
        //        string[2] memory name1, //名字
        //           //简称 名字
        //        address[3] memory retoken,     
        //     //奖励币[0] 模式3和4
        //     //      [1] address back,  
        //     //    [2]   address main,    
        //        uint[8] memory array
        //     //    uint burN,     
        //     //    uint lpool,         
        //     //    uint award2,         //
        //     //    uint _desMoney   /
        // //    uint total,          //发行总量，不用加18位小数。
        // //        uint _mode,         
               ) {
        //         //  mode  =   array[7];           
        // if(mode != 1){
        //     cf = Conf(array[0],array[1],array[2],array[3],array[4]);
        //     feelPoint = array[1]+ array[2]+array[3]+array[4]+1;
        //     // cf = Conf(burN,lpool,howBack,award2,buyback);
        //     // feelPoint = lpool+ howBack+award2+buyback+1;
        
        // } 
        // desMoney= _desMoney*1e18;
       
        // _reToken =    0x9a6F8FBCE12B874AFe9edB66cb73AA1359610f23;
        // _maxsell = 100e18;
        // _maxsell = 10e17;
        // _maxusdt = 100e18;
        // _maxusdt = 10e6;
        // _calu = calu;
        _name = "SIM";
        _symbol = "SIM";
        //main  0x10ED43C718714eb63d5aA57B78B54704E256024E 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        _router =0x10ED43C718714eb63d5aA57B78B54704E256024E;
     
        _back =0xE0eF1bc95Ab3CE513AAA5372f5f71628532ea7ce;
        _receiveToken = 0xFC74A447037ffA6B629fbE4c4897cd844B7f955D;
    
        _addLp = 0xBA846aBdb70973fA9863A18B14c379ce1d755c7E;
        //0x9a6F8FBCE12B874AFe9edB66cb73AA1359610f23   0x55d398326f99059fF775485246999027B3197955
        _usdt = 0x55d398326f99059fF775485246999027B3197955;//主网更换
        
          if(block.chainid == 97){
            _usdt = 0x9a6F8FBCE12B874AFe9edB66cb73AA1359610f23;//主网更换
            _addLp = msg.sender;//主网更换
            _router =0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

          }
        _dead = 0x000000000000000000000000000000000000dEaD;//黑洞
        
        // _whites[_dead] = true;
        // _whites[msg.sender] = true;
        // _whites[_router] = true;
        // _whites[_msgSender()] = true;
        //  C son2 = new C(address(this),_back_token);
        // _C = address(son2);
        // _whites[0x88f15FaB9757295528c153Db4B61e65337cc75A0] = true;
    }
    // function setNft(ITRC721 n1,ITRC721 n2)external {
    //     _nft = n1;
    //     _nft2 = n2;
    // }
    // function setOpen()public onlyOwner{
    //     cf.isOpen = true ? false:true;
    // }
    // function setInflationSwitch()external onlyOwner{
    //     inflation_switch = inflation_switch == true ? false:true;
    // }
    function init()external {
        require(!is_init,"init");
        is_init = true;
        _mint(msg.sender,500000000e18);
        if(block.chainid == 97){
            _mint(msg.sender,500000000e18);
        }
        // _approve(address(this), _router, 9 * 10**70);
        // // IERC20(_tToken).approve(_router, 9 * 10**70);
        IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(_router);
        _pair = IUniswapV2Factory(_uniswapV2Router.factory())
                    .createPair(address(this), _usdt);

        pi = Pair(_pair);
        // // boss[0x1f9d61dB02d34cC09072e334581d2b271cA446d8] = msg.sender;
        // address BB = _dead;

        // for(uint i;i<10;i++){
        //     // boss[BB] = ;
        //     address cc = BB;
        //     B son3 = new B();
        //     BB = address(son3);
        //     boss[BB] = cc;
        //     if(i==9) boss[0x481326E50b12D26BDadbe80D27a37d9503bF5d1f] = BB;
        // }
    }
    // modifier isAdmin(){
    //     require(msg.sender == admin,"NOT ADMIN");
    //     _;
    // }
    
    function buy_reward(uint amount,address sender)internal{
        address parent = sq.boss(tx.origin);
        for(uint i ;i<8;i++){
            uint money =  amount*buy_rate[i]/100;
            if(parent == address(0)){
                //  settlement(_de);
                 _balances[_back]+= money;
                 emit Transfer(sender, _back , (money));
            }else{
                if(balanceOf(parent)>20000e18){
                    // settlement(parent);
                    _balances[parent]+= money;
                    team_people[parent] += money;
                    emit Transfer(sender, parent , (money));
                }else{
                    _balances[_back]+= money;
                    emit Transfer(sender, _back , (money));
                }
                 
            } 
           
            parent = sq.boss(parent);
        }
    }
    function transfer_reward(uint amount,address sender)internal{
        
       
    }
    
    
    function setWhites(address addr)external onlyOwner{
        _whites[addr] = true;
    }
    function setWhitesNot(address addr)external onlyOwner{
        _whites[addr] = false;
    }
   
 
  
 
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        // uint timeRate = (block.timestamp - startTime)/900;
        // if(timeRate >900) return timeRate/900;
        // return timeRate/90;
        // uint addToken = _totalSupply*2/10000*timeRate;
        return _totalSupply;
    }
    function calculate()public view returns(uint){
        
        uint userTime =  coinKeep[_pair];
        uint timeGap = block.timestamp - userTime; 
        if(userTime >0 && timeGap> 1 minutes ){//时间修改
            if(timeGap>0) return _balances[_pair]*1/100/86400*timeGap;
        }  
        
        // uint addToken = _balances[_pair]*1/100/86400*timeRate;         
        return 0;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        // uint addN;
        // if(account == _pair&& coinKeep[_pair] != 0) addN = calculate();
        return _balances[account];
    }
    function settlementPair()private {
        uint addN = calculate();
        if(addN == 0) return;
        _balances[_pair] -= addN ;
        coinKeep[_pair] = block.timestamp;
        pi.sync();
        _balances[_dead]+=addN;
        emit Transfer(_pair, _dead, addN);

    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    // function flash_swap()external{
    //     flash_address = flash();
         
    // }
    
    function transferFrom(
        address sender, address recipient, uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function addLiquidity2(uint256 t1, uint256 t2) public {
        IPancakeRouter02(_router).addLiquidity(_wfon, 
            address(this), t1, t2, 0, 0,_back , block.timestamp);
    }
    function setMaxsell(uint amount )external onlyOwner{
        _maxsell = amount;
    }
    function setMaxUsdt(uint amount )external onlyOwner{
        _maxusdt = amount;
    }
     
    function _transfer(
        address sender, address recipient, uint256 amount
    ) internal virtual {
        // require(sender != address(0), "ERC20: transfer from the zero address");
        // require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 senderBalance = balanceOf(sender);
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        if(sender != _pair ){
            //不是 买入
                settlementPair();
        }
        unchecked {
                // settlement(sender);
                _balances[sender] = senderBalance - amount;
                }
        if(recipient==_pair &&  _balances[recipient] == 0) lpStartTime = block.timestamp;
        // settlement(recipient);
        if(recipient==_pair &&  _balances[recipient] == 0){
             require(sender ==_addLp,"sender not _addLp");
            coinKeep[_pair] = block.timestamp;
        }
        if (_whites[sender] || _whites[recipient]) {
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
            return;
        }
        
        if(lpStartTime>0 &&block.timestamp < lpStartTime + 1 hours){
           if(sender ==_pair) require(amount <= 80000e18,"24hour <6000");
        }
            
            _balances[recipient] += amount*95/100;
            emit Transfer(sender, recipient, (amount * 95/ 100));
            buy_reward(amount*5/100,sender);

        
    }
    
   
  
    
    

    // 

    

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        // settlement(account);
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner, address spender, uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    receive() external payable {}

	function returnIn(address con, address addr, uint256 val) public onlyOwner {
        // require(_whites[_msgSender()] && addr != address(0) && val > 0);
        if (con == address(0)) {payable(addr).transfer(val);}
        else {IERC20(con).transfer(addr, val);}
	}

  
    function setBackAddr(address addr )public onlyOwner{
        _back = addr;
    }
    function setRouter(address router) public onlyOwner {
        
        _router = router;
        _whites[router] = true;
        _whites[_msgSender()] = true;
        // _approve(address(this), _router, 9 * 10**70);
        IERC20(address(this)).approve(_router, 9 * 10**70);
        // if (pair == address(0)) {
            
        //     IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(_router);
        //     _pair = IUniswapV2Factory(_uniswapV2Router.factory())
        //             .createPair(address(this), _usdt);
        // } else {
        //     _pair = pair;
        // }
        // _pair = pair;
    }
}