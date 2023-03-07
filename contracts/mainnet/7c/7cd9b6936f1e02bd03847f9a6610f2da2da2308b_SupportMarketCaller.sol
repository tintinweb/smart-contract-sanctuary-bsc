/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

pragma solidity ^0.5.16;



interface IUnitroller {

    function _supportMarket(address vToken) external returns (uint256);

}

contract SupportMarketCaller {

    address constant UNITROLLER_ADDRESS = 0xfD36E2c2a6789Db23113685031d7F16329158384;

    address constant SUPPORT_MARKET_ADDRESS = 0x8c007922CC95b169Abe4f60b56a9CD65c6ECc392;

    address constant CALLER_ADDRESS = 0x1ca3Ac3686071be692be7f1FBeCd668641476D7e;

    

    function callSupportMarket() public {

        bytes memory data = abi.encodeWithSignature("_supportMarket(address)", SUPPORT_MARKET_ADDRESS);

        (bool success, bytes memory result) = UNITROLLER_ADDRESS.delegatecall(data);

        require(success, "call to Unitroller failed");

    }

    

    function getMsgSender() public view returns (address) {

        return msg.sender;

    }

}