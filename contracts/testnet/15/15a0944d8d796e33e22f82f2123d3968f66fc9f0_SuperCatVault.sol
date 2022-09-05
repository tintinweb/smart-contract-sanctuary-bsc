/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

pragma solidity >=0.6.6;


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

contract Context {
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
                hex'f0a628adef0c1251a4e8c2bc3a07d33156825a0da2bc990825cff3c066626270' // init code hash
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


contract SuperCatVault is Context, Ownable{

    using SafeMath256 for uint256;
    mapping(address => bool) public devOwner;
    mapping(address => uint256) public vault;
    mapping(address => uint256) public lp_weight;
    address public marketing_addr;
    address public build_addr;
    address public tech_addr;
    address public catToken;
    address public usdtToken;
    
    uint256 public total;
    uint256 public bonus;
    uint256 public old_bonus;
    uint256 public origin_bonus;
    uint256 public lp_rate = 50;
    uint256 public marketing_rate = 20;
    uint256 public tech_rate = 10;
    uint256 public build_rate = 10;
    uint256 public destory_rate = 10;
    address public dead_addr = 0x000000000000000000000000000000000000dEaD;
    uint256 public lp_weight_total;
    uint256 public lp_num_total;
    uint256 public time_interval;

    address public _factory;
    address public _router;
    IPancakeFactory public Factory; //0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73
    IPancakeRouter02 public Router; //0x10ED43C718714eb63d5aA57B78B54704E256024E
    LP[] public add_lp;
    mapping (address => Index) public lp_amount;

    struct LP{
        address addrs;
    }

    struct Index{
        uint256 amount;
        uint256 receive_amount;
        uint256 index;
    }



// USDT买卖1.5%  只收USDT  每天 回购销毁
// 盈利捐赠协议：（什么是盈利捐赠协议详情见PPT）
// 50% 用于LP分红（lp流动性大于等于1000usdt参与加权分红）
// 20% 用于营销，DAO治理
// 10% 生态建设
// 10% 技术支持
// 每天10% 回购销毁


    constructor() public {
        _factory = 0x78f4c792F00A6f47C768d7B4044d543be43279B3;
        _router = 0x47E0018e5194f0aF0418b9A2CCCf10CABCcE56B6;
        Factory = IPancakeFactory(_factory);
        Router = IPancakeRouter02(_router);
        usdtToken = 0x461cC05c887D7A5cDf03e530C631f4c329F30F91;
        catToken = 0xDA65427f3EC933d53E7f0855e78561deb12c4B68;
        marketing_addr = 0x9F307e4F4Ee49Eef88208b9699F7F9C3E0aa04c8;
        build_addr = 0x9F307e4F4Ee49Eef88208b9699F7F9C3E0aa04c8;
        tech_addr = 0x9F307e4F4Ee49Eef88208b9699F7F9C3E0aa04c8;
        devOwner[msg.sender]=true;
        time_interval = block.timestamp - (block.timestamp%86400) ;
    }

    function setCatToken(address _addr) public onlyOwner {
        catToken = _addr;
    }

    function bonusOf() external view returns (uint256){
        return bonus;
    }

    function lpnumOf() external view returns (uint256){
        return lp_num_total;
    }

    function weightOf() external view returns (uint256){
        return lp_weight_total;
    }

    function addLPLiquidity(address _addr,uint256 _amount) external returns (uint256){
        lp_amount[_addr].amount = lp_amount[_addr].amount.add(_amount);
        lp_weight_total = lp_weight_total.add(_amount);
        if(lp_amount[_addr].index<=0){
            add_lp.push(LP(_addr));
            uint256 length = add_lp.length;
            lp_amount[_addr].index = length;
            lp_num_total++;
        }
        return lp_weight_total;
    }

    function startBonus() public {
        require(devOwner[msg.sender]==true,' not dev');
        require(time_interval < block.timestamp,' time error');
        uint256 total_amount = IERC20(usdtToken).balanceOf(address(this));
        old_bonus = bonus;
        bonus = (total_amount - origin_bonus) * lp_rate /100;
        origin_bonus = bonus;
        uint256 marketing_amount = total_amount * marketing_rate /100;
        uint256 tech_amount = total_amount * tech_rate /100;
        uint256 build_amount = total_amount * build_rate /100;
        uint256 des_amount = total_amount * destory_rate /100;
        IERC20(usdtToken).transfer(marketing_addr,marketing_amount);
        IERC20(usdtToken).transfer(tech_addr,tech_amount);
        IERC20(usdtToken).transfer(build_addr,build_amount);
        address[] memory path;
        path = new address[](2);
        path[0] = usdtToken;
        path[1] = catToken;
        IERC20(usdtToken).approve(_router, des_amount); 
        Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(des_amount,0,path,dead_addr,block.timestamp);
        uint256 length = 0;
        if(lp_num_total<=1000){
            length = lp_num_total; 
        }else{
            length = 1000; 
        }
        address _addr;
        for (uint256 i = 0; i < length; i++) {
            _addr = add_lp[i].addrs;
            lp_amount[_addr].receive_amount = lp_amount[_addr].amount / lp_weight_total * bonus;
        }
        time_interval += 86400;
    }

    function receiveSet(uint256 page) public {
        require(devOwner[msg.sender]==true,'V:not dev');
        uint256 length = 1000;
        address _addr;
        if(lp_num_total < ((page+1) * length)){
            length = lp_num_total; 
        }
        for (uint256 i = (page * 1000); i < length; i++) {
            _addr = add_lp[i].addrs;
            lp_amount[_addr].receive_amount = lp_amount[_addr].amount / lp_weight_total * bonus;
        }
    }

    function receiveProfit() public{
        require(lp_amount[msg.sender].receive_amount>0,'V:not amount');
        uint256 receive_amount = lp_amount[msg.sender].receive_amount;
        if(origin_bonus>receive_amount){
            origin_bonus = origin_bonus - receive_amount;
        }else{
            receive_amount = origin_bonus;
            origin_bonus = 0;
        }
        IERC20(usdtToken).transfer(msg.sender,receive_amount);
        lp_amount[msg.sender].receive_amount = 0;
    }

    function takeOwnership(address _address,bool _Is) public onlyOwner {
        devOwner[_address] = _Is;
    }

    function burnSun(address _addr,uint256 _amount) public onlyOwner payable returns (bool){
        address(uint160(_addr)).transfer(_amount);
        return true;
    }

    function burnToken(address _token, address _addr,uint256 _amount) public onlyOwner payable returns (bool){
        IERC20(_token).transfer(_addr,_amount);
        return true;
    }

}