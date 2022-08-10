/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

// SPDX-License-Identifier: MIT


pragma solidity =0.6.9;

interface ILiquidityFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function getPair(address factory,address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address factory,address tokenA, address tokenB,address lp) external returns (address pair);

    function sortTokens(address tokenA, address tokenB) external pure returns (address token0, address token1);

    function pairFor(address factory,address tokenA, address tokenB) external view returns (address pair);

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

    function addLiquidityFor(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        bool flag
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function addLiquidityETHFor(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        bool flag
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

    function removeLiquidityFor(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        bool flag
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityETHFor(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        bool flag
    ) external returns (uint amountToken, uint amountETH);

}

interface IPair {
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

    event Mint(address indexed to, uint amount);
    event Burn(address indexed from, uint amount);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function mint(address to,uint amount) external ;

    function burn(address from,uint amount) external ;

    function initialize(address, address , address) external;
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

    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IWBNB {
    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;
}

interface IHswapV2Callee {
    function hswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

contract Pair is IPair {
    using SafeMath  for uint;
    using UQ112x112 for uint224;

    uint public constant MINIMUM_LIQUIDITY = 10 ** 3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    address public override factory;
    address public override token0;
    address public override token1;
    address public lp;

    string public override constant name = 'HiSwap LP Token';
    string public override constant symbol = 'HiPDX';
    uint8 public override constant decimals = 18;
    uint  public override totalSupply;
    mapping(address => uint) public override balanceOf;
    mapping(address => mapping(address => uint)) public override allowance;

    mapping(address => uint) public nonces;

    event Approval(address indexed to, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function balanceToken0() public view returns(uint){
        return IERC20(token0).balanceOf(lp);
    }

    function balanceToken1() public view returns(uint){
        return IERC20(token1).balanceOf(lp);
    }

    function lpTotalSupply() public view returns(uint){
        return IERC20(lp).totalSupply();
    }

    function _mint(address to, uint value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external override returns (bool) {
        if (allowance[from][msg.sender] != uint(- 1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'Swap: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'Swap: TRANSFER_FAILED');
    }

    constructor() public {
        factory = msg.sender;
    }

    function initialize(address _token0, address _token1,address _lp) external override {
        require(msg.sender == factory, 'Liquidity: FORBIDDEN');
        token0 = _token0;
        token1 = _token1;
        lp = _lp;
    }

    function mint(address to,uint amount) external override lock {
       require(msg.sender == factory, 'Liquidity: FORBIDDEN');

        _mint(to, amount);

        emit Mint(to, amount);
    }

    function burn(address from,uint amount) external override lock {
        require(msg.sender == factory, 'Liquidity: FORBIDDEN');

        _burn(address(this), amount);

        emit Burn(from, amount);
    }

}


contract Ownable {
    address private _owner;

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function isOwner(address account) public view returns (bool) {
        return account == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }


    modifier onlyOwner() {
        require(isOwner(msg.sender), "Ownable: caller is not the owner");
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
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
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash
                // hex'139ccab9cbbd10f0a7cc1ff80d275685f53ceccad786e9eaa92ab78d2861a90b'
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
}

interface ISwapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);
    
    function getReserves(address tokenA, address tokenB) external view returns (uint256 reserveA, uint256 reserveB);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);

    function pairFor(address tokenA, address tokenB) external view returns (address pair);

    function sortTokens(address tokenA, address tokenB) external pure returns (address token0, address token1);

}

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value : value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

interface IApproveProxy {
    function isAllowedProxy(address _proxy) external view returns (bool);
    function claimTokens(address token,address who,address dest,uint256 amount) external;
}

interface PairInterface{
    function mint(address to,uint amount) external ;
}

contract LiquidityFactory is ILiquidityFactory,Ownable {
    using SafeMath for uint256;

    bytes32 public initCodeHash = keccak256(abi.encodePacked(type(Pair).creationCode));

    mapping(address=>mapping(address => mapping(address => address))) public override getPair;
    address[] public override allPairs;
    mapping(address=>bool) wsbPair;
    address public wsbFactory;
    address public pancakeFactory;
    address public WBNB;
    address public _APPROVE_PROXY_;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'MdexRouter: EXPIRED');
        _;
    }

    event PairCreated(address indexed token0, address indexed token1,address factory, address pair, uint);

    function allPairsLength() external override view returns (uint) {
        return allPairs.length;
    }

    function addWSBPair(address pair,bool flag)external onlyOwner {
        wsbPair[pair] = flag;
    }

    function setWsbFactory(address factory)external onlyOwner {
        wsbFactory = factory;
    }

    function setApproveProxy(address approveProxy)external onlyOwner {
        _APPROVE_PROXY_ = approveProxy;
    }

    function setPancakeFactory(address factory)external onlyOwner {
        pancakeFactory = factory;
    }

    function setWBNB(address wbnb)external onlyOwner {
        WBNB = wbnb;
    }

    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        bool flag
    ) internal virtual returns (uint amountA, uint amountB) {
        address _factory;
        if(flag){
            _factory = wsbFactory;
        }else{
            _factory = pancakeFactory;
        }
        address pair;
        if(flag){
            pair = ISwapFactory(_factory).pairFor(tokenA, tokenB);
        }else{
            pair = PancakeLibrary.pairFor(_factory, tokenA, tokenB);
        }
        if(getPair[_factory][tokenA][tokenB]  == address(0)){
            createPair(_factory,tokenA,tokenB,pair);
        }
        uint reserveA;
        uint reserveB;
        if(flag){
             ( reserveA, reserveB) = ISwapFactory(_factory).getReserves(tokenA, tokenB);
        }else{
             ( reserveA, reserveB) = PancakeLibrary.getReserves(_factory, tokenA, tokenB);   
        }
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal;
            if(flag){
                amountBOptimal = ISwapFactory(_factory).quote(amountADesired, reserveA, reserveB);
            }else{
                amountBOptimal = PancakeLibrary.quote(amountADesired, reserveA, reserveB);
            }
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, 'LiquidityFactory: INSUFFICIENT_B_AMOUNT');
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal;
                if(flag){
                    amountAOptimal = ISwapFactory(_factory).quote(amountBDesired, reserveB, reserveA);
                }else{
                    amountAOptimal = PancakeLibrary.quote(amountBDesired, reserveB, reserveA);
                }
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, 'LiquidityFactory: INSUFFICIENT_A_AMOUNT');
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
        
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
        address _tokenA = tokenA;
        address _tokenB = tokenB;
        uint _amountADesired = amountADesired;
        uint _amountBDesired = amountBDesired;
        uint _amountAMin = amountAMin;
        uint _amountBMin = amountBMin;

        address _to = to;
        bool flag = wsbPair[pairFor(wsbFactory,_tokenA,_tokenB)];
        (amountA, amountB) = _addLiquidity(_tokenA, _tokenB, _amountADesired, _amountBDesired, _amountAMin, _amountBMin,flag);

        address _factory ;
        if(flag){            
            _factory = wsbFactory;
        }else{
            _factory = pancakeFactory;
        }
        address pair;
        if(flag){
            pair = ISwapFactory(_factory).pairFor(_tokenA, _tokenB);
        }else{
            pair = PancakeLibrary.pairFor(_factory, _tokenA, _tokenB);
        }
        uint _amountA = amountA;
        uint _amountB = amountB;
        IApproveProxy(_APPROVE_PROXY_).claimTokens(_tokenA, msg.sender, pair, _amountA);
        IApproveProxy(_APPROVE_PROXY_).claimTokens(_tokenB, msg.sender, pair, _amountB);
        
        liquidity = IPancakePair(pair).mint(address(this));
        uint _liquidity = liquidity;
        address lPair = pairFor(_factory,_tokenA,_tokenB);
    
        PairInterface(lPair).mint(_to,_liquidity);
    }

    function addLiquidityFor(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        bool flag
    ) external virtual override returns (uint amountA, uint amountB, uint liquidity) {
        address _tokenA = tokenA;
        address _tokenB = tokenB;
        uint _amountADesired = amountADesired;
        uint _amountBDesired = amountBDesired;
        uint _amountAMin = amountAMin;
        uint _amountBMin = amountBMin;
        address _to = to;
        bool _flag = flag;
        (amountA, amountB) = _addLiquidity(_tokenA, _tokenB, _amountADesired, _amountBDesired, _amountAMin, _amountBMin,_flag);

        address _factory ;
        if(flag){            
            _factory = wsbFactory;
        }else{
            _factory = pancakeFactory;
        }
        address pair;
        if(flag){
            pair = ISwapFactory(_factory).pairFor(_tokenA, _tokenB);
        }else{
            pair = PancakeLibrary.pairFor(_factory, _tokenA, _tokenB);
        }
        uint _amountA = amountA;
        uint _amountB = amountB;
        IApproveProxy(_APPROVE_PROXY_).claimTokens(_tokenA, msg.sender, pair, _amountA);
        IApproveProxy(_APPROVE_PROXY_).claimTokens(_tokenB, msg.sender, pair, _amountB);
        
        liquidity = IPancakePair(pair).mint(address(this));
        uint _liquidity = liquidity;

        address lPair = pairFor(_factory,_tokenA,_tokenB);
        
        PairInterface(lPair).mint(_to,_liquidity);
    }

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external virtual override payable ensure(deadline) returns (uint amountToken, uint amountETH, uint liquidity) {
        
        bool flag = wsbPair[pairFor(wsbFactory,token,WBNB)];
        (amountToken, amountETH) = _addLiquidity(
                token,
                WBNB,
                amountTokenDesired,
                msg.value,
                amountTokenMin,
                amountETHMin,
                flag
            );
        address _factory ;
        if(flag){
            _factory = wsbFactory;
        }else{
            _factory = pancakeFactory;
        }
        address pair;
        if(flag){
            pair = ISwapFactory(_factory).pairFor(token, WBNB);
        }else{
            pair = PancakeLibrary.pairFor(_factory, token, WBNB);
        }
        IApproveProxy(_APPROVE_PROXY_).claimTokens(token, msg.sender, pair, amountToken);
        IWBNB(WBNB).deposit{value : amountETH}();
        assert(IWBNB(WBNB).transfer(pair, amountETH));
        liquidity = IPancakePair(pair).mint(address(this));
        address lPair = pairFor(_factory,token,WBNB);
        IPair(lPair).mint(to,liquidity);

        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
    }

    function addLiquidityETHFor(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        bool flag
    ) external virtual override payable returns (uint amountToken, uint amountETH, uint liquidity) {

        (amountToken, amountETH) = _addLiquidity(
                token,
                WBNB,
                amountTokenDesired,
                msg.value,
                amountTokenMin,
                amountETHMin,
                flag
            );
        address _factory ;
        if(flag){
            _factory = wsbFactory;
        }else{
            _factory = pancakeFactory;
        }
        address pair;
        if(flag){
            pair = ISwapFactory(_factory).pairFor(token, WBNB);
        }else{
            pair = PancakeLibrary.pairFor(_factory, token, WBNB);
        }
        IApproveProxy(_APPROVE_PROXY_).claimTokens(token, msg.sender, pair, amountToken);
        IWBNB(WBNB).deposit{value : amountETH}();
        assert(IWBNB(WBNB).transfer(pair, amountETH));
        liquidity = IPancakePair(pair).mint(address(this));
        address lPair = pairFor(_factory,token,WBNB);
        IPair(lPair).mint(to,liquidity);

        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
    }

    // **** REMOVE LIQUIDITY ****
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountA, uint amountB) {
        bool flag = wsbPair[pairFor(wsbFactory,tokenA,tokenB)];
        address _factory ;
        address _tokenA = tokenA;
        address _tokenB = tokenB;
        uint _liquidity = liquidity;
        if(flag){
            _factory = wsbFactory;
        }else{
            _factory = pancakeFactory;
        }
        address pair;
        if(flag){
            pair = ISwapFactory(_factory).pairFor(_tokenA, _tokenB);
        }else{
            pair = PancakeLibrary.pairFor(_factory, _tokenA, _tokenB);
        }
        address lPair = getPair[_factory][_tokenA][_tokenB];
        IApproveProxy(_APPROVE_PROXY_).claimTokens(lPair, msg.sender, lPair, _liquidity);
        IPair(lPair).burn(to,_liquidity);

        TransferHelper.safeTransfer(pair, pair, _liquidity);
        (uint amount0, uint amount1) = IPancakePair(pair).burn(to);
        if(flag){
            (address token0,) = ISwapFactory(_factory).sortTokens(_tokenA, _tokenB);
            (amountA, amountB) = _tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        }else{
            (address token0,) = PancakeLibrary.sortTokens(_tokenA, _tokenB);
            (amountA, amountB) = _tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        }
        
        require(amountA >= amountAMin, 'LiquidityFactory: INSUFFICIENT_A_AMOUNT');
        require(amountB >= amountBMin, 'LiquidityFactory: INSUFFICIENT_B_AMOUNT');
    }

    function removeLiquidityFor(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        bool flag
    ) public virtual override returns (uint amountA, uint amountB) {
        address _factory ;
        address _tokenA = tokenA;
        address _tokenB = tokenB;
        uint _liquidity = liquidity;
        if(flag){
            _factory = wsbFactory;
        }else{
            _factory = pancakeFactory;
        }
        address pair;
        if(flag){
            pair = ISwapFactory(_factory).pairFor(_tokenA, _tokenB);
        }else{
            pair = PancakeLibrary.pairFor(_factory, _tokenA, _tokenB);
        }
        address lPair = getPair[_factory][_tokenA][_tokenB];
        IApproveProxy(_APPROVE_PROXY_).claimTokens(lPair, msg.sender, lPair, _liquidity);
        IPair(lPair).burn(to,_liquidity);

        TransferHelper.safeTransfer(pair, pair, _liquidity);
        (uint amount0, uint amount1) = IPancakePair(pair).burn(to);
        if(flag){
            (address token0,) = ISwapFactory(_factory).sortTokens(_tokenA, _tokenB);
            (amountA, amountB) = _tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        }else{
            (address token0,) = PancakeLibrary.sortTokens(_tokenA, _tokenB);
            (amountA, amountB) = _tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        }
        
        require(amountA >= amountAMin, 'LiquidityFactory: INSUFFICIENT_A_AMOUNT');
        require(amountB >= amountBMin, 'LiquidityFactory: INSUFFICIENT_B_AMOUNT');
    }

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountToken, uint amountETH) {
        (amountToken, amountETH) = removeLiquidity(
            token,
            WBNB,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, amountToken);
        IWBNB(WBNB).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }

    function removeLiquidityETHFor(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        bool flag
    ) public virtual override returns (uint amountToken, uint amountETH) {
        (amountToken, amountETH) = removeLiquidityFor(
            token,
            WBNB,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            flag
        );
        TransferHelper.safeTransfer(token, to, amountToken);
        IWBNB(WBNB).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }



    function createPair(address factory,address tokenA, address tokenB,address lp) public override returns (address pair) {
        require(tokenA != tokenB, 'LiquidityFactory: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'LiquidityFactory: ZERO_ADDRESS');
        require(getPair[factory][token0][token1] == address(0), 'LiquidityFactory: PAIR_EXISTS');
        // single check is sufficient
        bytes memory bytecode = type(Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1,factory));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IPair(pair).initialize(token0, token1,lp);
        getPair[factory][token0][token1] = pair;
        getPair[factory][token1][token0] = pair;
        // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1,factory, pair, allPairs.length);
    }

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) public override pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'LiquidityFactory: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'LiquidityFactory: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory,address tokenA, address tokenB) public override view returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                address(this),
                keccak256(abi.encodePacked(token0, token1,factory)),
                initCodeHash
            ))));
    }

    function pairFor(address tokenA, address tokenB) public view returns (address pair) {
        bool flag = wsbPair[pairFor(wsbFactory,tokenA,tokenB)];
        address _factory ;
        if(flag){
            _factory = wsbFactory;
        }else{
            _factory = pancakeFactory;
        }
        if(flag){
            pair = ISwapFactory(_factory).pairFor(tokenA, tokenB);
        }else{
            pair = PancakeLibrary.pairFor(_factory, tokenA, tokenB);
        }
    }

    function getReserves(address tokenA, address tokenB) public view returns (uint reserveA, uint reserveB) {
        bool flag = wsbPair[pairFor(wsbFactory,tokenA,tokenB)];
        address _factory;
        if(flag){
            _factory = wsbFactory;
        }else{
            _factory = pancakeFactory;
        }
        if(flag){
             ( reserveA, reserveB) = ISwapFactory(_factory).getReserves(tokenA, tokenB);
        }else{
             ( reserveA, reserveB) = PancakeLibrary.getReserves(_factory, tokenA, tokenB);   
        }
    }

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PancakeLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

}

