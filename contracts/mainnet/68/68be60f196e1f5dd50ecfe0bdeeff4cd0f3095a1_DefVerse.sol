// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./ERC20.sol";
import "./SafeToken.sol";
import "./LockToken.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";

contract DefVerse is ERC20, Ownable, SafeToken, LockToken {
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address payable public feeWallet;

    uint256 public swapMin = 200000e18;
    uint256 public swapMax = 50000000e18;

    uint256 public buyFee = 5;
    uint256 public sellFee = 10;

    mapping(address => bool) private _feeWhitelist;

    constructor(address _feeWallet, address _router)
        ERC20("DefVerse", "DVERSE")
    {
        feeWallet = payable(_feeWallet);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);
        uniswapV2Router = _uniswapV2Router;

        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        _feeWhitelist[owner()] = true;
        _feeWhitelist[address(this)] = true;
        _feeWhitelist[feeWallet] = true;

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(owner(), 500000000 * (10**18));
    }

    receive() external payable {
        require(_msgSender() == address(uniswapV2Router));
    }

    function setFeeWallet(address payable _feeWallet) external onlyOwner {
        feeWallet = _feeWallet;
    }

    function setFeeWhitelist(address account, bool excluded)
        external
        onlyOwner
    {
        _feeWhitelist[account] = excluded;
    }

    function getFeeWhitelist(address account) external view returns (bool) {
        return _feeWhitelist[account];
    }

    function setSwapMin(uint256 _swapMin) external onlyOwner {
        require(_swapMin > 0, "Minimum must be greater than 0");
        swapMin = _swapMin;
    }

    function setSwapMax(uint256 _swapMax) external onlyOwner {
        require(_swapMax > swapMin, "Maximum must be greater than minimum");
        swapMax = _swapMax;
    }

    function setBuyFee(uint256 _buyFee) external onlyOwner {
        require(_buyFee <= 10, "The buy fee is capped at 10%");
        buyFee = _buyFee;
    }

    function setSellFee(uint256 _sellFee) external onlyOwner {
        require(_sellFee <= 10, "The sell fee is capped at 10%");
        sellFee = _sellFee;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override open(from, to) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (
            (to == uniswapV2Pair || from == uniswapV2Pair) &&
            !_feeWhitelist[from] &&
            !_feeWhitelist[to]
        ) {
            uint256 fee;
            if (to == uniswapV2Pair) {
                fee = (amount * sellFee) / 100;
            } else {
                fee = (amount * buyFee) / 100;
            }
            amount = amount - fee;
            super._transfer(from, address(this), fee);
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        if (
            contractTokenBalance >= swapMin &&
            from != uniswapV2Pair &&
            !_feeWhitelist[from] &&
            !_feeWhitelist[to]
        ) {
            if (contractTokenBalance > swapMax) {
                contractTokenBalance = swapMax;
            }
            _swapTokensForBnb(contractTokenBalance, feeWallet);
        }

        super._transfer(from, to, amount);
    }

    function _swapTokensForBnb(uint256 tokenAmount, address _to) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        try
            uniswapV2Router.swapExactTokensForETH(
                tokenAmount,
                0, // accept any amount of ETH
                path,
                _to,
                block.timestamp
            )
        {} catch {}
    }
}