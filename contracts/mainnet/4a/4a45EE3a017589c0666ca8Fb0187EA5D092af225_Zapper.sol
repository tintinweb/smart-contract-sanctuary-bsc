//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./IUniswapV2Router02.sol";

interface IAutoFarm {
    function deposit(address user, uint256 amount) external;
}

interface IMDB {
    function buyFeeRecipient() external view returns (address);
    function getOwner() external view returns (address);
}

contract Zapper {

    // Tokens
    address public constant MDB = 0x0557a288A93ed0DF218785F2787dac1cd077F8f3;
    address public constant MDBP = 0x9f8BB16f49393eeA4331A39B69071759e54e16ea;

    address public constant MDB_BNB_LP = 0xB592BfF35a34EFe9C02Fe917c43F7adD9d48A957;
    address public constant MDB_MDBP_LP = 0xF73E61FCB92bb2a377fCC13879C0Af3692046EE1;

    // Farms
    address public mdb_bnb_auto_farm = 0x805Cc5aA1EBeE725250084D2ECcD9473c8bE46A9;
    address public mdb_mdbp_auto_farm = 0x65545d6eBf5F4245Ca2f9c90468dE38fE88E3672;

    // Router
    IUniswapV2Router02 public constant router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    // Swap Path
    address[] private path = [router.WETH(), MDB];

    uint256 public constant MDB_AFTER_TAX = 8500;
    uint256 public constant MDBP_AFTER_TAX = 9925;
    uint256 constant TAX_DENOM = 10000;

    modifier onlyOwner() {
        require(
            msg.sender == IMDB(MDB).getOwner(),
            'Only Owner'
        );
        _;
    }

    function refundDust() external onlyOwner {
        _refundDust();
    }

    function withdrawToken(address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function setFarms(address bnb, address mdbp) external onlyOwner {
        mdb_bnb_auto_farm = bnb;
        mdb_mdbp_auto_farm = mdbp;
    }

    function zapBNB() external payable {

        // buy MDB
        _buyTokens(false);

        // pair liquidity
        _pairLiquidity(false);

        // stake tokens into farm for user
        _stakeIntoFarm(false);

        // refund dust
        _refundDust();
    }

    function zapMDBP() external payable {

        // buy MDB and MDBP
        _buyTokens(true);

        // pair liquidity
        _pairLiquidity(true);

        // stake tokens into farm for user
        _stakeIntoFarm(true);

        // refund dust
        _refundDust();
    }

    function _stakeIntoFarm(bool mdbp) internal {

        if (mdbp) {

            // approve farm for balance
            uint balance = IERC20(MDB_MDBP_LP).balanceOf(address(this));
            IERC20(MDB_MDBP_LP).approve(mdb_mdbp_auto_farm, balance);

            // deposit into farm
            IAutoFarm(mdb_mdbp_auto_farm).deposit(msg.sender, balance);

        } else {

            // approve farm for balance
            uint balance = IERC20(MDB_BNB_LP).balanceOf(address(this));
            IERC20(MDB_BNB_LP).approve(mdb_bnb_auto_farm, balance);

            // deposit into farm
            IAutoFarm(mdb_bnb_auto_farm).deposit(msg.sender, balance);

        }

    }

    function _pairLiquidity(bool mdbp) internal {

        // swap half mdb balance into bnb
        uint256 balance = IERC20(MDB).balanceOf(address(this));

        // approve token for router
        IERC20(MDB).approve(address(router), balance);

        if (mdbp) {
            
            // approve MDBP for router
            uint256 mdbpBalance = IERC20(MDBP).balanceOf(address(this));
            IERC20(MDBP).approve(address(router), mdbpBalance);

            // add liquidity
            router.addLiquidity(MDB, MDBP, balance, mdbpBalance, 1, 1, address(this), block.timestamp + 100);

        } else {
            // add liquidity
            router.addLiquidityETH{value: address(this).balance}(
                MDB, balance, 1, 1, address(this), block.timestamp + 100
            );
        }
    }

    function _buyTokens(bool mdbp) internal {

        uint256 numerator = mdbp ? MDBP_AFTER_TAX : TAX_DENOM;
        uint256 denom = numerator + MDB_AFTER_TAX;

        // buy MDB with a portion of the bnb
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ( address(this).balance * numerator ) / denom}(0, path, address(this), block.timestamp);

        // send fee to MDB buy receiver
        uint256 buyFee = ( IERC20(MDB).balanceOf(address(this)) * (TAX_DENOM - MDB_AFTER_TAX) ) / TAX_DENOM;
        if (buyFee > 0) {
            IERC20(MDB).transfer(
                IMDB(MDB).buyFeeRecipient(),
                buyFee
            );
        }

        // buy MDBP if applicable
        if (mdbp) {
            (bool s,) = payable(MDBP).call{value: address(this).balance}("");
            require(s);
        }
    }

    function _refundDust() internal {

        // refund MDBP dust if any
        uint mdbpdust = IERC20(MDBP).balanceOf(address(this));
        if (mdbpdust > 0) {
            IERC20(MDBP).transfer(msg.sender, mdbpdust);
        }

        // refund MDB dust if any
        uint mdbdust = IERC20(MDB).balanceOf(address(this));
        if (mdbdust > 0) {
            IERC20(MDB).transfer(msg.sender, mdbdust);
        }

        // refund BNB dust if any
        uint dust = address(this).balance;
        if (dust > 0) {
            (bool s,) = payable(msg.sender).call{value: dust}("");
            require(s);
        }
    }

    receive() external payable {}

}