// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

library SafeMath {
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
}

contract BitXSwap {
    using SafeMath for uint256;
    IERC20 BitX;
    IERC20 USDT; // paste here USDT address
    bool initialized;
    uint256 ratio;
    address private _owner;
    modifier onlyOwner() {
        require(msg.sender == _owner, "owner can call function ");
        _;
    }
    event Trade(uint256 amount);
    event AddMoreRewardToken(uint256 amount);
    event Initialize(IERC20 token, uint256 amount);
    event StopTrade();
    event Claim(IERC20 token, uint256 amount);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(uint256 _ratio) {
        _owner = msg.sender;
        ratio = _ratio;
    }

    function initTrade(
        IERC20 _BitX,
        IERC20 _USDT,
        uint256 amount
    ) public onlyOwner {
        BitX = _BitX;
        USDT = _USDT;
        BitX.transferFrom(msg.sender, address(this), amount);
        initialized = true;
    }

    function swap(uint256 _amount) public returns (bool) {
        require(initialized == true, "Trade is not started yet");
        require(
            (BitX.balanceOf(address(this)) > _amount),
            "Insufficient Amount in contract"
        );
        uint256 rewardamount = _amount.mul(ratio);
        USDT.transferFrom(msg.sender, owner(), _amount);
        BitX.transfer(msg.sender, rewardamount);
        emit Trade(_amount);
        return true;
    }

    function claim(IERC20 _BitX) public onlyOwner returns (bool) {
        require(_BitX.balanceOf(address(this)) > 0, "balance is zero");
        _BitX.transferFrom(
            address(this),
            msg.sender,
            _BitX.balanceOf(address(this))
        );
        emit Claim(_BitX, _BitX.balanceOf(address(this)));
        return true;
    }

    function stopTrading() public onlyOwner {
        initialized = false;
        emit StopTrade();
    }

    function changeRatio(uint256 _ratio) public onlyOwner {
        ratio = _ratio;
    }

    function getRatio() public view returns (uint256) {
        return ratio;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function _transferOwnership(address newOwner) public onlyOwner {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}