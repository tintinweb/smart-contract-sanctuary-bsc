// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./SafeMath.sol";
import "./Ownable.sol";
import "./IERC20.sol";

contract SWAP is Ownable {
    using SafeMath for uint256;
    address private routerAddress;
    address private usdtAddress;
    address private hjdAddress;
    address private cpeAddress;
    uint256 public hjdTotal = 1000*1e18;
    uint256 public wcpeTotal = 1000*1e18;

    mapping(address => Orders[]) private buyRecord;
    mapping(address => Orders[]) private sellRecord;

    struct Orders {
        uint256 number;
        uint256 price;
        uint256 totalAmount;
    }

    constructor(
        address _routerAddress,
        address _usdtAddress,
        address _hjdAddress,
        address _cpeAddress
    ) {
        routerAddress = _routerAddress;
        usdtAddress = _usdtAddress;
        hjdAddress = _hjdAddress;
        cpeAddress = _cpeAddress;
        //IERC20(usdtAddress).approve(routerAddress, type(uint256).max);
    }

    function getCurrentPrice() external view returns (uint256) {
        return hjdTotal.mul(1e6).div(wcpeTotal);
    }

    function getHistoryBuyOrderTotal() external view returns (uint256) {
        return buyRecord[msg.sender].length;
    }

    function getHistoryBuyOrder(uint256 pageIndex, uint256 pageMax)
        external
        view
        returns (Orders[] memory)
    {
        require(pageIndex > 0);
        require(pageMax > 0);
        Orders[] memory tempOrders;
        {
            uint256 startNumber = (pageIndex - 1) * pageMax;
            uint256 endNumber = startNumber + pageMax;
            uint256 size = buyRecord[msg.sender].length;
            if (size <= startNumber) {
                return tempOrders;
            }
            if (endNumber > size) {
                endNumber = size;
            }
            tempOrders = new Orders[](endNumber - startNumber);
            uint256 j = 0;
            Orders[] memory myTempOrders = buyRecord[msg.sender];
            for (uint256 i = startNumber; i < endNumber; i++) {
                tempOrders[j] = myTempOrders[i];
                j++;
            }
        }
        return tempOrders;
    }

    function getHistorySellOrderTotal() external view returns (uint256) {
        return sellRecord[msg.sender].length;
    }

    function getHistorySellOrder(uint256 pageIndex, uint256 pageMax)
        external
        view
        returns (Orders[] memory)
    {
        require(pageIndex > 0);
        require(pageMax > 0);
        Orders[] memory tempOrders;
        {
            uint256 startNumber = (pageIndex - 1) * pageMax;
            uint256 endNumber = startNumber + pageMax;
            uint256 size = sellRecord[msg.sender].length;
            if (size <= startNumber) {
                return tempOrders;
            }
            if (endNumber > size) {
                endNumber = size;
            }
            tempOrders = new Orders[](endNumber - startNumber);
            Orders[] memory myTempOrders = sellRecord[msg.sender];
            uint256 j = 0;
            for (uint256 i = startNumber; i < endNumber; i++) {
                tempOrders[j] = myTempOrders[i];
                j++;
            }
        }
        return tempOrders;
    }

    function sellCPE(uint256 amount) external returns (bool) {
        require(amount > 0);
        uint256 balanceCPE = IERC20(cpeAddress).balanceOf(msg.sender);
        require(balanceCPE >= amount, "Insufficient balance");
        uint256 poolHjd = hjdTotal;
        uint256 cepPrice = _getCurrentPrice();
        uint256 hjdAmount = amount.mul(900000).mul(cepPrice).div(1000000).div(
            1e6
        );
        require(poolHjd >= hjdAmount, "Insufficient balance Pool");
        IERC20(cpeAddress).transferFrom(msg.sender, address(this), amount);
        IERC20(hjdAddress).transfer(msg.sender, hjdAmount);
        hjdTotal = hjdTotal - hjdAmount;
        wcpeTotal = wcpeTotal - amount;
        sellRecord[msg.sender].push(
            Orders({
                number: amount,
                price: hjdTotal.mul(1e6).div(wcpeTotal),
                totalAmount: hjdAmount
            })
        );
        return true;
    }

    function buyCPE(uint256 hjdAmount) external returns (bool) {
        IERC20(hjdAddress).transferFrom(msg.sender, address(this), hjdAmount);
        uint256 cpePrice = _getCurrentPrice();
        uint256 cpeAmount = hjdAmount.mul(1e6).div(cpePrice);
        uint256 mySelfNumber = cpeAmount.mul(900000).div(1000000);
        IERC20(cpeAddress).transfer(msg.sender, mySelfNumber);
        hjdTotal = hjdTotal + hjdAmount;
        wcpeTotal = wcpeTotal + mySelfNumber;
        buyRecord[msg.sender].push(
            Orders({
                number: mySelfNumber,
                price: hjdTotal.mul(1e6).div(wcpeTotal),
                totalAmount: hjdAmount
            })
        );
        return true;
    }

    function _getCurrentPrice() internal view returns (uint256) {
        return hjdTotal.mul(1e6).div(wcpeTotal);
    }

    fallback() external payable {}

    receive() external payable {}

    function withdrawToken(address[] calldata tokenAddr, address recipient)
        external
        onlyMinter
    {
        {
            uint256 ethers = address(this).balance;
            if (ethers > 0) payable(recipient).transfer(ethers);
        }
        unchecked {
            for (uint256 index = 0; index < tokenAddr.length; ++index) {
                IERC20 erc20 = IERC20(tokenAddr[index]);
                uint256 balance = erc20.balanceOf(address(this));
                if (balance > 0) erc20.transfer(recipient, balance);
            }
        }
    }

    // function _UsdtToHjd(uint256 usdtAmount) internal returns (uint256) {
    //     uint256 balance0 = IERC20(hjdAddress).balanceOf(address(this));
    //     address[] memory path = new address[](2);
    //     path[0] = usdtAddress;
    //     path[1] = hjdAddress;
    //     uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
    //         usdtAmount,
    //         0,
    //         path,
    //         address(this),
    //         block.timestamp + 20 * 60
    //     );
    //     return IERC20(hjdAddress).balanceOf(address(this)) - balance0;
    // }
}