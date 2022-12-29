/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

contract BatchTransfer{
    event Multisended(uint256 total, address tokenAddress);
    event ClaimedTokens(address token, address owner, uint256 balance);

    address public _owner;
    uint256 private _arrayLimit;
    uint256 private _fee;
    mapping(address => bool) _isFeeExempt;

    function initialize() public {
        require(_owner == address(0));
        _owner = msg.sender;
        _arrayLimit = 10;
    }

    function arrayLimit() public view returns(uint256) {
        return _arrayLimit;
    }

    function setArrayLimit(uint256 value) external onlyOwner {
        require(value != 0);
        _arrayLimit = value;
    }

    function fee() public view returns(uint256) {
        return _fee;
    }

    function setFee(uint256 value) external onlyOwner {
        require(value != 0);
        _fee = value;
    }

    function userFee(address account) public view returns(uint256) {
        return _isFeeExempt[account] ? 0 : fee();
    }

    function multisendToken(address token, address[] memory _contributors, uint256[] memory _balances) external payable {
        if (token == address(0)){
            multisendEther(_contributors, _balances);
        } else {
            uint256 total = 0;
            require(msg.value >= userFee(msg.sender));
            require(_contributors.length <= arrayLimit());
            IERC20 erc20token = IERC20(token);
            uint8 i = 0;
            for (i; i < _contributors.length; i++) {
                erc20token.transferFrom(msg.sender, _contributors[i], _balances[i]);
                total += _balances[i];
            }
            if (userFee(msg.sender) > 0) _isFeeExempt[msg.sender] =  true;
            emit Multisended(total, token);
        }
    }

    function multisendEther(address[] memory _contributors, uint256[] memory _balances) public payable {
        uint256 total = msg.value;
        require(total >= userFee(msg.sender));
        require(_contributors.length <= arrayLimit());
        total = total - userFee(msg.sender);
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i]);
            total = total - _balances[i];
            payable(_contributors[i]).transfer(_balances[i]);
        }
        if (userFee(msg.sender) > 0) _isFeeExempt[msg.sender] =  true;
        emit Multisended(msg.value, 0x000000000000000000000000000000000000bEEF);
    }

    function removeTokens(address _token) external onlyOwner {
        if (_token == address(0)) {
            payable(_owner).transfer(address(this).balance);
            return;
        }
        IERC20 erc20token = IERC20(_token);
        uint256 balance = erc20token.balanceOf(address(this));
        erc20token.transfer(_owner, balance);
        emit ClaimedTokens(_token, _owner, balance);
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    receive() external payable {}
}