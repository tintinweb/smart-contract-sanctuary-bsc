/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.7;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint256);
}

interface IPair {
     function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract balanceHelper {
    struct tokenInfoItem {
        string name;
        string symbol;
        uint256 decimals;
    }

    struct erc20BalanceItem {
        address _user;
        uint256 _gas;
        uint256 _tokenBalance;
    }

    function _getErc20Token(IERC20 _erc20Token) private view returns (tokenInfoItem memory tokenInfo) {
        tokenInfo.name = _erc20Token.name();
        tokenInfo.symbol = _erc20Token.symbol();
        tokenInfo.decimals = _erc20Token.decimals();
    }

    function _getErc20Balance(address _user, IERC20 _erc20Token) private view returns (erc20BalanceItem memory erc20Balance) {
        erc20Balance._user = _user;
        erc20Balance._gas = _user.balance;
        erc20Balance._tokenBalance = _erc20Token.balanceOf(_user);
    }

    function getErc20Balance(address[] memory _addressList, IERC20 _erc20Token,IPair _pair) external view returns (tokenInfoItem memory tokenInfo, erc20BalanceItem[] memory erc20BalanceList, uint256 gasLimit, uint256 gasLeft, uint256 gasUsed,uint112 reserve0, uint112 reserve1) {
        gasLimit = gasleft();
        tokenInfo = _getErc20Token(_erc20Token);
        erc20BalanceList = new erc20BalanceItem[](_addressList.length);
        for (uint256 i = 0; i < _addressList.length; i++) {
            erc20BalanceList[i] = _getErc20Balance(_addressList[i], _erc20Token);
        }
        (reserve0, reserve1,) = _pair.getReserves();
        gasLeft = gasleft();
        gasUsed = gasLimit - gasLeft;
    }
}