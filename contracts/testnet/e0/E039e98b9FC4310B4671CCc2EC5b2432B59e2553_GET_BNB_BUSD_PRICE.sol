/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//0x8bc85D6F1AA914e74F7eB3DCEEA119b1ad00498A BY 0x6b738eD5337e6c74D1d5483d6EA8aF439C4C336C
contract GET_BNB_BUSD_PRICE {
    
    uint112 reserve0 = 10;
    uint112 reserve1 = 3000;


    function setReserves(uint112 _reserve0, uint112 _reserve1) public returns (bool){
        reserve0 = _reserve0;
        reserve1 = _reserve1;
        return true;
    }

    function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 blockTimestampLast){
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        blockTimestampLast = uint32(block.timestamp % 2 ** 32);
    }

    function getReservedNum(uint256 amountBNBwei) external view returns (uint256){
    (uint256 Res0, uint256 Res1,) = getReserves();
    //uint256 res1 = Res1*(10**18);
    return ((amountBNBwei*Res1)/Res0); 
    }

    function getBNBFromToken(uint256 amountTokenWei) external view returns (uint256){
    (uint256 Res0, uint256 Res1,) = getReserves();
    //uint256 res1 = Res1*(10**18);
    return ((amountTokenWei*Res0)/Res1); 
    }

}