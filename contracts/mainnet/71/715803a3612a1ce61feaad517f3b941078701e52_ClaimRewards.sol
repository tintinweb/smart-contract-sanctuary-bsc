/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

// by moonbase.bnb
pragma solidity 0.8.0;

interface IController {
    function count() external view returns (uint);
    function increment() external;
    function claimVenus(address holder, address[] memory vTokens) external;
    function claimVenus(address[] memory holders, address[] memory vTokens, bool borrowers, bool suppliers) external;
}

contract ClaimRewards {
    address public rewardAddr = 0xf2721703d5429BeC86bD0eD86519E0859Dd88209;
    address public holderAddr = 0xb554B9856DFdbf52B98E0e4D2b981C34E20e1dAB;
    address[] public vTokenSupplyAddrs =  [0x972207A639CC1B374B893cc33Fa251b55CEB7c07, 0x882C173bC7Ff3b7786CA16dfeD3DFFfb9Ee7847B];
    address[] public vTokenBorrowAddrs =  [0x1610bc33319e9398de5f57B33a5b184c806aD217];
    address[] public vTokenAddrs = [0x972207A639CC1B374B893cc33Fa251b55CEB7c07, 0x882C173bC7Ff3b7786CA16dfeD3DFFfb9Ee7847B, 0x1610bc33319e9398de5f57B33a5b184c806aD217];

    function setRewardAddr(address _rewardAddr, address _holderAddr) external {
       rewardAddr = _rewardAddr;
       holderAddr = _holderAddr;
    }

    function setVTokenAddr(address[] memory _vTokenSupplyAddrs, address[] memory _vTokenBorrowAddrs) external {
       vTokenSupplyAddrs = _vTokenSupplyAddrs;
       vTokenBorrowAddrs = _vTokenBorrowAddrs;
    }

    function setVTokenAddr(address[] memory _vTokenAddrs) external {
       vTokenAddrs = _vTokenAddrs;
    }

    function claim() external {
        address[] memory holders = new address[](1);
        holders[0] = holderAddr;
        IController(rewardAddr).claimVenus(holders, vTokenBorrowAddrs, true, false);
        IController(rewardAddr).claimVenus(holders, vTokenSupplyAddrs, false, true);
    }

    function reward() external {
        IController(rewardAddr).claimVenus(holderAddr, vTokenAddrs);
    }
}