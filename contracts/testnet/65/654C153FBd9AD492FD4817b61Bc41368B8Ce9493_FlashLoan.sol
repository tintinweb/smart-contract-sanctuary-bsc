// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.7;

interface IUniswapV2Router {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
}

interface IUniswapV2Pair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IUniswapV2Factory {
  function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IERC3156FlashBorrower {
    /**
     * @dev Receive a flash loan.
     * @param initiator The initiator of the loan.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @param fee The additional amount of tokens to repay.
     * @param data Arbitrary data structure, intended to contain user-defined parameters.
     * @return The keccak256 hash of "ERC3156FlashBorrower.onFlashLoan"
     */
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}

interface IERC3156FlashLender {
   function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

contract FlashLoan {
    uint256 MAX_INT =
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    address public owner;
    uint256 public repayFee = 50000000000000000; // 0.05% equalizer flash loan provider repay fee

    event TransferOwnership(address indexed _owner);

    constructor() {
        owner = msg.sender;
    }

    function check(
        address _tokenBorrow, // example: BUSD
        uint256 _amountTokenPay, // example: BNB => 10 * 1e18
        address _tokenPay, // example: BNB
        address _sourceRouter,
        address _targetRouter
    ) public view returns (int256, uint256) {
        address[] memory path1 = new address[](2);
        address[] memory path2 = new address[](2);
        path1[0] = path2[1] = _tokenPay;
        path1[1] = path2[0] = _tokenBorrow;

        uint256 amountOut = IUniswapV2Router(_sourceRouter).getAmountsOut(
            _amountTokenPay,
            path1
        )[1];
        uint256 amountRepay = IUniswapV2Router(_targetRouter).getAmountsOut(
            amountOut,
            path2
        )[1];

        return (
            int256(amountRepay - _amountTokenPay - repayFee) , // our profit or loss; example output: BNB amount
            amountOut // the amount we get from our input "_amountTokenPay"; example: BUSD amount
        );
    }

    function initiateFlashloan(
      address flashloanProviderAddress, 
      address token, 
      uint amount, 
      bytes calldata data
    ) external {
    require(msg.sender == owner, "Owner Only");
      IERC3156FlashLender(flashloanProviderAddress).flashLoan(
        IERC3156FlashBorrower(address(this)),
        token,
        amount,
        data
      );
    }

    // @dev ERC-3156 Flash loan callback
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        (address outputToken, address sourceRouter, address targetRouter) = getEncodedDatas(data);
        (int256 profit,) = check(outputToken, amount, token, sourceRouter, targetRouter);
        require(profit > 0, 'e01');
        
        // Set the allowance to payback the flash loan
        IERC20(token).approve(msg.sender, MAX_INT);
        // Build your trading business logic here
        // e.g., sell on uniswapv2
        // e.g., buy on uniswapv3

        executeTrade(address(this), token, amount, data);

        // Return success to the lender, he will transfer get the funds back dataif allowance is set accordingly
        return keccak256('ERC3156FlashBorrower.onFlashLoan');
    }

    function executeTrade(address _sender, address _bnbAddress, uint256 _bnbAmount, bytes calldata _data) internal {
        (address outputToken, address sourceRouter, address targetRouter) = getEncodedDatas(_data);
        require(sourceRouter != address(0) && targetRouter != address(0), 'e12');

        address[] memory path0 = new address[](2);
        address[] memory path1 = new address[](2);

        path0[0] = path1[1] = _bnbAddress;
        path0[1] = path1[0] = outputToken;
        
        // swap bnb to get tokens from source router
        uint256 amountReceivedFromSourceDex = IUniswapV2Router(sourceRouter).swapExactTokensForTokens(
            _bnbAmount,
            0, 
            path0,
            address(this), // its a foreign call; from router but we need contract address also equal to "_sender"
            block.timestamp + 60
        )[1];

        // IERC20 token that we will sell for otherToken
        IERC20 token = IERC20(outputToken);
        token.approve(targetRouter, amountReceivedFromSourceDex);

        // swap output token from the source router into targer router to get bnb
        uint256 amountReceivedFromDestinationDex = IUniswapV2Router(targetRouter).swapExactTokensForTokens(
            amountReceivedFromSourceDex,
            0,
            path1,
            address(this), // its a foreign call; from router but we need contract address also equal to "_sender"
            block.timestamp + 60
        )[1];

        // fail if we didn't get enough tokens
        require(amountReceivedFromDestinationDex > _bnbAmount, 'e13');
        IERC20 otherToken = IERC20(_bnbAddress);

        otherToken.transfer(msg.sender, amountReceivedFromDestinationDex); // send back borrow
    }

    function transferOwnership(address _address) external {
        require(_address != address(0), "Address can't be zero address");
        require(msg.sender == owner, "Owner Only");
        owner = _address;
        emit TransferOwnership(_address);
    }

    function getEncodedDatas(bytes calldata data) public view returns (address, address, address) {
       (address outputToken, address sourceRouter, address targetRouter) = abi.decode(data, (address, address, address));
       return(outputToken, sourceRouter, targetRouter);
    } 

    function withdrawBNBFromContract() external {
        require(msg.sender == owner, "Owner Only");
         address payable _owner = payable(msg.sender);        
        _owner.transfer(address(this).balance);        
    }

}