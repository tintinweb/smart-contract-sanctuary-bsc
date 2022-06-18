//SPDX-License-Identifier: MIT
 /* solhint-disable */
pragma solidity 0.8.7;

/*
//  The legacy NFT staking contract has been migrated, and the staked tokens are still being held by the old cnt
//  This cnt uses the admin function of the old cnt to trnasfer the nft being unstaked to the new cnt, so the new cnt
//  can transfer the token to its owner, which is required for the unstaking
*/

interface UNSTAKEV1 {
    function admin_nft_withdrawal(address contract_addr, uint256 TokenId, address payable _to, bool force, bool safe) external;
}

interface UNSTAKEV2 {
    function admin_nft_unstake(address contract_addr, uint256 TokenId, address payable _to, bool safe) external;
    function nft_stakes(address contract_addr, uint256 TokenId) external view returns(address, uint256, uint256);
}

interface IERC721 {
    function ownerOf(uint256 tokenId) external returns (address);
}

contract nft_unstake_helper {
    address public constant stake_v1_addr = 0xbC12C91F990D61f89C6061D6D9F7c8239D82B7d9;
    address public constant stake_v2_addr = 0x27a959BC559A3412aF7A2900bE09296837BbEe75;
    address public constant erc1155cnt = 0x9c3D3d4f4CE2488C380EaA3e77a83F6d0b84Da51;

    UNSTAKEV1 public constant stake_v1_cnt = UNSTAKEV1(stake_v1_addr);
    UNSTAKEV2 public constant stake_v2_cnt = UNSTAKEV2(stake_v2_addr);

    function unstake(address contract_addr, uint256 TokenId)
    public
    {
        // Get the token data
        (address real_owner, , ) = stake_v2_cnt.nft_stakes(contract_addr, TokenId);

        // Sanity check, owner and timelock
        //require (lock < block.timestamp, "The time lock has not expired");
        require (real_owner == msg.sender, "You are not the owner of this NFT");

        // The ERC1155 doesn't have the ownerOf function, and its only used in the new cnt, skip check
        if (contract_addr != erc1155cnt){
            // Locate where the token is, to do the actual unstake
            IERC721 nft = IERC721(contract_addr);
            address owner = nft.ownerOf(TokenId);

            // If the NFT is in the old contract, transfer it to the new contract so it can be unstaked
            if (owner == stake_v1_addr){
                stake_v1_cnt.admin_nft_withdrawal(contract_addr, TokenId, payable(stake_v2_addr), true, false);
            }
        }

        // Perform the unstake on the new contract
        stake_v2_cnt.admin_nft_unstake(contract_addr, TokenId, payable(msg.sender), false);
    }
}