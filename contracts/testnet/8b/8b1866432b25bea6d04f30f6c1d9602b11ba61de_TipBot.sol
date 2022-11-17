/**
 *Submitted for verification at BscScan.com on 2022-11-16
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

contract TipBot {

    using SafeMath for uint256;
    address public contractOwner = msg.sender; 
    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public authorized;
    uint256 public Fee;
    address public FeeAddress;
    uint16 public Limit = 5;
    mapping(address => uint256) public txCount;

    constructor(uint _Fee, address _FeeAddress) {
        Fee = _Fee;
        FeeAddress = _FeeAddress;
    }

    receive() external payable {}

    event TipMessage(address indexed recipientAddress, string message, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Multisended(uint256 total, address tokenAddress);


    function sendEtherTo(address recipient_, string memory message_) public payable {
        uint256 total = msg.value;
        uint256 totalFee = total.mul(Fee).div(1000);
        (bool success, ) = recipient_.call{value: msg.value.sub(totalFee)}("");
        require(success, "Failed to send.");
        (bool sent, ) = FeeAddress.call{value: totalFee}("");
        require(sent, "Failed to charge.");
        emit TipMessage(recipient_, message_, msg.value);
    }

    function sendTokenTo(address recipient_, uint256 amount_, address tokenContractAddr_, string memory message_) public payable {
        ERC20 transferToken = ERC20(tokenContractAddr_);
        uint256 total = amount_;
        uint256 totalFee = total.mul(Fee).div(1000);
        require(transferToken.allowance(msg.sender, address(this)) >= amount_, "Insufficient Allowance");
        require(transferToken.transferFrom(msg.sender, address(this), amount_), "Transfer failed");
        require(transferToken.transfer(recipient_, amount_.sub(totalFee)), "Transfer failed");
        require(transferToken.transfer(FeeAddress, totalFee), "Transfer failed");
        emit TipMessage(recipient_, message_, amount_);
    }

    function multisendTokenTo(address token, address[] memory  _contributors, uint256[] memory  _balances) public payable {
        uint256 total = 0;
        require(_contributors.length <= Limit);
        ERC20 erc20token = ERC20(token);
        uint8 i = 0;
        require(erc20token.allowance(msg.sender, address(this)) > 0);
        for (i; i < _contributors.length; i++) {
            erc20token.transferFrom(msg.sender, _contributors[i], _balances[i] - Fee/1000);
            erc20token.transferFrom(msg.sender, FeeAddress, _balances[i]*Fee/1000);
        }
        txCount[msg.sender]++;
        emit Multisended(total, token);
    }
    
    function multisendEtherTo(address[] memory  _contributors, uint256[] memory  _balances) public payable {
        uint256 total = msg.value;
        require(total >= Fee);
        require(_contributors.length <= Limit);
        uint256 totalFee = total.mul(Fee).div(1000);
        (bool success, ) = FeeAddress.call{value: totalFee}("");
        require(success, "Failed to charge."); 
        uint8 i = 0;
        for (i; i < _contributors.length; i++) {
            payable(_contributors[i]).transfer(_balances[i]);
            total += _balances[i];
        }
        txCount[msg.sender]++;
        emit Multisended(total, address(0));
    }

    function withdraw() external {
        require(authorized[msg.sender] == true, "Only authorized can withdraw.");
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Failed to withdraw.");
    }

    function withdrawToken(address tokenContract) external {
        require(authorized[msg.sender] == true, "Only authorized can withdraw.");
        ERC20 withdrawTC = ERC20(tokenContract);
        withdrawTC.transfer(msg.sender, withdrawTC.balanceOf(address(this)));
    }

    function changeFee(uint _Fee) external {
        require(msg.sender == contractOwner, "Only contractOwner can make changes.");
        Fee = _Fee;
    }

    function changeFeeAddress(address _FeeAddress) external {
        require(msg.sender == contractOwner, "Only contractOwner can make changes.");
        FeeAddress = _FeeAddress;
    }

    function changeNewLimit(uint16 _newLimit) external {
        require(msg.sender == contractOwner, "Only contractOwner can make changes.");
        Limit = _newLimit;
    }

    function Auth(address AuthAddress) external {
        require(msg.sender == contractOwner, "Only contractOwner can give authorizations.");
        authorized[AuthAddress] = true;
    }

    function unAuth(address AuthAddress) external {
        require(msg.sender == contractOwner, "Only contractOwner can unauthorize.");
        authorized[AuthAddress] = false;
    }

    function transferContractOwnership(address newOwner) public payable {
        require(msg.sender == contractOwner, "Only contractOwner can change ownership of contract.");
        require(newOwner != address(0), "Ownable: new contractOwner is the zero address.");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = contractOwner;
        contractOwner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}