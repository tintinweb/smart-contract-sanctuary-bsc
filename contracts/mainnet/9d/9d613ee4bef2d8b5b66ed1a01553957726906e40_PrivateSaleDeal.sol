/**
 *Submitted for verification at BscScan.com on 2022-08-23
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
contract PrivateSaleDeal {
    address private _seller;
    IERC20 private WNOW = IERC20(address(0x56AA0237244C67B9A854B4Efe8479cCa0B105289));
    IERC20 private CZUSD = IERC20(address(0xE68b79e51bf826534Ff37AA9CeE71a3842ee9c70));
    
    constructor() {
        _seller = msg.sender;
    }
    modifier onlySeller() {
        require(_seller == msg.sender, "caller is not the seller");
        _;
    }
    function withdraw(IERC20 _token) external onlySeller {
        require(_token.transfer(msg.sender, _token.balanceOf(address(this))));
    }
    function closeDeal() external {
        require(CZUSD.transferFrom(msg.sender, _seller, 7267 * 1e18));
        require(WNOW.transfer(msg.sender, 500000 * 1e18));
    }
}