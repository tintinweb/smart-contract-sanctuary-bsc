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
    address public immutable depositAddress; // ??????????????????

    address public constant routerAddress =
        0xCc7aDc94F3D80127849D2b41b6439b7CF1eB4Ae0; // uniswapRouter
    address public constant usdtAddress =
        0x47A01F129b9c95E63a50a6aa6cBaFDD96bEb4C6F; // usdt

    address public immutable tokenAddress; // token
    address public pairAddress; // token/usdt pair address

    mapping(address => bool) public swapTokens; // ???????????????token
    mapping(address => address) public swapTokenForRouters; // ??????token???router
    mapping(address => bool) public mintRouters; // ??????mint???router

    uint256 public hourLimitTime; // ???????????????????????????
    uint256 public dayLimitTime; // ?????????????????????
    uint256 public hourMintLimitAmount; // ???????????????????????????usd??????
    uint256 public dayMintLimitAmount; // ????????????????????????usd??????
    uint256 public hourBurnLimitAmount; // ???????????????????????????usd??????
    uint256 public dayBurnLimitAmount; // ????????????????????????usd??????

    uint256 public maxMintLimit = 5; // ??????????????????????????? LP 0.5%
    uint256 public maxBurnLimit = 5; // ??????????????????????????? LP 0.5%

    uint256 public hourMintLimit = 1000 * 1e18; // ????????????????????? ????????? 1000
    uint256 public hourBurnLimit = 1000 * 1e18; // ????????????????????? 1000
    uint256 public dayMintLimit = 10000 * 1e18; // ?????????????????? 10000
    uint256 public dayBurnLimit = 10000 * 1e18; // ?????????????????? 10000

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

    function setSwapTokens(
        address _token,
        address _router,
        bool _value
    ) external onlyOwner {
        require(
            isContract(_router) && isContract(_token),
            "router and token must be contract"
        );

        if (_value && !swapTokens[_token]) {
            safeApprove(_token, _router, ~uint256(0));
        }
        swapTokens[_token] = _value;
        swapTokenForRouters[_token] = _router;
    }

    function setMintRouters(address _router, bool _value) external onlyOwner {
        require(isContract(_router), "router is not a contract");
        mintRouters[_router] = _value;
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

    function _tokenAmount(uint256 tokenAmount) private returns (uint256) {
        //???????????????????????????????????????1%
        uint256 tokenLP = IERC20(tokenAddress).balanceOf(pairAddress);
        uint256 maxAmount = (tokenLP * maxMintLimit) / 1000;
        require(tokenAmount <= maxAmount, "amount max limit error");

        uint256 beforeBalance = IERC20(tokenAddress).balanceOf(depositAddress);

        //????????????
        TransferHelper.safeTransferFrom(
            tokenAddress,
            msg.sender,
            depositAddress, //??????????????????
            tokenAmount
        );

        uint256 afterBalance = IERC20(tokenAddress).balanceOf(depositAddress);
        //?????????????????????(?????????fee???Token)
        uint256 amount = afterBalance - beforeBalance;
        return amount;
    }

    function _swapTokenAmount(address _token, uint256 tokenAmount)
        private
        returns (uint256)
    {
        require(swapTokens[_token], "token not in swapTokens");
        require(tokenAmount > 0, "amount error");

        //???????????????????????????????????????1%
        uint256 swapTokenAmount = getSwapRouterPrice(
            tokenAmount,
            swapTokenForRouters[_token],
            _token,
            tokenAddress
        );
        uint256 tokenLP = IERC20(tokenAddress).balanceOf(pairAddress);
        uint256 maxAmount = (tokenLP * maxMintLimit) / 1000;
        require(swapTokenAmount <= maxAmount, "amount max limit error");

        uint256 beforeBalance = IERC20(_token).balanceOf(address(this));

        //????????????
        TransferHelper.safeTransferFrom(
            _token,
            msg.sender,
            address(this),
            tokenAmount
        );

        uint256 afterBalance = IERC20(_token).balanceOf(address(this));
        //?????????????????????(?????????fee???Token)
        uint256 amount = afterBalance - beforeBalance;
        require(amount > 0, "amount error");

        uint256 beforeSwap = IERC20(tokenAddress).balanceOf(depositAddress);

        //swap token
        swapTokensToToken(
            amount,
            swapTokenForRouters[_token],
            _token,
            tokenAddress,
            depositAddress
        );

        uint256 afterSwap = IERC20(tokenAddress).balanceOf(depositAddress);
        uint256 swapAmount = afterSwap - beforeSwap;
        return swapAmount;
    }

    function mintUsd(address _token, uint256 tokenAmount) external {
        require(
            (!isContract(msg.sender)) && (msg.sender == tx.origin),
            "contract not allowed"
        );
        uint256 amount;
        if (_token == tokenAddress) {
            amount = _tokenAmount(tokenAmount);
        } else {
            amount = _swapTokenAmount(_token, tokenAmount);
        }

        require(amount > 0, "amount error");

        uint256 usdAmount = getSwapPrice(amount, tokenAddress, usdtAddress);
        require(usdAmount > 0, "usd amount error");

        // ????????????????????? 1%
        uint256 _epoch_hour = block.timestamp / 3600;
        if (_epoch_hour > hourLimitTime) {
            hourLimitTime = _epoch_hour;
            hourMintLimitAmount = 0;
        }

        require(
            usdAmount + hourMintLimitAmount <= hourMintLimit,
            "hour mint limit error"
        );
        hourMintLimitAmount = hourMintLimitAmount + usdAmount;

        // ?????????????????? 2%
        uint256 _epoch_day = block.timestamp / 86400;
        if (_epoch_day > dayLimitTime) {
            dayLimitTime = _epoch_day;
            dayMintLimitAmount = 0;
        }
        require(
            usdAmount + dayMintLimitAmount <= dayMintLimit,
            "day mint limit error"
        );
        dayMintLimitAmount = dayMintLimitAmount + usdAmount;

        IUSD(usdTokenAddress).mint(msg.sender, usdAmount);
    }

    // usd=>token
    function burnUsd(address _token, uint256 usdAmount) external {
        require(
            (!isContract(msg.sender)) && (msg.sender == tx.origin),
            "contract not allowed"
        );
        if (_token != tokenAddress) {
            require(swapTokens[_token], "token not in swapTokens");
        }
        uint256 tokenAmount = getSwapPrice(
            usdAmount,
            usdtAddress,
            tokenAddress
        );
        require(tokenAmount > 0, "token amount error");
        require(
            tokenAmount <= IERC20(tokenAddress).balanceOf(depositAddress),
            "burn amount overflow error"
        );

        //???????????????????????????????????????1%
        uint256 tokenLP = IERC20(tokenAddress).balanceOf(pairAddress);
        uint256 maxAmount = (tokenLP * maxBurnLimit) / 1000;
        require(tokenAmount <= maxAmount, "amount max limit error");

        // ????????????????????? 1%
        uint256 _epoch_hour = block.timestamp / 3600;
        if (_epoch_hour > hourLimitTime) {
            hourLimitTime = _epoch_hour;
            hourBurnLimitAmount = 0;
        }
        require(
            usdAmount + hourBurnLimitAmount <= hourBurnLimit,
            "hour burn limit error"
        );
        hourBurnLimitAmount = hourBurnLimitAmount + usdAmount;

        // ?????????????????? 2%
        uint256 _epoch_day = block.timestamp / 86400;
        if (_epoch_day > dayLimitTime) {
            dayLimitTime = _epoch_day;
            dayBurnLimitAmount = 0;
        }
        require(
            usdAmount + dayBurnLimitAmount <= dayBurnLimit,
            "day burn limit error"
        );
        dayBurnLimitAmount = dayBurnLimitAmount + usdAmount;

        IUSD(usdTokenAddress).burn(msg.sender, usdAmount);
        if (_token == tokenAddress) {
            IDepositUSD(depositAddress).withdrawToken(
                tokenAddress,
                msg.sender,
                tokenAmount
            );
        } else {
            IDepositUSD(depositAddress).withdrawToken(
                tokenAddress,
                address(this),
                tokenAmount
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
    }

    function mintTo(
        address _sender,
        address _account,
        uint256 tokenAmount
    ) external onlyRouter {
        uint256 usdAmount = getSwapPrice(
            tokenAmount,
            tokenAddress,
            usdtAddress
        );
        require(usdAmount > 0, "usd amount error");

        // ????????????????????? 1%
        uint256 _epoch_hour = block.timestamp / 3600;
        if (_epoch_hour > hourLimitTime) {
            hourLimitTime = _epoch_hour;
            hourMintLimitAmount = 0;
        }

        // ?????????????????? 2%
        uint256 _epoch_day = block.timestamp / 86400;
        if (_epoch_day > dayLimitTime) {
            dayLimitTime = _epoch_day;
            dayMintLimitAmount = 0;
        }

        // ??????????????????
        (
            uint256 maxAmount,
            uint256 hourLimit,
            uint256 dayLimit
        ) = getMintLimit();

        //???????????????????????????????????????1%
        require(tokenAmount <= maxAmount, "amount max limit error");

        require(
            usdAmount + hourLimit <= hourMintLimit,
            "hour mint limit error"
        );
        hourMintLimitAmount += usdAmount;

        require(usdAmount + dayLimit <= dayMintLimit, "day mint limit error");
        dayMintLimitAmount += usdAmount;

        //????????????
        TransferHelper.safeTransferFrom(
            tokenAddress,
            _sender,
            depositAddress, //??????????????????
            tokenAmount
        );
        IUSD(usdTokenAddress).mint(_account, usdAmount);
    }

    function burnTo(
        address _sender,
        address _account,
        uint256 usdAmount
    ) external onlyRouter {
        uint256 tokenAmount = getSwapPrice(
            usdAmount,
            usdtAddress,
            tokenAddress
        );
        require(tokenAmount > 0, "token amount error");
        require(
            tokenAmount <= IERC20(tokenAddress).balanceOf(depositAddress),
            "burn amount overflow error"
        );

        // ????????????????????? 1%
        uint256 _epoch_hour = block.timestamp / 3600;
        if (_epoch_hour > hourLimitTime) {
            hourLimitTime = _epoch_hour;
            hourBurnLimitAmount = 0;
        }

        // ?????????????????? 2%
        uint256 _epoch_day = block.timestamp / 86400;
        if (_epoch_day > dayLimitTime) {
            dayLimitTime = _epoch_day;
            dayBurnLimitAmount = 0;
        }

        // ??????????????????
        (
            uint256 maxAmount,
            uint256 hourLimit,
            uint256 dayLimit
        ) = getBurnLimit();

        //???????????????????????????????????????1%
        require(tokenAmount <= maxAmount, "amount max limit error");

        //???????????????
        require(
            usdAmount + hourLimit <= hourBurnLimit,
            "hour burn limit error"
        );
        hourBurnLimitAmount += usdAmount;

        //????????????
        require(usdAmount + dayLimit <= dayBurnLimit, "day burn limit error");
        dayBurnLimitAmount += usdAmount;

        IUSD(usdTokenAddress).burn(_sender, usdAmount);
        IDepositUSD(depositAddress).withdrawToken(
            tokenAddress,
            _account,
            tokenAmount
        );
    }

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
        maxAmount = (tokenLP * maxMintLimit) / 1000;
        hourLimit = hourMintLimit - hourMintLimitAmount;
        dayLimit = dayMintLimit - dayMintLimitAmount;
        return (maxAmount, hourLimit, dayLimit);
    }

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
        maxAmount = (tokenLP * maxBurnLimit) / 1000;
        hourLimit = hourBurnLimit - hourBurnLimitAmount;
        dayLimit = dayBurnLimit - dayBurnLimitAmount;
        return (maxAmount, hourLimit, dayLimit);
    }

    // ??????????????????
    function getSwapPrice(
        uint256 amount,
        address tokenIn,
        address tokenTo
    ) public view returns (uint256) {
        return getSwapRouterPrice(amount, routerAddress, tokenIn, tokenTo);
    }

    function getSwapRouterPrice(
        uint256 amount,
        address router,
        address tokenIn,
        address tokenTo
    ) public view returns (uint256) {
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

    // ???????????????????????????
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