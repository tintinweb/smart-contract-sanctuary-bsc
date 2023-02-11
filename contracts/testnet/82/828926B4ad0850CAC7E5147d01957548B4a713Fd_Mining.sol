// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Ownable.sol";
import "./IUniswapV2Router.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";
import "./Distributor.sol";

contract Mining is Ownable {
    Distributor private distributor = new Distributor();
    mapping(address => uint256) private startBlockMapping;
    mapping(address => uint256) private lpAmountMapping;
    address private routerAddress;
    address private usdtAddress;
    address private wetnAddress;
    address private hjdAddress;
    bool private isAddLiquidity = false;
    bool private isConfigPrice = false;
    uint256[] private prices;
    mapping(uint256 => uint256) private priceStartBlock;
    uint256 private hjdNumberByLp = 6;

    IUniswapV2Pair public uniswapV2Pair;

    uint256 private startBlock = 0;
    bool private isExistsMining = true;

    constructor() // address _routerAddress,
    // address _usdtAddress,
    // address _wetnAddress,
    // address _hjdAddress
    {
        address _routerAddress = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        address _usdtAddress = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
        address _wetnAddress = 0xF7237bf1945609dA37F662d2CdA536922002dd2A;
        address _hjdAddress = 0x3084a748EBf5646124696f98cE147b2Ad6c28B59;

        routerAddress = _routerAddress;
        usdtAddress = _usdtAddress;
        wetnAddress = _wetnAddress;
        hjdAddress = _hjdAddress;
        address pairAddress = IUniswapV2Factory(
            IUniswapV2Router(routerAddress).factory()
        ).getPair(usdtAddress, wetnAddress);
        uniswapV2Pair = IUniswapV2Pair(pairAddress);
        IERC20(usdtAddress).approve(_routerAddress, type(uint256).max);
    }

    function isStartMining() public view returns (bool) {
        return startBlockMapping[_msgSender()] > 0;
    }

    function getHjdNumberByLpNumber(uint256 lpAmount)
        external
        view
        returns (uint256)
    {
        return lpAmount * hjdNumberByLp;
    }

    function startMining(uint256 lpAmount) external payable lock {
        require(isExistsMining, "Mining has not started");
        require(isAddLiquidity, "not Add Liquidity");
        require(isConfigPrice, "not config Price");
        require(startBlockMapping[_msgSender()] == 0, "already started");
        require(msg.value >= 0.004 ether);
        payable(address(distributor)).transfer(msg.value);
        address pairAddress = address(uniswapV2Pair);
        uint256 lpBalance = IERC20(pairAddress).balanceOf(_msgSender());
        require(lpBalance >= lpAmount, "lpBalance<lpAmount");
        uint256 allowanceAmount = IERC20(pairAddress).allowance(
            _msgSender(),
            address(this)
        );
        require(allowanceAmount >= lpAmount, "allowanceAmount<lpAmount");
        IERC20(pairAddress).transferFrom(_msgSender(), address(this), lpAmount);
        uint256 hjdAmount = lpAmount * hjdNumberByLp;
        uint256 hjdBalance = IERC20(hjdAddress).balanceOf(_msgSender());
        require(hjdBalance >= hjdAmount, "hjdBalance<hjdAmount");
        allowanceAmount = IERC20(hjdAddress).allowance(
            _msgSender(),
            address(this)
        );
        require(allowanceAmount >= hjdAmount, "allowanceAmount<hjdAmount");
        IERC20(hjdAddress).transferFrom(_msgSender(), address(this), hjdAmount);
        startBlockMapping[_msgSender()] = block.number;
        lpAmountMapping[_msgSender()] = lpAmount;
        if (startBlock == 0) {
            startBlock = block.number;
        }
    }

    function addLpMining(uint256 lpAmount) external payable lock {
        require(startBlockMapping[_msgSender()] != 0, "has not started");
        require(msg.value >= 0.004 ether);
        payable(address(distributor)).transfer(msg.value);
        _getHjdAward();
        _getUsdtAward();
        address pairAddress = address(uniswapV2Pair);
        uint256 lpBalance = IERC20(pairAddress).balanceOf(_msgSender());
        require(lpBalance >= lpAmount, "lpBalance<lpAmount");
        uint256 allowanceAmount = IERC20(pairAddress).allowance(
            _msgSender(),
            address(this)
        );
        require(allowanceAmount >= lpAmount, "allowanceAmount<lpAmount");
        IERC20(pairAddress).transferFrom(_msgSender(), address(this), lpAmount);

        uint256 hjdAmount = lpAmount * hjdNumberByLp;
        uint256 hjdBalance = IERC20(hjdAddress).balanceOf(_msgSender());
        require(hjdBalance >= hjdAmount, "hjdBalance<hjdAmount");
        allowanceAmount = IERC20(hjdAddress).allowance(
            _msgSender(),
            address(this)
        );
        require(allowanceAmount >= hjdAmount, "allowanceAmount<hjdAmount");
        IERC20(hjdAddress).transferFrom(_msgSender(), address(this), hjdAmount);
        startBlockMapping[_msgSender()] = block.number;
        lpAmountMapping[_msgSender()] =
            lpAmountMapping[_msgSender()] +
            lpAmount;
    }

    function endMining() external payable lock {
        require(startBlockMapping[_msgSender()] != 0, "has not started");
        require(msg.value >= 0.004 ether);
        payable(address(distributor)).transfer(msg.value);
        _getHjdAward();
        _getUsdtAward();
        IERC20(address(uniswapV2Pair)).transfer(
            _msgSender(),
            lpAmountMapping[_msgSender()]
        );
        startBlockMapping[_msgSender()] = 0;
    }

    function getLpNumber() external view returns (uint256) {
        return lpAmountMapping[_msgSender()];
    }

    function getHjdAwardNumber() external view returns (uint256) {
        if (
            startBlockMapping[_msgSender()] == 0 ||
            startBlockMapping[_msgSender()] == block.number
        ) {
            return 0;
        }
        uint256 miningAmount = _getHjdAwardNumber(
            startBlockMapping[_msgSender()],
            block.number,
            lpAmountMapping[_msgSender()]
        );
        return miningAmount;
    }

    function getAward() external {
        require(startBlockMapping[_msgSender()] != 0, "has not started");
        _getHjdAward();
        _getUsdtAward();
        startBlockMapping[_msgSender()] = block.number;
    }

    function configPrice(
        uint256 _lpAmount,
        uint256 _days,
        uint256 _hjdAmount
    ) external onlyOwner {
        require(_lpAmount > 0);
        require(_days > 0);
        require(_hjdAmount > 0);
        uint256 lpAmount = _lpAmount * 1e18;
        uint256 dayBlockNumber = 24 * 60 * 20;
        uint256 hjdAmount = _hjdAmount * 1e18;
        uint256 price = (1e18 * hjdAmount) / dayBlockNumber / lpAmount;
        if (price > 0) {
            prices.push(price);
            priceStartBlock[price] = block.number;
            isConfigPrice = true;
        }
    }

    function configIsExistsMining(bool _isExistsMining) external onlyOwner {
        isExistsMining = _isExistsMining;
    }

    function configHjdNumberByLp(uint256 _hjdNumberByLp) external onlyOwner {
        hjdNumberByLp = _hjdNumberByLp;
    }

    function addAddLiquidity() external onlyOwner {
        uint256 usdtBalance = IERC20(usdtAddress).balanceOf(address(this));
        uint256 wetnBalance = IERC20(wetnAddress).balanceOf(address(this));
        require(
            usdtBalance > 0 && wetnBalance > 0,
            "not usdtBalance or wetnBalance balance"
        );
        _addLiquidity(wetnAddress, wetnBalance, usdtBalance);
        isAddLiquidity = true;
    }

    function getPrices() external view onlyOwner returns (uint256[] memory) {
        return prices;
    }

    function getPriceStartBlock(uint256 price)
        external
        view
        onlyOwner
        returns (uint256)
    {
        return priceStartBlock[price];
    }

    function getStartBlock() external view onlyOwner returns (uint256) {
        return startBlock;
    }

    function _getHjdAwardNumber(
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _lpAmount
    ) internal view returns (uint256) {
        uint256 total = 0;
        uint256 tempBlock = 0;
        for (uint256 i = 0; i < prices.length; i++) {
            uint256 tempPrice = prices[i];
            if (prices.length > i + 1) {
                uint256 nextStartBlock = priceStartBlock[prices[i + 1]];
                if (nextStartBlock > _endBlock) {
                    tempBlock = _endBlock;
                } else {
                    tempBlock = nextStartBlock;
                }
                if (tempBlock > _startBlock) {
                    total =
                        total +
                        (tempPrice * (tempBlock - _startBlock) * _lpAmount);
                    _startBlock = tempBlock;
                }
            } else {
                total =
                    total +
                    (tempPrice * (_endBlock - _startBlock) * _lpAmount);
            }
        }
        return total / 1e18;
    }

    function _getHjdAward() internal {
        if (isExistsMining && block.number > startBlockMapping[_msgSender()]) {
            uint256 lpAdmount = lpAmountMapping[_msgSender()];
            uint256 miningAmount = _getHjdAwardNumber(
                startBlockMapping[_msgSender()],
                block.number,
                lpAdmount
            );
            uint256 contractHjdBalance = IERC20(hjdAddress).balanceOf(
                address(this)
            );
            if (miningAmount > contractHjdBalance) {
                isExistsMining = false;
                IERC20(hjdAddress).transfer(_msgSender(), contractHjdBalance);
            } else {
                IERC20(hjdAddress).transfer(_msgSender(), miningAmount);
            }
        }
    }

    function _getUsdtAward() internal {
        uint256 usdtTotal = IERC20(usdtAddress).balanceOf(address(this));
        if (usdtTotal > 0) {
            uint256 workBlock = block.number - startBlockMapping[_msgSender()];
            uint256 miningUsdtAmount = (workBlock *
                lpAmountMapping[_msgSender()] *
                ((usdtTotal * 1e18) /
                    (block.number - startBlock) /
                    IERC20(address(uniswapV2Pair)).balanceOf(address(this)))) /
                1e18;
            IERC20(usdtAddress).transfer(_msgSender(), miningUsdtAmount);
        }
    }

    function _addLiquidity(
        address _tokenAddress,
        uint256 _tokenAmount,
        uint256 _usdtAmount
    ) internal {
        IERC20(_tokenAddress).approve(
            address(routerAddress),
            type(uint256).max
        );
        IUniswapV2Router(routerAddress).addLiquidity(
            address(usdtAddress),
            address(_tokenAddress),
            _usdtAmount,
            _tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }
}