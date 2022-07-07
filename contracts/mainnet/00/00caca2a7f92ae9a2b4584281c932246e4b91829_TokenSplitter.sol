/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.4;

// Deployed by @CryptoSamurai031 - Telegram user

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract TokenSplitter is Context, Ownable {
    address public token;
    address[] public recipients;
    uint256 public totalPercentage;
    uint256 public percentageDivisor = 10000;

    mapping(address => uint256) public shares;
    mapping(address => bool) public canDistribute;

    /// @param percentages_ share of recipient, up to 2 decimal digits. Set it * 10^2, e.g. 10% => 1000
    constructor (address token_, address[] memory recipients_, uint256[] memory percentages_) {
        require(recipients_.length == percentages_.length, "Unequal recipient and share arrays length");
        token = token_;

        for(uint256 i = 0; i < recipients_.length; i++) {
            shares[recipients_[i]] = percentages_[i];
            recipients.push(recipients_[i]);
            totalPercentage += percentages_[i];
            canDistribute[recipients_[i]] = true;
        }

        // Allow owner to distribute
        canDistribute[_msgSender()] = true;
    }

    /// @dev It is recommended to set it to 10000 to be able to adjust fees up to 2 decimals
    function setPercentageDivisor(uint256 divisor) external onlyOwner {
        require(divisor % 100 == 0, "Divisor must be multiple of 100");
        percentageDivisor = divisor;
    }

    function setTokenAddress(address tokenAddress) external onlyOwner {
        token = tokenAddress;
    }

    function rescueLockTokens(address tokenAddress, uint256 weiAmount) external onlyOwner {
        IERC20(tokenAddress).transfer(_msgSender(), weiAmount);
    }

    function rescueLockContractBNB(uint256 weiAmount) external onlyOwner {
        (bool sent, ) = payable(_msgSender()).call{value: weiAmount}("");
        require(sent, "Failed to rescue");
    }

    /// @dev Delete previous recipient list
    /// @param percentages_ share of recipient, up to 2 decimal digits. Set it * 10^2, e.g. 10% => 1000
    function addMultipleRecipients(address[] calldata recipients_, uint256[] calldata percentages_) external onlyOwner{
        require(recipients_.length == percentages_.length, "Unequal recipient and share arrays length");

        // Remove previous recipients
        delete recipients;
        totalPercentage = 0;
        for(uint256 i = 0; i < recipients_.length; i++) {
            _addRecipient(recipients_[i], percentages_[i]);
        }

    }

    /// @dev The new recipient should not previously exists
    /// @param percentage share of recipient, up to 2 decimal digits. Set it * 10^2, e.g. 10% => 1000
    function addRecipient(address recipient, uint256 percentage) external onlyOwner {
        require(shares[recipient] == 0, "Recipient already exists");
        _addRecipient(recipient, percentage);
    }

    // TODO check if works without passing to memory first
    function getRecipientList() external view returns (address[] memory){
        // address[] memory recipients_ = recipients;
        return recipients;
        // return recipients_;
    }

    function getRecipientsShares() external view returns (address[] memory recipients_, uint256[] memory shares_){
        // address[] memory recipients_ = recipients;
        recipients_ = recipients;
        uint256 recipientsNumber = recipients.length;
        // uint256[] memory shares_ = new uint256[](recipientsNumber);
        shares_ = new uint256[](recipientsNumber);

        for(uint256 i = 0; i < recipientsNumber; i++) {
            shares_[i] = shares[recipients_[i]];
        }
        // return recipients;
    }

    /// @notice Get the index of the account by calling getRecipientList before
    function removeRecipient(uint256 index) external onlyOwner {
        address wallet = recipients[index];
        uint256 percentage = shares[wallet];
        totalPercentage -= percentage;
        shares[wallet] = 0;
        canDistribute[wallet] = false;

        // Remove recipient from array (order unimportant)
        uint256 lastRecipient = recipients.length - 1;
        recipients[index] = recipients[lastRecipient];
        recipients.pop();
    }

    /// @dev The recipient should already exists
    function setShare(address recipient, uint256 percentage) external onlyOwner {
        require(shares[recipient] > 0, "Recipient does not exist");
        shares[recipient] = percentage;
    }

    function distribute() external {
        require(canDistribute[_msgSender()], "Caller can not distribute");
        address to;
        uint256 percentage;
        uint256 shareAmount;
        uint256 totalAmount = address(this).balance;

        for(uint256 i = 0; i < recipients.length; i++) {
            to = recipients[i];
            percentage = shares[to];

            if (percentage > 0) {
                shareAmount = totalAmount * percentage / percentageDivisor;
                payable(to).transfer(shareAmount);
            }
        }
    }

    function setDistributePower(address wallet, bool enable) external onlyOwner {
        canDistribute[wallet] = enable;
    }

    function _addRecipient(address recipient, uint256 percentage) private {
        // require(shares[recipient] == 0, "Recipient already exists");
        totalPercentage += percentage;
        // require(totalPercentage <= 10000, "Total percentage different than 10000 (100%)");

        shares[recipient] = percentage;
        recipients.push(recipient);
        canDistribute[recipient] = true;
    }
    receive() external payable {}

}