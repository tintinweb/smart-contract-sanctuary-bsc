// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./IERC20.sol";
import "./Ownable.sol";
import "./SSSairdrop.sol";

contract SSSairdropfactory is Ownable{

    struct airdropinfo {
        address tokenAddress;
        uint256 quantity;
        uint256 distributionTimeUnix;
    }

     address[] private airdropAddresses;

    function addairdropAddress(address _airdrop) internal returns (uint256) {
        airdropAddresses.push(_airdrop);
        return airdropAddresses.length - 1;
    }

    function getairdropCount() external view returns (uint256) {
        return airdropAddresses.length;
    }

    function getairdropAddress(uint256 Id) external view returns (address) {
        return airdropAddresses[Id];
    }

    function createAirdrop(airdropinfo calldata _airdropinfo) external payable{
        require(msg.value == 1 ether, "Not sufficient msg value. Please send 1 BNB");
        IERC20 token = IERC20(_airdropinfo.tokenAddress);
        
        SSSairdrop airdrop = new SSSairdrop(_airdropinfo.tokenAddress, msg.sender, _airdropinfo.distributionTimeUnix);

        addairdropAddress(address(airdrop));

        token.transferFrom(msg.sender, address(airdrop), _airdropinfo.quantity);
        payable(owner()).transfer(msg.value);
    }

}