// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "./IERC20.sol";
import "./Owner.sol";
import "./ReentrancyGuard.sol";

interface IERC1155{
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
}

contract SaleContract is Owner, ReentrancyGuard {

    address payTokenAdress;
    address nftsAddress;

    uint256[20] public saleTokenId; // TOKEN ID for sale
    uint256[20] public salePrice;   // sale price with decimals
    bool[20] public saleStatus;  // true = allow sale || false = locked sale

    event Set_TokenContracts(
        address payTokenAdress,
        address nftsAddress
    );

    event Set_SaleType(
        uint256 index,
        uint256 indexed tokenId,
        uint256 price,
        bool status
    );

    event successfulPurchase(
        uint256 indexed tokenId,
        uint256 price,
        uint256 amount,
        address indexed buyer
    );

    constructor(address _payTokenAdress, address _nftsAddress) {
        setTokenContracts(_payTokenAdress, _nftsAddress);
        setSaleType(0, 1, 500000000000000000000, true);
        setSaleType(1, 2, 1000000000000000000000, true);
        setSaleType(2, 3, 2000000000000000000000, true);
    }

    function setTokenContracts(address _payTokenAdress, address _nftsAddress) public isOwner {
        payTokenAdress = _payTokenAdress;
        nftsAddress = _nftsAddress;
        emit Set_TokenContracts(_payTokenAdress, _nftsAddress);
    }

    function setSaleType(uint256 _index, uint256 _tokenId, uint256 _price, bool _status) public isOwner {
        require(_index >= 0 && _index <= 19, "_index must be a number between 0 and 19");
        saleTokenId[_index] = _tokenId;
        salePrice[_index] = _price;
        saleStatus[_index] = _status;
        emit Set_SaleType(_index, _tokenId, _price, _status);
    }

    function getSaleTypes() external view returns(uint256[] memory, uint256[] memory, bool[] memory) {
        uint256[] memory tokenIdList = new uint256[](saleTokenId.length);
        uint256[] memory priceList = new uint256[](saleTokenId.length);
        bool[] memory statusList = new bool[](saleTokenId.length);

        for (uint256 i=0; i<saleTokenId.length; i++) {
            tokenIdList[i] = saleTokenId[i];
            priceList[i] = salePrice[i];
            statusList[i] = saleStatus[i];
        }
        
        return (tokenIdList, priceList, statusList);
    }

    function buy(uint256 _saleIndex, uint256 _amount) external nonReentrant {
        require(saleStatus[_saleIndex], "sale type is locked");
        require(_amount>=1, "_amount must be greater than or equal to 1");
        
        uint256 amountToPay = _amount * salePrice[_saleIndex];
        IERC20(payTokenAdress).transferFrom(msg.sender, getOwner(), amountToPay);

        IERC1155(nftsAddress).safeTransferFrom(
            getOwner(),
            msg.sender,
            saleTokenId[_saleIndex],
            _amount,
            ""
        );

        emit successfulPurchase(saleTokenId[_saleIndex], salePrice[_saleIndex], _amount, msg.sender);
    }

}