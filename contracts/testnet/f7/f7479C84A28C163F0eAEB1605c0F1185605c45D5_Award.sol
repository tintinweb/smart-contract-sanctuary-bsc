// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Ownable.sol";
import "./IERC20.sol";
import "./IShopStore.sol";
import "./ListTool.sol";

contract Award is Ownable, ShopStoreContract {
    constructor() {}

    fallback() external payable {}

    receive() external payable {}

    using ListTool for address[];

    address private shopContractAddress;
    address private gasAddress;
    address private gasMiddleAddress =
        0xd0C26978624BE9CB55609be6ae174546Fa097007;

    address[] private cashAddressList;

    function applyCash(address tempAddress_) external payable {
        require(address(tempAddress_) != address(0),"1");
        require(!cashAddressList.contains(tempAddress_),"2");
        require(msg.value == 0.003 ether,"3");
        payable(gasMiddleAddress).transfer(msg.value);
        cashAddressList.add(tempAddress_);
    }

    function getCashAddressList() external view returns (address[] memory) {
        return cashAddressList;
    }

    function setShopContractAddress(address tempAddress_) external onlyMinter {
        shopContractAddress = tempAddress_;
    }

    function setGasAddress(address tempAddress_) external onlyMinter {
        gasAddress = tempAddress_;
    }

    function getUsdtAward(address tempAddress_, uint256 amount_)
        external
        payable
        onlyMinter
    {
        require(address(tempAddress_) != address(0));
        require(amount_ > 0);
        require(msg.value == 0.002 ether);
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
        onlyMinter
    {
        require(address(tempAddress_) != address(0));
        require(amount_ > 0);
        require(msg.value == 0.002 ether);
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
        onlyMinter
    {
        require(address(tempAddress_) != address(0));
        require(amount_ > 0);
        require(msg.value == 0.002 ether);
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
}