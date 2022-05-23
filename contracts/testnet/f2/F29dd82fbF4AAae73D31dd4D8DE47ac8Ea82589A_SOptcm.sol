// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./IToken.sol";

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract SOptcm is Context, Ownable {
    
    IToken public token;
    uint256 public burnAmount;
    uint256 public feeAmount;
    uint256 public rewardAmount;
    
    constructor(address _token) {
        token = IToken(_token);
    }

    function setPercent(uint256 _burnAmount, uint256 _feeAmount, uint256 _rewardAmount) external onlyOwner{
        burnAmount = _burnAmount;
        feeAmount = _feeAmount;
        rewardAmount = _rewardAmount;
    }

    function send(address _receiver, uint256 amount) external {
        uint256 _transferAmount = amount * (100 - burnAmount - feeAmount - rewardAmount) / 100;
        uint256 _feeAmount = amount * feeAmount / 100;
        uint256 _burnAmount = amount * burnAmount / 100;
        uint256 _rewardAmount = amount * rewardAmount / 100;

        token.transferFrom(msg.sender, _receiver, _transferAmount);
        token.transferFrom(msg.sender, owner(), _feeAmount);
        token.transferFrom(msg.sender, address(this), _rewardAmount);
        token.burnFrom(msg.sender, _burnAmount);
    }

    function sweep(address _token) external onlyOwner {
        uint256 _value = IToken(_token).balanceOf(address(this));
        IToken(_token).transfer(owner(), _value);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IToken {
    function approve(address to, uint256 amount) external;

    function transfer(address recipient, uint256 amount) external;

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;

    function balanceOf(address account) external view returns (uint256);

    function burnFrom(address account, uint256 amount) external;
}