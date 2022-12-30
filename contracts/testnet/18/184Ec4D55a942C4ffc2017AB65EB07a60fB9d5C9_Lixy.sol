/**
 *Submitted for verification at BscScan.com on 2022-12-30
*/

pragma solidity 0.8.16;


contract Lixy{
    mapping(uint256=>uint256) private  so_tien;
    constructor(uint256[] memory data){
        for(uint256 i = 0; i<data.length;i++){
            so_tien[i+1] = data[i];
        }
    }    

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function li_xy(uint256 i)public view returns(string memory){
        return string.concat(uint2str(so_tien[i])," VND");
    }
}