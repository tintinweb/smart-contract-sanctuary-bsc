/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}



library UniswapV2Library {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address pair, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pair).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getPairAmountsOut(address pair, uint amountIn, address[] memory path) internal view returns (uint amountsOut) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        (uint reserveIn, uint reserveOut) = getReserves(pair, path[0], path[1]);
        amountsOut = getAmountOut(amountIn, reserveIn, reserveOut);

    }

}


// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

interface ISwapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function feeToRate() external view returns (uint256);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function setFeeToRate(uint256) external;

    function sortTokens(address tokenA, address tokenB) external pure returns (address token0, address token1);

    function pairFor(address tokenA, address tokenB) external view returns (address pair);

    function getReserves(address tokenA, address tokenB) external view returns (uint256 reserveA, uint256 reserveB);

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external pure returns (uint256 amountB);

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external view returns (uint256 amountOut);

    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) external view returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}


interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}

interface ICzzSwap is IERC20 {
    function mint(address _to, uint256 _amount) external;
    function burn(address _account, uint256 _amount) external;
    function transferOwnership(address newOwner) external;
}

interface IUniswapV2Router {
  function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

contract CzzRouter is Ownable {
    
    using SafeMath for uint;
    address WETH;
    address USDT;
    uint CONVERTTYPE;
    uint _commissionRate = 3;

    uint MIN_SIGNATURES = 2;

    struct InsertSign {
        uint8 signatureCount;
        address[] signatures;
    }

    mapping (address => uint8) private managers;
    mapping (address => uint8) private crossTokens;
    mapping (address => uint8) private routerAddrs;
    mapping (address => uint8) private commissionTokens;
    mapping (address => uint256) private commission;
    
    mapping (uint => MintItem) private mintItems;
    
    //0:setMinSignatures  1: setCommissionRate 2: crossToMainChain 3:betweenSideChainCross  4:manageCommission 5：tranGasToManager
    enum FunctionType{ 
        SETMINSIGNATURES,
        SETCOMMISSIONRATE,
        CROSSTOMAINCHAIN,
        BETWEENSIDECHAINCROSS,
        MANAGECOMMISSION,
        TRANGASTOMANAGER
    }

    struct MintItem {
        FunctionType funcType;
        address addresss;
        uint256 amounts;
        address Token;
        bytes32 burnHash;
        uint fromNetworkType;
        uint toNetworkType;
        uint setSignaturesNum;
        uint setCommissionRate;
        address managerCommissionToken;
        address commissionAddr;
        InsertSign sign;
    }

    struct ReMintItem{
        FunctionType funcType;
        address addresss;
        uint256 amounts;
        address Token;
        bytes32 burnHash;
        uint fromNetworkType;
        uint toNetworkType;
        uint setSignaturesNum;
        uint setCommissionRate;
        address managerCommissionToken;
        address commissionAddr;
    }

    struct RouterInfo {
        address factory;   
        address TokenOut; 
        uint index; 
    }

    struct FullRouterInfo {
        uint amountIn;
        address srcToken; 
        uint amountOutMin; 
        uint convertType;
        uint deadline;
        uint slippage;
        RouterInfo[] path; 
        bytes toInfo; 
    }

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'CzzRouter: EXPIRED');
        _;
    }

    function insertSignature(InsertSign storage item, address key) internal returns (bool)
    {
        uint i;
        for(i = 0; i<item.signatureCount; i++){
            if(item.signatures[i] == key){
                break;
            }
        }
        if(i < item.signatureCount){
            return false;
        }
        else
        {
            item.signatures.push(key);
            item.signatureCount += 1;
            return true;
        }
    }

    event TransferLog(
        address to,
        uint256 mid,
        uint256 gas,
        uint256 amountIn,
        uint256 amountOut,
        address toToken
    );

    event AtomTransferLog(
        uint256 mid,
        address toToken,
        address toaddress,
        uint256 amountIn
    );

    event BurnLog(
        address     from_,
        uint256     amountIn,
        uint256     amountOut,
        uint256     convertType,
        address     crossToken,
        bytes       toInfo,
        address     managerAddress
    );

    event AtomBurnLog(
        address     from_,
        uint256     amountIn,
        uint256     amountOut,
        uint256     convertType,
        address     crossToken,
        bytes       toInfo,
        address     managerAddress
    );

    event mintMapLog(
        uint id,  
        address _addresss, 
        uint256 _amounts, 
        address _Token, 
        bytes32 burnHash, 
        uint fromNetworkType,
        uint toNetworkType
    );

    event SwapToken(
        address indexed to,
        uint256 inAmount,
        uint256 outAmount,
        string   flag
    );
    
    event TransferToken(
        address  indexed to,
        uint256  amount
    );

    modifier isManager {
        require(
            msg.sender == owner() || managers[msg.sender] == 1);
        _;
    }

    constructor(address weth, uint convertType) {
        CONVERTTYPE = convertType;
        WETH = weth;
        commissionTokens[weth] = 1;
    }
    
    receive() external payable {}
    
    function addManager(address manager) public onlyOwner{
        managers[manager] = 1;
    }
    
    function removeManager(address manager) public onlyOwner{
        managers[manager] = 0;
    }


    function addCrossToken(address crossToken) public isManager{
        crossTokens[crossToken] = 1;
    }

    function removeCrossToken(address crossToken) public isManager{
        crossTokens[crossToken] = 0;
    }

    function addCommissionToken(address commissionToken) public isManager{
        commissionTokens[commissionToken] = 1;
    }

    function removeCommissionToken(address commissionToken) public isManager{
        commissionTokens[commissionToken] = 0;
    }

    function approve(address token, address spender, uint256 _amount) public virtual returns (bool) {
        require(address(token) != address(0), "approve token is the zero address");
        require(address(spender) != address(0), "approve spender is the zero address");
        require(_amount != 0, "approve _amount is the zero ");
        IERC20(token).approve(spender,_amount);
        return true;
    }

    function swapForPair(uint _amountOut, address[] memory path, address pair, address to) internal {
            (address input, address output) = (path[0], path[1]);
            (address token0,) = UniswapV2Library.sortTokens(input, output);
            uint amountOut = _amountOut;
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            IUniswapV2Pair(pair).swap(amount0Out, amount1Out, to, new bytes(0));
    }

    function getAmountsForPairWithPath(uint amountIn, address srcToken, RouterInfo[] memory path) view public returns (uint[] memory amounts, address[] memory pair)
    {
        uint n = path.length;
        amounts = new uint[](n + 1);
        amounts[0] = amountIn;
        pair = new address[](n);
        address[] memory path1 = new address[](2);
        path1[0] = srcToken;
        path1[1] = path[0].TokenOut;
        //console.log("amounts",0," ",amounts[0]);
        for(uint i; i < n; i++){
            (address tokenA,address tokenB) = UniswapV2Library.sortTokens(path1[0], path1[1]);
            pair[i] = ISwapFactory(path[i].factory).getPair(tokenA,tokenB);
           // console.log("path1[0]",path1[0]);
            //console.log("path1[1]",path1[1]);
            
            amounts[i+1] = UniswapV2Library.getPairAmountsOut(pair[i], amounts[i], path1);
           // console.log("amounts",i+1," ",amounts[i+1]);
            path1[0] = path[i].TokenOut;
            if(i+1<n){
                path1[1] = path[(i+1)].TokenOut;
            }
        }
    }

    function swapForPairWithPath(FullRouterInfo calldata pathFull, address to, uint needAward) internal returns (uint[] memory amounts)    /*rate :  Serv_charge_rate/1000*/
    {

        address[] memory path1 = new address[](2);
        address[] memory pair;
        address _to;
        address commissionToken = address(0);
        uint _amountIn = pathFull.amountIn;
        uint n = pathFull.path.length;

        path1[0] = pathFull.srcToken;
        path1[1] = pathFull.path[0].TokenOut;

        TransferHelper.safeTransferFrom(
                pathFull.srcToken, msg.sender, address(this), _amountIn
            );

        if(commissionTokens[path1[0]] == 1 && (needAward != 0))
        {
            _amountIn = pathFull.amountIn.mul(1000 - _commissionRate).div(1000);
            commissionToken = path1[0];
            commission[commissionToken] += pathFull.amountIn.mul(_commissionRate).div(1000);
        }
        (amounts, pair) = getAmountsForPairWithPath(_amountIn, pathFull.srcToken, pathFull.path);
        if(amounts[amounts.length - 1] >= pathFull.amountOutMin) {

            TransferHelper.safeTransfer(
                pathFull.srcToken, pair[0], _amountIn
            );

            for(uint i = 0; i < n; i++){
                if( (commissionTokens[path1[1]] == 1) && (commissionToken == address(0)) && (needAward != 0))
                {
                    commissionToken = path1[1];
                    swapForPair(amounts[i+1], path1, pair[i], address(this));
                    amounts[i+1] = amounts[i+1].mul(1000 - _commissionRate).div(1000);
                    commission[commissionToken] += amounts[i+1].mul(_commissionRate).div(1000);
                    if(i + 1 < n){
                        //RouterInfo[] calldata path2 = new RouterInfo[](n - i - 1);
                        RouterInfo[] calldata path2 = pathFull.path[(i+1):];
                        uint[] memory amounts1;
                        address[] memory pair1;
                        // for(uint j ; j < (n-i-1); j++){
                        //     path2[j] = pathFull.path[i+j+1];
                        // }
                        (amounts1, pair1) = getAmountsForPairWithPath(amounts[i+1], path1[1], path2);
                        for(uint j ; j < (n-i-1); j++){
                            amounts[j+i+2] = amounts1[j+1];
                        }
                        TransferHelper.safeTransfer(
                            path1[1], pair[i+1], amounts[i+1]
                        ); 
                    }else{
                        TransferHelper.safeTransfer(
                            path1[1], to, amounts[i+1]
                        ); 
                    }

                }else{
                    if(i + 1 < n){
                        _to = pair[i+1];
                    }else{
                        _to = to;
                    }
                    swapForPair(amounts[i+1], path1, pair[i], _to);
                }
                if(i + 1 < n){
                    path1[0] = pathFull.path[i].TokenOut;
                    path1[1] = pathFull.path[(i+1)].TokenOut;
                }
            }
        }
    }

    function swapEthForPairWithPath(FullRouterInfo calldata pathFull, address to, uint needAward) internal returns (uint[] memory amounts)   /*rate :  Serv_charge_rate/1000*/
    {

        address[] memory path1 = new address[](2);
        address[] memory pair;
        address _to;
        address commissionToken = address(0);
        uint n = pathFull.path.length;
        uint _amountIn = msg.value;

        path1[0] = pathFull.srcToken;
        path1[1] = pathFull.path[0].TokenOut;
       

        IWETH(WETH).deposit{value: _amountIn}();
        if(commissionTokens[path1[0]] == 1 && (needAward != 0))
        {
            _amountIn = _amountIn.mul(1000 - _commissionRate).div(1000);
            commissionToken = path1[0];
            commission[commissionToken] += pathFull.amountIn.mul(_commissionRate).div(1000);
        }
        (amounts, pair) = getAmountsForPairWithPath(_amountIn,pathFull.srcToken,pathFull.path);
            
            
        if(amounts[amounts.length - 1] >= pathFull.amountOutMin) {
            TransferHelper.safeTransfer(
                pathFull.srcToken, pair[0], _amountIn
            );
            for(uint i; i < n; i++){
                if( (commissionTokens[path1[1]] == 1) && (commissionToken == address(0)) && (needAward != 0))
                {
                    commissionToken = path1[1];
                    swapForPair(amounts[i+1], path1, pair[i], address(this));
                    amounts[i+1] = amounts[i+1].mul(1000 - _commissionRate).div(1000);
                    commission[commissionToken] += amounts[i+1].mul(_commissionRate).div(1000);
                    if(i + 1 < n){
                        
                        RouterInfo[] calldata path2 = pathFull.path[(i+1):];
                        uint[] memory amounts1;
                        address[] memory pair1;

                        (amounts1, pair1) = getAmountsForPairWithPath(amounts[i+1],path1[1],path2);
                        for(uint j ; j < (n-i-1); j++){
                            amounts[j+i+2] = amounts1[j+1];
                        }
                        TransferHelper.safeTransfer(
                            path1[1], pair[i+1], amounts[i+1]
                        ); 
                    }else{
                        TransferHelper.safeTransfer(
                            path1[1], to, amounts[i+1]
                        ); 
                    }

                }else{
                    if(i + 1 < n){
                        _to = pair[i+1];
                    }else{
                        _to = to;
                    }
                    swapForPair(amounts[i+1], path1, pair[i], _to);
                }
                if(i + 1 < n){
                    path1[0] = pathFull.path[i].TokenOut;
                    path1[1] = pathFull.path[(i+1)].TokenOut;
                }
            }
        }
    }

    function swapBurnGetReserves(address factory, address tokenA, address tokenB) public view isManager returns (uint reserveA, uint reserveB){
        require(address(0) != factory);
        return  ISwapFactory(factory).getReserves(tokenA, tokenB);
    }

    function swapGetAmount(uint256 amountIn, address[] memory path, address routerAddr) public view returns (uint[] memory amounts){
        require(address(0) != routerAddr); 
        return IUniswapV2Router(routerAddr).getAmountsOut(amountIn,path);
    }
 

    function swapAndBurnWithPath(FullRouterInfo calldata pathFull, address managerAddr) payable public
    {

        require(crossTokens[pathFull.path[pathFull.path.length -1].TokenOut] == 1, "last fromPath is not crossToken"); 
        require(pathFull.convertType != CONVERTTYPE, "convertType is oneself"); 

        uint[] memory amounts = swapForPairWithPath(pathFull, managerAddr, 1);
        emit BurnLog(msg.sender, pathFull.amountIn, amounts[amounts.length - 1], pathFull.convertType, pathFull.path[pathFull.path.length -1].TokenOut, pathFull.toInfo, managerAddr);

    }

    function swapAndBurnEthWithPath(FullRouterInfo calldata pathFull, address managerAddr) payable public ensure(pathFull.deadline)
    {
        require(pathFull.srcToken == WETH, "toPath 0 is not weth");
        require(crossTokens[pathFull.path[pathFull.path.length -1].TokenOut] == 1, "last fromPath is not crossToken"); 
        require(pathFull.convertType != CONVERTTYPE, "convertType is oneself"); 
        require(msg.value > 0);

        uint[] memory amounts = swapEthForPairWithPath(pathFull, managerAddr, 1);
        emit BurnLog(msg.sender, msg.value, amounts[amounts.length - 1], pathFull.convertType, pathFull.path[pathFull.path.length -1].TokenOut,pathFull.toInfo, managerAddr);
    }
    
    function swapTokenWithPath(FullRouterInfo calldata pathFull, uint256 mid, uint256 gas, address toAddress) payable public isManager {
        require(pathFull.amountIn > 0);
        require(pathFull.amountIn >= gas, "ROUTER: transfer amount exceeds gas");
        require(crossTokens[pathFull.srcToken] == 1, "toPath 0 is not crossToken"); 

        uint[] memory amounts = swapForPairWithPath(pathFull, toAddress, 0);
        emit TransferLog(toAddress, mid, gas, pathFull.amountIn, amounts[amounts.length - 1], pathFull.path[pathFull.path.length - 1].TokenOut);
    }
    
    function swapAndTokenForEthWithPath(FullRouterInfo calldata pathFull, uint256 mid, uint256 gas, address toAddress) payable public isManager {
        require(pathFull.amountIn > 0);
        require(pathFull.amountIn >= gas, "ROUTER: transfer amount exceeds gas");
        require(crossTokens[pathFull.srcToken] == 1, "toPath 0 is not crossToken"); 
        require(pathFull.path[pathFull.path.length - 1].TokenOut == WETH, "toPath 0 is not weth"); 
     
        uint[] memory amounts = swapForPairWithPath(pathFull, address(this), 0);
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(toAddress, amounts[amounts.length - 1]);

        emit TransferLog(toAddress, mid, gas, pathFull.amountIn, amounts[amounts.length - 1], pathFull.path[pathFull.path.length - 1].TokenOut);
    }
    
    function burnFromUser( uint256 amountIn, uint256 convertType, bytes memory toInfo, address token, address managerAddr, uint deadline) payable public ensure(deadline)
    {
        require(crossTokens[token] == 1, "token is not crossToken"); 
        require(managers[managerAddr] == 1 || managerAddr == owner(), "managerAddr is error"); 
        uint256 amountOut;
        TransferHelper.safeTransferFrom(token, msg.sender, address(this), amountIn);
        amountOut = amountIn.mul(1000 - _commissionRate).div(1000);
        commission[token] += amountIn.mul(_commissionRate).div(1000);
        TransferHelper.safeTransfer(token, managerAddr, amountOut);
        emit BurnLog(msg.sender, amountIn, amountOut, convertType, token,toInfo, managerAddr);
    }

    function tranGasToUser(address toAddress, uint256 mid, uint256 _amountIn, uint256 gas, address toToken)  payable public  isManager
    {
        require(_amountIn > 0);
        require(_amountIn >= gas, "ROUTER: transfer amount exceeds gas");
        require(crossTokens[toToken] == 1, "toPath 0 is not crossToken"); 

        uint256 amountIn = _amountIn - gas;
        TransferHelper.safeTransferFrom(toToken, msg.sender, toAddress, amountIn);
        emit TransferLog(toAddress, mid, gas, _amountIn, _amountIn, toToken);
    }

    function burnFromManager(uint256 amountIn, uint256 convertType, bytes memory toInfo, address token, address managerAddr, uint deadline) payable public ensure(deadline) isManager
    {
        require(crossTokens[token] == 1, "token is not crossToken"); 
        require(managers[managerAddr] == 1 || managerAddr == owner(), "managerAddr is error"); 

        //console.log("token is ",token);
        ICzzSwap(token).burn(managerAddr, amountIn);
        emit AtomBurnLog(msg.sender, amountIn, amountIn, convertType, token, toInfo, managerAddr);
    }

    function tranGasToManagerMap(uint id,  address _addresss, uint256 _amounts, address _Token, bytes32 _burnHash, uint _fromNetworkType, uint _toNetworkType) payable public isManager {
        
        require(mintItems[id].sign.signatureCount == 0, "mintAmounts is exist");
        require(crossTokens[_Token] == 1, "token is not crossToken"); 
        require(insertSignature(mintItems[id].sign, msg.sender), "Repeat the signature");
        mintItems[id].funcType = FunctionType.TRANGASTOMANAGER;
        mintItems[id].addresss =  _addresss;
        mintItems[id].amounts =  _amounts;
        mintItems[id].Token =  _Token;
        mintItems[id].burnHash = _burnHash;
        mintItems[id].fromNetworkType = _fromNetworkType;
        mintItems[id].toNetworkType = _toNetworkType;

        emit mintMapLog(id,  _addresss, _amounts, _Token, _burnHash, _fromNetworkType, _toNetworkType);
        if(mintItems[id].sign.signatureCount >= MIN_SIGNATURES)
        {
            ICzzSwap(mintItems[id].Token).mint(mintItems[id].addresss, mintItems[id].amounts);
            emit AtomTransferLog(id, mintItems[id].Token, mintItems[id].addresss, mintItems[id].amounts);
            delete mintItems[id];
            
        }
    }
    
    function getMapFromId(uint id) public view isManager returns(ReMintItem memory item){
        item.funcType = mintItems[id].funcType;
        item.addresss = mintItems[id].addresss;
        item.amounts = mintItems[id].amounts;
        item.Token = mintItems[id].Token;
        item.burnHash = mintItems[id].burnHash;
        item.fromNetworkType  = mintItems[id].fromNetworkType;
        item.toNetworkType  = mintItems[id].toNetworkType;
        item.setSignaturesNum = mintItems[id].setSignaturesNum;
        item.setCommissionRate = mintItems[id].setCommissionRate;
        item.managerCommissionToken = mintItems[id].managerCommissionToken;
        item.commissionAddr = mintItems[id].commissionAddr;
    }

    function setMinSignaturesMap(uint id, uint num) public isManager {
        require(mintItems[id].sign.signatureCount == 0, "setMinSignaturesMap is error");
        require(num < 100, "value too large ,must less 100");
        require(insertSignature(mintItems[id].sign, msg.sender), "Repeat the signature");
        mintItems[id].funcType = FunctionType.SETMINSIGNATURES;
        mintItems[id].setSignaturesNum = num;
        if(mintItems[id].sign.signatureCount >= MIN_SIGNATURES) {
            MIN_SIGNATURES = mintItems[id].setSignaturesNum;
            delete mintItems[id];
        }
    }

    function getMinSignatures() public view isManager returns(uint){
        return MIN_SIGNATURES;
    }

    function manageCommissionMap(uint id, address token, address commissionAddr) public isManager {
        require(mintItems[id].sign.signatureCount == 0, "manageCommission is exist");
        require((commissionTokens[token] == 1) || (crossTokens[token] == 1), "token is not crossTokens or commissionToken");
        require(commission[token] > 0, "token commission ballance is zero");
        require(insertSignature(mintItems[id].sign, msg.sender), "Repeat the signature");
        mintItems[id].funcType = FunctionType.MANAGECOMMISSION;
        mintItems[id].commissionAddr = commissionAddr;
        mintItems[id].Token = token;
        if(mintItems[id].sign.signatureCount >= MIN_SIGNATURES) {
            TransferHelper.safeTransfer(mintItems[id].Token, mintItems[id].commissionAddr, commission[mintItems[id].Token]);
            commission[mintItems[id].Token] = 0;
            delete mintItems[id];
        }
    }

    function getCommission(address token) public view isManager returns(uint){
        return commission[token];
    }

    function setCommissionRateMap(uint id, uint rate) public isManager {
        require(mintItems[id].sign.signatureCount == 0, "setCommissionRateMap is error");
        require(rate >= 0, "rate is error !!");
        require(insertSignature(mintItems[id].sign, msg.sender), "Repeat the signature");
        mintItems[id].funcType = FunctionType.SETCOMMISSIONRATE;
        mintItems[id].setCommissionRate = rate;
        if(mintItems[id].sign.signatureCount >= MIN_SIGNATURES) {
            _commissionRate = mintItems[id].setCommissionRate;
            delete mintItems[id];
        }
    }

    function getCommissionRate() public view isManager returns(uint){
        return _commissionRate;
    }

    function participateInSignature(uint id, uint deadline) payable public ensure(deadline) isManager {
        //0:setMinSignatures  1: setCommissionRate 2: crossToMainChain 3:betweenSideChainCross  4:manageCommission 5：tranGasToManager
        require(mintItems[id].sign.signatureCount > 0, "participateInSignature is error , no map");
        require(insertSignature(mintItems[id].sign, msg.sender), "Repeat the signature");
        if(mintItems[id].sign.signatureCount >= MIN_SIGNATURES) {
            if(mintItems[id].funcType == FunctionType.SETMINSIGNATURES){
                MIN_SIGNATURES = mintItems[id].setSignaturesNum;
            }else if(mintItems[id].funcType == FunctionType.SETCOMMISSIONRATE){
                _commissionRate = mintItems[id].setCommissionRate;
            }else if(mintItems[id].funcType == FunctionType.MANAGECOMMISSION){
                TransferHelper.safeTransfer(mintItems[id].Token, mintItems[id].commissionAddr, commission[mintItems[id].Token]);
                commission[mintItems[id].Token] = 0;
            }else if(mintItems[id].funcType == FunctionType.TRANGASTOMANAGER){
                ICzzSwap(mintItems[id].Token).mint(mintItems[id].addresss, mintItems[id].amounts);
                emit AtomTransferLog(id, mintItems[id].Token, mintItems[id].addresss, mintItems[id].amounts);
            }
            delete mintItems[id];
        }

    }

}