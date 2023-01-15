/**
 *Submitted for verification at BscScan.com on 2023-01-15
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IDexRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

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
}

contract ReferralSystem {
    mapping(address => uint256) internal referralBalances;
    mapping(address => uint256) internal referralCount;

    uint256 public referralPercentage = 10;

    IDexRouter public constant ROUTER = IDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address internal constant STEP = 0x465707181ACba42Ed01268A33f0507e320a154bD;

    function buy(address referral) public payable {
        require(
            msg.sender != referral,
            "Referral and referee cannot be the same wallet"
        );
        (bool sent,) = payable(address(this)).call{value: msg.value, gas: 25000}("");
        
        address[] memory path = new address[](2);
        path[0] = ROUTER.WETH();
        path[1] = STEP;

        ROUTER.swapExactETHForTokens{value: msg.value/100*99}(
            msg.value/100*99,
            path,
            msg.sender,
            block.timestamp
        );

        uint256 referralFee = msg.value / 100;
        referralBalances[referral] += referralFee;
        referralCount[referral] += 1;
    }

    function balance(address referral) public view returns (uint256) {
        return referralBalances[referral];
    }

    function count(address referral) public view returns (uint256) {
        return referralCount[referral];
    }

    function claim(address referral) public {
        require(
            msg.sender == referral,
            "You cannot claim the referral earnings of someone else"
        );
        (bool claimed,) = payable(referral).call{value: referralBalances[referral], gas: 25000}("");
        referralBalances[referral] = 0;
    }
}