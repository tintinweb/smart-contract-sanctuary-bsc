/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

pragma solidity 0.5.16;

contract ClaimRequest {
    event TokenRequested(address user, uint256 amount, uint256 chainId);
    mapping(address => mapping(uint256 => uint256)) public requests;

    function requestTokensFromEth() public returns (bool) {
        requests[msg.sender][4]++;
        emit TokenRequested(msg.sender, requests[msg.sender][4] * 10**18, 4);
        return true;
    }

    function requestTokensFromPoly() public returns (bool) {
        requests[msg.sender][80001]++;
        emit TokenRequested(
            msg.sender,
            requests[msg.sender][80001] * 10**18,
            80001
        );
        return true;
    }
}