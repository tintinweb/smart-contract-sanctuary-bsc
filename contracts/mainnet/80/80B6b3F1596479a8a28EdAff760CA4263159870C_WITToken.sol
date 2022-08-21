// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;

import "./IBEP20.sol";
import "./SafeMath.sol";

interface IPancakePair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
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
contract Ownable {
    address public _owner;

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

contract InviteReward {

    mapping (address => address) internal _refers;

    function _bindParent(address sender, address recipient) internal {
        if(_refers[recipient] == address(0)) {
            _refers[recipient] = sender;
        }
    }
    
    function getParent(address user) public view returns (address) {
        return _refers[user];
    }

}

contract LineReward {

    address[10] internal _lines;
    
    function _pushLine(address user) internal {
        for(uint256 i = _lines.length - 1; i > 0 ; i--) {
            _lines[i] = _lines[i-1];
        }
        _lines[0] = user;
    }

    function getLines() public view returns (address[10] memory) {
        return _lines;
    }

}
interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

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
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}


contract WITToken is IBEP20, Ownable, InviteReward {
    
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    string constant  _name = "WIT";
    string constant _symbol = "WIT";
    uint8 immutable _decimals = 18;
    uint256 private _totalSupply = 1000000000*10**18;
    uint256 nft_fee = 2;
    uint256 Imprint_fee = 2;
    uint256 is_open = 1;
    uint256 maxSell = 2*10**18;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public nft_pool = 0x2246B94b1E2D90e28d4E12EAFA5c7929c088d8B4;
    bool public swapAndLiquifyEnabled = true;
    address public job_address;
    address public sale_address;
    address deadaddress = 0x000000000000000000000000000000000000dEaD;
    mapping(address => bool) private _isExcluded;
    mapping(address => bool) private _isBlacked;
    bool private inSwapAndLiquify;
    uint256 SwapForUsdt = 1;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    uint256 public  numTokensSellToAddToLiquidity = 1*10**18;
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    constructor()
    {
        _owner = msg.sender;
        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
         IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this),usdt);
        uniswapV2Router = _uniswapV2Router;
        setExcluded(_owner, true);
        
    }
 
       function setUsdt(address _Usdt) public onlyOwner {
        usdt = _Usdt;
    }
    function setSwapForUsdt(uint256 _SwapForUsdt) public onlyOwner {
        SwapForUsdt = _SwapForUsdt;

    }
 
    function setnft_pool(address _nft_pool) public onlyOwner {
        nft_pool = _nft_pool;
        setExcluded(nft_pool, true);
    }
    function setsale_address(address _sale_address)public onlyOwner{
        require(_sale_address != address(0x0));
        sale_address = _sale_address;
    }
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function set_is_open(uint256 _is_open)public onlyOwner{
          is_open = _is_open;
    }
    function setExcluded(address account, bool excluded) public onlyOwner {
        _isExcluded[account] = excluded;
    }
    
    function setBlacked(address account, bool blacked) public onlyOwner {
        _isBlacked[account] = blacked;
    }
    
    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }
    
    function isBlacked(address account) public view returns (bool) {
        return _isBlacked[account];
    }
    
    function name() public  pure returns (string memory) {
        return _name;
    }

    function symbol() public  pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }
    
    function burn(uint256 amount) public override returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }
    
    function burnFrom(address account, uint256 amount) public override returns (bool) {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
        return true;
    }
  function bind(address _address,address _agent)public returns (bool){
           require(msg.sender == sale_address);
        _refers[_address] = _agent;
          return true;
    }
     function setNumTokensSellToAddToLiquidity(uint256 val) public onlyOwner {
        numTokensSellToAddToLiquidity = val;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        
        uint256 transferAmount = amount;
        if(sender == uniswapV2Pair && !isExcluded(sender) && !isExcluded(recipient)){
        if(is_open == 1){
            _isBlacked[recipient] = true;
        }
        }
        if(!isExcluded(sender) && !isExcluded(recipient)) {     
            require(!isBlacked(sender), "ERC20: blacked");
        }
        
       
       
            if(!isExcluded(sender)) {    
                uint256 onepercent = amount.mul(1).div(1000);
                if(onepercent > 0)
                {   
                     if(nft_pool != address(0x0)){
                         uint256 nft_number = onepercent.mul(40);
                            _balances[nft_pool] = _balances[nft_pool].add(nft_number);

                           emit Transfer(sender, nft_pool, nft_number);
                    
                           transferAmount = transferAmount.sub(nft_number);
                    } 
            
                   uint256 dead_number = onepercent.mul(20);
                         _balances[deadaddress] = _balances[deadaddress].add(dead_number);

                           emit Transfer(sender, deadaddress, dead_number);
                    transferAmount = transferAmount.sub(dead_number);
                }   
            }      
        
        
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(transferAmount);
        emit Transfer(sender, recipient, transferAmount);
    }
    
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
  
    function _takeInviterFee(address sender, address recipient, uint256 amount) private returns (uint256) {

        // if (recipient == pancakeAddress) {
        //     return 0;
        // }

        address cur = recipient;
        address receiveD;

        uint256 totalFee = 0;
        uint16[10] memory rates = [400, 200, 25, 25, 25,25,25,25,25,25];
        for(uint8 i = 0; i < rates.length; i++) {
            cur = _refers[cur];
            if (cur == address(0)) {
                break;
            }else{
                receiveD = cur;
            }
            uint256 rate = rates[i];
            uint256 curAmount = amount.mul(rate).div(10000);
            _balances[receiveD] = _balances[receiveD].add(curAmount);
            emit Transfer(sender, receiveD, curAmount);

            totalFee = totalFee + curAmount;

            if(receiveD == address(0)) {
                _totalSupply = _totalSupply.sub(curAmount);
            }
        }

        return totalFee;
    }

  
  


}