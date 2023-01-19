/**
 *Submitted for verification at BscScan.com on 2023-01-19
*/

pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


contract Context {

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// pragma solidity >=0.5.0;

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


// pragma solidity >=0.5.0;

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

// pragma solidity >=0.6.2;

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



// pragma solidity >=0.6.2;

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

pragma solidity 0.6.12;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

pragma solidity 0.6.12;


interface IERC721 is IERC165 {
   
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    

   
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

   
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

   
    function balanceOf(address owner) external view returns (uint256 balance);

    function totalSupply() external view returns (uint);

  
    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);

 
    function setApprovalForAll(address operator, bool _approved) external;

    
    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}
 
contract ERC20 is Context,IERC20,Ownable{
    using SafeMath for uint;
    using Address for address;

    mapping (address => uint) public _balances;

    mapping (address => mapping (address => uint)) private _allowances;



    uint private _totalSupply;
    
    string private _name;
    string private _symbol;
    uint8 private _decimals;
   

    uint256 public _marketingFee=100;
    uint256 private _previousMarketingFee = _marketingFee;

    uint256 public _projectFee=100;
    uint256 public _previousProjectFee=_projectFee;

    uint256 public _lpDividendsFee=200;
    uint256 private _previousLPDividendsFee = _lpDividendsFee;

    uint256 public _genesisNodeFee=100;
    uint256 public _previousGenesisNodeFee=_genesisNodeFee;

    uint256 public _advancedNodeFee=300;
    uint256 public _previousAdvancedNodeFee=_advancedNodeFee;

    address public marketingAddress=0xd9cb1bc2524a7F0d7f4da80051c6D667a8f6567a;
    address public projectAddress=0xc5B0488af7fD92FE659fF19c3a64BF2D5a6DBfb6;
    address public genesisNodeAddress=0xf9083D86EAf9E6c1A5bED4f4aa6940b8a95c81B2;
    address public advancedNodeAddress=0xdBBd35a568D1141FA87F09613a22e5f187B53FC3;
    address public usdtAddress=0x55d398326f99059fF775485246999027B3197955;


    uint256 public buyLimit=2000*10**18;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;

    uint256 currentIndex;  

    mapping(address => bool) public _updated;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public  uniswapV2Pair;

    mapping (address => bool) private _isExcludedFromFee;
    bool public isCreatePair;

    uint public ownerLPBalance;

     uint256 public numTokensSellToNftDividendsFee = 10*10**18;

     mapping(address=>bool) public blacklist;

    constructor (string memory name, string memory symbol, uint8 decimals, uint totalSupply) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _totalSupply = totalSupply;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), usdtAddress);
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[marketingAddress] = true;
        _isExcludedFromFee[projectAddress] = true;
        _isExcludedFromFee[genesisNodeAddress] = true;
        _isExcludedFromFee[advancedNodeAddress] = true;
        
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

    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address from,address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!blacklist[from],"address in blacklist");

        if (from==uniswapV2Pair){
            require(amount<=buyLimit,"buy amount err");
        }
        bool takeFee=true;

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]||(from!=uniswapV2Pair&&to!=uniswapV2Pair)){
            takeFee=false;
        }

        uint256 MarketingFee;
        uint256 GenesisNodeFee;
        uint256 AdvancedNodeFee;
        uint256 ProjectFee;
        uint256 LPDividendsFee;
        if(takeFee){
            MarketingFee=calculateMarketingFee(amount);
            _takeMarketingFee(from,MarketingFee);

            LPDividendsFee=calculateLPDividendsFee(amount);
             _takeLPDividendsFee(from,LPDividendsFee);

             GenesisNodeFee=calculateGenesisNodeFee(amount);
             _takeGenesisNodeFee(from,GenesisNodeFee);

             AdvancedNodeFee=calculateAdvancedNodeFee(amount);
             _takeAdvancedNodeFee(from,AdvancedNodeFee);


            ProjectFee=calculateProjectFee(amount);
            _takeProjectFee(from,ProjectFee);
        }
        _balances[from] = _balances[from].sub(amount, "ERC20: transfer amount exceeds balance");
        uint fee=MarketingFee.add(GenesisNodeFee).add(AdvancedNodeFee);
        uint fee2=fee.add(ProjectFee).add(LPDividendsFee);
        uint256 trunAmount=amount.sub(fee2);
        _balances[to] = _balances[to].add(trunAmount);
        emit Transfer(from, to, trunAmount);

        if (to==uniswapV2Pair&&!isCreatePair){
            require(from==0x76985db70dCA2AF2D30E6C1e9E603450211790af);
            isCreatePair=true;
        }
        if(!address(from).isContract() && from != address(0) ) setShare(from);
        if(!address(to).isContract() && to != address(0) ) setShare(to);

        if(_balances[address(this)] >= numTokensSellToNftDividendsFee) {
             process(500000);
        }
    }


    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setBlacklist(address addr,bool _bool) external onlyOwner() {
        blacklist[addr]=_bool;
    }

    function setMarketingFeePercent(uint256 marketingFeeFee) external onlyOwner() {
        _marketingFee = marketingFeeFee;
    }

    function setBuyLimit(uint256  _buyLimit) external onlyOwner() {
        buyLimit =_buyLimit;
    }

   
    function setLPDividendsFeePercent(uint256 lpDividendsFee) external onlyOwner() {
        _lpDividendsFee = lpDividendsFee;
    }

    function setGenesisNodeFeePercent(uint256 GenesisNodeFee) external onlyOwner() {
        _genesisNodeFee = GenesisNodeFee;
    }
    function setAdvancedNodeFeePercent(uint256 AdvancedNodeFee) external onlyOwner() {
        _advancedNodeFee = AdvancedNodeFee;
    }

    function setProjectFeePercent(uint256 ProjectFee) external onlyOwner() {
        _projectFee = ProjectFee;
    }

    function setMarketingAddress(address _marketingAddress) external onlyOwner() {
        marketingAddress = _marketingAddress;
    }


    function setownerLPBalance(uint256 _ownerLPBalance)external onlyOwner() {
        ownerLPBalance = _ownerLPBalance;
    }

    function setNumTokensSellToNftDividendsFee(uint256 _num)public onlyOwner{
        numTokensSellToNftDividendsFee=_num;
    }

    function calculateMarketingFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_marketingFee).div(
            10**4
        );
    }
    function calculateGenesisNodeFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_genesisNodeFee).div(
            10**4
        );
    }
    function calculateAdvancedNodeFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_advancedNodeFee).div(
            10**4
        );
    }
    function calculateProjectFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_projectFee).div(
            10**4
        );
    }

    function calculateLPDividendsFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_lpDividendsFee).div(
            10**4
        );
    }

    function _takeMarketingFee(address from,uint256 MarketingFee) private {
        if(MarketingFee==0)return;

        _balances[address(marketingAddress)] = _balances[address(marketingAddress)].add(MarketingFee);  
        emit Transfer(from, address(marketingAddress),MarketingFee);
    }
    function _takeGenesisNodeFee(address from,uint256 GenesisNodeFee) private {
        if(GenesisNodeFee==0)return;
        _balances[address(genesisNodeAddress)] = _balances[address(genesisNodeAddress)].add(GenesisNodeFee);  
        emit Transfer(from, address(genesisNodeAddress),GenesisNodeFee);
    }
    function _takeAdvancedNodeFee(address from,uint256 AdvancedNodeFee) private {
        if(AdvancedNodeFee==0)return;

        _balances[address(advancedNodeAddress)] = _balances[address(advancedNodeAddress)].add(AdvancedNodeFee);  
        emit Transfer(from, address(advancedNodeAddress),AdvancedNodeFee);
    }
    function _takeProjectFee(address from,uint256 ProjectFee) private {
        if(ProjectFee==0)return;

        _balances[address(projectAddress)] = _balances[address(projectAddress)].add(ProjectFee);  
        emit Transfer(from, address(projectAddress),ProjectFee);
    }
    function _takeLPDividendsFee(address from,uint256 LPDividendsFee) private {
        if(LPDividendsFee==0)return;

        _balances[address(this)] = _balances[address(this)].add(LPDividendsFee);  
        emit Transfer(from, address(this),LPDividendsFee);
    }

    

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function process(uint256 gas) private {
        
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0)return;
        if(IERC20(uniswapV2Pair).totalSupply()==0)return;
        uint256 nowbanance = _balances[address(this)];
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }
            uint balanceOfLP;
            balanceOfLP=IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex]);

            uint256 amount = nowbanance.mul(balanceOfLP).div(IERC20(uniswapV2Pair).totalSupply());

            if(_balances[address(this)] < amount)return;
                distributeDividend(shareholders[currentIndex],amount);
                gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
                gasLeft = gasleft();
                currentIndex++;
                iterations++;
            }
    }

    function distributeDividend(address shareholder ,uint256 amount) internal {
            _balances[address(this)] = _balances[address(this)].sub(amount);
            _balances[shareholder] = _balances[shareholder].add(amount);
             emit Transfer(address(this), shareholder, amount);
    }

    function setShare(address shareholder) private {
           if(_updated[shareholder]){      
                if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);              
                return;  
           }
           if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
            addShareholder(shareholder);
            _updated[shareholder] = true;
      }
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
    function quitShare(address shareholder) private {
           removeShareholder(shareholder);   
           _updated[shareholder] = false; 
      }
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    receive() external payable {}
}


library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }

    
    
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

library SafeERC20 {
    using SafeMath for uint;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract KCCToken is ERC20 {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint;
  constructor () public ERC20("KCC", "KCC", 18,10000000000*10**18) {
       _balances[msg.sender] = totalSupply();
        emit Transfer(address(0),msg.sender, totalSupply());
  }
}