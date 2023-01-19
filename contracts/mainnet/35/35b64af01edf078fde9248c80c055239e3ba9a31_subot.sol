/**
 *Submitted for verification at BscScan.com on 2023-01-19
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17; 

interface ERC20 {
    function balanceOf(address _tokenOwner) external view returns (uint balance);
    function transfer(address _to, uint _tokens) external returns (bool success);
    function allowance(address _contract, address _spender) external view returns (uint256 remaining);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }   

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract subot {

    using SafeMath for uint256;
    address public staking_pool_address = 0xEa2EE9e8772c2f40D6318db389af8ED70140d507;
    address public buy_back_contract = 0xA9119ec3dcdCCE968C68DaEaa8017a371C1B4e79;
    address public project_wallet = 0x2986e524138345849a6bdFcEd3c36A2Ef50C53Dc;
    address public token_contract = 0x5353A64D9231C6c541183c70Ef245295b73EF4FF;
    address public busd_contract = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    address public owner = msg.sender;
    address public staking_address;
    address public dev_address;
    uint256 public staking_fees;
    uint256 public dev_fees;

    constructor(uint256 _staking_fees, uint256 _dev_fees) {
        // staking_address = _staking_address;
        // dev_address = _dev_address;
        staking_fees = _staking_fees;
        dev_fees = _dev_fees;
    }

    receive() external payable {}

    event acceptedPaymentBNB(address indexed group_owner, string indexed order_id, uint256 amount);
    event acceptedPaymentToken(address indexed group_owner, string indexed order_id, uint256 amount, address indexed token_contract);

    function acceptPaymentBNB(address group_owner, string memory order_id) public payable {
        uint256 total = msg.value;
        uint256 s_fees = total.mul(staking_fees).div(1000);
        uint256 d_fees = total.mul(dev_fees).div(1000);

        (bool sent, ) = buy_back_contract.call{value: s_fees}("");
        require(sent, "Failed to charge staking fees.");

        (bool sent1, ) = project_wallet.call{value: d_fees}("");
        require(sent1, "Failed to charge dev fees.");

        (bool sent2, ) = group_owner.call{value: msg.value.sub(s_fees + d_fees)}("");
        require(sent2, "Failed to charge.");

        emit acceptedPaymentBNB(group_owner, order_id, msg.value);
    }
    
    function acceptPaymentTTN(address recipient_, uint256 amount_) public payable {
        ERC20 transferToken = ERC20(token_contract);
        uint256 total = amount_;

        uint256 s_fees = total.mul(staking_fees).div(1000);
        uint256 d_fees = total.mul(dev_fees).div(1000);

        require(transferToken.allowance(msg.sender, address(this)) >= amount_, "Insufficient Allowance");
        require(transferToken.transferFrom(msg.sender, address(this), amount_), "Transfer failed");

        require(transferToken.transfer(staking_pool_address, s_fees), "Transfer failed");
        require(transferToken.transfer(project_wallet, d_fees), "Transfer failed");
        require(transferToken.transfer(recipient_, total.sub(s_fees + d_fees)), "Transfer failed");
    }

    function acceptPaymentBUSD(address recipient_, uint256 amount_) public payable {
        ERC20 transferToken = ERC20(busd_contract);
        uint256 total = amount_;

        uint256 s_fees = total.mul(staking_fees).div(1000);
        uint256 d_fees = total.mul(dev_fees).div(1000);

        require(transferToken.allowance(msg.sender, address(this)) >= amount_, "Insufficient Allowance");
        require(transferToken.transferFrom(msg.sender, address(this), amount_), "Transfer failed");

        require(transferToken.transfer(buy_back_contract, s_fees), "Transfer failed");
        require(transferToken.transfer(project_wallet, d_fees), "Transfer failed");
        require(transferToken.transfer(recipient_, total.sub(s_fees + d_fees)), "Transfer failed");
    }
}