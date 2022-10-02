// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.15;

import "./ERC20.sol";
import "./SwapHelper.sol";
import "./IDAO.sol";
import "./ISwapRouter.sol";
import "./ISwapFactory.sol";
import "./INFTsDividend.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract KTBToken is ERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => bool) private _isExcludedFromFee;

    bool private _isBlackOpen = true;
    mapping(address => bool) public blacklist;

    // burn fee
    uint256 public burnFee = 300;
    // buy fee
    address public deadAddress = address(0xdead);
    uint256 public tribeFee = 200;
    uint256[] public levelsFees = [400, 200, 50];
    // sell fee
    uint256 public fundsFee = 200;
    uint256 public nftsFee = 500;
    uint256 public liquidityFee = 500;

    address public usdtAddress;
    address public daoAddress;
    address public nftsDivAddress;
    address public fundsAddress;

    address public swapPair;
    SwapHelper public swapHelper;
    ISwapRouter public swapRouter;

    bool inSwapAndLiquidity;
    bool public swapAndLiquidityEnabled = true;
    uint256 private _numTokensSellToAddToLiquidity;

    event SwapAndLiquidity(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap() {
        inSwapAndLiquidity = true;
        _;
        inSwapAndLiquidity = false;
    }

    constructor(
        address _routerAddress,
        address _usdtAddress,
        address _daoAddress,
        address _nftsDivAddress,
        address _fundsAddress
    ) ERC20("KTB", "KTB") {
        address sender = _msgSender();
        _mint(sender, 310000000 * 10**decimals());
        _numTokensSellToAddToLiquidity = 1000 * 10**decimals();

        usdtAddress = _usdtAddress;
        daoAddress = _daoAddress;
        nftsDivAddress = _nftsDivAddress;
        fundsAddress = _fundsAddress;

        ISwapRouter _swapRouter = ISwapRouter(_routerAddress);
        swapPair = ISwapFactory(_swapRouter.factory()).createPair(
            address(this),
            usdtAddress
        );
        swapRouter = _swapRouter;
        swapHelper = new SwapHelper(usdtAddress);

        _isExcludedFromFee[_msgSender()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[deadAddress] = true;
        _isExcludedFromFee[nftsDivAddress] = true;
        _isExcludedFromFee[fundsAddress] = true;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setBlacklist(address _address, bool _flag) external onlyOwner {
        blacklist[_address] = _flag;
    }

    function setIsBlackOpen(bool _open) external onlyOwner {
        _isBlackOpen = _open;
    }

    function setSwapFees(
        uint256 _burn,
        uint256 _tribe,
        uint256[] memory _levels,
        uint256 _funds,
        uint256 _nfts,
        uint256 _liquidity
    ) external onlyOwner {
        burnFee = _burn;
        tribeFee = _tribe;
        levelsFees = _levels;
        fundsFee = _funds;
        nftsFee = _nfts;
        liquidityFee = _liquidity;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: Transfer amount must be greater than zero");
        require(
            balanceOf(from) >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            super._transfer(from, to, amount);
        } else {
            require(
                !blacklist[from] && !blacklist[to],
                "ERC20: the current user is in the blacklist and cannot be transferred"
            );
            if (from == swapPair || from == nftsDivAddress) {
                _buyWithFee(from, to, amount);
            } else {
                _sellWithFee(from, to, amount);
            }
        }
    }

    function _buyWithFee(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        if (_isBlackOpen) blacklist[recipient] = true;
        uint256 feeTotal = 0;
        // burn
        uint256 burnAmount = amount.mul(burnFee).div(10000);
        feeTotal = feeTotal.add(burnAmount);
        _balances[deadAddress] = _balances[deadAddress].add(burnAmount);
        emit Transfer(sender, deadAddress, burnAmount);
        // dividend to tribe
        uint256 tribeDivAmount = amount.mul(tribeFee).div(10000);
        feeTotal = feeTotal.add(tribeDivAmount);
        _balances[nftsDivAddress] = _balances[nftsDivAddress].add(
            tribeDivAmount
        );
        INFTsDividend(nftsDivAddress).distributeLevelDividends(
            1,
            tribeDivAmount
        );
        emit Transfer(sender, nftsDivAddress, tribeDivAmount);
        // dividend to levels
        address[] memory relations = IDAO(daoAddress).getRelations(recipient);
        for (uint8 i = 0; i < relations.length; i++) {
            uint256 idx = i;
            if (idx >= levelsFees.length) idx = levelsFees.length - 1;
            uint256 levelAmount = amount.mul(levelsFees[idx]).div(10000);
            feeTotal = feeTotal.add(levelAmount);
            _balances[relations[i]] = _balances[relations[i]].add(levelAmount);
            emit Transfer(sender, relations[i], levelAmount);
        }
        // transfer finally
        _balances[sender] = _balances[sender].sub(amount);
        uint256 toAmount = amount.sub(feeTotal);
        _balances[recipient] = _balances[recipient].add(toAmount);
        emit Transfer(sender, recipient, toAmount);
    }

    function _sellWithFee(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        // take liquidity
        uint256 tokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = tokenBalance >=
            _numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquidity &&
            swapAndLiquidityEnabled
        ) {
            tokenBalance = _numTokensSellToAddToLiquidity;
            swapAndLiquidity(tokenBalance);
        }
        uint256 feeTotal = 0;
        // burn
        uint256 burnAmount = amount.mul(burnFee).div(10000);
        feeTotal = feeTotal.add(burnAmount);
        _balances[deadAddress] = _balances[deadAddress].add(burnAmount);
        emit Transfer(sender, deadAddress, burnAmount);
        // funds
        uint256 fundsAmount = amount.mul(fundsFee).div(10000);
        feeTotal = feeTotal.add(fundsAmount);
        _balances[fundsAddress] = _balances[fundsAddress].add(fundsAmount);
        emit Transfer(sender, fundsAddress, fundsAmount);
        // dividend to nft
        uint256 nftsDivAmount = amount.mul(nftsFee).div(10000);
        feeTotal = feeTotal.add(nftsDivAmount);
        _balances[nftsDivAddress] = _balances[nftsDivAddress].add(
            nftsDivAmount
        );
        INFTsDividend(nftsDivAddress).distributeDividends(nftsDivAmount);
        emit Transfer(sender, nftsDivAddress, nftsDivAmount);
        // liquidity fee
        uint256 liquidityAmount = amount.mul(liquidityFee).div(10000);
        feeTotal = feeTotal.add(liquidityAmount);
        _balances[address(this)] = _balances[address(this)].add(
            liquidityAmount
        );
        emit Transfer(sender, address(this), liquidityAmount);
        // transfer finally
        _balances[sender] = _balances[sender].sub(amount);
        uint256 toAmount = amount.sub(feeTotal);
        _balances[recipient] = _balances[recipient].add(toAmount);
        emit Transfer(sender, recipient, toAmount);
    }

    function swapAndLiquidity(uint256 contractTokenBalance)
        private
        lockTheSwap
    {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
        uint256 initialBalance = IERC20(usdtAddress).balanceOf(address(this));
        // swap tokens for USDT
        swapTokensForUsdtToSelf(half);
        uint256 newBalance = IERC20(usdtAddress).balanceOf(address(this)).sub(
            initialBalance
        );
        // add liquidity to swap
        addLiquidity(otherHalf, newBalance);
        emit SwapAndLiquidity(half, newBalance, otherHalf);
    }

    function swapTokensForUsdtToSelf(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdtAddress;
        _approve(address(this), address(swapRouter), tokenAmount);
        swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of USDT
            path,
            address(swapHelper), // use the helper to receive
            block.timestamp
        );
        // transfer back to the current contract
        swapHelper.transferToOwner();
    }

    function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(swapRouter), tokenAmount);
        IERC20(usdtAddress).approve(address(swapRouter), usdtAmount);
        // add the liquidity
        swapRouter.addLiquidity(
            address(this),
            usdtAddress,
            tokenAmount,
            usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }
}