/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

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

interface AddLiquidityPool{
    function swapAndLiquify(uint256 tokenAmount)external;
}


contract Context {
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint;
    using Address for address;

    mapping (address => uint) public _balances;

    mapping (address => mapping (address => uint)) private _allowances;

    uint private _totalSupply;
    
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address private _owner;

    IUniswapV2Router02 public uniswapV2Router;

    address public  uniswapV2Pair;
    
    uint256 public _sellFee = 5;
    
    uint256 private _previousSellFee = _sellFee;
    uint256 public _buyFee = 3;
    
    uint256 private _previousBuyFee = _buyFee;

    mapping (address => bool) public _isExcludedFromFee;

    address public addLiquidityPool=0xDfE15e321B24334bb673C544A232EC82e8e96696;
    address public beneficiary=0x39Ec4Ae11c0cAa510e5b92135aE76846C744ec20;

    struct Player {
        address[] directRecommendAddress;
        address referrer;
    }

    mapping(address => Player) public referralRelationships; 

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    uint256 private numTokensSellToAddToLiquidity = 1000*10**18;

    mapping(address=>bool) private isExcludedFromReferral;
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    constructor (string memory name, string memory symbol, uint8 decimals, uint totalSupply) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _totalSupply = totalSupply;
        _owner=msg.sender;
        

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), 0x55d398326f99059fF775485246999027B3197955);

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[beneficiary] = true;
        
        isExcludedFromReferral[owner()]=true;
        isExcludedFromReferral[address(this)]=true;
        isExcludedFromReferral[beneficiary]=true;
    }

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
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
     modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
     function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
    }

    function renounceOwnership() public virtual onlyOwner {
        _owner = address(0);
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
    function allowance(address _from, address _to) public view override returns (uint) {
        return _allowances[_from][_to];
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
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }
        _updateReferralRelationship(from,to);
        
        if(_isExcludedFromFee[from]||_isExcludedFromFee[to]||(from!=uniswapV2Pair&&to!=uniswapV2Pair)){
            removeAllFee();
        }
        uint256 taxDividends;
        if (from==uniswapV2Pair){
            taxDividends=calculateBuyFee(amount);
            _balances[address(0xdead)]=_balances[address(0xdead)].add(taxDividends);
            emit Transfer(from, address(0xdead), taxDividends);
            
        }

        if(to==uniswapV2Pair){
            taxDividends=calculateSellFee(amount);
            _balances[address(this)]=_balances[address(this)].add(taxDividends.mul(2).div(5));
            emit Transfer(from, address(this), taxDividends.mul(2).div(5));
            _balances[beneficiary]=_balances[beneficiary].add(taxDividends.div(5));
            emit Transfer(from, beneficiary, taxDividends.div(5));
            dividendsToReferrer(from,taxDividends.mul(2).div(5));
        }
            
        _balances[from] = _balances[from].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[to] = _balances[to].add(amount.sub(taxDividends));
        emit Transfer(from, to, amount.sub(taxDividends));
        if(_isExcludedFromFee[from]||_isExcludedFromFee[to]||(from!=uniswapV2Pair&&to!=uniswapV2Pair)){
            restoreAllFee();
        }
    }

    function excludeFromFee(address[] memory accounts) public onlyOwner {
        for(uint i=0;i<accounts.length;i++){
           _isExcludedFromFee[accounts[i]] = true;
        } 
    }
    function includeInFee(address[] memory accounts) public onlyOwner {
        for(uint i=0;i<accounts.length;i++){
           _isExcludedFromFee[accounts[i]] = false;
        } 
    }

    function _updateReferralRelationship(address from, address to) internal {

        if (address(from).isContract()||address(to).isContract()){
            return;
        }

        if(isExcludedFromReferral[from]||isExcludedFromReferral[to]){
           return;
        }

        if (from== to) { // referrer cannot be user himself/herself
          return;
        }

        if (referralRelationships[to].referrer != address(0)) { // referrer has been set
          return;
        }

        if (referralRelationships[from].referrer == to) { 
          return;
        }
        referralRelationships[to].referrer = from;
        referralRelationships[from].directRecommendAddress.push(to);
    }

    function getReferralRelationship(address user) public view returns(address){
        return referralRelationships[user].referrer;
    }

    function dividendsToReferrer(address from,uint256 Amount)private{
        uint8 i=1;
        address userAddress=from;
        while (true) {
            address referalAddress=referralRelationships[userAddress].referrer;
            if (i==3){
                break;
            }
            uint AmountDividend=getAmountDividend(Amount);
            if (referalAddress==address(0)){ 
                _balances[address(beneficiary)] = _balances[address(beneficiary)].add(AmountDividend);
                emit Transfer(from, address(beneficiary),AmountDividend);
            }else{
                _balances[referalAddress] = _balances[referalAddress].add(AmountDividend);
                emit Transfer(from, referalAddress,AmountDividend);
            }
            userAddress =referalAddress;
            i++;
        }
    }
    function getAmountDividend(uint256 amount)private pure returns(uint256){
        uint amountDividend=amount.div(2);
        return amountDividend;
    }

    function getDirectRecommendAddressList(address user)public view returns(address[] memory){
        return referralRelationships[user].directRecommendAddress;
    }


    function _approve(address _from, address _to, uint amount) internal {
        require(_from != address(0), "ERC20: approve from the zero address");
        require(_to != address(0), "ERC20: approve to the zero address");

        _allowances[_from][_to] = amount;
        emit Approval(_from,_to, amount);
    }
    
    function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
        _sellFee = taxFee;
    }
    function calculateBuyFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_buyFee).div(
            10**2
        );
    }
    function calculateSellFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_sellFee).div(
            10**2
        );
    }
    function removeAllFee() private {
        if(_sellFee == 0&&_buyFee==0) return;
        
        _previousSellFee = _sellFee;
        _previousBuyFee = _buyFee;
        
        _sellFee = 0;
        _buyFee = 0;
    }

    function restoreAllFee() private {
        _sellFee = _previousSellFee;
        _buyFee = _previousBuyFee;
    }

   function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap{
        AddLiquidityPool(addLiquidityPool).swapAndLiquify(contractTokenBalance);
    }

    function setNumTokensSellToAddToLiquidity(uint _amount) public onlyOwner{
        numTokensSellToAddToLiquidity=_amount;
    }

    function setAddLiquidityPool(address _addLiquidityPool)public onlyOwner{
        addLiquidityPool = _addLiquidityPool;
    }

    function setBeneficiary(address _beneficiary)public onlyOwner{
        beneficiary = _beneficiary;
    }
    
    function withdrawStuckTokens(address _token, uint256 _amount) public onlyOwner {
		IERC20(_token).transfer(msg.sender, _amount);
	}
	
	function withdrawStuckEth(address payable recipient) public onlyOwner {
		recipient.transfer(address(this).balance);
	}
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

contract HCBtoken is ERC20 {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint;
  
 
  constructor () public ERC20("HCB", "HCB", 18,100000000*10**18) {
       _balances[0xc090d9DF500e5AEe32a6FCDBd444691145a2AB86] = totalSupply();
        emit Transfer(address(0), 0xc090d9DF500e5AEe32a6FCDBd444691145a2AB86, totalSupply());
  }
}