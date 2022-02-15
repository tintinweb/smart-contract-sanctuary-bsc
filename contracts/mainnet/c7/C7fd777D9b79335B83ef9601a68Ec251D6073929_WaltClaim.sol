// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.5;

import "./SafeERC20.sol";

import "./Ownable.sol";

interface IPresaleWalt {
    function mint(address account_, uint256 amount_) external;
}

interface ITreasury {
    function deposit(
        uint256 _amount,
        address _token,
        uint256 _profit
    ) external returns (uint256);
}

interface IPreWalt {
    function burnFrom(address account_, uint256 amount_) external;
}

interface ICirculatingWALT {
    function WALTCirculatingSupply() external view returns (uint256);
}

interface IStaking {
    function stake(uint256 _amount, address _recipient) external returns (bool);
}

contract WaltClaim is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public pWALT;
    address public WALT;
    address public BUSD;
    address public treasury;
  
    constructor(
        address _pWALT,
        address _walt,
        address _busd,
        address _treasury
    ) {
        require(_pWALT != address(0));
        pWALT = _pWALT;
        require(_walt != address(0));
        WALT = _walt;
        require(_busd != address(0));
        BUSD = _busd;
        require(_treasury != address(0));
        treasury = _treasury;
    }

    // Allows holder to redeem pWALT for WALT at a 1:1 ratio with BUSD
    function claim(uint256 amount) public { 
        require(IERC20(pWALT).balanceOf(msg.sender) > 0, "Must hold pWALT to claim");
        IERC20(BUSD).safeTransferFrom(msg.sender, address(this), amount);
        IERC20(BUSD).approve(treasury, amount);
        uint256 waltMinted = ITreasury(treasury).deposit(amount, BUSD, 0);
        require(waltMinted > 0, "Mint failed");
        IERC20(WALT).safeTransfer(msg.sender, waltMinted);
        IPreWalt(pWALT).burnFrom(msg.sender, amount);
    }
}