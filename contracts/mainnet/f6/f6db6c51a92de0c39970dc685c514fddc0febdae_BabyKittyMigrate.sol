/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
***   website:  https://snakeking.club
*** 
*/

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor()  {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
    modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
    
    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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

interface IState {
    function getEndTime() view external returns(uint256);
}


contract BabyKittyMigrate is Context, Ownable, ReentrancyGuard {
    
    using SafeMath for uint256;
    using Address for address;
    
    address public immutable _deadAddress = 0x000000000000000000000000000000000000dEaD;

    IUniswapV2Router02 public _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    uint8 public _migrateStep = 1;
    
    address public _v1TokenAddress;
    mapping(address => uint256) _v1ExchangeAmount;
    mapping(address => uint256) _v2ExchangeAmount;

    
    address public _v2TokenAddress;
    address public _v2PairAddress;

    mapping(address => uint256) _v2ExchangeRewardAmount;
    mapping(address => uint256) _v2ExchangeRewardTime;
    mapping(address => uint256) _v2ExchangeSingleDrawAmount;
    
    address[] public _releaseList;
    mapping(address => uint256) _releaseBnbAmount;
    mapping(address => uint256) _releaseTokenAmount;
    mapping(address => uint8) _releaseCount;
    mapping(address => uint256) _releaseRewardAmount;
    mapping(address => uint256) _releaseLPAmount;

    
    uint256 public _receiveV1Amount;
    uint256 public _exchangeV2Amount;
    uint256 public _unionPoolBNB;
    uint256 public _unionPoolToken;
    uint256 public _burnTokenAmount;
    
    uint256 public _startDrawRewardTime = 1653472800;

    event ExchangeDone(address sender, uint256 v1Amount, uint256 v2Amount);
    event ReleaseDone(address sender, uint256 bnbAmount, uint256 tokenAmount);
    event DrawDone(address sender);
    
    
    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    constructor(address v1TokenAddress, address v2TokenAddress, address v2PairAddress) {
        _v1TokenAddress = v1TokenAddress;
        
        _v2TokenAddress = v2TokenAddress; 
        _v2PairAddress = v2PairAddress;
        
        uint256 v1TotalSupply = IERC20(_v1TokenAddress).totalSupply();
        IERC20(_v1TokenAddress).approve(address(_uniswapV2Router), v1TotalSupply);
    }

    //direct exchange for v1
    function exchange() public isHuman nonReentrant {
        
        require(_migrateStep == 1 || _migrateStep == 2, "Step error");
        
        address sender = _msgSender();
        uint256 v1Balance = IERC20(_v1TokenAddress).balanceOf(sender);
        require(v1Balance >= 10 ** 14 * 10 ** 9, "Too little v1");
        
        uint256 allowanceBalance = IERC20(_v1TokenAddress).allowance(sender, address(this));
        require(allowanceBalance >= v1Balance, "Insufficient authorized amount");
        
        uint256 currV1TokenAmount = IERC20(_v1TokenAddress).balanceOf(address(this));
        
        bool result = IERC20(_v1TokenAddress).transferFrom(sender, address(this), v1Balance);
        require(result, "Transfer error");
        
        uint256 receiveV1TokenAmount = IERC20(_v1TokenAddress).balanceOf(address(this)).sub(currV1TokenAmount);
        if(receiveV1TokenAmount < v1Balance) {
            v1Balance = receiveV1TokenAmount;
        }
        
        require(v1Balance > 0, "V1 balance error");
        
        uint256 currBnbAmount = address(this).balance;
        _swapTokensForEthByV1(v1Balance);
        uint256 targetBnbAmount = address(this).balance.sub(currBnbAmount);
        
        uint256 targetTokenAmount = getTokenAmountByBnb(targetBnbAmount);
        _addV2Liquidity(targetTokenAmount, targetBnbAmount, _deadAddress);
        
        result = IERC20(_v2TokenAddress).transfer(sender, targetTokenAmount);
        require(result, "V2 token transfer error");
        
        _v2ExchangeAmount[sender] = _v2ExchangeAmount[sender].add(targetTokenAmount);
        _v1ExchangeAmount[sender] = _v1ExchangeAmount[sender].add(v1Balance);
        
        _receiveV1Amount = _receiveV1Amount.add(v1Balance);
        _exchangeV2Amount = _exchangeV2Amount.add(targetTokenAmount);
        
        if(_migrateStep == 1) {
            
            uint256 rewardAmount = targetTokenAmount.div(2);
            _v2ExchangeRewardAmount[sender] = _v2ExchangeRewardAmount[sender].add(rewardAmount);
            _v2ExchangeRewardTime[sender] = _startDrawRewardTime;
            _v2ExchangeSingleDrawAmount[sender] = _v2ExchangeRewardAmount[sender].div(5);
        }
        
         emit ExchangeDone(sender, v1Balance, targetTokenAmount);
       
    }
    
    function drawReward() public isHuman {
        require(_migrateStep == 2, "Step error");
        address sender = _msgSender();
        require(_v2ExchangeRewardTime[sender] != 0, "You have no reward");
        require(_v2ExchangeRewardTime[sender] < block.timestamp, "The collection time has not been reached");
        require(_v2ExchangeRewardAmount[sender] > 0, "The reward has been collected");
        
        uint256 amount = _v2ExchangeSingleDrawAmount[sender];
        _v2ExchangeRewardAmount[sender] = _v2ExchangeRewardAmount[sender].sub(amount);
        
        IERC20(_v2TokenAddress).transfer(sender, amount);
        
        if(_v2ExchangeRewardAmount[sender] == 0){
            _v2ExchangeRewardTime[sender] = 0;
        } else {
            _v2ExchangeRewardTime[sender] = block.timestamp + 30 days;
        }
        
        emit DrawDone(sender);
    }

    //ecological release
    function release() payable public isHuman nonReentrant {
        
        address sender = _msgSender();
        
        uint256 currV2Balance = IERC20(_v2TokenAddress).balanceOf(address(this));
        require(currV2Balance > 0, "Amount not enough");

        //0.1 bnb minimum required
        uint256 minBNB = 10 ** 17; 
        uint256 payBNB = msg.value;
        require(payBNB >= minBNB, "Minimum amount error");
        uint256 lpBNB = payBNB.div(2);

        uint256 neetTokenAmount = getTokenAmountByBnb(lpBNB);
        require(neetTokenAmount <= currV2Balance, "Token not enough");
    
        uint256 currLP = IERC20(_v2PairAddress).balanceOf(sender);
        _addV2Liquidity(neetTokenAmount, lpBNB, sender);
        uint256 targetLP = IERC20(_v2PairAddress).balanceOf(sender).sub(currLP);
        
        _releaseLPAmount[sender] = _releaseLPAmount[sender].add(targetLP);
        
        if(_releaseCount[sender] == 0) {
            _releaseList.push(sender);
        }
        _releaseTokenAmount[sender] = _releaseTokenAmount[sender].add(neetTokenAmount);
        _releaseBnbAmount[sender] = _releaseBnbAmount[sender].add(payBNB);
        _releaseCount[sender] = _releaseCount[sender] + 1;
        
        if(_migrateStep == 1) {
            uint256 rewardTokenAmount = neetTokenAmount.mul(5).div(100);
            bool result = IERC20(_v2TokenAddress).transfer(sender, rewardTokenAmount);
            require(result, "Reward token transfer error");
            _releaseRewardAmount[sender] = _releaseRewardAmount[sender].add(rewardTokenAmount);
        }
        
        _unionPoolBNB = _unionPoolBNB.add(lpBNB);
        _unionPoolToken = _unionPoolToken.add(neetTokenAmount);
        
        emit ReleaseDone(sender, payBNB, neetTokenAmount);
    }
    
    function clear() public onlyOwner {
        uint256 bnbBalance = address(this).balance;
        if(bnbBalance > 0) {
            uint256 currAmount = IERC20(_v2TokenAddress).balanceOf(address(this));
            _swapEthForTokensByV2(address(this), bnbBalance);
            uint256 targetAmount = IERC20(_v2TokenAddress).balanceOf(address(this)).sub(currAmount);
            if(targetAmount > 0) {
                IERC20(_v2TokenAddress).transfer(_deadAddress, targetAmount);
                _burnTokenAmount = _burnTokenAmount.add(targetAmount);
            }
        }
    }

    function setStep(uint8 step) public onlyOwner {
        _migrateStep = step;
    }


    function end() public isHuman {
        uint256 endTime = IState(_v2TokenAddress).getEndTime();
        require(block.timestamp > endTime, "Time limit not reached");
        uint256 tokenAmount = IERC20(_v2TokenAddress).balanceOf(address(this));
        if(tokenAmount > 0) {
            IERC20(_v2TokenAddress).transfer(_deadAddress, tokenAmount);
            _burnTokenAmount = _burnTokenAmount.add(tokenAmount);
        }
    }
    
    function getTokenAmountByBnb(uint256 bnbAmount) public view returns(uint256) {
        uint256 tokenPrice = getPriceOfToken();
        return bnbAmount.mul(tokenPrice).div(10 ** 18);
    }
    
    function getBnbAmountByToken(uint256 tokenAmount) public view returns(uint256) {
        uint256 bnbnPrice = getPriceOfBNB();
        return tokenAmount.mul(bnbnPrice).div(10 ** 9);
    }
    
    function getPriceOfBNB() view public returns(uint256){
        IUniswapV2Pair pair = IUniswapV2Pair(_v2PairAddress);
        (uint256 res0, uint256 res1,) = pair.getReserves();
        (res0, res1) = (pair.token0() == _v2TokenAddress) ? (res0,res1) : (res1,res0);
        return (res1 * (10 ** 9)).div(res0);
    }
    
    function getPriceOfToken() view public returns(uint256){
        IUniswapV2Pair pair = IUniswapV2Pair(_v2PairAddress);
        (uint256 res0, uint256 res1,) = pair.getReserves();
        (res0, res1) = (pair.token0() == _v2TokenAddress) ? (res0,res1) : (res1,res0);
        return (res0 * (10 ** 18)).div(res1);
    }
    

    function _swapTokensForEthByV1(uint256 v1Amount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = _v1TokenAddress;
        path[1] = _uniswapV2Router.WETH();
        
        // make the swap
        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            v1Amount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
        
    }
    
    function _swapEthForTokensByV2(address recipient, uint256 bnbAmount) private {
        // generate the uniswap pair path of weth -> token
        address[] memory path = new address[](2);
        path[0] = _uniswapV2Router.WETH();
        path[1] = _v2TokenAddress;
        // make the swap
        _uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bnbAmount}(
            0, // accept any amount of Token
            path,
            recipient, // The recipient
            block.timestamp + 60
        );
        
    }
    
    function _addV2Liquidity(uint256 tokenAmount, uint256 bnbAmount, address toAddress) private returns(uint256) {
        // approve token transfer to cover all possible scenarios
        IERC20(_v2TokenAddress).approve(address(_uniswapV2Router), tokenAmount);

        uint256 currLPAmount = IERC20(_v2PairAddress).balanceOf(toAddress);

        // add the liquidity
        _uniswapV2Router.addLiquidityETH{value: bnbAmount}(
            _v2TokenAddress,
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            toAddress,
            block.timestamp
        );

        uint256 getLPAmouunt = IERC20(_v2PairAddress).balanceOf(toAddress).sub(currLPAmount);

        return getLPAmouunt;
    }
    
    function baseInfo() public view isHuman returns(
         uint8 step,
         uint256 currBalance,
         uint256 receiveV1Amount,
         uint256 exchangeV2Amount,
         uint256 unionPoolBNB,
         uint256 unionPoolToken,
         uint256 burnTokenAmount
         ) {
        
        step = _migrateStep;
        currBalance = IERC20(_v2TokenAddress).balanceOf(address(this));
        receiveV1Amount = _receiveV1Amount;
        exchangeV2Amount = _exchangeV2Amount;
        unionPoolBNB = _unionPoolBNB;
        unionPoolToken = _unionPoolToken;
        burnTokenAmount = _burnTokenAmount;
    }
    
    function releaseInfo(address sender) public view isHuman returns(
        uint256 bnbBalance,
        uint8 joinCount,
        uint256 bnbAmount,
        uint256 tokenAmount,
        uint256 lpAmount,
        uint256 rewardAmount,
        address[] memory listAddress, 
        uint256[] memory listBnb,
        uint256[] memory listToken) {
            
            
        bnbBalance = address(sender).balance;
        joinCount = _releaseCount[sender];
        bnbAmount = _releaseBnbAmount[sender];
        tokenAmount = _releaseTokenAmount[sender];
        rewardAmount = _releaseRewardAmount[sender];
        lpAmount = _releaseLPAmount[sender];
  
        uint256 len = _releaseList.length;
        listAddress = new address[](len);
        listBnb = new uint256[](len);
        listToken = new uint256[](len);
        for(uint256 i=0; i<len; i++) {
           address target = _releaseList[i];
           listAddress[i] = target;
           listToken[i] = _releaseTokenAmount[target];
           listBnb[i] = _releaseBnbAmount[target];
        }

    }
    
    function exchangeInfo(address sender) public view isHuman returns (
        uint256 v1Balance,
        uint256 myV1Amount,
        uint256 myV2Amount,
        uint256 myRewardAmount,
        uint256 myRewardTime) {
        
        v1Balance = IERC20(_v1TokenAddress).balanceOf(sender);
        myV1Amount = _v1ExchangeAmount[sender];
        myV2Amount = _v2ExchangeAmount[sender];
        myRewardAmount = _v2ExchangeRewardAmount[sender];
        myRewardTime = _v2ExchangeRewardTime[sender];
    }
    
}