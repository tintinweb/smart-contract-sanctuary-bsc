// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Ownable.sol";
import "./IERC20.sol";
import "./IShopStore.sol";
import "./ListTool.sol";

contract Award is Ownable, ShopStoreContract {
    uint256 private gasValue = 6000000000000000;

    constructor() {}

    fallback() external payable {}

    receive() external payable {}

    using ListTool for address[];

    address private shopContractAddress;
    address private gasAddress;
    address private gasMiddleAddress;

    address[] private cashAddressList;

    function applyCash() external payable {
        require(!cashAddressList.contains(msg.sender), "1");
        require(msg.value == gasValue, "2");
        payable(gasMiddleAddress).transfer(msg.value);
        cashAddressList.add(msg.sender);
    }

    function getCashAddressList() external view returns (address[] memory) {
        require(msg.sender == gasMiddleAddress);
        return cashAddressList;
    }

    function getUsdtAward(address tempAddress_, uint256 amount_)
        external
        payable
    {
        require(address(tempAddress_) != address(0));
        require(amount_ > 0);
        require(msg.value == 0.004 ether);
        require(msg.sender == gasMiddleAddress);
        cashAddressList.remove(tempAddress_);
        payable(address(this)).transfer(msg.value);
        uint256 amount = IERC20(_getUsdtAddress()).balanceOf(
            shopContractAddress
        );
        require(amount >= amount_);
        IERC20(_getUsdtAddress()).transferFrom(
            shopContractAddress,
            tempAddress_,
            amount_
        );
    }

    function getKingAward(address tempAddress_, uint256 amount_)
        external
        payable
    {
        require(address(tempAddress_) != address(0));
        require(amount_ > 0);
        require(msg.value == 0.004 ether);
        require(msg.sender == gasMiddleAddress);
        cashAddressList.remove(tempAddress_);
        payable(address(this)).transfer(msg.value);
        uint256 amount = IERC20(_getKingAddress()).balanceOf(
            shopContractAddress
        );
        require(amount >= amount_);
        IERC20(_getKingAddress()).transferFrom(
            shopContractAddress,
            tempAddress_,
            amount_
        );
    }

    function getCpeAward(address tempAddress_, uint256 amount_)
        external
        payable
    {
        require(address(tempAddress_) != address(0));
        require(amount_ > 0);
        require(msg.value == 0.004 ether);
        require(msg.sender == gasMiddleAddress);
        cashAddressList.remove(tempAddress_);
        payable(address(this)).transfer(msg.value);
        uint256 amount = IERC20(_getCpeAddress()).balanceOf(
            shopContractAddress
        );
        require(amount >= amount_);
        IERC20(_getCpeAddress()).transferFrom(
            shopContractAddress,
            tempAddress_,
            amount_
        );
    }

    function gasOut() external {
        require(address(this).balance > 1 wei);
        require(msg.sender == gasAddress);
        payable(msg.sender).transfer(address(this).balance);
    }

    function setGasValue(uint256 gasValue_) external onlyMinter {
        gasValue = gasValue_;
    }

    function setShopContractAddress(address tempAddress_) external onlyMinter {
        shopContractAddress = tempAddress_;
    }

    function setGasAddress(address tempAddress_) external onlyMinter {
        gasAddress = tempAddress_;
    }

    function setGasMiddleAddress(address tempAddress_) external onlyMinter {
        gasMiddleAddress = tempAddress_;
    }
}