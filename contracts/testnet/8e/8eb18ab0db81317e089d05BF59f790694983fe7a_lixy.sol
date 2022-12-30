/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

pragma solidity 0.8.16;
contract lixy{
    mapping(uint256=>uint256) public  so_tien_mung_tuoi;
    constructor(uint256[] memory data){
        for(uint256 i =0; i<data.length;i++){
            so_tien_mung_tuoi[i] = data[i];
        }
    }    
}