// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
}

interface IUSD {
    function owner() external view returns (address);

    function burn(address account, uint256 amount) external;

    function mint(address to, uint256 amount) external;
}

interface IUniswapRouter {
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

library TransferHelper {
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }
}

interface IMinterUSD {
    function mintTo(
        address _sender,
        address _account,
        uint256 tokenAmount
    ) external returns (uint256 usdAmount);

    function burnTo(
        address _sender,
        address _account,
        uint256 usdAmount
    ) external returns (uint256 tokenAmount);
}

contract mintRouter {
    address public immutable usdTokenAddress; // usd token address
    address public immutable tokenAddress; // token
    address public mintUsdAddress; // usd token address

    mapping(address => bool) public swapTokens; // 支持兑换的token
    mapping(address => address) public swapTokenForRouters; // 兑换token的router

    constructor(
        address token_,
        address usd_,
        address mintAddr
    ) {
        usdTokenAddress = usd_;
        tokenAddress = token_;
        mintUsdAddress = mintAddr;
        safeApprove(tokenAddress, mintUsdAddress, ~uint256(0));
    }

    modifier onlyOwner() {
        require(
            msg.sender == IUSD(usdTokenAddress).owner(),
            "caller is not the owner"
        );
        _;
    }

    function setMintUsdAddress(address addr) external onlyOwner {
        mintUsdAddress = addr;
        safeApprove(tokenAddress, mintUsdAddress, ~uint256(0));
    }

    //设置第三方交换代币, 设置开启后需调用approveSwap进行授权
    function setSwapTokens(address _token, address _router) external onlyOwner {
        require(
            isContract(_router) && isContract(_token),
            "router and token must be contract"
        );

        swapTokens[_token] = !swapTokens[_token];
        swapTokenForRouters[_token] = _router;
    }

    function approveSwap(
        address _token,
        address _router,
        uint256 _value
    ) external onlyOwner {
        safeApprove(_token, _router, _value);
    }

    function mintUsd(address _token, uint256 tokenAmount) external {
        require(
            (!isContract(msg.sender)) && (msg.sender == tx.origin),
            "contract not allowed"
        );
        uint256 amount = _swapTokenAmount(_token, tokenAmount);
        require(amount > 0, "amount error");
        IMinterUSD(mintUsdAddress).mintTo(address(this), msg.sender, amount);
    }

    // usd=>token
    function burnUsd(address _token, uint256 usdAmount) external {
        require(
            (!isContract(msg.sender)) && (msg.sender == tx.origin),
            "contract not allowed"
        );
        require(swapTokens[_token], "token not in swapTokens");
        uint256 tokenAmount = IMinterUSD(mintUsdAddress).burnTo(
            msg.sender,
            address(this),
            usdAmount
        );

        //swap token
        swapTokensToToken(
            tokenAmount,
            swapTokenForRouters[_token],
            tokenAddress,
            _token,
            msg.sender
        );
    }

    function _swapTokenAmount(address _token, uint256 tokenAmount)
        private
        returns (uint256)
    {
        require(swapTokens[_token], "token not in swapTokens");
        require(tokenAmount > 0, "amount error");

        uint256 beforeBalance = IERC20(_token).balanceOf(address(this));

        //转入资产
        TransferHelper.safeTransferFrom(
            _token,
            msg.sender,
            address(this), //转入存储合约
            tokenAmount
        );

        uint256 afterBalance = IERC20(_token).balanceOf(address(this));
        //确切的转入金额(防止有fee的Token)
        uint256 amount = afterBalance - beforeBalance;
        require(amount > 0, "amount error");

        uint256 beforeSwap = IERC20(tokenAddress).balanceOf(address(this));

        //swap token
        swapTokensToToken(
            amount,
            swapTokenForRouters[_token],
            _token,
            tokenAddress,
            address(this)
        );

        uint256 afterSwap = IERC20(tokenAddress).balanceOf(address(this));
        uint256 swapAmount = afterSwap - beforeSwap;
        return swapAmount;
    }

    function swapTokensToToken(
        uint256 amount,
        address router,
        address tokenA,
        address tokenB,
        address to
    ) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;

        // make the swap
        IUniswapRouter(router)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amount,
                0,
                path,
                to,
                block.timestamp
            );
    }

    // 判断地址是否为合约
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        if (addr == address(0)) return false;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }
}