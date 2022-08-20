/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

// File: TWINToken.sol


//
// SAFUU PROTOCOL COPYRIGHT (C) 2022

pragma solidity ^0.8.0;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IPancakeSwapPair {
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

interface IPancakeSwapRouter{
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

interface IPancakeSwapFactory {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
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
}

interface INFT{
    function getLevelAddress(uint256 level) external view returns(address[] memory);
}
contract TWINToken is ERC20Detailed, Ownable {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    string public _name = "TWIN";
    string public _symbol = "TWIN";
    uint256 public _decimals = 18;
    uint256 public _totalSupply = 1000000000 * 10 ** _decimals;

    IPancakeSwapRouter public router;
    address public pair;
    address public nftAddress;
    address public routerAddress;

    address public pondAddress;
    address public marketingAddress;
    address public buybackAddress;
    address public insuranceAddress;

    mapping(address => uint256) private _balances;
    mapping(address => bool) _isFeeExempt;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 public pondFee = 200;// 2%
    uint256 public marketingFee = 200;
    uint256 public nftBonusFeeByBuy = 600;

    uint256 public buybackFee = 200;// 2%
    uint256 public insuranceFee = 200;
    uint256 public nftBonusFeeBySell = 600;

    uint256 public feeDenominator = 10000;

    constructor(address _swapRouter,address _nftAddress) ERC20Detailed(_name,_symbol, uint8(_decimals)) Ownable() {
        require(_swapRouter!=address(0),"invalid swap router address");
        nftAddress = _nftAddress;
        routerAddress = _swapRouter;
        router = IPancakeSwapRouter(_swapRouter);
        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        _balances[_msgSender()] = _totalSupply;
        _isFeeExempt[owner()] = true;
        _isFeeExempt[_swapRouter] = true;
        _isFeeExempt[address(this)] = true;
    }

    event NftBonusEvent(address recipient,uint256 amount);

    event SwapTokensForETHEvent(
        uint256 amountIn,
        address taxAddress,
        address[] path
    );

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    function transfer(address to, uint256 value) public virtual override validRecipient(to) returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual override validRecipient(to) returns (bool) {
        _transferFrom(from, to, value);
        _approve(from, _msgSender(), _allowances[from][_msgSender()].sub(value, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function swapTokensForEth(uint256 amount1,address address1,uint256 amount2,address address2) private {
        IPancakeSwapRouter _router = IPancakeSwapRouter(routerAddress);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();

        _approve(address(this), routerAddress,amount1.add(amount2));

        // Make the swap    
        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount1,
            0, // Accept any amount of ETH
            path,
            address1,
            block.timestamp
        );
        emit SwapTokensForETHEvent(amount1,address1,path);

        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount2,
            0, // Accept any amount of ETH
            path,
            address2,
            block.timestamp
        );
        emit SwapTokensForETHEvent(amount2,address2,path);

    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool){
        _balances[sender] = _balances[sender].sub(amount);
        
        //buy
        if(sender == pair && !_isFeeExempt[recipient]){
            uint256 nftBonusAmount = amount.mul(nftBonusFeeByBuy).div(feeDenominator);
            uint256 pondAmount = amount.mul(pondFee).div(feeDenominator);
            uint256 marketingAmount = amount.mul(marketingFee).div(feeDenominator);
            uint256 surplusAmount = amount.sub(nftBonusAmount).sub(pondAmount).sub(marketingAmount);
            _balances[address(this)] = _balances[address(this)].add(pondAmount.add(marketingAmount));
            _balances[pondAddress] = _balances[pondAddress].add(pondAmount);
            _balances[marketingAddress] = _balances[marketingAddress].add(marketingAmount);
            _balances[recipient] = _balances[recipient].add(surplusAmount);
            address[] memory level1AddLs = INFT(nftAddress).getLevelAddress(1);
            address[] memory level2AddLs = INFT(nftAddress).getLevelAddress(2);
            address[] memory level3AddLs = INFT(nftAddress).getLevelAddress(3);
            uint256 totalNum = level1AddLs.length.add(level2AddLs.length).add(level3AddLs.length);
            if(totalNum > 0){
                uint256 amountAv = nftBonusAmount.div(totalNum); 
                _nftBonus(amountAv,level1AddLs);
                _nftBonus(amountAv,level2AddLs);
                _nftBonus(amountAv,level3AddLs);
            }else{
                _balances[address(this)]=_balances[address(this)].add(nftBonusAmount);
            }
            emit Transfer(sender,recipient,surplusAmount);
            return true;
        }

        //sell
        if(recipient == pair && !_isFeeExempt[sender]){
            uint256 nftBonusAmount = amount.mul(nftBonusFeeByBuy).div(feeDenominator);      
            uint256 buybackAmount = amount.mul(buybackFee).div(feeDenominator);
            uint256 insuranceAmount = amount.mul(insuranceFee).div(feeDenominator);
            uint256 surplusAmount = amount.sub(nftBonusAmount).sub(buybackAmount).sub(insuranceAmount);
            _balances[address(this)] = _balances[address(this)].add(buybackAmount.add(insuranceAmount));
            swapTokensForEth(buybackAmount,buybackAddress,insuranceAmount,insuranceAddress);
            _balances[recipient] = _balances[recipient].add(surplusAmount);
            address[] memory level2AddLs = INFT(nftAddress).getLevelAddress(2);
            address[] memory level3AddLs = INFT(nftAddress).getLevelAddress(3);
            uint256 totalNum = level2AddLs.length.add(level3AddLs.length);
            if(totalNum > 0){
                uint256 amountAv = nftBonusAmount.div(totalNum); 
                _nftBonus(amountAv,level2AddLs);
                _nftBonus(amountAv,level3AddLs);
            }else{
                _balances[address(this)]=_balances[address(this)].add(nftBonusAmount);
            }
            emit Transfer(sender,recipient,surplusAmount);
            return true;
        }
        _balances[recipient] = _balances[recipient].add(amount);
        return true;
    }

    function getLevelAddress(uint256 level) public view onlyOwner returns(address[] memory){
        return INFT(nftAddress).getLevelAddress(level);
    }

    function _nftBonus(uint256 amountAv,address[] memory addLs) internal returns(bool){
        if(addLs.length > 0){
            for(uint256 i = 0;i < addLs.length;i++){
                if(addLs[i] != address(0)){
                    _balances[addLs[i]] = _balances[addLs[i]].add(amountAv);
                    emit NftBonusEvent(addLs[i],amountAv);
                }
            }
        }
        return true;
    }

    function airdrop(address[] calldata userAddressLs,uint256 amount) public onlyOwner{
        for (uint256 i; i < userAddressLs.length; i++) {
            transfer(userAddressLs[i],amount * 10 ** _decimals);
        }
    }
    
    function setFeeExemptAddress(address _addr,bool _isFee) public onlyOwner{
        _isFeeExempt[_addr] = _isFee;
    }
    
    function addressIsFeeExempt(address _addr) public view onlyOwner returns(bool){
        return _isFeeExempt[_addr];
    }

    function allowance(address owner_, address spender)
    external
    view
    override
    returns (uint256)
    {
        return _allowances[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    returns (bool)
    {
        uint256 oldValue = _allowances[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowances[msg.sender][spender] = 0;
        } else {
            _allowances[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowances[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
    external
    returns (bool)
    {
        _allowances[msg.sender][spender] = _allowances[msg.sender][
        spender
        ].add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowances[msg.sender][spender]
        );
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _addr) external view override returns (uint256) {
        return _balances[_addr];
    }
    
    function setNftAddress(address _nftAddress) public onlyOwner{
        nftAddress = _nftAddress;
    }

    function setAddress(address _marketingAddress,address _pondAddress,address _buybackAddress,address _insuranceAddress) public onlyOwner{
        if(_marketingAddress != address(0))
        {
            marketingAddress = _marketingAddress;
            _isFeeExempt[_marketingAddress] = true;
        }
        if(_pondAddress != address(0))
        {
            pondAddress = _pondAddress;
            _isFeeExempt[_pondAddress] = true;
        }
        if(_buybackAddress != address(0))
        {
            buybackAddress = _buybackAddress;
            _isFeeExempt[_buybackAddress] = true;
        }
        if(_insuranceAddress != address(0))
        {
            insuranceAddress = _insuranceAddress;
            _isFeeExempt[_insuranceAddress] = true;
        }
    }

    function setBuyFee(uint256 _pondFee,uint256 _marketingFee,uint256 _nftBonusFeeByBuy) public onlyOwner{
        if(_pondFee > 0){
            pondFee = _pondFee;
        }
        if(_marketingFee > 0){
            marketingFee = _marketingFee;
        }
        if(_nftBonusFeeByBuy > 0){
            nftBonusFeeByBuy = _nftBonusFeeByBuy;
        }
    }

    function setSellFee(uint256 _buybackFee,uint256 _insuranceFee,uint256 _nftBonusFeeBySell) public onlyOwner{
        if(_buybackFee > 0){
            buybackFee = _buybackFee;
        }
        if(_insuranceFee > 0){
            insuranceFee = _insuranceFee;
        }
        if(_nftBonusFeeBySell > 0){
            nftBonusFeeBySell = _nftBonusFeeBySell;
        }
    }

    function withdraw(address token,address recipient,uint256 amount) public onlyOwner{
        IERC20(token).transfer(recipient,amount);
    }

}