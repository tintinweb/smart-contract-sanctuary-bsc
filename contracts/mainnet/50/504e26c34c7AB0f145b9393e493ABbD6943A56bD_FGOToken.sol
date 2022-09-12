// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./SwapHelper.sol";
import "./IDAO.sol";
import "./INFTDividend.sol";
import "./ISwapRouter.sol";
import "./ISwapFactory.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./IERC20.sol";

contract FGOToken is ERC20, Ownable {
    using SafeMath for uint256;

    bool private _isBlackOpen = false;
    mapping(address => bool) public blacklist;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 private _startTms;
    uint256 private _botKillFee = 30;
    uint256 private _botInterval = 60;
    address public botFeeAddress = 0xa7A7f754964e876339F40A9902b386fd5794cFeD;

    address public holderDivAddress =
        0xAb36bbd9b9a4BC4b5C434BCBf8bAa13460b17ea4;
    uint256 public holderDivFee = 125;
    address public nftDivAddress;
    uint256 public nftDivFee = 125;
    address public fundAddress = 0x00CCf97c63d3baAa505cE9D9d56A511B7c19F307;
    uint256 public fundFee = 100;
    address public recycleAddress = 0x91cD27A20F01e621512d3cf4C302a718c50AEF44;
    uint256 public recycleFee = 50;
    address public daoAddress;
    uint256[] public promoteFees = [75, 25];
    address public prizeAddress = 0x432C4a7a4dc0B49D5C0d3236f9dE2835aABE17c5;
    uint256 public prizeFee = 100;

    address public usdtAddress;
    address public routerAddress;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    ISwapRouter public swapRouter;
    address public swapPair;
    SwapHelper public swapHelper;

    uint256 private _numTokensSellToAddToLiquidity;

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(
        address _daoAddress,
        address _nftDivAddress,
        address _usdtAddress,
        address _routerAddress
    ) ERC20("FGO", "FGO") {
        address sender = _msgSender();
        _mint(sender, 1 * 10**8 * 10**decimals());
        _numTokensSellToAddToLiquidity = 5000 * 10**decimals();

        daoAddress = _daoAddress;
        nftDivAddress = _nftDivAddress;
        usdtAddress = _usdtAddress;
        routerAddress = _routerAddress;
        ISwapRouter _swapRouter = ISwapRouter(_routerAddress);
        swapPair = ISwapFactory(_swapRouter.factory()).createPair(
            address(this),
            usdtAddress
        );
        swapRouter = _swapRouter;
        swapHelper = new SwapHelper(_usdtAddress);

        _isExcludedFromFee[sender] = true;
        _isExcludedFromFee[address(this)] = true;
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

    function setHolderDivAddress(address addr, uint256 fee) external onlyOwner {
        holderDivAddress = addr;
        holderDivFee = fee;
    }

    function setNftDivAddress(address addr, uint256 fee) external onlyOwner {
        nftDivAddress = addr;
        nftDivFee = fee;
    }

    function setFundAddress(address addr, uint256 fee) external onlyOwner {
        fundAddress = addr;
        fundFee = fee;
    }

    function setRecycleAddress(address addr, uint256 fee) external onlyOwner {
        recycleAddress = addr;
        recycleFee = fee;
    }

    function setDaoAddress(address addr, uint256[] memory fees)
        external
        onlyOwner
    {
        daoAddress = addr;
        promoteFees = fees;
    }

    function setPrizeAddress(address addr, uint256 fee) external onlyOwner {
        prizeAddress = addr;
        prizeFee = fee;
    }

    function setStartData(
        uint256 fee,
        uint256 interval,
        address botFee
    ) external onlyOwner {
        _botKillFee = fee;
        _botInterval = interval;
        botFeeAddress = botFee;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }

    function setNumTokensSellToAddToLiquidity(uint256 _num) external onlyOwner {
        _numTokensSellToAddToLiquidity = _num;
    }

    function getTotalUsdtFee() private view returns (uint256) {
        uint256 fee = holderDivFee.add(nftDivFee).add(fundFee);
        return fee.add(recycleFee).add(prizeFee);
    }

    function _transferOutAndIn(
        address sender,
        address recipient,
        uint256 amountOut,
        uint256 amountIn
    ) private {
        uint256 fromBalance = _balances[sender];
        require(
            fromBalance >= amountOut,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = fromBalance.sub(amountOut);
        }
        _balances[recipient] = _balances[recipient].add(amountIn);

        emit Transfer(sender, recipient, amountIn);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: Transfer amount must be greater than zero");
        if (_startTms == 0 && to == swapPair) {
            _startTms = block.timestamp;
        }
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            _transferOutAndIn(from, to, amount, amount);
        } else if (block.timestamp < _startTms.add(_botInterval)) {
            uint256 botFee = amount.mul(_botKillFee).div(100);
            _transferOutAndIn(from, to, amount, amount.sub(botFee));
            _balances[botFeeAddress] = _balances[botFeeAddress].add(botFee);
            emit Transfer(from, botFeeAddress, botFee);
        } else {
            {
                uint256 tokenBalance = balanceOf(address(this));
                bool overMinTokenBalance = tokenBalance >=
                    _numTokensSellToAddToLiquidity;
                if (
                    overMinTokenBalance &&
                    !inSwapAndLiquify &&
                    swapAndLiquifyEnabled
                ) {
                    tokenBalance = _numTokensSellToAddToLiquidity;
                    swapFeeTokensForUsdtAndDistribution(tokenBalance);
                }
            }
            uint256 usdtFeeTotal = amount.mul(getTotalUsdtFee()).div(10000);
            _balances[address(this)] = _balances[address(this)].add(
                usdtFeeTotal
            );
            emit Transfer(from, address(this), usdtFeeTotal);
            uint256 promoteFeeTotal = distributePromoteFee(from, to, amount);
            _transferOutAndIn(
                from,
                to,
                amount,
                amount.sub(usdtFeeTotal).sub(promoteFeeTotal)
            );
        }
        // Set bind address by token
        if (
            amount == 10**decimals() &&
            from != address(0) &&
            to != address(0) &&
            !Address.isContract(from) &&
            !Address.isContract(to)
        ) {
            try IDAO(daoAddress).bindByTransfer(from, to) {} catch {}
        }
    }

    function distributePromoteFee(
        address from,
        address to,
        uint256 amount
    ) private returns (uint256) {
        uint256 promoteFeeTotal = 0;
        address user = from;
        if (from == swapPair) user = to;
        address[] memory parents = IDAO(daoAddress).getRelations(user);
        for (uint8 i = 0; i < parents.length; i++) {
            uint256 promoteFee = amount.mul(promoteFees[i]).div(10000);
            address share = parents[i];
            _balances[share] = _balances[share].add(promoteFee);
            emit Transfer(from, share, promoteFee);
            promoteFeeTotal = promoteFeeTotal.add(promoteFee);
        }
        return promoteFeeTotal;
    }

    function swapFeeTokensForUsdtAndDistribution(uint256 tokenAmount)
        private
        lockTheSwap
    {
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
        swapUsdtInternalDistribution();
    }

    function swapUsdtInternalDistribution() private {
        uint256 totalBalance = IERC20(usdtAddress).balanceOf(
            address(swapHelper)
        );
        uint256 totalFee = getTotalUsdtFee();
        // holder dividend
        uint256 holderDivAmount = totalBalance.mul(holderDivFee).div(totalFee);
        swapHelper.transfer(holderDivAddress, holderDivAmount);
        // nft dividend
        uint256 nftDivAmount = totalBalance.mul(nftDivFee).div(totalFee);
        bool success = swapHelper.transfer(nftDivAddress, nftDivAmount);
        if (success)
            INFTDividend(nftDivAddress).distributeDividends(nftDivAmount);
        // fund fee
        uint256 fundAmount = totalBalance.mul(fundFee).div(totalFee);
        swapHelper.transfer(fundAddress, fundAmount);
        // recycle fee
        uint256 recycleAmount = totalBalance.mul(recycleFee).div(totalFee);
        swapHelper.transfer(recycleAddress, recycleAmount);
        // prize fee
        uint256 prizeAmount = totalBalance.mul(prizeFee).div(totalFee);
        swapHelper.transfer(prizeAddress, prizeAmount);
    }
}