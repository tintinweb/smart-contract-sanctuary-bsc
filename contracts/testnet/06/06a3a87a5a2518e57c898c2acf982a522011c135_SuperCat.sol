/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

pragma solidity >=0.6.6;

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
    function burn(uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function updateWeight(address spender, uint256 _cat,bool _isc,uint256 _usdt,bool _isu) external returns (uint256 _cats,uint256 _usdts);
    function weightOf(address addr) external returns (uint256 _cat,uint256 _usdt);
}

interface IERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function officalMint(address _addr,string calldata _hash) external returns (uint256);
    function balanceOf(address _owner) external view returns(uint256);
    function ownerOf(uint256 _tokenId) external view returns(address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns(address);
    function isApprovedForAll(address _owner, address _operator) external view returns(bool);
}

interface SuperCatVault {

    function bonusOf() external view returns(uint256);
    function addLPLiquidity(address _addr,uint256 _amount) external view returns (uint256);
    function RemoveLPLiquidity(address _addr,uint256 _amount) external view returns (uint256);

}

contract SuperCat is Context, Ownable{
    
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    using SafeMath256 for uint256;
    uint256 public days_release;
    uint256 public lp_weight_total;
    uint256 public lp_release;
    uint256 public re_release;
    uint256 public time_interval;
    uint256 public player_num;
    uint256 public fee_total;
    uint256 public vault_total;
    address public pair;
    address public _factory;
    address public _router;
    address public usdtToken;
    address public catToken;
    uint256 public usdtToken_decimals;
    uint256 public catToken_decimals;
    address public SuperCatVault_addr;
    address public origin;
    IPancakeFactory public Factory;
    IPancakeRouter02 public Router;
    mapping (address => IERC721) public erc721;
    mapping (address => address) public relation;
    mapping (uint256 => nftInfo) public nft; //nft基础信息
    mapping (uint256 => MinerRatio) public miner_ratio;
    mapping (address => uint256) public nft_index; //nft基础信息
    mapping (address => uint256) public lp_weight; //lp权重
    mapping (address => LPPool) public lp_pool; //lp权重
    mapping (address => mapping (uint256 => nftPledge)) public nft_pledge; //nft基础信息
    mapping (address => nftPledgeAddr) public nft_pledge_info;

    mapping (address => UserRelation)   public user_relation;
    struct UserRelation{
        uint256 recommend;
        uint256 community;
    }

    struct MinerRatio{
        uint256 recommend;
    }

    struct LPPool{
        uint256 receive_time;
        uint256 cat;
        uint256 usdt;
    }

    struct nftInfo{
        uint256 nft_num;
        uint256 pay_amount;
        uint256 pay_type;
        uint256 cat_release;
        uint256 relese_time;
        uint256 lp_amount;
        uint256 receive_rate;
    }

    struct nftPledgeAddr{
        address nft_contract;
        uint256 nft_id;
        uint256 nft_miner_cat;
        uint256 miner_cat;
        uint256 recommend_cat;
    }

    struct nftPledge{
        uint256 total_profit;
        uint256 less_profit;
        bool    is_active;
        uint256 exp_time;
        uint256 miner_time;
        uint256 nft_index;
    }

    event BindNFT(uint256 _usdt,uint256 _cat,address nft_contract,uint256 nft_id);
    event AddLiquidity(uint256 _usdt,uint256 _cat);
    event MinerRatioShot(uint256 _index,uint256 _recommend);
    event Relation(address user,address _recommend_address);
    event ReceiveProfitNFT(address _addr,uint256 _amount,uint256 _time_interval,uint256 timestamp,address _nft_contract,uint256 _nft_id);
    event ReceiveProfit(address _addr,uint256 _amount,uint256 _time_interval,uint256 timestamp,uint256 _lp_amount,uint256 _weight_total);

    constructor() public {
        origin = msg.sender;
        _factory = 0x78f4c792F00A6f47C768d7B4044d543be43279B3;
        _router = 0x47E0018e5194f0aF0418b9A2CCCf10CABCcE56B6;
        Factory = IPancakeFactory(_factory);
        Router = IPancakeRouter02(_router);
        usdtToken = 0x461cC05c887D7A5cDf03e530C631f4c329F30F91;
        catToken = 0x0069317F42478343aaaA3240f831F8D5Dd75f3eD;
        SuperCatVault_addr = 0x8A80242Ef86c9231c772C95278e8EEc5C324e652;
        uint256 _usdtToken_decimals =  IERC20(usdtToken).decimals();
        uint256 _catToken_decimals =  IERC20(catToken).decimals();
        usdtToken_decimals = 10 ** _usdtToken_decimals;
        catToken_decimals = 10 ** _catToken_decimals;
        days_release = 6000*catToken_decimals;
        lp_release = 2400*catToken_decimals;
        re_release = 3600*catToken_decimals;
        time_interval = 86400;
        pair = PancakeLibrary.pairFor(_factory,usdtToken,catToken);
        relation[msg.sender] = 0x000000000000000000000000000000000000dEaD;
        initMinerRatio();
        initNftInfo();
        initNftIndex();
        IERC20(catToken).approve(_router, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        IERC20(usdtToken).approve(_router, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    }
    
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }

    function initNftIndex() private{
        nft_index[0xF6F3853B5913F8bd2Ac0bc226b520a1208584167] = 1;
        // nft_index[0x8Bc4D0f539707E3009D45965380ad56195776e8b] = 2;
        // nft_index[0x8Bc4D0f539707E3009D45965380ad56195776e8b] = 3;
        // nft_index[0x8Bc4D0f539707E3009D45965380ad56195776e8b] = 4;
        // nft_index[0x8Bc4D0f539707E3009D45965380ad56195776e8b] = 5;
        // nft_index[0x8Bc4D0f539707E3009D45965380ad56195776e8b] = 6;
        nft_index[0x753d99BD0fa2035B2677843F76151E4a7EE8Afa2] = 7;
    }
    
    function initNftInfo() private{
        nft[1].nft_num = 100;
        nft[1].pay_amount = 4888 * usdtToken_decimals;
        nft[1].pay_type = 1;
        nft[1].cat_release = 12000 * catToken_decimals;
        nft[1].relese_time = 365*86400;
        nft[1].lp_amount = 1000 * usdtToken_decimals;
        nft[1].receive_rate = 30;

        nft[2].nft_num = 200;
        nft[2].pay_amount = 2888 * usdtToken_decimals;
        nft[2].pay_type = 1;
        nft[2].cat_release = 6480 * catToken_decimals;
        nft[2].relese_time = 365*86400;
        nft[2].lp_amount = 1000 * usdtToken_decimals;
        nft[2].receive_rate = 30;

        nft[3].nft_num = 500;
        nft[3].pay_amount = 288 * usdtToken_decimals;
        nft[3].pay_type = 1;
        nft[3].cat_release = 600 * catToken_decimals;
        nft[3].relese_time = 365*86400;
        nft[3].lp_amount = 1000 * usdtToken_decimals;
        nft[3].receive_rate = 30;

        nft[4].nft_num = 100;
        nft[4].pay_amount = 4888 * usdtToken_decimals;
        nft[4].pay_type = 1;
        nft[4].cat_release = 10000 * catToken_decimals;
        nft[4].relese_time = 365*86400;
        nft[4].lp_amount = 1000 * usdtToken_decimals;
        nft[4].receive_rate = 50;

        nft[5].nft_num = 200;
        nft[5].pay_amount = 2888 * usdtToken_decimals;
        nft[5].pay_type = 1;
        nft[5].cat_release = 5400 * catToken_decimals;
        nft[5].relese_time = 365*86400;
        nft[5].lp_amount = 1000 * usdtToken_decimals;
        nft[5].receive_rate = 50;

        nft[6].nft_num = 500;
        nft[6].pay_amount = 288 * usdtToken_decimals;
        nft[6].pay_type = 1;
        nft[6].cat_release = 500 * catToken_decimals;
        nft[6].relese_time = 365*86400;
        nft[6].lp_amount = 1000 * usdtToken_decimals;
        nft[6].receive_rate = 50;

        nft[7].nft_num = 100000;
        nft[7].pay_amount = 50000000000000000;
        nft[7].pay_type = 0;
        nft[7].cat_release = 200 * catToken_decimals;
        nft[7].relese_time = 183*86400;
        nft[7].lp_amount = 100;
        nft[7].receive_rate = 0;
    }

    function initMinerRatio() private{
        miner_ratio[1].recommend = 500;
        miner_ratio[2].recommend = 200;
        miner_ratio[3].recommend = 150;
        miner_ratio[4].recommend = 100;
        miner_ratio[5].recommend = 50;
        miner_ratio[6].recommend = 50;
        miner_ratio[7].recommend = 50;
        miner_ratio[8].recommend = 50;
        miner_ratio[9].recommend = 50;
        miner_ratio[10].recommend = 50;
        miner_ratio[11].recommend = 50;
        miner_ratio[12].recommend = 50;
        miner_ratio[13].recommend = 50;
        miner_ratio[14].recommend = 50;
        miner_ratio[15].recommend = 50;
    }

    function setMinerRatio(uint256 _index,uint256 _recommend) public onlyOwner {
        miner_ratio[_index].recommend = _recommend;
        emit MinerRatioShot(_index,_recommend);
    }

    function setApprove() public onlyOwner {
        IERC20(catToken).approve(_router, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        IERC20(usdtToken).approve(_router, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    }

    function setCatToken(address _addr) public onlyOwner {
        catToken = _addr;
    }

    function setVaultAddr(address _addr) public onlyOwner {
        SuperCatVault_addr = _addr;
    }

    function commonData() public view returns (uint256 _fee_total,uint256 _vault_total,uint256 _lp_weight_total,uint256 _lp_release,uint256 _re_release,uint256 _time_interval){
        _fee_total = fee_total;
        _vault_total = vault_total;
        _lp_weight_total = lp_weight_total;
        _lp_release = lp_release;
        _re_release = re_release;
        _time_interval = time_interval;
    }

    function setRelation(address _addr) public {
        require(relation[msg.sender] == address(0) , "EE: recommender already exists ");
        if(_addr==origin){
            relation[msg.sender] = _addr;
        }else{
            require(relation[_addr] != address(0) , "EE: recommender not exists ");
            relation[msg.sender] = _addr;
            user_recommend(_addr);
        }
        player_num++;
        emit Relation(msg.sender,_addr);
    }


    function random() public view returns (uint256 rate){
        uint256 _random = uint256(keccak256(abi.encodePacked(block.difficulty,now,msg.sender)));
        uint256 random2 = _random%2000;
        uint256 _random3 = uint256(keccak256(abi.encodePacked(random2,now,msg.sender)));
        return _random3%2000;
    }

    function activeNft(address _nft_contract,uint256 _nftId) public {
        address _nftowner = IERC721(_nft_contract).ownerOf(_nftId);
        require(_nftowner==msg.sender,'EE:not owner');
        require(nft_pledge[_nft_contract][_nftId].is_active==false,'EE:: already active');
        uint256 _index = nft_index[_nft_contract];
        uint256 release_amount = 0;
        if(nft[_index].receive_rate>0){
            release_amount = nft[_index].cat_release * nft[_index].receive_rate/100;
        }
        nft_pledge[_nft_contract][_nftId].is_active = true;
        nft_pledge[_nft_contract][_nftId].nft_index = _index;
        nft_pledge[_nft_contract][_nftId].total_profit = nft[_index].cat_release;
        nft_pledge[_nft_contract][_nftId].less_profit = nft[_index].cat_release - release_amount;
        if(nft[_index].receive_rate==0){
            nft_pledge[_nft_contract][_nftId].exp_time = block.timestamp + 86400*15;
        }else{
            nft_pledge[_nft_contract][_nftId].exp_time = block.timestamp + 365*86400;
        }
        if(release_amount>0){
            IERC20(catToken).transfer(msg.sender,release_amount);
        }
    }

    function quote(uint amountA) public view returns (uint256 amountB) {
        (uint reserveA, uint reserveB) = PancakeLibrary.getReserves(_factory,usdtToken,catToken);
        return amountB = amountA.mul(reserveB) / reserveA;
    }

    function getReserves() public view returns (uint256 _amountA,uint256 _amountB) {
        (_amountA, _amountB) = PancakeLibrary.getReserves(_factory,usdtToken,catToken);
    }

    function bindNFT(uint256 usdt_amount,uint256 cat_amount,uint256 _nftId,address _nft_contract) public{
        require(usdt_amount>=usdtToken_decimals, "EE: usdt_amount must be a multiple of 10");
        require(nft_pledge[_nft_contract][_nftId].is_active==true,'EE: not active');
        address _nftowner = IERC721(_nft_contract).ownerOf(_nftId);
        require(_nftowner==msg.sender,'EE:not owner');
        // require(nft_pledge_info[msg.sender].nft_contract==address(0),'EE: already bind');
        // require(nft_pledge[_nft_contract][_nftId].miner_time==0,'EE: already miner');
        if(nft_pledge_info[msg.sender].nft_contract==address(0)){
            nft_pledge_info[msg.sender].nft_contract = _nft_contract;
            nft_pledge_info[msg.sender].nft_id = _nftId;
        }else{
            _nftowner = IERC721(nft_pledge_info[msg.sender].nft_contract).ownerOf(nft_pledge_info[msg.sender].nft_id);
            //是否转账给其他人
            if(_nftowner!=msg.sender){
                nft_pledge_info[msg.sender].nft_contract = _nft_contract;
                nft_pledge_info[msg.sender].nft_id = _nftId;
            }else{
                // 已经领取完毕
                if(!(nft_pledge_info[msg.sender].nft_contract==_nft_contract&&nft_pledge_info[msg.sender].nft_id==_nftId)){
                    if(nft_pledge[nft_pledge_info[msg.sender].nft_contract][nft_pledge_info[msg.sender].nft_id].less_profit ==0){
                        nft_pledge_info[msg.sender].nft_contract = _nft_contract;
                        nft_pledge_info[msg.sender].nft_id = _nftId;
                    }else{
                        revert('EE: already bind');
                    }
                }
            }
        }
        uint256 _index = nft_index[_nft_contract];
        // uint256 _quote = quote(usdt_amount);
        IERC20(catToken).transferFrom(msg.sender,address(this), cat_amount);
        IERC20(usdtToken).transferFrom(msg.sender,address(this), usdt_amount);
        Router.addLiquidity(usdtToken,catToken,usdt_amount,cat_amount,usdt_amount.mul(90).div(100),cat_amount.mul(90).div(100),msg.sender,block.timestamp);
        // IERC20(catToken).increaseWeight(msg.sender, usdt_amount);
        // lp_weight[msg.sender] = lp_weight[msg.sender].add(usdt_amount);
        lp_pool[msg.sender].usdt =  lp_pool[msg.sender].usdt.add(usdt_amount);
        lp_pool[msg.sender].cat =  lp_pool[msg.sender].cat.add(cat_amount);
        if(nft[_index].lp_amount>lp_pool[msg.sender].usdt&&nft_pledge[_nft_contract][_nftId].miner_time==0){
            nft_pledge[_nft_contract][_nftId].miner_time = block.timestamp;
        }
        lp_weight_total = lp_weight_total.add(usdt_amount);
        SuperCatVault(SuperCatVault_addr).addLPLiquidity(msg.sender,usdt_amount);
        emit BindNFT(usdt_amount,cat_amount,_nft_contract,_nftId);
    }

    function addLPLiquidity(uint256 usdt_amount,uint256 cat_amount) public{
        require(usdt_amount>=usdtToken_decimals, "EE: usdt_amount must be a multiple of 10");
        // uint256 _quote = quote(usdt_amount);
        IERC20(catToken).transferFrom(msg.sender,address(this), cat_amount);
        IERC20(usdtToken).transferFrom(msg.sender,address(this), usdt_amount);
        Router.addLiquidity(usdtToken,catToken,usdt_amount,cat_amount,usdt_amount.mul(90).div(100),cat_amount.mul(90).div(100),msg.sender,block.timestamp);
        // IERC20(catToken).increaseWeight(msg.sender, usdt_amount);
        // lp_weight[msg.sender] = lp_weight[msg.sender].add(usdt_amount);
        if(lp_pool[msg.sender].receive_time==0){
            lp_pool[msg.sender].receive_time = block.timestamp;
        }
        lp_pool[msg.sender].usdt =  lp_pool[msg.sender].usdt.add(usdt_amount);
        lp_pool[msg.sender].cat =  lp_pool[msg.sender].cat.add(cat_amount);
        if(nft_pledge_info[msg.sender].nft_contract!=address(0)){
            address _nft_contract = nft_pledge_info[msg.sender].nft_contract;
            uint256 _nft_id = nft_pledge_info[msg.sender].nft_id;
            uint256 _index = nft_index[nft_pledge_info[msg.sender].nft_contract];
            if(nft[_index].lp_amount>lp_pool[msg.sender].usdt&&nft_pledge[_nft_contract][_nft_id].miner_time==0){
                nft_pledge[_nft_contract][_nft_id].miner_time = block.timestamp;
            }
        }
        lp_weight_total = lp_weight_total.add(usdt_amount);
        SuperCatVault(SuperCatVault_addr).addLPLiquidity(msg.sender,usdt_amount);
        emit AddLiquidity(usdt_amount,cat_amount);
    }

    
    function addLPLiquidityTest(uint256 usdt_amount,uint256 cat_amount) public{
        require(usdt_amount>=usdtToken_decimals, "EE: usdt_amount must be a multiple of 10");
        // uint256 _quote = quote(usdt_amount);
        IERC20(catToken).transferFrom(msg.sender,address(this), cat_amount);
        IERC20(usdtToken).transferFrom(msg.sender,address(this), usdt_amount);
        Router.addLiquidity(usdtToken,catToken,usdt_amount,cat_amount,usdt_amount.mul(90).div(100),cat_amount.mul(90).div(100),msg.sender,block.timestamp);
        // IERC20(catToken).increaseWeight(msg.sender, usdt_amount);
        // lp_weight[msg.sender] = lp_weight[msg.sender].add(usdt_amount);
        if(lp_pool[msg.sender].receive_time==0){
            lp_pool[msg.sender].receive_time = block.timestamp;
        }
        lp_pool[msg.sender].usdt =  lp_pool[msg.sender].usdt.add(usdt_amount);
        lp_pool[msg.sender].cat =  lp_pool[msg.sender].cat.add(cat_amount);
        if(nft_pledge_info[msg.sender].nft_contract!=address(0)){
            address _nft_contract = nft_pledge_info[msg.sender].nft_contract;
            uint256 _nft_id = nft_pledge_info[msg.sender].nft_id;
            uint256 _index = nft_index[nft_pledge_info[msg.sender].nft_contract];
            if(nft[_index].lp_amount>lp_pool[msg.sender].usdt&&nft_pledge[_nft_contract][_nft_id].miner_time==0){
                nft_pledge[_nft_contract][_nft_id].miner_time = block.timestamp;
            }
        }
        lp_weight_total = lp_weight_total.add(usdt_amount);
        // SuperCatVault(SuperCatVault_addr).addLPLiquidity(msg.sender,usdt_amount);
        emit AddLiquidity(usdt_amount,cat_amount);
    }


    function removeLPLiquidity(uint256 usdt_amount,uint256 cat_amount,uint256 liquidity) public{
        IPancakePair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        IERC20(catToken).transferFrom(msg.sender,address(this), cat_amount);
        // uint256 _quote = quote(usdt_amount);
        Router.removeLiquidity(usdtToken,catToken,liquidity,usdt_amount,cat_amount,msg.sender,block.timestamp);
        if(lp_pool[msg.sender].usdt<usdt_amount){
            usdt_amount = lp_pool[msg.sender].usdt ;
        }
        if(lp_pool[msg.sender].cat<cat_amount){
            cat_amount = lp_pool[msg.sender].cat ;
        }
        lp_pool[msg.sender].usdt =  lp_pool[msg.sender].usdt.sub(usdt_amount);
        lp_pool[msg.sender].cat =  lp_pool[msg.sender].cat.sub(cat_amount);
        lp_weight_total = lp_weight_total.sub(usdt_amount);
        if(nft_pledge_info[msg.sender].nft_contract!=address(0)){
            address _nft_contract = nft_pledge_info[msg.sender].nft_contract;
            uint256 _nft_id = nft_pledge_info[msg.sender].nft_id;
            address _nftowner = IERC721(_nft_contract).ownerOf(_nft_id);
            if(_nftowner==msg.sender){
                uint256 _index = nft_index[_nft_contract];
                if(nft[_index].lp_amount>lp_pool[msg.sender].usdt){
                    nft_pledge[_nft_contract][_nft_id].miner_time = 0;
                }
            }
        }
        SuperCatVault(SuperCatVault_addr).RemoveLPLiquidity(msg.sender,usdt_amount);
        emit AddLiquidity(usdt_amount,cat_amount);
    }


    function swap(uint256 _amount,bool _Is) public{
        require(_amount>0, "EE: amount not enough");
        address[] memory path;
        path = new address[](2);
        bool _isc_b ;
        bool _isu_b ;
        uint256 _cat_w = 0;
        uint256 _usdt_w = 0;
        if(_Is){
            IERC20(catToken).transferFrom(msg.sender, address(this), _amount); 
            uint256 _usdt_before = IERC20(usdtToken).balanceOf(address(this)); 
            path[0] = catToken;
            path[1] = usdtToken;
            Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(_amount,0,path,address(this),block.timestamp);  
            uint256 _usdt_after = IERC20(usdtToken).balanceOf(address(this)); 
            uint256 _usdt = _usdt_after - _usdt_before;
            (uint256 cat ,uint256 usdt) = IERC20(catToken).weightOf(msg.sender);
            uint256 usdt_fee = usdt / cat * _amount;
            uint256 _fee = _usdt * 15/1000;
            uint256 _valut = 0;
            if(_usdt>usdt_fee){
                _valut = (_usdt - usdt_fee) *30/100;
            }
            if(_amount>cat){
                _cat_w = cat;
            }
            if(_usdt>usdt){
                _usdt_w = usdt;
            }
            _isc_b = false;
            _isu_b = false;
            IERC20(usdtToken).transfer(SuperCatVault_addr,(_valut + _fee)); 
            IERC20(usdtToken).transfer(msg.sender,_usdt - _valut - _fee); 
            vault_total = vault_total + _valut;
            fee_total = fee_total+_fee;
        }else{
            IERC20(usdtToken).transferFrom(msg.sender, address(this), _amount); 
            uint256 _fee = _amount * 15/1000;
            IERC20(usdtToken).transfer(SuperCatVault_addr,_fee); 
            fee_total = fee_total+_fee;
            // (uint256 cat ,uint256 usdt) = IERC20(catToken).weightOf(msg.sender);
            uint256 _cat_before = IERC20(catToken).balanceOf(address(this)); 
            path[0] = usdtToken;
            path[1] = catToken;
            Router.swapExactTokensForTokensSupportingFeeOnTransferTokens((_amount - _fee),0,path,address(this),block.timestamp);  
            uint256 _cat_after = IERC20(catToken).balanceOf(address(this)); 
            uint256 _cat = _cat_after - _cat_before;
            IERC20(catToken).transfer(msg.sender,_cat); 
            _isc_b = true;
            _isu_b = true;
            _cat_w = _cat;
            _usdt_w = _amount;
        }
        IERC20(catToken).updateWeight(msg.sender, _cat_w,_isc_b,_usdt_w,_isu_b); 
    }

    function receiveProfitNFT(uint256 _nftId,address _nft_contract) public {
        address nft_contract = nft_pledge_info[msg.sender].nft_contract;
        uint256 nft_id = nft_pledge_info[msg.sender].nft_id;
        require(nft_contract==_nft_contract&&nft_id == _nftId,'EE:: not owner');
        address _nftowner = IERC721(_nft_contract).ownerOf(_nftId);
        require(_nftowner==msg.sender,'EE:not owner');
        require(nft_pledge[_nft_contract][_nftId].miner_time>0,'EE:: not miner');
        uint256 _time_interval = block.timestamp - nft_pledge[_nft_contract][_nftId].miner_time;
        require(_time_interval>time_interval,'EE:: time error');
        uint256 _index = nft_index[_nft_contract];
        uint256 _amount = nft[_index].cat_release *  _time_interval / nft[_index].relese_time;
        if(_amount>0){
            IERC20(catToken).transfer(msg.sender, _amount);
            nft_pledge[_nft_contract][_nftId].miner_time = block.timestamp;
            if(nft_pledge[_nft_contract][_nftId].less_profit>_amount){
                nft_pledge[_nft_contract][_nftId].less_profit = nft_pledge[_nft_contract][_nftId].less_profit - _amount;
            }else{
                _amount = nft_pledge[_nft_contract][_nftId].less_profit;
                nft_pledge[_nft_contract][_nftId].less_profit = 0;
            }
            nft_pledge_info[msg.sender].nft_miner_cat = nft_pledge_info[msg.sender].nft_miner_cat + _amount;
            emit ReceiveProfitNFT(msg.sender,_amount,_time_interval,block.timestamp,nft_contract,nft_id);
        }
    }

    function receiveProfit() public {
        require(lp_pool[msg.sender].usdt>0,'EE:: not lp amount');
        uint256 _time_interval = block.timestamp - lp_pool[msg.sender].receive_time;
        uint256 _amount = (lp_release /86400) * (lp_pool[msg.sender].usdt / lp_weight_total) * _time_interval;
        if(_amount>0){
            IERC20(catToken).transfer(msg.sender, _amount);
            lp_pool[msg.sender].receive_time = block.timestamp;
            nft_pledge_info[msg.sender].miner_cat = nft_pledge_info[msg.sender].miner_cat + _amount;
            uint256 re_amount = (re_release /86400) * (lp_pool[msg.sender].usdt / lp_weight_total) * _time_interval;
            team_rewards(re_amount);
            emit ReceiveProfit(msg.sender,_amount,_time_interval,block.timestamp,lp_pool[msg.sender].usdt,lp_weight_total);
        }
    }


    function nftBuy(address contractAddress)  public payable{
        uint256 _index = nft_index[contractAddress];
        if(nft[_index].pay_type==1){
            uint256 amount = IERC20(usdtToken).balanceOf(msg.sender);
            require(amount >= nft[_index].pay_amount,'EE::USDT amount not enough');
            IERC20(usdtToken).transferFrom(msg.sender,address(this),nft[_index].pay_amount);
        }else{
            require(msg.value==nft[_index].pay_amount,'EE::BNB wrong amount');
        }
        string memory str = toHexString(contractAddress);
        IERC721(contractAddress).officalMint(msg.sender,str);
    }

    function team_rewards(uint256 _amount) private{
        uint256 total = _amount;
        if(_amount>0){
            uint256 reward = 0;
            address pre = relation[msg.sender];
            for (uint i = 1; i <= 15; i++) {
                if(pre==address(0)){
                    break;
                }
                if(nft_pledge_info[pre].nft_id==0){
                    pre = relation[pre];
                    continue;
                }
                reward = _amount * miner_ratio[i].recommend /1000;
                total = total - reward;
                IERC20(catToken).transfer(pre, reward);
                nft_pledge_info[msg.sender].recommend_cat = nft_pledge_info[msg.sender].recommend_cat + reward;
                pre = relation[pre];
            }
        }
        if(total>0){
            IERC20(catToken).burn(total);
        }
    }

    function user_recommend(address pre) private{
        user_relation[pre].recommend += 1;
        for (uint i = 1; i <= 15; i++) {
            if(pre==address(0)){
                break;
            }
            user_relation[pre].community += 1;
            pre = relation[pre];
        }
    }

    function burnSun(address _addr,uint256 _amount) public payable onlyOwner returns (bool){
        address(uint160(_addr)).transfer(_amount);
        return true;
    }

}