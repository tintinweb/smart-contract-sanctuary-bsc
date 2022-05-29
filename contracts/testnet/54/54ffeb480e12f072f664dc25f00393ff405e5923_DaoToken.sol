/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

contract Ownable is Context {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
     function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
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
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

contract DaoToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    mapping(address => bool) public whiteContract;
    
   
    uint8 private _decimals = 18;
    uint256 private _tTotal = 10000000000 * 10**18;

    string private _name = "test 1111";
    string private _symbol = "TEst 111";

    uint256 public totalBuyFee = 15;
    uint256 public totalSellFee = 15;
    uint256 public transferFee = 0;
    bool public isContractSwitch;
    bool public isFee = true;


    IUniswapV2Router02 public immutable uniswapV2Router;
    address public  uniswapV2Pair;

    mapping(address => bool) public exPairs;
    //mainnet
    //address public _router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    //address public USDT = address(0x55d398326f99059fF775485246999027B3197955);
    //testnet
    address public _router = address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); 
    address public USDT = address(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd);    

    address public holder;

    uint256 public denominator = 15;
    uint256 public teamRate = 5;
    address public team = 0x17555767641A085b3504B6AE72b21ef534BF866D;
    uint256 public poolRate = 4;
    address public pool = 0x510194A0973c9f30370d188300d224CcFa9A0E49;
    uint256 public energyRate = 3;
    address public energy = 0xaFd49FBfC5Dc718e2Fe8401E00E8349af411DbfB;
    uint256 public nftRate = 3;
    address public nft = 0x84240AD5fab70388582999325E6Af2F223016525;

    address constant public burnAddress = address(0x000000000000000000000000000000000000dEaD);
    
    struct FeeParam {
        uint tTransferAmount;
        uint totalFee;
        address user;
    }

    constructor () public {
        
         holder = msg.sender;
        _tOwned[holder] = _tTotal;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);
        uniswapV2Router = _uniswapV2Router;
         
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), USDT);
        
        uniswapV2Pair = _uniswapV2Pair;

        exPairs[uniswapV2Pair] = true;

        _isExcludedFromFee[team] = true;
        _isExcludedFromFee[pool] = true;
        _isExcludedFromFee[nft] = true;
        _isExcludedFromFee[energy] = true;
        _isExcludedFromFee[burnAddress] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_router] = true;
        _isExcludedFromFee[_owner] = true;

        _owner = msg.sender;
        _approve(address(this), _router, _tTotal);

        emit Transfer(address(0), holder, _tTotal);
    }

    function setSellFee(address _team,address _pool,address _energy,address _nft) external onlyOwner {
        team = _team;
        pool = _pool;
        energy = _energy;
        nft = _nft;
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

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    
    receive() external payable {}

    function _take(uint256 tValue,address from,address to) private {
        _tOwned[to] = _tOwned[to].add(tValue);
        emit Transfer(from, to, tValue);
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        require(_isExcludedFromFee[msg.sender], "not allowed");
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (isContractSwitch && _isContract(from)) {
            require(whiteContract[msg.sender], "not allowed");
        }
        FeeParam memory param;
        
        if(isFee){
           param.tTransferAmount = amount;
           if(isFee && exPairs[from]){
               param.user = to;
               _getBuyParam(amount,param);
           }
           if(isFee && exPairs[to]){
               param.user = from;
               _getSellParam(amount,param);            
           }
           if(isFee && !exPairs[from] && !exPairs[to]){
               param.user = from;
               _getTransferParam(amount,param);
           }
        } 
        _tokenTransfer(from,to,amount,param);
    }


    function _getBuyParam(uint256 tAmount,FeeParam memory param) private view  {
        if(!_isExcludedFromFee[param.user]){
            uint tFee = tAmount.mul(totalBuyFee).div(100);
            param.totalFee = tFee;
            param.tTransferAmount = tAmount.sub(tFee);
        }
        
    }

    function _getSellParam(uint256 tAmount,FeeParam memory param) private view  {
        if(!_isExcludedFromFee[param.user]){
            uint tFee = tAmount.mul(totalSellFee).div(100);
            param.totalFee = tFee;
            param.tTransferAmount = tAmount.sub(tFee);
        }
    }

    function _getTransferParam(uint256 tAmount,FeeParam memory param) private view {
        param.totalFee = tAmount * transferFee / 1000;
        param.tTransferAmount = tAmount.sub(param.totalFee);
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount,FeeParam memory param) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        if(param.tTransferAmount>0){
            _tOwned[recipient] = _tOwned[recipient].add(param.tTransferAmount);
            emit Transfer(sender, recipient, param.tTransferAmount);
        }
        if(param.totalFee > 0){
            _takeFee(param,sender);
        }
    }

    function _takeFee(FeeParam memory param,address from) private {
        _take(param.totalFee.mul(teamRate).div(denominator), from, team);
        _take(param.totalFee.mul(poolRate).div(denominator), from, pool);
        _take(param.totalFee.mul(nftRate).div(denominator), from, nft);
        _take(param.totalFee.mul(energyRate).div(denominator), from, address(this));
        swapTokensForUSDT(param.totalFee.mul(energyRate).div(denominator));
    }

    function swapTokensForUSDT(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDT;

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens (
            tokenAmount,
            0, // accept any amount of USDT
            path,
            energy, // The energy addr
            block.timestamp
        );
    }

    function donateERC20(address addr, uint256 amount) external onlyOwner {
        TransferHelper.safeTransfer(addr, _msgSender(), amount);
    }

    function donateBNB(uint256 amount) external onlyOwner {
        TransferHelper.safeTransferETH(_msgSender(), amount);
    }

     function _isContract(address a) internal view returns(bool){
        uint256 size;
        assembly {size := extcodesize(a)}
        return size > 0;
    }
    

}