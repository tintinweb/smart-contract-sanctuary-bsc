// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ILpToken.sol";
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

contract LPStaking is Context, Ownable {
    struct LPTokenInfo {
        uint256 stakeAmount;
        uint stakeTime;
        bool farmingType;
    }

    IToken public token;
    mapping(address => LPTokenInfo) public lpTokens;

    ILPToken public lpToken;
    // IToken public token1;
    IToken public token2;
    bool public farmingType;
    uint256 private apy;


    constructor(address _lpToken, address _token2, uint256 _apy) {
        lpToken = ILPToken(_lpToken);
        // token1 = IToken(_token1);
        token2 = IToken(_token2);
        apy = _apy;
    }

    function deposit(uint256 amount, bool _farmingType) external {
        uint256 _amount = lpToken.balanceOf(msg.sender);
        require(_amount >= amount, 'The wallet has less amount');
        LPTokenInfo storage _lpToken = lpTokens[msg.sender];
        _lpToken.stakeAmount = amount;
        _lpToken.stakeTime = block.timestamp;
        _lpToken.farmingType = _farmingType;
        lpToken.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw() external {
        uint _curTime = block.timestamp;
        LPTokenInfo storage _lpToken = lpTokens[msg.sender];
        require(_lpToken.stakeAmount >= 0, 'Nothing to withdraw');
        if(_lpToken.farmingType == true) 
            require(_curTime - 60 * 10 >= _lpToken.stakeTime, '10mins not passed yet');
        uint256 _rewardAmount = _lpToken.stakeAmount * (_curTime - _lpToken.stakeTime) / (3600 * 24 * 365) * apy / 100;
        lpToken.transfer(msg.sender, _lpToken.stakeAmount);
        uint256 _curAmount = token2.balanceOf(msg.sender);
        require(_curAmount >= _rewardAmount, 'There is not enough reward tokens.');
        token2.transfer(msg.sender, _rewardAmount);
    }

    function claim(uint256 _amount) external {
        uint _curTime = block.timestamp;
        LPTokenInfo storage _lpToken = lpTokens[msg.sender];
        require(_lpToken.stakeAmount >= _amount, 'Not enough amount for claim');
        if(_lpToken.farmingType == true)
            require(_curTime - 60 * 10 >= _lpToken.stakeTime, '10mins not passed yet');
        uint256 _rewardAmount =  _amount * (_curTime - _lpToken.stakeTime) / (3600 * 24 * 365) * apy / 100;
        lpToken.transfer(msg.sender, _amount);
        _lpToken.stakeAmount -= _amount;
        uint256 _curAmount = token2.balanceOf((msg.sender));
        require(_curAmount >= _rewardAmount, 'There is not enough reward tokens.');
        token2.transfer(msg.sender, _rewardAmount);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface ILPToken {
    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function burnFrom(address account, uint256 amount) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IToken {
    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function burnFrom(address account, uint256 amount) external;

}