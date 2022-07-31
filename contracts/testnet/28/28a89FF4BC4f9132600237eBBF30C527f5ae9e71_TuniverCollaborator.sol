pragma solidity ^0.8.0;

import "./interfaces/ITuniverBox.sol";


contract TuniverCollaborator {
    ITuniverBox public boxContract = ITuniverBox(0x442F471feC720382bd3Ef9Da47E0DE68FeEef0fA);

    function setBoxContract(ITuniverBox _boxContract) external {
        boxContract = _boxContract;
    }

    function buy(uint256 amount)  external payable {
        uint256 pricePerBox = boxContract.getPricePerBox();
        require(msg.value == pricePerBox, "not enough fee");

        boxContract.buy(amount, msg.sender);
    }
}

pragma solidity ^0.8.0;

interface ITuniverBox {
    function getPricePerBox() external view returns(uint256);
    function buy(uint256 amount, address buyer) external;
}