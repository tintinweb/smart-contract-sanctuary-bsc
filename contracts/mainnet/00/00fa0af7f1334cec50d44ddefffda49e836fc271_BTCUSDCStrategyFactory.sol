/**
 *Submitted for verification at BscScan.com on 2022-09-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract BTCUSDCStrategyFactory {

    address payable banker;
    mapping(address => BTCUSDCStrategy) strategies;
    address[] owners;

    constructor() {
        banker = payable(msg.sender);
    }

    function createStrategy() public returns(BTCUSDCStrategy) {
        if(address(strategies[msg.sender]) != address(0x0)){
            return strategies[msg.sender];
        }else{
            BTCUSDCStrategy strategy = new BTCUSDCStrategy(banker);
            strategies[msg.sender] = strategy;
            owners.push(msg.sender);
            return strategy;
        }
    }

    function getStrategy(address _wallet) public view returns(BTCUSDCStrategy) {
        return strategies[_wallet];
    }

    function getOwner(uint index) public view returns(address) {
        return owners[index];
    }

    function getBanker() public view returns(address) {
        return banker;
    }

    function getTotalStrategies() public view returns(uint) {
        return owners.length;
    }
}

contract BTCUSDCStrategy {
    uint256 MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    address payable public owner;
    address payable public banker;

    uint public totalDeposit;
    uint totalSupply;
    uint totalBorrow;

    vToken vBTCB;
    vToken BTCB;
    vToken vUSDC;
    vToken USDC;
    vToken XVS;
    Unitroller unitroller;
    PancakeSwapRouter router;
    vOracle voracle;
    ChainLinkPriceFeed BTCUSDPriceFeed;
    ChainLinkPriceFeed USDCUSDPriceFeed;
    Comptroller comptroller;

    constructor(address payable _banker) {
        banker = _banker;
        owner = payable(tx.origin);
        totalDeposit = 0;

        vBTCB = vToken(0x882C173bC7Ff3b7786CA16dfeD3DFFfb9Ee7847B);
        BTCB = vToken(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c);
        vUSDC = vToken(0xecA88125a5ADbe82614ffC12D0DB554E2e2867C8);
        USDC = vToken(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d);
        XVS = vToken(0xcF6BB5389c92Bdda8a3747Ddb454cB7a64626C63);
        unitroller = Unitroller(0xfD36E2c2a6789Db23113685031d7F16329158384);
        router = PancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        voracle = vOracle(0x516c18DC440f107f12619a6d2cc320622807d0eE);
        BTCUSDPriceFeed = ChainLinkPriceFeed(
            0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf
        );
        USDCUSDPriceFeed = ChainLinkPriceFeed(
            0x51597f405303C4377E36123cBc172b13269EA163
        );
        comptroller = Comptroller(0xf6C14D4DFE45C132822Ce28c646753C54994E59C);
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier onlyBanker() {
        require(msg.sender == banker, "Only banker");
        _;
    }

    modifier onlyOwnerAndBanker() {
        require(
            msg.sender == owner || msg.sender == banker,
            "Only owner or banker"
        );
        _;
    }

    function getVenusAccrued() public view returns(uint){
        return unitroller.venusAccrued(address(this));
    }

    event claimedXVS(address _owner);
    /*
     * @title claim all XVS from Venus into the contract
     */
    function claimAllXVS() public onlyOwner {
        unitroller.claimVenus(address(this));
        emit claimedXVS(msg.sender);
    }

    event redeemedAllBNB(address _owner, uint _amount);

    /*
     * @title transfer all bnb back to owner
     */
    function redeemAllBNB() public onlyOwner {
        uint balance = address(this).balance;
        owner.transfer(balance);
        emit redeemedAllBNB(msg.sender, balance);
    }

    event redeemedAllOfToken(address _owner, address _token, uint _amount);

    /*
     * @title transfer all amount of a token back to owner
     */
    function redeemAllOf(address tokenAddress) public onlyOwner {
        vToken token = vToken(tokenAddress);
        uint balance = token.balanceOf(address(this));
        token.transfer(owner, balance);
        emit redeemedAllOfToken(msg.sender, tokenAddress, balance);
    }

    function getTotalSupplyInBTCB() public returns (uint) {
        return vBTCB.balanceOfUnderlying(address(this));
    }

    function getTotalSupplyInUSD() public returns (uint) {
        return
            getTotalSupplyInBTCB() *
            (voracle.getUnderlyingPrice(address(vBTCB)) / 1e18);
    }

    function getTotalBorrowInUSDC() public returns (uint) {
        return vUSDC.borrowBalanceCurrent(address(this));
    }

    event repaidUSDC(address _owner, uint _amount);

    function repayUSDC(uint amount) public onlyOwner {
        require(
            USDC.transferFrom(msg.sender, address(this), amount),
            "Error sending USDC to contract"
        );
        require(vUSDC.repayBorrow(amount) == 0, "Erorr repaying USDC!");
        emit repaidUSDC(msg.sender, amount);
    }

    event enteredStrategy(address _owner, uint _amount, uint loop);

    /*
     * @title Supply BTCB and loop multiple time to maximize exposure
     * @param amount is the amount of BTCB to supply
     * @param loop is the number of borrow-supply loop to do to increase exposure to BTCB
     */
    function enterStrategy(uint amount, uint loop) public onlyOwner {
        require(depositBTCB(amount), "Error depositing BTCB to contract!");
        require(supplyBTCB(amount) == 0, "Minting vBTC encounter error!");
        require(enterVBTCMarket() == 0, "Error entering vBTC market!");

        for (uint i = 0; i < loop; i++) {
            uint safeBorrowAmount = getSafeBorrowAmount();
            require(borrowUSDC(safeBorrowAmount) == 0, "Error borrowing USDC!");
            swapAllUSDCForBTCB();
            require(supplyAllBTCB() == 0, "Error supplying BTCB!");
        }
        emit enteredStrategy(msg.sender, amount, loop);
    }

    event exitedStrategy(address _owner);

    /*
     * @title Payback all borrow and withdraw all supply to owner address
     */
    function exitStrategy() public onlyOwner {
        uint totalUSDCBorrow = vUSDC.borrowBalanceCurrent(address(this));
        uint repaymentCounter = 0;
        USDC.approve(address(vUSDC), MAX_INT);
        while (totalUSDCBorrow > 0) {
            uint liquidity = getAccountLiquidityInUSD();
            uint amountToRedeem = liquidity;
            uint BTCBPrice = voracle.getUnderlyingPrice(address(vBTCB));
            uint BTCBToRedeem = amountToRedeem / (BTCBPrice / 1e18);
            require(
                vBTCB.redeemUnderlying(BTCBToRedeem) == 0,
                "Error redeeming BTCB!"
            );
            swapAllBTCBForUSDC();
            uint USDCToRepay = USDC.balanceOf(address(this));
            uint repayResult;
            if (USDCToRepay >= totalUSDCBorrow) {
                repayResult = vUSDC.repayBorrow(2**256 - 1);
            } else {
                repayResult = vUSDC.repayBorrow(USDCToRepay);
            }
            require(repayResult == 0, "Error repaying USDC!");
            totalUSDCBorrow = vUSDC.borrowBalanceCurrent(address(this));
            repaymentCounter++;
        }
        uint USDCLeft = USDC.balanceOf(address(this));
        if (USDCLeft > 0) {
            swapAllUSDCForBTCB();
        }
        uint vBTCBLeft = vBTCB.balanceOf(address(this));
        require(vBTCB.redeem(vBTCBLeft) == 0, "Error redeeming BTCB!");
        BTCB.transfer(owner, BTCB.balanceOf(address(this)));
        totalDeposit = 0;
        comptroller.claimVenus(address(this));
        if(XVS.balanceOf(address(this)) > 0){
            XVS.transfer(msg.sender, XVS.balanceOf(address(this)));
        }
        emit exitedStrategy(msg.sender);
    }

    /*
     * @title Increase borrow amount by taking on more loan
     * @param amount is the amount of USDC to borrow
     */
    function increaseBorrow(uint amount) public onlyOwner {
        uint liquidity = getAccountLiquidityInUSD();
        if (amount > liquidity) {
            revert("Amount exceeds liquidity");
        } else {
            require(borrowUSDC(amount) == 0, "Error borrowing USDC!");
            swapAllUSDCForBTCB();
            require(supplyAllBTCB() == 0, "Error supplying BTCB!");
        }
    }

    /*
     * @title reduce borrow by selling some BTC position
     * @param amount is the amount of USDC to pay
     */
    function reduceBorrow(uint amount) public onlyOwner {
        uint liquidity = getAccountLiquidityInUSD();
        if (amount > liquidity) {
            revert("Amount exceeds liquidity");
        }
        uint BTCBPrice = voracle.getUnderlyingPrice(address(vBTCB));
        uint BTCBToRedeem = liquidity / (BTCBPrice / 1e18);
        require(
            vBTCB.redeemUnderlying(BTCBToRedeem) == 0,
            "Error redeeming BTCB!"
        );
        swapAllBTCBForUSDC();
        if (amount > USDC.balanceOf(address(this))) {
            revert("Encounter unexpected high slippage when swap!");
        }
        USDC.approve(address(vUSDC), MAX_INT);
        require(vUSDC.repayBorrow(amount)==0,"Error repaying USDC");
        swapAllUSDCForBTCB();
        supplyAllBTCB();
    }

    //Private functions

    /*
     * @title msg.sender transfer BTCB to contract
     * @param amount is the amount of BTCB to transfer
     * @return true if success
     */
    function depositBTCB(uint amount) private returns (bool) {
        bool success = BTCB.transferFrom(msg.sender, address(this), amount);
        totalDeposit += amount;
        return success;
    }

    /*
     * @title supply BTCB to Venus Market
     * @param amount is the amount of BTCB to supply
     * @return 0 if success
     */
    function supplyBTCB(uint amount) private returns (uint) {
        BTCB.approve(
            address(vBTCB),
            MAX_INT
        ); //approve vBTCB contract to access BTCB of the msg.msg.sender
        return vBTCB.mint(amount);
    }

    /*
     * @title supply all BTCB to Venus Market
     * @param amount is the amount of BTCB to supply
     * @return 0 if success
     */
    function supplyAllBTCB() private returns (uint) {
        return vBTCB.mint(BTCB.balanceOf(address(this)));
    }

    /*
     * @title Enter BTC Market
     * @return 0 if success
     */
    function enterVBTCMarket() private returns (uint) {
        address[] memory tokensToEnterMarket = new address[](1);
        tokensToEnterMarket[0] = address(vBTCB);
        return unitroller.enterMarkets(tokensToEnterMarket)[0];
    }

    /*
     * @title Borrow USDC from Venus Market
     * @param amount is the amount of USDC to borrow
     * @return 0 if success
     */
    function borrowUSDC(uint amount) private returns (uint) {
        return vUSDC.borrow(amount);
    }

    /*
     * @title Calculate how much USDC is safe to borrow
     * @return Safe borrow amount
     */
    function getSafeBorrowAmount() private view returns (uint) {
        (uint error, uint liquidity, ) = unitroller.getAccountLiquidity(
            address(this)
        );
        require(error == 0, "Erorr getting borrowable amount");
        (, uint collateralFactorMantissa, ) = unitroller.markets(
            address(vBTCB)
        );
        uint borrowAmount = (liquidity *
            (collateralFactorMantissa / 1e16) *
            80) / 10000; //we wat to borrow 80% of the amount we can borrow
        return borrowAmount;
    }

    function getAccountLiquidityInUSD() private view returns (uint) {
        (uint error, uint liquidity, ) = unitroller.getAccountLiquidity(
            address(this)
        );
        require(error == 0, "Erorr getting borrowable amount");
        return liquidity;
    }

    /*
     * @title Swap "all" USDC the contract own to BTCB on Pancakeswap V2
     */
    function swapAllUSDCForBTCB() private {
        uint amountUSDC = USDC.balanceOf(address(this));

        address[] memory path;
        path = new address[](3);
        path[0] = address(USDC);
        path[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //busd
        path[2] = address(BTCB);
        uint[] memory mins = router.getAmountsOut(amountUSDC, path);
        uint minBTCB = mins[2];
        USDC.approve(address(router), MAX_INT);
        router.swapExactTokensForTokens(
            amountUSDC,
            minBTCB,
            path,
            address(this),
            block.timestamp
        );
    }

    /*
     * @title Swap "all" BTCB the contract own to USDC on Pancakeswap V2
     */
    function swapAllBTCBForUSDC() private {
        uint amountBTCB = BTCB.balanceOf(address(this));

        address[] memory path;
        path = new address[](3);
        path[0] = address(BTCB);
        path[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //busd
        path[2] = address(USDC);
        uint[] memory mins = router.getAmountsOut(amountBTCB, path);
        uint minUSDC = mins[2];
        BTCB.approve(address(router), MAX_INT);
        router.swapExactTokensForTokens(
            amountBTCB,
            minUSDC,
            path,
            address(this),
            block.timestamp
        );
    }
}

interface vToken {
    function mint() external payable;

    function mint(uint mintAmount) external returns (uint);

    function redeem(uint redeemTokens) external returns (uint);

    function redeemUnderlying(uint redeemAmount) external returns (uint);

    function balanceOf(address owner) external view returns (uint256 balance);

    function balanceOfUnderlying(address account) external returns (uint);

    function borrowRatePerBlock() external view returns (uint);

    function borrowBalanceCurrent(address account) external returns (uint);

    function borrow(uint borrowAmount) external returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function repayBorrow(uint repayAmount) external returns (uint);

    function exchangeRateCurrent() external returns (uint);

    function transfer(address dst, uint amount) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint amount
    ) external returns (bool);
}

abstract contract Unitroller {

    mapping(address => uint) public venusAccrued;
    function enterMarkets(address[] calldata vTokens)
        public virtual
        returns (uint[] memory);

    function exitMarket(address vToken) public virtual returns (uint);

    function claimVenus(address holder) public virtual;

    function getAccountLiquidity(address account)
        public virtual
        view
        returns (
            uint,
            uint,
            uint
        );

    function markets(address vTokenAddress)
        public virtual
        view
        returns (
            bool,
            uint,
            bool
        );
}

abstract contract Comptroller {
    mapping(address => uint) public venusAccrued;
    function claimVenus(address holder) virtual external;
}


interface vOracle {
    function getUnderlyingPrice(address vToken) external view returns (uint);
}

interface PancakeSwapRouter {
    function getAmountsOut(uint amountIn, address[] memory path)
        external
        view
        returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface ChainLinkPriceFeed {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}