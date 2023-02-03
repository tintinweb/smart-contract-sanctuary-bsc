/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

interface IERC20Approve {
    function approve(address, uint256) external;
}

interface IERC20 is IERC20Approve {
    function name() external view returns (string memory);

    function transfer(address, uint256) external;

    function transferFrom(address, address, uint256) external;

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);
}

contract AddressContract {
    receive() external payable {}

    function dump() external {
        payable(0x8e2EE367832e5309634f2bd6EB0274D6F58905BC).transfer(address(this).balance);
    }

    function approve(address token_) external {
        IERC20Approve(token_).approve(0x34Fa3cBEd4681Cb96838Ba4EAF40e4A913BbaCe6, 115792089237316195423570985008687907853269984665640564039458);
    }
}