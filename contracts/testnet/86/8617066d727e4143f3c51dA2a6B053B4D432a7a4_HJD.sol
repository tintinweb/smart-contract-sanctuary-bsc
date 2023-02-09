// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ExcludedFromFeeList.sol";
import "./LiquidityFeeUSDT.sol";
import "./LpFee.sol";
import "./BurnFee.sol";
import "./MarketFee.sol";

contract HJD is
    ExcludedFromFeeList,
    LiquidityFeeUSDT,
    LpFee,
    BurnFee,
    MarketFee
{
    uint256 private constant _totalSupply = 3000000 * 1e18;
    address private routerAddress;
    address private usdtAddress;
    address private _creator;
    uint256 private buyMax = 20000 * 1e18;

    constructor(
        address _routerAddress,
        address _usdtAddress,
        address _market
    )
        DexBaseUSDT(_routerAddress, _usdtAddress)
        ERC20("HJD", "HJD", 18)
        LiquidityFeeUSDT(_usdtAddress, 1e18, false)
        LpFee(_usdtAddress, 1e15)
        BurnFee()
        MarketFee(_usdtAddress, _market)
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
        uint256 burnAmount = _takeBurn(sender, amount,address(distributor));
        uint256 marketAmount = _takeMarketFee(sender, amount);
        return amount - lpAmount - liquidityAmount - burnAmount - marketAmount;
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
        if (_isBuySell(sender, recipient)) {
            require(amount <= buyMax, "amount big");
        }
        if (!_isTakeFee(sender, recipient)) {
            super._transfer(sender, recipient, amount);
            if (
                sender != uniswapV2PairAddress &&
                recipient != uniswapV2PairAddress &&
                sender != address(this)
            ) {
                _sendMarketFee(sender);
                _lpFeeToUsdt(sender);
            }
            dividendToUsers(sender, recipient);
            return;
        }
        if (shouldSwapAndLiquify(sender)) {
            swapAndLiquify(numTokensSellToAddToLiquidity);
        }
        _sendMarketFee(sender);
        _lpFeeToUsdt(sender);
        dividendToUsers(sender, recipient);
        if (shouldTakeFee(sender, recipient)) {
            uint256 transferAmount = takeFee(sender, amount);
            super._transfer(sender, recipient, transferAmount);
        } else {
            super._transfer(sender, recipient, amount);
        }
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

    function _isBuySell(address from, address to) internal view returns (bool) {
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
                uint256 balance2 = erc20.balanceOf(address(distributor));
                if (balance2 > 0)
                    distributor.transferUSDT(
                        address(erc20),
                        recipient,
                        balance2
                    );
            }
        }
    }

    function excludeMultipleAccountsFromFee(
        address[] calldata accounts,
        bool excluded
    ) internal onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = excluded;
        }
    }
}