library SafeMath {
    uint256 constant WAD = 10 ** 18;
    uint256 constant RAY = 10 ** 27;

    function wad() public pure returns (uint256) {
        return WAD;
    }

    function ray() public pure returns (uint256) {
        return RAY;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a <= b ? a : b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function sqrt(uint256 a) internal pure returns (uint256 b) {
        if (a > 3) {
            b = a;
            uint256 x = a / 2 + 1;
            while (x < b) {
                b = x;
                x = (a / x + x) / 2;
            }
        } else if (a != 0) {
            b = 1;
        }
    }

    function wmul(uint256 a, uint256 b) internal pure returns (uint256) {
        return mul(a, b) / WAD;
    }

    function wmulRound(uint256 a, uint256 b) internal pure returns (uint256) {
        return add(mul(a, b), WAD / 2) / WAD;
    }

    function rmul(uint256 a, uint256 b) internal pure returns (uint256) {
        return mul(a, b) / RAY;
    }

    function rmulRound(uint256 a, uint256 b) internal pure returns (uint256) {
        return add(mul(a, b), RAY / 2) / RAY;
    }

    function wdiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(mul(a, WAD), b);
    }

    function wdivRound(uint256 a, uint256 b) internal pure returns (uint256) {
        return add(mul(a, WAD), b / 2) / b;
    }

    function rdiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(mul(a, RAY), b);
    }

    function rdivRound(uint256 a, uint256 b) internal pure returns (uint256) {
        return add(mul(a, RAY), b / 2) / b;
    }

    function wpow(uint256 x, uint256 n) internal pure returns (uint256) {
        uint256 result = WAD;
        while (n > 0) {
            if (n % 2 != 0) {
                result = wmul(result, x);
            }
            x = wmul(x, x);
            n /= 2;
        }
        return result;
    }

    function rpow(uint256 x, uint256 n) internal pure returns (uint256) {
        uint256 result = RAY;
        while (n > 0) {
            if (n % 2 != 0) {
                result = rmul(result, x);
            }
            x = rmul(x, x);
            n /= 2;
        }
        return result;
    }
}

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**112 - 1]
// resolution: 1 / 2**112

library UQ112x112 {
    uint224 constant Q112 = 2 ** 112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112;
        // never overflows
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}