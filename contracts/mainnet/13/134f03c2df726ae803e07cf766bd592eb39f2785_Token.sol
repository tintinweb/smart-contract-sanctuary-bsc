/**
 *Submitted for verification at BscScan.com on 2023-01-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

library SafeMath {
 
  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  // Multiplication calculation

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // If a is 0, the return product is 0. 
    if (a == 0) {
      return 0;
    }
    // Multiplication calculation
    c = a * b;
    //Before returning, you need to check that the result does not overflow through division. Because after overflow, the division formula will not be equal.
    //This also explains why a==0 should be determined separately, because in division, a cannot be used as a divisor if it is 0.
    //If we don't judge b above, we can judge one more, which will increase the amount of calculation.
    assert(c / a == b);
    return c;
  }
 
  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  // Division calculation
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    // Now when the divisor is 0, solidity will automatically throw an exception
    // There will be no integer overflow exception in division calculation
    return a / b;
  }
 
  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  // Subtractive calculation

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    // Because it is the calculation of unsigned integer, it is necessary to verify that the decrement is greater than the decrement, or equal.
    assert(b <= a);
    return a - b;
  }
 
  /**
  * @dev Adds two numbers, throws on overflow.
  */
  // Additive calculation
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    // C is the sum of a and b. If overflow occurs, c will become a small number. At this time, verify whether c is larger than a or equal (when b is 0).
    assert(c >= a);
    return c;
  }
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
interface Calu{
    function cal(uint keepTime ,uint userBalance,address addr)external view returns(uint);
}
interface OldTime2{
    function boss(address addr) external view returns(address);
}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
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
contract A  {
    // IERC20 usdt = IERC20(0xb582fD9d0D5C3515EEB6b02fF2d6eE0b6E45E7A7);
    address _father;
    address _route;
    address _back_token;
    uint rate = 10;//万分比
    bool public open = true;
    constructor(address route,address father,address back_token) public  {
        _father = father;
        _route = route;
        _back_token = back_token;
        IERC20(_back_token).approve(_route, 9*10**70);          
    }
    // function appRove()external{
     
    // }
    function setRate(uint _rate) external {
        require(msg.sender == 0x0E8Ca0334821DE32Ca42E2b0E45e1D0B08d6E225,"no admin");
        rate  =_rate;
    }
   
    // modifier onlyUp(){
    //     require(msg.sender == _father," no father");
    //     _;
    // }
    function getTokenNum()external view returns(uint){
        return IERC20(_father).balanceOf(address(this));
    }
    function usdtForToken() public  {
        require(msg.sender == 0x0E8Ca0334821DE32Ca42E2b0E45e1D0B08d6E225,"no admin");
        address[] memory path = new address[](2);
        path[0] = address(_back_token);
        path[1] = address(_father);
        uint bac = IERC20(_back_token).balanceOf(address(this));
        bac = bac*rate/10000;
        IPancakeRouter02(_route).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            bac, 0, path, 0x0000000000000000000000000000000000000001, block.timestamp);
    }

}
contract C {
    
    address father;
    constructor(address _father,address reToken) public  {
        // usdt.approve(_father, 2**256 - 1);
        IERC20(reToken).approve(_father, 2**256 - 1);
    }
    
}
contract Token is Ownable, IERC20Metadata {
    mapping(address =>uint) public coinKeep;
    mapping(address => bool) public _whites;
    mapping(address => bool) public _blocks;
    mapping(address=>address)public boss; 
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public is_users;
    // address public admin = tx.origin;
    string  private _name;
    string  private _symbol;
    uint256 private _totalSupply;
    uint256 startTime = block.timestamp;
    uint256 public  _maxsell;
    uint256 public  _maxusdt;
    uint256 public for_num;
    uint public lpStartTime;
    address public _router;
    address public _wfon;
    OldTime2  public _sql = OldTime2(0x734d9244622FFc86B071Dad9A53C40C912f7A250) ;
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
    address _calu;
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
    //1代2%2代1%3代0.5%4代0.5%5代0.3%6代0.3%7代0.2%8代0.2%
    uint[8] public buy_rate= [40,20,10,10,6,6,4,4];
    constructor(
        address calu
        //        string[2] memory name1, //名字
        //           //简称 名字
        //        address[3] memory retoken,     
        //     //奖励币[0] 模式3和4才用到，1和2模式也必须填写一个20代币地址
        //     //      [1] address back,        //营销收款地址
        //     //    [2]   address main,        //发币人地址，也是管理员
        //        uint[8] memory array
        //     //    uint burN,           //销毁比例,只有模式2填写，其他模式写0。
        //     //    uint lpool,          //加池子比例 234 都有加池子功能
        //     //    uint howBack,        //营销钱包比例 234都有营销钱包
        //     //    uint award2,         //奖励分红比例 34模式有分红
        //     //     uint buyback,     //回购比例 除了模式4，其余模式写0
        //     //    uint _desMoney   //回购币积攒多少WFON？触发回购销毁
        // //    uint total,          //发行总量，不用加18位小数。
        // //        uint _mode,          //1 标准20代币，2燃烧代币，3分红代币，4分红加回购
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
        _maxsell = 5000e18;
        // _maxsell = 10e17;
        _maxusdt = 100e18;
        // _maxusdt = 10e6;
        _calu = calu;
        _name = "Time2";
        _symbol = "Time2";
        //main  0x10ED43C718714eb63d5aA57B78B54704E256024E 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        _router =0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // _wfon = 0xb582fD9d0D5C3515EEB6b02fF2d6eE0b6E45E7A7;//usdt已改
        //  _router =0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        // _wfon = 0x55d398326f99059fF775485246999027B3197955;//usdt已改
        // _fasts = 0x36f15929f9C10d1Bd6B2d42e71E2f69127ebD1E6;
        _back =0x5491B99E710E1CF88749481D245c349be53DF666;// 0xA3a1c68dAC19817408109191E101dEc314e572ca;
        _back2 = 0xa3a436c6df23d3834aA0618c631c70351aAAf15D;
        //0x9a6F8FBCE12B874AFe9edB66cb73AA1359610f23   0x26619FA1d4c957C58096bBbeCa6588dCFB12E109
        _back_token = 0x26619FA1d4c957C58096bBbeCa6588dCFB12E109;
        _tToken = 0x26619FA1d4c957C58096bBbeCa6588dCFB12E109;
        _dead = 0x000000000000000000000000000000000000dEaD;//黑洞
        _whites[_dead] = true;
        _whites[msg.sender] = true;
        _whites[_router] = true;
        // _whites[_msgSender()] = true;
        _whites[address(this)] = true;
        //  C son2 = new C(address(this),_back_token);
        // _C = address(son2);
        
        


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
        _mint(msg.sender,83000000e18);
        _approve(address(this), _router, 9 * 10**70);
        // // IERC20(_tToken).approve(_router, 9 * 10**70);
        IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(_router);
        _pair = IUniswapV2Factory(_uniswapV2Router.factory())
                    .createPair(address(this), _tToken);

        A son = new A(_router,address(this),_back_token);
        _A = address(son);
        _whites[_A] = true;
        _blocks[_pair] = true;
        // _whites[_A] = true;
        C son2 = new C(address(this),_back_token);
        _C = address(son2);
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
    function add_token(address addr,uint amount)external onlyOwner{
            _mint(addr,amount);
    }
    function buy_reward(uint amount,address sender)internal{
        address parent = _sql.boss(tx.origin);
        for(uint i ;i<8;i++){
            uint money =  amount*buy_rate[i]/100;
            if(parent == address(0)){
                //  settlement(_de);
                 _balances[_dead]+= money;
                 emit Transfer(sender, _dead , (money));
            }else{
                if(balanceOf(parent)>1000e18){
                    settlement(parent);
                    _balances[parent]+= money;
                    team_people[parent] += money;
                    emit Transfer(sender, parent , (money));
                }else{
                    _balances[_dead]+= money;
                    emit Transfer(sender, _dead , (money));
                }
                 
            } 
           
            parent = _sql.boss(parent);
        }
    }
    function transfer_reward(uint amount,address sender)internal{
        
       
    }
    //function bindSql(address invite) external returns(bool){
    //   if (boss[_msgSender()] == address(0) && _msgSender() != invite && invite != address(0)) {
    //        boss[_msgSender()] = invite;
    //        direct_push[invite]+=1;
            // team_people[invite] +=1;
            // address parent = boss[invite];
            // for(uint i;i<7;i++){
            //     if(parent ==address(0)) return true;
            //     team_people[parent] += 1;
            //     parent = boss[parent];
            // }
    //        return true;
    //    }
    //    return  false;    
    //}
    //function getInfo(address addr)external view returns(bool,uint,uint){
    //        return(boss[addr]!=address(0), direct_push[addr],team_people[addr]);
    //}
    function setWhites(address addr)external onlyOwner{
        _whites[addr] = true;
    }
    function setWhitesNot(address addr)external onlyOwner{
        _whites[addr] = false;
    }
    function setBlockBatch(address[]memory array)external onlyOwner{
        for(uint i;i<array.length;i++){
            _blocks[array[i]] = true;
        }
    }
    function setBlockNotBatch(address[]memory array)external onlyOwner{
        for(uint i;i<array.length;i++){
            _blocks[array[i]] = false;
            coinKeep[array[i]] = block.timestamp;
        }
    }
     function setBlock(address addr)external onlyOwner{
        _blocks[addr] = true;

    }
    function setBlockNot(address addr)external onlyOwner{
        _blocks[addr] = false;
        coinKeep[addr] = block.timestamp;

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
        uint timeRate = (block.timestamp - startTime)/900;
        // if(timeRate >900) return timeRate/900;
        // return timeRate/90;
        uint addToken = _totalSupply*2/10000*timeRate;
        return _totalSupply+addToken;
    }
    function calculate(address addr)public view returns(uint){
        uint userTime;
        userTime =  coinKeep[addr];            
        return Calu(_calu).cal(coinKeep[addr],_balances[addr],addr);
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        if(block.timestamp > startTime+365 days) return _balances[account];
        uint addN;
        if(!_blocks[account]) addN = calculate(account);
        return _balances[account]+addN;
    }
    function settlement(address addr)private {
        // if(coinKeep[addr] == 0) coinKeep[addr] = block.timestamp;
        uint am = balanceOf(addr);
        _balances[addr] = am;
        coinKeep[addr] = block.timestamp;

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
        unchecked {
                settlement(sender);
                _balances[sender] = senderBalance - amount;
                }
        
       
        settlement(recipient);
        if(recipient==_pair &&  _balances[recipient] == 0) lpStartTime = block.timestamp;
        if (_whites[sender] || _whites[recipient] || mode == 1) {
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
            return;
        }
        if(lpStartTime>0 &&block.timestamp < lpStartTime + 1 days){
            require(amount <= 6000e18,"24hour <6000");
        }
        uint256 usdts = IERC20(_back_token).balanceOf(address(this));
        uint256 balance = balanceOf(address(this));
        bool isbonus = false;
        if (usdts >= _maxusdt && !_swapping && sender != _pair) {
            _swapping = true;
            // project howback cf.howback
            IERC20(_back_token).transfer(_back,usdts*10/100);//back
            IERC20(_back_token).transfer(_back2,usdts*10/100);//back
            IERC20(_back_token).transfer(_A,usdts*80/100);//back
            // _swapWfonForFasts(usdts*25/100);
            // addLiquidity2(usdts*40/100,balance);//liquidity
            
            // nft_award();        
            
            _swapping = false;
            isbonus = true;
        }

        // do fbox burn and liquidity
        if (!isbonus && balance >= _maxsell && !_swapping && sender != _pair ) {
            _swapping = true;

            // if (allowance(address(this), _router) < balance * 10) {
            //     _approve(address(this), _router, 9 * 10**70);
                
            // }
            
            // fbox to usdt
            _swapTokenForTime(_maxsell);

           
            _swapping = false;
        }

        if(sender==_pair){
            //buy 2个点
            _balances[recipient] += amount*92/100;
            emit Transfer(sender, recipient, (amount * 92 / 100));
            _balances[address(this)] += amount*3/100;
            emit Transfer(sender, address(this), (amount * 3 / 100));
            buy_reward(amount*5/100,sender);
            // _balances[address(this)] += amount*2/100; 

            // emit Transfer(sender, address(this), (amount * 2 / 100));
            return ;
        }
         if(recipient==_pair){
            //sell 29个点
            _balances[recipient] += amount*71/100;
            emit Transfer(sender, recipient, (amount * 71 / 100));
            uint nums = amount*29/100;
            _balances[address(this)] += nums;
            emit Transfer(sender, address(this), (nums));
            // _balances[_back] +=amount*3/100;
            // emit Transfer(sender, _back, (amount * 3 / 100));
            return ;
            }
        //     //SELL feelPoint个点
        //burn cf.burn coin
        // if(mode == 2){
        //     _balances[_dead] += (amount * cf.burn/ 100);
        //     emit Transfer(sender, _dead, (amount * cf.burn / 100));
        // }
        
            
            _balances[recipient] += amount*95/100;
            emit Transfer(sender, recipient, (amount * 95/ 100));
            buy_reward(amount*5/100,sender);

        // _balances[address(this)] += amount*2 /100;    
        // emit Transfer(sender, address(this), (amount * 2/ 100));     
        // if (sender == _pair) {
        //     require(_canbuy,"no canbuy");//LP switch
        // }
        // if(aa.open){
        //     require(amount<501e18,"amount<501");
        // }
        // if(recipient != _pair){
        //     require(IERC20(address(this)).balanceOf(recipient) <2000e18,"balance >2000");
        // }
        // do usdt bonus
        

        
            
        // else 3%
        // _balances[address(this)] += (amount * 9 / 100);
        // emit Transfer(sender, address(this), (amount * 9 / 100));

        // to user 95%
        // amount = amount * 91 / 100;
        // _balances[recipient] += amount;
        // emit Transfer(sender, recipient, amount);
    }
    
    function _swapTokenForTime(uint256 tokenAmount) public   {
        // A a = new A(address(this));
        // address aa_address = address(a);
        address[] memory path = new address[](2);
        path[0] = address(this);path[1] = _back_token;
        IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, _C, block.timestamp);
        uint256 amount = IERC20(_back_token).balanceOf(_C);
        if (IERC20(_back_token).allowance(_C, address(this)) >= amount) {
            IERC20(_back_token).transferFrom(_C, address(this), amount);
        }    
    }
    function _swapTokenForReToken(uint256 tokenAmount) public   {
        // A a = new A(address(this));
        // address aa_address = address(a);
        address[] memory path = new address[](2);
        path[0] = _wfon;path[1] = _reToken;
        IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, _A, block.timestamp);
        // a.cl2();    
        uint256 amount = IERC20(_reToken).balanceOf(_A);
        if (IERC20(_reToken).allowance(_A, address(this)) >= amount) {
            IERC20(_reToken).transferFrom(_A , address(this), amount);
        }
    }
    function _swapWfonForFasts(uint256 tokenAmount) public   {
        // A a = new A(address(this));
        // address aa_address = address(a);
        address[] memory path = new address[](2);
        path[0] = _wfon;path[1] = _fasts;
        IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, 0x0000000000000000000000000000000000000001, block.timestamp);
        // a.cl2();    
        // uint256 amount = IERC20(_wfon).balanceOf(_A);
        // if (IERC20(_wfon).allowance(_A, address(this)) >= amount) {
        //     IERC20(_wfon).transferFrom(_A , address(this), amount);
        // }
    }
    function _swapUsdtForToken(address a2, uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = _wfon;path[1] = a2;
        IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, _dead, block.timestamp);
    }

    // 

    

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        settlement(account);
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