//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./IUniswapV2Router02.sol";
import "./IPresaleDatabase.sol";

interface ITokenLocker {
    function giveDiscount(address user) external;
}

/**
    Presale contract talks to the liquidity pairer to have liquidity paired
 */
contract LiquidityPairer {

    // WETH - Wrapped BNB
    address public immutable WETH;

    // Type 0 = Restricted | Type 1 = Standard (Uniswap) | Type 2 = Balancer
    mapping ( address => uint8 ) public dexType;

    // Presale Database
    IPresaleDatabase public database;

    // Governance
    modifier onlyOwner {
        require(
            msg.sender == database.getOwner(),
            'Only Owner'
        );
        _;
    }

    constructor(
        address database_,
        address WETH_
    ) {
        database = IPresaleDatabase(database_);
        WETH = WETH_;
    }

    /** 
        Registers `DEX_` To Use Call Associated With `dexType_`
        @param DEX - Dex To Register
        @param dexType_ - Type Of Dex | 1 - Standard | 2 - Balancer
     */
    function registerDEX(address DEX, uint8 dexType_) external {
        require(
            dexType_ <= 2,
            'Invalid DEX Type'
        );

        dexType[DEX] = dexType_;
    }

    // Add require that only Sales can interact with this
    function pair(
        address projectToken,
        address backingToken,
        address DEX
    ) external {
        
        // sale is caller
        address sale = msg.sender;
        address saleOwner = database.getSaleOwner(sale);

        require(
            database.isSale(sale),
            'Only Presale Can Call'
        );
        require(
            saleOwner != address(0),
            'Zero Owner'
        );
        require(
            dexType[DEX] != 0,
            'Not Approved DEX'
        );
        require(
            balanceOf(projectToken) > 0,
            'Zero Project'
        );
        require(
            balanceOf(backingToken) > 0,
            'Zero Backing'
        );

        if (dexType[DEX] == 1) {
            _pairMakingStandardCall(projectToken, backingToken, DEX, saleOwner, sale);
        } else {
            _pairMakingBalancerCall(projectToken, backingToken, DEX, saleOwner, sale);
        }
    }

    function _pairMakingStandardCall(address projectToken, address backingToken, address DEX, address projectOwner, address sale) internal {
        
        // Fetch Balances In Contract
        uint nTokens = balanceOf(projectToken);
        uint nBacking = balanceOf(backingToken);

        // Approve Of DEX For Project Token
        IERC20(projectToken).approve(DEX, nTokens);

        // Instantiate DEX
        IUniswapV2Router02 router = IUniswapV2Router02(DEX);

        // If Backing Is BNB
        if (isWETH(backingToken)) {
            // Add Liquidity
            router.addLiquidityETH{value: nBacking}(
                projectToken,
                nTokens,
                nTokens,  // ensure first creation event
                nBacking, // ensure first creation event
                address(this),
                block.timestamp + 10
            );
        } else {
            // Approve DEX For Backing Token
            IERC20(backingToken).approve(DEX, nBacking);

            // Add Liquidity
            router.addLiquidity(
                projectToken,
                backingToken,
                nTokens,
                nBacking,
                nTokens,   // ensure first creation event
                nBacking,  // ensure first creation event
                address(this),
                block.timestamp + 10
            );
        }

        // Fetch LP Token Address
        address _pair = IUniswapV2Factory(router.factory()).getPair(projectToken, backingToken);

        // handle fee and LP distribution
        _handleFeesAndDistribution(_pair, projectOwner, sale);
    }

    function _pairMakingBalancerCall(address projectToken, address backingToken, address DEX, address projectOwner, address sale) internal {

        projectToken;
        backingToken;
        DEX;
        projectOwner;
        sale;
        dexType[projectToken] = 1;
        delete dexType[projectToken];
        
    }

    function _handleFeesAndDistribution(address _pair, address projectOwner, address sale) internal {

        // take fee out of accrued BNB and Tokens
        uint fee = database.getFee(sale);
        address receiver = database.getFeeReceiver();

        // take fee
        uint256 pairFee = IERC20(_pair).balanceOf(address(this)) * fee / 10**5;
        if (pairFee > 0 && receiver != address(0)) {
            IERC20(_pair).transfer(receiver, pairFee);
        }

        // send remaining LP tokens back to project owner
        IERC20(_pair).transfer(projectOwner, IERC20(_pair).balanceOf(address(this)));

        // give project owner a lock discount
        address locker = database.tokenLocker();
        if (locker != address(0)) {
            ITokenLocker(locker).giveDiscount(projectOwner);
        }
    }

    function isWETH(address token) public view returns (bool) {
        return token == WETH;
    }

    function balanceOf(address token) public view returns (uint256) {
        return isWETH(token) ? address(this).balance : IERC20(token).balanceOf(address(this));
    }

    receive() external payable {}
}