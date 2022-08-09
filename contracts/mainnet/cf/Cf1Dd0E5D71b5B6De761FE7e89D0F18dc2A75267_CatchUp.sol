// SPDX-License-Identifier: MIT

// Developed by TrendsHub LLC

pragma solidity 0.8.15;
import "./tools.sol";

contract CatchUp is ERC20, Ownable {
    uint256 public  liquidityFeeOnBuy   = 0;
    uint256 public  liquidityFeeOnSell  = 0;

    uint256 public  teamFeeOnBuy      = 2;
    uint256 public  teamFeeOnSell     = 2;

    uint256 private _totalFeesOnBuy     = 4;
    uint256 private _totalFeesOnSell    = 4;

    address public teamVestingWallet=0x38d292689d0a66325c3D65993D64bA36414103e5; //Team Vesting


    bool public walletToWalletTransferWithoutFee;
    bool public zeroTax;
    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;

    address private DEAD = 0x000000000000000000000000000000000000dEaD;

    bool    private swapping;
    uint256 public swapTokensAtAmount;

    mapping (address => bool) private _isExcludedFromFees;

    event ExcludeFromFees(address indexed account);
    event MarketingWalletChanged(address marketingWallet);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);
    event SendMarketing(uint256 bnbSend);
    event UpdateBuyFees(uint256 liquidityFeeOnBuy, uint256 teamFeeOnBuy);
    event UpdateSellFees(uint256 liquidityFeeOnSell, uint256 teamFeeOnSell);
    event TeamWalletChanged(address teamWallet);
    event SendTeam(uint256 bnbSend);

    constructor (address newOwner) ERC20("Catch Up", "CU"){
        transferOwnership(newOwner);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair   = _uniswapV2Pair;

        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[DEAD] = true;
        _isExcludedFromFees[address(this)] = true;
        _mint(owner(), 104_199_218_705 * (10 ** 17));

        swapTokensAtAmount = 104_199_218_705 * (10 ** 17) / 5000;
    }

    receive() external payable {

  	}

    function claimStuckTokens(address token) external onlyOwner {
        require(token != address(this), "Owner cannot claim native tokens");
        if (token == address(0x0)) {
            payable(msg.sender).transfer(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendBNB(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function TrueBurn(uint256 amount) external onlyOwner {
            _burn(owner(), amount);
            }

    //=======FeeManagement=======//
    function excludeFromFees(address account) external onlyOwner {
        require(!_isExcludedFromFees[account], "Account is already the value of true");
        _isExcludedFromFees[account] = true;

        emit ExcludeFromFees(account);
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function updateBuyFees(uint256 _liquidityFeeOnBuy, uint256 _teamFeeOnBuy) external onlyOwner {
        require(
            _liquidityFeeOnBuy  + _teamFeeOnBuy <= 25,
            "Fees must be less than 25%"
        );
        liquidityFeeOnBuy = _liquidityFeeOnBuy;
        teamFeeOnBuy    = _teamFeeOnBuy;
        _totalFeesOnBuy   = liquidityFeeOnBuy  + teamFeeOnBuy;
        emit UpdateBuyFees(_liquidityFeeOnBuy, _teamFeeOnBuy);
    }

    function updateSellFees(uint256 _liquidityFeeOnSell, uint256 _teamFeeOnSell) external onlyOwner {
        require(
            _liquidityFeeOnSell + _teamFeeOnSell <= 25,
            "Fees must be less than 25%"
        );
        liquidityFeeOnSell = _liquidityFeeOnSell;
        teamFeeOnSell    = _teamFeeOnSell;
        _totalFeesOnSell   = liquidityFeeOnSell  + teamFeeOnSell;
        emit UpdateSellFees(_liquidityFeeOnSell, _teamFeeOnSell);
    }

    function enableWalletToWalletTransferWithoutFee(bool enable) external onlyOwner {
        require(walletToWalletTransferWithoutFee != enable, "Wallet to wallet transfer without fee is already set to that value");
        walletToWalletTransferWithoutFee = enable;
    }



    function changeTeamWallet(address _teamWallet) external onlyOwner {
        require(_teamWallet != teamVestingWallet, "TeamVesting wallet is already that address");
        require(!isContract(_teamWallet), "TeamVesting wallet cannot be a contract");
        teamVestingWallet = _teamWallet;
        emit TeamWalletChanged(teamVestingWallet);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal  override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

		uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if( canSwap &&
            !swapping &&
            from != uniswapV2Pair
        ) {
            swapping = true;

            uint256 totalFee = _totalFeesOnBuy + _totalFeesOnSell;
            uint256 liquidityShare = liquidityFeeOnBuy + liquidityFeeOnSell;
            uint256 teamShare    = teamFeeOnBuy    + teamFeeOnSell;

            uint256 liquidityTokens;
            if(liquidityShare > 0) {
                liquidityTokens = (contractTokenBalance * liquidityShare) / totalFee;
                swapAndLiquify(liquidityTokens);
            }

            contractTokenBalance -= liquidityTokens;
            uint256 bnbShare = teamShare;

            if(contractTokenBalance > 0 && bnbShare > 0) {
                uint256 initialBalance = address(this).balance;

                address[] memory path = new address[](2);
                path[0] = address(this);
                path[1] = uniswapV2Router.WETH();

                uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                    contractTokenBalance,
                    0,
                    path,
                    address(this),
                    block.timestamp);

                uint256 newBalance = address(this).balance - initialBalance;



                if(teamShare > 0) {
                    uint256 teamBNB = (newBalance * teamShare) / bnbShare;
                    sendBNB(payable(teamVestingWallet), teamBNB);
                    emit SendTeam(teamBNB);
                }
            }
            swapping = false;
        }

        bool takeFee = !swapping;

        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(walletToWalletTransferWithoutFee && from != uniswapV2Pair && to != uniswapV2Pair) {
            takeFee = false;
        }

        if(takeFee && !zeroTax) {
            uint256 _totalFees;

            if(from == uniswapV2Pair) {
                _totalFees = _totalFeesOnBuy;
            } else {
                _totalFees = _totalFeesOnSell;
            }

            if( _totalFees > 0 ){
                uint256 fees = amount * _totalFees / 100;

                amount = amount - fees;

                super._transfer(from, teamVestingWallet, fees);
            }
        }

        super._transfer(from, to, amount);

    }

    //=======Swap=======//
    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;

        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            half,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp);

        uint256 newBalance = address(this).balance - initialBalance;

        uniswapV2Router.addLiquidityETH{value: newBalance}(
            address(this),
            otherHalf,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            DEAD,
            block.timestamp
        );

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function setSwapTokensAtAmount(uint256 newAmount) external onlyOwner{
        require(newAmount > totalSupply() / 100000, "SwapTokensAtAmount must be greater than 0.001% of total supply");
        swapTokensAtAmount = newAmount;
    }

    function zeroTaxDay(bool enable) external onlyOwner{
        require(zeroTax!=enable,"Marketing wallet is already that enable");
        zeroTax = enable;
    }
}