/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
interface TNBNFTLike {
    function mint(address,uint) external;
}
contract TNBMINT {

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "Contributor/not-authorized");
        _;
    }
     TNBNFTLike                       public  tnb =  TNBNFTLike(0x6A6763bCAA3950f231E5B4A15f8DB0c35c0854e4);

    constructor() public {
        wards[msg.sender] = 1;
    }

    function mint(uint256 start, uint256 end,address to) external auth {
        for (uint i = start; i<=end;i++) {
            tnb.mint(to,i);
        }
    }
    function mints(uint256 start, uint256 end, address[] memory to) external auth {
        uint256 n = end-start+1;
        require(to.length == n, "001");
        uint256 tokenid = start;
        for (uint i = 0; i<n;i++) {
            tnb.mint(to[i],tokenid);
            tokenid +=1;
        }
    }
 }