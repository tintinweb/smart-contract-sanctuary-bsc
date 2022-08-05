/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

pragma solidity >=0.5.8;

interface ERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}
contract AirDrop {
    mapping(address => bool) private whitleList; // 白名单用户

    constructor() public {
        address superOwner = msg.sender;
        whitleList[superOwner] = true;
    }

    modifier onlySPOwner() {
        require(
            whitleList[msg.sender] == true,
            "Ownable: caller is not the super owner"
        );
        _;
    }

    function setOwner(address addr, bool f) public onlySPOwner {
        whitleList[addr] = f;
    }

    function transfer_Token(
        address tokenAddr,
        address[] memory toAddrs,
        uint256 amount
    ) public onlySPOwner returns (bool) {
        uint256 cnt = toAddrs.length;
        for (uint256 i = 0; i < cnt; i++) {
            require(
                ERC20(tokenAddr).transferFrom(msg.sender, toAddrs[i], amount),
                "token transferfrom fail"
            );
        }
        return true;
    }

    function transfer_Token2(
        address tokenAddr,
        address[] memory toAddrs,
        uint256[] memory amount
    ) public onlySPOwner returns (bool) {
        uint256 cnt = toAddrs.length;
        for (uint256 i = 0; i < cnt; i++) {
            require(
                ERC20(tokenAddr).transferFrom(msg.sender, toAddrs[i], amount[i]),
                "token transferfrom fail"
            );
        }
        return true;
    }
}