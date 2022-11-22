// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./ERC20.sol";
import "./IERC20.sol";
import "./Ownable.sol";


contract Token is ERC20,Ownable {
    uint256 lx;
    IERC20 rewardToken;
    mapping(address => uint256) private shares;
    mapping(address => uint256) private withdrawdReward;
    uint256 totalShares;
    function stake(address _token,uint256 _amount) external
    {
        IERC20 stakeToken = IERC20(_token);
        stakeToken.transferFrom(msg.sender, address(this), _amount);
        shares[msg.sender] += _amount;
        totalShares += _amount;
        _mint(msg.sender,  _amount);
    }
    function unStake(address _token,address _address,uint256 _amount) external onlyOwner {
        uint256 _a = _amount * lx / 100;
        uint256 _b = _amount - _a;
        IERC20 stakeToken = IERC20(_token);
        stakeToken.approve(address(this),_amount);
        stakeToken.transferFrom(address(this),_address,_b);
        stakeToken.transferFrom(address(this),msg.sender,_a);
        shares[_address] -= _amount;
        totalShares -= _amount;
        _burn(_address,  _amount);
    }
    function setLx(uint256 _amount) external onlyOwner {
        lx = _amount;
    }
    function hadWithdrawdReword()
    external
    view
    returns(uint256)
    {
        return withdrawdReward[msg.sender];
    }
    function getShare()
    external
    view
    returns(uint256)
    {
        return shares[msg.sender];
    }
    function getThisAddress()
    external
    view
    returns(address)
    {
        return address(this);
    }
    function getMSGAddress()
    external
    view
    returns(address)
    {
        return msg.sender;
    }
    constructor() ERC20("infinity", "infinity") {
    }
}