/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

pragma solidity ^0.8.0;



interface IUnitroller {

    function _supportMarket(address vToken) external returns (uint256);

}



contract CallUnitroller {

    IUnitroller public unitroller;

    address public delegate;



    constructor(address unitrollerAddress, address _delegate) {

        unitroller = IUnitroller(unitrollerAddress);

        delegate = _delegate;

    }



    function supportMarket() public returns (uint256) {

        (bool success, bytes memory result) = delegate.delegatecall(

            abi.encodeWithSignature("supportMarket()")

        );

        require(success, "delegatecall failed");

        return abi.decode(result, (uint256));

    }



    function setDelegate(address _delegate) external {

        delegate = _delegate;

    }



    function getDelegate() external view returns (address) {

        return delegate;

    }



    receive() external payable {

        revert("fallback function not allowed");

    }

}