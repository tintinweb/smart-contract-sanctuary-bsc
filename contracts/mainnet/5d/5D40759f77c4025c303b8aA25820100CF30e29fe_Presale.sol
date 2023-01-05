/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

//SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

library TransferHelper {
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }
} 

interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IInviter {
    function setInvitePermissionByPresale(address account, uint amount) external;
    function inviterOf(address account) external returns (address);
}

contract Presale {
    address public owner;
    address public USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public token = 0x34B9609b0ffBd9f742d74D9591b9438DEA93735e;
    address public wallet = 0x15358069894a498c5830B59676812e1aDf44DA76;
    uint public price = 33*(1e16); //0.33U per token

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != owner, "same owner");
        owner = newOwner;
    }

    function setPrice(uint newPrice) external onlyOwner {
        require(newPrice != price, "same price");
        price = newPrice;
    } 

    function buy(uint usdtAmount) external {
        require(IBEP20(USDT).allowance(msg.sender, address(this)) >= usdtAmount, 'allowance not enough');
		require(IBEP20(USDT).balanceOf(msg.sender) >= usdtAmount, 'balance not enough');
        TransferHelper.safeTransferFrom(USDT, msg.sender, wallet, usdtAmount);

        uint tokenAmount = usdtAmount * (1e18) / price;

        uint tokensOfThis = IBEP20(token).balanceOf(address(this));
        require(tokensOfThis >= tokenAmount, "unsufficient tokens");
        IBEP20(token).transfer(msg.sender, tokenAmount);

        address inviterOfL1 = IInviter(token).inviterOf(msg.sender);
        if (inviterOfL1 != address(0)) {
            uint rewards = tokenAmount / 10;
            require(IBEP20(token).balanceOf(address(this)) >= rewards, "unsufficient tokens");
            IBEP20(token).transfer(inviterOfL1, rewards);

            address inviterOfL2 = IInviter(token).inviterOf(inviterOfL1);
            if (inviterOfL2 != address(0)) {
                rewards = tokenAmount / 20;
                require(IBEP20(token).balanceOf(address(this)) >= rewards, "unsufficient tokens");
                IBEP20(token).transfer(inviterOfL2, rewards);
            }
        }

        IInviter(token).setInvitePermissionByPresale(msg.sender, usdtAmount);
    }

    function sell(uint tokenAmount) external {
        require(IBEP20(token).allowance(msg.sender, address(this)) >= tokenAmount, 'allowance not enough');
		require(IBEP20(token).balanceOf(msg.sender) >= tokenAmount, 'balance not enough');
        TransferHelper.safeTransferFrom(token, msg.sender, wallet, tokenAmount);
    }

    function viewAmountOfThis(address _token) external view returns(uint) {
        uint amount = IBEP20(_token).balanceOf(address(this));
        return amount;
    }

    function exactTokens(address _token, uint amount) external onlyOwner {
        uint balanceOfThis = IBEP20(_token).balanceOf(address(this));
        require( balanceOfThis >= amount, 'no balance');
        IBEP20(_token).transfer(msg.sender, amount);
    }
}