/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IToken {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

//将需要发送空投的代币授权给该合约，通过空投方法发放空投，也可用于批量转账
//授权：1. 通过 bscscan 区块浏览器搜索代币合约地址，需要代币合约开源验证才行
//     2. 调用代币合约的 approve 方法 ，
//        spender 填 空投合约地址
//        amount 填授权数量，注意需要加上精度的0，可以填一个非常大的数字也行
contract Airdrop {
    //空投数量一样，_values 要注意精度处理，最小精度，例如精度18，则后面加18个0
    //_recipients = ["address1","address2","address3"]，可以继续添加地址，链上限制，每次可能只能空投几百个地址
    //_value = 1000000000000000000，精度18时，表示1个
    //_tokenAddress = 代币合约地址，需要先将代币授权给该空投合约，才能调用 transferFrom 发送空投
    function airdrop(
        address[] memory _recipients,
        uint256 _value,
        address _tokenAddress
    ) public returns (bool) {
        require(_recipients.length > 0 && _value > 0, "invalid input");
        IToken token = IToken(_tokenAddress);
        for (uint256 i = 0; i < _recipients.length; i++) {
            token.transferFrom(msg.sender, _recipients[i], _value);
        }
        return true;
    }

    //空投数量不一样
    function airdrops(
        address[] memory _recipients,
        uint256[] memory _values,
        address _tokenAddress
    ) public returns (bool) {
        require(
            _recipients.length > 0 && _recipients.length == _values.length,
            "invalid input"
        );
        IToken token = IToken(_tokenAddress);
        for (uint256 i = 0; i < _recipients.length; i++) {
            token.transferFrom(msg.sender, _recipients[i], _values[i]);
        }
        return true;
    }
}