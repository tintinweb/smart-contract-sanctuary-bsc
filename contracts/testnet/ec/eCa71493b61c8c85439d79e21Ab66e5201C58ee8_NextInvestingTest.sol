/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function mint(address _to, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IPancakeSwapPair {
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

interface IPancakeSwapRouter {
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

contract NextInvestingTest {
    using SafeMath for uint256;
    using SafeMath for uint8;

    uint256 public constant INVEST_MIN_AMOUNT = 5 ether; // 5 USD
    uint256 public constant RESTAKE_MIN_AMOUNT = 0.05 ether; //0.05 USD
    uint256[] public REFERRAL_PERCENTS = [30, 20, 10, 10, 5];
    uint256 public constant TOTAL_REF = 75; // 7.5%

    uint256 public constant COMPOUND_PERCENT = 500; // Compound 50% every withdrawal

    uint256 public constant PROJECT_FEE = 30;
    uint256 public constant FUND_FEE = 30;
    uint256 public constant MARKETING_FEE = 30;
    uint256 public constant SPONSOR_FEE = 30;

    uint256 public constant SWAP_FEE = 5;
    uint256 public constant SWAP_REWARDS = 5;

    uint256 public constant PERCENTS_DIVIDER = 1000;
    uint256 public constant TIME_STEP = 1 minutes;

    IBEP20 public BUSD = IBEP20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
    IBEP20 public USDT = IBEP20(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
    IBEP20 public USDC = IBEP20(0x8a9424745056Eb399FD19a0EC26A14316684e274);
    IBEP20 public DAI = IBEP20(0x8a9424745056Eb399FD19a0EC26A14316684e274);

    IPancakeSwapRouter public router =
        IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    uint256 public totalStaked;
    uint256 public totalRefBonus;
    uint256 public totalDeposits;
    uint256 public totalTradingVolume;

    struct Plan {
        uint256 time;
        uint256 percent;
    }

    Plan[] internal plans;
    IBEP20[] public tokens;

    struct Deposit {
        uint8 plan;
        uint256 percent;
        uint256 amount;
        uint256 profit;
        uint256 start;
        uint256 finish;
    }

    struct User {
        Deposit[] deposits;
        Deposit[] swapDeposits;
        uint256 checkpoint;
        uint256 swapCheckpoint;
        address payable referrer;
        uint256 referrals;
        uint256 totalBonus;
        uint256 withdrawn;
        uint256 swapTurnover;
    }

    mapping(address => User) internal users;

    uint256 public startDate;

    address payable public WALLET_PROJECT;
    address payable public WALLET_MARKETING;
    address payable public WALLET_FUND;
    address payable public WALLET_SPONSOR;

    event Newbie(address user);
    event NewDeposit(
        address indexed user,
        uint8 plan,
        uint256 percent,
        uint256 amount,
        uint256 profit,
        uint256 start,
        uint256 finish
    );
    event Withdrawn(address indexed user, uint256 amount);
    event RefBonus(
        address indexed referrer,
        address indexed referral,
        uint256 indexed level,
        uint256 amount
    );
    event Swap(address indexed token0, address indexed token1, uint256 amount);
    event FeePayed(address indexed user, uint256 totalAmount);

    constructor(
        address payable _walletMarketing,
        address payable _walletFund,
        address payable _walletSponsor,
        uint256 startTime
    ) {
        require(
            !isContract(_walletMarketing) &&
                !isContract(_walletFund) &&
                !isContract(_walletSponsor)
        );
        require(
            _walletMarketing != address(0) &&
                _walletFund != address(0) &&
                _walletSponsor != address(0)
        );

        WALLET_PROJECT = payable(msg.sender);
        WALLET_MARKETING = _walletMarketing;
        WALLET_FUND = _walletFund;
        WALLET_SPONSOR = _walletSponsor;

        if (startTime > 0) {
            startDate = startTime;
        } else {
            startDate = block.timestamp;
        }

        _status = _NOT_ENTERED;

        plans.push(Plan(25, 80)); // 8% per day for 25 days = 200% ROI

        tokens.push(BUSD);
        tokens.push(USDT);
        tokens.push(USDC);
        tokens.push(DAI);
    }

    function UpdateStartDate(uint256 _startDate) public {
        require(msg.sender == WALLET_PROJECT);
        require(block.timestamp < startDate, "Start date must be in future");
        startDate = _startDate;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function FeePayout(uint256 msgValue) internal {
        uint256 pFee = msgValue.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
        uint256 fFee = msgValue.mul(FUND_FEE).div(PERCENTS_DIVIDER);
        uint256 mFee = msgValue.mul(MARKETING_FEE).div(PERCENTS_DIVIDER);
        uint256 sFee = msgValue.mul(SPONSOR_FEE).div(PERCENTS_DIVIDER);

        BUSD.transfer(WALLET_PROJECT, pFee);
        BUSD.transfer(WALLET_FUND, fFee);
        BUSD.transfer(WALLET_MARKETING, mFee);
        BUSD.transfer(WALLET_SPONSOR, sFee);

        emit FeePayed(msg.sender, fFee.add(pFee).add(mFee).add(sFee));
    }

    function FeePayoutSwap(uint256 msgValue, address tokenId) internal {
        IBEP20 _tokenSwap = IBEP20(tokenId);

        uint256 swapfeePay = msgValue;
        uint256 swapfeeCalculated = msgValue.div(4);

        _tokenSwap.transfer(WALLET_PROJECT, swapfeeCalculated);
        swapfeePay = swapfeePay.sub(swapfeeCalculated);
        _tokenSwap.transfer(WALLET_FUND, swapfeeCalculated);
        swapfeePay = swapfeePay.sub(swapfeeCalculated);
        _tokenSwap.transfer(WALLET_MARKETING, swapfeeCalculated);
        swapfeePay = swapfeePay.sub(swapfeeCalculated);
        _tokenSwap.transfer(WALLET_SPONSOR, swapfeePay);

        emit FeePayed(msg.sender, msgValue);
    }

    function FeePayoutSwapBNB(uint256 msgValue) internal {
        uint256 swapfeePay = msgValue;
        uint256 swapfeeCalculated = msgValue.div(4);

        WALLET_PROJECT.transfer(swapfeeCalculated);
        swapfeePay = swapfeePay.sub(swapfeeCalculated);
        WALLET_FUND.transfer(swapfeeCalculated);
        swapfeePay = swapfeePay.sub(swapfeeCalculated);
        WALLET_MARKETING.transfer(swapfeeCalculated);
        swapfeePay = swapfeePay.sub(swapfeeCalculated);
        WALLET_SPONSOR.transfer(swapfeePay);

        emit FeePayed(msg.sender, msgValue);
    }

    function invest(
        address payable referrer,
        uint8 plan,
        uint256 tokenId,
        uint256 amount
    ) public {
        _invest(referrer, plan, msg.sender, amount, tokenId);
    }

    function _invest(
        address payable referrer,
        uint8 plan,
        address payable sender,
        uint256 value,
        uint256 tokenId
    ) private {
        require(value >= INVEST_MIN_AMOUNT);
        require(plan < 1, "Invalid plan");
        require(startDate < block.timestamp, "contract hasn`t started yet");
        require(tokenId < 4, "Invalid token id");

        if (tokenId == 0) {
            //BUSD
            BUSD.transferFrom(sender, address(this), value);
        } else {
            if (tokenId == 1) {
                //USDT
                USDT.transferFrom(sender, address(this), value);
            }

            if (tokenId == 2) {
                //USDC
                USDC.transferFrom(sender, address(this), value);
            }

            if (tokenId == 3) {
                //DAI
                DAI.transferFrom(sender, address(this), value);
            }

            value = swapTokensForBusd(tokenId, value);
        }

        FeePayout(value);

        User storage user = users[sender];

        if (user.referrer == address(0)) {
            if (users[referrer].deposits.length > 0 && referrer != sender) {
                user.referrer = referrer;
            }

            address upline = user.referrer;
            for (uint256 i = 0; i < 5; i++) {
                if (upline != address(0)) {
                    users[upline].referrals = users[upline].referrals.add(1);
                    upline = users[upline].referrer;
                } else break;
            }
        }
        uint256 refsamount = 0;
        if (user.referrer != address(0)) {
            uint256 _refBonus = 0;
            address payable upline = user.referrer;
            for (uint256 i = 0; i < 5; i++) {
                if (upline != address(0)) {
                    uint256 amount = value.mul(REFERRAL_PERCENTS[i]).div(
                        PERCENTS_DIVIDER
                    );

                    users[upline].totalBonus = users[upline].totalBonus.add(
                        amount
                    );
                    BUSD.transfer(upline, amount);
                    _refBonus = _refBonus.add(amount);

                    emit RefBonus(upline, sender, i, amount);
                    upline = users[upline].referrer;
                } else {
                    uint256 amount = value.mul(REFERRAL_PERCENTS[i]).div(
                        PERCENTS_DIVIDER
                    );
                    refsamount = refsamount.add(amount);
                }
            }

            if (refsamount > 0) {
                FeePayoutSwap(refsamount, address(tokens[0]));
                totalRefBonus = totalRefBonus.add(refsamount);
            }

            totalRefBonus = totalRefBonus.add(_refBonus);
        } else {
            uint256 amount = value.mul(TOTAL_REF).div(PERCENTS_DIVIDER);
            FeePayoutSwap(amount, address(tokens[0]));
            totalRefBonus = totalRefBonus.add(amount);
        }

        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
            emit Newbie(sender);
        }

        (uint256 percent, uint256 profit, uint256 finish) = getResult(
            plan,
            value
        );

        user.deposits.push(
            Deposit(plan, percent, value, profit, block.timestamp, finish)
        );

        totalStaked = totalStaked.add(value);
        totalDeposits = totalDeposits.add(1);

        emit NewDeposit(
            sender,
            plan,
            percent,
            value,
            profit,
            block.timestamp,
            finish
        );
    }

    function autoreStake(uint256 toReinvest) internal {
        User storage user = users[msg.sender];

        require(
            user.checkpoint.add(TIME_STEP) <= block.timestamp,
            "It`s not time to reinvest or withdraw"
        );

        require(toReinvest > 0, "User has no amount to reinvest");

        FeePayout(toReinvest);

        (uint256 percent, uint256 profit, uint256 finish) = getResult(
            0,
            toReinvest
        );

        user.deposits.push(
            Deposit(0, percent, toReinvest, profit, block.timestamp, finish)
        );

        totalStaked = totalStaked.add(toReinvest);
        totalDeposits = totalDeposits.add(1);

        emit NewDeposit(
            msg.sender,
            0,
            percent,
            toReinvest,
            profit,
            block.timestamp,
            finish
        );
    }

    function reStake() public {
        require(startDate < block.timestamp, "contract hasn`t started yet");

        User storage user = users[msg.sender];

        require(
            user.checkpoint.add(TIME_STEP) <= block.timestamp,
            "It`s not time to reinvest"
        );

        uint256 totalAmount = getUserDividends(msg.sender);

        require(totalAmount >= RESTAKE_MIN_AMOUNT, "Invalid amount");

        FeePayout(totalAmount);

        (uint256 percent, uint256 profit, uint256 finish) = getResult(
            0,
            totalAmount
        );

        user.deposits.push(
            Deposit(0, percent, totalAmount, profit, block.timestamp, finish)
        );

        user.checkpoint = block.timestamp;
        user.withdrawn = user.withdrawn.add(totalAmount);

        totalStaked = totalStaked.add(totalAmount);
        totalDeposits = totalDeposits.add(1);

        emit NewDeposit(
            msg.sender,
            0,
            percent,
            totalAmount,
            profit,
            block.timestamp,
            finish
        );
    }

    function withdraw() public {
        User storage user = users[msg.sender];

        uint256 totalAmount = getUserDividends(msg.sender);
        require(totalAmount > 0, "User has no dividends");

        uint256 contractBalance = BUSD.balanceOf(address(this));
        if (contractBalance < totalAmount) {
            totalAmount = contractBalance;
        }

        uint256 autoCompound = totalAmount.mul(COMPOUND_PERCENT).div(
            PERCENTS_DIVIDER
        );

        autoreStake(autoCompound);

        user.checkpoint = block.timestamp;
        user.withdrawn = user.withdrawn.add(totalAmount);

        BUSD.transfer(msg.sender, totalAmount.sub(autoCompound));

        emit Withdrawn(msg.sender, totalAmount.sub(autoCompound));
    }

    function claimSwapRewards() public {
        User storage user = users[msg.sender];

        uint256 totalAmount = getUserSwapDividends(msg.sender);

        require(totalAmount > 0, "User has no rewards");

        uint256 contractBalance = BUSD.balanceOf(address(this));
        if (contractBalance < totalAmount) {
            totalAmount = contractBalance;
        }

        user.swapCheckpoint = block.timestamp;

        user.withdrawn = user.withdrawn.add(totalAmount);
        BUSD.transfer(msg.sender, totalAmount);

        emit Withdrawn(msg.sender, totalAmount);
    }

    function addSwapDeposit(uint256 value, address sender) private {
        User storage user = users[sender];

        if (user.swapDeposits.length == 0) {
            user.swapCheckpoint = block.timestamp;
            emit Newbie(sender);
        }

        (uint256 percent, uint256 profit, uint256 finish) = getResult(0, value);

        user.swapDeposits.push(
            Deposit(0, percent, value, profit, block.timestamp, finish)
        );

        totalStaked = totalStaked.add(value);

        emit NewDeposit(
            sender,
            0,
            percent,
            value,
            profit,
            block.timestamp,
            finish
        );
    }

    function swapTokensForBusd(uint256 tokenId, uint256 amount)
        private
        nonReentrant
        returns (uint256)
    {
        IBEP20 _token = tokens[tokenId];

        address[] memory path = new address[](2);
        path[0] = address(_token); //token we want to swap
        path[1] = address(BUSD); //token we want to get

        uint256 contractBalanceBefore = BUSD.balanceOf(address(this));

        _token.approve(address(router), amount);

        router.swapExactTokensForTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 contractBalanceAfter = BUSD.balanceOf(address(this));

        uint256 depositedAmount = contractBalanceAfter.sub(
            contractBalanceBefore
        );

        return depositedAmount;
    }

    function swap(
        uint256 tokenId0,
        uint256 tokenId1,
        uint256 amount
    ) public {
        require(startDate < block.timestamp, "contract hasn`t started yet");
        require(tokenId0 < 4, "Invalid token in");
        require(tokenId1 < 4, "Invalid token out");

        IBEP20 _token0 = tokens[tokenId0];
        IBEP20 _token1 = tokens[tokenId1];

        _token0.transferFrom(msg.sender, address(this), amount);

        uint256 feeValue = amount.mul(SWAP_FEE).div(PERCENTS_DIVIDER);

        FeePayoutSwap(feeValue, address(tokens[tokenId0]));

        uint256 newAmount = amount.sub(feeValue);

        address[] memory path = new address[](2);
        path[0] = address(_token0); //token we want to swap
        path[1] = address(_token1); //token we want to get

        _token0.approve(address(router), newAmount);

        router.swapExactTokensForTokens(
            newAmount,
            0,
            path,
            msg.sender,
            block.timestamp
        );

        uint256 swapRewards = amount.mul(SWAP_REWARDS).div(PERCENTS_DIVIDER);

        addSwapDeposit(swapRewards, msg.sender);

        User storage user = users[msg.sender];

        user.swapTurnover = user.swapTurnover.add(amount);
        totalTradingVolume = totalTradingVolume.add(amount);

        emit Swap(path[0], path[1], newAmount);
    }

    function swapTokensForBnb(uint256 tokenId, uint256 amount) public {
        require(startDate < block.timestamp, "contract hasn`t started yet");
        require(tokenId < 4, "Invalid tokenId");

        IBEP20 _token = tokens[tokenId];

        _token.transferFrom(msg.sender, address(this), amount);

        uint256 feeValue = amount.mul(SWAP_FEE).div(PERCENTS_DIVIDER);

        FeePayoutSwap(feeValue, address(tokens[tokenId]));

        uint256 newAmount = amount.sub(feeValue);

        address[] memory path = new address[](2);
        path[0] = address(_token);
        path[1] = router.WETH();

        _token.approve(address(router), newAmount);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            newAmount,
            0,
            path,
            msg.sender,
            block.timestamp
        );

        uint256 swapRewards = amount.mul(SWAP_REWARDS).div(PERCENTS_DIVIDER);

        addSwapDeposit(swapRewards, msg.sender);

        User storage user = users[msg.sender];

        user.swapTurnover = user.swapTurnover.add(amount);
        totalTradingVolume = totalTradingVolume.add(amount);

        emit Swap(path[0], path[1], newAmount);
    }

    function swapBnbForTokens(uint256 tokenId) public payable {
        require(startDate < block.timestamp, "contract hasn`t started yet");
        require(tokenId < 4, "Invalid tokenId");

        IBEP20 _token = tokens[tokenId];

        uint256 feeValue = msg.value.mul(SWAP_FEE).div(PERCENTS_DIVIDER);

        FeePayoutSwapBNB(feeValue);

        uint256 newAmount = msg.value.sub(feeValue);

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(_token);

        router.swapExactETHForTokens{value: newAmount}(
            0,
            path,
            msg.sender,
            block.timestamp.add(300)
        );

        uint256 expectedOut = router.getAmountsOut(msg.value, path)[1];

        uint256 swapRewards = expectedOut.mul(SWAP_REWARDS).div(
            PERCENTS_DIVIDER
        );

        addSwapDeposit(swapRewards, msg.sender);

        User storage user = users[msg.sender];

        user.swapTurnover = user.swapTurnover.add(expectedOut);
        totalTradingVolume = totalTradingVolume.add(expectedOut);

        emit Swap(path[0], path[1], newAmount);
    }

    function getContractBalance() public view returns (uint256) {
        return BUSD.balanceOf(address(this));
    }

    function getPlanInfo(uint8 plan)
        public
        view
        returns (uint256 time, uint256 percent)
    {
        time = plans[plan].time;
        percent = plans[plan].percent;
    }

    function getPercent(uint8 plan) public view returns (uint256) {
        return plans[plan].percent;
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }

    function getResult(uint8 plan, uint256 deposit)
        public
        view
        returns (
            uint256 percent,
            uint256 profit,
            uint256 finish
        )
    {
        percent = getPercent(plan);

        profit = deposit.mul(percent).div(PERCENTS_DIVIDER).mul(
            plans[plan].time
        );

        finish = block.timestamp.add(plans[plan].time.mul(TIME_STEP));
    }

    function getUserDividends(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = users[userAddress];

        uint256 totalAmount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            if (user.checkpoint < user.deposits[i].finish) {
                uint256 share = user
                    .deposits[i]
                    .amount
                    .mul(user.deposits[i].percent)
                    .div(PERCENTS_DIVIDER);
                uint256 from = user.deposits[i].start > user.checkpoint
                    ? user.deposits[i].start
                    : user.checkpoint;
                uint256 to = user.deposits[i].finish < block.timestamp
                    ? user.deposits[i].finish
                    : block.timestamp;
                if (from < to) {
                    totalAmount = totalAmount.add(
                        share.mul(to.sub(from)).div(TIME_STEP)
                    );
                }

                if (block.timestamp > user.deposits[i].finish) {
                    totalAmount = totalAmount.add(user.deposits[i].amount);
                }
            }
        }

        return totalAmount;
    }

    function getUserSwapDividends(address userAddress)
        public
        view
        returns (uint256)
    {
        User storage user = users[userAddress];

        uint256 totalAmount;

        for (uint256 i = 0; i < user.swapDeposits.length; i++) {
            if (user.swapCheckpoint < user.swapDeposits[i].finish) {
                uint256 share = user
                    .swapDeposits[i]
                    .amount
                    .mul(user.swapDeposits[i].percent)
                    .div(PERCENTS_DIVIDER);
                uint256 from = user.swapDeposits[i].start > user.swapCheckpoint
                    ? user.swapDeposits[i].start
                    : user.swapCheckpoint;
                uint256 to = user.swapDeposits[i].finish < block.timestamp
                    ? user.swapDeposits[i].finish
                    : block.timestamp;
                if (from < to) {
                    totalAmount = totalAmount.add(
                        share.mul(to.sub(from)).div(TIME_STEP)
                    );
                }

                if (block.timestamp > user.swapDeposits[i].finish) {
                    totalAmount = totalAmount.add(user.swapDeposits[i].amount);
                }
            }
        }

        return totalAmount;
    }

    function getContractInfo()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (totalStaked, totalRefBonus, totalDeposits, totalTradingVolume);
    }

    function getUserWithdrawn(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].withdrawn;
    }

    function getUserCheckpoint(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].checkpoint;
    }

    function getUserReferrer(address userAddress)
        public
        view
        returns (address)
    {
        return users[userAddress].referrer;
    }

    function getUserDownlineCount(address userAddress)
        public
        view
        returns (uint256)
    {
        return (users[userAddress].referrals);
    }

    function getUserReferralTotalBonus(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].totalBonus;
    }

    function getUserAmountOfDeposits(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].deposits.length;
    }

    function getUserTotalDeposits(address userAddress)
        public
        view
        returns (uint256 amount)
    {
        for (uint256 i = 0; i < users[userAddress].deposits.length; i++) {
            amount = amount.add(users[userAddress].deposits[i].amount);
        }
    }

    function getUserTotalSwapDeposits(address userAddress)
        public
        view
        returns (uint256 amount)
    {
        for (uint256 i = 0; i < users[userAddress].swapDeposits.length; i++) {
            amount = amount.add(users[userAddress].swapDeposits[i].amount);
        }
    }

    function getUserSwapTurnover(address userAddress)
        public
        view
        returns (uint256)
    {
        return users[userAddress].swapTurnover;
    }

    function getUserDepositInfo(address userAddress, uint256 index)
        public
        view
        returns (
            uint8 plan,
            uint256 percent,
            uint256 amount,
            uint256 profit,
            uint256 start,
            uint256 finish
        )
    {
        User storage user = users[userAddress];

        plan = user.deposits[index].plan;
        percent = user.deposits[index].percent;
        amount = user.deposits[index].amount;
        profit = user.deposits[index].profit;
        start = user.deposits[index].start;
        finish = user.deposits[index].finish;
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}