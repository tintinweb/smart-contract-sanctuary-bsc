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

contract Staking is Context, Ownable {
    struct SInfo {
        uint256 amount;
        uint256 stakingTime;
        uint256 claimAmount;
    }

    IToken public token;
    uint256 public period;
    mapping(address => SInfo) public stakings;

    constructor(address _token) {
        token = IToken(_token);
        period = 60;
    }

    function setPeriod(uint256 _period) external onlyOwner {
        period = _period;
    }

    function stake(uint256 amount) external {
        require(
            amount * 2 <= token.balanceOf(address(this)),
            "Cannot stake over 50% amount of Contract"
        );
        token.transferFrom(msg.sender, address(this), amount);
        SInfo storage _sinfo = stakings[msg.sender];
        _sinfo.amount = amount;
        _sinfo.stakingTime = block.timestamp;
        _sinfo.claimAmount = amount * 10;
    }

    function claim(uint256 claimAmount) external {
        SInfo storage _sinfo = stakings[msg.sender];
        require(_sinfo.claimAmount > 0, "There is no claimable Amount");
        require(
            block.timestamp >= _sinfo.stakingTime + period,
            "Not Claim Time"
        );
        uint256 _claimableAmount = claimableAmount(msg.sender);
        require(_claimableAmount >= claimAmount, "Claim Amount is too much");
        uint256 _turn = (block.timestamp - _sinfo.stakingTime) / period;
        uint256 _transferamount = 0;
        // if (_sinfo.claimAmount <= (_sinfo.amount * _turn) / 2 * 5) {
        //     _transferamount = _sinfo.claimAmount;
        //     _sinfo.claimAmount = 0;
        // } else {
        //     _transferamount = (_sinfo.amount * _turn) / 2 * 5;
        //     _sinfo.claimAmount -= (_sinfo.amount * _turn) / 2 * 5;
        // }

        if (_sinfo.claimAmount <= claimAmount) {
            _transferamount = _sinfo.claimAmount;
            _sinfo.claimAmount = 0;
        } else {
            _transferamount = claimAmount;
            _sinfo.claimAmount -= claimAmount;
        }

        token.transfer(msg.sender, _transferamount);

        _sinfo.stakingTime = _sinfo.stakingTime + _turn * period;
    }

    function claimableAmount(address account) public view returns (uint256) {
        SInfo storage _sinfo = stakings[account];
        uint256 _turn = (block.timestamp - _sinfo.stakingTime) / period;
        uint256 _transferamount = 0;
        if (_sinfo.claimAmount <= (_sinfo.amount * _turn) / 2 * 5) {
            _transferamount = _sinfo.claimAmount;
            // _sinfo.claimAmount = 0;
        } else {
            _transferamount = (_sinfo.amount * _turn) / 2 * 5;
            // _sinfo.claimAmount -= (_sinfo.amount * _turn) / 2 * 5;
        }
        return _transferamount;
    }

    function isClaimable(address account) external view returns (bool) {
        SInfo storage _sinfo = stakings[account];
        if (_sinfo.claimAmount > 0) {
            if (block.timestamp >= _sinfo.stakingTime + period) {
                return true;
            }
        }
        return false;
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
}