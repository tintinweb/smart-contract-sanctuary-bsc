pragma solidity >= 0.5.17;

import "./math.sol";
import "./IERC20.sol";

library useDecimal{
    using uintTool for uint;

    function m278(uint n) internal pure returns(uint){
        return n.mul(278)/1000;
    }
}

library Address {
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
}

interface ISwap{
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

    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
	external
	returns (uint[] memory amounts);

    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
	external
	returns (uint[] memory amounts);
	
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline)
	external
	payable
	returns (uint amountToken, uint amountETH, uint liquidity);
	
	function getPair(address tokenA, address tokenB) external view returns (address pair);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
	
	function factory() external view returns (address);
}

contract FPLiquidityReserved is math{
    using Address for address;

    function() external payable{}
	address manager;
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
	address _DEXAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;    //DEX Router
	address _TokenAddr = 0x5F1D2cfDEB097B83eD2f35Cf3E827DE2b700F05a;  //MTC
	address _ETHAddr = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;    //Wrapped Mainnet token (WETH/WBNB/WHT)
	address _LPsAddr = 0xe8260E271d5c684868E84BF288faE7f07Ae3fC34;    //LPs
	address _FPDAOAddr;
	uint BurnRate = 10;

    constructor() public {
        manager = msg.sender;
    }

    modifier onlyManager{
        require(msg.sender == manager, "Not manager");
        _;
    }

    modifier onlyDAO{
        require(msg.sender == manager || msg.sender == _FPDAOAddr, "Not Freeport DAO.");
        _;
    }

    function changeManager(address _new_manager) public onlyManager{
        require(msg.sender == manager, "Not Manager");
        manager = _new_manager;
    }

    function withdraw() external onlyManager{
        (msg.sender).transfer(address(this).balance);
    }

    function withdrawTokens(address tokenAddr) external onlyManager{
        uint _thisTokenBalance = IERC20(tokenAddr).balanceOf(address(this));
        require(IERC20(tokenAddr).transfer(msg.sender, _thisTokenBalance));
    }
	
    //----------------All address----------------------------
	function setBurnRate(uint sBurnRate) public onlyDAO{
        require(sBurnRate >= 0 && sBurnRate <= 50, "BurnRate error.");
        BurnRate = sBurnRate;
    }
	
	function DEXAddr() public view returns(address){
        require(_DEXAddr != address(0), "It's a null address");
        return _DEXAddr;
    }

	function ETHAddr() public view returns(address){
        require(_ETHAddr != address(0), "It's a null address");
        return _ETHAddr;
    }

	function TokenAddr() public view returns(address){
        require(_TokenAddr != address(0), "It's a null address");
        return _TokenAddr;
    }

	function LPsAddr() public view returns(address){
        require(_LPsAddr != address(0), "It's a null address");
        return _LPsAddr;
    }

	function setAllAddr(address sDEXAddr, address sETHAddr, address sTokenAddr, address sLPsAddr) public onlyManager{
        _DEXAddr = sDEXAddr;
        _ETHAddr = sETHAddr;
        _TokenAddr = sTokenAddr;
        _LPsAddr = sLPsAddr;
		approveForDEX();
    }

    //---------------------------------------------------------------------------------
	//--Execute Liquidity reserve--//
    function ExecuteLiquidityReserve(uint256 _addAmounts) public onlyManager returns(bool){
        require(_addAmounts <= address(this).balance, "ETH Amounts error.");

		uint256 _amountBurn = _addAmounts.mul(BurnRate).div(100);
		uint256 _amountAddLiquidity = _addAmounts.sub(_amountBurn);
        addLiquidityLR(_amountAddLiquidity);
        swapExactETHnBurnLR(_amountBurn);
		return true;
    }

	//--Add Liquidity to Lps contract--//
    function addLiquidityLR(uint256 _addAmounts) private returns(bool){
		uint256 _addLpsTokenneed = inqLpsPrice().mul(_addAmounts);
		require(_addLpsTokenneed <= IERC20(TokenAddr()).balanceOf(address(this)), "Not enough tokens.");
		uint256 _amountTokenMin = _addLpsTokenneed.mul(99).div(100);
		uint256 _amountETHMin = _addAmounts.mul(99).div(100);
		
		ISwap(DEXAddr()).addLiquidityETH.value( _addAmounts)(
			TokenAddr(),
			_addLpsTokenneed,
			_amountTokenMin,
			_amountETHMin,
			address(this),
			now.add(1800)
		);
		return true;
    }

	//--Swap Exact ETH to token--//
    function swapExactETHnBurnLR(uint256 _tradeAmount) private returns(bool){
		uint _tokenAmountsOut = inqETHToTokenAmountsOut(_tradeAmount);
		address[] memory pathtokenIn = new address[](2);
		pathtokenIn[0] = ETHAddr();
		pathtokenIn[1] = TokenAddr();
		uint amountOutMin = _tokenAmountsOut.div(2);
		uint TraderResult = 0;

		uint[] memory TradeOut = ISwap(DEXAddr()).swapExactETHForTokens.value( _tradeAmount)(
            amountOutMin,
            pathtokenIn,
            address(this),
            now.add(1800)
		);
		TraderResult = TradeOut[TradeOut.length - 1];
 		require(IERC20(TokenAddr()).transfer(BURN_ADDRESS, TraderResult));
    }





	//--Add Liquidity to Lps contract--//
    function addLiquidity(uint256 _addAmounts) public onlyManager returns(bool){
		uint256 _addLpsTokenneed = inqLpsPrice().mul(_addAmounts);
		require(_addLpsTokenneed <= IERC20(TokenAddr()).balanceOf(address(this)), "Not enough tokens.");
		uint256 _amountTokenMin = _addLpsTokenneed.mul(99).div(100);
		uint256 _amountETHMin = _addAmounts.mul(99).div(100);
		
		ISwap(DEXAddr()).addLiquidityETH.value( _addAmounts)(
			TokenAddr(),
			_addLpsTokenneed,
			_amountTokenMin,
			_amountETHMin,
			address(this),
			now.add(1800)
		);
		return true;
    }

	//--Swap Exact ETH to token--//
    function swapExactETHnBurn(uint256 _tradeAmount) public onlyManager returns(bool){
		uint _tokenAmountsOut = inqETHToTokenAmountsOut(_tradeAmount);
		address[] memory pathtokenIn = new address[](2);
		pathtokenIn[0] = ETHAddr();
		pathtokenIn[1] = TokenAddr();
		uint amountOutMin = _tokenAmountsOut.div(2);
		uint TraderResult = 0;

		uint[] memory TradeOut = ISwap(DEXAddr()).swapExactETHForTokens.value( _tradeAmount)(
            amountOutMin,
            pathtokenIn,
            address(this),
            now.add(1800)
		);
		TraderResult = TradeOut[TradeOut.length - 1];
 		require(IERC20(TokenAddr()).transfer(BURN_ADDRESS, TraderResult));
    }

	//--Calculate Exact ETH amounts in a DEX token amounts out--//
    function inqETHToTokenAmountsOut(uint amountsInETH) public view returns(
        uint amountsOutToken){

        address[] memory path = new address[](2);
		path[0] = ETHAddr();
		path[1] = TokenAddr();
		uint[] memory _amountsOutToken = new uint[](2);
		_amountsOutToken = ISwap(DEXAddr()).getAmountsOut(amountsInETH, path);
        return _amountsOutToken[1];
    }

	//--Check Lps token Price--//
    function inqLpsPrice() public view returns(
        uint256 Amounts){
		uint256 _balanceETH = IERC20(ETHAddr()).balanceOf(LPsAddr());
		uint256 _balanceToken = IERC20(TokenAddr()).balanceOf(LPsAddr());
		uint256 _Amounts1ETH = _balanceToken.div(_balanceETH);
		
        return _Amounts1ETH;
    }

	//--Manager only--//
    function approveForDEX() public onlyManager{
        IERC20(ETHAddr()).approve(DEXAddr(), 1000000000000000000*10**18);
        IERC20(TokenAddr()).approve(DEXAddr(), 1000000000000000000*10**18);
        IERC20(LPsAddr()).approve(DEXAddr(), 1000000000000000000*10**18);
    }
	
	//--Manager only--//
    function BurnLps() public onlyManager{
		uint256 _burnAmounts = IERC20(LPsAddr()).balanceOf(address(this));
        require(IERC20(LPsAddr()).transfer(BURN_ADDRESS, _burnAmounts));
    }
}