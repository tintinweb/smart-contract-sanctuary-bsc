/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.3;
interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
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
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
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
contract BirdCrypto {
    using SafeMath for uint256;
    IBEP20 public rewardContract;
    uint256 public totalSupply = 1000000000 ether; //1b
    string public name = "Bird Crypto";
    string public symbol = "BIRD";
    uint8 public decimals = 18;
    address public owner;
    uint256 public cap = 0;
    uint256 public saleMin = 0.001 ether;
    uint256 public salePrice = 25000; //1BNB = 25,000 BIRD
    bool public startSale = true;
    bool public locked = true;
    uint256 public _refRate = 10; //10%
    
    mapping (address => uint256) private _balances;   
    mapping (address => mapping (address => uint256)) private _allowances;

    ////////////////////////////////////////////////    
    mapping(address => bool) _isFeeExempt;
    uint256 public liquidityFee = 5; //5%
    uint256 public treasuryFee = 5; //5%
    uint256 public totalFee = liquidityFee.add(treasuryFee);
    uint256 public feeDenominator = 100;
    address public autoLiquidityReceiver;
    address public treasuryReceiver;
    address public pair;
    IPancakeSwapRouter public router;
    
    bool public inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }
    bool public _autoAddLiquidity = true;
    uint256 public _lastAddLiquidityTime;

    mapping(address => bool) public blacklist;
    mapping(address => bool) public whitelist;
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        _isFeeExempt[owner] = true;
        whitelist[owner] = true;
        
        // _setRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);      //pancake v2
        autoLiquidityReceiver = 0x092fE0eFeE0C0E20C485852f43dBDB00104Cb66e;
        treasuryReceiver = 0xC16e55d06aC7aCe4A2a4BC6087eB4dAb6bfBf86B;               
        _isFeeExempt[treasuryReceiver] = true;
        whitelist[treasuryReceiver] = true;    

        _isFeeExempt[address(this)] = true;
        whitelist[address(this)] = true;
        //todo: change it to ingame contract address
        rewardContract = IBEP20(address(this));
        
        _mint(owner, totalSupply.div(20));   
    }

    function _setRouter(address _router) private  {
        router = IPancakeSwapRouter(_router);
        _allowances[address(this)][address(router)] = type(uint128).max;
        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        whitelist[pair] = true;
        _isFeeExempt[pair] = true;
    }

    function setRouter(address _router) public onlyOwner {
        _setRouter(_router);
    }

    fallback() external {}
    receive() payable external {}

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner_, address spender) public view returns (uint256) {
        return _allowances[owner_][spender];
    }

    function transferOwnership(address newOwner) public onlyOwner{
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        owner = newOwner;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        require(cap.add(amount) <= totalSupply, "ERC20: mint to the zero address");
        cap = cap.add(amount);        
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(this), account, amount);
    }

    function _approve(address owner_, address spender, uint256 amount) internal {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function clear() public onlyOwner {        
        payable(msg.sender).transfer(address(this).balance);
    }

    
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function shouldAddLiquidity() internal view returns (bool) {
        return
            _autoAddLiquidity && 
            !inSwap && 
            msg.sender != pair &&
            msg.sender != address(this) &&
            block.timestamp >= (_lastAddLiquidityTime + 2 days);
    }
    function shouldTakeFee(address from, address to) internal  view returns (bool){
        return 
            pair == to && !_isFeeExempt[from];
    }
    function _transfer(address sender, address recipient, uint256 amount) internal {       
        require(!blacklist[sender], "in_blacklist");       
        require(!locked || whitelist[sender], "in_locked"); 
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");

        if (inSwap) {
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
            return;
        }        
        if (shouldAddLiquidity()) {
            addLiquidity();
        }
        if (shouldSwapBack()) {
            swapBack();
        }
        
        uint256 amountReceived = shouldTakeFee(sender, recipient)? takeFee(sender, amount): amount;        
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amountReceived);        
        emit Transfer(sender, recipient, amountReceived);
    }
    function buyToken(address _refer) payable public returns(bool){        
        require(msg.value >= saleMin,"The amount is too small");
        require(startSale,"End of sale");
        uint256 _msgValue = msg.value;
        uint256 _token = _msgValue.mul(salePrice);        
        payable(address(this)).transfer(_msgValue);       
        _transfer(address(this), msg.sender, _token); 
        if(_refRate > 0 && msg.sender != _refer){                        
            uint256 _refToken = _token.mul(_refRate).div(100);
            rewardContract.transfer(_refer, _refToken);
            // _transfer(address(this), _refer, _refToken);                 
        }        
        return true;
    }
    function takeFee(
        address sender,
        uint256 amount
    ) internal  returns (uint256) {        
        uint256 feeAmount = amount.div(feeDenominator).mul(totalFee);

        uint256 treasuryFeeAmount = amount.div(feeDenominator).mul(treasuryFee); 
        _balances[address(this)] = _balances[address(this)].add(treasuryFeeAmount);
        emit Transfer(sender, address(this), treasuryFeeAmount);

        uint256 liquidityFeeAmount = amount.div(feeDenominator).mul(liquidityFee); 
        _balances[autoLiquidityReceiver] = _balances[autoLiquidityReceiver].add(liquidityFeeAmount);
        emit Transfer(sender, autoLiquidityReceiver, liquidityFeeAmount);
        
        return amount.sub(feeAmount);
    }
    function addLiquidity() internal swapping {
        uint256 autoLiquidityAmount = _balances[autoLiquidityReceiver];
        _balances[address(this)] = _balances[address(this)].add(
            _balances[autoLiquidityReceiver]
        );
        _balances[autoLiquidityReceiver] = 0;
        uint256 amountToLiquify = autoLiquidityAmount.div(2);
        uint256 amountToSwap = autoLiquidityAmount.sub(amountToLiquify);

        if( amountToSwap == 0 ) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint256 balanceBefore = address(this).balance;


        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHLiquidity = address(this).balance.sub(balanceBefore);

        if (amountToLiquify > 0 && amountETHLiquidity > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
        }
        _lastAddLiquidityTime = block.timestamp;
    }
    function swapBack() internal swapping {

        uint256 amountToSwap = _balances[address(this)];

        if( amountToSwap == 0) {
            return;
        }

        uint256 balanceBefore = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHToTreasuryAndIF = address(this).balance.sub(
            balanceBefore
        );

        (bool success, ) = payable(treasuryReceiver).call{
            value: amountETHToTreasuryAndIF.mul(treasuryFee).div(treasuryFee),
            gas: 30000
        }("");
       
    }
    function withdrawAllToTreasury() external swapping onlyOwner {

        uint256 amountToSwap = _balances[address(this)];
        require( amountToSwap > 0,"There is no token deposited in token contract");
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            treasuryReceiver,
            block.timestamp
        );
    }
    function shouldSwapBack() internal view returns (bool) {
        return 
            !inSwap &&
            msg.sender != pair  ; 
    }
    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }
    function manualSync() external {
        IPancakeSwapPair(pair).sync();
    }
    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _treasuryReceiver
    ) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        treasuryReceiver = _treasuryReceiver;
    }
    function setFeeExempt(address _addr, bool _flag) external onlyOwner {
        _isFeeExempt[_addr] = _flag;
    }   
    function setWhitelist(address _addr, bool _flag) external onlyOwner {
        whitelist[_addr] = _flag;
    }
    function setBlacklist(address _botAddress, bool _flag) external onlyOwner {        
        blacklist[_botAddress] = _flag;    
    }
    function update(uint256 tag, uint256 value)public onlyOwner returns(bool){        
        if(tag==1){
            startSale = (value == 1);
        }else if(tag==2){
            saleMin = value;
        }else if(tag==3){
            _mint(msg.sender, value);              
        }else if(tag==4){
            _refRate = value;
        }else if(tag==5){           
            _autoAddLiquidity = (value == 1);
        }else if(tag==6){
           locked = (value == 1);
        }
        return true;
    }
}