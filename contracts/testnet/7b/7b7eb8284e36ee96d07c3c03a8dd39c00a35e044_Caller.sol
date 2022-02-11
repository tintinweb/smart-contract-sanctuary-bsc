/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

pragma solidity ^0.8.0;

interface Recipient
{
    function Test() external returns(address t, address c);

    function TestCall(uint a) external returns(address t, address c);

    function TestDelegate() external returns(address t, address c);
}

contract Caller
{
    Recipient recipient;
    address recipientAddr;

    event OnReceived(address indexed from, uint value);

    constructor(address recAddr)
    {
        recipient = Recipient(recAddr);
        recipientAddr = recAddr;
    }

    function T() external returns(address t, address c)
    {
         return recipient.Test();
    }

    function getEncode() external returns (bytes4 a, bytes memory b)
    {
        a = Recipient.Test.selector;
        b = abi.encodeWithSelector(Recipient.Test.selector);
    }

    function TCall() external returns(bool r, bytes memory m)
    {
         (r,  m) = recipientAddr.call(abi.encodeWithSelector(Recipient.TestCall.selector, 6767));
    }

    function TDeleCall() external returns(bool r, bytes memory m)
    {
         (r,  m) = recipientAddr.delegatecall(abi.encodeWithSelector(Recipient.TestDelegate.selector));
    }

    fallback() external payable
    {
        emit OnReceived(msg.sender, msg.value);
    }
}