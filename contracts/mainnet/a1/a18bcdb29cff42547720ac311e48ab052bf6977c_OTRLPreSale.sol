/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract AbsPreSale {
    uint256 private soldCount;
    uint256 private perNum = 50 * 10 ** 6;
    uint256 private price = 50 * 10 ** 18;

    address private usdtAddress;
    address private cashAddress;
    address private tokenAddress;

    mapping(address => uint256) private inviteReward;

    mapping(address => uint256) private saleNum;

    mapping(address => address) private inviter;
    mapping(address => address[]) private binders;

    address[] private userList;

    constructor(address UsdtAddress, address CashAddress, address TokenAddress){
        usdtAddress = UsdtAddress;
        cashAddress = CashAddress;
        tokenAddress = TokenAddress;
    }

    function buy(address invitor) external _onlyNonContract {
        address account = msg.sender;
        require(saleNum[account] == 0, "only 1 time");
        userList.push(account);

        saleNum[account]++;
        soldCount += 1;

        if (address(0) != invitor && invitor != account && address(0) == inviter[account] && saleNum[invitor] > 0) {
            inviter[account] = invitor;
            binders[invitor].push(account);
        }

        IERC20 usdt = IERC20(usdtAddress);
        uint256 usdtNum = price;

        address current = account;
        uint256 inviterAmount;
        for (uint256 i; i < 2; ++i) {
            invitor = inviter[current];
            if (address(0) == invitor) {
                break;
            }
            if (0 == i) {
                inviterAmount = price / 10;
            } else {
                inviterAmount = price / 50;
            }
            inviteReward[invitor] += inviterAmount;
            usdtNum -= inviterAmount;
            usdt.transferFrom(account, invitor, inviterAmount);
            current = invitor;
        }
        usdt.transferFrom(account, cashAddress, usdtNum);

        IERC20 token = IERC20(tokenAddress);
        token.transfer(account, perNum);
    }

    function info() external view returns (uint256, uint256, uint256) {
        return (price, perNum, soldCount);
    }

    function userInfo(address user) external view returns (uint256, address) {
        return (saleNum[user], inviter[user]);
    }

    function viewBinders(address user, uint256 start, uint256 length) external view returns (uint256 returnLen, address[] memory returnBinders, uint256[] memory binderBindersCount) {
        if (0 == length) {
            length = binders[user].length;
        }
        returnLen = length;

        returnBinders = new address[](length);
        binderBindersCount = new uint256[](length);

        uint256 index = 0;
        for (uint256 i = start; i < start + length; ++i) {
            if (i >= binders[user].length)
                return (index, returnBinders, binderBindersCount);
            address binder = binders[user][i];
            returnBinders[index] = binder;
            binderBindersCount[index] = binders[binder].length;
            ++index;
        }
    }

    function viewUserList(uint256 start, uint256 length) external view returns (uint256 returnLen, address[] memory returnUsers, uint256[] memory bindersCount, uint256[] memory rewards) {
        if (0 == length) {
            length = userList.length;
        }
        returnLen = length;

        returnUsers = new address[](length);
        bindersCount = new uint256[](length);
        rewards = new uint256[](length);

        uint256 index = 0;
        for (uint256 i = start; i < start + length; ++i) {
            if (i >= userList.length)
                return (index, returnUsers, bindersCount, rewards);
            address user = userList[i];
            returnUsers[index] = user;
            bindersCount[index] = binders[user].length;
            rewards[index] = inviteReward[user];
            ++index;
        }
    }

    function getCashAddress() external view returns (address){
        return cashAddress;
    }

    function getTokenAddress() external view returns (address){
        return tokenAddress;
    }

    function getUsdtAddress() external view returns (address){
        return usdtAddress;
    }

    modifier _onlyNonContract(){
        require(tx.origin == msg.sender);
        _;
    }

    receive() external payable {}

    function withdrawBalance() external {
        address payable addr = payable(cashAddress);
        addr.transfer(address(this).balance);
    }

    function withdrawToken(address erc20Address) external {
        IERC20 erc20 = IERC20(erc20Address);
        erc20.transfer(cashAddress, erc20.balanceOf(address(this)));
    }
}

contract OTRLPreSale is AbsPreSale {
    constructor() AbsPreSale(
        address(0x55d398326f99059fF775485246999027B3197955),
        address(0xf04dcB6bF4dCc0C7bdF52a91f851df5Bf91C50D4),
        address(0x606F34239eC8cAccC9c7dE45D25ba6dC9048d13F)
    ){

    }
}