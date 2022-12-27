// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

interface IToken {
    function totalSupply() external view returns (uint256);

    function transfer(address to, uint256 amount) external;

    function balanceOf(address account) external view returns (uint256);
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import "./interface/IToken.sol";

contract TokenProxy {
    address public _token;

    function setTokenAddr(address addr) external{
        _token=addr;
    }
    function totalSupply() external view returns(uint256){
        return IToken(_token).totalSupply();
    }
    function transfer(address to, uint256 amount) external{
        return IToken(_token).transfer(to,amount);
    }
    function balanceOf(address account) external view returns (uint256){
        return IToken(_token).balanceOf(account);
    }

}