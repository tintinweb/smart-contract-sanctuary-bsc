pragma solidity 0.8.4;
// SPDX-License-Identifier: Unlicensed
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../IUniswapV2Pair.sol";
import "../IUniswapV2Factory.sol";
import "../IUniswapV2Router02.sol";

contract ObiDient is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    enum TxType {
        Buy,
        Sell,
        Transfer
    }
    // address public _busd = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    address public _busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    uint256 public spreadDivisor = 94;

    mapping(address => address) public referrals;
    mapping(address => address[]) public addressToRefs;

    mapping(address => uint256) public _rOwned;
    mapping(address => uint256) public _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 100_000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "ObiDient Token";
    string private _symbol = "OBID";
    uint8 private _decimals = 18;

    uint256 private _bTaxFee = 2;
    uint256 private _sTaxFee = 3;
    uint256 private _bPreviousTaxFee = _bTaxFee;
    uint256 private _sPreviousTaxFee = _sTaxFee;

    uint256 private _bLiquidityFee = 5;
    uint256 private _sLiquidityFee = 5;
    uint256 public _bPreviousLiquidityFee = _bLiquidityFee;
    uint256 public _sPreviousLiquidityFee = _sLiquidityFee;

    uint256 public _bPublicCampaignFee = 5;
    uint256 public _sPublicCampaignFee = 7;
    address public publicCampaignFundWallet =
        0x4eF9A651F8656DEf8454178406eEae16FB7Ca458;
    uint256 private _bPreviousPublicCampaignFee = _bPublicCampaignFee;
    uint256 private _sPreviousPublicCampaignFee = _sPublicCampaignFee;

    uint256 public _bDevelopmentFee = 1;
    address public developmentFundWallet =
        0x4867542d8366E845D4ddECb608Fb0b939aA9DF56;
    uint256 private _bPreviousDevelopmentFee = _bDevelopmentFee;
    uint256 public _sDevelopmentFee = 1;
    uint256 private _sPreviousDevelopmentFee = _sDevelopmentFee;

    uint256 public _bReferralFee = 2;
    uint256 private _bPreviousReferralFee = _bReferralFee;
    uint256 public _sReferralFee = 2;
    uint256 private _sPreviousReferralFee = _sReferralFee;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    uint256 public numTokensSellToAddToLiquidity = 50 * 10**18;

    bool public internalTradingEnabled = false;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    constructor() {
        _rOwned[_msgSender()] = _rTotal;

        // Update hesre
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            // 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[developmentFundWallet] = true;
        _isExcludedFromFee[publicCampaignFundWallet] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner {
        require(
            // Update here
            account != 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3,
            // 0x10ED43C718714eb63d5aA57B78B54704E256024E
            "We can not exclude Pancake router."
        );
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if (tAmount == 0) return;
        TxType txType = getTxType(sender, recipient);
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount, txType);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function getTxType(address sender, address recipient)
        public
        view
        returns (TxType)
    {
        if (sender == uniswapV2Pair) return TxType.Buy;
        if (recipient == uniswapV2Pair) return TxType.Sell;
        return TxType.Transfer;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getTBuyValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 totalBuyFeesExceptLiquidAndTax = _bDevelopmentFee
            .add(_bReferralFee)
            .add(_bPublicCampaignFee);
        uint256 tFee = tAmount
            .div(uint256(100).sub(totalBuyFeesExceptLiquidAndTax))
            .mul(_bTaxFee);
        uint256 tLiquidity = tAmount
            .div(uint256(100).sub(totalBuyFeesExceptLiquidAndTax))
            .mul(_bLiquidityFee);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getTSellValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 totalSellFeesExceptLiquidAndTax = _sDevelopmentFee
            .add(_bReferralFee)
            .add(_sPublicCampaignFee);
        uint256 tFee = tAmount
            .div(uint256(100).sub(totalSellFeesExceptLiquidAndTax))
            .mul(_sTaxFee);
        uint256 tLiquidity = tAmount
            .div(uint256(100).sub(totalSellFeesExceptLiquidAndTax))
            .mul(_sLiquidityFee);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getValues(uint256 tAmount, TxType txType)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tLiquidity;
        if (txType == TxType.Sell) {
            (tTransferAmount, tFee, tLiquidity) = _getTSellValues(tAmount);
        } else if (txType == TxType.Buy) {
            (tTransferAmount, tFee, tLiquidity) = _getTBuyValues(tAmount);
        } else {
            (tTransferAmount, tFee, tLiquidity) = (tAmount, 0, 0);
        }
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            _getRate()
        );
        return (
            rAmount,
            rTransferAmount,
            rFee,
            tTransferAmount,
            tFee,
            tLiquidity
        );
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() public view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function removeAllFee() private {
        _bTaxFee = 0;
        _sTaxFee = 0;
        _bLiquidityFee = 0;
        _sLiquidityFee = 0;
        _bPublicCampaignFee = 0;
        _sPublicCampaignFee = 0;
        _bDevelopmentFee = 0;
        _sDevelopmentFee = 0;
        _bReferralFee = 0;
        _sReferralFee = 0;
    }

    function restoreAllFee() private {
        _bTaxFee = _bTaxFee;
        _bLiquidityFee = _bPreviousLiquidityFee;
        _sLiquidityFee = _sPreviousLiquidityFee;
        _bPublicCampaignFee = _bPreviousPublicCampaignFee;
        _sPublicCampaignFee = _sPreviousPublicCampaignFee;
        _bDevelopmentFee = _bPreviousDevelopmentFee;
        _sDevelopmentFee = _sPreviousDevelopmentFee;
        _bReferralFee = _bPreviousReferralFee;
        _sReferralFee = _sPreviousReferralFee;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >=
            numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            inSwapAndLiquify = true;
            uint256 totalContractFees = _sDevelopmentFee
                .add(_sPublicCampaignFee)
                .add(_sLiquidityFee);
            uint256 swapTokens = contractTokenBalance
                .mul(_sDevelopmentFee)
                .add(_sPublicCampaignFee)
                .div(totalContractFees);
            if (swapTokens > 0) {
                uint256 bnbBefore = address(this).balance;
                swapTokensForEth(swapTokens);
                uint256 bnbDiff = address(this).balance.sub(bnbBefore);
                if (bnbDiff > 0) {
                    payable(developmentFundWallet).transfer(
                        bnbDiff.mul(_sDevelopmentFee).div(totalContractFees)
                    );
                    payable(publicCampaignFundWallet).transfer(
                        bnbDiff.mul(_sPublicCampaignFee).div(totalContractFees)
                    );
                }
            }
            //add liquidity
            swapAndLiquify(contractTokenBalance.sub(swapTokens));
            inSwapAndLiquify = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        if (amount == 0) return;
        if (
            _isExcludedFromFee[sender] ||
            _isExcludedFromFee[recipient] ||
            (sender != uniswapV2Pair && recipient != uniswapV2Pair)
        ) {
            removeAllFee();
        }

        //Calculate dev amount and campaign amount
        uint256 publicCampaignFee = _bPublicCampaignFee;
        uint256 developmentFee = _bDevelopmentFee;
        uint256 referralFee = _bReferralFee;
        if (recipient == uniswapV2Pair) {
            publicCampaignFee = _sPublicCampaignFee;
            developmentFee = _sDevelopmentFee;
            referralFee = _sReferralFee;
        }
        uint256 publicCampaignAmt = amount.mul(publicCampaignFee).div(100);

        uint256 devAmt = amount.mul(developmentFee).div(100);
        uint256 referralAmt = amount.mul(referralFee).div(100);
        uint256 takedFees = publicCampaignAmt.add(devAmt).add(referralAmt);

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, (amount.sub(takedFees)));
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, (amount.sub(takedFees)));
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, (amount.sub(takedFees)));
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, (amount.sub(takedFees)));
        } else {
            _transferStandard(sender, recipient, (amount.sub(takedFees)));
        }

        //Temporarily remove fees to transfer to dev address and public campaign fund wallet
        _bTaxFee = 0;
        _sTaxFee = 0;
        _bLiquidityFee = 0;
        _sLiquidityFee = 0;
        _bPublicCampaignFee = 0;
        _sPublicCampaignFee = 0;
        _bDevelopmentFee = 0;
        _sDevelopmentFee = 0;
        _bReferralFee = 0;
        _sReferralFee = 0;

        if (devAmt > 0) {
            _transferStandard(sender, address(this), devAmt);
        }
        if (publicCampaignAmt > 0) {
            _transferStandard(sender, address(this), publicCampaignAmt);
        }
        if (referralAmt > 0) {
            if (sender == uniswapV2Pair) {
                if (referrals[recipient] != address(0)) {
                    _transferStandard(
                        sender,
                        referrals[recipient],
                        referralAmt
                    );
                } else {
                    _transferStandard(sender, recipient, referralAmt);
                }
            } else if (recipient == uniswapV2Pair) {
                if (referrals[sender] != address(0)) {
                    _transferStandard(
                        recipient,
                        referrals[sender],
                        referralAmt
                    );
                } else {
                    _transferStandard(recipient, sender, referralAmt);
                }
            }
        }

        //Restore tax and liquidity fees
        _bTaxFee = _bPreviousTaxFee;
        _sTaxFee = _sPreviousTaxFee;
        _bLiquidityFee = _bPreviousLiquidityFee;
        _sLiquidityFee = _sPreviousLiquidityFee;
        _bPublicCampaignFee = _bPreviousPublicCampaignFee;
        _sPublicCampaignFee = _sPreviousPublicCampaignFee;
        _bDevelopmentFee = _bPreviousDevelopmentFee;
        _sDevelopmentFee = _sPreviousDevelopmentFee;
        _bReferralFee = _bPreviousReferralFee;
        _sReferralFee = _sPreviousReferralFee;

        if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient])
            restoreAllFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if (tAmount == 0) return;
        TxType txType = getTxType(sender, recipient);
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount, txType);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        if (tLiquidity > 0) {
            if (txType == TxType.Sell) {
                emit Transfer(sender, address(this), tLiquidity);
            } else if (txType == TxType.Buy) {
                emit Transfer(address(this), recipient, tLiquidity);
            }
        }
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if (tAmount == 0) return;
        TxType txType = getTxType(sender, recipient);
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount, txType);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        if (tLiquidity > 0) {
            if (txType == TxType.Sell) {
                emit Transfer(sender, address(this), tLiquidity);
            } else if (txType == TxType.Buy) {
                emit Transfer(address(this), recipient, tLiquidity);
            }
        }
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if (tAmount == 0) return;
        TxType txType = getTxType(sender, recipient);
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount, txType);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        if (tLiquidity > 0) {
            if (txType == TxType.Sell) {
                emit Transfer(sender, address(this), tLiquidity);
            } else if (txType == TxType.Buy) {
                emit Transfer(address(this), recipient, tLiquidity);
            }
        }
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setPublicCampaignFundWallet(address newWallet) external onlyOwner {
        publicCampaignFundWallet = newWallet;
    }

    function setDevelopmentFundWallet(address newWallet) external onlyOwner {
        developmentFundWallet = newWallet;
    }

    function setBuyFee(
        uint256 taxFee,
        uint256 liquidityFee,
        uint256 publicCampaignFee,
        uint256 referralFee,
        uint256 developmentFee
    ) external onlyOwner {
        require(
            taxFee
                .add(liquidityFee)
                .add(publicCampaignFee)
                .add(referralFee)
                .add(developmentFee) <= 25,
            "Fee must be less than 25%"
        );
        _bTaxFee = taxFee;
        _bLiquidityFee = liquidityFee;
        _bPublicCampaignFee = publicCampaignFee;
        _bReferralFee = referralFee;
        _bDevelopmentFee = developmentFee;
        _bPreviousTaxFee = _bTaxFee;
        _bPreviousLiquidityFee = _bLiquidityFee;
        _bPreviousPublicCampaignFee = _bPublicCampaignFee;
        _bPreviousReferralFee = _bReferralFee;
        _bPreviousDevelopmentFee = _bDevelopmentFee;
    }

    function setSellFee(
        uint256 taxFee,
        uint256 liquidityFee,
        uint256 publicCampaignFee,
        uint256 referralFee,
        uint256 developmentFee
    ) external onlyOwner {
        require(
            taxFee
                .add(liquidityFee)
                .add(publicCampaignFee)
                .add(referralFee)
                .add(developmentFee) <= 25,
            "Fee must be less than 25%"
        );
        _sTaxFee = taxFee;
        _sLiquidityFee = liquidityFee;
        _sPublicCampaignFee = publicCampaignFee;
        _sReferralFee = referralFee;
        _sDevelopmentFee = developmentFee;
        _sPreviousTaxFee = _sTaxFee;
        _sPreviousLiquidityFee = _sLiquidityFee;
        _sPreviousPublicCampaignFee = _sPublicCampaignFee;
        _sPreviousReferralFee = _sReferralFee;
        _sPreviousDevelopmentFee = _sDevelopmentFee;
    }

    function setNumTokensSellToAddLiquidity(
        uint256 newNumTokensSellToAddLiquidity
    ) external onlyOwner {
        numTokensSellToAddToLiquidity = newNumTokensSellToAddLiquidity;
    }

    function setRouterAddress(address newRouter) public onlyOwner {
        IUniswapV2Router02 _newPancakeRouter = IUniswapV2Router02(newRouter);
        uniswapV2Pair = IUniswapV2Factory(_newPancakeRouter.factory())
            .createPair(address(this), _newPancakeRouter.WETH());
        uniswapV2Router = _newPancakeRouter;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function buyBusd(uint256 amount) internal {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = _busd;

        try
            uniswapV2Router.swapExactETHForTokens{value: amount}(
                0,
                path,
                address(this),
                block.timestamp.add(30)
            )
        {} catch {
            revert();
        }
    }

    function getReferredAddresses(address referrer)
        public
        view
        returns (address[] memory)
    {
        return addressToRefs[referrer];
    }

    function getReferredAddressesCount(address referrer)
        public
        view
        returns (uint256)
    {
        return addressToRefs[referrer].length;
    }

    function purchase(uint256 bnbAmount, address ref) internal returns (bool) {
        // make sure we don't buy more than the bnb in this contract
        require(
            bnbAmount <= address(this).balance,
            "purchase not included in balance"
        );
        if (referrals[msg.sender] == address(0)) {
            if (ref == address(0)) {
                referrals[msg.sender] = msg.sender;
            } else {
                referrals[msg.sender] = ref;
                if (ref != msg.sender) {
                    addressToRefs[ref].push(msg.sender);
                }
            }
        }
        // previous amount of BUSD before we received any
        uint256 prevBusdAmount = IERC20(_busd).balanceOf(address(this));
        // buy BUSD with the BNB we received
        buyBusd(bnbAmount);
        // if this is the first purchase, use current balance
        uint256 currentBusdAmount = IERC20(_busd).balanceOf(address(this));
        // number of BUSD we have purchased
        uint256 difference = currentBusdAmount.sub(prevBusdAmount);
        // if this is the first purchase, use new amount
        prevBusdAmount = prevBusdAmount == 0
            ? currentBusdAmount
            : prevBusdAmount;
        // make sure total supply is greater than zero
        uint256 calculatedTotalSupply = _tTotal == 0
            ? _tTotal.add(10**18)
            : _tTotal;
        // apply our spread to tokens to inflate price relative to total supply
        uint256 totalBuyFee = _bTaxFee
            .add(_bLiquidityFee)
            .add(_bPublicCampaignFee)
            .add(_bDevelopmentFee)
            .add(_bReferralFee);
        uint256 currentRate = _getRate();
        uint256 totalFeesBUSD = difference.mul(totalBuyFee).div(100);
        IERC20(_busd).transfer(
            publicCampaignFundWallet,
            totalFeesBUSD.mul(_bPublicCampaignFee).div(totalBuyFee)
        );
        IERC20(_busd).transfer(
            developmentFundWallet,
            totalFeesBUSD.mul(_bDevelopmentFee).div(totalBuyFee)
        );
        if (referrals[msg.sender] != address(0)) {
            IERC20(_busd).transfer(
                referrals[msg.sender],
                totalFeesBUSD.mul(_bReferralFee).div(totalBuyFee)
            );
        } else {
            IERC20(_busd).transfer(
                msg.sender,
                totalFeesBUSD.mul(_bReferralFee).div(totalBuyFee)
            );
        }
        // find the number of tokens we should mint to keep up with the current price
        uint256 nShouldPurchase = calculatedTotalSupply
            .mul(difference.sub(totalFeesBUSD))
            .div(prevBusdAmount);

        uint256 tokensToSend = nShouldPurchase.mul(spreadDivisor).div(10**2);

        if (tokensToSend < 1) {
            revert("Must Buy More Than One");
        }

        // // mint the tokens we need to the buyer
        uint256 rTokenToSend = tokensToSend.mul(currentRate);
        _rOwned[msg.sender] = _rOwned[msg.sender].add(rTokenToSend);
        if(_isExcluded[msg.sender]) {
            _tOwned[msg.sender] = _tOwned[msg.sender].add(tokensToSend);
        }
        _tTotal = _tTotal.add(tokensToSend);
        // _rTotal = _tTotal.mul(currentRate);
        // _rTotal = _rTotal.add(tokensToSend.mul(currentRate));
        emit Transfer(address(this), msg.sender, tokensToSend);
        return true;
    }

    function sell(uint256 tokenAmount) public returns (bool) {
        require(internalTradingEnabled, "Internal trading is disabled");
        // make sure seller has this balance
        require(
            balanceOf(msg.sender) >= tokenAmount,
            "cannot sell above token amount"
        );

        // calculate the sell fee from this transaction
        uint256 totalSellFees = _sTaxFee
            .add(_sLiquidityFee)
            .add(_sPublicCampaignFee)
            .add(_sDevelopmentFee)
            .add(_sReferralFee);
        uint256 currentRate = _getRate();
        uint256 totalFeesTokens = tokenAmount.mul(totalSellFees).div(10**2);
        uint256 tokensToSwap = tokenAmount.sub(totalFeesTokens);
        _transfer(
            msg.sender,
            publicCampaignFundWallet,
            totalFeesTokens.mul(_sPublicCampaignFee).div(totalSellFees)
        );
        _transfer(
            msg.sender,
            developmentFundWallet,
            totalFeesTokens.mul(_sDevelopmentFee).div(totalSellFees)
        );
        if (referrals[msg.sender] != address(0)) {
            _transfer(
                msg.sender,
                referrals[msg.sender],
                totalFeesTokens.mul(_sReferralFee).div(totalSellFees)
            );
        } else {
            _transfer(
                msg.sender,
                publicCampaignFundWallet,
                totalFeesTokens.mul(_sPublicCampaignFee).div(totalSellFees)
            );
        }
        uint256 taxTokens = totalFeesTokens.mul(_sTaxFee).div(totalSellFees);
        _reflectFee(taxTokens.mul(currentRate), taxTokens);

        // how much BUSD are these tokens worth?
        uint256 amountBUSD = tokensToSwap.mul(calculatePrice()).div(10**18);

        // send BUSD to Seller
        bool successful = IERC20(_busd).transfer(msg.sender, amountBUSD);
        if (successful) {
            // subtract full amount from sender
            _transferStandard(msg.sender, address(0), tokensToSwap);
            if (_isExcluded[msg.sender]) {
                _tOwned[msg.sender] = _tOwned[msg.sender].sub(tokensToSwap);
            }
            _tTotal = _tTotal.sub(tokenAmount);
            // _rTotal = _rTotal.sub(tokensToSwap.mul(currentRate));
        } else {
            revert();
        }
        return true;
    }

    function enableInternalTrading() external onlyOwner {
        internalTradingEnabled = true;
    }

    function calculatePrice() public view returns (uint256) {
        uint256 busdBalance = IERC20(_busd).balanceOf(address(this));
        return busdBalance.mul(10**18).div(_tTotal);
    }

    function buy(address _ref) external payable {
        require(internalTradingEnabled, "Internal trading is disabled");
        uint256 val = msg.value;
        purchase(val, _ref);
    }

    function burn(uint256 _amount) public returns (bool) {
        require(
            balanceOf(msg.sender) >= _amount,
            "Cannot burn more than you have"
        );
        _transferStandard(msg.sender, address(0), _amount);
        uint256 currentRate = _getRate();
        if (_isExcluded[msg.sender]) {
            _tOwned[msg.sender] = _tOwned[msg.sender].sub(_amount);
        }
        _tTotal = _tTotal.sub(_amount);
        _rTotal = _rTotal.sub(_amount.mul(currentRate));
        return true;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}