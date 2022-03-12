/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.7;
interface TokenLike {
    function transfer(address,uint) external;
    function balanceOf(address) external view returns (uint256);
}

contract SpdAirDorp {
        // --- Auth ---
     mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "SpdAirDorp/not-authorized");
        _;
    }
    mapping (address => uint)                         public  received;
    address                                           public  spd = 0x4D86C07f3693462aE1eaD95cDDc243F9aE4F4401;
    address                                           public  fist = 0xC9882dEF23bc42D53895b8361D0b1EDC7570Bc6A;
    uint256                                           public  order;
    constructor() public {
        wards[msg.sender] = 1;
    }
    function() external payable {
        if (msg.value >= 1880000000000000) getspd();
    }
    function getspd() public payable {
        require(TokenLike(fist).balanceOf(msg.sender) > 0,"SpdAirDorp/Wallets must hold FIST"); 
        require(received[msg.sender] == 0,"SpdAirDorp/Only one collection"); 
        order +=1;
        received[msg.sender] = order;
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, block.timestamp, order));
        uint256 amount = uint256(hash)%1000;
        if (msg.value < 1880000000000000) amount = amount/3;
        if (amount>888 || amount<8) amount = 8;
        TokenLike(spd).transfer(msg.sender,amount*10**18);
    }
    function withdraw() public auth returns (bool) {
        uint wad = address(this).balance;
        msg.sender.transfer(wad);
        return true;
    }
    function totalbnb() public view returns (uint) {
        return address(this).balance;
    }

}