//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface INFT {
    function claimMintRevenueFor(address user) external;
}

interface IPaymentSplitter {
    function claimRewardFor(address user) external;
}

contract BatchClaimer {

    function batchClaim(address[] calldata assets, address paymentSplitter) external {

        // loop through NFT assets and claim rewards
        uint len = assets.length;
        address user = msg.sender;
        for (uint i = 0; i < len;) {
            INFT(assets[i]).claimMintRevenueFor(user);
            unchecked { ++i; }
        }

        // claim rewards from royalty payment splitter
        IPaymentSplitter(paymentSplitter).claimRewardFor(user);
    }


}