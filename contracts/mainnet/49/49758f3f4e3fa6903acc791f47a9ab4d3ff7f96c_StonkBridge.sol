// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./IBEP20.sol";
import "./Pancakeswap.sol";

/**
*   From Yolo Doggins with love <3
*/
contract StonkBridge is Ownable {
    string public name = "StonkBridge";

    address private constant _STONK_V1 = address(0x52FD0dB7597c332C0D3449A35F03625D881C3117);
    address private constant _STONK_V2 = address(0xC2973496E7c568D6EEcBF1d4234A24aa2FD71bd8);
    address private constant _WBNB = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

    address private constant _pancakeRouter = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    address[] private depoAddresses;
    mapping(address => uint) depoAmounts;

    uint64 public liquidityLock;
    uint64 public expiry = 1646074800;
    uint64 public constant exchangeRate = 80;       // 80%

    constructor() {}

    /**
    * Deposit Stonks V1 and receive Stonks V2.
    * Requires an approval of Stonks V1
    */
    function exchangeStonks(uint amount) external {
        require(
            block.timestamp < expiry,
            "BRIDGE_EXPIRED"
        );

        require(
            IBEP20(_STONK_V1).allowance(tx.origin, address(this)) >= amount,
            "INSUFFICIENT_ALLOWANCE"
        );

        uint balanceBefore = IBEP20(_STONK_V1).balanceOf(address(this));

        require(
            IBEP20(_STONK_V1).transferFrom(tx.origin, address(this), amount),
            "TRANSFER_ERROR"
        );

        amount = IBEP20(_STONK_V1).balanceOf(address(this)) - balanceBefore;

        addDepo(amount);

        amount = amount / 100 * exchangeRate;

        require(
            IBEP20(_STONK_V2).transfer(tx.origin, amount),
            "V2_TRANSFER_ERROR"
        );
    }

    function addDepo(uint amount) internal {
        if (depoAmounts[tx.origin] == 0) {
            depoAddresses.push(tx.origin);
            depoAmounts[tx.origin] = amount;

        } else {
            depoAmounts[tx.origin] += amount;
        }
    }

    /**
    * Exchange Stonk v1 for ETH and add the received BNB to the Stonk V2's LP
    */
    function exchangeLP() external onlyOwner {
        exchangeStonkV1();
        addLiquidity();
    }

    function exchangeStonkV1() public onlyOwner {
        require(
            block.timestamp > expiry,
            "BRIDGE_STILL_OPEN"
        );

        address[] memory path = new address[](2);
        path[0] = address(_STONK_V1);
        path[1] = address(_WBNB);

        uint v1Balance = IBEP20(_STONK_V1).balanceOf(address(this));
        IBEP20(_STONK_V1).approve(_pancakeRouter, v1Balance);

        IPancakeRouter02 pancakeRouter = IPancakeRouter02(_pancakeRouter);

        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            v1Balance,
            0,
            path,
            address(this),
            block.timestamp + 10000
        );
    }

    function addLiquidity() public onlyOwner {
        require(
            block.timestamp > expiry,
            "BRIDGE_STILL_OPEN"
        );

        uint v2Balance = IBEP20(_STONK_V2).balanceOf(address(this));
        IBEP20(_STONK_V2).approve(_pancakeRouter, v2Balance);

        IPancakeRouter02 pancakeRouter = IPancakeRouter02(_pancakeRouter);

        pancakeRouter.addLiquidityETH{value: payable(this).balance}(
            _STONK_V2,
            v2Balance,
            1,
            1,
            owner(),
            block.timestamp + 10000
        );
    }

    /**
    * Withdraw the remaining V2 stonk and BNB
    */
    function withdraw() external onlyOwner {
        require(
            block.timestamp > expiry,
            "BRIDGE_STILL_OPEN"
        );

        uint v2Balance = IBEP20(_STONK_V2).balanceOf(address(this));

        if (v2Balance > 0) {
            IBEP20(_STONK_V2).transfer(
                owner(),
                v2Balance
            );
        }

        if (payable(this).balance > 0) {
            payable(owner()).transfer(payable(this).balance);
        }
    }

    /**
    * Withdraw the remaining V1 stonk
    */
    function withdrawV1() external onlyOwner {
        require(
            block.timestamp > expiry,
            "BRIDGE_STILL_OPEN"
        );

        uint v1Balance = IBEP20(_STONK_V1).balanceOf(address(this));

        if (v1Balance > 0) {
            IBEP20(_STONK_V1).transfer(
                owner(),
                v1Balance
            );
        }
    }
    /**
    * Withdraw the remaining V2 stonk
    */
    function withdrawV2() external onlyOwner {
        require(
            block.timestamp > expiry,
            "BRIDGE_STILL_OPEN"
        );

        uint v2Balance = IBEP20(_STONK_V2).balanceOf(address(this));

        if (v2Balance > 0) {
            IBEP20(_STONK_V2).transfer(
                owner(),
                v2Balance
            );
        }
    }
    /**
    * Withdraw the remaining BNB
    */
    function withdrawBnb() external onlyOwner {
        require(
            block.timestamp > expiry,
            "BRIDGE_STILL_OPEN"
        );

        if (payable(this).balance > 0) {
            payable(owner()).transfer(payable(this).balance);
        }
    }

    /**
    * Extends expiry timestamp
    */
    function extendExpiry(uint64 amount) external onlyOwner {
        require(
            block.timestamp < expiry,
            "BRIDGE_CLOSED"
        );

        expiry += amount;
    }

    receive() external payable {}
}