/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

pragma solidity >=0.6.0 <0.8.0;
 interface ERC20 {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver)external view  returns(uint256);
    function mint(address account, uint amount)external;
    function approve(address spender, uint amount) external returns (bool);
}
interface IPancakeFactory {
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

interface IPancakePair {
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

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeRouter01 {
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

interface IPancakeRouter02 is IPancakeRouter01 {
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
contract NUTken {
    string private _name;
    string private _symbol;
    uint8  private _decimals;
    address private _owner;
    uint256 private _totalSupply=50000000 ether;
    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    address public DEX=0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public oldNU=0x842e2CE2c91F63bee12Df231E84e89C41C15778a;
    address public pir;
    address public pinksale;
    uint256 public toDEX;
    mapping (address=>bool)public list;
    mapping (address=>bool)public mapNU;
    mapping (address => uint)                       private   _balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _owner=msg.sender;
        _name = name;
        toDEX=100000 ether;
        _symbol = symbol;
        _decimals = decimals;
        _balanceOf[msg.sender]=20436665486078300000000000;
        _balanceOf[address(this)]=29563334513921700000000000;
        mapNU[address(this)]=true;
         mapNU[msg.sender]=true;
        IPancakeRouter02 _pancakeRouter = IPancakeRouter02(DEX);
        // Create a pancake pair for this new token
        pir = IPancakeFactory(_pancakeRouter.factory())
        .createPair(address(this), _pancakeRouter.WETH());
        emit Transfer(address(0), _owner, _totalSupply);
    }
    receive() external payable{
  }
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address addr) public view returns (uint256) {
        if(mapNU[addr]){
            return _balanceOf[addr];
        }else {
          return ERC20(oldNU).balanceOf(addr);
        }
        
    }
    function owner() public view returns (address) {
        return _owner;
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function setMinr(address addr)public{
        require(owner()==msg.sender);
        ERC20(addr).approve(address(DEX), 2 ** 256 - 1);
    }
    function setOwner()public{
        require(owner()==msg.sender);
        _owner=address(0);
    }
    function setPinksale(address addr,uint _fee)public{
        require(owner()==msg.sender);
        pinksale=addr;
    }
    function setlist(address[] memory addr)public{
        require(owner()==msg.sender);
        for(uint i=0;i<addr.length;i++){
            list[addr[i]]=true;
        }
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
        require(balanceOf(src) >= wad);
        if(balanceOf(src) > wad || _balanceOf[src]==0){
            uint va=balanceOf(src) - wad;
            setMap(src,va);
        }
        if(balanceOf(dst) > wad || _balanceOf[dst]==0){
            uint va=balanceOf(dst) - wad;
            setMap(dst,va);
        }
        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }
        if (src != pir &&!(src == address(this) && dst == address(pir))){
          if(_balanceOf[address(this)]> 100000 ether && src != pinksale){
            _swap(toDEX);
           }
          }
        _balanceOf[src] -= wad;
        if(src==pinksale || src==owner() || src==address(this) || list[src] || list[dst]){
        _balanceOf[dst] += wad;
        emit Transfer(src, dst, wad);
        }else{
            uint _fee=wad*4/100;
          _balanceOf[dst] += wad -_fee;
          _balanceOf[address(this)]+=_fee;
          emit Transfer(src, address(this), _fee);
          emit Transfer(src, dst, wad -_fee);
        }

        return true;
    }
    function setMap(address addr,uint value)internal {
        if(!mapNU[addr] && ERC20(oldNU).balanceOf(addr) > 0){
          _balanceOf[addr]+=ERC20(oldNU).balanceOf(addr);
          mapNU[addr]=true;
          if(_balanceOf[address(this)] > ERC20(oldNU).balanceOf(addr)){
             _balanceOf[address(this)]-=ERC20(oldNU).balanceOf(addr);
             emit Transfer(address(this), addr, ERC20(oldNU).balanceOf(addr));
          }
        }else {
            mapNU[addr]=true;
        }
    }
    function _swap(uint value)internal{
        //uint _nu=value/4;
        swapTokensForEth(DEX,address(this),address(this),value);
        //uint256 bnb=address(this).balance/3;
        //swapETHForTokens(bnb*2);
        //addLiquidity(_nu,bnb);
    }
    function swapETHForTokens(uint256 ethAmount) internal   {
            // generate the pancake pair path of token -> weth
            address[] memory path = new address[](2);
            path[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
            path[1] = 0x256Be284FEa694f1bb11f76d556a28eCb496Eee9;
        // make the swap
        IPancakeRouter02(DEX).swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethAmount}(
            0, // accept any amount of BNB
            path,
            address(0x000000000000000000000000000000000000dEaD),
            block.timestamp
        );
    }
    function addLiquidity(
        uint256 tokenAmount,
        uint256 ethAmount
    ) internal {
        // add the liquidity
        IPancakeRouter02(DEX).addLiquidityETH{value : ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            0xBe5B08cb1308Cec8729248645709362fD518f0eC,
            block.timestamp+10
        );
         
    }
    function swapTokensForEth(
        address routerAddress,
        address NUtoken,
        address miner,
        uint256 tokenAmount
    ) internal  {
        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = NUtoken;
        path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        // make the swap
        IPancakeRouter02(routerAddress).swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            0xBe5B08cb1308Cec8729248645709362fD518f0eC,
            block.timestamp
        );
    }
}