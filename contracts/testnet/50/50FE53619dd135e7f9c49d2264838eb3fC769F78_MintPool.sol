/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

// SPDX-License-Identifier: UNLISCENSED

pragma solidity ^0.8.4;

interface IERC20 {

    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


contract MintPool {
 
    IERC20 busd;
    IERC20 native;
    address tax_pool;
    uint256 Tax = 100; // 1%
    uint256 value = 10000;
    constructor () {
        busd = IERC20(0xB31e26356521296064E792618628cA1C834B7882);
        native = IERC20(0x342d2E24b5D317615346f3012a8b5ACE8aD0309c);
        tax_pool = (0xB9c5313C9B7b60a8dd0231427F158C7D3bdcA9F1);
        
        
    }   
    function TaxPoolAddress() public view virtual returns (address) {
        return tax_pool;
    }
    function BuyNative(uint256 Amount)  external  {
    require(busd.balanceOf(msg.sender) >= Amount * 10**busd.decimals());
    require(native.balanceOf(address(this)) >= Amount * 10**native.decimals());

    uint256 fee = ((Amount * Tax) / (value));

    busd.transferFrom(msg.sender, address(this), (Amount - fee) * 10**busd.decimals());
    busd.transferFrom(msg.sender, tax_pool, fee * 10**busd.decimals());
    native.transfer(msg.sender, (Amount - fee) * 10**native.decimals());
    }  
    
    function SellNative(uint256 Amount) external {
    require(native.balanceOf(msg.sender) >= Amount * 10**native.decimals());
    require(busd.balanceOf(address(this)) >= Amount * 10**native.decimals());

    native.transferFrom(msg.sender, address(this), Amount * 10**native.decimals());
    busd.transfer(msg.sender, Amount * 10**busd.decimals());


  }
}