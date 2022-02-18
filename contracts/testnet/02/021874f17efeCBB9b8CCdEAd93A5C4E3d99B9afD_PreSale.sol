// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

contract PreSale {

    using SafeMath for uint256;

    uint256 private constant decimal = 18;

    uint256 private _airdrop;
    uint256 private _preSale;

    mapping (address => uint256) _erc20Balance;
    mapping (address => bool) _isReceive;
    mapping (address => uint256) _balance;
    mapping (address => uint256) _buyBalance;
    mapping (address => uint256) _share;
    mapping (address => address) _shareFirst;

    address private owner;
    address private _erc20;
    address private _preSaleAddress;    // 私募地址
    address private _airdropAddress;    // 空投地址
    address private _collectionAddress; // 收款地址
    address private _share1; // 股东1
    address private _share2; // 股东2
    address private _share3; // 股东3
    address private _share4; // 股东4

    bool public isPancakeswap;

    IUniswapV2Router02 public immutable uniswapV2Router;
    IUniswapV2Pair public immutable uniswapV2Pair;

    event Airdrop(address indexed sender, uint256 amount);
    event Buy(address indexed sender, uint256 amount);
    event Withdraw(address indexed sender, uint256 amount);
    event Transfer(address indexed sender, uint256 amount);

    constructor(
        address erc20_, 
        address preSaleAddress_, 
        address collectionAddress_, 
        address airdropAddress_, 
        address share1_, 
        address share2_, 
        address share3_, 
        address share4_){
        _erc20 = erc20_;
        _preSaleAddress = preSaleAddress_;
        _airdropAddress = airdropAddress_;
        _collectionAddress = collectionAddress_;
        _airdrop = 60000*10**decimal;
        _preSale = 1200000*10**decimal;
        _share1 = share1_;
        _share2 = share2_;
        _share3 = share3_;
        _share4 = share4_;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Pair(IUniswapV2Factory(_uniswapV2Router.factory()).createPair(erc20_, _uniswapV2Router.WETH()));

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        isPancakeswap = false;
        owner = msg.sender;
    }

    function getERC20Balance(address owner_) external view returns(uint256){
        return _erc20Balance[owner_];
    }

    function getIsReceive(address owner_) external view returns(bool){
        return _isReceive[owner_];
    }

    function getBalance(address owner_) external view returns(uint256){
        return _balance[owner_];
    }

    function getCanBuyBalance(address owner_) external view returns(uint256){
        uint256 buyBalance = _buyBalance[owner_];
        return (10*10**decimal).sub(buyBalance);
    }

    function getShareBalance(address owner_) external view returns(uint256){
        return _share[owner_];
    }

    function getShareAddress(address owner_) external view returns(address){
        return _shareFirst[owner_] == address(0) ? address(0) : _shareFirst[owner_];
    }

    function setPancakeswapOnline(bool online) external {
        require(msg.sender == owner, "PreSale: No permission");
        isPancakeswap = online;
    }

    function airdrop(address recomm) external {
        address sender = msg.sender;
        require(_airdrop >= 3*10**(decimal - 1), "PreSale: Airdrop has been issued");
        require(!_isReceive[sender], "PreSale: The airdrop has been received and cannot be received again");
        uint256 airdropAmount = 2*10**(decimal - 1);
        if (recomm != address(0)) {
            _erc20Balance[recomm] = _erc20Balance[recomm].add(10**(decimal - 1));
            _airdrop = _airdrop.sub(10**(decimal - 1));
        }
        _airdrop = _airdrop.sub(2*10**(decimal - 1));
        _isReceive[sender] = true;
        IERC20(_erc20).transferFrom(_airdropAddress, sender, airdropAmount);
        emit Airdrop(sender, airdropAmount);
    }

    function buy(address share_, address recomm) payable external {
        address sender_ = msg.sender;
        uint256 buyAmount = msg.value;
        uint256 price = 400;

        // 上线pancakeswap
        if (isPancakeswap){
            (uint112 amountA,uint112 amountB,) = uniswapV2Pair.getReserves();
            if (uniswapV2Pair.token0() == _erc20){
                price = amountA / amountB;
            }else{
                price = amountB / amountA;
            }
        }
        
        uint256 amount = buyAmount.mul(price);
        uint256 buyBalance = _buyBalance[sender_];
        require(buyAmount <= 10**19 && buyAmount >= 10**17, "PreSale: Minimum 0.1 BNB, maximum 10 BNB");
        require((10*10**decimal).sub(buyBalance) >= buyAmount, "Presale: The purchase quantity has been operated 10 BNB");
        require(_preSale >= amount, "PreSale: Sell out");
        uint256 recommFree;
        if (share_ == _share1 || share_ == _share2 || share_ == _share3 || share_ == _share4){
            _share[share_] = _share[share_].add(buyAmount);
            if (_shareFirst[sender_] == address(0)){
                _shareFirst[sender_] = share_;
            }
        }
        if (recomm != address(0)){
            recommFree = buyAmount.div(10);
            _balance[recomm] = _balance[recomm].add(recommFree);
        }
        _preSale = _preSale.sub(amount);
        _buyBalance[sender_] = buyBalance.add(buyAmount);
        IERC20(_erc20).transferFrom(_preSaleAddress, sender_, amount); // 预售地址授权给合约
        payable(_collectionAddress).transfer(buyAmount.sub(recommFree));
        emit Buy(sender_, buyAmount);
    }

    function withdraw() external {
        address sender_ = msg.sender;
        uint256 balance = _balance[sender_];
        require(balance > 0, "PreSale: The balance is unstable");
        require(balance >= 10**(decimal - 1), "PreSale: At least 0.1 BNB can be extracted");
        _balance[sender_] = 0;
        payable(sender_).transfer(balance);
        emit Withdraw(sender_, balance);
    }

    function transfer() external {
        address sender_ = msg.sender;
        uint256 balance = _erc20Balance[sender_];
        require(balance > 0, "PreSale: The balance is unstable");
        require(_airdrop >= balance, "PreSale: The airdrop has been issued");
        _erc20Balance[sender_] = 0;
        IERC20(_erc20).transferFrom(_airdropAddress, sender_, balance);
        emit Transfer(sender_, balance);
    }

}