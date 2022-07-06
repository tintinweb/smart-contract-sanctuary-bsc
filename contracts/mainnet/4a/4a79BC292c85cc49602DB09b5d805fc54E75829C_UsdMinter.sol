// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
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

interface IUSD {
    function owner() external view returns (address);

    function burn(address account, uint256 amount) external;

    function mint(address to, uint256 amount) external;
}

interface IDepositUSD {
    function withdrawToken(
        address token_,
        address to_,
        uint256 amount_
    ) external;
}

contract UsdMinter {
    address public immutable usdTokenAddress; // usd token address
    address public immutable depositAddress; // 存款合约地址

    address public constant routerAddress =
        0x10ED43C718714eb63d5aA57B78B54704E256024E; // uniswapRouter
    address public constant usdtAddress =
        0x55d398326f99059fF775485246999027B3197955; // usdt

    address public immutable tokenAddress; // token
    address public pairAddress; // token/usdt pair address

    mapping(address => bool) public swapTokens; // 支持兑换的token
    mapping(address => address) public swapTokenForRouters; // 兑换token的router
    mapping(address => bool) public mintRouters; // 支持mint的router

    uint256 public hourLimitTime; // 当前小时周期的时间
    uint256 public dayLimitTime; // 当前周期的时间
    uint256 public hourMintLimitAmount; // 当前小时周期铸造的usd数量
    uint256 public dayMintLimitAmount; // 当前天周期铸造的usd数量
    uint256 public hourBurnLimitAmount; // 当前小时周期消耗的usd数量
    uint256 public dayBurnLimitAmount; // 当前天周期消耗的usd数量

    uint256 public maxMintLimit = 5; // 每次铸造的最大数量 LP 0.5%
    uint256 public maxBurnLimit = 5; // 每次销毁的最大数量 LP 0.5%

    uint256 public hourMintLimit = 1000 * 1e18; // 每小时铸造上限 具体值 1000
    uint256 public hourBurnLimit = 1000 * 1e18; // 每小时销毁上限 1000
    uint256 public dayMintLimit = 10000 * 1e18; // 每天铸造上限 10000
    uint256 public dayBurnLimit = 10000 * 1e18; // 每天销毁上限 10000

    constructor(
        address token_,
        address usd_,
        address deposit_
    ) {
        usdTokenAddress = usd_;
        tokenAddress = token_;
        depositAddress = deposit_;
        safeApprove(tokenAddress, routerAddress, ~uint256(0));
    }

    modifier onlyOwner() {
        require(
            msg.sender == IUSD(usdTokenAddress).owner(),
            "caller is not the owner"
        );
        _;
    }

    modifier onlyRouter() {
        require(mintRouters[msg.sender], "caller is not the router");
        _;
    }

    function setPairAddress(address pair_) external onlyOwner {
        pairAddress = pair_;
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
        address token,
        address router,
        uint256 value
    ) external onlyOwner {
        safeApprove(token, router, value);
    }

    function setMintRouters(address _router) external onlyOwner {
        require(isContract(_router), "router is not a contract");
        mintRouters[_router] = !mintRouters[_router];
    }

    function setMaxLimit(uint256 maxMintLimit_, uint256 maxBurnLimit_)
        external
        onlyOwner
        returns (bool)
    {
        maxMintLimit = maxMintLimit_;
        maxBurnLimit = maxBurnLimit_;
        return true;
    }

    function setLimit(
        uint256 hourMintLimit_,
        uint256 hourBurnLimit_,
        uint256 dayMintLimit_,
        uint256 dayBurnLimit_
    ) external onlyOwner returns (bool) {
        hourMintLimit = hourMintLimit_;
        hourBurnLimit = hourBurnLimit_;
        dayMintLimit = dayMintLimit_;
        dayBurnLimit = dayBurnLimit_;
        return true;
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

    function mintUsd(address _token, uint256 tokenAmount) external {
        require(
            (!isContract(msg.sender)) && (msg.sender == tx.origin),
            "contract not allowed"
        );
        if (_token == tokenAddress) {
            require(tokenAmount > 0, "amount error");
            _mintTo(msg.sender, msg.sender, tokenAmount);
        } else {
            uint256 amount = _swapTokenAmount(_token, tokenAmount);
            require(amount > 0, "amount error");
            _mintTo(address(this), msg.sender, amount);
        }
    }

    // usd=>token
    function burnUsd(address _token, uint256 usdAmount) external {
        require(
            (!isContract(msg.sender)) && (msg.sender == tx.origin),
            "contract not allowed"
        );
        if (_token != tokenAddress) {
            require(swapTokens[_token], "token not in swapTokens");
            uint256 tokenAmount = _burnTo(msg.sender, address(this), usdAmount);

            //swap token
            swapTokensToToken(
                tokenAmount,
                swapTokenForRouters[_token],
                tokenAddress,
                _token,
                msg.sender
            );
        } else {
            _burnTo(msg.sender, msg.sender, usdAmount);
        }
    }

    function mintTo(
        address _sender,
        address _account,
        uint256 tokenAmount
    ) external onlyRouter returns (uint256 usdAmount) {
        return _mintTo(_sender, _account, tokenAmount);
    }

    function burnTo(
        address _sender,
        address _account,
        uint256 usdAmount
    ) external onlyRouter returns (uint256 tokenAmount) {
        return _burnTo(_sender, _account, usdAmount);
    }

    function _mintTo(
        address _sender,
        address _account,
        uint256 tokenAmount
    ) private returns (uint256 usdAmount) {
        usdAmount = getSwapUsd(tokenAmount, tokenAddress);
        require(usdAmount > 0, "usd amount error");

        //更新当前时间段
        _updateTime();

        // 获取限制额度
        (
            uint256 maxAmount,
            uint256 hourLimit,
            uint256 dayLimit
        ) = getMintLimit();

        //单次铸币数量不超过流动池的1%
        require(usdAmount <= maxAmount, "amount max limit error");

        hourMintLimitAmount += usdAmount;
        require(usdAmount <= hourLimit, "hour mint limit error");

        dayMintLimitAmount += usdAmount;
        require(usdAmount <= dayLimit, "day mint limit error");

        //转入资产
        if (_sender == address(this)) {
            TransferHelper.safeTransfer(
                tokenAddress,
                depositAddress,
                tokenAmount
            );
        } else {
            TransferHelper.safeTransferFrom(
                tokenAddress,
                _sender,
                depositAddress, //转入存储合约
                tokenAmount
            );
        }

        IUSD(usdTokenAddress).mint(_account, usdAmount);
        return usdAmount;
    }

    function _burnTo(
        address _sender,
        address _account,
        uint256 usdAmount
    ) private returns (uint256 tokenAmount) {
        tokenAmount = getSwapToken(usdAmount, tokenAddress);
        require(tokenAmount > 0, "token amount error");
        require(
            tokenAmount <= IERC20(tokenAddress).balanceOf(depositAddress),
            "burn amount overflow error"
        );

        //更新当前时间段
        _updateTime();

        // 获取限制额度
        (
            uint256 maxAmount,
            uint256 hourLimit,
            uint256 dayLimit
        ) = getBurnLimit();

        //单次铸币数量不超过流动池的1%
        require(usdAmount <= maxAmount, "amount max limit error");

        //每小时限制
        hourBurnLimitAmount += usdAmount;
        require(usdAmount <= hourLimit, "hour burn limit error");

        //每天限制
        dayBurnLimitAmount += usdAmount;
        require(usdAmount <= dayLimit, "day burn limit error");

        IUSD(usdTokenAddress).burn(_sender, usdAmount);
        IDepositUSD(depositAddress).withdrawToken(
            tokenAddress,
            _account,
            tokenAmount
        );
        return tokenAmount;
    }

    function _updateTime() private {
        // 每小时额度上限 1%
        uint256 _epoch_hour = block.timestamp / 3600;
        if (_epoch_hour > hourLimitTime) {
            hourLimitTime = _epoch_hour;
            hourMintLimitAmount = 0;
            hourBurnLimitAmount = 0;
        }

        // 每天额度上限 2%
        uint256 _epoch_day = block.timestamp / 86400;
        if (_epoch_day > dayLimitTime) {
            dayLimitTime = _epoch_day;
            dayMintLimitAmount = 0;
            dayBurnLimitAmount = 0;
        }
    }

    // 当前时间段剩余铸造额度
    function getMintLimit()
        public
        view
        returns (
            uint256 maxAmount,
            uint256 hourLimit,
            uint256 dayLimit
        )
    {
        uint256 tokenLP = IERC20(tokenAddress).balanceOf(pairAddress);
        uint256 tokenAmount = (tokenLP * maxMintLimit) / 1000;
        maxAmount = getSwapUsd(tokenAmount, tokenAddress);

        // 每小时铸造上限 1%
        uint256 _hourAmount = hourMintLimitAmount;
        uint256 _epoch_hour = block.timestamp / 3600;
        if (_epoch_hour > hourLimitTime) {
            _hourAmount = 0;
        }

        // 每天铸造上限 2%
        uint256 _dayAmount = dayMintLimitAmount;
        uint256 _epoch_day = block.timestamp / 86400;
        if (_epoch_day > dayLimitTime) {
            _dayAmount = 0;
        }

        hourLimit = hourMintLimit - _hourAmount;
        dayLimit = dayMintLimit - _dayAmount;
        return (maxAmount, hourLimit, dayLimit);
    }

    // 当前时间段剩余赎回额度
    function getBurnLimit()
        public
        view
        returns (
            uint256 maxAmount,
            uint256 hourLimit,
            uint256 dayLimit
        )
    {
        uint256 tokenLP = IERC20(tokenAddress).balanceOf(pairAddress);
        uint256 tokenAmount = (tokenLP * maxBurnLimit) / 1000;
        maxAmount = getSwapUsd(tokenAmount, tokenAddress);

        // 每小时销毁上限 1%
        uint256 _hourAmount = hourBurnLimitAmount;
        uint256 _epoch_hour = block.timestamp / 3600;
        if (_epoch_hour > hourLimitTime) {
            _hourAmount = 0;
        }

        // 每天销毁上限 2%
        uint256 _dayAmount = dayBurnLimitAmount;
        uint256 _epoch_day = block.timestamp / 86400;
        if (_epoch_day > dayLimitTime) {
            _dayAmount = 0;
        }
        hourLimit = hourBurnLimit - _hourAmount;
        dayLimit = dayBurnLimit - _dayAmount;

        return (maxAmount, hourLimit, dayLimit);
    }

    function getSwapToken(uint256 amount, address token)
        public
        view
        returns (uint256)
    {
        if (token == tokenAddress) {
            return _getSwapPrice(amount, routerAddress, usdtAddress, token);
        } else {
            uint256 tokenAmount = _getSwapPrice(
                amount,
                routerAddress,
                usdtAddress,
                tokenAddress
            );

            return
                _getSwapPrice(
                    tokenAmount,
                    swapTokenForRouters[token],
                    tokenAddress,
                    token
                );
        }
    }

    function getSwapUsd(uint256 amount, address token)
        public
        view
        returns (uint256)
    {
        if (token == tokenAddress) {
            return _getSwapPrice(amount, routerAddress, token, usdtAddress);
        } else {
            uint256 tokenAmount = _getSwapPrice(
                amount,
                swapTokenForRouters[token],
                token,
                tokenAddress
            );

            return
                _getSwapPrice(
                    tokenAmount,
                    routerAddress,
                    tokenAddress,
                    usdtAddress
                );
        }
    }

    function _getSwapPrice(
        uint256 amount,
        address router,
        address tokenIn,
        address tokenTo
    ) private view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenTo;

        uint256[] memory amounts = IUniswapRouter(router).getAmountsOut(
            amount,
            path
        );
        return amounts[amounts.length - 1];
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