/**
 *Submitted for verification at BscScan.com on 2023-01-23
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    function balanceOf(address owner) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);
}

library SafeMath {
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
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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


    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

  
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
}


interface IPancakeRouter02 is IPancakeRouter01 {

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IPancakePair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
        
}

library PancakeLibrary {
    using SafeMath for uint256;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "PancakeLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "PancakeLibrary: ZERO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IPancakePair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

}

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

contract mySwapContract {
    using SafeMath for uint256;

    address public immutable  factory;
    address public immutable  WETH;
    //address internal constant UNISWAP_ROUTER_ADDRESS = 0x10ed43c718714eb63d5aa57b78b54704e256024e;
    //address internal constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    //0xca143ce32fe78f1f7019d7d551a6402fc5350c73 
    IPancakeRouter02 public uniswapRouter;
    address private _owner;
    mapping(address => bool) addressAuthorized;
    mapping(address => bool) tokenApprovedUniswap;

    event AuthorizedAccessToAddress(address indexed myaddress, bool value);

    function isTokenApproved(address token)
        public
        view
        returns (bool)
    {
        return tokenApprovedUniswap[token];
    }

    function isAddressAuthorized(address myaddress) public view returns (bool) {
        return addressAuthorized[myaddress];
    }

    constructor(address _factory, address _WETH, address _router) public {
        uniswapRouter = IPancakeRouter02(_router);
        factory = _factory;
        WETH = _WETH;
        IERC20(_WETH).approve(
            address(uniswapRouter),
            type(uint256).max
        );
        tokenApprovedUniswap[_WETH] = true;
        _owner = msg.sender;
        addressAuthorized[msg.sender] = true;
        addressAuthorized[address(this)] = true;
    }

    function setAddressAllowance(address myaddress, bool value) external {
        require(msg.sender == _owner, "only owner can set address allowance");
        addressAuthorized[myaddress] = value;
        emit AuthorizedAccessToAddress(myaddress, value);
    }

    function approve(address token, address address_router) private {
        require(
            addressAuthorized[msg.sender] == true,
            "msg.sender not authorized to approve"
        );
        IERC20(token).approve(
            address_router,
            type(uint256).max
        );
        tokenApprovedUniswap[token] = true;
        
    }

    function swapEtherForWETH(uint256 amount) external {
        require(
            addressAuthorized[msg.sender] == true,
            "msg.sender not authorized to swapEtherForWETH"
        );
        IWETH(WETH).deposit{value: amount}();
    }

    function swapAllTokensForWETH(
        address token,
        uint256 deadline
    ) external  {
        require(
            addressAuthorized[msg.sender] == true,
            "msg.sender not authorized to swapAllTokensForWETH"
        );
        uint256 amountIn = IERC20(token).balanceOf(address(this));
        require(amountIn > 0, "no balance for this token");
        if (!tokenApprovedUniswap[token])
            approve(token, address(uniswapRouter));
        uint256[] memory amountOutMin = uniswapRouter.getAmountsOut(
            amountIn,
            getPathForTokentoWETH(token)
        );
        uniswapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn,
            amountOutMin[amountOutMin.length - 1],
            getPathForTokentoWETH(token),
            address(this),
            deadline
        );
    }

    function frontrunExactTokens(
        uint256 desiredWETHamount,
        address token,
        uint256 deadline
    ) external{
        require(
            addressAuthorized[msg.sender] == true,
            "msg.sender not authorized to frontrunExactTokens"
        );
        uint256 reserveWETH = 0;
        uint256 reserveToken = 0;
        (reserveWETH, reserveToken) = PancakeLibrary.getReserves(
            factory,
            WETH,
            token
        );
        
        
        require(reserveWETH > 0, "reserve WETH empty");
        require(reserveToken > 0, "reserve TOKEN empty");
        require(reserveWETH > desiredWETHamount, "reserve WETH is not enough");
     
        uint256 WETH_balance = IERC20(WETH).balanceOf(
            address(this)
        );
        require(WETH_balance > 0, "No WETH balance");
        uint256 maxWETHPossible = WETH_balance < desiredWETHamount
            ? WETH_balance
            : desiredWETHamount;
      
        uint256 exactTokenOut = uniswapRouter.getAmountOut(
            maxWETHPossible,
            reserveWETH,
            reserveToken
        );
        
        uniswapRouter.swapTokensForExactTokens(
            exactTokenOut,
            maxWETHPossible,
            getPathForWETHtoToken(token),
            address(this),
            deadline
        );
    }

    function getPathForWETHtoToken(address token)
        private
        view
        returns (address[] memory)
    {
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = token;
        return path;
    }
    
 
    function getWethAddress() external view returns(address x){
        
        return   WETH;
    }

  function getBalance() external view returns(uint256){
        
        
            uint256 WETH_balance = IERC20(WETH).balanceOf(
            address(this)
        );
    return    WETH_balance;
    }


    
    function subTest(address token,uint256 reserveWETHTarget) external view   returns (   uint256 x  ) {
        
        uint256 reserveWETH = 0;
        uint256 reserveToken = 0;
        (reserveWETH, reserveToken) = PancakeLibrary.getReserves(
            factory,
            WETH,
            token
        );

        
        
       uint256 desiredWETHamount = reserveWETHTarget.sub(
            reserveWETH
        );
        
        return desiredWETHamount;
    }

 

    function getPathForTokentoWETH(address token)
        private
        view
        returns (address[] memory)
    {
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = WETH;
        return path;
    }

    function retrieveWei(uint256 amount) external {
        require(
            addressAuthorized[msg.sender] == true,
            "msg.sender not authorized to retrieveWei"
        );
        msg.sender.transfer(amount);
    }

    function retrieveAllWETH() external {
        require(
            addressAuthorized[msg.sender] == true,
            "msg.sender not authorized to retrieveAllWETH"
        );
        IERC20(WETH).transfer(
            msg.sender,
            IERC20(WETH).balanceOf(address(this))
        );
    }

    function retrieveToken(uint256 amount, address token) external {
        require(
            addressAuthorized[msg.sender] == true,
            "msg.sender not authorized to retrieveToken"
        );
        IERC20(token).transfer(msg.sender, amount);
    }

    // this function is used for checking if a token has a transfer fee on buy and/or sell actions
    // swapExactTokensForTokensSupportingFeeOnTransferTokens with 0% slippage will fail for tokens that have unexpected transfer fees
    // We check for WETH --> TOKEN, and then back from TOKEN --> WETH
    function checkTransferFee(
        address token,
        uint256 deadline,
        address router_address
    ) external {
        require(
            addressAuthorized[msg.sender] == true,
            "msg.sender not authorized to checkTransferFee"
        );
        approve(token, router_address);
        // input 0.1 ether
        // get exact output of token
        uint256[] memory amountTokenOutMin = uniswapRouter.getAmountsOut(
            1e17,
            getPathForWETHtoToken(token)
        );
        // if this fails then there is a transfer fee on buy action
        uniswapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            1e17,
            amountTokenOutMin[amountTokenOutMin.length - 1],
            getPathForWETHtoToken(token),
            address(this),
            deadline
        );
        //
        // if this fails then there is a transfer fee on sell action

        uint256[] memory amountWETHOutMin = uniswapRouter.getAmountsOut(
            amountTokenOutMin[amountTokenOutMin.length - 1],
            getPathForTokentoWETH(token)
        );
        uniswapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountTokenOutMin[amountTokenOutMin.length - 1],
            amountWETHOutMin[amountWETHOutMin.length - 1],
            getPathForTokentoWETH(token),
            address(this),
            deadline
        );
    }

    // important to receive ETH
    receive() external payable {}
}