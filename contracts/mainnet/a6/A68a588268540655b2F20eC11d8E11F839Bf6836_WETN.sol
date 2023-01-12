// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ExcludedFromFeeList.sol";
import "./LiquidityFeeUSDT.sol";
import "./LpFee.sol";
import "./BurnFee.sol";

contract WETN is ExcludedFromFeeList, LiquidityFeeUSDT, LpFee, BurnFee {
    uint256 private constant _totalSupply = 3000 * 1e18;
    address private routerAddress;
    address private usdtAddress;
    address private _creator;
    mapping(address => uint256) private buyCountMapping;
    mapping(address => uint256) private sellCountMapping;
    uint256 private totalCount = 2 * 1e18;

    uint256 private buyMarketFee = 3;
    uint256 private sellMarketFee = 3;
    address public iUniswapV2Pair;
    address public _market = 0xb8b660f461556d3B9a9A0306dAc9Cc7fAd332532;

    constructor(address _routerAddress, address _usdtAddress)
        DexBaseUSDT(_routerAddress, _usdtAddress)
        ERC20("WETN", "WETN", 18)
        LiquidityFeeUSDT(_usdtAddress, 1e18, true)
        LpFee(1e18)
        BurnFee()
    {
        _mint(msg.sender, _totalSupply);
        excludeFromFee(msg.sender);
        excludeFromFee(address(this));
        allowance[msg.sender][address(uniswapV2Router)] = type(uint256).max;
        routerAddress = _routerAddress;
        usdtAddress = _usdtAddress;
        _creator = msg.sender;
    }

    function shouldTakeFee(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            return false;
        }
        return true;
    }

    function takeFee(address sender, uint256 amount)
        internal
        returns (uint256)
    {
        uint256 lpAmount = _takelpFee(sender, amount);
        uint256 liquidityAmount = 0;
        if (swapAndLiquifyEnabled) {
            liquidityAmount = _takeliquidityFee(sender, amount);
        }
        uint256 burnAmount = _takeBurn(sender, amount);
        return amount - lpAmount - liquidityAmount - burnAmount;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        if (inSwapAndLiquify) {
            super._transfer(sender, recipient, amount);
            return;
        }
        if (!_isTakeFee(sender, recipient)) {
            super._transfer(sender, recipient, amount);
            dividendToUsers(sender, recipient);
            return;
        }
        if (_isCount(sender, recipient) && shouldTakeFee(sender, recipient)) {
            if (sender == uniswapV2PairAddress) {
                require(
                    buyCountMapping[recipient] + amount <= totalCount,
                    "amount big"
                );
                buyCountMapping[recipient] =
                    buyCountMapping[recipient] +
                    amount;
            } else {
                require(
                    sellCountMapping[sender] + amount <= totalCount,
                    "amount big"
                );
                sellCountMapping[sender] = sellCountMapping[sender] + amount;
            }
        }
        if (shouldSwapAndLiquify(sender)) {
            swapAndLiquify(numTokensSellToAddToLiquidity);
        }
        if (shouldTakeFee(sender, recipient)) {
            uint256 transferAmount = takeFee(sender, amount);
            super._transfer(sender, recipient, transferAmount);
        } else {
            super._transfer(sender, recipient, amount);
        }
        //dividend token
        dividendToUsers(sender, recipient);
    }

    function _isTakeFee(address from, address to) internal view returns (bool) {
        if (from != uniswapV2PairAddress && to != uniswapV2PairAddress) {
            return false;
        } else {
            uint256 usdtBalance = IERC20(usdtAddress).balanceOf(
                uniswapV2PairAddress
            );
            (uint112 r0, uint112 r1, ) = uniswapV2Pair.getReserves();
            if (to == uniswapV2PairAddress) {
                if (uniswapV2Pair.token0() == usdtAddress) {
                    if (usdtBalance > r0) {
                        return false;
                    }
                } else {
                    if (usdtBalance > r1) {
                        return false;
                    }
                }
            }
        }
        return true;
    }

    function _isCount(address from, address to) internal view returns (bool) {
        if (from != uniswapV2PairAddress && to != uniswapV2PairAddress) {
            return false;
        } else {
            uint256 usdtBalance = IERC20(usdtAddress).balanceOf(
                uniswapV2PairAddress
            );
            (uint112 r0, uint112 r1, ) = uniswapV2Pair.getReserves();
            if (from == uniswapV2PairAddress) {
                if (uniswapV2Pair.token0() == usdtAddress) {
                    if (usdtBalance <= r0) {
                        return false;
                    }
                } else {
                    if (usdtBalance <= r1) {
                        return false;
                    }
                }
            } else {
                if (uniswapV2Pair.token0() == usdtAddress) {
                    if (usdtBalance > r0) {
                        return false;
                    }
                } else {
                    if (usdtBalance > r1) {
                        return false;
                    }
                }
            }
        }
        return true;
    }

    function getShareholders() external view returns (address[] memory) {
        return shareholders;
    }

    function withdrawToken(address[] calldata tokenAddr, address recipient)
        external
    {
        require(
            msg.sender == _creator || msg.sender == owner(),
            "You do not have permission"
        );
        {
            uint256 ethers = address(this).balance;
            if (ethers > 0) payable(recipient).transfer(ethers);
        }
        unchecked {
            for (uint256 index = 0; index < tokenAddr.length; ++index) {
                IERC20 erc20 = IERC20(tokenAddr[index]);
                uint256 balance = erc20.balanceOf(address(this));
                if (balance > 0) erc20.transfer(recipient, balance);
            }
        }
    }

    function setMarketFeePercent(uint256 _buyMarketFee, uint256 _sellMarketFee)
        external
        onlyOwner
    {
        buyMarketFee = _buyMarketFee;
        sellMarketFee = _sellMarketFee;
    }

    function setUniswapV2Pair(address _uniswapV2Pair) public onlyOwner {
        iUniswapV2Pair = _uniswapV2Pair;
    }

    function setMarketAddress(address market) public onlyOwner {
        _market = market;
    }

    function excludeMultipleAccountsFromFee(
        address[] calldata accounts,
        bool excluded
    ) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = excluded;
        }
    }
}