// SPDX-License-Identifier: test

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Ownable.sol";

contract Token is ERC20,Ownable {

    uint256 public total = 50000000 * 10 ** 18;
    uint256 public fundDayReleaseAmount = 0;
    uint256 public technologyDayReleaseAmount = 0;
    address public fundReleaseAddress;
    address public technologyReleaseAddress;
    uint256 public startSellTime = 0;

    mapping (address => bool) swapAddress;
    mapping (uint256 => uint256) private releaseMapping; // time=>amount


   
    constructor(address addr,address fundReleaseAddress_,address technologyReleaseAddress_) ERC20("Plant","Plant"){
        uint256 fundAmount = total * 5 / 10 ** 2;
        uint256 technologyAmount = total * 10 / 10 ** 2;
        super._mint(addr, total - fundAmount - technologyAmount);
        //Lock release
        super._mint(address(this),fundAmount);
        super._mint(address(this),technologyAmount);
        fundDayReleaseAmount = fundAmount / (36*30);
        technologyDayReleaseAmount = technologyAmount / (36*30);
        fundReleaseAddress = fundReleaseAddress_;
        technologyReleaseAddress = technologyReleaseAddress_;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override{
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;
        _release();

        emit Transfer(sender, recipient, amount);
        _afterTokenTransfer(sender, recipient, amount);
    }

    function _release() internal {
        if(releaseMapping[zeroHourCalculation(block.timestamp)] > 0) return;
        if(_balances[address(this)] > fundDayReleaseAmount){
            _balances[address(this)] -= fundDayReleaseAmount;
            _balances[fundReleaseAddress] += fundDayReleaseAmount;
            releaseMapping[zeroHourCalculation(block.timestamp)] += fundDayReleaseAmount;
            emit Transfer(address(this),fundReleaseAddress,fundDayReleaseAmount);
        }
        if(_balances[address(this)] > technologyDayReleaseAmount){
            _balances[address(this)] -= technologyDayReleaseAmount;
            _balances[technologyReleaseAddress] += technologyDayReleaseAmount;
            releaseMapping[zeroHourCalculation(block.timestamp)] += technologyDayReleaseAmount;
            emit Transfer(address(this),technologyReleaseAddress,technologyDayReleaseAmount);
        }
    }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override virtual{
        if(from == address(0) || amount < 1) return;
        if(block.timestamp >= startSellTime) return;
        require(!swapAddress[to],"Sale time not reached");
    }
    
    function setStartSellTime(uint256 time)public onlyOwner{
        startSellTime = time;
    }

    function setSwapAddress(address account,bool flag) public onlyOwner{
        swapAddress[account] = flag;
    }

    function setFundReleaseAddress(address account)public onlyOwner{
        fundReleaseAddress = account;
    }
    function setTechnologyReleaseAddress(address account)public onlyOwner{
        technologyReleaseAddress = account;
    }
    
    function zeroHourCalculation(uint256 time) internal pure returns(uint256){
        return time - (time+28800) % 1 days;
    }

    
}